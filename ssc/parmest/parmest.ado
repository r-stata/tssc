#delim ;
program define parmest,rclass;
version 16.0;
/*
 If current estimation matrices exist,
 then extract the parameter names, estimates,
 standard errors and confidence limits
 and reformat them as a data set with 1 observation per parameter,
 (replacing the current one, in the manner of the collapse command,
 if the user explicitly requests this).
*! Author: Roger Newson
*! Date: 10 April 2020
*/


syntax [, LIst(string asis) FRAme(string asis) SAving(string asis) noREstore FAST FList(string)
    EForm Dof(string)
    LEvel(numlist >=0 <100 sort) CLNumber(passthru) MCOMPare(passthru) MCOMCi(passthru)
    BMATrix(string) VMATrix(string) DFMATrix(string)
    MSEType OMit EMPty Label YLabel IDNum(string) IDStr(string) STArs(passthru)
    EMac(string asis) EScal(string asis) EVec(string asis) ERows(string asis) ECols(string asis)
    REName(string) FOrmat(string) FLOAT noDOUble noZErop NUllvalue(numlist min=1 max=1) ];
/*

Output-destination options:

LIst() contains a varlist of variables to be listed,
  expected to be present in the output data set
  and referred to by the new names if REName is specified,
  together with optional if and/or in subsetting clauses and/or list_options
  as allowed by the list command.
FRAme specifies a Stata data frame in which to create the output data set.
SAving() specifies a data set in which to save the output data set.
noREstore specifies that the pre-existing data set
  is not restored after the output data set has been produced
  (set to norestore if FAST is present).
FAST specifies that parmest will not preserve the original data set
  so that it can be restored if the user presses Break
  (intended for use by programmers).
  The user must specify at least one of the four options
  list, saving, norestore and fast,
  because they specify whether the output data set
  is listed to the log, saved to a disk file,
  written to the memory (destroying any pre-existing data set),
  or multiple combinations of these possibilities.
FList() is a global macro name,
  belonging to a macro containing a filename list (possibly empty),
  to which parmest will append the name of the data set
  specified in the SAving() option.
  This enables the user to build a list of filenames
  in a global macro,
  containing the output of a sequence of model fits,
  which may later be concatenated using dsconcat (if installed) or append.

Confidence-interval options:

EForm indicates that the estimates and confidence limits
  are to be exponentiated, and the standard errors multiplied
  by the exponentiated estimate.
Dof() specifies a scalar or number for the degrees of freedom
  (overriding the default, which may be scalar or vector,
  and is usually copied from the estimation results).
  If dof is zero, then normal confidence limits are calculated.
LEvel() specifies the confidence level(s) to be used
  in calculating the lower and upper confidence limits minxx and maxxx
  (defaulting to c(level) if not specified).
CLNumber() specifies the method for numbering the names
  of the lower and upper confidence limit variable names minxx and maxxx,
  and may be level (specifying that xx is the confidence level)
  or rank (specifying that xx is the rank, in ascending order,
  of the confidence level in the set of levels specified in the level option).
MCOMPare specifies a multiple-comparison correction method
  to be used with confidence limits and P-values.
MCOMCi specifies a multiple-comparison correction method
  to be used with confidence limits only.
BMATrix() specifies the matrix from which the estimates will be extracted.
VMATrix() specifies the matrix from which the variances will be extracted,
  in order to calculate the standard error variable.
DFMATrix() specifies the matrix
  from which the degrees of freedom will be extracted,
  in order to calculate the degrees of freedom variable.

Variable-adding options:

MSEType indicates that the new dataset
  should contain a string variable,
  containing the matrix stripe element type of the corresponding parameter
  (variable, error, factor, interaction, or product).
OMit indicates that the new dataset
  should contain a binary indicator variable with default name omit,
  indicating the collinearity omit status of the corresponding parameter.
EMPty indicates that the new dataset
  should contain a binary indicator variable with default name empty,
  indicating the empty cell status of the corresponding parameter.
Label indicates that the new data set
  should contain a variable with default name label,
  containing labels corresponding to variables named in parm
  (wherever such variables exist in the pre-existing data set).
YLabel indicates that the new data set
  should contain a variable with default name ylabel,
  containing the label corresponding to the variable named
  in the estimation result e(depvar)
  (wherever such a variable exists in the pre-existing data set).
IDNum() is an ID number for the model fit,
  used to create a numeric variable idnum in the output data set
  with the same value for all observations.
  This is useful if the output data set is concatenated
  with other parmest output data sets,
  using dsconcat (if installed) or append.
IDStr() is an ID string for the model fit,
  used to create a string variable idstr in the output data set
  with the same value for all observations.
  A parmest output data set may have idnum, idstr, both or neither.
EMac() is a list of macro estimation results
  to be saved in string variables with names em_xx.
EScal() is a list of scalar estimation results
  to be saved in numeric variables with names es_xx.
EVec() is a list of matrix estimation results
  to be converted to column vectors
  and saved in numeric variables with names ev_xx.
ERows() is a list of matrix estimation results
  whose rows will be stored in numeric variables
  with names of form er_xx_yy.
ECols() is a list of matrix estimation results
  whose columns will be stored in numeric variables
  with names of form ec_xx_yy.
STArs() specifies a list of P-value thresholds,
  and indicates that the new data set should contain a string variable
  with default name stars,
  containing, in each observation, one star for each P-value threshold alpha
  such that the variable p is less than or equal to alpha.

Variable-modifying options:

REName() contains a list of alternating old and new variable names,
  so the user can rename variables in the output data set
  to avoid name clashes (eg with by-variables).
FOrmat() contains a list of the form varlist1 format1 ... varlistn formatn,
  where the varlists are lists of variables in the output data set
  (referred to by the new names if REName is specified)
  and the formats are formats to be used for these variables
  in the output data sets.
FLOAT specifies that there will be no double-precision numeric variables
  in the output data set (because they will be recast to float).
noDOUble is an alternative way of specifying FLOAT.
noZErop specifies that P-values below c(smallestdouble) will be left-truncated
  to c(smallestdouble).
NUllvalue specifies the parameter values under the null hypotheses tested
  using the t- or z-statistics and confidence intervals.
*/


