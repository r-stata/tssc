{smcl}
{* *! version 1.0 06jan2020}{...}
{viewerjumpto "Syntax" "multicoefplot##syntax"}{...}
{viewerjumpto "Description" "multicoefplot##description"}{...}
{viewerjumpto "Options" "multicoefplot##options"}{...}
{viewerjumpto "Examples" "multicoefplot##examples"}{...}
{viewerjumpto "Saved results" "multicoefplot##saved_results"}{...}
{viewerjumpto "Author" "multicoefplot##author"}{...}
{viewerjumpto "Acknowledgements" "multicoefplot##acknowledgements"}{...}
{title:Title}

{p2colset 5 19 21 2}{...}
{p2col :{hi:multicoefplot} {hline 2}}Advanced repeated cross-section graphical analysis{p_end}
{p2colreset}{...}


{marker syntax}{title:Syntax}

{p 8 15 2}
{cmd:multicoefplot}
{namelist} {ifin}
[{cmd:,} {it:options}]


{pstd}
{it:Namelist} is the constant part of the outcome variable's name. E.g. for vars gdp1999, gdp2000, gdp2001, the namelist must be "gdp". 
Multicoefplot runs a reghdfe by default, however, it runs with ivreghdfe if its syntax is used in the {it:namelist}: (varlist2_instrumented=varlist_iv).
If the instrumented variable or the instruments are time varying then they must be specified in the varying() option: (varlist_instrumented=varlist_iv, varying(varlist_varying)) 
and only the constant part of their variables name must be included, as for the outcome variable.
{p_end}

{synoptset 26 tabbed}{...}
{synopthdr :options}
{synoptline}
{syntab :Required options}
{synopt :{opth window(string)}}range of period of analysis, see {help forvalues} for range type. E.g. 1999 to 2010 "1999/2010" {p_end}
{synopt :WARNING: timevarying variables included in the analysis should exist for all values of the window}{p_end}

{synopt :{opth treatment:1(string)}} treatment variable to be plotted, if the varying(varlist) option is included, varlist variables in treatment are treated as time-varying and follow the window: e.g. treatment1(varname, varying(varname)). Interactions are not allowed. {p_end}
{synopt :Treatment1 MUST be specified}

