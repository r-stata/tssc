{smcl}
{* *! version 1.0  29apr2016}{...}
{viewerdialog choi_lr_test "dialog choi_lr_test"}{...}
{viewerdialog choi_lr_testi "dialog choi_lr_testi"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] bitest" "help bitest"}{...}
{vieweralsosee "[R] ci" "help ci"}{...}
{vieweralsosee "[R] dstdize" "help dstdize"}{...}
{vieweralsosee "[R] logistic" "help logistic"}{...}
{vieweralsosee "[R] tabulate twoway" "help tabulate_twoway"}{...}
{vieweralsosee "[U] 19 Immediate commands" "help immed"}{...}
{viewerjumpto "Syntax" "choi_lr_test##syntax"}{...}
{viewerjumpto "Menu" "choi_lr_test##menu"}{...}
{viewerjumpto "Description" "choi_lr_test##description"}{...}
{viewerjumpto "Options for choi_lr_test" "choi_lr_test##options_choi_lr_test"}{...}
{viewerjumpto "Options for choi_lr_testi" "choi_lr_test##options_choi_lr_testi"}{...}
{viewerjumpto "Examples" "choi_lr_test##examples"}{...}
{viewerjumpto "Video examples" "choi_lr_test##videos"}{...}
{viewerjumpto "Stored results" "choi_lr_test##results"}{...}
{viewerjumpto "References" "choi_lr_test##references"}{...}
{title:Title}

