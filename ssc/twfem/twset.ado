capture program drop twset 
capture program drop nonredundants
capture mata mata drop sparse()
capture mata mata drop excludemissing()
capture mata mata drop proddiag()
capture mata mata drop diagprod()
capture mata mata drop diagminus()
capture mata mata drop projDummies()
capture mata mata drop saveMat()
capture mata mata drop readMat()

//Mata programs:


mata:
real matrix sparse(real matrix x)
 {
  real matrix y
  real scalar k
 
  y = J(colmax(x[,1]),colmax(x[,2]),0) 
  for (k=1; k<=rows(x); k++) {
    y[x[k,1],x[k,2]] = y[x[k,1],x[k,2]] + x[k,3]
  }
 
  return(y)
 }
 
  //sparse matrix function ends
  

 // multiplying a diagonal matrix represented by a vector times a matrix.
 // Diag*A multiplies each rows.
 real matrix diagprod(real colvector x, real matrix A)
 {
  real matrix y
  real scalar k
  if(rows(x)<cols(x)) x = x'
 
  y = J(rows(A),cols(A),0)
  for (k=1; k<=rows(x); k++) {
    y[k,] = A[k,] * x[k,1]
  }
 
  return(y)
 }
 
   matrix readMat(string s,string n)
 {
  matrix X
  real scalar fh
fh = fopen(s+"_"+n, "r")
X = fgetmatrix(fh)
fclose(fh)
return(X)
 }
 
 
  
 void saveMat(string s,string n,matrix X)
 {
  real scalar fh
fh = fopen(s + "_" + n, "rw")
fputmatrix(fh, X)
fclose(fh)
 }
 
 
  real matrix proddiag(real matrix A,real colvector x)
 {
  real matrix y
  real scalar k
  if(rows(x)<cols(x)) x = x'
 
  y = J(rows(A),cols(A),0)
  for (k=1; k<=rows(x); k++) {
    y[,k] = A[,k] * x[k,1]
  }
 
  return(y)
 }
 
   real matrix diagminus(real colvector x,real matrix A)
 {
  //real matrix y
  real scalar k
  if(rows(x)<cols(x)) x = x'
 
  //y = -A
  for (k=1; k<=rows(x); k++) {
    A[k,k] = A[k,k] - x[k,1]
  }
 
  return(-A)
 }
 

 void projDummies()
{
real matrix D, DH1, DH, CinvHHDH, AinvDDDH, A, B, C
real colvector DD, HH, invDD, invHH
real scalar N, T, save_to_e,correction_rank 
string scalar newid,newt,w,sampleVarName, root
D=.
root=st_local("using")
save_to_e=st_numscalar("save_to_e")
newid=st_local("var1")
newt=st_local("var2")
w = st_local("twoway_w")
sampleVarName = st_local("touse_set2")
if (w==""){
D = st_data(.,(newid,newt),sampleVarName)
D = (D,J(rows(D),1,1))
}
else {
D = st_data(.,(newid,newt,w),sampleVarName)
}


DH1=sparse(D)
DD=quadrowsum(DH1)
HH=quadcolsum(DH1)'
HH=HH[1..cols(DH1)-1]
DH=DH1[.,1..cols(DH1)-1]
invDD=DD:^-1 
invHH=HH:^-1

N=colmax(D)[.,1]
T=colmax(D)[.,2]
//save the scalar in eresults	
st_numscalar("e(dimN)",N)
st_numscalar("e(dimT)",T)

//save the matrices in eresults
if (save_to_e>0){
	st_matrix("e(invDD)",invDD)
	st_matrix("e(invHH)",invHH) 

}
//save the scalars and matrices the current directory or in the path selected
else
{
	saveMat(root,"twoWayVar1", newid)
	saveMat(root,"twoWayVar2", newt)
	saveMat(root,"twoWayW",w)
	saveMat(root,"twoWayN1", N)
	saveMat(root,"twoWayN2", T)
	saveMat(root,"twoWayinvDD", invDD)
	saveMat(root,"twoWayinvHH", invHH)
}

if (N<T)
		{
        
        CinvHHDH=diagprod(invHH,DH')
		A=invsym(diagminus(DD,CinvHHDH'*DH'))
		correction_rank= N-rank(A)
        B=-A*CinvHHDH'
		//save the matrices in eresults
		if (save_to_e>0){
			st_matrix("e(CinvHHDH)",CinvHHDH)
			st_matrix("e(A)",A)
			st_matrix("e(B)",B)
			st_numscalar("e(rank_adj)",correction_rank)

		}
		//save the matrices the current directory or in the path selected
		else{
			saveMat(root,"twoWayCinvHHDH", CinvHHDH)
			saveMat(root,"twoWayA", A)
			saveMat(root,"twoWayB", B)
			saveMat(root,"twoWayCorrection",correction_rank)


		}		
			
		
		}
    else
	{
        AinvDDDH=diagprod(invDD,DH)
		C=invsym((diagminus(HH,AinvDDDH'*DH)))
		correction_rank= T-rank(C)
        B=-AinvDDDH*C

		//save the matrices in eresults
		if (save_to_e>0){
			st_matrix("e(AinvDDDH)",AinvDDDH)
			st_matrix("e(C)",C)
			st_matrix("e(B)",B)
			st_numscalar("e(rank_adj)",correction_rank)

		}
		
		//save the matrices the current directory or in the path selected		
		else{
			saveMat(root,"twoWayAinvDDDH", AinvDDDH)
			saveMat(root,"twoWayC", C)
			saveMat(root,"twoWayB", B)
			saveMat(root,"twoWayCorrection",correction_rank)


		}		
			

		
    }
//save the scalar in eresults	
	st_numscalar("e(rank_adj)",correction_rank)

 }
 
 end
 
program define nonredundants, eclass sortpreserve
version 11
syntax varlist(min=2 max=2) [if] [in], GENerate(name)

gettoken twoway_id twoway_t: varlist

	*touse_red is created to pass the if and in options of twset or twload to nonredundants 
	tempvar touse_red
	mark `generate' `if' `in'
	
	tempvar howmany
	count if `generate'== 1
	
	*with this part of the code we are able to discard the redundants observations of analysis 
	while `r(N)' {
			bys `twoway_id': gen `howmany' = _N if `generate'
			replace `generate'= 0 if `howmany' == 1
			drop `howmany'

			bys `twoway_t': gen `howmany' = _N if `generate'
			replace `generate'= 0 if `howmany' == 1
						
			count if `howmany' == 1
			drop `howmany'
			}
end


program define twset, eclass sortpreserve
version 11
syntax varlist(min=2 max=3) [if] [in] [using/], [GENerate(namelist min=2 max=2) Nogen] 
gettoken twoway_id aux: varlist
gettoken twoway_t twoway_w: aux

	qui{
	*if and in options to twset  
	tempvar touse_set
	mark `touse_set' `if' `in'
	markout `touse_set' `varlist'
	*Discard the observations with negative weights
	if !("`twoway_w'"==""){
	replace `twoway_w' = . if `twoway_w'<=0
	replace `touse_set' = 0 if `twoway_w' == .
	}

	tempvar touse_set2 touse_set3
	nonredundants `twoway_id' `twoway_t' if `touse_set', gen(`touse_set2')

	*touse_set2 is used in ProjDummies() as a marker of nonredundants observations
	*touse_set_3 is created to be used in e(sample)
	gen `touse_set3'=`touse_set2'
	
	ereturn post, esample(`touse_set3')
}
	*if generate option is omitted there is no creation of extra fixed effects consecutives
	capt assert inlist( "`generate'", "")
	if !_rc { 
		di "{err} Warning in twfem/twset: generate option not detected. The program may be slower or crash if fixed effects indices are not consecutive integers." 
		tempvar var1 var2
		local var1  "`twoway_id'"
		local var2  "`twoway_t'"
	} 
	else{
		*if the fixed effects are not consecutive the user has to create new variables to be used to create D matrix
		qui{
		gettoken var1 var2: generate
		egen `var1'= group(`twoway_id') if `touse_set2'==1
		egen `var2'= group(`twoway_t') if `touse_set2'==1
	
		}		
		}
	ereturn local absorb "`var1' `var2' `twoway_w'"
	
capt assert inlist( "`using/'", "")
if !_rc {    
	scalar save_to_e=1
}
else{
	scalar save_to_e=0
}

	mata projDummies()
	drop `touse_set'
	
	


end
