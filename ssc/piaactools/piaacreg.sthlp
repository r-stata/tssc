{smcl}
{* *! version 2 DEC2013}{...}
{cmd:help piaacreg} {right:also see:  {help piaacdes} {help piaactab} }
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:[R] piaacreg} } Regression models with PIAAC data{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 18 2}
{cmd:piaacreg}
	{it:{help varlist}}
	{cmd: [if] [in],} save(string) weight(varlist max=1) rep(varlist) [, options] 
	
{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main options}

{synopt :{help prefix_saving_option:{bf:{ul:save}(}{it:filename}{bf:, ...)}}}save
	results to {it:filename}. You have to specify this option {p_end}

{syntab: Optional}

{synopt :{opt countryid(varname)}} Allows providing the name of a variable containing a list of countries for which you want to obtain results.
The list can be numeric or string with any possible values.
Missing categories will be omitted from calculations and average over all countries will be calculated.
When this option is not specified, CNTRYID or cntryid variable will be used as to identify countries and the OECD average will be calculated. {p_end}

{synopt :{opt vemethodn(varname numeric)}} Provides the name of the numeric variable specifying the jackknife variance estimation method for each country.
The variable can only contain values of 1 or 2. When this option is not specified, VEMETHODN or vemethodn variable will be used to identify jackknife method.
When this option is not specified, piaacreg will look for VEMETHODN or vemethodn variable to identify jackknife method. {p_end}

{synopt :{opt weight(varlist max=1) rep(varlist)}} Gives the main weight and a list of jackknife replication weights.
You don't have to specify these options if your dataset contains original weights spfwt0-spfwt80 or SPFWT0-SPFWT80 {p_end}

{synopt :{opt pvdep(pv prefix)}} Specifies plausible values as dependent variables.
Specify plausible values prefix without ending numbers, e.g. pv(pvlit) asks for plausible values pvlit1-pvlit10 to be used as dependent variables. {p_end}

{synopt :{opt pvindep1(pv prefix) pvindep1(pv prefix)  pvindep3(pv prefix)}}
Specifies plausible values to be used as independent variables.
Specify plausbile values prefix without ending numbers, e.g. pvindep1(pvlit) asks for plausible values pvlit1-pvlit10 to be used as independent variables.
If additional plausible values need to be used one could specify option pvindep2() or pvindep3(). {p_end}

{synopt :{opt over(varname)}} Specifies a categorical variable or plausible value for which you want to obtain regression results by each category.
The variable must be numerical with a sequence of integers denoting each category. 
For proficiency levels, specify the prefix of plausible values without ending numbers (e.g. pvlit, pvnum, pvpsl). {p_end}

{synopt :{opt round(int)}} Specifies how many decimal places you want to see in results tables. The default is 2. {p_end}

{synopt :{opt fast}} Specifying this option speeds up calculations at the cost of not fully valid estimates of standard errors. Point estimates are correct, while standard errors are obtained analytically and usually differ from those obtained with jackknife method. {p_end}

{synopt :{opt cons}} Specify this option if you want to save estimates for the regression constant. {p_end}

{synopt :{opt cmd() cmdops()}} Specify these options if you want to run a regression model different from -regress-. You can pass options to the regression command using cmdops(). {p_end}

{synopt :{opt or }} Specify this option together with cmd("logit") or cmd("logistic") to obtain odds ratios instead of coefficients.
In this case, a standard Stata approach is taken and the standard errors are derived using the
{browse "http://www.stata.com/support/faqs/statistics/delta-rule/":{it: delta rule}}. {p_end}

{synopt :{opt r2()}} Specify r2(r2_a) to report adjusted R-square or any other scalar returned in e(). {p_end}

{synoptline}

{title:Description}

{pstd}
{cmd:piaacreg} runs regression with PIAAC data.
First variable listed after piaacreg command is the dependent variable unless you specify pvdep().
If your dependent variable is a vector of plausible values, you should specify pvdep() option providing the prefix of plausible values variable without ending numbers (e.g. pvlit, pvnum, pvpsl).
The remaining variables listed after piaacreg are treated as independent variables.
Options pvindep1(), pvindep2() and pvindep3() allow for the use of plausible variables as independent variables.
Similarly, the prefix of plausible values can be specified in over() option.
In this case, the regressions will be run over proficiency levels.
Piaacreg saves results as html file that can be, for example, further edited in a spreadsheet application.
Piaacreg also returns results in Stata matrices. Type -return list- after executing the command.
{p_end}

{title:Example 1. Regression without plausible values.}

{phang2}{cmd:. piaacreg readytolearn gender_r, countryid(cntryid) round(5) save(example1) }{p_end}

{pstd}
Results are saved in the working directory in the file example1.html. Numbers are reported with 5 decimal points.
Results are also returned in matrices that can be further processed directly in Stata.
Type -return list- after running piaacreg to see the list of returned result matrices.{p_end}

{pstd}For example, to see the point estimates type:{p_end}
{phang2}{cmd:. mat list r(b)}{p_end}

{pstd}To see the standard errors type:{p_end}
{phang2}{cmd:. mat list r(se)}{p_end}

{pstd}To see the R-squared matrix type:{p_end}
{phang2}{cmd:. mat list r(r2)}{p_end}

{title:Example 2. Regression with plausible values as a dependent variable.}

{phang2}{cmd:. piaacreg readytolearn gender_r, pvdep(pvnum)  countryid(cntryid) round(5) save(example2)}{p_end}

{pstd}
Plausible values in numeracy are declared as the dependent variable by using the pvdep() option.
Results are saved in the html file and in the return matrices. For more details see Example 1.{p_end}

{title:Example 3. Regression with plausible values as an independent variable.}

{phang2}{cmd:. piaacreg readytolearn gender_r, pvindep1(pvnum)  countryid(cntryid) round(5) cons save(example3)}{p_end}

{pstd}
Plausible values in numeracy are declared as one of the independent variables by using the inpvdep1() option.
One can include the second or the third set of plausible values as independent variables by using the inpvdep2() or inpvdep3() options.
The regresion constant is reported in the output tables because the cons option was specified.
Results are saved in the html file and in the return matrices. For more details see Example 1.{p_end}

{title:Example 4. Logistic regression with plausible values as an independent variable.} {pstd}

{pstd}
Other regression models can be run by using the cmd("") option. This option specifies the regression command.
For example, to run the logistic regression one needs to type cmd("logit"). {p_end}

{phang2}{cmd:. recode computerexperience (1=1) (2=0), gen(compexp)} {p_end}
{phang2}{cmd:. piaacreg compexp readytolearn gender_r, pvindep1(pvnum) cmd("logit") countryid(cntryid) round(5) save(example4)}{p_end}

{pstd}
Results are saved in the html file and in the return matrices. For more details see Example 1.{p_end}

{title:Also see}

{p 4 13 2}
Help for {helpb piaactab}, {helpb piaacreg} (if installed)
{p_end}

{title:Authors}

{pstd} Maciej Jakubowski, 
Faculty of Economic Sciences, Warsaw University {p_end}
{pstd} {browse "mailto:mjakubowski@uw.edu.pl":mjakubowski@uw.edu.pl} {p_end}

{pstd} Artur Pokropek, 
Educational Research Institute (IBE), Warsaw {p_end}
{pstd} {browse "mailto:artur.pokropek@gmail.com":artur.pokropek@gmail.com} {p_end}

{title:Version}

{pstd}Last updated 2012-12-25{p_end}
