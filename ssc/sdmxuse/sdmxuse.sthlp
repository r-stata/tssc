{smcl}
{* *! version 2.0  June 2018}{...}
{viewerjumpto "Syntax" "sdmxuse##syntax"}{...}
{viewerjumpto "Description" "sdmxuse##description"}{...}
{viewerjumpto "Options" "sdmxuse##options"}{...}
{viewerjumpto "Examples" "sdmxuse##examples"}{...}
{viewerjumpto "Remarks" "sdmxuse##remarks"}{...}
{viewerjumpto "Author" "sdmxuse##author"}{...}

{title:Title}

{phang}
{bf:sdmxuse} {hline 2} Import data from statistical agencies using the SDMX standard

{pstd}
Available providers: {break}
- European Central Bank (ECB) {break}
- Eurostat (ESTAT) {break}
- International Monetary Fund (IMF) {break}
- Organisation for Economic Co-operation and Development (OECD) {break}
- United Nations Statistics Division (UNSD) {break}
- World Bank (WB) {p_end}

{marker syntax}{...}
{title:Syntax}

{p 8 8 2}
{cmdab:sdmxuse} dataflow {it:provider}

{p 8 8 2}
{cmdab:sdmxuse} datastructure {it:provider}, dataset({it:identifier})

{p 8 8 2}
{cmdab:sdmxuse} data {it:provider}, dataset({it:identifier})

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{bf:attributes}}download attributes (e.g. observations' flags) {p_end}
{synopt:{bf:clear}}clears data in memory {p_end}

{syntab:Select data}
{synopt:{bf:dimensions()}}allows customizing requests for data {p_end}
{synopt:{bf:start()}}defines start period {p_end}
{synopt:{bf:end()}}defines end period {p_end}

{syntab:Reshape data}
{synopt:{bf:timeseries}}reshapes dataset to obtain time series {p_end}
{synopt:{bf:panel()}}reshapes dataset to obtain a panel {p_end}

{syntab:Merge DSD}
{synopt:{bf:mergedsd}}merges data (time series) and Data Structure Definition {p_end}
{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:sdmxuse} imports data from statistical agencies using the SDMX standard. Available providers are the European Central Bank (ECB), Eurostat (ESTAT),
the International Monetary Fund (IMF), the Organisation for Economic Co-operation and Development (OECD), the United Nations Statistics Division (UNSD) and the World Bank (WB).

{pstd}
You can get a complete list of publicly available datasets from a provider by specifying the resource: dataflow.
Then, you can obtain the Data Structure Definition (DSD) of a given dataset by specifying the resource: datastructure.
Finally, you can download the dataset by specifying the resource: data.

{pstd}
You can also find the dataset identifier on some providers' website. Eurostat, for instance, refers to the dataset identifier as 'product code',
indicated between brackets after the titles in the navigation tree: {browse "http://ec.europa.eu/eurostat/data/database"}

{marker options}{...}
{title:Options}
{dlgtab:Main}

{phang}
{opt attributes} downloads attributes that give additional information about the series or the observations but do not affect the dataset structure itself (e.g. observations' flags). {p_end}

{phang}
{opt clear} clears data memory before proceeding. {p_end}

{dlgtab:Select data}

{phang}
{opt dimensions()} allows customizing requests for data. Time series can be retrieved based on the value they take for each dimension.
Dimensions should be separated by a dot "." character and must respect the order specified in the Data Structure Definition.
A dimension can be left empty if all values are requested. Multiple values for a dimension are separated by a plus "+" sign. {p_end}

{phang}
{opt start()} defines the start period. You can specify the exact value (e.g. 2010-01) or just the year (e.g. 2010). {p_end}

{phang}
{opt end()} defines the end period. {p_end}

{dlgtab:Reshape data}

{phang}
{opt timeseries} reshapes the dataset so that each series is stored in a single variable. Variables' names are made of dimensions' values. {p_end}

{phang}
{opt panel(panelvar)} reshapes the dataset into a panel. {it:panelvar} must be specified, it will often be the geographical dimension.  {p_end}

{dlgtab:Merge DSD}

{phang}
{opt mergedsd} merges the data (time series) and the Data Structure Definition - particularly useful when dimensions' codes are not transparent (e.g. HRV is the ISO ALPHA-3 code for Croatia). {p_end}

{marker examples}{...}
{title:Examples}

{phang}
{cmd:. sdmxuse} dataflow OECD, clear {p_end}

{phang}
{cmd:. sdmxuse} datastructure OECD, clear dataset(EO) {p_end}

{phang}
{cmd:. sdmxuse} data OECD, clear dataset(EO) dimensions(FRA+DEU.GDPV_ANNPCT.A) start(1993) {p_end}

{phang}
{cmd:. sdmxuse} data OECD, clear dataset(EO) dimensions(FRA+DEU.GDPV_ANNPCT.A) start(1993) timeseries {p_end}

{phang}
{cmd:. sdmxuse} data OECD, clear dataset(EO) dimensions(.GDPV_ANNPCT+CPIH.A) panel(location) {p_end}

{phang}
{cmd:. sdmxuse} data OECD, clear dataset(EO) dimensions(.GDPV_ANNPCT.A) mergedsd

{marker remarks}{...}
{title:Remarks}

{pstd}
The author is grateful to Robert Picard and Nicholas J. Cox for allowing him to reproduce their code of the package {cmd:moss} to deal with multiple occurrences of substrings. {p_end}

{pstd}
For queries larger than 30,000 cells, Eurostat will post the file to a different repository. 
{cmd:sdmxuse} can accommodate this but processing time will be longer. {p_end}

{marker author}{...}
{title:Author}

{pstd}
	Sebastien Fontenay{break}
	Universite catholique de Louvain{break}
	sebastien.fontenay@uclouvain.be {p_end}
