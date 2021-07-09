*! version 3            <10apr2007>         JPAzevedo
*   multiple variables
*   option nospace
*   option multiple poverty lines
* version 2.2.1         <24jul2005>         JPAzevedo
* include pweight
* version 2.2.0         <23apr2005>         JPAzevedo
* include varpl
* version 2.1.0         <01apr2005>         JPAzevedo
* version 2.0.0         <01aug1999>         Philippe Van Kerm

program define apoverty, rclass

version 7.0

  syntax varlist(min=1 max=5)               ///
        [if] [in]                           ///
        [aweight fweight pweight] [,        ///
        Line(real -1)                       ///
        gen(string)                         ///
        varpl(varname)                      ///
        All                                 ///
        H H2 APG PGR IGR                    ///
        W S TAk THon FGT1 FGT2 FGT3 FGT4    ///
        FGT5 FGT6 FGT7                      ///
        FGT8 FGT9 CHU1 CHU2 CHU3 CHU4 CHU5  ///
        NOSPACE                             ///
        ]

preserve

if "`all'"~="" {
   loc h    = "t"
   loc h2   = "t"
   loc apg  = "t"
   loc pgr  = "t"
   loc igr  = "t"
   loc w    = "t"
   loc s    = "t"
   loc tak  = "t"
   loc thon = "t"
   loc fgt1 ="t"
   loc fgt2 ="t"
   loc fgt3 ="t"
   loc fgt4 ="t"
   loc fgt5 ="t"
   loc fgt6 ="t"
   loc fgt7 ="t"
   loc fgt8 ="t"
   loc fgt9 ="t"
   loc chu1 ="t"
   loc chu2 ="t"
   loc chu3 ="t"
   loc chu4 ="t"
   loc chu5 ="t"
}

parse "`varlist'", parse (" ")
loc weight "[`weight'`exp']"
loc var `1'
local wvar : word 2 of `exp'

tempvar wwvar rweid swwvar touse theta totheta tempora flagp theta2 totheta2 flagp2 varpl2 index order value
tempname temp

loc k 0
tokenize `varlist'

quietly {
   mark `touse' `if' `in' `weight'
   keep if `touse'==1
   loc ntot=_N
   markout `touse' `var'
   keep if `touse'==1
   loc nobs=_N
}

qui gen byte `index' = .
qui gen int  `order' = _n in 1/30

label variable `index' "Poverty measures of `varlist'"
label variable `order' "Poverty measures of `varlist'"

if "`format'"==""{loc format "%12.3fc"}

sort `var'

loc Z = `line'

qui gen `theta'=0
qui gen `totheta'=0
qui gen `theta2'=0
qui gen `totheta2'=0

qui gen `flagp'=.
qui gen `flagp2'= .
qui gen `varpl2' = .
qui gen `wwvar'=.
qui gen `swwvar' =.
qui gen `rweid'=.

