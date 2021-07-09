{smcl}
{hline}
help for {cmd:skdecomp}{right:Bernardo Atuesta}
{right:Joao Pedro Azevedo}
{right:Andres Castaneda}
{right:Viviane Sanfelice}
{hline}

{title:Shapley value of growth, price, and distribution components of on changes in poverty indicators}

{p 8 17}
{cmdab:skdecomp}
{it:welfarevar}
[{cmd:weight}]
[{cmd:if} {it:exp}]
[{cmd:in} {it:exp}] ,
{cmd:by}{cmd:(}{it:varname}{cmd:)}
{cmd:varpl}{cmd:(}{it:varname}{cmd:)}
[
{cmd:indicator}{cmd:(}{it:string}{cmd:)}
{cmd:mpl}{cmd:(}{it:numlist}{cmd:)}
{cmd:idpl}{cmd:(}{it:varname}{cmd:)}
]{p_end}

{p 4 4 2}{cmd:fweights} and {cmd:aweights} are allowed; see help weights. See help {help weight}.{p_end}


{title:Description}

{p 4 4 2}{cmd:skdecomp} implements the shapley value of Kolenikov and Shorrocks (2003) decomposition of changes in a welfare 
indicator into growth, distribution and price.{p_end}


{title:Where}

{p 4 4 2}{it:welfarevar} is the welfare aggregate variable.{p_end}

{p 4 4 2}{cmd:by} is the comparison variable. It must take two categorical values and is usually defines as two points 
in time or two geographic locations, which the difference of the indicator is being decomposed.{p_end}

{p 4 4 2}{cmd:{opt varpl(varname)}} poverty line variable.{p_end}


{title:Options}

{p 4 4 2}{cmd:{opt in:dicator(string)}} poverty indicators. fgt0, fgt1, fgt2 are the currently supported options. {it:fgt0} is the indicator default.{p_end}

{p 4 4 2}{cmd:{opt mpl(numlist)}} allow to calculate the poverty indicators by range using multiples of the poverty line.{p_end}

{p 4 4 2}{cmd:{opt idpl(varname)}} to switch the poverty line in case the poverty line is not constant to all the observation in one categorical of {it:by}. For instance, there are different poverty lines to urban and rural areas.{p_end}


{title:Saved Results}

{cmd:skdecomp} returns results in {hi:r()} format. 
By typing {helpb return list}, the following results are reported:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(b)}}average effect by factors and the total change on the poverty indicator.{p_end}
{synopt:{cmd:r(shapley)}}besides the average effect, returns the contribution of each paths. {p_end}
{synopt:{cmd:r(poverty)}} returns the value of the {it:indicator} by categorical value of {it:by}. {p_end}

{pstd}{cmd:Obs:} On the reported matrices {p_end}

{pstd}{it:Indicator label}: 0 - FGT(0); 1 - FGT(1); 2 - FGT(2).{p_end}

{pstd}{it:Effect label}: 1 represents the {it:growth}; 2 {it:distribtuion}; 3 {it:line} and 4 the total change in percentage points on the indicator.{p_end}

{pstd}{it:Line label} (if {it:mpl} specified): 1 represents the first multiple; 2 the second, and so on. The last indicates the range from the last multiple and the maximun value.{p_end}


{title:Examples}

{p 8 12}{inp:. skdecomp income, by(year) varpl(pline)}{p_end}

{p 8 12}{inp:. skdecomp income, by(year) varpl(pline) idpl(region)}{p_end}

{p 8 12}{inp:. skdecomp income, by(year) varpl(pline) in(fgt0 fgt1 fgt2)}{p_end}

{p 8 12}{inp:. skdecomp income, by(year) varpl(pline) mpl(1 2.5 6)}{p_end}



{txt}      ({stata "_ex_skdecomp, example(1)":click to run the example below})
	
	{p 8 12}{Original SK decomposition - welfare and poverty line variable in nominal terms}{p_end}
	
	{cmd:. skdecomp ipcf [w=pondera], by(ano) varpl(lp_4usd)} ///
    {cmd:    . in(fgt0 fgt1 fgt2) }
		


{title:References}

{p 4 4 2}Shorrocks, A.; Kolenikov, S. A Decomposition Analysis of Regional Poverty in Russia, Discussion Paper No. 2003/74 United Nations University, 2003.{p_end}

{p 4 4 2}Shorrocks, A. F. Decomposition procedures for distributional analysis: a unified framework based on the Shapley value. Journal of Economic Inequality, 2012.{p_end}

{p 4 4 2}World Bank (2011) On The Edge Of Uncertainty: Poverty Reduction in Latin America and the Caribbean during the Great Recession and Beyond. {cmd:LAC Poverty and Labor Brief}. World Bank: Washington DC.
{browse "http://siteresources.worldbank.org/INTLAC/Resources/LAC_poverty_report.pdf" : (link to publication)}{p_end}

{title:Authors}

{p 4 4 2}Bernardo Atuesta,{p_end}
{p 4 4 2}Joao Pedro Azevedo, jazevedo@worldbank.org{p_end}
{p 4 4 2}Andres Castanedas, acastanedaa@worldbank.org{p_end}
{p 4 4 2}Viviane Sanfelice,  vsanfelice@worldbank.org{p_end}


{title:Acknowledgements}
    {p 4 4 2}This program was developed by the {browse "http://go.worldbank.org/IYDYF1BG70" : LAC Team for Statistical Development} (2012), in the Latin American and Caribbean Poverty Reduction and Economic Managment Group of the World Bank.
	

{title:Also see}

{p 2 4 2}Online:  help for {help gidecomposition}; {help apoverty}; {help ainequal};  {help wbopendata}; {help adecomp}; {help mpovline}; {help drdecomp} (if installed){p_end} 


