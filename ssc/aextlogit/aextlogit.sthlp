{smcl}
{* *! version 1.2 - 16/06/19}{...}
{cmd: help aextlogit}

{hline}

{title:Title}

{p2colset 8 21 23 0}{...}
{p2col :{cmd: aextlogit} {hline 2}}Average elasticities for fixed effects logit{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 12 2}
{cmd:aextlogit}
{depvar}
{indepvars}
{ifin}
[{it:{help aextlogit##weight:weight}}]
[{cmd:,} {it:options}]

{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}

{synopt:{opt gr:oup}}specifies the variable defining the panel{p_end}

{synopt:{opt b:etas}}reports the fixed effects logit estimates{p_end}

{synopt:{opt nolog}}suppress the display of the iteration log{p_end}

{synopt:{opth vce(vcetype)}}{it:vcetype} may be {opt oim}, {opt r:obust}, {opt cl:uster} {it:clustvar}, {opt boot:strap}, or {opt jack:knife}{p_end}

{synopt:{it:{help aextlogit##maximize_options:maximize_options}}}control the maximization process{p_end}


{hline}

{marker weight}{...}
{p 4 6 2}{opt iweights}s are allowed; weights must be constant within panel. See {help weight} for details.{p_end}
 

{title:Description}

{pstd}
{cmd: aextlogit} is a wrapper for {cmd: clogit} which estimates the fixed effects logit and reports estimates of 
the average (semi-) elasticities of Pr(y=1|x,u) with respect to the regressors, and the corresponding standard 
errors and t-statistics. The method used to compute the (semi-) elasticities was first described by Kitazawa (2012); 
see Kemp and Santos Silva (2016) for further details.


{title:Options}

{phang}{opt group(panelvar)} specifies that the variable defining the panel is {it:panelvar}.

{phang}
{opt b:etas} reports the fixed effects logit estimates{p_end}

{phang}
{opt nolog} suppress the display of the iteration log{p_end}

{phang}
{opth vce(vcetype)} {it:vcetype} may be {opt oim}, {opt r:obust}, {opt cl:uster} {it:clustvar}, {opt boot:strap}, or {opt jack:knife}{p_end}

{marker maximize_options}{...}
{phang}
{it:maximize_options}:
{opt tech:nique(string)},
{opt iter:ate(#)},
{opt nolo:g},
{opt tr:ace},
{opt dif:ficult},
{opt grad:ient},
{opt showstep},
{opt hess:ian},
{opt showtol:erance},
{opt tol:erance(#)},
{opt ltol:erance(#)},
{opt nrtol:erance(#)},
{opt nonrtol:erance},
{opt from(init_specs)}; see {manhelp maximize R} for more details.


{title:Remarks}

{pstd}
{cmd: aextlogit} is not an official Stata command and was written by J.M.C. Santos Silva. 
For further help and support, please contact jmcss@surrey.ac.uk. Please notice that this software is provided 
as is, without warranty of any kind, express or implied, including but not limited to the warranties of 
merchantability, fitness for a particular purpose and noninfringement. In no event shall the authors be liable 
for any claim, damages or other liability, whether in an action of contract, tort or otherwise, arising from, 
out of or in connection with the software or the use or other dealings in the software.


{title:Examples}

    {hline}
{pstd}Setup{p_end}

{phang2}{cmd:. webuse union}{p_end}

{phang2}{cmd:. xtset idcode}{p_end}

{pstd}Basic use of {cmd: aextlogit}{p_end}

{phang2}{cmd:. aextlogit union age grade i.not_smsa south##c.year}{p_end}

{pstd}Use of {cmd: aextlogit} with bootstrap standard errors and reporting the fixed effects logit estimates {p_end}

{phang2}{cmd:. aextlogit union age grade i.not_smsa south##c.year, b vce(boot)}{p_end}

{pstd}Estimate the fixed effects logit for comparison{p_end}

{phang2}{cmd:. xtlogit union age grade i.not_smsa south##c.year, fe}{p_end}


{title:Saved results}

{pstd}
The output saved in {cmd:e()} by {cmd:aextlogit} is essentially the same that is saved by {cmd:clogit}; more details can be seen in {help clogit}. 
Some additional results are listed below.


{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(ybar)}}mean of the dependent variable{p_end}
{synopt:{cmd:e(N_ybar)}}number of observations used in the computation of the mean of the dependent variable{p_end}


{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}(semi-) elasticity estimates{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the (semi-) elasticity estimates{p_end}



{title:References}

{phang}
Kemp, G.C.R. and Santos Silva, J.M.C., (2016), 
{it:{browse "http://EconPapers.repec.org/RePEc:boc:usug16:06":Partial effects in fixed-effects models}}, 
United Kingdom Stata Users' Group Meetings 2016, Stata Users Group.

{phang}
Kitazawa, Y. (2012). 
{browse "http://www.scirp.org/journal/PaperInformation.aspx?PaperID=19296":Hyperbolic transformation and average elasticity in the framework of the fixed effects logit model}, 
{it:Theoretical Economics Letters}, 2, 192-199. 

{title:Also see}

{psee}
Manual:  {manlink R clogit} 


{center: Last modified on 16 June 2019}

