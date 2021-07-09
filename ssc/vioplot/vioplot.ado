*! version 1.1.5  24may2012 by austinnichols@gmail.com and nwinter@virginia.edu
*! create violin plots

/*
 changelog

 1.1.5  add check for N>0 with [if] [in] etc.

 1.1.4  fix double `over' -levels- call, changed default label orientation
 
 1.1.3  support weights

 1.1.2  minimized memory footprint when -total- option is specified

 1.1.1  truncate() option within over()

 1.1.0  multiple y variables
               added over() suboptions -total-, -missing-, -nolabel-
               added -noylab- option

 1.0.2  disabled accidental use of -by- option
               added -sortpreserve-


*/

program vioplot, sortpreserve
       version 9.2

       syntax varlist [if] [in] [aw pw fw],                              ///
               [       Over1(string) Over2(string) Over3(string)       ///
                       noFill                                                  ///
                       HORizontal VERTical                             /// (vertical) is default
                       Kernel(passthru) BWidth(passthru)               /// kdensity options
                       DScale(real 100) BARWidth(real 100)     /// rescale the densities
                       DENsity(string)                                 /// density plotting options
                       BAR(string)                                             /// bar plotting options (note barw() is percentage)
                       LINE(string)                                            /// line plotting options
                       MEDian(string)                                          /// median plotting options
                       OBs1 OBsalt(string) OBSOPTs(string)     /// obs or obs(alt) to add (n) to plot
                       OGap(real 100) YGap(real 100)   noYLabel noLabelrotate ///
                       by(string)                                              /// sic
                       *                                                               /// overall graph options
               ]
       if `"`exp'"'!="" loc wt `"[aw`exp']"'
       if "`horizontal'"!="" & "`ylabel'"=="" loc y0 "yla(,angle(0))"
       if "`horizontal'"=="" & "`xlabel'"=="" loc y0 "xla(,angle(90))"
       if "`horizontal'"!="" & "`ylabel'"=="" & "`labelrotate'"=="" loc y0 "yla(,angle(90))"
       if "`horizontal'"=="" & "`xlabel'"=="" & "`labelrotate'"=="" loc y0 "xla(,angle(0))"
       local gropts `options'
       local yvars `varlist'

       if `"`by'"'!="" {
               di as error "by() not allowed; use over() to specify categories"
               exit 190
       }


       if `"`over1'"'=="" {    // no over() specified
               local no_over_spec 1
               tempvar no_over
               tempname no_over_lab
               qui gen byte `no_over'=1
               local over1 `no_over'
               la de `no_over_lab' 1 "`varlist'"
               la val `no_over' `no_over_lab'
               local gropts xscale(range(0.5 1.5)) `gropts'
       }
       else {
               local no_over_spec 0
       }

       if `"`over3'"'!="" {
               di as error "too many over() options specified"
               exit 198
       }

       if "`obsalt'"!="" {
               if "`obsalt'"=="alt" local obs obs
               else {
                       di as error "invalid obs()"
                       exit 198
               }
       }
       if "`obs1'"=="obs1"  local obs obs

       if `: word count `horizontal' `vertical''>1 {
               di as error "may not combine options horizontal and vertical"
               exit 198
       }
       else if "`horizontal'`vertical'"=="" local vertical vertical

       if "`horizontal'"=="horizontal" {
               local kdorientation vertical    /* needs to be reverse of overall */
               local cataxis y                 /* category labels are ylab */
       }
       else {
               local kdorientation horizontal
               local cataxis x
       }

       marksample touse, novarlist             // based on varlist (i.e., yvar(s))
                                                               // additional -markout- below after processing of -over- option

       if "`fill'"=="nofill" {         // need to dump categories that have no observations for *any* y-var
               tempvar marker
               qui gen `marker'=.
               foreach var of local varlist {
                       qui replace `marker'=1 if !mi(`var')            // set to one for any obs that is avail for any y-var
               }
               markout `touse' `marker'                                                        // drop obs that don't exist for any y-var
                                                                                                       // done with `marker' at this point
       }


