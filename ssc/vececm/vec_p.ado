*! vec_p: predictions for vecvar.ado and vececm.ado
*! version 1.0   19dec2002   PJoly
* v.1.1   19dec2002   PJoly   corrected set() to properly handle tsops
* v.1.0   02may2002   PJoly

program define vec_p
      version 7.0

      syntax [newvarname] [if] [in],    [  Suffix(str)             /*
                                    */     Prefix(str)             /*
                                    */     Dynamic(str)            /*
                                    */     Residuals               /*
                                    */     Y                       /*
                                    */     YResiduals              /*
                                    */     Type(str)               /*
                                    */     set(varlist ts)         /*
       std opt for ME estimators    */     EQuation(str) xb stdp ]

qui {
      marksample touse,  novarlist
      _ts tvar pvar if `touse', sort onepanel
      qui tsset
      markout `touse' `tvar' `pvar'

      local p : word count `e(depvar)'
      local y   = cond("`y'"!="" | "`yresiduals'"!="",1,0)
      local ecm = cond("`e(cmd)'"=="vececm",1,0)
      if "`type'" != "" {
            if !index(" int long float double "," `type' ") {
                  di as err "type() invalid"
                  exit 198
            }
            local typlist "`type'"
      }
      if "`dynamic'" == "" { local dyn = 0 }
      else {
            cap local dyn = `dynamic'
            if _rc {
                  di as err "dynamic(`dynamic') invalid"
                  exit 198
            }
      }

      if "`varlist'" == "" {
            if "`prefix'`suffix'" == "" {
                  di as err "newvarname or either suffix(), prefix() required"
                  exit 198
            }
            if "`equation'" != "" {
                  di as err "equation() not allowed without newvarname"
                  exit 198
            }
            foreach var in `e(depvar)' {
                  tsrevar `var', list
                  confirm new var `prefix'`r(varlist)'`suffix'
            }
      }
      else {
            if "`prefix'`suffix'" != "" {
                  di as err "suffix() or prefix() not allowed with newvarname"
                  exit 198
            }
      }
      local oneof : word count `yresiduals' `residuals' `xb' `stdp'
      if `oneof' > 1 {
            di as err "too many statistics chosen"
            exit 198
      }
      if ("`stdp'" != "" & (`dyn' | `y')) {
            di as err "stdp not allowed with dynamic or y, yet {c -} " _c
            di as err "stay tuned for updates"
            exit 198
      }
      if (!`dyn' & "`set'" != "") {
            di as err "set() only allowed with dynamic"
            exit 198
      }
      if `ecm' {
            forv i = 1/`e(cirel)' { confirm var Co_Rel`i' }

            tempname A BP b0 b1                   /* only relevant if `dyn' */
            mat     `A'  = e(A)
            mat     `BP' = e(BP)
            cap mat `b0' = e(b0)
            cap mat `b1' = e(b1)
            local vlist : colnames `BP'       /* varlist as entered by user */
      }
      else { local vlist `e(depvar)' }

      tokenize `vlist'
      local setlist "`set'"
      forv i = 1/`p' {
            local setlist : subinstr loc setlist "``i''" "", word all
      }
      if trim("`setlist'") != "" {
            di as err "set() invalid, variable(s) `setlist' " _c
            di as err "not found in `e(cmd)'"
            exit 198
      }

      if `dyn' {                                     /* mark dynamic sample */
            summ `tvar', meanonly
            if `dyn'<`r(min)' | `dyn'>`r(max)' {
                  di as err "dynamic() outside range of time variable"
                  exit 198
            }
            tempvar   touseD
            g byte   `touseD' = `touse'
            replace  `touseD' = 0 if `tvar'<`dyn'
            count if `touseD'
            if r(N)==0 {
                  di as err "dynamic() outside range defined by _if_ or _in_"
                  exit 198
            }
      }


      /* The strategy is to process the simpler cases first and then Close ->
       * exit.  If recursive forecasts are requested, temporary predictions
       * must be calculated regardless of whether user requests fitted values
       * for a single eq'n.  Predictions are always stored as temporary
       * variables until the end of the Close subroutine.  The latter computes
       * residuals (if applicable), renames, and labels. */


            /********************************************/
            /*                                          */
            /*  Case 1:                                 */
            /*          one equation, one-step ahead    */
            /*                                          */
            /********************************************/

      if ("`varlist'" != "" & !`dyn') {
            if "`equation'" == "" { local equation #1 }

            tempname pred opinv
            _predict double `pred' if `touse', eq(`equation') `xb' `stdp'
            Depname depname : `equation'
            if `y' & index("`depname'",".") {
                  op_inv `depname' `pred' if _n, gen(`opinv')
                  replace `pred' = `opinv'
            }
            n Close "`pred'" "" `0'
            exit
      }

            /********************************************/
            /*                                          */
            /*  Case 2:                                 */
            /*          all equations, one-step ahead   */
            /*                                          */
            /********************************************/

      tokenize `e(depvar)'

      if !`dyn' {
            forv i = 1/`p' {
                  tempname pred`i' opinv`i'
                  _predict double `pred`i'' if `touse', eq(#`i') `xb' `stdp'

                  if `y' & index("``i''",".") {
                        op_inv ``i'' `pred`i'' if _n, gen(`opinv`i'')
                        replace `pred`i'' = `opinv`i''
                  }
                  local predlis `predlis' `pred`i''  /* list of predictions */
            }
      }

            /********************************************/
            /*                                          */
            /*  Case 3:                                 */
            /*          one or all equations, dynamic   */
            /*                                          */
            /********************************************/

      if `dyn' {
            tempfile origdat preddat
            tempname merge
            preserve
            save `origdat'                           /* save original data */

            IsSet "`vlist'" "`set'" `p'

            /* names stripped of ts operators */

            foreach var in `e(depvar)' {
                  tsrevar `var', list
                  local baselis `baselis' `r(varlist)'
            }

            /* dump obs on endog vars after `dyn' */

            forv i = 1/`p' {    /* issue if `dyn' & !`y', think of solution */
                  local s   : word `i' of `setbin'
                  local var : word `i' of `baselis'
                  replace `var' =. if `tvar'>=`dyn' & !`s'
            }

            /* static predictions */

            forv i = 1/`p' {
                  tempname pred`i' opinv`i'

                  _predict double `pred`i'' if `touse', eq(#`i') `xb' `stdp'

                  if `y' & index("``i''",".") {
                        op_inv ``i'' `pred`i'' if _n, gen(`opinv`i'')
                        replace `pred`i'' = `opinv`i''
                  }
                  local predlis `predlis' `pred`i''  /* list of predictions */
            }

            summ `tvar' if `touseD', meanonly
            local tmax = r(max)
            local t = `dyn'-1

            while `t'< `tmax' {
                  local t = `t'+1
                  local if_t "if `tvar'==`t'"

/* <<============ */

if `ecm' {

      forv v = 1/`e(cirel)' {
            tempvar vec`v'
            g double `vec`v'' = 0
            forv i = 1/`p' {       /* slightly different than in vececm.ado */
                  local var : word `i' of `vlist'
                  replace `vec`v'' = `vec`v'' + `BP'[`v',`i']*l.`var' `if_t'
            }
            if "`e(sm)'" == "1*" {
                  replace `vec`v'' = `vec`v'' + `b0'[`v',1] `if_t'
            }
            if "`e(sm)'" == "2*" {
                  replace `vec`v'' = `vec`v'' + `b1'[`v',1]*`tvar' `if_t'
            }
            replace Co_Rel`v' = `vec`v'' `if_t'
      }
}

