*! -spkde-: Kernel estimation for two-dimensional spatial point patterns       
*! Version 1.0.0 - 3 February 2009                                             
*! Author: Maurizio Pisati                                                     
*! Department of Sociology and Social Research                                 
*! University of Milano Bicocca (Italy)                                        
*! maurizio.pisati@unimib.it                                                   




*  ----------------------------------------------------------------------------
*  1. Define program                                                           
*  ----------------------------------------------------------------------------

program spkde, sortpreserve
version 10.1




*  ----------------------------------------------------------------------------
*  2. Define syntax                                                            
*  ----------------------------------------------------------------------------

syntax [varlist(numeric default=none)] [if] [in] using/,   ///
        Xcoord(varname numeric)                            ///
        Ycoord(varname numeric)                            ///
       [Kernel(string)]                                    ///
       [TRUNCated(numlist max=1 >0)]                       ///
        Bandwidth(string)                                  ///
                                                           ///
       [FBW(string)]                                       ///
       [NDP(numlist max=1 >0)]                             ///
       [NDPW(varname numeric)]                             ///
       [EDGEcorrection]                                    ///
                                                           ///
       [Dots]                                              ///
       [noVERBose]                                         ///
                                                           ///
        SAVing(string asis)




*  ----------------------------------------------------------------------------
*  3. Check syntax                                                             
*  ----------------------------------------------------------------------------

/* Check varlist */
local VARLIST "`varlist'"
if ("`VARLIST'" != "") {
   unab VARLIST: `VARLIST'
}
if ("`varlist'" == "") {
   tempvar POINTS
   qui gen `POINTS' = 1
   local varlist "`POINTS'"
}


/* Check using file */
if (substr(reverse("`using'"),1,4) != "atd.") local using "`using'.dta"
capture confirm file "`using'"
if _rc {
   di as err "{p}File {bf:`using'} not found {p_end}"
   exit 601
}
preserve
qui use "`using'", clear
cap confirm numeric variable spgrid_id spgrid_xcoord spgrid_ycoord spgrid_status
if _rc {
   di as err "{p}File {bf:`using'} is not a valid {it:gridpoints} dataset {p_end}"
   exit 198
}
qui drop if spgrid_id == .
qui drop if spgrid_xcoord == .
qui drop if spgrid_ycoord == .
qui drop if spgrid_status == 0
local VGC = `_dta[ValidGridCells]'
qui count
local G = r(N)
if (`VGC' != `G') {
   di as err "{p}File {bf:`using'} is not a valid {it:gridpoints} dataset {p_end}"
   exit 198
}
local CHECK = `_dta[CellArea]'
if ("`CHECK'" == "") {
   di as err "{p}File {bf:`using'} is not a valid {it:gridpoints} dataset {p_end}"
   exit 198
}
local CHECK "`_dta[UnitOfMeasure]'"
if ("`CHECK'" == "") {
   di as err "{p}File {bf:`using'} is not a valid {it:gridpoints} dataset {p_end}"
   exit 198
}
tempvar ID X Y
qui clonevar `ID' = spgrid_id
qui clonevar `X'  = spgrid_xcoord
qui clonevar `Y'  = spgrid_ycoord
keep `ID' `X' `Y'
sort `ID'
tempfile GRID
qui save `GRID', replace
restore


/* Check option kernel() */
if ("`kernel'" != "") {
   local KLIST "uniform normal negexp quartic triangular epanechnikov"
   local LEN = length("`kernel'")
   if (`LEN' < 2) {
      di as err "{p}The argument of option {bf:{ul:k}ernel()} cannot be "   ///
                "abbreviated to less than 2 letters {p_end}"
      exit 198
   }
   local OK = 0
   foreach K of local KLIST { 
      if ("`kernel'" == substr("`K'", 1, `LEN')) {
         local OK = 1
         local kernel "`K'"
         continue, break
      }
   }
   if (!`OK') {
      di as err "{p}Option {bf:{ul:k}ernel()} accepts only "   ///
                "one of the following arguments: "             ///
                "{bf:{ul:un}iform} "                           ///
                "{bf:{ul:no}rmal} "                            ///
                "{bf:{ul:ne}gexp} "                            ///
                "{bf:{ul:qu}artic} "                           ///
                "{bf:{ul:tr}iangular} "                        ///
                "{bf:{ul:ep}anechnikov} "                      ///
                "{p_end}"
      exit 198
   }
}


/* Check option bandwidth() */
local KLIST "fbw ndp mixed"
local LEN = length("`bandwidth'")
if (`LEN' < 3) {
   di as err "{p}The argument of option {bf:{ul:b}andwidth()} cannot "   ///
             "be abbreviated to less than 3 letters {p_end}"
   exit 198
}
local OK = 0
foreach K of local KLIST {
   if ("`bandwidth'" == substr("`K'", 1, `LEN')) {
      local OK = 1
      local bandwidth "`K'"
      continue, break
   }
}
if (!`OK') {
   di as err "{p}Option {bf:{ul:b}andwidth()} accepts only "   ///
             "one of the following arguments: "                ///
             "{bf:fbw} "                                       ///
             "{bf:ndp} "                                       ///
             "{bf:{ul:mix}ed} "                                ///
             "{p_end}"
   exit 198
}


/* Check options required when bandwidth(fbw) */
if ("`bandwidth'" == "fbw") & ("`fbw'" == "") {
   di as err "{p}If you specify option {bf:{ul:b}andwidth(fbw)}, "   ///
             "you are requested to specify also option "                  ///
             "{bf:fbw(ad{it:#}|{it:#})} {p_end}"
   exit 198 
}


