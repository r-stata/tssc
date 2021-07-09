*! OPROBPR.ADO version 3.1.1 by Nick Winter 7/6/2001
*! Program to plot predicted values for oprobit/ologit
*! Updated for Stata 7
*  Built upon LOGPRED.ADO by Joanne M. Garrett 
*      published 02/20/95 in sg42: STB-26; and subsequent updates.
*  Also draws upon PROBPRED.ADO by Mead Over, October 30, 1996 Version 1.0.1  
*      STB 42 sg42.2 
* 2/25/99 Fixed graph title so it won't crash with long variable label
*         fixed calculation of variable means--now drops all missings
*              before calculating means of any variable
* v1.2.1  re-fixed calculation of means so it doesn't conflict with user-set's
* v2.0    allows complex plot categories and uses y value labels to label
*              plot lines if available
* v2.1    updated to Stata version 6.0
*         added support for weights and for svy based estimation commands
* v2.1.1  fixed bug in parsing command() option
* v3.0    updated for Stata version 7
* v3.1.1  added support for mlogit and svymlogit

program define oprobpr7
   version 7

   syntax varlist(min=2 max=2 numeric) [pw iw fw] [if] [in], [Adjust(string)      /*
      */    From(string) To(string) INC(string) POly(integer 0)        /*
      */    Xact(varlist) SAVE(string) SAving(string) T1title(string) L1title(string) /*
      */    NOModel NOList NOPlot CMD(string) Connect(string) LABels(string) /*
      */    Symbol(string) PLot(string) PEn(string)  /*
      */    MODeloptions(string) Keys TExt(string) TSize(real 0.8) *]

   if `"`saving'"'!="" {
      local saving `"saving(`saving')"'
   }
   
   if "`weight'"!="" {
      local wgt "[`weight'`exp']"
      local wgtvar=substr("`exp'",2,.)
   }

   if "`cmd'"!="" {
      if substr(trim("`cmd'"),1,4)=="olog" { 
         local cmd "ologit"
      }
      else if substr(trim("`cmd'"),1,8)=="svyoprob" {
         local cmd "svyoprobit"
      }
      else if substr(trim("`cmd'"),1,7)=="svyolog" {
         local cmd "svyologit"
      }
      else if substr(trim("`cmd'"),1,5)=="oprob" {
         local cmd "oprobit"
      }
	else if substr(trim("`cmd'"),1,4)=="mlog" {
		local cmd "mlogit"
	}
	else if "`cmd'"=="svymlogit" {
		local cmd "svymlogit"
	}
      else {
         di in red "Illegal cmd()"
         error 198
      }
   }
   else {
      local cmd "oprobit"
   }
   
*   if "`adjust'"!="" {
*      unab adjust : `adjust'
*   }
*   if "`xact'"!="" {
*      unab xact : `xact'
*   }
     
   local yvar : word 1 of `varlist'
   local xvar : word 2 of `varlist'
   local varlbly : variable label `yvar'
   local vallab  : value label `yvar'
   local varlblx : variable label `xvar'

   if "`from'"=="" {
      sum `xvar', meanonly
      local from = r(min)
      if "`to'"=="" {
         local to = r(max)
      }
   }
   else if "`to'"=="" {
      sum `xvar', meanonly
      local to = r(max)
   }
   confirm number `from'
   confirm number `to'
   if `from'>=`to' {
      di in red "from() must be less than to()."
      error 198
   }
   if "`inc'"=="" { 
      local newobs 11
   }
   else {
      confirm number `inc'
      local newobs=int(((`to')-(`from'))/(`inc'))+1
   }

   if "`nomodel'"=="nomodel"  { local shhh "quietly"  }
   
   if "`connect'"!="" {
       local cst `connect'
   }

	if "`keys'"=="keys" & (`"`t1title'"'!="") {
		di as error "Can't combine keys with t1title() "
		error 198
	}

	if index(`"`options'"',"key") {				/* kill of ttitles if any keys are specified */
		local keys keys
	}

   preserve
   marksample touse   				/* this should deal with if, xvar, yvar */

*If there are covariates, parse the list, drop missing
   tokenize `adjust'
   local i 1
   while "`1'"!="" {
      local equal=index("`1'","=")
      if `equal'==0  {                          /* simple covariate */
         *local cov`i' "`1'"
         unab cov`i' : `1'
         local mcov`i' "mean"
      }
      else {                                    /* covariate w/user mean */
         *local cov`i'=substr("`1'",1,`equal'-1)
         local xxx=substr("`1'",1,`equal'-1)
         unab cov`i' : `xxx'
         local mcov`i'=substr("`1'",`equal'+1,.)
         cap confirm number `mcov`i''
         if _rc {
            di in r "a(`1') invalid"
            di in r "must set covariates to a number"
            error 198
         }
      }
      local covlist `covlist' `cov`i''
      local covdisp `covdisp' `1'
      local i=`i'+1
      macro shift
   }
   local numcov=`i'-1

