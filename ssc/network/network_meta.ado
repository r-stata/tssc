/*
*! Ian White # 4apr2018
	better error message for network meta without c/i or previous model
version 1.2.1 # Ian White # 29jun2017 
	- attempted bug fix in standard format with nested trt names - see line 467
version 1.2.0 # Ian White # 3jul2015
    prints warning if MNAR has been set
version 1.1.4 # Ian White # 1jul2015
    network meta requires mvmeta v3.1
version 1.1.2 # Ian White # 10jun2015
    bug fix - output to forest failed when it shouldn't have done
version 1.1.1 # Ian White # 9jun2015
    if not suitable for forest, program used to halt with error; now it just doesn't send the results to forest 
version 1.1 # Ian White # 8jun2015
8jun2015
    nowt option dropped as it is mvmeta default
28may2015
    fixed bug giving wrong fitted values from inconsistency model in augmented format (made forest plot wrong)
26may2015
    stores matrix of fitted values for -network forest- (using code moved from there)
14may2015
    new options nowarnings, force
    now stops if disconnected etc. unless force option is used
11may2015
    added LuAdes models
8may2015
    added suppress() option to work with mvmeta v3.0
30mar2015
    added wt options (default is nowt)
    corrected error messages for missing metareg etc.
11mar2015
    fixed bug in vercheck
version 1.0 # Ian White # 9Sep2014 
version 0.8 # 31jul2014
    changed `metavars':
        from `trtdiff'`trt' to `trtdiff'_`trt'
        from `trtdiff'`r'`trt' to `trtdiff'`r'_`trt'
        from `trtdiff'`r'`trt'_`design'_* to `trtdiff'`r'_`trt'_des_*
version 0.7 # Ian White # 11jul2014
version 0.6.1 # Ian White # 6jun2014
version 0.6 # Ian White # 3jun2014
version 0.5 # Ian White # 27jan2014
25jan2014 testcons_chi2 changed to testcons_type and testcons_stat
    (because metareg test is F not chi2)
*/

prog def network_meta

// LOAD SAVED NETWORK PARAMETERS
foreach thing in `_dta[network_allthings]' {
    local `thing' : char _dta[network_`thing']
}

// PARSE
syntax [anything] [if] [in], [ REGress(varlist) ///
    pbest(string) Vars(string) /// mvmeta options not allowed
    i2 /// mvmeta option with a warning 
    BSCOVariance(string) debug pause fixed wt WT2(string) EQuations(passthru) /// mvmeta options needing special treatment
    LUAdes LUAdes2(string) noWARnings force * ///
    KEEPmat(name) /// undocumented
    ]
local options `fixed' `equations' `options'
local warn = "`warnings'"!="nowarnings"
local ifdebugdi = cond(mi("`debug'"),"*",`"di as text "debug: ""')

* which model?
if !mi("`anything'") {
    if substr("consistency",1,length("`anything'"))=="`anything'" local model consistency
    else if substr("inconsistency",1,length("`anything'"))=="`anything'" local model inconsistency
    else {
    	di as error "Syntax: network meta c[onsistency]|i[nconsistency], ..."
    	exit 198
    }
}
if !mi("`luades'`luades2'") {
    if "`model'"!="inconsistency" & `warn' di as error "Warning: luades option is only allowed with inconsistency model"
    if "`format'"!="augmented" {
        di as error "Lu-Ades model is only available when data are in augmented format"
        exit 198
    }
}
if mi("`ncomponents'") & `warn' di as error "Warning: can't check for disconnected network"
else if `ncomponents'>1 {
    if mi("`force'") | `warn' di as error "Warning: network is disconnected, so network meta models will be wrong"
    if mi("`force'") {
        di as error "(Use force option to override - at your own risk)"
        exit 498
    }
}
if mi("`df_inconsistency'") di as error "Warning: can't check df for inconsistency"
else if `df_inconsistency'==0 & "`model'"=="inconsistency" {
    if mi("`force'") | `warn' di as error "Warning: inconsistency model requested, but there is no source of inconsistency" 
    if mi("`force'") {
        di as error "(Use force option to override - at your own risk)"
        exit 498
    }
}
if mi("`df_heterogeneity'") di as error "Warning: can't check df for heterogeneity"
else if `df_heterogeneity'==0 {
	local bscov1=word("`bscovariance'",1)
	if !mi("`bscov1'") & "`bscov1'"==substr("equals",1,length("`bscov1'")) local bscov1 equals
	if mi("`fixed'") & "`bscov1'"!="equals" {
        if mi("`force'") | `warn' di as error "Warning: heterogeneity model requested, but there is no source of heterogeneity: consider the fixed option"
        if mi("`force'") {
            di as error "(Use force option to override - at your own risk)"
            exit 498
        }
    }
}

