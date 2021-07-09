{smcl}
{* 23oct2007/8may2009}{...}
{hline}
help for {hi:rcspline}
{hline}

{title:Restricted cubic spline smoothing}

{p 8 12 2} 
{cmd:rcspline} 
{it:yvar xvar} 
{ifin}
{weight} 
[
{cmd:,}
{it:mkspline_options}
{cmd:stub(}{it:stub}{cmd:)} 
{cmd:regressopts(}{it:regress_options}{cmd:)} 
{cmdab:gen:erate(}{it:newvar}{cmd:)} 
{cmdab:sc:atter(}{it:scatter_options}{cmd:)} 
{cmd:ci}[{cmd:(}{it:rarea_options}{cmd:)]} 
{cmdab:l:evel(}{it:#}{cmd:)} 
{cmdab:sh:owknots} 
{it:mspline_options}
{cmd:addplot(}{it:plot}{cmd:)}
]

{p 4 4 2}{opt fweight}s are allowed; see {help weight}.


{title:Description}

{p 4 4 2}{cmd:rcspline} computes and graphs a restricted cubic spline
smooth of {it:yvar} given {it:xvar}.


{title:Remarks}

{p 4 4 2}{cmd:rcspline} calls {help mkspline:mkspline, cubic} to create
variables containing a restricted cubic spline of {it:xvar}.  It then
calls {help regress} to regress {it:yvar} against those new variables,
and thus obtains predicted (smoothed) values of {it:yvar} given
{it:xvar}.  Finally, it calls {help graph} to plot data and smooth. 

{p 4 4 2}R-square (squared correlation coefficient) and RMSE (root mean
square error) are provided as goodness of fit indicators.  However,
these can typically be 'improved' simply by smoothing less, which
is often likely to be unhelpful. As the resulting predictions come
closer to interpolating the data, R-square will increase, and RMSE will
decrease, but scientific usefulness and the possibility of insight will
usually diminish. 

{p 4 4 2}More generally, the main intended usage of {cmd:rcspline} is 
for informal exploratory analysis in which relationships are checked for linearity
or nonlinearity and appropriate transformations or link functions
are considered. More formal uses would require specification of the 
{cmd:stub()} option to save the variables created. Some consideration
might need to be given to the implications of any data snooping. 


{title:Options} 

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

{p 4 8 2}{cmd:stub(}{it:stub}{cmd:)} specifies that the variables
containing the spline be saved in variables with prefix {it:stub}.  This
option is essential if {cmd:rcspline} is to be followed by
{cmd:regress}. 

{p 4 8 2}{cmd:regressopts()} contains options of {help regress}. It is
difficult to know why you would want to specify any. 

{p 4 8 2}{cmd:generate(}{it:newvar}{cmd:)} specifies that smoothed
values be saved in a new variable {it:newvar}.

{p 4 8 2}{cmd:scatter()} specifies options allowed by the
{help scatter} command.  These should be specified to control the
rendering of the data points.  

{p 4 8 2}{it:mspline_options} are any of the options allowed with 
{help twoway mspline}.  These should be specified to control the
rendering of the smooth or the overall graph. 

{p 4 8 2}{cmd:showknots} specifies that the positions of 
the knots be shown on the graph by vertical lines. 

{p 4 8 2}{cmd:ci}[{cmd:(}{it:rarea_options}{cmd:)}] specifies that 
confidence intervals based on the standard error of the linear
prediction be shown. {cmd:ci} may be specified with options 
of {help twoway rarea} to tune the display of the confidence interval. 

{p 4 8 2}{cmd:level()} specifies a confidence level to use for 
confidence intervals. See help on {help level}. 

{p 4 8 2}{cmd:addplot(}{it:plot}{cmd:)}
provides a way to add other plots to the generated graph. See help on 
{help addplot_option}. 


{title:Examples} 

{p 4 8 2}{cmd:. rcspline mpg weight}

{p 4 8 2}{cmd:. rcspline mpg weight, scatter(ms(oh))}

{p 4 8 2}{cmd:. rcspline mpg weight, generate(Smpg)}

{p 4 8 2}{cmd:. rcspline mpg weight, ci(color(ltblue)) clw(medthick)} 

{p 4 8 2}{cmd:. rcspline mpg weight, addplot(lowess mpg weight)}


{title:Saved results} 

    r(N_knots)   number of knots (scalar) 
    r(knots)     knot positions (matrix) 


{title:Author} 

{p 4 4 2}Nicholas J. Cox{break} 
         Durham University{break} 
	 n.j.cox@durham.ac.uk 


{title:Acknowledgments} 

{p 4 4 2}A question from Jos{c e'} Maria Pacheco de Souza on Statalist led to the addition of 
saved r-class results as above. 


{title:Also see}

{p 4 13 2}Online: {help lowess}, {help lpoly}, {help mvrs} (if installed){p_end}

