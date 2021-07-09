#delim ;
prog def rtfrstyle, rclass;
version 11.0;
/*
 Define a listtex row style for a RTF table.
*!Author: Roger Newson
*!Date: 23 November 2010
*/

syntax [varlist(default=none)] [, CWidths(numlist >0) trgaph(integer 40) trleft(numlist integer min=1 max=1) TDPosition(string)
  TDAdd(string) CDAdd(string asis)
  MIssnum(string) 
  LOcal(namelist max=4 local)
  ];
/*
 cwidths() specifies the list of column widths (in twips),
   to be trimmed or extended to length of varlist if present.
 trgaph() specifies half the space between the cells of a table row (in twips).
 trleft() specifies the position in twips of the leftmost edge of the table
   with respect to the left edge of its column.
 tdposition() specifies position of the table definition,
   which may be in the begin string, in the end string, or in both.
 tdadd() specifies a string,
   to be used as additional RTF table definition material.
 cdadd() specifies a list of strings,
   to be used as additional RTF cell definition material.
 missnum() specifies the missnum() component of the listtex row style.
 local() specifies a list of names of local macros in the calling program,
   to contain the begin, delimiter, end and missnum strings, respectively,
   of the generated row style.
*/

*
 Set default for tdposition
 and check that it is valid.
*;
if `"`tdposition'"'=="" {;local tdposition "b";};
if !inlist(`"`tdposition'"',"b","e", "be","eb") {;
  disp as error "Invalid tdposition()";
  error 498;
};

*
 Set default for trleft()
*;
if "`trleft'"=="" {;local trleft -`trgaph';};

*
 Trim or extend column width list
 for equal length to varlist (if present).
*;
if "`cwidths'"=="" {;local cwidths "1440";};
if "`varlist'"!="" {;
  local i1=0;
  local newcwidths "";
  foreach Y of var `varlist' {;
    local i1=`i1'+1;
    local widnew: word `i1' of `cwidths';
    if "`widnew'"!="" {;
      local widcur "`widnew'";
    };
    local newcwidths "`newcwidths' `widcur'";
  };
  local cwidths "`newcwidths'";
};

*
 Trim or extend list of cell definition additional materials
 for equal length to column width list.
*;
if `"`cdadd'"'=="" {;local cdadd `""""';};
mata: rtfrstyle_tokenize("ncdadd","cdadd");
local newcdadd "";
local i1=0;
foreach CW of num `cwidths' {;
  local i1=`i1'+1;
  if `i1'<=`ncdadd' {;
    local cdanew `"``i1''"';
  };
  local newcdadd `"`newcdadd' `"`cdanew'"'"';
};
local cdadd `"`newcdadd'"';

*
 Calculate cell right boundaries.
*;
rtfcumlist `cwidths', lo(crbounds);

*
 Generate cell definitions.
*;
mata: rtfrstyle_tokenize("ncdadd","cdadd");
local celldefs "";
forv i1=1(1)`ncdadd' {;
  local CRB: word `i1' of `crbounds';
  local celldefs `"`celldefs'``i1''\cellx`CRB'"';
};

*
 Generate table definition.
*;
local tabdef `"\trowd\trgaph`trgaph'\trleft`trleft'`tdadd'`celldefs'"';

*
 Generate begin, end and delimiter strings.
*;
local delimiter "\cell\pard\intbl ";
if strpos(`"`tdposition'"',"b")==0 {;
  local begin "{\pard\intbl ";
};
else {;
  local begin `"{`tabdef'\pard\intbl "';
};
if strpos(`"`tdposition'"',"e")==0 {;
  local end "\cell\row}";
};
else {;
  local end `"\cell`tabdef'\row}"';
};

*
 Return row style definition in local macros
*;
local i1=0;
foreach R in begin delimiter end missnum {;
  local i1=`i1'+1;
  local cmac: word `i1' of `local';
  if "`cmac'"!="" {;
    c_local `cmac' `"``R''"';
  };
};

*
 Return results to r().
*;
return local missnum `"`missnum'"';
return local end `"`end'"';
return local delimiter `"`delimiter'"';
return local begin `"`begin'"';
return local tabdef `"`tabdef'"';
return local celldefs `"`celldefs'"';
return local cdadd `"`cdadd'"';
return local crbounds "`crbounds'";
return local cwidths "`cwidths'";
return local tdadd `"`tdadd'"';
return scalar trleft=`trleft';
return scalar trgaph=`trgaph';

end;

#delim cr
version 11.0
/*
  Private Mata programs
*/
mata:

void rtfrstyle_tokenize(string scalar tokencount,string scalar tokenlist)
{
/*
 Count tokens in local macro with name in tokenlist
 and return result in local macro with name in tokencount
 and return tokens in numbered local macros.
*/
string rowvector tokenrow;
real i1;
/*
 tokenrow will be a row vector of the tokens.
 i1 will be a counter.
*/

tokenrow=tokens(st_local(tokenlist));
st_local(tokencount,strofreal(cols(tokenrow)));
for(i1=1;i1<=cols(tokenrow);i1++){
  st_local(strofreal(i1),tokenrow[i1]);
}

}

end
