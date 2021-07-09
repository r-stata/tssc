*! v1.0.0, 2007-09-04, Andreas Peichl, Philippe Van Kerm : module for taxation and income redistribution analysis


program define progres , rclass sortpreserve
  version 8.2
  syntax varlist(min=2 max=2 numeric)  [if] [in] [fweight aweight] ,  [Param(real 2.0) Format(string) ]
  
  gettoken pretaxvar posttaxvar : varlist , parse(" ")
  loc posttaxvar = trim("`posttaxvar'")

  tempvar taxvar
  gen double `taxvar' = `pretaxvar' - `posttaxvar'
 
  if ("`format'"=="") loc format "%5.4f"
  
  marksample touse 
  
  // do not use negative pretax income values (Problem with Suits)
  	qui count if `pretaxvar' < 0 & `touse'
  	local ct = _result(1)
  	if `ct' > 0 {
  		noi di as text "Note: `pretaxvar' has `ct' value(s) < 0." _c
  		noi di as text " Not used in calculations."
	  	qui replace `touse' = 0 if `pretaxvar' < 0
  	}
  	qui count if `pretaxvar' == 0 & `touse'
  	local ct = _result(1)
  	if `ct' > 0 {
  		noi di as text "Note: `pretaxvar' has `ct' value(s) = 0." _c
  		noi di as text " Used in calculations."
  	}
    	qui count if `posttaxvar' < 0 & `touse'
    	local ct = _result(1)
    	if `ct' > 0 {
    		noi di as text "Note: `posttaxvar' has `ct' value(s) < 0." _c
    		noi di as text " Used in calculations."
    	}
    	qui count if `posttaxvar' == 0 & `touse'
    	local ct = _result(1)
    	if `ct' > 0 {
    		noi di as text "Note: `posttaxvar' has `ct' value(s) = 0." _c
    		noi di as text " Used in calculations."
  	}

  // --- estimate necessary components
  qui su `taxvar' [`weight'`exp'] if `touse' , meanonly
  local m_tax = r(mean)
  loc N = r(N)
  loc sum_w = r(sum_w)
  qui su `pretaxvar' [`weight'`exp'] if `touse' , meanonly
  local m_pre = r(mean)
  _sgini `posttaxvar' [`weight'`exp'] if `touse', param(`param')
  local G_post = r(coeff)
  _sgini `pretaxvar' [`weight'`exp'] if `touse', param(`param')
  local G_pre = r(coeff)
  _sgini `taxvar' [`weight'`exp'] if `touse', sortvar(`pretaxvar')  param(`param')
  local C_tax = r(coeff)
  _sgini `posttaxvar' [`weight'`exp'] if `touse', sortvar(`pretaxvar')  param(`param')
  local C_post = r(coeff)
  _sgini `taxvar' [`weight'`exp'] if `touse', sortvar(`pretaxvar')  param(`param') suits
  local R_taxvar = r(coeff)
  _sgini `pretaxvar' [`weight'`exp'] if `touse', sortvar(`pretaxvar')  param(`param') suits
  local R_pretaxvar = r(coeff)
  
  // --- estimate coefficients
  local MT = (1-`G_post')/(1-`G_pre')
  * RS  =  VE + R  =  (g/1-g)K + R
  local RS = `G_pre' - `G_post'
  local g  = `m_tax'/`m_pre'
  local K  = `C_tax' - `G_pre'
  local VE = `G_pre'-`C_post'
  local R  = `G_post'-`C_post'
  local AP =  0.5*`R'/`G_post'
  local S  = `R_taxvar'-`R_pretaxvar'
  
  // --- Return results:
  return clear
  return scalar Kakwani = `K'
  return scalar MusThin = `MT'
  return scalar ReySmol	= `RS'
  return scalar VE  	= `VE'
  return scalar R		= `R'
  return scalar AtkPlot = `AP'
  return scalar Suits   = `S'
  return scalar ATR		= `g'
  return scalar G_pre   = `G_pre'
  return scalar G_post  = `G_post'
  return scalar C_post  = `C_post'
  return scalar C_tax   = `C_tax'
  return local pretaxvar  "`pretaxvar'"
  return local posttaxvar  "`posttaxvar'"
  return scalar sum_w = `sum_w'
  return scalar N = `N'
  
  // --- Output 
  tempvar index value  
  tempname lbindex  lbd
  qui gen `index' = _n in 1/12
  la var `index' "Measures"
  lab def `lbindex' 1 "Pre-tax Gini"   , add
  lab def `lbindex' 2 "Post-tax Gini"  , add
  lab def `lbindex' 3 "Average tax rate" , add
  lab def `lbindex' 4 " " , add
  lab def `lbindex' 5 "Reynolds-Smolensky net redis. effect" , add
  lab def `lbindex' 6 "Kakwani progressivity index"   , add
  lab def `lbindex' 7 "Vertical equity" , add  
  lab def `lbindex' 8 "Reranking"   , add
  lab def `lbindex' 9 " " , add
  lab def `lbindex' 10 "Suits progressivity index", add
  lab def `lbindex' 11 "Musgrave-Thin redistributive effect", add
  lab def `lbindex' 12 "Atkinson-Plotnick horiz. inequity", add
  lab values `index' `lbindex'
  
  quietly {
   gen `value'= .
   la var `value' "(v=`param')"
   replace `value' = `G_pre'   in 1
   replace `value' = `G_post'  in 2
   replace `value' = `g'		  in 3
   replace `value' = .a		  in 4
   replace `value' = `RS'	  in 5
   replace `value' = `K'       in 6
   replace `value' = `VE'      in 7
   replace `value' = `R'       in 8
   replace `value' = .b		  in 9
   replace `value' = `S'       in 10
   replace `value' = `MT'      in 11
   replace `value' = `AP'      in 12
  }
  lab def `lbd' .a " " .b " "
  lab val `value' `lbd'
  tabdisp `index' in 1/12 , cellvar(`value') concise format(`format') missing

end  


program define _sgini , rclass sortpreserve
  // v2.3.1, 2007-08-30
  version 8.2
  syntax varname [if] [in]  [fweight aweight] [ , Param(real 2.0) Sortvar(varname) SUITS ]
  tempvar p padj sumw sumwp
  tempname X m
  loc w "`weight'`exp'"
  if "`sortvar'"==""  loc sortvar "`varlist'"
  marksample touse
  markout `touse' `sortvar' 
  gettoken eq wexp : exp , parse(=)
  if "`wexp'"=="" loc wexp "1"
  quietly {
    if ("`suits'" != "") cumul `sortvar' [aw=`wexp'*`sortvar'] if `touse' , gen(`p') 
    else cumul `sortvar' [`w'] if `touse' , gen(`p') 
    sort `p'
    gen double `padj' = max(0,`p'[_n-1]) + ( (( `p' - max(0,`p'[_n-1]))/2 ) )  if `touse'
    gen double `sumw' = .
    gen double `sumwp' = .
    bys `sortvar' `touse' : replace `sumw' = sum(`wexp') if `touse'
    bys `sortvar' `touse' : replace `sumwp' = sum(`wexp'*`padj') if `touse'
    bys `sortvar' `touse' : replace `padj' = `sumwp'[_N]/`sumw'[_N] if `touse'
    replace `p' = (1-`padj')^(`param'-1) if `touse'
    mat accum `X' = `varlist' `p' [`w'] if `touse' , dev noc means(`m')
    return scalar coeff = -`param' * (`X'[2,1]/(r(N))) / `m'[1,1] 
  }
end


exit
Andreas Peichl
Philippe Van Kerm
