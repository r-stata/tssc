{smcl}
{* *! version 0.23}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "crossmat##syntax"}{...}
{viewerjumpto "Description" "crossmat##description"}{...}
{viewerjumpto "Examples" "crossmat##examples"}{...}
{viewerjumpto "Stored results" "crossmat##results"}{...}
{viewerjumpto "Author and support" "crossmat##author"}{...}
{title:Title}
{phang}
{bf:crossmat} {hline 2} A wrapper for {help tabulate:tabulate} that returns 
calculated values in matrices as well as showing them in the log

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:crossmat} varlist(min=1 max=2) [{help if}] [{help in}] [{help weight}] 
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt l:abel}} Use values labels as row and column names when possible.{p_end}
{synopt:{opt m:issing}} treat missing values like other values.{p_end}
{synopt:{opt e:xact}(integer)} Default is 0, ie not set. If set and two variables 
are given as arguments Fisher's exact test is reported.{p_end}
{synopt:{opt v:erbose}} show the Stata commands and output behind crossmat. 
For validation purposes.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}
{cmd:crossmat} is a wrapper on {help tabulate:tabulate} that returns all 
calculated values as matrices.

{marker examples}{...}
{title:Examples}

{pstd}Below is a set of examples. You can copy the code and insert it in the 
command window or you can just click once on each blue line below.
Then the command is automatically moved to the command window and executed.{p_end}
{pstd}Note that there is progression in the examples such a command line may require 
some of the previous lines to show the intended properly.{p_end}

{pstd}In this example estimates and their confidence intervals for two regression
models are combined into one summary matrix.{p_end}

	{phang}{stata `"sysuse auto, clear"'}{p_end}
	
{pstd}One can get tabulate outputs with one variable:{p_end}
	{phang}{stata `"crossmat rep78"'}{p_end}

{pstd}The command as such prints nothing in the log. What can be retrieved is 
seen by:{p_end}
	{phang}{stata `"return list"'}{p_end}

	{pstd}One can get tabulate outputs with one variable, eg using 
	{help matprint: matprint:{p_end}
	{phang}{stata `"matprint (r(counts), r(pct)), d((0,1))"'}{p_end}

	{pstd}One can get tabulate outputs with two variables:{p_end}
	{phang}{stata `"crossmat rep78 foreign, exact(1) missing"'}{p_end}

	{pstd}This can be retrieved:{p_end}
	{phang}{stata `"return list"'}{p_end}

	{pstd}The martrices can be viewed by {help matprint:matprint}:{p_end}
	{phang}{stata `"matprint r(counts), d(0)"'}{p_end}
	{phang}{stata `"matprint r(expected), d(2)"'}{p_end}
	{phang}{stata `"matprint r(chi2), d(3)"'}{p_end}
	{phang}{stata `"matprint r(lrchi2), d(3)"'}{p_end}
	{phang}{stata `"matprint r(tests), d((3,0,3))"'}{p_end}
	{phang}{stata `"matprint r(greeks), d(3)"'}{p_end}
	{phang}{stata `"matprint 100 * r(pct), d(1)"'}{p_end}
	{phang}{stata `"matprint 100 * r(rpct), d(1)"'}{p_end}
	{phang}{stata `"matprint 100 * r(cpct), d(1)"'}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:crossmat} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(counts)}}The count table{p_end}
{synopt:{cmd:r(expected)}}The expected values from the independence assumption{p_end}
{synopt:{cmd:r(chi2)}}The Pearson chisquare parts of the independence test{p_end}
{synopt:{cmd:r(lrchi2)}}The likelihood ratio chisquare parts of the independence test{p_end}
{synopt:{cmd:r(tests)}}The test summary{p_end}
{synopt:{cmd:r(greeks)}}The greek estimates{p_end}
{synopt:{cmd:r(pct)}}The percentages{p_end}
{synopt:{cmd:r(rpct)}}The row percentages{p_end}
{synopt:{cmd:r(cpct)}}The column percentages{p_end}


{browse "http://www.bruunisejs.dk/StataHacks/My%20commands/crossmat/crossmat_demo/":To see more examples}


{marker author}{...}
{title:Authors and support}

{phang}{bf:Author:}{break}
 	Niels Henrik Bruun, {break}
	Section for General Practice, {break}
	Dept. Of Public Health, {break}
	Aarhus University
{p_end}
{phang}{bf:Support:} {break}
	{browse "mailto:nhbr@ph.au.dk":nhbr@ph.au.dk}
{p_end}
