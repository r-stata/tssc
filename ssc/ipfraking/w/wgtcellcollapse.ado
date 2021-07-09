*! v.0.3.74 wgtcellcollapse: collapsing weighting cells; Stas Kolenikov
program define wgtcellcollapse, rclass

	version 12
	
	* syntax namelist(name=task id="task" min=1 max=1) [if] [in], [*]*
	* marksample touse
	
	gettoken task rest : 0, parse(" ,")
	
	if "`task'" == "define" 		Define 					`rest'
	else if "`task'" == "collapse" 	Collapse_Cells 			`rest'
	else if "`task'" == "candidate" Find_Candidate_Rules	`rest'
	else if "`task'" == "report"	Report_Rules			`rest'
	else if "`task'" == "label" 	Label_Collapsed_Cells	`rest'
	else if "`task'" == "sequence" 	Seq_Define				`rest'
	else {
		di "{err}unrecognized task"
		exit (70198)
	}
	
	return add
	
end // of wgtcellcollapse

* spacer before Define
{
program define Define
	syntax, VARiables(varlist numeric min=1) [from(string) to(numlist min=1 max=1) max(real 0) clear label(str)]
	
	foreach x of varlist `variables' {
	
		local nrule : char `x'[nrules]
		
		if ("`clear'" != "") + ("`from'"!="" & "`to'" != "") != 1 {
			di "{err}in wgtcellcollapse define, either clear or both from()/to() options must be specified"
			exit (70103)
		}	
		
		if "`clear'" == "clear" {
			if "`nrule'" == "" {
				di "{txt}nothing to clear for {res}`x'"
				continue
			}
			
			* push empty chars
			forvalues k=1/`nrule' {
				char `x'[rule`k']
			}
			char `x'[nrules]
			char `x'[max]
			char `x'[factor]
		}
		else {		
			if "`nrule'" == "" {
				* no rules defined
				local nrule 0
			}
			
			local ++nrule
			
			* process the from string
			local fromcol = trim("`from'")
			local fromcol = subinstr("`fromcol'"," ",":",.)
			cap numlist "`from'", range( >=1 ) integer
			if _rc {
				di "{err}invalid specification of source cells in the collapsing rule definition: `from'"
				exit (70105)
			}
			
			* pass the rule
			char `x'[rule`nrule'] `fromcol'=`to'
			char `x'[nrules] `nrule'
			
			* label, if defined
			if "`label'" != "" & "`: value label `x''"!="" {
				lab define `: value label `x'' `to' `"`label'"', modify
			}
			
			* update the maximum
			if "`: char `x'[max]'" == "" char `x'[max] `to'
			else if `to' > `: char `x'[max]' char `x'[max] `to'
			if `max' > 0 & `max' > `: char `x'[max]' char `x'[max] `to'
			
			* update the padding factor
			local xfactor = 10^ceil( log10(`: char `x'[max]') )
			confirm number `xfactor'
			char `x'[factor] `xfactor'
		}
	}
	
end // of Define
}



