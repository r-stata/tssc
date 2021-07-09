{smcl}
{* *! version 1.0 21 Jun 2019}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "surface##syntax"}{...}
{viewerjumpto "Description" "surface##description"}{...}
{viewerjumpto "Options" "surface##options"}{...}
{viewerjumpto "Remarks" "surface##remarks"}{...}
{viewerjumpto "Examples" "surface##examples"}{...}
{title:Title}
{phang}
{bf:surface} {hline 2} Produce a Wireframe Surface plot

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:surface}
varlist(min=3
max=3)
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt saving(string)}}  saves the graph to a specified file name. Use the option saving(filename,replace) to overwrite a previous file.

{pstd}
{p_end}
{synopt:{opt round(#)}}  specifies the precision of the x and y variables so that a wireframe can be drawn.

{pstd}
{p_end}
{synopt:{opt label:round(#)}}  specifies the precision of the x, y and z automatic axes labels.

{pstd}
{p_end}
{synopt:{opt nlines(#)}}  specifies the number of lines to be used in the surface, the default is 40.

{pstd}
{p_end}
{synopt:{opt nobox}}  suppresses the drawing of the box around the surface.

{pstd}
{p_end}
{synopt:{opt orient(string)}}  specifies which axes should be the x, y and z-axes.

{pstd}
{p_end}
{synopt:{opt xlab:el(numlist)}}  specifies the labelling on the x-axis.

{pstd}
{p_end}
{synopt:{opt ylab:el(numlist)}}  specifies the labelling on the y-axis.

{pstd}
{p_end}
{synopt:{opt zlab:el(numlist)}}  specifies the labelling on the z-axis.

{pstd}
{p_end}
{synopt:{opt nowire}}  specifies that the data is plotted as a point and a dropline.

{pstd}
{p_end}
{synopt:{opt xtitle(string)}}  specifies the title for the x-axis.

{pstd}
{p_end}
{synopt:{opt ytitle(string)}}  specifies the title for the y-axis.

{pstd}
{p_end}
{synopt:{opt ztitle(string)}}  specifies the title for the z-axis.

{pstd}
{p_end}
{synopt:{opt wc:olor(string)}}  specifies the color of the wireframe lines.

{pstd}
{p_end}
{synopt:{opt colorif(string)}}  specifies a series of if statements and colors to vary the colours in some of the surface plots

{pstd}
{p_end}
{synopt:{opt *}}  twoway options{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

{pstd}
    The function attempts to draw a wireframe plot from three variables.  Var1 specifies the x-coordinate, var2 the y-coordinate and var3 the
    z-coordinate. Alternatively the function can draw a circle at each point and add a straight line going down to the lowest point.

{pstd}
    This function can handle data that is not in the form of a matrix of values.  However if there are too many x- and y- values the function will
    attempt to round the dataset values into a more reasonable spread of values. This will result in very messy figures. However in such a case it is
    the impression that is needed. Many other statistical packages require a full matrix of values. This is not a problem using the nowire option.

{pstd}
    At present the state of rotating the diagram is limited to interchanging the axes.

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt saving(string)}  this will save the resulting graph in filename.gph. If the file already exists then use the replace suboption.

{pstd}
{p_end}
{phang}
{opt round(#)}  data is automatically rounded if there are too many x and y values. This option controls the amount of rounding, for example round(1)
        rounds the x and y values to the nearest integer.
{p_end}
{phang}
{opt label:round(#)}  specifies the precision of the x, y and z automatic axes labels.

{pstd}
{p_end}
{phang}
{opt nlines(#)} 3    specifies the number of lines to be used in the surface, the default is 40.

{pstd}
{p_end}
{phang}
{opt nobox}     suppresses the drawing of the box around the surface.

{pstd}
{p_end}
{phang}
{opt orient(string)}  ) this function must take the letters xyz or a combination of them. Whichever letter comes first is the x-axis, second is y-axis and
        third is the z-axis. Thus orient(zxy) means that var1 is now the y coordinates, var2 is the z-coordinates and var3 is the x-coordinates. This
        is different from changing the variables around since the wireframe is still draw across the original x and y values. This is a crude attempt
        to implement rotation to obtain a clearer picture.
{p_end}
{phang}
{opt xlab:el(numlist)}     specifies the labelling on the x-axis.

{pstd}
{p_end}
{phang}
{opt ylab:el(numlist)}     specifies the labelling on the y-axis.

{pstd}
{p_end}
{phang}
{opt zlab:el(numlist)}     specifies the labelling on the z-axis.

{pstd}
{p_end}
{phang}
{opt nowire}  this suppresses the drawing of the wire frame in exchange for lines

{pstd}
{p_end}
{phang}
{opt xtitle(string)}     specifies the title for the x-axis.

{pstd}
{p_end}
{phang}
{opt ytitle(string)}     specifies the title for the y-axis.

{pstd}
{p_end}
{phang}
{opt ztitle(string)}     specifies the title for the z-axis.

{pstd}
{p_end}
{phang}
{opt wc:olor(string)}     specifies the color of the wireframe lines.

{pstd}
{p_end}
{phang}
{opt colorif(string)}  specifies a series of if statements and colors to vary the colours in some of the surface plots. For example the scatter points could be coloured
red for low values and blue for high values.
{p_end}
{phang}
{opt *}  twoway options {p_end}


{marker examples}{...}
{title:Examples}
{pstd}

{pstd}

{pstd}
    surface x y z, saving(myfile) round(10) orient(zxy)

{pstd}
    surface x y z, xtitle(my x title) ytitle(my y title) ztitle(my z title) saving(myfile,replace)

{pstd}
    An "immediate" example without using a dataset. Please click the commands in order to avoid problems.

{pstd}
    {stata clear} <--- NOTE all data is removed you may want to preserve first

{pstd}
	{stata set obs 900}

{pstd}
	{stata gen x = int((_n - mod(_n-1,30) -1 ) /30 )}

{pstd}
	{stata gen y = mod(_n-1,30)}

{pstd}
	{stata gen z = normalden(x,10,3)*normalden(y,15,5)}

{pstd}
	{stata surface x y z}

{pstd}
	{stata surface x y z, zlabel(0 0.005 0.012) labelround(1) xtitle(X-variable)}

{pstd}
	{stata surface x y z, zlabel(0 0.005 0.012) labelround(1) xtitle(X-variable) title(My surface plot)}
	
    {stata surface x y z, zlabel(0 0.005 0.012) labelround(1) xtitle(X-variable) title(My surface plot) wc(red*.5)}
	
    {stata surface x y z, zlabel(0 0.005 0.012) labelround(1) colorif(z<0.004 red z>0.004 blue) xtitle(X-variable) title(My surface plot) nowire}


{title:Author}
{p}

Prof Adrian Mander, Cardiff University.

Email {browse "mailto:mandera@cardiff.ac.uk":mandera@cardiff.ac.uk}



{title:See Also}
Related commands:

{pstd}
Other Graphic Commands I have written: {p_end}

{synoptset 27 }{...}
{synopt:{help batplot} (if installed)} {stata ssc install batplot}   (to install) {p_end}
{synopt:{help cdfplot} (if installed)} {stata ssc install cdfplot}   (to install) {p_end}
{synopt:{help contour} (if installed)}   {stata ssc install contour}     (to install) {p_end}
{synopt:{help drarea}  (if installed)}   {stata ssc install drarea}      (to install) {p_end}
{synopt:{help graphbinary} (if installed)}   {stata ssc install graphbinary} (to install) {p_end}
{synopt:{help metagraph} (if installed)}   {stata ssc install metagraph}   (to install) {p_end}
{synopt:{help palette_all} (if installed)}   {stata ssc install palette_all} (to install) {p_end}
{synopt:{help plotbeta} (if installed)}   {stata ssc install plotbeta}    (to install) {p_end}
{synopt:{help plotmatrix} (if installed)}   {stata ssc install plotmatrix}  (to install) {p_end}
{synopt:{help radar}  (if installed)}   {stata ssc install radar}     (to install) {p_end}
{synopt:{help trellis}  (if installed)}   {stata ssc install trellis}     (to install) {p_end}
{p2colreset}{...}
