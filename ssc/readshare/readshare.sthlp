{smcl}
{* *! version 0.1  17oct2016}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "readSHARE##syntax"}{...}
{viewerjumpto "Description" "readSHARE##description"}{...}
{viewerjumpto "Options" "readSHARE##options"}{...}
{viewerjumpto "Remarks" "readSHARE##remarks"}{...}
{viewerjumpto "Examples" "readSHARE##examples"}{...}
{title:Title}

{phang}
{bf:readSHARE} {hline 2} Read SHARE data for analysis


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:readSHARE}
{varlist}
[{cmd:,} {it:options}]

{synoptset 15 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt :{opth w:aves(str)}}select the wave(s) from which to extract the data;
default is {cmd:waves(5)}. It is possible to extract data from multiple waves at once by providing wave numbers 
separated by space. {p_end}


{syntab:Data options}
{synopt :{opt descTab}}create a description table for the requested variables; with this option no SHARE data is extracted{p_end}
{synopt :{opt mod:ule(str)}}limit the modules from which variables are extracted; by default all modules are considered{p_end}
{synopt :{opt p:refix(str)}}set prefix for the extracted variables{p_end}
{synopt :{opt wide}}load multiple wave data into wide format; by default data extracted in long format{p_end}
{synopt :{opt imp:utations}}allow extraction of variables from {bf:GV_IMPUTATIONS} module{p_end}
{synopt :{opt cv_r}}keep all observations when loading variables from {bf:CV_R} module{p_end}
{synopt :{opt xt}}load variables from the {bf:XT} module{p_end}
{synopt :{opt mergeBy(str)}}set variables as identifiers for merging data from different modules; by default mergeid is used{p_end} 

{syntab:Data imputations}
{synopt :{opt hh:res(str)}}indicate variables with values present only for the household respondent and impute for all household members {p_end}
{synopt :{opt fin:res(str)}}indicate variables with values present only for the financial respondent and impute for all household members {p_end}
{synopt :{opt fam:res(str)}}indicate variables with values present only for the family respondent and impute for all household members{p_end}
{synopt :{opt l:ong(str)}}indicate variables with values present in earlier waves in case of longitudinal questionnaire{p_end}


{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:readSHARE} is a tool to easily select and read variables from the 
{browse "http://www.share-project.org":SHARE} dataset into a single .dta file.
It also allows for a straightforward automation of typical operations on SHARE variables in particular
imputing observations for various types of questions and extracting longitudinal information 
from previous waves. 

{pstd}
The {varlist} provides variable names to be extracted from SHARE data. The program uses regular expressions 
to select the variables, so it is possible to use wildcards (e.g. ? and * signs) for variable names to be 
extracted. Using this method it is also possible to extract groups of variables.

{pstd}
If a badly specified variable is given as input the program does not produce an error, however
it reports variables which have not been found in the data.
Data from different modules are merged by default by {it:mergeid}.
variables from the {bf:GV_IMPUTATIONS, CV_R} and {bf:XT} modules are extracted only after explicitly
declaring appropriate options.

{pstd}
While {bf:readSHARE} cleans the memory every time it is used, {bf:addSHARE} can be used to add additional variables 
to those already existing in memory. {bf:addSHARE} has the same syntax and options as {bf:readSHARE}. 

{title:Setup}

{pstd}
For the program to run it needs to have specified directories (as globals) for the description table and SHARE data.

{pstd}
The description table is a Stata .dta file containing variable names, module names
and variable labels for all the variables present in SHARE datasets in all waves. Creating the description table 
is a necessary requirement to run {helpb readSHARE} and {helpb addSHARE}. 

{pstd}
The description table can be created out of SHARE data using the command {helpb createSHAREDesc} and needs to be saved
in a user specified location. 

{pstd}
It is important to keep the given directory structure and module names as in the official SHARE release. 

{pstd}
Example:

