{smcl}
{* 25nov2015/30nov2015/1dec2015/7mar2016}{...}
{cmd:help depthplot} 
{hline}

{title:Plot of one or more variables with depth as vertical axis}


{title:Syntax}

{p 8 18 2}
{cmd:depthplot} {it:depthvar xvarlist} 
{ifin} 
[{cmd:,}
{opt by(by_options)} 
{it:graph_options} 
]


{title:Description}

{pstd}
{cmd:depthplot} is intended primarily for researchers with environmental
data to be plotted with depth below surface as vertical axis. The depth
variable {it:depthvar} must always be specified first and by default
will be shown with a reversed scale, low values at the top and high
values at the bottom.  Other numeric variables should be specified
afterwards and will be plotted in separate panels with separate {it:x} axes.
Each distinct depth value should occur just once in the data provided. 


{title:Remarks} 

{pstd}
Each other variable is by default shown as a line plot in a separate
panel.  The panels are controlled with options of {cmd:by()}. For
example, {cmd:by(row(1))} insists on one row of panels, which will often
be desired.  {cmd:by(xrescale)} uses different scales to more nearly fill
the space available. 

{pstd}
Use {cmd:recast()} to recast to equivalent {cmd:twoway} graphs, most
obviously {cmd:recast(connected)}.
Other possibilities are 
{cmd:recast(area)}, 
{cmd:recast(bar)} (avoid unless data are equally spaced), 
{cmd:recast(dot)} (avoid any way), 
{cmd:recast(dropline)},  
{cmd:recast(scatter)} and  
{cmd:recast(spike)}. Watch out that other options may need to be set to
avoid puzzling or bizarre results, such as {cmd:base(0)} or
{cmd:barwidth()}. Start a search in the help at 
{help advanced_options:advanced options}. Look at the first block 
of {it:newplottype}s. 

{pstd} 
Note that variable labels will be echoed to the graph when they exist,
but typically they should be very concise as well as informative. If
units of measurement are common to several variables, they are better 
specified by a {cmd:note()} or {cmd:caption()} or {cmd:subtitle()},
which should be inserted inside the {cmd:by()} option. 

{pstd}
If the vertical scale is in effect a height scale, then specify
{cmd:ysc(noreverse)} to override the default. 


{title:Options}

{phang}
{opt by()} indicates options that control the panels collectively. 

{phang}
{it:graph_options} are any options allowed for {help line}
excluding {opt by()}.  


{title:Examples} 

{phang}{cmd:. depthplot depth Au Cd As Pb Cu Zn}{p_end}
{phang}{cmd:. depthplot depth Au Cd As Pb Cu Zn, by(row(1) compact xrescale note(all elements ppm)) recast(connected) yla(50(10)90, ang(h)) ytitle(depth (cm)) ms(Oh) lc(gs12)}{p_end}
{phang}{cmd:. depthplot depth Au Cd As Pb Cu Zn, by(row(1) compact xrescale note(all elements ppm)) recast(scatter) yla(50(10)90, ang(h)) ytitle(depth (cm)) ms(Oh)}{p_end}
{phang}{cmd:. depthplot depth Au Cd As Pb Cu Zn, by(row(1) compact xrescale note(all elements ppm)) recast(scatter) yla(50(10)90, ang(h)) ytitle(depth (cm)) ms(Oh) yli(50(2)96, lstyle(grid))}{p_end}
{phang}{cmd:. depthplot depth Au Cd As Pb Cu Zn, by(row(1) compact xrescale note(all elements ppm)) recast(spike) yla(50(10)90, ang(h)) ytitle(depth (cm)) base(0)}{p_end}
{phang}{cmd:. depthplot depth Au Cd As Pb Cu Zn, by(row(1) compact xrescale note(all elements ppm)) recast(dropline) yla(50(10)90, ang(h)) ytitle(depth (cm)) ms(Oh) base(0)}{p_end}
{phang}{cmd:. depthplot depth Au Cd As Pb Cu Zn, by(row(1) compact xrescale note(all elements ppm)) recast(bar) yla(50(10)90, ang(h)) ytitle(depth (cm)) ms(Oh) base(0) barwidth(2) }{p_end}
{phang}{cmd:. depthplot depth Au Cd As Pb Cu Zn, by(row(1) compact xrescale note(all elements ppm)) recast(area) yla(50(10)90, ang(h)) ytitle(depth (cm)) ms(Oh) base(0) }{p_end}


{title:Author} 

{pstd}Nicholas J. Cox, Durham University{break} 
      n.j.cox@durham.ac.uk 


{title:Acknowledgments}

{pstd}This command was stimulated by discussions with Jeff Warburton. 
The data in the example were discussed by Cox and Natasha L.M. Barlow (2008).  


{title:References} 

{phang}
Cox, N.J. and Barlow, N.L.M. 
2008. 
Plotting on reversed scales. 
{it:Stata Journal} 8: 295{c -}298.  
{browse "http://www.stata-journal.com/sjpdf.html?articlenum=gr0035":http://www.stata-journal.com/sjpdf.html?articlenum=gr0035}


{title:Also see}

{psee}
Manual: {bf:[G] graph twoway} 

{psee}
User-written: 
{help wallplot} (if installed), 
{help tabplot} (if installed) 