//deal with over() options
       local 0 `over1'
       syntax [varname (default=none)] , [ Missing1 noLABel1 Total1 TRuncate(passthru) ]
       if "`varlist'"!="" {
               local m = cond("`missing1'"=="missing1","missing","")

               if substr("`: type `varlist''",1,3)!="str" & "`label1'"=="nolabel1" {   // string variables need -label- option in egen
                       tempvar tmp                                                                     //
                       qui gen `tmp' = `varlist'                       // so that egen, label will grab values r/t original labels if any
                       local varlist `tmp'
               }

               tempvar over1
               sort `varlist'
               qui egen `over1'=group(`varlist') if `touse', `m' label `truncate' // so we have a numeric variable, labelled
               if `"`: label (`over1') 1'"'=="" {
                       label define `over1' 1 ".", modify                      // egen used varname as labelname
               }
               capture drop `tmp'                                              // done with `tmp'; need capture in case we didn't ever use it
       }

       local 0 `over2'
       syntax [varname (default=none)] , [ Missing2 noLABel2 Total2 TRuncate(passthru) ]
       if "`varlist'"!="" {
               local m = cond("`missing2'"=="missing2","missing","")
               if substr("`: type `varlist''",1,3)!="str" & "`label2'"=="nolabel2" {   // string variables need -label- option in egen
                       tempvar tmp                                                                     //
                       qui gen `tmp' = `varlist'
                       local varlist `tmp'
               }

               tempvar over2
               sort `varlist'
               qui egen `over2'=group(`varlist') if `touse', `m' label `truncate' // so we have a numeric variable, labelled
               if `"`: label (`over2') 1'"'=="" {                              // if string with blanks
                       label define `over2' 1 ".", modify                      // egen used varname as labelname
               }
               capture drop `tmp'                                              // done with `tmp'; need capture in case we didn't ever use it
       }


       local over `over1' `over2'
       local nover : word count `over'

       if "`total1'"!="" & "`total2'"!="" {
               di as error "May only specify total option for one over() variable"
               exit 198
       }

       local preserved 0
       if `nover'==2 & "`fill'"!="nofill" {
               preserve
               local preserved 1
               fillin `over'                                           // create missing values of over combinations
               qui replace `touse'=1 if _fillin==1     // so that new categories exist in group variable
       }

       if "`total1'`total2'"!="" {
               if !`preserved' preserve                                // preserve if we didn't already do it above
               local preserved 1
               keep `yvars' `touse' `over1' `over2'    // will be appending entire dataset, so drop unnecessary vars
       }

                       * marksample occurs before -fillin-
                       * then -fillin-
                       * then flag new observations as in-sample (even though they are missing on DV(s)
                       *        because we want those categories to exist on the category axis
                       * Then we markout the -over- vars *after* the fillin, in order to markout any
                       *               that fillin created with missing on the over variables (unless -missing- option specified)
       if "`missing1'"!="missing1" markout `touse' `over1'             // no strok b/c group variables created by egen above
       if "`missing2'"!="missing2" markout `touse' `over2'

* `touse' is all set at this point

       local 0 , `bar'                                 // pull off the barwidth argument (note it's now a percentage)
       syntax , [ BARWidth1(string) * ]
       local bar `options'
       if "`barwidth1'"!="" {
               di as error "must specify barwidth() as main option, not suboption for bar()"
               exit 198
       }

       local n_y : word count `yvars'
       local barwidth barwidth(`=0.05*(`barwidth'/100)*(1/`n_y')')
       local overgap 0.5*(`ogap'/100)

       qui {
               tempvar overvar                                 // to hold category values 1 2 3 . . . .
               tempvar xpos                                            // position on "x"-axis for each category


                                                                               // note: val label for each group is [o2level] [o1level]
                                                                               // GenGroup sorts data: `touse' `over2' `over1'
               GenGroup "`overvar'" "`touse'" "`over1'" "`over2'" "`label1'" "`label2'" "`total1'" "`total2'" "`preserved'"
               sum `overvar', meanonly
               local nlev `r(max)'
               if "`nlev'"=="" error 2000

               // work out xpos and labelling for second -over- variable, if any
               if `nover'==1 {
                       gen `xpos'=`overvar'
               }
               else {
                       gen `xpos'=.
                       local prev_o2 : word 1 of `: label (`overvar') 1'                       // initialize to the first one
                       local cur_o2_min 1
                       local curxpos 1
                       forval i=1/`nlev' {

                               local cur_o2 : word 1 of `: label (`overvar') `i''
                               if `"`cur_o2'"'!=`"`prev_o2'"' {
                                       local cur_o2_range = `curxpos' - `cur_o2_min' - 1               // minus 1 is b/c already incremented for this one
                                       local ppos = (`curxpos'-1)-(`cur_o2_range')/2   // midpoint of previous group

                                       local curxpos = `curxpos' + `overgap'                           // jump up by the gap
                                       local cur_o2_min `curxpos'

                                       * generate axis label part for this group
                                       if "`cataxis'"=="x" local catlabs2 `catlabs2' `ppos' `"" " "`prev_o2'""'
                                       else                    local catlabs2 `catlabs2' `ppos' `""`prev_o2'" " ""'

                                       local prev_o2 `cur_o2'
                               }
                               replace `xpos' = `curxpos' if `overvar'==`i'            // for creation of stuff
                               local curxpos = `curxpos' + 1                                   // increment for next

                       }
                       * do final group
                       local cur_o2_range = `curxpos' - `cur_o2_min' - 1               // minus 1 is b/c already incremented for this one
                       local ppos = (`curxpos'-1)-(`cur_o2_range')/2   // midpoint of previous group
                       if "`cataxis'"=="x" local catlabs2 `catlabs2' `ppos' `"" " "`cur_o2'""'
                       else                    local catlabs2 `catlabs2' `ppos' `""`cur_o2'" " ""'

               }


       local legend_num 1
       local cur_y_n 0

       local kdmin .
       local kdmax .

       foreach cur_y of varlist `yvars' {
               tempvar inspike p25 p50 p75 first lav uav min max nobs
               tempvar my_xpos

               local cur_y_n=`cur_y_n'+1

               local offset = (`cur_y_n' - `n_y'/2 - 0.5)*(1/(`n_y'+1))*(`ygap'/100)           // creates spacing of ygap between categories

               gen `my_xpos' = `xpos'+`offset'

               // generate statistics for bar and spike (i.e., boxplot stats)

		bys `touse' `over' (`cur_y'): egen `p25'=count(`cur_y') if `touse'		// sic
		gen `nobs' = "(" + string(`p25',"%9.0g") + ")"
		drop `p25'
		
		by `touse' `over': egen `min'=min(`cur_y') if `touse'
		by `touse' `over': egen `max'=max(`cur_y') if `touse'

		g double `p25'=.
		g double `p50'=.
		g double `p75'=.
		levels `overvar' if `touse', loc(overlevs)
		foreach olev of loc overlevs {
		 _pctile `cur_y' `wt' if `touse' & `overvar'==`olev', nq(4)
		 replace `p50'=r(r2) if `touse' & `overvar'==`olev'
		 replace `p25'=r(r1) if `touse' & `overvar'==`olev'
		 replace `p75'=r(r3) if `touse' & `overvar'==`olev'
		 }

               // flag observations within the spike range
               gen `inspike'=inrange(`cur_y',`p25' - 1.5*(`p75'-`p25'),`p75' + 1.5*(`p75'-`p25')) if `touse'

               // flag first observation within each group--this is the one that is plotted for each bar
               bysort `touse' `over' `inspike' (`cur_y'): gen `first' = (_n==1) if `inspike'==1 & `touse'

               // flag lav and uav for plotting the spike
               by `touse' `over' `inspike': gen `lav' = `cur_y'[1] if `inspike'==1 & `touse'
               by `touse' `over' `inspike': gen `uav' = `cur_y'[_N] if `inspike'==1 & `touse'

               forval i=1/`nlev' {
                       tempvar x_`i' d_`i' nd_`i'

                       local curlev `i'                // : word `i' of `xlevels'
                       capture kdensity `cur_y' `wt' if `overvar'==`curlev' & `touse', gen(`x_`i'' `d_`i'') nograph `kernel' `bwidth'
                       if _rc==2001 {          // only one observation; treat as if none for purposes of density
                               gen `x_`i''=.
                               gen `d_`i''=.
                       }
                       else if _rc {
                               di as error "kdensity produced an error:"
                               exit _rc
                       }

                       sum `d_`i'', meanonly
                       local scalefac = (.3/(r(max)-r(min)))*(1/`n_y')*(`dscale'/100)
                       replace `d_`i'' = `scalefac' * (`d_`i''-r(min))         // scales & forces the mirror images to touch
                       gen `nd_`i'' = -`d_`i''                                                 // create mirror

                       if "`obs'"!="" {
                               sum `x_`i'', meanonly
                               if `r(N)' {
                                       local kdmin = min(`kdmin',`r(min)')
                                       local kdmax = max(`kdmax',`r(max)')
                               }
                       }

                       sum `my_xpos' if `overvar'==`curlev', meanonly
                       replace `d_`i'' = `d_`i'' + `r(min)'            // move over
                       replace `nd_`i'' = `nd_`i'' + `r(min)'

                       if `cur_y_n'==1 {               // cat axis label; only needed for first y
                               sum `xpos' if `overvar'==`curlev', meanonly // doesn't include offset!
                               local thelabel : label (`overvar') `curlev'
                               local thelab_1 : word `nover' of `thelabel'             // word two if two over vars; word one if one
                               local thelab_2 : word 1 of `thelabel'
                               local catlabs `catlabs' `r(min)' `"`thelab_1'"'                 // add var1 label
                       }

                       local kdplots `kdplots' ///
                               rarea `nd_`i'' `d_`i'' `x_`i'' , `kdorientation' pstyle(p`cur_y_n') finten(35) `density' sort ||
                       if `i'==1 {
                               local cylab : variable label `cur_y'
                               if "`cylab'"=="" | "`ylabel'"=="noylabel" local cylab `cur_y'
                               local legend_text `legend_text' `legend_num' `"`cylab'"'

                       }



                       local ++legend_num


               }

               local scatter_vars = cond("`vertical'"=="vertical","`p50' `my_xpos'","`my_xpos' `p50'")

               if "`obs'"=="obs" {
                       tempvar obsy

                       if "`obsalt'"=="" gen `obsy' = `kdmin' - 0.05*(`kdmax'-`kdmin')
                       else               gen `obsy' = `kdmax' + 0.05*(`kdmax'-`kdmin')

                       local obs_vars = cond("`vertical'"=="vertical","`obsy' `my_xpos'","`my_xpos' `obsy'")
                       local obsplot || scatter `obs_vars' , ///
                               msym(none) mlab(`nobs') mlabpos(0) mlabsize(vsmall) mlabcolor("scheme foreground") `obsopts'
                       local ++legend_num
               }


               local curgraph  `kdplots'       ///
                       rbar `p25' `p75' `my_xpos' if `first',                                  ///
                               `horizontal'`vertical' pstyle(p`cur_y_n') `barwidth' `bar' ||   ///
                       scatter `scatter_vars' if `first',                                      ///
                               pstyle(p`cur_y_n') msym(O) mfcolor(white) `median' ||   ///
                       rspike `p75' `uav' `my_xpos' if `first',                                        ///
                               `horizontal'`vertical' pstyle(p`cur_y_n') `line' ||                     ///
                       rspike `lav' `p25' `my_xpos' if `first',                                        ///
                               `horizontal'`vertical' pstyle(p`cur_y_n') `line'                        ///
                       `obsplot'

               local kk `kk' `kdplots' ||
               local oo `oo' || ///
                       rbar `p25' `p75' `my_xpos' if `first',                                  ///
                               `horizontal'`vertical' pstyle(p`cur_y_n') `barwidth' `bar' ||   ///
                       scatter `scatter_vars' if `first',                                      ///
                               pstyle(p`cur_y_n') msym(O) mfcolor(white) `median' ||   ///
                       rspike `p75' `uav' `my_xpos' if `first',                                        ///
                               `horizontal'`vertical' pstyle(p`cur_y_n') `line' ||                     ///
                       rspike `lav' `p25' `my_xpos' if `first',                                        ///
                               `horizontal'`vertical' pstyle(p`cur_y_n') `line'                        ///
                       `obsplot'

               local wholegraph `wholegraph' || `curgraph'
               local kdplots

       } // foreach cur_y of yvars


       if `no_over_spec' {             // ie, no over specified; need to sort out labelling of x-axis
               local catlabs
               forval i=1/`n_y' {
                       local cy : word `i' of `yvars'
                       local cylab : variable label `cy'

                       if "`cylab'"=="" | "`ylabel'"=="noylabel" local cylab `cy'

                       local offset = (`i' - `n_y'/2 - 0.5)*(1/(`n_y'+1))*(`ygap'/100)         // creates spacing of ygap between categories

                       local catlabs `catlabs' `=1+`offset'' `"`cylab'"'
               }
       }


       if `n_y'>1 & !`no_over_spec'    local legend legend(order(`legend_text'))
       else                                    local legend legend(off)

       gr twoway `kk' `oo' ///
               `cataxis'lab(`catlabs' `catlabs2', notick)                              ///
               `legend' `y0' `gropts'

       } // quietly

