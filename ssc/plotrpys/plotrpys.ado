program def plotrpys, rclass
*! plotrpys v4 LutzBornmann January2018
version 11

quietly summarize year, detail
syntax varlist(min=3 max=3 numeric) , color(string) curve(string)/*
*/ [startyr(integer `r(min)') incre(integer 50) endyr(integer `r(max)')]
local year: word 1 of `varlist'
local ncr: word 2 of `varlist'
local devmed: word 3 of `varlist'
tabstat `year', stat(min max range)

gen median5_p=median5 if median5>=0
quietly sum median5_p, detail
local out3 = r(p75) + 3 * (r(p75) - r(p25))
local out1 = r(p75) + 1.5 * (r(p75) - r(p25))
gen median5_v = year if median5_p > `out3' & median5_p ~= .

gen low = invchi2(2*`ncr', 0.025)/2
gen high = invchi2(2*(`ncr'+1), 0.975)/2

set scheme plottig

if "`color'" == "mono" & "`curve'" == "both" {
twoway (scatter `ncr' `year', yaxis(1 2) mfcolor(white) /*
*/ connect(l .) lcolor(black) mlcolor(black) msize(small))/*
*/ (scatter `devmed' `year', mfcolor(black) mlcolor(black) /*
*/ connect(l .)  lcolor(black) msize(small)), /*
*/ ytitle("Cited references counts", axis(1)) ytitle("Deviation from median", axis(2)) /*
*/ xtitle("Reference publication year") /*
*/ legend(order(1 "Cited references counts" 2 "Deviation from median") /*
*/ ring(0) position(10) bmargin(large)) /*
*/ xlabel(`startyr'(`incre')`endyr')
}

if "`color'" == "col" & "`curve'" == "both" {
twoway (scatter `ncr' `year', yaxis(1 2) mfcolor(red) /*
*/ connect(l .) lcolor(red) mlcolor(red) msize(small))/*
*/ (scatter `devmed' `year', mfcolor(blue) mlcolor(blue) /*
*/ connect(l .)  lcolor(blue) msize(small)), /*
*/ ytitle("Cited references counts", axis(1)) ytitle("Deviation from median", axis(2)) /*
*/ xtitle("Reference publication year") /*
*/ legend(order(1 "Cited references counts" 2 "Deviation from median") /*
*/ ring(0) position(10) bmargin(large)) /*
*/ xlabel(`startyr'(`incre')`endyr')
}

if "`color'" == "mono" & "`curve'" == "median" {
twoway scatter `devmed' `year', mfcolor(black) mlcolor(black) /*
*/ connect(l .)  lcolor(black) msize(small) /*
*/ ytitle("Deviation from median") /*
*/ xtitle("Reference publication year") /*
*/ yline(`out3', lcolor(black) lwidth(thick) lpattern(dot)) yline(0, lpattern(solid) lcolor(black)) /*
*/ yline(`out1', lcolor(black) lwidth(thick) lpattern(dot)) /*
*/ mlabel(median5_v) mlabposition(1) mlabsize(tiny) mlabangle(90)/*
*/ legend(off) /*
*/ xlabel(`startyr'(`incre')`endyr')
}

if "`color'" == "col" & "`curve'" == "median" {
twoway scatter `devmed' `year', mfcolor(blue) mlcolor(blue) /*
*/ connect(l .)  lcolor(blue) msize(small) /*
*/ yline(`out3', lcolor(black) lwidth(thick) lpattern(dot)) yline(0, lpattern(solid) lcolor(black)) /*
*/ yline(`out1', lcolor(black) lwidth(thick) lpattern(dot)) /*
*/ mlabel(median5_v) mlabposition(1) mlabsize(tiny)  mlabangle(90)/*
*/ ytitle("Deviation from median") /*
*/ xtitle("Reference publication year") /*
*/ xlabel(`startyr'(`incre')`endyr')
}

if "`color'" == "mono" & "`curve'" == "sample" {
twoway rcap low high `year', /*
*/ ytitle("Cited references counts") /*
*/ xtitle("Reference publication year") /*
*/ legend(off) /*
*/ xlabel(`startyr'(`incre')`endyr')
}

if "`color'" == "col" & "`curve'" == "sample" {
twoway rcap low high `year', mfcolor(red) /*
*/ lcolor(red) mlcolor(red)/*
*/ ytitle("Cited references counts") /*
*/ xtitle("Reference publication year") /*
*/ legend(off) /*
*/ xlabel(`startyr'(`incre')`endyr')
}

if ("`color'" ~= "col") & ("`color'" ~= "mono") {
display "The color option must be 'col' or 'mono'"
}

if ("`curve'" ~= "median") & ("`curve'" ~= "both") & ("`curve'" ~= "sample") {
display "The curve option must be 'both', 'median' or 'sample'"
}

drop median5_p median5_v low high

end

