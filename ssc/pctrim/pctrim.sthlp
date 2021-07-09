{smcl}
{* *! version 1.1.0  30nov2012}{...}
{cmd:help pctrim}
{hline}

{title:Title}

{phang}
{bf:pctrim} {hline 2} Mark or recode observations outside of a percentile range 


{title:Syntax}

{p 8 17 2}
{cmd:pctrim} 
{varlist}
{ifin}
{cmd:,} [{it:options}]

{phang}

{synoptset 30}{...}
{synopthdr}
{synoptline}
{synopt:{opt p:ercentiles(lb ub)}}Lower and upper bounds for percentile trimming. Defaults are 1 and 99.{p_end}
{synopt:{opth by(varname)}}Group variables within which to check for outliers and calculate replacement values.{p_end}
{synopt:{opt mark(newvarname)}}Generate indicator variable marking observations with outliers in any variable.{p_end}
{synopt:{opt rec:ode(mean|median|miss|bound)}}Recode outliers for each variable.{p_end}
{synopt:{opt replace}}Replace existing outliers with recode value, after recode.{p_end}
{synopt:{opt gen:erate(stubname)}}Prefix for new, recoded variables, after recode.{p_end}
{synopt:{opt copy:rest}}Copy out-of-sample values from old variables to new variables, after recode generate. {p_end}
{synopt:{opt miss:ok}}Do not exclude observations with missing values for some or all variables.{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
{cmd:pctrim} trims outlying observations based on percentile bounds. {cmd:pctrim} can operate on
a {varlist}. The user can create an indicator variable marking outliers or recode them. Recode
options include mean, median, upper/lower bounds, or system missing. Outliers may be 
recoded in place, or new variables may be generated with trimmed data. The {opt mark} option 
operates case-wise, marking observations that have outliers for any variable 
in {varlist}. The {opt rec:ode} option operates on each variable indpendently. Only 
values that are outliers with respect to the current variable are recoded.
Recode can replace outliers with system missing, mean, median, or the relevant (upper or lower) 
percentile bound. Replacement statistics are computed with outliers included.  

{pstd}
{cmd:pctrim} works best if the variables in {varlist} have no missing observations. By default,
{cmd:pctrim} works on a single analysis sample after excluding any observations with missing
data for any variable in {varlist}. Observations with missing data are not considered when
identifying outliers or when computing replacement statistics. If the user would prefer to
operate on each variable independently, the option {opt miss:ok} should be specified. Given 
this option, {cmd:pctrim} operates on a single variable at a time, and does not consider
whether other variables in {varlist} have missing data. 


{title:Options}

{dlgtab:Main}

{phang}
{opt p:ercentiles(lb ub)} allows the user to choose lower and upper percentile bounds to
designate outliers. The defaults are 1 and 99. 0 may be used for the lower bound if trimming
is only desired for the top of the distribution. Similarly, 100 may be used for the upper bound.
{p_end}

{phang}
{opth by(varlist)} designates group variables. If specified, percentile bounds and 
replacement statistics are calculated within each combination of group 
variables. By variables must be numeric. Observations with missing data for the by-variables
are excluded. This is true even with the {opt miss:ok} option.{p_end}

{phang}
{opt mark(newvarname)} creates a new indicator variable marking observations with outliers in 
any of the variables in {varlist}. {opt mark(newvarname)} operates case-wise.

{phang}
{opt rec:ode(mean|median|miss|bound)} replaces outlying values for each variable. 
{opt rec:ode(mean|median|miss|bound)} operates on each variable indpendently. Only 
observations that are outliers with respect to that variable are recoded.
Recode options are system missing, mean, median, or the relevant (upper or lower) 
percentile bound.

{phang}
{opt replace} replaces outlying values in existing variables.  

{phang}
{opt gen:erate(stubname)} creates a new, trimmed variable for each variable in {varlist}.
	Each new variable is prefixed with stubname.

{phang}
{opt copy:rest} specifies that out-of-sample values be copied from the original
        variables.  In line with other data-management commands, {cmd: pctrim} defaults
        to setting newvar to missing (.) outside the observations selected by if
        exp and in range. {opt copy:rest} option can only be used with the recode 
		and generate options.  

{phang}
{opt miss:ok} specifies that observations should not be excluded from the analysis 
		sample if they have missing values for some or all variables in {varlist}. 
		Missing values are ignored when computing percentile bounds and marking 
		outlying observations for each variable. 


{title:Examples}

{phang}{cmd:. sysuse auto} 

{phang}{cmd:. pctrim weight mpg length , by(foreign) p(0 99) mark(outlier)}

{phang}{cmd:. pctrim weight mpg length , p(0 99) gen(tr_)}


{title:Author}

{pstd} Michael Barker {p_end}
{pstd} Georgetown University {p_end}
{pstd} mdb96@georgetown.edu {p_end}


{title:Also see}

{psee}
{space 2}Help: 
{help pctile						} , 
{help centile	 					} , 
{help egen##pctile(): egen pctile()	}  

{psee}
{space 2}Net:  
{net `"describe winsor		, from(http://fmwww.bc.edu/repec/bocode/w)"' : winsor	} ,
{net `"describe winsor2		, from(http://fmwww.bc.edu/repec/bocode/w)"' : winsor2	} ,
{net `"describe trimmean	, from(http://fmwww.bc.edu/repec/bocode/t)"' : trimmean	} ,
{net `"describe trimplot	, from(http://fmwww.bc.edu/repec/bocode/t)"' : trimplot	}
{p_end}
