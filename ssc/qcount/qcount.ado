*! Quantile Regression for Count Data
*! Version 1.0.0
*! Author: Alfonso Miranda
*! Cetre for Economic Research
*! Keele University
*! Keele, Staffordshire ST5 5BG, UK.
*! Date: 07.08.2007
*! Acknowledgement: Many thanks to Joao Santos Silva
*! for his TSP version of the QR Count model

program define qcount, eclass
    version 7
    if replay() {
        if "`e(cmd)'" != "qcount" { error 301 }
        else Display `0'
        }
    else Estimate `0'
end

program define Estimate, eclass
    syntax varlist [if] [in], Quantile(real) [REPetition(integer 1000)]

gettoken endgv exogv : varlist, parse("")

_rmcoll `exogv', nocons
local exogv "`r(varlist)'"

marksample touse
markout `touse' `varlist'
qui su `endgv' if `touse'
local N = r(N)

if `quantile'>=1 {
    di in red "quantile option should be higher than zero and less than one"
    error 197
     }

local m = `repetition'
local eps = 1e-10
local cn = (0.5*ln(ln(`N')))/sqrt(`N')
local nev : word count `exogv'
local nev = `nev' + 1
local names "`exogv' _cons"
tempname mb mV mK
mat `mb' = J(1,`nev',0)
mat `mV' = J(`nev',`nev',0)
mat `mK' = J(`nev',`nev',0)
mat colnames `mb' = `names'
mat colnames `mV' = `names'
mat rownames `mV' = `names'
mat colnames `mK' = `names'
mat rownames `mK' = `names'
set seed 123456789
forvalues i = 1/`m' {
 tempvar u`i' z`i' y`i' xb`i' test`i' sumtest`i'
 tempname b`i'
 qui gen double `u`i''=uniform() if `touse'
 qui gen double `z`i''=`endgv'+`u`i'' if `touse'
 qui gen double `y`i'' = log(`eps') if `touse'
 qui replace `y`i''=log(`z`i''-`quantile') if ((`z`i''-`quantile')>`eps') & `touse'

 qui qreg `y`i'' `exogv', q(`quantile')
 mat `b`i''=(1/`m')*e(b)
 qui predict double `xb`i'' if `touse', xb
 qui gen `test`i''=cond(abs(`xb`i''-log(`eps'))<1e-5,1,0)
 qui gen `sumtest`i''=sum(`test`i'')
 if `sumtest`i''[`N']>0 { continue }

 tempvar res`i' wa`i' ind_1`i'
 tempname A`i'
 qui predict double `res`i'' if `touse', r
 qui gen `ind_1`i''=0 if `touse'
 qui replace `ind_1`i''=1 if `res`i''<=0 & `touse'
 qui gen double `wa`i''=(`quantile'-`ind_1`i'')^2
 qui mat accum `A`i''= `exogv' [pw=`wa`i'']

 tempvar eres`i' M`i' M1`i'
 qui gen double `eres`i'' = `z`i''-`quantile'-exp(`xb`i'') if `touse'
 qui gen double `M`i''= `quantile'+exp(`xb`i'') if `touse'
 qui gen double `M1`i''=`M`i''+1 if `touse'

 tempvar Fn`i' Fn1`i'
 qui gen double `Fn`i''=int(`M`i'')-0.5+(1/(2*`cn'))*(`M`i''-int(`M`i'')) if `touse'
 qui gen double `Fn1`i''=int(`M1`i'')-0.5+(1/(2*`cn'))*(`M1`i''-int(`M1`i'')) if `touse'
 qui replace `Fn`i''=int(`M`i'') if (`M`i''-int(`M`i''))>=`cn' & (`M`i''-int(`M`i''))<(1-`cn') & `touse'
 qui replace `Fn1`i''=int(`M1`i'') if (`M1`i''-int(`M1`i''))>=`cn' & (`M1`i''-int(`M1`i''))<(1-`cn') & `touse'
 qui replace `Fn`i''=int(`M`i'') if `M`i''<1 & `touse'
 qui replace `Fn1`i''=int(`M1`i'') if `M1`i''<1 & `touse'
 qui replace `Fn`i''=int(`M`i'')+0.5+(1/(2*`cn'))*(`M`i''-int(`M`i'')-1) if (`M`i''-int(`M`i''))>=(1-`cn') & `touse'
 qui replace `Fn1`i''=int(`M1`i'')+0.5+(1/(2*`cn'))*(`M1`i''-int(`M1`i'')-1) if (`M1`i''-int(`M1`i''))>=(1-`cn') & `touse'

 tempvar ind_2`i'
 qui gen double `ind_2`i''=0 if `touse'
 qui replace `ind_2`i''=1 if `z`i''>=`Fn`i'' & `z`i''<`Fn1`i'' & `touse'

 tempvar wd`i'
 qui gen double `wd`i''=exp(`xb`i'')*`ind_2`i'' if `touse'

 tempvar jfm`i' cond1`i' cond2`i' cond3`i' fxcn`i' cond4`i' wd2`i'
 qui gen double `jfm`i''=1 if `touse'
 qui replace `jfm`i''=1+int(`M`i''-0.5) if `M`i''>1 & `touse'
 qui gen `cond1`i''=(`M`i''<`jfm`i''-`cn') & `touse'
 qui gen `cond2`i''=(`M`i''>=`jfm`i''+`cn') & `touse'
 qui gen `cond3`i''=0
 qui replace `cond3`i''=1 if (`M`i''<`jfm`i''+`cn') & (`M`i''>=`jfm`i''-`cn') & `touse'
 #delimit ;
  qui gen double `fxcn`i''=`cond1`i''*(`jfm`i''-1)
  + `cond2`i''*`jfm`i''
  + `cond3`i''*(`jfm`i''-0.5 + (`M`i''-`jfm`i'')/(2*`cn')) if `touse' ;
 #delimit cr
 qui gen `cond4`i''=0 if `touse'
 qui replace `cond4`i''=1 if (`z`i''>=`fxcn`i'') & (`z`i''<`fxcn`i''+1) & `touse'
 qui gen double `wd2`i''=exp(`xb`i'')*`cond4`i'' if `touse'

 if `wd2`i''!=`wd`i'' {
  di in red "difference in weight for matrix D on iter `i'"
 }

 tempvar wb`i' ind_3`i' ind_4`i'
 qui gen `ind_3`i''=0 if `touse'
 qui replace `ind_3`i''=1 if (`endgv'<=`M`i''-1) & `touse'
 qui gen `ind_4`i''=0 if `touse'
 qui replace `ind_4`i''=1 if (`endgv'>`M`i''-1) & (`endgv'<`M`i'') & `touse'
 #delimit ;
  qui gen double `wb`i''=`quantile'^2
  +(1-2*`quantile')*`ind_3`i''
  +(`M`i''-`endgv')*(`M`i''-`endgv'-2*`quantile')*`ind_4`i'' if `touse' ;
 #delimit cr

 tempname D`i' B`i' mV`i' mK`i'
 qui mat accum `D`i'' = `exogv' [pw=`wd`i'']
 qui mat accum `B`i'' = `exogv' [pw=`wb`i'']
 mat `mV`i'' = (1/`m')*syminv(`D`i'')*`A`i''*syminv(`D`i'')
 mat `mK`i'' = (1/`m')*syminv(`D`i'')*`B`i''*syminv(`D`i'')

 mat `mb' = `mb' + `b`i''
 mat `mV' = `mV' + `mV`i''
 mat `mK' = `mK' + `mK`i''


 /* drop temps */

 #delimit ;
  drop `u`i'' `z`i'' `y`i'' `xb`i'' `test`i'' `sumtest`i''
  `res`i'' `wa`i'' `ind_1`i'' `eres`i'' `Fn`i'' `Fn1`i''
 `ind_2`i'' `wd`i'' `jfm`i'' `cond1`i'' `cond2`i''
 `cond3`i'' `fxcn`i'' `cond4`i'' `wd2`i'' `wb`i'' `ind_3`i''
 `ind_4`i'' `M`i'' `M1`i'' ;

  mat drop `b`i'' `mV`i'' `mK`i'' `A`i'' `D`i'' `B`i'' ;
 #delimit cr
 di in gre _continue "."
}

tempname b V
mat `V'=(1/`m')*`mV'+(1-(1/`m'))*`mK'
mat `b'=`mb'

est post `b' `V', dep("`endgv'") esample(`touse') obs(`N')

est local cmd "qcount"
est local depv "`endgv'"
est local exogv "`exogv'"
est local predict "qcount_p"
est scalar N=`N'
est scalar k=`nev'
est scalar qv=`quantile'
est scalar rep=`m'

Display

end

program define Display

        di _skip(12)
    #delimit ;
    di _n as txt
    "Count Data Quantile Regression"  ;
    di as text "( Quantile " as res %3.2f e(qv) as text " )"  ;
    di _col(45) in gre "Number of obs           =" as res %9.0f e(N) ;
    di _col(45) in gre "No. jittered samples    =" as res %9.0f e(rep);
    #delimit cr
    est di

end
exit