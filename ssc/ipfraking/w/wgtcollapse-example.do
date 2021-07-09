*** Examples for the 2017 update of ipfraking

clear
program drop _all

sjlog using ipfr.whatsdeff, replace
webuse nhanes2, clear
whatsdeff finalwgt
return list
whatsdeff finalwgt, by(sex)
return list
sjlog close, replace

matrix ACS2011_sex_age = ( ///
    153267860*0.274, 153267860*0.275, 153267860*0.173, /// males
    158324057*0.260, 158324057*0.276, 158324057*0.207  /// females
)
matrix colnames ACS2011_sex_age = 11 12 13 21 22 23
matrix coleq    ACS2011_sex_age = _one
matrix rownames ACS2011_sex_age = sex_age

scalar ACS2011_total_pop = 311591917
matrix ACS2011_adult_pop = ACS2011_sex_age * J(colsof(ACS2011_sex_age),1,1)

matrix Census2011_region = ///
    (55521598, 67158835, 116046736, 72864748 )
matrix Census2011_region = Census2011_region * ACS2011_adult_pop / ACS2011_total_pop
matrix colnames Census2011_region = 1 2 3 4
matrix coleq    Census2011_region = _one
matrix rownames Census2011_region = region

matrix Census2011_race = ///
    (243470497, 40750746, 27370674 )
matrix Census2011_race = Census2011_race * ACS2011_adult_pop / ACS2011_total_pop
matrix colnames Census2011_race = 1 2 3
matrix coleq    Census2011_race = _one
matrix rownames Census2011_race = race

webuse nhanes2, clear
gen byte _one = 1
generate byte age_grp = 1 + (age>=40) + (age>=60) if !mi(age)
generate sex_age = sex*10 + age_grp

ipfraking [pw=finalwgt], gen( rakedwgt3 ) ///
    ctotal( ACS2011_sex_age Census2011_region Census2011_race ) ///
    trimhiabs( 200000 ) trimloabs( 2000 ) meta


sjlog using ipfr.report1, replace
ipfraking_report using rakedwgt3-report, raked_weight(rakedwgt3) replace by(_one)
sjlog close, replace

sjlog using ipfr.report2, replace
use rakedwgt3-report, clear
list C_Total_Margin_Variable_Name C_Total_Margin_Category_Label ///
	Category_Total_Target Category_Total_RKDWGT DEFF_SRCWGT DEFF_RKDWGT , ///
	sepby( C_Total_Margin_Variable_Name )
sjlog close, replace

sjlog using ipfr.collapse1, replace
clear
set obs 4
gen byte x = _n
label define x_lbl 1 "One" 2 "Two" 3 "Three" 4 "Four"
label values x x_lbl
wgtcellcollapse define, var(x) from(1 2 3) to(123)
wgtcellcollapse report, var(x)
sjlog close, replace

sjlog using ipfr.collapse2, replace
wgtcellcollapse report, var(x) break
wgtcellcollapse define, var(x) clear
wgtcellcollapse define, var(x) from(1 2 3) to(123) label("One through three")
wgtcellcollapse report, var(x) break
sjlog close, replace

sjlog using ipfr.collapse3, replace
clear
set obs 4
gen byte x = _n
label define x_lbl 1 "One" 2 "Two" 3 "Three" 4 "Four"
label values x x_lbl
wgtcellcollapse sequence, var(x) from(1 2 3 4) depth(3)
wgtcellcollapse report, var(x)
sjlog close, replace

sjlog using ipfr.collapse4, replace
wgtcellcollapse candidate, var(x) cat(2)
sreturn list
wgtcellcollapse candidate, var(x) cat(2) max(9)
sreturn list
wgtcellcollapse candidate, var(x) cat(212)
sreturn list
wgtcellcollapse candidate, var(x) cat(55)
sreturn list
sjlog close, replace

sjlog using ipfr.collapse5, replace
wgtcellcollapse define, var(x) clear
wgtcellcollapse sequence, var(x) from(2 4 1 3) depth(2)
wgtcellcollapse report, var(x)
sjlog close, replace



*** wgtcellcollapse example

clear
set scheme s1color
set linesize 84

* stations
input str16 station_name
	"Alewife"
	"Brookline"
	"Carmenton"
	"Dogville"
	"East End"
	"Framington"
	"Grand Junction"
	"High Point"
	"Irvingtown"
	"Johnsville"
	"King Street"
	"Limerick"
	"Moscow City"
	"Ninth Street"
	"Ontario Lake"
	"Picadilly Square"
	"Queens Zoo"
	"Redline Circle"
	"Silver Spring"
	"Toledo Town"
	"Union Station"
end

set seed 135042
gen byte station_id = sum(1+8*uniform()^1.5)

list

