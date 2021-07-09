{smcl}
{* 21jul2015}{...}
{viewerjumpto "Syntax" "ucspsplit##syn"}{...}
{viewerjumpto "Description" "ucspsplit##des"}{...}
{viewerjumpto "Note on response times" "ucspsplit##nrt"}{...}
{viewerjumpto "Note on visits and its interaction with response times" "ucspsplit##vis"}{...}
{viewerjumpto "Note on DAC-events" "ucspsplit##dac"}{...}
{viewerjumpto "Note on number of clicks and double clicks" "ucspsplit##cli"}{...}
{viewerjumpto "Note on scrolling and window size" "ucspsplit##scr"}{...}
{viewerjumpto "Note on key-events" "ucspsplit##key"}{...}
{viewerjumpto "Note on blur-events" "ucspsplit##blu"}{...}
{viewerjumpto "Examples" "ucspsplit##exa"}{...}
{viewerjumpto "Further reading" "ucspsplit##fur"}{...}
{viewerjumpto "Authors" "ucspsplit##aut"}{...}
{viewerjumpto "Version" "ucspsplit##ver"}{...}


{title:Title}

{p 4 4 2}{hi:ucspsplit} {hline 2} Extracts paradata from a string variable produced by the universal client-side paradata script (UCSP version 6).


{marker syn}	
{title:Syntax}

{p 4 8 2}{cmd:ucspsplit} {it:{help varlist}} [{it:{help if}}] [{cmd:,} {it:options}]


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{p2coldent :{opt v:isits(integer)}}up to how many visits shall be processed, default == 1 only the most recent visit will be processed.{p_end}

{p2coldent :{opt gen:erate(string)}}what paradata to extract from varname, default is "all"{p_end}
{synopt :{opt (vsts)}}number of page visits. The first visit has a value of "0", and is incremented on each revisit.{p_end}
{synopt :{opt (dac)}}one-time activation of the probe (Do-Answer-Check, short: DAC) on the survey page.{p_end}
{synopt :{opt (ms1stclk)}}time from page load to the first click in milliseconds.{p_end}
{synopt :{opt (ms2ndlstclk)}}time from page load to the second-to-last click in milliseconds (time to answer){p_end}
{synopt :{opt (mslstclk)}}time from page load to the last click, that is the submit button, in milliseconds (page viewing time){p_end}
{synopt :{opt (nclk)}}number of clicks{p_end}
{synopt :{opt (ndblclk)}}number of double clicks (depends on the system){p_end}
{synopt :{opt (winx)}}window width in pixels{p_end}
{synopt :{opt (winy)}}window height in pixels{p_end}
{synopt :{opt (scrollx)}}maximum width of scrolling in pixels{p_end}
{synopt :{opt (scrolly)}}maximum height of scrolling in pixels{p_end}
{synopt :{opt (ms1stkey)}}time from page load to the first keyboard input in milliseconds{p_end}
{synopt :{opt (mslastkey)}}time from page load to the last keyboard input in milliseconds{p_end}
{synopt :{opt (cntblur)}}number of blur-events (left the survey window){p_end}
{synopt :{opt (msblur)}}duration of the blur-events in milliseconds{p_end}
{synoptline}


{marker des}
{title:Description}

{p 4 4 2}{cmd:ucspsplit} turns online survey paradata which is stored in a string into ready-to-use variables with meaningful names.
The program works on data which is collected and stored by the universal client-side paradata script (UCSP).
For example, it can prepare the paradata from the GESIS Panel. 
The program extracts all or selected paradata from the string and creates all necessary new variables which can then be used in further analyses. 
The UCSP script is a paradata capture tool written in JavaScript by Lars Kaczmirek which can be implemented in online survey software and which captures a rich set of paradata.


{marker nrt}
{title:Note on response times}

{p 4 4 2}Researchers might wonder why there are three different variables for response times.
This section explains the different concepts of the three variables.

{p 4 4 2}The variable ms1stclk is the number of milliseconds from page load to the first click on the page. 
That time reflects the processes of orientation on the page, reading time of the question and time for generating the answers. 

{p 4 4 2}The variable ms2ndlstclk measures milliseconds from page load to the second-to-last click. 
Ideally, the second-to-last click is the last answer, because the last click is the click on the "submit"-button. 
Thus, this time corresponds to the answering time.

{p 4 4 2}The variable mslstclk provides the milliseconds from the page load to the last click. 
The last click can only be the "submit"-button, therefore, this variable provides the viewing time of the page.

{p 4 4 2}Many survey software programs offer a variable that contains the server-side time stamps. But these measures are much less exact in operationalizing response times.
This can be considered as a fourth variable. 


{marker vis}
{title:Note on visits and its interaction with response times}

{p 4 4 2}The variable visit is usually zero. On every occasion in which a respondent returns to a page which he or she has seen earlier, visits is increased by one.
The most common behavior that increases visits is when a respondent clicks a previous-button in a survey because he or she wants to return to the previous page to either re-read something or to change the answer. 
For this reason, each visit stores its own full set of paradata. 
Technically, each new visit is stored in the beginning of the string on the left side. 
This means that the paradata describing the first visit is the part of the string on right side. 
{cmd:ucspsplit} allows you to extract the visit you are interested in or can also process all visits at once. 
When no option is given {cmd:ucspsplit} extracts only the paradata from the last visit. 
Beware: If you analyze response times you may find that respondents who have visits higher than zero show lower response times on their last visit compared to respondents with a single visit. 
The reason is simply because these respondents have already spend some time on the same page on earlier visits. 
Therefore, you could consider to add the response times from all visits or to only consider the first visit of all respondents or to drop those respondents depending on your research question. 


