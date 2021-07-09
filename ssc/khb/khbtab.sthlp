{smcl}
{* September 9, 2015 @ 09:38:31}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "khbtab" "khbtab"}{...}

{title:Title}

{phang} {cmd:khb} Table of KHB-corrected coefficients of nested non-linear probabiltiy models{p_end}

{title:Syntax}

{p 8 17 2}
   {cmd: khbtab}
   {it:model-type}
   {it:depvar} {varlist} || {varlist} [ || {varlist} || ... ] 
   [ {help using} filename ] {ifin}
   {weight}
[ {cmd:, } {it: options} ]
{p_end}

{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}

{syntab :Main}
{synopt:{opt nopreserve}}keep residuals and estimates{p_end}
{synopt:{opt p:refix(prefix_cmd)}}prefix models with bootstrap, svy, etc ...{p_end}
{syntab :KHB-options}
{synopt:{opt vce(vcetype)}}vcetype may be {cmd:robust}, {cmd:cluster}
{it:clustvar}{p_end}
{synopt:{opt ape}}display average partial (marginal) effects{p_end}
{synopt:{opt continuous}}treat dummy variables as continuous when ape{p_end}
{syntab :Reporting options}
{synopt:{opt esttab}} use esttab instad of estimates table{p_end}
{synopt:{opt t:ableoptions(...)}} options allowed for {help estimates table} or {help esttab}{p_end}
{synoptline}
{p2colreset}{...}

{pstd} {it:model-type} can be any of {help regress}, {help logit},
{help ologit}, {help probit}, {help oprobit}, {help cloglog}, {help slogit},
{help scobit}, {help rologit}, {help clogit}, {help xtlogit},
{help xtprobit} and {help mlogit}. Other models might also produce
output but for the time being this output is considered to be
"experimental".{p_end}

{pstd}{help fvvarlist:Factor variables} are allowed for Stata 12 or
higher. Factor variables are allowed.{p_end}

{pstd}aweights, fweights, iweights, and pweights are allowed if they
    are allowed in the specified {it:model-type}; see {help weight}.  

{title:Description}

{pstd}{cmd:khbtab} creates a table of nested non-linear probability
models with all coefficients expressed in the scale of the most
saturated model (see {help help khb}). Basically, the command allows
the user to insert pipe symbols (||) to separate a model with many
independend variables into layers of nested models. For example
{p_end}

{pstd}{cmd: . use dlsy_khb.dta}{p_end}
{pstd}{cmd:. khbtab logit univ intact boy || fses || abil} {p_end}

{pstd} creates a table of the regression coefficients of the following
logistic regression models:{p_end}

{pstd}{cmd:. logit univ intact boy} {p_end}
{pstd}{cmd:. logit univ intact boy fses } {p_end}
{pstd}{cmd:. logit univ intact boy fses abil} {p_end}

{pstd} The KHB method is used to rescale all coefficients in the
table to the scale of the most saturated model, i.e. to the scale of
the last model.
{p_end}

{title:Options}

{phang}{opt nopreserve} By default, {cmd:khbtab} leaves the dataset
  unchanged, i.e. it does not keep the created residuals stored
  estimates. With option {cmd:nopreserve} residuals and the results of
  the estimated models remain in the dataset. {p_end}

{phang}{opt p:refix(prefix_cmd)} allows to specify the following
  prefix commands to be used in front of each of the regression
  commands:{p_end}

{pmore}o bootstrap{p_end}
{pmore}o jackknife{p_end}
{pmore}o svy{p_end}
{pmore}o svy linearized{p_end}
{pmore}o svy bootstrap{p_end}
{pmore}o svy jackknife{p_end}
{pmore}o svy brr{p_end}
{pmore}o svy sdr{p_end}

{pmore}Note that all prefixes with {cmd:svy} require appropriate setting
of the dataset; see {help help svyset}. Note also that any weights
defined with {help svyset} will be used automatically if prefix
{cmd:svy} is being used. The user must not specifiy further weights in
this case.{p_end}

{phang}{opt vce(vcetype)} specifies the type of standard error
  reported; see help {help vce_option}. It defaults to the Stata's
  defaults for the specified model-type. {p_end}

{phang}{opt ape} displays average partial effects (average marginal
   effects) instead of coeficients. For {it:model-types} {help ologit}
   and {help oprobit}, khb uses the average partial effect on the
   probability for the first outcome. This can be changed with option
   {cmd:predict()}.  {p_end}

{phang}{opt continuous} Average partial effects are by default based
   on unit effects for dummy variables. Specifying continuous treats
   dummy variables equal to continuous variables. See {help margins}
   for details about this option{p_end}

{phang}{opt outcome()} lets the user specify the outcome for which the
   average partial (marginal) effects are calculated. The default is
   the outcome with the lowest level. {p_end}

{phang}{opt esttab} uses the user written command {help esttab} (Ben
   Jann) to create the output. By default {help estimates table} is
   being used. Note that {help esttab} must be installed before using
   this option. Note as an aside that further esttab options should be
   placed in option {cmd:tableoptions()}.{p_end}

{phang}{opt tableoptions()} lets the users specify all options that
   are allowed with {help estimates table}. If option {help esttab} is
   being used, {cmd:tableoptions()} lets the user specify all options
   that are allowed for {help esttab}. Note specifically, that the
   display of exponentiated coefficients and equations of
   multi-equation models is handled by tableoptions. 

{title:Example(s)}

{pstd}{cmd:. use dlsy_khb.dta}{p_end}
{pstd}{cmd:. khbtab logit univ intact boy || fses || abil} {p_end}
{pstd}{cmd:. khbtab logit univ intact boy || fses || abil, tableoptions(eform stats(r2_p N))} {p_end}

{pstd}{cmd:. khbtab ologit fgroup fses edu || univ || abil} {p_end}
{pstd}{cmd:. khbtab ologit fgroup fses edu || univ || abil, ape outcome(2)} {p_end}

{pstd}{cmd:. khbtab mlogit fgroup fses edu || univ || abil} {p_end}
{pstd}{cmd:. khbtab mlogit fgroup fses edu || univ || abil, tableoptions(drop("Middle:"))} {p_end}
{pstd}{cmd:. khbtab mlogit fgroup fses edu || univ || abil, ape outcome("Highest")}{p_end}

{title:References}

{pstd} Breen, R./Karlson, K.B./Holm, A. (2013).
Total, direct, and indirect effects in logit models.
Sociological Methods and Research, 42(2)164-191.
{p_end}

{pstd} Karlson, K.B./Holm, A./Breen, R. (2011): Comparing Regression
Coefficients Between Same-sample Nested Models using Logit and Probit. A New
Method. Sociological Methodology 42:286-313.{p_end}

{pstd} Karlson, K.B./Holm, A. (2011): Decomposing
primary and secondary effects: A new decomposition method. Research
in Stratification and Social Mobility 29:221-237.{p_end}

{pstd} Kohler, U./Karlson, K.B./Holm, A. (2011): Comparing
coefficients of nested nonlinear probability models. The Stata Journal
11:420-438.{p_end}

{title:Also see}

{psee}
Manual: {hi:[R] margins}
{p_end}

{psee}
Online: help for {help margins}, {help ldecomp} (if installed)
{p_end}

{psee}
Web:   {browse "http://stata.com":Stata's Home}
{p_end}

{title:Author}

{pstd}Ulrich Kohler (ukohler@uni-potsdam.de){p_end}


