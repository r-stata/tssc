#delim ;
prog def smileplot7,rclass byable(onecall) sortpreserve;
version 7.0;
/*
 Create smile plot of inverse log P-value against estimate
 for data points corresponding to estimated model parameters,
 with Y-axis lines corresponding to an uncorrected P-value threshold
 and a corrected P-value threshold according to a multiple test procedure.
 -smileplot- works by calling -multproc- and -graph-
 and is usually used with a data set created as output
 by -parmby- or -parmest-.
*! Author: Roger Newson
*! Date: 07 May 2003
*/
syntax [if] [in] [ , PValue(varname numeric)
  PUncor(passthru) PCor(passthru) MEthod(passthru)
  RAnk(passthru) GPUncor(string) CRitical(passthru) GPCor(string)
  NHcred(passthru) REJect(passthru) FLOAT FAST
  EStimate(varname numeric)
  * ];
/*
 The first list of options are passed to -multproc-.
 -pvalue- is the variable containing the P-values.
 -puncor- is the uncorrected P-value threshold
  (set to $S_level if absent or out of range [0,1]).
 -pcor- is the corrected P-value threshold
  (set according to -method- option if absent or out of range [0,1])
 -method- specifies the method used to calculate corrected P-values
  and is overridden and set to userspecified if -pcor- is in range [0,1]
 -rank- is a new variable generated to contain the ranks of the P-values
  (from lowest to highest, with ties sorted in original order).
 -gpuncor- is a new variable generated to contain the uncorrected P-value threshold used.
 -critical- is a new variable generated to contain critical P-value thresholds
  corresponding to the P-values in -pvalue-
  (for use in a one-step, step-up or step-down procedure).
 -gpcor- is a new variable generated to contain, for all observations in each by-group,
  the overall corrected P-value threshold calculated for that by-group.
 -nhcred- is a new variable generated to contain an indicator
  that the null hypothesis for that observation is credible,
  given the choice of uncorrected P-threshold and method.
 -reject- is a new variable generated to contain an indicator
  that the null hypothesis for that observation is rejected,
  given the choice of uncorrected P-threshold and method.
 -float- specifies that the critical P-values
  in the variables -gpuncor-, -critical- and -gpcor-
  will be saved as -float- variables (instead of -double- variables).
 -fast- is an option for programmers,
  specifying that -smileproc- will take no action to restore the pre-existing data set
  if the user presses -break-.
 The other options are passed to only -_smplot-.
 -estimate- is the variable containing estimates.
 Other graph options are stored in -options- to be passed to -_smplot-.
*/

* Define by-group prefix *;
if !_by() {;local bypref="";};
else {;
  local bypref "by `_byvars' `_byrc0':";
};

*
 Default variable names for estimate and P-value
 (assumed to be from a -parmest- output data set)
*;
if "`pvalue'"=="" {;
  confirm numeric variable p;
  local pvalue "p";
};
if "`estimate'"=="" {;
  confirm numeric variable estimate;
  local estimate "estimate";
};

*
 Select sample for plotting
 and count the P-values in -npvalue-
*;
local varlist "`pvalue' `estimate'";
marksample touse;
qui count if `touse';
local npvalue=r(N);
if `npvalue'==0 {;error 2000;};

if "`fast'"=="" {;preserve;};

*
 Initialise options -gpuncor- and -gpcor- to temporary variables if necessary
