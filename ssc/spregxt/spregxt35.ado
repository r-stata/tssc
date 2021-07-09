 program define spregxt35 , eclass byable(recall)
 version 11.2
 syntax varlist , [fe re be mle vce(str) aux(str)  level(str) ///
 idv(str) itv(str) wit(str) iter(int 10)]

 qui {
 gettoken yvar xvar : varlist
 tempvar dy dy1 X0 Time Yh_ML Ue_ML LYvar Z0
 tempname ldye12 By Bx Covx Covy Beta0 Beta1 Beta Cov kb0 kbd0 B V xz Bh xy2 Yh_ML Ue_ML
 local kx=e(kx)
 local kb=e(kb)
 local kbd=`kx'
 scalar `Beta0' = .
 scalar `Beta1' = 0
 xtset `idv' `itv'
 local NC=r(imax)
 local NT=r(tmax)
 local N=_N
 gen `Time'=_n
 gen double `LYvar' = L.`yvar'
 gen double `dy' = D.`yvar'
 gen double `dy1'= L.`dy'
 gen `Z0' = 1
 local j = 1
 while `j' <= `iter' & abs(`Beta1'-`Beta0') > 0.01 {
 tempvar Y Ys
 scalar `Beta0' = `Beta1'
 gen double `Y' = `yvar' - `Beta0'*`LYvar'
 local varhp ""
 foreach var of local xvar {
 tempvar dxv
 gen double `dxv' = `var' - `Beta0'*`LYvar'
 local varhp "`varhp' `dxv'"
 }
 if "`be'"=="" & "`fe'"=="" & "`mle'"=="" {
 xtreg `Y' `varhp' , re `vce' `level'
 }
 else {
 xtreg `Y' `varhp' , `mle' `fe' `be' `vce' `level'
 }
 matrix `Bx' = e(b)
 matrix `Covx' = e(V)
 gen double `Ys' = `yvar'
 local k = 1
 foreach x of local xvar {
 replace `Ys' = `Ys' - `Bx'[1,`k'] * `x'
 local k = `k' + 1
 }
 replace `Z0' = 1 - _b[_cons]
 tempvar dy ldy ldy2 Eh ldye ldye1
 gen double `dy' = D.`Ys'
 gen double `ldy' = L.`dy'
 gen double `ldy2'= 2*`dy'+`ldy'
 matrix accum `xy2' = `ldy' `ldy2' `Z0'
 matrix `By'= `xy2'[2,1]/`xy2'[1,1]
 local  By1 = `By'[1,1]
 gen double `Eh'= `ldy2' - `By1' * `ldy'
 gen double `ldye' = `ldy' * `Eh'
 by `idv': egen double `ldye1' = sum(`ldye')
 by `idv': replace `ldye1' = `ldye1'/sqrt(_N)
 matrix accum `ldye12' = `ldye1'
 matrix `Covy' = `ldye12'[1,1] / (`xy2'[1,1]^2)
 scalar `Beta1' = `By'[1,1]
 local j = `j' + 1
 }
 matrix `Beta' = `By'[1,1],`Bx'[1,1..`kbd']
 matrix `kbd0' = J(1,`kbd',0)
 matrix `Cov' = `Covy',`kbd0' \ `kbd0'',`Covx'[1..`kbd',1..`kbd']
 tokenize "L.`yvar' `xvar' "
 matrix colnames `Cov' = `*' _cons
 matrix rownames `Cov' = `*' _cons
 matrix colnames `Beta'= `*' _cons
 ereturn post `Beta' `Cov', depname("`yvar'")
 ereturn display , `level'
 ereturn scalar df_m=`kx'+1
 ereturn scalar N=_N
 }
 end

