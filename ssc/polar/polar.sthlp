{smcl}
{* 29may2014}{...}
{cmd:help polar}{right:Version 1.0}
{hline}

{title:Title}

{p 4 11 2}
{hi:polor} {hline 2} Plot polar coordinates.{p_end}


{marker syntax}{title:Syntax}

{p 8 48 2}
{cmdab:polar}
radius_var
angle_var
[if]
[in]
[, {it:options}] 

{title:Description}

{pstd}
This command takes data expressed in polar coordinates and plots the points on a polar grid.  The polar coordinates of a point
can be thought of as the parameters of a vector ("ray") that connects the origin ("pole") to the point.  Thus, polar coordinates are expressed in terms of the
length of the vector (called the radius or radial coordinate, the distance from the origin to the point; denoted by the letter r) 
and the angle between the positive x-axis and the vector (called the angular coordinate, polar angle, or azimuth; often denoted by the letter t
or the Greek letters theta or phi). By default, the command assumes that angles are specified in radians.

{pstd}
The polar grid includes several concentric circles and several grid lines.  By default, three concentric circles are plotted, along with grid lines at
0, 30, 60, 90, 120, and 150 degrees from the positive x-axis.  

{title:Options}

{phang}
{opt ncc(#)} Specify the number of concentric circles used to display the polar grid.  To determine the radius of each concentric circle, 
the maximum radius value in the data set is computed and divided into # equal intervals.  Only one of the {cmdab:ncc} and {cmdab:cc} options
can be specified. If neither the {cmdab:ncc} nor {cmdab:cc} options are specified, {cmdab:ncc} defaults to 3.

{phang}
{opth cc(numlist)} Specify the the precise locations (radii) of concentric circles used to display the polar grid. No checking is
done to determine whether the specified values are consistent with the range of radii in the data set. 
Only one of the {cmdab:ncc} and {cmdab:cc} options can be specified.

{phang}
{opt nsp:okes(#)} Specify the number of spokes to display on the polar grid.  To determine the angle of each spoke with respect to the positve x-axis,
the positive half of the unit circle is divied into # equal intervals. Spokes are drawn symmetric to the origin: {it:i.e.}, from above the x-axis, 
through the origin, to below the x-axis.  Thus, the number of spokes in each quadrant is half of the specified number of spokes.
Only one of the {cmdab:nspokes} and {cmdab:spokes} options can be specified.
If neither the {cmdab:nspokes} nor {cmdab:spokes} options are specified, {cmdab:nspokes} defaults to 6.  

{phang}
{opth sp:okes(numlist)} Specify the the precise locations of spokes used to display the polar grid. For convenience, angles are specified
in degrees relative to the positive x-axis.  Since spokes are drawn symmetric to the origin and extend to both above and below the x-axis, 
only angles from 0 to 180 degrees need to specified. Only one of the {cmdab:nspokes} and {cmdab:spokes} options can be specified.

{phang}
{cmdab:deg:rees} Indicates that angle measurements in the input data set are in degrees rather than radians.

{phang}
{cmdab:sc:atteropts}({help twoway scatter:twoway_scatter_options}) Any {cmd:twoway scatter} options, such as those controlling {help marker_options:markers}, 
{help connect_options:connecting lines}, etc., can be specified and will be passed on to {cmd:twoway} without processing. 

{phang}
{it:{help twoway_options}} Any {cmd:twoway} options, such as those controlling {help title option:titles}, {help legend option:legends}, 
{help axis option:axes}, etc., can be specified and will be passed on to {cmd:twoway} without processing. 

{title:Examples}

{pstd}
{cmd:. // Set up Polar Rose}{break}
{cmd:. set obs 360}{break}
{cmd:. gen theta=_n*2*_pi/360}{break}
{cmd:. gen r=2*cos(3*theta)}{break}
{cmd:. polar r theta}{break}

{pstd}{cmd:. polar r theta, cc(4)}

{pstd}{cmd:. polar r theta, cc(.5(0.5)2)}

{pstd}{cmd:. polar r theta, nsp(8)}

{pstd}{cmd:. polar r theta, sp(30 45 60 120 135 150)}

{pstd}{cmd:. polar r theta, sc(mcolor(red)}

{pstd}{cmd:. polar r theta, title("Polar Rose")}

{pstd}
{cmd:. // Set up Archimedes spiral}{break}
{cmd:. set obs 720}{break}
{cmd:. gen theta=_n}{break}
{cmd:. gen r=1+2*theta}{break}
{cmd:. polar r theta, deg}{break}

{pstd}
{cmd:. // Other shapes}{break}
{cmd:. gen r=0.5+0.5*sin(theta)  // Cardiod} {break}
{cmd:. gen r=1                    // Circle with radius 1 }{break}
{cmd:. gen r=1/(1+cos(theta))     // Parabola }{break}
{cmd:. gen r=1/(1+0.5*cos(theta))  // Ellipse }{break}
{cmd:. gen r=1/(1+1.5*cos(theta))  // Hyperbola }{break}
Note: Be careful with the conic sections, since the denominator can equal zero for certain values of theta

{title:Author}

{pstd}
Joseph Canner{break}
Johns Hopkins University School of Medicine{break}
Department of Surgery{break}
Center for Surgical Trials and Outcomes Research{break}

{pstd}
Email {browse mailto:jcanner1@jhmi.edu}



 

