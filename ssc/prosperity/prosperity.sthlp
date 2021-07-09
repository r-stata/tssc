{smcl}
{* *! version 5.1 10OCT2014}{...}

{hline}
help for {hi:prosperity}{right:Oscar Barriga Cabanillas}
{hline}

{title:Title}

{phang}
{bf:prosperity} {hline 2} Calculates the Shared Prosperity Convergence Index -SPCI- 

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:prosperity:}
[Income aggregate]
{if}
{weight}
[{cmd:,} {it:options}]

{marker options}{...}
{title:Options}

{synoptset 20 tabbed}{...}

{dlgtab:Main            }

{synopt:{opt PER:iod}}identifies the years for which SPCI index is calculated -when more than two years are available use if option-. {p_end}

{synopt:{opt BOTT:om}}The default is the bottom 40 of the distribution in the initial year; use to define a different cut-off percentile. {p_end}

{synopt:{opt DIS:aggregate}}Calculates SPCI for different levels of disaggregation e.g: Regions, ethnicity. {p_end}

{synopt:{opt over}}When more than 2 years are loaded in the computer's memory, it identifies the two year to be usedCalculates SPCI for different levels of disaggregation e.g: Regions, ethnicity. {p_end}

{synopt:{opt SHOWWHO}}Keeps the percentiles generated during the calculations under pctile_ variable.{p_end}

{dlgtab:Poverty options }

{synopt:{opt varpl}}Allows to calculate the annualized income growth for the poor population accordingly to a user's provided variable containing the values of the poverty line.{p_end}
{synopt:}Please be sure of using values that match the level of variable income in terms of reference year and level of aggregation e.g: per capita terms.{p_end}

{synopt:{opt line}}Same as varpl option, but allows the user to set the value of the poverty line. Same remarks apply.{p_end}
	
{dlgtab:Export Results  }

{synopt:{opt EXP:ort}}Allows the user to define a root to export the results. The default is a matrix called GB.{p_end}

{synopt:{opt FIL:ename}}Define a name for the file generated. If not defined the default name is Shared_prosperity. To be used with export option.{p_end}

{synopt:{opt FOR:mat}}Export in .xls format. xls and excel are accepted. The defaults is a dta file.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{cmd:by} is not allowed.{p_end}
{p 4 6 2}
{cmd:fweight}s are allowed; see {help weight}.


{marker description}{...}
{title:Description}

{pstd}
{cmd:prosperity} Calculates the SPCI to tracks progress in equity adjusted growth.{p_end}
{pstd}
		The index is calculated as the annualized growth rate of the income of the bottom 40 percent of the population and comparing it with the total aggregate growth. The World Bank established the indicator as part of its to twin goal agenda that emphasizes the importance of sustained growth in increasing the living standards of the poor while highlighting the importance of achieving greater levels of equality.{p_end}
		

{marker remarks}{...}
{title:Remarks}

{pstd}
Please be sure of using income variables in real terms.{p_end}

{pstd}
For detailed information on the Shared Prosperity Convergence Index , see {bf: http://www.worldbank.org/content/dam/Worldbank/document/WB-goals2013.pdf}.{p_end}

{marker examples}{...}
{title:Examples}

{phang}{cmd:. prosperity ipcf_ppp [w=weight], period(year)}{p_end}

{phang}{cmd:. prosperity ipcf_ppp [w=weight], period(year) bottom(10)}{p_end}

{phang}{cmd:. prosperity ipcf_ppp [w=weight], period(year) bottom(10) dis(region)}{p_end}

{phang}{cmd:. prosperity ipcf_ppp [w=weight], period(year) bottom(10) export(C:\Users) filename(Country) format(xls)}{p_end}

{phang}{cmd:. prosperity ipcf_ppp [w=weight], period(year) varpl(lp_4usd_ppp) dis(region) } {p_end}


{title:Author}

{p 5}Oscar Barriga-Cabanillas{p_end}
{p 5}obarriga@ucdavis.edu{p_end}

{title:Special thanks to}

{p 5}Mateo Salazar{p_end}
{p 5}The World Bank{p_end}