{phang2}{cmd: global w1Dir "${sData}/sharew1_rel5-0-0_ALL_datasets_stata/"}{p_end}
{phang2}{cmd: global w2Dir "${sData}/sharew2_rel5-0-0_ALL_datasets_stata/"}{p_end}
{phang2}{cmd: global w3Dir "${sData}/sharew3_rel5-0-0_ALL_datasets_stata/"}{p_end}
{phang2}{cmd: global w4Dir "${sData}/sharew4_rel5-0-0_ALL_datasets_stata/"}{p_end}
{phang2}{cmd: global w5Dir "${sData}/sharew5_rel5-0-0_ALL_datasets_stata/"}{p_end}
{phang2}{cmd: global w6Dir "${sData}/sharew6_rel0_ALL_datasets_stata/"}{p_end}

{phang2}{cmd: global shareDesc "${sData}/shareDescStata.dta"}{p_end}

{marker options}{...}
{title:Options}

{dlgtab:Main}
{phang}
{opt waves()} indicates which wave of SHARE to extract the data from. To read data from multiple waves it is possible to provide
multiple numbers in the option, separated by space. By default the data is loaded into a long format with an additional variable 
{it: wave} created containing the wave number for each observation. It is possible to load the data into wide format using the {bf:wide} option.

{dlgtab:Data options}
{phang}
{opt descTab} generates variable description table, does not load the data. 
Creates a table indicating which variables are extracted with full variable names, labels and specifying module and wave information.

{phang}
{opt imputations} allows loading of multiple imputations from the imputed data files. 
By default it is not possible to extract variables from the {bf:GV_IMPUTATIONS} module. 
This module contains multiple imputations (5 per respondent) for each {it:mergeid}. The default set up does not allow imputed 
variables to be extracted to avoid erroneous use of multiple observations. The user needs to specify that imputed variables are to be extracted.
The variable {it:implicat} identifying each imputation is automatically added to the list of extracted variables.

{phang}
{opt mergeBy} selects variables by which modules are merged, {it: mergeid} is set as default.

{phang}
{opt module} extracts variables only for selected modules. This option might be useful to selectively draw 
variables which may be present in more than one module (e.g. {it:bmi} in {bf:GV_HEALTH} and {bf:GV_IMPUTATIONS})

{phang}
{opt prefix} adds prefix for all selected variables with the exception of {it:mergeid} and {it:implicat}.

{phang}
{opt cv_r} keeps all observations from the {bf:CV_R} module when extracting a variable from that module.
By default the program keeps only data for persons eligible for the SHARE interview. End-of-life interviews 
are excluded by default. It is possible to load them using the {bf:xt} option.
Using this option allows to read observations for all household members for variables from the {bf:CV_R}. 

{phang}
{opt wide} loads data from multiple waves in the wide format if multiple waves are selected in the {bf:waves()} option.
When no {bf:prefix()} is provided wave number is indicated with w {bf:w}{it:wave}{bf:_} prefix for each of the extracted 
variables. When the {bf:prefix()}
option is not empty the prefix is constructed as {bf:prefix_}{it:wave}{bf:_}.

{dlgtab:End-of-life interview data}
{phang}
{opt xt} allows to load data from the {bf:XT} module. It also provides the possibility to merge this data with other modules. 
When using data from the end-of-life interview it is problematic to work with {bf:XT} variables form multiple waves since 
for a given wave the observations exist only in the {bf:CV_R} and {bf:XT} modules. Loading longitudinal data is problematic
due to the fact that the {it:mn101_} indicating whether the respondent received a longitudinal version of 
the questionnaire is not specified in the wave in which the end-of-life interview was conducted.

{phang}
Merging with other data is possible only in the wide format when using the {bf:xt} option. In this way
values from previous waves can be assigned to the {bf:XT} respondent in the wave of the end-of-life interview.
Including imputations is also possible.

