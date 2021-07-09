*! version 2.0.0  8/1/99 
*Philippe Van Kerm

capture program drop poverty
program define poverty


version 5.0
set more on
local varlist "req ex min(1) max(1)"
loc if "opt"
loc in "opt"
loc weight "fweight aweight"
loc options "Line(real -1) Gen(string) All H APG PGR IGR "
loc options "`options' W S TAk THon FGT1 FGT2 FGT3 FGT4 FGT5 FGT6 FGT7 "
loc options "`options' FGT8 FGT9 CHU1 CHU2 CHU3 CHU4 CHU5"
parse "`*'"

if "`all'"~="" {
   loc h = "t"
   loc apg = "t"
   loc pgr = "t"
   loc igr = "t"
   loc w = "t"
   loc s = "t"
   loc tak = "t"
   loc thon = "t"
   loc fgt1="t" 
   loc fgt2="t" 
   loc fgt3="t" 
   loc fgt4="t" 
   loc fgt5="t" 
   loc fgt6="t" 
   loc fgt7="t" 
   loc fgt8="t"
   loc fgt9="t" 
   loc chu1="t"
   loc chu2="t" 
   loc chu3="t" 
   loc chu4="t" 
   loc chu5="t" 
    }
parse "`varlist'", parse (" ")
loc weight "[`weight'`exp']"
loc var `1'
local wvar : word 2 of `exp'
tempvar wwvar rweid swwvar touse theta totheta tempora flagp
sort `var'
quietly {
   preserve
   mark `touse' `if' `in' `weight'
   keep if `touse'==1
   loc ntot=_N
   markout `touse' `var'
   keep if `touse'==1
   loc nobs=_N
   gen `wwvar'=1
   }
if "`wvar'"~="" {qui replace `wwvar'=`wvar'}
qui gen `swwvar' = sum(`wwvar')
qui gen `rweid'=((2*`swwvar')-`wwvar'+1)/2 
loc wnobs=`swwvar'[_N]

loc Z = `line'
if `line'==-1 {
	qui _pctile `var' `weight', p(50)
	loc Z = _result(1)/2
	}
if `line'==-2 {
	qui _pctile `var' `weight', p(50)
	loc Z = (_result(1)/3)*2
	}
