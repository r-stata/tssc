capture program drop twsave
capture mata mata drop matasave()

findfile twres.ado
include "`r(fn)'"

mata
void matasave()
{
real matrix D, CinvHHDH, AinvDDDH, A, B, C
real colvector  invDD, invHH, var1,var2
real scalar N, T,correction_rank
string scalar newid,newt, w,sampleVarName, root


root =st_local("using")
newid=st_local("var_1")
st_local("newid",newid)
newt=st_local("var_2")
st_local("newt",newt)
w=st_local("twoway_w")
st_local("w",w)
N=st_numscalar("dimN")
T=st_numscalar("dimT")
correction_rank=st_numscalar("rank_adj")
invDD=st_matrix("invDD")
invHH=st_matrix("invHH") 
saveMat(root,"twoWayVar1", newid)
saveMat(root,"twoWayVar2", newt)
saveMat(root,"twoWayCorrection",correction_rank)
saveMat(root,"twoWayW",w)
saveMat(root,"twoWayN1", N)
saveMat(root,"twoWayN2", T)
saveMat(root,"twoWayInvDD", invDD)
saveMat(root,"twoWayInvHH", invHH)


 if (N<T)
		{
        CinvHHDH=st_matrix("CinvHHDH")
		A=st_matrix("A")
		B=st_matrix("B")

		saveMat(root,"twoWayCinvHHDH", CinvHHDH)
		saveMat(root,"twoWayA", A)
		saveMat(root,"twoWayB", B)
		
		
		}
    else
	{
        AinvDDDH=st_matrix("AinvDDDH")
		C=st_matrix("C")
		B=st_matrix("B")
		saveMat(root,"twoWayAinvDDDH", AinvDDDH)
		saveMat(root,"twoWayC", C)
		saveMat(root,"twoWayB", B)
		
    }


}

end


program define twsave, eclass
version 11
syntax [using/]

local absorb = "`e(absorb)'"
gettoken var1 aux: absorb
gettoken var2 w: aux
*obtain the name of the fixed effects
local var_1 `var1'
local var_2 `var2'
local twoway_w `w'

qui{
tempvar touse_save
gen byte `touse_save'= e(sample)
}

*create the scalars that are store in e()
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

*create the new list of macros
ereturn clear
ereturn post, esample(`touse_save')
mata matasave()
ereturn local absorb "`newid' `newt' `w'"
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
