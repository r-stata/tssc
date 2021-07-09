{smcl}
help for {cmd:qogmerge}{right:also see: {helpb qoguse}}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col :Merging Quality of Government (QoG) data}{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 17 2}{cmd:qogmerge} {it:country} {it:time} [{cmd:using} {it:filepath|{help filename}}]{cmd:,}
{opt v:ersion()} {opt f:ormat()} [{it:{help merge}_options}]



{pstd}{ul:{it:country}} is either (a) a variable holding the names of the
countries {ul:OR} (b) a single country name.

{pstd}{ul:{it:time}} is either (a) a variable holding the years in the survey
{ul:OR} (b) a single 4-digit year.


{title:Description}

{pstd}The QoG-data is a dataset containing aggregate statistics of the quality of government of
various countries worldwide measured at various points in time. It is provided by
{it:University of Gothenburg: The Quality of Government Institute}.

{pstd}
{cmd:qogmerge} merges the latest release of {it:Quality of Government (QoG) data} 
to the data stored in the memory, using {it:country} and {it:year} as a key. To make this possible, the
user must specify country and year in specific format. The {it:country} must be specified either in 
the "numeric ISO-3166 format" or as "full English country names" as defined by the International
Standardization Organization. {it:Year} must be specified in 4-digit-numeric-format.

{pstd}Usually both, country and time, will be specified by listing the variables in the data loaded in memory in which 
countries and years are stored. If data is based on only {ul:one country} or on a {ul:single year}, specify only this 
country/year instead of a country-variable or a time-variable (see {help qogmerge##examples:Examples} below)

{pstd} When you not want to automatically download the latest version from the internet, specify the location of the 
QoG-data on your computer with {opt using}. You can specify the path on your computer or a certain filename. 
{cmd:qogmerge} detects whether a {ul:folder} or a {ul:file} is given.

{pstd}If you specify the {ul:folder} on your computer containing the QoG-data, the filename
will be set automatically based on your {opt v:ersion()} and {opt f:ormat()}. Therefore, you need the latest
QoG-data available through {helpb qoguse} or {hi:http://www.qog.pol.gu.se/data/}. 


{title:Options}

{phang}
{opt v:ersion()} defines which version of the QoG-data you want to use. The alternatives are {it:Basic} ({opt bas}), {it:Standard} 
({opt std}), {it:OECD} ({opt oecd}), {it:Expert Survey} ({opt exp}), {it:EQI} ({opt eqi}) and {it:EU Regional} ({opt eureg}). 
Each version has different formats which you have to specify:

{phang}
{opt f:ormat()} defines the different datasets. For the {it:Basic}, {it:Standard} and {it:OECD} version you can choose between 
Cross-Section Data ({opt cs}) and Time-Series Data ({opt ts}). For the {it:Expert Survey} and {it:EQI} data you can choose 
individual ({opt ind}) or aggregate ({opt agg}) formats. The {it:EU Regional} data is available in three formats: 
Long ({opt long}), NUTS 1 ({opt wide1}) and NUTS 2 ({opt wide2}).). 

{pstd}
Merging the {it:Expert Survey} is only possible for Country-Level ({opt agg}) data. It is not possible to merge format({opt ind}) 
since this data is based on a web-survey by country experts and has individual experts, not country-year, as the unit of analysis.

{pstd}
Time information (year) is only available for format()-options: {opt ts}, {opt long}, {opt wide1}, {opt wide2} and for {it:EQI} 
data with format({opt ind}). If you specify a time-variable (or a single year) for any other dataset, this information will be ignored.


{title:other Options}

{pstd}{it:All {help merge}-options} are allowed with {it:qogmerge}. If
{cmd:keep()} is not specified, {cmd:keep(1 3)} is default.

{marker examples}
{title:Examples}

Example 1: Merge QoG-data to the World Values Survey (WVS)

{pstd} Assume you have already downloaded and unzipped the data of the
World Values Survey (WVS). We load into memory all rounds of the WVS

{phang2}{cmd:. use WVS_Longitudinal_1981_2014_stata_v2015_04_18, clear}

{pstd}In this file the country names are stored in variable S009. However,
the information in this file given in ISO 3166 Alpha-2 format, which
is not suitable for {cmd:qogmerge}. We use the user defined program
{net "describe http://fmwww.bc.edu/RePEc/bocode/k/kountry":kountry}
by Rafal Raciborski to convert the information stored in
S009 into the correct format:

{phang2}{cmd:. kountry S009, from(iso2c)}

{pstd} This command creates the variable NAMES_STD holding the
standardized English country names. You can now use {cmd:qogmerge}, in this case with S020 holding year-information.
Here we add all variables from QoG to the WVS

{phang2}{cmd:. qogmerge NAMES_STD S020, version(std) format(ts)}

{pstd}although it is recommended to apply the option {cmd:keepusing({varlist})} to reduce the size of the new data set.

Example 2: Merge QoG to the first wave of European Social Survey (ESS)

{phang2}{cmd:. use ESS1e06_5.dta, clear}{p_end}
{phang2}{cmd:. kountry cntry, from(iso2c)}{p_end}
{phang2}{cmd:. qogmerge NAMES_STD, version(bas) format(cs)}{p_end}


Example 3: Merge QoG and ESS for Sweden only

{phang2}{cmd:. use ESS1e06_5.dta if cntry == "SE", clear}{p_end}
{phang2}{cmd:. qogmerge Sweden inwyr, version(oecd) format(ts)}{p_end}


Example 4: Merge QoG to round II of the European Quality of Life Survey (EQLS)

{phang2}{cmd:. use analytical_file_8_sept_2008_compact_file.dta, clear}{p_end}
{phang2}{cmd:. kountry country_abbr, from(iso2c)}{p_end}
{phang2}{cmd:. qogmerge NAMES_STD 2007, version(bas) format(ts)}{p_end}


Example 5: With local data
{phang}-with filename:{p_end}
{phang2}{cmd:. qogmerge {it:country} {it:time} using "C:/Data/qog_std_ts_jan17.dta", version(std) format(ts)}{p_end}

{phang}-with folder:{p_end}
{phang2}{cmd:. qogmerge {it:country} {it:time} using "C:/Data/", version(std) format(ts)}{p_end}


{title:Author}

{pstd}Christoph Thewes, University of Potsdam, thewes@mailbox.org{p_end}

{pstd}The QoG-data is provided by {it:University of Gothenburg: The Quality of Government Institute}{p_end}
{pstd}({it:Thanks to William Lisowski and Daniel Klein for useful help}){p_end}
{pstd}({it:Code-snippet from {net "describe http://fmwww.bc.edu/RePEc/bocode/c/confirmdir":confirmdir}. By Dan Blanchette})


{title:Also see}

{psee} Help: {helpb merge}, {helpb qoguse} {it:(if installed)}, {helpb kountry} {it:(if installed)}

{psee} Online:
{net "describe http://fmwww.bc.edu/RePEc/bocode/k/kountry":kountry}

{psee} Source: {hi:http://www.qog.pol.gu.se}

{psee} Data: {hi:http://www.qog.pol.gu.se/data/}

{title:Version}
{psee}2.1.2: 25/05/2020

