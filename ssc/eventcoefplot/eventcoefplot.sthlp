{smcl}
{* *! version 1.0 16mar2020}{...}
{viewerjumpto "Syntax" "eventcoefplot##syntax"}{...}
{viewerjumpto "Description" "eventcoefplot##description"}{...}
{viewerjumpto "Options" "eventcoefplot##options"}{...}
{viewerjumpto "Examples" "eventcoefplot##examples"}{...}
{viewerjumpto "Saved results" "eventcoefplot##saved_results"}{...}
{viewerjumpto "Author" "eventcoefplot##author"}{...}
{viewerjumpto "Acknowledgements" "eventcoefplot##acknowledgements"}{...}
{title:Title}

{p2colset 5 19 21 2}{...}
{p2col :{hi:eventcoefplot} {hline 2}}Advanced event-study graphical analysis{p_end}
{p2colreset}{...}


{marker syntax}{title:Syntax}

{p 8 15 2}
{cmd:eventcoefplot}
{varname} {ifin} {cmd:, window(varlist)} 
[{it:options}]


{pstd}
{it:varname} is the outcome variable's name. {p_end}

{synoptset 26 tabbed}{...}
{synopthdr :options}
{synoptline}
{syntab :Required options}
{synopt :{opth window:1(varlist)}} event dummies to be plotted, interactions are not allowed. E.g. "period_-2 period_-1 period_0 period_1 period2"{p_end}
{synopt :Window1 MUST be specified. Eventcoefplot uses as xlabel labels of variables, if available, varnames otherwise}{p_end}

