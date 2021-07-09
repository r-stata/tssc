{smcl}
{* *! version 1.0.1 24aug2016}{...}
{vieweralsosee "[R] xtpoisson" "help xtpoisson"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "ppml_panel_sg" "help ppml_panel_sg"}{...}
{vieweralsosee "ppmlhdfe" "help xtpqml"}{...}
{vieweralsosee "poi2hdfe" "help poi2hdfe"}{...}
{vieweralsosee "reghdfe" "help reghdfe"}{...}
{viewerjumpto "Syntax" "ge_gravity##syntax"}{...}
{viewerjumpto "Description" "ge_gravity##description"}{...}
{viewerjumpto "Main Options" "ge_gravity##main_options"}{...}
{viewerjumpto "Background" "ge_gravity##backgroup"}{...}
{viewerjumpto "Examples" "ge_gravity##examples"}{...}
{viewerjumpto "Stored results" "ge_gravity##results"}{...}
{viewerjumpto "Author" "ge_gravity##contact"}{...}
{viewerjumpto "Other" "ge_gravity##other"}{...}
{viewerjumpto "Updates" "ge_gravity##updates"}{...}
{viewerjumpto "Acknowledgements" "ge_gravity##acknowledgements"}{...}
{viewerjumpto "References" "ge_gravity##references"}{...}
{title:Title}

