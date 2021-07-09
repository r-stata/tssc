#delim ;
prog def xrelong;
version 10.0;
/*
 Extended version of reshape long,
 assigning an existing value label to the output j-variable.
*!Author: Roger Newson
*!Date: 07 November 2012
*/

syntax [ anything(name=stubnames) ] [ , j(string) JLAbel(name) String  * ];
/*
 j() is the j-variable name passed to reshape long.
 jlabel() is a value label name,
   specifying a value label to be assigned to the j-variable.
 string is the string option passed to reshape long.
*/

*
 Complete stubnames from _dta[] characteristics if absent.
*;
if `"`stubnames'"'=="" {;
  local stubnames `"`_dta[ReS_Xij]'"';
};

*
 Extract j-variable name.
*;
if `"`j'"'=="" {;
  local j `"`_dta[ReS_j]' `_dta[ReS_jv]'"';
};
gettoken jvar jvals: j;
if `"`jvar'"'=="" {;
  disp as error `""reshape j" not defined"';
  error 111;
};
conf new var `jvar';

*
 Check that string and jlabel() options
 are not both present.
*;
if "`jlabel'"!="" & "`string'"!="" {;
  disp as error "Options jlabel() and string may not be combined";
  error 498;
};

* Do the reshaping *;
mata: xrelong_reshape();
if "`jlabel'"!="" {;
  lab val `jvar' `jlabel';
};

end;

#delim cr
version 10.0
mata:

void function xrelong_reshape()
{
/*
 Input reshape options, invoke reshape long,
 and assign variable label specified by jlabel() option
 to j-variable.
*/
string scalar stubnames;
string scalar jvar;
string scalar jlabel;
string scalar stringopt;
string scalar reshopts;
real scalar retcode;
real vector jlabvals;
string vector jlabtext;
/*
 stubnames contains stub names input to reshape long.
 jvar contains the name of the j-variable.
 jlabel contains the name of the variable label for the j-variable.
 stringopt contains the string option for reshape long.
 reshopts contains the other options for reshape long.
 retcode contains the return code from reshape long.
 jlabvals contains the numeric values for the variable label for the j-variable.
 jlabtext contains the text labels for the variable label for the j-variable.
*/

stubnames=st_local("stubnames");
jvar=st_local("jvar");
jlabel=st_local("jlabel");
stringopt=st_local("string");
reshopts=st_local("options");

st_vlload(jlabel,jlabvals,jlabtext);
retcode=_stata("reshape long "+stubnames+" , j("+jvar+") "+stringopt+" "+reshopts);
if(retcode){
  exit(retcode);
}
st_vlmodify(jlabel,jlabvals,jlabtext);

}

end