*
 Set restore to norestore if fast is present
 and check that the user has specified one of the four options:
 list and/or nd/or frame and/or saving and/or norestore and/or fast.
*;
if "`fast'"!="" {;
    local restore="norestore";
};
if (`"`list'"'=="")&(`"`frame'"'=="")&(`"`saving'"'=="")&("`restore'"!="norestore")&("`fast'"=="") {;
    disp as error "You must specify at least one of the five options:"
      _n "list(), frame(), saving(), norestore, and fast."
      _n "If you specify list(), then the output variables specified are listed."
      _n "f you specify frame(), then the new data set is output to a data frame."
      _n "If you specify saving(), then the new data set is output to a disk file."
      _n "If you specify norestore and/or fast, then the new data set is created in the current ata frame,"
      _n "and any existing data set in the current data frame is destroyed."
      _n "For more details, see {help parmest:on-line help for parmby and parmest}.";
    error 498;
};


*
 Parse frame() option if present
*;
if `"`frame'"'!="" {;
  cap frameoption `frame';
  if _rc {;
    disp as error `"Illegal frame option: `frame'"';
    error 498;
  };
  local framename "`r(namelist)'";
  local framereplace "`r(replace)'";
  local framechange "`r(change)'";
  if `"`framename'"'=="`c(frame)'" {;
    disp as error "frame() option may not specify current frame."
      _n "Use norestore or fast instead.";
    error 498;
  };
  if "`framereplace'"=="" {;
    cap noi conf new frame `framename';
    if _rc {;
      error 498;
    };
  };
};


*
 Set level to default value
*;
if "`level'"=="" {;
    local level=c(level);
};


*
 Harmonize the synonyms float and nodouble if either is specified
*;
if "`float'"!="" {;
    local double "nodouble";
};
else if "`double'"=="nodouble" {;
    local float "float";
};


*
 Issue error message if the estimation command is incompatible with parmest
*;
if inlist(`"`e(cmd)'"',"exlogistic","expoisson") {;
  disp as error "parmest and parmby cannot work after exlogistic or expoisson";
  error 498;
};


*
 Set default for dof()
 and check that dof() is a number or a scalar if present
