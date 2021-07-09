{smcl}
{* *! version 1.0  May2014}{...}
{cmd:help dseg}{right:dialog:  {dialog dseg}{space 15}}
{hline}

{title:Title}

{title:Syntax}

{p 8 14 2}
{cmd:dseg} {it:index} {it:groupvar} {it:units_varlist} {ifin} {weight} {cmd:,} [{it:options}]

{synoptset 22}{...}
{p2coldent:{it:index}}description{p_end}
{synoptline}
{synopt:{opt mutual}}Mutual Information{p_end}
{synopt:{opt atkinson}}Symmetric Atkinson{p_end}
{synopt:{opt entropy}}Entropy{p_end}
{synopt:{opt diversity}}Relative Diversity{p_end}
{synoptline}

{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Model}
{synopt :{opt b:y(by_varlist)}}specifies the {it:by_varlist} combinations over which the index is to be computed{p_end}
{synopt :{opt w:ithin(w_varlist)}}specifies the units within which the index is to be computed{p_end}
{synopt :{opt save(filename[,opt])}}saves in {it:filename} all elements in the within term{p_end}
{synopt :{opt replace}}replaces current data with index values{p_end}
{synopt :+ {opt gen:erate(newvar)}}name for new variable that includes index values{p_end}

{syntab :Reporting}
{synopt :{opt f:ormat(%fmt)}}set index output format; default is %9.4f; see {help format}{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}+ This option must be specified when {cmd:replace} is specified.{p_end}
{p 4 6 2}{cmd:fweight}s are allowed; see {help weight}.{p_end}

{title:Description}

{pstd}
{cmd:dseg} computes four alternative multigroup indexes of segregation that are additively decomposable. 
Each index is designed to measure how different groups of individuals are associated with different organizational units. 
The four indexes are: the Mutual Information and the Symmetric Atkinson index (both characterized in terms of ordinal axioms by Frankel and Volij, 2011), and the Entropy and the Relative Diversity index 
(whose properties are discussed by Reardon and Firebaugh, 2002). No other multigroup index of segregation has been shown to be additively decomposable as defined below.

{pstd}
The variable {it:groupvar} identifies the groups. The combinations formed by {it:units_varlist} identify the organizational units. 
The data can be individual-level or aggregated (i.e., each observation represents several people). 
In the latter case, the data set must also contain a variable for the actual number of individuals represented in each observation and {it:fweight} should be used.

{title:Options}

{dlgtab:Model}

{phang}
{opt by(by_varlist)} specifies the {it:by_varlist} combinations over which the index is to be computed. 
This option can be used to compute the same index for different years, countries, etc.{p_end}

{phang}
{opt within(w_varlist)} specifies the units within which the index is to be computed.
This option must be used to compute the within-term in any decomposition of the index. 
The between term can be directly computed using the supergroups (superunits) as groups (units).{p_end}

{phang}
{opt save(file[,opt])} saves in {it:file} the index, weight, and (whenever neccessary) ratio of all elements in the within term. Saving options are passed through by {it:opt}; see {help save}.
This option is only relevant when option {opt within(w_varlist)} is used.{p_end}

{phang}
{opt replace} replaces current data with index values.
The new data has as many observations as {it:by_varlist} combinations.
The variables are those in {it:by_varlist} and the new variable that contains the value of the index.{p_end}

{phang}
{opt generate(newvar)} declares the name for the new variable that includes index values in the new dataset. 
This option is required if option {opt replace} is used.{p_end}

{dlgtab:Reporting}

{phang}
{opt format(%fmt)} sets index output format; default is %9.4f; see {help format}{p_end}

{title:Remarks}

{pstd}
Decomposable indexes can be decomposed along groups or along untis. 
The property of group decomposability is relevant when the groups are partitioned into supergroups and we want to analyze segregation withing the supergroups.
Similarly, the property of unit decomposability is relevant when the organizational units can be partitioned into superunits and we want to analyze segregation withing the superunits.  
For example, when studying the level of racial segregation in the schools, the units are the schools and the groups are the races. 
If we want to analize national trends of segregation within school districts, we need an index that is unit decomposable and the superunits would be the school districts.  
If we want to analize trends of segregation within non-whites, we need an index that is group decomposable and the supergroups would be the whites and the non-whites categories. 
An index is additively decomposable along groups or units if it can be expressed as the sum of a between and a within term.
In an index that satisfies additive decomposability along groups (units), the between term is the index obtained using the supergroups (superunits). 
The within term is a linear combination of the indexes defined within the supergroups (superunits), where the weights of the linear combination are a function of the supergroups (superunits) sizes. 
If the weights are the population shares of the supergroups (superunits), then the index is said to be strong decomposable.
The within term is the decrease in segregation if observations within supergroups (superunits) were redistributed in the same supergroup (superunit) so that for each supergroup (superunit) the measure of segregation were zero.


