{smcl}
{* March 2017}{...}
{hline}
help for {hi:welflossas (Version 1.0)}{right:Alicia Pérez-Alonso (March 2017)}
{hline}

{title:Well-being (monetary) gain/loss measures and social welfare loss indices and curves associated with segregation using either disaggregated or aggregated data for the quantitative variable.}

{p 4 4 2}
Disaggregated data: {it:quantvar} contains individual observations

{p 8 17 2} 
{cmd:welflossas} {it:{help varname:unitvar}} {it:{help varname:groupvar}} {it:{help varname:quantvar}} {ifin} [{it:{help weight}}]
[,{cmdab:st:ats:(}{it:statname}{cmd:)} {cmdab:thr:incl:(}{it:#}{cmd:)} {cmdab:nog:raph} {cmdab:f:ormat:(}{it:%{help format:fmt}}{cmd:)}] 

{p 4 4 2}
Aggregated data I: all individuals belonging to  the same unit have the same value in {it:quantvar} 

{p 8 17 2} 
{cmd:welflossas} {it:{help varname:unitvar}} {it:{help varname:groupvar}} {it:{help varname:quantvar}} {ifin} [{it:{help weight}}]
[,{cmdab:ag:gregate:} {cmdab:thr:incl:(}{it:#}{cmd:)} {cmdab:nog:raph} {cmdab:f:ormat:(}{it:%{help format:fmt}}{cmd:)}] 

{p 4 4 2}
Aggregated data II: a variable that contains an aggregated value for each unit is added from a 
second dataset to existing individual observations  from the dataset currently in memory  {p_end}

{p 8 17 2} 
{cmd:welflossas} {it:{help varname:unitvar}} {it:{help varname:groupvar}} {ifin} [{it:{help weight}}]
[,{cmdab:ag:gregate:} {cmdab:adds:tatus} {cmdab:callf:ile:(}{it:{help filename:filename1}}{cmd:)} {cmdab:callv:ar:(}{it:{help varname:quantvar}}{cmd:)} {cmdab:sav:ing:(}{it:{help filename:filename2}}{cmd:)} {cmdab:thr:incl:(}{it:#}{cmd:)}
 {cmdab:nog:raph} {cmdab:f:ormat:(}{it:%{help format:fmt}}{cmd:)}] {p_end} 

{p 4 4 2}
{cmdab:st:ats()} is available only for disaggregated data.

{pstd}
{cmdab:adds:tatus} is available only for aggregated data.
 
{pstd}
{cmd:fweight}s, {cmd:aweight}s and {cmd:iweight}s are allowed. {cmd:iweight}s are not allowed by {cmdab:st:ats(}{it:median}{cmd:)}. See {help weight}.  

{pstd}
{it:unitvar}, {it:groupvar}, and {it:quantvar} must be numeric. Zero-values of {it:quantvar} are automatically changed to missing values by the program. 
In case all observations of {it:quantvar} are missing for a specific value of {it:unitvar}, the program automatically excludes that value from the analysis.  {p_end}


{title:Description}

{pstd}
{cmd:welflossas} computes a family of indices measuring the well-being (monetary) gain/loss of a group associated with its segregation as proposed by Del Río and Alonso-Villar (2015)  and Alonso-Villar 
and Del Río (2016). {cmd:welflossas} also computes the FGT indices and produces the Social Welfare Loss curves as proposed by Del Río and Alonso-Villar (2017). {p_end}

{pstd}
Microdata (individual observations) are required. {p_end}
{p 8 12 2}
{it:unitvar} is a categorical variable identifying organizational units (e.g. occupations, census tracts, schools,...). {p_end}
{phang2}
{it:groupvar} is a categorical variable identifying demographic groups (e.g. gender, race, gender x race,...). {p_end}
{phang2}
{it:quantvar} is a quantitative variable (e.g. wage, status,...). Values of {it:quantvar} are either disaggregated or aggregated by unit (e.g. status by occupation). 
Use the {cmdab:ag:gregate} option for aggregated values. If these data come from an external source, specify also {cmdab:adds:tatus} and its associated options. {p_end}

{pstd}
If the {cmdab:nog:raph} option is omitted, the default is to draw the Social Welfare Loss curves and the 
decomposition of the per capita earning gap ratio (displayed only for disaggregated data).  {p_end}


{title:Options}

{p 4 8 2}
{cmdab:ag:gregate} uses aggregated values by unit for {it:quantvar} at individual level, the default is to use disaggregated data.

{phang} 
{cmdab:adds:tatus} performs a many-to-one merge on key variable {it:unitvar}; see {manhelp merge D}.

{phang2} 
{cmdab:callf:ile:(}{it:{help filename:filename1}}{cmd:)} is for use with {cmdab:adds:tatus}; it specifies a valid {it:filename1} that contains the using dataset.

{phang2} 
{cmdab:callv:ar:(}{it:{help varname:quantvar}}{cmd:)} is for use with {cmdab:adds:tatus}; it specifies the name of {it:quantvar} in the using dataset.

{phang2} 
{cmdab:sav:ing:(}{it:{help filename:filename2}}{cmd:)} is for (optional) use with {cmdab:adds:tatus}; it stores the dataset currently in memory on disk under the name {it:filename2}{cmd:.dta}. 

{phang} 
{cmdab:st:ats:(}{it:statname}{cmd:)} specifies the statistic used to compute aggregated values of {it:quantvar} at unit level and within-unit for groups. Available statistics are {it:mean} and {it:median}. The default is equivalent to specifying {cmdab:st:ats(}{it:mean}{cmd:)}. 
{cmdab:st:ats()} requires disaggregated data because {it:mean} and {it:median} would produce the same output with aggregated data by unit (values of {it:quantvar} do not vary in within-unit for different groups). 
If all values of {it:quantvar} are missing for a certain group within a unit, the value of the statistic for the whole unit is automatically imputed.{p_end}

{phang}
{cmdab:thr:incl:(}{it:#}{cmd:)} specifies a threshold z>=0 which determines the level of losses that would be considered when computing FGT indices and  producing Social Welfare Loss curves using Psi_{0} index. {cmdab:thr:incl(}{it:real 0}{cmd:)} is the default.

{phang} 
{cmdab:nog:raph} suppresses display of default graphs.

{phang}
{cmdab:f:ormat:(}{it:%{help format:fmt}}{cmd:)} changes numeric format, the default is {cmdab:f:ormat(}{it:%9.4f}{cmd:).}


{title:Reporting}

{pstd}
Notation: epsilon={c -(}0,1,2,3,4{c )-} is the constant elasticity of the assumed utility function that can be interpreted as a (relative) inequality aversion parameter in Psi_{epsilon} indices.
alpha={c -(}0,1,2,3{c )-} is an inequality aversion parameter in FGT indices. See references below for some further notation and formulae.{p_end}

{pstd} 
{ul:Measures of well-being (monetary) gain/loss associated with segregation:} 

{p 8 12 2} 
{c -} Psi_{c -(}epsilon{c )-}, family of indices to quantify the well-being gain/loss of a group associated with its segregation.

{p 12 12 2} Note that Gamma=Psi_{c -(}0{c )-} measures the monetary gain/loss of a group associated with its segregation.

{pstd}Available only for disaggregated data:

{phang2}
{c -} Omega_{c -(}epsilon{c )-}, the well-being gain/loss of a group due to within-unit status disparities with respect to other groups.

{pmore2} Note that Delta=Omega_{c -(}0{c )-} measures the monetary gain/loss of the group associated with within-unit status disparities with respect to other groups.

{phang2} 
{c -} WAD_{c -(}epsilon{c )-}, total well-being advantage/disadvantage (WAD) of a group: Psi_{c -(}epsilon{c )-} + Omega_{c -(}epsilon{c )-}.

{phang2} 
{c -} seg-EGap, contribution of segregation to the per capita earning gap ratio (EGap=WAD_{c -(}0{c )-}) of the group: Psi_{c -(}0{c )-}/WAD_{c -(}0{c )-}.

{phang2} If option {cmdab:nog:raph} is not specified:

{phang2} 
{c -} Decomposition of the per capita earning gap ratio (EGap) in terms of segregation (Gamma) and within-unit status disparities (Delta). The graph currently displayed is saved to disk under the name {it:grEGap}{cmd:.gph}. 

{pstd} 
{ul:Measures of social welfare loss associated with segregation:} 

{phang2}
{c -} FGT_{c -(}alpha{c )-}, the Foster-Greer-Thorbecke (FGT) family of poverty indices adapted to measure the social welfare loss that the society experiences due to segregation.

{pmore2}
Note that FGT_{c -(}0{c )-} is the headcount ratio, fraction of the population that belongs to groups that have well-being (monetary) losses associated with segregation.

{phang2} If option {cmdab:nog:raph} is not specified:

{phang2}
{c -} WLAS_{c -(}epsilon{c )-}, Social Welfare Loss curves associated with segregation. The graph currently displayed is saved to disk under the name {it:grWLAS}{cmd:.gph}.

{pstd} 
Each group's relative population share is also reported.


{title:Saved results} 

{pstd} 
{cmd:welflossas} stores the following matrices in {cmd:r()}:

{phang2} 
{cmd:r(measures)} : Measures of well-being (monetary) gain/loss associated with segregation

{phang2} 
{cmd:r(xywlas)} : Coordinates of points on the WLAS curves

{phang2} 
{cmd:r(FGT)} : FGT indices
 
{phang2} 
{cmd:r(share)} : Population shares by group


{title:Limits} 

{pstd} 
This program makes use of {cmd:tabulate} to produce a two-way table of frequency counts for the variables {it:unitvar} (rows) and {it:groupvar} (columns). 
The maximum dimension allowed for {it:unitvar} or {it:groupvar} is the maximum row or column dimension for {cmd:tabulate} (see {help limits}). {p_end}


{title:Examples} 

{pstd} {ul:Disaggregated data:}

{phang} . {stata use wlasdata.dta, clear }

{phang} . {stata welflossas occ1990 raceh hw [aw=perwt]}

{phang} . {stata ret list}

{phang} . {stata mat list r(xywlas)}

{phang} . {stata welflossas occ1990 raceh hw [aw=perwt], st(median) thr(15) nog}

{pstd} {ul:Aggregated data I:}

{phang} . {stata use wlasdata.dta, clear }

{pstd}Create a new variable (mhw) containing the weighted mean wage for each distinct occupation

{phang} . {stata gen mhw=. }

{phang} . {stata "qui levelsof occ1990, local(levels)"  }
   
    {cmd:. qui foreach l of local levels {c -(}}
	{cmd:       summarize hw [aw=perwt] if occ1990 == `l', meanonly }
	{cmd:       replace mhw = r(mean) if occ1990 == `l'}
	{cmd:  {c )-}}
		  
{phang} . {stata welflossas occ1990 raceh mhw [aw=perwt], ag}

{pstd} {ul:Aggregated data II:}

{phang} . {stata use wlasdata.dta, clear }

{phang} . {stata welflossas occ1990 raceh [aw=perwt], ag adds callf(wlas2data) callv(mhw) sav(wlas3data) nog}


{title:Author}

{pstd}{browse "https://sites.google.com/site/aliciaperezalonso/": Alicia Pérez-Alonso}
<apereza@ucm.es>{break}
Facultad de Estudios Estadísticos{break}
Universidad Complutense de Madrid{break} 
Avda. Puerta de Hierro s/n, 28040 Madrid, Spain.


{title:References}

{phang}
Del Río, C. and Alonso-Villar, O. (2017), Segregation and Social Welfare: A Methodological Proposal with an Application to the U.S., Social Indicators Research, forthcoming. DOI: 10.1007/s11205-017-1598-0

{phang}
Alonso-Villar, O. and Del Río, C. (2016), 
{browse "http://onlinelibrary.wiley.com/doi/10.1111/roiw.12224/abstract": Local segregation and well-being}, The Review of Income and Wealth. DOI: 10.1111/roiw.12224

{phang}
Del Río, C. and Alonso-Villar, O. (2015),
{browse "http://link.springer.com/article/10.1007/s13524-015-0390-5?wt_mc=email.event.1.SEM.ArticleAuthorAssignedToIssue": The Evolution of Occupational Seggregation in the United States, 1940-2010: Gains and Losses of Gender-Race/Ethnicity Groups}, Demography, vol. 52(3), pp. 967-988. DOI:10.1007/s13524-015-0390-5

{title:Also see}

{p 4 13 2}
{help localseg} if installed; {help dicseg} if installed




