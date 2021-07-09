{smcl}
{* *! version 3.0.4  21January2020}{...}
{viewerjumpto "Syntax" "importsav##syntax"}{...}
{viewerjumpto "Requirements" "importsav##requirements"}{...}
{viewerjumpto "Description" "importsav##description"}{...}
{viewerjumpto "Remarks" "importsav##remarks"}{...}
{viewerjumpto "Examples" "importsav##examples"}{...}

{title:Title}

{phang}{bf:importsav} {hline 2} Program to convert SPSS file to Stata (requires R)


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
	{cmd:importsav} {it:{help filename:filename1}} [ {it:{help filename:filename2}} ]
	[{cmd:,} {it:options}]

{p 8 17 2}
	{cmd:importsav} [ foreign | haven ] {it:{help filename:filename1}} [ {it:{help filename:filename2}} ]
	[{cmd:,} {it:options}]

{pmore2}
	where {it:{help filename:filename2}} will be automatically set identical to {it:{help filename:filename1}} if omitted.


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt e:ncoding(string)}}set which {help unicode encoding:encoding} to be used when reading {cmd:SPSS} file via {cmd:haven}{p_end}
{synopt:{opt r:eencode(string)}}set which {help unicode encoding:encoding} to be used when reading {cmd:SPSS} file via {cmd:foreign}{p_end}
{synopt:{opt u:nicode(string)}}set which {help unicode encoding:encoding} to be used when translating from extended ASCII after {cmd:foreign}{p_end}
{synopt:{opt c:ompress(#)}}set the reference size for compression (unit: {it:megabyte}, default value: {it:256}) {p_end}
{synopt:{opt off:default}}force {cmd:importsav} not to compress the data{p_end}
{synoptline}
{p2colreset}{...}

{p 4 6 2}
If {opt encoding(string)} is set, {cmd:importsav} will set option {cmd:encoding} of R function {cmd:haven::read_sav} using that {it:string}.
If you specify {it:NULL} or {it:null}, it is identical not to use {opt encoding(string)}.{p_end}
{p 4 6 2}
If {opt reencode(string)} is set, {cmd:importsav} will set option {cmd:reencode} of R function {cmd:foreign::read.spss} using that {it:string};
here, {opt reencode(string)} will be automatically set identical to {opt encoding(string)} if omitted.
If you don’t want this fallback behaviour, specify {it:NA} or {it:na} in {opt reencode(string)}.{p_end}
{p 4 6 2}
If {opt unicode(string)} is set and your version of {cmd:Stata} is newer than {it:13}, {cmd:importsav} will execute {help unicode translate} using that {it:string} after R package {cmd:foreign} converted your data;
here, {opt unicode(string)} will be automatically set identical to {opt reencode(string)} if omitted.
If you don’t want this fallback behaviour, specify {it:off} in {opt unicode(string)}.{p_end}
{p 4 6 2}
By default, {cmd:importsav} compresses your data when current file size is larger than {it:256MB}.
You can manually adjust that criterion via {opt compress(#)}.
If {opt offdefault} is set, the data will not be compressed in any cases.{p_end}
{p 4 6 2}


{marker requirements}{...}
{title:Requirements}

{pstd}
	You should install {browse "https://cran.r-project.org/":R} on your system.
	If you have installed {cmd:R} on the location other than the default,
	you should add the location of {cmd:R} to {search whereis} or {cmd:system environment variable}.
	In the latter case, say path to {cmd:R.exe} is {cmd:D:\R-3.6.2\bin\R.exe},
	you need to add either {cmd:D:\R-3.6.2} to {cmd:R_HOME environment variable} (Windows-only)
	or {cmd:D:\R-3.6.2\bin\R.exe} to {cmd:PATH environment variable}.


{marker description}{...}
{title:Description}

{pstd}
	{cmd:importsav} converts {cmd:SPSS} file to {cmd:Stata} with the help of {cmd:R} packages--{browse "https://www.rdocumentation.org/packages/haven/":haven},
	{browse "https://www.rdocumentation.org/packages/foreign":foreign}
	and {browse "https://www.rdocumentation.org/packages/bit64":bit64}.
	Thus, in order to use {cmd:importsav}, you need to install {browse "https://cran.r-project.org/":R} on your system first.
	But after that, there is no need of running {cmd:R} at all.

{pstd}
	The essential idea underlying {cmd:importsav} is {it:not to interrupt} your workflow within {cmd:Stata}.
	With this command, you don’t need to escape {cmd:Stata} for data conversion.
	{cmd:importsav} will automatically write and execute {cmd:R} code for you.

{pstd}
	This is how {cmd:importsav} works: if you typed the command properly,
	{cmd:importsav} stores file name(s) and path in {cmd:Stata}’s macros,
	writes {cmd:R} code using information contained in those macros
	and then sends that {cmd:R} code to {cmd:R} console through {cmd:Stata}’s {cmd:shell} command.

{pstd}
	{cmd:importsav} depends on {cmd:haven} and {cmd:foreign} to support non-English labels.
	Since {cmd:foreign} truncates variable labels exceeding a certain length, by default {cmd:importsav} tries {cmd:haven} first and then {cmd:foreign} only if {cmd:haven} didn’t work.
	But using a subcommand {cmd:importsav foreign}, it is also possible to try {cmd:foreign} first regardless of the malfunction of {cmd:haven}.

{pstd}
	For this program to work, hence, {cmd:importsav} must ascertain location of {cmd:R} on your system.
	To identify where {cmd:R} is installed, the program depends on three different algorithms:
	(1) using SSC package {search whereis};
	(2) searching expected directories similar to github package {browse "https://github.com/haghish/rcall/":rcall}’s behavior;
	(3) chekcing the {cmd:PATH environment variable}.
	If all three fail to find location of {cmd:R}, {cmd:importsav} will cease to proceed.
	In this case, you can set the {cmd:R} path manually using the {cmd:whereis} command.

{pstd}
	An important limitation of {cmd:importsav} is that it is not able to convert a file with {it:non-English characters} in path.
	The source of this problem lies in {cmd:R} itself and currently there is no credible solution.
	You should check your {it:current working directory} and {it:{help filename:filename(s)}}.


{marker remarks}{...}
{title:Remarks}

{pstd}
	Below addresses known issue(s).

{pstd}
	1. (Windows) If {cmd:importsav} hangs after invoking {cmd:R} console within the shell, please re-run {cmd:Stata} {cmd:as Administrator}.


{marker examples}{...}
{title:Examples}

{phang}{cmd:. importsav dataname.sav}{p_end}
{pmore}
	With this command, you will get {it:dataname.dta} from {it:dataname.sav}.

{phang}{cmd:. importsav spssfile statafile , e("EUC-KR")}{p_end}
{pmore}
	With this command, you will get {it:statafile.dta} from {it:spssfile.sav} using {help unicode encoding:encoding} {it:EUC-KR} to read {cmd:SPSS} file.

{phang}{cmd:. importsav "spss file" statafile.dta , c(100)}{p_end}
{pmore}
	With this command, you will get {it:statafile.dta} from {it:spss file.sav} and your data will be compressed if the file size is larger than {it:100MB}.

{phang}{cmd:. importsav spssfile "C:\Data\stata file" , off}{p_end}
{pmore}
	With this command, you will get {it:stata file.dta} in {it:C:\Data} from {it:spssfile.sav} in the {it:current working directory} and your data will not be compressed even if the file size is larger than {it:256MB}.

{phang}{cmd:. importsav "C:\Data\spss file" "stata file", c(100) off}{p_end}
{pmore}
	With this command, you will get {it:stata file.dta} in the {it:current working directory} from {it:spss file.sav} in {it:C:\Data} and your data will not be compressed even if the file size is larger than {it:100MB}.

{phang}{cmd:. importsav foreign "spss data" stata_data}{p_end}
{pmore}
	With this command, you will get {it:stata_data.dta} from {it:spss data.sav} using {cmd:R} package {cmd:foreign}.


{marker author}{...}
{title:Author}

{pstd}
	{browse "https://jhmin.weebly.com":JeongHoon Min}, Sogang University, plus1@sogang.ac.kr


{marker acknowledgement}{...}
{title:Acknowledgement}

{pstd}
	This program owes a lot to {browse "https://codeandculture.wordpress.com/2010/06/29/importspss-ado-requires-r/":importspss} by Gabriel Rossman,
	{browse "https://ideas.repec.org/c/boc/bocode/s458303.html":whereis} by Germán Rodríguez
	and {browse "https://github.com/haghish/rcall/":rcall} by E. F. Haghish.
	The author is grateful for their informative programs.

