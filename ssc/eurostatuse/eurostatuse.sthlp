{smcl}
{* *! version 1.0.0  24apr2015}{...}
{viewerjumpto "Syntax" "eurostatuse##syntax"}{...}
{viewerjumpto "Dialogue box" "eurostatuse##dialogue"}{...}
{viewerjumpto "Description" "eurostatuse##description"}{...}
{viewerjumpto "Options" "eurostatuse##options"}{...}
{viewerjumpto "Remarks" "eurostatuse##remarks"}{...}
{viewerjumpto "Examples" "eurostatuse##examples"}{...}
{viewerjumpto "Install" "eurostatuse##install"}{...}
{viewerjumpto "Authors" "eurostatuse##authors"}{...}
{title:Title}

{phang}
{bf:eurostatuse} {hline 2} Import Eurostat data

{marker syntax}{...}
{title:Syntax}

{p 8 8 2}
{cmdab:eurostatuse} {it:table_name} [{cmd:,} {it:options}]

{p 8 8 2}
{it:table_name} is the Eurostat data file to be downloaded, unzipped and processed.

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{bf:long}}creates output in the long format (e.g. time in rows) {p_end}
{synopt:{bf:[no]label}}drops the label variables {p_end}
{synopt:{bf:[no]flags}}drops the flag variables {p_end}
{synopt:{bf:[no]erase}}saves the original .tsv file in the active folder {p_end}
{synopt:{bf:save}}saves output in a Stata data (.dta) file {p_end}
{synopt:{bf:clear}}clears data in memory {p_end}

{syntab:Select data}
{synopt:{bf:start()}}defines start period {p_end}
{synopt:{bf:end()}}defines end period {p_end}
{synopt:{bf:geo()}}set a list of countries to be kept {p_end}
{synopt:{bf:keepdim()}}limits by other dimensions {p_end}
{synoptline}
{p2colreset}{...}

{marker dialogue}{...}
{title:Dialogue box}

{pstd}
{stata db eurostatuse}{p_end}

{pstd}
You can access the dialogue box by clicking on the link above or just typing: {cmd: db eurostatuse}

{marker description}{...}
{title:Description}

{pstd}
{cmd:eurostatuse} imports data from the Eurostat repository into Stata. It also provides
information on the data set, downloads labels, separates flags and values, implements
the reshape to long format, and fixes time formats. 

{pstd}
{it:table_name} should include just one Eurostat data file. You should only 
specify the name (case sensitive), not the .tsv or .gz extension. Eurostat refers to the table 
name as 'product code', indicated between brackets after the titles in 
the navigation tree.

{pstd}
Eurostat navigation tree: {browse "https://ec.europa.eu/eurostat/data/database"}.

{pstd}
See also: {browse "https://ec.europa.eu/eurostat/data/bulkdownload"} 
and {browse "https://ec.europa.eu/eurostat/estat-navtree-portlet-prod/BulkDownloadListing"}.

{marker options}{...}
{title:Options}
{dlgtab:Main}

{phang}
{opt long} creates output in the long format (time in rows). Default is wide. Depending on the size of the data set this may take a while. {p_end}

{phang}
{opt [no]erase} saves the original .tsv file in the active folder. {p_end}

{phang}
{opt [no]label} removes the label variables. The codes may be self-explanatory. {p_end}

{phang}
{opt [no]flags} removes the flags Eurostat uses to comment on the data. {p_end}

{phang}
{opt save} saves output in a Stata data (.dta) file. {p_end}

{phang}
{opt clear} clears data memory before proceeding. {p_end}

{dlgtab:Select data}

{phang} These options significantly reduce processing time of long data requests.

{phang}
{opt start()} defines the start period (e.g. 2008, 2010Q3, 2012M09). If not sure
about the time code, download the full table first for a small sample depending
on geo() or keepdim(). {p_end}

{phang}
{opt end()} defines the end period (as above). You do not have to specify both
end and start period. {p_end}

{phang}
{opt geo()} selects data by {it:country_abbreviations} (see below). For an 
aggregate, use area codes (EA, EU28 etc.) for a list of member states and other
countries, use EU 2-digit codes separated by a space and don't use quotes.{p_end}

{phang}
{opt keepdim()} selects by other dimensions. Multiple dimensions have to be 
separated by a semicolon but need not be named. Just enter the desired values 
within a dimension, each separated by a space. The ordering of the dimensions is 
not important and you should not use quotes for the values. {p_end}

{marker remarks}{...}
{title:Remarks}

