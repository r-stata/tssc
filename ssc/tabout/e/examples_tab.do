*table1

sysuse cancer, clear

la var died "Patient died"
la def ny  0 "No" 1 "Yes", modify
la val died ny

recode studytime (min/10 = 1 "10 or less months") ///
			(11/20 = 2 "11 to 20 months") ///
			(21/30 = 3 "21 to 30 months") ///
			(31/max = 4 "31 or more months") ///
			, gen(stime)
la var stime "To died or exp. end"

tabout stime died using table1.txt, ///
cells(freq col cum) format(0 1) clab(No. Col_% Cum_%) ///
replace

*table2

sysuse nlsw88, clear

la var south "Location"
la def south 0 "Does not live in the South" ///
			1 "Lives in the South"
la val south south

la var race "Race"
la def race 1 "White" 2 "Black" 3 "Other"
la val race race

la var collgrad "Education"
la def collgrad 0 "Not college graduate" 1 "College graduate"
la val collgrad collgrad

gen wt = 10 * runiform()

tabout south race collgrad [iw=wt] using  table2.txt, ///
cells(freq row col) format(0c 1p 1p) clab(_ _ _) /// 
layout(rb) h3(nil) ///
replace

*table3

sysuse nlsw88, clear

la var south "Location"
la def south 0 "Does not live in the South" ///
			1 "Lives in the South"
la val south south

la var race "Race"
la def race 1 "White" 2 "Black" 3 "Other"
la val race race

la var collgrad "Education"
la def collgrad 0 "Not college graduate" 1 "College graduate"
la val collgrad collgrad

gen wt = 10 * runiform()

tabout south race collgrad [iw=wt] using  table3.txt, ///
cells(freq row col) format(0c 1p 1p) layout(cb) h1(nil) h3(nil) npos(row) ///
replace

*table4

sysuse nlsw88, clear

la var south "Location"
la def south 0 "Does not live in the South" ///
			1 "Lives in the South"
la val south south

la var race "Race"
la def race 1 "White" 2 "Black" 3 "Other"
la val race race

la var collgrad "Education"
la def collgrad 0 "Not college graduate" 1 "College graduate"
la val collgrad collgrad

gen wt = 10 * runiform()

tabout south race collgrad [iw=wt] using  table4.txt, ///
cells(freq row col) format(0c 1p 1p) layout(cb) h1(nil) h3(nil) npos(row) ///
noff(3) ///
replace

*table5

sysuse nlsw88, clear

la var south "Location"
la def south 0 "Does not live in the South" ///
			1 "Lives in the South"
la val south south

la var race "Race"
la def race 1 "White" 2 "Black" 3 "Other"
la val race race

la var married "Marital status"
la def married 0 "Single" 1 "Married"
la val married married

la var collgrad "Education"
la def collgrad 0 "Not college graduate" 1 "College graduate"
la val collgrad collgrad

gen wt = 10 * runiform()

tabout married south collgrad race using table5.txt, ///
cells(col) format(1) clab(Col_%) stats(gamma) npos(row) ///
replace


*table6

sysuse nlsw88, clear 

la var south "Geographical location"
la def south 0 "Does not live in the South" ///
			1 "Lives in the South"
la val south south

la var industry "Industry"
la var occupation "Occupation"
tabout occupation industry south using table6.txt, /// 
cells(col cell) format(1) clab(Col_% Cell_%) npos(row) nlab(Sample size) ///
replace

*table7

sysuse nlsw88, clear 

la var south "Location"
la def south 0 "Does not live in the South" ///
			1 "Lives in the South"
la val south south

la var industry "Industry"
la var occupation "Occupation"
tabout occupation industry south using table7.txt, /// 
cells(col cell) format(1) clab(Col_% Cell_%) npos(row) nlab(Sample size) ///
layout(cb) dpcomma ///
replace


*table8

sysuse nlsw88, clear

la var south "Location"
la def south 0 "Does not live in the South" ///
			1 "Lives in the South"
la val south south

la var race "Race"
la def race 1 "White" 2 "Black" 3 "Other"
la val race race

la var married "Marital status"
la def married 0 "Single" 1 "Married"
la val married married

la var collgrad "Education"
la def collgrad 0 "Not college graduate" 1 "College graduate"
la val collgrad collgrad

