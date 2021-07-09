{smcl}
{* *! version 1.1  24 Apr 2018}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[D] label" "help label"}{...}
{viewerjumpto "Syntax" "labeldatasyntax##syntax"}{...}
{viewerjumpto "Description" "labeldatasyntax##description"}{...}
{viewerjumpto "Remarks" "labeldatasyntax##remarks"}{...}
{viewerjumpto "Examples" "labeldatasyntax##examples"}{...}
{viewerjumpto "Author" "labeldatasyntax##author"}{...}
{title:Title}

{phang}
{bf:labeldatasyntax} {hline 2} Produce syntax to label variables and values, given a data dictionary


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:labeldatasyntax} [{cmd:using} {it:{help filename}}], {cmd:saving}({it:{help filename}})
[{it:options}]

{pstd}
You may enclose {it:filename} in double quotes and must do so if
{it:filename} contains blanks or other special characters.

{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt replace}}specifies that the saving file be replaced if it already exists{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:labeldatasyntax} creates a syntax file to label variables and/or values, given a data dictionary is provided in one of a few specific formats. 
The resulting syntax can look like this: 

{pmore}
label define regionlbl 1 "North" 2 "East" 3 "South" 4 "West"{break} 
label define sexlbl 1 "Male" 2 "Female"{break} 
label define yesnolbl 0 "No" 1 "Yes"{break} 

{pmore}
label values sex sexlbl{break} 
label values region regionlbl{break} 
label values badears yesnolbl{break} 
label values respprobs yesnolbl{break} 

{pmore}
label variable sex "Gender"{break}  
label variable region "Where the child lives"{break}  
label variable age "Age of child in years"{break}  
label variable dob "Date of birth"{break} 
label variable badears "Has bad ears?"{break} 
label variable respprobs "Has respiratory problems?"{break} 


{pstd}There are two general formats of the data dictionary that can be used with {cmd:labeldatasyntax}.

{pstd}{ul:Format I.} When the data dictionary consists of just one file (dataset currently in memory) with variables and their descriptions and/or values and labels. {break}
The file may contain variables called: {input}variable description codeset value label{break}

{pstd}{txt}{ul:Format II.} When the data dictionary consists of two files.{break} 
File (a) (dataset currently in memory) may contain variables called: {input}codeset value label{break}
{txt}This file is used to create syntax such as:
 
{pmore}
label define yesnolbl 0 "No" 1 "Yes"{break}

{pstd}File (b) ({bf:using} {it:{help filename}}.dta) may contain variables called: {input}variable codeset description{break}
{txt}This file is used to create syntax such as: 

{pmore}
label values badears yesnolbl{break}

{pmore}
label variable badears "Has bad ears?" {break}


{marker remarks}{...}
{title:Remarks}

{phang}i.   It is hoped that the .xlsx (and/or .csv) files provided in this package could be useful for users in 
communicating to data providers what is a convenient format to receive a data dictionary associated with a dataset.

{phang}ii. All variables are optional. You just might not get many lines of syntax.

{phang}iii.{bf:variable} need not be repeated for every row detailing the connection between value and label (though it can be). The same is true for {bf:codeset}.

{phang}iv. {bf:codeset} is simply a name (I could alternatively have called it: value_label_name or vallabname or lblname) 
corresponding to a set of codings for categorical variables.

{phang}v.   If the dataset currently in memory does not have a variable called {bf:codeset}, then {bf:codeset} will be generated (. generate {bf:codeset} = {bf:variable})

{phang}vi. The presence or absence of blank lines in a .dta file makes no difference to anything. 


{marker examples}{...}
{title:Examples} (The examples assume the ancillary files have been downloaded to the current folder.) 

{pmore}{txt}Example 0{break}
{cmd}
. import excel "Guide. How to share data from a project in Excel v2.xlsx", sheet("Data Dictionary1") cellrange(A2:D27) firstrow clear {break}
. labeldatasyntax, saving("ex0_label.do") {break}
. import excel "Guide. How to share data from a project in Excel v2.xlsx", sheet("Data1") cellrange(B2:K8) firstrow clear {break}
. describe {break}
. do "ex0_label.do" {break}
. describe {break}
. browse  {break}
 
{pmore}{txt}Example 1{break}
{cmd}
. import delimited "ex1_datadictionary.csv", varnames(1) {break}
. browse {break}
. labeldatasyntax, saving("ex1_label.do") {break}
. doedit "ex1_label.do"{break}

{pmore}{txt}Example 2{break}
{cmd}
. import delimited "ex2_datadictionary.csv", varnames(1) {break}
. browse {break}
. labeldatasyntax, saving("ex2_label.do") {break}
. doedit "ex2_label.do"

{pmore}{txt}Example 3{break}
{cmd}
. import delimited "ex3_allvariables_b.csv", varnames(1) {break}
. browse {break}
. save "ex3_allvariables_b.dta" {break}
. import delimited "ex3_codesetinfo_a.csv", varnames(1) clear {break}
. browse {break}
. labeldatasyntax using "ex3_allvariables_b.dta", saving("ex3_label.do") {break}  
. doedit "ex3_label.do"


{marker author}{...}
{title:Author}

{pstd}{txt}
Mark Chatfield {break}
University of Queensland{break}
Australia{break}
M.Chatfield@uq.edu.au{break}
