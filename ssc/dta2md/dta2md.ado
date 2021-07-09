// dta2md.ado
// Generate Meta Data from Stata system file
// Klaus Pforr
// 2019-10-10
// version 1.0.17
// CC BY-NC-SA 4.0
//
// Change log
// v2: 2019-02-28 no mata
// v3: 2019-02-28 streamlining of program structure draft
// v4: 2019-03-01 bugfixing in input control, solved abbreviation of group var
// v5: 2019-03-01 program structure draft clear
// v6: 2019-03-04 specification of output variable formats necessary for postfile, 
//                length of longest value label, first implementation steps of 
//                program draft
// v7: 2019-03-05 finishing implementation for "if v in freqvarlist"
// v8: 2019-03-05 restructuring program draft -> integrate distinction between
//                "if v in freqvarlist", "if v not in freqvarlist and nocount option specified",
//                "if v not in freqvarlist and nocount option not specified" in loop over variables and all levels
// v9: 2019-05-09 debugging
//                drop nocount option
// v10: 2019-05-13 debugging
//                 drop abbreviation of group var
// v11: 2019-05-14 revert to v10
//                 add mother
//                 debug input check problems
// v12: 2019-05-16 debug problems with relation
//                 debug firstVar: rename to first, and 1 for first level within groups
//                 debug: only list cases for which we have values
//                 debug group var: type at least str3
// v13: 2019-07-02 still problem with relation
//                    check relationship problems only if relation specified
//                 check: only list cases for which we have values?
//                 check: group var: type at least str3
//                 add progress report
// v14: 2019-07-08 debug unsolved problems with input control
//                 simplify code / remove redundancies between parts for freqvarlist vars and for non-freqvarlist vars
// v15: 2019-07-08 solve bug first variable for non-freqvarlist vars =1 for als group vars groups
// v16: 2019-08-13 bug with empty missing option
// v17: 2019-10-10 add check for continuous variables in freqvarlist, change version to 10.0
//
// Draft of program:
// loop over vars v
//   if v in freqvarlist
//     loop over all levels l of var v
//       post varName, variableLabel, total_n, total_missing, min, max, Mean, StandardDeviation for each level l for group "all",
//            value, valueLabel, n, percent, validPercent, isValid for each level l for group "all"
//       if first level l of var v 
//         post first in first level l for group "all"
//       if group var specfied
//         loop over levels of group var g
//           post varName, variableLabel, total_n, total_missing, min, max, Mean, StandardDeviation for each level l for group g
//           post value, valueLabel, n, percent, validPercent, isValid for each level l for group g
//   if v not in freqvarlist
//     post varName, variableLabel, total_n, total_missing, min, max, Mean, StandardDeviation once for group "all"
//     if group var specfied
//       loop over levels of group var g
//         post varName, variableLabel, total_n, total_missing, min, max, Mean, StandardDeviation once for group g

