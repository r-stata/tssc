* Program to reproduce example from Greene, Econometric Analysis, 5th ed., 2002, p. 554, based on Dalberg and Johansson 2000)
* To make this work , download and unzip
*   http://qed.econ.queensu.ca/jae/2000-v15.4/dahlberg-johansson/dj-data.zip
* and edit the "infile" command below to open the extracted file.

clear all
set mem 32m
set matsize 800

infile id  year expend revenue grants using h:\macros\T7987.asc, clear
tsset id year
* This run won't match for the year dummies.
xi: xtabond2 expend l(1/3).(expend revenue grants) i.year, gmm(l.expend) iv(i.year) noleveleq twostep h(1)
* For a perfect match, make variables whose first differences are year dummies.
forvalues y=1980/1987 {
	gen yr`y'c = year>=`y'
}
xtabond2 expend l(1/3).(expend revenue grants) yr*c, gmm(l.expend) iv(yr*c) noleveleq twostep h(1)