{syntab :Other options}
{synopt :{opt com:mand}}shows the implied regression command; recommended for first-time users{p_end}
{synopt :{opt noconstant}}no constant included in all specifications{p_end}
{synopt :{opth level(#)}}set confidence level; default is level(95){p_end}
{synopt :{opt first}}when included, ivreghdfe includes first stage estimation{p_end}

{synoptline}
{syntab :Specifications comparison options}
{synopt :The following options can be used to compare up to 3 models, by adding the model number at the end, e.g.: treatment1() treatment2() treatment3().}{p_end}
{synopt :If the number is not specified, the option is used for model 1 (e.g. controls()=controls1()). Depending on the syntax models can use reghdfe or ivreghdfe.}{p_end}

{synopt :{opth treatment#(string)}}treatment variable to be plotted. If any option for models 2/3 is specified and treatment 2/3 is not, treatment 2/3 is set equal to treatment1. (see opt treatment1 for time-varying treatments){p_end}
{synopt :{opth absorb#(string)}}fixed effects to be included in the regression (controls should always be included in the controls opt){p_end}
{synopt :{opth controls#(varlist)}}control variables to be included in the regression{p_end}
{synopt :{opth timeabsorb#(varlist)}}time varying fixed effect to be included in the regression (include only constant part of the name). Interactions are not allowed.{p_end}
{synopt :{opth timecontrols#(varlist)}}time varying control variables to be included in the regression (include only constant part of the name). Interactions are not allowed.{p_end}
{synopt :{opth cluster#(varname)}}clustered standard errors{p_end}
{synopt :{opth vce#(robust)}}robust standard errors{p_end}
{synopt :{opth aweight#(varname)}}include aweights{p_end}
{synopt :{opth fweight#(varname)}}include fweights{p_end}

{synoptline}
{syntab :Robustness tests options - CAN BE COMPUTATIONALLY INTENSIVE}
{phang2} Multicoefplot can potentially compare thousands of specifications, with an easy to read graphical output. If the number of specifications/estimates exceeds the limit, consider reducing it by grouping or creating random subsamples.{p_end}
{phang2} The tests options refer to the options for specification 1.{p_end}

{synopt :{opt di:splay}}regressions are not run quietly, for tests, when this option is included{p_end}
{synopt :{opth fstat(globalsnames)}}plots the Kleibergen-Paap rk Wald statistic instead of coefficients for the included specifications{p_end}
{synopt :{opth multitest(globalsnames)}}plots the regressions including separately the set of controls included in the list. Elements of the list must be names of globals previously saved{p_end}
{synopt :{opth tuplestest(varlist)}}plots the regressions including separately all the possible tuples of the variables in varlist{p_end}
{synopt :{opth leaveoneouttest(varlist)}}plots the regressions excluding one of the controls from the list at the time{p_end}
{synopt :{opth perturbationtest(varname)}}plots the regressions dropping from the sample each time a different "levelsof" varname and generates a diagnostics table on the stability of the sample{p_end}

{synoptline}
{syntab :Graph options}
{synopt :Multicoefplot specific options}{p_end}
{synopt :{opth time(string)}}automatic labelling for the x-axis, can be year, month, week, day. More detailed labels have to be entered through xlabel(){p_end}
{synopt :{opth speccolor#(color)}}changes color for specification#{p_end}
{synopt :{opt symbols}}when included, the specifications use different symbols (black and white friendly){p_end}
{synopt :{opt symbol#}}changes symbol for the # spec, can be used together with symbols{p_end}
{synopt :{opth testcicolor(color)}}color of the confidence intervals for the tests{p_end}
{synopt :{opth testcoefcolor(color)}}color of the coefficients in the tests{p_end}

{synopt :General graph options{p_end}
{synopt :Note that x-axis options are based on the matrix position (that is 1,..,number of estimates), not the label value}{p_end}
{synopt :{opth offset(filename)}}set offset between specifications in the basic comparison{p_end}
{synopt :{opth legend(filename)}}controls legend. Default is: legend(1 "Specification 1" 2 "Specification 2" 3 "Specification 3"). Input "off" to turn off default lines{p_end}
{synopt :{opth {y|x}title(string)}}controls axis titles, standard options apply{p_end}
{synopt :{opth {y|x}label(string)}}controls axis labels, standard options apply e.g. {y|x}label(1 "1" 2 "2" 3 "3" 4 "4" 5 "5") {p_end}
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

{pstd} Load and prepare data{p_end}
{phang2}  webuse nlswork, clear{p_end}

{pstd}* For the time being multicoefplot works only on "regular" periods, irregular periods can be saved as regular in a new var, then used e.g. 1=68 2=69 3=71.. etc. {p_end}
{phang2}  keep if inlist(year, 69,71,73,75,77){p_end}  
{phang2}  reshape wide birth_yr age race msp nev_mar grade collgrad not_smsa c_city south ind_code occ_code union wks_ue ttl_exp tenure hours wks_work ln_wage, i(idcode) j(year){p_end}
{phang2}  gen c_race=race69{p_end}
{phang2}  gen c_birth_yr=birth_yr69{p_end}
{phang2}  gen c_collgrad=collgrad69{p_end}
{phang2}  gen c_south=south69{p_end}
{phang2}  drop race* birth_yr* collgrad* south*{p_end}


{pstd}* Examples of specifications comparison{p_end}

{pstd}* Command is a first-time-users friendly option to show in the console a draft of the regression(s) being run. Varying(tenure) tells multicoefplot the treatment is timevarying.{p_end}
{phang2}  multicoefplot ln_wage, window(69(2)77) command noconstant legend(off) treatment(tenure, varying(tenure)) controls(c_race c_birth_yr c_collgrad c_south) timecontrols(age ttl_exp not_smsa){p_end}

{pstd}* Comparing first spec to a second one adding time-varying FE's{p_end}
{phang2}  multicoefplot ln_wage, window(69(2)77) command noconstant treatment1(tenure, varying(tenure)) controls1(c_race c_birth_yr c_collgrad c_south) timecontrols1(age ttl_exp not_smsa) treatment2(tenure, varying(tenure)) controls2(c_race c_birth_yr c_collgrad c_south) timecontrols2(age ttl_exp not_smsa) timeabsorb2(occ_code){p_end}

{pstd}* Comparing first and second specs to a third one adding time-varying FE's and using robust S.E.. Symbols is a black and white friendly option.{p_end}
{phang2}  multicoefplot ln_wage, window(69(2)77) command noconstant symbols treatment1(tenure, varying(tenure)) controls1(c_race c_birth_yr c_collgrad c_south) timecontrols1(age ttl_exp not_smsa) treatment2(tenure, varying(tenure)) controls2(c_race c_birth_yr c_collgrad c_south) timecontrols2(age ttl_exp not_smsa) timeabsorb2(occ_code) treatment3(tenure, varying(tenure)) controls3(c_race c_birth_yr c_collgrad c_south) timecontrols3(age ttl_exp not_smsa) timeabsorb3(occ_code) vce3(robust) legend(1 "Baseline" 2 "Occupation FE's" 3 "Occupation FE's + Robust S.E.") xlabel(1 "1969" 2 "1971" 3 "1973" 4 "1975" 5 "1977"){p_end}
 
 
{pstd}* Tests{p_end}

{pstd}* Tuplestest runs all the tuples of the included controls, separately. They have to be constant, for the time being{p_end}
{phang2}  multicoefplot ln_wage, window(69(2)77) command noconstant legend(off) treatment(tenure, varying(tenure)) timecontrols(age ttl_exp not_smsa) tuplestest(c_race c_birth_yr c_collgrad c_south){p_end}

{pstd}* Leaveoneouttest leaves out one of the controls at the time{p_end}
{phang2}  multicoefplot ln_wage, window(69(2)77) command noconstant legend(off) treatment(tenure, varying(tenure)) timecontrols(age ttl_exp not_smsa) leaveoneouttest(c_race c_birth_yr c_collgrad c_south){p_end}

{pstd}* Multitest includes one set of controls at the time{p_end}
{phang2}  global cov1 "c_race c_south"{p_end}
{phang2}  global cov2 "c_birth_yr c_collgrad"{p_end}
{phang2}  multicoefplot ln_wage, window(69(2)77) command noconstant legend(off) treatment(tenure, varying(tenure)) timecontrols(age ttl_exp not_smsa) multitest(cov1 cov2){p_end}

{pstd}* Perturbationtest excludes one sub-sample at the time, based on the levelsof() of the variable. Tests look can be adjusted{p_end}
{phang2}  multicoefplot ln_wage, window(69(2)77) command noconstant legend(off) treatment(tenure, varying(tenure)) controls(c_race c_birth_yr c_collgrad c_south) timecontrols(age ttl_exp not_smsa) perturbationtest(c_birth_yr) testcicolor(navy) testcoefcolor(black){p_end}

{pstd}* Instrumental variable - Variables can be instrumented, and reduced forms and second stages can be put together in the same graph{p_end}
{pstd}* Looking at the Diagnostics Table of the Perturbationtest, we see that the minimum sample drop required to change the significance of estimates is roughly 8% of the sample{p_end}
{phang2}  multicoefplot ln_wage, window(69(2)77) command noconstant symbols treatment1(tenure=age, varying(tenure age)) controls1(c_race c_birth_yr c_collgrad c_south) timecontrols1(ttl_exp not_smsa) treatment2(tenure=age, varying(tenure age)) controls2(c_race c_birth_yr c_collgrad c_south) timecontrols2(ttl_exp not_smsa) timeabsorb2(occ_code) treatment3(tenure=age, varying(tenure age)) controls3(c_race c_birth_yr c_collgrad c_south) timecontrols3(ttl_exp not_smsa) timeabsorb3(occ_code) vce3(robust) legend(1 "Baseline" 2 "Occupation FE's" 3 "Occupation FE's + Robust S.E.") xlabel(1 "1969" 2 "1971" 3 "1973" 4 "1975" 5 "1977"){p_end}










{marker description}{...}
{title:Description}

{pstd}
{opt multicoefplot} runs regressions and generates graphs for repeated cross-section analysis, with extensive options for multiple specifications comparison, and specification and sample robustness-checks.

{pstd}
Repeated cross-sections are a useful tool of analysis of panel data. In such context, researchers are often in need of comparing specifications varying the choice of controls, fixed effects or cluster standard errors, or in the framework of instrumental variables, to compare Two Stages Least Squares estimates to OLS or Reduce Forms. {cmd:Multicoefplot} offers an easy way to compare up to three specifications, furthermore: the {opt multitest} option allows to compare any number of groups of controls by including one group at the time; the {opt leaveoneouttest} option allows to check for estimates robustness by leaving out one control at the time; the {opt tuplestest} option checks that results are robust to including any tuples of a set of controls and finally the {opt perturbationtest} option checks that results are not driven by specific sub-samples, by singularly dropping all different values of the indicated variable. The {opt perturbationtest} includes a Diagnostics Table of the heterogeneity of results across subsamples, e.g. the Minimum Perturbation: the minimum sample drop that changes at least one estimate's significance/sign.


{marker author}{...}
{title:Author}
{pstd}Matteo Pinna (matteo.pinna@gess.ethz.ch){p_end}


