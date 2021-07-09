{smcl}
{hline}
help for {cmd:alorenz}{right:Joao Pedro Azevedo}
{right:Samuel Franco}
{hline}

{title:Derivation of the Pen's Parade, Lorenz and Generalised Lorenz curve from the empirical distribution}

{p 8 17}
{cmdab:alorenz}
{it:depvar}
[{cmd:if} {it:exp}]
[{cmd:in} {it:range}]
[{cmd:weight}]
[ ,
{cmd:points}{cmd:(}{it:number}{cmd:)}
{cmd:by}{cmd:(}{it:varname}{cmd:)}
{cmd:order}{cmd:(}{it:varname}{cmd:)}
{cmd:gl}
{cmd:gp}
{cmd:ge}
{cmd:gom}
{cmd:goa}
{cmd:angle45}
{cmd:format}{cmd:(}{it:string}{cmd:)}
{cmd:output}{cmd:(}{it:string}{cmd:)}
{cmd:view}
{cmd:fullview}
{cmd:compare}
{cmd:base}{cmd:(}{it:refcat}{cmd:)}
{cmd:grname}{cmd:(}{it:string}{cmd:)}
{cmd:results}{cmd:(}{it:string}{cmd:)}
{cmd:select}{cmd:(}{it:string}{cmd:)}
{cmd:mlabangle}{cmd:(}{it:string}{cmd:)}
{cmd:mlabsize}{cmd:(}{it:string}{cmd:)}
{cmd:mark}{cmd:(}{it:value 1} ... {it:value n}{cmd:)}
{cmd:marklabel}{cmd:(}{it:valuelabel 1}...{it:valuelabel n}{cmd:)}
{cmd:markvar}{cmd:(}{it:varname (categorical)}{cmd:)}
{cmd:invert}
{cmd:xdecrease}
{cmd:ksmirnov}
{cmd:exact}
{cmd:noisily}
{cmd:{it:{help twoway_options}}}
]{p_end}

{p 4 4 2}{cmd:pweights}, {cmd:fweights} and {cmd:aweights} are allowed; see help weights. See help {help weight}.{p_end}

{title:Description}

{p 4 4 2}{cmd:alorenz} derive and plot the Pen's Parade, Lorenz and Generalized Lorenz curve from the empirical distribution. In addition, {cmd:alorenz} allow user 
to retrive the data used to generate the curves, and implement first order stochastic dominance (Saposnik, 1981, 1983), second order 
stochastic dominance (Shorrocks, 1983), and the Lorenz dominance analysis of the distribution (Atkinson, 1970). Moreover, following 
Pigou-Dalton principles, demonstrated by Marshall & Olkin (1979), {cmd:alorenz} also ranks two or more social states by analysing 
the Lorenz, Generalized Lorenz, and Pen's Parade. {cmd:alorenz} also performs the two-sample Kolmogorov-Smirnov tests of the equality 
of distributions.{p_end}

{title:Options}

{p 4 4 2}{cmd:points}{cmd:(}#{cmd:)} sets the number of the distribution points. If the selected number of points is larger than the 
number of observations, alorenz will automatically adjust its value, and display a warning message. Default value 10.

{p 4 4 2}{cmd:by}{cmd:(}groupvar{cmd:)} repeats the command for each group of observations for which the values of the variables
 in varlist are the same. Groupvar must be an integer variable.{p_end}

{p 4 4 2}{cmd:order}{cmd:(}varname{cmd:)} Selects an alternative variable the build the cumulative distribution. The default is 
the population.{p_end}

{p 4 4 2}{cmd:gl} plot the Lorenz curve (cumulated share of var by cumulated share of the population).{p_end}

{p 4 4 2}{cmd:gp} plot the Pen's Parade curve (max value of each percentile).{p_end}

{p 4 4 2}{cmd:ge} plot the Generalized Lorenz curve (cumulated mean of var by cumulated share of the population).{p_end}

{p 4 4 2}{cmd:gom} plot the mean of variable {it:depvar} against the mean of variable {it:order} as ordered by percentiles of the population by variable {it:order}.{p_end}

{p 4 4 2}{cmd:goa} plot the cumulated mean of variable {it:depvar} against the cumulated mean of variable {it:order} as ordered by percentiles of the population by variable {it:order}.{p_end}

{p 4 4 2}{cmd:angle45} specifies that a 45 degree angel line is to the ploted at the Lorenz Curve.{p_end}

{p 4 4 2}{cmd:format} specify the display format for variables. Default format %12.2f.{p_end}

{p 4 4 2}{cmd:output} desired name of the data file writes in comma-separated format.{p_end}

{p 4 4 2}{cmd:view} specifies that the tabels are to be viewed on the Stata display window.{p_end}

{p 4 4 2}{cmd:fullview} specifies that all the possible variables are to be displayed at the Stata window.{p_end}

{p 4 4 2}{cmd:grname}{cmd:(}string{cmd:)} specifies an alternative name of the figures.{p_end}

{p 4 4 2}{cmd:select}{cmd:(}string{cmd:)} select particular observations to be marked on the plot.{p_end}

{p 4 4 2}{cmd:invert} invert the axis of the gl, gp, ge, gom or goa plots.{p_end}

{p 4 4 2}{cmd:xdecrease} invert the order the the x-axis, from increasing to decreasing.{p_end}

{p 4 4 2}{cmd:base}{cmd:(}{it:refcat}{cmd:)} sets the value of the comparation categoric group that defided
the base group. If the base category was not defined {cmdab:alorenz} will use the first category.{p_end}

{p 4 4 2}{cmd:mark}{cmd:(}{it:value 1} ... {it:value n}{cmd:)} select particular values to be marked on the plot.{p_end}

{p 4 4 2}{cmd:marklabel}{cmd:(}{it:valuelabel 1}...{it:valuelabel n}{cmd:)} set the label for the selected values to be marked on the plot.{p_end}

{p 4 4 2}{cmd:markvar}{cmd:(}{it:varname (categorical)}{cmd:)} select the values of a particular categorical variable to be marked on the graph.{p_end}

{p 4 4 2}{cmd:ksmirnov} performs two-sample Kolmogorov-Smirnov tests of the equality of distributions. For more information please see {help ksmirnov}.{p_end}

{p 4 4 2}{cmd:exact} specifies that the exact p-value be computed.  This may take a long time if n > 50. For more information please see {help ksmirnov}.{p_end}

{p 4 4 2}{cmd:noisily} displays on the Stata screen the results of the Kolmogorov-Smirnov tests.{p_end}

{p 4 4 2}{cmd:compare} Analysis the first order stochastic dominance (Saposnik, 1981, 1983), second order stochastic dominance (Shorrocks, 1983), and the Lorenz dominance
of the distribution (Atkinson, 1970).{p_end}

{p 4 4 2}{it:{help twoway_options}} accept any options other than {opt name()} or {opt by()} documented in {bind:{bf:[G] {it:twoway_options}}}{p_end}

{title:Saved Results}

{p 4 4 2}{cmd:max_:} Pen's Parade.{p_end}
{p 4 4 2}{cmd:ac_prop_:} Loren's Curve.{p_end}
{p 4 4 2}{cmd:ac_mean_:} Generalized Loren's Curve.{p_end}
{p 4 4 2}{cmd:speso:} Population.{p_end}
{p 4 4 2}{cmd:ac_speso:} Cumulative Population.{p_end}
{p 4 4 2}{cmd:prop_pop:} Distribution of population.{p_end}
{p 4 4 2}{cmd:ac_prop_pop:} Cumulative distribution of population.{p_end}
{p 4 4 2}{cmd:prop_:} percentage of {it:depvar} by percentile.{p_end}

{title:Stocastic Dominance analysis (Marshall & Olkin, 1979)}

{p 4 4 2}{cmd:I :}  Lack of envy.{p_end}
{p 4 4 2}{cmd:IE:}  Lack of envy and preference for equity.{p_end}
{p 4 4 2}{cmd:CE:}  Preference for growth with equity.{p_end}

{title:Examples}

{p 8 12}{inp:. alorenz y}{p_end}

{p 8 12}{inp:. alorenz y [pw=weight]}{p_end}

{p 8 12}{inp:. alorenz y [pw=weight], points(10)}{p_end}

{p 8 12}{inp:. alorenz y [pw=weight], points(10) format(%12.0f) view}{p_end}

{p 8 12}{inp:. alorenz y [pw=weight], points(10) output(tab) fullview}{p_end}

{p 8 12}{inp:. alorenz y [pw=weight], points(10) format(%12.0f) fullview output(tab)}{p_end}

{p 8 12}{inp:. alorenz y [pw=weight], points(100) view gl}{p_end}

{p 8 12}{inp:. alorenz y [pw=weight], points(100) view gl ge}{p_end}

{p 8 12}{inp:. alorenz y [pw=weight], points(100) view gl ge gp}{p_end}

{p 8 12}{inp:. alorenz y [pw=weight], points(100) view gl ge gp angle45 format(%12.0f) output(tab)}{p_end}

{p 8 12}{inp:. alorenz y [pw=weight], points(100) view gl ge gp angle45 format(%12.0f) output(tab) by(pais)}{p_end}

{p 8 12}{inp:. alorenz y [pw=weight], points(10) compare base(1)}{p_end}

{p 8 12}{inp:. alorenz y [pw=weight], points(10) compare base(4)}{p_end}

{p 8 12}{inp:. alorenz y [pw=weight], points(100) gp select(country == India | country == Brazil | country == Peru | country == Mexico)}{p_end}

{p 8 12}{inp:. alorenz y [pw=weight], points(100) gp order(x) select(country == India | country == Brazil | country == Peru | country == Mexico)}{p_end}

{title:References}

{p 4 4 2}Atkinson, A.B., 1970, "On the Measurement of Inequality", Journal of Economic Theory, 2: 244-63.{p_end}

{p 4 4 2}Dalton, H., 1920, "The Measurement of the Inequality of Incomes", Economic Journal, 30: 348-61.{p_end}

{p 4 4 2}Marshall, A.W. and I.Olkin, 1979, Inequalities: Theory of Majorization and Its Applications. In: Mathematics 
in Science and Engineering, V. 143. Academic Press.{p_end}

{p 4 4 2}Pigou, A.F., 1912, Wealth and Welfare, Macmillan, London.{p_end}

{p 4 4 2}Saposnik, R., 1981, "Rank-Dominance in Income Distribution" Public Choice, 36 pp147-151.{p_end}

{p 4 4 2}Saposnik, R., 1983, "On Evaluating Income Distributions: Rank Dominance, the Suppes-Sen Grading
Principle of Justice and Pareto Optimality", Public Choice, 40: 329-36.{p_end}

{p 4 4 2}Shorrocks A.F., 1983, "Ranking Income Distributions", Economica, 50: 3-17.{p_end}


{title:ADO Dependencies}

{p 4 4 2}Paul Corral & Minh Cong Nguyen & Joao Pedro Azevedo, 2018. "GROUPFUNCTION: Stata module to replace several basic collapse functions," Statistical Software Components S458475, Boston College Department of Economics. <https://ideas.repec.org/c/boc/bocode/s458475.html>{p_end} 
{p 4 4 2}Daniel Klein, 2019. "WHICH_VERSION: Stata module to return location and programmer's version of ado-files," Statistical Software Components S4584706, Boston College Department of Economics, revised 11 Nov 2019. <https://ideas.repec.org/c/boc/bocode/s458706.html>{p_end} 

{title:Authors}

    Joao Pedro Azevedo
    jazevedo@worldbank.org

    Samuel Franco

{title:Aknowledgements}

{p 4 4 2}The authors would like to thank Andres Castaneda, Viviane Sanfelice, Gabriel Facchini, and Amer Hasan for their valuable suggestions.{p_end}
{p 4 4 2}The usual disclaimer applies.{p_end}
{p 4 4 2}{cmd:alorenz} uses the Stata user written command _pecats by J. Scott Long and Jeremy Freese., as well as groupfunction and which_version.{p_end} 

{title:Also see}

{p 4 13 2}Manual:  {hi:[R] lorenz}{p_end}
{p 4 13 2}Online:  help for {help glcurve}; {help inequal7}; {help ineqdeco}; {help ksmirnov}; {help wbopendata}(if installed){p_end}
