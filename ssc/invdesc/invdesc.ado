#delim ;
prog def invdesc;
version 16.0;
/*
 Reset variable attributes in dataset in the current frame
 using attriibutes from a describe or descsave resultsset
 (possibly extended) in a describe frame
 and value labels from a label frame.
*! Author: Roger Newson
*! Date: 15 May 2020
*/

syntax , DFRame(name) [ LFRame(string)
  NAme(name) TYpe(name) ISnumeric(name) FOrmat(name)
  VALlab(name) VARlab(name)
  CHarvars(string) DESTopts(name) TOSTopts(name)
  ];
/*
 dframe() specifies a frame containing the variable attributes.
 lframe() specifies a frame containing the value labels.
 name(), type(), isnumeric(), format(), vallab(), varlab(), destopts() and tostopts()
  specify nondefault names for variables in the input frame,
  corresponding to the variables of the same names in a describe resultsset
  (possibly extended with destring options in destopts()
  and tostring options in tostopts()).
 charvars() specifies a list of string variables in  the describe frame
  containing values for variable characteristics
  (as created in a descsave resultsset).
*/

*
 Check that input frames exist if specified
 and store name of current frame
*;
conf frame `dframe';
if "`lframe'"!="" {;
  * Parse lframe() option *;
  lframe_parse `lframe';
  local lframename "`r(lframename)'";
  local vlreplace "`r(vlreplace)'";
  local vallabs "`r(vallabs)'";
  local replaceind = "`vlreplace'"!="";
  conf frame `lframename';
};
local oldframe `c(frame)';

*
 Set default variable names and lists
*;
foreach X in name type isnumeric format vallab varlab destopts tostopts {;
  if "``X''"=="" {;
    local `X' "`X'";
  };
};
frame `dframe' {;
  cap unab ucharvars: `charvars';
  local charvars "`ucharvars'";
  local Ncharvar: word count `charvars';
  local charpres=`Ncharvar'>0;
};


*
 Check whether specified variable names are present in the describe frame
 (defining presence indicators)
 and have the right mode (numeric or string)
*;
frame `dframe' {;
  foreach X in isnumeric {;
    cap conf var `X';
    local `X'pres=_rc==0;
    if  ``X'pres' {;
      cap conf numeric var `X';
      if _rc {;
        disp as error "Variable `X' in data frame `dframe' is not numeric";
        error 498;
      };
    };
  };
  foreach X in name type format vallab varlab destopts tostopts `charvars' {;
    cap conf var `X';
    local `X'pres=_rc==0;
    if ``X'pres' {;
      cap conf string var `X';
      if _rc {;
        disp as error "Variable `X' in data frame `dframe' is not string";
        error 498;
      };
    };
  };
  if !`namepres' {;
    disp as error "name variable `name' not found in descriptive frame `dframe'";
    error 498;
  };

};


*
 Parse and execute lframe() option
*;
if `"`lframename'"'!="" {;
  *
   Extract list of value labels from label frame
  *;
  frame `lframename' {;
    *
     Set default label name list if necessary
    *;
    qui lab dir;
    local allvallabs "`r(names)'";
    if "`vallabs'"=="" {;
      local vallabs "`allvallabs'";
    };
    local namelistok: list vallabs in allvallabs;
    if !`namelistok' {;
      disp as error "Invalid value label list: `vallabs'";
      error 498;
    };
    *
     Transfer value labels between frames
    *;
    foreach VL in `vallabs' {;
      mata: transferforinvdesc("`VL'","`oldframe'",`replaceind');
    };
  };
};


*
 Loop over variables in descriptive frame
