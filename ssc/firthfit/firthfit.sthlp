{smcl}
{* *! version 1.0.0, Alexander Staudt, 18apr2016}{...}
{* findalias asfradohelp}{...}
{* vieweralsosee "" "--"}{...}
{* vieweralsosee "[R] help" "help help"}{...}
{vieweralsosee "firthlogit" "help firthlogit"}{...}
{vieweralsosee "fitstat" "help fitstat"}{...}
{viewerjumpto "Syntax" "firthfit##syntax"}{...}
{viewerjumpto "Description" "firthfit##description"}{...}
{* viewerjumpto "Options" "firthfit##options"}{...}
{viewerjumpto "Examples" "firthfit##examples"}{...}
{viewerjumpto "Remarks" "firthfit##remarks"}{...}
{viewerjumpto "Author" "firthfit##author"}{...}
{viewerjumpto "Also see" "firthfit##alsosee"}{...}
{title:Title}

{phang}
{bf:firthfit} {hline 2} Compute measures of fit for Firth's logit models.


{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:firthfit:}

{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{cmd:firthfit} computes measures of fit for Firth's logit models. {cmd:firthfit} reports the likelihoods of the intercept-only (null) model and the full model. 
Furthermore, {cmd:firthfit} computes the model AIC and BIC, Cox-Snell/maximum likelihood R2, Cragg-Uhler/Nagelkerke R2, Efron R2, McFadden R2, McFadden adjusted R2, McKelvey & Zavoina R2, as well as Tjur's D.


{marker examples}{...}
{title:Examples}

{phang}{cmd:. webuse hiv1}{p_end}

{phang}{cmd:. firthlogit hiv cd4 cd8}{p_end}

{phang}{cmd:. firthfit}{p_end}

{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd: firthfit} requires {cmd:firthlogit} to be installed ({cmd:ssc install firthlogit}).

{marker author}{...}
{title:Author}

{phang}Alexander Staudt, Universitaet Mannheim, astaudt@mail.uni-mannheim.de{p_end}

{marker alsosee}{...}
{title:Also see}

{psee}
{help firthlogit}
{p_end}

{psee}
{help fitstat} (if installed)
{p_end}