gen wt = 10 * runiform()

svyset [pw=wt]

tabout collgrad race married south using table8.txt, ///
cells(row ci) format(1 1) clab(Row_% 95%_CI) svy stats(chi2) /// 
npos(lab) per ///
replace


*table9

sysuse nlsw88, clear

la var south "Location"
la def south 0 "Does not live in the South" ///
			1 "Lives in the South"
la val south south

la var race "Race"
la def race 1 "White" 2 "Black" 3 "Other"
la val race race

la var married "Marital status"
la def married 0 "Single" 1 "Married"
la val married married

la var collgrad "Education"
la def collgrad 0 "Not college graduate" 1 "College graduate"
la val collgrad collgrad

gen wt = 10 * runiform()

svyset [pw=wt]

tabout collgrad race married south using table9.txt, ///
cells(row ci) format(1 1) clab(Row_% 95%_CI) svy stats(chi2) /// 
npos(lab) per dpcomma cisep(-) ///
replace


*table10

sysuse voter, clear

tabout inc candidat using table10.txt,  ///
cells(mean pfrac) format(1) clab(%) sum ///
replace


*table11

sysuse auto, clear

tabout rep78 foreign using table11.txt, ///
cells(mean weight) format(0c) sum h3(nil) npos(both) ///
replace


*table12

sysuse auto, clear 

tabout foreign rep78 using table12.txt, /// 
cells(mean mpg mean weight mean length median price median headroom) /// 
f(1c 1c 1c 2cm 1c) /// 
clab(MPG Weight_(lbs) Length_(in) Price Headroom_(in)) /// 
sum npos(tufte) ///
replace


*table13

sysuse nlsw88, clear

la var south "Location"
la def south 0 "Does not live in the South" ///
			1 "Lives in the South"
la val south south

la var race "Race"
la def race 1 "White" 2 "Black" 3 "Other"
la val race race

la var collgrad "Education"
la def collgrad 0 "Not college graduate" 1 "College graduate"
la val collgrad collgrad

la var occupation "Occupation"

gen wt = 10 * runiform()

svyset [pw=wt]

tabout occupation south race collgrad using table13.txt, /// 
cells(mean wage se) format(2 2) clab(Mean_wage SE) ///
sum svy npos(lab) ///
replace


*table14

sysuse nlsw88, clear

la var south "Location"
la def south 0 "Does not live in the South" ///
			1 "Lives in the South"
la val south south

la var race "Race"
la def race 1 "White" 2 "Black" 3 "Other"
la val race race

la var collgrad "Education"
la def collgrad 0 "Not college graduate" 1 "College graduate"
la val collgrad collgrad

gen wt = 10 * runiform()

svyset [pw=wt]

tabout collgrad race south using table14.txt, /// 
cells(mean wage lb ub) format(2m) svy sum ///
replace


*table15

sysuse nlsw88, clear

la var south "Location"
la def south 0 "Does not live in the South" ///
			1 "Lives in the South"
la val south south

la var race "Race"
la def race 1 "White" 2 "Black" 3 "Other"
la val race race

la var collgrad "Education"
la def collgrad 0 "Not college graduate" 1 "College graduate"
la val collgrad collgrad

gen wt = 10 * runiform()

svyset [pw=wt]

tabout collgrad race south using table15.txt, ///
cells(mean wage se ci) format(2 2) sum svy npos(lab) layout(row) ///
level(90) clab(_ (SE) (90%_CI)) ///
h3( | Average wage | Average wage | Average wage) ///
replace


*table16

sysuse nlsw88, clear

la var south "Location"
la def south 0 "Does not live in the South" ///
			1 "Lives in the South"
la val south south

la var race "Race"
la def race 1 "White" 2 "Black" 3 "Other"
la val race race

la var collgrad "Education"
la def collgrad 0 "Not college graduate" 1 "College graduate"
la val collgrad collgrad

gen wt = 10 * runiform()

svyset [pw=wt]

tabout collgrad south race coll using table16.txt, ///
cells(mean wage lb ub) format(2 2) sum svy /// 
npos(lab) nlab((Sample size = #)) ///
layout(row) level(90) clab(_  Lower_bound Upper_bound) /// 
h3( | | Average wage | ) ///
replace

