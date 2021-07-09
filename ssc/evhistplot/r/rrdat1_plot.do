* Henrik Stovring, June 5, 2008
* Henrik Stovring, July 2, 2008: Update showing it works with just one event variable.
* Thanks go to Hans-Peter Blossfeld for making the data available

clear
webuse set "http://oldsite.soziologie-blossfeld.de/eha/stata/do_files/Data/"
webuse rrdat1.dta

* Convert event times to dates. Are arbitrarily set to fifteenth day of month.
foreach var of varlist tstart tb te tmar ti tfin {
  gen `var'date = mdy(mod(`var' - 1, 12) + 1, 15, (`var' - 1) / 12 + 1900)
  local labvar : variable label `var'
  la var `var'date "`labvar'"
  format %d `var'date
}

* replace with missing where observation is actually right censored
replace tmardate = . if tmar == 0
la var tmardate "Date of marriage"
replace tfindate = . if tfin == ti

* Example 1: Observation window
evhistplot *date, id(id) start(1jan1900) end(31dec1981)
more

* Example 2: Lexis plot
evhistplot tstartdate tedate - tfindate, id(id) start(1jan1900) end(31dec1981) birth(tbdate) nsub(50)
more

* Labels for job number
levelsof noj, local(nojvals)
foreach i of local nojvals {
  lab de nojlab `i' "Job # `i'", add
}
la val noj nojlab

* Example 3: Lexis plot with date of job starts labelled according to rank

evhistplot tstartdate, id(id) start(1jan1940) end(31dec1981) birth(tbdate) evtype(noj) nsub(20)
more

* Example 4: Lexis plot with date of marriage and job starts labelled
* according to rank

evhistplot tstartdate tmardate, id(id) start(1jan1940) end(31dec1981) birth(tbdate) evtype(noj) nsub(20) xtitle(Calendar time)

