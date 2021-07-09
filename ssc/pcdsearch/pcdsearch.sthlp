{smcl}
{* 10Jun2015}{...}
{hline}
help for {hi:pcdsearch}
{hline}

{title:Title}

{p2colset 5 15 17 2}{...}
{p2col :{hi:pcdsearch} {hline 2}} A string and code search programme to extract code lists from primary care databases {p_end}
{p2colreset}{...}


{title:Syntax}

{p 4 8 2}
{cmd:pcdsearch}
{it:filename}
[{cmd:,} {it:{help pcdsearch##options:options}}]

{p 4 4 2}
where

{p 6 6 2}
{it:filename} the full name, with extension, of the csv or MS Excel file with the strings and codes to be searched for

{synoptset 20 tabbed}{...}
{marker options}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opth pcddir(string)}}Directory where the PCD files to be searched exist
{p_end}
{synopt :{opth filedir(string)}}Directory where the provided csv or MS Excel file exists
{p_end}
{synopt :{opth pcdcodefnm(string)}}File name for the clinical lookup file
{p_end}
{synopt :{opth pcdprodfnm(string)}}File name for the products lookup file
{p_end}


{title:Description}

{p 4 4 2}
{cmd:pcdsearch} aims to facilitate searching the very long lookup files accompanying Primary Care Databases (PCDs) to identify relevant clinical codes
(usually Read codes in the UK) and product codes. The command receives an MS excel file (*.xls or *.xlsx) or a comma separated values file (*.csv) as input,
containing clinical description stub strings (e.g. "asthma"), code stub strings (e.g. Read code stub "H33") and/or product(drug) description stub strings (e.g. "bambuterol").

{p 4 4 2}
The command needs the four strings provided by the options to operate, but an alternative approach is possible. Users can provide the information in globals
before calling {cmd:pcdsearch}, either in code or by editing profile.do. The four globals are pcdsourcepath, pcdoutputpath, pcdcodefilenm and pcdprodfilenm,
in place of options {opt pcddir}, {opt filedir}, {opt pcdcodefnm} or {opt pcdprodfnm}, respectively.

{p 4 4 2}
The {help pcdsearch##rules:search rules} are desribed in detail below, along with examples using Read codes and the Clinical Practice Research Datalink (CPRD)
Gold version lookup files. Identified clinical codes and product lists are appended as additional MS Excel worksheets or saved as separate csv files, depending
on the provided file type. Worksheet names in {it:filename} are irrelevant. If an Ms Excel file the command will always import information from the first sheet.
Variable names are required (the first row is assumed to be variable names) but irrelevant. The order, however, is important and three variables/columns are
expected: (1) Clinical name stubs, (2) Clinical codes, and (3) Product name stubs


{title:Options}

{phang}
{opth pcddir(string)} Directory where the Primary Care Database clinical and product lookup tables are located. Can be text or Stata files.

{phang}
{opth filedir(string)} Directory where the MS Excel or csv file with the search criteria is located.

{phang}
{opth pcdcodefnm(string)} Full name of Primary Care Database clinical lookup file (including extension). Can be in Stata format (*.dta) or a text file. If a text file (i.e. if the file name provided does not have a dta extension),
the file is loaded as delimited to Stata using the {cmd:import} command.

{phang}
{opth pcdprodfnm(string)} Full name of Primary Care Database products lookup file (including extension). Can be in Stata format (*.dta) or a text file. If a text file (i.e. if the file name provided does not have a dta extension),
the file is loaded as delimited to Stata using the {cmd:import} command.


{title:Remarks}

{p 4 4 2}
Test codes are another parameter of PCD analyses (e.g. HbA1c testing) but these tend to be limited to a few dozen codes and search strategies are much less
relevant since the relevant tests are known a-priori.

{p 4 4 2}
When opening csv files, do not double-click to open in MS Excel because codes will not be imported as strings and for example 2326.00 would be imported as 2326. Instead,
use the import option and make sure you ask for all varibles to be imported as strings

{p 4 4 2}
PCD clinical and product files can be Stata or text files

{p 4 4 2}
A tricky issue is the names of the variables of interest in the lookup files. The command is compatible with variable names in CPRD Gold and older CPRD versions. Users
of other databases have to rename the respective variables before using {cmd:pcdsearch} (informative error codes will provide the required variable names).

{p 4 4 2}
Spaces are not allowed in any of the three input fields but searching for phrases is possible (see below).


{marker rules}{...}
{title:Search rules}

{dlgtab:For fields 1 (Clinical name stubs) and 3 (Product name stubs)}

{phang}
{it: Single word, no special characters}: will return all cases that include the stub; e.g. "angin" will return "Ludwig's angina" (Read code J083300) but also "Head-banging" (Read code E273100).

{phang}
{it: Phrase, underscore used to separate words}: will search for an exact phrase; e.g. "ischemic_cardiomyopathy" will search for "ischemic cardiomyopathy", with the same rules as for single word.

{phang}
{it: Phrase, plus sign used to separate words}: will search for all words but not exact phrase; e.g. "alcohol+depend" will return cases where both "alcohol" AND "depend" are found, with the same rules as for single word.

{phang}
{it: Single word, minus sign at start of word/stub}: cases with word/stub to be excluded; e.g. using "splen" and "-hypersplenism" will return cases with "splen" but not any with "hypersplenism" (does not work for with phrases).

{phang}
Generally words/stubs/phrases need to be inputted as lowercase: the respective fields in the lookup files are turned to lowercase to ensure capitalisation of whole words or letters do no lead to omissions.

{phang}
If words/stubs/phrases inputted as capitals: will only be searched as capitals to avoid many false positives; e.g. "UTI" will return "suspected UTI" (Read code 1J4..00) but not "Therapeutic enteroscopy" (Read code 7649.11).

{dlgtab:For field 2 (Clinical codes)}

{phang}
Codes are searched for exactly as inputted, at the start of the respective field. Hence search for "H33" would return H331.11 (Late onset asthma) but not 8H33.00 (Day hospital care).


{title:Example}

{p 4 4 2}
Using globals to define directories and files:

{phang2}{cmd:. global pcdsourcepath "T:\Evan\GPRD\GPRD\Data\"}{p_end}
{phang2}{cmd:. global pcdoutputpath "P:\Evan\GPRD\Mental Health\paper methods\pcdsearch\"}{p_end}
{phang2}{cmd:. global pcdcodefilenm "read_oxmis_20081117.dta"}{p_end}
{phang2}{cmd:. global pcdprodfilenm "products_20081121.dta"}{p_end}
{phang2}{cmd:. pcdsearch asthma.xlsx}{p_end}

{p 4 4 2}
Using options to define directories and files:

{phang2}{cmd:. pcdsearch asthma.csv, pcddir("R:\CPRD2014\Lookups\") filedir("P:\Evan\GPRD\Mental Health\paper methods\pcdsearch\") pcdcodefnm("medical.txt") pcdprodfnm("product.txt")}{p_end}


{title:Authors}

{p 4 4 2}
Evangelos Kontopantelis, Centre for Health Informatics, Institute of Population Health, University of Manchester, e.kontopantelis@manchester.ac.uk


{title:Please cite as}

{p 4 4 2}
Kontopantelis E. pcdsearch: A string and code search programme to extract code lists from primary care databases.


{title:Described in}

{p 4 4 2}
Olier I., Springate D., Reeves D., Ashcroft D., Doran T., Reilly S. and Kontopantelis E. Modelling conditions in a Primary Care Database:
an application to Severe Mental Illness with the Clinical Practice Research Datalink.


{title:Also see}

{p 4 4 2}
help for {help ipdpower}, {help repsample}

