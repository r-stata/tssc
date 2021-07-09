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

tabout stime died using table1.tex, ///
cells(freq col cum) format(0 1) clab(No. Col_% Cum_%) ///
replace ///
style(tex) bt  cl1(2-10) cl2(2-4 5-7 8-10) font(bold) ///
topf(top.tex) botf(bot.tex) topstr(14cm) botstr(cancer.dta) 

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

tabout south race collgrad [iw=wt] using  table2.tex, ///
cells(freq row col) format(0c 1p 1p) clab(_ _ _) /// 
layout(rb) h3(nil) ///
replace ///
style(tex) bt font(bold) cl1(2-4) ///
topf(top.tex) botf(bot.tex) topstr(11cm) botstr(nlsw88.dta)

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

tabout south race collgrad [iw=wt] using  table3.tex, ///
cells(freq row col) format(0c 1p 1p) layout(cb) h1(nil) h3(nil) npos(row) ///
replace ///
style(tex) bt font(bold) rotate(60) ///
topf(top.tex) botf(bot.tex) topstr(15cm) botstr(nlsw88.dta)

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

tabout south race collgrad [iw=wt] using  table4.tex, ///
cells(freq row col) format(0c 1p 1p) layout(cb) h1(nil) h3(nil) npos(row) ///
noff(3) ///
replace ///
style(tex) bt font(bold) rotate(60) ///
topf(top.tex) botf(bot.tex) topstr(15cm) botstr(nlsw88.dta)

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

tabout married south collgrad race using table5.tex, ///
cells(col) format(1) clab(Col_%) stats(gamma) npos(row) ///
replace ///
style(tex) bt font(bold) cl1(2-5) ///
topf(top.tex) botf(bot.tex) topstr(11cm) botstr(nlsw88.dta)


*table6

sysuse nlsw88, clear 

la var south "Geographical location"
la def south 0 "Does not live in the South" ///
			1 "Lives in the South"
la val south south

la var industry "Industry"
la var occupation "Occupation"
tabout occupation industry south using table6.tex, /// 
cells(col cell) format(1) clab(Col_% Cell_%) npos(row) nlab(Sample size) ///
replace ///style(tex) bt font(bold) cl1(2-7) cl2(2-3 4-5 6-7) ///
topf(top.tex) botf(bot.tex) topstr(14cm) botstr(nlsw88.dta)


*table7

sysuse nlsw88, clear 

la var south "Location"
la def south 0 "Does not live in the South" ///
			1 "Lives in the South"
la val south south

la var industry "Industry"
la var occupation "Occupation"
tabout occupation industry south using table7.tex, /// 
cells(col cell) format(1) clab(Col_% Cell_%) npos(row) nlab(Sample size) ///
layout(cb) dpcomma ///
replace ///style(tex) bt font(bold) cl1(2-7) cl2(2-4 5-7) ///
h3(& \multicolumn{3}{c}{Column percentages} & ///
\multicolumn{3}{c}{Cell percentages} \\) ///
topf(top.tex) botf(bot.tex) topstr(14cm) botstr(nlsw88.dta)

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

tabout collgrad race married south using table8.tex, ///
cells(row ci) format(1 1) clab(Row_% 95%_CI) svy stats(chi2) /// 
npos(lab) per ///
replace ///
style(tex) bt font(bold) cl1(2-6) ///
topf(top.tex) botf(bot.tex) topstr(14cm) botstr(nlsw88.dta)

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

tabout collgrad race married south using table9.tex, ///
cells(row ci) format(1 1) clab(Row_% 95%_CI) svy stats(chi2) /// 
npos(lab) per dpcomma cisep(-) ///
replace ///
style(tex) bt font(bold) cl1(2-6) ///
topf(top.tex) botf(bot.tex) topstr(14cm) botstr(nlsw88.dta)

*table10

sysuse voter, clear

tabout inc candidat using table10.tex,  ///
cells(mean pfrac) format(1) clab(%) sum ///
replace ///
style(tex) bt font(bold) cl1(2-5) ///
topf(top.tex) botf(bot.tex) topstr(10cm) botstr(voter.dta)


*table11

sysuse auto, clear

tabout rep78 foreign using table11.tex, ///
cells(mean weight) format(0c) sum h3(nil) npos(both) ///
replace ///
style(tex) bt font(bold) cl1(2-4) cltr1(.5em) ///
h1(& \multicolumn{3}{c}{\textbf{Inter-quartile range of  weight}} \\) ///
topf(top.tex) botf(bot.tex) topstr(10cm)  botstr(auto.dta)


*table12

sysuse auto, clear 

tabout foreign rep78 using table12.tex, /// 
cells(mean mpg mean weight mean length median price median headroom) /// 
f(1c 1c 1c 2cm 1c) /// 
clab(MPG Weight_(lbs) Length_(in) Price Headroom_(in)) /// 
sum npos(tufte) ///
replace ///
style(tex) bt cl2(2-4 5-6) cltr2(.75em 1.5em) /// 
topf(top.tex) botf(bot.tex) topstr(10cm) botstr(auto.dta)


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

tabout occupation south race collgrad using table13.tex, /// 
cells(mean wage se) format(2 2) clab(Mean_wage SE) ///
sum svy npos(lab) ///
replace ///
style(tex) bt cl1(2-7) font(bold) /// 
topf(top.tex) botf(bot.tex) topstr(14cm) botstr(nlsw88)


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

tabout collgrad race south using table14.tex, /// 
cells(mean wage lb ub) format(2m) svy sum ///
replace ///
style(tex) bt font(italic) cl1(2-10) cl2(2-4 5-7 8-10) ///
h1(& \multicolumn{9}{c}{\emph{Average wages according to location}} \\) /// 
topf(top.tex) botf(bot.tex) topstr(14cm) botstr(nlsw88.dta)

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

tabout collgrad race south using table15.tex, ///
cells(mean wage se ci) format(2 2) sum svy npos(lab) layout(row) ///
level(90) clab(_ (SE) (90%_CI)) ///
replace ///
style(tex) bt  cl1(2-4) cl2(2-4) font(bold) ///
h3(& \multicolumn{3}{c}{Average wage} \\) /// 
topf(top.tex) botf(bot.tex) topstr(12cm) botstr(nlsw88.dta) 


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

tabout collgrad south race coll using table16.tex, ///
cells(mean wage lb ub) format(2 2) sum svy /// 
npos(lab) nlab((Sample size = #)) ///
layout(row) level(90) clab(_  Lower_bound Upper_bound) /// 
replace ///
style(tex) bt  cl1(2-4) cl2(2-4) font(bold) ///
h3(& \multicolumn{3}{c}{Average wage} \\) ///
topf(top.tex) botf(bot.tex) topstr(13cm) botstr(nlsw88.dta) 

