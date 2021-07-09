#delim ;
prog def smileplot,rclass byable(onecall) sortpreserve;
version 10.0;
/*
 Create smile plot of inverse log P-value against estimate
 for data points corresponding to estimated model parameters,
 with Y-axis lines corresponding to an uncorrected P-value threshold
 and a corrected P-value threshold according to a multiple test procedure.
 -smileplot- works by calling -multproc- and -graph-
 and is usually used with a data set created as output
 by -parmby- or -parmest-.
*! Author: Roger Newson
*! Date: 03 July 2008
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
version 10.0;
/*
  Create smile plot for each by-group.
  Author: Roger Newson
  Date: 03 July 2008
*/

syntax [if] [in] , pvalue(varname numeric) estimate(varname numeric)
  puncor(varname numeric) pcor(varname numeric)
  [  LOGBase(real 10) MAXYLABS(integer 25)
  XLOG
  NLine(numlist min=1 max=1 missingokay)
  PTSymbol(string) PTLabel(varname)
  SCATTEROPTS(string asis)
  REFOPTS(string asis) UREFOPTS(string asis) CREFOPTS(string asis) NREFOPTS(string asis)
  ADDPLOT(string asis) PLOT(string asis)
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
 -maxylabs- gives the default maximum number of Y-axis labels,
  used with -logbase- to calculate Y-axis labels spaced equally
  on an exponential scale.
 -xlog- indicates that the X-axis must be logged (eg for odds ratios).
 -nline- is the position on the X-axis of the reference line
 -ptsymbol- is indicator for the symbols (defaulting to T for triangle).
 -ptlabel- is the variable containing plot point labels.
  indicating the value of the parameter under the null hypothesis.
 -scatteropts- is a list of options appropriate for -graph twoway scatter-
  (other than axis selection options),
  governing the presentation of the data points of the smile plot
  and their labels and/or lines (if any),
  and these options may override the defaults implied by -ptsymbol- and -ptlabel-.
 -refopts- is a list of added line options (other than -axis-)
  for the axis reference lines of the smile plot,
  assumed to be the same for all reference lines except if otherwise specified.
 -urefopts- is a list of added line options
  for the uncorrected critical P-value reference line,
  allowing these options to be different from those for the other reference lines.
 -crefopts- is a list of added line options
  for the corrected critical P-value reference line,
  allowing these options to be different from those for the other reference lines.
 -nrefopts- is a list of added line options
  for the null hypothesis reference line,
  allowing these options to be different from those for the other reference lines.
 -addplot- is an additional plot option,
  allowing the user to overlay extra plots on top of the smile plot.
 -plot- is an obsolete Stata 8 name for -addplot-,
  retained so that old do-files will still work.
 The remaining options are all -graph twoway- options, modified as necessary,
 and then passed on to -graph twoway-.
 -saving- is used by -_smplot- to check that it is not being specified
  at the same time as -by varlist:-,
  and, if not, then it is passed to -graph-.
 Other -graph twoway- options are stored in -options- to be passed to -graph twoway-.
*/

*
 Set -addplot()- option if given as -plot()- option
*;
if `"`addplot'"'=="" {;
  local addplot `"`plot'"';
};
else if `"`plot'"'!="" {;
  disp as error "Options addplot() and plot() are alternatives and cannot both be specified";
  error 498;
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

*
 Convert options -puncor- and -pcor- from variables to numbers
*;
foreach X in puncor pcor {;
  qui summ ``X'' if `touse';
  local `X'=r(min);
};
* Warn if uncorrected or corrected overall critical P-values are unplottable *;
if (`puncor'<=0)|(missing(`puncor')) {;
  disp as text "Note: Uncorrected overall critical P-value of `puncor' cannot be plotted on a smile plot";
};
if (`pcor'<=0)|(missing(`pcor')) {;
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
 if !missing(`puncor')&(`puncor'>0)&(`puncor'<`pvmin') {;local pvmin=`puncor';};
 if !missing(`pcor')&(`pcor'>0)&(`pcor'<`pvmin') {;local pvmin=`pcor';};
 qui count if `touse'&(`pvalue'==0);
 local npzero=r(N);
 if `npzero'>0 {;
   disp as text "Note: `npzero' individual P-values are zero and cannot be plotted on a smile plot";
 };
};

*
 Screen out invalid values of -logbase- and -maxylabs-
*;
if (`logbase'<=0) | missing(`logbase') {;
  disp as error "Invalid value of logbase: `logbase'";
  error 498;
};
if (`maxylabs'<2) | missing(`maxylabs') {;
  disp as error "Invalid value of maxylabs: `maxylabs'";
};

*
 Check that -saving- and -by varlist:- are not being combined
*;
if _by()&(`"`saving'"'!="") {;
  disp as error "saving() option may not be combined with by varlist:";
  error 190;
};

* Set default point symbol *;
if `"`ptsymbol'"'=="" {;local ptsymbol "Th";};

* Set default null hypothesis line value for X-axis *;
if "`nline'"=="" {;
  if "`xlog'"=="" {;local nline=0;};
  else {;local nline=1;};
};

*
 Set default added line options for reference lines
*;
if `"`refopts'"'=="" {;local refopts "lstyle(xyline)";};
if `"`nrefopts'"'=="" {;local nrefopts `"`refopts'"';};
if `"`urefopts'"'=="" {;local urefopts `"`refopts'"';};
if `"`crefopts'"'=="" {;local crefopts `"`refopts'"';};

*
 Set default -graph twoway scatter- options for smile plots
*;
local scatteropts_def `"msymbol(`ptsymbol')"';
if "`ptlabel'"!="" {;local scatteropts_def `"`scatteropts_def' mlabel(`ptlabel')"';};

*
 Set default axis added line options
*;
local addline_def "";
if !missing(`nline') {;local addline_def `"`addline_def' xline(`nline',`nrefopts')"';};
if !missing(`puncor')&(`puncor'>0) {;local addline_def `"`addline_def' yline(`puncor',`urefopts')"';};
if !missing(`pcor')&(`pcor'>0) {;local addline_def `"`addline_def' yline(`pcor',`crefopts')"';};

*
 Set default axis label options
*;
* Right Y-axis labels *;
local rlabdef "";
if !missing(`puncor')&(`puncor'>0) {;local rlabdef "`rlabdef' `puncor'";};
if !missing(`pcor')&(`pcor'>0) {;local rlabdef "`rlabdef' `pcor'";};
* Left Y-axis labels *;
* Minimum -log(P-value) to base -logbase- *;
local mlmin=-log(`pvmin')/log(`logbase');
if `mlmin'!=int(`mlmin') {;local mlmin=int(`mlmin')+1;};
* Y-axis label interval (in log units to base -logbase-) *;
local ylabint=`mlmin'/(`maxylabs'-1);
if `ylabint'!=int(`ylabint') {;local ylabint=int(`ylabint')+1;};
* Compute Y-axis labels *;
explist 0(-`ylabint')-`mlmin',base(`logbase');
local ylabdef "`r(explist)'";
local label_def "";
if "`ylabdef'"!="" {;local label_def `"`label_def' ylabel(`ylabdef',axis(1) angle(0))"';};
if "`rlabdef'"=="" {;local label_def `"`label_def' ylabel(,axis(2) nolabel nogrid)"';};
else {;local label_def `"`label_def' ylabel(`rlabdef',axis(2) angle(0))"';};

*
 Set default axis scale options
*;
local nylabdef:word count `ylabdef';
local yscmin:word 1 of `ylabdef';
local yscmax:word `nylabdef' of `ylabdef';
local scale_def "yscale(range(`yscmin' `yscmax') axis(1) log reverse)";
if "`xlog'"=="" {;local scale_def `"`scale_def' xscale(axis(1) nolog)"';};
else {;local scale_def `"`scale_def' xscale(axis(1) log)"';};

*
 Set default axis title options
*;
local ytitdef:var lab `pvalue';
if `"`ytitdef'"'=="" {;local ytitdef "`pvalue'";};
local xtitdef:var lab `estimate';
if `"`xtitdef'"'=="" {;local xtitdef "`estimate'";};
local title_def
 `" ytitle(`"`ytitdef'"',axis(1)) ytitle("",axis(2)) xtitle(`"`xtitdef'"',axis(1)) "';

*
 Create graph
*;
graph twoway
  scatter `pvalue' `estimate' if `touse'&(`pvalue'>0), xaxis(1) yaxis(1 2) `scatteropts_def' `scatteropts' ||
  `addplot' || ,
  legend(off) `scale_def' `addline_def' `label_def' `title_def' `saving' `options';
return add;
if _by() {;more;};

end;

prog def explist,rclass;
version 10.0;
/*
 Take, as input, a list of numbers,
 and create, as output, a new list of numbers of the same length,
 equal to an exponentiated version of the input list.
 Author: Roger Newson
 Date: 03 July 2008
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
