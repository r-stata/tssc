{smcl}
{* *! version 1.0.0  10dec2013}{...}
{viewerjumpto "Syntax" "smvcir##syntax"}{...}
{viewerjumpto "Description" "smvcir##description"}{...}
{viewerjumpto "Options smvcir" "smvcir##smvcir_options"}{...}
{viewerjumpto "Options smvcir plot" "smvcir##smvcir_plot_options"}{...}
{viewerjumpto "Examples" "smvcir##examples"}{...}
{viewerjumpto "Stored results" "smvcir##results"}{...}
{viewerjumpto "Reference" "smvcir##reference"}{...}
{title:Title}

{p2colset 5 15 18 2}{...}
{p2col :{hi:smvcir} {hline 2}}Sliced mean variance-covariance inverse regression{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 4 4 2}
Estimate spanning set of difference space and its dimension

{p 8 16 2}
{cmd:smvcir} {depvar} {indepvars} {ifin}  
[{cmd:,}{it:{help fp##smvcir_options:smvcir_options}}] 

{p 4 4 2}
Plot difference dimensions

{p 8 16 2}
{cmd: smvcir plot} [{cmd:,} 
{it:{help smvcir##smvcir_plot_options:smvcir_plot_options}}]

{p 4 4 2}
Produce standardized coefficients

{p 8 16 2}
{cmd: smvcir std} [{cmd:,} {opth d:imensions(numlist)}]


{synoptset 20 tabbed}{...}
{synopthdr:smvcir_options}
{synoptline}
{syntab:Reporting}
{synopt:{opt notest}}omit dimensionality test{p_end}
{synopt:{opt noscree}}omit scree plot{p_end}
{synopt:{opt l:evel(#)}}set confidence level; default is
	{cmd:level(95)}{p_end}
{synopt:{opt discl:evel(#)}}set discrimination strength level; default is
	{cmd:disclevel(100)}.{p_end}
{synoptline}
{p2colreset}{...}

{synoptset 27 tabbed}{...}
{synopthdr:smvcir_plot_options}
{synoptline}
{syntab:Main}
{synopt:{opth d:imensions(numlist)}}set difference dimensions to plot{p_end}
{synopt:{opth g:roups(numlist)}}set groups to plot{p_end}

{syntab:Scatter}
{synopt:{cmd:plot}{it:#}{cmd:opts(}{it:{help marker_options:marker_options}}{cmd:)}}affect the rendition of group {it:#}s scatter points{p_end}

{syntab:Fit line}
{synopt:{cmd:line}{it:#}{cmd:opts(}{it:{help cline_options:cline_options}}{cmd:)}}affect the rendition of the linear regression lines for group {it:#}{p_end}

{syntab:Overall plot options}
{p2col:{cmdab:ycom:mon}}give {it:y} axes common scales{p_end}
{p2col:{cmdab:xcom:mon}}give {it:x} axes common scales{p_end}

{p2col:{it:{help title_options}}}title to appear on combined graph{p_end}
{p2col:{it:{help region_options}}}outlining, shading, aspect ratio{p_end}

{p2col:{cmdab:com:monscheme}}put graphs on common scheme{p_end}
{p2col:{helpb scheme_option:{ul:sch}eme({it:schemename})}}overall look{p_end}
{p2col:{help name_option:{bf:name(}{it:name}{bf:, ...)}}}specify name for
        combined graph{p_end}
{p2col:{help saving_option:{bf:saving(}{it:filename}{bf:, ...)}}}save combined
        graph in file{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:smvcir} performs the sliced mean variance–covariance inverse regression
(SMVCIR) algorithm on grouped multivariate data.  The data is transformed to a
new coordinate system where the group mean, variance, and covariance
differences are more apparent.  A test for the dimension of this new coordinate space is also provided.  

{pstd}
See {help smvcir##CL2013:Lindsey et. al (2013)} for details on the SMVCIR algorithm.


{marker smvcir_options}{...}
{title:Options for smvcir}

{dlgtab:Reporting}

{phang}
{opt notest} omits the dimensionality test of the SMVCIR space.

{phang}
{opt noscree} omits the scree plot of the singular values of the SMVCIR
spanning set.

{phang}
{opt level(#)}; see {helpb estimation options##level():[R] estimation options}.

{phang}
{opt disclevel(#)} sets the discrimination strength level, a measure of
practical significance.  This is an acceptable percentage of the total singular
value sum that is represented by the singular values of the chosen number of
dimensions.  The default is {cmd:disclevel(100)}.


{marker smvcir_plot_options}{...}
{title:Options for smvcir plot}

{dlgtab:Main}

{phang}
{opth dimensions(numlist)} specifies which difference dimensions to plot.

{phang}
{opth group(numlist)} specifies which groups to plot.

{dlgtab:Scatter}

{phang}
{opth plot#opts(marker_options)} affects the rendition of the scatter points for group {it:#}, including the size and color of markers.

{dlgtab:Fit line}

{phang}
{opth line#opts(cline_options)} affects the rendition of the linear regression lines for group {it:#}.

{dlgtab:Overall plot options}

{phang}
{cmd:ycommon}
and
{cmd:xcommon}
    specify that the individual graphs previously drawn by {cmd:graph}
    {cmd:twoway}, and for which the {cmd:by()} option was not specified,
    be put on common {it:y} or {it:x} axes scales.  See
    {it:{help graph combine##remarks3:Combining twoway graphs}} under
    {it:Remarks} below.

{pmore} These options have no effect when applied to the categorical axes of
{cmd:bar}, {cmd:box}, and {cmd:dot} graphs.  Also, when {cmd:twoway} graphs
are combined with {cmd:bar}, {cmd:box}, and {cmd:dot} graphs, the options
affect only those graphs of the same type as the first graph combined.

{phang}
{it:title_options}
    allow you to specify titles, subtitles, notes, and captions
    to be placed on the combined graph; see {manhelpi title_options G-3}.

{phang}
{it:region_options}
    allow you to control the aspect ratio, size, etc., of the combined graph;
    see {manhelpi region_options G-3}.  Important among these options are
    {cmd:ysize(}{it:#}{cmd:)} and {cmd:xsize(}{it:#}{cmd:)}, which specify the
    overall size of the resulting graph.  It is sometimes desirable to make
    the combined graph wider or longer than usual.

{phang}
{cmd:commonscheme} and {opt scheme(schemename)}
    are for use when combining graphs that use different schemes.  By default,
    each subgraph will be drawn according to its own scheme.

{pmore}
    {cmd:commonscheme} specifies that all subgraphs be drawn using the same
    scheme and, by default, that scheme will be your default scheme.

{pmore}
    {cmd:scheme(}{it:schemename}{cmd:)} specifies that the
    {it:schemename} be used instead; see {manhelpi scheme_option G-3}.

{phang}
{cmd:name(}{it:name}[{cmd:, replace}]{cmd:)}
    specifies the name of the resulting combined graph.
    {cmd:name(Graph, replace)} is the default.
    See {manhelpi name_option G-3}.

{phang}
{cmd:saving(}{it:{help filename}}[{cmd:, asis replace}]{cmd:)}
    specifies that the combined graph be saved as {it:filename}.  If
    {it:filename} is specified without an extension, {cmd:.gph} is assumed.
    {cmd:asis} specifies that the graph be saved in as-is format.
    {cmd:replace} specifies that, if the file already exists, it is okay to
    replace it.  See {manhelpi saving_option G-3}.


{marker examples}{...}
{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. use wine}{p_end}

{pstd} Estimate SMVCIR spanning set {p_end}
{phang2}{cmd:. smvcir cultivar alcohol-proline, disclevel(70)}{p_end}

{pstd} Plot SMVCIR dimensions{p_end}
{phang2}{cmd:. smvcir plot}{p_end}

{pstd} Show standardized coefficients{p_end}
{phang2}{cmd:. smvcir std}{p_end}


{marker results}{...}
{title:Stored results}

{synoptset 27 tabbed}{...}
{p2col 5 27 31 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(k)}}number of predictors{p_end}
{synopt:{cmd:e(g)}}number of groups{p_end}
{synopt:{cmd:e(d_test)}}statistically significant dimension{p_end}
{synopt:{cmd:e(d_prac)}}practically significant dimension{p_end}
{synopt:{cmd:e(d)}}min({cmd:d_test},{cmd:d_prac}){p_end}
{synopt:{cmd:e(level)}}statistical significance level{p_end}
{synopt:{cmd:e(disclevel)}}practical significance level{p_end}

{synoptset 27 tabbed}{...}
{p2col 5 27 31 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:smvcir}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(depvar)}}dependent variable{p_end}
{synopt:{cmd:e(predictors}}independent vairables{p_end}

{synoptset 27 tabbed}{...}
{p2col 5 27 31 2: Matrices}{p_end}
{synopt:{cmd:e(Spanset)}}SMVCIR spanset{p_end}
{synopt:{cmd:e(Spanset_Vt)}}right singular vectors of SMVCIR spanset{p_end}
{synopt:{cmd:e(Spanset_U)}}left singular vectors of SMVCIR spanset{p_end}
{synopt:{cmd:e(Sv)}}singular values of SMVCIR spanset{p_end}
{synopt:{cmd:e(Spanset2)}}SMVCIR kernel{p_end}
{synopt:{cmd:e(Spanset2_eigvals)}}eigenvalues of SMVCIR kernel{p_end}
{synopt:{cmd:e(Spanset2_eigvecs)}}eigenvectors of SMVCIR kernel{p_end}
{p2colreset}{...}


{marker reference}{...}
{title:Reference}

{marker CL2013}{...}
{phang}
Lindsey, C. L. and S. J. Sheather, and J. W. McKean. 2013.  Using sliced mean variance–covariance inverse regression for classification and dimension reduction.  Computational Statistics. http://dx.doi.org/10.1007/s00180-013-0460-3
{p_end}

