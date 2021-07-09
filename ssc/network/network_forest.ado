/*
*! Ian White # 4apr2018
	note() doesn't default to "graphs by column" if no inco model
version 1.2.3 # Ian White # 11jan2016
    output "group(...) assumed" suppressed unless -debug- on
version 1.2.2 # Ian White # 21aug2015
    really tiny changes
version 1.2.1 # Ian White # 22jul2015
    default for group() depends on whether inconsistency results are displayed
version 1.1 # Ian White # 8jun2015
    new structure using matrices of fitted values stored by -network meta-
version 1.0 # Ian White # 9Sep2014 
version 0.8 # 31jul2014 
    adapted to network meta's new covariate naming scheme
version 0.7 # Ian White # 11jul2014
    diamond option - useful for monochrome printing
version 0.6 # Ian White # 6jun2014
    force option to truncate the CIs (hence new parsing for xlabel())
version 0.5.2 # Ian White # 3feb2014
    bug fixed in extracting inco result (e.g. for B-H in thromb)
	note() and legend() options added - should behave in standard ways
	legend(off) and note(" ") are default with cons(off) inco(off)	
	noteopts() removed in favour of better parsing of note()
version 0.5 # Ian White # 27jan2014 
    uses network convert pairs
    works for all formats
version 0.4.1 # Ian White # 3jan2014 
    graph symbol scaling problem: solved 2jan2014
        - see http://www.stata.com/statalist/archive/2008-08/msg00987.html    
        - idea is that the set of weights in the to-use subset must be the same across variables and across by-groups
version 0.4 # Ian White # 18dec2013
version 0.3   13sep2013 + 4oct2013

Problems: 
    set graphics off -> loses current memory graphs and remains after crashes

Would like to allow gap() option to control gap between blocks, but this will disturb other code!
*/

prog def network_forest

// LOAD SAVED NETWORK PARAMETERS
if mi("`_dta[network_allthings]'") {
	di as error "Data are not in network format"
	exit 459
}
foreach thing in `_dta[network_allthings]' {
    local `thing' : char _dta[network_`thing']
}

// PARSE
syntax [if] [in], [ ///
/// model options
	CONSistency(string) INCOnsistency(string) ///
/// options controlling what is displayed
    List noGRaph clear ///
/// non-standard graph options
    COLors(string) CONTRASTOptions(string) TRTCodes CONTRASTPos(string) /// 
	COLUMNs(string) Level(cilevel) NCOLumns(int 0) force DIAmond group(string) ///
    eform ///
/// standard graph options needing special treatment
    TItle(passthru) XTItle(string) MSIZe(passthru) ///
	MSymbol(passthru) note(string asis) LEGend(string) XLABel(string) /// 
/// undocumented options
    addrows(int 0) headband debug diamondheight(real 0.4) /// 
/// standard graph options NOT needing special treatment
    * ]

if "`graph'" == "nograph" & mi("`clear'") local list list
if mi("`debug'") local ifdebug *
else local dicmd noi dicmd 
if mi("`consistency'") local consistency `consistency_fitted'
if mi("`inconsistency'") local inconsistency `inconsistency_fitted'
if mi("`msymbol'") local msymbol msymbol(S)
if mi("`xtitle'") {
    if mi("`eform'") local xtitle `measure'
    else if lower(substr("`measure'",1,4))=="log " local xtitle = upper(substr("`measure'",5,1)) + substr("`measure'",6,.)
    else local xtitle exp(`measure')
}
else if substr("`xtitle'",1,1)=="," local xtitle `measure' `xtitle'
if !mi("`xtitle'") local xtitle xtitle(`xtitle')
if !inlist("`columns'","xtile","smart","") {
    di as error "Syntax: columns(smart|xtile)"
    exit 198
}
if mi("`msize'") local msize msize(*0.2) // default
local graphoptions `options' // leaves us free to parse suboptions
marksample touse

// NB new syntax statement
* legend options: pick out locations options, rest are content options
local 0 ,`legend'
syntax, [off on POSition(passthru) ring(passthru) /// location options
	BPLACEment(passthru) span at(passthru) /// location options
	Rows(passthru) Cols(passthru) * /// contents options
	]
