mata:
void transition_driven_subsmat (string matrix tabmat) {
// Read stata matrix into mata
G=st_matrix(tabmat)

if (rows(G)!=cols(G)) {
_error("Table isn't square")
}

Gr=G:/rowsum(G)
subsmat= trunc(0.5:+(J(rows(G),rows(G),2) - Gr - Gr' - 2:*I(rows(G))):*1000000):/1000000 
subsmat = subsmat - diag(subsmat)
st_matrix(tabmat,subsmat)
}

end

capture program drop trans2subs
program define trans2subs
   syntax varlist(min=1 max=1) [if] [in], IDvar(varname) SUBSmat(string) [DIAgincl]

   marksample touse
   
   local colvar `varlist'
   tempvar rowvar

   by `idvar': gen `rowvar'=`colvar'[_n-1] if _n>1
   
   di "Generating transition-driven substitution matrix"
   
   if ("x`diagincl'"=="x") {
      qui tab `rowvar' `colvar' if (`rowvar' != `colvar') & `touse', matcell(`subsmat')
      }
   else {
      qui tab `rowvar' `colvar' if `touse', matcell(`subsmat')
      }
   
   
   mata: transition_driven_subsmat("`subsmat'")
end
