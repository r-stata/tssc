{smcl}
{hline}
help for {cmd:mpovline}{right:Joao Pedro Azevedo}
{right:Viviane Sanfelice}
{hline}

{title:Calculate FGT0, FGT1 and FGT2 by intervals of multiple welfare lines.}

{p 8 17}
{cmdab:mpovline}
{it:welfarevar}
[{cmd:weight}]
[{cmd:if} {it:exp}]
[{cmd:in} {it:exp}],
[
{cmd:varpl}{cmd:(}{it:varname}{cmd:)}
{cmd:lines}{cmd:(}{it:numlist}{cmd:)}
{cmd:indicator}{cmd:(}{it:string}{cmd:)}
{cmd:mpl}{cmd:(}{it:numlist}{cmd:)}
{cmd:max}
]{p_end}

{p 4 4 2}{cmd:fweights} and {cmd:aweights} are allowed; see help weights. See help {help weight}.{p_end}


{title:Description}

{p 4 4 2}{cmdab:mpovline} calculate FGT0, FGT1 and FGT2 by intervals of multiple welfare lines. It is useful to calculate 
headcount for the poor, vulnerable and middle class lines as proposed by Ferreira et al (2012), and the respective 
FGT1 and FGT2 reported by Azevedo and Sanfelice (2012).{p_end} 


{title:Where}

{p 4 4 2}{cmd:welfarevar} is the welfare aggregate variable.{p_end}


{title:Options}

{p 4 4 2}{cmd:{opt varpl(varname)}} poverty line variables.{p_end}

{p 4 4 2}{cmd:{opt line:s(numlist)}} sets of values for the poverty lines.{p_end}

{p 4 4 2}{cmd:{opt in:dicator(string)}} poverty indicators. fgt0, fgt1, fgt2 are the currently supported options. {it:fgt0} is the indicator default.{p_end}

{p 4 4 2}{cmd:{opt mpl(numlist)}} to calculate the poverty indicators by range using multiples of the poverty line. Must be combined with the {cmd:varpl} option{p_end}

{p 4 4 2}{cmd:{opt max}} poverty indicators for the range between the last line and the maximun value of {it: welfarevar}It is quite sensitive to outliers. {p_end}


{title:Saved Results}

{cmd:mpovline} returns results in {hi:r()} format. 
By typing {helpb return list}, the following results are reported:

{synoptset 20 tabbed}{...}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(b)}} matrix in long format. The first column represents the index used, the sencond the range of the poverty line used and the last column reports the poverty numbers.{p_end}
{synopt:{cmd:r(fgt)}} short version of the matrix {it:r(b)} with results by indicator. {it:r(fgt0)}, {it:r(fgt1)} and {it:r(fgt2)} if {cmd:indicator} option specified. {p_end}
{synopt:{cmd:r(obs)}} matrix with the number of observation by range of the lines. {p_end}

{pstd}{cmd:Obs:} On the reported matrices {p_end}
{pstd}{it:Indicator label}: 0 - FGT(0); 1 - FGT(1); 2 - FGT(2).{p_end}
{pstd}{it:Line label}: 1 represents the first range; 2 the second, and so on. The last number indicates the range from the last line and the maximun value if the option {cmd:max} is specified.{p_end}


{title:Examples}

{p 8 12}{inp:. mpovline percapitainc, varpl(pline1 plin2)}{p_end}

{p 8 12}{inp:. mpovline percapitainc [w=weight], line(100 500) in(fgt0 fgt1 fgt2)}{p_end}

{p 8 12}{inp:. mpovline percapitainc [w=weight], varpl(pline) mpl(1 3.5 6)}{p_end}


{p 4 4 2}Headcount for moderate poverty, vunerable and middle class in terms of $4USD a day, $4 to 10USD a day and $10 to 50USD a day, respectively. {p_end}

{p 8 12}{inp:. mpovline percapitainc [w=weight], varpl(lp_4usd_ppp) mpl(1 2.5 12.5)}{p_end}
{p 4 4 2}or{p_end}
{p 8 12}{inp:. mpovline percapitainc [w=weight], line(121.68 304.2 1521)}{p_end}
{p 4 4 2}or{p_end}
{p 8 12}{inp:. mpovline percapitainc [w=weight], varpl(lp_4usd_ppp lp_10usd_ppp lp_50usd_ppp)}{p_end}	

{title:References}

{p 4 4 2}Azevedo, Joao Pedro and Viviane Sanfelice (2012) "The rise of the middle class in Latin America". World Bank (mimeo).{p_end}

{p 4 4 2}Ferreira, Francisco H.G.; Messina, Julian; Rigolini, Jamele; López-Calva, Luis-Felipe; Lugo, Maria Ana; Vakis, Renos. (2013) Economic Mobility and the Rise of the Latin American Middle Class. Washington, DC: World Bank. 
{browse "https://openknowledge.worldbank.org/handle/10986/11858" : (link to publication)}{p_end}

{p 4 4 2}Foster, James; Joel Greer and Erik Thorbecke (1984) "A class of decomposablepoverty measures". Econometrica. 2 81: 761–766. {p_end}

{p 4 4 2}Lopez-Calva, Luis F. and Eduardo Ortiz-Juarez (2011) "A Vulnerability Approach to the Definition of the Middle Class". Policy Research Working Paper, World Bank, n. 5902.{p_end}


{title:Authors}

{p 4 4 2}Joao Pedro Azevedo, jazevedo@worldbank.org {p_end}
{p 4 4 2}Viviane Sanfelice,  vsanfelice@worldbank.org {p_end}

	
{title:Acknowledgements}
    {p 4 4 2}This program was developed by the {browse "http://go.worldbank.org/IYDYF1BG70" : LAC Team for Statistical Development} (2012), in the Latin American and Caribbean Poverty Reduction and Economic Managment Group of the World Bank. 
	

{title:Also see}

{p 2 4 2}Online:  help for {help apoverty}; {help ainequal};  {help wbopendata}; {help adecomp}; {help drdecomp}; {help skdecomp} (if installed){p_end} 