*Generate Interaction Variables
   local numxact : word count `xact'
   
   forval i=1(1)`numxact' {
      local xact`i' : word `i' of `xact'
      cap confirm variable `xact`i''
      if _rc {
         di in r "xact() variables must also be adjust() variables"
         error 198
      }
      qui gen _I_`i'=`xvar'*`xact`i''
      lab var _I_`i' "`xvar' * `xact`i''"
      local xacts  "`xacts' _I_`i'"
   }

*If polynomial terms are requested, create them
   if `poly'==2  {
      gen _x_sq=`xvar'^2
      local polylst "_x_sq"
   }
   if `poly'==3  {
      gen _x_sq=`xvar'^2
      gen _x_cube=`xvar'^3
      local polylst "_x_sq _x_cube"
   }

*Run oprobit/ologit regression model.
   `shhh' `cmd' `yvar' `xvar' `covlist' `polylst' `xacts' `wgt' if `touse', `modeloptions'
   local i 1
   forval i=1(1)`numxact' {
      local j : variable label _I_`i'
      `shhh' di in g "     _I_`i' : `j'"
   }
   local newn `e(N)'

   tempname yvals
   qui ta `yvar' if e(sample), matrow(`yvals')
   local ncat `r(r)'

*Get value label if exists and if user didn't override
   if "`labels'"=="" & "`vallab'"!="" {
      forval i=1(1)`ncat' {
         local cur = `yvals'[`i',1]
         local ylab`i' : label `vallab' `cur'
      }
   }

*Calculate means for covariates that aren't user-set
   forval i=1(1)`numcov' {
      if "`mcov`i''"=="mean" {
         sum `cov`i'' if e(sample), meanonly
         local mcov`i' `r(mean)'
      }
   }

*Generate the values of x to calculate the predicted values
   drop _all
   qui set obs `newobs'
   gen `xvar'=(_n-1)/(`newobs'-1)*((`to')-(`from'))+(`from')
   label var `xvar' "`varlblx'"
   forval i=1(1)`numcov'  {
      gen `cov`i''=`mcov`i''
   }
   if `poly'>=2  {
      gen x_sq=`xvar'^2
   }
   if `poly'==3  {
      gen x_cube=`xvar'^3
   }
   forval i=1(1)`numxact' {
      gen _I_`i'= `xvar' * `xact`i''
      la var _I_`i' "`xvar' * `xact`i''"
   }

*Generate predict string
   forval i=1(1)`ncat' {
      local prst `prst' _Cat_`i'
   }

*Do predictions
   qui predict `prst' 

*Parse plot() -- use specification of what to plot ========needs error trapping!
*     This assigns: `nplot'   : number of categories to plot
*                   `ncompx'  : number of complex categories
*                   `pvar`i'' : name of variable containing category i
*                   `pnm`i''  : category number (ito y var) in plot cat i

   if "`plot'"=="" {                    /* no user specified */
      local nplot `ncat'
      local ncompx 0
      forval i=1(1)`ncat' {
         local pvar`i' "_Cat_`i'"
         local pnm`i' "`i'"
         la var `pvar`i'' "Category `i'"
      }
   }
   else {                                 /* user-specified plot() */
      local nplot 0                       /* number of cats to plot */
      local ncompx 0                      /* number of complex ones */
      tokenize "`plot'", parse(",")
      while "`1'"!="" {
         if "`1'"!="," {                  /* have a non-comma */
            local nplot=`nplot'+1
            local plus=index("`1'","+")
            if `plus'==0 {                /* its a simple category -- add check */
               local pvar`nplot' "_Cat_`1'"
               local pnm`nplot' "`1'"
               la var _Cat_`1' "Category `1'"
            }
            else {                        /* complex category, eg: p(1+2+3) */
               local ncompx=`ncompx'+1
               local formula "0"
               local compnm
               while `plus'!=0 {
                  local cur=substr("`1'",1,`plus'-1)   /* get first cat number */
                  local formula "`formula' + _Cat_`cur'"
                  local compnm "`compnm'&`cur'"
                  local 1=substr("`1'",`plus'+1,.)
                  local plus=index("`1'","+")
               }
               local formula "`formula' + _Cat_`1'"      /* add on final one */
               local compnm=substr("`compnm'&`1'",2,.)  /* add last and cut leading */
               local pvar`nplot' "_Comp_`ncompx'"
               local pnm`nplot' "`compnm'"
               quietly gen _Comp_`ncompx'=`formula'
               local nm=substr("`formula'",5,.)
               la var _Comp_`ncompx' "`nm'"
            }
         }
         macro shift
      }
   }

