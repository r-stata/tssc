
*!multigmelogit 1.0 Jan 21, 2015
* Paul Corral

program define gmemultinomial, eclass

	version 11.2
	syntax varlist(min=2 numeric fv) [if] [in] [,GENerate(string) NOCons BASEoutcome(numlist)]
	

//mark estimation sample

marksample touse

//Check if we have categorical variable

tokenize `varlist'

qui:tab `1' if `touse'
if (r(r)<2 | r(r)==.){
	display as error "You must specify a categorical variable"
	error 498
	}
	
local numdep=r(r)
	

// Local for dependent variable
local depend `1'
// obtain the independent variables
macro shift 
local indeps `*'

//Remove collinear explanatory vars
_rmcoll `indeps' if `touse', forcedrop
local indeps  `r(varlist)'


if "`baseoutcome'"!=""{
qui:levelsof `depend', local(eqns) separate(,)
if (inlist(`baseoutcome',`eqns'))!=1{
display as error "Baseoutcome is not a member of the dependent variable"
exit
}

}

else{
qui:levelsof `depend',local(eqns)
tokenize `eqns'
local baseoutcome `1'
}

///Okay now create the depvars
local check:value label `depend'

qui: levelsof `depend' if `depend'!=`baseoutcome', local(eqns)

local eqns `baseoutcome' `eqns'



	foreach x of local eqns{		
		tempvar d`x'
		gen `d`x''=(`depend'==`x')
		
		local depvars `depvars' `d`x''
		}
		

if "`check'"==""{


	tokenize `eqns'
	macro shift
	local eqnames `*'
	}
	
else{
	tokenize `eqns'
	macro shift 
	local EQ `*'

	foreach x of local EQ{
		local nm: label `check' `x'
		local wc=wordcount("`nm'")
			if `wc'!=1{
				local a=1
			foreach z of local nm{
				if `a'!=1{
					local AH `AH'_`z'
					}
				else{
					local AH `z'
					}
				local a=`a'+1
			}
			local eqnames `eqnames' `AH'
			}
		else{
		local eqnames `eqnames' `nm'
		}
		}
		}

**
** Names for matrices	
local wc=wordcount("`eqnames'")



	
if "`nocons'"=="nocons" {
mata: multigme_discrete("`depvars'", "`indeps'", 1, "`touse'")

forvalues c=1/`wc'{
	
	tokenize `eqnames'
	foreach x in `indeps'{
	local EQn `EQn' ``c''
	local Varn `Varn' `x'
	}
	}


}
else{
mata: multigme_discrete("`depvars'", "`indeps'", 0, "`touse'")
local eqs = `wc'
forvalues c=1/`wc'{
	
	tokenize `eqnames'
	foreach x in `indeps' _cons{
	local EQn `EQn' ``c''
	local Varn `Varn' `x'
	}
	}
}

tempname s
mat `s' = r(Prob)




tempname b V 
mat `b' = r(beta)
mat `V' = r(V)
mat coleq `b' = `EQn'
mat coln  `b' =  `Varn'

mat coleq `V' = `EQn'
mat roweq `V' = `EQn'

mat rown `V' = `Varn'
mat coln `V' = `Varn'

// Predicted results:
if "`generate'"!=""{
	tokenize `generate'
	
	local wc=wordcount("`generate'")
	if `wc'!=1{
		display as error "You must specify a name for predicted variable, only one"
			}
	else{
		capture confirm name `1'
		if _rc!=0{
			display as error "Invalid name for new variable"
				}
		else{
			capture confirm variable `1'
			if _rc==0{
			display as error "For predicted values, specify variable not already in use"
				}
			else{
			
			foreach i of local eqns{
			qui: gen double `generate'`i'=. if `touse'
			local pred `pred' `generate'`i'
			}
			mata:predict_gmulti("`indeps'", "`b'", "`pred'", "`touse'")
			}
			}
		}
				
			

}
	
	
**************************************************
**************************************************
**************************************************

