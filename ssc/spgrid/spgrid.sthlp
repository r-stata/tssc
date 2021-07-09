{smcl}
{* 4oct2011}{É}
{cmd:help spgrid}{right:Version 1.0.1}
{hline}

{title:Title}

{p 4 11 2}
{hi:spgrid} {hline 2} Generates two-dimensional grids for spatial data analysis{p_end}


{marker syntax}{title:Syntax}

{p 8 15 2}
{cmd:spgrid} [{help using} {help spgrid##section03:{it:studyregion}}]
[{cmd:,}
{help spgrid##options1:{it:options}}]


{synoptset 35 tabbed}{...}
{marker options1}{synopthdr:{help spgrid##options2:options}{col 41}}
{synoptline}
{syntab : Main}
{synopt : {opt sh:ape(gcs)}}grid cell shape, where {it:gcs} is one of
   the following: {cmdab:he:xagonal} (default), {cmdab:sq:uare} {p_end}
{synopt : {cmdab:res:olution(a}{it:#}|{cmd:w}{it:#}{cmd:)}}grid
   resolution {p_end}
{synopt : {opt xd:im(#)}}number of grid columns {p_end}
{synopt : {opt yd:im(#)}}number of grid rows {p_end}
{synopt : {opt u:nit(string)}}grid unit of measurement {p_end}

{syntab : Rectangular study region}
{synopt : {opt xr:ange(xmin xmax)}}minimum and maximum coordinates of the
   horizontal side of the study region {p_end}
{synopt : {opt yr:ange(ymin ymax)}}minimum and maximum coordinates of the
   vertical side of the study region {p_end}

{syntab : Non-rectangular study region}
{synopt : {cmdab:mapid(}{help varname:{it:mapid}}{cmd:)}}set to {it:mapid}
   the name of the variable that, in the output dataset {it:gridpoints},
   stores the identifier of the study region polygon corresponding to each
   grid cell {p_end}
{synopt : {cmdab:mapex:clude(}{help spgrid##section03:{it:mapex}}{cmd:)}}exclude
   from the analysis the subareas of the study region defined in Stata dataset
   {it:mapex} {p_end}
{synopt : {opt idex:clude}}exclude subareas defined in dataset {it:mapex} on
   the basis of their identifier {p_end}

{syntab : Reporting}
{synopt : {opt d:ots}}display job progression dots {p_end}
{synopt : {opt noverb:ose}}suppress display of job progression {p_end}

{syntab: Saving results}
{p2coldent :* {cmdab:c:ells(}{help spgrid##section04:{it:gridcells}}{cmd:)}}save
   grid cells definition to Stata dataset {it:gridcells} {p_end}
{p2coldent :* {cmdab:p:oints(}{help spgrid##section04:{it:gridpoints}}{cmd:)}}save
   grid cells identifiers and grid points coordinates to Stata dataset
   {it:gridpoints} {p_end}
{synopt : {opt compress}}save only valid grid cells {p_end}
{synopt : {opt replace}}overwrite datasets {it:gridpoints} and
   {it:gridcells} if already existing {p_end}
{synoptline}
{p 4 6 2}* Required option {p_end}


{marker desc}{title:Description}

{pstd} {cmd:spgrid} generates two-dimensional grids that can be used by
       other Stata programs to carry out several kinds of spatial data
       analysis, e.g., kernel density and intensity estimation for
       two-dimensional spatial point patterns as implemented in the
       user-written Stata program {help spkde}. {p_end}

{pstd} In the context of spatial data analysis, a {it:grid} is a regular
       tessellation of a given two-dimensional study region that divides
       it into a set of contiguous {it:cells} whose centers are referred
       to as the {it:grid points} (Sahr {it:et al.} 2003).
       
{pstd} {cmd:spgrid} can generate both hexagonal and square grids, i.e.,
       grids whose cells are either hexagonal or square. In general,
       hexagonal grids have better properties than square grids. In
       particular, hexagonal cells offer a more compact tessellation
       of the plane, have a lower perimeter-to-area ratio {hline 1} which
       potentially reduces bias due to edge effects {hline 1} and have
       uniform adjacency, i.e., each of them has six adjacent neighbors in
       symmetrically equivalent positions (Sahr {it:et al.} 2003; de Sousa
       {it:et al.} 2006; Birch {it:et al.} 2007). {p_end}

{pstd} {cmd:spgrid} can generate grids covering both
       {help spgrid##section01:rectangular study regions} and 
       {help spgrid##section02:non-rectangular study regions}. The
       latter can be made of one or more polygons, and include
       one or more gaps {hline 1} i.e., subareas to be excluded
       from the analysis. {p_end}


{marker section01}{title:Rectangular study regions}

{pstd} To generate a grid covering a rectangular study region:
       {p_end}

{phang2}{space 1}o{space 2}Specify the size of the study region with options
                           {opt xrange(xmin xmax)} and {opt yrange(ymin ymax)}.
                           {p_end}

{phang2}{space 1}o{space 2}Specify the shape of the grid cells with option
                           {opt shape(gcs)}. {p_end}

{phang2}{space 1}o{space 2}Specify the size of the grid cells, either direcly
                           with option {cmd:resolution(a}{it:#}|{cmd:w}{it:#}{cmd:)},
                           or indirectly with one of options {opt xdim(#)} and
                           {opt ydim(#)}. {p_end}


{marker section02}{title:Non-rectangular study regions}

{pstd} To generate a grid covering a non-rectangular study region:
       {p_end}

{phang2}{space 1}o{space 2}Specify the {help spgrid##syntax:using} dataset
                           {help spgrid##section03:{it:studyregion}}, i.e.,
                           the dataset that defines the study region. {p_end}

{phang2}{space 1}o{space 2}Specify the shape of the grid cells with option
                           {opt shape(gcs)}. {p_end}

{phang2}{space 1}o{space 2}Specify the size of the grid cells, either direcly
                           with option {cmd:resolution(a}{it:#}|{cmd:w}{it:#}{cmd:)},
                           or indirectly with one of options {opt xdim(#)} and
                           {opt ydim(#)}. {p_end}

{phang2}{space 1}o{space 2}If needed, specify the subareas of the study region
                           to be excluded from the analysis with option
                           {cmd:mapexclude(}{help spgrid##section03:{it:mapex}}{cmd:)}
                           {hline 1} and, possibly, option {cmd:idexclude}. {p_end}


{marker section03}{title:Input datasets}

{pstd} As mentioned above, when requested to generate a grid covering a
       non-rectangular study region, {cmd:spgrid} requires that the
       {help spgrid##syntax:using} dataset {it:studyregion} be
       specified. Whenever the study region contains gaps {hline 1}
       i.e., subareas to be excluded from the analysis {hline 1} the
       dataset {it:mapex} must also be specified via option
       {opt mapexclude(mapex)}. {p_end}
 
{pstd} {it:studyregion} is a Stata dataset that contains the definition
       of the polygon(s) making up the study region of interest. Such
       definition must follow the format of a
       {help spmap##spatdata:spmap {it:basemap} dataset}. {p_end}

{pstd} {it:mapex} is a Stata dataset that contains the definition of the
       subareas of {it:studyregion} to be excluded from the analysis. Such
       definition must follow the format of a
       {help spmap##spatdata:spmap {it:basemap} dataset}. {p_end}


{marker section04}{title:Output datasets}

{pstd} {cmd:spgrid} routinely generates two Stata datasets that can then be
       used by other Stata programs to carry out several kinds of spatial
       data analysis: {it:gridcells} and {it:gridpoints}. {p_end}

{pstd} {it:gridcells} is a Stata dataset that contains the definition of the
       cells making up the grid. Its format corresponds to that of a
       {help spmap##spatdata:spmap {it:basemap} dataset}. {p_end}
 
{pstd} {it:gridpoints} is a Stata dataset that contains the identifiers of the
       grid cells and the coordinates of the corresponding grid
       points. Specifically, {it:gridpoints} includes the following
       variables: {p_end}

{phang2}{space 1}o{space 2}{bf:spgrid_id} is a numeric variable that uniquely
                           identifies the cells making up the grid. {p_end}

{phang2}{space 1}o{space 2}{bf:spgrid_xdim} is an integer variable that
                           identifies the x-dimension (column) of each
                           grid cell. {p_end}

{phang2}{space 1}o{space 2}{bf:spgrid_ydim} is an integer variable that
                           identifies the y-dimension (row) of each
                           grid cell. {p_end}

{phang2}{space 1}o{space 2}{bf:spgrid_status} is an indicator variable that
                           takes value 1 when the corresponding grid cell is
                           valid {hline 1} i.e., lies within the study region
                           {hline 1} and value 0 otherwise. {p_end}

{phang2}{space 1}o{space 2}{bf:spgrid_xcoord} is a numeric variable that
                           contains the x-coordinate of each grid point.
                           {p_end}

{phang2}{space 1}o{space 2}{bf:spgrid_ycoord} is a numeric variable that
                           contains the y-coordinate of each grid point.
                           {p_end}

{phang2}{space 1}o{space 2}{it:mapid} is a numeric variable {hline 1}
                           specified via option {opt mapid(mapid)}
                           {hline 1} that contains the identifier of the
                           study region polygon corresponding to each
                           grid cell. {p_end}


{marker options2}{title:Options}

{dlgtab:Main}

{phang}
{opt shape(gcs)} specifies the shape of the grid cells.

{phang2}{cmd:shape(hexagonal)} is the default and requests that the
   grid cells be hexagonal. {p_end}

{phang2}{cmd:shape(square)} requests that the grid cells be square. {p_end}

{phang}
{cmd:resolution(a}{it:#}|{cmd:w}{it:#}{cmd:)} specifies the resolution
   of the grid, i.e., the size of the grid cells. {p_end}

{phang2}{cmd:resolution(a}{it:#}{cmd:)} requests that the grid cells
   have area {it:#}. {p_end}

{phang2}{cmd:resolution(w}{it:#}{cmd:)} requests that the grid cells
   have width {it:#}. When option {cmd:shape(hexagonal)} is specified,
   the cell width corresponds to the diameter of the circle inscribed
   in the hexagon. When option {cmd:shape(square)} is specified, the
   cell width corresponds to the length of the side of the square. {p_end}

{phang}
{opt xdim(#)} specifies the number of grid columns. {p_end}

{phang}
{opt ydim(#)} specifies the number of grid rows. {p_end}

{phang}
{opt unit(string)} specifies the unit of measurement (e.g., miles,
   kilometers, meters, pixels) of the grid. The default is a generic
   {cmd:unit(units)}. {p_end}

{dlgtab:Rectangular study region}

{phang}
{opt xrange(xmin xmax)} specifies the minimum ({it:xmin}) and the
   maximum ({it:xmax}) coordinates of the horizontal side of the
   study region. {p_end}

{phang}
{opt yrange(ymin ymax)} specifies the minimum ({it:ymin}) and the
   maximum ({it:ymax}) coordinates of the vertical side of the
   study region. {p_end}


{dlgtab:Non-rectangular study region}

{phang}
{opt mapid(mapid)} specifies the name of the numeric variable that, in
   dataset {help spgrid##section04:{it:gridpoints}}, will contain the
   identifier of the study region polygon corresponding to each grid
   cell. The default is {cmd:mapid(spgrid_mapid)}. {p_end}

{phang}
{opt mapexclude(mapex)} requests that the subareas of the study region defined
   in dataset {help spgrid##section03:{it:mapex}} be excluded from the
   analysis. {p_end}

{phang}
{cmd:idexclude} requests that the subareas of the study region defined with
   option {opt mapexclude(mapex)} be excluded from the analysis not on the
   basis of their geometry (the default), but on the basis of their
   identifier. {p_end}

{dlgtab:Reporting}

{phang}
{cmd:dots} requests that job progression dots be displayed. {p_end}

{phang}
{cmd:noverbose} requests that the display of every indicator of job
   progression be suppressed. {p_end}

{dlgtab:Saving results}

{phang}
{opt cells(gridcells)} requests that the definition of the grid cells be
   saved to dataset {help spgrid##section04:{it:gridcells}}. {p_end}

{phang}
{opt points(gridpoints)} requests that the identifiers of the grid cells
   and the coordinates of the corresponding grid points be saved to dataset
   {help spgrid##section04:{it:gridpoints}}. {p_end}

{phang}
{opt compress} requests that only the valid grid cells be saved to
   datasets {help spgrid##section04:{it:gridcells}} and
   {help spgrid##section04:{it:gridpoints}}. {p_end}

{phang}
{opt replace} requests that datasets {help spgrid##section04:{it:gridcells}}
   and {help spgrid##section04:{it:gridpoints}} be overwritten if already
   existing. {p_end}


{title:Examples}
{cmd}
    . spgrid, xrange(0 500) yrange(0 200) resolution(w10)   ///
        cells("GridCells.dta") points("GridPoints.dta")     ///
        replace dots
    . use "GridPoints.dta", clear
    . spmap using "GridCells.dta", id(spgrid_id)

    . spgrid, xrange(0 500) yrange(0 200) shape(square) xdim(50)   ///
        cells("GridCells.dta") points("GridPoints.dta")            ///
        replace dots
    . use "GridPoints.dta", clear
    . spmap using "GridCells.dta", id(spgrid_id)

    . spgrid using "Italy-OutlineCoordinates.dta",   ///
        resolution(w10) unit(kilometers)             ///
        cells("Italy-GridCells.dta")                 ///
        points("Italy-GridPoints.dta")               ///
        replace dots
    . use "Italy-GridPoints.dta", clear
    . spmap using "Italy-GridCells.dta", id(spgrid_id)   ///
        polygon(data("Italy-OutlineCoordinates.dta")     ///
        ocolor(red) osize(thick))

    . spgrid using "Italy-OutlineCoordinates.dta",   ///
        resolution(w10) unit(kilometers)             ///
        cells("Italy-GridCells.dta")                 ///
        points("Italy-GridPoints.dta")               ///
        replace compress dots
    . use "Italy-GridPoints.dta", clear
    . spmap using "Italy-GridCells.dta", id(spgrid_id)   ///
        polygon(data("Italy-OutlineCoordinates.dta")     ///
        ocolor(red) osize(medthick))

    . spgrid using "Italy-OutlineCoordinates.dta",   ///
        resolution(w10) unit(kilometers)             ///
        mapexclude("Italy-Exclude.dta")              ///
        cells("Italy-GridCells.dta")                 ///
        points("Italy-GridPoints.dta")               ///
        replace compress dots
    . use "Italy-GridPoints.dta", clear
    . spmap using "Italy-GridCells.dta", id(spgrid_id)   ///
        polygon(data("Italy-OutlineCoordinates.dta")     ///
        ocolor(red) osize(medthick))
{txt}

{title:Author}

{p 4} Maurizio Pisati {p_end}
{p 4} Department of Sociology and Social Research {p_end}
{p 4} University of Milano Bicocca - Italy {p_end}
{p 4} {browse "mailto:maurizio.pisati@unimib.it":maurizio.pisati@unimib.it}


{title:References}

{p 4 8 2}Birch, C.P.D., Oom, S.P. and J.A. Beecham. 2007. Rectangular and
         Hexagonal Grids Used for Observation, Experiment and Simulation in
         Ecology. {it:Ecological Modelling} 206: 347{c -}359.

{p 4 8 2}de Sousa, L., Nery, F., Sousa, R. and J. Matos. 2006. Assessing the
         Accuracy of Hexagonal versus Square Tiled Grids in Preserving DEM
         Surface Flow Directions. In {it:Proceedings of the 7th International}
         {it:Symposium on Spatial Accuracy Assessment in Natural Resources}
         {it:and Environmental Sciences}, 5{c -}7 July, Lisboa, Portugal,
         ed. M. Caetano and M. Pinho, 191{c -}200.

{p 4 8 2}Sahr, K., White, D. and A.J. Kimerling. 2003. Geodesic Discrete
         Global Grid Systems. {it:Cartography and Geographic Information}
         {it:Science} 30: 121{c -}134.


{title:Also see}

{psee}
Online:  {helpb spkde} (if installed), {helpb spmap} (if installed)
{p_end}
