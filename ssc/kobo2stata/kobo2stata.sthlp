{smcl}
{* *! version 1.05 Felix Schmieding 14/06/2020}{...}
{title:Title}

{phang}
{cmd:kobo2stata} {hline 2} Create labelled Stata datasets from KoboToolbox


{marker syntax}{...}
{title:Syntax}

{p 8 10 2}
{cmd:kobo2stata}
{cmd:using}
{it:{help filename}}{cmd:,}
{opt xlsform(xlsfile)} 
[{it:options}]


{synoptset 32 tabbed}{...}
{synopthdr:Mandatory items}
{synoptline}
{synopt:{opt using} {it:{help filename}}}Name and location of the .xlsx file
that contains the Kobo raw data.{p_end}
{break}
{synopt:{opt xlsform(xlsfile)}}Name and location of the .xls file
that contains Kobo's XLSForm. This file must contain a 'survey' and a 'choices' tab.{p_end}
{synoptline}

{break}
{synoptset 32 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt:{opt surveylabel(columnheader)}}Header of the column in the XLSForm's 
'survey' tab that contains the applicable variable labels. 
Specifying this item is optional - if nothing is specified, 'label' is assumed.{p_end}
{break}
{synopt:{opt choiceslabel(columnheader)}}Header of the column in the XLSForm's 
'choices' tab that contains the applicable value labels. 
Specifying this item is optional - if nothing is specified, 'label' is assumed.{p_end}
{break}
{synopt:{opt dropnotes}}Drop variables identified as 'note'-type in the XLSForm (this type of variable 
contains no data).{p_end}
{break}
{synopt:{opt usenotsave}}This will load the imported dataset into Stata‘s active memory rather 
than saving to drive. Please note this option is not recommended for (hierarchical) 
Kobo datasets with multiple tabs in the raw data file - for these, only the last tab would be 
loaded to memory.{p_end}
{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:kobo2stata} combines the information contained in the raw data file and the 
XLSForm, and creates labelled Stata datasets. The main focus is on applying the variable labels 
and value labels in the XLSForm to the data. There are also some secondary functions, e.g. the removal of HTML tags from labels. 
Please read the important remarks below on generating the input files in KoboToolbox.


{marker remarks}{...}
{title:Important remarks on generating input files in KoboToolbox}

{pstd}
For kobo2stata to work properly, the two input files - i.e. the data file and XLSForm - 
{cmd:must be exported from KoboToolbox} as follows:

{phang2}o  For the raw data file, go to Kobo's 'Downloads' and then 'Data' section, 
then select export type 'XLS' and value/header format 'XML values and headers'. 
Deactivate the 'include groups in headers' checkbox. 
Then click 'export' and save the .xlsx file that is generated.{p_end}
{phang2}o  For the XLSForm, go to Kobo's 'Downloads' and then 'Form' section, 
then select the '...' symbol at the top right ("more actions"), and select 'Download XLS'.{p_end}


{marker remarks}{...}
{title:Further remarks}

{pstd}
Kobo2stata will only consider numeric values found in the "name" column of your XLSForm's choices tab. 
String values will be ignored, and will result in missing value labels for single-choice variables, and missing 
variable labels as well as missing value labels for multiple-choice binary variables. 

{pstd}
Kobo2stata creates the Stata datasets in the same location as the original raw data file (except if the 'usenotsave' option is specified, in which case no dataset is saved).

{pstd}
Kobo2stata can handle raw Kobo datasets with hierarchical data / multiple tabs. 
No restructuring or merging is carried out, kobo2stata will create the same 
number of Stata datasets as there are tabs in the .xlsx file. 

{pstd}
The surveylabel() and choiceslabel() options allow the user to specify the 
relevant label columns in the XLSForm's 'survey' and 'choices' tabs, respectively.
By default, Kobo uses the column header 'label', and this is what kobo2stata assumes if the 
options are not specified by the user. However, some Kobo applications - in particular multilingual ones, 
may use other headers (e.g. 'Label:English').

{pstd}
Kobo allows non-exclusive numeric values in value labels, but Stata does not. 
For example, answer choices "0-red", "0-blue", "0-green", "1-yellow" (such non-exclusive codes are sometimes applied in multiple-choice exams, 
where all incorrect answers carry a value of zero). While all different answer choices 
will be displayed separately in Kobo, Stata cannot differentiate between the different types of zeroes. 
Hence, if your XLSForm's choices tab contains non-exclusive values for a given label set, your Stata dataset will contain only the last 
label found for the duplicate value (i.e. in the above example, all zeroes would be labelled "green").

{pstd}
Kobo puts no length limitations on variable names and value label names, but Stata limits them to 32 characters. 
Any variable names or value label names with more than 32 characters in your Kobo data
(or more than 29-30 characters in the case of select_multiple items) will remain 
unlabelled in the Stata dataset created.


{marker examples}{...}
{title:Examples}

{pstd}
Create Stata dataset(s) from a raw dataset and accompanying XLSForm:
{p_end}
{phang2}{cmd}
. kobo2stata using "C:/mydata/kobosurveydata.xlsx", xlsform("C:/mydata/aDyQEvcRVs9re5L.xls")
{txt}

{pstd}
Same as above, but with non-standard column headers specified in the XLSForm:
{p_end}
{phang2}{cmd}
. kobo2stata using "C:/mydata/kobosurveydata.xlsx", xlsform("C:/mydata/aDyQEvcRVs9re5L.xls") 
surveylabel("Label::English") choiceslabel("Label::English")
{txt}


{marker author}{...}
{title:Author}

{pstd}Felix Schmieding{p_end}
{pstd}For questions or suggestions, e-mail kobo2stata@gmail.com{p_end}
{pstd}(v1.05){p_end}