/* Check options required when bandwidth(ndp) */
if ("`bandwidth'" == "ndp") & ("`ndp'" == "") {
   di as err "{p}If you specify option {bf:{ul:b}andwidth(ndp)}, "   ///
             "you are requested to specify also option "                  ///
             "{bf:ndp({it:#})} {p_end}"
   exit 198 
}


/* Check options required when bandwidth(mixed) */
if ("`bandwidth'" == "mixed") & ("`fbw'" == "" | "`ndp'" == "") {
   di as err "{p}If you specify option {bf:{ul:b}andwidth({ul:mix}ed}), "    ///
             "you are requested to specify also options "                    ///
             "{bf:fbw(ad{it:#}|{it:#})} and {bf:ndp({it:#})} {p_end}"
   exit 198 
}


/* Check option fbw() */
if ("`bandwidth'" == "ndp") local fbw = 0
else {
   local ADK = 0
   qui cap confirm number `fbw'
   if _rc {
      local BAD = 0
      if (substr("`fbw'",1,2) != "ad") local BAD = `BAD' + 1
      local K = substr("`fbw'",3,.)
      qui cap confirm integer number `K'
      local BAD = cond(_rc, `BAD' + 1, `BAD' + (`K'<=0))
      if (`BAD') {
         di as err "{p}Option {bf:{ul:fbw}()} accepts only "         ///
                   "positive numbers or argument {bf:ad{it:#}}, "    ///
                   "where {bf:{it:#}} represents a positive "        ///
                   "integer number {p_end}"
         exit 198
      }
      else {
         local ADK = `K'
      }
   }
   else {
      local BAD = (`fbw' <= 0)
      if (`BAD') {
         di as err "{p}Option {bf:{ul:fbw}()} accepts only "         ///
                   "positive numbers or argument {bf:ad{it:#}}, "    ///
                   "where {bf:{it:#}} represents a positive "        ///
                   "integer number {p_end}"
         exit 198
      }
   }
}


/* Check option ndp() */
if ("`bandwidth'" == "fbw") local ndp = 0


/* Check option ndpw() */
if ("`bandwidth'" == "fbw") local ndpw ""


/* Set and check macros FILENAME and REPLACE */
tokenize `"`saving'"', parse(", ")
local FILENAME "`1'"
local REPLACE "`3'"
if (substr(reverse("`FILENAME'"),1,4) != "atd.") {
   local FILENAME "`FILENAME'.dta"
}
cap confirm file "`FILENAME'"
if (_rc == 0) & ("`REPLACE'" != "replace") {
   di as err "{p}File {bf:`FILENAME'} specified in option "   ///
             "{bf:{ul:sav}ing()} already exists {p_end}"
   exit 602
}




*  ----------------------------------------------------------------------------
*  4. Define basic objects                                                     
*  ----------------------------------------------------------------------------

/* Set default kernel function */
if ("`kernel'" == "") local kernel "quartic"


/* Marksample */
marksample TOUSE, novarlist
markout `TOUSE' `xcoord' `ycoord' `ndpw'
qui count if `TOUSE'
if (r(N) == 0) error 2000


/* Preserve data */
preserve


/* Select relevant observations */
qui keep if `TOUSE'


/* Generate variable NDPW */
if (inlist("`bandwidth'","ndp","mixed")) {
   tempvar NDPW
   qui gen `NDPW' = 1
   if ("`ndpw'" != "") qui replace `NDPW' = `ndpw'
   su `NDPW', mean
   if (`ndp' > r(sum) ) {
      di as err "{p}Option {bf:{ul:ndp}()} accepts only positive "   ///
                "values lesser than or equal to `r(sum)' {p_end}"
      exit 198
   }
}


/* Select relevant variables */
keep `xcoord' `ycoord' `varlist' `NDPW'
tempvar IDP
qui gen `IDP' = _n
order `IDP' `xcoord' `ycoord' `varlist' `NDPW'
sort `IDP'
qui count
local N = r(N)


/* Get name of current dataset */
_getfilename "`c(filename)'"
local DATASET "`r(filename)'"


/* Set varlist */
unab varlist: `varlist'
local NV : word count `varlist'


/* Set kernel truncation parameter */
if ("`truncated'" == "") {
   local truncated = 0
}
if inlist("`kernel'", "uniform", "quartic", "triangular", "epanechnikov") {
   local truncated = 1
}


/* Set option dots */
if ("`verbose'" != "") local dots ""


/* Prepare working dataset */
local CHARLIST : char _dta[]
foreach CHAR in local `CHARLIST' {
   char _dta[`CHAR']
}
qui merge using `GRID'
drop _merge
tempvar BW NNDP
qui gen `BW' = .
qui gen `NNDP' = .
if ("`ndpw'" != "") {
   tempvar WSNDP
   qui gen `WSNDP' = .
}
if ("`edgecorrection'" != "") & (`truncated' > 0) {
   tempvar EDGE
   qui gen `EDGE' = .
}
tempvar A
qui gen `A' = .
foreach VAR of varlist `varlist' {
   tempvar `VAR'_sum
   qui gen double ``VAR'_sum' = .
   local SUM "`SUM'``VAR'_sum' "
}


