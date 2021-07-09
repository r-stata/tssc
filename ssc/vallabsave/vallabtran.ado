#delim ;
prog def vallabtran;
version 16.0;
/*
 Transfer a list of value labels from one frame to another.
*!Author: Roger Newson
*!Date: 16 September 2019
*/

syntax [ namelist ] [, From(name) To(name) replace ];
/*
 from() specifies the frame from which the labels are copied.
 to() specifies the frame to which the labels are copied.
 replace specifies that any existing value labels in the to() dataset
  with the same names as the copied labels will be replaced.
*/

*
 Set default frame names from() and to()
*;
local curframe=c(frame);
foreach X in from to {;
  if "``X''"=="" {;
    local `X' "`curframe'";
  };
  cap conf frame ``X'';
  if _rc {;
    disp as error "Illegal option `X'(``X'')" _n "``X'' is not a frame";
    error 498;
  };
};

*
 Transfer value labels from the frame specified in the from() option
 to the frame specified in the to() option
*;
local oldframe=c(frame);
local replaceind="`replace'"!="";
frame change `from';
cap noi {;

  *
   Set default label name list if necessary
  *;
  qui lab dir;
  local allvallabs "`r(names)'";
  if "`namelist'"=="" {;
    local namelist "`allvallabs'";
  };
  local namelistok: list namelist in allvallabs;
  if !`namelistok' {;
    disp as error "Invalid value label list: `namelist'";
    error 498;
  };

  *
   Transfer value labels between frames
  *;
  foreach VL in `namelist' {;
    mata: transferforvallabtran("`VL'","`to'",`replaceind');
    frame change `from';
  };

};
frame change `oldframe';

end;

#delim cr
/*
  Private Mata programs used by vallabtran
*/
mata:

void transferforvallabtran(string scalar vallab,string scalar toframe,real scalar replaceind){
/*
 Copy value label vallab from current frame to frame toframe,
 replacing old value labels if replaceind is true.
*/
string scalar curframe
real vector labvalues
string vector labtext

curframe=st_framecurrent()
st_vlload(vallab,labvalues,labtext)
st_framecurrent(toframe)
if(replaceind){
  st_vldrop(vallab)
}
st_vlmodify(vallab,labvalues,labtext)
st_framecurrent(curframe)
  
}

end