*;
if `"`dof'"'=="" {;
  local dof=-1;
};
cap conf scalar `dof';
if _rc!=0 {;
  cap conf number `dof';
  if _rc!=0 {;
    disp as error `"Invalid dof(): `dof'"'
      _n as error "dof() must be a number or a scalar";
    error 498;
  };
};


*
 Set default for nullvalue()
*;
if "`nullvalue'"=="" {;
  local nullvalue=.;
};
if missing(`nullvalue') {;
  if "`eform'"=="" {;
    local nullvalue=0;
  };
  else {;
    local nullvalue=1;
  };
};


*
 Set defaults for bmatrix(), vmatrix() and dfmatrix()
*;
if `"`bmatrix'"'=="" {;
  if inlist(`"`e(cmd)'"',"svymean","svyratio","svytotal")&(`"`e(complete)'"'=="available") {;
    local bmatrix "e(est)";
  };
  else if `"`e(prefix_mi)'"'=="mi estimate" {;
    local bmatrix "e(b_mi)";
  };
  else {;
    local bmatrix "e(b)";
  };
};
if `"`vmatrix'"'=="" {;
  if inlist(`"`e(cmd)'"',"svymean","svyratio","svytotal")&(`"`e(complete)'"'=="available") {;
    local vmatrix "e(V_db)";
  };
  else if `"`e(prefix_mi)'"'=="mi estimate" {;
    local vmatrix "e(V_mi)";
  };
  else {;
    local vmatrix "e(V)";
  };
};
if `"`dfmatrix'"'=="" {;
  if inlist(`"`e(cmd)'"',"svymean","svyratio","svytotal")&(`"`e(complete)'"'=="available") {;
    local dfmatrix="e(_N_psu)-e(_N_str)";
  };
  else if `"`e(prefix_mi)'"'=="mi estimate" {;
    local dfmatrix "e(df_mi)";
  };
};


*
 Extract column vectors of estimates, variances and degrees of freedom
 from options bmatrix(), vmatrix(), dfmatrix() and dof()
*;
tempname cvesti cvvari cvdof;
*
 Estimates
*;
cap matr def `cvesti'=(`bmatrix');
if _rc {;
  disp as error `"Invalid estimates matrix: `bmatrix'"';
  error 301;
};
if rowsof(`cvesti')!=1 {;
  disp as error `"Estimates matrix `bmatrix' must have exactly 1 row"';
  error 498;
};
else {;
  matr def `cvesti'=(`cvesti')';
};
matr colnames `cvesti'="estimate";
local nparm=rowsof(`cvesti');
*
 Variances
*;
matr def `cvvari'=(`vmatrix');
if _rc {;
  disp as error `"Invalid variance matrix: `vmatrix'"';
  error 301;
};
if colsof((`cvvari'))!=`nparm' {;
  disp as error `"Variance matrix `vmatrix' must have as many columns as estimates matrix `bmatrix'"';
  error 498;
};
else if rowsof(`cvvari')==1 {;
  matr def `cvvari'=(`cvvari')';
};
else if rowsof(`cvvari')==`nparm' {;
  matr def `cvvari'=(vecdiag(`cvvari'))';
};
else {;
  disp as error `"Variance matrix `vmatrix' must have 1 row or as many rows as columns"';
  error 498;
};
matr colnames `cvvari'="variance";
*
 Degrees of freedom
*;
if `dof'==0 {;
  local dofpres=0;
  local dfmatrix "";
};
else if (`dof'>0)&(!missing(`dof')) {;
  local dofpres=1;
  local dfmatrix "";
  matr def `cvdof'=`dof'*J(`nparm',1,1);
};
else if `"`dfmatrix'"'!="" {;
  * Extract degrees of freedom from input matrix dfmatrix() *;
  local dofpres=1;
  matr def `cvdof'=(`dfmatrix');
  if _rc {;
    disp as error `"Invalid degrees of freedom matrix: `vmatrix'"';
    error 301;
  };
  if rowsof(`cvdof')!=1 {;
    disp as error `"Degrees of freedom matrix `dfmatrix' must have exactly 1 row"';
    error 498;
  };
  else if colsof(`cvdof')==`nparm' {;
    matr def `cvdof'=(`cvdof')';  
  };
  else if colsof(`cvdof')==1 {;
    matr def `cvdof'=`cvdof'*J(`nparm',1,1);
  };
  else {;
    disp as error `"Degrees of freedom matrix `dfmatrix' must have 1 column"'
      _n `"or as many columns as estimates matrix `bmatrix'"';
    error 498;
  };
};
else if !missing(e(df_r)) {;
  local dofpres=1;
  matr def `cvdof'=e(df_r)*J(`nparm',1,1);
};
else {;
  local dofpres=0;
};
if `dofpres' {;
  matr colnames `cvdof'="dof";
};


