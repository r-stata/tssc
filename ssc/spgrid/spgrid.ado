*! -spgrid-: Generates two-dimensional grids for spatial data analysis         
*! Version 1.0.1 - 4 October 2011                                              
*! Version 1.0.0 - 3 February 2009                                             
*! Author: Maurizio Pisati                                                     
*! Department of Sociology and Social Research                                 
*! University of Milano Bicocca (Italy)                                        
*! maurizio.pisati@unimib.it                                                   




*  ----------------------------------------------------------------------------
*  1. Define program                                                           
*  ----------------------------------------------------------------------------

program spgrid
version 10.1




*  ----------------------------------------------------------------------------
*  2. Define syntax                                                            
*  ----------------------------------------------------------------------------

syntax [using/],                            ///
       [SHape(string)]                      /// hexagonal,square
       [RESolution(string)]                 ///
       [XDim(numlist max=1 >0 integer)]     ///
       [YDim(numlist max=1 >0 integer)]     ///
       [Unit(string)]                       ///
                                            ///
       [XRange(numlist min=2 max=2 sort)]   ///
       [YRange(numlist min=2 max=2 sort)]   ///
                                            ///
       [MAPID(name)]                        ///
       [MAPEXclude(string)]                 ///
       [IDEXclude]                          ///
                                            ///
       [Dots]                               ///
       [noVERBose]                          ///
                                            ///
        Cells(string)                       ///
        Points(string)                      ///
       [COMPRESS]                           ///
       [REPLACE]




*  ----------------------------------------------------------------------------
*  3. Check syntax                                                             
*  ----------------------------------------------------------------------------

/* Check using file */
local map "`using'"
if ("`map'" != "") {
   if (substr(reverse("`map'"),1,4) != "atd.") {
      local map "`map'.dta"
   }
   capture confirm file "`map'"
   if _rc {
      di as err "{p}File {bf:`map'} not found {p_end}"
      exit 601
   }
   preserve
   qui use "`map'", clear
   local BAD = 0
   cap confirm numeric variable _ID _X _Y
   local BAD = `BAD' + _rc
   local SORTVAR: sortedby
   local SORTVAR : word 1 of `SORTVAR'
   if ("`SORTVAR'" != "_ID") local BAD = `BAD' + 1
   if (`BAD') {
      di as err "{p}File {bf:`map'} is not a valid "       ///
                "{help spmap##sd_basemap:{it:basemap}} "   ///
                "dataset {p_end}"
      exit 198
   }
   restore
}


/* Check option shape() */
if ("`shape'" != "") {
   local KLIST "square hexagonal"
   local LEN = length("`shape'")
   if (`LEN' < 2) {
      di as err "{p}Keywords specified in option {bf:{ul:sh}ape()} "     ///
                "cannot be abbreviated to less than 2 letters {p_end}"
      exit 198
   }
   local OK = 0
   foreach K of local KLIST { 
      if ("`shape'" == substr("`K'", 1, `LEN')) {
  	      local OK = 1
         local shape "`K'"
         continue, break
      }
   }
   if (!`OK') {
      di as err "{p}Option {bf:{ul:s}hape()} accepts only "   ///
                "one of the following keywords: "             ///
                "{bf:{ul:sq}uare} "                           ///
                "{bf:{ul:he}xagonal} "                        ///
                "{p_end}"
      exit 198
   }
}


/* Check options resolution(), xdim(), and ydim() */
if ("`resolution'" == "" & "`xdim'" == "" & "`ydim'" == "") {
   di as err "{p}You are requested to specify one of the "     ///
             "following options: {bf:{ul:res}olution()}, "     ///
             "{bf:{ul:xd}im()}, or {bf:{ul:yd}im()} {p_end}"
   exit 198
}
if ("`resolution'" != "" & "`xdim'" != "") {
   di as err "{p}Options {bf:{ul:res}olution()} and {bf:{ul:xd}im()} "   ///
             "cannot be specified together {p_end}"
   exit 198
}
if ("`resolution'" != "" & "`ydim'" != "") {
   di as err "{p}Options {bf:{ul:res}olution()} and {bf:{ul:yd}im()} "   ///
             "cannot be specified together {p_end}"
   exit 198
}
if ("`xdim'" != "" & "`ydim'" != "") {
   di as err "{p}Options {bf:{ul:xd}im()} and {bf:{ul:yd}im()} "   ///
             "cannot be specified together {p_end}"
   exit 198
}