*generate plot string, connect string & empty symbol variables
   local i 1
   while `i'<=`nplot' {
      local plst "`plst' `pvar`i''"
      if "`connect'"=="" {
	      local cst "`cst's"
	  }
      local sst "`sst'[_S`i']"
      quietly gen str1 _S`i'=" "
      local i=`i'+1
   }

   if "`labels'"!="" {                        /* user symbols */
      local i 1
      parse "`labels'", parse(",")
      while "`1'"!="" {
         if "`1'"!="," {
            if "`1'"=="." { local 1 " " }
            quietly replace _S`i'="`1'" if inlist(_n,1,_N)
            la var `pvar`i'' "`1'"
            local i=`i'+1
         }
         macro shift
      }
   }
   else {                                     /* no user symbols */
      if `ncompx'==0 {                            /* all simple  */
         if "`vallab'"!="" {                        /* is y lab */
            local i 1
            while `i'<=`nplot' {
               qui replace _S`i'="`ylab`pnm`i'''" if inlist(_n,1,_N)
               la var `pvar`i'' "`ylab`pnm`i'''"
               local i=`i'+1
            }
         }
         else {                                      /* no y lab */
            local i 1
            while `i'<=`nplot' {
               quietly replace _S`i'="Cat `pnm`i''" if inlist(_n,1,_N)
               la var `pvar`i'' "Category `pnm`i''"
               local i=`i'+1
            }
         }
      }
      else {                                      /* not all simple */
            local i 1
            while `i'<=`nplot' {
               if substr("`pvar`i''",1,3)=="Cat" {        /* simple  */
                  quietly replace _S`i'="Cat `pnm`i''" if inlist(_n,1,_N)
                  la var `pvar`i'' "Category `pnm`i''"
               }
               else {
                  quietly replace _S`i'="C`pnm`i''" if inlist(_n,1,_N)
                  la var `pvar`i'' "Sum of Categories `pnm`i''"
               }
               local i=`i'+1
            }
      }
   }

   if `nplot'>10 {
      di in r "Can't plot more than 10 categories. " 
      di in r "Specify fewer or combine some using plot()."
      error 198
   }

	local listst "`plst'"
	local plst "`plst' `plst'"
	local cst  "`cst' . . . . . . . . . ."
	if "`symbol'"=="" {
		local symbol=substr("iiiiiiiiii",1,`nplot')
	}
	local symbol `"symbol(`symbol'`sst')"'
	
	if "`pen'"!="" {
		local lenpen=length("`pen'")
		if `lenpen'<`nplot' {
			local addlpen=substr("2345678923",`lenpen'+1,`nplot'-`lenpen')
			local pen "`pen'`addlpen'"
		}
		local pen "`pen'`pen'"
	}
	else {
		local pen=substr("2345678923",1,`nplot')
		local pen "`pen'`pen'"
	}
	
*Plot and list results
   if "`noplot'"~="noplot"  {
      if "`t1title'"=="" & "`keys'"=="" {
         local t1title `"t1title(Predicted Probabilities: `varlbly' ($S_E_depv))"'
      }
      else if "`t1title'"!="" {
      		local t1title `"t1title(`t1title')"'
      }
      if "`l1title'"=="" {
         local l1title "Probabilities"
      }
      
      if "`text'"=="" {
         graph `plst' `xvar' , sort c(`cst') `symbol' `t1title' l1(`"`l1title'"') pen(`pen') `saving' `options'
      }
      else {
      		local tr=570*`tsize'
			local tc=290*`tsize'

			local ntext 0
			while `"`text'"'!="" {
				gettoken curtext text : text , parse("\")
				if `"`curtext'"' != "\" {
					local ntext=`ntext'+1
					gettoken tx`ntext' curtext : curtext		
					gettoken ty`ntext' thetext`ntext' : curtext
				}
			}

	        graph `plst' `xvar' , sort c(`cst') `symbol' `t1title' l1(`"`l1title'"') pen(`pen') `options'
	
			local ay=`r(ay)'
			local by=`r(by)'
			local ax=`r(ax)'
			local bx=`r(bx)'

			gph open , `saving'
			graph
			gph font `tr' `tc'
			forv i=1(1)`ntext' {
				local r = (`ay')*(`ty`i'') + (`by')
				local c = (`ax')*(`tx`i'') + (`bx')
				gph text `r' `c' 0 -1 `thetext`i''
			}
			gph close
      }
   }

   if "`nolist'"==""  {
      di "  "
      di as text "Probabilities"
      di
      di as text "  Outcome Variable:     " as res "`yvar' " cond("`varlbly'"=="","","-- ") "`varlbly'"
      di as text "  Independent Variable: " as res "`xvar' " cond("`varlblx'"=="","","-- ") "`varlblx'"
      if `poly'==2 | `poly'==3  {
         di "{txt}  Polynomial Terms:     {res}`polylst'"
      }
      if "`xact'"~="" {
         di "{txt}  Interaction Terms:    {res}`xact'"
      }
      if `numcov'>0 {
	   di "{p 2 28 2}{txt}Covariates:{bind:           }{res}`covdisp'{p_end}"
      }
      di "{txt}  Total Observations:   {res}`newn'"
      list `xvar' `listst' 
      di "{txt}{hline 78}
      local i 1
      while `i'<=`nplot' {
         local nm : var lab `pvar`i''
         local nsp = 8-length("`pvar`i''")
         di "{txt} `pvar`i''"  _d(`nsp') " "  " : `nm'"
         local i=`i'+1
      }
   }

   if "`save'" ~= "" {
      save `save'
   }


end
*/
*end&