local N=r(N)
ereturn post `b' `V', depname(`depend') obs(`N') esample(`touse')




//Number of observations
ereturn scalar N = r(N)
//Degs of freedom
ereturn scalar d_fm = (r(K)-1)
//Log likelihood 
ereturn scalar lnf = r(lnf)
//Log likelihood 
ereturn scalar lnf0 = r(lnf0) 
//Normalized entropy
ereturn scalar Sp = r(Sp)
//Pseudo R2
ereturn scalar R2 = (1- r(Sp))
//Entropy for probs.
ereturn scalar S = r(S)
//Entropy ratio statistic
ereturn scalar ERS = 2*r(N)*ln(2)*(1- r(Sp))
// P value for LR
ereturn scalar pv = chiprob(e(d_fm),e(ERS))



display _newline in gr "Generalized Maximum Entropy (MLogit)" _col(52) in gr "Number of obs" _col(71) in gr "=" _col(72) in ye %7.0f e(N)
display _col(52) in gr "Entropy for probs." _col(71) in gr "=" _col(72) in ye %7.1f e(S)
display _col(52) in gr "Normalized entropy" _col(71) in gr "="  _col(72) in ye %7.4f e(Sp)
display _col(52) in gr "Ent. ratio stat." _col(71) in gr "="  _col(72) in ye %7.1f e(ERS)
display _col(1) in gr "Criterion F (log L) = "  in ye e(lnf) _col(52) in gr "Pseudo R2" _col(71) in gr "=" _col(72)  in ye %7.4f e(R2)

ereturn display

end



mata: mata set matastrict on
mata:
// Discrete GME 1.0.0  Jan 21, 2015
function multigme_discrete(string scalar yname, 
                  string scalar xname, 
				  real scalar nc,
                  string scalar touse) 
				  
{
	
	real matrix  Y, X, vcov
	real vector cons, beta, v1, P,B,omega
	real scalar K, N, lnf, lnf0, s, Sp, S
	
// Use st_data to import variables from stata

	Y=st_data(., tokens(yname), touse)
	X=st_data(., tokens(xname), touse)
	
		
	if (nc==0){
	cons = J(rows(X),1,1)
	X=X,cons
	}
	
	
// Observations
	N=rows(X)
// Variables
	K=cols(X)

// Create error  vector, Symmetric error support vector

	v1=-1/sqrt(rows(Y))\0\1/sqrt(rows(Y))
	
// Optimization
			s=optimize_init()
			optimize_init_evaluator(s,&multidis())
			optimize_init_evaluatortype(s,"d1")
			optimize_init_which(s,"min")
			optimize_init_technique(s,"nr")
			optimize_init_argument(s,1,Y)
			optimize_init_argument(s,2,X)
			optimize_init_argument(s,3,v1)
			
			optimize_init_params(s,J(1,(cols(X)*(cols(Y)-1)),0))
			beta=-optimize(s)
			vcov=optimize_result_V_oim(s)
			lnf=-optimize_result_value(s)
			lnf0=-optimize_result_value0(s)

			
// Normalized entropy	
B=J(1,cols(X),0)\colshape(beta, cols(X))
omega=rowsum(exp(cross(X',B')))
P=vec(exp(cross(X',B')):/omega)

S=-sum(P:*log(P))
Sp=S/(rows(X)*log(cols(Y)))

P=exp(cross(X',B')):/omega


// Return results to Stata

	st_matrix("r(beta)",beta)
	st_matrix("r(Prob)",B)
	st_matrix("r(V)",vcov)
	st_numscalar("r(lnf)", lnf)
	st_numscalar("r(lnf0)", lnf0)
	st_numscalar("r(N)", N)
	st_numscalar("r(K)", K)
	st_numscalar("r(Sp)", Sp)
	st_numscalar("r(S)", S)
	
}
end

mata:
mata set matastrict off

// Multinomial GME optimization Jan 21, 2015

function multidis (todo, R, Y, X,v, L, g, H)  ///J categories
{

B=J(1,cols(X),0)\colshape(R, cols(X))

P1=cross(X',B')
z=cross((vec(Y)),(I(cols(Y))#X))

A=cross(z',(vec(B')))

omega=rowsum(exp(-P1))
psi=rowsum(exp(vec(-P1)*v'))

	p=vec(exp(-P1):/omega)
	w=exp(vec(-P1)*v'):/psi
	
	

L=A+sum(log(omega))+sum(log(psi))

if (todo==1){

    dep=cross((vec(Y)),(I(cols(Y))#X))
	ex=cross((vec(p)),(I(cols(Y))#X))
	error=cross(cross(w',v),(I(cols(Y))#X))
	
	grad=(dep-ex-error)

g=grad[|1,(cols(X)+1)\.,.|]
}

}
end

mata: mata set matastrict on
mata:

function predict_gmulti (string scalar xname, 
                     string scalar bname,
				     string scalar pname,
                     string scalar touse)
				  
{

	real matrix X, omega, P
	real vector  beta, newvar
	
	
	
	X=st_data(., tokens(xname), touse)
	X=X,J(rows(X),1,1)
	st_view(newvar,., tokens(pname), touse)
	beta=st_matrix(bname)
	
	beta=J(1,cols(X),0)\colshape(beta, cols(X))
	
	// Normalized entropy	
	omega=rowsum(exp(cross(X',beta')))
	P=exp(cross(X',beta')):/omega
	
	newvar[.,.]=P
	
}

end

mata: mata set matastrict off
	

		





