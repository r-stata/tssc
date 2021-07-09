{smcl}
{* 03Feb2011}{...}
{hline}
help for {hi:proprcspline}
{hline}

{title:Restricted cubic spline smoothing of proportions}

{p 8 12 2} 
{cmd:proprcspline} 
{it:yvar xvar} [{it:cvars}] 
{ifin}
{weight} 
[
{cmd:,}
{opt at(cvar1 # [cvar2 # [...]])}
{opt by(by_option)}
{opt sh:owknots} 
{opt catax:is}
{opt catleg:end}
{opt rareaopt#(rarea_options)}
{opt addplot(plot)}
{opt labl:ength("all" | #)}
{opt stub(stub)} 
{opt gen:erate(stub)} 
{it:mkspline_options}
{opt mlogit:opts(mlogit_options)} 
]

{p 4 4 2}{opt fweight}s and {opt pweight}s are allowed; see {help weight}.


{title:Description}

{p 4 4 2}{cmd:proprcspline} computes a restricted cubic spline smooth of 
proportions of observations in each category of {it:yvar} given {it:xvar},
and graphs them as a stacked area plot.  Optionally, these smoothed 
proportions can be adjusted for a set of control variables ({it:cvars}).  


{title:Remarks}

{p 4 4 2}{cmd:proprcspline} calls {help mkspline:mkspline, cubic} to create
variables containing a restricted cubic spline of {it:xvar}.  It then
calls {help mlogit} to regress {it:yvar} against those new variables,
and thus obtains predicted (smoothed) values of proportions in each 
category of {it:yvar} given {it:xvar}.  Finally, it calls {help graph} to 
plot the smooth. 

{p 4 4 2}When control variables are added, then these will also be added
to the {cmd:mlogit} model. When predicting the smoothed proportions the
values of control variables will be fixed at the values specified in the
{opt at()} option or the mean when these variables did not occur in the 
{opt at()} option.

{p 4 4 2}More generally, the main intended usage of {cmd:proprcspline} 
is for descriptive analysis and informal exploratory analysis. More formal 
uses would require specification of the {cmd:stub()} option to save the 
variables created. Some consideration might need to be given to the 
implications of any data snooping. 


{title:Options} 

{p 4 8 2}{opt at(cvar1 # [cvar2 # [...]])} specifies the values at which
the control variables ({it:cvars}) are held constant when predicting the
smoothed proportions. All control variables that are not mentioned in the
{opt at()} option will be fixed at their overal mean. When the {opt by()} 
option is specified, the mean will be computed once for the entire sample
(allowing for {cmd:if} and {cmd:in} selection criteria), {it: not}  
separately for each group specified in the {opt by()} option.

{p 4 8 2}{opt by(by_options)} allows comparing the smoothed proportions
across groups. See help on {help by_option}.

{p 4 8 2}{cmd:showknots} specifies that the positions of 
the knots be shown on the graph by vertical lines. 

{p 4 8 2}{opt cataxis} specifies that the categories of {it:yvar}
are labeled on the right y-axis. This is the default when the {cmd:by()}
option is not specified or when the {cmd:by()} option implies the comparison
of only two groups.

{p 4 8 2}{opt catlegend} specifies that the categories of {it:yvar}
are labeled in a legend. This is the default when the {cmd:by()} option
is specified such that more than 2 groups are compared.

{p 4 8 2}{opt rareaopt#(rarea_options)} specifies options to be applied
to the area representing category number # of {it:yvar}. These options are
listed in {help twoway rarea}

{p 4 8 2}{cmd:addplot(}{it:plot}{cmd:)}
provides a way to add other plots to the generated graph. See help on 
{help addplot_option}. 

{p 4 8 2}{opt lablength("all"| #)} Within the second y-axis or the legend 
the categories are labeled using the value labels. the {opt lablength(()} 
option specifies the maximum number of characters that are used from each 
value label. The default is 20. One can either specify "all" to make 
{cmd:proprcspline} use all characters of the value labels in the legend 
or a positive integer indicating the maximum number of characters used.

{p 4 8 2}{opt stub(stub)} specifies that the variables
containing the spline be saved in variables with prefix {it:stub}. 

{p 4 8 2}{opt generate(stub)} specifies that smoothed proportions
be saved in variables with prefix {it:stub}..

{p 4 8 2}{it:mkspline_options} are options of 
{help mkspline:mkspline, cubic}. 

{p 8 8 2}{cmd:nknots()} specifies the number of knots that are to be
used for a restricted cubic spline.  This number must be between 3 and 7
unless the knot locations are specified using {cmd:knots()}.  The
default number of knots is 5.

{p 8 8 2}{cmd:knots()} specifies the exact location of the knots to be
used for a restricted cubic spline.  The values of these knots must be
given in increasing order.  When this option is omitted, the default
knot values are based on Harrell's recommended percentiles with the
additional restriction that the smallest knot may not be less than the
fifth-smallest value of {it:xvar} and the largest knot may not be
greater than the fifth-largest value of {it:xvar}.  If both
{cmd:nknots()} and {cmd:knots()} are given, they must specify the same
number of knots.

{p 4 8 2}{opt mlogitopts()} contains options of {help mlogit}. It is
difficult to know why you would want to specify any. 


{title:Examples} 

{cmd}
    sysuse nlsw88, clear
    
    gen marst = cond(never_married, 1,              ///
                cond(married, 2, 3))                ///
                if !missing(married, never_married)
    label define marst 1 "never married"            ///
                       2 "married"                  ///
                       3 "divorced/widowed"
    label value marst marst
    
    proprcspline marst grade, xlab(0(5)15) 
{txt}
{p 4 4 2}({stata "proprcspline_ex 1":click to run}){p_end}

{cmd}
    sysuse nlsw88, clear
    
    gen marst = cond(never_married, 1,              ///
                cond(married, 2, 3))                ///
                if !missing(married, never_married)
    label define marst 1 "never married"            ///
                       2 "married"                  ///
                       3 "divorced/widowed"
    label value marst marst
    
    proprcspline marst grade, xlab(0(5)15)          ///
                 rareaopt1(color(red))              ///
                 rareaopt2(color(blue))             ///
                 rareaopt3(color(gs10))
{txt}
{p 4 4 2}({stata "proprcspline_ex 2":click to run}){p_end}

{cmd}
    sysuse nlsw88, clear
    
    gen marst = cond(never_married, 1,              ///
                cond(married, 2, 3))                ///
                if !missing(married, never_married)
    label define marst 1 "never married"            ///
                       2 "married"                  ///
                       3 "divorced/widowed"
    label value marst marst

    label define c_city 1 "in central city"         ///
                        0 "outside central city"
    label value c_city c_city  

    proprcspline marst grade, xlab(0(5)15)          ///
                 by(c_city, note(""))
{txt}
{p 4 4 2}({stata "proprcspline_ex 3":click to run}){p_end}

{cmd}
    sysuse nlsw88, clear
    
    gen marst = cond(never_married, 1,              ///
                cond(married, 2, 3))                ///
                if !missing(married, never_married)
    label define marst 1 "never married"            ///
                       2 "married"                  ///
                       3 "divorced/widowed"
    label value marst marst

    label define c_city 1 "in central city"         ///
                        0 "outside central city"
    label value c_city c_city  
	
    gen black = race == 2 if race < .
    label define black 1 "black"                     ///
                       0 "non-black"
    label value black black    

    proprcspline marst grade black, xlab(0(5)15)     ///
                 by(c_city, note("")) at(black 0)   
{txt}
{p 4 4 2}({stata "proprcspline_ex 4":click to run}){p_end}


{title:Saved results} 

    r(N_knots)   number of knots (scalar) 
    r(knots)     knot positions (matrix) 


{title:Author} 

{p 4 4 2}Maarten L. Buis{break} 
         Universitaet Tuebingen{break} 
         Institut fuer Soziologie{break}
         maarten.buis@uni-tuebingen.de 


{title:Acknowledgments} 

{p 4 4 2}Large portions of the code are based upon {cmd:rcspline} by Nicholas J. Cox.


{title:Also see}

{p 4 13 2}Online: {help lowess}, {help lpoly}{p_end}
{p 4 13 2}If installed: {help rcspline}, {help mvrs}{p_end}
