#delim ;
prog def dsweight, sortpreserve;
version 10.0;
/*
 Input a varlist of standardization variables
 and generate a variable containing direct standardization weights,
 for input as pweights to other Stata commands,
 to produce results standardized
 by combinations of the input variables
 to the joint distribution of these variables in a target population,
 which is either the total sample,
 or a by-group,
 or an outside standard population,
 specified in a using dataset with 1 observation per combination
 of the variables in the input varlist,
 and data on frequencies of that combination in the target population.
*!Author: Roger Newson
*!Date: 18 January 2012
*/

syntax varlist [if] [in] [using/] [fweight pweight iweight aweight] , Generate(name)
  [ GRoupvars(varlist) BY(varlist) noCOmplete TFReqvar(name) sorted Missing float fast
  ];
/*
 generate() specifies the name of the new variable to be generated,
   containing direct standardization weights.
 groupvars() specifies a varlist,
   whose combinations specify groups
   within which the generated weights will standardize the distribution
   to the target population.
 by() specifies a varlist,
   whose combinations specify by-groups,
   each of which has its own target population
   to which the subsets specified by the groupvars() varlist are to be standardized,
   either in the total sample in the by-group
   or in an outside target population specified by corresponding by-groups
   in the using dataset.
 nocomplete specifies that all combinations of the input varlist
   do not have to be represented in each combination of the groupvars() varlist,
   either in the whole input sample
   or in the by-group if by() is specified.
 tfreqvar() specifies the name of a numeric variable in the using dataset,
   containing (or proportional to) the frequency, in each observation,
   of the corresponding combination of the input varlist in the target population.
 sorted specifies that the using dataset is already sorted
   primarily by the by-variables (if by() is specified)
   and secondarily by the varlist,
   so dsweight does not have to do so.
 missing specifies that missing direct standardization weights may be generated.
 float specifies that the generated variable specified by generate()
   will have type float or lower.
 fast specifies that dsweight will not do any work
   to restore the original input dataset
   if the user presses Break.
*/

*
 Set target frequency variable name if required
 and check that it does not already exist
*;
if `"`using'"'!="" {;
  if "`tfreqvar'"=="" {;local tfreqvar="_freq";};
  cap conf var `tfreqvar';
  if !_rc {;
    disp as error "Variable `tfreqvar' already exists";
    error 498;
  };
};

if "`fast'"=="" {;preserve;};

marksample touse, strok;
markout `touse' `groupvars', strok;

*
 Generate input weights
*;
tempvar inpwei;
if `"`exp'"'=="" {;
  qui gene byte `inpwei'=1 if `touse';
};
else {;
  qui gene double `inpwei' `exp' if `touse';
  qui compress `inpwei';
};

*
 Calculate sample and target population sums of weights
*;
tempvar sampsw tarpsw;
qui bysort `touse' `by' `varlist' `groupvars': egen `sampsw'=total(`inpwei') if `touse';
if `"`using'"'=="" {;
  * Target population is total sample *;
  qui by `touse' `by' `varlist': egen double `tarpsw'=total(`inpwei') if `touse';
};
else {;
  * Target population is specified in using dataset *;
  qui {;
    sort `by' `varlist';
    merge m:1 `by' `varlist' using `"`using'"', `sorted' noreport nolabel nonotes nogenerate keep(master match) keepus(`tfreqvar');
    gene double `tarpsw'=`tfreqvar' if `touse';
    drop `tfreqvar';
  };
};
qui {;
  compress `sampsw' `tarpsw';
  gene double `generate'=`tarpsw'/`sampsw' if `touse';
  if "`float'"!="" {;recast float `generate', force;};
  compress `generate';
};

*
 Check for missing standardization weights if required
*;
if "`missing'"=="" {;
  tempname nmiss;
  qui count if `touse' & missing(`generate');
  scal `nmiss'=r(N);
  if `nmiss'>0 {;
    disp as error "Missing standardization weights for " `nmiss' "observations in the sample"
      _n as error "Use option missing to allow missing standardization weights";
    error 498;
  };
};

*
 Check for completeness if required
*;
if "`complete'"!="nocomplete" {;
  tempvar tag1 sumtag1 tag2 sumtag2;
  tempname nincomp;
  qui {;
    bysort `touse' `by' `varlist': gene byte `tag1'=_n==1 if `touse';
    by `touse' `by': egen double `sumtag1'=total(`tag1') if `touse';
    bysort `touse' `by' `groupvars' `varlist': gene byte `tag2'=_n==1 if `touse';
    by `touse' `by' `groupvars': egen double `sumtag2'=total(`tag2') if `touse';
    compress `sumtag1' `sumtag2';
    count if `touse' & (`sumtag1'!=`sumtag2');
    scal `nincomp'=r(N);
  };
  if `nincomp'>0 {;
    disp as error `nincomp' " observations in the sample are in groups"
      _n as error "defined by variables:"
      _n as error "`groupvars'"
      _n as error "with incomplete range of value combinations for variables:"
      _n as error "`varlist'"
      _n as error "Use option nocomplete to allow incomplete groups";
    error 498;
  };
};

if "`fast'"=="" {;restore, not;};

end;
