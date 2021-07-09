   // Nov 13 2011 11:38:45
   // Based on bstrpr.do, attempt to generalise as an ado

   // Represent the average time-dependent transition pattern underlying a
   // set of sequences
   
capture program drop trprgr
   // VARLIST is the set of consecutive variables describing the sequences (must be reshape-able)
   // Options
   //  - required
   // NSTATES is number of states (numbered consecutively from 1)
   //  - optional
   // Probabilities on the diagonal (p(i,i)) are plotted with range FLOOR to 1
   // Probabilities off the diagonal (p(i,j), i!=j) are plotted with range 0 to CEILING
   // GMAX is the highest count in any state in any period
   // MOVINGAVERAGE is the half-window width for the smoothing in the transition matrix caclulation
   // TEXTSIZE is a textsizestyle option that controlls the textsize
program define trprgr
syntax varlist(min=2) [if] [in],  /* NStates(int) */ [FLoor(real 0.9) CEIling(real 0.1) GMax(integer 400) MOVingaverage(int 3) TEXtsize(string) *]

   marksample touse

local gmaxxs `gmax'
local floorxs `floor'
local ceilingxs `ceiling'

// allow textsizestyle options
   if ("`textsize'"!="") {
      local textsize ",size(`textsize')"
      }
   else {
      local textsize ",size(`textsize')"
      }
   
   preserve

   keep if `touse'

   tempname id
   gen `id' = _n

   keep `id' `varlist'

   local state : word 1 of `varlist'
   local statelab: value label `state'
   local state = regexr("`state'","[0-9]+","")
   local seql  : word count `varlist'
   
   
   tempname timevar
   tempname trpr
   
   // Store the smoothed transition matrix
   di "Creating transition probability matrix"
   qui maketrpr `varlist', mat(`trpr') ma(`movingaverage')
   
   // Reshape long to calculate the
   // chronograms
   
   di "Creating chronogram data"
   qui reshape long `state', i(`id') j(`timevar')
   
   qui tab `state', gen(m)
   qui sum `state'
   local nstates `r(max)'
   collapse (sum) m1-m`nstates' , by(`timevar')
   
   label variable `timevar' "Time"

   di "Drawing chronograms"
   
   // Get intervals for count scale; principle copied from `gmax'units in hmap.ado
   local step 1
   while `gmax' == round(`gmax',`step') {
      local step = `step'*10
      }
   /* i is such that `gmax'==round(`gmax',i) is not true but `gmax'==round(`gmax',i/10) is */
   /* e.g. `gmax' is 1234500, i is 1000. */
   local step = `step'/10
   if (`gmax'!=round(`gmax',1)) {
      local step 1
      while `gmax' == round(`gmax',`step') {
         local step = `step'/10
         }
      local step = `step'*10
      }
   
   
   forvalues i = 1/`nstates' {
      
      if ("`statelab'"!="") {
         local sl : label `statelab' `i'
         label variable m`i' "`sl'"
         }
      else {
         label variable m`i' "State `i'"
         }
      qui su m`i'
      if (r(max)>`gmaxxs') {
        local gmaxxs `r(max)'
        noisily display in blue "Warning: state `i' exceeds GMAX: `r(max)' > `gmax'"
      }
      local cl : word `i' of navy maroon forest_green dkorange teal cranberry lavender khaki sienna emidblue emerald brown erose gold bluishgray
      tempname tmpgraph`i'
      twoway area m`i' `timevar', nodraw pstyle(p`i') yscale(range(0 `gmax')) xtitle(`textsize') ytitle(`textsize') ylabel(#5) /* ylabel(0(`step')`gmax') */ `options' name(`tmpgraph`i'', replace)
      /* graph save `tmpgraph`i'', replace */
      }
   
   local gcom ""
   
   //clear
   
   qui drop _all
   qui svmat `trpr'
   qui gen period = 1 + int((_n-1)/`nstates')
   qui gen state = 1 + mod(_n-1,`nstates')
   
   di "Drawing transition time-series"
   forvalues origin = 1/`nstates' {
      
      local gcom "`gcom' `tmpgraph`origin''"
      
      if ("`statelab'"!="") {
         local yt : label `statelab' `origin'
         }
      else {
         local yt "Origin `origin'"
         }
      
      forvalues dest = 1/`nstates' {
         if ("`statelab'"!="") {
            local xt: label `statelab' `dest'
            }
         else {
            local xt "Destination `dest'"
          }
         tempname graphof_`origin'_`dest'
         local gcom "`gcom' `graphof_`origin'_`dest''"
         
         if (`origin'==`dest') {
            qui su `trpr'`dest' if state==`origin'
            if (r(min)<`floorxs') {
              local floorxs `r(min)'
               noisily display in blue "Warning: Min t-rate(`origin',`dest') is less than floor: `r(min)' < `floor'"
               }
            line `trpr'`dest' period if state==`origin', clcolor(red) nodraw yscale(range(`floor' 1)) ylabel(`floor'(0.025)1.0) ytitle("`yt'"`textsize') xtitle("`xt'"`textsize') `options' name(`graphof_`origin'_`dest'', replace)
            }
         if (`origin'!=`dest') {
            qui su `trpr'`dest' if state==`origin'
            if (r(max)>`ceilingxs') {
              local ceilingxs `r(max)'
               noisily display in blue "Warning: Max t-rate(`origin',`dest') is greater than ceiling: `r(max)' > `ceiling'"
               }
            line `trpr'`dest' period if state==`origin', nodraw yscale(range(0 `ceiling')) ylabel(0.0(0.025)`ceiling') ytitle("`yt'"`textsize') xtitle("`xt'"`textsize') `options' name(`graphof_`origin'_`dest'', replace)
            }
         /* graph save `graphof_`origin'_`dest'', replace */
         }
    }
if (`gmaxxs' > `gmax') {
  di "GMAX exceeded: `gmaxxs'"
}
if (`floorxs' < `floor') {
  di "FLOOR exceeded: `floorxs'"
}
if (`ceilingxs' != `ceiling') {
  di "CEILING exceeded: `ceilingxs'"
}
di "Combining graphs"
graph combine `gcom'
   restore
end