/* Compute bandwidth when fbw(ad#) */
if ("`bandwidth'" != "ndp") & ("`ADK'" != "") {
   if (`ADK') {
      if ("`verbose'" == "") {
         di ""
         di as txt "-> Computing average distance between each data "   ///
                   "point and its `ADK' nearest neighbors..."
      }
      mata: spkdeADk(`N', "`xcoord'", "`ycoord'", `ADK')
   }
}




*  ----------------------------------------------------------------------------
*  5. Execute task                                                             
*  ----------------------------------------------------------------------------

/* Compute kernel estimates */
mata: spkde(`N', "`IDP'", "`xcoord'", "`ycoord'", "`varlist'",       ///
            "`kernel'", `truncated', "`bandwidth'", `fbw', `ndp',    ///
            "`NDPW'", `G', "`X'", "`Y'", "`BW'", "`NNDP'",           ///
            "`WSNDP'", "`EDGE'", "`A'", "`SUM'", `_dta[CellArea]',   ///
            "`verbose'", "`dots'")


/* Compute kernel density and intensity estimates */
if ("`verbose'" == "") {
   di as txt "-> Estimating kernel intensities and densities..."
}
local i = 1
foreach VAR of varlist `varlist' {
   if ("`VARLIST'" != "") local V "`VAR'_"
   su `VAR', mean
   local VSUM = r(sum)
   qui gen double `V'lambda = ``VAR'_sum' / `A'
   qui recode `V'lambda (. = 0)
   tempvar TEMP
   qui gen `TEMP' = `V'lambda * `_dta[CellArea]'
   su `TEMP', mean
   local TSUM = r(sum)
   qui gen `V'c = `VSUM' / `TSUM'
   qui replace `V'lambda = `V'lambda * `V'c
   qui gen `V'p = ((`TEMP' * `V'c) / `VSUM') * 100
   qui move `V'c `V'lambda
   if (`"`VARLIST'"' != "") lab var `V'c `"`VAR' - Constant of proportionality"'
   else lab var `V'c "Constant of proportionality"
   if (`"`VARLIST'"' != "") lab var `V'lambda `"`VAR' - Objects per unit area"'
   else lab var `V'lambda "Objects per unit area"
   if (`"`VARLIST'"' != "") lab var `V'p `"`VAR' - Relative frequency of objects (%)"'
   else lab var `V'p "Relative frequency of objects (%)"
   drop `TEMP'
   local i = `i' + 1
}


/* Arrange results dataset */
if ("`verbose'" == "") {
   di as txt "-> Saving results dataset..."
}
drop `IDP' `xcoord' `ycoord' `varlist' `NDPW'
qui drop if `ID' == .
clonevar spgrid_id = `ID'
clonevar spgrid_xcoord = `X'
clonevar spgrid_ycoord = `Y'
qui gen bandwidth = `BW'
lab var bandwidth "Kernel bandwidth"
qui gen ndp = `NNDP'
lab var ndp "Number of data points used for kernel estimation"
if ("`ndpw'" != "") {
   qui gen wndp = `WSNDP'
   lab var wndp "Weighted number of data points used for kernel estimation"
   local KEEPVAR "`KEEPVAR'wndp "
}
if ("`edgecorrection'" != "") & (`truncated' > 0) {
   qui gen edgecorrect = `EDGE'
   lab var edgecorrect "Edge correction factor"
   local KEEPVAR "`KEEPVAR'edgecorrect "
}
qui gen A = `A'
lab var A "Area over which the kernel function has been evaluated"
drop `ID' `X' `Y' `BW' `NNDP' `WSNDP' `EDGE' `A' `SUM'
order spgrid_id spgrid_xcoord spgrid_ycoord bandwidth ndp `KEEPVAR' A
sort spgrid_id


