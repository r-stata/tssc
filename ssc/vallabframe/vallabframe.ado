#delim ;
prog def vallabframe;
version 16.0;
/*
 Convert a list of value labels to variables in a new data frame.
*!Author: Roger Newson
*!Date: 18 November 2020
*/

syntax [ namelist ] ,  FRame(string asis)
  [ NAmevar(name) VAluevar(name) LAbelvar(name) ];
/*
 frame() specifies a Stata data frame in which to create the output dataset.
 namevar() specifies the name of the value label name variable.
 valuevar() specifies the name of the value variable.
 labelvar() specifies the name of the label variable.
*/

*
 Set default name list, make name list unique and ordered,
 and check that it is a list of label names
*;
if "`namelist'"=="" {;
  qui lab dir;
  local namelist "`r(names)'";
};
local namelist: list uniq namelist;
local namelist: list sort namelist;
qui lab list `namelist';

*
 Set default output variable names
*;
foreach X in name value label {;
  if "``X'var'"=="" {;
    local `X'var "`X'";
  };
};

*
 Parse frame() option if present
*;
if `"`frame'"'!="" {;
  cap frameoption `frame';
  if _rc {;
    disp as error `"Illegal frame option: `frame'"';
    error 498;
  };
  local framename "`r(namelist)'";
  local framereplace "`r(replace)'";
  local framechange "`r(change)'";
  if `"`framename'"'=="`c(frame)'" {;
    disp as error "frame() option may not specify current frame";
    error 498;
  };
  if "`framereplace'"=="" {;
    cap noi conf new frame `framename';
    if _rc {;
      error 498;
    };
  };
};

*
 Create temporary frame and name for additional frame
*;
local oldframe=c(frame);
tempname tempframe addframe;
frame create `tempframe';

*
 Populate temporary frame as append of additional frames
*;
tempname namescal valuescal labelscal;
foreach labname in `namelist' {;
  * Create frame to be appended *;
  qui lab list `labname';
  local N_values=r(k);
  frame create `addframe';
  qui frame `addframe' {;
    set obs `N_values';
    gene `namevar'="`labname'";
    gene double `valuevar'=.;
    gene strL `labelvar'="";
    lab var `namevar' "Name";
    lab var `valuevar' "Value";
    lab var `labelvar' "Label";
  };
  * Extract value labels to variables in frame to be added *;
  mata: extract_label_for_vallabframe("`oldframe'","`labname'",
    "`addframe'","`valuevar'","`labelvar'","`valuescal'","`labelscal'");
  * Compress and append frame to be appended *;
  qui frame `addframe': compress;    
  qui frame `tempframe': _appendframe `addframe', fast drop;
};
qui frame `tempframe': sort `namevar' `valuevar', stable;

*
 Rename temporary frame to frame name (if frame is specified)
 and change current frame to frame name (if requested)
*;
if "`framename'"!="" {;
  if "`framereplace'"=="replace" {;
    cap frame drop `framename';
  };
  frame rename `tempframe' `framename';
  if "`framechange'"!="" {;
    frame change `framename';
  };
};

end;

prog def frameoption, rclass;
version 16.0;
*
 Parse frame() option
*;

syntax name [, replace CHange ];

return local change "`change'";
return local replace "`replace'";
return local namelist "`namelist'";

end;

#delim cr

program define _appendframe
/*
 Append one or more frames to the current frame.
 This program uses code modified
 from Jeremy Freese's SSC package frameappend.
*/

	version 16.0

	syntax namelist(name=frame_list) [, drop fast]
	/*
	  drop specifies that the from frame will be dropped.
	  fast speciffies that no work will be done to preserve the to frame
	    if the user presses Brak or other failure occurs
	*/

	* Check that all frame names belong to frames *
	foreach frame_name in `frame_list' {
	  confirm frame `frame_name'
	}

	* Preserve old dataset if requested *
	if "`fast'"=="" {
		preserve
	}
	
	* Beginning of frame loop *
	foreach frame_name in `frame_list' {
	* Beginning of main quietly block *
	quietly {
	
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
	        
	        * Order variables (old ones first) *
	        order `to_varlist' `new_varlist'

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

#delim cr
version 16.0
/*
  Private Mata programs used by vallabframe
*/
mata:

void extract_label_for_vallabframe(string scalar oldframe,string scalar labname,
  string scalar addframe,string scalar valuevar,string scalar labelvar,
  string scalar valuescal, string scalar labelscal)
{
/*
  Extract label information from value label labname in frame oldframe
  and assign it to variables valuevar and labelvar in frame addframe,
  using scalars valuescal and labelscal as intermediary data stores,
  and return to frame oldframe.
*/
real vector valuevec
string vector labelvec
real scalar Nval, i1

/* Extract vectors from value label */
st_vlload(labname,valuevec,labelvec)

/* Go to additional frame to be created */
st_framecurrent(addframe)

/*
  Copy label name, values and labels into variables
  in additional frame to be created
*/
Nval=rows(valuevec)
for (i1=1;i1<=Nval;i1++) {
  st_numscalar(valuescal,valuevec[i1])
  st_strscalar(labelscal,labelvec[i1])
  stata("qui replace "+valuevar+"="+valuescal+" in "+strofreal(i1))
  stata("qui replace "+labelvar+"="+labelscal+" in "+strofreal(i1))
}

/* Return to old frame */
st_framecurrent(oldframe)

}

end