/* ============>> */

                  forv i = 1/`p' {                /* predictions for ea obs */
                        local s    : word `i' of `setbin'
                        local base : word `i' of `baselis'

                        if !`s' {
                              tempvar pred opinv temp
                              _predict double `pred' `if_t', eq(#`i')
                              g double `temp' = `pred'

                              if index("``i''",".") {
                                    op_inv ``i'' `pred' if _n, gen(`opinv')
                                    replace `temp' = `opinv'
                              }

                              replace `base' = `temp' if `tvar'>=`dyn' &    /*
                                                                 */  `base'==.

                              if `y' {
                                    replace `pred`i'' = `temp' if `pred`i''==.
                              }
                              else {
                                    replace `pred`i'' = `pred' if `pred`i''==.
                              }
                              drop `pred' `temp'
                              cap drop `opinv'
                        }
                  }
            } /* t loop */

            keep `predlis' `tvar'
            save `preddat'
            drop _all
            u `origdat'
            merge `tvar' using `preddat', update replace _merge(`merge')
            tsset
            restore, not

      } /* end if `dyn' */

      n Close "`predlis'" "`setbin'" `0'

} /* end quietly */
end


program define Close
      gettoken predlist 0 : 0
      gettoken setbin   0 : 0
      syntax [newvarname] [if] [in],    [  Suffix(str)             /*
                                    */     Prefix(str)             /*
                                    */     Dynamic(str)            /*
                                    */     Residuals               /*
                                    */     Y                       /*
                                    */     YResiduals              /*
                                    */     Type(str)               /*
                                    */     set(varlist ts)         /*
       std opt for ME estimators    */     EQuation(str) xb stdp ]

      marksample touse, novarlist
      if "`yresiduals'" != "" {
            local y "y"
            local residuals "residuals"
      }
      local eq = cond("`equation'"=="","1",subinstr("`equation'","#","",.))
      if "`type'"!="" { local typlist "`type'" }
      local y = cond("`y'"!="" | "`yresiduals'"!="",1,0)
      local resid = cond("`residuals'"!="",1,0)
      local stdp  = cond("`stdp'"!="",1,0)
      local dyn   = cond("`dynamic'"!="",1,0)

      /* make list of new variable names */

      if "`varlist'"=="" {
            foreach var in `e(depvar)' {
                  tsrevar `var', list
                  local varlist `varlist' `prefix'`r(varlist)'`suffix'
            }
      }
      local nv : word count `varlist'


      /* residuals, if applicable */

      if `resid' {
            forv i = 1/`nv' {
                  local pred : word `i' of `predlist'
                  local depv : word `i' of `e(depvar)'
                  if `nv'==1 { local depv : word `eq' of `e(depvar)' }
                  if `y' {
                        tsrevar `depv', list
                        qui replace `pred' = `r(varlist)' - `pred'
                  }
                  else { qui replace `pred' = `depv' - `pred' }
            }
      }

      /* generate permanent variables & labels */

      if `y'   { local levels  ", levels"      }
      if `dyn' { local foretyp "(Recursive)" }
      else     { local foretyp "(One-step)"  }
      if `resid' { local lbl "Residuals`levels' `foretyp'" }
      else {
            if `stdp' { local lbl "S.E. of the prediction`levels' `foretyp'" }
            else { local lbl "Fitted`levels' `foretyp'" }
      }
      local lbl = trim("`lbl'")

      forv i = 1/`nv' {
            if `nv'==1 {
                  local depv : word `eq' of `e(depvar)'
                  local s    : word `eq' of `setbin'
                  if `dyn' {
                        local pred   : word `eq' of `predlist'
                  }
                  else {
                        local pred   : word `i' of `predlist'
                  }
            }
            else {
                  local depv : word `i' of `e(depvar)'
                  local s    : word `i' of `setbin'
                  local pred : word `i' of `predlist'
            }
            if ("`s'" != "1") {     /*  bcs, here, set() may be empty */
                  local newvar : word `i' of `varlist'
                  qui g `typlist' `newvar' = `pred' if `touse'
                  la var `newvar' "`lbl': `depv'"
                  qui count if missing(`newvar')
                  if r(N) {
                        local s = cond(r(N)>1,"s","")
                        di as txt "(" r(N) " missing value`s' generated)"
                  }
            }
      }
