*! version 2.1 xtewreg estimates an Erickson-Whited linear errors-in-variables model of arbitrary degree

/*

Author: Robert Parham, University of Rochester

http://kn.owled.ge


*/


capture program drop xtewreg
program define xtewreg, eclass
	version 12
	//syntax varlist(min=2 numeric) [if] [in] , MAXDeg(integer) [MISmeasured(integer 1)  METHod(string) PANmethod(string) BXint(numlist) HAScons NOcons NOPRN VCE(string) OPTim(integer 2) CENTmom(string)]
	syntax varlist(min=2 numeric) [if] [in] , MAXDeg(integer) [MISmeasured(integer 1)  METHod(string) PANmethod(string) BXint(numlist) CENTmom(string) HAScons NOcons NOPRN]
	marksample touse

	local optim = 2

	quietly count if `touse'
	if `r(N)' == 0 error 2000
	
	if (`mismeasured'<1) {
		di as err "Option <mismeasured> is required to be at least 1. Aborting."
		exit 197
	}
	if (`maxdeg'<3) {
		di as err "Option <maxdeg> is required to be at least 3. Aborting."
		exit 197
	}
	if (`optim'!=1 & `optim'!=2) {
		di as err "Option <optim> is required to be either 1(DFP) or 2(GN). Aborting."
		exit 197
	}
	
	local vce = strupper("`vce'")
	if ("`vce'"=="" | "`vce'"=="TWOSTEP") 	local vcemet = 0
	else if ("`vce'"=="OLS") 				local vcemet = 1
	else {
		di as err "Unknown value provided for VCE. Aborting."
		exit 197
	}

	local centmom = strupper("`centmom'")
	if ("`centmom'"=="" | "`centmom'"=="RESET") local centmet = 0
	else if ("`centmom'"=="SET") 				local centmet = 1
	else if ("`centmom'"=="USE") 				local centmet = 2
	else {
		di as err "Unknown value provided for CentMom. Aborting."
		exit 197
	}
	

	// separate varlist
	gettoken depvar varlist: varlist
	local wc = wordcount("`varlist'")
	if (`wc'<`mismeasured') {
		di as err "Less regressors provided than specified in option <mismeasurd>. Aborting."
		exit 197
	}
	local misindep = ""
	forvalues i=1/`mismeasured' {
		gettoken mis varlist: varlist
		local misindep = "`misindep' `mis'"
	}
	local indep = "`varlist'"

	// verify bxint
	if ("`bxint'"!="" & ///
		wordcount("`bxint'")/`mismeasured'!=round(wordcount("`bxint'")/`mismeasured')) {
		di as err "If BXint is specified, it must have c*<mismeasured> members for some integer c. Aborting."
		exit 197
	}
	if "`bxint'"=="" local bxint = "0"

	// parse method
	local method = strupper("`method'")
	if ("`method'"=="" | "`method'"=="CML") {
		local met = 0
	}
	else if ("`method'"=="MOM" | "`method'"=="GMM") {
		local met = 1
	}
	else {
		di as err "Unknown value provided for METHOD. Aborting."
		exit 197
	}
	
	// parse panmethod
	local panmethod = strupper("`panmethod'")
	if ("`panmethod'"=="" | "`panmethod'"=="CLS") {
		local clustmet = 0
	}
	else if ("`panmethod'"=="CMD") {
		local clustmet = -1
	}
	else if ("`panmethod'"=="IDN") {
		local clustmet = 1
	}
	else if ("`panmethod'"=="NON") {
		local clustmet = 2
	}
	else {
		di as err "Unknown value provided for PANMETHOD. Aborting."
		exit 197
	}
	
	// parse hascons / nocons
	if ("`hascons'"=="" & "`nocons'"=="") {
		local docons = 1
	}
	else {
		local docons = 0
	}
	
	if ("`nocons'"!="") {
		local nocons1 = 1
	}
	else {
		local nocons1 = 0
	}

	qui: xtset
	local idname `r(panelvar)'
	local tmname `r(timevar)'

	if "`idname'" == "" {
		di "Warning: xtset was not run before this [XT] command. Use xtset <panel variable>. Continuing without clustering."
	}
	if "`tmname'" == "" & `clustmet'==-1 {
		di as error "Error: xtset was not used to set a time variable for panmethod(CMD) to use. Aborting.\n"
		exit(197)
	}
	
	tempname b V cst
	mata: doEW("`depvar'", "`misindep'", "`indep'", "`idname'", "`tmname'", `met', `clustmet', `maxdeg', "`bxint'", 0, `docons', `nocons1', `optim',  `centmet', "`touse'")
	local cst = cond(`docons' == 1, "_cons", "")
	local vnames `misindep' `indep' `cst'
	mat `b' = r(beta)
	mat `V' = r(VCmat)
	matname `V' `vnames'
	matname `b' `vnames', c(.)
	local N = r(N)
	ereturn post `b' `V', depname(`depvar') obs(`N') esample(`touse')

	ereturn scalar rho = r(rho)
	ereturn matrix tau = tau
	ereturn matrix serr  = serr
	ereturn scalar SErho = r(SErho)
	ereturn matrix SEtau = SEtau
	ereturn matrix vcrhotau  = vcrhotau
	ereturn matrix w  = w
	ereturn local  bxint = "`bxint'"
	ereturn local  vcetype = "`vce'"
	ereturn local  panmethod = "`panmethod'"
	ereturn scalar Jstat = r(Jstat)
	ereturn scalar Jval = r(Jval)
	ereturn scalar dfree = r(dfree)
	ereturn scalar obj = r(obj)
	ereturn matrix IDval = IDval
	ereturn matrix IDstat = IDstat
	

	if ("`noprn'"=="") {
		display _newline "`method'`maxdeg'(`mismeasured') EIV results" _col(65) "N = " %9.0g e(N)
		display _col(65) "Rho^2 = " %5.3f r(rho)
		display _col(65) "       (" %5.3f r(SErho) ")"
		ereturn display
		forvalues i=1/`mismeasured' {
			display "Tau" `i' "^2: " %5.3f el(e(tau),`i',1) " (" %5.3f el(e(SEtau),`i',1) ")"
		}
		if ( e(Jstat) > 0 ) {
			display "Sargan-Hansen J statistic: " %7.3f e(Jstat) ///
					"   (p=" %5.3f e(Jval) ", d=" e(dfree) ")"
		}
	}

end



version 12

mata: mata clear









































///////////////////////////////////////////////////////////////////////////////////////
// Partitions.mata
///////////////////////////////////////////////////////////////////////////////////////

mata:

// define Partitions class
class Partitions {
	private:
		real scalar D
		real scalar P
		real matrix PMAT
		static real scalar CURR
		
		real rowvector 				getpartvec()
		real colvector 				nextpart()
		real colvector				nextexp()
		
	public:
		void 						einit()
		real scalar 				getP()
		real colvector 				getnext()
		real matrix 				expand()
		real colvector				sub()
}
// end class


// return a number of parts per cumulant degree vector (e.g. f(4)=15)
real rowvector Partitions::getpartvec()
{
	/* These functions are adapted from Hankin RKS (2005). “Additive integer partitions in R.”,
	Journal of Statistical Software, Code Snippets, 16(1) */
	
	p = J(1,D,0)
	p[1,1] = 1
	p[1,2] = 1
	for (i=3 ; i<=D ; i++)
	{
		// first do r = m(3m+1)/2
		s = 1  /* "s" for "sign" */
		f = 5  /* f is first difference  */
		r = 2  /* initial value (viz m(3m+1)/2 for m=1) */

		p[1,i] = 0
		while(i-r >= 1)
		{
			p[1,i] = p[1,i] + s*p[1,i-r]
			r = r+f
			f = f+3  /* 3 is the second difference */
			/* change sign of s */
			s = s*(-1)
		}
		/* now do r = m(3m-1)/2 */
		s = 1
		f = 4 /*first difference now 4 */
		r = 1 /* initial value (viz m(3m-1)/2 for m=1) */
		while(i-r >= 1)
		{
			p[1,i] = p[1,i] + s*p[1,i-r];
			r = r+f
			f = f+3  /* 3 is the second difference */
			s = s*(-1)
		}
	}
	
	return (p)
}
// end get_partvec


// build the next parts vector given the current one
real colvector Partitions::nextpart(real scalar ind)
{
	x = PMAT[.,ind]'
	
	a=1
	while(x[1,a] > 0) {
		a++
	}
	a-- 					/* a: pos of last nonzero */
	
	b=a
	while(x[1,b] == 1){
		b--
	}

	if(x[1,a]>1){ 			/* if last nonzero number >1 */
		x[1,a] = x[1,a]-1 	/* subtract one from it */
		x[1,a+1] = 1 		/* and put a 1 next to it */
		return (x')
	}
	
	n = a-b   				/* n: number of 1s*/
	x[1,b] = x[1,b]-1 		/* decrement final nonzero digit (perforce >1) */
	yy = x[1,b]				/* and prepare to replicate it as many times as possible */
	n++;					/* n is now number of 1s plus 1 (thus "n" is to
							 * to be distributed as "evenly" as possible
							 * after x[a]) */
	j = b
	while(n >= yy){			/* distribute n among elements x[b] onwards */
		j++
		x[1,j] = yy			/* by repeatedly adding yy elements until no longer */
		n = n-yy       		/* possible */
	}
	if(n > 0){
		j++
		x[1,j] = n			/* add the remainder to x */
	}
	while(j < a){			/* set remaining elements to 0 */
		j++
		x[1,j] = 0
	}
	
	return (x')
}
// end nextpart


// take partition-specific exp, "advance by one", return. return J(1,1,-1) if last exp
real colvector Partitions::nextexp(real colvector exp, real colvector begvec, real colvector pt)
{
	/* if only one group, return */
	if (rows(begvec)==1) return (J(1,1,-1))
	
	
	/* try advancing tail */
	res = nextexp(exp[begvec[2,1]..rows(exp),1],begvec[2..rows(begvec),1]:-(begvec[2,1]-1), pt[2..rows(pt),1])
	if (res[1,1]!=-1) return (exp[1..(begvec[1,1]+pt[1,1]),1] \ res)
	
	
	/* advance first group, initialize tail */
	uid = sort(uniqrows(exp),1)
	uid = uid[2..rows(uid)] 			// get rid of -1
	
	// last cell of first group
	j = begvec[1,1]+pt[1,1]-1
	
	// find cell to increase in first block
	for(pos=rows(uid);j>0;j--,pos--) {
		if (exp[j]!=uid[pos]) break		
	}
	// no cell left to increase in first block
	if (j==0) return (J(1,1,-1))

	// increase cell
	for(;exp[j]!=uid[pos];pos--){}		
	pos++
	exp[j]=uid[pos]
	
	// remove first block members upto j from uid
	good = J(rows(uid),1,1)
	for(i=j;i>0;i--){
		for(;exp[i]!=uid[pos];pos--){}
		good[pos] = 0
	}
	uid = select(uid,good)
	
	// first block must be index-increasing
	if (exp[j+1]!=-1) {
		for (;uid[pos]<=exp[j];pos++) {}
		j++
		good = J(rows(uid),1,1)
		for (;exp[j]!=-1;j++) {
			exp[j]=uid[pos]
			good[pos]=0
			pos++
		}
		uid = select(uid,good)
	}

	// spread what's left orderly across non(-1) members of exp
	for (i=1;i<=rows(uid);i++) {
		if (exp[j+i]==-1) j++
		exp[j+i] = uid[i]
	}
	
	return (exp)
}
// end next_exp


// initialize a partition
void Partitions::einit(real scalar deg)
{
	assert (deg>=2)
	
	D = deg
	pvec = getpartvec()
	P = pvec[1,D]
	PMAT = J(D,P,0)
	CURR = 0
	PMAT[1,1] = D
	for(i=2 ; i<=P ; i++){
		PMAT[.,i] = nextpart(i-1)
	}
}
// end init


// return the number of partitions
real scalar Partitions::getP()
{
	assert (D!=.)
	return (P)
}
// end getP


// return next partition
real colvector Partitions::getnext()
{
	assert (D!=. & CURR <= P)
	CURR++
	return (PMAT[.,CURR])
}
// end getnext


// return a matrix whose columns are raw exp vectors (implement [k] in tensor notation)
real matrix Partitions::expand(real colvector pt)
{
	D2 = 2*D
	ngrp = sum(pt:!=0)
	retval = J(D2,1,-1)
	logeq = 0

	// build block beginning vector for pt
	begvec = J(ngrp,1,1)
	for (i=2;i<=ngrp;i++) {
		begvec[i,1] = begvec[i-1,1]+pt[i-1,1]+1
	}

	// fill the first exp
	for (i=1;i<=ngrp;i++) {
		curgrp = (begvec[i,1]-i+1)..(sum(pt[1..i,1]))
		curidx = (begvec[i,1])..(begvec[i,1]+pt[i,1]-1)
		retval[curidx,1] = curgrp'
	}

	// fill the rest of them
	while (1) {
		tmp = nextexp(retval[.,cols(retval)], begvec, pt)
		if (tmp[1,1]==-1) break
		retval = retval, tmp
	}
	
	// verify all generated exps
	good = J(1,cols(retval),1)
	for (ie=1;ie<=cols(retval);ie++) {
		
		// verify exp obeys the index order condition for same sized blocks
		keepexp = 1
		for (i=1;i<ngrp & keepexp==1;i++) {
			for(j=i+1;j<=ngrp;j++) {
				if (pt[i]!=pt[j]) continue
				if (retval[begvec[i,1],ie] > retval[begvec[j,1],ie]) {
					keepexp = 0
					break
				}
			}
		}
		if (!keepexp) good[1,ie] = 0
	}
	
	retval = select(retval,good)

	return (retval)
}
// end expand


// get a mapping vector and an exp, sub map into exp
real colvector Partitions::sub(real colvector exp, real colvector map) {
	assert(max(exp)==rows(map))
	retval = J(rows(exp),1,-1)
	for (i=1;i<=rows(exp);i++) {
		if (exp[i] == -1) continue
		retval[i] = map[exp[i]]
	}
	
	return (retval)
}
// end sub

end





///////////////////////////////////////////////////////////////////////////////////////
// Symbolic.mata
///////////////////////////////////////////////////////////////////////////////////////

mata:

// represent a symbolic equation
class Symbolic {
	private:
		real matrix loc					// [N,T] - each column is a location vector for a term
										// loc holds the power of each variable in the term [N,1]
		numeric rowvector A				// [1,T]
		real scalar N					// number of variables in the multinomial
		real scalar T					// number of terms in the equation
		
		numeric scalar 				colmul()
		numeric colvector 			matmul()
		transmorphic matrix			del_mem()
		
	public:
		void 						einit()
		real scalar 				getN()
		real scalar 				getT()
		numeric rowvector 			getA()
		real matrix					getloc()
		void 						print()
		void 						addterm()
		void 						delterm()
		void 						replaceterm()
		numeric scalar 				eval()
		numeric colvector 			evalmat()
		numeric scalar 				partialeval()
		class Symbolic colvector	getgrad()
		class Symbolic matrix		gethess()
		void 						addeq()
		void 						muleq()
}
// end class


// return the multiplication of all members of a column vector
numeric scalar Symbolic::colmul(numeric colvector vec)
{
	// better to do this in a bi-section method for numerical stability, at some point
	total = 1
	for (i=1;i<=rows(vec);i++) {
		total=total*vec[i,1]
	}
	
	return (total)
}
// end function colmul


// return the multiplication of all rows of a matrix
numeric colvector Symbolic::matmul(numeric matrix mat)
{
	// better to do this in a bi-section method for numerical stability, at some point
	total = J(rows(mat),1,1)
	
	for (i=1;i<=cols(mat);i++) {
		total = total:*mat[.,i]
	}
	
	return (total)
}
// end function colmul


// remove a member at any position in a rowvector
transmorphic matrix Symbolic::del_mem(transmorphic matrix mt, real scalar to_del) {
	assert(to_del>=1 & to_del<=cols(mt))
	
	sel = J(1,cols(mt),1)
	sel[1,to_del] = 0
	return (select(mt,sel))
}
// end function mem_del


// initialize the equation, sets T=0 and sets N
void Symbolic::einit(real scalar n)
{
	assert (N==round(N) & N>0)
	T = 0
	N = n
	loc = J(N,0,0)
	A = J(1,0,0)
}
// end einit


// return N value
real scalar Symbolic::getN()
{
	return (N)
}
// end getN


// return T value
real scalar Symbolic::getT()
{
	return (T)
}
// end getT


// return the a of specific term or all of them
numeric rowvector Symbolic::getA(real scalar tr)
{
	assert (T>0 & tr==round(tr) & tr>=0 & tr<=T)
	if (tr==0) return (A)
	return (A[1,tr])
}
// end getA


// return the loc of specific term or all of them
real matrix Symbolic::getloc(real scalar tr)
{
	assert (T>0 & tr==round(tr) & tr>=0 & tr<=T)
	if (tr==0) return (loc)
	return (loc[.,tr])
}
// end getloc


// print equation
void Symbolic::print(real scalar verbosity)
{
	if (verbosity==0) return
	
	if (T==0) printf("[empty]")
	
	for (tr=1;tr<=T;tr++) {
		printf ("%g*",A[1,tr])
		for (j=1;j<=N;j++) {
			po = loc[j,tr]
			if (po != 0) {
				printf ("[%g]^%g",j,po)
				if (j<N) printf("*")
			}
		}
		if (tr<T) printf(" + ")
	}
	printf ("\n")
}
// end print


// add a term to equation - might be first term!
void Symbolic::addterm(numeric scalar a, real colvector locv)
{
	assert (a!=0 & rows(locv)==N)

	A = A, a
	loc = loc, locv
	T++
}
// end addterm


// replace a term in equation
void Symbolic::replaceterm(real scalar tr, numeric scalar a, real colvector locv)
{
	assert (a!=0 & rows(locv)==N & T>0 & tr==round(tr) & tr>0 & tr<=T)

	A[1,tr] = a
	loc[.,tr] = locv
}
// end replaceterm


// delete a term from equation - might leave it empty!
void Symbolic::delterm(real scalar tr)
{
	assert (T>0 & tr==round(tr) & tr>0 & tr<=T)
	
	A = del_mem(A,tr)
	loc = del_mem(loc,tr)
	T--
}
// end delterm


// evaluate equation at V=vars
numeric scalar Symbolic::eval(numeric colvector vars)
{
	assert (rows(vars)==N)
	
	numeric scalar retval
	retval = 0
	
	if (T==0 | T==.) return (retval)

	for (tr=1;tr<=T;tr++) {
		retval = retval + A[1,tr]*colmul(vars:^loc[.,tr])
	}
	
	return (retval)
}
// end eval


// evaluate equation at V=vars
numeric colvector Symbolic::evalmat(numeric matrix vars)
{
	assert (cols(vars)==N)

	numeric colvector retval
	retval = J(rows(vars),1,0)
	
	if (T==0 | T==.) return (retval)
	
	for (tr=1;tr<=T;tr++) {
		retval = retval :+ A[1,tr]*matmul(vars:^loc[.,tr]')
	}
	
	return (retval)
}
// end eval


// evaluate equation at a partial vector. return the constant term resulting or 0
numeric scalar Symbolic::partialeval(numeric colvector vars)
{
	assert (rows(vars)==N)
	//vars
	
	numeric scalar cst
	cst = 0
	if (T==0 | T==.) return (cst)

	todel = J(1,0,0)
	for (tr=1;tr<=T;tr++) {
		// mark variables to eval
		evlmask = (vars:!=.):*(loc[.,tr]:!=0)
		
		if (sum(evlmask)!=0) {
			// mul into a
			A[1,tr] = A[1,tr]*colmul(select(vars,evlmask):^select(loc[.,tr],evlmask))
			// zero these variables in loc
			loc[select(1..N,evlmask'),tr] = select(J(1,N,0),evlmask')'
		}
	
		// build cst and mark empty terms
		if (sum(loc[.,tr]:!=0)==0) {
			cst = cst + A[1,tr]
			todel = todel , tr
		}
	}
	
	// remove empty terms
	for (i=0;i<cols(todel);i++) {
		delterm(todel[1,i+1]-i)
	}
	
	return (cst)
}
// end eval


// add two equations
void Symbolic::addeq(class Symbolic scalar toadd)
{
	assert (N==toadd.getN())
	
	if (toadd.getT()==0) return
	
	for (tr_add=1;tr_add<=toadd.getT();tr_add++){
		found = 0
		if (T>0) {
			for (tr=1;tr<=T;tr++){
				if (loc[.,tr]==toadd.getloc(tr_add)){
					A[1,tr] = A[1,tr] + toadd.getA(tr_add)
					found = 1
					break
				}
			}
		}
		if (found==0) {
			addterm(toadd.getA(tr_add), toadd.getloc(tr_add))
		}
	}
}
// end addeq


// multiply two equations
void Symbolic::muleq(class Symbolic scalar tomul)
{
	assert (T>0 & tomul.getT()>0 & N==tomul.getN())
	
	class Symbolic scalar retval
	retval.einit(N)
	class Symbolic scalar empty
	empty.einit(N)
	
	
	for (tr_mul=1;tr_mul<=tomul.getT();tr_mul++){
		for (tr=1;tr<=T;tr++){
			t_a = A[1,tr] * tomul.getA(tr_mul)
			t_loc = loc[.,tr] + tomul.getloc(tr_mul)
			retval.addterm(t_a, t_loc)
		}
	}
	
	// this bit has the side effect of getting rid of repeat members of retval
	empty.addeq(retval)

	T = empty.getT()
	A = empty.getA(0)
	loc = empty.getloc(0)
	
}
// end muleq


// get gradient equations for EQ
class Symbolic colvector Symbolic::getgrad()
{
	assert (T>0)
		
	class Symbolic colvector retval
	retval = J(N,1,Symbolic())
	for (iv=1;iv<=N;iv++) {
		retval[iv,1].einit(N)
	}
	
	for (tr=1;tr<=T;tr++) {
		for (iv=1;iv<=N;iv++) {
			if (loc[iv,tr] == 0) continue
			t_a = A[1,tr] * loc[iv,tr]
			t_loc = loc[.,tr]
			t_loc[iv,1] = t_loc[iv,1]-1
			retval[iv,1].addterm(t_a,t_loc)
		}
	}
	
	return (retval)
}
// end getgrad


// get hessian equations for EQ
class Symbolic matrix Symbolic::gethess()
{
	assert (T>0)

	class Symbolic matrix retval
	retval = J(N,N,Symbolic())
	for (jv=1;jv<=N;jv++){
		for (iv=1;iv<=N;iv++) {
			retval[iv,jv].einit(N)
		}
	}

	class Symbolic colvector grad
	grad = getgrad()

	class Symbolic colvector tmp
	
	for (jv=1;jv<=N;jv++){
		tmp = grad[jv,1].getgrad()
		for (iv=1;iv<=N;iv++){
			retval[iv,jv].addeq(tmp[iv,1])
		}
	}
	
	return (retval)
}
// end gethess

end





///////////////////////////////////////////////////////////////////////////////////////
// EWproblem.mata
///////////////////////////////////////////////////////////////////////////////////////

mata:

// a problem definition class
class EWproblem {
	private:
		void						get_lhs()
		void						get_N1lhs()
		void 						get_rhs()
		void 						get_mom2()
		void 						get_cml()
		void						get_D()
		void 						get_idx()
		
		real 			rowvector 	combrep()
		real 			rowvector 	get_neqvec()
		real 			colvector 	get_tvec()
		real 			rowvector 	next_ind()
		real 			matrix 		get_rocmat()
		real 			rowvector 	occur2count()
		real 			matrix 		get_rmat()
		real 			scalar 		colmul()
		real 			scalar 		facto()
		real 			scalar 		get_avk()
		real 			rowvector	get_locvk()		
		real 			colvector	getexploc()
		real 			colvector	resolve()

	public:
		class Symbolic 	colvector	lhs				//[neq,1]
		class Symbolic 	matrix		Dlhs			//[neq,nx1]
		class Symbolic 	colvector	N1lhs			//[N1neq,1]
		class Symbolic 	colvector	rhs				//[neq,1]
		class Symbolic 	matrix		Drhs			//[neq,nt]
		class Symbolic 	colvector	mom2			//[neq2,1]
		class Symbolic 	matrix		Dmom2			//[neq2,nt2]
		class Symbolic 	colvector	cml				//[neq,1]
		class Symbolic 	matrix		Dcml			//[neq,neq]
		
		real			matrix		rmat			//[neq,nx1]
		real			matrix		rocmat			//[neq,maxdeg]
		real			matrix		N1rmat			//[N1neq,nx1]
		real			matrix		N1rocmat		//[N1neq,maxdeg]
		real			rowvector	neqvec			//[1,maxdeg-1]
		real			colvector	ntvec			//[4,1]
		real			colvector	ntvec2			//[4,1]
		real			rowvector	tmap			//[1,nt] - transforms nt to nt2 vec

		real			rowvector	yidx			//[1,nk]
		real			matrix		xidx			//[nx,nk]

		void 						einit()
		real 			matrix		getW2()
		real			colvector	resolve_eq()
}
// end EWproblem


// choose k from n with repetitions
real rowvector EWproblem::combrep(real rowvector n, real rowvector k)
{
	n1 = n :+ k :-1
	return (comb(n1,k))
}
// end combrep


// Return vector of equation numbers per each degree - returns [1,maxdeg-1] rowvector
real rowvector EWproblem::get_neqvec(real scalar maxdeg, real scalar nvars, real scalar correct)
{
	if (maxdeg==0) return (J(1,1,1))
	if (maxdeg==1) return (J(1,1,nvars))
	n = J(1,maxdeg-1,nvars)
	k = (2..maxdeg)
	degs = combrep(n,k)
	degs[1,cols(degs)] = degs[1,cols(degs)] - nvars*(maxdeg>=3)*(correct>0)
	tmp = (cols(degs)-1+1*(maxdeg==2)) //avoid subscript errors when maxdeg==2
	degs[1,tmp] = degs[1,tmp] - nvars*(maxdeg>=4)*(correct>0)
	return (degs)
}
// end get_neqvec


// count the stacked elements (including optional correction) for vector t
real colvector EWproblem::get_tvec(real scalar maxdeg, real scalar nx, real scalar correct)
{
	retval = J(4,1,0)
	//the betas
	retval[1,1] = nx
	//the E(etas)
	retval[2,1] = rowsum(get_neqvec(maxdeg,nx,0))
	//the E(epsilon^i), 2..maxdeg per xi (full)
	retval[3,1] = (maxdeg-1-1*(correct>0)-1*(correct>0 & maxdeg>=4))*nx
	//the E(u^i)
	retval[4,1] = (maxdeg-1-1*(correct>0)-1*(correct>0 & maxdeg>=4))
	
	return (retval)
}
// end function get_tcnt


// advance the indices denoting which moment combination to do next
real rowvector EWproblem::next_ind(real rowvector indx, real scalar nx1, real scalar correct)
{
	deg = cols(indx)
	retindx = indx
	for (b_d=deg;b_d>=1;b_d--) {
		if (retindx[1,b_d]+1>nx1) continue
		retindx[1,b_d] = retindx[1,b_d]+1
		// here indx is correct up to position b_d, now take care of fwd positions
		for (f_d=b_d+1;f_d<=deg;f_d++) {
			retindx[1,f_d] = retindx[1,f_d-1]
		}
		if (retindx[1,deg] == retindx[1,1] & correct>0) {
			retindx[1,deg] = retindx[1,deg] + 1
		}
		return (retindx)
	}
	// We're done
	return (J(1,0,0))
}
// end function next_ind


// create r (occurances) vectors for all eqs
real matrix EWproblem::get_rocmat(real scalar maxdeg, real scalar nx1, real scalar neqfull, 	///
								real rowvector neqvecfull)
{
	retval = J(neqfull,maxdeg,0)
	//printf("maxdeg: %g, nx1: %g, neqfull: %g\n",maxdeg, nx1, neqfull)
	
	pos=1
	for (deg=2;deg<=maxdeg;deg++) {
		indx = J(1,deg,1) // start with y^deg
		nmom = neqvecfull[1,deg-1]
		for (j=1;j<=nmom;j++) {
			retval[pos,1..deg] = indx
			pos++
			indx = next_ind(indx,nx1,0)
		}
	}
	assert(pos==neqfull+1)
	
	return(retval)
}
// end get_rocmat


// turn occur rep to count rep
real rowvector EWproblem::occur2count(real rowvector oc, real scalar nvar)
{
	retval = J(1,nvar,0)
	
	for (j=1;j<=nvar;j++) {
		retval[1,j] = sum(oc[1,.]:==j)
	}
	
	return (retval)
}
// end occur2count


// create r (counts) vectors for all eqs
real matrix EWproblem::get_rmat(real scalar nx1, real scalar neqfull)
{
	retval = J(neqfull,nx1,0)
	
	for (i=1;i<=neqfull;i++) {
		retval[i,.] = occur2count(rocmat[i,.], nx1)
	}
	
	return(retval)
}
// end get_rmat


// return the multiplication of all members of a vector
real scalar EWproblem::colmul(real colvector vec)
{
	// better to do this in a bi-section method for numerical stability, at some point
	total = 1
	for (i=1;i<=rows(vec);i++) {
		total=total*vec[i,1]
	}
	
	return (total)
}
// end function colmul


// numer!/mul(denom[i]!)
real scalar EWproblem::facto(real scalar numer, real rowvector denom)
{
	tmp = factorial(numer)
	return (tmp[1,1]/colmul(factorial(denom')))
}
//end function facto


// generates the constant part a[v,k] of a term. zeroes it if term has vanishing moments multiplied
real scalar EWproblem::get_avk(real rowvector r, real rowvector v, real rowvector k,		///
					real scalar maxdeg)
{
	// take care of vanishing u
	if (v[1,1]==1 | (v[1,1]==(maxdeg-1) & maxdeg!=3)) return (0)
	
	// take care of vanishing eta
	vk = v[1,2..(cols(v))]:+k
	if (sum(vk:>0)==1 & (sum(vk)==1 /*| (sum(vk)==(maxdeg-1) & maxdeg!=3)*/ )) return (0)
	
	a = 1
	a = a*facto(r[1,1],v)
	
	for (j=1;j<=(cols(r)-1);j++) {
		// take care of vanishing epsilon
		if (r[1,(j+1)]-k[1,j]==1 | (r[1,(j+1)]-k[1,j]==maxdeg-1 & maxdeg!=3)) return (0)
		a = a*facto(r[1,(j+1)],(k[1,j],(r[1,(j+1)]-k[1,j])))
	}
	
	return (a)
}
//end get_avk


// locvk is a list of powers of each variable in the term
real rowvector EWproblem::get_locvk(real rowvector r, real rowvector v, real rowvector k,	///
					real scalar maxdeg, real scalar nx, real scalar nt)
{
	
	retval = J(1,nt,0)
	
	base_beta	= 1
	base_eta 	= ntvec[1,1] + 1
	base_eps 	= sum(ntvec[1..2,1]) + 1
	base_u		= sum(ntvec[1..3,1]) + 1

	// u^v0
	if (v[1,1]!=0) {
		retval[1,(base_u+v[1,1]-2)] = 1
	}

	for (j=1;j<=nx;j++) {
		rj = r[1,(j+1)]
		kj = k[1,j]
		vj = v[1,(j+1)]

		// epsj^(rj-kj)
		if (rj-kj!=0) {
			retval[1,(base_eps+nx*(rj-kj-2)+(j-1))] = 1
		}

		// betaj^vj
		if (vj!=0) {
			retval[1,j] = vj
		}
	}	
	
	// v and k define a specific eta combination
	vk = v[1,2..(cols(v))]:+k
	indx = J(1,maxdeg,0)
	for (i=0;i<=nx;i++) {
		indx = next_ind(indx, nx, 0)
	}
	for (i=1;i<=ntvec[2,1];i++) {
		if (sum(occur2count(indx,nx):==vk)==nx) {
			retval[1,(base_eta + (i-1))] = 1
			break
		}
		indx = next_ind(indx, nx, 0)
	}

	return (retval)
}
// end function get_locvk


// take a subexp and return loc vector
real colvector EWproblem::getexploc(real colvector exp, real scalar nx1, real scalar neq)
{

	retval = J(neq,1,0)
	ibeg = 1
	while (1) {
		for (iend=ibeg ; exp[iend+1,1]!=-1 ; iend++) {}
		rtmp = occur2count(exp[ibeg..iend,1]',nx1)
		tmp = (colsum(rmat':==rtmp'):==nx1):*(1..neq)
		assert (sum(tmp:!=0)==1)
		pos = sum(tmp)
		retval[pos,1] = retval[pos,1]+1
		if (iend+2>rows(exp)) break
		ibeg = iend+2
		if (exp[ibeg,1]==-1) break
	}
	return (retval)
}	
// end getexploc


// build all lhs equations (EQ7 EW2002)
void EWproblem::get_lhs(real scalar nx, real scalar neq)
{
	lhs = J(neq,1,Symbolic())

	for (i=1;i<=neq;i++) {
		lhs[i,1].einit(nx+1)		// lhs equation variables are y and the xj
		lhs[i,1].addterm(1,rmat[i,.]')
	}
}
// end get_lhs


// build all N1lhs equations (y^(maxdeg-1), xj^(maxdeg-1), for SE correction)
void EWproblem::get_N1lhs(real scalar nx, real scalar N1neq)
{
	N1lhs = J(N1neq,1,Symbolic())

	for (i=1;i<=N1neq;i++) {
		N1lhs[i,1].einit(nx+1)		// lhs equation variables are y and the xj
		N1lhs[i,1].addterm(1,N1rmat[i,.]')
	}
}
// end get_N1lhs


// build all rhs equations (EQ7 EW2002)
void EWproblem::get_rhs(real scalar maxdeg, real scalar nx, real scalar neq, real scalar nt)
{
	rhs = J(neq,1,Symbolic())
	
	for (i=1;i<=neq;i++) {
		rhs[i,1].einit(nt)		// rhs equation variables are t
		r = rmat[i,.]
		
		vvec = get_neqvec(r[1,1],nx+1,0)
		nv = vvec[1,cols(vvec)]
		max_nv = rowsum(vvec)+(nx+1)+1 //+(nx+1)+1 is for deg==0,1
		m = sum(r)
		max_nk = rowsum(get_neqvec(m,nx,0))+nx+1 //+nx+1 is for deg==0,1
		

		curr_k = J(1,maxdeg,0)
		for (ik=1;ik<=max_nk;ik++) {
			count_k = occur2count(curr_k,nx)

			// if curr_k not admissable, continue
			if (sum(count_k)>m | sum(count_k:>r[1,2..(nx+1)])>0) {
				curr_k = next_ind(curr_k, nx, 0)
				continue
			}

			curr_v = J(1,maxdeg,0)
			for (iv=1;iv<=max_nv;iv++) {
				count_v = occur2count(curr_v,nx+1)
				
				// if curr_v not admissable, continue
				if (sum(count_v)!=r[1,1]) {
					curr_v = next_ind(curr_v, nx+1, 0)
					continue
				}
				
				//get_a zeroes vanishing terms
				a = get_avk(r, count_v, count_k, maxdeg)
				
				if (a>0) {
					locvk = get_locvk(r, count_v, count_k, maxdeg, nx, nt)
					rhs[i,1].addterm(a,locvk')
				}
				
				curr_v = next_ind(curr_v, nx+1, 0)
			}
			
			curr_k = next_ind(curr_k, nx, 0)
		}
	}
}
// end get_rhs


// build equations for mom2 problem
void EWproblem::get_mom2(real scalar nx, real scalar nt, real colvector ntvec)
{
	neta2 = combrep(nx,2)
	neq2 = rowsum(get_neqvec(2,(nx+1),0))
	ntvec2 = (nx,neta2,nx,1)'
	nt2 = colsum(ntvec2)
	
	mom2 = J(neq2,1,Symbolic())
	
	pos2 = ntvec[1,1] + 1
	pos3 = ntvec[1,1] + ntvec[2,1] + 1
	pos4 = ntvec[1,1] + ntvec[2,1] + ntvec[3,1] + 1
	
	tmap = J(1,nt,0)
	tmap[1,1..nx] = J(1,nx,1)										// all beta
	tmap[1,pos2..(pos2+neta2-1)] = J(1,neta2,1)						// E(etai*etaj)
	tmap[1,pos3..(pos3+nx-1)] = J(1,nx,1)							// E(ej^2)
	tmap[1,pos4] = 1												// E(u^2)

	for (i=1;i<=neq2;i++) {
		mom2[i,1].einit(nt2)
		a = rhs[i,1].getA(0)
		locmat = rhs[i,1].getloc(0)
		
		locmat_nt2 = select(locmat, tmap')
		assert (sum(select(locmat, (!tmap)'))==0)
		
		for (j=1;j<=rhs[i,1].getT();j++)
		{
			mom2[i,1].addterm(a[j],locmat_nt2[.,j])
		}
		//mom2[i,1].print(1)
	}
}
// end get_mom2


// build equations for cumulants
void EWproblem::get_cml(real scalar maxdeg, real scalar nx, real scalar neq, real scalar nt)
{
	class Partitions scalar part
	cml = J(neq,1,Symbolic())
	
	deg = rowsum(rmat)

	for (eq=1;eq<=neq;eq++) {
		cml[eq,1].einit(neq)
		
		part = Partitions()
		part.einit(deg[eq,1])
		
		for (i=1;i<=part.getP();i++) {
			pt = part.getnext()							// [deg,1] part template
			if (sum(pt:==1)!=0) continue				// E(xj^1) = E(y^1) = 0
			q = sum(pt:>0)
			a = ((-1)^(q-1))*factorial(q-1)
			expmat = part.expand(pt)					// [2*deg,?] expanded exp
			for (j=1;j<=cols(expmat);j++) {
				subexp = part.sub(expmat[.,j],rocmat[eq,1..deg[eq,1]]')
				locv = getexploc(subexp, nx+1, neq)
				cml[eq,1].addterm(a,locv)
			}
		}
	}
}
// end get_cml


// build indices for choosing cumulants
void EWproblem::get_idx(real scalar maxdeg, real scalar nx, real scalar nk,			///
				real scalar neq, real rowvector neqvecfull)
{
	yidx = J(1,nk,0)
	xidx = J(nx,nk,0)
	
	pos = 1
	for (d=2;d<=maxdeg-1;d++) {
		idx = J(1,d,1)										// start with y^d
		idx = next_ind(idx,nx+1,1)							// and advance one
		for (i=1; i<=(neqvecfull[1,d-1]-(nx+1)); i++) {
			ry = occur2count((1,idx), nx+1)
			yidx[1,pos] = sum((colsum(rmat':==ry'):==nx+1):*(1..neq))
			for (j=1; j<=nx; j++) {
				rx = occur2count((j+1,idx), nx+1)
				xidx[j,pos] = sum((colsum(rmat':==rx'):==nx+1):*(1..neq))
			}
			pos++
			idx = next_ind(idx, nx+1, 1)
		}
	}
}
// end get_idx


// build equations for gradient matrix of system
void EWproblem::get_D(class Symbolic colvector systm, class Symbolic matrix Dsys)
{
	neq   = rows(systm)
	nvars = systm[1,1].getN()
	
	class Symbolic colvector tmp
	
	for (i=1;i<=neq;i++) {
		tmp = systm[i,1].getgrad()	//tmp[nvars,1]
		
		for (j=1;j<=nvars;j++) {
			Dsys[i,j].einit(nvars)
			Dsys[i,j].addeq(tmp[j,1])
		}
	}
}
// end get_D


// initialize problem
void EWproblem::einit(real scalar maxdeg, real scalar nx)
{
	correct = 1
	neqvec = get_neqvec(maxdeg, (nx+1), correct)
	neqvecfull = get_neqvec(maxdeg, (nx+1), 0)
	ntvec = get_tvec(maxdeg, nx, correct)
	neq = rowsum(neqvec)
	neqfull = rowsum(neqvecfull)
	nt = colsum(ntvec)
	nk = rowsum(neqvecfull[1,1..cols(neqvecfull)-1]:-(nx+1))
	
	rocmat = get_rocmat(maxdeg, (nx+1), neqfull, neqvecfull)
	rmat = get_rmat((nx+1), neqfull)
	
	N1sel = ((rowsum(rmat:!=0):==1):*rowsum(rmat):==(maxdeg-1))
	N1rocmat = select(rocmat, N1sel)
	N1rmat = select(rmat, N1sel)
	N1neq = rows(N1rmat)
	
	if (correct) {
		corr_sel = (rowsum(rmat:!=0):==1):*rowsum(rmat)
		corr_sel = (corr_sel:==(maxdeg-1)):*(maxdeg>=4) + (corr_sel:==maxdeg):*(maxdeg>=3)
		rocmat = select(rocmat, !corr_sel)
		rmat = select(rmat, !corr_sel)
	}
	assert (rows(rmat)==neq)
	
	get_lhs(nx, neq)
	get_N1lhs(nx, N1neq)
	get_rhs(maxdeg, nx, neq, nt)
	get_mom2(nx, nt, ntvec)
	get_cml(maxdeg, nx, neq, nt)
	
	// RPG - Dlhs currently unused, so don't waste time
	//Dlhs  = J(rows(lhs),lhs[1,1].getN(),Symbolic())
	Drhs  = J(rows(rhs),rhs[1,1].getN(),Symbolic())
	Dmom2 = J(rows(mom2),mom2[1,1].getN(),Symbolic())
	Dcml  = J(rows(cml),cml[1,1].getN(),Symbolic())

	//get_D(lhs, Dlhs)
	get_D(rhs, Drhs)
	get_D(mom2, Dmom2)
	get_D(cml, Dcml)
	
	get_idx(maxdeg, nx, nk, neq, neqvecfull)
	
	return
}
// end einit


// return the lower part of the W matrix of Eq26
real matrix EWproblem::getW2(real scalar nx, real scalar nr, real scalar neq)
{
	retval = J(nr,nx,1)
	
	idx = (2,3)
	for (i=1;i<=nr;i++) {
		for (j=1;j<=nx;j++) {
			r = idx , j+1
			rc = occur2count(r,nx+1)
			retval[i,j] = sum((colsum(rmat':==rc'):==nx+1):*(1..neq))
		}
		idx = next_ind(idx,nx+1,1)
	}
	
	return(retval)	
}
// end getW2


// resolve a general set of equations by iterated substitution
real colvector EWproblem::resolve(real colvector retval, real colvector LHS,
						class Symbolic colvector RHS, real scalar neq, real scalar nt)
{
	// repeat until all of t is resolved or too many iterations
	for (iter=1;(sum(retval:==.)>0 & iter<=10);iter++) {
		for (eq=1;eq<=neq;eq++) {
			// make sure everything in retval is substituted into the equation
			cst = RHS[eq,1].partialeval(retval)
			// deduct constant from LHS
			LHS[eq,1] = LHS[eq,1] - cst
			// for 1-term equations, divide by a
			if (RHS[eq,1].getT()==1) {
				LHS[eq,1] = LHS[eq,1]/RHS[eq,1].getA(1)
				locv = RHS[eq,1].getloc(1)
				RHS[eq,1].replaceterm(1, 1, locv)
				
				// for 1-member 1-term equations, resolve if needed, discard anyway
				if (sum(locv:!=0)==1) {
					loc = sum((locv:!=0):*(1..nt)')
					if (retval[loc,1]==.) retval[loc,1] = LHS[eq,1]:^(1/sum(locv))
					RHS[eq,1].delterm(1)
				}
			}
		}
	}
	
	if (sum(retval:==.)>0) {
		printf("Iterated substitution failed. Please submit bug report.")
		exit(197)
	}
	
	return (retval)
}
// end resolve


// resolve a set of equations
real colvector EWproblem::resolve_eq(class Symbolic colvector systm, real colvector start,		///
						real scalar neq, real scalar nx, real scalar nt, real colvector emom)
{
	retval = J(nt,1,.)
	retval[1..nx,1] = start
	
	class Symbolic colvector RHS
	RHS = J(neq,1,Symbolic())
	LHS = J(neq,1,0)
	for (i=1;i<=neq;i++) {
		RHS[i,1].einit(nt)
		RHS[i,1].addeq(systm[i,1])
		LHS[i,1] = emom[i,1]
	}

	return (resolve(retval, LHS, RHS, neq, nt))	
}
// end resolve_eq

end





///////////////////////////////////////////////////////////////////////////////////////
// EWopt.mata
///////////////////////////////////////////////////////////////////////////////////////

mata:

class EWopt {

	public:
		real			scalar		n
		real			scalar		nx
		real			scalar		maxdeg
		real			scalar		nz
		real			scalar		nt
		real			scalar		nt2
		real			scalar		neq
		real			scalar		neq2
		real			scalar		N1neq
		real			scalar		ncml
		real			scalar		nk

		real			scalar 		met
		real			scalar 		clustmet
		real			scalar 		vcmet
		real			scalar 		optmet
		real			scalar 		centmet

		real			scalar		nbXint

		string			scalar		fname
		
		real 			scalar		CML_maxiter
		real 			scalar		GN_maxiter
		real 			scalar		GN_maxsqz
		real 			scalar		tol

		void 						einit()
		void 						setprb()
		real 			scalar 		doMOM()
}



// initialize all options
void EWopt::einit(real scalar n, real scalar nx, real scalar maxdeg, real scalar nz, 		///
				real scalar met, real scalar clustmet, real scalar vcmet, 					///
				real scalar optmet, real scalar centmet)
{
	this.n 			= n
	this.nx 		= nx
	this.maxdeg 	= maxdeg
	this.nz			= nz
	this.met		= met
	this.clustmet	= clustmet
	this.vcmet		= vcmet
	this.optmet		= optmet
	this.fname 		= "EWcache_" + strofreal(nx) + "_" + strofreal(maxdeg) + ".data"
	this.CML_maxiter = 500
	this.GN_maxiter = 999
	this.GN_maxsqz	= 240
	this.tol		= 1e-9
	this.centmet	= centmet
	
}
// end einit


// sets model dependant options
void EWopt::setprb(class EWproblem scalar prb)
{
	neq 	= rows(prb.Drhs)
	nt 		= cols(prb.Drhs)
	neq2 	= rows(prb.mom2)
	nt2 	= prb.mom2[1,1].getN()
	ncml	= rows(prb.cml)
	N1neq	= rows(prb.N1lhs)
	nk		= cols(prb.yidx)
}
// end setprb


// is the method to use MOM?
real scalar EWopt::doMOM()
{
	assert (n!=.)
	
	return (met==1)
}
// end doMOM

end





///////////////////////////////////////////////////////////////////////////////////////
// EWdata.mata
///////////////////////////////////////////////////////////////////////////////////////

mata:

// Create and hold all data pertaining to the EW problem
class EWdata {
	private:
		real 			colvector	find_beta()

	public:
		real			matrix		yx		//[n,nx+1]
		real			matrix		z		//[n,nz]
		real			matrix		mom		//[n,neq]
		real			matrix		emom	//[neq,1]
		real			matrix		zmom	//[neq,nz]
		real			matrix		N1mom	//[n,N1neq]
		real			matrix		N1emom	//[N1neq,1]
		real			matrix		N1zmom	//[N1neq,nz]
		real 			colvector	muy		//[nz,1], projection of y on z, y_i=z_i*muy
		real 			matrix		mux		//[nz,nx], projection of x on z, x_i=z_i*mux
		real			matrix		inEzz	//[nz,nz], cholinv((z'*z)/n)
		real			matrix		zyx		//[n,nz*(nx+1)], yx(_d) dot-multiplied by z's columns

		real			rowvector	ni		//[1,??], number of clustered obs

		real			colvector	fCent	//[neq/nk,1], moments for centered bootstrap

		real 			colvector	ky		//[nk,1]
		real 			matrix		kx		//[nk,nx]
		real 			matrix		Dky		//[nk,neq]
		real 			matrix		Dkx		//[nk,nx*neq]
		
		real 			rowvector	bXint	//[1,c*nx]
		real 			colvector	bX0_Gry	//[nx,1]
		real 			colvector	bX0_OLS	//[nx,1]
		
		real 			colvector	bX		//[nx,1]
		real 			colvector	bZ		//[nz,1]
		real 			scalar		rho		//[1,1]
		real 			colvector	tau		//[nx,1]
		
		void 						einit()
		real			colvector	get_beta()
}
// end EWdata


// find starting beta based on Eq26 of EW2002
real colvector EWdata::find_beta(class EWopt scalar opt, class EWproblem scalar prb)
{
	nr = comb(opt.nx+1,2)
	V = J(nr,1,0)
	W1 = J(opt.nx,opt.nx,0)
	W2 = J(nr-opt.nx,opt.nx,0)

	// fill V
	pos = sum(1..opt.nx)+opt.nx+1 + 1*(opt.maxdeg>=5) + 1
	wpos = pos
	V[1..opt.nx,1] = emom[(pos)..(pos+opt.nx-1),1]
	vpos = opt.nx + 1
	pos = pos + opt.nx

	for (i=opt.nx-1;i>=1;i--) {
		pos++
		V[(vpos)..(vpos+i-1),1] = emom[(pos)..(pos+i-1),1]
		vpos = vpos+i
		pos = pos+i
	}
	
	// fill W1
	pos = wpos + opt.nx
	for (i=1;i<=opt.nx;i++) {
		for (j=i;j<=opt.nx;j++) {
			W1[i,j] = emom[pos,1]			// E(y*x_i*x_j)
			W1[j,i] = W1[i,j] 				// use symmetry of W1 to save a few steps
			pos++
		}
	}
	
	// fill W2
	if (opt.nx>1) {
		W2 = prb.getW2(opt.nx, nr-opt.nx, opt.neq)
		for (i=1;i<=nr-opt.nx;i++) {
			W2[i,.] = emom[W2[i,.],1]'
		}
		W = W1\W2
	}
	else {
		W = W1
	}

	// verify identification, find beta and return it
	pW = pinv(W,rnk)		//this should be pinv, not cholinv!
	if (rnk<opt.nx) {
		errprintf("Third moment matrix not full-rank. System not identified. Aborting.\n")
		exit(error(459))
	}
	beta = pW*V

	return (beta)
}
// end find_beta


// initialize data
void EWdata::einit(class EWopt scalar opt, class EWproblem scalar prb, transmorphic colvector id,	///
					real colvector y, real matrix x, real matrix z1, real rowvector bXint)
{
	// save z
	z = z1
	
	// partial out z from x and y
	invzz = cholinv(quadcross(z,z))
	mux = invzz*quadcross(z,x)
	muy = invzz*quadcross(z,y)
	inEzz = opt.n*invzz
	yx = (y-z*muy,x-z*mux)
	
	// generate ezmom
	mom = J(opt.n, opt.neq, 0)
	emom = J(opt.neq, 1, 0)
	zmom = J(opt.neq, opt.nz, 0)
	
	for (i=1;i<=opt.neq;i++) {
		mom[.,i] = prb.lhs[i,1].evalmat(yx)
	}
	
	emom = mean(mom)'
	
	for (i=1;i<=opt.nz;i++) {
		zmom[.,i] = mean(mom:*(J(1,opt.neq,1)#z[.,i]))'
	}

	// generate N1ezmom
	N1mom = J(opt.n, opt.N1neq, 0)
	N1emom = J(opt.N1neq, 1, 0)
	N1zmom = J(opt.N1neq, opt.nz, 0)
	
	for (i=1;i<=opt.N1neq;i++) {
		N1mom[.,i] = prb.N1lhs[i,1].evalmat(yx)
	}
	
	N1emom = mean(N1mom)'
	
	for (i=1;i<=opt.nz;i++) {
		N1zmom[.,i] = mean(N1mom:*(J(1,opt.N1neq,1)#z[.,i]))'
	}

	// generate zyx
	zyx = J(opt.n,opt.nz*(opt.nx+1),0)
	for (i=1;i<=(opt.nx+1);i++) {
		cur_beg = (i-1)*opt.nz+1
		cur_end = i*opt.nz
		zyx[.,cur_beg..cur_end] = (J(1,opt.nz,1)#yx[.,i]):*z
	}
	
	// build the ni for clustering (as per section 2.7 of EJW)
	uid = uniqrows(id)
	ni = J(1,rows(uid),0)
	j=1
	for (i=1;i<=opt.n;i++)
	{
		if (id[i,1]==uid[j,1]) continue
		ni[1,j]=i-1
		j=j+1
	}
	ni[1,j]=opt.n
	ni = (0,ni)
	assert (j==rows(uid))
	
	// count the implied bXint iterations, and update opt
	this.bXint = bXint
	if (cols(bXint)==1 & bXint[1,1] == 0) {
		this.bXint = J(1,opt.nx,0) , J(1,opt.nx,0)
	}
	opt.nbXint = (cols(this.bXint)/opt.nx)
	assert(opt.nbXint==round(opt.nbXint))
	
	// verify and put fCent
	external real colvector EWSAVEDfCent
	if (opt.centmet == 0 | opt.centmet == 1 | EWSAVEDfCent==NULL) {
		EWSAVEDfCent = J(0,1,0)
		fCent = EWSAVEDfCent
	}
	else { //opt.centmet == 2, i.e. Use
		valid_fCent = opt.doMOM()*(rows(EWSAVEDfCent)==opt.neq) + ///
					  (!opt.doMOM())*(rows(EWSAVEDfCent)==opt.nk)
		
		if (valid_fCent) 	fCent = EWSAVEDfCent
		else				fCent = J(0,1,0)
	} // if fCent is set, then it is ready to be used.
	
	// do cumulants
	cml = J(opt.neq, 1, 0)
	for (i=1;i<=opt.neq;i++) {
		cml[i,1] = prb.cml[i,1].eval(emom)
	}
	// split cml into ky and kxj
	ky = cml[prb.yidx,1]
	kx = J(opt.nk,0,0)
	for (i=1;i<=opt.nx;i++) {
		kx = kx, cml[prb.xidx[i,.],1]
	}
	
	// do Dcumulants
	Dcml = J(opt.neq, opt.neq, 0)
	for (i=1;i<=opt.neq;i++) {
		for (j=1;j<=opt.neq;j++) {
			Dcml[i,j] = prb.Dcml[i,j].eval(emom)
		}
	}
	// split Dcml into Dky and Dkxj
	Dky = Dcml[prb.yidx,.]
	Dkx = J(opt.nk,0,0)
	for (i=1;i<=opt.nx;i++) {
		Dkx = Dkx, Dcml[prb.xidx[i,.],.]
	}

	// create bX0_Gry - the Eq26 least-squares guess for beta
	bX0_Gry = find_beta(opt, prb)
	
	// create bX0_OLS - the simple ols estimate
	bX0_OLS = qrsolve((x,z), y)
	bX0_OLS = bX0_OLS[1..opt.nx,1]
	
	// initialize bX, bZ and tau, for good measure
	bX = 	J(opt.nx,1,0)
	bZ = 	J(opt.nz,1,0)
	tau = 	J(opt.nx,1,0)

}
// end einit


// return i-th beta to attempt (possibly generating a candidate)
real colvector EWdata::get_beta(numeric scalar i, class EWopt scalar opt)
{
	retval = bXint[1,((i-1)*opt.nx+1)..(i*opt.nx)]
	iszero = sum(retval:!=0)==0
	isdbl  = 0
	if (i>1) {
		retval1 = bXint[1,((i-2)*opt.nx+1)..((i-1)*opt.nx)]
		isdbl = sum(retval1:!=0)==0
	}
	if (iszero) {
		retval = bX0_Gry
	}
	if (isdbl) {
		retval = bX0_OLS
	}
	
	return (retval)
}
// end get_beta

end





///////////////////////////////////////////////////////////////////////////////////////
// EWreg.mata
///////////////////////////////////////////////////////////////////////////////////////

mata:

// return value struct
struct stats {
	real 	colvector 	beta
	real 	matrix 		VCmat
	real 	colvector 	serr
	real 	scalar 		N
	real 	scalar 		Jstat
	real 	scalar 		Jval
	real 	scalar 		dfree
	real 	scalar 		rho
	real 	colvector	tau
	real 	scalar 		SErho
	real 	colvector	SEtau
	real 	matrix 		vcrhotau
	real 	matrix 		inflncXZ
	real 	matrix 		inflncRT
	real 	matrix 		w
	real 	scalar 		obj
	real 	colvector 	IDval
	real 	colvector 	IDstat
}
// end struct stats


// a struct to allow vectors of matrices
struct mt
{
	transmorphic matrix inmat
}
// end struct mt


// an EW regression class
class EWreg {
	private:
		pointer(class EWproblem) scalar 		pprb

		class EWdata 	scalar 		dta
		class EWopt 	scalar 		opt
		
		real 			matrix 		ff				//[n,neq]
		real 			matrix 		omega
		real 			matrix 		w
		real 			colvector 	t
		real			scalar		obj

		real 			colvector 	fsave
		
		real			matrix		optw()
		real			matrix		getomega()
		real 			colvector 	dogmm()
		struct stats	scalar		getret()
		real 			colvector	EWgmm1()
		real 			colvector	EWgmm2()
		real 			colvector	sqeez()
		real 			matrix		dogeeRT()
		
		real 			scalar		mutual_cnt()
		real			matrix		CMDshare()
		real 			colvector	findpos()
		real 			rowvector 	cmd()
		
	public:
		struct stats	scalar		doCLS()
		struct stats	scalar		doCMD()

		real 			colvector	deff()
		real 			matrix		gradMOM()
		pointer(class EWproblem) scalar 		get_pprb()
		
}
// end EWreg


// a public interface for pprb, for i_crit. A hack, but we'll survive.
pointer(class EWproblem) scalar EWreg::get_pprb()
{
	return (pprb)
}
// end get_pprb


// define the f = gi(mu_hat)-gbar(mu_hat)+Gbar(mu_hat)*KSImui vector for the optimal weight matrix
real matrix EWreg::optw()
{
	nemom = (J(opt.n,1,1)#dta.emom')
	retval = dta.mom-nemom
	
	// do standard error adjustment
	if (opt.vcmet==0) {
	
		ei=J(opt.n,opt.neq,0)

		// define G(mu) - maybe easier with Symbolic, but i kinda gave up here.
		G = J(opt.neq,opt.nz*(opt.nx+1),0)
		for (eq=1;eq<=opt.neq;eq++) {
			for (j=1;j<=opt.nx+1;j++) {
				d = pprb->rmat[eq,j]

				if (d>0) {
					mr = pprb->rmat[eq,.]
					mr[1,j] = mr[1,j]-1
					m = sum((colsum(pprb->rmat':==mr'):==opt.nx+1):*(1..opt.neq))
					if (m==0) {
						m = sum((colsum(pprb->N1rmat':==mr'):==opt.nx+1):*(1..opt.N1neq))
						if (m==0) continue

						G[eq,((j-1)*opt.nz+1)..(j*opt.nz)] = -1:*d:*dta.N1zmom[m,.]
						continue
					}
					G[eq,((j-1)*opt.nz+1)..(j*opt.nz)] = -1:*d:*dta.zmom[m,.]
				}
			}
		}
		
		// multiply G, Q^-1 (inEee), Rmu (zyx)
		ei = (G*(I(opt.nx+1)#dta.inEzz)*dta.zyx')'
		
		// add correction into retval
		retval = retval + ei
	}
	
	// do numerical adjustment - reweigthing f, so that optw will be well-conditioned
	if (opt.doMOM()) retval = retval:/nemom
	
	return (retval)	
}
// end optw


// ff->omega, take care of clustering
real matrix EWreg::getomega(real matrix ff1)
{
	// 0: clustered
	// 1: identity
	// 2: regular ((ff'*ff)/n)

	if (opt.clustmet==1) {
		return (I(cols(ff1)))
	}
	if (opt.clustmet==2) {
		return ((ff1'*ff1)/rows(ff1))
	}
	if (opt.clustmet==0) {
		retval = J(cols(ff1),cols(ff1),0)
	}
	else {
		errprintf("getomega recieved unexpected clustmet value. Please submit bug report.\n")
		exit(error(198))
	}
		
	for (i=2;i<=cols(dta.ni);i++)
	{
		hi = colsum(ff1[dta.ni[1,i-1]+1..dta.ni[1,i],.])
        retval = retval + hi'*hi
    }
    retval = retval:/rows(ff1)
	
	return (retval)
}
// end getomega


// compute gradient matrix of moment problem
real matrix EWreg::gradMOM(class Symbolic matrix systm, real colvector t, real scalar wgt)
{
	dvdc = J(rows(systm), cols(systm), 0)
	for (eq=1;eq<=rows(systm);eq++) {
		for (it=1;it<=cols(systm);it++) {
			dvdc[eq,it] = systm[eq,it].eval(t)
		}
	}
	
	if (wgt) dvdc = dvdc:/(J(1,opt.nt,1)#dta.emom)
	
	return (-1:*dvdc)
}
// end gradMOM


// define the f vector (distance between data moments and constructed moments)
real colvector EWreg::deff(real colvector t)
{
	// f'wf is the GMM objective function to minimize to find t
	// for an example defining f, see page 783 of EW2002
	
	f=J(opt.neq, 1, 0)
	
	for (eq=1;eq<=opt.neq;eq++) {
		f[eq,1] = (dta.emom[eq,1] - pprb->rhs[eq,1].eval(t))
	}
	
	if (opt.doMOM()) f = f:/dta.emom
	
	if (rows(dta.fCent)>0) f = f - dta.fCent

	return (f)
}
// end deff


// criterion function for EWgmm1. Provide the obj func and the gradient thereof
void i_crit(real scalar todo, real rowvector b, real scalar crit, real rowvector g, real matrix H)
{
	class EWreg scalar EWobj
	
	p = findexternal("EWexternal")
	EWobj  	= *((*p)[1])
	w 		= *((*p)[2])

	f=EWobj.deff(b')
	crit = f'*w*f
	
	if (todo==1) {
		gr = EWobj.gradMOM(EWobj.get_pprb()->Drhs, b', 1)
		gwg = gr'*w*gr
		gwf = gr'*w*f
		g = (cholinv(gwg)*gwf)'
	}
}
// end function i_crit


// compute squeezes
real colvector EWreg::sqeez(real colvector s_t, real colvector s_dt, real scalar obj1, real matrix w)
{
	// compare the values of the objective function at the
	// points c+s*dc and c+0.5*s*dc, with dc = the proposed change in the vector
	// of parameters, and with step length s initially at 1. s is halved until
	// minus the objective function stops declining.
	
	s_t1=s_t-s_dt
	s_lm=1/2
	s_itr=1

	s_f1=deff(s_t1)
	lc1 = s_f1'*w*s_f1

	while (s_itr<=opt.GN_maxsqz)
	{
		s_t2=s_t-s_lm*s_dt
		s_f2=deff(s_t2)
		lc2 = s_f2'*w*s_f2

		if (lc1 <= lc2 && lc1 <= obj1) {
			return (s_t1)
		}
		else {
			s_t1=s_t2
			s_lm=s_lm/2
			lc1=lc2
			s_itr=s_itr+1
		}
	}
	
	return(s_t2)
}
// end sqeez


// do gauss-newton
real colvector EWreg::EWgmm2(real matrix w, real colvector t)
{
	dt=1	// Initialize the step length.
	
	for (iter=1; iter<=opt.GN_maxiter & norm(dt,.)>=opt.tol ; iter++)
	{
		// find current objective
		f = deff(t)
		g = gradMOM(pprb->Drhs, t, 1)
		obj1 = f'*w*f
		
		// use the GAUSS-NEWTON method to compute optimal full step dt
		gwg= g'*w*g
		gwf= g'*w*f
		dt= cholinv(gwg)*gwf
		
		if (opt.GN_maxsqz > 0) 	t_new=sqeez(t,dt,obj1,w)
		else 					t_new=t-dt

		dt=t_new-t	// Update variables for the next iteration, also better for numerical stability
		t=t_new
	}
	
	if (iter>opt.GN_maxiter)
	{
		printf("Gauss-Newton stopped after maximum iterations. \n")
		return (0\t)
	}

	return (1\t)
}
// end EWgmm2


// do mata internal optimization (BFGS)
real colvector EWreg::EWgmm1(real matrix w, real colvector t)
{
	pointer(pointer() vector) scalar p
	p = crexternal("EWexternal")
	(*p) = (&this, &w)
	
	S=optimize_init()
	optimize_init_evaluator(S, &i_crit())
	optimize_init_which(S,"min")
	optimize_init_tracelevel(S,"none")
	optimize_init_evaluatortype(S,"d1")
	optimize_init_technique(S, "bfgs")
	optimize_init_conv_warning(S, "off")
	optimize_init_params(S,t')
	if (err=_optimize(S)) {
		printf("%s\n", optimize_result_errortext(S))
		printf("Using value from Gauss-Newton. Suspect problem is ill-condtioned. \n")
		t = J(1,0,0)
	}
	else {
		t=optimize_result_params(S)
	}

	rmexternal("EWexternal")	
	return(t')
}
// end EWgmm1


// do optimization based GMM computation
real colvector EWreg::dogmm(real matrix w, real colvector t)
{
	if (opt.optmet == 1) {
		//printf("Using BFGS optimizer. \n")
		t1 = EWgmm1(w,t)
		if (rows(t1)!=0) return (t1)
		// if here it means BFGS failed
		printf("BFGS failed. Attempting Gauss-Newton optimizer. \n")
	}

	// if here it means BFGS failed or optmet==2
	//printf("Using Gauss-Newton optimizer. \n")
	t1 = EWgmm2(w,t)
	
	if (opt.optmet == 2 & t1[1,1]==0) {
		//GN was first, we ran it, and it stopped after maxiter
		printf("Gauss-Newton failed. Attempting BFGS optimizer. \n")
		t2 = EWgmm1(w,t1[2..rows(t1),1])
		if (rows(t2)==0) {
			printf("BFGS failed to find a better solution than Gauss-Newton.")
			return (t1[2..rows(t1),1])
		}
		return (t2)
	}
	
	return (t1[2..rows(t1),1])
}
// end dogmm


// calculate the gradient matrix going with bigphiRT
real matrix EWreg::dogeeRT(real matrix sigz, real scalar denomy, real scalar numery, 			///
					real colvector denomx, real colvector numerx, real matrix sigeta, 			///
					numeric rowvector eta2p)
{

	//			muyx				sigz				beta		etaj				eps	  u
	nrows = (opt.nx+1)*opt.nz + opt.nz*(opt.nz+1)/2 + opt.nx + opt.nx*(opt.nx+1)/2 + opt.nx + 1

	// first column rho2, next nx columns tau2j
	gee = J(nrows,(1+opt.nx),0)
	
	/*** start with rho2 column (column 1) ***/
	
	// derivatives wrt muy
	counter=1
	for (i=1;i<=opt.nz;i++) {
		gee[counter,1]= (2*dta.muy'*sigz[,i])/denomy - numery*(2*dta.muy'*sigz[,i])/(denomy^2)
		counter++
	}

	// derivatives wrt sigz
	counter=(opt.nx+1)*opt.nz + 1
	for (i=1;i<=opt.nz;i++) {
		for (j=i;j<=opt.nz;j++) {
			x = ((i!=j)*1+1)*dta.muy[i,1]*dta.muy[j,1]
			gee[counter,1] = x/denomy - numery*x/(denomy^2)
			counter++
		}
	}
	
	// derivatives wrt the members of t we care about
	// first, betaj
	counter=(opt.nx+1)*opt.nz + opt.nz*(opt.nz+1)/2 + 1
	for (i=1;i<=opt.nx;i++) {
		gee[counter,1] = (2*dta.bX'*sigeta[.,i])/denomy - numery*(2*dta.bX'*sigeta[,i])/(denomy^2)
		counter++
	}

	// Now E(etaj1*etaj2) for all combs
	for (i=1;i<=opt.nx;i++) {
		for (j=i;j<=opt.nx;j++) {
			x = ((i!=j)*1+1)*dta.bX[i,1]*dta.bX[j,1]
			gee[counter,1] = x/denomy - numery*x/(denomy^2)
			counter++
		}
	}
	
	// E(u^2) is lonely
	//			muyx				sigz				 beta		etaj				eps
	counter = (opt.nx+1)*opt.nz + opt.nz*(opt.nz+1)/2 + opt.nx + opt.nx*(opt.nx+1)/2 + opt.nx + 1
	gee[counter,1] = -numery/(denomy^2)
	
	
	/*** now for the tau columns ***/

	for (jt=1;jt<=opt.nx;jt++) {
		// derivatives wrt mux
		counter = opt.nz*jt + 1
		for (i=1;i<=opt.nz;i++) {
			gee[counter,1+jt]= (2*dta.mux[.,jt]'*sigz[,i])/denomx[jt,1] - numerx[jt,1]*(2*dta.mux[.,jt]'*sigz[,i])/(denomx[jt,1]^2)
			counter++
		}

		// derivatives wrt sigz
		counter=(opt.nx+1)*opt.nz + 1
		for (i=1;i<=opt.nz;i++) {
			for (j=i;j<=opt.nz;j++) {
				x = ((i!=j)*1+1)*dta.mux[i,jt]*dta.mux[j,jt]
				gee[counter,1+jt] = x/denomx[jt,1] - numerx[jt,1]*x/(denomx[jt,1]^2)
				counter++
			}
		}
		
		// derivatives wrt the members of t we care about
		// E(eta^2)j
		counter = (opt.nx+1)*opt.nz + opt.nz*(opt.nz+1)/2 + opt.nx + eta2p[1,jt]
		gee[counter,1+jt] = 1/denomx[jt,1] - numerx[jt,1]/(denomx[jt,1]^2)
		// E(eps^2)j
		counter = (opt.nx+1)*opt.nz + opt.nz*(opt.nz+1)/2 + opt.nx + opt.nx*(opt.nx+1)/2 + jt
		gee[counter,1+jt] = - numerx[jt,1]/(denomx[jt,1]^2)
	}
	
	return (gee)
}
// end dogeeRT


// do post-estimation and create struct stats return value
struct stats scalar EWreg::getret()
{
	struct stats scalar retval
	retval = stats()

	
	/*** The basic stuff ***/
	
	retval.N			= opt.n
	retval.w			= w
	retval.IDval  		= J(1,1,-1)
	retval.IDstat 		= J(1,1,-1)

	
	/*** Save centered moments for next time ***/

	external real colvector EWSAVEDfCent
	if (opt.centmet==1)		EWSAVEDfCent = fsave
	
	
	/*** Sargan-Hansen J-stats ***/
	
	retval.obj		= obj
	retval.Jstat 	= obj*opt.n
	if (opt.doMOM())	retval.dfree = opt.neq-opt.nt
	else 				retval.dfree = opt.nk-opt.nx
	retval.Jval  	= 1-chi2(retval.dfree,retval.Jstat)

	
	/*** inflncX + inflncT ***/
	
	if (opt.doMOM()) {
		g 		= gradMOM(pprb->Drhs, t, 1)			//[neq,nt]
		nvcX 	= cholinv(g'*w*g)
		vcX 	= nvcX/opt.n
		inflncT = (nvcX*g'*w*ff')'  				//[n,nt], NOTE - Minus removed!
		inflncX = inflncT[.,1..opt.nx]				//[n,nx]
		inflncT = inflncT[.,(opt.nx+1)..opt.nt]		//[n,nt-nx]
	}
	else {
		D 		= dta.Dky - dta.Dkx*(dta.bX#I(opt.neq))			//[nk,neq]
		nvcX 	= cholinv(dta.kx'*w*dta.kx)
		vcX 	= nvcX/opt.n
		inflncX = (nvcX*dta.kx'*w*D*ff')'						//[n,nx]
		t		= pprb->resolve_eq(pprb->mom2, dta.bX, opt.neq2, opt.nx, opt.nt2, dta.emom)	//[nt2,1]
		g		= gradMOM(pprb->Dmom2, t, 0)					//[neq2,nt2]
		tmp		= I(opt.nt2)
		g 		= tmp[1..opt.nx,.]\g							//[neq2+nx,nt2] == [nt2,nt2]
		ff2		= (inflncX, ff[.,1..opt.neq2])					//[n,nt2]
		w2		= cholinv(getomega(ff2))						//[nt2,nt2]
		inflncT = (cholinv(g'*w2*g)*g'*w2*ff2')' 				//[n,nt2], NOTE - Minus removed!
		inflncT = inflncT[.,(opt.nx+1)..opt.nt2]				//[n,nt2-nx] == [n,neq2]
	}
	

	// redefine a local version of nt and ntvec to fit both MOM and CML
	if (opt.doMOM()) {
		nt = opt.nt
		ntvec = pprb->ntvec
	}
	else {
		nt = opt.nt2
		ntvec = pprb->ntvec2
	}
	
	
	/*** bZ ***/
	
	dta.bZ = dta.muy-dta.mux*dta.bX

	
	/*** inflncZ ***/
	
	geeZ = J((opt.nz*(opt.nx+1)+opt.nx), opt.nz, 0)
	geeZ[1..opt.nz,.] = -I(opt.nz)
	for (j=1;j<=opt.nx;j++) {
		geeZ[(opt.nz*j+1)..(opt.nz*(j+1)),.] = dta.bX[j,1]*I(opt.nz)
		geeZ[(opt.nz*(opt.nx+1)+j),.] = dta.mux[.,j]'
	}

	phimuyx = ((I(opt.nx+1)#dta.inEzz)*dta.zyx')'
	bigphiZ = phimuyx, inflncX
	avarZ = getomega(bigphiZ):/opt.n
	vcZ = geeZ'*avarZ*geeZ
	seZ = sqrt(diagonal(vcZ))
	inflncZ = bigphiZ*geeZ


	/*** rho and tau ***/

	ez = mean(dta.z)
	sigz = crossdev(dta.z, ez, dta.z, ez) :/ opt.n

	// build sigeta symmetric matrix [nx,nx]
	sigeta = J(opt.nx,opt.nx,0)
	eta2 = J(1,opt.nx,0)
	curr = ntvec[1,1] + 1
	for (i=1;i<=opt.nx;i++) {
		// also grab E(etaji^2] rowvector [1,nx] of addresses in t - only etaj*etaj
		eta2[1,i] = curr
		for (j=i;j<=opt.nx;j++) {
			sigeta[i,j] = t[curr]
			sigeta[j,i] = sigeta[i,j]
			curr++
		}
	}

	// grab E(ui^2] address in t
	u2 = sum(ntvec[1..3,1]) + 1
	
	// grab E(epsji^2] rowvector [1,nx] of addresses in t
	base_eps = sum(ntvec[1..2,1])
	eps2 = ((base_eps+1)..(base_eps+opt.nx))

	// grab E(etaji^2] rowvector [1,nx*(nx+1)/2] of addresses in t - all etaj1*etaj2 combs
	eta2_all=((ntvec[1,1] + 1)..(ntvec[1,1] + opt.nx*(opt.nx+1)/2))

	// do rho
	numery=dta.muy'*sigz*dta.muy + dta.bX'*sigeta*dta.bX
	denomy=(numery+t[u2,1])
	dta.rho=numery/denomy

	// do tau
	numerx=diagonal(dta.mux'*sigz*dta.mux) :+ t[eta2,1]
	denomx=(numerx:+t[eps2,1])
	dta.tau=numerx:/denomx

	
	/*** SE rho and tau ***/

	vecsigz=J(opt.nz*(opt.nz+1)/2,1,0)
	phiz=J(opt.n,opt.nz*(opt.nz+1)/2,0)

	counter=1
	for (i=1;i<=opt.nz;i++) {
		for (j=i;j<=opt.nz;j++) {
			vecsigz[counter,1] = sigz[i,j]
			phiz[.,counter]=(dta.z[,i]-J(opt.n,1,1)#ez[1,i]):*(dta.z[,j]-J(opt.n,1,1)#ez[1,j])
			counter++
		}
	}
	phiz=phiz:-J(opt.n,1,1)#vecsigz'
	
	// make the influence functions for rhotau
	bigphiRT = (phimuyx, phiz, inflncX, inflncT[.,eta2_all:-opt.nx], inflncT[.,eps2:-opt.nx], inflncT[.,u2:-opt.nx])
	avarRT = getomega(bigphiRT):/opt.n
	
	
	// build geeRT
	eta2p = eta2 :- ntvec[1,1]
	geeRT = dogeeRT(sigz, denomy, numery, denomx, numerx, sigeta, eta2p)

	
	/*** finish retval ***/
	
	retval.inflncXZ 	= inflncX, inflncZ
	retval.inflncRT 	= bigphiRT*geeRT
	retval.vcrhotau		= geeRT'*avarRT*geeRT
	retval.SErho		= sqrt(retval.vcrhotau[1,1])
	retval.SEtau		= sqrt(diagonal(retval.vcrhotau[2..(opt.nx+1),2..(opt.nx+1)]))
	retval.rho 			= dta.rho
	retval.tau 			= dta.tau
	retval.beta 		= dta.bX\dta.bZ
	retval.VCmat 		= getomega(retval.inflncXZ):/opt.n
	retval.serr 		= sqrt(diagonal(retval.VCmat))
	
	return (retval)
}
// end getret


// do J mismeasured regressors using moments or cumulants :)
struct stats scalar EWreg::doCLS(transmorphic colvector id, real colvector y, real matrix x, 	///
							real matrix z, numeric scalar met, numeric scalar clustmet, 		///
							numeric scalar maxdeg, real rowvector bXint, numeric scalar vcemet, ///
							numeric scalar optmet, real scalar centmet)
{
	opt = EWopt()
	opt.einit(rows(id), cols(x), maxdeg, cols(z), met, clustmet, vcemet, optmet, centmet)

	external class EWproblem scalar EWSAVEDprb
	if (EWSAVEDprb!=NULL) {
		if (cols(EWSAVEDprb.rocmat) != maxdeg | rows(EWSAVEDprb.xidx) != cols(x)) {
			printf("Problem structure different from last executed. Rebuilding problem.\n")
			EWSAVEDprb = EWproblem()
			EWSAVEDprb.einit(opt.maxdeg, opt.nx)
		}
	}
	else {
		EWSAVEDprb = EWproblem()
		EWSAVEDprb.einit(opt.maxdeg, opt.nx)
	}
	pprb = &EWSAVEDprb
	opt.setprb(*pprb)
	
	dta = EWdata()
	dta.einit(opt, *pprb, id, y ,x, z, bXint)
	
	// do identification tests
	// RPG - skip id tests for now

	
	// calculate optimal inverse weighting matrix, omega
	ff = optw()
	omega = getomega(ff)
	
	if (opt.doMOM()) {
		// do moments
		objsave = J(opt.nbXint,1,0)
		t = J(opt.nt,1,0)
		
		for (rep=1;rep<=opt.nbXint+1;rep++) {
			if (rep<=opt.nbXint) {
				bXinit = dta.get_beta(rep,opt)
			}
			else {
				if (opt.nbXint>1) {
					// restore best inital value
					minindex(objsave, 1, ind, where)
					bXinit = dta.get_beta(ind[1,1],opt)
				}
				else {
					// no point in restoring - only one value tested
					break
				}
			}
			
			t = pprb->resolve_eq(pprb->rhs, bXinit, opt.neq, opt.nx, opt.nt, dta.emom)
			w = cholinv(omega)
			t = dogmm(w, t)
			
			// save objective value for usage in final loop and reporting
			f = deff(t)
			obj = f'*w*f
			if (rep<=opt.nbXint) objsave[rep,1]=obj
		}
		dta.bX = t[1..opt.nx,1]
		fsave = f
	}
	else {
		// do cumulants
		
		bX = J(opt.nx,1,0)
		diffW = opt.tol + 1
		
		if (rows(dta.fCent)>0) dta.ky = dta.ky - dta.fCent

		for (iter = 0; iter<=opt.CML_maxiter & diffW > opt.tol ; iter++)
		{
			// D as defined in prop 1 of EJW2013
			D = dta.Dky - dta.Dkx*(bX#I(opt.neq))
			w = cholinv(D*omega*D')					//[nk,nk]
			iKWK = cholinv(dta.kx'*w*dta.kx)		//[nx,nx]
			bX1 = iKWK*dta.kx'*w*dta.ky				//[nx,1]
			diffW = norm(bX - bX1)
			bX = bX1
		}
		
		if (diffW > opt.tol) printf("Reached maxiter in CML. Continuing nevertheless.\n")
		dta.bX = bX
		fsave = (dta.ky-dta.kx*dta.bX)
		obj = fsave'*w*fsave
	}

	return (getret())
}
// end doCLS


// count mutual appearances in pan1 and pan2
real scalar EWreg::mutual_cnt(transmorphic colvector pan1, transmorphic colvector pan2)
{
	mutual = 0
	p1 = 1
	p2 = 1
	
	while(p1<=rows(pan1) && p2<=rows(pan2))
	{
		if(pan1[p1,1]<pan2[p2,1])
			p1=p1+1
		else if (pan1[p1,1]>pan2[p2,1])
			p2=p2+1
		else
		{
			p1=p1+1
			p2=p2+1
			mutual = mutual+1
		}
	}
	
	return (mutual)
}
// end mutual_cnt


// sharefrac hold nc/ni as defined in eq A4 of EW2011 RFS
real matrix EWreg::CMDshare(transmorphic colvector id, transmorphic colvector tm, 		///
					transmorphic colvector periods, transmorphic colvector pans)
{
	bigmat 	= (id,tm)
	bigmat 	= sort(bigmat,(2,1))
	id 		= bigmat[,1]
	tm 		= bigmat[,2]
	
	n_per   = rows(periods)
	n_panel = rows(pans)

	struct mt rowvector used
	used  = J(1, n_per, mt())
	
	ibeg = 1
	j = 1
	for (i=1;i<=rows(tm);i++)
	{
		if (tm[i,1]==periods[j,1]) continue
		used[1,j].inmat = id[ibeg..(i-1),1]
		ibeg=i
		j=j+1
	}
	used[1,j].inmat = id[ibeg..rows(id),1]
	
	if (j<n_per)
	{
		errprintf("Internal error in CMDshare. Please submit bug report.\n")
		exit(error(198))
	}
	
	sharefrac = J(n_per,n_per,0)
	for (t1=1;t1<=n_per;t1++)
	{
		n_pan = rows(used[1,t1].inmat)
		for (t2=1;t2<=n_per;t2++)
		{
			// is the entity in the panel in both time periods?
			sharefrac[t1,t2] = mutual_cnt(used[1,t1].inmat,used[1,t2].inmat)/n_pan
		}
	}
	
	return(sharefrac)
}
// end sharefrac


// find beginning position of each of ids in allids (assume both are sorted) - same as find ni
real colvector EWreg::findpos(transmorphic colvector ids, transmorphic colvector allids)
{
	pos = J(rows(ids),1,0)
	
	p_allids = 1
	
	for (p_ids=1;p_ids<=rows(ids);p_ids++)
	{
		while(allids[p_allids,1]!=ids[p_ids,1])
		{
			p_allids = p_allids+1
			if (p_allids > rows(allids))
			{
				errprintf("Internal error in findpos - please submit bug report\n")
				exit(error(198))
			}
		}
		pos[p_ids,1]=p_allids
	}
	
	return (pos)
}
//end findpos


// subroutine to compute classical minimum distance estimator
real rowvector EWreg::cmd(real rowvector csave, real matrix isave, real scalar n_period,		///
					real matrix sharefrac)
{
	// csave [1,S] - coefficients to be merged
	// isave [N,S] - influence functions of coefficients
	// retval = [theta, stderr, cmdtest, cmdval]

	ninfl = (isave:!=0)
	divideby = ninfl'*ninfl
	w        = pinv(isave'*isave:*sharefrac:*sharefrac':/(divideby:^2))
	g        = J(n_period,1,1)
	theta    = pinv(g'*w*g)*g'*w*csave'		// weighted average csave
	f        = csave' :- theta
	stderr   = sqrt(pinv(g'*w*g))
	cmdtest  = f'*w*f						// Sargan test value for the mini-gmm in here
	cmdval   = 1-chi2(n_period-1,cmdtest)	// Sargan p-val

	retval = (theta, stderr, cmdtest, cmdval)
	return (retval)
}
// end cmd


// wrap doCLS with a classical minimum distance estimator
struct stats scalar EWreg::doCMD(transmorphic colvector id, transmorphic colvector tm,			///
							real colvector y, real matrix x, real matrix z, real scalar met, 	///
							real scalar maxdeg, real rowvector bXint, real scalar vcemet, 		///
							real scalar optmet)
{
	n = rows(y)
	nx = cols(x)
	nz = cols(z)

	periods = uniqrows(tm)
	n_per   = rows(periods)
	pans    = uniqrows(id)
	n_panel = rows(pans)

	struct stats scalar ret
	struct stats scalar tmp
	ret = stats()
	tmp = stats()

	printf("\nDoing CMD post-estimation, please wait.\n")

	xz_csave = J(nx+nz,n_per,0)
	xz_isave = J(n_panel,(nx+nz)*n_per,0)
	rt_csave = J(nx+1,n_per,0)
	rt_isave = J(n_panel,(nx+1)*n_per,0)

	for (it=1;it<=n_per;it++)
	{
		//printf("Now at period %f of %f : %f\n",t,n_per,periods[t,1])
		us = (tm:==periods[it,1])
		tmp = doCLS(select(id,us), select(y,us), select(x,us), select(z,us), met, 2, maxdeg, bXint, vcemet, optmet, 0)
		
		xz_csave[.,it] = tmp.beta
		rt_csave[.,it] = tmp.rho\tmp.tau

		pos = findpos(select(id,us), pans)
		xz_isave[pos,((it-1)*(nx+nz)+1)..(it*(nx+nz))] = tmp.inflncXZ
		rt_isave[pos,((it-1)*(nx+1)+1)..(it*(nx+1))]   = tmp.inflncRT
	}
	
	sharefrac = CMDshare(id, tm, periods, pans)
	
	ret.beta 			= J(nx+nz,1,0)
	ret.VCmat 			= J(nx+nz,nx+nz,0)
	ret.tau 			= J(nx,1,0)
	ret.SEtau 			= J(nx,1,0)

	// do XZ
	for (i=1;i<=nx+nz;i++) {
		tmp1 = cmd(xz_csave[i,.], xz_isave[.,((i-1)*n_per+1)..(i*n_per)], n_per, sharefrac)
		ret.beta[i,1]  = tmp1[1,1]
		ret.VCmat[i,i] = tmp1[1,2]
	}
	
	// do R
	tmp1 = cmd(rt_csave[1,.], rt_isave[.,1..n_per], n_per, sharefrac)
	ret.rho   = tmp1[1,1]
	ret.SErho = tmp1[1,2]
	
	// do T
	for (i=2;i<=nx+1;i++) {
		tmp1 = cmd(rt_csave[i,.], rt_isave[.,((i-1)*n_per+1)..(i*n_per)], n_per, sharefrac)
		ret.tau[i-1,1]   = tmp1[1,1]
		ret.SEtau[i-1,1] = tmp1[1,2]
	}

	ret.serr 			= sqrt(diagonal(ret.VCmat))
	ret.N 				= n
	ret.Jstat 			= -1
	ret.Jval 			= -1
	ret.dfree 			= -1
	ret.vcrhotau 		= J(1,1,-1)
	ret.w 				= J(1,1,-1)
	ret.obj 			= -1
	ret.IDval 			= J(1,1,-1)
	ret.IDstat 			= J(1,1,-1)

	return (ret)
}
// end doCMD

end





///////////////////////////////////////////////////////////////////////////////////////
// The MATA entrypoint - mostly communicates with stata and calls doCLS/doCMD
///////////////////////////////////////////////////////////////////////////////////////

mata:

void doEW(string scalar depvar, string scalar misindep,	string scalar indepvars, 	///
		string scalar idname, string scalar tmname,	numeric scalar met, 			///
		numeric scalar clustmet, numeric scalar maxdeg, string scalar bXint, 		///
		numeric scalar vcemet, numeric scalar docons, numeric scalar nocons,        ///
		numeric scalar optmet, real scalar centmet, string scalar touse)
{
	st_view(y, ., depvar, touse)
	n  = rows(y)
	st_view(x=., ., tokens(misindep), touse)
	st_view(z=., ., tokens(indepvars), touse)
	
	if (idname=="") id = J(n,1,1)
	else st_view(id, ., idname, touse)
	
	if (tmname=="") tm = J(n,1,1)
	else st_view(tm, ., tmname, touse)

	bXint1 = strtoreal(tokens(bXint))
	
	//verify no missing in y,x,z,id,tm. we don't deal with missing values well.
	if (sum(y:==.)+sum(x:==.)+sum(z:==.)+sum(id:==.)+sum(tm:==.)>0)
	{
		errprintf("Command does not support missing values. Aborting.\n")
		exit(error(197))
	}
	
	if (docons==1 | nocons==1) // add constant (which is to be ignored in nocons case)
	{
		con = J(n,1,1)
		z = (z,con)
	}
	
	// make sure everything is sorted on id, will be crucial later
	bigmat 	= (id,tm,y,x,z)
	bigmat 	= sort(bigmat,(1,2,3))
	id 		= bigmat[,1]
	tm 		= bigmat[,2]
	y 		= bigmat[,3]
	x 		= bigmat[,4..(cols(x)+4-1)]
	z 		= bigmat[,(cols(x)+4)..cols(bigmat)]
	
	struct stats 	scalar 		retval
	class EWreg 	scalar 		ew
	
	ew = EWreg()

	if (clustmet==-1) { //do classical minimum distance
		retval = ew.doCMD(id, tm, y, x, z, met, maxdeg, bXint1, vcemet, optmet)
	}
	else { // do clustered weighting matrix
		retval = ew.doCLS(id, y, x, z, met, clustmet, maxdeg, bXint1, vcemet, optmet, centmet)
	}

	// Ignore Z if we are in a nocons case
	beta1  = retval.beta
	VCmat1 = retval.VCmat
	serr1  = retval.serr
	
	if (nocons==1) {
		N1 = cols(VCmat1) - 1
		beta1  = beta1[1..N1,]
		VCmat1 = VCmat1[1..N1,1..N1]
		serr1  = serr1[1..N1,]
	}

	// Return values
	st_matrix("r(beta)",beta1')
	st_matrix("r(VCmat)",VCmat1)
	st_numscalar("r(N)",n)
	st_matrix("serr",serr1)
	st_numscalar("r(Jstat)",retval.Jstat)
	st_numscalar("r(Jval)",retval.Jval)
	st_numscalar("r(dfree)",retval.dfree)
	st_numscalar("r(rho)",retval.rho)
	st_numscalar("r(SErho)",retval.SErho)
	st_matrix("tau",retval.tau)
	st_matrix("SEtau",retval.SEtau)
	st_matrix("vcrhotau",retval.vcrhotau)
	st_matrix("w",retval.w)
	st_numscalar("r(obj)",retval.obj)
	st_matrix("IDval",retval.IDval)
	st_matrix("IDstat",retval.IDstat)
}
// end function doEW

end
