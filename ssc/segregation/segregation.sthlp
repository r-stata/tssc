{smcl}
{* February 2014}{...}
{hline}
help for {hi:segregation (Version 2)}{right:Carlos Gradín (February 2014)}
{hline}

{title:Segregation indices with optional segregation curve; using either individual data or aggregated data}

{title:Description}

{cmd:dicseg} estimates several segregation indices across units (e.g. occupations, schools, ...) in a two-group context (i.e. whites vs. nonwhites, men vs. females, ...).

{p 8 13 2}
For more details: {help dicseg} if installed; 


{cmd:localseg} estimates several local and overall segregation indices across units (i.e. occupations, schools, ...) in a multigroup context (e.g. several racial groups)
as proposed by Alonso-Villar and Del Rio, Local versus Overall Segregation Measures, Mathematical Social Sciences, 2010.

{p 8 13 2}
For more details: {help localseg} if installed.

Both modules can use either individual data or data aggregated by units.

Optionally, both modules draw the corresponding segregation curves.

There is an ancillory file for both commands: {net get segregation.pkg}


They require: Stata version 10 and {help matsort} from SSC

. {stata ssc install matsort}	(if not installed)



{title:Author}

{p 4 4 2}{browse "http://webs.uvigo.es/cgradin": Carlos Gradín}
<cgradin@uvigo.es>{break}
Facultade de CC. Económicas{break}
Universidade de Vigo{break} 
36310 Vigo, Galicia, Spain.