/* Check option resolution() */
if ("`resolution'" != "") {
   local BAD = 0
   local RESTYPE = substr("`resolution'",1,1)
   local RESSIZE = substr("`resolution'",2,.)
   if !inlist("`RESTYPE'","a","w") local BAD = `BAD' + 1
   qui cap confirm number `RESSIZE'
   local BAD = cond(_rc, `BAD' + 1, `BAD' + (`RESSIZE'<=0))
   if (`BAD') {
      di as err "{p}Option {bf:{ul:res}olution()} accepts only "   ///
                "one of the following keywords: "                  ///
                "{bf:a#} "                                         ///
                "{bf:w#}, "                                        ///
                "where {bf:#} represents a positive number"        ///
                "{p_end}"
      exit 198
   }
}


/* Check options xrange() and yrange() */
if ("`map'" == "") & ("`xrange'" == "" | "`yrange'" == "") {
   di as err "{p}You are requested to specify options "            ///
             "{bf:{ul:xr}ange()} and {bf:{ul:yr}ange()} {p_end}"
   exit 198 
}


/* Check option mapid() */
if ("`map'" != "") &                 ///
   ("`mapid'" == "spgrid_id"     |   ///
    "`mapid'" == "spgrid_xdim"   |   ///
    "`mapid'" == "spgrid_ydim"   |   ///
    "`mapid'" == "spgrid_xcoord" |   ///
    "`mapid'" == "spgrid_ycoord" |   ///
    "`mapid'" == "spgrid_data") {
   di as err "{p}Option {bf:{ul:mapid}()} cannot accept as argument "     ///
             "the following reserved words: {bf:spgrid_id}, "             ///
             "{bf:spgrid_xdim}, {bf:spgrid_ydim}, {bf:spgrid_xcoord}, "   ///
             "{bf:spgrid_ycoord}, {bf:spgrid_status} {p_end}"
   exit 198
}


/* Check option mapexclude() */
if ("`map'" != "") & ("`mapexclude'" != "") {
   if (substr(reverse("`mapexclude'"),1,4) != "atd.") {
      local mapexclude "`mapexclude'.dta"
   }
   capture confirm file "`mapexclude'"
   if _rc {
      di as err "{p}File {bf:`mapexclude'} specified in option "   ///
                "{bf:{ul:mapex}clude()} not found {p_end}"
      exit 601
   }
   preserve
   qui use "`mapexclude'", clear
   local BAD = 0
   if ("`idexclude'" == "") {
      cap confirm numeric variable _ID _X _Y
      local BAD = `BAD' + _rc
      local SORTVAR: sortedby
      local SORTVAR : word 1 of `SORTVAR'
      if ("`SORTVAR'" != "_ID") local BAD = `BAD' + 1
   }
   if ("`idexclude'" != "") {
      cap confirm numeric variable _ID
      local BAD = `BAD' + _rc
   }
   if (`BAD') {
      di as err "{p}File {bf:`mapexclude'} specified in option "   ///
                "{bf:{ul:mapex}clude()} is not a valid "           ///
                "{help spmap##sd_basemap:{it:basemap}} "           ///
                "dataset {p_end}"
      exit 198
   }
   restore
}


/* Check option cells() */
if (substr(reverse("`cells'"),1,4) != "atd.") {
   local cells "`cells'.dta"
}
cap confirm file "`cells'"
if (_rc == 0) & ("`replace'" == "") {
   di as err "{p}File {bf:`cells'} specified in option "   ///
             "{bf:{ul:c}ells()} already exists {p_end}"
   exit 602
}


/* Check option points() */
if (substr(reverse("`points'"),1,4) != "atd.") {
   local points "`points'.dta"
}
cap confirm file "`points'"
if (_rc == 0) & ("`replace'" == "") {
   di as err "{p}File {bf:`points'} specified in option "   ///
             "{bf:{ul:p}oints()} already exists {p_end}"
   exit 602
}
if ("`points'" == "`cells'") {
   di as err "{p}Options {bf:{ul:p}oints()} and {bf:{ul:c}ells()} "   ///
             "cannot accept the same argument {p_end}"
   exit 198
}




*  ----------------------------------------------------------------------------
*  4. Define basic objects                                                     
*  ----------------------------------------------------------------------------

/* Set default cell shape */
if ("`shape'" == "") local shape "hexagonal"

/* Set default unit of measure */
if ("`unit'" == "") local unit "units"

/* Set default mapid name */
if ("`map'" != "" & "`mapid'" == "") local mapid "spgrid_mapid"

/* Set option dots */
if ("`verbose'" != "") local dots ""




*  ----------------------------------------------------------------------------
*  5. Create gridpoints dataset                                                
*  ----------------------------------------------------------------------------

/* Define grid limits and size */
if ("`map'" == "") {
   local XMIN : word 1 of `xrange'
   local XMAX : word 2 of `xrange'
   local YMIN : word 1 of `yrange'
   local YMAX : word 2 of `yrange'
}
if ("`map'" != "") {
   preserve
   qui use "`map'", clear
   su _X, mean
   local XMIN = r(min)
   local XMAX = r(max)
   su _Y, mean
   local YMIN = r(min)
   local YMAX = r(max)
   restore
}
local XSIZE = `XMAX' - `XMIN'
local YSIZE = `YMAX' - `YMIN'


/* Define grid resolution and dimensions */
if ("`resolution'" != "") {
   if ("`shape'" == "square") {
      if ("`RESTYPE'" == "a") {
         local AREA = `RESSIZE'
         local SIDE = sqrt(`AREA')
      }
      if ("`RESTYPE'" == "w") {
         local SIDE = `RESSIZE'
         local AREA = `SIDE'^2
      }
      local XRES = `SIDE'
      local YRES = `SIDE'
      local XDIM = round(`XSIZE' / `XRES')
      local YDIM = round(`YSIZE' / `YRES')
   }
   if ("`shape'" == "hexagonal") {
      if ("`RESTYPE'" == "a") {
         local AREA = `RESSIZE'
         local SIDE = sqrt(`AREA' / 2.5980762)
      }
      if ("`RESTYPE'" == "w") {
         local SIDE = `RESSIZE' / 1.7320508
         local AREA = `SIDE'^2 * 2.5980762
      }
      local XRES = `SIDE' * 1.7320508
      local YRES = `SIDE' * 1.5
      local XDIM = round(`XSIZE' / `XRES')
      local YDIM = round(`YSIZE' / `YRES')
   }
}
if ("`resolution'" == "") {
   local ADJ = ("`shape'" == "square") + ("`shape'" == "hexagonal") * 0.8660254
   if ("`xdim'" != "") {
      local XRES = `XSIZE' / `xdim'
      local YRES = `XRES' * `ADJ'
      local XDIM = `xdim'
      local YDIM = round(`YSIZE' / `YRES')
   }
   if ("`ydim'" != "") {
      local YRES = `YSIZE' / `ydim'
      local XRES = `YRES' / `ADJ'
      local XDIM = round(`XSIZE' / `XRES')
      local YDIM = `ydim'
   }
   if ("`shape'" == "square") {
      local SIDE = `XRES'
      local AREA = `SIDE'^2
   }
   if ("`shape'" == "hexagonal") {
      local SIDE = `XRES' / 1.7320508
      local AREA = `SIDE'^2 * 2.5980762
   }
}
local FGC = `XDIM' * `YDIM'


/* Preserve */
preserve


/* Create gridpoints dataset */
if ("`verbose'" == "") {
   di ""
   di as txt "-> Setting up full grid..."
}
clear // was: clear all -- Modification suggested by Philippe Van Kerm
qui set obs `FGC'
qui egen spgrid_xdim = seq(), from(1) to(`XDIM')
qui egen spgrid_ydim = seq(), from(1) to(`YDIM') block(`XDIM')
if ("`shape'" == "square") {
   qui gen spgrid_xcoord = `XMIN' + (`XRES' / 2) + (spgrid_xdim - 1) * `XRES'
   qui gen spgrid_ycoord = `YMAX' - (`YRES' / 2) - (spgrid_ydim - 1) * `YRES'
}
if ("`shape'" == "hexagonal") {
   qui gen spgrid_xcoord = `XMIN' + (`XRES' / 2) + (spgrid_xdim - 1) * `XRES' +   ///
                           (`XRES' / 2) * !mod(spgrid_ydim, 2)
   qui gen spgrid_ycoord = `YMAX' - (`YRES' - `XRES' / 3.464) -   ///
                           (spgrid_ydim - 1) * `YRES'
}
qui gen spgrid_status = 1
qui gen spgrid_id = _n
order spgrid_id
lab var spgrid_id "Grid cell: id number"
lab var spgrid_xdim "Grid cell: x-dimension"
lab var spgrid_ydim "Grid cell: y-dimension"
lab var spgrid_xcoord "Grid point: x-coordinate"
lab var spgrid_ycoord "Grid point: y-coordinate"
lab var spgrid_status "Grid cell: 1=valid 0=null"


/* Clip grid cells outside the map boundaries */
if ("`map'" != "") {
   tempvar CIP MAPID
   qui gen `CIP' = .
   qui gen `MAPID' = .
   tempfile F0
   qui save `F0', replace
   use "`map'", clear
   keep _ID _X _Y
   gen POLY = (_X == .)
   qui replace POLY = sum(POLY)
   qui drop if _X == .
   order _X _Y
   tempfile F1
   qui save `F1', replace
   rename POLY poly
   gen IDX = _n
   collapse (mean) MID=_ID                     ///
            (min) first=IDX (max) last=IDX     ///
            (min) xmin=_X (max) xmax=_X        ///
            (min) ymin=_Y (max) ymax=_Y        ///
            , by(poly)
   tempfile F2
   qui save `F2', replace
   use `F0', clear
   qui merge using `F2'
   drop _merge
   qui merge using `F1'
   drop _merge _ID POLY
   su poly, mean
   local NPOLY = r(N)
   if ("`verbose'" == "") {
      di as txt "-> Clipping grid cells outside the boundaries " _c
      di as txt "of the study region..."
   }
   if ("`dots'" != "") {
      di as txt ""
   }
   mata: spgridClip(`FGC', `NPOLY', "`dots'")
   qui replace spgrid_status = 0 if `CIP' == .
   keep spgrid_* `CIP' `MAPID'
   qui drop if (spgrid_id == .)
   qui replace `CIP' = .
}


/* Clip grid cells within specified map polygons */
if ("`map'" != "") & ("`mapexclude'" != "") {
   if ("`verbose'" == "") {
      di as txt "-> Clipping grid cells within specified subareas " _c
      di as txt "of the study region..."
   }
   if ("`idexclude'" != "") {
      sort `MAPID'
      tempfile F0
      qui save `F0', replace
      use "`mapexclude'", clear
      qui collapse _X, by(_ID)
      ren _ID `MAPID'
      keep `MAPID'
      sort `MAPID'
      tempfile F1
      qui save `F1', replace
      use `F0', clear
      qui merge `MAPID' using `F1'
      qui drop if (_merge == 2)
      qui replace spgrid_status = 0 if _merge == 3
      drop _merge
   }
   else {
      tempfile F0
      qui save `F0', replace
      use "`mapexclude'", clear
      keep _ID _X _Y
      gen POLY = (_X == .)
      qui replace POLY = sum(POLY)
      qui drop if _X == .
      order _X _Y
      tempfile F1
      qui save `F1', replace
      rename POLY poly
      gen IDX = _n
      collapse (mean) MID=_ID                     ///
               (min) first=IDX (max) last=IDX     ///
               (min) xmin=_X (max) xmax=_X        ///
               (min) ymin=_Y (max) ymax=_Y        ///
               , by(poly)
      tempfile F2
      qui save `F2', replace
      use `F0', clear
      qui merge using `F2'
      drop _merge
      qui merge using `F1'
      drop _merge _ID POLY
      su poly, mean
      local NPOLY = r(N)
      if ("`dots'" != "") {
         di as txt ""
      }
      mata: spgridClip(`FGC', `NPOLY', "`dots'")
      qui replace spgrid_status = 0 if `CIP' == 1
      keep spgrid_* `CIP' `MAPID'
      qui drop if (spgrid_id == .)
   }
}


/* Save gridpoints dataset */
if ("`verbose'" == "") {
   di as txt "-> Saving gridpoints dataset..."
}
if ("`map'" != "") {
   qui gen `mapid' = `MAPID'
   lab var `mapid' "Grid cell: corresponding study region polygon identifier"
   drop `CIP' `MAPID'
}
su spgrid_status, mean
local VGC = r(sum)

local CHARLIST : char _dta[]
foreach CHAR in local `CHARLIST' {
   char _dta[`CHAR']
}
char _dta[basemap] "`map'"
char _dta[exclmap] "`mapexclude'"
char _dta[UnitOfMeasure] "`unit'"
char _dta[xmin] `XMIN'
char _dta[xmax] `XMAX'
char _dta[ymin] `YMIN'
char _dta[ymax] `YMAX'
char _dta[xsize] `XSIZE'
char _dta[ysize] `YSIZE'
char _dta[xdim] `XDIM'
char _dta[ydim] `YDIM'
char _dta[xres] `XRES'
char _dta[yres] `YRES'
char _dta[CellShape] "`shape'"
char _dta[CellSide] `SIDE'
char _dta[CellArea] `AREA'
char _dta[FullGridCells] `FGC'
char _dta[ValidGridCells] `VGC'
if ("`compress'" != "") qui keep if spgrid_status
sort spgrid_id
qui compress
order spgrid_id spgrid_xdim spgrid_ydim spgrid_status `mapid'   ///
      spgrid_xcoord spgrid_ycoord
qui save "`points'", `replace'




*  ----------------------------------------------------------------------------
*  6. Create gridcells dataset                                                 
*  ----------------------------------------------------------------------------

/* Create gridcells dataset */
if ("`verbose'" == "") {
   di as txt "-> Saving gridcells dataset..."
}
keep spgrid_id spgrid_xcoord spgrid_ycoord
local NC = cond("`compress'" != "", `VGC', `FGC')
local NR = cond("`shape'" == "square", `NC' * 6, `NC' * 8)
qui set obs `NR'
qui gen _ID=.
qui gen _X=.
qui gen _Y=.
lab var _ID "Grid cell: id number"
lab var _X "Grid cell: x-coordinates"
lab var _Y "Grid cell: y-coordinates"
local ADJ = cond("`shape'" == "square", 2, 3)
local X = `XRES' / 2
local Y = `YRES' / `ADJ'
mata: spgridCells(`NC', `NR', "`shape'", `X',`Y')
keep _*


/* Save gridcells dataset */
sort _ID, stable
qui compress
qui save "`cells'", `replace'




*  ----------------------------------------------------------------------------
*  7. Display summary grid features                                            
*  ----------------------------------------------------------------------------

if ("`verbose'" == "") {
   local STUDRES = cond("`map'" == "", "rectangular", "non-rectangular")
   if ("`mapexclude'" != "") local STUDRES "`STUDRES' with gaps"
   di as txt ""
   di as txt "   Study region: " as res "`STUDRES'"
   di as txt "   Full grid size: "  as res `XSIZE'  as txt " x "   ///
      as res `YSIZE'  as txt " `unit'"
   di as txt "   Full grid limits: ["  as res `XMIN'  as txt ","   ///
      as res `XMAX'  as txt "] x ["  as res `YMIN'  as txt ","     ///
      as res `YMAX'  as txt "]"  as txt " `unit'"
   di as txt "   Number of full grid cells: "  as res `FGC'
   di as txt "   Number of valid grid cells: "  as res `VGC'
   di as txt "   Cell shape: "  as res "`shape'"
   di as txt "   Cell side: "  as res `SIDE'  as txt " `unit'"
   di as txt "   Cell area: "  as res `AREA'  as txt " squared `unit'"
}




*  ----------------------------------------------------------------------------
*  8. End program                                                              
*  ----------------------------------------------------------------------------

restore
end








*  ----------------------------------------------------------------------------
*  Mata functions                                                              
*                                                                              
*  : spgridClip()                                                              
*  : spgridCells()                                                             
*  : sp_*()                                                                    
*  ----------------------------------------------------------------------------

version 10.1
mata:
mata clear
mata set matastrict on




//*****************************************************************************
//*  spgridClip()                                                             *
//*  --> sp_dots1()                                                           *
//*  --> sp_dots2()                                                           *
//*  --> sp_pips()                                                            *
//*****************************************************************************

void spgridClip(real scalar nc, real scalar np, string scalar dots)
{


/* Setup */
real scalar   c, x, y, p, xmin, xmax, ymin, ymax, fp, lp
real matrix   POLY

/* Scan grid cells */
if (dots != "") sp_dots1("Grid cells", nc)
for (c=1; c<=nc; c++) {
   if (dots != "") sp_dots2(c, nc)
   if (_st_data(c, 6) == 1) {
      x = _st_data(c, 4)
      y = _st_data(c, 5)
      for (p=1; p<=np; p++) {
         xmin = _st_data(p, 13)
         xmax = _st_data(p, 14)
         ymin = _st_data(p, 15)
         ymax = _st_data(p, 16)
         if (x>=xmin & x<=xmax & y>=ymin & y<=ymax) {
            fp = _st_data(p, 11)
            lp = _st_data(p, 12)
            POLY = st_data((fp,lp), (17,18))
            if (sp_pips(x, y, POLY)) {
               st_store(c, 7, 1)
               st_store(c, 8, _st_data(p, 10))
               break
            }
         }
      }
   }
}


}




//*****************************************************************************
//*  spgridCells()                                                            *
//*****************************************************************************

void spgridCells(real scalar nc, real scalar nr, string scalar shape,
                 real scalar x, real scalar y)
{


/* Setup */
real scalar      r, i
real colvector   ID, X, Y

/* Generate working objects */
st_view(ID=., (1,nr), 4)
st_view( X=., (1,nr), 5)
st_view( Y=., (1,nr), 6)

/* Generate grid cells */
r = 1
for (i=1; i<=nc; i++) {
   if (shape == "square") {
      /* Dummy record */
      ID[r] = _st_data(i, 1)
      r++
      /* South-West */
      ID[r] = _st_data(i, 1)
      X[r]  = _st_data(i, 2) - x
      Y[r]  = _st_data(i, 3) - y
      r++
      /* North-West */
      ID[r] = _st_data(i, 1)
      X[r]  = _st_data(i, 2) - x
      Y[r]  = _st_data(i, 3) + y
      r++
      /* North-East */
      ID[r] = _st_data(i, 1)
      X[r]  = _st_data(i, 2) + x
      Y[r]  = _st_data(i, 3) + y
      r++
      /* South-East */
      ID[r] = _st_data(i, 1)
      X[r]  = _st_data(i, 2) + x
      Y[r]  = _st_data(i, 3) - y
      r++
      /* South-West */
      ID[r] = _st_data(i, 1)
      X[r]  = _st_data(i, 2) - x
      Y[r]  = _st_data(i, 3) - y
      r++
   }
   if (shape == "hexagonal") {
      /* Dummy record */
      ID[r] = _st_data(i, 1)
      r++
      /* South */
      ID[r] = _st_data(i, 1)
      X[r]  = _st_data(i, 2)
      Y[r]  = _st_data(i, 3) - y * 2
      r++
      /* South-West */
      ID[r] = _st_data(i, 1)
      X[r]  = _st_data(i, 2) - x
      Y[r]  = _st_data(i, 3) - y
      r++
      /* North-West */
      ID[r] = _st_data(i, 1)
      X[r]  = _st_data(i, 2) - x
      Y[r]  = _st_data(i, 3) + y
      r++
      /* North */
      ID[r] = _st_data(i, 1)
      X[r]  = _st_data(i, 2)
      Y[r]  = _st_data(i, 3) + y * 2
      r++
      /* North-East */
      ID[r] = _st_data(i, 1)
      X[r]  = _st_data(i, 2) + x
      Y[r]  = _st_data(i, 3) + y
      r++
      /* South-East */
      ID[r] = _st_data(i, 1)
      X[r]  = _st_data(i, 2) + x
      Y[r]  = _st_data(i, 3) - y
      r++
      /* South */
      ID[r] = _st_data(i, 1)
      X[r]  = _st_data(i, 2)
      Y[r]  = _st_data(i, 3) - y * 2
      r++
   }
}


}




//*****************************************************************************
//*  sp_*() - Library of Mata functions for spatial data analysis             *
//*                                                                           *
//*  : sp_dots1                                                               *
//*  : sp_dots2                                                               *
//*  : sp_pips                                                                *
//*****************************************************************************




/** 200808 *******************************************************************/
/*                                                                           */
/*  sp_dots1                                                                 */
/*                                                                           */
/*  Displays header & ruler of dots-type verbose output                      */
/*                                                                           */
/*****************************************************************************/

void sp_dots1(string scalar header, real scalar n)
{


printf("{txt}%s (", header)
printf("{res}%g{txt})\n", n)
printf("{txt}{hline 4}{c +}{hline 3} 1 {hline 3}{c +}{hline 3} 2 ") 
printf("{txt}{hline 3}{c +}{hline 3} 3 {hline 3}{c +}{hline 3} 4 ")
printf("{txt}{hline 3}{c +}{hline 3} 5\n")


}




/** 200808 *******************************************************************/
/*                                                                           */
/*  sp_dots2                                                                 */
/*                                                                           */
/*  Displays iterations of dots-type verbose output                          */
/*                                                                           */
/*****************************************************************************/

void sp_dots2(real scalar i, real scalar n)
{


/* Setup */
real scalar   linenum

/* Display */
linenum = mod(i,50)
if (linenum != 0  &  i < n) {
   printf("{txt}.")
}
if (linenum == 0  &  i < n) {
   printf("{txt}. %5.0f\n", i)
}
if (i == n) {
   printf("{txt}.\n")
   printf("\n")
}


}




/** 200808 *******************************************************************/
/*                                                                           */
/*  sp_pips                                                                  */
/*                                                                           */
/*  Returns a scalar indicating whether the point defined by the coordinate  */
/*  pair (x,y) lies within (value 1) or without (value 0) the polygon        */
/*  defined by the R-by-2 coordinate matrix POLY                             */
/*                                                                           */
/*****************************************************************************/

real scalar sp_pips(real scalar x, real scalar y, real matrix POLY)
{


/* Setup */
real scalar   pip, nv, iwind, xlastp, ylastp, ioldq, inewq
real scalar   xthisp, ythisp, i, a, b

/* Generate working objects */
nv = rows(POLY)
if (POLY[1,1] == POLY[nv,1] & POLY[1,2] == POLY[nv,2]) nv = nv - 1
iwind = 0
xlastp = POLY[nv, 1]
ylastp = POLY[nv, 2]
ioldq = sp_pips_aux(xlastp, ylastp, x, y)

/* Check and report point status */
for (i=1; i<=nv; i++) {
   xthisp = POLY[i, 1]
   ythisp = POLY[i, 2]
   inewq = sp_pips_aux(xthisp, ythisp, x, y)
   if (ioldq != inewq) {
      if (mod(ioldq+1, 4) == inewq) {
         iwind = iwind + 1
      }
      else if (mod(inewq+1, 4) == ioldq) {
         iwind = iwind - 1
      }
      else {
         a = (ylastp - ythisp) * (x - xlastp)
         b = xlastp - xthisp
         a = a + ylastp * b
         b = b * y
         if (a > b) {
            iwind = iwind + 2
         }
         else {
            iwind = iwind - 2
         }
      }
   }
   xlastp = xthisp
   ylastp = ythisp
   ioldq = inewq
}
pip = abs(iwind / 4)

/* Returns results */
return(pip)


}


/* Auxiliary function */
real scalar sp_pips_aux(real scalar xp, real scalar yp, real scalar xo,
                        real scalar yo)
{
real scalar iq
if(xp < xo) {
   if(yp < yo) iq = 2
   else iq = 1
}
else {
   if(yp < yo) iq = 3
   else iq = 0
}
return(iq)
}




//*****************************************************************************
//*  Exit Mata                                                                *
//*****************************************************************************

end



