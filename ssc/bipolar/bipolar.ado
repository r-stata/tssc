*! v1.2.0, 2020-05-03, module to compute bipolarization index
*  call external sgini, all weights (except iw), svy bootstrap
* v1.1.0, 2011-05-13, module to compute bipolarization index
* option sortvar()- is there for checking (keep undocumented!)... need to see if proper way forward and check within/between concentration stuff
* probably not making much sense...

program define bipolar, rclass sortpreserve byable(recall) properties(svyb svyj)
  version 9.2
  syntax varname(numeric ts) [if] [in]  [fweight aweight pweight] [ , ///
          POSonly ///
          Rankcut(real -100) Levelcut(real -100) ///
          Format(string) ///
          /// sortvar(varname) ///
          ]
  
  if ("`format'"=="") loc format "%4.3f"
  *if ("`sortvar'"=="")  loc sortvar "`varlist'"
  loc sortvar "`varlist'"
  
  // --- parse weight
  loc w "`weight'`exp'"
  if (inlist("`weight'","","fweight","aweight"))  loc faw "`w'"  
  else loc faw "aweight`exp'"     // where iw, pw and aw treated similarly
   
  // --- parse cutoff
  if ( ((`rankcut'==-100) + (`levelcut'==-100))==2 )    loc rankcut    0.50  
  else { 
    if ( ((`rankcut'==-100) + (`levelcut'==-100)) == 0 ) {
      di as error "Options {cmd:rankcut()} and {cmd:levelcut()} are mutually exclusive"
      exit 198
    }
    if (`rankcut'!=-100 & !inrange(`rankcut',0,1) ) {
      di as error "{cmd:rankcut()} must be between 0 and 1"
      exit 198
    }  
  }  
  
  marksample touse 
  markout `touse' 
  if ("`posonly'" != "")  qui replace `touse' = 0 if `varlist'<=0
    
  qui count if `touse'
  if r(N) == 0 {
		error 2000
  }

  // if (("`sortvar'"!="`varlist'"))     di as text "Note: {cmd:sortvar()} option is experimental!"

  // -- check non-positive data
  qui count if `varlist' < 0 & `touse'
  loc ctneg = r(N)
  qui count if `varlist' == 0 & `touse'
  loc ct0 = r(N)
  if (`ctneg'+`ct0')>0  {
		  di as text "Note: `varlist' has " _c
		  if (`ctneg'>0)  di "`ctneg' value(s) < 0 " _c
		  if (`ct0'>0)  di "`ct0' value(s) == 0 " _c
  		 di as text "(used in calculations)."
  }
  
  // -- find out the cut point and build condition for split
  tempvar inlow
  if (`levelcut'!=-100) {
    gen byte `inlow' =  (`sortvar'<`levelcut')  if `touse'
    loc cutpoint = `levelcut' 
  }
  else {
    tempvar rank
    sort `sortvar' `varlist'
    qui cumul `sortvar'   [`faw']     if `touse' , gen(`rank')  equal
    qui gen byte `inlow' =  (`rank'<`rankcut')  if `touse'
    qui _pctile `varlist' [`faw'] if `touse', p(`=100*`rankcut'')
    loc cutpoint = r(r1)
  }    
  
  // --- estimate necessary components
  //---------------
  // Overall stats:
  //---------------
  
  su `varlist' [`faw'] if `touse' , meanonly
  if (r(mean)==0) {
    di as error "Mean `varlist' == 0 . 'Total Gini' and bipolarization measures undefined."
    exit
  }
  local mean = r(mean)
  loc N = r(N)
  loc sum_w = r(sum_w)
  
  su `inlow'  if `touse'  [`faw']  , meanonly
  if (r(mean)==0) | (r(mean)==1) {
    di as error "One population group is empty. Bipolarization measures undefined.""
    exit
  }
  loc sharep = r(mean)
  
  qui sgini `varlist'  if `touse' [`weight'`exp'] , sortvar(`sortvar')
  local sgini = r(coeff)
  
  //------------------
  // low income group:
  //------------------
 	su `varlist'  if `inlow' & `touse' [`faw']  , meanonly
  local mup = r(mean)
  if (r(min)==r(max)) {
    di as txt "Note: `varlist' constant within low income group -- Gini set to unity."
    local sginip = 1
  }
  else {
    if (r(mean)==0) {
      di as error "Mean `varlist' == 0 among low income group. 'Within Gini' and bipolarization measures undefined."
      exit
    }
    qui sgini `varlist'  if `inlow' & `touse' [`weight'`exp']  , sortvar(`sortvar')
    local sginip = r(coeff)
  }

  //------------------
  // high income group:
  //------------------    
 	su `varlist'  if !`inlow' & `touse' [`faw'] , meanonly
  local mur = r(mean)
  if (r(min)==r(max)) {
    di as txt "Note: `varlist' constant within high income group -- Gini set to unity."
    local sginir = 1
  }
  else {
    if (r(mean)==0) {
      di as error "Mean `varlist' == 0 among high income group. 'Within Gini' and bipolarization measures undefined."
      exit
    }
    qui sgini `varlist' if !`inlow' & `touse'  [`weight'`exp'] , sortvar(`sortvar')
 	  local sginir = r(coeff)
  }
  
  //-------------------
  // Combine components
  //-------------------    
  local Within  = (((`sharep'^2)*`mup'*`sginip') + (((1-`sharep')^2)*`mur'*`sginir'))/`mean'
  local Between = `sharep' * (`mean' - `mup')/`mean'   
  
  // --- estimate coefficients
  local DHS = ( `Between' - `Within' ) / `sgini'
  local ZK = `Between' / `Within'
  if (float(`rankcut')!=float(0.5))  di as text "Note: Foster Wolfson (1992,2010) index only defined at median cut-off."
  //if (("`sortvar'"!="`varlist'"))     di as text "Note: Foster Wolfson (1992,2010) index undefined with {cmd:sortvar()} option."
  if ((float(`rankcut')==float(0.5)) & ("`sortvar'"=="`varlist'") ) {
   	local FW = ( `Between' - `Within' ) * `mean' / `cutpoint'
  }	


  // --- Return results:
  return local varname "`varlist'"
  return local sortvar "`sortvar'"
  return scalar DHS = `DHS'
  if ("`FW'"!="")   	return scalar FW  = `FW'
  return scalar ZK	  = `ZK'
  return scalar Gini   = `sgini'
  return scalar GW    = `Within'
  return scalar GB	  = `Between'
  return scalar sum_w = `sum_w'
  return scalar N = `N'
  return scalar share_low = `sharep'
  return scalar cutpoint = `cutpoint'
  
  // --- Output 
  tempvar index value  
  tempname lbindex  lbd
  loc j 0
  lab def `lbindex' `++j' "Deutsch Hanoka Silber (2007)"	, add
  lab def `lbindex' `++j' "Foster Wolfson (1992, 2010)"		, add
  lab def `lbindex' `++j' "Zhang Kanbur (2001)"				, add
  lab def `lbindex' `++j' " "								, add
  lab def `lbindex' `++j' "Overall Gini index"			, add
  lab def `lbindex' `++j' "Population share in low income group"		, add
  lab def `lbindex' `++j' "Within group inequality"			, add
  lab def `lbindex' `++j' "Between group inequality"		, add
  qui gen `index' = _n in 1/`j'
  lab values `index' `lbindex'
  lab var `index' "Bi-polarization measures"
  
  quietly {
    loc j 0
  	gen `value'= .
  	la var `value' "value"
  	replace `value' = `DHS'   	in `++j'
  	if ("`FW'"!="") replace `value' = `FW'  	in `++j'
  	replace `value' = `ZK'		in `++j'
  	replace `value' = .a		in `++j'
  	replace `value' = `sgini'	in `++j'
  	replace `value' = `sharep'	in `++j'
  	replace `value' = `Within'	in `++j'
  	replace `value' = `Between' in `++j'
  }
  lab def `lbd' .a " "
  lab val `value' `lbd'
  tabdisp `index' in 1/`j' , cellvar(`value') concise format(`format') missing
 	 
end

exit