*;
foreach X of any gpuncor gpcor {;
  if "``X''"=="" {;tempvar `X';};
  else {;confirm new variable ``X'';};
};

*
 Carry out multiple test procedure,
 creating new variables if requested
*;
if _by() {;disp _n as text "Multiple test procedure for each by-group:";};
`bypref' multproc if `touse',pvalue(`pvalue')
 `puncor' `pcor' `method'
 `rank' gpuncor(`gpuncor') `critical' gpcor(`gpcor') `nhcred' `reject' `float' fast;
return add;

* Call _smplot to create smile plots *;
if _by() {;disp _n as text "Smile plot for each by-group:";};
`bypref' _smplot if `touse', pvalue(`pvalue') estimate(`estimate')
  puncor(`gpuncor') pcor(`gpcor') `options';
return add;

if "`fast'"=="" {;restore,not;};

end;

prog def _smplot,rclass byable(recall);
version 7.0;
/*
  Create smile plot for each by-group.
  Author: Roger Newson
  Date: 06 May 2003
*/

syntax [if] [in] , pvalue(varname numeric) estimate(varname numeric) puncor(varname numeric) pcor(varname numeric)
  [  LOGBase(real 10)
  NLine(numlist min=1 max=1 missingokay)
  PTSymbol(string) PTLabel(varname)
  Symbol(string) YLOG YReverse RReverse noBORder
  XLOG
  XLIne(numlist) YLIne(numlist >0 <=1)
  YLAbel(numlist >0 <=1) RLAbel(numlist >0 <=1)
  SAving(passthru)
  * ];
/*
 -pvalue- is the variable containing the P-values.
 -estimate- is the variable containing estimates.
 -puncor- is the variable containing
  the uncorrected overall critical P-value for the by-group
  (expected to be constant within the by-group).
 -pcor- is the variable containing
  the corrected overall critical P-value for the by-group
  (expected to be constant within the by-group).
 -logbase- is the log base used for calculating default Y-axis labels.
 -nline- is the position on the X-axis of the reference line
 -ptsymbol- is indicator for the symbols (defaulting to T for triangle).
 -ptlabel- is the variable containing plot point labels.
  indicating the value of the parameter under the null hypothesis.
 The remaining options are all -graph- options, modified as necessary,
 and then passed on to -graph-..
 -symbol- causes the program to ignore -symbol- as a -graph- option.
 -ylog- causes the program to ignore -ylog- as a -graph- option.
 -yreverse- causes the program to ignore -yreverse- as a -graph- option.
 -rreverse- causes the program to ignore -rreverse- as a -graph- option.
 -noborder- causes the program to ignore -noborder- as a -graph- option.
 -xlog- indicates that the X-axis must be logged (eg for odds ratios).
 -xline- contains additional X-axis lines
  (apart from the one corresponding to null hypotheses at -nline-).
 -yline- contains additional Y-axis lines
  (apart from the ones corresponding to uncorrected and corrected overall critical P-values).
 -ylabel- may override the default Y-axis labels.
 -rlabel- may override the default R-axis labels.
 -saving- is used by -_smplot- to check that it is not being specified
  at the same time as -by varlist:-,
  and, if not, then it is passed to -graph-.
 Other graph options are stored in -options- to be passed to -graph-.
*/

*
 Select sample for plotting
 and count the P-values in -npvalue-
*;
local varlist "`pvalue' `estimate'";
marksample touse;
qui count if `touse';
local npvalue=r(N);
if `npvalue'==0 {;error 2000;};

*
 Convert options -puncor- and -pcor- from variables to numbers
*;
foreach X in puncor pcor {;
  qui summ ``X'' if `touse';
  local `X'=r(min);
};
* Warn if uncorrected or corrected overall critical P-values are unplottable *;
if (`puncor'<=0)|(`puncor'>1) {;
  disp as text "Note: Uncorrected overall critical P-value of `puncor' cannot be plotted on a smile plot";
};
if `pcor'==0 {;
  disp as text "Note: Corrected overall critical P-value of `pcor' cannot be plotted on a smile plot";
};

*
 Calculate minimum P-value
 and check that all P-values are legal
 and that some P-values are non-zero
*;
qui count if `touse'&((`pvalue'<0)|(`pvalue'>1));
local npinval=r(N);
if `npinval'>0 {;
  disp as error "`npinv' P-values are outside the range 0<=P<=1";
  error 498;
};
qui summ `pvalue' if `touse'&(`pvalue'>0);
if r(N)<=0 {;
  disp as text "All P-values are zero. Smile plot cannot be created.";
  exit;
};
else {;
 local pvmin=r(min);
 if (`puncor'>0)&(`puncor'<`pvmin') {;local pvmin=`puncor';};
 if (`pcor'>0)&(`pcor'<`pvmin') {;local pvmin=`pcor';};
 qui count if `touse'&(`pvalue'==0);
 local npzero=r(N);
 if `npzero'>0 {;
   disp as text "Note: `npzero' individual P-values are zero and cannot be plotted on a smile plot";
 };
};

