{smcl}
{* 21may2017}{...}
{hi:help ihstrans}
{hline}

{title:Title}

{phang}
{bf:ihstrans} {hline 2} Generate inverse hyperbolic sine (IHS) transformed variables out of a list of multiple variables


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:ihstrans}
[{varlist}]
{ifin}
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opth k:eep(varlist)}}variables to keep from using{p_end}
{synopt:{opt p:refix(string)}}specifies the prefix for the newly generated variables; default is "ihs_"{p_end}
{synopt:{opt c:asewise}}use casewise deletion to handle missing values{p_end}
{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:ihstrans} is a tool for inverse hyperbolic sine (IHS)-transformation of multiple variables.
The command can process multiple variables at once, and therefore can handle datasets that are in wide format and allows for setting casewise missings for observations.
The program automatically detects string variables and keeps them from transformation to avoid an abrupt ending.
Additionally, variables identifying panel and time within a panel dataset (see {help xtset}) are also kept from the process of generating new variables.

{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opth keep(varlist)} specifies the variables for which no transformation will be executed. By default, IHS-transformed derivatives of all non-string variables will be created.
{p_end}

{phang}
{opth prefix(string)} specifies the prefix for the newly generated variables. By default, the string "ihs_" is placed in front of all variables set in {it: varlist}.
{p_end}

{phang}
{opt casewise} handles missing values through listwise deletion, meaning that the entire observation is omitted from the estimation sample if any of the variables in {it: varlist} is missing for that observation.
{p_end}

{marker Remarks}{...}
{title:Remarks}

{pstd}
The transformation of variables is a common practice in statistics in general, and multiple regression analysis in particular.
When variables have at the same time extreme values as well as zeroes, the log-transformation, however, is not a convenient option, since log(0) is not defined.
The IHS-function is an appropriate alternative to log-transformation, since it is approximately equal to the logarithmic function, except that its domain is the entire real line and therefore it is defined at zero.
Due to these properties, using the IHS function is a proper form of transforming variables that have extreme values and zeroes at the same time (e.g. income or worth of owned property).
The IHS is defined as y=log(x+sqrt(x^2+1)) and the plotted function can be obtained with the following syntax: {cmd:}{stata twoway function y=ln(x+sqrt(x^2+1)), range(-10 10) yline(0) xline(0)}.
For a more detailled discussion, see Burbidge et al. (1988).
{p_end}

{marker examples}{...}
{title:Examples}

1st example: IHS-transformation for all variables (except integer)

{phang}{cmd:.}{stata sysuse auto, clear}

{phang}{cmd:.}{stata ihstrans}

2nd example: IHS-transformation for selected variables, casewise missings

{phang}{cmd:.}{stata sysuse auto, clear}

{phang}{cmd:.}{stata ihstrans price-trunk, keep(headroom) casewise}

3rd example: IHS-transformation for specific sample

{phang}{cmd:.}{stata sysuse xtline1, clear}

{phang}{cmd:.}{stata  ihstrans if inlist(person,1,2) & tin(01jan2002, 31jan2002)}

{marker References}{...}
{title:References}

{phang}Burbidge, J. B., Magee, L., & Robb, A. L. (1988). Alternative transformations to handle extreme values of the dependent variable. Journal of the American Statistical Association, 83(401), 123-127.

{marker Author}{...}
{title:Author}

{phang}Jan Helmdag, Department of Political Science, University of Greifswald, Germany



