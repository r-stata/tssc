{smcl}
{* *! version 1.0.0  08FEB2014}{...}
{cmd:help irscharities}
{hline}

{title:Title}

{hi:irscharities {hline 2}}{tab}IRS Recognized Tax Exempt Organizations

{title:Syntax}

{p 4 4 4}{cmd:irscharities} , {cmdab:sa:ve(}{it:string}{opt )} [ {cmdab:st:ate(}{it:string}{opt )} {opt nteen:fix} {cmdab:rep:lace} ] {p_end}
{p 12 12 12} where {opt st:ate} is the state's two character US postal code abbreviation {p_end}

{title:Description}

{p 4 4 4}{cmd:irscharities} is a convenience program that will pull the SOI Exempt Organizations Business Master File Extract (EO BMF) for the specified state and build a Stata data file.  This program will clear any data currently in memory;
if you would like to retain the dataset in memory please see {help preserve} and {help restore} for additional information.{p_end}

{title:Options}

{p 4 4 4}{opt save} is a required option used to save the dataset created by {cmd:irscharities}.{p_end}

{p 4 4 4}{opt state} is currently a required option but will be optional in future releases.  It takes the two letter state abbreviation as its argument.  The state code is used to identify the state where the exempt organizations of interest are located.  {it:Future releases will include capability to read/parse the region and area codes as well}.{p_end}

{p 4 4 4}{opt nteen:fix} Several of the NTEE Activity codes use a combination of alphanumeric characters to identify the primary purpose/activity of the organization.  These codes replace the first string character with the corresponding number in the alphabet (e.g., A-Z == 1-26).  The following two characters were typically numeric, however several codes have been reassigned to unused numeric values in cases where the last two characters included a string character.  These are: {p_end}

{col 8}Original{col 20}Code{col 60}New Value {break}
{col 8}A6A{col 20}Opera{col 60} 171{break}
{col 8}A6B{col 20}Singing, Choral{col 60} 172{break}
{col 8}A6C{col 20}Music Groups, Bands, Ensembles{col 60} 173{break}
{col 8}A6E{col 20}Performing Arts Schools{col 60} 174{break}
{col 8}G9B{col 20}Surgery{col 60} 797{break}
{col 8}H9B{col 20}Surgery Research{col 60} 897{break}
{col 8}N6A{col 20}Golf{col 60}1459{break}

{p 4 4 4} More importantly, this option will replace other undocumented string characters in number positions with 0.  {p_end}

{p 4 4 4}{opt replace} is an optional argument used to replace an existing dataset with the same name that was specified in {opt:save}.{p_end}

{title:Examples}{marker examples}
{p 8 8 8} Get Mississippi data without fixing string characters in the NTEE codes. {p_end}
{p 12 12 12} {stata irscharities, sa(MSdata.dta) st(ms) rep} {p_end}
{break}
{p 8 8 8} Get Rhode Island data and fix string characters in the NTEE codes. {p_end}
{p 12 12 12} {stata irscharities, sa(RIeobmf) state(ri) nteenfix}{p_end}

{title:Notes}
{p 12 12 12}{hi: When installing this program, make sure the dictionary file is installed in the same directory as the .ado file.}{p_end}
{p 4 8 8}For additional information on the codes please see {browse "http://www.irs.gov/pub/irs-soi/eobk13.txt": IRS File Specification}{p_end}

{title: Author}
{p 8 8 8} William R. Buchanan, Ph.D. {break}
Strategic Data Fellow {break}
{browse "http://mde.k12.ms.us":Mississippi Department of Education} {break}
BBuchanan at mde [dot] k12 [dot] ms [dot] us