local legendlocation `off' `on' `position' `ring' `bplacement' `span' `at'
if mi("`rows'`cols'") local rows rows(1)
local legendcontents `options' `rows' `cols'
* note options: separate text from options
local 0 `"`note'"'
syntax [anything], [size(passthru) *]
if mi("`size'") local size size(vsmall)
local note `"`anything'"'
local noteopts `size' `options'
* raw forest plot?
if inlist("`consistency'","off","") & inlist("`inconsistency'","off","") {
	di as text "Drawing raw forest plot without any model results"
	local consistency off   // suppresses later message
	local inconsistency off // suppresses later message
	if mi("`legend'") local legendlocation off // no legend
}
if mi("`group'") {
    if inlist("`inconsistency'","off","") local group type
    else local group design
    if !mi("`debug'") di as text "group(`group') assumed"
}
if !inlist("`group'","design","type") {
    di as error "group(`group') not allowed"
    exit 198
}


// START ANALYSIS
preserve
qui keep if `touse'
tempvar base
gen `base' = word(`design',1)
qui tab `design'
local ndesigns = r(r)

// make a dataset of designs # treatment-contrasts (converting to pairs format)
if "`format'" != "pairs" qui network convert pairs

// extract study-specific treatment contrasts
local typelist study
tempvar diff se type
local diff `y'
local se `stderr'
keep `studyvar' `design' `t1' `t2' `diff' `se'
`ifdebug' di as text "Listing of study-level results: studyvar design t1 t2 diff se"
`ifdebug' l `studyvar' `design' `t1' `t2' `diff' `se'
gen `type'="study"
local stackvars `studyvar' `design' `t1' `t2' `diff' `se' `type'

