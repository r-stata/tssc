{smcl}
{* *! version 1.3.2 22jan2015}{...}
{* findalias asfradohelp}{...}
{* vieweralsosee "" "--"}{...}
{* vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "krippalpha##syntax"}{...}
{viewerjumpto "Description" "krippalpha##description"}{...}
{viewerjumpto "Options" "krippalpha##options"}{...}
{viewerjumpto "Remarks" "krippalpha##remarks"}{...}
{viewerjumpto "Examples" "krippalpha##examples"}{...}
{viewerjumpto "Stored results" "krippalpha##results"}{...}
{viewerjumpto "Authors" "krippalpha##author"}{...}
{viewerjumpto "References" "krippalpha##references"}{...}
{viewerjumpto "Acknowledgements" "krippalpha##acknowledgements"}{...}
{title:Title}

{phang}
{bf:krippalpha} {hline 2} Krippendorff's alpha intercoder reliability coefficient


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:krippalpha:}
{varlist} {ifin} [, {cmd: method(}{it:datalevel}{cmd:)} {cmd: format(}{it:{help fmt}}{cmd:)}]

{p2colreset}{...}
{p 4 6 2}
Note: the data used must be numeric or factor. String variables do not work.{p_end}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt m:ethod}}set datalevel (nominal, ordinal, interval, ratio){p_end}
{synopt:}{p_end}
{syntab:Options}
{synopt:{opt f:ormat}}set display format for alpha{p_end}
{synopt:}{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}


{marker description}{...}
{title:Description}

{pstd}
{cmd:krippalpha} calculates Krippendorff's alpha intercoder reliability coefficient for given observations on all data levels.

{pstd} Please note that the bootstrap-option added in version 1.2.0 has been removed in the current version due to conceptional issues.

{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt method} defines whether Krippendorff's alpha shall be calculated for nominal, ordinal, interval or ratio level data. 

{dlgtab:Options}

{phang}
{opt format(fmt)} sets the display format for alpha. Default is %-8.3f. For more details, see {help format}.

{marker remarks}{...}
{title:Remarks}

{pstd}
Please note that the dataset needs to have a certain structure in order for Krippendorff's alpha to be calculated properly. 

{pstd}
Each column in the dataset stands for one single coder and his or her ratings of one given category. The rows define units which are rated concerning the given category. If coders rate different 
categories, the coders' ratings of the different categories have to be placed in separate columns.

{pstd}Let c1, c2, c3 be different coders and stub1, stub2 different categories. 
The corresponding dataset would be structured as follows:

        {c TLC}{hline 56}{c TRC}
        {c |}c1_stub1 c2_stub1 c3_stub1   c1_stub2 c2_stub2 c3_stub2 {c |}
        {c |}{hline 56}{c |}
        {c |}    1        1        1          1        1        1    {c |}
        {c |}    2        2        2          3        1        3    {c |}
        {c |}    1        1        1          1        2        1    {c |}
        {c |}    3        2        3          2        3        3    {c |}
        {c |}    2        2        1          2        2        2    {c |}
        {c BLC}{hline 56}{c BRC}


{marker examples}{...}
{title:Examples}

{phang}{cmd:. sysuse krippendorff}{p_end}
{phang}{cmd:. krippalpha *stub1, method(nominal)}{p_end}
{phang}{cmd:. krippalpha c1_stub1 c3_stub1, method(nominal)}{p_end}
{phang}{cmd:. krippalpha *stub2, method(ordinal)}{p_end}

{pstd}
The examples above compute coefficients for single variables. If one wants to compute an average Krippendorff's alpha (i.e. over different variables), consider following code:

{phang}{cmd:{space 2}sysuse krippendorff}{p_end}
{phang}{cmd:{space 2}foreach x in stub1 stub2 {c -(}}{p_end}
{phang}{cmd:{space 6}krippalpha *`x', method(nominal)}{p_end}
{phang}{cmd:{space 6}{tab}gen alpha_`x' =`r(k_alpha)'}{p_end}
{phang}{cmd:{space 2}{c )-}}{p_end}
{phang}{cmd:{space 2}qui egen alphamean=rowmean(alpha*) in 1}{p_end}
{phang}{cmd:{space 2}qui sum alphamean}{p_end}
{phang}{cmd:{space 2}scalar overallalpha=`=r(mean)'}{p_end}
{phang}{cmd:{space 2}drop alpha_* alphamean}{p_end}
{phang}{cmd:{space 2}display `=overallalpha'}{p_end}


{marker results}{...}
{title:Stored Results}

{pstd}
{cmd:krippalpha} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(k_alpha)}}Krippendorff's alpha intercoder reliability coefficient{p_end}
{synopt:{cmd:r(rater)}}number of coders{p_end}
{synopt:{cmd:r(units)}}number of rated cases{p_end}
{synopt:}{p_end}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(method)}}contains level of the data for which Krippendorff's alpha was computed{p_end}
{synopt:}{p_end}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(table)}}matrix contains the scalars described above{p_end}
{p2colreset}{...}


{marker author}{...}
{title:Authors}

{phang}Alexander Staudt, Universitaet Mannheim, astaudt@mail.uni-mannheim.de{p_end}
{phang}Mona Krewel, Universitaet Mannheim, mona.krewel@mzes.uni-mannheim.de{p_end}


{marker references}{...}
{title:References}

{phang}Krippendorff, K. 1980. {it:Content Analysis: An Introduction to Its Methodology.} 
Beverly Hills, CA: Sage.{p_end}
{phang}Krippendorff, K. 2011. Computing Krippendorff's Alpha-Reliability. {it:Departmental Papers (ASC)} 43. {browse "http://repository.upenn.edu/asc_papers/43/"}{p_end}
{phang}Lemon, J. 2013. {it:kripp.alpha}. In: Gamer, M./Lemon, J./Fellows, I./Singh, P.{it: Package 'irr': Various Coefficients of Interrater Reliability and Agreement} 
(version 0.84). {browse "http://ftp5.gwdg.de/pub/misc/cran/web/packages/irr/index.html"}.


{marker acknowledgements}{...}
{title:Acknowledgements}

{pstd}
The code computing Krippendorff's alpha coefficient draws on Jim Lemon's implementation "kripp.alpha" for R; the implementation is part of the "irr"-package, maintained by Matthias Gamer.

