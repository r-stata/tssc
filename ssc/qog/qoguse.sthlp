{smcl}
help for {cmd:qoguse}{right:also see: {helpb qogmerge}}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col :Using Quality of Government (QoG) data} {p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 12 2}
{opt qoguse}
[{varlist}]
{ifin}
{cmd:,}
{opt v:ersion()}
{opt f:ormat()}
[{opt y:ears()}
{opt clear}]


{title:Description}

{pstd}The QoG-data is a dataset containing aggregate statistics of the quality of government of
various countries worldwide measured at various points in time. It is provided by
{it:University of Gothenburg: The Quality of Government Institute}.

{pstd}{cmd:qoguse} loades the most recent release of the {it:Quality of Government (QoG) datasets} from the
internet into memory. If you don`t need the complete dataset, you can opt for specific variables with [{help varlist}] 
and/or years with the option {opt y:ears}. 

{title:Options}

{phang}
{opt v:ersion()} defines which version of the QoG-data you want to use. The alternatives are {it:Basic} ({opt bas}), {it:Standard} ({opt std}), {it:OECD} ({opt oecd}), 
{it:Expert Survey} ({opt exp}), {it:EQI} ({opt eqi}) and {it:EU Regional} ({opt eureg}). Each version has different formats which you have to specify:

{phang}
{opt f:ormat()} defines the different datasets. For the {it:Basic}, {it:Standard} and {it:OECD} version you can choose between Cross-Section Data ({opt cs}) and Time-Series Data 
({opt ts}). For the {it:Expert Survey} and {it:EQI} data you can choose individual ({opt ind}) or aggregate ({opt agg}) formats. The {it:EU Regional} data is available in three formats: 
Long ({opt long}), NUTS 1 ({opt wide1}) and NUTS 2 ({opt wide2}).

{title:other Options}

{phang}
{opt y:ears}({help numlist}) specifies the different years to be kept in the data. You can use a {help numlist} 
to specify the years, which must be in 4-digit-format (e.g. {opt y:ears(1990 1995/1997 2002)}). 
This option is only available with format()-options: {opt ts}, {opt long},  {opt wide1}, {opt wide2} and for {it:EQI} data with format({opt ind}).

{phang}
{opt clear} specifies that it is okay to replace the data in memory,
even though the current data have not been saved to disk.


{title:Examples}

{phang}{cmd:. qoguse}, version(bas) format(cs) clear

{phang}{cmd:. qoguse} ccode year aid_*, version(std) format(ts) clear	{space 5} // large file!

{phang}{cmd:. qoguse}, version(eureg) format(wide2) y(1990 1995/1997 2002) clear

{phang}{cmd:. qoguse}, v(exp) f(agg) clear


{title:Author}

{pstd}Christoph Thewes, University of Potsdam, thewes@mailbox.org{p_end}

{pstd}The QoG-data is provided by {it:University of Gothenburg: The Quality of Government Institute}{p_end}
{pstd}({it:Thanks to William Lisowski and Daniel Klein for useful help}){p_end}


{title:Also see}

{psee} Help: {helpb use}, {helpb qogmerge} {it:(if installed)}

{psee} Source: {hi:http://www.qog.pol.gu.se}

{psee} Data: {hi:http://www.qog.pol.gu.se/data/}

{title:Version}
{psee}2.1.2: 25/05/2020








