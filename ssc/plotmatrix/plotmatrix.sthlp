{smcl}
{* *! version 1.0 20 Jun 2019}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "plotmatrix##syntax"}{...}
{viewerjumpto "Description" "plotmatrix##description"}{...}
{viewerjumpto "Options" "plotmatrix##options"}{...}
{viewerjumpto "Remarks" "plotmatrix##remarks"}{...}
{viewerjumpto "Examples" "plotmatrix##examples"}{...}
{title:Title}
{phang}
{bf:plotmatrix} {hline 2} Plot values of a matrix as different coloured blocks

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:plotmatrix}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt m:at(name)}}  specifies the name of the matrix to plot. Note that for matrices e(b) and e(V) the user must create a new matrix using the matrix command.

{pstd}
{p_end}
{synopt:{opt ,}}  {p_end}
{synopt:{opt matse(name)}}  specifies the name of the matrix to scale each square by. This could be the standard error of your main matrix.

{pstd}
{p_end}
{synopt:{opt s:plit(numlist)}}  specifies the cutpoints used in the legend. Note that if the matrix contains values outside the range of the number list then the values will not be plotted.  The default will be a number list containing the min, max and 10 other percentiles.

{pstd}
{p_end}
{synopt:{opt c:olor(string)}}  specifies the colour of the blocks used. The default colour is bluish gray. Note that RGB and CMYK colors are not accepted and colors should be specified by the word list in colorstyle e.g. brown.

{pstd}
{p_end}
{synopt:{opt upp:ercolor(string)}}  specifies the colour used in the upper triangular part of the matrix.

{pstd}
{p_end}
{synopt:{opt low:ercolor(string)}}  specifies the colour used in the lower triangular part of the matrix.

{pstd}
{p_end}
{synopt:{opt diag:color(string)}}  specifies the colour used in the diagonal  part of the matrix.

{pstd}
{p_end}
{synopt:{opt allcolors(string)}}  specifies the colours of the blocks used. Note you need to specify all the colours rather than a single colour used by the color() option.

{pstd}
{p_end}
{synopt:{opt nodiag}}  specifies that the diagonal of the matrix is not represented in the graph.

{pstd}
{p_end}
{synopt:{opt save}}  specifies that the stata data file created to plot the heatmap is saved.

{pstd}
{p_end}
{synopt:{opt addbox(numlist)}}  specifies that areas of the graph will be enclosed within a box.  The arguments of this option are groups of 4 numbers representing the (y,x) points of two extreme vertices of the box.

{pstd}
{p_end}
{synopt:{opt u:pper}}  specifies that only the upper diagonal matrix be plotted.

{pstd}
{p_end}
{synopt:{opt l:ower}}  specifies that only the lower diagonal matrix be plotted.

{pstd}
{p_end}
{synopt:{opt d:istance(varname)}}  specifies the physical distances between rows/columns in the matrix. This is mostly useful for plotting a pairwise LD matrix to include the genomic distances between markers.

{pstd}
{p_end}
{synopt:{opt du:nit(string)}}  specifies the units of the distances specified in the distance variable. The default is Megabases but can be any string.