end /* nwviolin */

program GenGroup
       args overvar touse over1 over2 label1 label2 total1 total2 preserved

       local sortorder `over2' `over1'

       if "`total1'`total2'"!="" {
               if "`total1'"!="" {
                       local tot_var `over1'
                       local tot_other `over2'
                       local sortorder `over2' `orig' `over1'
               }
               else {
                       local tot_var `over2'
                       local tot_other `over1'
                       local sortorder `orig' `over2' `over1'
               }

               drop if !`touse'                        // keep things simple: drop unused observations
                                                               // this will drop or keep missing values of over_vars as necessary
                                                               // dataset was already -preserve-d when parsing total options before

               tempfile tmp
               save `"`tmp'"'
               tempvar orig
               gen `orig'=1

               append using `"`tmp'"'
               replace `orig'=2 if mi(`orig')          // put at end

               sum `tot_var', meanonly                                 // this has been egen'd, so no longer string
               replace `tot_var' = `r(max)'+1 if `orig'==2     // collapse relevant over variable after all other values
               local lll : value label `tot_var'
               if "`lll'"=="" {
                       tempname lll
               }
               la de `lll' `=`r(max)'+1' "(total)" , add       // label new category as "(Total)"
               la val `tot_var' `lll'

       }

       * code stolen from and modified: _ggroup.ado
       sort `touse' `sortorder'
       by `touse' `sortorder' : gen `overvar'=1 if _n==1 & `touse'
       replace `overvar'=sum(`overvar')
       replace `overvar'=. if `touse'!=1

       local lname `overvar'
       local dfltfmt : set dp
       local dfltfmt = cond("`dfltfmt'"=="period","%9.0g","%9,0g")

       count if !`touse'               // touse==0 sorted first
       local j = 1 + r(N)              // first observation in the first group
       sum `overvar', meanonly
       local max `r(max)'              // max number of categories
       local i 1
       while `i' <= 0`max' {   // while we are not through all the categories

               tokenize `over2' `over1'                //
               local vtmp " "
               local iteration `: word count `over2' `over1''
               local x 1
               while "`1'"!="" {
                       local vallab : value label `1'
                       local val = `1'[`j']
                       if "`vallab'" != "" {                                   // & "`label`iteration''"!="nolabel`iteration'"
                               local vtmp2 : label `vallab' `val'              // if label, grab it
                       }
                       else {
                               cap confirm numeric var `1'
                               if _rc==0 {
                                       local vtmp2 = string(`1'[`j'],"`dfltfmt'")      // if not a label, grab the value itself
                               }
                               else {
                                       local vtmp2 = trim(`1'[`j'])    // if not a label, grab the string itself (sic; all numeric at this point)
                               }
                       }
                       local x = `x' + length("`vtmp2'") + 1
                       local vtmp `"`vtmp' "`vtmp2'" "'
                       mac shift
                       local --iteration
               }

               local val `"`vtmp'"'
               label def `lname' `i' `"`val'"', modify
               count if `overvar' == `i'
               local j = `j' + r(N)
               local i = `i' + 1
       }
       label val `overvar' `lname'

       *END Labelling code from _ggroup.ado


end


exit

/*
* To Do
*
       -- relabel option for x-axis labelling

       -- individual heights for densities; widths for bars

       -- create a scheme for a nice default coloring?
*/
