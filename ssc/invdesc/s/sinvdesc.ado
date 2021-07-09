#delim ;
prog def sinvdesc;
version 16.0;
/*
 Use invdesc to reset variable attributes in dataset in the current frame
 using descriptives from the current frame.
 using attriibutes from a describe or descsave resultsset
*! Author: Roger Newson
*! Date: 10 May 2020
*/

syntax [ , NAme(name)  ISnumeric(name) * ];
/*
 name() specifies a name variable in the current input frame.
 isnumeric() specifies an isnumeric variable in the current input frame
   (to be destringed if necessary).
 All other optons are passed to invdesc.
*/


*
 Set default variable names and lists
*;
foreach X in name isnumeric {;
  if "``X''"=="" {;
    local `X' "`X'";
  };
};

*
 Check whether specified variable names are present in the describe frame
 (defining presence indicators)
 and have the right mode (numeric or string)
*;
foreach X in name {;
  cap conf var `X';
  local `X'pres=_rc==0;
  if ``X'pres' {;
    cap conf string var `X';
    if _rc {;
      disp as error "Variable `X' in current data frame is not string";
      error 498;
    };
  };
};
if !`namepres' {;
  disp as error "name variable `name' not found in current frame";
  error 498;
};


*
 Convert isdata() variable to numeric if necessary
*;
cap conf string var `isnumeric';
if !_rc {;
  cap destring `isnumeric' , replace force;
  char `isnumeric'[destring];
  char `isnumeric'[destring_cmd];
};


*
 Call invdesc
*;
invdesc, dframe(`c(frame)') name(`name') isnumeric(`isnumeric') `options';


end;
