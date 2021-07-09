{smcl}

{* * ! version 1.0 3-6-2011}{...}
{cmd:help quickicc}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:quickicc} {hline 2}}Intraclass correlation and standard error calculation after XTMIXED {p_end}
{p2colreset}{...}

{title:Syntax}
{p 8 17 2}
{cmd:quickicc}

{title:Description}

{pstd}{cmd:quickicc} calcuates the intraclass correlation (ICC) after fitting a
two-level xtmixed model where the intercept is the only random effect.  In addition to 
calculating the ICC, this program also calculates the standard error of the 
maximum likelihood large sample ICC (see reference).

{title:Examples}

{phang}First, fit an xtmixed model

{phang}{cmd:. use iccexample.dta, clear}{p_end}

{phang}{cmd:. xtmixed machach || l2id:}{p_end}

{phang}Then, type quickicc

{phang}{cmd:. quickicc}{p_end}

{phang}You can also find ICCs after models with several fixed effects

{phang}{cmd:. xtmixed machach f b h || l2id:}{p_end}

{phang}{cmd:. quickicc}{p_end}

{title:Saved results}

{pstd}
{cmd:quickicc} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(l1vc)}}the level 1 variance component{p_end}
{synopt:{cmd:r(l2vc)}}the level 2 variance component{p_end}
{synopt:{cmd:r(tv)}}the total variance{p_end}
{synopt:{cmd:r(N)}}the number of observations from the xtmixed command{p_end}
{synopt:{cmd:r(m)}}the number of groups from the xtmixed command{p_end}
{synopt:{cmd:r(icc)}}the intraclass correlation{p_end}
{synopt:{cmd:r(se)}}the standard error of the intraclass correlation{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(model)}}the previous xtmixed command{p_end}

{title:References}

{phang}
Donner, A. & J. J. Koval.  1980.  The Large Sample Variance of an Intraclass Correlation.  
Biometrika. 67:3. 719-722.
{p_end}


