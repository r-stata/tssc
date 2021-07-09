{smcl}
{hline}
help for {cmd:drdecomp}{right:Joao Pedro Azevedo}
{right:Andrés Castaneda}
{right:Viviane Sanfelice}
{hline}

{title:Shapley value of growth and distribution components of on changes in poverty indicators}

{p 8 17}
{cmdab:drdecomp}
{it:welfarevar}
[{cmd:weight}]
[{cmd:if} {it:exp}]
[{cmd:in} {it:exp}],
{cmd:by}{cmd:(}{it:varname}{cmd:)}
{cmd:varpl}{cmd:(}{it:varlist}{cmd:)}
[
{cmd:indicator}{cmd:(}{it:string}{cmd:)}
{cmd:mpl}{cmd:(}{it:numlist}{cmd:)}
]{p_end}

{p 4 4 2}{cmd:fweights} and {cmd:aweights} are allowed; see help weights. See help {help weight}.{p_end}


{title:Description}

{p 4 4 2}{cmd:drdecomp} implements the shapley value of the Datt and Ravallion (1992) decomposition of changes in a welfare indicator into growth and distribution,
 however, following the shapley and non parametric methodology suggested by Shorrocks (1999/2012) and Kolenikov and Shorrocks (2003).{p_end}

{p 4 4 2}For examples of applications please see Azevedo and Sanfelice (2012) and Ferreira et al (2012).{p_end} 

{title:Where}

{p 4 4 2}{it:welfarevar} is the welfare aggregate variable.{p_end}

{p 4 4 2}{cmd:by} is the comparison indicator. It must take two categorical values and is usually defines two points 
in time or two geographic locations, which the difference of the indicator of choice is being decomposed.{p_end}

{p 4 4 2}{cmd:{opt varpl(varname)}} poverty line variable.{p_end}

{title:Options}

{p 4 4 2}{cmd:{opt in:dicator(string)}} poverty indicators. fgt0, fgt1, fgt2 are the currently supported options. {it:fgt0} is the indicator default.{p_end}

{p 4 4 2}{cmd:{opt mpl(numlist)}} allow to calculate the poverty indicators by range using multiples of the poverty line.{p_end}

{title:Saved Results}

{cmd:drdecomp} returns results in {hi:r()} format. 
By typing {helpb return list}, the following results are reported:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(b)}}average effect of the two factors and the total change on the poverty indicator.{p_end}
{synopt:{cmd:r(shapley)}}besides the average effect, returns the contribution for the two paths. {p_end}
{synopt:{cmd:r(poverty)}} returns the value of the {it:indicator} by categorical value of {it:by}. {p_end}

{pstd}{cmd:Obs:} On the reported matrices {p_end}
{pstd}{it:Indicator label}: 0 - FGT(0); 1 - FGT(1); 2 - FGT(2).{p_end}
{pstd}{it:Effect label}: 1 represents the {it:growth}; 2 {it:redistribtuion} and 3 the total change on the indicator.{p_end}
{pstd}{it:Line label} (if {it:mpl} specified): 1 represents the first multiple; 2 the second, and so on. The last indicates the range from the last multiple and the maximun value.{p_end}


{title:Examples}

{p 8 12}{inp:. drdecomp percapitainc, by(year) varpl(pline)}{p_end}

{p 8 12}{inp:. drdecomp percapitainc, by(year) varpl(pline) in(fgt0 fgt1 fgt2)}{p_end}

{p 8 12}{inp:. drdecomp percapitainc, by(year) varpl(pline) mpl(1 3.5 6)}{p_end}


{txt}      ({stata "_ex_drdecomp, example(1)":click to run the example below})

	. use exdata_drdecomp, clear
	
	{cmd:. drdecomp income [w=weight], by(year) varpl(lp_4usd_ppp)} ///
    {cmd:    . in(fgt0 fgt1 fgt2) }
	

{title:References}

{p 4 4 2} Azevedo, Joao Pedro and Viviane Sanfelice (2012) "The rise of the middle class in Latin America". World Bank (mimeo). {p_end}

{p 4 4 2}Ferreira, Francisco H.G.; Messina, Julian; Rigolini, Jamele; López-Calva, Luis-Felipe; Lugo, Maria Ana; Vakis, Renos. (2013) Economic Mobility and the Rise of the Latin American Middle Class. Washington, DC: World Bank. 
{browse "https://openknowledge.worldbank.org/handle/10986/11858" : (link to publication)}{p_end}

{p 4 4 2}Datt, G.; Ravallion, M. (1992) Growth and Redistribution Components of Changes in Poverty Measures: A Decomposition with Applications to Brazil and India in the 1980s. Journal of Development Economics, 38: 275-296.{p_end}

{p 4 4 2}Shorrocks, A. F. (2012) Decomposition procedures for distributional analysis: a unified framework based on the Shapley value. Journal of Economic Inequality.{p_end}

{p 4 4 2}Shorrocks, A.; Kolenikov, S. (2003) A Decomposition Analysis of Regional Poverty in Russia, Discussion Paper No. 2003/74 United Nations University.{p_end}

{p 4 4 2}World Bank (2011) On The Edge Of Uncertainty: Poverty Reduction in Latin America and the Caribbean during the Great Recession and Beyond. {cmd:LAC Poverty and Labor Brief}. World Bank: Washington DC.
{browse "http://siteresources.worldbank.org/INTLAC/Resources/LAC_poverty_report.pdf" : (link to publication)}{p_end}

{title:Authors}

{p 4 4 2}Joao Pedro Azevedo, jazevedo@worldbank.org{p_end}
{p 4 4 2}Andres Castanedas, acastanedaa@worldbank.org{p_end}
{p 4 4 2}Viviane Sanfelice,  vsanfelice@worldbank.org{p_end}
	

{title:Acknowledgements}
    {p 4 4 2}This program was developed by the {browse "http://go.worldbank.org/IYDYF1BG70" : LAC Team for Statistical Development} (2012), in the Latin American and Caribbean Poverty Reduction and Economic Managment Group of the World Bank.


{title:Also see}

{p 2 4 2}Online:  help for {help gidecomposition}; {help apoverty}; {help ainequal};  {help wbopendata}; {help adecomp}; {help mpovline}; {help skdecomp} (if installed){p_end} 