{pstd}
Only the Mutual Information index is strong decomposable both along groups and along organizational units (see Frankel and Volij, 2011).
The Symmetric Atkinson, the Entropy, and the Diversity index are decomposable along any partition of the units into superunits but are not decomposable along any partition of the groups into supergroups 
(see Frankel and Volij, 2011, Mora and Ruiz-Castillo, 2011, and Reardon and Firebaugh, 2002).

{pstd}
All four indexes have a minimim value of 0 when all groups are equally distributed along the organizational units.
The Symmetric Atkinson, the Entropy, and the Relative Diversity indexes reach their maximum value 1 whenever, within any organizational unit, groups are not mixed.
The Mutual Information index reaches its upper bound whenever, in addition to having no groups mixing in any organizational unit, all groups have exactly the same population shares.
The upper bound of the Mutual Information index is the smallest value between the logarithm of the number of groups or the logarithm of the number of organizational units.

{pstd}
The within term in the decomposition can be computed using the option {opt within(w_varlist)} while the option {opt save(filename[,opt])} saves all the elements of the within term in file {it:filename}.

{pstd} 
Observations with missing values in at least one of {it:groupvar}, {it:units_varlist}, {it:fweight}, {it:w_varlist}, or {it:by_varlist} are dropped.

{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. use dseg.dta}{p_end}

{pstd}
The data are a subsample of the 2005 Common-Core of Data compiled by the U.S. National Center for Educational Statistics and contain enrollment counts by school and race.
Variables {it:race}, {it:school}, {it:district}, and {it:state} identify the racial group, the school, the district, and the state of each observation.
The variable {it:weight} includes the number of students in each {it:school}-{it:race} combination. 

{pstd}Displays the Mutual Information index of school segregation by race{p_end}
{phang2}{cmd:. dseg mutual race school [fw=weight]}{p_end}

{pstd}Displays the Mutual Information index of district segregation by race{p_end}
{phang2}{cmd:. dseg mutual race district [fw=weight]}{p_end}

{pstd}Displays the Mutual Information index of school segregation by race within school districts{p_end}
{phang2}{cmd:. dseg mutual race school [fw=weight], within(district)}{p_end}

{pstd}The within district term plus the index of district segregation equals the index of school segregation.{p_end}

{pstd}Displays the index of school segregation by race for each state in the sample{p_end}
{phang2}{cmd:. dseg mutual race school [fw=weight], by(state)}{p_end}

{pstd}Displays the same index by state within school districts{p_end}
{phang2}{cmd:. dseg mutual race school [fw=weight], by(state) within(district)}{p_end}

{pstd}As before plus it saves (replacing if neccessary) dataset within.dta with the district indexes and weights used to compute the within term.
It also replaces the current data with a set containing the within terms by state{p_end}
{phang2}{cmd:. dseg mutual race school [fw=weight], by(state) within(district) replace generate(Mw) saving(within.dta,replace)}{p_end}

{pstd}Using {cmd:preserve}, {cmd:dseg}, {cmd:save}, and {cmd:restore}, it is straightforward to save the indexes in a stata file and carry on with computations on the original dataset.{p_end}

{pstd}Using the Atkinson index{p_end}
{phang2}{cmd:. dseg atkinson race school [fw=weight], by(state) within(district) replace generate(Mw) saving(within.dta,replace)}{p_end}



{title:References}

{p 4 8 2}Frankel, D. M. and Volij, O. (2011). Measuring school segregation. {it:Journal of Economic Theory} 146(1):1{c -}38.

{p 4 8 2} Mora, R. and Ruiz-Castillo, J. (2011) Entropy-Based Segregation Indices.  {it:Sociological Methodology} 159–194{c -}41.

{p 4 8 2}Reardon, S. F. and Firebaugh, G. (2002). Measures of Multigroup Segregation.
{it:Sociological Methodology} 32:33{c -}67.


{title:Author}

{p 4 4 2}
Ricardo Mora, Department of Economics, Universidad Carlos III Madrid. Email: ricmora@eco.uc3m.es

{title:Acknowledgements}

{p 4 4 2}{cmd:dseg} was developed as part of a project on measurement of segregation supported by the Spanish Ministry of Science and Technology through grant ECO2012-31358.

{title:Also see}

{p 4 13 2}
{help duncan}, {help duncan2}, {help hutchens}, {help seg} if installed.
