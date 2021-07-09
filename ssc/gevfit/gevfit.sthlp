{smcl}
{* November 21, 2007, based on the -betafit- helpfile by Cox, Jenkins, and Buis}{...}
{hline}
help for {hi:gevfit}
{hline}

{title:Fitting a generalized extreme value distribution by maximum likelihood}

{p 8 17 2}
{cmd:gevfit} 
{it:depvar} 
[{it:weight}] 
[{cmd:if} {it:exp}]
[{cmd:in} {it:range}] 
[{cmd:} 
{cmdab:shape:var(}{it:varlist_a}{cmd:)}
{cmdab:scale:var(}{it:varlist_b}{cmd:)} 
{cmdab:loc:ation var(}{it:varlist_c}{cmd:)} 
{cmdab:r:obust}
{cmdab:cl:uster(}{it:clustervar}{cmd:)}  
{cmdab:l:evel(}{it:#}{cmd:)} 
{it:maximize_options} 
]

{p 4 4 2}{cmd:by} {it:...} {cmd::} may be used with {cmd:gevfit}; see help
{help by}. 

{p 4 4 2}{cmd:fweight}s and {cmd:aweight}s are allowed; see help {help weights}.


{title:Description}

{p 4 4 2} {cmd:gevfit} fits by maximum likelihood a three-parameter generalized 
extreme value distribution.


{title:Options}

{p 4 8 2}{cmd:shapevar()}, {cmd:scalevar()} and {cmd:locationvar()} allow the user to specify
each parameter as a function of the
covariates specified in the respective variable list. A constant term is
always included in each equation.

{p 4 8 2}{cmd:robust} specifies that the Huber/White/sandwich estimator
of variance is to be used in place of the traditional calculation; see
{hi:[U] 23.14 Obtaining robust variance estimates}.  {cmd:robust}
combined with {cmd:cluster()} allows observations which are not
independent within cluster (although they must be independent between
clusters). 

{p 4 8 2}{cmd:cluster(}{it:clustervar}{cmd:)} specifies that the observations
are independent across groups (clusters) but not necessarily within groups.
{it:clustervar} specifies to which group each observation belongs; e.g.,
{cmd:cluster(personid)} in data with repeated observations on individuals.  See
{hi:[U] 23.14 Obtaining robust variance estimates}.  Specifying {cmd:cluster()}
implies {cmd:robust}.

{p 4 8 2}{cmd:level(}{it:#}{cmd:)} specifies the confidence level, in percent,
for the confidence intervals of the coefficients; see help {help level}.

{p 4 8 2}{cmd:nolog} suppresses the iteration log.

{p 4 8 2}{it:maximize_options} control the maximization process; see 
help {help maximize}. If you are seeing many "(not concave)" messages in the 
log, using the {cmd:difficult} option may help convergence.


{title:Example}

{p 4 8 2}{cmd:. use yearly_rain}

{p 4 8 2}{cmd:. gevfit rain}


{title:Author}

{p 4 4 2}Scott Merryman, Risk Management Agency (USDA){break}scott.merryman@gmail.com


{title: Acknowledgements}

{p 4 4 2} This is based on {help betafit} by Nick Cox, Stephen Jenkins, and Maarten Buis.


{title:References}

{p 4 4 2}
Coles, Stuart. 2001. {it:An Introduction to Statistical Modeling of Extreme Values.}
London: Springer-Verlag

{p 4 4 2}
Cole, Stuart and Luis Pericchi. 2003. Anticipating catastrophes through extreme value modelling.
{it: Journal Of The Royal Statistical Society Series C}, Royal Statistical Society, vol. 52(4), pages 405{c -}416.


{title:Also see}

{p 4 13 2}
Online: help for {help gumbelfit} (if installed), help for {help gevd} (if installed)



