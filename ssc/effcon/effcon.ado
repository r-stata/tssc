program effcon,rclass
/* 
   calculates a one-sided confidence limit for the effect size E
   a) normally distributed observations from one group E = mu/sig
   b) normally distributed observations from two groups with the same variance E = (mu1-mu2)/sig
   revised 12/14/2007
   uses Tom Steichen's noncentral t utility "nctncp" in nct package

   `confdir' is direction of confidence limit Upper or Lower

*/
version 9.0    
local B "1e530"
syntax [varlist (default=none)] [if] [in] , [group(string) confdir(string) level(real .95) xb1(real `B') n1(real `B') xb2(real `B') n2(real `B') s(real `B') ] 
if `level' >= 1 local level=`level'/100
local pct = 100*`level'
local nv2 = 0
cap confirm existence `group'
if _rc==0  local nv2=1 // nv2=1 if `group' variable exists
//di "nv2 = `nv2'"
tokenize `varlist'
local nv1: word count `varlist'
if `nv1'==1 & `nv2' == 0 {  // standard mode, no `group' option => one group
args x
qui summ `x' `if' `in'
local n1=r(N)
local xb1=r(mean)
local s = r(sd)
local nsamp=1
}
if `nv1'==1 & `nv2'==1  {  // standard mode with `group' option => two groups
args x
qui ttest `x',by(`group')
local xb1 = r(mu_1)
local xb2 = r(mu_2)
local n1 = r(N_1)
local n2 = r(N_2)
local v1=r(sd_1)^2
local v2=r(sd_2)^2
local N = `n1'+`n2'-1
local df = `N'-1
local s = sqrt(  (`v1'*(`n1'-1)+ `v2'*(`n2'-1) )/`df') //pooled SD
local nsamp=2
}

if `nv1'==0 {    //interactive mode
local a =`n1'< .
local b = `xb1'< .
local c = `s' < .
local d = `n2'< .
local e =`xb2' < .
if `a'+ `b'+`c'+`d'==0 local nsamp=2
local nsamp = `a'*`b'*`c'*(1 + `d'*`e')
//di "a,b,c,d,e,nsamp = `a',`b',`c',`d',`e',`nsamp'"
if `d'+`e'>0 & `d'*`e'==0 {
 di in yellow "Warning: one, but not both of xb2 and n2 were specified"
 di "          (only info for first sample was used)"

 }
}

local dir = upper(substr("`confdir'",1,1))
if "`dir'"==""  local dir "L"  // default to lower confidence limit if none specified
if "`dir'"=="L"  local p = `level'  //lower conf for mu/sig
if "`dir'"=="U"  local p = 1-`level'    //upper conf mu/sig
// ---------- 1-sample confidence limits for mu/sig ------------
if `nsamp'==1 {   
local rn = sqrt(`n1')		/*sqrt # of obs*/
local df = `n1'-1			/*degrees of freedom*/
local Z0 = `xb1'/`s'
local tp = `rn'*`Z0'
qui nctncp `tp' `p' `df' //Tom Steichen's "G-1" program for noncentral t
local del = r(delta)
local Zp = `del'/`rn'
//di "Zp = ", %10.5f `Zp'
}
// ---------- 2-sample confidence limits for (mu1-mu2)/sig ------------
if `nsamp'==2 {
local N = `n1'+`n2'-1
local df = `N'-1
local C = sqrt(`N'*(1/`n1'+1/`n2'))
local R = 1/(1/`n1'+1/`n2')
local rn = sqrt(`N')
local Z0 = (`xb1'-`xb2')/`s'
local tp = `rn'*`Z0'/`C'
local df = `N'-1
qui nctncp `tp' `p' `df'   //Tom Steichen's "G-1" program for noncentral t
local del = r(delta)
local Zp = `C'*`del'/`rn'
//di "Zp = ", %10.5f `Zp'
}

//di in green" Point Estimate = ",`Z0'
if "`dir'"=="L" & `nsamp'==1 {
        di in bl"Point Estimate and Lower `pct'% Limit for mu/sig : ",%9.4g `Z0'  %9.4g `Zp' 
 						}
if "`dir'"=="U" & `nsamp'==1 {
        di in bl"Point Estimate and Upper `pct'% Limit for mu/sig : ",%9.4g `Z0'  %9.4g `Zp' 
}

if "`dir'"=="L" & `nsamp'==2 {
        di in bl"Point Estimate and Lower `pct'% Limit for (mu1-mu2)/sig : ",%9.4g `Z0' %9.4g `Zp' 
 						}
if "`dir'"=="U" & `nsamp'==2 {
        di in bl"POint Estimate and Upper `pct'% Limit for (mu1-mu2)/sig : ",%9.4g `Z0' %9.4g `Zp' 
}

if `nsamp'==1 {
 local n2 = .
 local R = .
 local xb2 = .
}
return scalar level =`level'
return scalar R = `R'
return scalar s=`s'
return scalar n2=`n2'
return scalar n1=`n1'
return scalar xb2=`xb2'
return scalar xb1=`xb1'
return scalar Z0 = `Z0'
return scalar Zp = `Zp'










end








