#delim ;
prog def chardef;
version 11.0;
/*
 Assign a list of values for a characteristic
 to an evarlist of variables or the name _dta.
*!Author: Roger Newson
*!Date: 09 May 2012
*/

syntax [ anything(name=evarlist) ] [, Char(name) Values(string asis) PRefix(string) SUffix(string) ];
/*
 char() specifies the name of the variable characteristic to be assigned.
 values() specifies a list of values to assign.
 prefix() specifies a prefix to be added before these values.
 suffix() specifies a suffix to be added after these values.
*/

*
 Unabbreviate evarlist
*;
if `"`evarlist'"'=="" {;
  unab evarlist: *;
};
else {;
  local newevarlist "";
  foreach Y in `evarlist' {;
    if "`Y'"=="_dta" {;
      local newevars "`Y'";
    };
    else {;
      unab newevars: `Y';
    };
    local newevarlist `"`newevarlist' `newevars'"';
  };
  local evarlist `"`newevarlist'"';
};

*
 Use default character name and value list if required
 and tokenize list of values.
*;
if "`char'"=="" {;local char "varname";};
if `"`values'"'=="" {;local values `""""';};
mata:chardef_tokenize("nval","values");

*
 Assign characteristics to variables
*;
local i1=0;
foreach Y in `evarlist' {;
  local i1=`i1'+1;
  if `i1'>`nval' {;
    char `Y'[`char'] `"`prefix'`macval(`nval')'`suffix'"';
  };
  else {;
    char `Y'[`char'] `"`prefix'`macval(`i1')'`suffix'"';
  };
};

end;

#delim cr
version 11.0
/*
  Private Mata programs
*/
mata:

void chardef_tokenize(string scalar tokencount,string scalar tokenlist)
{
/*
 Count tokens in local macro with name in tokenlist
 and return result in local macro with name in tokencount
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
