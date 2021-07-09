{smcl}
{* March 2015}{...}
{hline}
help for {hi:dicseg (Version 2.2)}{right:Carlos Gradín (March 2015)}
{hline}

{title:Segregation indices with optional segregation curve for the case of two groups with either individual data or aggregated data}
(For multigroup cases see {help localseg})

{p 4 4 2}
-For individual data (each observation is an individual):

{p 8 17 2} {cmd:dicseg} {it:unitvar} {it:groupvar} [{it:weights}] [{cmd:if} {it:exp}] [{cmd:in} {it:range}]
[,  {cmdab:nor:malize} {cmdab:f:ormat}{it:(%9.#f)} {cmdab:sc:} {cmdab:no:graph} {cmdab:x:}{it:(newvar)} {cmdab:y:}{it:(newvar)} {cmdab:xt:itle}{it:(xtitle)} {cmdab:yt:itle}{it:(ytitle)} {cmdab:gr:aph_options}{it:(graph_options)} ]

{p 4 4 2} {cmd:fweights}, {cmd:aweights} and {cmd:aweights} are allowed; see {help weights}.

{p 4 4 2}
-For aggregated data (each observation is a unit):

{p 8 17 2} {cmd:dicseg} {it:unitvar} {it:group1var} {it:group2var} [{cmd:if} {it:exp}] [{cmd:in} {it:range}]
, {cmdab:ag:gregate} [ {cmdab:nor:malize}  {cmdab:f:ormat}{it:(%9.#f)} {cmdab:sc:} {cmdab:no:graph} {cmdab:x:}{it:(newvar)} {cmdab:y:}{it:(newvar)} {cmdab:xt:itle}{it:(xtitle)} {cmdab:yt:itle}{it:(ytitle)} {cmdab:gr:aph_options}{it:(graph_options)} ]


{title:Important}

{p 4 4 2}
It requires to have {cmd: matsort}, written by Paul Millar, previously installed; if not, install it writing in the command line:

{p 8 4 2}
. net install matsort, all from(http://fmwww.bc.edu/RePEc/bocode/m)


{title:Description}

{p 4 4 2} 
{cmd:dicseg} computes segregation indices across units in a two-group context.

{p 4 4 2} 
By default, microdata (individual observations) are required. 

{p 8 4 2} 
{it:unitvar} indicates units (ex. occupations, census tracts, schools, ....).

{p 8 4 2} 
{it:groupvar} is a dichotomous variable identifying two groups such as gender (male vs. female), race (white versus non-white), ...

{p 4 4 2} 
For data aggregated by unit (each observation is a unit), use the {cmdab:ag:gregate} option .

{p 8 4 2} 
{it:unitvar} indicates units (ex. occupations, census tracts, schools, ....).

{p 8 4 2} 
{it:group1var} and {it:group2var} identify the variables that give the number (or proportion) of individuals from the first and second group respectively in each unit.

{p 4 4 2} 
If option {cmdab:sc:} is specified it also draws the segregation curve, and creates new variables using {cmdab:x:}{it:(newvar)} and {cmdab:y:}{it:(newvar)} options. 

{p 12 4 2} 
{cmd:x} represents the group with the lowest value in {it:groupvar} and {cmd:y} the group with the highest value.


{title:Reporting}

{p 4 4 2} 
Segregation indices (for formulae and details, see {browse "http://webs.uvigo.es/cgradin/Measuring_Segregation_Using_Stata__The_Two_group_Case.pdf": Gradín, 2014}):

{p 8 4 2} 
. Dissimilarity index.


{p 8 4 2} 
. KM, the Karmel and Maclachlan (1988) index.


{p 8 4 2} 
. GE(alpha) with alpha= -2, -1, 0, .10, .25, .50, .75, .90, 1, 2 is the family of Generalized Entropy measures for different values of the segregation sensitivity parameter. GE(1) is also known as Theil index.

{p 12 4 2} 
Note: GE is infinite for some alpha when one group has no observations at one or more units: GE(alpha>=1) if group 1; GE(alpha<=0) if group 2. In those cases only finite cases are reported.


{p 8 4 2} 
. Squared Root (Hutchens, 1991, 2004) is equivalent to GE(.5)/4


{p 8 4 2} 
. A(epsilon) with epsilon= .10, .25, .50, .75, .90, 1, 2, 4 is the family of Atkinson indices for different values of the segregation sensitivity parameter.

{p 12 4 2} 
Note: A(epsilon>1) is infinite when group 2 has no observations at one or more units. In those cases only finite cases are reported.


{p 8 4 2} 
. Mutual Information (e.g. Theil and Finizza, 1971) using log(2).


{p 8 4 2} 
. Gini, the Gini index.

{p 8 4 2}

{p 8 4 2} 
All indices take the value 0 when there is no segregation because both groups have the same distribution across units.

{p 8 4 2} 
Dissimilarity, Squared Root, A, M, Gini take the value 1 when segregation is at its maximum (no overlapping distributions).

{p 4 4 2}
Segregation Curve (if option {cmdab:sc:} is specified): as defined in Duncan and Duncan (1955) or Hutchens (1991).


{title:Options}

{p 4 8 2}
{cmdab:ag:gregate} to use aggregated data, the default is to use individual data.

{p 4 8 2}
{cmdab:nor:malize} to normalize GE(0<alpha<1) to range between 0 and 1, multiplying by alpha*(1-alpha). By default, the index is not normalized.

{p 4 8 2}
{cmdab:f:ormat}{it:(%9.#f)} to change numeric format, the default is {cmdab:f:ormat}{it:(%9.4f)}.

{p 4 8 2}
{cmdab:sc:} to compute segregation curves.

{p 8 8 2}
{cmdab:no:graph} to do not graph segregation curves.

{p 8 8 2}
{cmdab:x:}{it:(newvar)} {cmdab:y:}{it:(newvar)} to create variables for segregation curves.

{p 8 8 2}
{cmdab:xt:itle}{it:(xtitle)},{cmdab:yt:itle}{it:(ytitle)} to change the title of segregation curves.

{p 8 8 2}
{cmdab:gr:aph_options}{it:(graph_options)} to change default graph options for segregation curves.


{title:Saved results} 

{p 4 4 2} 
Matrix:

{p 8 8 2} 
r(seg) : segregation indices

{p 4 4 2} 
Scalars:

{p 8 8 2} 
r(D), r(KM), r(GEm2), r(GEm1), r(GE0), r(GE10), r(GE25), r(GE50), r(GE75), r(GE90), r(GE1), r(GE2), r(H), r(CV), r(A10), r(A25), r(A50), r(A75), r(A90), r(A1) r(A2), r(A4), r(Mutual), r(Gini)

{p 8 8 2} 
r(freq1), r(freq2), r(nunits)

{title:Examples} 

{p 4 8 2}
. {stata use segdata.dta, clear }

{p 4 8 2}
For individual data:

{p 4 8 2}
. {stata dicseg occupation white [aw=pwgtp], sc}

{p 4 8 2}
. {stata ret list}

{p 4 8 2}
. {stata dicseg occupation2 sex [aw=pwgtp], nor sc}

{p 4 8 2}
. {stata dicseg occupation white [aw=pwgtp], sc x(cumnonwhite) y(cumwhite) xt(Cumulative proportion of nonwhites) yt(Cumulative proportion of whites)}

{p 4 8 2}
. {stata dicseg occupation sex [aw=pwgtp], sc x(cummale) y(cumfemale) xt(Cumulative proportion of males) yt(Cumulative proportion of females)}

{p 4 8 2}
For aggregated data (we first collapse data by occupation):

{p 4 8 2}
. {stata collapse (sum) white nonwhite [iw=pwgtp] , by(occupation) }

{p 4 8 2}
. {stata dicseg occupation nonwhite white , ag sc}


{p 4 8 2}
For bootstrapping (BC estimates) with individual data, using saved scalars (copy and paste the following in the command line or in a .do file)

{p 8 8 2}
 {stata use segdata.dta, clear }

{p 8 8 2}
 cap program drop dseg

{p 8 8 2}
 program def dseg

{p 12 8 2}
 dicseg occupation2 sex [aw=pwgtp]

{p 8 8 2}
 end

{p 8 8 2}
 bootstrap r(D) r(KM) r(GE1) r(H) r(M) r(G) , reps(10): dseg

{p 8 8 2}
 estat bootstrap


{title:Author}

{p 4 4 2}{browse "http://webs.uvigo.es/cgradin": Carlos Gradín}
<cgradin@uvigo.es>{break}
Facultade de CC. Económicas{break}
Universidade de Vigo{break} 
36310 Vigo, Galicia, Spain.


{title:References}


{p 4 8 2}
Duncan, Otis D. and Duncan, Bervely (1955), A Methodological Analysis of Segregation Indexes, American Sociological Review, 20(2): 210-217.

{p 4 8 2}
Gradín, Carlos (2014), {browse "http://webs.uvigo.es/cgradin/Measuring_Segregation_Using_Stata__The_Two_group_Case.pdf": Measuring Segregation using Stata}, Universidade de Vigo.

{p 4 8 2}
Hutchens, Robert M. (1991), Segregation Curves, Lorenz Curves, and Inequality in the Distribution of People across Occupations, Mathematical Social Sciences, 21: 31- 51.

{p 4 8 2}
Hutchens, Robert M. (2004), One Measure of Segregation, International Economic Review 45(2): 555-578.

{p 4 8 2}
Karmel, T. and Maclachlan M. (1988), Occupational Sex Segregation - Increasing or Decreasing, Economic Record, 64: 187-195.


{p 4 8 2}
Theil, Henri and Anthony J. Finizza (1971), A Note on the Measurement of Racial Integration of Schools by Means of Informational Concepts, Journal of Mathematical Sociology, 1: 187-194

{title:Also see}

{p 4 13 2}
{help duncan} if installed; {help hutchens} if installed; {help localseg} if installed; {help seg} if installed




