{smcl}
{* *! version 1.0}{...}
{cmd:help postsim}
{hline}

{title:Title}

{phang}
{bf:postsim} {hline 2} Post-estimation simulation


{title:Syntax}

{p 8 18 2}
{cmd:postsim}
        {it:{help exp_list}}
        [{cmd:,} {it:options}]
        {cmd::} {it:command}

{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt :{opt r:eps(#)}}perform {it:#} replications; default is 
	{cmd:reps(1000)}{p_end}

{syntab:Options}
{synopt :{help prefix_saving_option:{bf:{ul:sav}ing(}{it:filename}{bf:, ...)}}}
  save results to {it:filename}; 
	save values in double precision;
	overwrite {it:filename};
	append results to {it:filename}{p_end}

{syntab:Advanced}
{synopt :{opt seed(#)}}set random-number seed to {it:#}{p_end}
{synopt :{opt forcepsd}}force the covariance matrix to be positive
semidefinite{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{opt svy} is allowed; see {manhelp svy SVY:svy}.{p_end}
{p 4 6 2}
{cmd:postsim} is intended for use in conjunction with {cmd:{help simqoi}}.{p_end}


{title:Description}

{pstd}
{cmd:postsim} simulates the main and ancillary parameters of a statistical
model from their asymptotic sampling distribution
({help simqoi##refs:Gelman et al, 2013, ch. 4}).
Specifically, typing

{phang2}
{cmd:. postsim} {it:exp_list}{cmd:,} {opt reps(#)}{cmd::} {it:command}

{pstd}
executes {it:command}, and simulates {opt reps(#)} values of the parameters
in {it:{help exp_list}} from a multivariate normal distribution with vector of means {cmd:e(b)} and covariance matrix {cmd:e(V)} (See {help ereturn}).

{pstd}
{it:command} defines the estimation command to be executed.
Most Stata commands and user-written programs can be used with {cmd:postsim},
as long as they have {cmd:e(b) e(V)} properties and follow
{help language:standard Stata syntax}.
The {cmd:by} prefix may not be part of {it:command}.

{pstd}
{it:{help exp_list}} specifies the parameters to be simulated from the
execution of {it:command}.
{it:exp_list} is optional and defaults to {cmd:_b}.

{pstd}
The expressions in {it:exp_list} are assumed to conform to the following
grammar.
Note that {it:exp_list} should not be enclosed in parentheses,
though individual expressions may be.

{p2colset 9 32 36 2}{...}
{p2col :{it:exp_list} contains}{cmd:(}{it:name}{cmd::} {it:elist}{cmd:)}{p_end}
{p2col :}{it:elist}{p_end}
{p2col :}{it:eexp}{p_end}

{p2col :{it:elist} contains}{it:newvarname} = {opt (exp)}{p_end}
{p2col :}{opt (exp)}{p_end}

{p2col :{it:eexp} is}{it:specname}{p_end}
{p2col :}{cmd:[}{it:eqno}{cmd:]}{it:specname}{p_end}

{p2col :{it:specname} is}{cmd:_b}{p_end}
{p2col :}{cmd:_b[]}{p_end}

{p2col :{it:eqno} is}{cmd:#}{it:#}{p_end}
{p2col :}{it:name}{p_end}

{pmore}
{it:exp} is a standard Stata expression; see help {help exp}.

{pstd}
Because statistical simulation is a random process, the values generated
are a function of the current random-number seed or the number specified with
{cmd:set seed()}.
If you want to be able to reproduce results, set the random-number
seed by specifying the {opt seed(#)} option or by typing

{phang2}
{cmd:. set seed} {it:#}

{pstd}
where {it:#} is a seed of your choosing, before running {cmd:postsim}; see
{manhelp set_seed R:set seed}.


{title:Options}

{dlgtab:Main}

{phang}
{opt reps(#)} specifies the number of replications or simulations to be performed.
The default is 1000.
The approximation to the asymptotic distribution becomes more accurate as #
increases.

{dlgtab:Options}

{phang}
{help prefix_saving_option:{bf:saving}({it:filename}[, {it:suboptions}])} creates
a Stata data file ({opt .dta} file) consisting of, for each parameter in
{it:{help exp_list}}, a variable containing simulated values.

{phang2}
{opt double} specifies that the results for each replication be stored as
{opt double}s, meaning 8-byte reals.
By default, they are stored as {opt float}s, meaning 4-byte reals.

{phang2}
{opt replace} specifies that {it:filename} be overwritten, if it exists.

{phang2}
{opt append} appends simulated data to the end of {it:filename}.

{dlgtab:Advanced}

{phang}
{opt seed(#)} sets the random-number seed.
Specifying this option is equivalent to typing the following command prior
to calling {cmd:postsim}:

{phang2}
{cmd:. set seed} {it:#}

{phang}
{opt forcepsd} modifies the covariance matrix to be positive semidefinite (psd), 
and so be a proper covariance matrix.
If the covariance matrix is not positive semidefinite, it will have negative eigenvalues.
By setting negative eigenvalues to 0 and reconstructing, we obtain the least-squares
positive-semidefinite approximation.
This approximation is a singular covariance matrix.


{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. sysuse auto}{p_end}

{pstd}Simulate model parameters{p_end}
{phang2}{cmd:. postsim, saving(sims): probit foreign weight mpg}{p_end}
{phang2}{cmd:. describe using misms}{p_end}

    {hline}
{pstd}Setup{p_end}
{phang2}{cmd:. webuse nhanes2d}{p_end}
{phang2}{cmd:. svyset}

{pstd}Logistic regression using survey data{p_end}
{phang2}{cmd:. postsim, saving(sims, replace): svy: logit highbp height weight age female}{p_end}

    {hline}


{title:Saved results}

{pstd}
{cmd:postsim} saves the following in {cmd:r()}:

{synoptset 13 tabbed}{...}
{p2col 5 13 17 2: Scalars}{p_end}
{synopt:{cmd:r(N_reps)}}number of replications{p_end}

{synoptset 13 tabbed}{...}
{p2col 5 13 17 2: Macros}{p_end}
{synopt:{cmd:r(prefix)}}{cmd:postsim}{p_end}
{synopt:{cmd:r(cmdline)}}command as typed{p_end}
{synopt:{cmd:r(seed)}}initial random-number seed{p_end}

{synoptset 13 tabbed}{...}
{p2col 5 13 17 2: Matrices}{p_end}
{synopt:{cmd:r(b)}}simulated estimates{p_end}
{synopt:{cmd:r(V)}}simulated variance-covariance matrix{p_end}


{marker refs}{...}
{title:References}

{phang}
Andrew Gelman, John B. Carlin, Hal S. Stern, David B. Dunson, Aki Vehtari, and Donald B. Rubin. 2013.
{it:Bayesian Data Analysis}. 
CRC Press.


{title:Author}

{phang}
Javier M{c a'}rquez Pe{c n~}a,{break}
Buend{c i'}a & Laredo, Mexico City.{break}
javier.marquez@buendiaylaredo.com{break}
{browse "http://javier-marquez.com/software/moreclarify"}


{title:Also see}

{psee}
{space 2}Help:  {cmd:{help simqoi}}, {cmd:{help estsimp}} (if installed);{break}
{manhelp bootstrap R}, {manhelp jackknife R}, {manhelp permute R}, {manhelp simulate R}
{p_end}