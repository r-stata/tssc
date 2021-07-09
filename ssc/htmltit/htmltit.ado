#delim ;
prog def htmltit;
version 14.0;
/*
 Input a string file path name variable
 assumed to contain HTML file names,
 and generate a string variable
 containing the likely HTML document titles.
*!Author: Roger Newson
*!Date: 01 April 2017
*/


syntax varname(string) [if] [in], Generate(name);
/*
 generate() specifies the output variable name.
*/


*
 Evaluate start and end tags and their lengths
*;
local tag1 "<title>";
local tag2 "</title>";
tempname lentag1 lentag2;
scal `lentag1'=ustrlen("`tag1'");
scal `lentag2'=ustrlen("`tag2'");


*
 Mark sample
*;
marksample touse, strok;
local Nobs=_N;


*
 Create temporary version of generated variable
*;
tempvar tempgen;
/*
tempname titcur;
qui gene strL `tempgen'="";
forv i1=1(1)`Nobs' {;
  if `touse'[`i1'] {;
    local Fcur=`varlist'[`i1'];
    cap conf file `"`Fcur'"';
    if !_rc {;
      qui {;
        preserve;
        tempvar line candtitle;
        import delimited `line' using `"`Fcur'"', clear delim(tab) stringcols(1) varnames(nonames);
        replace `line'=ustrtrim(`line');
        gene byte `candtitle' = ustrpos(`line',"`tag1'")==1 & ustrpos(`line',"`tag2'")==ustrlen(`line')-`lentag2'+1;
        keep if `candtitle';
        keep if _n==1;
        replace `line'=usubstr(`line',`lentag1'+1,ustrlen(`line')-`lentag1'-`lentag2');
        scal `titcur'=`line'[1];
        restore;
        replace `tempgen'=`titcur' in `i1';
      };
    };
  };
};
*/
tempname FNscal TITscal HTMb1;
qui gene strL `tempgen'="";
forv i1=1(1)`Nobs' {;
  if `touse'[`i1'] {;
    scal `FNscal'=`varlist'[`i1'];
    * Check that we have a readable file *;
    mata: st_local("isFN",strofreal(fileexists(st_strscalar("`FNscal'"))));
    if `isFN' {;
      * Search file for candidate title line *;
      local found=0;
      file open `HTMb1' using `"`=`FNscal''"', read text;
      cap noi {;
        file read `HTMb1' curlin;
        while !r(eof) & !`found' {;
          mata: st_strscalar("`TITscal'", st_local("curlin"));
          scal `TITscal'=ustrtrim(`TITscal');
          local found = ustrpos(`TITscal',"`tag1'")==1 & ustrpos(`TITscal',"`tag2'")==ustrlen(`TITscal')-`lentag2'+1;
          if `found' {;
            scal `TITscal'=usubstr(`TITscal',`lentag1'+1,ustrlen(`TITscal')-`lentag1'-`lentag2');
          };
          file read `HTMb1' curlin;
        };
        if `found' {;
          qui replace `tempgen'=`TITscal' in `i1';
        };
      };
      file close `HTMb1';
    };
  };
};
qui compress `tempgen';
lab var `tempgen' "HTML document title"; 


* Create permanent generated variable *;
rename `tempgen' `generate';


end;