*
 Screen out invalid values of -logbase-
*;
if `logbase'<=0 {;
  disp as error "Invalid value of logbase: `logbase'";
  error 498;
};

*
 Check that -saving- and -by varlist:- are not being combined
*;
if _by()&(`"`saving'"'!="") {;
  disp as error "saving() option may not be combined with by varlist:";
  error 190;
};

* Compute labels of R-axis if not provided *;
if "`rlabel'"=="" {;
  if `puncor'>0 {;local rlabel "`rlabel' `puncor'";};
  if `pcor'>0 {;local rlabel "`rlabel' `pcor'";};
};
if "`rlabel'"!="" {;local rlabel "rlabel(`rlabel')";};

* Symbols and labels for plot points *;
if "`ptsymbol'"=="" {;local ptsymbol "T";};
if "`ptlabel'"=="" {;
  tempvar ptlabel;
  qui gene str1 `ptlabel'="";
};

*
 Add Y-axis lines at uncorrected and corrected P-threshold
 and an X-axis line at the value of -nline-
 (defaulting to zero or one,
 depending if the X-axis is to be logged)
*;
if (`puncor'>0)&(`puncor'<=1) {;local yline "`yline' `puncor'";};
if (`pcor'>0)&(`pcor'<=1) {;local yline "`yline' `pcor'";};
if "`yline'"!="" {;local yline "yline(`yline')";};
if "`nline'"=="" {;
  if "`xlog'"=="" {;local nline=0;};
  else {;local nline=1;};
};
if !missing(`nline'){;local xline "`xline' `nline'";};
if "`xline'"!="" {;local xline "xline(`xline')";};

*
 Compute Y-axis labels if not provided
*;
if "`ylabel'"=="" {;
  * Maximum number of Y-axis labels *;
  local ylabmax=25;
  * Minimum -log(P-value) to base -logbase- *;
  local mlmin=-log(`pvmin')/log(`logbase');
  if `mlmin'!=int(`mlmin') {;local mlmin=int(`mlmin')+1;};
  * Y-axis label interval (in log units to base -logbase-) *;
  local ylabint=`mlmin'/(`ylabmax'-1);
  if `ylabint'!=int(`ylabint') {;local ylabint=int(`ylabint')+1;};
  * Compute Y-axis labels *;
  explist 0(-`ylabint')-`mlmin',base(`logbase');
  local ylabel "`r(explist)'";
};
if "`ylabel'"!="" {;local ylabel "ylabel(`ylabel')";};

* Create graph *;
graph7 `pvalue' `pvalue' `estimate' if `touse'&(`pvalue'>0),s(`ptsymbol'[`ptlabel'])
  `saving'
  ylog yreverse `ylabel' `yline'
  `xlog' `xline'
  `rlabel' border
  `options';
return add;
if _by() {;more;};

end;

prog def explist,rclass;
version 7.0;
/*
 Take, as input, a list of numbers,
 and create, as output, a new list of numbers of the same length,
 equal to an exponentiated version of the input list.
 Author: Roger Newson
 Date: 06 May 2003
*/

* Get the list of numbers *;
gettoken list 0 : 0, parse(",");
if "`list'" == "" | "`list'" == "," {; 
  di as error "no list specified";
  exit 198;
};
numlist "`list'";                       
local list "`r(numlist)'";
local nnum : word count `list';

* Get the options *;
syntax [ , Base(real 10) Scale(real 1) Global(string) Noisily ];

/*
  -base- is the base of the logarithmic list.
  -scale- is a scale factor for the new list.
  -global- is the name of a global variable to store the new list.
  -noisily- specifies that the new list must be printed.
  Each number in the new list is equal to scale*base^Z,
  where Z is the corresponding number in the input list.
*/

* Create exponentiated list *;
local explist "";
forv i1=1(1)`nnum' {;
  local Z:word `i1' of `list';
  local expcur=`scale'*`base'^`Z';
  if "`explist'"=="" {;local explist "`expcur'";};
  else {;local explist "`explist' `expcur'";};
};

* Return results, printing and globalising if requested *;
return local explist "`explist'";
if "`global'"!="" {;global `global' "`explist'";};
if "`noisily'"!="" {;disp as result "`explist'";};

end;
