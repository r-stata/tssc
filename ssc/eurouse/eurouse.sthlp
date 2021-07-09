{smcl}
{* *! version 1.0.0 10jan2016}{…}
{cmd:help eurouse}
{hline}

{title:Title}
{phang}
{bf: eurouse -- Download data from the Eurostat bulk facility}

{title:Syntax}
{p 8 17 2}
{cmd:eurouse}
{it:eurostat_code} 
[ 
{cmd:,}
{cmd:clear}
]

{title:Description}

{pstd}{cmd:eurouse} automatically downloads and imports these the Eurostat datasets into Stata using the {browse "http://ec.europa.eu/eurostat/estat-navtree-portlet-prod/BulkDownloadListing":Eurostat bulk facility}, which contains about 5,800 datasets from more than thirty European countries, some datasets also include the United States and Japan. Eurostat updates the datasets twice a day. 
The user only needs to type the dataset code ({it:eurostat_code}). {p_end}

{pstd}{cmd:eurouse} The list with all the series can be found at the Eurostat data tree: {browse "http://ec.europa.eu/eurostat/data/database":here} or download {browse "http://ec.europa.eu/eurostat/estat-navtree-portlet-prod/BulkDownloadListing?sort=1&file=table_of_contents_en.pdf":here} the PDF. {p_end}

{title:Options}

{phang}{opt clear} specifies that you want to clear Stata's memory before loading 
the new dataset.

{title:Examples} 

{pstd}Import unemployment rate series of the Eurozone founding fathers {p_end}
{phang2}{cmd:  eurouse ei_lmhr_m, clear} {p_end}
{phang2}{cmd:  keep if inlist(geo, "AT", "BE", "DE", "ES", "FI") | inlist(geo, "FR", "EL", "IE", "IT", "LU", "NL", "PT")} {p_end}
{phang2}{cmd:  encode geo, gen(geo_num)} {p_end}
{phang2}{cmd:  xtset geo_num time} {p_end}
{phang2}{cmd:  tsline ei_lmhr_m_18, by(geo) tlabel(1983m8(134)2015m8, angle(45)) } {p_end}

{title:Author}
{phang}David Leite Neves, ISEG-Universidade de Lisboa{break} 
dneves@iseg.ulisboa.pt{p_end} 
