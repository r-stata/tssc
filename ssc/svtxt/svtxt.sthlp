{smcl}
{* *! version 1.0 30 Apr 2018}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "svtxt##syntax"}{...}
{viewerjumpto "Description" "svtxt##description"}{...}
{viewerjumpto "Options" "svtxt##options"}{...}
{viewerjumpto "Remarks" "svtxt##remarks"}{...}
{viewerjumpto "Examples" "svtxt##examples"}{...}
{title:Title}

{phang}
{bf:svtxt} {hline 2} save text, chapter and sections to log, without additonal logging noise


{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:svtxt:}
logname [{cmd:,} {it: {opt u:nderline} {opt l:ine} {opt c:hapter}  {opt s:ection}}]
:
text 

{it: 	where:}
{phang2}logname is the reference name of the log, specified in {cmd: log using "path\name", name(logname)}{p_end} 


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:logname}
{synopt:{opt logname}} only needs to be defined first time either 
{helpb svcom} or {cmd:svtxt} is used{p_end}


{syntab:Main}
{synopt:{opt u:nderline}} underlines the text.{p_end}
{synopt:{opt l:ine}} prints a demarcation line before and after the text.{p_end}
{synopt:{opt c:hapter}} places a numbered chapter marker in the logfile.
The input text will be the chapter name.{p_end}
{synopt:{opt s:ection}} places a numbered section marker in the logfile.
The input text will be the section name.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{cmd:svtxt} does not support {helpb by}.

{marker description}{...}
{title:Description}

{pstd}
{cmd: svtxt} is intented for making dynamic texts and 
longer notes for output stored with the {helpb svcom}. 

{pstd}
{cmd:svtxt} is closely related to {helpb svcom}, and it works in the same way, 
although only on text. 
It stores text in a rigorously maintained logfile without the need for 
{cmd:log on} - {cmd:log off} commands, and especially without the extra text 
those commands will produce on there own, if not embeded in {cmd: quietly{c -(} ... {c )-}}


{pstd}
{cmd:svtxt} can also utillise its capabillity to store text 
to part the logfile in sections and chapters.


{marker options}{...}
{title:Options}
{dlgtab:Log}

{phang}
{opt logname} only needs to be specified the first time, or if you change log. 
The name is stored and reused. If you are using different logs to store results, 
then remember to specify logname every time you are changing log. Logname is 
reused by both {helpb svcom} and {cmd:svtxt}.

{dlgtab:Main}  

{phang}
{opt u:nderline} Underlines the text in the output. The same effect can be achieved by using 
{cmd:{c -(}ul:{c )-}} or the {cmd:{c -(}ul on{c )-}} - {cmd:{c -(}ul off{c )-}}. 
Using the underline option can sometimes be faster.{p_end}

{phang}
{opt l:ine} places a demarcation line before and after the output text,
just as seen with {helpb svcom}. With {cmd:svtxt} the default is no line.

{phang}
{opt c:hapter} places a consecutive numbered chapter mark in the logfile. 
Probably most interesting in long logfiles 
or with major shifts in the focus of analysis within the same logfile.
In case you prefer the chapter named in your own language, it can easily be changed in the ado.

{phang}
{opt s:ection} places a consecutively numbered section mark in the logfile. 
The number includes both the chapter number and the section number. 
In case {it: section} is used before first chapter, then a warning is issued, 
and the section is numbered only with the consecutive section number.
The warning is not included in the restricted logfile, 
but is printet in the result window and 
recorded in an ordinary running log - see third example.



{marker examples}{...}
{title:Examples}


The basic use of {cmd:svtxt} is examplified below.


{space 8}{hline 10} {it:example do-file content} {hline 10}
{cmd}{...}
{* example_start - basicsvtxt}{...}
	* Display of basic functionality of svtxt
	* In this display only one log is active
	set more off
    
	log using one-log.smcl, replace name(results)
	log off results
	sysuse auto, clear
	tab foreign 
	display "The above command and this text will not show in the log"
	
	svtxt results : "Only this short text and .... "
        
	svtxt , underline: "this slightly longer text will appear in the log"
	
	svtxt , line: "The demarcation line can sometimes find a use."
	
	svtxt : Quotations marks are not nessecary ///
	and it is possible to write longer pragraphs. 
	
	log close results
	
	view one-log.smcl
		
	* cleaning up
	rm one-log.smcl
  		
{* example_end}{...}
{txt}{...}
{space 8}{hline 45}
{space 8}{it:({stata svtxt_run basicsvtxt using svtxt.sthlp:click to run})}


{cmd:svtxt} can be used to create a 'dynamic text' in the logfil.


