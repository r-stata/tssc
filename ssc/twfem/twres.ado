capture program drop twres
capture mata mata drop projVar()
capture mata mata drop microMataLoad()

findfile twset.ado
include "`r(fn)'"

mata 
void microMataLoad()
{
	string scalar newid,newt, w, root
	root =st_local("using")
	w = readMat(root,"twoWayW")
	var1= readMat(root,"twoWayVar1")
	var2= readMat(root,"twoWayVar2")
	st_local("var1",var1)
	st_local("var2",var2)
	st_local("w",w)
}
end

mata
void projVar()
{
	real matrix V, varIn, D,aux,delta,tau,varOut,A,B,CinvHHDH,AinvDDDH,C
	real colvector invHH,invDD,Dy,Ty
	real scalar N,T, correction_rank, save_to_e
	string scalar newid, newt, currvar,newvar,sampleVarName,w,linear_index,var1,var2, root
	root=st_local("using")
	save_to_e=st_numscalar("save_to_e")
	currvar = st_local("currvar")
	newvar = st_local("newvar")
	var1 = st_local("var1")
	var2 = st_local("var2")
	w=st_local("w")

	sampleVarName = st_local("touse_proj")
	linear_index = st_local("linear_index")

	V = st_data(.,(var1, var2,currvar),sampleVarName)
	varIn=V[.,3]
	
	if (w==""){
	D = st_data(.,(var1, var2),sampleVarName)
	D = (D,J(rows(D),1,1))
	}
	else {
	D = st_data(.,(var1, var2,w),sampleVarName)
	}
		
	V[.,3]=V[.,3]:*D[.,3]
	aux=sparse(V)
	Dy=rowsum(aux)
	Dy=Dy
	Ty=colsum(aux)
	Ty=Ty[1,1..cols(aux)-1]'

	//load the matrices from eresults
	if (save_to_e>0){
		N=st_numscalar("e(dimN)")
		T=st_numscalar("e(dimT)")
		correction_rank=st_numscalar("e(rank_adj)")
		B=st_matrix("e(B)")
	}
	else{
		//load the matrices from using option
		N=readMat(root,"twoWayN1")
		T=readMat(root,"twoWayN2")
		correction_rank=readMat(root,"twoWayCorrection")
		B=readMat(root,"twoWayB")
		st_numscalar("e(dimN)",N)
		st_numscalar("e(dimT)",T)
		st_numscalar("e(rank_adj)",correction_rank)
		
	}

	 if (N<T)
			{
			if (save_to_e>0){
				A=st_matrix("e(A)")
				invHH=st_matrix("e(invHH)")
				CinvHHDH=st_matrix("e(CinvHHDH)")
			}
			else{
				A=readMat(root,"twoWayA")
				invHH=readMat(root,"twoWayinvHH")
				CinvHHDH=readMat(root,"twoWayCinvHHDH")
			}
			delta=A*Dy+B*Ty
			tau=B'*(Dy-CinvHHDH'*Ty)+(invHH:*Ty) \0
			}
		else
		{
			if (save_to_e>0){
				C=st_matrix("e(C)")
				invDD=st_matrix("e(invDD)")
				AinvDDDH=st_matrix("e(AinvDDDH)")
			}
			else{
				C=readMat(root,"twoWayC")
				invDD=readMat(root,"twoWayinvDD")
				AinvDDDH=readMat(root,"twoWayAinvDDDH")
			}
			delta=(invDD:*Dy)+B*(Ty-AinvDDDH'*Dy)
			tau=B'*Dy+C*Ty \0 
		}

	varOut=(varIn-delta[V[.,1]]-tau[V[.,2]]):*sqrt(D[.,3])
	st_store(st_data(.,linear_index,sampleVarName), newvar, varOut)

}
end



program define twres, eclass
version 11
syntax varlist(numeric ts fv) [using/], [Prefix(name)] [REPLACE]

local varlist `varlist'
local anything `varlist'

foreach x of local anything {
	if strpos("`x'","."){
		capt assert inlist( "`.'", "")
		local rc = !_rc
		if !_rc {
			di "{err} factor-variable and time-series operators not allowed, create the variables and then re-run the command"
				exit !_rc
			}
	}
}

foreach currvar of  local varlist{ 
	if ("`replace'"=="") {
		capture confirm variable `prefix'`currvar'
		local rc = !_rc
		if !_rc {
				di "{err} The variable `prefix'`currvar' already exists."
				exit !_rc
			}
		}
}


	*in e(absorb) there is the fixed effects that we use to generate the new matrix V
	local absorb = "`e(absorb)'"
	gettoken var1 aux : absorb
	gettoken var2 twoway_w : aux
	local w `twoway_w'
	
	*set the vars to be projected
	gettoken depvar indepvars : varlist
    _fv_check_depvar `depvar'
    fvexpand `indepvars' 
	
	qui{
		
	tempvar touse_proj touse_check linear_index
	*set the sample that is projected
	gen byte `touse_proj'= e(sample)
	gen byte `touse_check'  =  `touse_proj'
	*touse_check is a marker of missing values of the vars projected
	markout `touse_check'  `varlist'
	*check if there is a missing in some of the variables
	capture assert  `touse_proj' ==  `touse_check' 
	local rc = _rc
	}
	if `rc' {
		  di "{err} Some of the included variables have missing values."
	   exit `rc'
	}
	drop `touse_check'

	
	*check that there is using in the command or not.
	capt assert inlist( "`using/'", "")
	if !_rc { 
			*check if e() has not been rewritten
			capt confirm scalar e(dimN)
			if _rc { 
				di "{err} The e() has been rewritten, please run twset again."
				exit
			}
			scalar save_to_e=1
			}
	else{
		scalar save_to_e=0
		mata microMataLoad()
		gettoken twoway_id: var1
		gettoken twoway_t: var2
		gettoken twoway_w: w

		qui{
			tempvar touse_proj touse_proj2 touse_proj3
			mark `touse_proj2' `if' `in'
			markout `touse_proj2' `twoway_id' `twoway_t' `twoway_w'	
			*Discard the observations with negative weights
			if !("`twoway_w'"==""){
				replace `twoway_w' = . if `twoway_w'<=0
				replace `touse_proj2' = 0 if `twoway_w' == .
				}

			tempvar touse_set2
			nonredundants `twoway_id' `twoway_t' if `touse_proj2', gen(`touse_proj')
			}
		  gen `touse_proj3'=`touse_proj2'
		  ereturn post, esample(`touse_proj3')
		  ereturn local absorb "`var1' `var2' `twoway_w'"
		  ereturn scalar dimN= e(dimN)
		  ereturn scalar dimT= e(dimT)
		  ereturn scalar rank_adj=e(rank_adj)

		}

	

	*variable created to store only the observations that are non-missings and in that way the arrays are conformables
	gen `linear_index' = _n	
	
	*we create the new variables, if a variable already exists then it is ignored and not projected
	foreach currvar of local varlist {
		local newvar="`prefix'`currvar'"
		if ("`replace'" != "") {
		local newvar="`currvar'"
		mata projVar()
		}
		else {
			  capture confirm variable `prefix'`currvar', exact
			  if !_rc { 
				}
			else{
			qui gen `newvar'=.
			mata projVar()
			}
		}	

	
	}


end
