#delim ;
prog def scdsweight, sortpreserve;
version 10.0;
/*
 Input a varlist of standardization variables
 and a binary scenario variable name,
 and generate a variable containing scenario-comparison direct standardization weights,
 for input as pweights to the scsomersd command,
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
*!Date: 31 January 2012
*/

syntax varlist [if] [in] [using] [fweight pweight iweight aweight] , Generate(name) SCenvar(varname numeric)
  [ BY(varlist) noCOmplete TFReqvar(name) sorted Missing float fast
  ];
/*
 generate() specifies the name of the new variable to be generated,
   containing direct standardization weights.
 scenvar() specifies a binary scenario variable,
   specifying a scenario,
   with the feature that the generated weights will standardize the distribution
   of observations with a scenario-variable value of 1
   to the target population,
   and will be 0 for observations with a scenario value of 0..
 by() specifies a varlist,
   whose combinations specify by-groups,
   each of which has its own target population
   to which the subset specified by the scenvar() variable is to be standardized,
   either in the total sample in the by-group
   or in an outside target population specified by corresponding by-groups
   in the using dataset.
 nocomplete specifies that all combinations of the input varlist
   do not have to be represented in the scenario specified by the scenvar() variable,
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
 fast specifies that scdsweight will not do any work
   to restore the original input dataset
   if the user presses Break.
*/

if "`fast'"=="" {;preserve;};

marksample touse, strok;
markout `touse' `scenvar';

*
 Check that scenario variable contains only values 0 and 1 in observations to be used
*;
cap assert inlist(`scenvar',0,1) if `touse';
if _rc {;
  disp _n as error "Variable `scenvar' has values other than 0 or 1";
  error 498;
};

*
 Compute weights
*;
dsweight `varlist' if `touse' `using' [`weight'`exp'], generate(`generate') groupvar(`scenvar')
  nocomplete fast by(`by') tfreqvar(`tfreqvar') `sorted' `missing' `float';
qui replace `generate'=0 if `touse' & `scenvar'==0;

*
 Check for completeness if required
*;
if "`complete'"!="nocomplete" {;
  tempvar tag1 sumtag1 tag2 sumtag2;
  tempname nincomp;
  qui {;
    bysort `touse' `by' `varlist': gene byte `tag1'=_n==1 if `touse';
    by `touse' `by': egen double `sumtag1'=total(`tag1') if `touse';
    bysort `touse' `by' `scenvar' `varlist': gene byte `tag2'=_n==1 if `touse' & `scenvar';
    by `touse' `by' `scenvar': egen double `sumtag2'=total(`tag2') if `touse' & `scenvar';
    compress `sumtag1' `sumtag2';
    count if `touse' & `scenvar' & (`sumtag1'!=`sumtag2');
    scal `nincomp'=r(N);
  };
  if `nincomp'>0 {;
    disp as error `nincomp' " observations are in the scenario defined by `scenvar'"
      _n as error "with incomplete range of value combinations for variables:"
      _n as error "`varlist'"
      _n as error "Use option nocomplete to allow an incomplete scenario";
    error 498;
  };
};

if "`fast'"=="" {;restore, not;};

end;
