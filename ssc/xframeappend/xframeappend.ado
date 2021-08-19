program define xframeappend
/*
*!Author: Roger Newson
*!Date: 15 March 2021 
*/

	version 16.0

	syntax namelist(name=frame_list) [, drop Generate(name) fast]
	/*
	  drop specifies that the from frame will be dropped.
	  generate() specifies the name of a new variable to be generated,
	    with values 0 for observations from the current frame
	    and k for observations from the kth appended frame.
	  fast speciffies that no work will be done to preserve the to frame
	    if the user presses Break or other failure occurs
	*/

	* Check that all frame names belong to frames *
	foreach frame_name in `frame_list' {
	  confirm frame `frame_name'
	}

        * Check that generate variable does not exist in any input frame *
        if "`generate'"!="" {
          cap conf new var `generate'
          if _rc {
            disp as error "variable `generate' already defined in current frame `c(frame)'"
            error 110
          }
          foreach frame_name in `frame_list' {
            frame `frame_name': cap conf new var `generate'
            if _rc {
              disp as error "variable `generate' already defined in frame `frame_name''"
              error 110
            }
          }
        }

	* Preserve old dataset if requested *
	if "`fast'"=="" {
		preserve
	}
	
	* Create generate() variable if requested *
	if "`generate'"!="" {
	  qui gene byte `generate'=0
	}
	
	* Beginning of frame loop *
	local frameseq=0
	foreach frame_name in `frame_list' {
	* Beginning of main quietly block *
	quietly {
	
	        * Set frame sequence number *
	        local frameseq=`frameseq'+1
	
		* Get varlists from old dataset *
		ds
		local to_varlist "`r(varlist)'"
		* Get varlists from dataset to be appended *
		frame `frame_name': ds
		local from_varlist "`r(varlist)'"
		local shared_varlist : list from_varlist & to_varlist
		local new_varlist : list from_varlist - shared_varlist

		* Check modes of shared variables (numeric or string) *
		if "`shared_varlist'" != "" {
			foreach type in numeric string {
				ds `shared_varlist', has(type `type')
				local `type'_to "`r(varlist)'"
				frame `frame_name': ds `shared_varlist', has(type `type')
				local `type'_from "`r(varlist)'"
				local `type'_eq: list `type'_to === `type'_from
			}
			if (`numeric_eq' == 0) | (`string_eq' == 0) {
				di as err "shared variables in frames being combined must be both numeric or both string"
				error 109
			}
		}
		
		* get size of new dataframe *
		frame `frame_name' : local from_N = _N
		local to_N = _N
		local from_start = `to_N' + 1
		local new_N = `to_N' + `from_N'

		* Create variables for linkage in the 2 datasets *
		set obs `new_N'
		tempvar temp_n temp_link
		gen double `temp_n' = _n
		frame `frame_name' {
			gen double `temp_n' = _n + `to_N'
		}
	
		* Create linkage between the 2 datasets *
		frlink 1:1 `temp_n', frame(`frame_name') gen(`temp_link')
		
		* Import shared variables to old dataset *
		if "`shared_varlist'"!="" {
		  tempvar temphome
		  foreach X of varlist `shared_varlist' {
		    frget `temphome'=`X', from(`temp_link')
		    replace `X'=`temphome' in `=`to_N'+1' / `new_N'
		    drop `temphome'
		  }
		}
	
		* Import new variables to old dataset *
		if "`new_varlist'" != "" {
		  tempvar temphome2
		  foreach X in `new_varlist' {
		    frget `X'=`X', from(`temp_link')
		  }
	        }
	        
	        * Update generate variable if necessary *
	        if "`generate'"!="" {
	          qui replace `generate'=`frameseq' if _n>`to_N'
	        }
	        
	        * Order variables (old ones first) *
	        local oldto_varlist: list to_varlist - generate
	        order `oldto_varlist' `new_varlist' `generate'

	}
        * End of main quietly block *
        }
        * End of frame loop *

        * Restore old dataset if requested and necessary *
	if "`fast'"=="" {
        	restore, not
	}

	* Drop appended frame if requested *
	if "`drop'" == "drop" {
		foreach frame_name in `frame_list' {
			frame drop `frame_name'
		}
	}
		
end