while "`1'"~=""{

    loc k = `k'+1
    loc j 1
    tempvar value`k'
    qui gen `value`k'' = .
    loc varval "`varval' `value`k''"
    label variable `value`k'' "`1'"
    local var `1'

    qui replace `wwvar'=1

    if "`wvar'"~="" {
        qui replace `wwvar'=`wvar'

    }
    qui replace `swwvar' = sum(`wwvar')
    qui replace `rweid'=((2*`swwvar')-`wwvar'+1)/2
    loc wnobs=`swwvar'[_N]

    if ("`varpl'"=="") & (`line'==-1) {
        qui _pctile `var' `if' `in' `weight', p(50)
        loc Z = _result(1)/2
        qui replace `flagp'=(`var'<`Z') `if' `in'
        loc Z2 = `Z'/2
        qui replace `flagp2'=(`var'<`Z2') `if' `in'
    }

    if ("`varpl'"=="") & (`line'==-2) {
        qui _pctile `varlist' `if' `in' `weight', p(50)
        loc Z = (_result(1)/3)*2
        qui replace `flagp'=(`var'<`Z') `if' `in'
        loc Z2 = `Z'/2
        qui replace `flagp2'=(`var'<`Z2') `if' `in'
    }

    if ("`varpl'"=="") & (`line'>0) {
        loc Z = `line'
        qui replace `flagp'=(`var'<`Z') `if' `in'
        loc Z2 = `Z'/2
        qui replace `flagp2'=(`var'<`Z2') `if' `in'
    }


    if ("`varpl'"!="") {
        qui replace `flagp'=(`var'<`varpl') `if' `in'
        qui replace `varpl2' = `varpl'/2
        qui replace `flagp2'=(`var'<`varpl2') `if' `in'
        loc Z `varpl'
    }


       /* indices */

       qui replace `theta' = `wwvar' if `flagp'==1
       qui replace `totheta' = sum(`theta')
       loc wnbp = `totheta'[_N]
       loc head = (`wnbp'/`wnobs')*100

       qui replace `value`k'' = `head'  	in 1
       qui replace `index' = 1  		in 1

       qui replace `theta2' = `wwvar' if `flagp2'==1
       qui replace `totheta2' = sum(`theta2')
       loc wnbp2 = `totheta2'[_N]
       loc head2 = (`wnbp2'/`wnobs')*100

       qui replace `value`k'' = `head2'  	in 2
       qui replace `index' = 2  		in 2

       return local head_`k'      =`head'
       return local head2_`k'     =`head2'
       		
       local j = 3
       if "`apg'"~="" {
          qui replace `theta' = (`wwvar')*((`Z'-`var')) if `flagp'==1
          qui replace `totheta' = sum(`theta')
          loc pogap1 = `totheta'[_N]
          loc pogap2 = `totheta'[_N]/`wnobs'
          qui replace `index' = 3  		in `j'
          qui replace `value`k'' = `pogap1'  	in `j'
          local j = `j'+1
          qui replace `index' = 4  		in `j'
          qui replace `value`k'' = `pogap2'  	in `j'
          return local pogap1_`k'    =`pogap1'
          return local pogap1_`k'    =`pogap2'
          local j = `j'+1
          }
       if "`pgr'"~="" {
          qui replace `theta' = (`wwvar')*((`Z'-`var')/`Z') if `flagp'==1
          qui replace `totheta' = sum(`theta')
          loc pogapr = (`totheta'[_N]/`wnobs')*100
          qui replace `index' = 5  		in `j'
          qui replace `value`k'' = `pogapr'  	in `j'
          return local pogapr_`k'    =`pogapr'
          local j = `j'+1
          }
       if "`igr'"~="" {
          qui replace `theta' = (`wwvar')*((`Z'-`var')/`Z') if `flagp'==1
          qui replace `totheta' = sum(`theta')
          loc ingapr = (`totheta'[_N]/`wnbp')*100
          qui replace `index' = 6  		in `j'
          qui replace `value`k'' = `ingapr'  	in `j'
          return local ingapr_`k'    =`ingapr'
          local j = `j'+1
          }
       if "`w'"~="" {
          qui replace `theta' = (`wwvar')*(ln(`Z')-ln(`var')) if `flagp'==1
          qui replace `totheta' = sum(`theta')
          loc watts = (`totheta'[_N]/`wnobs')*100
          qui replace `index' = 7  	in `j'
          qui replace `value`k'' = `watts'  in `j'
          return local watts_`k'     =`watts'
          local j = `j'+1
          }

       if "`fgt1'"~="" {
          qui replace `theta' = (`wwvar')*((`Z'-`var')/`Z')^0.5 if `flagp'==1
          qui replace `totheta' = sum(`theta')
          loc fogto1 = (`totheta'[_N]/`wnobs')*100
          qui replace `index' = 8  	in `j'
          qui replace `value`k'' = `fogto1'  in `j'
          return local fogto1_`k'    =`fogto1'
          local j = `j'+1
          }
          loc n1 2
          loc q = 9
          while `n1' <= 9 {
          if "`fgt`n1''"~="" {
             qui replace `theta' = (`wwvar')*(((`Z'-`var')/`Z')^((`n1'+1)/2)) /*
                      */ if `flagp'==1
             qui replace `totheta' = sum(`theta')
             loc fogto`n1' = (`totheta'[_N]/`wnobs')*100
             qui replace `index' = `q'  	in `j'
             qui replace `value`k'' = `fogto`n1''  in `j'
             return local fogto`n1'_`k'    =`fogto`n1''
             loc q = `q'+1
             local j = `j'+1
          }
          loc n1 = `n1' + 1
          }

       loc n1 2
       loc q = 18
       while `n1' <= 4 {
        if "`chu`n1''"~="" {
         qui replace `theta' = (`wwvar')*(1-(`var'/`Z')^((`n1'-1)*0.25))/((`n1'-1)*0.25) /*
                 */  if `flagp'==1
         qui replace `totheta' = sum(`theta')
         loc clk`n1' = (`totheta'[_N]/`wnobs')*100
          qui replace `index' = `q'  	in `j'
          qui replace `value`k'' = `clk`n1''  in `j'
          return local clk`n1'_`k'      =`clk`n1''
          loc q = `q'+1
          local j = `j'+1
         }
        loc n1 = `n1' + 1
        }
       if "`chu1'"~="" {
          qui replace `theta' = (`wwvar')*(1-(`var'/`Z')^0.1)/0.1 if `flagp'==1
          qui replace `totheta' = sum(`theta')
          loc clk1 = (`totheta'[_N]/`wnobs')*100
          qui replace `index' = 17  	in `j'
          qui replace `value`k'' = `clk1'  in `j'
          return local clk1_`k'      =`clk1'
          local j = `j'+1
          }
       if "`chu5'"~="" {
          qui replace `theta' = (`wwvar')*(1-(`var'/`Z')^0.9)/0.9 if `flagp'==1
          qui replace `totheta' = sum(`theta')
          loc clk5 = (`totheta'[_N]/`wnobs')*100
          qui replace `index' = 21  	in `j'
          qui replace `value`k'' = `clk5'  in `j'
          return local clk5_`k'      =`clk5'
          local j = `j'+1
          }

       if "`thon'"~="" {
          qui replace `theta' = (`wnobs'+1-`rweid')*(`wwvar'*(`Z'-`var')) /*
                            */ if `flagp'==1
          qui replace `totheta' = sum(`theta')
          loc thonse = 100*(2*`totheta'[_N])/(((`wnobs'+1)*`Z')*`wnobs')
          qui replace `index' = 23  	in `j'
          qui replace `value`k'' = `thonse'  in `j'
          return local thonse_`k'    =`thonse'
          local j = `j'+1
          }

       if "`s'"~="" {
          qui replace `theta' = (`wnbp'+1-`rweid')*(`wwvar'*(`Z'-`var')) /*
                      */ if `flagp'==1
          qui replace `totheta' = sum(`theta')
          loc sen = ((2*`totheta'[_N])/(((`wnbp'+1)*`Z')*`wnobs'))*100
          qui replace `index' = 24  	in `j'
          qui replace `value`k'' = `sen'  in `j'
          return local sen_`k'       =`sen'
          local j = `j'+1
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
          qui replace `index' = 25  	in `j'
          qui replace `value`k'' = .  in `j'
          local j = `j'+1
          qui replace `index' = 26  	in `j'
          qui replace `value`k'' = `takase'  in `j'
          return local takase_`k'    =`takase'
          local j = `j'+1
          }

    qui replace `theta'=0
    qui replace `totheta'=0
    qui replace `theta2'=0
    qui replace `totheta2'=0

    mac shift

    }

    label define `index' 					        /*
		*/ 1 "Headcount ratio %"                 	/*
		*/ 2 "Extreme Poverty Headcount ratio %"    /*
 		*/ 3 "Aggregate poverty gap" 			     /*
	    */ 4 "Per capita poverty gap"			   /*
		*/ 5 "Poverty gap ratio %"  			   /*
		*/ 6 "Income gap ratio %"  			        /*
		*/ 7 "Watts index" 				           /*
    	*/ 8 "Index FGT(0.5) *100" 			    /*	
		*/ 9 "Index FGT(1.5) *100"       		   /*
    	*/ 10 "Index FGT(2.0) *100"  			/*
    	*/ 11 "Index FGT(2.5) *100"     		/*
    	*/ 12 "Index FGT(3.0) *100" 			/*
    	*/ 13 "Index FGT(3.5) *100" 			/*
    	*/ 14 "Index FGT(4.0) *100" 			/*
    	*/ 15 "Index FGT(4.5) *100" 			/*
    	*/ 16 "Index FGT(5.0) *100" 			/*
    	*/ 17 "Clark et al. index (0.10) *100" 	/*
    	*/ 18 "Clark et al. index (0.25) *100" 	/*    		
		*/ 19 "Clark et al. index (0.50) *100" 	/*
		*/ 20 "Clark et al. index (0.75) *100" 	/*
		*/ 21 "Clark et al. index (0.90) *100" 	/*
		*/ 22 "Clark et al. index (1.5) *100" 	/*
		*/ 23 "Thon index *100" 			/*
		*/ 24 "Sen index *100" 				/*
		*/ 25 "param1" 			/*
		*/ 26 "Takayama index *100"

if ("`nospace'" != "") {
    forvalues i = 1(1)26 {
        local label : label `index' `i'
        local newlabel = subinstr("`label'"," ","_",.)
        label define `index' `i' "`newlabel'", modify
    }
}

label values `index' `index'

if "`varpl'"=="" {
    di
    di
    di in gr " The poverty line is set at " in ye %9.0f "`Z'" in gr " units"
    if `line'==-1 { di in gr "                           (1/2 of median value)" }
    if `line'==-2 { di in gr "                           (2/3 of median value)" }
}
di
di
if "`varpl'"~="" {di in gr " The poverty line is set by variable" in y " `varpl'"}

  local word = word("`varval'",1)
  tabdisp `index' if `word'!=. ,c(`varval') format(`format')

di
if "`weight'"~="[]" {di in yellow "`weight'"}


return local ntot = `ntot'
return local nobs = `nobs'
return local wnobs = `wnobs'
return local z = `Z'
return local wnbp = `wnbp'

restore

if "`gen'" ~= "" {
        confirm new variable `gen'`k'
        qui generate `gen'`k' = (`var'<`Z') `if' `in'
        qui replace `gen'`k' = . if `var'==.
        label var `gen'`k' "Poverty flag (varname = `var' & poverty line = `Z')"
}

if ("`varpl'"!="") {
      local Z = .
}

