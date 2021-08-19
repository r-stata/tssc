
*! T. FOREMAN 11/2020: PROGRAM TO ESTIMATE SPATIAL HAC ERRORS FOR IV REGRESSION MODEL



/*-----------------------------------------------------------------------------

This may contain errors. Please notify me of any errors you find.

------------------------------------------------------------------------------

Syntax:

spatial_hac_iv Yvar ExogenousVars (EndogenousVars=Instruments), lat(latvar) lon(lonvar) Timevar(tvar) Panelvar(pvar) [DISTcutoff(#) LAGcutoff(#) bartlett DISPlay star dropvar]

Function calculates non-parametric (GMM) spatial and autocorrelation
structure using a panel data set.  Spatial correlation is estimated for all
observations within a given period.  Autocorrelation is estimated for a
given individual over multiple periods up to some lag length. Var-Covar
matrix is robust to heteroskedasticity.


Example commands:

spatial_hac_iv dep indep1 (endo=inst), lat(C1) lon(C2) t(year) p(id) dist(300) lag(3) bartlett disp


spatial_hac_iv dep indep* (endo1 endo2=inst1 inst2), lat(C1) lon(C2) timevar(year) panelvar(id) dist(100) lag(2) star dropvar

------------------------------------------------------------------------------

Required arguments:

Yvar: dependent variable
Xvarlist: independent variables (INCLUDE constant as column)
latvar: variable containing latitude in DEGREES of each obs
lonvar: same, but longitude
tvar: varible containing time variable
pvar: variable containing panel variable (must be numeric, see "encode")

------------------------------------------------------------------------------

Optional arguments:

distcutoff(#): {abbrev dist(#)} describes the distance cutoff in KILOMETERS for the spatial kernel (the distance at which spatial correlation is assumed to vanish). Default is 1 KM.

lagcutoff(#): {abbrev lag(#)} describes the maximum number of temporal periods for the linear Bartlett window that weights serial correlation across time periods (the distance at which serial correlation is assumed to vanish). Default is 0 PERIODS (no serial correlation). {Note, Greene recommends at least T^0.25}

------------------------------------------------------------------------------

Options:


bartlett: use a linear bartlett window for spatial correlations, instead of a uniform kernel

display: {abbrev disp} display a table with estimated coeff and SE & t-stat using IV, adjusting for spatial correlation and adjusting for both spatial and serial correlation. Can be used with star option. Ex:

-----------------------------------------------
    Variable |   IV      spatial    spatHAC
-------------+---------------------------------
      indep1 |    0.568      0.568      0.568
             |    0.198      0.206      0.240
             |    2.876      2.761      2.369
       const |    6.415      6.415      6.415
             |    0.790      1.176      1.340
             |    8.119      5.454      4.786
-----------------------------------------------
                                 legend: b/se/t


star: same as display, but uses stars to denote significance and does not show SE & t-stat. Can be used with display option. Ex:

-----------------------------------------------------
    Variable |    IV        spatial      spatHAC
-------------+---------------------------------------
      indep1 |   0.568***     0.568***     0.568**
       const |   6.415***     6.415***     6.415***
-----------------------------------------------------
                  legend: * p<.1; ** p<.05; *** p<.01


dropvar: Drops variables that Stata would drop due to collinearity. This requires that an additional regression is run, so it slows the code down. For large datasets, if this function is called many times, it may be faster to ensure that colinear variables are dropped in advance rather than using the option dropvar. If Stata returns "estimates post: matrix has missing values", than including the option dropvar may solve the problem. (This option written by Kyle Meng).

------------------------------------------------------------------------------

Implementation:

The default kernel used to weight spatial correlations is a uniform kernel that
discontinously falls from 1 to zero at length distcutoff in all directions (it is isotropic). This is the kernel recommented by Conley (2008). If the option "bartlett" is selected, a conical kernel that decays linearly with distance in all directions is used instead.

Serial correlation bewteen observations of the same individual over multiple periods seperated by lag L are weighted by

      w(L) = 1 - L/(lagCutoff+1)

------------------------------------------------------------------------------

Notes:

Location arguments should specify lat-lon units in DEGREES, however
distcutoff should be specified in KILOMETERS.

distcutoff must exceed zero. CAREFUL: do not supply
coordinate locations in modulo(360) if observations straddle the
zero-meridian or in modulo(180) if they straddle the date-line.

Distances are computed by approximating the planet's surface as a plane
around each observation.  This allows for large changes in LAT to be
present in the dataset (it corrects for changes in the length of
LON-degrees associated with changes in LAT). However, it does not account
for the local curvature of the surface around a point, so distances will
be slightly lower than true geodesics. This should not be a concern so
long as locCutoff is < O(~2000km), probably.

Each time-series for an individual observation in the panel is treated
with Heteroskedastic and Autocorrelation Standard Errors. If lagcutoff =
0, than this estimate is equivelent to White standard errors (with spatial correlations
accounted for). If lagcutoff = infinity, than this treatment is
equivelent to the "cluster" command in Stata at the panel variable level.

This script stores estimation results in standard Stata formats, so most "ereturn" commands should work properly.  It is also compatible with "outreg2," although I have not tested other programs.

The R^2 statistics output by this function will differ from analogous R^2 stats
computed using "reg" since this function omits the constant.

If factor variables are used to include fixed effects, it is still necessary to include the constant variable.

------------------------------------------------------------------------------

References:

     TG Conley "GMM Estimation with Cross Sectional Dependence"
     Journal of Econometrics, Vol. 92 Issue 1(September 1999) 1-45
     http://www.elsevier.com/homepage/sae/econworld/econbase/econom/frame.htm

     and

     Conley "Spatial Econometrics" New Palgrave Dictionary of Economics,
     2nd Edition, 2008

     and

     Greene, Econometric Analysis, p. 546

   and

   Modified from scripts written by Ruben Lebowski and Wolfram Schlenker and Jean-Pierre Dube and Solomon Hsiang.

	 Syntax parsing code largely follows that of ivreg2.

-----------------------------------------------------------------------------*/

