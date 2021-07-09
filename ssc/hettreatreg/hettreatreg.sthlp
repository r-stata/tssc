{smcl}
{* 18nov2019}{...}
{hline}
help for {hi:hettreatreg}
{hline}

{title:Title}

{phang}
{bf:hettreatreg} {hline 2} Diagnostics for linear regression when treatment effects are heterogeneous

{marker syntax}
{title:Syntax}

{p 8 17 2}
{cmdab:hettreatreg}
{it:indepvars}
{ifin}{cmd:,}
{opt o:utcome(varname)} {opt t:reatment(varname)} [{it:options}]


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt:{opt o:utcome(varname)}}designate an outcome variable{p_end}
{synopt:{opt t:reatment(varname)}}designate a binary treatment variable{p_end}

{syntab:Optional}
{synopt:{opt noi:sily}}display model estimation output{p_end}
{synopt:{opt vce(vcetype)}}{it:vcetype} may be {opt ols}, {opt r:obust}, 
{opt cl:uster}{space 1}{it:clustvar}, {opt boot:strap}, {opt jack:knife}, 
{opt hc2}, or {opt hc3}; default is {opt ols}{p_end}
{synoptline}


{title:Description}

{pstd} {cmd:hettreatreg} represents OLS estimates of the effect of a binary treatment as a weighted average of the average
treatment effect on the treated (ATT) and the average treatment effect on the untreated (ATU).  The program estimates
the OLS weights on these parameters, computes the associated model diagnostics, and reports the implicit OLS estimate
of the average treatment effect (ATE).  See Sloczynski (2019) for the underlying theoretical results and further details.

{pstd} The options {cmd:outcome} and {cmd:treatment} are required.  They are used to designate an outcome variable
and a treatment variable, respectively.  The treatment variable must be binary and coded 0 for the untreated
units and 1 for the treated units.  {it:indepvars} is a list of control variables that must not include the treatment variable.

{pstd} {cmd:hettreatreg} displays a number of statistics.  {it:OLS} is the estimated regression coefficient on the
treatment variable.  {it:P(d=1)} and {it:P(d=0)} are the sample proportions of treated and untreated units,
respectively.  {it:w1} and {it:w0} are the OLS weights on ATT and ATU, respectively.  {it:delta} is a diagnostic
for interpreting OLS as ATE.  {it:ATE}, {it:ATT}, and {it:ATU} are the implicit OLS estimates of the corresponding
parameters.  See Sloczynski (2019) for further details.

{pstd} If the option {cmd:noisily} is specified, {cmd:hettreatreg} also displays the usual regression output, as obtained
by {cmd:regress}.  The option {cmd:vce} specifies the type of standard error for {cmd:regress}.  Using {cmd:outreg2}
provides the same output after {cmd:regress} and {cmd:hettreatreg}, with {cmd:hettreatreg} offering the additional advantage of
reporting the diagnostics from Sloczynski (2019), including the OLS weights on ATT and ATU.  See an example
below.  Statistical inference may proceed using {cmd:bootstrap}.  An example is also provided below.

{pstd} If you use this program in your work, please cite Sloczynski (2019).


{title:References}

{phang}
Sloczynski, Tymon (2019). "Interpreting OLS Estimands When Treatment Effects Are Heterogeneous: Smaller Groups Get Larger
Weights." Available at {browse "http://people.brandeis.edu/~tslocz/Sloczynski_paper_regression.pdf"}.


{title:Examples}

        {com}. {stata "use http://people.brandeis.edu/~tslocz/nswcps.dta, clear"}

        . {stata "regress re78 treated age-re75, vce(robust)"}

        . {stata "hettreatreg age-re75, o(re78) t(treated) noisily vce(robust)"}

        . {stata "hettreatreg age-re75, o(re78) t(treated)"}

        . {stata "outreg2 using myfile, excel keep(treated) e(p1 w1 w0 delta ate att atu)"}

        . {stata "bootstrap e(w1) e(w0) e(delta) e(ate) e(att) e(atu), seed(123456789): hettreatreg age-re75, o(re78) t(treated)"}
        {txt}

{title:Stored results}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations
    {p_end}
{synopt:{cmd:e(r2)}}R-squared, as obtained by {cmd:regress}
    {p_end}
{synopt:{cmd:e(ols1)}}OLS estimate of the treatment effect, as obtained by {cmd:regress}
    {p_end}
{synopt:{cmd:e(ols2)}}OLS estimate of the treatment effect, obtained as {cmd:e(w1)}*{cmd:e(att)}+{cmd:e(w0)}*{cmd:e(atu)}
    {p_end}
{synopt:{cmd:e(ate)}}implicit OLS estimate of ATE
    {p_end}
{synopt:{cmd:e(att)}}implicit OLS estimate of ATT
    {p_end}
{synopt:{cmd:e(atu)}}implicit OLS estimate of ATU
    {p_end}
{synopt:{cmd:e(p1)}}proportion of treated units
    {p_end}
{synopt:{cmd:e(p0)}}proportion of untreated units
    {p_end}
{synopt:{cmd:e(w1)}}OLS weight on ATT
    {p_end}
{synopt:{cmd:e(w0)}}OLS weight on ATU
    {p_end}
{synopt:{cmd:e(delta)}}diagnostic for interpreting OLS as ATE
    {p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:hettreatreg}
    {p_end}
{synopt:{cmd:e(cmdline)}}command as typed
    {p_end}
{synopt:{cmd:e(depvar)}}name of dependent (outcome) variable
    {p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}
    {p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector, as obtained by {cmd:regress}
    {p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix, as obtained by {cmd:regress}
    {p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}


{title:Author}

{p 4 4 2}Tymon Sloczynski, Brandeis University, tslocz@brandeis.edu, {browse "http://people.brandeis.edu/~tslocz/"}

{p 4 4 2}Please feel free to report bugs and share your comments on this program.

