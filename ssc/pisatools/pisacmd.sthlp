{smcl}
{* *! version 12 APR2020}{...}
{cmd:help pisacmd} {right:also see:  {help pisastats} {help pisareg} {help pisaqreg} {help pisaoaxaca} {help pv} {help repest}}
{hline}

{title:Title}

{p2colset 5 16 22 2}{...}
{p2col :{hi: pisacmd} {hline 2}}Estimation command with PISA data and plausible values{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 18 2}
{cmd:pisacmd}
{depvar} [{indepvars}] {ifin}
   [{cmd:,} {it:options}]
	
{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}

{syntab:Main options}

{synopt :{opt cmd(string)}} Specifies a Stata estimation command. {p_end}

{synopt :{opt cnt(string)}} Specifies a list of countries for which results will be calculated.
If OECD is specified, then results are provided for all OECD countries participating in this cycle. 
Similarly, specifying PARTNERS will produce results for all partner countries and economies participating in this cycle.
Specifying PISA will produce similar results for all countries participating in this cycle. 
If ALL is specified, then results are provided for all countries currently in your dataset. 
Results can be provided for distinct groups of countries by specifying a list with three letter ISO codes. 
For example, option cnt("AUS DEU POL") will produce results for Australia, Germany and Poland. 
The OECD average is calculated only when OECD or PISA is specified.
In other cases simple average will be calculated.
If you don't specify this option, the results will be produced for all values of the variable cnt. 
This variable must exist in the dataset.
{p_end}

{synopt :{help prefix_saving_option:{bf:{ul:save}(}{it:filename}{bf:, ...)}}}save
	results to {it:filename}. You have to specify this option {p_end}
	
{syntab: Optional}

{synopt :{opt cmdops(string)}} Passes options to the Stata estimation command specified in cmd(). {p_end}

{synopt :{opt pvindep*(string)}} where * can be 1, 2 or 3.
Provides a list of plausible values to be included as independent variables in the regression.
You can use the end of any plausible value variable name that starts with pv*. 
For example, if you have pv*read variables then use pvindep1(read) to have one plausible value in reading on the rand hand side.
You can specify up to three plausible values as independent variables.
The dependent variable can be also plausible value or any other variable.
 {p_end}

{synopt :{opt over(var)}} Specifies a categorical variable for which you want to obtain statistics by each category. 
The variable must be numerical with a sequence of integers denoting each category. {p_end}

{synopt :{opt round(int)}} Specifies how many decimal places you want to see in results tables. Default is 2. {p_end}

{synopt :{opt cycle(int)}} Specifies which PISA cycle you analyze.
This affects the list of countries recognized as OECD, PISA or PARTNERS in option cnt() 
as well as which names of plausible values will be recognized when given as dependent variable. 
Default is 2018. {p_end}

{synopt :{opt fast}} Specifying this option dramatically speeds up calculations at the cost of not fully valid estimates of standard errors. 
Statistic itself is calculated properly, however, standard errors are calculated using the clustered sandwich estimator (you need to keep schoolid variable in the data).
These standard errors are usually overstimated comparing to the original BRR method. {p_end}

{synopt :{opt cons}} Specify this option if you want to save estimates for the regression constant. {p_end}

{synopt :{opt r2()}} Specify r2(r2_a) to report adjusted R-square or any other scalar returned in e(). {p_end}

{synopt :{opt pw}} Specifying this option pweights are used instead of default aweights when running Stata commands. 
Please use it with commands like logit which does not allow aweights but allow pweights. {p_end}

{synopt :{opt keepvar(varlist)}} Specifies a list of variables that will be kept in the dataset during calculations.
This way, for example, you can keep variables that are not used in your model but are used in your estimation command options. {p_end}

{synoptline}


{title:Description}