{space 8}{hline 10} {it:example do-file content} {hline 10}
{cmd}{...}
{* example_start - macrosvtxt}{...}
	* Display of dynamic text functionality of svtxt
	* In this display only one log is active
	set more off
    
	log using one-log.smcl, replace name(results)
	log off results
	sysuse auto, clear
	
	svtxt results : Even if a calculation is not shown in the logfile, ///
	you can still cite the values. 
	
	sum price
	svtxt results : Like the mean of {cmd:summarized price} is calculated to `r(mean)'
	svtxt :But the high numbers of digtets can be a problem.

	* There is one annoyance in the use of svtxt.
	* As the text has to be embeded in quotation marks, 
	* the normal syntax of display format macro "text" does not work.
	* Normally you would probably do something like this:
		
	sum price
	return list
	display %5.1f `r(mean)'
        
	* With svtxt you can either store the result first in a local macro, 
	* and there include information about precession.
	* Or you can use strofreal().
		
	sum price 
	local price_mean: display %5.1f `r(mean)'
	
	svtxt : Now the mean on `price_mean' is more readable, /// 
	when the local macro is preajusted.
		
	sum price 
	svtxt : Instead of local macros you can use the strofreal()-function ///
	- e.g. strofreal(`r(mean)',"%4.1f") = `=strofreal(`r(mean)',"%3.1f")'
		
	log close results
	view one-log.smcl
       
	* cleaning up
	rm one-log.smcl
                
{* example_end}{...}
{txt}{...}
{space 8}{hline 45}
{space 8}{it:({stata svtxt_run macrosvtxt using svtxt.sthlp:click to run})}

Example of the chapter and section function is shown here below.
This example requires that {helpb svcom} is installed.

{space 8}{hline 10} {it:example do-file content} {hline 10}
{cmd}{...}
{* example_start - chaptersvtxt}{...}
	* Display of chapter and section capabillities of svtxt
	* In this display only one log is active
	set more off
	capture scalar drop sv_chapnum_dvpd
	capture scalar drop sv_secnum_dvpd
	capture scalar drop sv_chapnumcopy_dvpd
	
	log using main-log.smcl, replace
	sysuse auto, clear
	
	log using one-log.smcl, replace name(results)
	log off results

	svtxt results, section : First section - a table
	
	svcom : tab foreign, note(A one-way table) nocommand noline
	
	svtxt : Sorry I forgot to define the chapter first.
	
	svtxt  ,chapter: First chapter - AUTO data set
	
	svtxt : This chapter will only draw information from the auto data set.
	
	svtxt ,s: About prices
	
	svcom: tabstat price, by(foreign) s(mean) ///
	head(mean price for foreign and domestic cars) ///
	noline
	
	svtxt : More text about this section.
		
	svtxt, s: About repair
		
	svcom: tab rep78 foreign, row  ///
	head(Distribution of repair record between foreign and domestic cars) ///
	noline nocommand

	svtxt ,c : The bplong dataset
	
	sysuse bplong, clear
	
	svtxt: This chapter concerns fictional blood pressure.

	svcom : bysort when agegrp: tabstat bp, by(sex) s(mean p25 p75) ///
	headline(Blood pressure before and after treatment) ///
	noline nocommand ///
	note(Blood pressure for men and women before and after treatment in each age group) 
	
	svtxt: Hopefully this gives some idea about how svcom and svtxt work.
		
	log close _all
	view main-log.smcl
	view one-log.smcl
	
	* cleaning up
	rm one-log.smcl
	rm main-log.smcl
  		
{* example_end}{...}
{txt}{...}
{space 8}{hline 45}
{space 8}{it:({stata svtxt_run chaptersvtxt using svtxt.sthlp:click to run})}


{marker acknowledgements}
{title:Acknowledgements}
{pstd}
Thanks to Robert Picard for writing the{cmd: rangerun_run.ado} command and allowing the 
reuse of it in the example do-files in this help-file and in the 
help-file for {helpb svcom}.

{pstd}
Thanks to countless answeres, to me or others, on the statalist for providing indirect help 
for this little projekt and other stataproblems.

{pstd}
Thanks to Nich Cox, Clyde Schecter and Jens Lauritsen for providing answers 
directly relvant to this program.


{marker storedscalars}
{title:Stored Scalars}
{pstd}

{synoptset 30 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:sv_lognavn_dvpd}} name of the log{p_end}
{synopt:{cmd:sv_chapnum_dvpd }} scalar to store current chapter number{p_end}
{synopt:{cmd:sv_secnum_dvpd}} scalar to store current section number{p_end}
{synopt:{cmd:sv_chapnumcopy_dvpd}} scalar, deriviat of chapnum, 
is used when first chapter is not defined.{p_end}
				


{title:Author}
Dennis Lund Hansen
MD, PhD-fellow
Odense University Hospital, 
Department of Haematology
dlh@dadlnet.dk
