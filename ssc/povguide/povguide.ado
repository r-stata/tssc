/*
povguide.ado  8-6-2003
By David Kantor.

Get the poverty guideline for a household, given its size.

This is the GUIDELINE -- not the THRESHOLD (which is more complex).

Properly, Alaska and Hawaii have their own set of values; we don't
cover those areas here.

see http://aspe.hhs.gov/poverty/figures-fed-reg.htm

Individual years are found at, e.g., 
 http://aspe.hhs.gov/poverty/99poverty.htm
(Those have the AK & HI figures.)

Another source found (on 8-16-2008) is
www.ssa.gov/policy/docs/statcomps/2006/3e.html#table3.e8


4-7-2007 updating with figures for 2004-2007 from
http://aspe.hhs.gov/poverty/figures-fed-reg.shtml

4-21-2008 updating with figures for 2008.

8-16-2008 expanding the range back to 1973.
Note that figures are available back to 1965, BUT prior to 1973, the
increments were not all the same, so this scheme will not work for those
early years.

*/


* version 1.0  8-6-2003
* version 1.1  4-7-2007
*! version 1.2  4-21-2008


program def povguide
version 8.2

syntax , gen(string) famsize(string) year(string)
/* Could have famsize(varname) year(integer); that's a bit more restrictive.
year is most likely a constant, but we allow it to be an expression.

Thus, both famsize and year can be expressions.

Some programming borrowed from cpiadj.ado.

*/

capture confirm new var `gen'
if _rc~=0 {
  disp as err "gen must be new var"
  exit 198
}


tempname povtable

#delimit ;
matrix input `povtable' = (
/*       base  incr */
/*1973*/ 2200,  700  \
/*1974*/ 2330,  740  \
/*1975*/ 2590,  820  \
/*1976*/ 2800,  900  \
/*1977*/ 2970,  960  \
/*1978*/ 3140, 1020  \
/*1979*/ 3400, 1100  \
/*1980*/ 3790, 1220  \
/*1981*/ 4310, 1380  \
/*1982*/ 4680, 1540  \  /* 1982 applies to nonfarm only */
/*1983*/ 4860, 1680  \
/*1984*/ 4980, 1740  \
/*1985*/ 5250, 1800  \
/*1986*/ 5360, 1880  \
/*1987*/ 5500, 1900  \
/*1988*/ 5770, 1960  \
/*1989*/ 5980, 2040  \
/*1990*/ 6280, 2140  \
/*1991*/ 6620, 2260  \
/*1992*/ 6810, 2380  \
/*1993*/ 6970, 2460  \
/*1994*/ 7360, 2480  \
/*1995*/ 7470, 2560  \
/*1996*/ 7740, 2620  \
/*1997*/ 7890, 2720  \
/*1998*/ 8050, 2800  \
/*1999*/ 8240, 2820  \
/*2000*/ 8350, 2900  \
/*2001*/ 8590, 3020  \
/*2002*/ 8860, 3080  \
/*2003*/ 8980, 3140  \
/*2004*/ 9310, 3180  \
/*2005*/ 9570, 3260  \
/*2006*/ 9800, 3400  \
/*2007*/ 10210, 3480 \
/*2008*/ 10400, 3600
);
#delimit cr


local yearlo "1973"
local yearhi "2008"



tempvar year1
capture gen int `year1' = (`year')
if _rc ~=0 {
    disp in red "invalid expression for year: `year'"
    exit 198
}

capture assert (`year1' >= `yearlo' & `year1' <= `yearhi') | mi(`year1')
if _rc ~=0 {
    disp as error  "Warning: year expression has out-of-bounds values"
    /* But do not exit; just let out-of-bounds values yield missing. */
}

capture assert ~mi(`year1')
if _rc ~=0 {
    disp as error  "Warning: year expression yields some missing values"
    /* But do not exit. */
}

tempvar index1 /* index for year */

gen int `index1' = (`year1' - `yearlo') + 1



tempvar base incr
gen int `base' = `povtable'[`index1', 1]
gen int `incr' = `povtable'[`index1', 2]



tempvar famsiz1
capture gen int `famsiz1' = (`famsize')
/* Note that that is loaded into an int; will be truncated if non-integer.*/
if _rc ~=0 {
    disp in red "invalid expression for famsize: `famsize'"
    exit 198
}

capture assert `famsiz1' >= 1
if _rc ~=0 {
    disp as error  "Warning: famsize expression has out-of-bounds values (<1)"
    /* But do not exit; just let out-of-bounds values yield missing. */
}

capture assert ~mi(`famsiz1')
if _rc ~=0 {
    disp as error  "Warning: famsize expression yields some missing values"
    /* But do not exit. */
}

/* bottom-code  famsiz1 at 1. */
quietly replace `famsiz1' = 1 if `famsiz1' < 1

gen long `gen' = `base' + (`famsiz1' - 1)* `incr'
quietly compress `gen'
end