{p2colset 5 19 21 2}{...}
{p2col :{cmd:choi_lr_test} {hline 2} Choi et al.'s likelihood ratio test for 2x2 tables (choi_lr_test and choi_lr_testi)}
{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 14 2}{cmd:choi_lr_test} {it:var_case var_exposed} {ifin}
[{it:{help choi_lr_test##weight:weight}}]
[{cmd:,} {it:{help choi_lr_test##choi_lr_test_options:choi_lr_test_options}}]

{p 8 14 2}{cmd:choi_lr_testi} {it:#a #b #c #d} [{cmd:,} {it:{help choi_lr_test##choi_lr_testi_options:choi_lr_testi_options}}]

{synoptset 24 tabbed}{...}
{marker choi_lr_test_options}{...}
{synopthdr:choi_lr_test_options}
{synoptline}
{syntab:Options}
{synopt :{opt co:rnfield}}use Cornfield approximation to calculate confidence intervals (CIs) of the odds ratio{p_end}
{synopt :{opt w:oolf}}use Woolf approximation to calculate standard error (SE) and CI of the odds ratio{p_end}
{synopt :{opt e:xact}}calculate Fisher's exact p{p_end}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt :{opt k:(#k)}}calculate the 1/#k likelihood support interval (LSI) for the odds ratio{p_end}
{synoptline}
{p2colreset}{...}
{marker weight}{...}
{p 4 6 2}{it:var_case} equals 1 or 0 for cases or controls, respectively.{p_end}
{p 4 6 2}{it:var_exposed} equals 1 or 0 for subjects who are, or are not, exposed.{p_end}
{p 4 6 2}{opt fweight}s are allowed; see {help weight}.
{p2colreset}{...}

{synoptset 24 tabbed}{...}
{marker choi_lr_testi_options}{...}
{synopthdr :choi_lr_testi_options}
{synoptline}
{syntab:Options}
{synopt :{opt co:rnfield}}use Cornfield approximation to calculate CI of the odds ratio{p_end}
{synopt :{opt w:oolf}}use Woolf approximation to calculate SE and CI of the odds ratio{p_end}
{synopt :{opt e:xact}}calculate Fisher's exact p{p_end}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt :{opt k:(#k)}}calculate the 1/#k likelihood support interval for the odds ratio{p_end}
{synoptline}
{p2colreset}{...}
{marker weight}{...}
{p 4 6 2}{it:#a} equals the number of exposed cases.{p_end}
{p 4 6 2}{it:#b} equals the number of unexposed cases.{p_end}
{p 4 6 2}{it:#c} equals the number of exposed controls.{p_end}
{p 4 6 2}{it:#d} equals the number of unexposed controls.{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:choi_lr_test} is used for 2x2 tables when the parameter of interest 
is the odds ratio. It is similar to the {cmd:cc} and {cmd:cci} commands 
but also calculates the maximum likelihood estimate (MLE) of the odds 
ratio conditioned on the total number of exposed subjects, Choi et al.'s 
likelihood ratio test of the null hypothesis that the odds ratio = 1, and the 
1/k likelihood support interval (LSI) for this odds ratio. By default, 
it calculates the 1/6.8 LSI which equals the 95% CI for normally
distributed random variables. See {help choi_lr_test##C2015:Choi et al. (2015)} 
for additional details and {help choi_lr_test##B2002:Blume (2002)} for an introduction
to likelihood methods for measuring statistical evidence.

{pstd}
{cmd:choi_lr_test} and {cmd:choi_lr_testi} use the {cmd:cc} and {cmd:cci} programs, 
respectively, to calculate point estimates and CIs for the 
unconditioned odds ratio, along with attributable or prevented fractions for the 
exposed and total population. {cmd:choi_lr_testi} is the immediate form of 
{cmd:choi_lr_test}; see {help immed}. Also see {manhelp logistic R} for 
related commands.

{pstd}
This program may not be used for analyzing stratified 2x2 tables.

{pstd}
A Shiny app {help choi_lr_test##C2016:(Choi 2016)} and an R package {help choi_lr_test##C2011:(Choi 2011)} are also available for performing these 
calculations.

{marker options_choi_lr_test}{...}
{title:Options for {cmd:choi_lr_test}}
{title:Options for {cmd:choi_lr_testi}}

{dlgtab:Options}

{phang}
{opt cornfield} requests that the 
{help choi_lr_test##C1956:Cornfield (1956)} approximation be used to calculate the
CI of the odds ratio.  (This approximation does not use the 
continuity correction use by Cornfield in his 1956 paper.) By default, 
{cmd:choi_lr_test} reports an exact interval. 

{phang}
{opt woolf} requests that the
{help choi_lr_test##W1955:Woolf (1955)} approximation, also known as the Taylor
expansion, be used for calculating the SE and CI
for the odds ratio. 

{phang}
{opt exact} requests that Fisher's exact 
p be calculated rather than the chi-squared and its significance level.  We
(Dupont & Plummer) recommend using Choi's likelihood ratio chi-squared statistic
whenever samples are small. We also recommend using the 1/6.8 LSI instead of the 95%
CI for the odds ratio for small samples. When the least-frequent cell contains 
1,000 cases or more, there will be no appreciable difference between the 
significance levels of any of the tests calculated by this program. 
The exact significance level will take 
considerably longer to calculate.   {opt exact} 
does not affect whether exact CIs are calculated.  Commands 
always calculate exact CIs where they can, unless {opt cornfield} or
{opt woolf} is specified.

{phang}
{opt level(#)} specifies the confidence level, as a 
percentage, for CIs.  The default is {cmd:level(95)} or as 
set by {helpb set level}.

{phang}
{opt k(#k)} specifies a positive number used to calculate the 1/#k LSI for 
the odds ratio. The 1/6.8259358 LSI is always calculated. (This LSI is typically
refered to by us and others as the 1/6.8 LSI.) It provides the same level of support 
for the true location of the odds ratio as a 95% CI.

{marker examples}{...}
{title:Examples}

    {hline}
{pstd}Setup{p_end}
{phang2}{cmd:. webuse ccxmpl}

{pstd}List the data{p_end}
{phang2}{cmd:. list}

{pstd}Calculate odds ratio, etc.{p_end}
{phang2}{cmd:. choi_lr_test case exposed [fw=pop]}

{pstd}Immediate form of above command{p_end}
{phang2}{cmd:. choi_lr_testi 4 386 4 1250}

{pstd}Same as above, but calculate Fisher's exact p rather than the
chi-squared{p_end}
{phang2}{cmd:. choi_lr_testi 4 386 4 1250, exact}

    {hline}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:choi_lr_test} and {cmd:choi_lr_testi} store the following in {cmd:r()}:
{synoptset 17 tabbed}{...}

{p2col 5 15 19 2: Scalars defined in the choi_lr_test and choi_lr_testi programs}{p_end}
{synopt:{cmd:r(or_cond)}}MLE of odds ratio conditioned on the total number of exposed subjects {p_end}
{synopt:{cmd:r(clr)}}Conditional likelihood ratio for the null hypothesis that OR = 1 {p_end}
{synopt:{cmd:r(chi2_clr)}}Choi's LR chi-squared statistic. This is equation (9) of {help choi_lr_test##C2015:Choi et al. (2015)}  {p_end}
{synopt:{cmd:r(p_choi)}}p-value from Choi's likelihood ratio statistic {p_end}
{synopt:{cmd:r(lr6pt8lsi_lb)}}Lower bound of the 1/6.8259358 LSI for the odds ratio {p_end}
{synopt:{cmd:r(lr6pt8lsi_ub)}}Upper bound of the 1/6.8259358 LSI for the odds ratio {p_end}
{synopt:{cmd:r(lrklsi_lb)}}Lower bound of the 1/k LSI for the odds ratio {p_end}
{synopt:{cmd:r(lrklsi_ub)}}Upper bound of the 1/l LSI for the odds ratio {p_end}

{p2col 5 15 19 2: Scalars defined in the cc and cci programs}{p_end}
{synopt:{cmd:r(p)}}two-sided p-value from the 2x2 chi^2 statistic without continuity correction{p_end}
{synopt:{cmd:r(p1_exact)}}chi-squared or one-sided exact significance{p_end}
{synopt:{cmd:r(p_exact)}}two-sided exact significance{p_end}
{synopt:{cmd:r(or)}}Unconditioned MLE of the odds ratio{p_end}
{synopt:{cmd:r(lb_or)}}lower bound of CI for {cmd:or}{p_end}
{synopt:{cmd:r(ub_or)}}upper bound of CI for {cmd:or}{p_end}
{synopt:{cmd:r(afe)}}attributable (prev.) fraction among exposed{p_end}
{synopt:{cmd:r(lb_afe)}}lower bound of CI for {cmd:afe}{p_end}
{synopt:{cmd:r(ub_afe)}}upper bound of CI for {cmd:afe}{p_end}
{synopt:{cmd:r(afp)}}attributable fraction for the population{p_end}
{synopt:{cmd:r(chi2)}}2x2 chi^2 statistic without continuity correction{p_end}


{marker references}{...}
{title:References}

{marker B2002}{...}
{phang}
Blume JD. 2002. Likelihood methods for measuring statistical evidence. 
{it:Stat Med} 21:2563-99.

{marker C2015}{...}
{phang}
Choi et al. 2015. Elucidating the Foundations of Statistical Inference with 2 x 2 
Tables. {it:PLoS ONE} 10(4): e0121263. doi:10.1371/journal.pone.0121263

{marker C2011}{...}
{phang}
Choi, L. 2011. ProfileLikelihood: profile likelihood for a parameter in commonly 
used statistical models; 2011. R package version 1.1. 
https://cran.r-project.org/web/packages/ProfileLikelihood/index.html 

{marker C2016}{...}
{phang}
Choi, L. 2016. Likelihood ratio statistics for 2 x 2 tables. http://statcomp2.vanderbilt.edu:37212/dalep/ProfileLikelihood/

{marker C1956}{...}
{phang}
Cornfield, J. 1956. A statistical problem arising from retrospective studies.  In Vol. 4 of Proceedings of the Third Berkeley Symposium, ed.  J. Neyman, 135-148. Berkeley, CA: University of California Press.

{marker W1955}{...}
{phang}
Woolf, B. 1955. On estimating the relation between blood group disease.  Annals of Human Genetics 19: 251-253.  Reprinted in Evolution of Epidemiologic Ideas: Annotated Readings on Concepts and Methods, ed. S. Greenland, pp.
        108-110. Newton Lower Falls, MA: Epidemiology Resources.
{p_end}