mat `temp' = `ntot', `nobs', `wnobs', `Z', `wnbp'

if "`h'"~="" {mat `temp' = `temp', `head'}
if "`h2'"~="" {mat `temp' = `temp', `head2'}
if "`apg'"~="" {mat `temp' = `temp', `pogap1'}
if "`pgr'"~="" {mat `temp' = `temp', `pogapr'}
if "`igr'"~="" {mat `temp' = `temp', `ingapr'}
if "`w'"~="" {mat `temp' = `temp', `watts'}
if "`fgt1'"~="" {mat `temp' = `temp', `fogto1'}
if "`fgt2'"~="" {mat `temp' = `temp', `fogto2'}
if "`fgt3'"~="" {mat `temp' = `temp', `fogto3'}
if "`fgt4'"~="" {mat `temp' = `temp', `fogto4'}
if "`fgt5'"~="" {mat `temp' = `temp', `fogto5'}
if "`fgt6'"~="" {mat `temp' = `temp', `fogto6'}
if "`fgt7'"~="" {mat `temp' = `temp', `fogto7'}
if "`fgt8'"~="" {mat `temp' = `temp', `fogto8'}
if "`fgt9'"~="" {mat `temp' = `temp', `fogto9'}
if "`chu1'"~="" {mat `temp' = `temp', `clk1'}
if "`chu2'"~="" {mat `temp' = `temp', `clk2'}
if "`chu3'"~="" {mat `temp' = `temp', `clk3'}
if "`chu4'"~="" {mat `temp' = `temp', `clk4'}
if "`chu5'"~="" {mat `temp' = `temp', `clk5'}
if "`s'"~="" {mat `temp' = `temp', `sen'}
if "`thon'"~="" {mat `temp' = `temp', `thonse'}
if "`tak'"~="" {mat `temp' = `temp', `takase'}