qui gen `flagp'=(`var'<`Z')
			
   	/* indices */

   qui gen `theta'=0
   qui gen `totheta'=0
   qui replace `theta' = `wwvar' if `flagp'==1
   qui replace `totheta' = sum(`theta')
   loc wnbp = `totheta'[_N]
   loc head = (`wnbp'/`wnobs')*100

   if "`apg'"~="" { 
      qui replace `theta' = (`wwvar')*((`Z'-`var')) if `flagp'==1
      qui replace `totheta' = sum(`theta')
      loc pogap1 = `totheta'[_N]
      loc pogap2 = `totheta'[_N]/`wnobs'
      }
   if "`pgr'"~="" { 
      qui replace `theta' = (`wwvar')*((`Z'-`var')/`Z') if `flagp'==1
      qui replace `totheta' = sum(`theta')
      loc pogapr = (`totheta'[_N]/`wnobs')*100
      }
   if "`igr'"~="" { 
      qui replace `theta' = (`wwvar')*((`Z'-`var')/`Z') if `flagp'==1
      qui replace `totheta' = sum(`theta')
      loc ingapr = (`totheta'[_N]/`wnbp')*100
      }
   if "`w'"~="" { 
      qui replace `theta' = (`wwvar')*(ln(`Z')-ln(`var')) if `flagp'==1
      qui replace `totheta' = sum(`theta')
      loc watts = (`totheta'[_N]/`wnobs')*100
      }

   if "`fgt1'"~="" { 
      qui replace `theta' = (`wwvar')*((`Z'-`var')/`Z')^0.5 if `flagp'==1
      qui replace `totheta' = sum(`theta')
      loc fogto1 = (`totheta'[_N]/`wnobs')*100
      }
   loc n1 2
   while `n1' <= 9 {
      if "`fgt`n1''"~="" { 
         qui replace `theta' = (`wwvar')*(((`Z'-`var')/`Z')^((`n1'+1)/2)) /*
                  */ if `flagp'==1
         qui replace `totheta' = sum(`theta')
         loc fogto`n1' = (`totheta'[_N]/`wnobs')*100
         }
      loc n1 = `n1' + 1
      }

   loc n1 2
   while `n1' <= 4 {
    if "`chu`n1''"~="" { 
     qui replace `theta' = (`wwvar')*(1-(`var'/`Z')^((`n1'-1)*0.25))/((`n1'-1)*0.25) /*
             */  if `flagp'==1
     qui replace `totheta' = sum(`theta')
     loc clk`n1' = (`totheta'[_N]/`wnobs')*100
     }
    loc n1 = `n1' + 1
    }
   if "`chu1'"~="" { 
      qui replace `theta' = (`wwvar')*(1-(`var'/`Z')^0.1)/0.1 if `flagp'==1
      qui replace `totheta' = sum(`theta')
      loc clk1 = (`totheta'[_N]/`wnobs')*100
      }
   if "`chu5'"~="" { 
      qui replace `theta' = (`wwvar')*(1-(`var'/`Z')^0.9)/0.9 if `flagp'==1
      qui replace `totheta' = sum(`theta')
      loc clk5 = (`totheta'[_N]/`wnobs')*100
      }

   if "`thon'"~="" {
      qui replace `theta' = (`wnobs'+1-`rweid')*(`wwvar'*(`Z'-`var')) /*
                        */ if `flagp'==1
      qui replace `totheta' = sum(`theta')
      loc thonse = 100*(2*`totheta'[_N])/(((`wnobs'+1)*`Z')*`wnobs') 
      }

   if "`s'"~="" {
      qui replace `theta' = (`wnbp'+1-`rweid')*(`wwvar'*(`Z'-`var')) /*
                  */ if `flagp'==1
      qui replace `totheta' = sum(`theta')
      loc sen = ((2*`totheta'[_N])/(((`wnbp'+1)*`Z')*`wnobs'))*100 
      }
   if "`tak'"~="" {
      qui replace `theta'=0
      qui replace `totheta'=0
      qui replace `theta' = `wwvar'*`var'
      qui replace `theta' = `wwvar'*`Z' if `flagp'==0
      qui replace `totheta' = sum(`theta')	
      loc param1 = `totheta'[_N] / `wnobs'
      qui replace `theta' = ((`wnobs'+1-`rweid')*`wwvar')*`var' if `flagp'==1
      qui replace `theta' = ((`wnobs'+1-`rweid')*`wwvar')*`Z' if `flagp'==0
      qui replace `totheta' = sum(`theta')
      loc takase = 100*(1 + (1/`wnobs') - ((2*`totheta'[_N]) /((`param1')*((`wnobs')^2))) )
      }


restore		

if "`gen'" ~= "" {
	confirm new variable `gen'
	qui generate `gen' = (`var'<`Z') `if' `in'
	qui replace `gen' = . if `var'==.	
	}	

					/* Output */

di
di in green _d(78) "-"
di in green "Poverty measures of " in yellow "`varlist'"
di in green _d(78) "-"
di
di in gr " Your selection is made of " in ye "`ntot'" in gr " observations."
di in gr " The following poverty analysis has been using the " _c
di in ye "`nobs'" in gr " non-missing" 
di in gr " observations for `var' in your selection."
di
di in green _d(78) "~"
di
di in gr " The poverty line is set at " in ye %9.0f "`Z'" in gr " units"  
if `line'==-1 { di in gr "                           (1/2 of median value)" }
if `line'==-2 { di in gr "                           (2/3 of median value)" }
di
di in green _d(78) "~"
di
if "`h'"~="" {di in gr "Headcount ratio % " _col(40) in ye %9.3f `head'}
if "`apg'"~="" {di in gr "Aggregate poverty gap " _col(38) in ye `pogap1' " units
di in gr _col(22) "(or equivalently " in ye  %9.2f `pogap2' in gr " units per obs.)" }
if "`pgr'"~="" {di in gr "Poverty gap ratio % " _col(40) in ye %9.3f `pogapr'}
if "`igr'"~="" {di in gr "Income gap ratio %" _col(40) in ye %9.3f `ingapr'}
if "`w'"~="" {di in gr "Watts index " _col(40) in ye %9.3f `watts'}
if "`fgt1'"~="" {di in gr "Index FGT(0.5) *100" _col(40) in ye %9.3f  `fogto1'}
if "`fgt2'"~="" {di in gr "Index FGT(1.5) *100" _col(40) in ye %9.3f `fogto2'}
if "`fgt3'"~="" {di in gr "Index FGT(2.0) *100" _col(40) in ye %9.3f  `fogto3'}
if "`fgt4'"~="" {di in gr "Index FGT(2.5) *100" _col(40) in ye %9.3f  `fogto4'}
if "`fgt5'"~="" {di in gr "Index FGT(3.0) *100" _col(40) in ye %9.3f  `fogto5'}
if "`fgt6'"~="" {di in gr "Index FGT(3.5) *100" _col(40) in ye %9.3f  `fogto6'}
if "`fgt7'"~="" {di in gr "Index FGT(4.0) *100" _col(40) in ye %9.3f  `fogto7'}
if "`fgt8'"~="" {di in gr "Index FGT(4.5) *100" _col(40) in ye %9.3f `fogto8'}
if "`fgt9'"~="" {di in gr "Index FGT(5.0) *100" _col(40) in ye  %9.3f  `fogto9'}
if "`chu1'"~="" {
	di in gr "Clark et al. index (0.10) *100" _col(40) in ye  %9.3f  `clk1'
	}
if "`chu2'"~="" {
	di in gr "Clark et al. index (0.25) *100" _col(40) in ye  %9.3f  `clk2'
	}
if "`chu3'"~="" {
	di in gr "Clark et al. index (0.50) *100" _col(40) in ye %9.3f   `clk3'
	}
if "`chu4'"~="" {
	di in gr "Clark et al. index (0.75) *100" _col(40) in ye  %9.3f  `clk4'
	}
if "`chu5'"~="" {
	di in gr "Clark et al. index (0.90) *100" _col(40) in ye  %9.3f  `clk5'
	}
if "`cl5'"~="" {
	di in gr "Clark et al. index (1.5) *100" _col(40) in ye %9.3f   `clk5'
	}
if "`s'"~="" {di in gr "Sen index *100" _col(40) in ye  %9.3f  `sen'}
if "`thon'"~="" {di in gr "Thon index *100" _col(40) in ye %9.3f   `thonse'}
if "`tak'"~="" {di in gr "Takayama index *100" _col(40) in ye  %9.3f  `takase'}
di
if "`weight'"~="[]" {di in yellow "`weight'"}  
di in green _d(78) "-"

global S_1 = `ntot'
global S_2 = `nobs'
global S_3 = `wnobs'
global S_4 = `Z'
global S_5 = `wnbp'

if "`h'"~="" {global S_6 = `head'}
if "`apg'"~="" {global S_7 = `pogap1'}
if "`pgr'"~="" {global S_8 = `pogapr'}
if "`igr'"~="" {global S_9 =`ingapr'}
if "`w'"~="" {global S_10 =`watts'}
if "`fgt1'"~="" {global S_11 =`fogto1'}
if "`fgt2'"~="" {global S_12 =`fogto2'}
if "`fgt3'"~="" {global S_13 =`fogto3'}
if "`fgt4'"~="" {global S_14 =`fogto4'}
if "`fgt5'"~="" {global S_15 =`fogto5'}
if "`fgt6'"~="" {global S_16 =`fogto6'}
if "`fgt7'"~="" {global S_17 =`fogto7'}
if "`fgt8'"~="" {global S_18 =`fogto8'}
if "`fgt9'"~="" {global S_19 =`fogto9'}
if "`chu1'"~="" {global S_20 =`clk1'}
if "`chu2'"~="" {global S_21 =`clk2'}
if "`chu3'"~="" {global S_22 =`clk3'}
if "`chu4'"~="" {global S_23 =`clk4'}
if "`chu5'"~="" {global S_24 =`clk5'}
if "`s'"~="" {global S_25 =`sen'}
if "`thon'"~="" {global S_26 =`thonse'}
if "`tak'"~="" {global S_27 =`takase'}

end


