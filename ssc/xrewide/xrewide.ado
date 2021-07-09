#delim ;
prog def xrewide;
version 10.0;
/*
 Extended version of reshape wide,
 saving j-variable values and/or labels
 in characteristics of the output reshaped variables.
*!Author: Roger Newson
*!Date: 06 November 2012
*/

syntax [ anything(name=stubnames) ] [ , i(varlist) j(string)
  CJValue(name) VJValue(varlist) CJLabel(name) VJLabel(varlist)
  PJValue(string) SJValue(string) PJLabel(string) SJLabel(string)
  XMLSub
  LXJK(name) LXKJ(name)
  * ];
/*
 i() is the i-variable list.
 j() is the j-variable option passed to reshape wide.
 cjvalue() specifies the name of a variable characteristic,
   to be assigned to the output reshaped variables,
   to contain the corresponding j-variable value.
 vjvalue() specifies a sublist of input variables to be reshaped,
   whose corresponding output reshaped variables
   will have the cjvalue() characteristic.
 cjlabel() specifies the name of a variable characteristic,
   to be assigned to the output reshaped variables,
   to contain the corresponding j-variable value label.
 vjlabel() specifies a sublist of input variables to be reshaped,
   whose corresponding output reshaped variables
   will have the cjlabel() characteristic.
 pjvalue() specifies a prefix to be added to the left of j-values.
 sjvalue() specifies a suffix to be added to the right of j-values.
 pjlabel() specifies a prefix to be added to the left of j-labels.
 sjlabel() specifies a suffix to be added to the right of j-labels.
 xmlsub indicates that XML substitutions must be performed on the j-labels.
 lxjk() specifies the name of a local macro,
   to be assigned a list of names of generated variables
   ordered primarily by j-value and secondarily by input variable.
 lxkj() specifies the name of a local macro,
   to be assigned a list of names of generated variables
   ordered primarily by input variable and secondarily by j-value.
*/

*
 Complete stubnames from _dta[] characteristics if absent.
*;
if `"`stubnames'"'=="" {;
  local stubnames `"`_dta[ReS_Xij]'"';
};

*
 Expand stub names with wildcards if possible
 and convert at-signs in stub names if required
 and create full list of stub variables.
*;
local newstubnames "";
foreach stub in `stubnames' {;
  cap unab expstub: `stub';
  if _rc {;
    local newstubnames `"`newstubnames' `stub'"';
  };
  else {;
    local newstubnames `"`newstubnames' `expstub'"';
  };
};
local stubnames `"`newstubnames'"';
local newstubnames "";
local stubvars "";
foreach stub in `stubnames' {;
  if index(`"`stub'"',"@")==0 {;
    local newstub `"`stub'@"';
  };
  else {;
    local newstub `"`stub'"';
  };
  local stubvar=subinstr(`"`newstub'"',"@","",.);
  local newstubnames `"`newstubnames' `newstub'"';
  local stubvars `"`stubvars' `stubvar'"';
};
local stubnames `"`newstubnames'"';
local stubvars: list uniq stubvars;
local nstubvar: word count `stubvars';
if `nstubvar'>0 {;
  conf var `stubvars';
};
else {;
  disp as error "No input variables to be reshaped";
  error 498;
};

*
 Set default values for vjvalue and vjlabel
 and check that they are subsets of the stub variables.
*;
if "`vjvalue'"=="" {;local vjvalue `"`stubvars'"';};
if "`vjlabel'"=="" {;local vjlabel `"`stubvars'"';};
local retcode: list vjvalue in stubvars;
if !`retcode' {;
  disp as error "vjvalue(`vjvalue') not a subset of the input variables:" _n "`stubvars'";
  error 498;
};
local retcode: list vjlabel in stubvars;
if !`retcode' {;
  disp as error "vjlabel(`vjlabel') not a subset of the input variables:" _n "`stubvars'";
  error 498;
};

*
 Set i-varlist if missing.
*;
if "`i'"=="" {;
  local i `"`_dta[ReS_i]'"';
};

*
 Extract j-variable name, values and value labels.
