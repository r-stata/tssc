{smcl}
{* 3oct2012}{...}
{hline}
help for {hi:lmoments}
{hline}

{title:L-moments and derived statistics}

{p 8 17 2}{cmd:lmoments}
[{it:varlist}]
[{cmd:if} {it:exp}]
[{cmd:in} {it:range}] 
[{cmd:,}
{cmdab:all:obs}
{cmd:lmax(}{it:#}{cmd:)}
{cmd:short} 
{help tabdisp:tabdisp_options}
{cmd:variablenames}
{cmd:saving(}{it:filename}[{cmd:,} {help save:save_options}{cmd:)} 
]

{p 8 17 2}{cmd:lmoments}
{it:varname}
[{cmd:if} {it:exp}]
[{cmd:in} {it:range}] 
[{cmd:,}
{cmd:by(}{it:byvarlist}{cmd:)}
{cmdab:miss:ing} 
{cmd:lmax(}{it:#}{cmd:)}
{cmd:short} 
{help tabdisp:tabdisp_options}
{cmd:saving(}{it:filename}[{cmd:,} {help save:save_options}{cmd:)} 
]


{p 4 4 2}{cmd:by ... :} may also be used with {cmd:lmoments}: 
see help on {help by}.


{title:Description}

{p 4 4 2}{cmd:lmoments} calculates L-moments and derived statistics for
a {it:varlist}. Any string variables in {it:varlist} are ignored.
Specifically, and by default, the first four L-moments and the derived
statistics t, t_3 and t_4 are calculated for each variable in
{it:varlist}.


{title:Remarks}

{p 4 4 2}Denote by X(j:n) the j th smallest observation from a sample of
size n from a variable X and by E the expectation operator.

{p 4 4 2}The first four L-moments are defined by

	E (X(1:1)),

	1/2 E (X(2:2) - X(1:2)),

	1/3 E (X(3:3) - 2 X(2:3) + X(1:3)) and 

	1/4 E (X(4:4) - 3 X(3:4) + 3 X(2:4) - X(1:4)). 

{p 4 4 2}They are estimated via these weighted averages for a sample
x_1, ..., x_n, otherwise known as probability-weighted moments:

	b_0 = average of x(j:n),

			 j - 1
	b_1 = average of {hline 5} x(j:n),
			 n - 1

			 j - 1 j - 2
	b_2 = average of {hline 5} {hline 5} x(j:n) and 
			 n - 1 n - 2

			 j - 1 j - 2 j - 3
	b_3 = average of {hline 5} {hline 5} {hline 5} x(j:n). 
			 n - 1 n - 2 n - 3

{p 4 4 2} 
The estimators are

	l_1 = b_0,
	l_2 = 2 b_1 - b_0, 
	l_3 = 6 b_2 - 6 b_1 + b_0 and 
	l_4 = 20 b_3 - 30 b_2 + 12 b_1 - b_0, 

{p 4 4 2}whence

	t   = l_2 / l_1        (cf. coefficient of variation),
	t_3 = l_3 / l_2        (cf. skewness) and
	t_4 = l_4 / l_2        (cf. kurtosis). 


{title:Options}

{p 4 8 2}{cmd:allobs} specifies use of the maximum possible number of
observations for each variable. The default is to use only those
observations for which all variables in {it:varlist} are not missing. 

{p 4 8 2}{cmd:by()} specifies one or more variables defining distinct
groups for which L-moments should be calculated. {cmd:by()} is allowed
only with a single {it:varname}. The choice between {cmd:by:} and
{cmd:by()} is partly one of precisely what kind of output display is
required. The display with {cmd:by:} is clearly structured by groups
while that with {cmd:by()} is more compact. To show L-moments for
several variables and several groups with a single call to
{cmd:lmoments}, the display with {cmd:by:} is essential. 

{p 4 8 2}{cmd:missing} specifies that, if {cmd:by()} is specified,
observations with missing values on {it:byvarlist} are to be included in
calculations.  The default is to exclude them. Missing values on
{it:varlist} are always and necessarily ignored. 

{p 4 8 2}{cmd:lmax()} specifies calculation of the measures l_5 upwards
to the specified maximum and correspondingly of the measures t_5 upwards
in addition to the default.  Thus {cmd:lmax(8)} adds L-moments 5, 6, 7
and 8 and ratios t_5, ..., t_8.  See the references for definitions.
Results are not displayed, but may be saved to a new dataset via the
{cmd:saving()} option.  This is a rarely specified option for those
exploring the uses of these measures. 

{p 4 8 2}{cmd:short} specifies display of n, l_1, l_2, t_3, t_4 only.
This option has no effect on the calculation. 

{p 4 8 2}{it:tabdisp_options} are options of {help tabdisp}.  The
default display has {cmd:format(%9.3f)}.

{p 4 8 2}{cmd:variablenames} specifies that the variable names of
{it:varlist} should be used in display. The default is to use variable
labels to indicate a set of variables. 

{p 4 8 2}{cmd:saving()} specifies a filename in which to save the
results of calculations as a Stata dataset. Optionally, the options of
{help save} itself may be specified. 


{title:Examples}

{p 4 8 2}{cmd:. sysuse auto, clear}

{p 4 8 2}{cmd:. lmoments, short}  

{p 4 8 2}{cmd:. lmoments price-foreign}

{p 4 8 2}{cmd:. bysort rep78: lmoments mpg}

{p 4 8 2}{cmd:. lmoments mpg, by(rep78) missing}

{p 4 8 2}{cmd:. lmoments mpg, by(rep78) missing saving(lmoresults, replace)}


{title:Saved results} 

{p 4 4 2}(all for last-named variable or group only)

    r(N)     n
    r(l_1)   l_1
    r(l_2)   l_2
    r(l_3)   l_3
    r(l_4)   l_4
    ...      (higher sample L-moments if requested) 	
    r(t)     t
    r(t_3)   t_3
    r(t_4)   t_4
    ...      (higher sample L-moment ratios if requested) 	


{title:Acknowledgments} 

{p 4 4 2}
{cmd:lmoments} is a descendant of Patrick Royston's {cmd:lshape} program. 
Stephen Jenkins found a bug in a previous version of this program. 


{title:Author}

{p 4 4 2}Nicholas J. Cox, Durham University, U.K.{break} 
n.j.cox@durham.ac.uk


{title:References}

{p 4 8 2}{browse "http://researcher.watson.ibm.com/researcher/view_project.php?id=1021":L-moments}
 
{p 4 8 2}Hosking, J.R.M. 1990. L-moments: Analysis and estimation of
distributions using linear combinations of order statistics.
{it:Journal of the Royal Statistical Society} Series B 52: 105{c -}124.

{p 4 8 2}Hosking, J.R.M. 1998. L-moments. In Kotz, S., C.B. Read and 
D.L. Banks (eds) {it:Encyclopedia of Statistical Sciences Update Volume 2.} 
New York: Wiley, 357{c -}362.

{p 4 8 2}Hosking, J.R.M. 2006.  
On the characterization of distributions by their L-moments. 
{it:Journal of Statistical Planning and Inference}
136: 193{c -}198.  

{p 4 8 2}Hosking, J.R.M. and J.R. Wallis. 1997. 
{it:Regional frequency analysis: an approach based on L-moments.}
Cambridge University Press.

{p 4 8 2}Jones, M.C. 2004. 
On some expressions for variance, covariance, skewness and L-moments. 
{it:Journal of Statistical Planning and Inference} 
126: 97{c -}106. 

{p 4 8 2}Royston, P. 1992. 
Which measures of skewness and kurtosis are best? 
{it:Statistics in Medicine} 11: 333{c -}343. 

{p 4 8 2}Serfling, R. and Xiao, P. 2007. 
A contribution to multivariate L-moments: L-comoment matrices. 
{it:Journal of Multivariate Analysis} 98: 1765{c -}1781.  


{title:See also} 

{p 4 8 2}{help lmose} (if installed) 

