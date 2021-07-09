{smcl}
{* 23feb2013}{...}
{cmd:help oppincidence}
{hline}

{title:Title}

{p2colset 5 15 17 2}{...}
{p2col :{hi:oppincidence} {hline 2}}Ex-Ante Inequality of Opportunity{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 15 2}
    {cmd:oppincidence} {varlist} {ifin} {weight}{cmd:,} {opth gr:oupby(varlist)}
	
{p 4 4 2}
{cmd:fweight}, {cmd:aweight} and {cmd:iweight} are allowed; see help {help weights}.

{title:Options}

{p 4 8 2}
{opth groupby(varlist)} specifies the variables that make up the circumstances sets. 

{title:Description}

{pstd} {cmd:oppincidence} measures ex-ante inequality of opportunity across different
income concepts specified in {it:varlist} by circumstances sets specified by
the variables in {cmd:groupby()}. For example, one circumstances set could be 
(female, black, parents were college graduates, urban): all individuals with those four traits are grouped together in 
that circumstances set. Circumstances are pre-determined factors that are not dependent on an 
individual’s effort, such as race, gender, and parents’ education or parents’ income. A smoothed income distribution 
is created by assigning each individual the mean income of the individuals in his or 
her circumstances set. Inequality (measured using mean log deviation) of the smoothed income distribution for each income 
concept gives the measure of inequality of opportunity in levels by income concept. 
This is labeled "In levels". Dividing the resulting measure by the 
mean log deviation for the actual income distribution measures the ratio of inequality
due to inequality of opportunity as opposed to inequality of effort. This is labeled "In ratios".

{title:Examples}

{phang} {cmd:. oppincidence ym_BC yn_BC yd_BC ypf_BC yf_BC [aw=s_weight], groupby(male race fathers_education mothers_education rural) // use scaled income}

{title:Saved Results}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(levels)}}MLD of smoothed distribution
    {p_end}
{synopt:{cmd:r(ratios)}}MLD of smoothed distribution over MLD of original distribution
    {p_end}

{title:Author}

{p 4 4 2}Sean Higgins, Tulane University, shiggins@tulane.edu


{title:References}

{phang}
Lustig, N. and S. Higgins. 2012.
{browse "http://econ.tulane.edu/RePEc/pdf/tul1219.pdf":"Commitment to Equity Assessment (CEQ): Estimating the Incidence of Social Spending, Subsidies and Taxes Handbook,"} pages 52-53.{p_end}
{phang}
Ferreira, F. and J. Gignoux. 2011.
{browse "http://onlinelibrary.wiley.com/doi/10.1111/j.1475-4991.2011.00467.x/abstract":"The Measurement of Inequality of Opportunity: Theory and an Application to Latin America,"}{it:Review of Income and Wealth 57}(4): 622-657.{p_end}