{dlgtab:Data imputation}
{phang}
{opt hhres} assigns {bf: household respondent's} answers to all household members. 
Useful for household-level questions answered only by the {bf:household respondent}.

{phang}
{opt famres} assigns {bf: family respondent's} answers to all household members. 
Useful for family level questions answered only by the {bf:family respondent}.

{phang}
{opt finres} assigns {bf: financial respondent's} answers to all household members. 
Useful for family level questions answered only by the {bf:financial respondent}.
For wave 1 does not assign family respondent's answers if separate finances are indicated. 

{phang}
{opt long} assigns values from earlier waves if the respondent was given the longitudinal version 
of the questionaire and the specific question is asked only in the baseline version. 
New values are extracted from earlier waves only in case of missing values in the specified wave. 
An additional variable is created ({it:long_info_*}) indicating whether the variable had non-missing 
values in each wave.


{marker remarks}{...}
{title:Remarks}

{pstd}
The programs are dedicated to work with the Survey of Hearlth, Ageing and Retirement in Europe (SHARE) data:

{pstd}
Börsch-Supan, A., Brandt, M., Hunkler, C., Kneip, T., Korbmacher, J., Malter, F., Schaan, B., Stuck, S. and Zuber, S. (2013). {browse "https://academic.oup.com/ije/article-lookup/doi/10.1093/ije/dyt088":Data Resource Profile: The Survey of Health, Ageing and Retirement in Europe (SHARE)}. International Journal of Epidemiology DOI: 10.1093/ije/dyt088.

{pstd}
The SHARE dataset can be obtained from {browse "http://www.share-project.org":the official SHARE website.} 
The current version of the programs use the 6.0.0 release version of the SHARE data. 

{pstd}
In case of questions or errors please contact: 

{pstd}
Mateusz Najsztub: {it:mnajsztub@cenea.org.pl}.


{marker examples}{...}
{title:Examples}

{pstd}Extract all variables from PH module in wave 5.{p_end}
{phang2}{cmd:. readSHARE *, w(5) mod(ph)}{p_end}

{pstd}Extract some variables from wave 4 and save them with prefix w4_.{p_end}
{phang2}{cmd:. readSHARE interview *_resp mergeidp hh0* co2*, w(4) p(w4_)}{p_end}

{pstd}Extract variables specifically from the gv_imputations module.{p_end}
{phang2}{cmd:. readSHARE interview bmi weight height, w(5) imp mod(gv_imputations)}{p_end}

{pstd}Add CO207_ variable from wave 5 and impute answers for household members.{p_end}
{phang2}{cmd:. addSHARE interview country , w(5) hh(co207)}{p_end}

{pstd}Add CF001_ variable from wave 5 and impute missing values from earlier waves.{p_end}
{phang2}{cmd:. addSHARE cf001, w(5) long(cf001)}{p_end}

{pstd}Read CF001_ with country and age variables from waves 1-5 (wo. 3) and impute missing values from 
earlier waves. Load the data in long format.{p_end}
{phang2}{cmd:. readSHARE country age_int cf001, w(1 2 4 5) long(cf001)}{p_end}

{pstd}Read CF001_ with country and age variables from waves 1-5 (wo. 3) and impute missing values from 
earlier waves. Load the data in wide format.{p_end}
{phang2}{cmd:. readSHARE country age_int cf001, w(1 2 4 5) long(cf001) wide}{p_end}

{title:Working with {bf:XT} data}

{pstd}Read the {bf:XT} data from waves 2,4 and 5.{p_end}
{phang2}{cmd:. readSHARE xt*, w(2 4 5) xt}{p_end}
{pstd}Add {it:cf001_} from earlier waves with values imputed from earlier waves for each wave.{p_end}
{phang2}{cmd:. addSHARE cf001, w(1 2 4 5) long(cf001) xt}{p_end}
{pstd}Add {it:sp008_} from earlier waves and impute values for non-family respondents.{p_end}
{phang2}{cmd:. addSHARE sp008, fam(sp008) w(1 2 4 ) prefix(fam_) xt}{p_end}