*;
frame `dframe' {;

  *
   Create temporary names for temporary scalars
   in whch variable attributes will be stored
  *;
  foreach X in name isnumeric type format vallab varlab destopts tostopts {;
    tempname `X'cur;
  };
  forv i1=1(1)`Ncharvar' {;
    tempname charvarcur`i1' charvalcur`i1' charnamecur`i1';
  };

  *
   Loop over variables,
   modifying their attributes.
  *;
  local Nvar=_N;
  forv i1=1(1)`Nvar' {;
    
    * Assign scalars to values in variables *;
    foreach X in name isnumeric type format vallab varlab destopts tostopts {;
      if ``X'pres' {;
        scal ``X'cur' = ``X''[`i1'];
      };
    };
    forv i2=1(1)`Ncharvar' {;
      local cvcur: word `i2' of `charvars';
      scal `charvarcur`i2'' = "`cvcur'";
      scal `charvalcur`i2'' = `=`charvarcur`i2'''[`i1'];
      mata: st_strscalar("`charnamecur`i2''",st_local("`cvcur'[charname]"));
      if `charnamecur`i2''=="" {;
        mata: st_strscalar("`charnamecur`i2''","`cvcur'");
      };      
    };
    
    *
     Enter old frame and modify current variable
    *;
    frame `oldframe' {;
      mata: st_local("nameisvar",strofreal(!missing(_st_varindex("`=`namecur''"))));
      if `nameisvar' {;
        *
         Current name belongs to a variable
        *;
        
        *
         Modify mode (string or numeric) if required
        *;
        if `isnumericpres' {;
          if `isnumericcur'==0 {;
            cap conf numeric var `=`namecur'';
            if !_rc {;
              * Convert numeric variable to string *;
              local tostcom="cap tostring `=`namecur'' , replace ";
              if `tostoptspres' {;
                mata: stata(st_local("tostcom")+st_strscalar("`tostoptscur'"));  
              };
              else {;
                 mata: stata(st_local("tostcom"));
              };
              char `=`namecur''[tostring];
              char `=`namecur''[tostring_cmd];
            };
          };
          else if `isnumericcur'==1 {;
            cap conf string var `=`namecur'';
            if !_rc {;
              * Convert string variable to numeric *;
              local destcom="cap destring `=`namecur'' , replace ";
              if `destoptspres' {;
                mata: stata(st_local("destcom")+st_strscalar("`destoptscur'"));  
              };
              else {;
                mata: stata(st_local("destcom"));
              };
              char `=`namecur''[destring];
              char `=`namecur''[destring_cmd];
            };
          };
        };
        
        *
         Modify type if required
        *;
        if `typepres' {;
          
          local recastcom "cap recast `=`typecur'' `=`namecur''";
          mata: stata(st_local("recastcom"));
        };
        
        *
         Modify format if required
        *;
        if `formatpres' {;
          cap mata: st_varformat(st_strscalar("`namecur'"),st_strscalar("`formatcur'"));
        };
        
        *
         Modify value label if requested
        *;
        if `vallabpres' {;
            if missing(`vallabcur') {;
              cap mata: stata("lab val "+st_strscalar("`namecur'"));
            };
            else {;
              cap mata: st_local("vallabnameok",strofreal(st_isname(st_strscalar("`vallabcur'"))));
              if `vallabnameok' {;
                cap mata: stata("lab val "+st_strscalar("`namecur'")+" "+st_strscalar("`vallabcur'"));
            };
          };
        };
        
        *
         Modify variable label if requested
        *;
        if `varlabpres' {;
          cap mata: st_varlabel(st_strscalar("`namecur'"),st_strscalar("`varlabcur'"));
        };
        
        *
         Modify characteristics if required
        *;
        if `Ncharvar'>0 {;
          forv i2=1(1)`Ncharvar' {;
            cap mata: st_global("`=`namecur''[`=`charnamecur`i2''']",st_strscalar("`charvalcur`i2''"));
          };
        };
        
      };
    };
  };
};


end;


prog def lframe_parse, rclass;
version 16.0;
/*
 Parse the lframe() option
*/

syntax name [ , replace LAbels(namelist) ];
retu local vallabs "`labels'";
retu local vlreplace "`replace'";
retu local lframename "`namelist'";

end;


#delim cr
/*
  Private Mata programs used by invdesc
*/
mata:

void transferforinvdesc(string scalar vallab,string scalar toframe,real scalar replaceind){
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