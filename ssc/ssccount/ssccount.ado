*! v 1.0 Tim Morris 30 Oct 2015
* Downloads count of SSC hits and optionally graph for specified author and package
program define ssccount
version 13

syntax , [ FRom(string) to(string) AUthor(string) clear Fillin(string) GRaph PACKage(string) SAVing(string) ]

tempvar command

* If saving option was specified, check if the file exists and, if it does, that replace was specified.
if `"`saving'"' != "" {
	_prefix_saving `saving'
	local saving `"`s(filename)'"'
	local replace `"`s(replace)'"'
  if `"`replace'"' == "" {
    confirm new file `"`s(filename)'"'
  }
}

* Turn dates into numbers
if "`from'" == "" {
	local fromno 570
}
else if "`from'" != "" {
  tokenize "`from'", parse("m")
  local fromno = ym(`1',`3')
}
if "`to'" == "" {
	local tono = mofd(td("`c(current_date)'")) - 2
}
else if "`to'" != "" {
  tokenize "`to'", parse("m")
  local tono = ym(`1',`3')
}
local numdsets = 1 + `tono' - `fromno'

 * check that dates are reasonable
if `fromno' < 570 {
  display as error "You specified from(`from'), which is before records began." _newline "Option from() must be later than 2007m7."
  exit
}
if `tono' < 570 {
  display as error "You specified to(`to'), which is before records began." _newline "Option to() must be later than 2007m7."
  exit
}
if `fromno' > `tono' {
  display as error "Date given in from(first_month) is after that given in to(last_month)"
  exit
}

* Report on what will be downloaded
display as text "Looking to download `numdsets' months of SSC files (" %tmm_CY `fromno' " to " %tmm_CY `tono' ")"

if "`clear'" == "" {
  use "http://repec.org/docs/sschotP`fromno'.dta"
  if c(rc) != 0 {
    display as error "No; data in memory would be lost. Please clear data or specify the clear option."
    exit 4
  }
}
else {
  display as text "." _cont
  capture use "http://repec.org/docs/sschotP`fromno'.dta" , `clear'
}
if c(rc) != 0 {
  display ""
  display as error "Dataset for month specified in from(), `from', is not yet available online. Nothing downloaded."
  exit
}
else {
  local two = `fromno'+1
  forval i = `two' / `tono' {
    noisily display as text "." _cont
    capture quietly append using "http://repec.org/docs/sschotP`i'.dta"
    if c(rc) != 0 {
      display ""
      display as error "Warning: dataset " %tmm_CY `i' " was not found."
    }
  }
display ""
}

* Work around sschotP590.dta problem, which has 'npkghit589' instead of npkghit and mo=589
capture confirm numeric variable npkghit589
if c(rc) == 0 {
  quietly {
    replace mo = 590 if mo == .
    replace npkghit = npkghit589 if npkghit589 != .
    drop npkghit589
  }
}

* Keep data for authors and packages specified
if `"`package'"' != "" {
  quietly keep if package == upper("`package'")
}
if `"`author'"' != "" {
  quietly keep if regexm(lower(author),lower("`author'"))
  *quietly keep if lower(author) == lower("`author'")
}
quietly count
if `r(N)' == 0 {
  if "`author'" == "" display as text "Found no results for package `package' from `from' to `to'"
  else if "`package'" == "" display as text "Found no results for author `author' from `from' to `to'"
  else display as text "Found no results for author `author' and package `package' from `from' to `to'"
}

quietly encode package, generate(`command')
lab var author "Author"
lab var npkghit "Number of hits"
  format npkghit %9.0f
lab var mo "Date"
  format mo %tmMon_CCYY
lab var `command' "Package"
lab var package "Package"

if `"`fillin'"' != "" {
	quietly fillin package mo
	quietly replace npkghit=`fillin' if missing(npkghit)
	drop _fillin
}

quietly compress

sort author `command' mo

if "`graph'" != "" & "`author'" == "" & "`package'" == "" {
  display as error "No authors or packages have been selected, but the graph option has." _newline "The thousands of small graphs will not be drawn."
}
else if `"`graph'"' != "" {
  quietly tab `command' author
  if `r(r)'==1 & `r(c)'==1 { 
    twoway (line npkghit mo) (lowess npkghit mo) , ytit("Number of hits") ylab(,format(%9.0f)) xlab(,angle(45)) ylab(,angle(0))
  }
  else if `r(r)'==1 & `r(c)'>1 {
    noisily twoway (line npkghit mo) (lowess npkghit mo) , by(author,note("")) ytit("Number of hits") ylab(,format(%9.0f)) xlab(,angle(45)) ylab(,angle(0))
  }
  else if `r(r)'>1 & `r(c)'==1 {
    noisily twoway (line npkghit mo) (lowess npkghit mo) , by(`command',note("")) ytit("Number of hits") ylab(,format(%9.0f)) xlab(,angle(45)) ylab(,angle(0))
  }
  else if `r(r)'>1 & `r(c)'>1 {
    noisily twoway (line npkghit mo) (lowess npkghit mo) , by(author `command',note("")) ytit("Number of hits") ylab(,format(%9.0f)) xlab(,angle(45)) ylab(,angle(0))
  }
}

if `"`saving'"' != "" {
  capture drop __*
	sort author package mo
	save `"`saving'"', `replace'
}

end

exit

History of ssccount.ado
30oct2015  v 1.0  T Morris  Various bugs fixed and incorporated helpful suggestions from Roger Newson.
09jun2015  v 0.7  T Morris  Added smoothed line (lowess) to the graph drawn if graph option is specified.
12feb2015  v 0.6  T Morris  Fixed issue with inappropriate warning message.
22jan2015  v 0.5  T Morris  Changed name from getsschits to ssccount. Bug fixes and improvements. Updated help file.
18dec2014  v 0.4  T Morris  Minor updates and fixes. Option -clear- added.
07nov2014  v 0.3  T Morris  Created a command with error checking, automatic graph etc.