{p2colset 5 22 23 2}{...}
{p2col :{cmd:ge_gravity} {hline 2}} Solves a simple general equilibrium one sector Armington-CES trade model.{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 15 2}{cmd:ge_gravity}
{depvar} [{indepvars}] 
{ifin}{cmd:,} {opt ex:porter(exp_id)} {opt im:porter(imp_id)} {opt y:ear(time_id)} [{help ge_gravity##options:options}] {p_end}

{p 8 8 2}{it: exp_id} and {it: imp_id} are variables that respectively identify 
the origin and destination country associated with each observation. {it: flows} are
the observed trade flows in the data for the year being used as the baseline for the counterfactual.
{it: beta} is an input reflecting the “partial” change in trade, typically obtained as a coefficient
from a prior gravity estimation. For more details, see the {browse "http://www.tomzylkin.com/uploads/4/1/0/4/41048809/help_file.pdf":online version of this help file}.{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:ge_gravity}  solves for general equilibrium effects of changes in trade policies using a one sector Armington-CES
trade model. It uses a simple fixed point algorithm that allows for fast computation. This approach, together with
the implementation in Stata, makes this program ideal for bootstrapping confidence intervals for general equilibrium
simulations based on prior gravity estimates of FTAs or other similar variables. Examples of references
which conduct general equilibrium analysis based on FTA estimates in this way include Egger, Larch, Staub, &
Winkelmann (2011), Anderson & Yotov (2016), and Baier, Yotov, & Zylkin (2019). Yotov, Piermartini, Monteiro,
& Larch (2016) provide a detailed survey and introduction to the topic.{p_end}

{marker main_options}{...}
{title:Main Options}

These options allow you to store results for general equilibrium changes in trade flows, welfare, and real wages
as a result of the change in trade frictions. You may also vary how trade imbalances are treated in the model.

{synoptset 20 tabbed}{...}
{synopt: {opt theta(#)}}An input is required for the trade elasticity.{p_end}

{synopt: {opt mult:iplicative}}If trade is unbalanced in the data (as it usually is), the default is to treat the trade balance as an
additive component of national expenditure (see below.) The “multiplicative” option instead
supposes that national expenditure is a fixed multiple of national output, as in Anderson &
Yotov (2016).{p_end}

{synopt: {opt gen_w(varname)}}Store the resulting change in welfare for each country (i.e., the new level of welfare divided
by the old level of welfare). The value that is saved corresponds with the exporter’s change
in welfare.

{synopt: {opt gen_X(varname)}}Store the new level of trade for each pair of countries.

{synopt: {opt gen_rw(varname)}}Store the change in real wage for each country (i.e., the new real wage divided by the old
real wage). Note this is generally different from the change in welfare unless if either trade is
balanced or the “multiplicative” option is chosen. The value that is saved corresponds with
the exporter’s change in real wage.

As of v. 1.1, it's also possible to compute the constituent parts of the change in the real wage—the change in the nominal wage and the change in the price index—using {opt gen_nw(varname)} and {opt gen_P(varname)}.  
The saved values always correspond to the exporting country.

{marker background}{...}
{title:Background & Advisory}

{pstd}
This is an advanced technique that requires a fundamental understanding of the model being solved and its connection to
the empirical gravity model. Before using this command, I suggest that users read the 
{browse "http://www.tomzylkin.com/uploads/4/1/0/4/41048809/help_file.pdf":online help file}
I have created
that goes into full detail regarding the model and algorithm being used.
There is also an {browse "http://www.tomzylkin.com/uploads/4/1/0/4/41048809/ge_gravity.zip":example .do file} 
that demonstrates the syntax and options in a practical setting using 
real data. In addition, I would recommend reading either Section 4.3 of Head & Mayer (2014) or Ch. 2 of Yotov, Piermartini, Monteiro, & Larch (2016)
before implementing these methods.{p_end}

{marker examples}{...}
{title:Examples}

{pstd}These examples follow the sample .dta and .do files that have been provided along with this command ({browse "http://www.tomzylkin.com/uploads/4/1/0/4/41048809/ge_gravity.zip":link}). The data
set consists of a panel of 44 countries trading with one another over the years 2000-2014. The trade data uses
aggregated trade flows based on WIOD and information on FTAs is from the NSF-Kellogg database maintained
by Scott Baier and Jeff Bergstrand.{p_end}

{pstd}Suppose the researcher wishes to use this data set to quantify general equilibrium trade and welfare effects of the
EU enlargements that took place between 2000-2014. To first obtain the partial effects of these enlargements on
trade flows, a PPML gravity specification may be used:{p_end}

{p 8 15 2}{cmd:ppmlhdfe trade eu_enlargement other_fta if exporter != importer, a(expcode#year impcode#year expcode#impcode) cluster(expcode#impcode)}

{pstd}This syntax implements a PPML gravity model with three-way fixed effects using the ppmlhdfe command created by Correia, Guimarães, &
Zylkin (2019). In addition to estimating the effects of EU enlargements on new EU pairs, this example also
controls for any other FTAs signed during the period. Each of these variables is coded as a dummy variable that
becomes 1 when the agreement goes into effect for a given pair. The estimated coefficient for eu_enlargements
is 0.224, implying that the expansion of the EU had an average partial effect of exp(0.224)-1 = 25.1% on trade between
new EU members and existing members. With clustered standard errors, this estimate is statistically significant at
the p < .01 significance level.{p_end}

{pstd}Next, to obtain the general equilibrium effects of these new additions to the EU (as of 2000) we can input the
following code:{p_end}

{p 8 8 2}{cmd:sort exporter importer year}{break}
{cmd:by exporter importer: gen new_eu_pair = (eu_enlargement[_N]-eu_enlargement[1])}{break}
{cmd:gen eu_effect = _b[eu_enlargement] * new_eu_pair}{break}
{cmd:ge_gravity exporter importer trade eu_effect if year==2000, theta(4) gen_w(w_eu) gen_X(X_eu)}{p_end}

{pstd}This assumes a standard trade elasticity value of theta = 4. The input for “beta” is given by a variable called
eu_effect, which is equal to 0.224 for new EU pairs formed during the period and equal to 0 otherwise. Because
of the small size of the sample, it solves almost instantly. Unsurprisingly, the new EU members (Bulgaria,
Croatia, Czech Republic, Estonia, Hungary, Latvia, Lithuania, Malta, Poland, Romania, Slovakia, and Slovenia)
realize the largest welfare gains from their joining the EU, with existing EU countries also gaining. All countries
not included in the agreement experience small losses due to trade diversion, with the largest losses accruing to
Russia.{p_end}

{pstd}We can also change how trade imbalances enter the model. The default is to assume that they enter expenditure
additively (i.e., E_j = Y_j + D_j, where E_j is national expenditure, Y_j is national income, and D_j is the trade imbalance), but one can also change the model so that expenditure is instead a fixed multiple of
income (i.e., let Ej = delta_j * Y_j .) This is done using the multiplicative option:{p_end}

{p 8 15 2}{cmd:ge_gravity exporter importer trade eu_effect if year==2000, theta(4) gen_w(w_eu) gen_X(X_eu) mult}{p_end}

{pstd}While using multiplicative imbalances instead of additive balances changes the results slightly, they are still qualitatively
very similar.{p_end}

{pstd}An important point about the above exercises is that the initial partial effect is estimated with some 
uncertainty (i.e., the estimation error reflected in the estimated standard error for beta).
The GE results that were calculated may paint a misleading picture because they do not take this uncertainty
into account. For this reason, it is considered good practice to use a bootstrap method to construct confidence
intervals for the GE calculations. This type of procedure is easily coded using {cmd:ge_gravity}. The included file
“GE_gravity_example.do” provides a simple demonstration.{p_end}

{marker other}{...}
{title:Other Notes}

{pstd}
One common issue that researchers new to these methods should be aware of is that GE trade models require a
“square” data set with information on internal trade flows in addition to data on international trade flows. In the
model, these internal flows are denoted by X_ii. If ge_gravity detects that the variable given for flows does not
include one or more X_ii terms, it will exit with an error. Not all publicly available trade data sets include internal
trade values. But some that do are include 
{browse "http://www.wiod.org/home":WIOD}, 
{browse "https://worldmrio.com/":Eora MRIO,} 
and the data set made available by
{browse "https://vi.unctad.org/tpa/index.html":UNCTAD} 
as part of their online course on trade policy analysis 
(see Yotov, Piermartini, Monteiro, & Larch, 2016.){p_end}

{pstd}This is version 1.1 of this command. Depending on interest, future versions could feature additional options
such as allowances for tariff revenues and/or multiple sectors. If you believe you have found an error that can be
replicated, or have other suggestions for improvements, please feel free to {browse "mailto:tomzylkin@gmail.com":contact me}.{p_end}

{marker contact}{...}
{title:Author}

{pstd}Thomas Zylkin{break}
Department of Economics, Robins School of Business{break}
University of Richmond{break}
Email: {browse "mailto:tomzylkin@gmail.com":tomzylkin@gmail.com}
{p_end}

{marker citation}{...}
{title:Suggested Citation}

If you are using this command in your research I would appreciate if you would cite

{pstd}• Baier, Scott L., Yoto V. Yotov, and Thomas Zylkin. “On the widely differing effects of free trade agreements: Lessons from twenty years of trade integration." Journal of International Economics 116 (2019): 206-226.{p_end}

The algorithm used in this command was specifically written for the exercises performed in this paper. Section 6 of the paper provides a more detailed description of the underlying model and its connection to the literature.

{marker acknowledgements}{...}
{title:Acknowledgements}

{pstd}The basic idea of using fixed point iteration to solve the gravity model has previously been implemented in Stata
by Head & Mayer (2014) and Anderson, Larch, & Yotov (2015).{p_end}

{marker further_reading}{...}
{title:Further Reading}

{pstd}• Structural gravity: Anderson & van Wincoop (2003); Head & Mayer (2014){p_end}

{pstd}• Methods for solving trade models: Alvarez & Lucas (2007); Anderson, Larch, & Yotov (2015); Head &
Mayer (2014){p_end}

{pstd}• Hat algebra: Dekle, Eaton, & Kortum (2007){p_end}

{pstd}• GE effects of EU enlargements: Felbermayr, Gröschl, & Heiland (2018); Mayer, Vicard, & Zignago (2018){p_end}


{marker references}{...}
{title:References}

{phang}
Alvarez, F. & Lucas, J., Robert E. (2007), “General equilibrium analysis of the Eaton–Kortum model of international
trade”, Journal of Monetary Economics 54(6), 1726–1768.{p_end}

{phang}
Anderson, J. E., Larch, M., & Yotov, Y. V. (2015), “Estimating General Equilibrium Trade Policy Effects: GE
PPML”, CESifo Working Paper 5592.{p_end}

{phang}
Anderson, J. E. & van Wincoop, E. (2003), “Gravity with Gravitas: A Solution to the Border Puzzle”, American
Economic Review 93(1), 170–192.{p_end}

{phang}
Anderson, J. E. & Yotov, Y. V. (2016), “Terms of trade and global efficiency effects of free trade agreements,
1990–2002”, Journal of International Economics 99, 279–298.{p_end}

{phang}
Baier, S. L., Yotov, Y. V., & Zylkin, T. (2019), “On the widely differing effects of free trade agreements: Lessons
from twenty years of trade integration”, Journal of International Economics 116, 206–226.{p_end}

{phang}
Correia, S., Guimarães, P., & Zylkin, T. (2019), “PPMLHDFE: Fast Poisson Estimation with High-dimensional
Data”, Unpublished manuscript.{p_end}

{phang}
Dekle, R., Eaton, J., & Kortum, S. (2007), “Unbalanced Trade”, American Economic Review 97(2), 351–355.{p_end}

{phang}
Egger, P., Larch, M., Staub, K. E., & Winkelmann, R. (2011), “The Trade Effects of Endogenous Preferential
Trade Agreements”, American Economic Journal: Economic Policy 3(3), 113–143.{p_end}

{phang}
Felbermayr, G., Gröschl, J. K., & Heiland, I. (2018), “Undoing Europe in a new quantitative trade model”, Ifo Working Paper.{p_end}

{phang}
Head, K. & Mayer, T. (2014), “Gravity Equations: Workhorse, Toolkit, and Cookbook”, in G. Gopinath, E. Helpman,
& K. Rogoff (eds.) Handbook of International Economics, vol. 4, pp. 131–195, North Holland, 4 ed.{p_end}

{phang}
Mayer, T., Vicard, V., & Zignago, S. (2018), “The cost of non-Europe, revisited”, Economic Policy.{p_end}

{phang}
Yotov, Y. V., Piermartini, R., Monteiro, J.-A., & Larch, M. (2016), An Advanced Guide to Trade Policy Analysis:
The Structural Gravity Model, World Trade Organization, Geneva.{p_end}