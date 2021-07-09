{smcl}
{* *! version 1.3  20 Dec 2013}{...}
{vieweralsosee "" "--"}{...}
{viewerjumpto "Syntax" "backup##syntax"}{...}
{viewerjumpto "Description" "backup##description"}{...}
{viewerjumpto "Options" "backup##options"}{...}
{viewerjumpto "Remarks" "backup##remarks"}{...}
{viewerjumpto "Examples" "backup##examples"}{...}
{hline}
help for {cmd:backup}{right:Andres Castaneda}
{hline}
{title:Back up files and folders}

{phang}
{bf:backup} {hline 2} Program to automatically create backup of any type of file

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:backup}
[{cmd:,}
{it:options}]

{marker sections}{...}
{title:Sections}

{pstd}
Help is presented under the following headings:

	{help backup##description:Description}
	{help backup##options:Options}
	{help backup##examples:Examples}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt s:ource(string)}}Source Directory (local or network path){p_end}
{synopt:{opt d:estination(string)}}Destination Directory (local or network path){p_end}
{synopt:{opt mirror}}Mirror a directory tree with all the sub-folders including empty directories{p_end}
{synopt:{opt copy(string)}}Specifies the file properties to be copied{p_end}
{synopt:{opt F:iles(string)}}list of files to copy{p_end}
{synopt:{opt st:art(string)}}Folder from the source directory from which the folder tree is desired to start{p_end}
{synopt:{opt nf:olders(int 8)}}Number of folders with backup of the same directory{p_end}
{synopt:{opt p:eriod(string)}}Frequency for copying each folder{p_end}
{synopt:{opt speed(int 32)}}Number of files copied in parallel {p_end}
{synopt:{opt xd:ir(string)}}Directories to be excluded from being copied{p_end}
{synopt:{opt xf:ile(string)}}Type of files to be excluded from being copied {p_end}
{synopt:{opt inf:ile(string)}}Type of files to be copied{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}
{cmd:backup} Copies any type of file maintaining the permissions, attributes, owner information, timestamps 
and properties of the objects copied. It uses the DOS command-line {cmd:ROBOCOPY} to perform the backup, 
so it {error:only works over Windows} for now.
{cmd:backup} is very useful as one of the instructions of the {help profilew##:profile.do} in which you 
can set which files or folders are desired to be backed up each time Stata is started. In addition, {cmd:backup} might
be used at the beginning or ending of any do-file in order to ensure a backup of all the files developed  
in a project. 

{col 30}{help backup##sections:Back to Sections}

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt s:ource(string)} Source Directory (local or network path). 

{phang}
{opt d:estination(string)} Destination Directory (local or network path)

{phang}{it:NOTE:} If either the source or desination are a "quoted long foldername" do not include a trailing 
backslash as this will be treated as an escape character, i.e. "C:\some path\" will fail but 
"C:\some path\\" or "C:\some path\." or "C:\some path" will work

{phang}
{opt f:iles(string)} Name of file to act upon. File you want to copy o type of file you need to copy.
You can use wildcard characters (? and *). If no files are listed, {cmd:backup} defaults to all files (*.*)

{phang}
{opt mirror} mirror a directory tree with all the subfolders including the empty directories and you 
purge files and folders on the destination server that no longer exists in source.

{phang}
{opt copy(string)} Specifies the file properties to be copied. The following are the valid values 
for this option:

 {col 10}Value ...{col 25}Property 
 {col 10}{hline 40}
 {col 10}{cmd:D}{col 25}Data
 {col 10}{cmd:A}{col 25}Attributes
 {col 10}{cmd:T}{col 25}Time stamps
 {col 10}{cmd:S}{col 25}NTFS access control list (ACL)
 {col 10}{cmd:O}{col 25}Owner information
 {col 10}{cmd:U}{col 25}Auditing information

{phang}
The default is {cmd:DAT}. Do not specify values separated with spaces. 

{phang}
{opt st:art(string)} from the source path, select directory from which you want to preserve the tree 
structure of the original folder

{phang}
{opt nf:olders(int 8)} Number of folder you want to keep in you backup directory. In other words, you can
specify how many copies of your backup by date you want to have. Default is 8 folders

{phang}
{opt p:eriod(string)} you can select how many days, weeks, month, quarters or years will be the frequency
of your backup. If you specify just a number, {cmd:backup} will understand it as number of days. 
the period has the following syntax. {it:x[d|w|m|q|s|y]} where {it:x} is any number and {it:d} refers to days;
 {it:w} to weeks; {it:m} to 30-day months; {it:q} to 90-day quarters; {it:s} to 180-day semester; and 
 {it:y} to 360-day years. 
 
 {col 10}period ...{col 25}is equivalent to typing 
 {col 10}{hline 40}
 {col 10}{cmd:9} {col 25}Nine-days backup frequency
 {col 10}{cmd:4d}{col 25}Four-days backup frequency 
 {col 10}{cmd:3w}{col 25}three-weeks (21 days) backup frequency
 {col 10}{cmd:3m}{col 25}three-months backup frequency
 {col 10}{cmd:1q}{col 25}one-quarter (90 day) backup frequency 
 {col 10}{cmd:1y}{col 25}one-year backup frequency 

{phang}
{opt speed(int 32)} Multi-threaded support allows {cmd:backup} using Windows command-line 
Robocopy to open multiple threads simultaneously, 
allowing many files to be copied in parallel. With multi-threaded copying, total time required to 
complete the operation will be drastically reduced and cut, when comparing with with typical copying 
one file at time in serial sequential order. the value of {it:speed} must be at least 1 and not greater
than 128. Default is 32.

{phang}
{opt xd:ir(string)} Directories to exclude from the directory source. If one of the folders within the
directory path has intermediate blanks it is important to use double compounded quotes (`""') and 
separate each directory with double quotes ("")

{phang}
{opt xf:ile(string)}  File/s or type/s of file to exclude. Not use with option {it:infile}

{phang}
{opt inf:ile(string)} File/s or type/s of file to include. Not use with option {it:xfile}

{col 30}{help backup##sections:Back to Sections}

{marker examples}{...}
{title:Examples}

{dlgtab:Basic}
{phang}
Copy everything from {it:"C:\source"} to {it:"E:\destination"} excluding the folder "C:\source\exclude" 
and "C:\source\to exclude". Multi-thread set to 100, maximum six copies of "C:\source" will be kept in
"E:\destination" organized by dates. Copies will be performed every other week (2w)

   {cmd:backup}, source("C:\source") destination("E:\destination") ///
     xdir(`" "C:\source\exclude" "C:\source\to exclude" "') ///
     speed(100) nfolders(6) period(2w) mirror

{dlgtab:Files}
{phang}
Copy everything from {it:"C:\source\a\b\c"} to {it:"E:\destination"} starting folder tree from "C:\source\a\b". 
Multi-thread set to 100, maximum six copies of "C:\source\a\b\c" will be kept in
"E:\destination" organized by dates. Copies will be performed every three days (2w). Only files Excel 
files that start with the word "graphs" and do-files that start with the word "programs" will be copied. 

   {cmd:backup}, source("C:\source\a\b\c") destination("E:\destination") ///
     start(b) files(graphs*.xlsx programs*.do) ///
     speed(100) nfolders(6) period(3d) mirror


{col 30}{help backup##sections:Back to Sections}

{title:Additional information}
{p}

Website {browse "http://technet.microsoft.com/en-us/library/cc733145.aspx":ROBOCOPY, Microsoft}

{title:Author}
{p}

Andrés Castañeda, The World bank.
Email {browse "mailto:acastanedaa@worldbank.org":acastanedaa@worldbank.org}