* spacer before Seq_Define
{
program define Seq_Define

	syntax, VARiables(varlist numeric min=1) from(string) depth(real)
	
	cap assert `depth' >= 2
	if _rc {
		di "{err}depth must be a positive integer greater than 1"
		exit (70107)
	}
	
	local nlist : word count `from'

	foreach x of varlist `variables' {
	
		if "`: value label `x''" == "" {
			* desperate for labeling
			lab def `x'_lbl 0 "0"
			lab val `x' `x'_lbl
		}
	
		sum `x', mean
		local npad = floor(log10(r(max))+1)
		local pad = 10^`npad'
				
		forvalues l=2/`depth' {

			* starting point
			forvalues s=1/`nlist' {
				local e=`s'+`l'-1
				if `e' > `: word count `from'' continue
				
				local top : word `s' of `from'
				local btm : word `e' of `from'
				
				local ttop `top'
				forvalues k=1/`npad' {
					if `top' < `pad'/(10^`k') 	local ttop 0`ttop'
				}
				
				local bbtm `btm'
				forvalues k=1/`npad' {
					if `btm' < `pad'/(10^`k') 	local bbtm 0`bbtm'
				}
				
				* (v.a) main definition
				local fulist
				forvalues k=`s'/`e' {
					local fulist `fulist' `: word `k' of `from''
				}
				
				local fulistc : subinstr local fulist " " ":", all
				* di "{txt}Rules for segment {res}`l'`ttop'`bbtm'{txt}:"
				label define `: value label `x'' `l'`ttop'`bbtm' "`: label (`x') `top'' to `: label (`x') `btm''", modify
				
				
				
				Define, var(`x') from(`fulist') to(`l'`ttop'`bbtm')
				
				if `l' > 2 {
					* can split into segments plus station
					local l1 = `l' - 1
					
					* (v.b) northmost station + remaining segment
					local t2 : word `=`s'+1' of `from'
					
					local tt2 `t2'
					forvalues k=1/`npad' {
						if `t2' < `pad'/(10^`k') 	local tt2 0`tt2'
					}

					Define, var(`x') from(`top' `l1'`tt2'`bbtm') to(`l'`ttop'`bbtm')
					
					* (v.c) southmost station + remaining segment
					local b2 : word `=`e'-1' of `from'
					
					local bb2 `b2'
					forvalues k=1/`npad' {
						if `b2' < `pad'/(10^`k') 	local bb2 0`bb2'
					}
					
					Define , var(`x') from(`btm' `l1'`ttop'`bb2') to(`l'`ttop'`bbtm')
					
					if `l' > 3 {
						* can split into two segments
						
						* (v.d) middle split station
						forvalues m=`=`s'+1'/`=`e'-2' {
						
							local lm = `m' - `s' + 1
							local ln = `e' - `m'
							
		*					di "lm = `lm', ln = `ln'"
							
							assert `lm' >= 2
							assert `ln' >= 2
						
							* was `fulist', changed to `from'
							local med : word `m' of `from'
							local nxt : word `=`m'+1' of `from'
							
							local mmed `med'
							local nnxt `nxt'
							forvalues k=1/`npad' {
								if `med' < `pad'/(10^`k')  local mmed 0`mmed'
								if `nxt' < `pad'/(10^`k')  local nnxt 0`nnxt'
							}
							
							Define, var(`x') from(`lm'`ttop'`mmed' `ln'`nnxt'`bbtm') to(`l'`ttop'`bbtm')
							
							* (v.e) parse short segments
							if `lm'==2 {
								Define, var(`x') from(`top' `med' `ln'`nnxt'`bbtm') to(`l'`ttop'`bbtm')
							}
							if `lm'==3 {
							
								assert `m' == `s' + 2
								* was `fulist', changed to `from'
								local aa : word `=`s'+1' of `from'
								
								local aaa `aa'
								forvalues k=1/`npad' {
									if `aa' < `pad'/(10^`k') local aaa 0`aaa'
								}
								
								Define, var(`x') from(`top' `aa' `med' `ln'`nnxt'`bbtm') to(`l'`ttop'`bbtm')
								Define, var(`x') from(`top' 2`aaa'`mmed' `ln'`nnxt'`bbtm') to(`l'`ttop'`bbtm')
								Define, var(`x') from(2`ttop'`aaa' `med' `ln'`nnxt'`bbtm') to(`l'`ttop'`bbtm')
							}

							if `ln'==2 {
								Define, var(`x') from(`lm'`ttop'`mmed' `nxt' `btm') to(`l'`ttop'`bbtm')
							}
							if `ln'==3 {
							
								assert `e' == `m' + 3
								* was `fulist', changed to `from'
								local aa : word `=`e'-1' of `from'
								
								local aaa `aa'
								forvalues k=1/`npad' {
									if `aa' < `pad'/(10^`k') local aaa 0`aaa'
								}
								
								Define, var(`x') from(`lm'`ttop'`mmed' `nxt' `aa' `btm') to(`l'`ttop'`bbtm')
								Define, var(`x') from(`lm'`ttop'`mmed' 2`nnxt'`aaa' `btm') to(`l'`ttop'`bbtm')
								Define, var(`x') from(`lm'`ttop'`mmed' `nxt' 2`aaa'`bbtm') to(`l'`ttop'`bbtm')
							}
						}
					}
				}
			}
		}
	}
end // of Seq_Define
}


* spacer before Report_Rules
{
program define Report_Rules
	
	syntax , VARiables(varlist numeric min=1 max=1) [ break ]
	
	local x `variables'
	
	if "`: char `x'[rule1]'" == "" {
		if "`break'" != "" {
			di "{err}ERROR: no collapsing rules found for `x'"
			error (9)
		}
		else di "{err}WARNING: no collapsing rules found for `x'"
		exit
	}
	
	local k=1
	while "`: char `x'[rule`k']'" != "" {
	
		local thisrule : char `x'[rule`k']
		
		if !strpos("`thisrule'","=") | !strpos("`thisrule'",":") {
			if "`break'" != ""  di as err _n "ERROR: " _c
			else di as err _n "WARNING: " _c
			di as err "rule `k' does not appear to be appropriately specified:"
			di as err "   `thisrule'"
			if "`break'" != "" error (9)
		}
		
		di _n "{txt}Rule ({res}`k'{txt}): collapse together"
		tokenize `thisrule', parse(":=")
		di "  {res}`x'{txt} == {res}`1' {txt}({res}`: label (`x') `1''{txt})"
		macro shift
		while "`1'"!="=" {		
			if "`1'" != ":" {
				di "  {res}`x'{txt} == {res}`1' {txt}({res}`: label (`x') `1''{txt})"
			}
			macro shift
		}
		macro shift
		di "{txt}  into {res}`x'{txt} == {res}`1' {txt}({res}`: label (`x') `1''{txt})"
		if "`: label (`x') `1', strict'" == "" {
			if "`break'" != "" {
				di "  {err}ERROR: unlabeled value `x' == `1'"
				assert "`: label (`x') `1', strict'" != ""
			}
			else di "  {err}WARNING: unlabeled value `x' == `1'"
		}
	
		local ++k
	}
	
	if `: char `x'[nrules]' != `k' - 1 {
		if "`break'" != ""  di as err _n "ERROR: " _c
		else di as err _n "WARNING: " _c
		di "# of rules do not match for `x'"
		if "`break'" != "" error (9)
	}
	
	sum `x', mean
	if r(max) > `: char `x'[max]' {
		di _n "{err}ERROR: the observed maximum of `x' exceeds the expected max in metadata"
		error (9)
	}
	
	di
	
end // of Report_Rules
}


* spacer before Find_Candidate_Rules
{
program define Find_Candidate_Rules, sclass
	syntax, VARiable(varlist numeric min=1 max=1) CATegory(int) [LOGlevel(int 0) MAXcategory(real -1)]
	
	local x `variable'
	local cat `category'
	if `maxcategory' == -1 local maxcategory .
	
	sreturn clear
	sreturn local x `x'
	sreturn local cat `cat'
	if `loglevel' > 1 char li `x'[]
	
	* cycle through the rules
	forvalues k=1/`: char `x'[nrules]' {
		local thisrule : char `x'[rule`k']
		if `loglevel' > 1 di "  {txt}Rule ({res}`k'{txt}): looking for {res}`cat'{txt} in {res}`thisrule'{txt}"
		tokenize `thisrule', parse(":=")
		local themax 0
		local found 0
		while "`1'" != "=" {
			if "`1'" != ":" {
				if `1' > `themax' local themax `1'
			}
			if "`1'" == "`cat'" local found 1
			mac shift
		}
		if `found' & `themax' < `maxcategory' {
				local goodrule `goodrule' `k'
				sreturn local rule`k' `thisrule'
				if `loglevel' > 1 di "    {txt}Found it here!"
			}
		
	}
	
	sreturn local goodrule `goodrule'
	if `loglevel' > 0 {
		sreturn list
		di "Finished in Find_Candidate_Rules"
	}
end // of Find_Candidate_Rules
}


* spacer before Label_Collapsed_Cells
{
program define Label_Collapsed_Cells

	syntax , VARiable(varlist numeric min=1 max=1) [ VERBose FORCE ]
	
	local main `variable'
	
	local srclist : char `main'[sources]
	if "`srclist'" == "" {
		di "{err}variable `main' does not have the metadata to recover the labels"
		exit (111)
	}
	
	* are these variables still out there?
	cap d `srclist'
	if _rc {
		d `srclist'
	}
	
	* do these variables have collapsing rules attached to them?
	foreach x of varlist `srclist' {
		if "`: char `x'[nrules]'" == "" di "{err}WARNING: source variable `x' does not seem to have collapsing rules defined"
		if "`: char `x'[rule`: char `x'[nrules]']'" == "" di "{err}WARNING: source variable `x' does not seem to have collapsing rules defined"
		if "`: char `x'[factor]'" == "" di "{err}WARNING: source variable `x' does not seem to have collapsing rules defined"
	}
	
	
	* are these variables labeled?
	foreach x of varlist `srclist' {
		if "`: value label `x''" == "" di "{err}WARNING: source variable `x' is not labeled"
	}
	
	* reverse order the source list
	foreach x of varlist `srclist' {
		local revsrclist `x' `revsrclist'
	}
	
	* labeling work
	qui levelsof `main', local( maincats )
	foreach cat of local maincats {
		local maincat `cat'
		local catnumlab
		local cattxtlab
	
		* chop bites from the back
		foreach x of varlist `revsrclist' {
		
			if "`force'" == "force" {
				qui levelsof `x' if `main' == `cat', local( xcat )
				if "`catnumlab'" == "" local catnumlab `x'==`xcat'
				else local catnumlab `x'==`xcat', `catnumlab'
				
				foreach c of local xcat {
					if "`cattxtlab'" == "" local cattxtlab `"`: label (`x') `c''"'
					else local cattxtlab `"`: label (`x') `c''; `cattxtlab'"'					
				}
			}
			else {
				* relevant category of `x'
				local thiscat = mod( `maincat', `: char `x'[factor]' )
				
				* numeric labels
				if "`catnumlab'" == "" local catnumlab `x'==`thiscat'
				else local catnumlab `x'==`thiscat', `catnumlab'
				
				* text labels
				if "`cattxtlab'" == "" local cattxtlab `"`: label (`x') `thiscat''"'
				else local cattxtlab `"`: label (`x') `thiscat''; `cattxtlab'"'
			}
			* update the `maincat'
			local maincat = floor( `maincat' / `: char `x'[factor]' )
		}
		
		label define `main'_numlbl `cat' `"`catnumlab'"', modify
		label define `main'_txtlbl `cat' `"`cattxtlab'"', modify
	}
	
	label var `main' "Interactions of `srclist', with some collapsing"
	* check the existing languages
	if strpos("`: char _dta[_lang_list]'", "_ccells") == 0 {
		* no collapsed cell lanugages have been defined
		
		* start with copying the current labels, including no labels of interactions
		label language unlabeled_ccells, rename
		
		local newcopy new copy
		
	}
	
	* define the numeric labels language
	label language numbered_ccells, `newcopy'
	label values `main' `main'_numlbl
	
	if "`verbose'" != "" {
		tab `main'
		lab li `main'_numlbl
	}
	
	* defint the text labels language
	label language texted_ccells, `newcopy'
	label values `main' `main'_txtlbl

	if "`verbose'" != "" {
		tab `main'
		lab li `main'_txtlbl
	}
	
	
	* switch back to the "unlabeled_ccells" language
	label language unlabeled_ccells
	
	* instruct the user what to do
	di
	di `"{txt}To attach the numeric labels (of the kind "{res}`main'==`: word 1 of `maincats''"{txt}), type:"'
	di "   {stata label language numbered_ccells}"
	di `"{txt}To attach the text labels (of the kind "{res}`main'==`: label `main'_txtlbl `: word 1 of `maincats'''"{txt}), type:"'
	di "   {stata label language texted_ccells}"
	di `"{txt}The original state, which is also the current state, is:"'
	di "   {stata label language unlabeled_ccells}"
	di

end // of Label_Collapsed_Cells
}



* spacer before Collapse_Cells
{
program define Collapse_Cells, sortpreserve rclass
	version 12
	
	syntax [if] [in], VARiables(varlist numeric min=1)  MINcellsize(real) SAVing(str) ///
		[GENerate(name) feed(varlist numeric min=1 max=1) strict sort(varlist numeric) run ///
		replace append loglevel(real 0) maxpass(real 10000) clevel(numlist) MAXCATegory(real -1) ///
		ZERoes(numlist) greedy ]
	
	marksample touse
	
	* sorting rules
	if "`sort'`if'`in'" != "" {
		gsort -`touse' `sort' `_sortindex'
		tempvar longsortindex
		gen long `longsortindex' = _n
	}
	else local longsortindex `_sortindex'
	
	* collapsing levels
	if "`clevel'" == "" local clevel 1
	
	* drop out if the variable already exists
	if "`generate'" != "" {
		cap confirm variable `generate'
		if _rc == 0 {
			gen double `generate' = .
			format `generate' %12.0f
		}
	}
	
	* file to write to
	tempname towr
	file open `towr' using `saving', text write `replace' `append'
	file write `towr' "*** Automatically created on $S_DATE at $S_TIME" _n
	file write `towr' "* Source syntax: wgtcellcollapse collapse `0'" _n(2)
	
	* collapsing rules must be defined for each variable in the varlist
	foreach x of varlist `variables' {
		local nrule : char `x'[nrules]
		if "`nrule'" == "" {
			di "{err}ERROR: no collapsing rules found for `x'"
			char li `x'[]
			exit (70209)
		}
		if "`: char `x'[rule`nrule']'" == "" {
			di "{err}ERROR: collapsing rules are specified incorrectly for `x'"
			char li `x'[]
			exit (70210)
		}
		if "`: char `x'[factor]'" == "" {
			char `x'[factor] `= 10^ceil( log10(`: char `x'[max]') )'
		}
	}
	
	* create the generate string
	foreach x of varlist `variables' {
		if "`genstring'"!="" {
			local genstring (`genstring')*`: char `x'[factor]' + `x'
			local gmax = `gmax'*`: char `x'[factor]' + `: char `x'[max]'
		}
		else {
			local genstring `x'
			local gmax : char `x'[max]
		}
		local lastx `x'
		local lastfactor : char `x'[factor]
	}
	
	local prevx : list variables - lastx
	local prevx : word `: word count `prevx'' of `prevx'

	
	* initial version
	tempvar thiscount this
	
	if "`generate'" != "" {
		gen long `this' = `genstring'
		label variable `this' "Long ID of the interaction"
		file write `towr' `"generate long `generate' = `genstring'"' _n(2)
		file write `towr' `"label variable `generate' "Long ID of the interaction""' _n
		file write `towr' `"format `generate' %12.0f"' _n
		file write `towr' `"char `generate'[sources] `variables'"' _n
		file write `towr' `"char `generate'[max] `gmax'"' _n
		local pass 0
	}
	else if "`feed'" != "" {
		gen `this' = `feed'
		file write `towr' "confirm variable `feed'" _n(2)
		* the code uses `generate' elsewhere; redefine here with `feed'
		local generate `feed'
		* pick up the number of rules
		local pass : char `feed'[nrules]
	}
	else {
		di "{err}one of generate() or feed() must be specified"
		error 198
	}
	qui gen byte `thiscount' = .
	label variable `thiscount' "Cell count for the values of `this'"
	
	* change 02/26/2018: this needs to be changed here so that -zeroes- can pick this up
	qui replace `thiscount' = .i if `touse'==0
	
	local nrule = `pass'
	
	* process potential zeroes
	if "`zeroes'" != "" {
	
		UpdateCount `pass' `this' `longsortindex' `thiscount' .
		
		di _n "{txt}Processing zero cells..." _n
	
		tempvar prefix
		* everything up to the factor
		qui {
			gen long `prefix' = floor(`this'/`lastfactor')
			if `loglevel' > 0 table `touse' , c(count `prefix' min `prefix' max `prefix')
			levelsof `prefix' if `touse', local( allprefixes )
			foreach k of numlist `allprefixes' {
				foreach z of numlist `zeroes' {
					local thisval = `k'*`lastfactor' + `z'
					count if `this' == `thisval'
					if r(N) == 0 local zerolist `zerolist' `thisval'
				}
			}
		}
		if `loglevel' > 0 di "{txt}Zero cells: {res}`zerolist'"
		while "`zerolist'" != "" {
			local thisval : word 1 of `zerolist'
* di "{inp}Long value of the zero = `thisval'"
			local thislast = mod(`thisval', `lastfactor')
* di "{inp}Find_Candidate_Rules, var(`lastx') cat(`thislast') loglevel(`loglevel') max(`maxcategory')"
			Find_Candidate_Rules, var(`lastx') cat(`thislast') loglevel(`loglevel') max(`maxcategory')
* di "{inp}Some rules = `s(goodrule)'"
			if "`s(goodrule)'" == "" {
				di "{err}NOTE: no applicable collapsing rules were found for zero cell `lastx' == `thislast'"
			}
			FindBestRule , longvar(`this') longcat(`thisval') countvar(`thiscount') loglevel(`loglevel') `greedy'
			
* di "{inp}Best rule = `r(bestrule)'"
* di "{inp}Sources   = `r(sources)'"
			
			if "`r(bestrule)'" != "" {
				* check if there are any other alleged zeroes
				local sources `r(sources)'
				
				di "{txt}  Invoking rule {res}`r(bestrule)'{txt} to collapse zero cells"
			
				qui replace `this' = `r(newval)' if `r(inlist)'
				
				local towrite replace `this' = `r(newval)' if `r(inlist)'
				local towrite : subinstr local towrite "`this'" "`generate'", all
				file write `towr' "`towrite'" _n
				di "{res}  `towrite'"
				
				local ++nrule
				char `this'[rule`nrule'] `r(redefine)'
				
				local towrite char `this'[rule`nrule'] `r(redefine)'
				local towrite : subinstr local towrite "`this'" "`generate'", all
				file write `towr' "`towrite'" _n
				
				local zerolist : list zerolist - sources
				
				UpdateCount `pass' `this' `longsortindex' `thiscount' .
			}
			else {
				di "{err}  WARNING: could not find any rules to collapse zero cell `generate' == `thisval'"
				local thiszero : word 1 of `zerolist'
				local zerolist : list zerolist - thiszero
			}
		}
		
* di "{inp}When done processing zeroes, we have this:"
* tab `this'		
		
	}
	
	local pass `nrule'
	
	qui replace `thiscount' = .i if `touse'==0
	
	UpdateCount `pass' `this' `longsortindex' `thiscount' `mincellsize'
	
	while !r(done) & `pass' <= `maxpass' {
		local ++pass
		if `loglevel' > 0 li `this' `thiscount' `prevx' `lastx' in 1
	
		* determine the category of the last two variable
		local thislast = mod(`this'[1],`lastfactor')
		local thisprev = mod( floor(`this'[1]/`lastfactor'), `: char `prevx'[factor]')
		
		if "`clevel'" == "1" {
			* return a bunch of rules in s()
			Find_Candidate_Rules, var(`lastx') cat(`thislast') loglevel(`loglevel') max(`maxcategory')
			if "`s(goodrule)'" == "" {
				di "{err}NOTE: no applicable collapsing rules were found for `lastx' == `thislast'"
				local failed `failed' `=`this'[1]'
				if `loglevel'>1 char li `lastx'[]
				Find_Candidate_Rules, var(`prevx') cat(`thisprev') loglevel(`loglevel') max(`maxcategory')
				if `loglevel'> 0 sreturn list
				file write `towr' _n "* skipping `generate' == `=`this'[1]'; " _n
				file write `towr' "* no good collapsing rule found for `lastx' == `thislast'" _n
				if "`s(goodrule)'" != "" {
					file write `towr' "* however rule(s) `s(goodrule)' may be used for `prevx'" _n
				}
				file write `towr' _n
				qui replace `thiscount' = .i if `this' == `=`this'[1]'
				sreturn clear
				UpdateCount `pass' `this' `longsortindex' `thiscount' `mincellsize'
				continue
			}
			
			* picks the rules in s() and finds the one with the smallest count
			FindBestRule , longvar(`this') longcat(`=`this'[1]') countvar(`thiscount') loglevel(`loglevel') `strict' `greedy'
			
			if "`r(bestrule)'" != "" {
			
				di "{txt}  Invoking rule {res}`r(bestrule)'"
			
				qui replace `this' = `r(newval)' if `r(inlist)'
				
				local towrite replace `this' = `r(newval)' if `r(inlist)'
				local towrite : subinstr local towrite "`this'" "`generate'", all
				file write `towr' "`towrite'" _n
				di "  `towrite'"
				
				local ++nrule
				char `this'[rule`nrule'] `r(redefine)'
				
				local towrite char `this'[rule`nrule'] `r(redefine)'
				local towrite : subinstr local towrite "`this'" "`generate'", all
				file write `towr' "`towrite'" _n
			}
			else {
				* could not find anything meaningful
				di "{err}  WARNING: could not find any rules to collapse `generate' == `=`this'[1]'"
				local failed `failed' `=`this'[1]'
				if `loglevel'>1 char li `lastx'[]
				local thisprev = mod( floor(`this'[1]/`lastfactor'), `: char `prevx'[factor]')
				Find_Candidate_Rules, var(`prevx') cat(`thisprev') loglevel(`loglevel') max(`maxcategory')
				if `loglevel' > 0 sreturn list
				file write `towr' _n "* skipping `generate' == `=`this'[1]'; " _n
				file write `towr' "* no good collapsing rule found for `lastx' == `thislast'" _n
				if "`s(goodrule)'" != "" {
					file write `towr' "* however rule(s) `s(goodrule)' may be used for `prevx'" _n
				}
				file write `towr' _n
				qui replace `thiscount' = .i if `this' == `=`this'[1]'
				local failed `failed' `=`this'[1]'
				sreturn clear
			}
		}
		else if "`clevel'" == "2" {
			Find_Candidate_Rules, var(`prevx') cat(`thisprev') loglevel(`loglevel') max(`maxcategory')
			if "`s(goodrule)'" == "" {
				di "{err}NOTE: no applicable collapsing rules were found for `prevx' == `thisprev'; skipping"
				if `loglevel'>1 char li `lastx'[]
				file write `towr' _n "* skipping `generate' == `=`this'[1]'; " _n
				file write `towr' "* no good collapsing rule found for `prevx' == `thisprev'" _n
				qui replace `thiscount' = .i if `this' == `=`this'[1]'
				local failed `failed' `=`this'[1]'
				UpdateCount `pass' `this' `longsortindex' `thiscount' `mincellsize'
				continue
			}
			
			* picks the rules in s() and finds the one with the smallest count
			FindBestRule2 , longvar(`this') longcat(`=`this'[1]') factor(`lastfactor') countvar(`thiscount') loglevel(`loglevel') `strict'
			
			if "`r(bestrule)'" != "" {
				di "{txt}  Invoking rule {res}`r(bestrule)'"
			
				qui replace `this' = `r(newval)' if `r(inlist)'
				
				local towrite replace `this' = `r(newval)' if `r(inlist)'
				local towrite : subinstr local towrite "`this'" "`generate'", all
				file write `towr' "`towrite'" _n
				di "  `towrite'"
				
				local ++nrule
				char `this'[rule`nrule'] `r(redefine)'
				
				local towrite char `this'[rule`nrule'] `r(redefine)'
				local towrite : subinstr local towrite "`this'" "`generate'", all
				file write `towr' "`towrite'" _n
			}
			else {
				* could not find anything meaningful
				di "{err}  WARNING: could not find any rules to collapse `generate' == `=`this'[1]'"
				if `loglevel'>1 char li `lastx'[]
				file write `towr' _n "* skipping `generate' == `=`this'[1]'; " _n
				file write `towr' "* no good collapsing rule found for `prevx' == `thisprev'" _n
				qui replace `thiscount' = .i if `this' == `=`this'[1]'
				local failed `failed' `=`this'[1]'
			}
		}
		else if "`clevel'" == "1 2" {
			* try level 1, and if it fails, try level 2 immediately
		}
	
		if `loglevel' > 0 di "{txt}{hline}"
		UpdateCount `pass' `this' `longsortindex' `thiscount' `mincellsize'
	}

	* # of rules used
	char `this'[nrules] `nrule'
	
	local towrite char `this'[nrules] `nrule'
	local towrite : subinstr local towrite "`this'" "`generate'", all
	file write `towr' _n "`towrite'" _n

	* close and exit
	file write `towr' _n
	file close `towr'
	
	if "`run'" != "" & `loglevel'>0 {
		di _n(2) `"{txt}The do-file {res}`saving'{txt} reads:"' _n(2)
		type `saving'
	}
	
	* re-create by doing the file
	if "`feed'" != "" & "`append'" != "" {
		* the variable probably exists
		* and the do-file probably defines it
		cap drop `generate'
	}
	if "`run'" == "run" run `saving'
	else do `saving'

	sort `thiscount' `longsortindex'
	return scalar min = `thiscount'[1]
	return scalar arg_min_id = `generate'[1]
	
	local failed : list uniq failed
	local cfailed : subinstr local failed " " ",", all
	return local failed `failed'
	return local cfailed `cfailed'
	
end // of Collapse_Cells
}

* spacer before UpdateCount
{
program define UpdateCount, rclass
	args pass this sort thiscount mincellsize
	
	di "{txt}Pass {res}`pass'{txt} through the data..."
	
	qui bysort `this' (`sort') : replace `thiscount' = _N if `thiscount' != .i

	sort `thiscount' `this' `sort'
	local min = `thiscount'[1]
	return scalar min = `min'
	
	di "{txt}  smallest count = {res}`=`thiscount'[1]'{txt} in the cell {res}" %12.0f `=`this'[1]'
	
	if `min' < `mincellsize' {
		// di "{txt}  need to conitnue collapsing"
	}
	else di "{txt}  Done collapsing! Exiting..."
	
	return scalar done = ( `min' >= `mincellsize' )
	
end // of UpdateCount
}


* spacer before FindBestRule
{
program define FindBestRule, rclass
	syntax , longvar( varname numeric ) longcat( real ) countvar( varname numeric ) loglevel(real) [ strict zero greedy ]
	
	* we are given the value of the interaction variable and the category
	* the category will be of the form `higher_categories'0`category_to_collapse'
	* so we might need to cycle over the allowed collapses to determine the least intrusive
	
	if `loglevel' == 0 {
		local qui quietly
		local mean mean
	}
	
	local x `s(x)'
	local cat `s(cat)'
	local basecat = `longcat' - `cat'
	if `loglevel' > 0 di "{txt}  Base category = {res}`basecat'{txt}; c.f. target small category {res}`longcat'{txt}"
	
	if `basecat' == 0 di "{err}  Warning: base category = 0 in {inp}FindBestRule `0'"

	if "`zero'" != "" {
		`qui' sum `countvar' if `longvar' == `longcat'
		if r(N) > 0 {
			cap assert r(min) == r(max) & r(min) == r(N)
			if _rc {
				di "{err}ERROR: FindBestRule found inconsistencies in the data"
				noi sum `countvar' if `longvar' == `longcat'
				return local bestrule
				exit
			}
		}
		else {
			* something strange happened
			return
		}
		local basecount = r(min)
	}
	else local basecount = 0
	
	* this should end on a bunch of zeroes
	local bestcount .
	local bestcats 0
	
	foreach k of numlist `s(goodrule)' {
		* pick the rule
		local thisrule : char `x'[rule`k']
		if `loglevel' > 0 di "{txt}Checking rule ({res}`k'{txt}): {res}`thisrule'{txt}"
		
		* get the part before the equals sign
		tokenize `thisrule', parse("=")
		* replace the semicolons with spaces
		local thesecats : subinstr local 1 ":" " ", all
		* take out the category to be replaced
		local thesecats : list thesecats - cat
		* convert to inlist-able format
		local inlistcats = subinstr(trim("`thesecats'"), " ", ",", .)
		
		local thiscount 0
		foreach c of local thesecats {
			if `loglevel' > 0 di "{txt}  Attempting {res}`longvar'{txt} == {res}" `basecat' + `c'
			
			qui count if (`longvar' == `basecat' + `c') & (`countvar'==.i)
			if r(N) > 0 {
				* this category overlaps with the if/in conditions, better skip
				if `loglevel' > 0 {
					di "{txt}  Found {res}`=r(N)'{txt} cases out of scope:"
					format `longvar' %15.0f
					tab `x' `longvar' if (`longvar' == `basecat' + `c'), mi
				}
				local thiscount -1
				continue, break
			}
			
			sum `countvar' if (`longvar' == `basecat' + `c'), `mean'
			if r(N) > 0 {
				* expect `countvar' to not vary within `basecat' + `c', and to be equal to the # of cases
				cap assert r(min) == r(max) & r(min) == r(N)
				if _rc {
					di "{err}ERROR: FindBestRule found something odd in the data"
					di "  while processing `longvar' == `longcat' and attempting `longvar' == `=`basecat' + `c''"
					di "  (was expecting the countvar `countvar' to not vary within the cell, and == no. of obs)"
					noi sum `countvar' if `longvar' == `basecat' + `c'
					list `x' `longvar' `countvar' if `longvar' == `basecat' + `c'
					return local bestrule
					exit
				}
				local thiscount = `thiscount' + r(min)
			}
			else {
				if "`strict'" == "strict" {
					* nothing in this category, rule not applicable
					local thiscount -1
					continue, break
				}
			}
		}
		if `thiscount' == -1 {
			* the rule was not applicable, quit
			continue
		}
		else {
			* compare the result with the best so far
			if `loglevel' > 0 di "{txt}Rule ({res}`k'{txt}) produced the additional count of {res}`thiscount'{txt}"
			if (`thiscount' < `bestcount' & `thiscount' > 0) {
				local best `k'
				local bestcount `thiscount'
				local bestcats : word count `thesecats'
			}
			else if ("`greedy'"!="") & (`thiscount' == `bestcount' & `thiscount' > 0 & `: word count `thesecats'' > `bestcats') {
				local best `k'
				local bestcount `thiscount'
				local bestcats : word count `thesecats'			
			}
		}
	}
	
	if "`best'" == "" {
		return local bestrule
		exit
	}
	
	return local bestindex rule`best'
	return local bestrule `s(rule`best')'

	* review the best rule
	tokenize `s(rule`best')', parse(":=")
	local inlist inlist(`longvar'
	while "`1'" != "=" {
		if "`1'" != ":" {
			local inlist `inlist', `=`basecat'+`1''
			if "`redefine'" != "" {
				local redefine `redefine':`=`basecat'+`1''
				local sources `sources' `=`basecat'+`1''
			}
			else {
				local redefine `=`basecat'+`1''
				local sources `redefine'
			}
		}
		mac shift
	}
	local inlist `inlist')
	mac shift
	local newval `=`basecat'+`1''
	local redefine `redefine'=`=`basecat'+`1''
	return local redefine `redefine'
	
	return local inlist `inlist'
	return local newval `newval'
	return local sources `sources'
	
	if `loglevel' > 0 {
		di "{txt}Finished in FindBestRule: the best index is {res}`best'{txt}, meaning the rule {res}`return(bestrule)'"
		di "{txt}Proposed code: {inp}replace `longvar' = `newval' if `inlist'{txt}"
	}

end // of FindBestRule
}

* spacer before FindBestRule2

{
program define FindBestRule2, rclass
	syntax , longvar( varname numeric ) longcat( real ) factor(real) countvar( varname numeric ) loglevel(real) [ strict ]
	
	* we are given the value of the interaction variable and the category
	* the category will be of the form ``category_to_collapse'0`lower_category'
	* so we might need to cycle over the allowed collapses to determine the least intrusive
	
	if `loglevel' == 0 {
		local qui quietly
		local mean mean
	}
	
	local x `s(x)'
	local cat `s(cat)' * `factor'
	local basecat = `longcat' - `cat'
	if `loglevel' > 0 di "{txt}  Base category = {res}`basecat'{txt}; c.f. target small category {res}`longcat'{txt}"

	`qui' sum `countvar' if `longvar' == `longcat'
	if r(N) > 0 {
		cap assert r(min) == r(max) & r(min) == r(N)
		if _rc {
			di "{err}ERROR: FindBestRule2 found inconsistencies in the data"
			noi sum `countvar' if `longvar' == `longcat'
			return local bestrule
			exit
		}
	}
	else {
		* something strange happened
		return
	}
	local basecount = r(min)
	
	* this should end on a bunch of zeroes
	local bestcount .
	
	foreach k of numlist `s(goodrule)' {
		* pick the rule
		local thisrule : char `x'[rule`k']
		if `loglevel' > 0 di "{txt}Checking rule ({res}`k'{txt}): {res}`thisrule'{txt}"
		
		* get the part before the equals sign
		tokenize `thisrule', parse("=")
		* replace the semicolons with spaces
		local thesecats : subinstr local 1 ":" " ", all
		* take out the category to be replaced
		local thesecats : list thesecats - cat
		* convert to inlist-able format
		local inlistcats = subinstr(trim("`thesecats'"), " ", ",", .)
		
		local thiscount 0
		foreach c of local thesecats {
			if `loglevel' > 0 di "{txt}  Attempting {res}`longvar'{txt} == {res}" `basecat' + `c'*`factor'
			`qui' sum `countvar' if `longvar' == `basecat' + `c'*`factor'
			if r(N) > 0 {
				cap assert r(min) == r(max) & r(min) == r(N)
				if _rc {
					di "{err}ERROR: FindBestRule2 found something odd in the data"
					noi sum `countvar' if `longvar' == `longcat'
					return local bestrule
					exit
				}
				local thiscount = `thiscount' + r(min)
			}
			else {
				if "`strict'" == "strict" {
					* nothing in this category, rule not applicable
					local thiscount -1
					continue, break
				}
			}
		}
		if `thiscount' == -1 {
			* the rule was not applicable, quit
			continue
		}
		else {
			* compare the result with the best so far
			if `loglevel' > 0 di "{txt}Rule ({res}`k'{txt}) produced the additional count of {res}`thiscount'{txt}"
			if `thiscount' < `bestcount' & `thiscount' > 0 {
				local best `k'
				local bestcount `thiscount'
			}
		}
	}
	
	if "`best'" == "" {
		return local bestrule
		exit
	}
	
	return local bestindex rule`best'
	return local bestrule `s(rule`best')'

	* review the best rule
	tokenize `s(rule`best')', parse(":=")
	local inlist inlist(`longvar'
	while "`1'" != "=" {
		if "`1'" != ":" {
			local inlist `inlist', `=`basecat'+`1'*`factor''
			if "`redefine'" != "" local redefine `redefine':`=`basecat'+`1'*`factor''
			else local redefine `=`basecat'+`1'*`factor''
		}
		mac shift
	}
	local inlist `inlist')
	mac shift
	local newval `=`basecat'+`1'*`factor''
	local redefine `redefine'=`=`basecat'+`1'*`factor''
	return local redefine `redefine'
	
	return local inlist `inlist'
	return local newval `newval'
	
	if `loglevel' > 0 {
		di "{txt}Finished in FindBestRule2: the best index is {res}`best'{txt}, meaning the rule {res}`return(bestrule)'"
		di "{txt}Proposed code: {inp}replace `longvar' = `newval' if `inlist'{txt}"
	}

end // of FindBestRule2
}

* last spacer

exit

v.0.1	02/12/2016	converted from LIRR_Collapse_Cells
v.0.2	08/22/2017	bugs found in Seq_Define (`fulist' was used where `from' was needed)
					syntax of Collapse_Cells was changed to use -var()- option rather than input varlist
v.0.3   10/26/2017  -strict- option of searching for label text was added in Report_Rules
0.3.62  Version numbers are aligned with -ipfraking-, -ipfraking_report-, -wgtcellcollapse-
0.3.63	02/26/2018	`thiscount' is changed to .i before processing -zeroes- (so that it could respect -if- conditions better)
0.3.74  04/29/2018  version numbers are aligned
