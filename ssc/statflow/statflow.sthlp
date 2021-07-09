{smcl}
{* Dec 31st 2018}
{hline}
Help for {hi:statflow}
{hline}

{title:Description}

{p}Given an Excel spreadsheet with columns A, B, C, and D titled “logic”, “var”, “stat” and “value”, respectively,
{cmd:statflow} replaces the “value” column with the requested statistic for the observations in the dataset that fit the condition expressed in “logic”.
This allows for the creation of dynamically updating custom tables and flowcharts.

{title:Syntax}

{p 2 4}{it:Set up a flowchart: }
{break}{cmd:statflow template} {help using} {it:"/path/to/file.xlsx"} , [replace]

{p 2 4}{it:Fill it out, then get all the requested statistics: }
{break}{cmd:statflow} {help using} {it:"/path/to/file.xlsx"} [{help if}] [{help in}]

{title:Author}

Benjamin Daniels
bbdaniels@gmail.com

{title:Contributing}

{p}{bf: statflow} is open for development on {browse "https://bbdaniels.github.io/stata-code/statflow/":GitHub}.
Submit bugs and feature requests {browse "https://github.com/bbdaniels/statflow/issues":here}.
If you like {bf:statflow}, be sure to visit my {browse "http://bbdaniels.github.io":homepage}
and {browse "https://gist.github.com/bbdaniels/a3c9f9416f1d16d6f3c6e8cf371f1d89":Stata boilerplate code}.{p_end}