*
 Store variable labels in macros with names of form labi1
 if label requested
*;
if "`label'" != "" {;
        local xvlist : rownames(`cvesti');
        local nxv : word count `xvlist';
        local i1 = 0;
        while `i1' < `nxv' {;
                local i1 = `i1' + 1;
                local xvcur : word `i1' of `xvlist';
                _ms_parse_parts `"`xvcur'"';
                if inlist("`r(type)'","variable","error","factor") {;
                  * Unique name portion *; 
                  local xvcur `"`r(name)'"';
                };
                else {;
                  * No unique name portion *;
                  local xvcur "";
                };
                local lab`i1' "";
                if `"`e(cmd)'"'=="lincomest" {;
                    * Set label to linear combination formula *;
                    local lab`i1' `"`e(formula)'"';
                };
                else if `"`xvcur'"'=="_cons" {;
                    local lab`i1' "Constant";
                };
                else {;
                    capture local lab`i1' : variable label `xvcur';
                };
        };
};


*
 Store Y-variable labels in macros with names of form ylabi1
 if ylabel requested
*;
if "`ylabel'"!="" {;
  local nyv=rowsof(`cvesti');
  local depvar `"`e(depvar)'"';
  local ndepvar: word count `depvar';
  cap confirm var `depvar';
  if _rc==0 & `ndepvar'==1 {;
    *
     e(depvar) is a single variable name,
     so use its label
    *;
    forv i1=1(1)`nyv' {;
      local ylab`i1' : variable label `depvar';
    };
  };
  else {;
    *
     e(depvar) is not a single variable name,
     so try equation names instead
    *;
    local yvlist: roweq(`cvesti'), quoted;
    forv i1=1(1)`nyv' {;
      local ylab`i1' "";
      local yvcur: word `i1' of `yvlist';
      local nyvcur: word count `yvcur';
      cap confirm var `yvcur';
      if _rc==0 & `nyvcur'==1 {;
        local ylab`i1': variable label `yvcur';
      };
    };
  };
};


*
 Beginning of frame block (NOT INDENTED)
*;
local oldframe=c(frame);
tempname tempframe;
frame create `tempframe';
frame `tempframe' {;


*
 Create new dataset
 with variables estimate, stderr and dof (if required)
*;
drop _all;
svroweq `cvesti' eq;
svrown `cvesti' parm;
svmat double `cvesti', name(col);
svmat double `cvvari', name(col);
rename variance stderr;
qui replace stderr=sqrt(stderr);
label variable eq "Equation name";
label variable parm "Parameter name";
label variable estimate "Parameter estimate";
label variable stderr "SE of parameter estimate";
if `dofpres'==0 {;
  local dof=0;
};
else {;
  svmat double `cvdof', name(col);
  qui compress dof;
  label variable dof "Degrees of freedom";
  qui summ dof;
  if r(min)==r(max) {;
    local dof=r(min);
  };
  else {;
    local dof=.;
  };
};


* Add msetype if requested *;
if "`msetype'"!="" {;
  qui gene str1 msetype="";
  lab var msetype "Parameter matrix stripe element type";
  forv i1=1(1)`nparm' {;
    local parmcur=parm[`i1'];
    _ms_parse_parts `"`parmcur'"';
    qui replace msetype=`"`r(type)'"' in `i1';
  };
};


* Add omit if requested *;
if "`omit'"!="" {;
    tempname omitmat rvesti;
    matr def `rvesti'=`cvesti'';
    _ms_omit_info `rvesti';
    matr def `omitmat'=r(omit);
    matr def `omitmat'=`omitmat'';
    matr colnames `omitmat'="omit";
    svmat `omitmat', names(col);
    qui compress omit;
    lab var omit "Parameter omit status";
};


