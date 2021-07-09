{smcl}
{hline}
help for {cmd:adecomp}{right:Joao Pedro Azevedo}
{right:Minh Cong Nguyen}
{right:Viviane Sanfelice}
{right:version 1.5}
{hline}

{title:{cmd:adecomp} - Shapley Decomposition by Components of a Welfare Measure}

{p 8 17}
{cmdab:adecomp}
{it:welfarevar}
{it:components}
[{cmd:weight}]
[{cmd:if} {it:exp}]
[{cmd:in} {it:exp}],
{cmd:by}{cmd:(}{it:varname}{cmd:)}
{opt eq:uation}{cmd:(}{it:c#[{it:operator}]c#[{it:operator}]c#[{it:operator}]...[{it:operator}]cN}{cmd:)}
[ {opt in:dicator}{cmd:(}{it:string}{cmd:)}
{cmd:varpl}{cmd:(}{it:varname}{cmd:)}
{cmd:mpl}{cmd:(}{it:numlist}{cmd:)}
{cmd:gic}{cmd:(}{it:#}{cmd:)}
{opt gr:oup}{cmd:(}{it:varname}{cmd:)}
{cmd:id}{cmd:(}{it:varname}{cmd:)}
{opt r:ank}{cmd:(}{it:string}{cmd:)}
{cmd:strata}{cmd:(}{it:varlist}{cmd:)}
{opt perc:entile}{cmd:(}{it:#}{cmd:)}
{opt b:ottom}{cmd:(}{it:#}{cmd:)}
{opt t:op}{cmd:(}{it:#}{cmd:)}
{opt mid:dle}{cmd:(}{it:numlist}{cmd:)}
{opt m:ethod}{cmd:(}{it:string}{cmd:)}
{cmd:oneway}
{cmd:std}
{opt s:tats}{cmd:(}{it:string}{cmd:)}
]{p_end}

{p 4 4 2}{cmd:fweights} and {cmd:aweights} are allowed; see help weights. See help {help weight}.{p_end}


{title:Description}

{p 4 4 2}{cmdab:adecomp} implements the shapley decomposition of changes in a welfare indicator as proposed by 
Azevedo, Sanfelicce and Minh (2012). Following Barros et al (2006), this method takes advantage of the additivity property of a 
welfare aggregate to construct a counterfactual unconditional distribution of the welfare aggregate by changing each 
component at a time to calculate their contribution to the observed changes in poverty and inequality.{p_end} 

{p 4 4 2}Given that the distribution of a observable welfare measure (i.e. income or consumption) for period 0 and period 1 are known, we can construct counterfactual 
distributions for period 1 by substituting the observed level of the indicators {it:c} in period 0, one at a time. For each 
counterfactual distribution, we can compute the poverty or inequality measures, and interpret those counterfactuals as the poverty or inequality 
level that would have prevailed in the absence of a change in that indicator.{p_end} 

{p 4 4 2}As much of the micro-decomposition literature, approaches of this nature traditionally suffer from path-dependence (See Essama-Nssah (2012), Fortin et al (2011) and 
Ferreira (2010) for recent reviews of the literature), in other words, the order in which the cumulative effects are calculated 
matters . One of the major contributions of Azevedo, Sanfelicce and Minh (2012) is the implementation of the best known remedy for path-dependence which is to 
calculate the decomposition across all possible paths and then take the average between them. These averages are also known as 
the Shapley-Shorrocks estimates of each component, implying that we estimate every possible path to decompose these components 
and then take the average of these estimates (See Shapley (1953) and Shorrocks (1999)).{p_end}   

{p 4 4 2}There is one remaining caveat to this approach: the counterfactual income distributions on which these decompositions suffer 
from equilibrium-inconsistency. Since we are modifying only one element at a time, the counterfactuals are not the result of 
an economic equilibrium, but rather a statistical exercise in which we assume that we can in fact modify one factor at a time 
and keep everything else constant.{p_end}

{p 4 4 2}For further examples of implementations of this approach please see Azevedo, Inchausete and Sanfelice (2012).{p_end}

{title:Thanks for citing adecomp as follows}

{p 4 4 2}Azevedo, Joao Pedro, Viviane Sanfelice and Minh Cong Nguyen (2012) Shapley Decomposition by Components of a Welfare Measure. World Bank. (mimeo){p_end}

{title:Where}

{p 4 4 2}{it:welfarevar} is the welfare aggregate variable.{p_end}

{p 4 4 2}{it:components} are the components used to construct the welfare variable, and which will be for the 
decomposition.{p_end}

{p 4 4 2}{cmd:by} is the comparison indicator. It must take two categorical values and is usually defines two points 
in time or two geographic locations, which the difference of the indicator of choice is being decomposed.{p_end}

{p 4 4 2}{cmd:{opt eq:uation()}} captures the relationship between {it:welfarevar} and {it:components}. 
The component variables in {it:varlist} must be denoted by c#, and must be separated by an {help operator:arithmetic operator}.{p_end}

{title:Options}

{p 4 4 2}{cmd:{opt in:dicator(string)}} poverty and inequality indicators. fgt0, fgt1, fgt2, gini, theil, and mean are the currently supported 
options.{p_end}

{p 4 4 2}{cmd:{opt t:op(#)}, {opt b:ottom(#)}} mean at bottom x%, top y% of the {it:welfarevar} distribution, and {opt mr:atio} is the ratio between the mean of bottom x% over the mean of the whole distribution.{p_end}

{p 4 4 2}{cmd:{opt mid:dle(# #)}} mean at middle part of distribution between x% and y%.{p_end}

{p 4 4 2}{cmd:{opt varpl(varname)}} poverty line variable. It must be specified when fgt0, fgt1 and/or fgt2 indicators 
are used.{p_end}

{p 4 4 2}{cmd:{opt mpl(numlist)}} allow to calculate the poverty indicators by multiple of the poverty line. It can be 
specified when  fgt0, fgt1 and/or fgt2 indicators are used.{p_end}

{p 4 4 2}{cmd:{opt gic(#)}} use as indicator the percentual change on the average of {it:welfarevar} in which one 
of its {it:#} percentile, i.e., decomposing the Growth Incidence Curve of {it:welfarevar}. You need to specify a number of bins{p_end}

{p 4 4 2}{cmd:{opt gr:oup(varname)}} the indicators are calculated by each group of {it:groupvar}. Differ from the 
{hi:if} option because do not restrict the database. {it:Groupvar} must be a numeric and discrete variable.{p_end}

{p 4 4 2}{cmd:{opt id(varname)}} to specify the identificator variable in case of balanced panel data. The observed value of the unit of analysis is going to be used when changing the distribution.{p_end}

{p 4 4 2}{cmd:{opt strata(varlist)}} allow the transposition of distributions be made within groups created using the variables listed in {it:varlist}.{p_end}

{p 4 4 2}{cmd:{opt r:ank(string)}} specific the rank of which variable must be used when changing the distribution.
It can be a {it:varname} or typing {it:components} the rank of each {it:component} is going to be used. Default is 
{it:welfarevar} rank.{p_end}

{p 4 4 2}{cmd:{opt perc:entile(#)}} used {it:#} percentile of {it:componentvar} to change the distribution. Default 
is to rescale the dataset in each period.{p_end}

{p 4 4 2}{cmd:{opt m:ethod(string)}} specify the method for Shapley decomposition, the default is "difference". The other option is "growth" and the results are the annualized growth using the exponential growth rate definition such as r = ln(Yt/Y1)/T, and T is the difference between period 0 and period 1.{p_end}

{p 4 4 2}{cmd:{opt oneway}} decomposition is made only one way from period 0 to period 1. Default is both ways.{p_end}

{p 4 4 2}{cmd:{opt std}} returns the standard deviation of the effect, besides the average.{p_end}

{p 4 4 2}{cmd:{opt s:tats}} returns specified poverty and inequality indicators, and statistics of variables in the equation.{p_end}

{title:Saved Results}

{cmd:adecomp} returns results in {hi:r()} format. 
By typing {helpb return list}, the following results are reported:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(path)}}number of paths of the shapley decomposition {p_end}
{synopt:{cmd:r(component)}}number of components of the decomposition {p_end}
{synopt:{cmd:r(N)}}number of observations utilized on the calculation{p_end}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(b)}}average effect of each components based on all paths.{p_end}
{synopt:{cmd:r(sd)}}standard deviation of the effects based on all paths. If option {hi:std} is specify. {p_end}
{synopt:{cmd:r(gic)}}average effect of each components based on all paths when the indicators are the changes on {it:welfarevar()} by bin.{p_end}
{synopt:{cmd:r(sd_gic)}}standard deviation of each components based on all paths when the indicators are the changes on {it:welfarevar()} by bin. If option {hi:std} is specify. {p_end}
{synopt:{cmd:r(stats)}}poverty and inequality indicators. If option {hi:stats} is specify. {p_end}
{synopt:{cmd:r(statsvar)}}summary statistics of factors. If option {hi:stats} is specify. {p_end}

{pstd}{cmd:Obs:} On the reported matrices {p_end}
{pstd}{it:Index label}: 0 - FGT(0); 1 - FGT(1); 2 - FGT(2); 3 - Gini; 4 - Theil; 5 - Mean; 6 - Bottom(); 7 - Top(); 8 - Bottom()/Mean; 9 - Middle(# #).{p_end}
{pstd}{it:Effect label}: 1 represents the first {it:component} listed on the command, and so on. Total of components plus 1 represents the total change on the indicator and plus 2 denotes the residual, when this option is specified.{p_end}

{pstd}{cmd:Important}: To guarantee precision, we recommend to use {it:double} when create variables.{p_end}


{title:Examples}

{p 8 12}{inp:. adecomp percapitainc laborinc nonlaborinc, by(year) equation(c1+c2) indicator(fgt0 fgt1 fgt2 gini theil) varpl(pline)}{p_end}

{p 8 12}{inp:. adecomp percapitainc laborinc nonlaborinc, by(year) equation(c1+c2) in(fgt0) varpl(pline) gic(100)}{p_end}

{p 8 12}{inp:. adecomp percapitainc laborinc nonlaborinc, by(year) equation(c1+c2) indicator(fgt0) varpl(pline) mpl(1 3.5)}{p_end}

{p 8 12}{inp:. adecomp percapitainc laborinc nonlaborinc, by(year) equation(c1+c2) indicator(fgt0 fgt1 fgt2 gini theil) varpl(pline) gic(100) strata(urban)}{p_end}

{p 8 12}{inp:. adecomp percapitainc laborinc nonlaborinc, by(year) equation(c1+c2) indicator(fgt0 fgt1 fgt2 gini theil) varpl(pline) gic(100) id(hh_id)}{p_end}

{p 8 12}{inp:. adecomp percapitainc laborinc nonlaborinc [w=weight], by(year) equation(c1+c2) indicator(fgt0 fgt1 fgt2) varpl(pline) group(region)}{p_end}

{p 8 12}{inp:. adecomp percapitainc laborinc nonlaborinc if (region == 1), by(year) equation(c1+c2) indicator(gini)}{p_end}

{p 8 12}{inp:. adecomp percapitainc padults laborinc capitalinc pensioninc transferinc othersinc, by(year) equation(c1*(c2+c3+c4+c5+c6)) indicator(fgt0) varpl(pline)} {p_end}

{p 8 12}{inp:. adecomp percapitainc padults laborinc capitalinc pensioninc transferinc othersinc, by(year) equation(c1*(c2+c3+c4+c5+c6)) indicator(fgt0 fgt1 fgt2 gini theil mean) varpl(pline) bottom(40) method(growth)}{p_end}


{txt}      ({stata "_ex_adecomp, example(1)":click to run the example below})

	. use exdata_adecomp.dta, clear
	
	{cmd:. adecomp ipcf_ppp ila_ppp itran_ppp ijubi_ppp icap_ppp others} ///
	{cmd:  [w=pondera], by(ano) eq(c1+c2+c3+c4+c5) } ///
	{cmd:  varpl(lp_2usd_ppp) in(fgt0 fgt1 fgt2 gini theil) }
	
	. mat result = r(b)
	. mat colnames  result = indicator effect rate
	. drop _all
	. svmat double result, n(col)
	. label define indicator 0 "FGT0" 1 "FGT1" 2 "FGT2" 3 "Gini" 4 "Theil"
	. label values indicator indicator
	. label define effect ///
		1 "Labor" ///
		2 "Transfer" ///
		3 "Pension" ///
		4 "Capital" ///
		5 "Others" ///
		6 "Total change"
	. label values effect effect
	. local total 6
	. gen aux=rate if  effect==`total'  
	. egen total_effect=sum(aux) , by(indicator)
	. drop aux
	. gen share_effect= -100*rate/abs(total_effect)

	. keep if effect!=6
	. graph bar share_effect , over(effect, label(labsize(*0.6))) ///
            by(indicator)   blabel(bar, format(%16.1fc) size(*.98)) ///
            ytitle(Share of the component effect in the total change)

{title:References}

{p 4 4 2}Azevedo, Joao Pedro, Viviane Sanfelice and Minh Cong Nguyen (2012) Shapley Decomposition by Components of 
	a Welfare Measure. MPRA Paper 85584, University Library of Munich, Germany.
	{browse "https://ideas.repec.org/p/pra/mprapa/85584.html":(link to publication)}{p_end}
	
{p 4 4 2}Azevedo, Joao Pedro, Gabriela Inchauste, and Viviane Sanfelice (2013) "Decomposing the recent inequality decline 
	in Latin America," Policy Research Working Paper Series 6715, The World Bank.
	{browse "https://ideas.repec.org/p/wbk/wbrwps/6715.html":(link to publication)}{p_end}

{p 4 4 2}Azevedo, Joao Pedro, Gabriela Inchauste, Sergio Olivieri, Jaime Saavedra, and Hernan Winkler. (2013) "Is labor 
	income responsible for poverty reduction ? a decomposition approach," Policy Research Working Paper Series 6414, 
	The World Bank. {browse "https://ideas.repec.org/p/wbk/wbrwps/6414.html":(link to publication)}{p_end}

{p 4 4 2}Barros, Ricardo Paes de. Carvalho, Mirela de. Franco, Samuel. Mendoça, Rosane (2006). "Uma Análise das 
	Principais Causas da Queda Recente na Desigualdade de Renda Brasileira." In: Revista Econômica. Volume 8, número 	
	1, p.117-147. Universidade Federal Fluminense. Rio de Janeiro. 
	{browse "https://doi.org/10.22409/economica.8i1.p158" : (link to publication)}{p_end}

{p 4 4 2}Essama-Nssah, B. (2012). "Identification of Sources of Variation in Poverty Outcomes", World Bank Policy Research 
	Working Papers, No. 5954.{p_end}

{p 4 4 2}Ferreira Francisco H.G. (2010) "Distributions in Motion: Economic Growth, Inequality and Poverty Dynamics".  
	World Bank Policy Research Working Paper No. 5424.  The World Bank, Washington, D.C.{p_end}

{p 4 4 2}Fortin Nicole, Lemieux Thomas and Firpo Sergio. (2011). "Decomposition Methods in Economics".  In: Ashenfelter 
	Orley and Card David (eds) Handbook of Labor Economics, Vol. 4A , pp. 1-102. Northolland, Amsterdam..{p_end}

{p 4 4 2}Inchauste, Gabriela , João Pedro Azevedo, Sergio Olivieri, Jaime Saavedra, and Hernan Winkler (2012) When Job 
	Earnings Are behind Poverty Reduction. Economic Premise, November 2012, Number 97. World Bank: Washington DC. 
{browse "http://siteresources.worldbank.org/EXTPREMNET/Resources/EP97.pdf" : (link to publication)}{p_end}

{p 4 4 2}Shapley, L. (1953). "A value for n-person games", in: H. W. Kuhn and A. W. Tucker (eds.), Contributions to the 
	Theory of Games, Vol. 2 (Princeton, N.J.: Princeton University Press).{p_end}

{p 4 4 2}Shorrocks, Anthony (2012) Decomposition procedures for distributional analysis: a unified framework based on 
	the Shapley value. Journal of Economic Inequality {browse "http://dx.doi.org/10.1007/s10888-011-9214-z" : (link to publication)}{p_end}

{p 4 4 2}World Bank (2012) The Effect Of Women'S Economic Power: in Latin America and the Caribbean. {cmd:LAC Poverty and Labor Brief}. World Bank: Washington DC.
{browse "http://www.bancomundial.org/content/dam/Worldbank/document/PLBSummer12latest.pdf" : (link to publication)}{p_end}

{title:Authors}

	{p 4 4 2}Joao Pedro Azevedo, jazevedo@worldbank.org{p_end}
	{p 4 4 2}Minh Cong Nguyen, mnguyen3@worldbank.org{p_end}
	{p 4 4 2}Viviane Sanfelice,  vsanfelice@worldbank.org{p_end}
		
{title:Acknowledgements}
    {p 4 4 2}The authors would like to thank Gabriela Inchauste, Samuel Freije, Andres Castaneda and 
    Gabriel Facchini for their valuable suggestions. The code from Samuel Franco and Sergio Oliveri were used 
    for inspiration in a few passages of this ado and should be greatfully acknowledged.{p_end} 
    {p 4 4 2}All errors and ommissions are of exclusive responsability of the authors.{p_end}
	
	{p 4 4 2}This program was developed by the {browse "http://go.worldbank.org/IYDYF1BG70" : LAC Team for Statistical Development} (2012), in the 
    Latin American and Caribbean Poverty Reduction and Economic Managment Group of the World Bank.{p_end} 
	

{title:GitHub Respository}

{p 4 4 2}For previous releases please visit ADECOMP {browse "https://github.com/jpazvd/adecomp" :GitHub Repo}{p_end}


{title:Also see}

{p 2 4 2}Online:  help for {help apoverty}; {help ainequal};  {help wbopendata}; {help mpovline}; {help drdecomp}; {help skdecomp}; {help tabmult}; {help xtsur} (if installed){p_end} 