program define dta2md, nclass
  version 10.0
  syntax, OUTput(string) INput(string) [FREQVARlist(string) GRoup(string) REPLace MISSingdef(string) SMISSingdef(string) RELATion(string)]

  // preserve current status
  quietly preserve
  
  // Input control
  if `"`input'"'!="" {
    // Check input file option
    capture confirm file `"`input'"'
	if _rc!=0 {
	  noisily di as error `"input file `input' not found"'
	  quietly exit
	}

	if _rc==0 {
	  quietly use `"`input'"', clear
	  // Create list of variable over which loops runs
	  quietly ds
	  local varlist `r(varlist)'
	  local nvars : list sizeof varlist

	  // Check freqvarlist option
	  if `"`freqvarlist'"'!="" {
	    fvexpand `freqvarlist'
	    local freqvarlistexp `r(varlist)'
	    capture confirm variable `freqvarlistexp'
	    if _rc!=0 {
	      noisily di as error "One variable in freqvarlist cannot be interpreted as variable"
		  quietly exit
	    }
		quietly ds `freqvarlistexp'
		local contvars=0
		foreach var of varlist `r(varlist)' {
		   capture levelsof `var'
		   if _rc!=0 {
		     local contvars=`contvars'+1
			 noisily di as error "`var' has too many levels."
		   }
		}
		if `contvars'>0 {
		  noisily di as error "Drop",cond(`contvars'==1,"this variable","these variables"),"from the freqvarlist."
		  quietly exit
		}
	  }

	  // Check group option
	  if `"`group'"'!="" {
	    fvexpand `group'
		local groupexp `r(varlist)'
		if `:list sizeof groupexp'>1 {
		  noisily di as error `"Group variable `groupexp' specifies more than one variable"'
		  quietly exit
		}
	    capture confirm variable `groupexp'
		if _rc!=0 {
		  noisily di as error `"Group variable `groupexp' cannot be interpreted as variable"'
		  quietly exit
		}
	  }

	  // Check relationship option
	  if "`relation'"!="" {
	    tempvar test1 test2
	    quietly gen `test1'=""
		quietly gen byte `test2'=.
		local relationproblem=0
		quietly ds
		foreach var in `r(varlist)' {
		  quietly replace `test1'=cond(regexm("`var'",`"`relation'"')==0,"",regexr("`var'",`"`relation'"',""))
		  quietly replace `test2'=regexm(`test1',`"`relation'"')
		  quietly count if `test2'==1
		  if `r(N)'>1 {
			di as error "Multiple levels of child-mother relationship in variable `var' detected (child-mother-grandmother)"
			local relationproblem=1
		  }
		}
		if `relationproblem'==1 {
		  di as error "Current version supports only one level of child-mother relationship"
		  quietly exit
		}
		drop `test1' `test2'
	  }

	  // Check Missing definitions
	  if `"`missingdef'"'!="" {
	    if regexm(`"`missingdef'"',"X")==0 {
		    noisily di as error "Missing definition does not relate to any variable"
		    quietly exit
		}
	  }
	  if `"`missingdef'"'!="" {
        quietly ds, has(type numeric)
		foreach var in `r(varlist)' {
		  capture quietly count if (`=subinstr(`"`missingdef'"',"X","`var'",.)')==0|(`=subinstr(`"`missingdef'"',"X","`var'",.)')==1
		  if _rc!=0 | r(N)!=_N {
		    noisily di as error "Error in missing definition for variable `var'"
			quietly exit
		  }
		}
      }
	  if `"`smissingdef'"'!="" {
	    if regexm(`"`smissingdef'"',"X")==0 {
		  noisily di as error "String missing definition does not relate to any variable"
		  quietly exit
		}
	  }
	  if `"`smissingdef'"'!="" {
        quietly ds, has(type string)
		foreach var in `r(varlist)' {
		  capture quietly count if (`=subinstr(`"`smissingdef'"',"X","`var'",.)')==0|(`=subinstr(`"`smissingdef'"',"X","`var'",.)')==1
		  if _rc!=0 | r(N)!=_N {
		    noisily di as error "Error in string missing definition for variable `var'"
			quietly exit
		  }
		}
      }
	}
  }

  // Check output file
  if `"`output'"'=="" {
    noisily di as error "No output file specified"
	quietly exit
  }
  if `"`output'"'!="" {
    tempname outputcheck
    capture noisily file open `outputcheck' using `output', write binary `replace'
	if _rc!=0 {
	  quietly exit
	}
	capture file close _all
	if `"`replace'"'=="" {
	  noisily confirm new file `output'
	  if _rc!=0 {
	    noisily di as error "Output file exists"
		quietly exit
	  }
	}
  }

  // Process group variable
  if "`groupexp'"!="" {
    // - recast numerical to string
    if substr("`:type `groupexp''",1,3)!="str" {
      quietly tempvar groupexpstr
      // if numerical variable has value labels, use decode to replace with labels
      if (`"`:value label `groupexp''"'!="") {
        quietly decode `groupexp', gen(`groupexpstr')
      }
      // if numerical variable has no labels, use string to replace with actual values
      if (`"`:value label `groupexp''"'=="") {
        quietly gen `groupexpstr'=string(`groupexp',"`:format `groupexp''")
      }
    }
    // - produce uppercase string
    if substr("`:type `groupexp''",1,3)!="str" {
      quietly replace `groupexpstr'=ustrupper(`groupexpstr')
    }
    if substr("`:type `groupexp''",1,3)=="str" {
      quietly replace `groupexp'=ustrupper(`groupexp')
    }
  }

  // Open output file
  // Find out maximum length for value labels for type specification
  local valuelabellength=0
  foreach var in `varlist' {
    if (`"`:value label `var''"'!="") {
	  quietly levelsof `var'
	  foreach level in `r(levels)' {
	    local valuelabellength=max(`valuelabellength',strlen(`"`:label (`var') `level',strict'"'))
	  }
	}
  }
  // Find out groupvar type
  if "`groupexp'"=="" {
    local groupexptype="str3"
  }
  if "`groupexp'"!="" {
    if substr("`:type `groupexp''",1,3)!="str" {
      local groupexptype="`="str"+strofreal(max(3,real(substr("`groupexpstr'",4,.))))'"
    }
	if substr("`:type `groupexp''",1,3)=="str" {
      local groupexptype="`="str"+strofreal(max(3,real(substr("`groupexp'",4,.))))'"
	}
  }
  
  // Actual postfile
  tempname out
  quietly postfile `out' `groupexptype' group /*
    */ byte computed str32 varName str80 variableLabel float (total_n total_missing /*
    */ min max Mean StandardDeviation) str32 value str`valuelabellength' valueLabel /*
	*/ float (n percent validPercent isValid first) /*
    */ using `output', `replace'

  // Progress report: header first
  noisily _dots 0, title(Variables processed) reps(`nvars')

  // Loop over vars
  // Loop step counter
  local v=1
  foreach var in `varlist' {
    // Replace X with variable in missing option
	if `"`missingdef'"'!="" {
	  local _missingdef=subinstr(`"`missingdef'"',"X","`var'",.)
    }
    if `"`smissingdef'"'!="" {
	  local _smissingdef=subinstr(`"`smissingdef'"',"X","`var'",.)
    }
	// Set missing def to zero if not used
	if `"`missingdef'"'=="" {
	    local _missingdef=0
	}
	if `"`smissingdef'"'=="" {
	    local _smissingdef=0
	}

    // Compute variable level info for all that cannot be posted on the fly
	// -> total_n total_missing min max Mean StandardDeviation first
	// total_n
	local total_n=_N
	// total_missing
	if substr("`:type `var''",1,3)!="str" {
	  quietly count if (`_missingdef')==1
	}
	if substr("`:type `var''",1,3)=="str" {
	  quietly count if (`_smissingdef')==1
	}
	local total_missing=`r(N)'
	// min max Mean StandardDeviation
	if substr("`:type `var''",1,3)!="str" {
	  quietly sum `var' if (`_missingdef')==0
    }
	local min=r(min)
	local max=r(max)
	local Mean=r(mean)
	local StandardDeviation=r(sd)
	// first
	local first=1
	// Different parts if variable in freqvarlist or not
	if (`:list var in freqvarlistexp')==1 {
	  // loop over all levels of var
	  quietly levelsof `var', local(varlevels)
	  foreach vlevel in `varlevels' {
	    // Compute value level info that cannot be posted on the fly
		// -> value valueLabel n percent validPercent isValid
		// value
		if substr("`:type `var''",1,3)!="str" {
	      local value=`"`=string(`vlevel',"`:format `var''")'"'
		}
		if substr("`:type `var''",1,3)=="str" {
	      local value=`"`vlevel'"'
		}
	    // valueLabel
		if substr("`:type `var''",1,3)!="str" {
	      local valueLabel=`"`:label (`var') `vlevel',strict'"'
		}
		if substr("`:type `var''",1,3)=="str" {
		  local valueLabel=""
		}
		// n percent validPercent
		if substr("`:type `var''",1,3)!="str" {
		  quietly count if `var'==`vlevel'
		}
		if substr("`:type `var''",1,3)=="str" {
		  quietly count if `var'==`"`vlevel'"'
		}
		local n=r(N)
		local percent=`=`n''/`=`total_n''*100
		local validPercent=`=`n''/(`=`total_n''-`=`total_missing'')*100
		// isValid
		local isValid=.
		if substr("`:type `var''",1,3)!="str" {
		  quietly count if `var'==`vlevel' & (`_missingdef')==0
		}
		if substr("`:type `var''",1,3)=="str" {
		  quietly count if `var'==`"`vlevel'"' & (`_smissingdef')==0
		}
		if `r(N)'==`n' {
		  local isValid=1
		}
		if substr("`:type `var''",1,3)!="str" {
		  quietly count if `var'==`vlevel' & (`_missingdef')==1
		}
		if substr("`:type `var''",1,3)=="str" {
		  quietly count if `var'==`"`vlevel'"' & (`_smissingdef')==1
		}
		if `r(N)'==`n' {
		  local isValid=0
		}
    	// actual post of info for all values and group "all"
	    // post only if number of cases for this value >0
	    if `n'>0 & `n'!=. {
          quietly post `out' ("all") (`:list var in freqvarlistexp') (`"`var'"') (`"`:variable label `var''"') /*
		  */ (`total_n') (`total_missing') (`min') (`max') (`Mean') (`StandardDeviation') /*
		  */ (`"`value'"') (`"`valueLabel'"') /*
		  */ (`n') (`percent') (`validPercent') (`isValid') (`first')
		  local first=0
	    }
      }
	}
	if (`:list var in freqvarlistexp')==0 {
	  // Set value valueLabel n percent validPercent isValid to missing
	  local value=""
	  local valueLabel=""
	  local n=.
	  local percent=.
	  local validPercent=.
	  local isValid=.
	  // actual post of info overall and group "all" /*problem*/
	  quietly post `out' ("all") (`:list var in freqvarlistexp') ("`var'") (`"`:variable label `var''"') /*
      */ (`total_n') (`total_missing') (`min') (`max') (`Mean') (`StandardDeviation') /*
      */ (`"`value'"') (`"`valueLabel'"') /*
      */ (`n') (`percent') (`validPercent') (`isValid') (`first')
	  local first=0
	}
    // group var specified
	if `"`groupexp'"'!="" {
	  // loop over all levels of group var
	  if substr("`:type `groupexp''",1,3)!="str" { 
		quietly levelsof `groupexpstr', local(groupexplevels)
      }
	  if substr("`:type `groupexp''",1,3)=="str" { 
		quietly levelsof `groupexp', local(groupexplevels)
	  }
	  foreach glevel in `groupexplevels' {
		// Compute variable level info for each group var level that cannot be posted on the fly
	    // -> total_n total_missing min max Mean StandardDeviation first
	    // total_n
        if substr("`:type `groupexp''",1,3)!="str" { 
		  quietly count if `groupexpstr'==`"`glevel'"'
		}
		if substr("`:type `groupexp''",1,3)=="str" { 
		  quietly count if `groupexp'==`"`glevel'"'
		}
		local total_n=`r(N)'
		// total_missing
	    if substr("`:type `var''",1,3)!="str" {
		  if substr("`:type `groupexp''",1,3)!="str" { 
	        quietly count if (`_missingdef')==1 & `groupexpstr'==`"`glevel'"'
		  }
		  if substr("`:type `groupexp''",1,3)=="str" { 
			quietly count if (`_missingdef')==1 & `groupexp'==`"`glevel'"'
		  }
	    }
	    if substr("`:type `var''",1,3)=="str" {
		  if substr("`:type `groupexp''",1,3)!="str" { 
	        quietly count if (`_smissingdef')==1 & `groupexpstr'==`"`glevel'"'
		  }
		  if substr("`:type `groupexp''",1,3)=="str" { 
			quietly count if (`_smissingdef')==1 & `groupexp'==`"`glevel'"'
		  }
	    }
	    local total_missing=`r(N)'
		// min max Mean StandardDeviation
	    if substr("`:type `var''",1,3)!="str" {
		  if substr("`:type `groupexp''",1,3)!="str" { 
	        quietly sum `var' if (`_missingdef')==0 & `groupexpstr'==`"`glevel'"'
		  }
		  if substr("`:type `groupexp''",1,3)=="str" { 
			quietly sum `var' if (`_missingdef')==0 & `groupexp'==`"`glevel'"'
		  }
	    }
	    local min=r(min)
	    local max=r(max)
	    local Mean=r(mean)
	    local StandardDeviation=r(sd)
		// first
	    local first=1
		if (`:list var in freqvarlistexp')==1 {
		  // loop over all levels of var
	      quietly levelsof `var', local(varlevels)
	      foreach vlevel in `varlevels' {
		    // Compute value level info that cannot be posted on the fly
		    // -> value valueLabel n percent validPercent isValid
		    // value
			if substr("`:type `var''",1,3)!="str" {
	          local value=`"`=string(`vlevel',"`:format `var''")'"'
			}
			if substr("`:type `var''",1,3)=="str" {
	          local value=`"`vlevel'"'
			}
	        // valueLabel
			if substr("`:type `var''",1,3)!="str" {
	          local valueLabel=`"`:label (`var') `vlevel',strict'"'
			}
			if substr("`:type `var''",1,3)=="str" {
			  local valueLabel=""
			}
	        // n percent validPercent
	        if substr("`:type `var''",1,3)!="str" {
			  if substr("`:type `groupexp''",1,3)!="str" { 
	            quietly count if `var'==`vlevel' & `groupexpstr'==`"`glevel'"'
			  }
			  if substr("`:type `groupexp''",1,3)=="str" { 
	            quietly count if `var'==`vlevel' & `groupexp'==`"`glevel'"'
			  }
	        }
	        if substr("`:type `var''",1,3)=="str" {
			  if substr("`:type `groupexp''",1,3)!="str" { 
	            quietly count if `var'==`"`vlevel'"' & `groupexpstr'==`"`glevel'"'
			  }
			  if substr("`:type `groupexp''",1,3)=="str" { 
	            quietly count if `var'==`"`vlevel'"' & `groupexp'==`"`glevel'"'
			  }
	        }
			local n=r(N)
	        local percent=`=`n''/`=`total_n''*100
	        local validPercent=`=`n''/(`=`total_n''-`=`total_missing'')*100
	        // isValid
	        local isValid=.
			// Special case: valid case for all groups combined but no cases for this group -> isValid=1
			if substr("`:type `var''",1,3)!="str" {
	            quietly count if `var'==`vlevel' & (`_missingdef')==0
	        }
	        if substr("`:type `var''",1,3)=="str" {
	            quietly count if `var'==`"`vlevel'"' & (`_smissingdef')==0
	        }
			local one_valid_across_all_groups=`=(`r(N)'>0 & `r(N)'!=.)'
			// Count non-missings for this group
	        if substr("`:type `var''",1,3)!="str" {
			  if substr("`:type `groupexp''",1,3)!="str" { 
	            quietly count if `var'==`vlevel' & (`_missingdef')==0 & `groupexpstr'==`"`glevel'"'
			  }
			  if substr("`:type `groupexp''",1,3)=="str" { 
	            quietly count if `var'==`vlevel' & (`_missingdef')==0 & `groupexp'==`"`glevel'"'
			  }
	        }
	        if substr("`:type `var''",1,3)=="str" {
			  if substr("`:type `groupexp''",1,3)!="str" { 
	            quietly count if `var'==`"`vlevel'"' & (`_smissingdef')==0 & `groupexpstr'==`"`glevel'"'
			  }
			  if substr("`:type `groupexp''",1,3)=="str" { 
	            quietly count if `var'==`"`vlevel'"' & (`_smissingdef')==0 & `groupexp'==`"`glevel'"'
			  }
	        }
	        if (`one_valid_across_all_groups'==1 & `r(N)'==0) | (`one_valid_across_all_groups'==1 & `r(N)'>0 & `r(N)'==`n') {
	          local isValid=1
	        }
	        if substr("`:type `var''",1,3)!="str" {
			  if substr("`:type `groupexp''",1,3)!="str" { 
	            quietly count if `var'==`vlevel' & (`_missingdef')==1 & `groupexpstr'==`"`glevel'"'
			  }
			  if substr("`:type `groupexp''",1,3)=="str" { 
	            quietly count if `var'==`vlevel' & (`_missingdef')==1 & `groupexp'==`"`glevel'"'
			  }
	        }
	        if substr("`:type `var''",1,3)=="str" {
			  if substr("`:type `groupexp''",1,3)!="str" { 
	            quietly count if `var'==`"`vlevel'"' & (`_smissingdef')==1 & `groupexpstr'==`"`glevel'"'
			  }
			  if substr("`:type `groupexp''",1,3)=="str" { 
	            quietly count if `var'==`"`vlevel'"' & (`_smissingdef')==1 & `groupexp'==`"`glevel'"'
			  }
	        }
	        if `one_valid_across_all_groups'==0 | (`one_valid_across_all_groups'==1 & `r(N)'>0 & `r(N)'==`n') {
	          local isValid=0
	        }
		    // actual post of info for all values and all groups
			// post only if number of cases for this value >0
			if `n'>0 & `n'!=. {
	          quietly post `out' (`"`glevel'"') (`:list var in freqvarlistexp') ("`var'") (`"`:variable label `var''"') /*
		      */ (`total_n') (`total_missing') (`min') (`max') (`Mean') (`StandardDeviation') /*
		      */ (`"`value'"') (`"`valueLabel'"') /*
		      */ (`n') (`percent') (`validPercent') (`isValid') (`first')
			  local first=0
			}
		  }
		}
		if (`:list var in freqvarlistexp')==0 {
		  // Set value valueLabel n percent validPercent isValid to missing
		  local value=""
		  local valueLabel=""
		  local n=.
		  local percent=.
		  local validPercent=.
		  local isValid=.
		  // END if (`:list var in freqvarlistexp')==0 {
		  // actual post of info for all values and all groups
	      quietly post `out' ("`glevel'") ((`:list var in freqvarlistexp')) ("`var'") ("`:variable label `var''") /*
		    */ (`total_n') (`total_missing') (`min') (`max') (`Mean') (`StandardDeviation') /*
		    */ (`"`value'"') (`"`valueLabel'"') /*
		    */ (`n') (`percent') (`validPercent') (`isValid') (`first')
		  local first=0
		}
	  }
    }
    // End of one variable step -> Progress report -> Print dot
    noisily _dots `v' 0
    local v=`v'+1
  }

  // Close output file
  quietly postclose `out'
  
  // Add mother variable
  if `"`relation'"'!="" {
    quietly use `output', clear
	quietly gen mother=cond(regexm(varName,`"`relation'"')==0,"",regexr(varName,`"`relation'"',""))
	quietly order group computed varName mother
	quietly save `output', replace
  }
  
  // Restore previous data
  quietly restore
end
