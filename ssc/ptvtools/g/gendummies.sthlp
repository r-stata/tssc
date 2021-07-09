{smcl}
{cmd:help gendummies}
{hline}

{title:Title}

{p2colset 5 20 22 2}{...}
{p2col :gendummies {hline 2}}Generates a set of dummy variables with suffixes taken from category codes{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{opt gendummies} {varname}
   [{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opth pre:fix(name)}} prefix for generated dummy variables (default is to use as a prefix 
the name of the variable from which the dummies are generated){p_end}
{synopt :{opt inc:ludemissing}} if specified, include missing values as zeros{p_end}
{synoptline}

{title:Description}

{pstd}
{cmd:gendummies} generates a set of dummy variables from a categorical variable, using as suffixes the codes 
actually found in the data, with the option of generating a set of zeros on all dummy variables when {it:varname} 
has a missing value.

{pstd}
SPECIAL NOTE ON MULTIPLE BATTERIES: {cmd:gendummies} uses the codes found in the data as suffixes for the generated 
variables, thus permitting users to ensure consistent codes across disparate batteries of responses (e.g. behaviours, 
attitudes, etc.) relating to the same items (e.g. political parties). This is in contrast to  {cmd:tab1}, which uses
sequential suffixes starting at the number 1 for the generated variables, no matter how those variables were coded.

{title:Options}

{phang}
{opt pre:fix(name)} if provided, prefix for the generated dummy variables (default is to use the name of the 
variable from which the dummies are being generated).

{phang}
{opt inc:ludemissing} if specified, missing values for {it:varname} will be coded as all zeros.

{title:Examples:}

{pstd}Generate dummies named "religX" for different values (X) found in the data for the variable {it:relig}; 
cases with a missing value on {it:relig} will be set to missing on all generated dummies.{p_end}{break}

{phang2}{cmd:. gendummies relig}{p_end}

{pstd}Generate dummies for different values of {it:VAR282} naming these by appending the values found to the 
stub "churchatt"; cases with a missing value on {it:VAR282} will be set to zero on all generated dummies.{p_end}{break}

{phang2}{cmd:. gendummies VAR282, prefix(churchatt_) includemissing}{p_end}

