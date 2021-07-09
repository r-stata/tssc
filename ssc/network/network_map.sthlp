{smcl}
{* *! version 1.1 8jun2015}{...}
{vieweralsosee "Main network help page" "network"}{...}
{vieweralsosee "networkplot (if installed)" "networkplot"}{...}
{viewerjumpto "Syntax" "network_map##syntax"}{...}
{viewerjumpto "Description" "network_map##description"}{...}
{viewerjumpto "Options" "network_map##options"}{...}
{viewerjumpto "Examples" "network_map##examples"}{...}
{title:Title}

{phang}
{bf:network map} {hline 2} draw a map of a network

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:network map} {ifin}
[{cmd:,}
{it:options}]

{synoptset 21 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt cir:cle}[(#)]}Treatments are placed around a circle (the default).{p_end}
{synopt:{opt squ:are}[(#)]}Treatments are placed in a square lattice.{p_end}
{synopt:{opt tri:angular}[(#)]}Treatments are placed in a triangular lattice.{p_end}
{synopt:{opt ran:dom}[(#)]}Treatments are placed at random.{p_end}
{synopt:{opt cen:tre}[(#)]}(only with the circle(#) option) The centre of the circle is also used.{p_end}
{synopt:{opt loc(matname)}}Specifies a matrix containing the locations of the treatments.{p_end}
{synopt:{opt replace}}Existing matrix is to be replaced.{p_end}
{synopt:{opt imp:rove}[(#)]}Requests optimisation of the map to minimise line crossings.{p_end}
{synopt:{opt list:loc}}Lists the treatment location matrix.{p_end}
{synopt:{opt trtc:odes}}makes the display use the treatment codes A, B, C etc. rather than the full treatment names.{p_end}
{synopt:{it:graph_options}}Other options for {helpb graph}.{p_end}
{synopt:{it:networkplot_options}}Other options for {helpb networkplot}.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}


{title:Description}{marker description}

{pstd} {cmd:network map} draws a
map of a network: that is, it shows which treatments are directly compared
against which other treatments, and roughly how much information is avaiable for each treatment
and for each treatment comparison.


{title:Options}{marker options}

{phang}
{opt circle}[(#)]
The treatments are placed around a circle. This is the most commonly used system and the default.
The optional argument specifies the number of locations round the circle; 
the default is the number of treatments.
Larger numbers can be useful with the improve option.

{phang}
{opt square}[(#)]
The treatments are placed in a square lattice.
The optional argument specifies the number of rows and columns in the lattice;
the default is the square root of the number of treatments (rounded up). 
Larger numbers can be useful with the improve option.

{phang}
{opt triangular}[(#)]
The treatments are placed in a triangular lattice.
The optional argument specifies the number of rows in the lattice, which is also the length of the longer rows;
the default is approximately the square root of the number of treatments. 
Larger numbers can be useful with the improve option.

{phang}
{opt random}[(#)]
The treatments are placed randomly.
The optional argument specifies the number of locations in the lattice;
the default is the number of treatments.
Larger numbers can be useful with the improve option.

{phang}
{opt loc(matname)} specifies a treatment location matrix.
This specifies where the treatments are placed on the map.
The matrix should have at least as many rows as treatments, and 3 columns, for the x-coordinate, the y-coordinate and the clock position for the label.
If the matrix does not exist, or if {opt replace} is specified, then a new matrix is created according to options {opt circle}, {opt square} or {opt random}.
If {opt loc(matname)} is not specified then a new matrix is created and stored in _network_map_location.

{pmore}Note that the rows of {it:matname} are taken as the locations of the treatments in alphabetical order.
Row names are ignored.
Thus {cmd:network map, loc(M)} and {cmd:network map if useit, loc(M)} may place the treatments differently.

{phang}
{opt replace} The existing treatment location matrix is to be replaced.

{phang}
{opt improve}[(#)]
requests an iterative procedure to improve the placement of the treatments. 
The algorithm swaps pairs of treatments if this reduces the number of line crossings. 
The optional argument gives the maximum number of cycles; the default is 10.

{phang}
{opt listloc} lists the treatment location matrix.

{phang}
{it:graph_options} specifies options for {helpb graph}: 
for example, {cmd:xscale(on) yscale(on)} could be used to show the axes. 
{cmd:plotregion(margin(t=-10))} can be used to lower the position of a title.

{phang}
{it:networkplot_options} are any options for {helpb networkplot}.



{marker examples}{...}
{title:Examples}

{pstd}Draw a network map for the thrombolytics data - assumes {help networkplot} is installed

{pin}. {stata "use http://www.homepages.ucl.ac.uk/~rmjwiww/stata/meta/thromb.dta, clear"}

{pin}. {stata "network setup r n, studyvar(study) trtvar(treat)"}

{pin}. {stata "network map"}

{pstd}The same, with an improved map on the circle

{pin}. {stata "network map, circle improve"}

{pstd}The same, with an improved map on a triangular grid

{pin}. {stata "network map, triangular(5) improve"}

{pstd}That's good (no line crossings at all), but we can tidy up a bit by aligning treatments and moving labels.
First we extract the matrix of stored locations

{pin}. {stata "mat loc2 = _network_map_location[1..8,.]"}

{pstd}Now we edit it by moving C left to the level of A:  

{pin}. {stata "mat loc2[3,1]=loc2[1,1]"}

{pstd}and moving D up to the level of A:    

{pin}. {stata "mat loc2[4,2]=loc2[1,2]"}

{pstd}and moving E up to the level of B:    

{pin}. {stata "mat loc2[5,2]=loc2[2,2]"}

{pstd}and moving F's label to 10 o'clock: 

{pin}. {stata "mat loc2[6,3]=10"}

{pstd}and then re-drawing the graph:

{pin}. {stata "network map, loc(loc2) title(Improved map of thrombolytics network)"}

{pstd}Finally, here is a set of locations that gives the best graph of these data:

{pin}. {stata "mat loc3=( 3,3,9\ 5,4,3\ 1,2,9\ 4.33,3,6\ 6,4.5,3\ 3,3.67,9\ 5,2,3\ 1,4,9)"}

{pin}. {stata "network map, loc(loc3) title(Best map of thrombolytics network)"}


{p}{helpb network: Return to main help page for network}