{syntab :Other options}
{synopt :{opt com:mand}}shows the implied regression command; recommended for first-time users{p_end}
{synopt :{opth event(varname)}}variable included in window, corresponding to the event. When included adds a 0 estimate (a "gap") before the event{p_end}
{synopt :{opth gapname(string)}}xlabel for the coefficient included above{p_end}
{synopt :{opt noconstant}}no constant included in all specifications{p_end}
{synopt :{opth level(#)}}set confidence level; default is level(95){p_end}

{synoptline}
{syntab :Specifications comparison options}
{synopt :The following options can be used to compare up to 3 models, by adding the model number at the end, e.g.: treatment1() treatment2() treatment3().}{p_end}
{synopt :If the number is not specified, the option is used for model 1 (e.g. controls()=controls1()). Depending on the syntax models can use reghdfe or ivreghdfe.}{p_end}

{synopt :{opth absorb#(varlist)}}fixed effects to be included in the regression (controls should always be included in the controls opt){p_end}
{synopt :{opth controls#(varlist)}}control variables to be included in the regression{p_end}
{synopt :{opth cluster#(varname)}}clustered standard errors{p_end}
{synopt :{opth vce#(robust)}}robust standard errors{p_end}
{synopt :{opth aweight#(varname)}}include aweights{p_end}
{synopt :{opth fweight#(varname)}}include fweights{p_end}

{synoptline}
{syntab :Robustness tests options - CAN BE COMPUTATIONALLY INTENSIVE}
{phang2} Eventcoefplot can potentially compare thousands of specifications, with an easy to read graphical output. If the number of specifications/estimates exceeds the limit, consider reducing it by grouping or creating random subsamples.{p_end}
{phang2} The tests options refer to the options for specification 1.{p_end}

{synopt :{opt di:splay}}regressions are not run quietly, for tests, when this option is included{p_end}
{synopt :{opth multitest(globalsnames)}}plots the regressions including separately the set of controls included in the list. Elements of the list must be names of globals previously saved{p_end}
{synopt :{opth tuplestest(varlist)}}plots the regressions including separately all the possible tuples of the variables in varlist{p_end}
{synopt :{opth leaveoneouttest(varlist)}}plots the regressions excluding one of the controls from the list at the time{p_end}
{synopt :{opth perturbationtest(varname)}}plots the regressions dropping from the sample each time a different "levelsof" varname and generates a diagnostics table on the stability of the sample{p_end}

{synoptline}
{syntab :Graph options}
{synopt :Eventcoefplot specific options}{p_end}
{synopt :{opth speccolor#(color)}}changes color for specification#{p_end}
{synopt :{opt symbols}}when included, the specifications use different symbols (black and white friendly){p_end}
{synopt :{opt symbol#}}changes symbol for the # spec, can be used together with symbols{p_end}
{synopt :{opth testcicolor(color)}}color of the confidence intervals for the tests{p_end}
{synopt :{opth testcoefcolor(color)}}color of the coefficients in the tests{p_end}

{synopt :General graph options}{p_end}
{synopt :Note that x-axis options are based on the matrix position (that is 1,..,number of estimates), not the label value}{p_end}
{synopt :{opth offset(filename)}}set offset between specifications in the basic comparison{p_end}
{synopt :{opth legend(filename)}}controls legend. Default is: legend(1 "Specification 1" 2 "Specification 2" 3 "Specification 3") Input "off" to turn off default lines{p_end}
{synopt :{opth {y|x}title(string)}}controls axis titles, standard options apply{p_end}
{synopt :{opth {y|x}label(string)}}controls axis labels, standard options apply{p_end}
{synopt :{opth {y|x}line(string)}}adds xlines or ylines, standard suboptions apply. Input "off" to turn off default lines{p_end}
{synopt :{opth {y|x}size(string)}}regulates length and height of the graph{p_end}

{synoptline}
{syntab :Save Output}
{synopt :{opt savegraph(file)}}saves all the tables, file has to be of format path/filename.csv{p_end}
{synopt :{opt savetex(file)}}saves a table in .tex format; not allowed for tests; file has to be of format path/filename{p_end}

{synoptline}
{marker Examples}{...}
{title:Examples of main features}

{pstd} I recommend users to look at these examples directly from the package example .do file{p_end}

{pstd}* Load and prepare data{p_end}
{phang2}  webuse nlswork, clear{p_end}
{phang2}  keep if inlist(year, 69,71,73,75,77){p_end}
{phang2}  gen pre_2=year==69{p_end}
{phang2}  gen pre_1=year==71{p_end}
{phang2}  gen post_1=year==75{p_end}
{phang2}  gen post_2=year==77{p_end}


{pstd}* Examples of specifications comparison{p_end}

{pstd}* Periods can be included in the preferred way in window(){p_end}
{phang2}  eventcoefplot ln_wage, window(pre_2 pre_1 post_1 post_2) noconstant legend(off) controls(race birth_yr collgrad south){p_end} 

{pstd}* Command is a first-time-users friendly option to show in the console a draft of the regression being run. Signalling the event(), adds a zero estimate before the event (not needed depending on the lags){p_end}
{phang2}  eventcoecommandfplot ln_wage, window(pre_2 pre_1 post_1 post_2) noconstant legend(off) command controls(race birth_yr collgrad south) event(post_1)  xline(3, lpattern(dash) lcolor(gray)){p_end}

{pstd}* Adding labels, eventcoepflot automatically uses them for the xlabels{p_end}
{phang2}  label var pre_2 "-3"{p_end}
{phang2}  label var pre_1 "-2"{p_end}
{phang2}  label var post_1 "0"{p_end}
{phang2}  label var post_2 "1"{p_end}

{pstd}* We compare here a second spec with robust S.E.. Gapname changes the name of the zero estimate.{p_end}
{phang2}  eventcoefplot ln_wage, window(pre_2 pre_1 post_1 post_2) noconstant  event(post_1) gapname(-1)  xline(3, lpattern(dash) lcolor(gray)) command controls1(race birth_yr collgrad south) speccolor1(black) controls2(race birth_yr collgrad south) speccolor2(red) vce2(robust){p_end}

{pstd}* We compare here a third spec with more FE's. Symbols is a black and white friendly option.{p_end}
{phang2}  eventcoefplot ln_wage, window(pre_2 pre_1 post_1 post_2) noconstant   event(post_1) gapname(-1)  xline(3, lpattern(dash) lcolor(gray)) command symbols controls1(race birth_yr collgrad south) vce1(robust) controls2(race birth_yr collgrad south) absorb2(idcode)  vce2(robust) controls3(race birth_yr collgrad south) absorb3(idcode occ) vce3(robust) legend(1 "Baseline" 2 "ID FE's" 3 "ID + Occupation FE's"){p_end}


{pstd}* Tests{p_end}

{pstd}* Tuplestest runs all the tuples of the included controls, separately.{p_end}
{phang2}  eventcoefplot ln_wage, window(pre_2 pre_1 post_1 post_2) noconstant legend(off) event(post_1)  xline(3, lpattern(dash) lcolor(gray)) command controls(age) tuplestest(race birth_yr collgrad south){p_end}

{pstd}* Leaveoneouttest leaves out one of the controls at the time{p_end}
{phang2}  eventcoefplot ln_wage, window(pre_2 pre_1 post_1 post_2) noconstant legend(off) event(post_1)  xline(3, lpattern(dash) lcolor(gray)) command controls(age) leaveoneouttest(race birth_yr collgrad south){p_end}

{pstd}* Multitest includes one set of controls at the time{p_end}
{phang2}  global cov1 "race birth_yr"{p_end}
{phang2}  global cov2 "collgrad south"{p_end}
{phang2}  eventcoefplot ln_wage, window(pre_2 pre_1 post_1 post_2) noconstant legend(off) event(post_1)  xline(3, lpattern(dash) lcolor(gray)) command controls(age) multitest(cov1 cov2){p_end}

{pstd}* Perturbationtest excludes one sub-sample at the time, based on the levelsof() of the variable. Tests look can be adjusted{p_end}
{phang2}  eventcoefplot ln_wage, window(pre_2 pre_1 post_1 post_2) noconstant legend(off) event(post_1)  xline(3, lpattern(dash) lcolor(gray)) command controls(age race birth_yr collgrad south) perturbationtest(age) testcicolor(navy) testcoefcolor(black){p_end}

{pstd}* Looking at the Diagnostics Table of the Perturbationtest, we see that the minimum sample drop required to change the significance of estimates is roughly 10% of the sample{p_end}
{phang2}  eventcoefplot ln_wage, window(pre_2 pre_1 post_1 post_2) noconstant legend(off) event(post_1)  xline(3, lpattern(dash) lcolor(gray)) command controls(age race birth_yr collgrad south) perturbationtest(birth_yr) testcicolor(navy) testcoefcolor(black){p_end}


{marker description}{...}
{title:Description}

{pstd}
{opt eventcoefplot} runs regressions and generates graphs for event-study analysis, with extensive options for multiple specifications comparison, and specification and sample robustness checks.

{pstd}
In the context of event-studies, researchers are often in need of comparing specifications varying the choice of controls, fixed effects or clustered standard errors. {cmd:Eventcoefplot} offers an easy way to compare up to three specifications, furthermore: the {opt multitest} option allows to compare any number of groups of controls by including one group at the time; the {opt leaveoneouttest} option allows to check for estimates robustness by leaving out one control at the time; the {opt tuplestest} option checks that results are robust to including any tuples of a set of controls and finally the {opt perturbationtest} option checks that results are not driven by specific sub-samples, by singularly dropping all different values of the indicated variable. The {opt perturbationtest} includes a Diagnostics Table of the heterogeneity of results across subsamples, e.g. the Minimum Perturbation: the minimum sample drop that changes at least one estimate's significance/sign.


{marker author}{...}
{title:Author}

{pstd}Matteo Pinna (matteo.pinna@gess.ethz.ch){p_end}