{marker dac}
{title:Note on DAC-events}

{p 4 4 2}The DAC (do-answer check) is a feature which is implemented in many survey software tools. 
This type of soft edit check validates the answer and if the respondent did not provide an answer the page is shown again with a message reminding respondents to answer. 
The DAC is commonly triggered in cases when respondents do not answer at all and simply click "next". 
UCSP was designed to capture DAC-events in the software EFS. 
If all data is zero it might be the case that the survey did not implement any do-answer checks at all.


{marker cli}
{title:Note on number of clicks and double clicks}

{p 4 4 2}Ideally, the amount of clicks would match the amount of required answers plus one (for the submit button). 
Cases of fewer clicks might indicate item-nonresponse. 
Cases of more clicks might hint at random clicks in non-sensitive areas of the survey or changes in answers. 
Researchers should be aware that even if the number of clicks matches the ideal number of clicks respondents could still have item-nonresponse
(e.g., when two answers are expected and the respondent changes one answer and does not answer the second question resulting in a total of two clicks). 
Double clicks should only occur rarely because there is no technical reason to use a double click in an online survey. 
Double clicks are sometimes seen with people who have difficulties in navigating with the mouse or might be purely incidental.


{marker scr}
{title:Note on scrolling and window size}

{p 4 4 2}A best practice in survey design is to keep necessary scrolling to a minimum. 
Therefore, extensive scrolling usually hints at problems in the interaction with the survey. 
Respondents who scroll might use a smaller screen or a smaller window than anticipated. 
UCSP stores the single event with the maximum scrolling distance which occurs during a page visit. 
This means that if a respondent scrolled twice only the scrolling with the higher amount of pixels is stored. 
Together with window size, researchers can assess whether a respondent was able to see all necessary information of the survey page at a glance.


{marker key}
{title:Note on key-events}

{p 4 4 2}Values greater than zero in msfirstkey and/or mslastkey indicate that respondents used the keyboard. 
This might be to navigate the survey or to enter verbatim answers. 
In some implementations of UCSP an additional variable might store the actual sequence of keys that have been pressed. 
However, this key-trail variable is not processed by {cmd:ucspsplit}.


{marker blu}
{title:Note on blur-events}

{p 4 4 2}The feature to capture blur-events should be considered experimental. 
Especially, there is no guarantee that this variable captures every occasion on which a respondent leaves the survey window. 
The technical implementation of this detection method is complicated and does not work equally well in all browsers. 
Newer browsers are known to deny this functionality and several browsers ask respondents whether they would allow the JavaScript to run at all.


{marker exa}
{title:Examples}

{p 4 4 2}Extract and prepare all available data from the last visit{p_end}
{p 8 4 2}{cmd:. ucspsplit varpara}{p_end}

{p 4 4 2}Get ms1stclk and mslstclk of first visit{p_end}
{p 8 4 2}{cmd:. ucspsplit varpara, v(1) gen(ms1stclk mslstclk)}{p_end} 
	
{p 4 4 2}Get ms1stclk and mslstclk of first two visits if dispcode==31 (complete){p_end}
{p 8 4 2}{cmd:. ucspsplit varpara if dispcode1==31, v(2) gen(ms1stclk mslstclk)}{p_end}


{marker fur}
{title:Further reading}

{p 4 4 2}For a description of the available paradata in the GESIS panel see:{p_end}
{p 4 4 2}Kai Weyandt, Bella Struminskaya , Ines Schaurer{p_end}
{p 4 4 2}Last updated 23 June 2014 (Version 1.0){p_end}
{p 4 4 2}GESIS Panel Online Paradata. Documentation{p_end}
{p 4 4 2}https://dbk.gesis.org/dbksearch/download.asp?db=E&id=53578{p_end}

{p 4 4 2}For a thorough explanation on the conceptual difference between various client-side and server-side response time measures see:{p_end}
{p 4 4 2}Kaczmirek, L. (2009). Human-survey interaction: usability and nonresponse in online surveys.{p_end}
{p 4 4 2}Cologne: Herbert von Halem Verlag.{p_end}
{p 4 4 2}Download from http://kaczmirek.de/ebook2008/ page 69f.{p_end}

{p 4 4 2}Large datasets containing online survey paradata are available from:{p_end}
{p 4 4 2}GESIS Panel, http://www.gesis-panel.de{p_end}

	
{marker aut}
{title:Authors}

{p 4 4 2} Kai Willem Weyandt, GESIS - Leibniz Institute for the Social Sciences, kai.weyandt@gesis.org

{p 4 4 2} Lars Kaczmirek, GESIS - Leibniz Institute for the Social Sciences, lars.kaczmirek@gesis.org


{marker ver}
{title:Version}

{p 4 4 2}Version 1.0 - 3th July 2015.