if !mi("`pbest'") {
    di as error "The mvmeta option pbest() is not allowed."
    di as error "Please instead use {help network rank}."
    exit 198
}
if !mi("`vars'") {
    di as error "The mvmeta option vars() is not allowed."
    di as error "To restrict the model, run {help network setup} with the trtlist option."
    exit 198
}
if !mi("`i2'") {
    if "`format'"=="pairs" di as error "Warning: i2 option is not available in pairs format"
    if "`format'"=="standard" di as error "Warning: i2 option is not meaningful in standard format"
}
if !mi("`regress'") & "`format'"!="augmented" {
    di as error "Meta-regression not yet implemented for `format' format"
    exit 198
}

* check metareg/mvmeta is loaded
if "`format'"=="pairs" {
    cap which metareg
    if _rc {
        di as error `"network requires metareg: click {stata ssc install metareg:here} to install"'
        exit 498
    }
}
else {
    local minmvmetaversion 3.1
    cap vercheck mvmeta `minmvmetaversion'
    if _rc {
        if _rc == 601 {
            di as error `"network requires mvmeta: click {stata "net install mvmeta, from(http://www.homepages.ucl.ac.uk/~rmjwiww/stata/meta)":here} to install"'
        }
        else if _rc == 498 {
            di as error "network requires mvmeta version `minmvmetaversion' or later"
            di as error `"Click {stata "net install mvmeta, from(http://www.homepages.ucl.ac.uk/~rmjwiww/stata/meta) replace":here} to update your version of mvmeta"'
        }
        else di as error "vercheck: unknown error"
        exit _rc
    }
}

// DEAL WITH SUBSET
* recreate trtlistnoref to account for subsetting (if, in)
qui levelsof `design' `if' `in', local(trtlist) clean
local trtlist : list uniq trtlist
local trtlist : list sort trtlist
local ok : list ref in trtlist
if !`ok' & "`format'"=="augmented" {
    di as error "Reference treatment is not included in studies"
    exit 498
}
local trtlistnoref2 : list trtlist - ref
if "`trtlistnoref2'" != "`trtlistnoref'" {
    local losttrts : list trtlistnoref - trtlistnoref2
    di as text "Treatments not found in subset: " as result "`losttrts'"
    local trtlistnoref `trtlistnoref2'
}
if !mi("`luades'`luades2'") { // now finish parsing luades option
    if mi("`luades2'") local luades2 `trtlistnoref' 
    local sort1 : list sort luades2
    local sort2 : list sort trtlistnoref
    if "`sort1'"!="`sort2'" {
        di as error "luades() must contain all the non-reference treatments"
        exit 198
    }
}

if !mi("`MNAR'") di as error "Warning: data were computed under MNAR using options: " as error "`MNAR'"

// SET UP MODELS
marksample touse
if !mi("`model'") { 
    // `metavars' holds previous derived variables - need to be dropped
    cap drop `metavars'
    local metavars
    
    tempvar narms
    qui gen `narms' = wordcount(`design') if `touse'
    
    * FORM CONSISTENCY MODEL
    `ifdebugdi' "Forming consistency model"
    if mi("`bscovariance'") & mi("`fixed'") local bscovariance exch 0.5
	if !mi("`bscovariance'") local bscovariance bscovariance(`bscovariance')

    if "`format'"=="pairs" {
        qui summ `narms' 
        if r(max)>2 {
            if mi("`force'") | `warn' di as error "The data contain multi-arm trials - this analysis in pairs format is wrong"
            if mi("`force'") {
                di as error "(Use force option to override - at your own risk)"
                exit 498
            }
        }
        * define treatment difference covariates and equation `eq'
        tempvar trt1 trt2
        qui gen `trt1' = word(`contrast',3) if `touse'
        qui gen `trt2' = word(`contrast',1) if `touse'
        foreach trt in `trtlistnoref' {
        	qui gen `trtdiff'_`trt' = ("`trt'"==`trt2') - ("`trt'"==`trt1') if `touse'
        	local eq `eq' `trtdiff'_`trt'
            local metavars `metavars' `trtdiff'_`trt'
        }
        local command metareg `y' 
        local options `options' wsse(`stderr') noconstant
    }

    else if "`format'"=="augmented" {
        local command mvmeta `y' `S' `regress'
        local options `options' `i2' `bscovariance' longparm suppress(uv mm)
        local hideoptions network(`model')
    }

    else if "`format'"=="standard" {
        * define treatment difference covariates and equations `eq`r''
        tempvar thistrt base 
        qui gen `thistrt' = ""
        qui gen `base' = word(`design',1) if `touse'
        local maxdim = `maxarms'-1
        forvalues r=1/`maxdim' {
            qui replace `thistrt' = word(`design',`r'+1) if `touse'
            local eq`r'
            foreach trt in `trtlistnoref' {
                qui gen `trtdiff'`r'_`trt' = ("`trt'"==`thistrt') - ("`trt'"==`base') if `narms'>`r' & `touse'
                qui replace `trtdiff'`r'_`trt' = 0 if `narms'<=`r' & `touse'
                local eq`r' `eq`r'' `trtdiff'`r'_`trt'
                local metavars `metavars' `trtdiff'`r'_`trt'
            }
        }
        local command mvmeta `y' `S'
        local options `options' `i2' `bscovariance' commonparm noconstant suppress(uv mm)
        local hideoptions network(`model')
    } //  END OF FORMING CONSISTENCY MODEL


    * FORM INCONSISTENCY MODEL (IF REQUIRED)
    if "`model'"=="inconsistency" & mi("`luades2'") {
        `ifdebugdi' "Forming DBT inconsistency model"
        * design indicators
        qui levelsof `design' if `touse', local(desnames) // desnames: quoted and with spaces
        foreach des in `desnames' {
            local des2 = subinstr("`des'"," ","",.)
            qui gen des_`des2' = `design'==`"`des'"' if `touse'
            local metavars `metavars' des_`des2'
            local desnames2 `desnames2' `des2' // desnames2: unquoted and without spaces
        }
        local nd = wordcount(`"`desnames'"')
        
        * initialise and loop