program define spatial_hac_iv, eclass byable(recall) sortpreserve
version 13
//syntax varlist(ts fv min=2)  [if] [in], ///
//       lat(varname numeric) lon(varname numeric) ///
//       Timevar(varname numeric) Panelvar(varname numeric) [LAGcutoff(integer 0) DISTcutoff(real 1) ///
//       DISPlay star bartlett dropvar]

/*--------PARSING COMMANDS AND SETUP-------*/
local ranktestversion 01.3.02

local ivreg2cmd "ivreg211"			//  actual command name
local ivreg2name "spatial_hac_iv"			//  name used in command line and for default naming of equations etc.
local ranktestcmd "ranktest"
local cmdline `ivreg2name' `0'

// Start parsing, based on ivreg2
		syntax [anything(name=0)] [if] [in] [aw fw pw iw/] [,		///
				NOID NOCOLLIN						 				///
				FIRST FFIRST SAVEFIRST SAVEFPrefix(name)			///
				RF SAVERF SAVERFPrefix(name)						///
				SFIRST SAVESFIRST SAVESFPrefix(name)				///
				SMall NOConstant 									///
				Robust CLuster(varlist) kiefer dkraay(integer 0)	///
				BW(string) kernel(string) center					///
				GMM GMM2s CUE										///
				LIML COVIV FULLER(real 0) Kclass(real 0)			///
				ORTHOG(string) ENDOGtest(string) REDundant(string)	///
				PARTIAL(string) FWL(string)							///
				LEVEL(integer $S_level)								///
				NOHEader NOFOoter NOOUTput							///
				bvclean NOOMITTED omitted vsquish noemptycells		///
				baselevels allbaselevels 							///
				title(string) subtitle(string)						///
				DEPname(string) EForm(string) PLUS					///
				B0(string) SMATRIX(string) WMATRIX(string)			///
				sw psd0 psda useqr									///
				dofminus(integer 0) sdofminus(integer 0)			///
				NOPARTIALSMALL										///
				fvall fvsep											///
        LAT(varname numeric) LON(varname numeric) TIMEVAR(varname numeric) ///
				PANELvar(varname numeric) LAGcutoff(integer 0) DISTcutoff(real 1) ///
				Tvar(varname) Ivar(varname) DISPlay star bartlett dropvar			]				///
          ///
      //         DISPlay star bartlett dropvar
			//	]

