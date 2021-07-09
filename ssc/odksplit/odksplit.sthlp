{smcl}
{* *! version 2.0.0  22jan2019}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "odksplit##syntax"}{...}
{viewerjumpto "Description" "odksplit##description"}{...}
{viewerjumpto "Options" "odksplit##options"}{...}
{viewerjumpto "Remarks" "odksplit##remarks"}{...}
{viewerjumpto "Examples" "odksplit##examples"}{...}
{title:Title}

{phang}
{bf:odksplit} {hline 2} is a module to label the variables, assign corresponding value labels, and split and label multiple response variables generated from ODK.

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:odksplit}
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt s:urvey}}The name of the XLSform, including the path{p_end}
{synopt:{opt d:ata}}The name of the data file, including the path{p_end}
{synopt:{opt l:abel}}The language specified in the label column in ODK XLSform. For example, if the label column is 'label:English', write English. Do not specify label if the column title is just 'label'. {p_end}
{synopt:{opt m:ultiple}}To split and label multiple responses{p_end}
{synopt:{opt sing:le}}To assign value label to single response variables{p_end}
{synopt:{opt var:label}}To label variables{p_end}
{synopt:{opt c:lear}}To clear any data in memory{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
If ODK or SurveyCTO is used for data collection, the multiple response variables are downloaded as string variables.
{cmd:odksplit} can be used to split those variables to create dummy variables as well as label the dummy variables. Additional options allow to do the other labeling excercises.

{pstd}
If "SurveyCTO sync" is used to download data, and the 'Export select_multiple responses as series of 1/0 columns?' option was ticked, the dummy variables are already created in the dataset.
However, {cmd:odksplit} does this again deleting the existing variables. {cmd:odksplit} uses the XLSform to identify the 'select_multiple' variables, and take the value labels from the choices sheet. {cmd:odksplit} was initially developed to work with the multiple response variables, however, additional options were added based on user feedback.


{marker remarks}{...}
{title:Remarks}

{pstd}
This program will clear any data in memory. Therefore, the program asks whether you really want to clear data from memory. Write ok in the command line and press enter if you want to proceed.
Otherwise, write cancel, and press enter to cancel the program. This will not work if the variable names include the group names as prefix.

{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt survey} specifies the XLSform name where 'survey' and 'choices' sheets exist.

{phang}
{opt data} specifies the data file 

{phang}
{opt label} The language specified in the label column in ODK XLSform. For example, if the label column is 'label:English', write English.  Do not specify label if the column title is just 'label'. 

{phang}
{opt multiple} splits and labels the multiple responses.

{phang}
{opt single} assigns value labels to the single response variables.

{phang}
{opt varlabel} assigns variable labels.

{phang}
{opt clear} clear any data from memory

{marker examples}{...}
{title:Examples}

{phang}{cmd:. odksplit, survey("X:\Projects 2018\Fieldwork\Tools\SurveyCTO files\Phase one_v1.xlsx") data("X:\Projects 2017\Fieldwork\Data\Data\raw\Phase one data.dta") label(English) multiple single varlabel clear}{p_end}

{phang}{cmd:. odksplit, s("X:\Projects 2018\Fieldwork\Tools\SurveyCTO files\Phase one_v1.xlsx") d("X:\Projects 2017\Fieldwork\Data\Data\raw\Phase one data.dta") multiple clear}{p_end}

{phang}{cmd:. odksplit, s("X:\Projects 2018\Fieldwork\Tools\SurveyCTO files\Phase one_v1.xlsx") d("X:\Projects 2017\Fieldwork\Data\Data\raw\Phase one data.dta") single clear}{p_end}

{phang}{cmd:. odksplit, s("X:\Projects 2018\Fieldwork\Tools\SurveyCTO files\Phase one_v1.xlsx") d("X:\Projects 2017\Fieldwork\Data\Data\raw\Phase one data.dta") var}{p_end}


{marker author}{...}
{title:Author}

{pstd}Mehrab Ali{p_end}
{pstd}For questions or suggestions e-mail at mehrabbabu@gmail.com.{p_end}
