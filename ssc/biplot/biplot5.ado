*! biplot version 1.0.0 UK 18 Feb 98
* Vers0 22-7-97, NJC suggestions 12 Feb 1998, Rev. UK 18 Feb 1998
program define biplot
version 5.0
local varlist "req ex min(2)"
local if "opt"
local in "opt"
#delimit ;
local options "Symbol(string) NOBORder L1title(string) B2title(string)
               BBox(string) Pen(string) XScale(string) YScale(string)
               COVariance Flip(string) Type(string) STretch(real 1) *";
#delimit cr
parse "`*'"
parse "`varlist'", parse(" ")
local k: word count `varlist'

tempvar touse W colnr G1 G2 H1 H2 names                       /* Tempvar */
tempname O Y U W V U1 U2 V1 V2 L Vt G H

mark `touse' `if' `in'                                          /* if in */
markout `touse' `varlist'
*--------------------------------------------------------ERROR CHECKS------
quietly count if `touse'                          /* check observations */
local n = _result(1)
if `n' == 0 {
        display in blue "no observations"
        exit
}
if `n' <= 2 {
        display in blue "insufficient observations"
        exit
}
local type = trim(upper("`type'"))                      /* check matsize */
if "`type'" == "SQ" | "`type'" == "GH" {
        matrix `O' = J(`n',`k',0)
        mat drop `O'
}
if "`type'" == "" { local type "JK" }                     /* check types */
else {
    if "`type'" != "SQ" & "`type'" != "GH" & "`type'" != "JK" {
        di in r "invalid type"
        exit 198
    }
}
if `stretch' <= 0 {                                     /* check stretch */
    di in r "stretch invalid"
    exit 198
}
local flip = trim(lower("`flip'"))                         /* check flip */
if "`flip'" != "" & "`flip'" != "x" & "`flip'" != "y" & "`flip'" != "xy" {
    di in r "flip invalid"
    exit 198
}
*------------------------------------------------------------PCA----------
quietly {
        factor `varlist' if `touse', pc `covariance'
        local i = 1
        local vartot = 0
        while `i' <= `k' {
            local j = `i' + 6
            local vartot = `vartot' + _result(`j')
            local i = `i' + 1
        }
        local a=round(_result(7)/`vartot'*100,1) /*% of Var PC 1*/
        local b=round(_result(8)/`vartot'*100,1) /*% of Var PC 2*/
        *------------------------------------------------JK-BIPLOT--------
        if "`type'" == "JK" {
                score `G1' `G2' if `touse'
                matrix `H' = get(Ld)
                gen `H1' = `H'[_n,1]
                gen `H2' = `H'[_n,2]
        }
        *----------------------------------------------SQ/GH-BIPLOT-------
        else {
                preserve                                     /* listwise */
                keep if `touse'
                local i = 1
                if "`covariance'"~="" {                   /* Zentrierung */
                        while `i' <= `k' {
                            sum ``i''
                            replace ``i''= ``i''-_result(3)
                            local i = `i' + 1
                        }
                }
                else {                               /* Standardisierung */
                    while `i' <= `k' {
                        sum ``i''
                        replace ``i''= (``i''-_result(3))/sqrt(_result(4))
                        local i = `i' + 1
                    }
                }
                mkmat `varlist', matrix(`Y')                      /* SVD */
                matrix svd `U' `W' `V' =`Y'
                matrix `W' = `W''               /* sort W in desc. Order */
                gen `W' =`W'[_n,1]
                gen `colnr' = _n
                if "`type'"== "SQ" {replace `W'=sqrt(`W')}
                gsort -`W'
                local col1=`colnr'[1]
                local col2=`colnr'[2]
                matrix drop `W'
                mkmat `W' in 1/2, matrix(`W')
                sort `colnr'
                drop `colnr'
                matrix `W' = `W''                       /* make L from W */
                matrix `L' = diag(`W')
                matrix `U1'=`U'[1...,`col1']            /* reorder U & V */
                matrix `U2'=`U'[1...,`col2']
                matrix `U'=`U1',`U2'
                matrix `V1'=`V'[1...,`col1']
                matrix `V2'=`V'[1...,`col2']
                matrix `V'=`V1',`V2'
                matrix `Vt'=`V''
                matrix drop `W' `V' `Y' `U1' `U2' `V1' `V2'
                if "`type'"=="GH" {                                /* GH */
                        matrix `G' =`U'
                        matrix `H' =`L'*`Vt'
                        matrix `H' = `H''
                }
                else if "`type'"=="SQ" {                           /* SQ */
                        matrix `G' =`U'*`L'
                        matrix `H' = `L'*`Vt' /* sqrt(L) in line97 */
                        matrix `H' = `H''
                }
                matrix drop `U' `L' `Vt'
                local i = 1                           /* Variables G & H */
                while `i' <= 2 {
                        tempvar G_`i' H_`i'
                        gen `G`i'' = `G'[_n,`i']
                        gen `H`i'' = `H'[_n,`i']
                        local i = `i' + 1
                }
        }
        *-----------------------------------------------OPTIONS-----------
        if `stretch' != 1 {                                   /* stretch */
                replace `H1'=`H1'*`stretch'
                replace `H2'=`H2'*`stretch'
        }
        if "`flip'"=="x" {                                       /* flip */
                replace `G1'=`G1'*-1
                replace `H1'=`H1'*-1
        }
        else if "`flip'"=="y" {
                replace `G2'=`G2'*-1
                replace `H2'=`H2'*-1
        }
        else if "`flip'"=="xy" {
                replace `G1'=`G1'*-1
                replace `H1'=`H1'*-1
                replace `G2'=`G2'*-1
                replace `H2'=`H2'*-1
        }
        *-----------------------------------------------DESIGN------------
        gen  `names' =_n                                        /* Label */
        lab val  `names'  names
        local i 1
        while `i'<= `k' {
                lab def names `i' "`1'", modify
                macro shift
                local i=`i'+1
        }
        sum `G1'                                               /* Skalen */
        local minG1=_result(5)
        local maxG1=_result(6)
        sum `G2'
        local minG2=_result(5)
        local maxG2=_result(6)
        sum `H1'
        local minH1=_result(5)
        local maxH1=_result(6)
        sum `H2'
        local minH2=_result(5)
        local maxH2=_result(6)
        local minx = min(`minG1', `minH1')
        local miny = min(`minG2', `minH2')
        local maxx = max(`maxG1', `maxH1')
        local maxy = max(`maxG2', `maxH2')
        local min = min(`minx',`miny')
        local max = max(`maxx',`maxy')
        *--------------------------------------DATACOORDINATES VARIABLES--
        local i=1
        while `i'<=`k' {
                sum `H2' in `i'
                local r`i'=_result(3)
                sum `H1' in `i'
                local c`i'=_result(3)
                local i=`i'+1
        }
}
*---------------------------------------------------------DEFAULTS--------
if "`symbol'" == "" {local symbol "O"}
if "`noborder'" == "" {local border "border"}
if "`xscale'" == "" {local xscale  "`min',`max'"}
parse "`xscale'", parse(",")
if `1' > `min' & `3' < `max' {local xscale  "`min',`max'"}
else if `1' > `min' & `3' >= `max' {local xscale  "`min',`3'"}
else if `1' <= `min' & `3' < `max' {local xscale  "`1',`max'"}
if "`yscale'" == "" {local yscale  "`min',`max'"}
parse "`yscale'", parse(",")
if `1' > `min' & `3' < `max' {local yscale  "`min',`max'"}
else if `1' > `min' & `3' >= `max' {local yscale  "`min',`3'"}
else if `1' <= `min' & `3' < `max' {local yscale  "`1',`max'"}
if "`l1title'" == "" {local l1title ""DIM 2 (`b' % of Var)""}
if "`b2title'" == "" {local b2title ""DIM 1 (`a' % of Var)""}
if "`bbox'"== "" {local bbox "0,4469,23063,27532,923,444,0"}
if "`pen'"=="" {local pen "2"}
*-----------------------------------------------------------GRAPHIK--------
gph open
graph `G2' `G1',s(`symbol') xscale(`xscale') yscale(`yscale') /*
*/ pen(`pen') `border' l1title(`l1title') b2title(`b2title') bbox(`bbox')/*
*/ `options'
graph `H2' `H1',s([`names']) xscale(`xscale') yscale(`yscale') /*
*/ pen(3) `border' l1title(`l1title') b2title(`b2title') bbox(`bbox')/*
*/ `options'
local i=1
gph pen 3
local r0 = _result(6)                             /* Ursprungkoordinaten */
local c0 = _result(8)
while `i'<=`k' {
      local r`i'=`r`i''*_result(5)+_result(6)    /* Dat.koor->Screenkoor */
      local c`i'=`c`i''*_result(7)+_result(8)
      gph line `r`i'' `c`i'' `r0' `c0'                          /* Lines */
      local i=`i'+1
}
gph close
end
