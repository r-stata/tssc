capture program drop twload
capture mata mata drop mataload()

findfile twsave.ado
include "`r(fn)'"

mata
void mataload()
{
real matrix D, CinvHHDH, AinvDDDH, A, B, C
real colvector  invDD, invHH
real scalar N, T, correction_rank
string scalar sampleVarName, root
root =st_local("using")

N=readMat(root,"twoWayN1")
T=readMat(root,"twoWayN2")

correction_rank=readMat(root,"twoWayCorrection")
invDD=readMat(root,"twoWayInvDD")
invHH=readMat(root,"twoWayInvHH")
st_numscalar("e(dimN)",N)
st_numscalar("e(dimT)",T)
st_numscalar("e(rank_adj)",correction_rank)
st_matrix("e(invDD)",invDD)
st_matrix("e(invHH)",invHH) 

 if (N<T)
		{
        CinvHHDH=readMat(root,"twoWayCinvHHDH")
		A=readMat(root,"twoWayA")
		B=readMat(root,"twoWayB")
		st_matrix("e(CinvHHDH)",CinvHHDH)
		st_matrix("e(A)",A)
		st_matrix("e(B)",B)
	
		}
    else
	{
        AinvDDDH=readMat(root,"twoWayAinvDDDH")
		C=readMat(root,"twoWayC")
		B=readMat(root,"twoWayB")
		st_matrix("e(AinvDDDH)",AinvDDDH)
		st_matrix("e(C)",C)
		st_matrix("e(B)",B)
		
    }

}

end


program define twload, eclass
version 11
syntax [using/] [if] [in]
mata mataload()
mata microMataLoad()
*tokenize the names of the fixed effects
gettoken twoway_id: var1
gettoken twoway_t: var2
gettoken twoway_w: w
	qui{
	tempvar touse_set
	mark `touse_set' `if' `in'
	markout `touse_set' `twoway_id' `twoway_t' `twoway_w'
	*Discard the observations with negative weights
	if !("`twoway_w'"==""){
	replace `twoway_w' = . if `twoway_w'<=0
	replace `touse_set' = 0 if `twoway_w' == .
	}

	tempvar touse_set2
	nonredundants `twoway_id' `twoway_t' if `touse_set', gen(`touse_set2')
}
*save the arrays, scalars obtained in ProjDummies_load()
scalar dimN= e(dimN)
scalar dimT=e(dimT)
scalar rank_adj=e(rank_adj)
matrix invDD=e(invDD)
matrix invHH=e(invHH)

if (dimN<dimT){
	matrix CinvHHDH=e(CinvHHDH)
	matrix A= e(A)
	matrix B=e(B)
}
else {
	matrix AinvDDDH=e(AinvDDDH)
	matrix C= e(C)
	matrix B=e(B)
}
ereturn post, esample(`touse_set2')
ereturn local absorb "`var1' `var2' `w'"
*store the arrays and scalars in e()
ereturn scalar dimN= dimN
ereturn scalar dimT= dimT
ereturn scalar rank_adj=rank_adj
ereturn matrix invDD= invDD
ereturn matrix invHH= invHH
if (dimN<dimT){
	ereturn matrix CinvHHDH=CinvHHDH
	ereturn matrix A= A
	ereturn matrix B= B
}
else {
	ereturn matrix AinvDDDH=AinvDDDH
	ereturn matrix C= C
	ereturn matrix B= B
}


end