// load predictions from consistency and inconsistency models 
qui levelsof `design', local(designs)
tempvar null
qui gen `null' = .
foreach model in inconsistency consistency {
    if "``model''"=="off" continue
    cap confirm matrix ``model''
    if _rc {
        di as text "Warning: `model' matrix of fitted values not found - forest plot will be incomplete"
        continue
    }
    `ifdebug' di "`model' results will be taken from matrix ``model''"
    local mod = substr("`model'",1,4)
    svmat ``model'', names(`mod') // columns are design t1 t2 b se
    * decode designs
    qui gen `design'`mod' = ""
    local ndes 0
    foreach des of local designs {
        local ++ndes
        qui replace `design'`mod'=`"`des'"' if `mod'1==`ndes'
    }
    * decode treatments
    qui gen `t1'`mod' = ""
    qui gen `t2'`mod' = ""
    local ntrt 0
    foreach trt in `ref' `trtlistnoref' {
        local ++ntrt
        qui replace `t1'`mod'=`"`trt'"' if `mod'2==`ntrt'
        qui replace `t2'`mod'=`"`trt'"' if `mod'3==`ntrt'
    }
    drop `mod'1 `mod'2 `mod'3
    gen `type'`mod'="`mod'"
    local stackvars `stackvars' `null' `design'`mod' `t1'`mod' `t2'`mod' `mod'4 `mod'5 `type'`mod'
    `ifdebug' di as text "Listing of `model' results:  design t1 t2 diff se"
    `ifdebug' l `design'`mod' `t1'`mod' `t2'`mod' `mod'4 `mod'5 if !mi(`mod'4)
    local typelist `typelist' `mod'
}
if "`typelist'"' != "study" { // some model results are included
    stack `stackvars', into(studyvar design t1 t2 diff se type) clear
    drop _stack
}
else rename (`stackvars') (studyvar design t1 t2 diff se type)
qui drop if mi(diff)

// GET RESULTS IN CORRECT SORT ORDER FOR GRAPH

sort t1 t2 type design studyvar
qui by t1 t2 type: drop if type=="cons" & _n>1
qui by t1 t2 type: drop if type=="inco" & design==design[_n-1]
qui replace design="" if type=="cons"
gen iscons=(type=="cons")
gen isinco=(type=="inco")
* `group' gives the top-level grouping after t1 t2
if "`group'"=="design" sort t1 t2 iscons design isinco studyvar
else if "`group'"=="type" sort t1 t2 iscons isinco studyvar design 
drop iscons isinco
order t1 t2 design type studyvar

// OPTIONALLY LIST

if "`list'"=="list" {
    di as text "Listing of results extracted from current data and saved network meta-analyses:"
    l t1 t2 design type studyvar diff se, sepby(t1 t2) 
}


// ADD EXTRA LINES FOR GRAPH

* make gap after each design, but only if there are multiple designs
gen row=_n
qui by t1 t2: gen first = _n==1
qui by t1 t2: gen gap = `group'!=`group'[_n-1] 
egen gapsum=sum(gap), by(t1 t2)
qui replace gap=0 if gapsum==2 // no gap between designs if only one design in the contrast
qui replace gap=4 if first // 4-line gap at start of contrast
qui expand 1 + gap 
drop gap gapsum first
sort t1 t2 row
qui by t1 t2: gen rowij = _n
sort row
qui by row: gen above = _N-_n // =rows above first study
qui replace type = "gap" if above
qui replace type = "header" if rowij==3
qui replace type = "headband" if inlist(rowij,2,4)
qui replace row=_n

* define columns
gen contrast = sum( (t1!=t1[_n-1]) | (t2!=t2[_n-1]) )
if `ncolumns'==0 local ncolumns = max(1, int(sqrt(_N/10)))
if `ncolumns'==1 gen column = 1
else if "`columns'"=="xtile" xtile column = contrast, nq(`ncolumns')
else smartgroup column = contrast, ngroups(`ncolumns')

sort column row
qui by column: gen rowincol=_n
qui by column: gen lastincol=_n==_N
summ rowincol, meanonly
local maxrows = r(max)+`addrows'
qui expand `maxrows'+1-rowincol if lastincol, gen(newrow)
qui replace type="gap" if newrow
qui replace diff=. if newrow
qui replace se=. if newrow
sort column newrow row
*drop rowincol lastincol newrow
qui replace row=_n

* label the rows
* label: labels studies/summaries on y-axis
cap confirm string var studyvar
if !_rc qui gen label = studyvar if type=="study" & !above 
else qui gen label = "Study " + string(studyvar) if type=="study" & !above 
qui replace label = "All " + design if type=="inco" & !above
qui replace label = "All studies" if type=="cons" & !above
if mi("`trtcodes'") foreach trt in `ref' `trtlistnoref' {
    if !mi("`trtname`trt''") {
        qui replace t1 = "`trtname`trt''" if t1 == "`trt'"
        qui replace t2 = "`trtname`trt''" if t2 == "`trt'"
    }
}
qui gen label2 = t2 + " vs. " + t1 if type=="header" 
* label2: labels contrast in middle of plot
qui for var diff se: replace X=. if above
labelit row label

tokenize "`colors'"
local col_study = cond("`1'"=="", "blue" , "`1'")
local col_inco  = cond("`2'"=="", "green", "`2'")
local col_cons  = cond("`3'"=="", "red"  , "`3'")
local zcrit = invnorm((1+`level'/100)/2)
qui gen low = diff-`zcrit'*se
qui gen upp = diff+`zcrit'*se

* test
if mi(`"`note'"') & !mi("`testcons_stat'") {
    local note = `""Test of consistency: `testcons_type'(`testcons_df')="' ///
        + string(`testcons_stat',"%6.2f") ///
        + `", P="' + string(`testcons_p',"%5.3f") + `"""'
}
if "`format'"=="pairs" & `maxarms'>2 local note `"`note' "The data contain multi-arm trials - this analysis in pairs format is wrong""'
if !mi(`"`note'"') local note note(`note', `noteopts')
else local note note("")

* TRUNCATION
if !mi("`xlabel'") & !mi("`force'") {
    local 0 `xlabel'
    syntax anything, [*]
    cap numlist "`anything'", sort
    if _rc {
        di as error "Force option ignored - xlabel() doesn't contain a numlist"
        local force
    }
    else {
        local lowtrunc = word("`r(numlist)'",1)
        local upptrunc = word("`r(numlist)'",wordcount("`r(numlist)'"))
    }
}
if !mi("`force'") {
    qui count if diff<`lowtrunc' & !mi(diff)
    if r(N) {
        di as error "Error: " r(N) " point estimates lie below truncation limit `lowtrunc'"
        exit 498
    }
    qui count if diff>`upptrunc' & !mi(diff)
    if r(N) {
        di as error "Error: " r(N) " point estimates lie above truncation limit `upptrunc'"
        exit 498
    }
    qui gen lowistrunc = low<`lowtrunc'
    qui replace low = `lowtrunc' if lowistrunc
    qui gen uppistrunc = upp>`upptrunc'
    qui replace upp = `upptrunc' if uppistrunc
}
else {
    gen lowistrunc=0
    gen uppistrunc=0
}

* GRAPH BOXES AND SPIKES
local cmd graph twoway 
if !mi("`diamond'") {
    gen rowplus=row+`diamondheight'
    gen rowminus=row-`diamondheight'
}
local igraph 0
foreach type in `typelist' {
    if "`type'"=="study" local desc Studies 
    if "`type'"=="inco"  local desc Pooled within design 
    if "`type'"=="cons"  local desc Pooled overall 
    // Scatter plot for point estimates: want this one in the legend
    if "`type'"=="study" | mi("`diamond'") { // symbol and line
        local ++igraph
        local cmd `cmd' (scatter row diff if type=="`type'" [aw=1/se^2], mcol(`col_`type'') `msymbol' `msize')
        local order `order' `igraph'
        local labellist `labellist' label(`igraph' "`desc'") 
        // Spike plot for confidence intervals: not wanted in legend
        forvalues ilow=0/1 {
            forvalues iupp=0/1 {
                qui count if lowistrunc==`ilow' & uppistrunc==`iupp'
                if r(N)==0 continue
                local ++igraph
                if `ilow'==0 & `iupp'==0 local cmdname pcspike
                else if `ilow'==1 & `iupp'==1 local cmdname pcbarrow
                else local cmdname pcarrow
                if `ilow'==1 & `iupp'==0 local vars row upp row low // gets arrow R to L
                else local vars row low row upp 
                local cmd `cmd' (`cmdname' `vars' if type=="`type'" & lowistrunc==`ilow' & uppistrunc==`iupp', ///
                    lcol(`col_`type'') mcol(`col_`type''))
            }
        }
    }
    else { // open diamond
        local coords1 row low
        local coords2 rowplus diff
        local coords3 row upp
        local coords4 rowminus diff
        forvalues j=1/4 {
            if `j'==1 local start `coords4'
            local finish `coords`j''
            local ++igraph
            local cmd `cmd' (pcspike `start' `finish' if type=="`type'", lcol(`col_`type'')) 
            if `j'==1 {
                local order `order' `igraph'
                local labellist `labellist' label(`igraph' "`desc'") 
            }
            local start `finish'
        }
    }
}

* GRAPH CONTRAST HEADINGS (like subtitles)
if mi("`contrastpos'") {
    summ low, meanonly
    local lowmin=r(min)
    summ upp, meanonly
    local uppmax=r(max)
    local contrastpos = (`lowmin'+`uppmax')/2
}
gen middle = `contrastpos'
local cmd `cmd' (scatter row middle, ///
    mlabel(label2) mlabpos(0) ms(none) mlabcol(black) `contrastoptions')

* GRAPH OPTIONS
if !mi("`headband'") {
    qui levelsof row if type=="headband", local(yline)
    local yline yline(`yline', lcol(black)) 
}
local legendcontents legend(order(`order') `labellist' `legendcontents')
local legendlocation legend(`legendlocation')
if mi("`xlabel'") local xlabel xlabel(,labsize(small))
else local xlabel xlabel(`xlabel') xlabel(,labsize(small))
local cmd `cmd', ///
    ylabel(#`maxrows', valuelabel angle(0) labsize(vsmall) nogrid ) ///
    yscale(reverse) plotregion(margin(t=0)) ytitle("") subtitle("") `yline' ///
    by(column, row(1) yrescale noiytick `title' `note' `legendlocation') ///
    `legendcontents' `xlabel' xtitle(,size(small)) `xtitle' ///
    `graphoptions'

* MAKE MARKER SIZES COMPARABLE
* Idea is to replicate all the weights in every type and every by-group,
* but a key variable is missing in all but the original
qui {
    gen typenum = 0 if type=="study"
    replace typenum = 1 if type=="inco"
    replace typenum = 2 if type=="cons"
    * remember there are other types which we don't need to replicate
    gen id = _n
    expand `=3*`ncolumns'' if !mi(typenum)
    sort id
    qui by id: gen dup = _n-1 // dup=0 is the orginal
    replace row = . if dup>0  // dup>0 isn't plotted but affects marker sizes
    if !mi("`diamond'") {
        replace rowplus = . if dup>0  // dup>0 isn't plotted but affects marker sizes
        replace rowminus = . if dup>0  // dup>0 isn't plotted but affects marker sizes
    }
    replace typenum = mod(typenum+dup,3) // the duplicates have all possible types ...
    replace type="study" if typenum == 0
    replace type="inco"  if typenum == 1 
    replace type="cons"  if typenum == 2 
    replace column = mod(column+int(dup/3)-1,`ncolumns')+1 // ... and all possible columns
}

* OPTIONAL EFORM
if !mi("`eform'") {
    foreach var in diff low upp middle {
        qui replace `var'=exp(`var')
    }
    local cmd `cmd' xscale(log)
}    

* DO THE GRAPH AND FINISH 
if "`graph'"!="nograph" `dicmd' `cmd'
if "`clear'"=="clear" {
    restore, not
    network unset
    global F9 `cmd'
    di as text "graph command stored as F9"
}

end


****************** AUXILIARY PROGRAMS: LABELIT *********************

* version 2.1 11feb2013  
prog def labelit
version 9
syntax varlist(min=2 max=2) [if] [in], [modify usefirst noBLAnks]
tokenize "`varlist'"
confirm numeric variable `1'
confirm string variable `2'
marksample touse, novarlist
qui summ `1' if `touse'
local imin=r(min)
local imax=r(max)
tempvar id 
gen `id'=_n
forvalues i = `imin'/`imax' {
   qui summ `id' if `1'==`i' & `touse'
   if r(N)>0 {
      local doit 1
      local j=r(min)
      local value = `2'[`j']
      cap assert `2'=="`value'" if `1'==`i' & `touse'
      if _rc>0 {
        di as text "Warning: multiple values of `2' found for `1'==`i'"
        tab `2' if `1'==`i' & `touse', missing
        if "`usefirst'"!="usefirst" {
            di as error "To use the first value, specify usefirst option"
            exit 498
        }
        else di as text "Using the first value, `2'=`value'"
      } 
      if "`value'"~="" local label `label' `i' "`value'"
	  else if "`blanks"!="noblanks" local label `label' `i' " "
      cap assert `2'=="`value'" if `1'==`i'
      if _rc>0  {
         di as text "Warning: multiple values of `2' for `1'==`i' - but only outside if/in expression"
         label var `touse' "to use"
         tab `2' `touse' if `1'==`i', missing
      }
   }
}
label def `1'_`2' `label', `modify'
label val `1' `1'_`2'
end

****************** END OF LABELIT *********************

****************** START OF SMARTGROUP *********************

prog def smartgroup

syntax newvarname=/exp, NGroups(int) [Table NOIsily]
local gen `varlist'
confirm var `exp'
* make `gen' from `exp'

qui {
	* setup
	tempvar n
	gen `gen'=.
	egen `n'=count(1), by(`exp')
	local go 1

	while `go' {
		* find biggest group in `exp'
		summ `n'
		summ `exp' if `n'==r(max)
		local expvalue = r(min)

		* find smallest group in `gen'
		local nmin .
		forvalues i=1/`ngroups' {
			count if `gen'==`i'
			local n`i'=r(N)
			local nmin=min(r(N),`nmin')
		}
		local smallest .
		forvalues i=1/`ngroups' {
			if `n`i''==`nmin' {
				local smallest `i'
				continue, break
			}
		}

		if !mi("`noisily'") noi di "Assign `exp'=`expvalue' to `gen'=`smallest'"
		replace `gen' = `smallest' if `exp'==`expvalue'
		replace `n' = 0 if `exp'==`expvalue'

		* stop?
		count if `n'>0
		if r(N)==0 local go 0
		
	}
}

if !mi("`table'") tab `exp' `gen', missing

end

****************** END OF SMARTGROUP *********************

prog def dicmd
noi di as input `"`0'"'
`0'
end
