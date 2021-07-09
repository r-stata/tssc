{smcl}
{* Dec 31st 2018}
{hline}
Help for {hi:makeid}
{hline}

{title:Description}

{p 2 4}{cmd:makeid} creates a unique ID for every observation in the dataset. These IDs are coded and nested, based on strata-type variables which uniquely identify the observations.
{p_end}

{p 2 4}For example, given a variable list such as {it:country state district name}, a unique ID is returned for every observation such that:
{break}{break}
1. Country code in the ID is fully unique {break}
2. State code in the ID is unique within country {break}
3. District code in the ID is unique within country and state {break}
4. Each name has a unique ID within country, state, and district. {break}
{p_end}

{p 2 4}
{cmd:makeid} prefixes each ID with the first letter of the project name, as a best practice to prevent against automatic conversion to numbers (in Excel for example).
{p_end}

{title:Syntax}

{p 2}{cmd:makeid} {help varlist} , {opth gen:erate(newvarname)} {opt project(Project Name)}

{title:Demo}

{p 2 2}
{stata sysuse auto.dta , clear:sysuse auto.dta , clear} {break}
{stata makeid foreign make , gen(uniqueid) project(Demo):makeid foreign make , gen(uniqueid) project(Demo)} {break}
{stata isid uniqueid , sort:isid uniqueid , sort} {break}
{stata list foreign make uniqueid in 1/5:list foreign make uniqueid in 1/5} {break}
{stata list foreign make uniqueid in 53/57:list foreign make uniqueid in 53/57} {break}
{p_end}

{title:Author}

Benjamin Daniels
bbdaniels@gmail.com

{title:Contributing}

{p}{bf: makeid} is open for development on {browse "https://bbdaniels.github.io/stata-code/makeid/":GitHub}.
Submit bugs and feature requests {browse "https://github.com/bbdaniels/makeid/issues":here}.
If you like {bf:makeid}, be sure to visit my {browse "http://bbdaniels.github.io":homepage}
and {browse "https://gist.github.com/bbdaniels/a3c9f9416f1d16d6f3c6e8cf371f1d89":Stata boilerplate code}.{p_end}
