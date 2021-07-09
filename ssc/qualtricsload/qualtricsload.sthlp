{smcl}
{* *! version 0.1.0  20feb2019}{...}
{viewerjumpto "Syntax" "qualtricsload##syntax"}{...}
{viewerjumpto "Description" "qualtricsload##description"}{...}
{viewerjumpto "Options" "qualtricsload##options"}{...}
{viewerjumpto "Remarks" "qualtricsload##remarks"}{...}
{viewerjumpto "Examples" "qualtricsload##examples"}{...}
{title:Title}

{phang}
{bf:qualtricsload} {hline 2} Download survey results from Qualtrics server and optionally convert to Stata dataset


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:qualtricsload}
{it:survey_id}
[{cmd:,} {it:options}]

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}

{synopt:{opt api:token(token)}}Qualtrics API token{p_end}
{synopt:{opt data:center(dsid)}}Qualtrics datacenter identifier{p_end}

{synopt:{opt saving(fn [, replace])}}Save output dataset as {it:fn}; default is the name of the survey in Qualtrics{p_end}
{synopt:{opt replace}}Replace existing dataset (redundant with {bf:saving}() suboption){p_end}
{synopt:{opt stcmd}}Convert downloaded dataset to Stata format using Stat-Transfer (if installed){p_end}

{syntab:Qualtrics API options}

{synopt:{opt format(data_format)}}Format for downloaded dataset. Default is 'spss'{p_end}
{synopt:{opt nodisp:layorder}}Do not include display-order (randomization) variables{p_end}
{synopt:{opt time:zone(timezone_id)}}Time zone for date/time variables{p_end}
{synopt:{opt start:date(datetime)}}Only export responses recorded after the specified date. 
See {browse "https://api.qualtrics.com/docs/dates-and-times":Dates and Times} for more information on the date and time format{p_end}
{synopt:{opt end:date(datetime)}}Only exports responses recorded before the specified date. {p_end}
{synopt:{opt new:line(string)}}Specify newline delimiter for the export (only applies XXX); default is '\n'{p_end}
{synopt:{opt comma}}Use a comma as a decimal separator instead of a period{p_end}
{synopt:{opt uselab:els}}Instead of exporting the recode value for the answer choice, export the text of the answer choice. For more information on recode values, see 
{browse "https://www.qualtrics.com/support/survey-platform/survey-module/question-options/recode-values/":Recode Values}{p_end}
{synopt:{opt seen:unansrecode(string)}}Recode seen but unanswered questions with this value{p_end}
{synopt:{opt multi:unansrecode(string)}}Recode seen but unanswered choices for multi-select questions. Default is to use value in {bf:seenunansrecode}(){p_end}

{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:qualtricsload} downloads survey responses directly from Qualtrics using the Qualtrics API and optionally translates the dataset to Stata format.

{pstd}
Your Qualtrics account must have API access enabled, and you must obtain an API token.  See 
{browse "https://www.qualtrics.com/support/integrations/api-integration/overview#GeneratingAnAPIToken":Generating an API Token}
for instructions on checking access and obtaining a token from Qualtrics.

{pstd}
You also need to know your Qualtrics datacenter id, which is usually the two or three letters and a number that preceed "qualtrics" in the URL for your Qualtrics login.  See 
{browse "https://www.qualtrics.com/support/integrations/api-integration/finding-qualtrics-ids#LocatingtheDatacenterID":Locating the Datacenter ID} for help finding it.

{pstd}
There are several ways to specify your API Token and Datacenter ID. The program will look for them in the following locations (in this order): 
(1) as options with each use of the {bf:qualtricsload} command; 
(2) by setting system environment variables QUALTRICS_API_TOKEN and QUALTRICS_DATA_CENTER; or 
(3) in a configuration file whose location is specified by environment variable QUALTRICS_CONFIG_FILE. 
The configuration file should be a plain-text file containing the following lines:

{p 10 10 0}QUALTRICS_API_TOKEN = {it:api token value}{p_end}
{p 10 10 0}QUALTRICS_DATA_CENTER = {it:datacenter id value}{p_end}


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt apitoken(token)} specifies your Qualtrics API Token.  
Although you can specify your API key using this option, long term it is better practice to keep it instead in a configuration file as described above. 
This increases security (your API key is equivalent to your Qualtrics password), and also allows for easier updating if you regenerate your API key.{p_end}

{phang}
{opt datacenter(dsid)} specifies your Qualtrics datacenter identifier. 
As with the API key, use of {opt qualtricsload} is simplified if you specify this in a configuration file as described above.{p_end}

{phang}
{opt saving(fn [, replace])} specifies the name of the output dataset. By default this will be the same as the name of the survey in Qualtrics.
If {opt stcmd} is specified, this will be a Stata dataset; otherwise it will have the format specified in the {opt format} option.{p_end}

{phang}
{opt replace} indicates that an existing file may be replaced. This is equivalent to the {opt replace} suboption of the {opt saving}() option.{p_end}

{phang}
{opt stcmd} indicates that the downloaded dataset be converted to Stata format using {browse "https://stattransfer.com/":Stat-Transfer}. 
This option requires that Stat-Transfer be installed and the 
{help stcmd} Stata command is installed and configured.  
See {stata ssc describe stcmd:ssc describe stcmd}.{p_end}

