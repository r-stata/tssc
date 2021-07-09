*! Marginal Effects for Selection Endogenous
*! Treatment after setpoisson
*! Version 1.0
*! Author: Alfonso Miranda
*! Date: 23.02.2010

capture program drop petpoisson_me
program define petpoisson_me, eclass
version 11

syntax [if] [in], [DMEan DMOde XBQuantile(string) CMOde(string)]

/* check that correct estimates are in memory */

if (e(cmd)!="petpoisson") {
 di red "last estimates not found"
 error 301
}

/* sort out options */

if ("`dmean'" != "" & "`dmode'" != "") {
#delimit ; 
di in red "options" in gre " dmean " in red "and" in gre " dmode " in red 
 "cannot be combined together";
#delimit cr
 error 198
}
if ("`dmean'" != "" | "`dmode'" != "") & "`xbquantile'" != "" {
#delimit ; 
di in red "options" in gre " dmean " in red "and" in gre " dmode " in red 
 "cannot be combined with " in gre "xbquantile";
#delimit cr
 error 198
}
if ("`dmean'" == "" & "`dmode'" == "" & "`xbquantile'" == "") {
 local option_1 = 1
}
if "`dmean'" != "" {
 local option_1 = 1
}
if "`dmode'" != "" {
 local option_1 = 2
}
if "`xbquantile'" != "" {
 local option_1 = 3
 capture assert (`xbquantile'>=0 & `xbquantile'<=1)
 if (_rc==9) {
  di in red "option" in gre " xbquantile " in red "should be a real number in [0,1]"
  exit 198
 }
}
if "`xbquantile'" != "" {
 local qxb = `xbquantile'
}
else {
 local qxb "" 
}
/* get sample */ 
marksample touse

/* calculate marginal effects */

if ("`cmode'" != "") {
 gettoken cvar atcmode : cmode
 mata: MagEff_petpcmode("e(exedv)"," e(exsv)","e(exordv)","`touse'", "`cvar'",`atcmode')
}
else{
 mata: MagEff_petpoisson("e(exedv)"," e(exsv)","e(exordv)","`touse'", `option_1',`qxb')
}
drop one

/* save ME matrices in e() */

if ("`cmode'" != "") {
 ereturn matrix ME_Poisson = ME_Poisson
}
else {
 ereturn matrix ME_EP = ME_EP
 ereturn matrix ME_Poisson = ME_Poisson
 ereturn matrix ME_ET = ME_ET
}
end