local rowlabel "pov:ntot pov:nobs pov:wnobs pov:Z pov:wnbp "

local complement ""
if "`h'"~="" {local complement "`complement' pov:head"}
if "`h2'"~="" {local complement "`complement' pov:head2"}
if "`apg'"~="" {local complement "`complement' pov:pogap1"}
if "`pgr'"~="" {local complement "`complement' pov:pogapr"}
if "`igr'"~="" {local complement "`complement' pov:ingapr"}
if "`w'"~="" {local complement "`complement' pov:watts"}
if "`fgt1'"~="" {local complement "`complement' pov:fogto1"}
if "`fgt2'"~="" {local complement "`complement' pov:fogto2"}
if "`fgt3'"~="" {local complement "`complement' pov:fogto3"}
if "`fgt4'"~="" {local complement "`complement' pov:fogto4"}
if "`fgt5'"~="" {local complement "`complement' pov:fogto5"}
if "`fgt6'"~="" {local complement "`complement' pov:fogto6"}
if "`fgt7'"~="" {local complement "`complement' pov:fogto7"}
if "`fgt8'"~="" {local complement "`complement' pov:fogto8"}
if "`fgt9'"~="" {local complement "`complement' pov:fogto9"}
if "`chu1'"~="" {local complement "`complement' pov:clk1"}
if "`chu2'"~="" {local complement "`complement' pov:clk2"}
if "`chu3'"~="" {local complement "`complement' pov:clk3"}
if "`chu4'"~="" {local complement "`complement' pov:clk4"}
if "`chu5'"~="" {local complement "`complement' pov:clk5"}
if "`s'"~="" {local complement "`complement' pov:sen"}
if "`thon'"~="" {local complement "`complement' pov:thonse"}
if "`tak'"~="" {local complement "`complement' pov:takase"}

mat colnames `temp' = `rowlabel' `complement'
mat `temp' = `temp''


return matrix b=`temp'

end
