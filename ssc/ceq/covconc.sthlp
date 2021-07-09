{smcl}
{title:Title}

{phang}
{cmd:covconc} {hline 2} gini and concentration coefficients


{marker syntax}{...}
{title:Syntax}

{p 8 12 2}
{cmd:covconc}
    {it:{help varname:yvar}}
    {ifin}
    [{it:{help covconc##weight:weight}}]
    [{cmd:,} rank({it:{help varname:rvar}})]

{p 4 4 2}
{it:yvar} is an income variable.{break}
{it:rvar} is a ranking variable.{break}
{opt pweight}s are allowed; see {help weight}.{marker weight}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:covconc} estimates the concentration index
{help covconc##VK2009:(Van Kerm, 2009)} of an income variable
{it:{help varname:yvar}}, given a ranking variable {it:{help varname:rvar}}.


{marker options}{...}
{title:Options}

{phang}
{opth rank(varname)}
specifies the ranking variable in the concentration index's calculation.
The default value is {it:yvar}. So, if this option is not specified,
{cmd:covconc} will calculate the gini index.


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:covconc} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt :{cmd:r(gini)}} 
gini index {space 8} (if the ranking variable is omitted).{p_end}
{synopt :{cmd:r(conc)}} 
concentration index (if the ranking variable is provided).{p_end}


{marker references}{...}
{title:References}

{marker VK2009}{...}
{phang}
Van Kerm, Philippe. 2009.
{it:Generalized Gini and Concentration coefficients}
{it:(with factor decomposition) in Stata.}
MeDIM Project,
(Advances in the Measurement of Discrimination, Inequality and Mobility),
Luxembourg.
{p_end}
