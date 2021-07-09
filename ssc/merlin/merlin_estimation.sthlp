{smcl}
{* *! version 0.1.0  ?????2017}{...}
{vieweralsosee "merlin postestimation" "help merlin_postestimation"}{...}
{viewerjumpto "Syntax" "merlin##syntax"}{...}
{viewerjumpto "Description" "merlin##description"}{...}
{viewerjumpto "Options" "merlin##options"}{...}
{viewerjumpto "Examples" "merlin##examples"}{...}
{title:Title}

{p2colset 5 36 39 2}{...}
{p2col:{helpb merlin estimation options} {hline 2}}Options affecting estimation{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 12 2}
{cmd:merlin} {help merlin model notation:{it:models}}
... {cmd:,} ... {it:estimation_options}
 

{synoptset 25}{...}
{synopthdr:estimation_options}
{synoptline}
{synopt :{cmd:from(}{it:{help merlin_estimation##matname:matname}}{cmd:)}}specify starting values{p_end}
{synopt :{cmdab:restartv:alues(}{it:{help merlin_estimation##svlist:sv_list}}{cmd:)}}specify starting values for specific random effect variances{p_end}
{synopt :{cmdab:apstartv:alues(#)}}specify the starting value for all ancilary parameters; see details{p_end}
{synopt :{cmd:zeros}}specify all initial values set to {cmd:0}; see details{p_end}
{synopt :{cmd:random}}specify all initial values set to draws from U(0,1); see details{p_end}

{synopt :{cmdab:intm:ethod(}{it:{help merlin_estimation##intmethod:intmethod}}{cmd:)}}integration method{p_end}
{synopt :{opt intp:oints(#)}}set the number of integration points{p_end}
{synopt :{cmdab:adapt:opts(}{it:{help merlin_estimation##adaptopts:adaptopts}}{cmd:)}}options for adaptive quadrature{p_end}

{synopt :{it:{help merlin##maximize_options:maximize_options}}}control the maximization process for specified model; seldom used{p_end}
{synoptline}

{synoptset 25}{...}
{marker intmethod}{...}
{synopthdr :intmethod}
{synoptline}
{synopt :{opt mv:aghermite}}mean-variance adaptive Gauss-Hermite quadrature;
the default{p_end}
{synopt :{opt gh:ermite}}nonadaptive Gauss-Hermite quadrature{p_end}
{synopt :{opt mc:arlo}}Monte-Carlo integration using Halton sequences or anti-thetic sampling; see details{p_end}
{synoptline}
{p2colreset}{...}

{synoptset 25}{...}
{marker adaptopts}{...}
{synopthdr :adaptopts}
{synoptline}
{synopt: [{cmd:{ul:no}}]{opt lo:g}}whether to display the iteration log
for each numerical integral calculation{p_end}
{synopt: {opt iterate(#)}}number of iterations to update integration points; default {cmd:1001}{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
These options control how results are obtained,
from starting values, to numerical integration (also known as quadrature),
to how variance estimates are obtained.


{marker options}{...}
{title:Options}

{marker matname}{...}
{phang}
{opt from(matname)} allows you to specify starting values. Use {cmd:ml display} following estimation of a model to see 
the equation names to help with specifying starting values.

{marker svlist}{...}
{phang}
{opt restartvalues(sv_list)} allows you to specify starting values for specific random effect variances. For example, 
if you fitted a model such as, 

{phang2}
{cmd:merlin (logb time time#M2[id] M1[id], family(gaussian))}

{p 8 8 2}
then you can override the default starting values (of 1) for the variances of the random effects {cmd:M1} and {cmd:M2}, by 
specifying something like 

{phang2}
{cmd:merlin (logb time time#M2[id] M1[id], family(gaussian)), restartvalues(M1 0.5 M2 0.1)}

{p 8 8 2}
The default of 1 for all random effect variances can often be poor in complex models. This can solve the problem. Note, {cmd:merlin} 
estimates on the scale of the log standard deviation for the random effects, but values should be passed to {cmd:restartvalues()} as variances.

{phang}
{opt apstartvalues(#)} allows you to specify a starting value for all ancillary parameters, i.e those defined by 
using the {cmd:nap()} option. 

{phang}
{opt zeros} tells {cmd:merlin} to use {cmd:0} for all parameters starting values, rather than fit the fixed effect model. Both {cmd:restartvalues()} 
and {cmd:apstartvalues()} can be used with {cmd:zeros}.

{phang}
{opt random} tells {cmd:merlin} to use draws from a Uniform distribution {it:U}(0,1) for all parameter 
starting values, rather than fit the fixed effect model. Both {cmd:restartvalues()} 
and {cmd:apstartvalues()} can be used with {cmd:random}.

{phang}
{opt intmethod(intmethod)},
{opt intpoints(#)}, and
{opt adaptopts(adaptopts)}
        affect how integration for the latent variables is numerically
        calculated.

{pmore}
        {opt intmethod(intmethod)} specifies the method and defaults
        to {cmd:intmethod(mvaghermite)}.  The current implementation uses mean-variance adaptive quadrature 
		at the highest level, and non-adaptive at lower levels. Sometimes it is useful to fall back
        on the less computationally intensive and less accurate
        {cmd:intmethod(ghermite)} and then perhaps use one of the other more accurate
        methods.  

{pmore}
        {cmd:intmethod(mcarlo)} tells {cmd:merlin} to use Monte-Carlo integration, which either uses Halton 
		sequences with normally-distributed random effects, or anti-thetic random draws with {it:t}-distributed 
		random effects.

{pmore}
        {opt intpoints(#)} specifies the number of integration points
        to use and defaults to {cmd:intpoints(7)} with {cmd:intmethod(mvaghermite)} or {cmd:intmethod(ghermite)}, 
		and {cmd:intpoints(150)} with {cmd:intmethod(mcarlo)}.  Increasing the number
        increases accuracy but also increases computational time.
        Computational time is roughly proportional to the number specified.

{phang}
        {opt adaptopts(adaptopts)} affects the adaptive part of
        adaptive quadrature (another term for numerical integration) and
        thus is relevant only for {cmd:intmethod(mvaghermite)}.

{pmore}
        {cmd:adaptopts()} defaults to
        {cmd:adaptopts(nolog iterate(1001))}.

{pmore}
[{cmd:no}]{cmd:log}
        specifies whether iteration logs are shown each
        time a numerical integral is calculated.

{pmore}
{cmd:iterate(#)} specifies the number of iterations to update the 
		integration points, which will include updating prior to iteration {cmd:0} in 
		the maximisation process.
		
{marker maximize_options}{...}
{phang}
{it:maximize_options}
     specify the standard and rarely specified options for controlling the
     maximization process; see {manhelp maximize R}.  The relevant options for
     {cmd:merlin} are
{opt dif:ficult},
{opth tech:nique(maximize##algorithm_spec:algorithm_spec)}, 
{opt iter:ate(#)}, [{cmd:{ul:no}}]{opt lo:g}, {opt tr:ace}, 
{opt grad:ient}, {opt showstep},
{opt hess:ian},
{opt tol:erance(#)},
{opt ltol:erance(#)},
{opt nrtol:erance(#)}, and
{opt nonrtol:erance}.


{marker examples}{...}
{title:Examples}

{phang}
For detailed examples, see {bf:{browse "https://www.mjcrowther.co.uk/software/merlin":mjcrowther.co.uk/software/merlin}}.

{pstd}Setup{p_end}
{phang2}{cmd:. use http://fmwww.bc.edu/repec/bocode/s/stjm_pbc_example_data, clear}{p_end}

{pstd}Linear mixed effects model with random intercept and slope using Monte Carlo integration{p_end}
{phang2}{cmd:. merlin (logb time age trt time#M1[id]@1 M2[id]@1, family(gaussian)), intmethod(mcarlo)}{p_end}