// Parse after clearing any sreturn macros (can be left behind in Stata 11)
		sreturn clear
		ivparse `0',	ivreg2name(`ivreg2name')		///  needed for some options
						partial(`partial')				///
						fwl(`fwl')						///  legacy option
						orthog(`orthog')				///
						endogtest(`endogtest')			///
						redundant(`redundant')			///
						depname(`depname')				///
						`robust'						///
						cluster(`cluster')				///
						bw(`bw')						///
						kernel(`kernel')				///
						dkraay(`dkraay')				///
						`center'						///
						`kiefer'						///
						`sw'							///
						`noconstant'					///
						tvar(`tvar')					///
						ivar(`ivar')					///
						`gmm2s'							///
						`gmm'							///  legacy option, produces error message
						`cue'							///
						`liml'							///
						fuller(`fuller')				///
						kclass(`kclass')				///
						b0(`b0')						///
						wmatrix(`wmatrix')				///
						`noid'							///
						`savefirst'						///
						savefprefix(`savefprefix')		///
						`saverf'						///
						saverfprefix(`saverfprefix')	///
						`savesfirst'					///
						savesfprefix(`savesfprefix')	///
						dofminus(`dofminus')			///
						`psd0'							///
						`psda'							///
						`nocollin'						///
						`useqr'							///
						`bvclean'						///
						eform(`eform')					///
						`noomitted'						///
						`vsquish'						///
						`noemptycells'					///
						`baselevels'					///
						`allbaselevels' ///
            lat(`lat') ///
            timevar(`timevar') ///
						panelvar(`panelvar') ///
						lagcutoff(`lagcutoff')

// varlists are unexpanded; may be empty
		local lhs			`s(lhs)'
		local depname		`s(depname)'
		local endo			`s(endo)'
		local inexog		`s(inexog)'
		local exexog		`s(exexog)'
		local partial		`s(partial)'
		local cons			=s(cons)
		local partialcons	=s(partialcons)
		local tvar			`s(tvar)'
		local ivar			`s(ivar)'
		local tdelta		`s(tdelta)'
		local tsops			=s(tsops)
		local fvops			=s(fvops)
		local robust		`s(robust)'
		local cluster		`s(cluster)'
		local bw			=`s(bw)'				//  arrives as string but return now as number
		local bwopt			`s(bwopt)'
		local kernel		`s(kernel)'				//  also used as flag for HAC estimation
		local center		=`s(center)'			//  arrives as string but now boolean
		local kclassopt		`s(kclassopt)'
		local fulleropt		`s(fulleropt)'
		local liml			`s(liml)'
		local noid			`s(noid)'				//  can also be triggered by b0(.) option
		local useqr			=`s(useqr)'				//  arrives as string but now boolean; nocollin=>useqr
		local savefirst		`s(savefirst)'
		local savefprefix	`s(savefprefix)'
		local saverf		`s(saverf)'
		local saverfprefix	`s(saverfprefix)'
		local savesfirst	`s(savesfirst)'
		local savesfprefix	`s(savesfprefix)'
		local psd			`s(psd)'				//  triggered by psd0 or psda
		local dofmopt		`s(dofmopt)'
		local bvclean		=`s(bvclean)'			//  arrives as string but return now as boolean
		local dispopt		`s(dispopt)'


// Can now tsset; sortpreserve will restore sort after exit
		if `tsops' | "`kernel'"~="" {
			cap tsset								//  restores sort if tsset or xtset but sort disrupted
			if _rc>0 {
				tsset `ivar' `tvar'
			}
		}



capture drop touse
marksample touse				// indicator for inclusion in the sample
gen touse = `touse'

//parsing variables
// loc Y = word("`varlist'",1)
//
// loc listing "`varlist'"
//
// loc X ""
// scalar k = 0

//make sure that Y is not included in the other_var list
foreach i of loc listing {
 if "`i'" ~= "`Y'"{
   loc X "`X' `i'"
   scalar k = k + 1 // # indep variables

 }
}

// expand varlist
fvrevar `inexog'
loc inexog = r(varlist)
loc tempinexog
loc listsize : list sizeof local(inexog)
if `listsize'>1 {
foreach i of varlist `inexog' {
 	  loc tempinexog "`tempinexog' `i'"
 }
}
 loc inexog "`tempinexog'"

//Kyle Meng's code to drop omitted variables that Stata would drop due to collinearity

if "`dropvar'" == "dropvar"{

 //quietly reg `Y' `X' if `touse', nocons
 qui ivreg2 `lhs' `inexog' (`endo'=`exexog') if `touse', nocons
//	disp e(cmdline)
 // dkraay(`dkraay')				///
 // `center'						///
 // `kiefer'						///
 // `sw'							///
 // `noconstant'					///
 // tvar(`tvar')					///
 // ivar(`ivar')					///
 // `gmm2s'							///
 // `gmm'							///  legacy option, produces error message
 // `cue'							///
 // `liml'							///
 // fuller(`fuller')				///
 // kclass(`kclass')				///
 // b0(`b0')						///
 // wmatrix(`wmatrix')				///
 // `noid'							///
 // `savefirst'						///
 // savefprefix(`savefprefix')		///
 // `saverf'						///
 // saverfprefix(`saverfprefix')	///
 // `savesfirst'					///
 // savesfprefix(`savesfprefix')	///
 // dofminus(`dofminus')			///
 // `psd0'							///
 // `psda'							///
 // `nocollin'						///
 // `useqr'							///
 // `bvclean'						///
 // eform(`eform')					///
 // `noomitted'						///
 // `vsquish'						///
 // `noemptycells'					///
 // `baselevels'					///
 // `allbaselevels' ///



 mat omittedMat=e(b)
 local newVarList=""
 local i=1
 scalar k = 0 //replace the old k if this option is selected

 foreach var of varlist `endo' {
   if omittedMat[1,`i']!=0{
     loc newVarList "`newVarList' `var'"
     scalar k = k + 1
   }
   local i=`i'+1
 }

 loc endo "`newVarList'"


 local newVarList=""
 if `listsize'>1 {
 foreach var of varlist `inexog'{
   if omittedMat[1,`i']!=0{
     loc newVarList "`newVarList' `var'"
     scalar k = k + 1
   }
   local i=`i'+1
 }
}
 loc inexog "`newVarList'"



}




//generating a function of the included obs
quietly count if `touse'
scalar n = r(N)					// # obs
scalar n_obs = r(N)

/*--------FIRST DO SIMPLE IV, STORE RESULTS-------*/


quietly: ivreg2 `lhs' `inexog' (`endo'=`exexog') if `touse', nocons
loc fstat = e(widstat)

// disp "`lhs' `inexog' (`endo'=`exexog') if `touse', nocons"

estimates store IV


/*--------SECOND, IMPORT ALL VALUES INTO MATA-------*/

mata{

Y_var = st_local("lhs")
 //importing variable assignments to mata
X_var = st_local("endo")
X_exo = st_local("inexog")
Z_var = st_local("exexog")
lat_var = st_local("lat")
lon_var = st_local("lon")
time_var = st_local("timevar")
panel_var = st_local("panelvar")

//NOTE: values are all imported as "views" instead of being copied and pasted as Mata data because it is faster, however none of the matrices are changed in any way, so it should not permanently affect the data.

st_view(Y=.,.,tokens(Y_var),"touse")
//importing variables vectors to mata
st_view(X=.,.,tokens(X_var),"touse")
st_view(Xexo=.,.,tokens(X_exo),"touse")
st_view(Z=.,.,tokens(Z_var),"touse")
st_view(lat=.,.,tokens(lat_var),"touse")
st_view(lon=.,.,tokens(lon_var),"touse")
st_view(time=.,.,tokens(time_var),"touse")
st_view(panel=.,.,tokens(panel_var),"touse")

Xfull=X,Xexo
Zfull=Xexo,Z


k = cols(Xfull)
				//importing other parameters
n = st_numscalar("n")
b = st_matrix("e(b)")
				// (estimated coefficients, row vector)
lag_var = st_local("lagcutoff")
lag_cutoff = strtoreal(lag_var)
dist_var = st_local("distcutoff")
dist_cutoff = strtoreal(dist_var)


P = Zfull*invsym(Zfull'*Zfull)*Zfull'
XPXinv = invsym(Xfull'*P*Xfull)
e = Y-Xfull*b'
XprimeP=Xfull'*P

PX = P*Xfull

XeeX = J(k, k, 0)
		//set variance-covariance matrix equal to zeros

// for iv, need variance matrix = (X'PX)^-1 (XeeX) (X'PX)^-1
// where P = Z(Z'Z)^-1 Z'
// where Z is all exogenous variables (inexog and exexog), call this Zfull
// and X is all included variables (endo and inexog), call this Xfull

/*--------THIRD, CORRECT VCE FOR SPATIAL CORR-------*/

timeUnique = uniqrows(time)
Ntime = rows(timeUnique)
		// # of obs. periods

for (ti = 1; ti <= Ntime; ti++){



 // 1 if in year ti, 0 otherwise:

 rows_ti = time:==timeUnique[ti,1]

 //get subsets of variables for time ti (without changing original matrix)

 Y1 = select(Y, rows_ti)
 X1 = select(X, rows_ti)
 Xfull1 = select(Xfull, rows_ti)
 PX1 = select(PX, rows_ti)
 P1 = select(P, rows_ti)
 Z1 = select(Z, rows_ti)
 Zfull1 = select(Zfull, rows_ti)
 lat1 = select(lat, rows_ti)
 lon1 = select(lon, rows_ti)
 e1 = Y1 - Xfull1*b'

 XprimeP1=select(XprimeP',rows_ti)'

 n1 = length(Y1)
 		// # obs for period ti

 //loop over all observations in period ti

 for (i = 1; i <=n1; i++){


   //----------------------------------------------------------------
       // step a: get non-parametric weight

     //This is a Euclidean distance scale IN KILOMETERS specific to i

   lon_scale = cos(lat1[i,1]*pi()/180)*111
   lat_scale = 111


   // Distance scales lat and lon degrees differently depending on
       // latitude.  The distance here assumes a distortion of Euclidean
       // space around the location of 'i' that is approximately correct for
       // displacements around the location of 'i'
       //
       //	Note: 	1 deg lat = 111 km
       // 			1 deg lon = 111 km * cos(lat)

// this is not robust to missing lat/lon values
   distance_i = ((lat_scale*(lat1[i,1]:-lat1)):^2 +        (lon_scale*(lon1[i,1]:-lon1)):^2):^0.5



   // this sets all observations beyon dist_cutoff to zero, and weights all nearby observations equally [this kernel is isotropic]

   window_i = distance_i :<= dist_cutoff

   //----------------------------------------------------------------
       // adjustment for the weights if a "bartlett" kernel is selected as an option

   if ("`bartlett'"=="bartlett"){

     // this weights observations as a linear function of distance
     // that is zero at the cutoff distance

     weight_i = 1:- distance_i:/dist_cutoff

     window_i = window_i:*weight_i
   }


       //----------------------------------------------------------------
       // step b: construct X'e'eX for the given observation
			 // for iv, need variance matrix = (X'PX)^-1 (X'PeePX) (X'PX)^-1
			 // where P = Z(Z'Z)^-1 Z' is the projection matrix
			 
    XeeXh = ((XprimeP1[.,i]*J(1,n1,1)*e1[i,1]):*(J(k,1,1)*e1':*window_i'))*PX1
   //add each new k x k matrix onto the existing matrix (will be symmetric)

   XeeX = XeeX + XeeXh

 }
 //i
} // ti



// -----------------------------------------------------------------
// generate the VCE for only cross-sectional spatial correlation,
// return it for comparison

invXX = invsym(Xfull'*Xfull) * n

XeeX_spatial = XeeX / n

// V = invXX * XeeX_spatial * invXX / n
V = XPXinv * XeeX_spatial * XPXinv
// Ensures that the matrix is symmetric
// in theory, it should be already, but it may not be due to rounding errors for large datasets
V = (V+V')/2

st_matrix("V_spatial", V)

} // mata


//------------------------------------------------------------------
// storing old statistics about the estimate so postestimation can be used

matrix beta = e(b)
scalar r2_old = e(r2c) // use the centered r2
scalar df_m_old = e(df_m)
scalar df_r_old = e(df_r)
scalar rmse_old = e(rmse)
scalar mss_old = e(mss)
scalar rss_old = e(rss)
scalar r2_a_old = e(r2_a)

// the row and column names of the new VCE must match the vector b
local xfull="`endo' `inexog'"
matrix colnames V_spatial = `xfull'
matrix rownames V_spatial = `xfull'

// this sets the new estimates as the most recent model

// ereturn post beta V_spatial, esample(`touse')

// then filling back in all the parameters for postestimation


ereturn local cmd = "iv_spatial"

ereturn scalar N = n_obs

ereturn scalar r2 = r2_old
ereturn scalar df_m = df_m_old
ereturn scalar df_r = df_r_old
ereturn scalar rmse = rmse_old
ereturn scalar mss = mss_old
ereturn scalar rss = rss_old
ereturn scalar r2_a = r2_a_old

ereturn local title = "Linear regression"
ereturn local depvar = "`lhs'"
ereturn local predict = "regres_p"
ereturn local model = "iv"
ereturn local estat_cmd = "regress_estat"

//storing these estimates for comparison to IV and the HAC estimates

estimates store spatial



/*--------FOURTH, CORRECT VCE FOR SERIAL CORR-------*/

mata{

panelUnique = uniqrows(panel)
Npanel = rows(panelUnique) 		// # of panels

for (pi = 1; pi <= Npanel; pi++){

 // 1 if in panel pi, 0 otherwise:

 rows_pi = panel:==panelUnique[pi,1]

 //get subsets of variables for panel pi (without changing original matrix)


 Y1 = select(Y, rows_pi)
 X1 = select(X, rows_pi)
 Xexo1 = select(Xexo, rows_pi)
 Xfull1 = select(Xfull, rows_pi)
 P1 = select(P, rows_pi)
 PX1 = select(PX, rows_pi)
 Z1 = select(Z, rows_pi)
 Zfull1 = select(Zfull, rows_pi)
 time1 = select(time, rows_pi)
 X1 = X1, Xexo1
 e1 = Y1 - Xfull1*b'
 XprimeP1=select(XprimeP',rows_pi)'

 n1 = length(Y1) 			// # obs for panel pi

 //loop over all observations in panel pi

 for (t = 1; t <=n1; t++){



       weight = 1:-abs(time1[t,1] :- time1)/(lag_cutoff+1)


       // obs var far enough apart in time are prescribed to have no estimated
       // correlation (Greene recomments lag_cutoff >= T^0.25 {pg 546})

       window_t = (abs(time1[t,1]:- time1) :<= lag_cutoff) :* weight

       //this is required so diagonal terms in var-covar matrix are not
       //double counted (since they were counted once above for the spatial
       //correlation estimates:

       window_t = window_t :* (time1[t,1] :!= time1)

     // ----------------------------------------------------------------
       // step b: construct X'e'eX for given observation
			 
       XeeXh = ((XprimeP1[.,t]*J(1,n1,1)*e1[t,1]):*(J(k,1,1)*e1':*window_t'))*PX1

   //add each new k x k matrix onto the existing matrix (will be symmetric)

       XeeX = XeeX + XeeXh

 } // t
} // pi




// -----------------------------------------------------------------
// generate the VCE for x-sectional spatial correlation and serial correlation

XeeX_spatial_HAC = XeeX

regular = XPXinv * (e'*e) / n

robust = XPXinv * Xfull' * P * (e'*e) * P * Xfull * XPXinv / n

//V = invXX * XeeX_spatial_HAC * invXX / n
	V = XPXinv * XeeX_spatial_HAC * XPXinv
// Ensures that the matrix is symmetric
// in theory, it should be already, but it may not be due to rounding errors for large datasets
V = (V+V')/2

st_matrix("V_spatial_HAC", V)

} // mata

//------------------------------------------------------------------
//storing results

matrix beta = e(b)

// the row and column names of the new VCE must match the vector b
local xfull="`endo' `inexog'"
matrix colnames V_spatial_HAC = `xfull'
matrix rownames V_spatial_HAC = `xfull'

// this sets the new estimates as the most recent model

marksample touse				// indicator for inclusion in the sample

ereturn post beta V_spatial_HAC, esample(`touse')

// then filling back in all the parameters for postestimation

ereturn local cmd = "spatial_hac_iv"

ereturn local widstat = `fstat'


ereturn scalar N = n_obs
ereturn scalar r2 = r2_old
ereturn scalar df_m = df_m_old
ereturn scalar df_r = df_r_old
ereturn scalar rmse = rmse_old
ereturn scalar mss = mss_old
ereturn scalar rss = rss_old
ereturn scalar r2_a = r2_a_old

ereturn local title = "Linear regression"
ereturn local depvar = "`lhs'"
ereturn local predict = "regres_p"
ereturn local model = "iv"
ereturn local estat_cmd = "regress_estat"

//storing these estimates for comparison to IV and the HAC estimates

estimates store spatHAC

//------------------------------------------------------------------
//displaying results

disp as txt " "
disp as txt "IV REGRESSION"
disp as txt " "
disp as txt "SE CORRECTED FOR CROSS-SECTIONAL SPATIAL DEPENDANCE"
disp as txt "             AND PANEL-SPECIFIC SERIAL CORRELATION"
disp as txt " "
disp as txt "DEPENDENT VARIABLE: `lhs'"
disp as txt "INDEPENDENT VARIABLES: `inexog'"
disp as txt " "
disp as txt "SPATIAL CORRELATION KERNEL CUTOFF: `distcutoff' KM"

if "`bartlett'" == "bartlett" {
 disp as txt "(NOTE: LINEAR BARTLETT WINDOW USED FOR SPATIAL KERNEL)"
}

disp as txt "SERIAL CORRELATION KERNEL CUTOFF: `lagcutoff' PERIODS"

ereturn display // standard Stata regression table format

// displaying different SE if option selected

if "`display'" == "display"{
 disp as txt " "
 disp as txt "STANDARD ERRORS UNDER IV, WITH SPATIAL CORRECTION AND WITH SPATIAL AND SERIAL CORRECTION:"
 estimates table IV spatial spatHAC, b(%7.3f) se(%7.3f) t(%7.3f) stats(N r2)
}

if "`star'" == "star"{
 disp as txt " "
 disp as txt "STANDARD ERRORS UNDER IV, WITH SPATIAL CORRECTION AND WITH SPATIAL AND SERIAL CORRECTION:"
 estimates table IV spatial spatHAC, b(%7.3f) star(0.10 0.05 0.01)
}

//------------------------------------------------------------------
// cleaning up Mata environment

capture mata mata drop V invXX  XeeX XeeXh XeeX_spatial_HAC window_t window_i weight t i ti pi X1 Y1 e1 time1 n1 lat lon lat1 lon1 lat_scale lon_scale rows_ti rows_pi timeUnique panelUnique Ntime Npanel X X_var XeeX_spatial Y Y_var b dist_cutoff dist_var distance_i k lag_cutoff lag_var lat_var lon_var n panel panel_var time time_var weight_i


if "`bartlett'" == "bartlett" {
 capture mata mata drop weight_i
}


end








program define ivparse, sclass
	version 11.2
		syntax [anything(name=0)]			///
			[ ,								///
				ivreg2name(name)			///
				partial(string)				///  as string because may have nonvariable in list
				fwl(string)					///  legacy option
				orthog(varlist fv ts)		///
				endogtest(varlist fv ts)	///
				redundant(varlist fv ts)	///
				depname(string)				///
				robust						///
				cluster(varlist fv ts)		///
				bw(string)					/// as string because may have noninteger option "auto"
				kernel(string)				///
				dkraay(integer 0)			///
				sw							///
				kiefer						///
				center						///
				NOCONSTANT					///
				tvar(varname)				///
				ivar(varname)				///
				gmm2s						///
				gmm							///
				cue							///
				liml						///
				fuller(real 0)				///
				kclass(real 0)				///
				b0(string)					///
				wmatrix(string)				///
				NOID						///
				savefirst					///
				savefprefix(name)			///
				saverf						///
				saverfprefix(name)			///
				savesfirst					///
				savesfprefix(name)			///
				psd0						///
				psda						///
				dofminus(integer 0)			///
				NOCOLLIN					///
				useqr						///
				bvclean						///
				eform(string)				///
				NOOMITTED					///
				vsquish						///
				noemptycells				///
				baselevels					///
				allbaselevels 				///
        lat(varname) ///
        lon(varname) ///
        timevar(varname) ///
				panelvar(varname) ///
				lagcutoff(integer 0) ///
				distcutoff(integer 0) ///
			]

// TS and FV opts based on option varlists
		local tsops		= ("`s(tsops)'"=="true")
		local fvops		= ("`s(fvops)'"=="true")
// useful boolean
		local cons		=("`noconstant'"=="")

		local n 0
		gettoken lhs 0 : 0, parse(" ,[") match(paren)
		IsStop `lhs'
		while `s(stop)'==0 {
			if "`paren'"=="(" {
				local ++n
				if `n'>1 {
di as err `"syntax is "(all instrumented variables = instrument variables)""'
					exit 198
				}
				gettoken p lhs : lhs, parse(" =")
				while "`p'"!="=" {
					if "`p'"=="" {
di as err `"syntax is "(all instrumented variables = instrument variables)""'
di as er `"the equal sign "=" is required"'
						exit 198
					}
					local endo `endo' `p'
					gettoken p lhs : lhs, parse(" =")
				}
				local exexog `lhs'
			}
			else {
				local inexog `inexog' `lhs'
			}
			gettoken lhs 0 : 0, parse(" ,[") match(paren)
			IsStop `lhs'
		}
// lhs attached to front of inexog
		gettoken lhs inexog	: inexog
		local endo			: list retokenize endo
		local inexog		: list retokenize inexog
		local exexog		: list retokenize exexog
// If depname not provided (default) name is lhs variable
		if "`depname'"=="" {
			local depname `lhs'
		}

// partial, including legacy FWL option
		local partial		`partial' `fwl'
// Need to nonvars "_cons" from list if present
// Also set `partialcons' local to 0/1
// Need word option so that varnames with cons in them aren't zapped
		local partial		: subinstr local partial "_cons" "", all count(local partialcons) word
		local partial		: list retokenize partial
		if "`partial'"=="_all" {
			local partial	`inexog'
		}
// constant always partialled out if present in regression and other inexog are being partialled out
// (incompatibilities caught in error-check section below)
		if "`partial'"~="" {
			local partialcons	= (`cons' | `partialcons')
		}

// detect if TS or FV operators used in main varlists
// clear any extraneous sreturn macros first
		sreturn clear
		local 0				`lhs' `inexog' `endo' `exexog' `partial'
		syntax				varlist(fv ts)
		local tsops			= ("`s(tsops)'"=="true") | `tsops'
		local fvops			= ("`s(fvops)'"=="true") | `fvops'

// TS operators not allowed with cluster, ivar or tvar.  Captured in -syntax-.
		if "`tvar'" == "" {
			local tvar		`_dta[_TStvar]'
		}
		if "`ivar'" == "" {
			local ivar		`_dta[_TSpanel]'
		}
		if "`_dta[_TSdelta]'" == "" {
			local tdelta	1
		}
		else {												//  use evaluator since _dta[_TSdelta] can
			local tdelta	= `_dta[_TSdelta]'				//  be stored as e.g. +1.0000000000000X+000
		}

		sreturn local lhs			`lhs'
		sreturn local depname		`depname'
		sreturn local endo			`endo'
		sreturn local inexog		`inexog'
		sreturn local exexog 		`exexog'
		sreturn local partial		`partial'
		sreturn local cons			=`cons'
		sreturn local partialcons	=`partialcons'
		sreturn local tsops			=`tsops'
		sreturn local fvops			=`fvops'
		sreturn local tvar			`tvar'
		sreturn local ivar			`ivar'
		sreturn local tdelta		`tdelta'
		sreturn local noid			`noid'			//  can be overriden below
		sreturn local liml			`liml'			//  can be overriden below

//convert to boolean
		sreturn local useqr			=("`useqr'" ~= "")

// Cluster and SW imply robust
		if "`cluster'`sw'"~="" {
			local robust	"robust"
		}

// HAC estimation.

// First dkraay(bw): special case of HAC with clustering
// on time-series var in a panel + kernel-robust
		if `dkraay' {
			if "`bw'" == "" {
				local bw	`dkraay'
			}
			if "`cluster'" == "" {
				local cluster	`tvar'
			}
		}
// If bw is omitted, default `bw' is 0.
// bw(.) can be number or "auto" hence arrives as string, but is returned as number
// bw=-1 returned if "auto"
// If bw or kernel supplied, check/set `kernel'.
// Macro `kernel' is also used for indicating HAC in use.
// If bw or kernel not supplied, set bw=0
		if "`bw'" == "" & "`kernel'" == "" {
			local bw	0
		}
		else {
// Check it's a valid kernel and replace with unabbreviated kernel name; check bw.
// s_vkernel is in livreg2 mlib.
			mata: s_vkernel("`kernel'", "`bw'", "`ivar'")
			local kernel	`r(kernel)'
			local bw		`r(bw)'			//  = -1 if bw(auto) option chosen
			local tsops		= 1
		}
// kiefer = kernel(tru) bw(T) and no robust
		if "`kiefer'" ~= "" & "`kernel'" == "" {
			local kernel "Truncated"
		}

// Done parsing VCE opts
		sreturn local bw		`bw'
		sreturn local kernel	`kernel'
		sreturn local robust	`robust'
		sreturn local cluster	`cluster'
		if `bw' {
			sreturn local bwopt "bw(`bw')"
			sreturn local kernopt "kernel(`kernel')"
		}
// center arrives as string but is returned as boolean
		sreturn local center	=("`center'"=="center")

// Fuller implies LIML
		if `fuller' != 0 {
			sreturn local liml			"liml"
			sreturn local fulleropt		"fuller(`fuller')"
		}

		if `kclass' != 0 {
			sreturn local kclassopt		"kclass(`kclass')"
		}

// b0 implies noid.
		if "`b0'" ~= "" {
			sreturn local noid			"noid"
		}

// save first, rf
		if "`savefprefix'" != "" {						//  savefprefix implies savefirst
			local savefirst				"savefirst"
		}
		else {											//  default savefprefix is _ivreg2_
			local savefprefix			"_`ivreg2name'_"
		}
		sreturn local savefirst			`savefirst'
		sreturn local savefprefix		`savefprefix'
		if "`saverfprefix'" != "" {						//  saverfprefix implies saverf
			local saverf				"saverf"
		}
		else {											// default saverfprefix is _ivreg2_
			local saverfprefix			"_`ivreg2name'_"
		}
		sreturn local saverf			`saverf'
		sreturn local saverfprefix		`saverfprefix'
		if "`savesfprefix'" != "" {					//  savesfprefix implies savesfirst
			local savesfirst			"savesfirst"
		}
		else {											// default saverfprefix is _ivreg2_
			local savesfprefix			"_`ivreg2name'_"
		}
		sreturn local savesfirst		`savesfirst'
		sreturn local savesfprefix		`savesfprefix'

// Macro psd has either psd0, psda or is empty
		sreturn local psd		"`psd0'`psda'"

// dofminus
		if `dofminus' {
			sreturn local dofmopt	dofminus(`dofminus')
		}

// display options
		local dispopt			eform(`eform') `vsquish' `noomitted' `noemptycells' `baselevels' `allbaselevels'
// now boolean - indicates that omitted and/or base vars should NOT be added to VCV
// automatically triggered by partial
		local bvclean			= wordcount("`bvclean'") | wordcount("`partial'") | `partialcons'
		sreturn local bvclean	`bvclean'
		sreturn local dispopt	`dispopt'

// ************ ERROR CHECKS ************* //

		if `partialcons' & ~`cons' {
di in r "Error: _cons listed in partial() but equation specifies -noconstant-."
			exit 198
		}
		if `partialcons' > 1 {
// Just in case of multiple _cons
di in r "Error: _cons listed more than once in partial()."
			exit 198
		}

// User-supplied tvar and ivar checked if consistent with tsset.
		if "`tvar'"!="`_dta[_TStvar]'" {
di as err "invalid tvar() option - data already -tsset-"
			exit 5
		}
		if "`ivar'"!="`_dta[_TSpanel]'" {
di as err "invalid ivar() option - data already -xtset-"
			exit 5
		}

// dkraay
		if `dkraay' {
			if "`ivar'" == "" | "`tvar'" == "" {
di as err "invalid use of dkraay option - must use tsset panel data"
				exit 5
			}
			if "`dkraay'" ~= "`bw'" {
di as err "cannot use dkraay(.) and bw(.) options together"
				exit 198
			}
			if "`cluster'" ~= "`tvar'" {
di as err "invalid use of dkraay option - must cluster on `tvar' (or omit cluster option)"
				exit 198
			}
		}

// kiefer VCV = kernel(tru) bw(T) and no robust with tsset data
		if "`kiefer'" ~= "" {
			if "`ivar'" == "" | "`tvar'" == "" {
di as err "invalid use of kiefer option - must use tsset panel data"
				exit 5
			}
			if	"`robust'" ~= "" {
di as err "incompatible options: kiefer and robust"
				exit 198
			}
			if	"`kernel'" ~= "" & "`kernel'" ~= "Truncated" {
di as err "incompatible options: kiefer and kernel(`kernel')"
				exit 198
			}
			if	(`bw'~=0) {
di as err "incompatible options: kiefer and bw"
				exit 198
			}
		}

// sw=Stock-Watson robust SEs
		if "`sw'" ~= "" & "`cluster'" ~= "" {
di as err "Stock-Watson robust SEs not supported with -cluster- option"
				exit 198
		}
		if "`sw'" ~= "" & "`kernel'" ~= "" {
di as err "Stock-Watson robust SEs not supported with -kernel- option"
				exit 198
		}
		if "`sw'" ~= "" & "`ivar'"=="" {
di as err "Must -xtset- or -tsset- data or specify -ivar- with -sw- option"
			exit 198
		}

// LIML/kclass incompatibilities
		if "`liml'`kclassopt'" != "" {
			if "`gmm2s'`cue'" != "" {
di as err "GMM estimation not available with LIML or k-class estimators"
			exit 198
			}
			if `fuller' < 0 {
di as err "invalid Fuller option"
			exit 198
			}
			if "`liml'" != "" & "`kclassopt'" != "" {
di as err "cannot use liml and kclass options together"
			exit 198
			}
			if `kclass' < 0 {
di as err "invalid k-class option"
				exit 198
				}
		}

		if "`gmm2s'" != "" & "`cue'" != "" {
di as err "incompatible options: 2-step efficient gmm and cue gmm"
			exit 198
		}

		if "`gmm2s'`cue'" != "" & "`exexog'" == "" {
di as err "option `gmm2s'`cue' invalid: no excluded instruments specified"
			exit 102
		}

// Legacy gmm option
		if "`gmm'" ~= "" {
di as err "-gmm- is no longer a supported option; use -gmm2s- with the appropriate option"
di as res "      gmm             =  gmm2s robust"
di as res "      gmm robust      =  gmm2s robust"
di as res "      gmm bw()        =  gmm2s bw()"
di as res "      gmm robust bw() =  gmm2s robust bw()"
di as res "      gmm cluster()   =  gmm2s cluster()"
			exit 198
		}

// b0 incompatible options.
		if "`b0'" ~= "" & "`gmm2s'`cue'`liml'`wmatrix'" ~= "" {
di as err "incompatible options: -b0- and `gmm2s' `cue' `liml' `wmatrix'"
			exit 198
		}
		if "`b0'" ~= "" & `kclass' ~= 0 {
di as err "incompatible options: -b0- and kclass(`kclass')"
			exit 198
		}

		if "`psd0'"~="" & "`psda'"~="" {
di as err "cannot use psd0 and psda options together"
			exit 198
		}
end



program define IsStop, sclass
				/* sic, must do tests one-at-a-time,
				 * 0, may be very large */
	version 11.2
	if `"`0'"' == "[" {
		sret local stop 1
		exit
	}
	if `"`0'"' == "," {
		sret local stop 1
		exit
	}
	if `"`0'"' == "if" {
		sret local stop 1
		exit
	}
* per official ivreg 5.1.3
	if substr(`"`0'"',1,3) == "if(" {
		sret local stop 1
		exit
	}
	if `"`0'"' == "in" {
		sret local stop 1
		exit
	}
	if `"`0'"' == "" {
		sret local stop 1
		exit
	}
	else	sret local stop 0
end
