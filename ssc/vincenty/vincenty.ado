*! Author: Austin Nichols
*! Version 1.0.3 15 Feb, 2007
*! Version 1.0.2 10 Apr, 2006
*! Version 1.0.1  1 Aug, 2005
*! Version 1.0 sometime in 2004
*! ..Purpose:
*! vincenty is used for calculating geodesic distances 
*! between a pair of points on the surface of the Earth
*! (specified in signed decimal degrees latitude and longitude),
*! using an accurate ellipsoidal model of the Earth.
*! see http://www.ngs.noaa.gov/PUBS_LIB/inverse.pdf
*! ..Acknowledgements:
*! The program is named for Thaddeus Vincenty who wrote
*! "Direct and Inverse Solutions of Geodesics on the Ellipsoid 
*! with application of nested equations" but the code
*! borrows extensively from Javascript code at
*! http://www.movable-type.co.uk/scripts/LatLongVincenty.html
*! [accessed 1 Aug, 2005].
*! ..Limitations:
*! The calculations are accurate to insane precision
*! assuming elevation above the ellipsoid is zero, so the
*! real 3D distance could differ substantially.
*! Note that elevation, even if available, cannot be
*! included in these calculations. 
*! The calculations fail if distance is close to a quarter
*! of the Earth's circumference, or if it is close to zero,
*! where the trig functions tax the limits of
*! machine precision.
#delimit;
cap prog drop vincenty;
prog vincenty, rclass;
version 8.2;
syntax [anything] [in] [if] [, Immed 
 Vin(name) Hav(name) Loc(name) replace PRECision(int 10)
 Maxiter(int 100) by(varlist) inkm];
tokenize `anything';
if "`by'"!="" local byvar="`by' :";
local lat2="`1'"; local lon2="`2'"; 
local lat1="`3'"; local lon1="`4'";
if `"`5'"'!="" {;
    di as err "Four numbers or variables should be specified";
    di as err "(Two pairs of signed decimal degrees lat/lon)";
    di as err "See " as res "help vincenty";
    error 198; };
if "`gd'"=="" local gd="`vin'";
if "`gd'"=="" local gd="`hav'";
if "`gd'"=="" local gd="`loc'";
if "`gd'"=="" local immed="now";
foreach v in vin hav loc {;
  if "`replace'"=="" & "``v''"!="" conf new var ``v''; 
  if "`replace'"!="" cap drop ``v''; 
  local ren`v'="``v''";
  if "``v''"=="" tempvar `v'; 
  cap gen double ``v''=.;
  };
