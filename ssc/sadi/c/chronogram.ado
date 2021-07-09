   // Nov 20 2011 22:38:31
   // Based on trprgr to make a simple chronogram

   // $Id: chronogram.ado,v 1.9 2014/09/12 18:02:38 brendan Exp $
   // $Log: chronogram.ado,v $
   // Revision 1.9  2014/09/12 18:02:38  brendan
   // Summary: Removed need to pass ID var as option
   //
   // Revision 1.8  2014/03/27 21:57:35  brendan
   // Summary: Escape Id
   //
   // Revision 1.7  2012/07/16 14:13:43  brendan
   // Improving version p/o
   //
   // Revision 1.6  2012/07/16 14:11:38  brendan
   // Added version/Id option
   //
   // Revision 1.5  2012/06/28 23:01:29  brendan
   // Made less noisy, put log and id in header
   //
capture program drop chronogram
   // VARLIST is the set of consecutive variables describing the sequences (must be reshape-able)
   // Options
   //  - required
   //    ID is an id variable
   //  - optional
   //    BY allows usual plots by variables
   //    textsize is probably redundant
   //    PROPortional draws plots that sum to 1, good with by
   // IN and IF respected
program define chronogram
   syntax varlist(min=2) [if] [in], [TEXtsize(string) * BY(string) PROPortional VERsion]

   if ("`version'"!="") di `"\$Id: chronogram.ado,v 1.9 2014/09/12 18:02:38 brendan Exp $"'

   
   // by -- stolen from sqindexplot
	if `"`by'"' != `""' {
		gettoken byvars byopts: by, parse(",")
	}

   marksample touse
   // allow textsizestyle options
   if ("`textsize'"!="") {
      local textsize ",size(`textsize')"
      }
   else {
      local textsize ",size(`textsize')"
      }
   
   preserve

   tempname id
   gen `id'=_n

   keep if `touse'
   keep `id' `varlist' `byvars'
   local state : word 1 of `varlist'
   local statelab: value label `state'
   local state = regexr("`state'","[0-9]+","")
   local seql  : word count `varlist'
   
   
   tempname timevar
   
   // Reshape long to calculate the
   // chronograms
   
   di "Creating chronogram data"
   qui reshape long `state', i(`id') j(`timevar')
   
   qui tab `state', gen(m)
   qui sum `state'
   local nstates `r(max)'
   collapse (sum) m1-m`nstates' , by(`timevar' `byvars')

   if ("`proportional'"!="") {
      qui egen total = rowtotal(m1-m`nstates')
      forvalues x = 1/`nstates' {
         qui replace m`x' = m`x'/total
         }
      }
   
   label variable `timevar' "Time"

   di "Drawing chronogram"

   qui gen runtot = 0
   
   forvalues i = `nstates'(-1)1 {

      qui replace runtot = runtot + m`i'
      qui replace m`i' = runtot
      
      if ("`statelab'"!="") {
         local sl : label `statelab' `i'
         label variable m`i' "`sl'"
         }
      else {
         label variable m`i' "State `i'"
         }
      }
   local none "" // roundabout way of setting an option for all variables to be plotted.
   // This reduces _almost_ to zero the ink from the last category if the last category is zero
   // Otherwise it plots a border even when there is nothing there. 
   forvalues i = 1/`nstates' {
      local none "`none' none"
      }
   if ("`byopts'"!="") local byopt ", `byopts'"
   local byoption "by(`byvars' `byopts')"
//   di `"twoway area m1-m`nstates' `timevar',  lwidth(`none') yscale(range(0)) xtitle(`textsize') ytitle(`textsize') `options' `byoption'"'
   twoway area m1-m`nstates' `timevar',  lwidth(`none') yscale(range(0)) xtitle(`textsize') ytitle(`textsize') `options' `byoption'
   restore
end
