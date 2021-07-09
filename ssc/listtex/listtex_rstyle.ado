#delim ;
prog def listtex_rstyle, rclass;
version 10.0;
/*
 Input a listtex rstyle() option
 (with or without amendments)
 and save begin, delimiter and end strings in r().
*! Author: Roger Newson
*! Date: 22 October 2009
*/

syntax [, Begin(string) Delimiter(string) End(string) Missnum(string) RStyle(string) ];
/*
  begin() is string at beginning of each obs
    (set to "" if absent).
  delimiter() is delimiter for separating values of same obs
    (set in default to "&").
  end() is string at end of each obs
    (set to "" if absent).
  missnum() is string code for missing numeric value
    (defaulting to empty string if absent)
  rstyle() is a row style
    (a named combination of -begin-, -end-, -using- and -missnum-)
*/

* Interpret row styles *;
if `"`rstyle'"'=="html" {;
  if `"`begin'"'=="" {;local begin "<tr><td>";};
  if `"`delimiter'"'=="" {;local delimiter "</td><td>";};
  if `"`end'"'=="" {;local end "</td></tr>";};
};
else if `"`rstyle'"'=="htmlhead" {;
  if `"`begin'"'=="" {;local begin "<tr><th>";};
  if `"`delimiter'"'=="" {;local delimiter "</th><th>";};
  if `"`end'"'=="" {;local end "</th></tr>";};
};
else if `"`rstyle'"'=="tabular" {;
  if `"`delimiter'"'=="" {;local delimiter "&";};
  if `"`end'"'=="" {;local end `"\\"';};
};
else if `"`rstyle'"'=="halign" {;
  if `"`delimiter'"'=="" {;local delimiter "&";};
  if `"`end'"'=="" {;local end "\cr";};
};
else if `"`rstyle'"'=="settabs" {;
  if `"`begin'"'=="" {;local begin "\+";};
  if `"`delimiter'"'=="" {;local delimiter "&";};
  if `"`end'"'=="" {;local end "\cr";};
};
else if `"`rstyle'"'=="tabdelim" {;
  if `"`delimiter'"'=="" {;local delimiter=char(9);};
};
else if `"`rstyle'"'!="" {;
  disp as text "Unrecognised row style: " as result `"`rstyle'"';
  disp as text "Default row style used instead";
};

* Default delimiter *;
if `"`delimiter'"'=="" {;local delimiter "&";};

*
 Return results
*;
return local missnum: copy local missnum;
return local end: copy local end;
return local delimiter: copy local delimiter;
return local begin: copy local begin;

end;
