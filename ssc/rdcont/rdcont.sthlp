{smcl}
{* *! version 2.0.0 15apr2020}{...}
{cmd:help rdcont}
{hline}

{title:Title}

    {hi:rdcont} {c -} Approximate sign test for testing continuity of a density at a point 

{title:Syntax}
{p 8 17 2}
{cmd:rdcont} {it:running_var} [{opt if}] [{opt in}]{cmd:,}
  [{it:options}]

{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:{help rdcont##options:Options}}
{synopt:{opt alpha(real)}} specifies critical value for calculation of optimal bandwidth {p_end}
{synopt:{opt threshold(real)}} specifies cutoff value for the test {p_end}
{synopt:{opt q:obs(real)}} specifies # of observations closest to cutoff {p_end}
{synoptline}
{p2colreset}{...}

{title:Description}

{pstd}
In the regression discontinuity design it is common practice to assess the credibility of the design by testing the continuity of the density of the running variable at the cut-off. {cmd:rdcont} tests this assumption using the non-randomized approximate sign test developed in Bugni and Canay (2020). 
{p_end}

{marker options}
{title:Options}
{marker options}
{dlgtab:Options}

{marker alpha}{...}
{phang}
{opt alpha(real)} specifies a critical value for the calculation of the data dependent rule of thumb for {it:q} proposed in Bugni and Canay (2020), referred to in the paper as q_irot (informed rule of thumb). If left unspecified, the default value is 0.05. Cannot be specified with {opt qobs}. {p_end}

{marker threshold}{...}
{phang}
{opt threshold(real)} specifies the cutoff value (point) at which to test continuity of the density. If left unspecified, the default value is 0. {p_end}

{marker qobs}{...}
{phang}
{opt q:band(real)} specifies the number {it:q} of observations used by the test (those that are closest to the cutoff) rather than using the data dependent rule from Bugni and Canay (2019). Cannot be specified with {opt alpha}. {p_end}

{title:Saved Results}

{phang}
{cmd:rdcont} saves the following in {cmd:r()}:{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(q_p)}} Preliminary rule of thumb before optimization stage {p_end}
{synopt:{cmd:r(lb)}} Running variable value corresponding to the left bound of the test bandwidth{p_end}
{synopt:{cmd:r(ub)}} Running variable value corresponding to the right bound of the test bandwidth{p_end}
{synopt:{cmd:r(N_r)}} Number of observations to the right of the threshold{p_end}
{synopt:{cmd:r(N_l)}} Number of observations to the left of the threshold{p_end}
{synopt:{cmd:r(c)}} Running variable threshold{p_end}
{synopt:{cmd:r(q_l)}} Number of observations in the bandwidth to the left of the threshold {p_end}
{synopt:{cmd:r(q_r)}} Number of observations in the bandwidth to the right of the threshold {p_end}
{synopt:{cmd:r(q)}} Number of observations in the bandwidth{p_end}
{synopt:{cmd:r(N)}} Number of observations{p_end}
{synopt:{cmd:r(p)}} {it:p}-value corresponding to the approximate sign test{p_end}
{p2colreset}{...}

{title:Author}

{phang}
Ivan Canay{p_end}
{phang}
iacanay@northwestern.edu
{p_end}

{title:References}

{phang}
Bugni, Federico A. and Ivan A. Canay. (2020) "Testing Continuity of a Density via {it:g}-order 
statistics in the Regression Discontinuity Design." 
{p_end}