end


program define Depname    /* <depname> : <equation name or number> */
      args      depname   /*  macro to hold dependent variable name
            */  colon     /*  ":"
            */  eqopt     /*  equation name or #number
            */  pos       /*  optional, requests macro pos to hold
                              position of eq'n name */

      if substr("`eqopt'",1,1) == "#" {
            local eqnum =  substr("`eqopt'",2,.)
            local dep : word `eqnum' of `e(depvar)'
            c_local `depname' `dep'
            if "`pos'" != "" { c_local pos `eqnum' }
            exit
      }

      tokenize `e(eqnames)'
      local i 1
      while "``i''" != "" {
            if "``i''" == "`eqopt'" {
                  local dep : word `i' of `e(depvar)'
                  c_local `depname' `dep'
                  if "`pos'" != "" { c_local pos `i' }
                  exit
            }
            local i = `i' + 1
      }
end


/* IsSet builds a list of 0s and 1s, the 1s appear if one of the variables in
eqlist has been set by the user to be pre-determined, such as in scenarios. */

program define IsSet

      args eqlist setlist p

      tokenize `eqlist'
      forv i = 1/`p' {
            local temp : subinstr loc setlist "``i''" "", word count(loc one)
            if `one' { local setbin `setbin' 1 }
            else { local setbin `setbin' 0 }
      }
      c_local setbin `setbin'
end

exit


Issues
------

o For ECMs, shouldn't predictions always be generated in levels since the user
  usually specifies them within tsops at -johans-.  (But then, what if the
  user uses a tsop on a subset of endogenous variables at -johans-?)

Features
--------

o don't complain when user specifies y or yr and model was estimated in levels

o -if `touse'- is indeed required in the block where `s'==1 (i.e. at line
   -replace `pred`i'' = `base' if `pred`i''==. & `touseD'-) whereas it is not
   required in the block where `s'==0.  The reason is that, in the latter case,
   `temp' and `pred' (in the `s'==0 block) are defined iff `touse' is not zero.
   Therefore, an -if `touse'- statement would be redundant.