*;
if `"`j'"'=="" {;
  local j `"`_dta[ReS_j]' `_dta[ReS_jv]'"';
};
gettoken jvar jvals: j;
if `"`jvar'"'=="" {;
  disp as error `""reshape j" not defined"';
  error 111;
};
conf var `jvar';
local jval1: word 1 of `jvals';
if `"`jval1'"'=="" {;
  qui levelsof `jvar', clean local(jvals);
};
tempname jvallab;
local jvala: val lab `jvar';
if "`jvala'"!="" {;
  lab copy `jvala' `jvallab';
};

* Do the reshaping *;
mata: xrewide_reshape();

*
 Assign the lxjk() macro if requested.
*;
if "`lxjk'"!="" {;
  local genvars "";
  foreach jvalcur in `_dta[ReS_jv]' {;
    foreach stubcur in `_dta[ReS_Xij]' {;
      local vncur=subinstr("`stubcur'","@","`jvalcur'",.);
      local genvars "`genvars' `vncur'";
    };
  };
  mata: st_local("genvars",strtrim(st_local("genvars")));
  c_local `lxjk': copy local genvars;
};

*
 Assign the lxkj() macro if requested.
*;
if "`lxkj'"!="" {;
  local genvars "";
  foreach stubcur in `_dta[ReS_Xij]' {;
    foreach jvalcur in `_dta[ReS_jv]' {;
      local vncur=subinstr("`stubcur'","@","`jvalcur'",.);
      local genvars "`genvars' `vncur'";
    };
  };
  mata: st_local("genvars",strtrim(st_local("genvars")));
  c_local `lxkj': copy local genvars;
};

end;

#delim cr
version 10.0
mata:

void function xrewide_reshape()
{
/*
 Input j-value labels, invoke reshape,
 and output j-values and j-value labels
 into variable characteristics for output reshaped variables.
*/
string scalar jvallab;
real colvector jvalues;
string colvector jlabels;
/*
 jvallab contains name of j-variable value label.
 jvalues contains values of j-variable value label.
 jlabels contains labels of j-variable value label.
*/
string rowvector stubnames;
string scalar cjvalue;
string scalar cjlabel;
string rowvector vjvalue;
string rowvector vjlabel;
string rowvector sjvalues;
real scalar jstring;
/*
 stubnames contains stub names input to reshape wide.
 cjvalue contains characteristic name in cjvalue() option.
 cjlabel contains characteristic name in cjlabel() option.
 vjvalue contains variable names in vjvalue() option.
 vjlabel contains variable names in vjlabel() option.
 sjvalues contains string j-values output by reshape wide.
 jstring contains indicalot rhat j-variable is string.
*/
string scalar varcur,invarcur;
real scalar i1, i2, retcode;
/*
 varcur contains variable name currently being processed.
 invarcur contains input variable name currently being processed.
 i1 and i2 contain indices.
 retcode contains a return code.
*/

/*
 Input local macro values to Mata matrices.
*/
cjvalue=st_local("cjvalue");
cjlabel=st_local("cjlabel");
vjvalue=tokens(st_local("vjvalue"));
vjlabel=tokens(st_local("vjlabel"));
jvallab=st_local("jvallab");

/*
 Input j-values and j-labels from value label to matrices.
*/
st_vlload(jvallab,jvalues,jlabels);

/* Perform XML substitutions if requested */
if(st_local("xmlsub")!=""){
  jlabels=subinstr(jlabels,"&","&amp;",.);
  jlabels=subinstr(jlabels,"<","&lt;",.);
  jlabels=subinstr(jlabels,">","&gt;",.);
}

/*
 Reshape dataset and input selected dataset characteristics.
*/
retcode=_stata("reshape wide " + st_local("stubnames") + ", i(" + st_local("i") + ") j(" + st_local("jvar")+" "+st_local("jvals")+") " + st_local("options"));
if(retcode){
  exit(retcode);
}
jstring=strtoreal(st_global("_dta[ReS_str]"));
stubnames=tokens(st_global("_dta[ReS_Xij]"));
sjvalues=tokens(st_global("_dta[ReS_jv]"));

/*
 Restore j-values and j-labels to value label.
*/
st_vlmodify(jvallab,jvalues,jlabels);

/*
 Assign j-value and j-label characteristics.
*/
for(i1=1;i1<=cols(stubnames);i1++){
  invarcur=subinstr(stubnames[i1],"@","",.);
  for(i2=1;i2<=cols(sjvalues);i2++){
    varcur=subinstr(stubnames[i1],"@",sjvalues[i2],.);
    if(!missing(_st_varindex(varcur))){
      if((cjvalue!="") & any(invarcur:==vjvalue)){
        st_global(varcur+"["+cjvalue+"]",st_local("pjvalue")+sjvalues[i2]+st_local("sjvalue"));
      }
      if(!jstring & (cjlabel!="") & any(invarcur:==vjlabel)){
        st_global(varcur+"["+cjlabel+"]",st_local("pjlabel")+st_vlmap(jvallab,strtoreal(sjvalues[i2]))+st_local("sjlabel"));
      }
    }
  }
}

}

end