{dlgtab:Qualtrics API options}

{phang}
These options correspond to the API options described here: 
{browse "https://api.qualtrics.com/reference/create-response-export-new":https://api.qualtrics.com/reference/create-response-export-new}.

{phang}
{opt format(data_format)} specifies the format for the downloaded dataset. 
Default is 'spss'; other options are 'csv', 'tsv', 'json', or 'ndjson'.  
If the {opt stcmd} option is specified, this option is ignored: 
the dataset is downloaded to a temporary file in SPSS format and converted to Stata.{p_end}

{phang}
{op}t nodisp:layorder} indicates that "display order" variables should not be included. 
For surveys that include randomization, these variables indicate which elements were displayed in what order. By default these variables are included in the download.{p_end}

{phang}
{opt time:zone(timezone_id)} indicates the time zone for date/time variables (including StartDate, EndDate, RecordedDate).  
By default the program will attempt to use Java system's default time zone, which should be your local time zone.{p_end}

{phang}
{opt start:date(datetime)} indicates that only responses recorded (i.e., RecordedDate) after the specified date should be included.  
Specify {it:datetime} as "yyyy-mm-ddThh:mm:ss±HH:MM", where ±HH:MM is the offset from UTC; 
e.g., "2019-01-17T14:47:00-05:00" would indicate 2:47pm on January 17, 2019 in the Eastern US time zone (i.e., UTC minus 5 hours).  
See {browse "https://api.qualtrics.com/docs/dates-and-times":Dates and Times} for more information on the date and time format in Qualtrics, 
or {browse "https://en.wikipedia.org/wiki/ISO_8601":https://en.wikipedia.org/wiki/ISO_8601} for far more than you ever wanted 
to know about the ISO 8601 standard for representing dates and times.{p_end}

{phang}
{opt end:date(datetime)} indicates that only responses recorded before the specified date should be included. {p_end}

{phang}
{opt new:line(string)} specify a newline delimiter for the export; default is '\n'.{p_end}

{phang}
{opt comma} indicates that a comma be used as the decimal separator instead of a period. This has no effect for spss/stcmd downloads.{p_end}

{phang}
{opt uselab:els} indicates that the text of the answer choices, rather than the numerical values. Has no effect for spss/stcmd downloads.  
For more information on recode values, see 
{browse "https://www.qualtrics.com/support/survey-platform/survey-module/question-options/recode-values/":Recode Values}{p_end}

{phang}
{opt seen:unansrecode(string)} indicates that "seen but unanswered" questions should be recoded with this value, rather than system missing.  
Must be an integer between -2,147,483,648 and 2,147,483,647; 
due to limitations in the Qualtrics export, it may not be an {help missing:extended missing} value.{p_end}

{phang}
{opt multi:unansrecode(string)} indicates that "seen but unanswered" multi-select questions should be recoded with this value, 
rather than system missing or the value specified by {opt seenunansrecode}(). {p_end}


{marker remarks}{...}
{title:Remarks}

{pstd}
To get started, you should:{p_end}

{p 10 14 5}
(1)  Determine whether your Qualtrics account allows API access and obtain your API Token.  
To do so, click on the silhouette in the top-right corner of your account; Select "Account Settings"; Click "Qualtrics IDs" on the navigation bar; in the box labeled "API", click "Generate Token".  
{bf:Important note:} if you already have an API token, do not re-generate it unless you want to invalidate the existing token.
See 
{browse "https://www.qualtrics.com/support/integrations/api-integration/overview#GeneratingAnAPIToken":Generating an API Token}.
{p_end}

{p 10 14 5}
(2)  Determine the survey ID of the Qualtrics survey you want to download.  Survey IDs are available from the "Qualtrics IDs" page, or can be inferred from the URL used to edit or take the survey; they have the format SV_xxxxxxxxxxxxxxx, where 'xxxxxxxxxxxxxxx' is a random set of letters and numbers. 
{p_end}

{p 10 14 5}
(3)  Download your data!

{marker examples}{...}
{title:Examples}

{pstd}Download Qualtrics survey SV_BD08KxeNaYZVaX2 and convert to Stata dataset using Stat-Transfer, using the Qualtrics study name as the filename:{p_end}

{phang}{cmd:. qualtricsload SV_BD08KxeNaYZVaX2 , stcmd}{p_end}


{pstd}Download Qualtrics survey SV_JvsVR3qTrHbPxP4, specifying Qualtrics API Token and datacenter, and convert to Stata dataset named "mydata.dta":

{phang}{cmd:. qualtricsload SV_JvsVR3qTrHbPxP4 , stcmd apitoken(csxGqLIRzHmogKP2UjPwfOxRsiTk002jvvgFly3t) datacenter(az1) saving(mydata, replace)}{p_end}


{marker copyright}{...}
{title:Copyright}

{p 4 4 2}See {help qualtricsload copyright}.


{marker author}{...}
{title:Author}

Nicholas J. G. Winter
Department of Politics
University of Virginia
nwinter [at] virginia.edu

