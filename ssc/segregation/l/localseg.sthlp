{smcl}
{* March 2015}{...}
{hline}
help for {hi:localseg (Version 2.2)}{right:Carlos Gradín (March 2015)}
{hline}

{title:Local and overall Segregation indices with optional local segregation curves, using either individual data or aggregated data}
(For the two-group case see {help dicseg})

{p 4 4 2}
-For individual data (each observation is an individual):

{p 8 17 2} {cmd:localseg} {it:unitvar} {it:groupvar} [{it:weights}] [{cmd:if} {it:exp}] [{cmd:in} {it:range}]
[, {cmdab:f:ormat}{it:(%9.#f)} {cmdab:sc:} {cmdab:no:graph} {cmdab:x:}{it:(newvar)} {cmdab:y:}{it:(newvar)} {cmdab:xt:itle}{it:(xtitle)} {cmdab:yt:itle}{it:(ytitle)} {cmdab:gr:aph_options}{it:(graph_options)}  ]

{p 4 4 2} 
For measuring the segregation of each unit (representativeness perspective), swap the variables (only works with few units supoorted by {cmd:tab} {it:groupvar} {it:unitvar}):

{p 8 17 2}
{cmd:localseg} {it:groupvar} {it:unitvar}  ...

{p 4 4 2} {cmd:fweights}, {cmd:aweights} and {cmd:aweights} are allowed; see {help weights}.


{p 4 4 2}
-For aggregated data (each observation is a unit):

{p 8 17 2} {cmd:localseg} {it:unitvar} {it:group1var} ... {it:groupkvar} [ {cmd:if} {it:exp}] [{cmd:in} {it:range}]
, {cmdab:ag:gregate} [ {cmdab:f:ormat}{it:(%9.#f)} {cmdab:sc:} {cmdab:no:graph} {cmdab:x:}{it:(newvar)} {cmdab:y:}{it:(newvar)} {cmdab:xt:itle}{it:(xtitle)} {cmdab:yt:itle}{it:(ytitle)} {cmdab:gr:aph_options}{it:(graph_options)}  ]

{title:Important}

{p 4 4 2}
It requires to have {help matsort}, written by Paul Millar, previously installed; if not, install it writing in the command line:

{p 8 4 2}
. net install matsort, all from(http://fmwww.bc.edu/RePEc/bocode/m)


{title:Description}

{p 4 4 2}
{cmd:localseg} computes local and overall segregation indices across units in a multigroup context, as proposed by Alonso-Villar and Del Río, 2010.

{p 8 4 2}
* A local segregation index compares the distribution of each group across units with that of the population.

{p 12 4 2}
(It is also possible to compute the segregation of each unit using the representativeness perspective).	

{p 8 4 2}
* An overall segregation index measures the segregation of the population across units, that in some cases can also be obtained from aggregating local segregation for every group.

{p 4 4 2} 
By default, microdata (individual observations) are required. 

{p 8 4 2}
{it:unitvar} is a categorical variable identifying units (ex. occupations, census tracts, schools, ....). Each observation is an individual.

{p 8 4 2}
{it:groupvar} is a categorical variable identifying groups (gender, race, gender x race...).

{p 4 4 2} 
For data aggregated by unit (each observation is a unit), use the {cmdab:ag:gregate} option .

{p 8 4 2} 
{it:unitvar} is a categorical variable identifying units (ex. occupations, census tracts, schools, ....). Each observation is a unit.

{p 8 4 2} 
{it:group1var} {it:group2var}  ... {it:groupkvar} are integer (or real) variables that identify the number (or proportion) of individuals from each group in the corresponding unit.

{p 4 4 2} 
If option {cmdab:sc:} is specified it also draws the local segregation curves, and creates new variables using {cmdab:x:}{it:(newvar)} and {cmdab:y:}{it:(newvar)} options.

{title:Reporting}

{p 4 4 2} 
(see Alonso-Villar and Del Río, 2010 for formulae and references)

{p 4 4 2} 
Overall Segregation indices:

{p 8 4 2} 
. Ip, multigroup index of dissimilarity.

{p 8 4 2} 
. M, the mutual information index.

{p 12 4 2} 
Note that M = GE(1); Mutual Information Index M using with natural log.

{p 8 4 2} 
. Gini, the unbounded version of the multigroup Gini index.

{p 8 4 2} 
. Dissimilarity, the index of dissimilarity (only reported in the case of two groups).


{p 4 4 2}
Local Segregation indices: 

{p 8 4 2}
. Ip, multigroup index of dissimilarity.

{p 8 4 2}
. K and K(a), Chakravarty and Silber (2007) multigroup indices.

{p 8 4 2} 
. GE(c), c=0, .10, .25, .50, .75, .90, 1, family of indices related to the Generalized Entropy family, for different values of the segregation sensitivity parameter.

{p 12 4 2}
Note that M = GE(1); Mutual Information Index M [ with natural logs ].

{p 12 4 2} 
. K, K(a) and GE(<=0) only reported for groups with members in all units.

{p 8 4 2} 
. Gini, variation of the Gini index. 

{p 4 4 2} 
Each group's relative population share and contribution to overall segregation are also reported.

{p 4 4 2} 
Segregation Curves (if option {cmdab:sc:} is specified).



{title:Options}

{p 4 8 2}
{cmdab:ag:gregate} to use aggregated data, the default is to use individual data.

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

{p 4 8 2}
{cmdab:f:ormat}{it:(%9.#f)} to change numeric format, the default is {cmdab:f:ormat}{it:(%9.4f)}



{title:Saved results} 

{p 4 4 2} 
Matrices:

{p 8 8 2} 
r(oseg) : overall segregation (first column) and relative contributions

{p 8 8 2} 
r(lseg) : local segregation



{title:Examples} 

{p 4 8 2}
. {stata use segdata.dta, clear }

{p 4 8 2}
For individual data:

{p 4 8 2}
. {stata localseg occupation2 race [aw=pwgtp]}

{p 4 8 2}
. {stata ret list}

{p 4 8 2}
. {stata localseg occupation race [aw=pwgtp], sc}

{p 4 8 2}
. {stata localseg occupation race [aw=pwgtp], sc x(cumem) y(cumtgt) xt(Cumulative employment) yt(Cumulative target workers)}

{p 8 8 2}
For representativeness:

{p 4 8 2}
. {stata localseg race occupation [aw=pwgtp]}


{p 4 8 2}
For aggregated data (we first collapse data by occupation):

{p 4 8 2}
. {stata collapse (sum) white black asian native hispanic other  [iw=pwgtp] , by(occupation) }

{p 4 8 2}
. {stata localseg occupation white black asian native hispanic other  , ag sc}


{p 4 8 2}
For bootstrapping (BC estimates) with individual data, using saved scalars (copy and paste the following in the command line or in a .do file)

{p 8 8 2}
(Example for local segregation GE(1) using information for this index saved in matrix r(lseg), 16th row)


{p 8 8 2}
 {stata use segdata.dta, clear }

{p 8 8 2}
 cap program drop lseg

{p 8 8 2}
 program def lseg

{p 12 8 2}
 localseg occupation2 race [aw=pwgtp]

{p 12 8 2}
 mat lseg=r(lseg)

{p 12 8 2}
 local r=rowsof(lseg)

{p 12 8 2}
 forvalues i=1/`r' {

{p 16 8 2}
  scalar ls`i'=lseg[16,`i']

{p 12 8 2}
 }

{p 8 8 2}
 end

{p 8 8 2}
 bootstrap ls1 ls2 ls3 ls4 ls5 ls6 , reps(10): lseg

{p 8 8 2}
 estat bootstrap




{title:Author}

{p 4 4 2}{browse "http://webs.uvigo.es/cgradin": Carlos Gradín}
<cgradin@uvigo.es>{break}
Facultade de CC. Económicas{break}
Universidade de Vigo{break} 
36310 Vigo, Galicia, Spain.


{title:References}

{p 8 8 2} For theory:

{p 4 8 2}
Alonso-Villar, O. and C. Del Río (2010), Local versus Overall Segregation Measures, Mathematical Social Sciences, vol. 60(1), pp. 30-38.

{p 8 8 2} For applications:

{p 4 8 2}
Alonso-Villar, O., C. Del Río, C., and C. Gradín, C. (2012), 
{browse "http://www.ecineq.org/milano/WP/ECINEQ2010-180.pdf": The extent of occupational segregation in the US: Differences by race, ethnicity, and gender}, Industrial Relations, 51(2): 179-212.

{p 4 8 2}
Del Río, C. and Alonso-Villar, O. (2010),
{browse "http://webs.uvigo.es/x06/sites/default/files/docs/wp0904.pdf": Gender segregation in the Spanish labor market: An alternative approach} , Social Indicators Research, vol. 98 (2), September, pp. 337-362

{p 4 8 2}
Del Rio, C. and Alonso-Villar, O. (2012), 
{browse "http://www.ecineq.org/milano/WP/ECINEQ2010-165.pdf": Occupational Segregation of Immigrant Women in Spain}, Feminist Economics, 18(2): 91-123.

{p 4 8 2}
Gradín, C., O. Alonso-Villar, and C. Del Río (2014), 
{browse "http://www.ecineq.org/milano/WP/ECINEQ2011-190.pdf": Occupational segregation by race and ethnicity in the US: Differences across states}, Regional Studies, forthcoming.

 

{title:Also see}

{p 4 13 2}
{help dicseg} if installed; {help duncan} if installed; {help hutchens} if installed; {help seg} if installed





