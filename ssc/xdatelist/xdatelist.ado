#delim ;
prog def xdatelist, rclass;
version 10.0;
syntax , First(string) Last(string) [Unit(string) Nunits(integer 1)
 S2(string) Ycutoff(integer 0) FOrmat(string) SEparator(string)];
*
 Create numeric date list in r(numlist)
 starting at the date given by first
 and incremented by steps equal to a number nunits
 of units defined by unit.
 Conversion of string arguments first and last to dates
 is done using the date function,
 with s2 as the s2 argument
 (a string containing a permutation of m, d and [##]y)
 and ycutoff as the year cutoff argument for 2-digit years.
 Optionally (if format is specified),
 a string date list is also created in r(strlist),
 separated by separator, which defaults to a space,
 but can be reset in case there are spaces in the date format.
*! Author: Roger Newson
*! Date: 04 July 2008
*;

* Initialise local variables and default string options *;
if("`s2'"==""){;local s2 "DMY";};
if("`unit'"==""){;local unit "year";};
else if("`unit'"=="week"){;
  local unit "day";
  local nunits=7*`nunits';
};
else if("`unit'"=="quarter"){;
  local unit "month";
  local nunits=3*`nunits';
};
else if("`unit'"=="decade"){;
  local unit "year";
  local nunits=10*`nunits';
};
else if("`unit'"=="century"){;
  local unit "year";
  local nunits=100*`nunits';
};

*
 Initialise first and last dates
*;
if(`ycutoff'==0){;
  local firstd=date("`first'","`s2'");
  local lastd=date("`last'","`s2'");
};
else{;
  local firstd=date("`first'","`s2'",`ycutoff');
  local lastd=date("`last'","`s2'",`ycutoff');
};
if missing(`firstd') {;disp as error "Invalid first(`first')";};
if missing(`lastd') {;disp as error "Invalid last(`last')";};
if missing(`firstd') | missing(`lastd') {;error 498;};

* Check that number of units is sensible *;
if((`nunits'<=0)|(missing(`nunits'))){;
  disp as error "Invalid nunits()";
  error 498;
};

*
 Create numeric list of dates
*;
local numlist "";
local date=`firstd';
if("`unit'"=="day"){;
  while(`date'<=`lastd'){;
    if("`numlist'"==""){;local numlist "`date'";};
    else{;local numlist "`numlist' `date'";};
    local date=`date'+`nunits';
  };
};
else if("`unit'"=="month"){;
  local day=day(`firstd');local month=month(`firstd');local year=year(`firstd');
  while(`date'<=`lastd'){;
    if("`numlist'"==""){;local numlist "`date'";};
    else{;local numlist "`numlist' `date'";};
    local year=`year'+int((`month'+`nunits'-1)/12);
    local month=mod(`month'+`nunits'-1,12)+1;
    local date=mdy(`month',`day',`year');
  };
};
else if("`unit'"=="year"){;
  local day=day(`firstd');local month=month(`firstd');local year=year(`firstd');
  while(`date'<=`lastd'){;
    if("`numlist'"==""){;local numlist "`date'";};
    else{;local numlist "`numlist' `date'";};
    local year=`year'+`nunits';
    local date=mdy(`month',`day',`year');
  };
};
else{;
  disp as error "Unrecognised unit(`unit')";
  error 498;
};

* Return numlist as result *;
return local numlist "`numlist'";

*
 If format is specified,
 then create and return strlist
*;
if("`format'"!=""){;
  if("`separator'"==""){;local separator " ";};
  local ndate:word count `numlist';
  local strlist "";
  local i1=0;
  while(`i1'<`ndate'){;local i1=`i1'+1;
    local date:word `i1' of `numlist';local sdate=string(`date',"`format'");
    if("`strlist'"==""){;local strlist "`sdate'";};
    else{;local strlist "`strlist'`separator'`sdate'";};
  };
};
return local strlist "`strlist'";

end;