* Add empty if requested *;
if "`empty'"!="" {;
    tempname emptymat rvesti;
    matr def `rvesti'=`cvesti'';
    _ms_empty_info `rvesti';
    matr def `emptymat'=r(empty);
    matr def `emptymat'=`emptymat'';
    matr colnames `emptymat'="empty";
    svmat `emptymat', names(col);
    qui compress empty;
    lab var empty "Parameter empty cell status";
};


* Add label if requested *;
if "`label'" != "" {;
        tempname labscal;
        qui gene str1 label = "";
        local i1 = 0;
        while `i1' < `nxv' {;
                local i1 = `i1' + 1;
                mata: st_strscalar("`labscal'",st_local("lab`i1'"));
                qui replace label = `labscal' in `i1';
        };
        order eq parm label;
        label variable label "Parameter label";
};


* Add ylabel if requested *;
if "`ylabel'" != "" {;
        tempname ylabscal;
        qui gene str1 ylabel = "";
        forv i1=1(1)`nyv' {;
                mata: st_strscalar("`ylabscal'",st_local("ylab`i1'"));
                qui replace ylabel = `ylabscal' in `i1';
        };
        if "`label'"=="" {;
          order eq parm ylabel;
        };
        else {;
          order eq parm label ylabel;
        };
        label variable ylabel "Y-variable label";
};


* Drop variable eq if it contains only underscores *;
qui {;
        count if eq == "_";
        if r(N) == _N {;
          drop eq;
        };
};


*
 Set null value to be passed to parmcip
*;
if "`eform'"=="" {;
  local pnullvalue "`nullvalue'";
};
else {;
  local pnullvalue=log(`nullvalue');
  if missing(`pnullvalue') {;
    disp as error "Missing value for log of nullvalue(`nullvalue')"
      _n "nullvalue() must be positive if eform is specified";
    error 498;
  };
};


*
 Add t-statistics or z-statistics, P-values, confidence limits,
 and stars if requested
*;
qui parmcip, fast level(`level') `stars' `clnumber' `mcompare' `mcomci' `zerop' nullvalue(`pnullvalue');


*
 EForm transformation if requested
*;
if "`eform'" != "" {;
        qui {;
                replace estimate = exp(estimate);
                replace stderr = stderr * estimate;
                foreach cimin of var min* {;
                    replace `cimin' = exp(`cimin');
                };
                foreach cimax of var max* {;
                    replace `cimax' = exp(`cimax');
                };

        };
};


*
 Compress CI and P-value related variables as far as possible
 without loss of precision
*;
qui compress;


*
 Create numeric and/or string ID variables if requested
 and move them to the beginning of the variable order
*;
if("`idstr'"!=""){;
    qui gene str1 idstr="";
    qui replace idstr=`"`idstr'"';
    qui compress idstr;
    qui order idstr;
    lab var idstr "String ID";
};
if("`idnum'"!=""){;
    qui gene double idnum=real("`idnum'");
    qui compress idnum;
    qui order idnum;
    lab var idnum "Numeric ID";
};


*
 Create scalar estimation result variables if requested
*;
if `"`escal'"'!="" {;
    local nescal:word count `escal';
    local i1=0;
    while `i1'<`nescal' {;
        local i1=`i1'+1;
        local escur:word `i1' of `escal';
        qui gene double es_`i1'=e(`escur');
        qui compress es_`i1';
        lab var es_`i1' `"e(`escur')"';
    };
};


*
 Create macro estimation result variables if requested
*;
if `"`emac'"'!="" {;
    local nemac:word count `emac';
    local i1=0;
    while `i1'<`nemac' {;
        local i1=`i1'+1;
        local emcur:word `i1' of `emac';
        qui gene str1 em_`i1'="";
        qui replace em_`i1'=`"`e(`emcur')'"';
        qui compress em_`i1';
        lab var em_`i1' `"e(`emcur')"';
    };
};


*
 Create vector estimation result variables if requested
