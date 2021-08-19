{smcl}
{right:version 0.0.1, 17 Nov 2020}
{title:Instrumental variables regression with Conley, HAC-robust standard errors}

{phang}
{bf:spatial_hac_iv }{hline 2} Runs an instrumental variable regression, adjusting standard errors for spatial correlation, heteroskedasticity, and autocorrelation


{title:Author}

{p 4 4 2}
Tim Foreman{break}
RFF-CMCC European Institute on Economics and the Environment{break}
timothy.foreman@eiee.org{break}

{title:Syntax}

{p 8 16 2}
{opt spatial_hac_iv} {depvar} indepvar (endog=inst){cmd:,} lon({it:varname}) lat({it:varname}) timevar({it:varname}) panelvar({it:varname}) distcutoff({it:#}) lagcutoff({it:#}) [bartlett dropvar]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt lat}} Latitude variable (degrees){p_end}
{synopt :{opt lon}} Longitude variable (degrees){p_end}
{synopt :{opt timevar}} Time variable{p_end}
{synopt :{opt panelvar}} Panel variable{p_end}
{synopt :{opt distcutoff}} Distance cutoff for spatial correlation within a time unit (kilometers){p_end}
{synopt :{opt lagcutoff}} Time cutoff for autocorrelation within a panel unit{p_end}
{synopt :{opt bartlett}} Use a linear bartlett window for spatial correlations, instead of a uniform kernel{p_end}
{synopt :{opt dropvar}} Drops variables that Stata would drop due to collinearity{p_end}
{synoptline}


{title:Example}

    Regress y on endogenous variable x with instrument z
        . spatial_hac_iv y (x=z), lat(lat) lon(lon) timevar(year) panelvar(countrynum) lagcutoff(5) distcutoff(100) dropvar

{title:Acknowledgements}

{p}The basis for this package was written by Solomon Hsiang and Kyle Meng. It relies on ivreg2, written by Christopher F Baum, Mark E Schaffer, and Steven Stillman
{browse "http://ideas.repec.org/c/boc/bocode/s425401.html":http://ideas.repec.org/c/boc/bocode/s425401.html}{p_end}