{pstd}
The Eurostat repository at {browse "https://ec.europa.eu/eurostat/data/database"} 
contains a large number of EU policy data sets, generally time series (monthly, quarterly, annually).
Each series is stored in a separate file that also contains a string-date variable and header
with information about the series.  {p_end}

{pstd}
{cmd:eurostatuse} imports data series into a Stata dataset.
 The output is a file with the same name as the data set. {p_end}

{p 3 3} The following country abbreviations are used by Eurostat and can be used 
as {it:country_abbreviations} in {hi:geo()}.

{p 3}Table: Geographical regions and country abbreviations {p_end}
{col 4}{dup 66:{c -}}
{col 4}Aggregates
{col 4}{bf:EU28}{col 10}European Union (28 countries)
{col 4}{bf:EU}{col 10}European Union (changing composition)
{col 4}{bf:EA19}{col 10}Euro area (19 countries)
{col 4}{bf:EA}{col 10}Euro area (changing composition)

{col 4}EU Member States
{col 4}{bf:BE}{col 10}Belgium
{col 4}{bf:BG}{col 10}Bulgaria
{col 4}{bf:CZ}{col 10}Czech Republic
{col 4}{bf:DK}{col 10}Denmark
{col 4}{bf:DE}{col 10}Germany
{col 4}{bf:EE}{col 10}Estonia
{col 4}{bf:IE}{col 10}Ireland
{col 4}{bf:EL}{col 10}Greece
{col 4}{bf:ES}{col 10}Spain
{col 4}{bf:FR}{col 10}France
{col 4}{bf:HR}{col 10}Croatia
{col 4}{bf:IT}{col 10}Italy
{col 4}{bf:CY}{col 10}Cyprus
{col 4}{bf:LV}{col 10}Latvia
{col 4}{bf:LT}{col 10}Lithuania
{col 4}{bf:LU}{col 10}Luxembourg
{col 4}{bf:HU}{col 10}Hungary
{col 4}{bf:MT}{col 10}Malta
{col 4}{bf:NL}{col 10}Netherlands
{col 4}{bf:AT}{col 10}Austria
{col 4}{bf:PL}{col 10}Poland
{col 4}{bf:PT}{col 10}Portugal
{col 4}{bf:RO}{col 10}Romania
{col 4}{bf:SI}{col 10}Slovenia
{col 4}{bf:SK}{col 10}Slovakia
{col 4}{bf:FI}{col 10}Finland
{col 4}{bf:SE}{col 10}Sweden
{col 4}{bf:UK}{col 10}United Kingdom

{col 4}Other countries
{col 4}{bf:IS}{col 10}Iceland
{col 4}{bf:LI}{col 10}Liechtenstein
{col 4}{bf:NO}{col 10}Norway
{col 4}{bf:CH}{col 10}Switzerland
{col 4}{bf:ME}{col 10}Montenegro
{col 4}{bf:TR}{col 10}Turkey
{col 4}{bf:US}{col 10}United States
{col 4}{dup 66:{c -}}

{marker examples}{...}
{title:Examples}

{phang}
{cmd:. eurostatuse} une_ltu_a, noflags nolabel long geo(BE DE FR) {p_end}

{phang}
{cmd:. eurostatuse} namq_10_gdp, noflags start(2000Q1) keepdim(CLV_PCH_PRE ; SCA ; B1GQ P3 P51G) {p_end}


{marker install}{...}
{title:Install}

{pstd}
Download the following file: eurostatuse.ado and put it in your personal ado 
folder (by default, on Windows the folder is C:\ado\personal\, on OS X it is found
within the Stata folder in the library). Put it in the subfolder e\ 
to keep the folder orderly. Stata will automatically search this directory for 
programs on the next run and have the command ready when you call it. {p_end}

{pstd}
If you use Windows you also need to install 7-zip into the program files directory
(C:\Program Files\7-Zip\7zG.exe). If you install it elsewhere, the ado needs to 
be changed - you can do that. Mac users don't need to do anything. A Linux shell 
should also be straightforward to add but it is currently not in the ado.

{pstd}
You can download 7-zip from {browse "http://www.7-zip.org/download.html"}. {p_end}


{marker authors}{...}
{title:Authors}

{pstd}
	Sebastien Fontenay{break}
	UCL-ESL IRES{break}
	sebastien.fontenay@uclouvain.be

{pstd}
	Sem Vandekerckhove{break}
	HIVA-KU Leuven{break}
	sem.vandekerckhove@kuleuven.be
{p_end}