* labels
sum station_id, mean
forvalues i=1/`=r(max)' {
	qui {
		count if station_id == `i'
		if r(N) == 1 {
			qui levelsof station_name if station_id == `i', clean
			lab def station_lbl `i' "`r(levels)'", modify
		}
	}
}
lab val station_id station_lbl
numlabel station_lbl, add

* general attraction potential
gen int size = 5 + 100*exp(rnormal()*1.6)
* everybody exits at the end of the line
replace size = size + 2345 in l


save stations, replace

sjlog using ipfr.trip.sta, replace
use stations, clear
list station_id, sep(0)
sjlog close, replace

* dayparts
expand 5
bysort station_id : gen byte daypart = _n
lab def daypart_lbl 1 "AM Peak" 2 "Midday" 3 "PM Reverse Peak" 4 "Night" 5 "Weekend"
lab val daypart daypart_lbl

* boardings are proportonal to size, with some modifications
gen int geton = size * exp( rnormal()*0.6 + 3*(daypart==1) + 2*(daypart==3) )

* alightings are proproprtional to size conditional on boarding
rename station_id board_id
drop size
drop station_name

cross using stations
rename station_id alight_id
drop station_name

* must leave at a subsequent station only
keep if alight_id > board_id

egen totsize = total(size), by(board_id daypart)
gen int trip_getoff = geton*size/totsize*(0.6+0.3*(daypart>=4))

egen t_getoff = total(trip_getoff), by(board_id daypart)
bysort board_id daypart (alight_id) : replace trip_getoff = trip_getoff + geton - t_getoff if _n == _N
drop t_getoff

* total alightings by daypart
egen getoff = total(trip_getoff), by(alight_id daypart)

* population
drop size totsize 

sort board_id daypart alight_id
list, sepby(board_id daypart)

sort alight_id daypart board_id 
list, sepby(alight_id daypart)

sum trip_getoff
di r(sum)

* control totals basic interaction
gen dpston_main = daypart*100 + board_id
total geton if alight_id == 69, over(dpston_main)
matrix dpston_main = e(b)
mat coleq dpston_main = _one
mat rowname dpston_main = dpston

gen dpstoff_main = daypart*100 + alight_id
total trip_getoff, over(dpstoff_main)
matrix dpstoff_main = e(b)
mat coleq dpstoff_main = _one
mat rowname dpstoff_main = dpstoff

mata : sum(st_matrix("dpston_main"))
mata : sum(st_matrix("dpstoff_main"))

save trip_population_raw, replace