*;
if `"`evec'"'!="" {;
    tempname emcur;
    local nevec:word count `evec';
    local i1=0;
    while `i1'<`nevec' {;
        local i1=`i1'+1;
        local evcur:word `i1' of `evec';
        cap matrix define `emcur'=e(`evcur');
        if _rc!=0 {;
                qui gene byte ev_`i1'=.;
        };
        else {;
            local nrcur=rowsof(`emcur');
            local nccur=colsof(`emcur');
            * Convert matrix to column vector if necessary *;
            if (`nrcur'==`nparm')&(`nccur'==`nparm') {;
                matrix define `emcur'=vecdiag(`emcur');
                matrix define `emcur'=`emcur'';
            };
            else if `nccur'==`nparm' {;
                matrix define `emcur'=`emcur'';
                matrix define `emcur'=`emcur'[1..`nccur',1];
            };
            else if `nrcur'==`nparm' {;
                matrix define `emcur'=`emcur'[1..`nrcur',1];
            };
            else if `nrcur'>`nparm' {;
                matrix define `emcur'=`emcur'[1..`nparm',1];
            };
            else {;
                matrix define `emcur'=`emcur'[1..`nrcur',1];
            };
            matr colnames `emcur'="ev_`i1'";
            svmat double `emcur',name(col);
            qui compress ev_`i1';
        };
        lab var ev_`i1' `"e(`evcur')"';
    };
};


*
 Create matrix row estimation result variables if requested
*;
if `"`erows'"'!="" {;
    tempname emcur evcur;
    local nerows: word count `erows';
    forv i1=1(1)`nerows' {;
        local ercur: word `i1' of `erows';
        cap matrix define `emcur'=e(`ercur');
        if _rc!=0 {;
                qui gene byte er_`i1'_1=.;
                lab var er_`i1'_1 `"e(`ercur'), row 1"';
        };
        else {;
            * Matrix estimation result exists *;
            local nrcur=rowsof(`emcur');
            local nccur=colsof(`emcur');
            forv i2=1(1)`nrcur' {;
                if `nccur'>=`nparm' {;
                    matrix define `evcur'=`emcur'[`i2',1..`nparm'];
                };
                else {;
                    matrix define `evcur'=`emcur'[`i2',1..`nccur'];
                };
                matrix define `evcur'=`evcur'';
                matrix colnames `evcur'="er_`i1'_`i2'";
                svmat double `evcur', name(col);
                qui compress er_`i1'_`i2';
                lab var er_`i1'_`i2' `"e(`ercur'), row `i2'"';
            };
        };
    };
};


*
 Create matrix column estimation result variables if requested
*;
if `"`ecols'"'!="" {;
    tempname emcur evcur;
    local necols: word count `ecols';
    forv i1=1(1)`necols' {;
        local eccur: word `i1' of `ecols';
        cap matrix define `emcur'=e(`eccur');
        if _rc!=0 {;
                qui gene byte ec_`i1'_1=.;
                lab var ec_`i1'_1 `"e(`eccur'), column 1"';
        };
        else {;
            * Matrix estimation result exists *;
            local nrcur=rowsof(`emcur');
            local nccur=colsof(`emcur');
            forv i2=1(1)`nccur' {;
                if `nrcur'>=`nparm' {;
                    matrix define `evcur'=`emcur'[1..`nparm',`i2'];
                };
                else {;
                    matrix define `evcur'=`emcur'[1..`nrcur',`i2'];
                };
                matrix colnames `evcur'="ec_`i1'_`i2'";
                svmat double `evcur', name(col);
                qui compress ec_`i1'_`i2';
                lab var ec_`i1'_`i2' `"e(`eccur'), column `i2'"';
            };
        };
    };
};


*
 Recast double-precision variables to float if requested
*;
if "`float'"!="" {;
    unab allvar:*;
    foreach X of var `allvar' {;
        local Xtype:type `X';
        if "`Xtype'"=="double" {;
            qui recast float `X',force;
            qui compress `X';
        };
    };
};


*
 Rename variables if requested
 (This section is duplicated in parmby.)
*;
if "`rename'"!="" {;
    local nrename:word count `rename';
    if mod(`nrename',2) {;
        disp as text "Warning: odd number of variable names in rename list - last one ignored";
        local nrename=`nrename'-1;
    };
    local nrenp=`nrename'/2;
    local i1=0;
    while `i1'<`nrenp' {;
        local i1=`i1'+1;
        local i3=`i1'+`i1';
        local i2=`i3'-1;
        local oldname:word `i2' of `rename';
        local newname:word `i3' of `rename';
        cap{;
            confirm var `oldname';
            confirm new var `newname';
        };
        if _rc!=0 {;
            disp as text "Warning: it is not possible to rename `oldname' to `newname'";
        };
        else {;
            rename `oldname' `newname';
        };
    };
};