{pstd}
{p_end}
{synopt:{opt maxt:icks(#)}}  specifies the maximum number of ticks on both the y and x axes. The default is 8.

{pstd}
{p_end}
{synopt:{opt freq}}  specifies that the matrix values are displayed within each coloured box.

{pstd}
{p_end}
{synopt:{opt formatcells(string)}}  specifies the format of the displayed matrix values within each coloured box.

{pstd}
{p_end}
{synopt:{opt blc(string)}}  specifies the color for the outline of each box.

{pstd}
{p_end}
{synopt:{opt blw(string)}}  specifies the thickness of the line surrounding each box, the default is vvvthin.

{pstd}
{p_end}
{synopt:{opt *}}  other twoway options.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

{pstd}
This command will display the values of a matrix using twoway area.  Each value of the matrix will be represented by a coloured rectangular block.  A
legend is automatically created using percentiles but the user can also specify how to split the data.

{pstd}
For genetic data there is an additional function to show the genomic distances between markers.  The genomic position is entered using the distance()
option.

{pstd}

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt m:at(name)}     specifies the name of the matrix to plot. Note that for matrices e(b) and e(V) the user must create a new matrix using the matrix command.

{pstd}
{p_end}
{phang}
{opt ,}    {p_end}
{phang}
{opt matse(name)}     specifies the name of the matrix to scale each square by. This could be the standard error of your main matrix.

{pstd}
{p_end}
{phang}
{opt s:plit(numlist)} 1    specifies the cutpoints used in the legend. Note that if the matrix contains values outside the range of the number list then the values will not be plotted.  The default will be a number list containing the min, max and 10 other percentiles.

{pstd}
{p_end}
{phang}
{opt c:olor(string)}     specifies the colour of the blocks used. The default colour is bluish gray. Note that RGB and CMYK colors are not accepted and colors should be specified by the word list in colorstyle e.g. brown.

{pstd}
{p_end}
{phang}
{opt upp:ercolor(string)}     specifies the colour used in the upper triangular part of the matrix.

{pstd}
{p_end}
{phang}
{opt low:ercolor(string)}     specifies the colour used in the lower triangular part of the matrix.

{pstd}
{p_end}
{phang}
{opt diag:color(string)}     specifies the colour used in the diagonal  part of the matrix.

{pstd}
{p_end}
{phang}
{opt allcolors(string)}     specifies the colours of the blocks used. Note you need to specify all the colours rather than a single colour used by the color() option.

{pstd}
{p_end}
{phang}
{opt nodiag}     specifies that the diagonal of the matrix is not represented in the graph.

{pstd}
{p_end}
{phang}
{opt save}     specifies that the stata data file created to plot the heatmap is saved.

{pstd}
{p_end}
{phang}
{opt addbox(numlist)}     specifies that areas of the graph will be enclosed within a box.  The arguments of this option are groups of 4 numbers representing the (y,x) points of two extreme vertices of the box.

{pstd}
{p_end}
{phang}
{opt u:pper}     specifies that only the upper diagonal matrix be plotted.

{pstd}
{p_end}
{phang}
{opt l:ower}     specifies that only the lower diagonal matrix be plotted.

{pstd}
{p_end}
{phang}
{opt d:istance(varname)}     specifies the physical distances between rows/columns in the matrix. This is mostly useful for plotting a pairwise LD matrix to include the genomic distances between markers.

{pstd}
{p_end}
{phang}
{opt du:nit(string)}     specifies the units of the distances specified in the distance variable. The default is Megabases but can be any string.

{pstd}
{p_end}
{phang}
{opt maxt:icks(#)}     specifies the maximum number of ticks on both the y and x axes. The default is 8.

{pstd}
{p_end}
{phang}
{opt freq}     specifies that the matrix values are displayed within each coloured box.

{pstd}
{p_end}
{phang}
{opt formatcells(string)}     specifies the format of the displayed matrix values within each coloured box.

{pstd}
{p_end}
{phang}
{opt blc(string)}     specifies the color for the outline of each box.

{pstd}
{p_end}
{phang}
{opt blw(string)}     specifies the thickness of the line surrounding each box, the default is vvvthin.

{pstd}
{p_end}
{phang}
{opt *}  other twoway options. {p_end}


{marker examples}{...}
{title:Examples}
{pstd}

{pstd}

{pstd}
Plotting the values of a variance covariance matrix

{pstd}

{pstd}
{stata sysuse auto} <--- click this first to load data

{pstd}
{stata  reg price mpg trunk weight length turn, nocons}

{pstd}
{stata  mat regmat = e(V)}

{pstd}
{stata  plotmatrix, m(regmat) c(green) ylabel(,angle(0))}

{pstd}
{stata plotmatrix, m(regmat) allcolors(green*1 green*0.8 green*0.6 green*0.4 red*0.4 red*0.6 red*0.8 red*1.0 ) ylabel(,angle(0))}

{pstd}
  To make the plot above more square use the aspect() option but you might want to make the text smaller in the legend so that the y-axis is closer to
the interior of the plot.

{pstd}
{stata  plotmatrix, m(regmat) allcolors(green*1 green*0.8 green*0.6 green*0.4 red*0.4 red*0.6 red*0.8 red*1.0 ) ylabel(,angle(0)) aspect(1) legend(size(*.4) symx(*.4))}

{pstd}
  Plotting the values of a correlation matrix of a given varlist

{pstd}
 {stata matrix accum R = price mpg trunk weight length turn , nocons dev}

{pstd}
{stata  matrix R = corr(R)}

{pstd}
{stata  plotmatrix, m(R) s(-1(0.25)1) c(red)}

{pstd}
By specifying the freq option the correlations are additional printed within each
coloured box. Negating the need for a legend. 
{stata  plotmatrix, m(R) s(-1(0.25)1) c(red) freq legend(off) plotmatrix, m(R) s(-1(0.25)1) c(red) freq aspect(1) legend(size(*.4) symx(*.4))}

{pstd}
With additional formatting on the cells
{stata plotmatrix, m(R) s(-1(0.25)1) c(red) freq formatcells(%5.2f) aspect(1) legend(size(*.4) symx(*.4))}

{pstd}
Genetic Examples

{pstd}
Plotting the values of a point-wise LD map (see command pwld), with boxes around two areas defined by variables 1-5 and variables 11-18.

{pstd}
  .pwld l1_1-l76_2, mat(grid)

{pstd}
  .plotmatrix, mat(grid) split( 0(0.1)1 ) c(gray) nodiag addbox(1 1 5 5 11 11 18 18)

{pstd}
Using the same data as above there were also map positions within the variable posn. Thus the genomic map could be displayed as a diagonal axis with the
following command

{pstd}
  .plotmatrix , mat(grid) split( 0(0.1)1 ) c(gray) nodiag save l distance(posn) dunit(Mb)

{pstd}

{pstd}

{pstd}

{pstd}
Updating this command

{pstd}
To obtain the latest version click the following to uninstall the old version

{pstd}
{stata ssc uninstall plotmatrix}

{pstd}
And click here to install the new version

{pstd}
{stata ssc install plotmatrix}


{title:Author}
{p}

Prof Adrian Mander, Cardiff University.

Email {browse "mailto:mandera@cardiff.ac.uk":mandera@cardiff.ac.uk}


