#delimit ;
program define normalbvr;
version 10.0;
/*
 Input X-variable and Y-variable
 and (optionally) expressions for Normal correlation and means and SDs for X and Y
 and generate Normal bivariate ridits.
*! Author: Roger Newson
*! Date: 30 March 2018
*/
syntax newvarlist(min=1 max=1) [if] [in] , X(string asis) Y(string asis)
  [  Rho(string asis) MUX(string asis) MUY(string asis) SDX(string asis) SDY(string asis)
   FLOAT ];
/*
 newvarname is the output variable name.
 x() is an expression specifying the X-variable.
 y() is an expression specifying the Y-variable.
 rho() is an expression specifying correlation coefficients.
 mux() is an expression specifying a mean for the X-variable.
 muy() is an expression specifying a mean for the Y-variable.
 sdx() is an expression specifying the SD for the X-variable.
 sdy() is an expression specifying the SD for the Y-variable.
 float specifies that the generated variable must be of type float,
  instead of the default output type double.
*/

marksample touse, novarlist;

*
 Generate temporary variables for X- and Y-variables,
 correlation coefficient
 and means and SDs for the X and Y variables
*;
foreach EXP in x y {;
  tempvar `EXP'_v;
  qui gene double ``EXP'_v'=(``EXP'') if `touse';
};
foreach EXP in rho mux muy {;
  if `"``EXP''"'=="" {;
    local `EXP' "0";
  };
  tempvar `EXP'_v;
  qui gene double ``EXP'_v'=(``EXP'') if `touse';
};
foreach EXP in sdx sdy {;
  if `"``EXP''"'=="" {;
    local `EXP' "1";
  };
  tempvar `EXP'_v;
  qui gene double ``EXP'_v'=(``EXP'') if `touse';
};

*
 Generate temporary variables for standard Normal deviates
*;
tempvar zx zy;
qui gene double `zx'=(`x_v'-`mux_v')/`sdx_v' if `touse';
qui gene double `zy'=(`y_v'-`muy_v')/`sdy_v' if `touse';
drop `mux_v' `muy_v' `sdx_v' `sdy_v';

*
 Generate output variable containing Normal bivariate ridits
*;
tempvar bvr;
qui gene double `bvr' = binormal(`zx',`zy',`rho_v')
  + binormal(-`zx',-`zy',`rho_v')
  if `touse';
qui replace `bvr'=`bvr'+`bvr'-1 if `touse';
if "`float'"!="" {;
  qui recast float `bvr', force;
};
lab var `bvr' "Normal bivariate ridit";
rename `bvr' `varlist';

end;