*
 Format variables if requested
 (This section is duplicated in parmby.)
*;
if `"`format'"'!="" {;
    local vlcur "";
    foreach X in `format' {;
        if strpos(`"`X'"',"%")!=1 {;
            * varlist item *;
            local vlcur `"`vlcur' `X'"';
        };
        else {;
            * Format item *;
            unab Y : `vlcur';
            conf var `Y';
            cap format `Y' `X';
            local vlcur "";
        };
    };
};


*
 List variables if requested
 (This section is nearly duplicated in parmby.)
*;
if `"`list'"'!="" {;
    list `list';
};


*
 Save data set if requested
 (This section is duplicated in parmby.)
*;
if(`"`saving'"'!=""){;
    capture noisily save `saving';
    if(_rc!=0){;
        disp as error `"saving(`saving') invalid"';
        exit 498;
    };
    tokenize `"`saving'"',parse(" ,");
    local fname `"`1'"';
    if(strpos(`"`fname'"'," ")>0){;
        local fname `""`fname'""';
    };
    * Add filename to file list in FList if requested *;
    if(`"`flist'"'!=""){;
        if(`"$`flist'"'==""){;
            global `flist' `"`fname'"';
        };
        else{;
            global `flist' `"$`flist' `fname'"';
        };
    };
};


*
 Copy new frame to old frame if requested
*;
if "`restore'"=="norestore" {;
  frame copy `tempframe' `oldframe', replace;
};


};
*
 End of frame block (NOT INDENTED)
*;


*
 Rename temporary frame to frame name (if frame is specified)
 and change current frame to frame name (if requested)
*;
if "`framename'"!="" {;
  if "`framereplace'"=="replace" {;
    cap frame drop `framename';
  };
  frame rename `tempframe' `framename';
  if "`framechange'"!="" {;
    frame change `framename';
  };
};


*
 Return saved results
*;
return local dfmatrix `"`dfmatrix'"';
return local vmatrix `"`vmatrix'"';
return local bmatrix `"`bmatrix'"';
return local eform "`eform'";
return local level "`level'";
return scalar nullvalue=`nullvalue';
return scalar nparm=`nparm';
return scalar dof=`dof';
return scalar dofpres=`dofpres';


end;


program define svroweq;
version 11.0;
/*
 Save row equation names from `matrix' in string variable `roweq'.
 (This routine is designed to be used with svmat.)
*/
args matrix roweq;

if "`matrix'" == "" {;
        di in r "No matrix specified";
        error 498;
};
if "`roweq'" == "" {;
        di in r "No variable name specified";
        error 498;
};
local nrow = rowsof(`matrix');

* Create variable `roweq' *;
tempname tempmat;
qui capture drop `roweq';
qui set obs `nrow';
qui gen str1 `roweq' = "";
local rowind = 0;
while `rowind' < `nrow'{;
        local rowind = `rowind' + 1;
        matr def `tempmat'=`matrix'[`rowind'..`rowind',1..1];
        local namec : roweq(`tempmat');
        qui replace `roweq' = "`namec'" in `rowind';
};

end;


program define svrown;
version 11.0;
/*
 Save row names from `matrix' in string variable `rowname'.
 (This routine is designed to be used with svmat.)
*/
args matrix rowname;

if "`matrix'" == "" {;
        di in r "No matrix specified";
        error 498;
};
if "`rowname'" == "" {;
        di in r "No variable name specified";
        error 498;
};
local nrow = rowsof(`matrix');

* Create variable `rowname' *;
tempname tempmat;
qui capture drop `rowname';
qui set obs `nrow';
qui gene str1 `rowname' = "";
local rowind = 0;
while  `rowind' < `nrow' {;
        local rowind = `rowind' + 1;
        matr def `tempmat'=`matrix'[`rowind'..`rowind',1..1];
        local namec : rownames(`tempmat');
        qui replace `rowname' = "`namec'" in `rowind';
};

end;

prog def frameoption, rclass;
version 16.0;
*
 Parse frame() option
*;

syntax name [, replace CHange ];

return local change "`change'";
return local replace "`replace'";
return local namelist "`namelist'";

end;
