{smcl}
{cmd:help kappaetc, ttest}{right: ({browse "http://www.stata-journal.com/article.html?article=st0544":SJ18-4: st0544})}
{hline}

{title:Title}

{p2colset 5 24 26 2}{...}
{p2col:{cmd:kappaetc, ttest} {hline 2}}Paired t tests of agreement coefficients{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{cmd:kappaetc}
{it:name1} {cmd:==} {it:name2}
[{cmd:, ttest} {it:{help kappaetc_ttest##opts:options}}]

{pstd}
where {it:name1} and {it:name2} are results previously stored by 
{helpb kappaetc} as

{p 8 16 2}
{cmd:kappaetc}
{varlist} 
{ifin} 
{weight}{cmd:,} {opt store(name1)} 
[{it:{help kappaetc##opts:kappaetc_options}}]

{p 8 16 2}
{cmd:kappaetc}
{varlist} 
{ifin} 
{weight}{cmd:,} {opt store(name2)}
[{it:{help kappaetc##opts:kappaetc_options}}]


{synoptset 15}{...}
{marker opts}{...}
{synopthdr}
{synoptline}
{synopt:{opt ttest}}perform paired t tests of agreement coefficients{p_end}
{synopt:{opt l:evel(#)}}set confidence level; default is 
{cmd:level({ccl level})}{p_end}
{synopt:{opt noh:eader}}suppress output header{p_end}
{synopt:{opt notab:le}}suppress coefficient table{p_end}
{synopt:{opt replay}}replay results in {it:name1} and {it:name2}{p_end}
{synopt:{it:{help kappaetc##opt_di:format_options}}}control column formats{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
{cmd:kappaetc} with the {opt ttest} option performs paired t tests of the
differences between correlated agreement coefficients.  It implements the
linearization method discussed in Gwet (2016).

{pstd}
The two sets of agreement coefficients are assumed to be based on the same
subjects rated by different groups of raters or rated repeatedly by the same
group of raters.  The test statistics are based on differences of the
subject-level agreement coefficients.


{title:Options}

{phang}
{opt ttest} performs paired t tests of correlated agreement coefficients.

{phang}
{opt level(#)} specifies the confidence level, as a percentage, for confidence
intervals.  The default is {cmd:level({ccl level})}.

{phang}
{opt noheader} suppresses the report about the number of subjects.  Only the
coefficient table is displayed.

{phang}
{opt notable} suppresses the display of the coefficient table.

{phang}
{opt replay} replays the two sets of agreement coefficients to be tested.

{phang}
{it:{help kappaetc##opt_di:format_options}} are the same as with 
{helpb kappaetc##opt_di:kappaetc}.


{title:Example}

{pstd}
The example data are drawn from {manlink R kappa}.

{pstd}
Test the difference of agreement among the first three and last two
raters:{p_end}
{phang2}{cmd:. webuse p615b}{p_end}
{phang2}{cmd:. kappaetc rater1-rater3, store(group1)}{p_end}
{phang2}{cmd:. kappaetc rater4 rater5, store(group2)}{p_end}
{phang2}{cmd:. kappaetc group1==group2}{p_end}


{title:Stored results}

{pstd}
{cmd:kappaetc} with the {opt ttest} option stores the following in {cmd:r()}:

{pstd}
Scalars{p_end}
{synoptset 15 tabbed}{...}
{synopt:{cmd:r(N)}}number of subjects{p_end}
{synopt:{cmd:r(level)}}confidence level{p_end}

{pstd}
Macros{p_end}
{synoptset 15 tabbed}{...}
{synopt:{cmd:r(cmd)}}{cmd:kappaetc}{p_end}
{synopt:{cmd:r(cmd2)}}{cmd:ttest}{p_end}
{synopt:{cmd:r(results1)}}{it:name1} of the first stored results{p_end}
{synopt:{cmd:r(results2)}}{it:name2} of the second stored results{p_end}

{pstd}
Matrices{p_end}
{synoptset 15 tabbed}{...}
{synopt:{cmd:r(b)}}coefficient vector{p_end}
{synopt:{cmd:r(table)}}information from the coefficient table{p_end}
{synopt:{cmd:r(se)}}standard errors of differences{p_end}
{synopt:{cmd:r(df)}}difference-specific degrees of freedom{p_end}
{synopt:{cmd:r(estimable)}}whether difference could be estimated{p_end}


{title:Reference}

{phang}
Gwet, K. L. 2016. Testing the difference of correlated agreement coefficients 
for statistical significance. {it:Educational and Psychological Measurement}
76: 609-637.


{title:Author}

{pstd}
Daniel Klein{break}
International Centre for Higher Education Research Kassel{break}
Kassel, Germany{break}
klein@incher.uni-kassel.de


{title:Also see}

{p 4 14 2}
Article:  {it:Stata Journal}, volume 18, number 4: {browse "http://www.stata-journal.com/article.html?article=st0544":st0544}{p_end}

{p 7 14 2}
Help:  {manhelp ttest R}, {manhelp kappa R}, {manhelp icc R},
{helpb kappaetc} (if installed){p_end}