/* Set relevant characteristics */
char _dta[gridpointsfile] "`using'"
char _dta[dataset] "`DATASET'"
char _dta[varlist] "`VARLIST'"
local SEL = "`if' `in'"
if ("`SEL'" == "") local SEL "all"
char _dta[selobs] "`SEL'"
char _dta[DataPoints] "`N'"
char _dta[xcoord] "`xcoord'"
char _dta[ycoord] "`ycoord'"
char _dta[kernel] "`kernel'"
if inlist("`kernel'","normal","negexp") {
   if (`truncated' == 0) {
      char _dta[truncated] "no"
   }
   else {
      char _dta[truncated] `truncated'
   }
}
char _dta[bandwidth] "`bandwidth'"
if (`fbw' > 0) char _dta[fbw] "`fbw'"
if (`ndp' > 0) char _dta[ndp] "`ndp'"
char _dta[ndpw] "`ndpw'"
if ("`edgecorrection'" != "") & (`truncated' > 0) {
   char _dta[edgecorrection] "yes"
}
else {
   char _dta[edgecorrection] "no"
}


/* Save results dataset */
qui compress
qui save "`FILENAME'", `REPLACE'




*  ----------------------------------------------------------------------------
*  6. End program                                                              
*  ----------------------------------------------------------------------------

restore
end








*  ----------------------------------------------------------------------------
*  Mata functions                                                              
*                                                                              
*  : spkde()                                                                   
*  : spkdeADk()                                                                
*  : spkdeBandwidth()                                                          
*  : sp_*()                                                                    
*  ----------------------------------------------------------------------------

version 10.1
mata:
mata clear
mata set matastrict on




//*****************************************************************************
//*  spkde()                                                                  *
//*  --> spkdeBandwidth                                                       *
//*  --> sp_distance                                                          *
//*  --> sp_dots1                                                             *
//*  --> sp_dots2                                                             *
//*  --> sp_proximity                                                         *
//*  --> sp_wsum                                                              *
//*****************************************************************************

void spkde(real scalar N, string scalar idp, string scalar xp,
           string scalar yp, string scalar varlist, string scalar kernel,
           real scalar truncated, string scalar bandwidth,
           real scalar fbw, real scalar ndp, string scalar ndpw,
           real scalar G, string scalar xg, string scalar yg,
           string scalar bw, string scalar nndp, string scalar wsndp,
           string scalar edge, string scalar areak, string scalar sum,
           real scalar areac, string scalar verbose, string scalar dots)
{


/* Setup */
real scalar        g, x, y, h
real colvector     ID, NNDP, A, D, BW
string colvector   spwmNEIGHBORS, spwmWEIGHTS
real matrix        XY, VL, XYG, W, EC, SUM

/* Generate working objects */
ID = st_data(1::N, idp)
XY = st_data(1::N, (xp,yp))
VL = st_data(1::N, tokens(varlist))
st_view(XYG, 1::G, (xg,yg))
NNDP = J(G, 1, .)
A = J(G, 1, .)

/* Generate neighbors and weights matrices */
spwmNEIGHBORS = J(G, 1, "")
spwmWEIGHTS = J(G, 1, "")

/* Compute proximity weights and edge correction */
if (verbose == "") {
   printf("\n")
   if (edge != "") printf("{txt}-> Computing proximity weights and edge correction...\n")
   else printf("{txt}-> Computing proximity weights...\n")
   if (dots != "") {
      printf("\n")
      sp_dots1("Grid points", G)
   }
}
for (g=1; g<=G; g++) {
   if (dots != "") sp_dots2(g, G)
   x = _st_data(g, st_varindex(xg))
   y = _st_data(g, st_varindex(yg))
   D = sp_distance(x, y, XY)
   BW = spkdeBandwidth(bandwidth, fbw, ndp, ndpw, N, D)
   h = BW[1]
   W = sp_proximity(D, h, kernel, truncated)
   W = ID , W
   W = select(W, W[.,2] :> 0)
   NNDP[g] = rows(W)
   st_store(g, bw, h)
   st_store(g, nndp, NNDP[g])
   if (wsndp != "") st_store(g, wsndp, BW[2])
   if (NNDP[g] > 0) {
      spwmNEIGHBORS[g] = invtokens(strofreal(W[.,1]'))
      spwmWEIGHTS[g] = invtokens(strofreal(W[.,2]', "%10.0g"))
      if (truncated == 0) A[g] = areac * G
      else {
         h = h*truncated
         A[g] = h * h * pi()
         if (edge != "") {
            EC = select(XYG, (XYG[.,1]:>=(x-h)) :& (XYG[.,1]:<=(x+h)) :& 
                             (XYG[.,2]:>=(y-h)) :& (XYG[.,2]:<=(y+h)) )
            EC = sp_distance(x, y, EC)
            EC = sum(EC :<= h)
            EC = EC / ((h * h * pi()) / areac)
            if (EC > 1) EC = 1
            st_store(g, edge, EC)
            A[g] = A[g] * EC
         }
      }
      st_store(g, areak, A[g])
   }
}

/* Compute weighted sums */
SUM = sp_wsum(VL, NNDP, spwmNEIGHBORS, spwmWEIGHTS)
st_store(1::G, tokens(sum), SUM)


}




//*****************************************************************************
//*  spkdeADk()                                                               *
//*  --> sp_distance                                                          *
//*****************************************************************************

void spkdeADk(real scalar N, string scalar xp, string scalar yp,
              real scalar k)
{


/* Setup */
real scalar      i, x, y, h
real colvector   D
real matrix      XY, AD

/* Generate working objects */
XY = st_data(1::N, (xp,yp))
AD = J(N, k, .)

/* Compute distances */
for (i=1; i<=N; i++) {
   x = XY[i,1]
   y = XY[i,2]
   D = sp_distance(x, y, XY)
   D[i] = .
   AD[i,.] = sort(D,1)[1::k]'
}

/* Return bandwidth */
st_local("fbw", strofreal(mean(mean(AD)')))


}




//*****************************************************************************
//*  spkdeBandwidth()                                                         *
//*****************************************************************************

real colvector spkdeBandwidth(string scalar bandwidth, real scalar fbw,
                              real scalar ndp, string scalar ndpw,
                              real scalar N, real colvector D)
{


/* Setup */
real scalar      nsel
real colvector   BW, NDPW
real matrix      SEL

/* Generate working objects */
BW = J(2, 1, .)

/* Fixed bandwidth method */
if (bandwidth == "fbw") {
   BW[1] = fbw
}

/* Minimum (weighted) number of data points method */
if (bandwidth == "ndp") {
   NDPW = st_data(1::N, ndpw)
   NDPW = D , NDPW
   _sort(NDPW, 1)
   NDPW = NDPW[.,1] , runningsum(NDPW[.,2])
   if (NDPW[1,2] > ndp) {
      BW[1] = NDPW[1,1] * 1.000001
      BW[2] = NDPW[1,2]
   }
   else {
      SEL = select(NDPW, NDPW[.,2] :<= ndp)
      if (SEL[rows(SEL),2] < ndp) {
         BW[1] = NDPW[rows(SEL)+1,1] * 1.000001
         BW[2] = NDPW[rows(SEL)+1,2]
      }
      else {
         BW[1] = SEL[rows(SEL),1] * 1.000001
         BW[2] = SEL[rows(SEL),2]
      }
   }
}

/* Mixed method */
if (bandwidth == "mixed") {
   NDPW = st_data(1::N, ndpw)
   NDPW = D , NDPW
   _sort(NDPW, 1)
   NDPW = NDPW[.,1] , runningsum(NDPW[.,2])
   if (NDPW[1,2] > ndp) {
      BW[1] = NDPW[1,1] * 1.000001
      BW[2] = NDPW[1,2]
   }
   else {
      SEL = select(NDPW, NDPW[.,2] :<= ndp)
      if (SEL[rows(SEL),2] < ndp) {
         BW[1] = NDPW[rows(SEL)+1,1] * 1.000001
         BW[2] = NDPW[rows(SEL)+1,2]
      }
      else {
         BW[1] = SEL[rows(SEL),1] * 1.000001
         BW[2] = SEL[rows(SEL),2]
      }
   }
   nsel = rows(select(NDPW, NDPW[.,1] :<= fbw))
   if (nsel > 0) {
      if (NDPW[nsel,2] >= ndp) {
         BW[1] = fbw
         BW[2] = NDPW[nsel,2]
      }
   }
}

/* Return results */
return(BW)


}




//*****************************************************************************
//*  sp_*() - Library of Mata functions for spatial data analysis             *
//*                                                                           *
//*  : sp_distance                                                            *
//*  : sp_dots1                                                               *
//*  : sp_dots2                                                               *
//*  : sp_proximity                                                           *
//*  : sp_wsum                                                                *
//*****************************************************************************




/** 200808 *******************************************************************/
/*                                                                           */
/*  sp_distance                                                              */
/*                                                                           */
/*  Returns a R-by-1 colvector containing the distances between the          */
/*  point defined by the coordinate pair (x,y) and each point in the         */
/*  R-by-2 coordinate matrix POINTS.                                         */
/*  Returned distances can be of two kinds:                                  */
/*  (a) Euclidean distances, when point coordinates are expressed            */
/*      in Cartesian units. These distances are computed using the           */
/*      Pythagorean formula                                                  */
/*  (b) Great-circle distances (in meters, kilometers, feet, yards,          */
/*      miles, or nautical miles), when point coordinates are expressed      */
/*      in latitude/longitude units (decimal degrees). These distances       */
/*      are computed using the Haversine formula and the Earth's             */
/*      quadratic mean radius (6372795.478 m)                                */
/*                                                                           */
/*****************************************************************************/

real colvector sp_distance(real scalar x, real scalar y, real matrix POINTS,
                          |string scalar latlon)
{


/* Setup */
real scalar      base, radius
real colvector   X, Y, A, B, D, DLON, DLAT

/* Generate working objects */
X = POINTS[., 1]
Y = POINTS[., 2]

/* Compute Euclidean distances */
if (latlon == "") {
   A = (X[.] :- x) :* (X[.] :- x)
   B = (Y[.] :- y) :* (Y[.] :- y)
   D = sqrt(A + B)
}

/* Compute great circle distances */
if (latlon != "") {
   base = 6372795.478
   if (latlon == "m")  radius = base
   if (latlon == "km") radius = base * 0.001
   if (latlon == "ft") radius = base * 3.280839895
   if (latlon == "yd") radius = base * 1.093613298 
   if (latlon == "mi") radius = base * 0.000621371
   if (latlon == "nm") radius = base * 0.000539956
   x = x * (pi() / 180)
   y = y * (pi() / 180)
   X = X :* (pi() / 180)
   Y = Y :* (pi() / 180)
   DLON = (X :- x) :/ 2
   DLAT = (Y :- y) :/ 2
   D = ((sin(DLAT)) :^ 2) + (cos(y) :* cos(Y) :* ((sin(DLON)) :^ 2))
   D = 2 :* atan2(sqrt(1 :- D), sqrt(D))
   D = D :* radius
}

/* Return results */
return(D)


}




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




/** 020209 *******************************************************************/
/*                                                                           */
/*  sp_proximity                                                             */
/*                                                                           */
/*  Returns a R-by-1 colvector containing the raw proximity weights          */
/*  corresponding to each distance in an R-by-1 colvector D, computed        */
/*  as a function of kernel bandwidth h, kernel function kf, and             */
/*  kernel truncation parameter tr                                           */
/*                                                                           */
/*****************************************************************************/

real colvector sp_proximity(real colvector D, real scalar h,
                            string scalar kf, real scalar tr)
{


/* Setup */
real colvector   W, OK

/* Uniform function */
if (kf == "uniform") {
   W = J(rows(D), 1, 1)
   OK = D :< h
}

/* Normal function */
if (kf == "normal") {
   W = D :* D
   W = W :/ (h * h)
   W = W :* 0.5
   W = exp(-W)
   if (tr > 0) OK = D :< (h * tr)
   else OK = J(rows(D), 1, 1)
}

/* Negative exponential function */
if (kf == "negexp") {
   W = D :/ h
   W = W :* 3
   W = exp(-W)
   if (tr > 0) OK = D :< (h * tr)
   else OK = J(rows(D), 1, 1)
}

/* Quartic function */
if (kf == "quartic") {
   W = D :* D
   W = W :/ (h * h)
   W = 1 :- W
   W = W :* W
   OK = D :< h
}

/* Triangular function */
if (kf == "triangular") {
   W = D :/ h
   W = 1 :- W
   OK = D :< h
}

/* Epanechnikov function */
if (kf == "epanechnikov") {
   W = D :* D
   W = W :/ (h * h)
   W = 1 :- W
   OK = D :< h
}

/* Return results */
_editmissing(W, 0)
return(W :* OK)


}




/** 200808 *******************************************************************/
/*                                                                           */
/*  sp_wsum                                                                  */
/*                                                                           */
/*  Returns a R1-by-C matrix containing the weighted sum of the R2-by-C      */
/*  matrix X, defined in terms of the R1-by-1 neighbors matrix NEIGHBORS     */
/*  and the R1-by-1 spatial weights matrix WEIGHTS                           */
/*                                                                           */
/*****************************************************************************/

real matrix sp_wsum(real matrix X, real colvector NN,
                    string colvector NEIGHBORS, string colvector WEIGHTS)
{


/* Setup */
real scalar      n, v, i
real colvector   Ni
real rowvector   Wi
real matrix      Xi, SUM

/* Generate working objects */
n = rows(NN)
v = cols(X)
SUM = J(n, v, 0)

/* Compute weighted sum */
for (i=1; i<=n; i++) {
   if (NN[i] > 0) {
      Ni = strtoreal(tokens(NEIGHBORS[i]))'
      Wi = strtoreal(tokens(WEIGHTS[i]))
      Xi = X[Ni,.]
      SUM[i, .] = Wi * Xi
   }
}

/* Return results */
return(SUM)


}




//*****************************************************************************
//*  Exit Mata                                                                *
//*****************************************************************************

end



