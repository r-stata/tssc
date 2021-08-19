{smcl}
{* *! version 1.1  19dec2020}{...}
{cmd:help lmtest}
{hline}

{title:Title}

{p2colset 5 20 22 2}{...} {phang} {bf:lmtest} {hline 2} Lagrange-multiplier test after constrained maximum-likelihood estimation{p_end} {p2colreset}{...}

{title:Syntax}

{p 10 17 2} {cmd:lmtest} [,{cmd:}{it:{help lmtest##options:options}}]

{synoptset 28 tabbed}{...}
{synopthdr :options}
{synoptline}
{synopt :{opt {ul on}not{ul off}est}}suppress output{p_end}
{synopt :{opt {ul on}nocnsr{ul off}eport}}suppress display of constraints{p_end}
{synopt :{opt {ul on}noomit{ul off}ted}}do not consider omitted variables as constraints{p_end}
{synopt :{opt {ul on}d{ul off}f(#)}}override the automatic degrees-of-freedom calculation{p_end}
{synopt :{opt {ul on}forcev{ul off}ce}}perform test even if {it:vcetype} is not {it:oim} or {it:opg}{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
{cmd:lmtest} performs a Lagrange-multiplier (LM) test (Silvey, 1959), also referred to as score test, 
of the restrictions that were previously imposed on the most recently estimated model by specifying the option {opt constraints()}. 
{cmd:lmtest} complements {cmd:test} and {cmd:lrtest} that implement the Wald test and the likelihood-ratio test, respectively, 
which - together with the Lagrange-multiplier test - represent the three canonical approaches to testing hypotheses after maximum-likelihood (ML) estimation (cf. Greene, 2012, p. 564).
{cmd:lmtest} requires that the preceding estimation command allows the option {opt constraints()} and the {help maximize##init_specs:maximize_options} {opt iterate()} and {opt from()}, 
and also requires that the constraints are saved in {cmd:e(Cns)} and the score vector is saved in {cmd:e(gradient)}. 
Unlike {cmd:test}, the syntax of {cmd:lmtest} does not involve specifying the restrictions to be tested. 
The restrictions are rather specified by the option {opt constraints()} in the command syntax used for estimating the model.
This corresponds to the logic of the Lagrange-multiplier test to estimate only the restricted version of a model.
The LM-test statistic reads simply as {it:score*inv(Info)*score'}, with the estimated score vector ({it:score}) and the estimated inverse information matrix ({it:inv(Info)}) being evaluated at the restricted maximum.
{cmd:lmtest} calculates the estimated score vector and the coefficient variance-covariance matrix, which serves as estimator for {it:inv(Info)},
at the restricted maximum by making use of the {help maximize##init_specs:maximize_options} {opt iterate(0)} and {opt from}{bf:(}{sf:e(b)}{bf:)}.
For determining the number of degrees-of-freedom, {cmd:lmtest} considers all restrictions that are specified in {cmd:e(Cns)}, except for base-level coefficients being restricted to the value of zero.
{it:indepvars} that are automatically omitted due to collinearity may hence distort the result of the LM test.
Specifying the option {opt df(#)} allows manually providing the appropriate number of degrees-of-freedom.
Alternatively, one may specify the option {opt noomitted} to prevent {cmd:lmtest} from interpreting omitted variables as exclusion restrictions to be tested; see {help lmtest##example3:example 3}.


{marker options}{...}
{title:Options}

{phang} {opt notest} prevents {cmd:lmtest} from displaying any output on the screen.

{phang} {opt nocnsreport} prevents {cmd:lmtest} from displaying the imposed constraints.

{phang} {opt df(#)} makes {cmd:lmtest} use an user-specified number of degrees-of-freedoms in calculating the p-value for the LM test. 
The default is to use the rank of {cmd:e(Cns)}, adjusted for the number of base-levels, as degrees-of-freedom. 
Specifying {opt df(#)} may be advisable if variables omitted due to collinearity inflate the rank of {cmd:e(Cns)} and in turn inflate the number of degrees-of-freedom.

{phang} {opt noomitted} makes {cmd:lmtest} not to consider omitted varaibles as exclusion restrictions to be tested. 
Since some estimation commands, {cmd:mlogit} for instance (see {help lmtest##example1:example 1}), label exclusion restictions specified by {opt constraints()} as omitted variables in {cmd:e(Cns)}, 
the default is to consider omitted variables as exclusion restrictions that are to be tested.
Unlike omitted variables, base-levels are never considered as testable exclusion restrictions, irrespective of whether or not {opt noomitted} is specified. 

{phang} {opt forcevce} makes {cmd:lmtest} carry out the LM test even if {help vce_option##:vcetype} is neither {it:oim} nor {it:opg}.
Since {cmd:lmtest} estimates the inverse information matrix as {cmd:e(V)}, {help vce_option##:vcetype}s other than {it:oim} and {it:opg} are most likely inappropriate.
With {opt forcevce} {cmd:lmtest} estimates the inverse information matrix as {cmd:e(V_modelbased)} and issues a warning.
If {help vce_option##:vcetype} is {it:oim} or {it:opg}, specifying {opt forcevce} has no effect.


{marker example1}{...}
{title:Example 1} (see {help mlogit##examples :mlogit examples})

{pstd}Load data{p_end}
{phang2}{cmd:. webuse sysdsn1}{p_end}

{pstd}Define constraints{p_end}
{phang2}{cmd:. constraint 1 [Uninsure]}{p_end}
{phang2}{cmd:. constraint 2 [Prepaid]: 2.site 3.site}{p_end}

{pstd}Estimate constrained multinomial logistic regression model{p_end}
{phang2}{cmd:. mlogit insure age male nonwhite i.site, constraint(1/2)}{p_end}

{pstd}LM test of the constraints{p_end}
{phang2}{cmd:. lmtest}{p_end}


{marker example2}{...}
{title:Example 2} (see {help oprobit##examples :oprobit examples}) 

{pstd}Load data{p_end}
{phang2}{cmd:. webuse fullauto}{p_end}

{pstd}Define constraints (equal distance between cutoff values){p_end}
{phang2}{cmd:. constraint 1 - [/]cut1 + 2*[/]cut2 - [/]cut3 = 0}{p_end}
{phang2}{cmd:. constraint 2 - [/]cut2 + 2*[/]cut3 - [/]cut4 = 0}{p_end}

{pstd}Estimate constrained ordered probit estimation{p_end}
{phang2}{cmd:. oprobit rep77 foreign length mpg, constraints(1 2)}{p_end}

{pstd}LM test of the constraints{p_end}
{phang2}{cmd:. lmtest}{p_end}


{marker example3}{...}
{title:Example 3} (see {help streg##examples :streg examples}, adjustment to automatically omitted variables) 

{pstd}Load data{p_end}
{phang2}{cmd:. webuse catheter}{p_end}

{pstd}Generate collinear regressor{p_end}
{phang2}{cmd:. gen male = 1 - female}{p_end}

{pstd}stset data{p_end}
{phang2}{cmd:. stset time, fail(infect)}{p_end}

{pstd}Define constraint{p_end}
{phang2}{cmd:. constraint 1 female = male + 2}{p_end}

{pstd}Estimate constrained survival model{p_end}
{phang2}{cmd:. streg age female male, distribution(lognormal) frailty(invgauss) shared(patient) constraints(1)}{p_end}

{pstd}LM test with manually adjusted degrees-of-freedom{p_end}
{phang2}{cmd:. lmtest, df(1)}{p_end}

{pstd}LM test with omitted varaibles not being considered as exclusion restrictions{p_end}
{phang2}{cmd:. lmtest, noomitted}{p_end}


{title:Saved results}

{pstd}
{cmd:lmtest} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(p)}}p-value{p_end}
{synopt:{cmd:r(chi2)}}test statistic (chi-squared){p_end}
{synopt:{cmd:r(df)}}test constraints degrees of freedom{p_end}
{synopt:{cmd:r(rank)}}rank of {cmd:e(Cns)} adjusted for the number of base-levels (only saved if {opt df(#)} is specified){p_end}
{synoptset 20 tabbed}{...} {p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(modelbased)}}{opt modelbased} if {cmd:e(V_modelbased)} used as estimate of the inverse information matrix{p_end}
{p2colreset}{...}


{title:References}

{pstd} Silvey, S. D. (1959). The Lagrangian Multiplier Test. {it:Annals of Mathematical Statistics} 30, 389-407.

{pstd} Greene, W. H. (2012). Econometric Analysis, Pearson, 7th ed.


{title:Also see}

{psee} Manual:  {manlink R test}, {manlink R lrtest}, {manlink SEM estat scoretests}, {manlink R constraint}, {manlink R Maximize} 

{psee} {space 2}Help:  {manhelp test R:test}, {manhelp lrtest R:lrtest}, {manhelp estat_scoretests SEM:estat scoretests}, {manhelp constraint R:constraint}, {manhelp maximize R:Maximize}{break}


{title:Author}

{psee} Harald Tauchmann{p_end}{psee} Friedrich-Alexander-Universit{c a:}t Erlangen-N{c u:}rnberg (FAU){p_end}{psee} N{c u:}rnberg,
Germany{p_end}{psee}E-mail: harald.tauchmann@fau.de {p_end}


{title:Disclaimer}

{pstd} This software is provided "as is" without warranty of any kind, either expressed or implied. The entire risk as to the quality and
performance of the program is with you. Should the program prove defective, you assume the cost of all necessary servicing, repair or
correction. In no event will the copyright holders or their employers, or any other party who may modify and/or redistribute this software,
be liable to you for damages, including any general, special, incidental or consequential damages arising out of the use or inability to
use the program.{p_end}


{title:Acknowledgements}

{pstd} I would like to thank Michael Oberfichtner for many valuable comments and suggestions.{p_end}

{pstd} {p_end}
