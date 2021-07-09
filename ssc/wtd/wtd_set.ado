*! version 0.1, HS
*! version 0.2, HS, drops early events and exits, but still requires ///
  event to precede an eventual exit

/* wtd_set
   wtdset, clear
   wtdset event exit, [i(id)] start(1jan1996) end(31dec1997)
	  [robust cl(clid)]

   Compare with st_set.
*/

program define wtd_set
version 7.0

if "`1'" != "set" { exit 198 }


#delimit ;

args
cmd  /*  	*/
/*  wtdopts  		"" or "notable"	       */
  event     /* event time:      <varname>              */
  exvar     /* exit time:       <varname>              */
  id        /* id:              <varname> | <nothing>  */
  ifexp     /* if exp:          <exp> | <nothing>      */
  fwexp     /* fw exp:          <exp> | <nothing>      */
  start     /* start:           "date"                 */
  end       /* end:             "date"                 */
  robust    /* marker:          <nothing> | "robust"   */
  cluster   /* cluster var:	<varname> | <nothing>  */
  scale     /* scale:           real      | <nothing>  */

  ;

#delimit cr

quietly {
  tempfile orgdata
  save `orgdata'



/* 
Step 1.  apply restrictions 
*/


  if `"`ifexp'"' != "" {
    local ifif `"if `ifexp'"'
  }

  tempvar touse
  mark `touse' `ifif'

  keep if `touse'
  
  local ifif
  count if `touse'==0

  if "`id'" != "" {
    count if missing(`id') & `touse'
    replace `touse' = 0 if missing(`id')

/*
Step 2. Prune data
*/

  replace `event' = . if `event' > d(`end')
  replace `exvar' = . if `exvar' > d(`end')

tempvar earlyev earlyex
gen `earlyev' = sum(`event' <= d(`start') & `event' != .)
  if `earlyev'[_N] > 0 {
    noi di in yellow ///
      "At least one of your event times happens before start of the time window."
    noi di in yellow ///
      "Please check if this is what you want." ///
        _n "These event times are set to missing for now." _n 
  }
  drop `earlyev'
  replace `event' = . if `event' <= d(`start')

  gen `earlyex' = sum(`exvar' <= d(`start') & `exvar' != .)
  if `earlyex'[_N] > 0 {
    noi di in yellow ///
      "At least one of your exit times happens before start" ///
        _n "of the time window."
    noi di in yellow ///
      "These observations are dropped from the dataset." _n
    drop if `exvar' <= d(`start')
  }
  drop `earlyex'

  gen `earlyex' = sum(`exvar' < `event' & `exvar' != . & `event' != .)
  if `earlyex'[_N] > 0 {
    use `orgdata', replace
    noi di in red ///
      "At least one individual has an exit time prior to an event."
    exit 198
    
  }

/*
Step 3. Only use first obs for each id if id is present
*/

    sort `id' `event'
    qby `id': replace `touse' = 0 if _n > 1
  }
    else {
      tempvar id
      gen `id' = _n
    }
/*
Step 4. If data are clustered, set markers
*/

  if "`cluster'" ~= "" {
    char _dta[wtd_clus] `"`cluster'"'
  }


/*
Step 5. Collapse data
*/
    
  keep if `touse'
  

  confirm new var _nev
  if "`fwexp'" == "" {
    collapse (count) _nev=`id', by(`event' `exvar' `cluster') fast
  }
  else {
    collapse (count) _nev=`id' [fw = `fwexp'], by(`event' `exvar' `cluster') fast
  }
  
/*
Step 5. Generate variables used by wtd-commands
*/
  
  confirm new var _t _z _clid
  
  local perlgth = d(`end') - d(`start')
  
  gen _t = (`event' - d(`start') - .5) / `perlgth' 
  gen _z = (`exvar' - d(`start') - .5 ) / `perlgth'
  
  gen _ot = .
  replace _ot = 1 if _t != . & _z != .
  replace _ot = 2 if _t != . & _z == .
  replace _ot = 3 if _t == . & _z != .
  replace _ot = 4 if _t == . & _z == .
  replace _t = 1 if _ot >= 3
  replace _z = 1 if _ot == 2 | _ot == 4
  
  if "`cluster'" != "" {
    gen _clid = `cluster'
    label var _clid "`cluster'"
    local robust = "robust"
  }
  
  label var _ot "Observation types"
  label def otcat 1 "Event + exit" 2 "Event only" ///
    3 "Exit only" 4 "None", modify
  label val _ot otcat
  
/*
Step 6. Set characteristics
*/

  char _dta[wtd_start] `"`start'"'
  char _dta[wtd_end] `"`end'"'
  char _dta[_dta] "wtd"
  char _dta[wtd_ev] `"`event'"'
  char _dta[wtd_ex] `"`exvar'"'
  char _dta[wtd_rob] `"`robust'"'
  char _dta[wtd_clus] `"`cluster'"'
  char _dta[wtd_scale] `"`scale'"'

}

/*
Step 7. Show basic descriptive statististics
*/

wtd_show
    
    

end