*        foreach trt in `ref' `trtlistnoref' {
*        	local eq`trt'
*        }
        local i 0
        while !mi("`desnames2'") {
        	local ++i

            * find a first design which must contain `ref' 
            *   thisdesign: unquoted and with spaces
            *   thisdesign2: unquoted and without spaces
   	        if `i'==1 { 
                foreach des2 in `desnames2' {
                    qui count if strpos(" "+`design'+" "," `ref' ")>0 & des_`des2' & `touse'
                    if r(N) { // design `des2' contains trt `ref'
                        local thisdesign2 `des2'
                        continue, break
                    }
                }
            }
            else local thisdesign2 = word("`desnames2'",1)
        	local desnames2 : list desnames2 - thisdesign2
        	qui levelsof `design' if des_`thisdesign2' & `touse', local(thisdesign) clean
        `ifdebugdi' `"Looking at design "' as result `"`thisdesign'"'
        	if `i'==1 {
                local thisdesignnoref : list thisdesign - ref		
                local trtsused `ref' `thisdesignnoref'
        	}
            if `i'==1 continue
        	local overlap : list trtsused & thisdesign
        	local new : list thisdesign - trtsused 
        	local noverlap = wordcount("`overlap'") 
        	if mi("`overlap'") {
        		`ifdebugdi' "- warning: no overlap with " as result "`trtsused'" as text " (saving this design for later)"
        		local desnames2 `desnames2' `thisdesign2'
        		continue
        	}
        	forvalues o=2/`noverlap' {
        		foreach trt in `ref' `trtlistnoref' {
        			if "`trt'" != word("`overlap'",`o') continue
                    `ifdebugdi' `"- outcome "' as result `"`trt'"' as text `" contains potential inconsistency"'
        			if "`format'"=="augmented" {
                        local eq`trt' `eq`trt'' des_`thisdesign2'
                        local testcons `testcons' [`y'_`trt']des_`thisdesign2'
                    }
        			else if "`format'"=="standard" {
        				* interact `trtdiff'`r'_`trt' with des_`thisdesign2'
        				forvalues r=1/`dim' {
        					qui gen `trtdiff'`r'_`trt'_des_`thisdesign2' = (`trtdiff'`r'_`trt')*(des_`thisdesign2') if `touse'
        					local eq`r' `eq`r'' `trtdiff'`r'_`trt'_des_`thisdesign2'
                            if `r'==1 local testcons `testcons' [`y'_`r']`trtdiff'`r'_`trt'_des_`thisdesign2'
                            local metavars `metavars' `trtdiff'`r'_`trt'_des_`thisdesign2'
        				}
        			}
        			else if "`format'"=="pairs" {
        				* interact `trtdiff'_`trt' with des_`thisdesign2'
        				forvalues r=1/`dim' {
        					qui gen `trtdiff'_`trt'_des_`thisdesign2' = (`trtdiff'_`trt')*(des_`thisdesign2') if `touse'
        					local eq `eq' `trtdiff'_`trt'_des_`thisdesign2'
                            local testcons `testcons' `trtdiff'_`trt'_des_`thisdesign2'
                            local metavars `metavars' `trtdiff'_`trt'_des_`thisdesign2'
        				}
        			}
        		}
        	}
        	local trtsused : list trtsused | thisdesign
        	if `i'>`nd'^2 {
        		di as error "The network is disconnected"
        		local incomodel no
        		continue, break
        	}
        }
    }

    if "`model'"=="inconsistency" & !mi("`luades2'") {
        `ifdebugdi' "Forming Lu-Ades inconsistency model"
        /* Algorithm is:
        Use current treatment order.
        1. Flag reference treatment as identified, rest as identified
        2. For each treatment T1:
          a. Create variable flagging studies in group T1 (these are studies that contain T1 but aren't in any previous group)
          b. For each treatment T2 ordered after T1:
            i.   If no direct comparison then do nothing
            ii.  Else if T2 is unidentified then identify it
            iii. Else if founder of T2's group is unidentified then identify it
            iv.  Else if T1 is unidentified then identify it
            v.   Else create yT2:groupT1 as an inconsistency term
        */
        foreach trt in `ref' `luades2' { // Create "has" indicators
            tempvar has`trt'
            qui gen `has`trt'' = strpos(" "+`design'+" "," `trt' ")>0 if `touse'
            local ident`trt' = ("`trt'"=="`ref'") // Step 1
        }
        local trtstogo `ref' `luades2'
        tempvar groupfound
        gen `groupfound' = 0
        foreach trt in `ref' `luades2' { 
            local trtstogo : list trtstogo - trt
            * Step 2a
            qui gen group`trt' = `has`trt'' & !`groupfound'
            qui replace `groupfound' = 1 if group`trt'
            local metavars `metavars' group`trt'
            * Step 2b
            foreach trt2 of local trtstogo {
                qui count if `has`trt2'' & group`trt' & `touse'
                if !r(N) continue                        // case i
                if mi("`groupof`trt2''") local groupof`trt2' `trt' // flags which group trt2 first came in
                if `ident`trt2''==0 local ident`trt2' 1    // case ii
                else if `ident`groupof`trt2'''==0 local ident`groupof`trt2'' 1    // case iii
                else if !`ident`trt'' local ident`trt' 1 // case iv
                else {                                   // case v
                    local eq`trt2' `eq`trt2'' group`trt'
                    local testcons `testcons' [`y'_`trt2']group`trt'
                    `ifdebugdi' "Regressing `y'_`trt2' on group`trt'"
                }
            }
            * Keep track of "to go" treatments
            local trtsdone `"`trtsdone' `trt'"'
        }
        foreach trt in `ref' `luades2' { 
            if !`ident`trt'' di as error "Algorithm has failed - `trt' remains unidentified"
        }
    }
    

    // FINISH OFF META COMMAND
    if "`format'"!="pairs" { // default for mvmeta is nowt
        if !mi("`wt2'") local options `options' wt(`wt2')
        else if !mi("`wt'") local options `options' wt
    }
    if "`format'"=="augmented" {
    	foreach trt in `ref' `trtlistnoref' {
            if "`trt'"!="`ref'" local varsopt `varsopt' `y'_`trt'
    		if mi("`eq`trt''") continue
    		if !mi("`equation'") local equation `equation',
    		local equation `equation' `y'_`trt': `eq`trt''
    	}
        if !mi("`equation'") local equationopt eq(`equation')
        local fullcommand `command' `if' `in', `options' `equationopt' vars(`varsopt')
    }
    else if "`format'"=="standard" {
    	forvalues r=1/`dim' {
            local varsopt `varsopt' `y'_`r'
    		if mi("`eq`r''") continue
    		if !mi("`equation'") local equation `equation',
    		local equation `equation' `y'_`r': `eq`r''
    	}
        local fullcommand `command' `if' `in', `options' eq(`equation') vars(`varsopt')
    }
    else if "`format'"=="pairs" {
        local fullcommand `command' `eq' `if' `in', `options'
    }
    
}

else {
	if "`e(cmd)'"!="mvmeta" | !inlist("`e(network)'","consistency","inconsistency") {
    	di as error "network meta must be followed by c[onsistency] or i[nconsistency] unless a previous network meta model is available for replay"
    	exit 198
	}
    di as text "Using last-run `e(network)' model"
    local fullcommand mvmeta, `i2' `options'
}

// RUN META COMMAND
di as input `"Command is: `fullcommand'"'
`pause'
`fullcommand' `hideoptions'
global F9 `fullcommand'
local f9message `""mvmeta command stored as F9""'
if !mi("`model'") {
    *estimates store `model'
    *char _dta[network_`model'_estimates] `model'
    char _dta[network_metavars] `metavars'
}

// EXTRACT RESULTS FOR NETWORK FOREST
local forestproblem 0 // can send results to forest
if "`model'"=="consistency" & !mi("`reg'`equations'") local forestproblem 1
local mod = substr("`model'",1,4)
qui levelsof `design' if `touse', local(designs)
local ndes 0
tempname thisfitted fitted
foreach thisdes of local designs {
    local ++ndes
    local trtsleft : copy local thisdes
    foreach t1 in `thisdes' {
        local trtsleft : list trtsleft - t1
        foreach t2 in `trtsleft' {
            local lincom
            foreach trt in `thisdes' {
                if "`trt'"=="`ref'" continue
    			if "`format'"=="augmented" {
                    local mult1 = (("`t2'"=="`trt'") - ("`t1'"=="`trt'")) 
                    if `mult1'==0 continue
                    local r : list posof "`trt'" in trtlistnoref
                    foreach x in _cons `e(xvars_`r')' {
                        if "`x'"!="_cons" { // multiply by covariate value
                            summ `x' if `design'=="`thisdes'", meanonly
                            if r(max)>r(min) | r(N)==0 {
*                                di as error "Problem with covariate `x' in design `thisdes'"
                                local forestproblem 2
                            }
                            local mult = `mult1' * r(mean)
                        }
                        else local mult `mult1'
                        if !mi("`lincom'") local lincom `lincom' +
                        local lincom `lincom' (`mult')*[`y'_`trt']_b[`x']
                    }
                }
                else if "`format'"=="standard" { 
                    foreach term in `e(xvars_1)' {
                        local termtrt = substr("`term'", length("`trtdiff'1_")+1,length("`trt'")) 
                        local termtrt = substr("`term'", length("`trtdiff'1_")+1,.) // CORRECTION??
                        if "`termtrt'" != "`trt'" continue
    					local mult1 = (("`t2'"=="`termtrt'") - ("`t1'"=="`termtrt'")) 
                        local termdes = substr("`term'", length("`trtdiff'1_`trt'_")+1,.) 
                        if !mi("`termdes'") {
                            noi summ `termdes' if `design'=="`thisdes'", meanonly
                            if r(max)>r(min) | r(N)==0 {
*                                di as error "Problem with covariate `termdes' in design `thisdes'"
                                local forestproblem 2
                            }
                            local mult = `mult1' * r(mean)
                        }
                        else local mult `mult1'
                        if !mi("`lincom'") local lincom `lincom' +
                        local lincom `lincom' (`mult')*`term'
                    }
                }
                else if "`format'"=="pairs" {
                    local xvars : colnames e(b)
                    foreach term in `xvars' {
                        local termtrt = substr("`term'", length("`trtdiff'_")+1,length("`trt'")) 
                        if "`termtrt'" != "`trt'" continue
    					local mult1 = (("`t2'"=="`termtrt'") - ("`t1'"=="`termtrt'")) 
                        local termdes = substr("`term'", length("`trtdiff'_`trt'_")+1,.) 
                        if !mi("`termdes'") {
                            noi summ `termdes' if `design'=="`thisdes'", meanonly
                            if r(max)>r(min) | r(N)==0 {
*                                di as error "Problem with covariate `termdes' in design `thisdes'"
                                local forestproblem 2
                            }
                            local mult = `mult1' * r(mean)
                        }
                        else local mult `mult1'
                        if !mi("`lincom'") local lincom `lincom' +
                        local lincom `lincom' (`mult')*`term'
                    }
                }
            }
            `ifdebugdi' "design `thisdes', contrast `t2'-`t1': lincom is " as result "`lincom'"
            qui lincom `lincom'
            * find trt numbers
            local n 0
            foreach trt in `ref' `trtlistnoref' {
                local ++n
                if `"`t1'"'==`"`trt'"' local nt1 `n'
                if `"`t2'"'==`"`trt'"' local nt2 `n'
            }
            mat `thisfitted'=(`ndes',`nt1',`nt2',r(estimate),r(se))
            mat rownames `thisfitted' = `"`thisdes':`t2'-`t1'"'
            mat colnames `thisfitted' = "design" "t1" "t2" "b" "se"
            mat `fitted' = nullmat(`fitted') \ `thisfitted'
        }     
    }
}
if `forestproblem'==0 {
    if mi("`keepmat'") local keepmat _network_`model'
    matrix `keepmat' = `fitted' 
    char _dta[network_`model'_fitted] `keepmat'
}
else {
    if `warn' di as error "Results can't be used by network forest: " _c
    if `forestproblem'==1 & `warn' di as error "consistency model has covariates"
    if `forestproblem'==2 & `warn' di as error "inconsistency model has variation within designs"
    char _dta[network_`model'_fitted]
}

// RUN INCONSISTENCY TEST (must come last as r(chi2) might be used)
if "`model'"=="inconsistency" {
    di as text _new "Testing for inconsistency:" _c
    test `testcons'
    if "`format'" == "pairs" {
        char _dta[network_testcons_type] F
        char _dta[network_testcons_stat] `r(F)'
        char _dta[network_testcons_df] `r(df)',`r(df_r)'
    }
    else {
        char _dta[network_testcons_type] chi2
        char _dta[network_testcons_stat] `r(chi2)'
        char _dta[network_testcons_df] `r(df)'
    }
    char _dta[network_testcons_p] `r(p)'
    global F8 test `testcons'
    local f8message `""; test command stored as F8""'
}
di as text `f9message' `f8message'

end


/*======================= auxiliary program: vercheck =======================*/

program define vercheck, sclass
* 8may2015 - bug fix - handles missing values
* 11mar2015 - bug fix - didn't search beyond first line
version 9.2
local progname `1'
local vermin `2'
local not_fatal `3'
// If arg `not_fatal' is set to anything, program exits without an error.
if missing("`not_fatal'") local exitcode 498
tempname fh
qui findfile `progname'.ado // exits with error 601 if not found
local filename `r(fn)'
file open `fh' using `"`filename'"', read
local stop 0
while `stop'==0 {
	file read `fh' line
	if r(eof) continue, break
	tokenize `"`line'"'
	if "`1'" != "*!" continue
	while "`1'" != "" {
		mac shift
		if inlist("`1'","version","ver","v") {
			local vernum `2'
			local stop 1
			continue, break
		}
	}
	if "`vernum'"!="" continue, break
}
sreturn local version `vernum'
if "`vermin'" != "" {
	if "`vernum'"=="" local match nover
	else {
		local vermin2 = subinstr("`vermin'","."," ",.)
		local vernum2 = subinstr("`vernum'","."," ",.)
		local words = max(wordcount("`vermin2'"),wordcount("`vernum2'"))
		local match equal
		forvalues i=1/`words' {
			local wordmin = real(word("`vermin2'",`i'))
			local wordnum = real(word("`vernum2'",`i'))
            if `wordmin' == `wordnum' continue
			if `wordmin' > `wordnum' local match old
			if `wordmin' < `wordnum' local match new
			if mi(`wordmin') local match new
			else if mi(`wordnum') local match old
			continue, break
		}
	}
	if "`match'"=="old" {
		di as error `"`filename' is version `vernum' which is older than target `vermin'"'
		exit `exitcode'
	}
	if "`match'"=="nover" {
		di as error `"`filename' has no version number found"'
		exit `exitcode'
	}
	if "`match'"=="new" {
		di `"`filename' is version `vernum'"'
	}
}
else {
	if "`vernum'"!="" di as text `"`filename' is version `vernum'"'
	else di as text `"`filename' has no version number found"'
}
end

/*======================= end of vercheck =======================*/

