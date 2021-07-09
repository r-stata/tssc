{smcl}
{* version 1.0.2 08dec2010}
{cmd:help gdsum}
{hline}

{title:Title}

{p 5}
{cmd:gdsum} {hline 2} Summarize grouped data

{title:Syntax}

{p 8}
{cmd:gdsum} {varlist} {ifin} [{cmd:,} {it:options}]

{synoptset 21 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt rem:ove("chars")}}remove {it:chars} from value labels{p_end}
{synopt:{opt med:ian}}additionally calculate median{p_end}
{synopt:{opt min(#)}}set lower boundary of first class to {it:#}{p_end}
{synopt:{opt max(#)}}set upper boundary of last class to {it:#}{p_end}
{synopt:{opt com:ma}}treat commas in value labels as decimal point{p_end}
{synopt:{opt mat:rix(matname)}}return output in matrix {cmd:r(}{it:matname}{cmd:)}{p_end}
{synopt:{opt novarl:abel}}use variable names in output matrix{p_end}
{synopt:{opt f:ormat(%fmt)}}set {help format} for output{p_end}
{synoptline}
{p 4}
{helpb by} is allowed


{title:Description}

{pstd}
{cmd:gdsum} calculates the mean and standard deviation for grouped data. The median may be 
calculated optionally. Results are displayed in a matrix and returned in {cmd:r()}. The 
lower and upper boundaries of the (disjoint) classes are needed to calculate the 
statistics. The way to provide this information is to define value labels for each class.

{pstd}
The value labels must contain the lower {hi:and} upper boundary of each class and may 
contain any other characters. The boundaries must be given in the correct order and all 
other characters (before the upper bound) must be specified in the {opt remove()} option.

{title:Options}

{dlgtab:options}

{phang}
{opt remove("chars")} specifies the characters to be removed from value labels. The 
default is {hi:"-"} and it is added to the characters specified. Commas in value labels 
are ignored, unless {opt comma} is specified. Double quotes may be omitted.

{phang}
{opt median} additionally calculates and returns the median.

{phang}
{opt min(#)} sets the lower boundary of the first class to {it:#}. This option may be used 
if the lower bound of the first class is not given in the value label. In this case 
{opt min(0)} is the default.

{phang}
{opt max(#)} sets the upper boundary of the last class to {it:#}. This option may be used 
if the upper bound of the last class is not given in the value label. In this case 
{opt max()} is set to the lower bound of the last class.

{phang}
{opt comma} treats commas in value labels as decimal point. The default is to ignore 
commas. This option temporarily {help set dp} {cmd: comma}.

{phang}
{opt matrix(matname)} returns the result matrix in {it:matname}.

{phang}
{opt novarlabel} uses variable names in the output. Default is to use variable labels. 
Labels are abbreviated to 32 characters.

{phang}
{opt format(%fmt)} sets the display format.


{title:Examples}

{pstd}
Example 1

	. tabulate inc

	 Income per month |      Freq.     Percent        Cum.
	------------------+-----------------------------------
	    $ 0 to 499.99 |          4       26.67       26.67
	  $ 500 to 999.99 |          6       40.00       66.67
	$ 1000 to 2499.99 |          3       20.00       86.67
	   $ 2500 to 5000 |          2       13.33      100.00
	------------------+-----------------------------------
	            Total |         15      100.00

	{cmd:. gdsum inc ,remove($ to)}

	                 |      Mean         SD        Obs 
	-----------------+---------------------------------
	Income per month |  1216.662   1156.762         15 


{pstd}
Example 2

	. tabulate inc

	        Einkommen |      Freq.     Percent        Cum.
	------------------+-----------------------------------
	    0-499,99 Euro |          4       26.67       26.67
	  500-999,99 Euro |          6       40.00       66.67
	1000-2499,99 Euro |          3       20.00       86.67
	   2500-5000 Euro |          2       13.33      100.00
	------------------+-----------------------------------
	            Total |         15      100.00

	{cmd:. gdsum inc ,novarlabel}

	             |      Mean         SD        Obs 
	-------------+---------------------------------
	         inc |  52366.23   41226.84         15 


{pstd}
Note that "-" and "Euro" do not have to be removed, because "-" is the default setting and 
"Euro" follows the upper boundary. The result is not equal to the result above, because a 
comma is used as decimal point. The default setting is to remove commas, so "499,99" 
becomes "49999". In order to get the correct result you have to specify {opt comma}.

	{cmd:. gdsum inc ,novarlabel comma}

	             |      Mean         SD        Obs 
	-------------+---------------------------------
	         inc |  1216,662   1156,762         15 


{pstd}
Example 3

	. tabulate inc

	    Income p. month |      Freq.     Percent        Cum.
	--------------------+-----------------------------------
	   up to USD 499.99 |          4       26.67       26.67
	  USD 500 to 999.99 |          6       40.00       66.67
	USD 1000 to 2499.99 |          3       20.00       86.67
	 more than USD 2500 |          2       13.33      100.00
	--------------------+-----------------------------------
	              Total |         15      100.00

	{cmd:. gdsum inc ,remove(up to USD "more than") median}
	inc: lower boundary set to 0
	inc: upper boundary set to 2500

	               |      Mean         SD        p50        Obs 
	---------------+--------------------------------------------
	Income p month |  1049.996   791.6993   791.6608         15 


{pstd}
Note that the lower boundary is missing in the first class and the upper boundary is 
missing in the last class. Since {opt min()} and {opt max()} are not specified, 
{cmd:gdsum} uses "0" as the lower bound of the first and "2500" as upper bound of the last 
class. To get the above result, specify {opt max(5000)}.

	{cmd:. gdsum inc ,remove(up to USD "more than") median max(5000)}
	inc: lower boundary set to 0
	inc: upper boundary set to 5000

	               |      Mean         SD        p50        Obs 
	---------------+--------------------------------------------
	Income p month |  1216.662   1156.762   791.6608         15 


{title:Saved results}

{pstd}
{cmd:gdsum} saves the following in {cmd:r()}:

{pstd}
Scalars{p_end}
{synopt:{cmd:r(mean_varname)}}mean{p_end}
{synopt:{cmd:r(sd_varname)}}standard deviation{p_end}
{synopt:{cmd:r(N_varname)}}non-missing observations{p_end}
{synopt:{cmd:r(p50_varname)}}median ({opt median} only){p_end}

{pstd}
Matrices{p_end}
{synopt:{cmd:r(matname)}}result matrix ({opt matrix()} only){p_end}


{title:Formulas}

{pstd}
The mean is calculated as

{p 8}
(1) {it:M = (A' * F) / n}{p_end}

{pstd}
with{p_end}
{p 8}
{it:A = (el1 el2 ... elk)'}{p_end}
{p 7}
{it:el = ((lb + ub)/2)}{p_end}
{p 8}
{it:F} = (freq1 freq2 ... freqk)'

{pstd}
{it:A} and {it:F} are {it:k} x 1 vectors, where {it:k} is the number of classes. In 
{it:el}, {it:lb} and {it:ub} are the lower and upper boundaries of the class intervals. In 
{it:F}, {it:freq} is the class frequency. The number of non-missing observations is 
{it:n}. 

{pstd}
The standard deviation is calculated as

{p 8}
(2) {it:sd = sqrt((1/n-1) * (B' * F))}{p_end}

{pstd}
with{p_end}
{p 8}
{it:B = (el1 el2 ... elk)'}{p_end}
{p 7}
{it:el = ((xm - M)^2)}{p_end}

{pstd}
In {it:el}, {it:xm} is the mid-point of the class interval (i.e. the elements of A'), {it:M} 
is the mean - as calculated in (1).

{pstd}
The median is calculated as

{p 8}
(3) {it:p50 = lbm + ((n/2 - cf) / nmcl) * (ubm-lbm)}{p_end}

{pstd}
where {it:lbm} is the lower boundary of the median class, {it:cf} is the cumulative 
frequency of the class prior to the median class, {it:nmcl} is the number of observations 
in the median class and {it:ubm} is the upper boundary of the median class.

{title:Author}

{pstd}Daniel Klein, University of Bamberg, daniel1.klein@gmx.de

{title:Also see}

{psee}
Online: {help summarize}
{p_end}