{pstd}
You can use {cmd:pisacmd} to run any standard Stata estimation command with PISA data. The command have to specified in the cmd() option. 
First variable listed after pisacmd is the dependent variable.
You can use any plausible value as the dependent variable but just specify last letters after pv*. Thus, for pv*read just type read. 
For any dataset you can type read, math, scie in which case the regression will be run 5 times (or 10 times for 2015 and 2018 data) 
on plausible values in reading, mathematics or science, respectively. 
For any dataset you can also use proflevel which will run regression 5 times (or 10 times for 2015 and 2018 data) on a dummy indicator
(or any other variable) that is based on any plausible value. This can be used to estimate regression with proficiency levels.
You can also use any plausible value existing in PISA dataset.
For PISA 2000 you can type: math, scie, read, read1, read2, read3, math1, math2, proflevel.
For PISA 2003 you can type: math, scie, read, math1, math2, math3, math4, prob, proflevel.
For PISA 2006 you can type: math, scie, read, intr, supp, eps, isi, use, proflevel.
For PISA 2009 you can type: math, scie, read, era, read1, read2, read3, read4, read5, proflevel.
For PISA 2012 you can type: math, scie, read, macc, macq, macs, macu, mape, mapf, mapi, proflevel.
For PISA 2015 you can type: math, scie, read, scep, sced, scid, skco, skpe, ssph, ssli, sses, proflevel.
For PISA 2018 you can type: math, scie, read, glcm, rcli, rcun, rcer, rtsn, rtml, proflevel.
You can also use pvindep*() option to run regression 5 times (or 10 times for 2015 data) with plausible values as independent variables.
The final result will be calculated as a mean of these five regressions (or 10 for 2015 and 2018 data).
You can also specify other variables as dependent variables.
In this case the command will perform a standard estimation with one dependent variable.
Standard errors are obtained by the BRR method unless fast option is specified.
With fast option standard errors do not take into account the complex survey design.
The command uses survey information provided in the original publicly available PISA datasets.
You need to keep variables like cnt, schoolid, w_fstuwt and w_fst* to be able to use this command.
Pisacmd returns matrices with point estimates and standard errors, separately for each over() category.
Type return list after executing pisacmd to see what is available.

{title:Examples}

{pstd}

{phang2}{cmd:. pisacmd scie intscie, cmd("reg") over(gender) cnt(PISA) cons save(example1) round(3)} {p_end}

{phang2}{cmd:. pisacmd read escs gender, cmd("qreg") cnt(AUS) save(example2) } {p_end}

{phang2}{cmd:. pisacmd proflevel escs gender migrant, cmd("logit") pw cnt(OECD) save(example3)}  {p_end}

{title:References}

When using our package please provide this reference in your work:

{phang} Maciej Jakubowski & Artur Pokropek (2017), {it: PISATOOLS: Stata module to facilitate analysis of the data from the PISA OECD study}, Statistical Software Components, Boston College Department of Economics.{p_end}

The formulas were taken from:

{phang}OECD (2009), {it:PISA Data Analysis Manual: SPSS and SAS, Second Edition}, OECD, Paris{p_end}

{phang}OECD (2017), {it:PISA 2015 Technical Report}, OECD, Paris{p_end}

{phang}Rubin, D. B. (1987), {it:Multiple imputations for nonresponse in surveys}, New York, John Wiley and Sons{p_end}

{title:Authors}

{pstd}

{phang} Maciej Jakubowski, Evidence Institute and University of Warsaw, Poland
email: mj@evidenceinstitute.pl {p_end}

{phang} Artur Pokropek, Institute of Philosophy and Sociology, Polish Academy of Sciences {p_end}

{title:Also see}

{pstd}
Other commands in this package {help pisastats}, {help pisareg}, {help pisaqreg}, {help pisaoaxaca}. {p_end}
{pstd} User-written commands pv.ado or repest.ado. Type {help pv} or {help repest} if installed. {p_end}

{title:Version}

{pstd} Last updated April 2020, by Maciej Jakubowski {p_end}