if "`immed'"!="" {;
 conf num `lat2';  conf num `lon2';  conf num `lat1';  conf num `lon1';
 if "`in'`if'"!="" {; di as err "You cannot specify in or if with immed option";error 198;};
 local in="in 1"; if `=c(N)'==0 cap set obs 1; if "`gd'"=="" tempvar gd;
 if `lat2'>90 | `lat2'<-90 | `lat1'>90 | `lat1'<-90 |
    `lon2'>180 | `lon2'<-180 | `lon1'>180 | `lon1'<-180 {;
       di as err "Invalid lat/lon: lat must be in [-90,90] and lon must be in [-180,180]";
       error 198; };
 };
 else if "`replace'"=="" {;
  foreach v in `lat2' `lat1' {;
     cap su `v'; if _rc==0 {; local r=max(abs(r(min)),r(max)); }; else {; local r=`v'; };
     if `r'>90 {; di as err "Latitude must be in [-90,90]"; error 198; };
     };
  foreach v in `lon2' `lon1' {;
     cap su `v'; if _rc==0 {; local r=max(abs(r(min)),r(max)); }; else {; local r=`v'; };
     if `r'>180 {; di as err "Longitude must be in [-180,180]"; error 198; };
     };
  };
local k=1.609344; local k0=`k'*1000; 
foreach v in L U1 U2 Lambda U1 U2 uSq A B deltaSigma sinSigma cosSigma 
    sigma alpha cosSqAlpha cos2SigmaM C lambdaP dlambda {;
    tempvar `v'; 
    };
local R=6367.44; 
/* The circumference of the earth at the equator is 24,901.55 mi (40,075.16 km),
   but the circumference through the poles is 24,859.82 mi (40,008 km). 
    Geometric mean radius from this info is 6372.8km, or 3959.88mi 
  But:
  (6356752.3142+6378137)/2000 = 6367.4447km = 3956.5467mi
  (6356752.3142*6378137)^.5/1e3 = 6367.4357km = 3956.5411mi
*/
  local a = 6378137;
  local b = 6356752.3142;
  local f = 1/298.257223563; *f=(a-b)/a;
  qui g double `L'=(`lon2'-`lon1')*_pi/180 `in' `if';
       qui replace `L'=(`lon2'-`lon1'-360)*_pi/180 if `L'<. & `L'>_pi;
       qui replace `L'=(`lon2'-`lon1'+360)*_pi/180 if `L'<-_pi;
  qui g double `Lambda' = `L' `in' `if';
  qui g double `U1' = atan((1-`f') * tan(`lat1'*_pi/180)) `in' `if';
  qui g double `U2' = atan((1-`f') * tan(`lat2'*_pi/180)) `in' `if';

  qui replace `loc'=acos(sin(`lat2'*_pi/180)*sin(`lat1'*_pi/180)+
    cos(`lat2'*_pi/180)*cos(`lat1'*_pi/180)*cos(`L'))*`R'/`k'^("`inkm'"=="");
  qui replace `hav'=`R'*2*atan2(sqrt((sin((`lat2' - `lat1')*_pi/360))^2 
    + cos(`lat1'*_pi/180) * cos(`lat2'*_pi/180) * (sin(`L'/2))^2)
        ,sqrt(1-((sin((`lat2' - `lat1')*_pi/360))^2 + cos(`lat1'*_pi/180) 
    * cos(`lat2'*_pi/180) * (sin(`L'/2))^2))) /`k'^("`inkm'"=="");

  local iterLimit = 1; local dls=1;
  while (abs(`dls') > `=1e-`precision'' & `iterLimit'<`maxiter') {;
    foreach v in sinSigma cosSigma sigma alpha cosSqAlpha cos2SigmaM C lambdaP dlambda {;
     cap drop ``v'';};
    qui g double `sinSigma' =sqrt((cos(`U2')*sin(`Lambda') * (cos(`U2')*sin(`Lambda'))) + 
      (cos(`U1')*sin(`U2')-sin(`U1')*cos(`U2')*cos(`Lambda')) 
      * (cos(`U1')*sin(`U2')-sin(`U1')*cos(`U2')*cos(`Lambda'))) `in' `if';
    qui g double `cosSigma' =(sin(`U1')*sin(`U2')+cos(`U1')*cos(`U2')*cos(`Lambda')) `in' `if';
    qui g double `sigma' = atan2(`sinSigma',`cosSigma') `in' `if';
    qui g double `alpha' = asin(cos(`U1') * cos(`U2') * sin(`Lambda') / `sinSigma') `in' `if';
    qui g double `cosSqAlpha' = cos(`alpha') ^2 `in' `if';
    qui g double `cos2SigmaM' = `cosSigma' - 2*sin(`U1')*sin(`U2')/`cosSqAlpha' `in' `if';
    qui g double `C' = `f'/16*`cosSqAlpha'*(4+`f'*(4-3*`cosSqAlpha')) `in' `if';
    qui g double `lambdaP' = `Lambda' `in' `if';
    qui replace `Lambda' = `L' + (1-`C') * `f' * sin(`alpha') *
      (`sigma' + `C'*`sinSigma'*(`cos2SigmaM'+`C'*`cosSigma'*(-1+2*`cos2SigmaM'^2))) `in' `if';
    qui g double `dlambda'=abs(`Lambda'-`lambdaP') `in' `if';
        su `dlambda', meanonly;
    local dls=r(max);
    local iterLimit=`iterLimit'+1;
   };
  if (`iterLimit'==0) {; di as err "Formula failed to converge"; 
    di as err "FOR:" _n "Lat2= `lat2'; Lon2= `lon2';"; 
    di "Lat1= `lat1'; Lon1= `lon1'";
    *exit 3003;};
  else di as txt "Finished in " `maxiter'-`iterLimit' " iterations";
  qui g double `uSq' = (`cosSqAlpha')*(`a'^2-`b'^2)/(`b'^2);
  qui g double `A' = 1 + (`uSq')/16384*(4096+(`uSq')*(-768+(`uSq')*(320-175*(`uSq'))));
  qui g double `B' = (`uSq')/1024 * (256+(`uSq')*(-128+(`uSq')*(74-47*(`uSq'))));
  qui g double `deltaSigma' = (`B')*(`sinSigma')*((`cos2SigmaM')+(`B')/4*((`cosSigma')*
   (-1+2*(`cos2SigmaM')^2)-(`B')/6*(`cos2SigmaM')*(-3+4*(`sinSigma')^2)*(-3+4*(`cos2SigmaM')^2)));
 if "`immed'"!="" {;
  local ivin = `b'*(`A')*((`sigma')-(`deltaSigma')) /1000;
  di as txt _n "Distance from (" `lat2' "," `lon2' ") to (" `lat1' "," `lon1' ")";
  di "is " `ivin'/`k' " miles, or " `ivin' " km";
  di "(approx. five significant figures).";
  local ivin = `b'*(`A')*((`sigma')-(`deltaSigma')) /1000/`k'^("`inkm'"=="");
  return local vin "`ivin'";
  qui su `hav', meanonly; ret local hav "`=r(mean)'";
  qui su `loc', meanonly; ret local loc "`=r(mean)'";
  };
 else {;
    qui replace `vin' = `b'*(`A')*((`sigma')-(`deltaSigma'))/1000/`k'^("`inkm'"=="") `in' `if';
    qui replace `vin' = . if `vin' <=0;
 };
end;