file open towr using pop.size.tex, text write replace
sum trip_getoff
file write towr %5.0f (`=r(sum)')
file close towr

keep board_id alight_id daypart trip_getoff
keep if trip_getoff > 0
ren trip_getoff num_pass

save trip_population, replace

sjlog using ipfr.trip.pop, replace
use trip_population, clear
table board_id daypart , c(sum num_pass) cellwidth(10) mi
table alight_id daypart , c(sum num_pass) cellwidth(10) mi
sjlog close, replace

* sample
keep board_id alight_id daypart num_pass
expand num_pass
drop if num_pass == 0
drop num_pass

gen propensity = 0.06 ///
	- 0.015*(daypart==1) /// less likely to fill in rush hour
	- 0.1/sqrt(40+alight_id-board_id) /// trip duration -- easier to fill on longer trips

gen response = uniform() < propensity

tab board_id daypart if response
tab alight_id daypart if response

save response_propensity, replace

keep if response == 1
keep board_id alight_id daypart
gen int personid = _n

save trip_sample, replace

file open towr using sample.size.tex, text write replace
count
file write towr %4.0f (`=r(N)')
file close towr

sjlog using ipfr.trip.samp, replace
use trip_sample, clear
table board_id daypart , c(freq) cellwidth(10) mi
table alight_id daypart , c(freq) cellwidth(10) mi
sjlog close, replace

* this raking won't work
gen byte _one = 1
gen int dpston = daypart*100 + board_id
gen int dpstoff= daypart*100 + alight_id
cap noi ipfraking [pw=_one], ctotal(dpston_main dpstoff_main) gen(raked_weight)
cap noi ipfraking [pw=_one], ctotal(dpstoff_main dpston_main) gen(raked_weight)

* wgtcelladjust example: naive run just trying to get everything to the cell size of 20

* define collapsing rules
sjlog using ipfr.trip.rule, replace
use trip_sample, clear
wgtcellcollapse sequence , var(daypart) from(2 3 4) depth(3)
levelsof board_id, local(stations_on)
levelsof alight_id, local(stations_off)
local all_stations : list stations_on | stations_off
* relies on stations being in sequential order!!!
wgtcellcollapse sequence , var(board_id alight_id) from(`all_stations') depth(20)
save trip_sample_rules, replace
sjlog close, replace

file open towr using station.nrules.tex, text write replace
file write towr %6.0f (`: char board_id[nrules]')
file close towr

* collapse: attempt 1
sjlog using ipfr.trip.att1, replace
use trip_sample_rules, clear
wgtcellcollapse collapse, variables(daypart board_id) mincellsize(20) ///
	generate(dpston1) saving(dpston1.do) replace run
return list
wgtcellcollapse collapse, variables(daypart alight_id) mincellsize(20) ///
	generate(dpstoff1) saving(dpstoff1.do) replace run
return list
sjlog close, replace

* control totals
sjlog using ipfr.trip.pop1, replace
use trip_population, clear
run dpston1.do
total num_pass , over(dpston1)
matrix dpston1 = e(b)
matrix coleq dpston1 = _one
matrix rownames dpston1 = dpston1
run dpstoff1.do
total num_pass , over(dpstoff1)
matrix dpstoff1 = e(b)
matrix coleq dpstoff1 = _one
matrix rownames dpstoff1 = dpstoff1
sjlog close, replace

* raking
sjlog using ipfr.trip.rake1, replace
use trip_sample, clear
run dpston1
run dpstoff1
gen byte _one = 1	
ipfraking [pw=_one], ctotal(dpston1 dpstoff1) gen(raked_weight1)
ipfraking [pw=_one], ctotal(dpstoff1 dpston1) gen(raked_weight1)
sjlog close, replace

* collapse: attempt 2
sjlog using ipfr.trip.att2, replace
use trip_sample_rules, clear
wgtcellcollapse collapse, variables(daypart board_id) mincellsize(20) ///
	zeroes(39 40 44 49 55 60) ///
	generate(dpston2) saving(dpston2.do) replace run
return list
wgtcellcollapse collapse, variables(daypart alight_id) mincellsize(20) ///
	zeroes(2 8 36 39 40 44 47 49 50 55 60 62) ///
	generate(dpstoff2) saving(dpstoff2.do) replace run
return list
sjlog close, replace

* control totals
sjlog using ipfr.trip.pop2, replace
use trip_population, clear
run dpston2.do
total num_pass , over(dpston2)
matrix dpston2 = e(b)
matrix coleq dpston2 = _one
matrix rownames dpston2 = dpston2
run dpstoff2.do
total num_pass , over(dpstoff2)
matrix dpstoff2 = e(b)
matrix coleq dpstoff2 = _one
matrix rownames dpstoff2 = dpstoff2
sjlog close, replace

* raking
sjlog using ipfr.trip.rake2, replace
use trip_sample, clear
run dpston2
run dpstoff2
gen byte _one = 1	
ipfraking [pw=_one], ctotal(dpston2 dpstoff2) gen(raked_weight2)
whatsdeff raked_weight2
sjlog close, replace

* overlap
sjlog using ipfr.trip.overlap2, replace
tab alight_id dpstoff2 if daypart == 1 & mod(dpstoff2,100*100)>99
sjlog close, replace

* collapse: attempt 3
sjlog using ipfr.trip.att3, replace
use trip_sample_rules, clear
wgtcellcollapse collapse, variables(daypart board_id) mincellsize(1) ///
	zeroes(39 40 44 49 55 60) ///
	generate(dpston3) saving(dpston3.do) replace run
wgtcellcollapse collapse, variables(daypart board_id) mincellsize(20) ///
	strict feed(dpston3) saving(dpston3.do) append run
wgtcellcollapse collapse, variables(daypart alight_id) mincellsize(1) ///
	zeroes(2 8 36 39 40 44 47 49 50 55 60 62) ///
	generate(dpstoff3) saving(dpstoff3.do) replace run
wgtcellcollapse collapse, variables(daypart alight_id) mincellsize(20) ///
	strict feed(dpstoff3) saving(dpstoff3.do) append run
sjlog close, replace

forvalues d=1/5 {
	tab alight_id dpstoff3 if daypart == `d' & mod(dpstoff3,1e4)>99
}

sjlog using ipfr.trip.overlap3, replace
tab alight_id dpstoff3 if daypart == 2 & mod(dpstoff3,100*100)>99
sjlog close, replace

* collapse: attempt 4
sjlog using ipfr.trip.att4, replace
use trip_sample_rules, clear
wgtcellcollapse collapse, variables(daypart board_id) mincellsize(1) ///
	zeroes(39 44 49 60) greedy maxcategory(99) ///
	generate(dpston4) saving(dpston4.do) replace run
wgtcellcollapse collapse, variables(daypart board_id) mincellsize(20) ///
	strict feed(dpston4) saving(dpston4.do) append run
assert "`r(failed)'" == ""	
wgtcellcollapse collapse, variables(daypart alight_id) mincellsize(1) ///
	zeroes(2 40 49 50 60) greedy maxcategory(99) ///
	generate(dpstoff4) saving(dpstoff4.do) replace run
wgtcellcollapse collapse, variables(daypart alight_id) mincellsize(20) ///
	strict feed(dpstoff4) saving(dpstoff4.do) append run
assert "`r(failed)'" == ""	
sjlog close, replace

forvalues d=1/5 {
*	tab alight_id dpstoff4 if daypart == `d' & mod(dpstoff4,1e4)>100
*	tab board_id  dpston4  if daypart == `d' & mod(dpston4,1e4)>100
	tab alight_id dpstoff4 if daypart == `d'
	tab board_id  dpston4  if daypart == `d'
}

sjlog using ipfr.trip.improve4, replace
tab alight_id dpstoff4 if daypart == 5 & mod(dpstoff4,100*100)>99
sjlog close, replace

* collapse: attempt 5
sjlog using ipfr.trip.att5, replace
use trip_sample_rules, clear
wgtcellcollapse collapse, variables(daypart board_id) mincellsize(1) ///
	zeroes(39 44 49 60) greedy maxcategory(99) ///
	generate(dpston5) saving(dpston5.do) replace run
wgtcellcollapse collapse, variables(daypart board_id) mincellsize(20) ///
	strict feed(dpston5) saving(dpston5.do) append run
assert "`r(failed)'" == ""	
wgtcellcollapse collapse, variables(daypart alight_id) mincellsize(1) ///
	zeroes(2 40 60) greedy maxcategory(99) ///
	generate(dpstoff5) saving(dpstoff5.do) replace run
wgtcellcollapse collapse if inlist(daypart,4,5) & inrange(alight_id,49,50), ///
	variables(daypart alight_id) mincellsize(1) ///
	feed(dpstoff5) zeroes(49) maxcategory(99) saving(dpstoff5.do) append run
* special cells for weekend
wgtcellcollapse collapse if daypart==5 & inrange(alight_id,1,36), ///
	variables(daypart alight_id) mincellsize(50) ///
	strict feed(dpstoff5) saving(dpstoff5.do) append run
wgtcellcollapse collapse if daypart==5 & inrange(alight_id,44,68), ///
	variables(daypart alight_id) mincellsize(50) ///
	strict feed(dpstoff5) saving(dpstoff5.do) append run
* all other cells
wgtcellcollapse collapse, variables(daypart alight_id) mincellsize(20) ///
	strict feed(dpstoff5) saving(dpstoff5.do) append run
assert "`r(failed)'" == ""	
sjlog close, replace

sjlog using ipfr.trip.improve5, replace
tab alight_id dpstoff5 if daypart == 5
sjlog close, replace

* control totals and raking
sjlog using ipfr.trip.rake5, replace
use trip_population, clear
run dpston5.do
total num_pass , over(dpston5)
matrix dpston5 = e(b)
matrix coleq dpston5 = _one
matrix rownames dpston5 = dpston5
run dpstoff5.do
total num_pass , over(dpstoff5)
matrix dpstoff5 = e(b)
matrix coleq dpstoff5 = _one
matrix rownames dpstoff5 = dpstoff5
use trip_sample_rules, clear
run dpston5
run dpstoff5
gen byte _one = 1	
ipfraking [pw=_one], ctotal(dpston5 dpstoff5) gen(raked_weight5)
whatsdeff raked_weight5
sjlog close, replace

sjlog using ipfr.trip.label5, replace
wgtcellcollapse label, var(dpston5) 
wgtcellcollapse label, var(dpstoff5) 
label language numbered_ccells
tab dpstoff5 if daypart==5
label language texted_ccells
tab dpstoff5 if daypart==5
label language unlabeled_ccells
tab dpstoff5 if daypart==5
sjlog close, replace

*  compare the speed
cap drop raked_weight5*
sjlog using ipfr.trip.lin5, replace
set rmsg on
ipfraking [pw=_one], ctotal(dpston5 dpstoff5) nograph gen(raked_weight5)
ipfraking [pw=_one], ctotal(dpston5 dpstoff5) nograph gen(raked_weight5l) linear
set rmsg off
label variable raked_weight5l "Linear calibrated weights"
compare raked_weight5 raked_weight5l
sjlog close, replace

twoway (scatter raked_weight5 raked_weight5l, msize(small) m(oh) ) ///
	(function y=x, range(10 40)), ///
	aspect(1) xsc(r(10 40)) ysc(r(10 40)) legend(off) xtitle("Linear calibrated weight") ///
	ytitle("Raked weight")
graph export raked_linear.png, replace width(1200)
graph export raked_linear.eps, replace 

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
exit
