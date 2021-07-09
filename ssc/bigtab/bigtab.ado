capture program drop bigtab
program define bigtab
	version 8
	syntax varlist(max=3) [if] [in] [fweight] [, Row Col Zero NOMISS NOCUM SAVing(string asis) SEPby(string asis) ALLlab NOLabel]
     
     if "`sepby'"=="" {
        local sep "sep(0)"
     }
     else{
        local sep "sepby(`sepby')"
     }
     
     if "`alllab'" != ""{
*set trace on
	   local i = 1
	   local x = 0
        foreach v of local varlist{
          local labl`i' : value label `v'
          local vl "`labl`i''"
          if "`labl`i''" != ""{
 	        tempfile `vl'
             local x = `x' + 1
             preserve
     	   uselabel `vl', clear
             rename value `v'
             sort `v'
     	   quietly save `"``vl''"'
     	   clear
     	   restore
     	}
     	local i = `i' + 1
        }
     }     
     preserve       
 
	contract `varlist' `if' `in' [`weight' `exp'] , `zero' `nomiss'
      local i=1
      if "`alllab'" != ""{
        local j=1
        foreach v of local varlist{
          local labl`i' : value label `v'
          if "`labl`i''" != ""{
             sort `v'
     	   quietly merge `v' using ``labl`j'''
     	   drop _merge
     	}
     	   local j = `j' + 1
        }
        }
        foreach v of local varlist{
        tempvar v`i'
        local an : format `v'
        if index("`an'","s")!=0{
	      *local la = reverse(substr(reverse(substr("`an'",2,.)),2,.))
  	      *quietly gen str`la' `v`i'' = `v'
  	      quietly gen  `v`i'' = `v'
 	  }
 	  else {
      	quietly gen  `v`i'' = `v'
	  }
 	      local i = `i' + 1
      }
	rename _freq freq
	sort `varlist'
	quietly replace freq=0 if freq==.
	quietly gen cumfreq=sum(freq)
	local fmt: format freq
	format cumfreq `fmt'
	quietly gen pct = (freq/cumfreq[_N])*100
	quietly gen cumpct=sum(pct)
	format pct cumpct %6.2f
	lab var freq "Frequency"
	lab var pct "Cell Percent"
		
	local i=`i'-1	
	if `i'==1 {
			if "`nocum'"==""{
			     lab var cumfreq "Cumulative Frequency"
		          lab var cumpct  "Cumulative Percent"
				l `varlist' freq pct cumfreq cumpct, noobs nodis `sep' `nolabel' 

			}
			else {
				l `varlist' freq pct, noobs nodis  `sep' `nolabel'
			}
		drop `v1'
	}
	if `i'==2 {
		if "`row'"!="" & "`col'"==""{
			quietly egen rowtot=sum(freq), by(`v1')
			quietly gen  rowpct=(freq/rowtot)*100
			format rowpct %6.2f
			lab var rowtot "Row Total"
			lab var rowpct "Row Percent"
			if "`nocum'"==""{
			     lab var cumfreq "Cumulative Frequency"
		          lab var cumpct  "Cumulative Percent"
				l `varlist' freq pct cumfreq cumpct rowpct, noobs nodis `sep' `nolabel'

			}
			else {
				l `varlist' freq pct rowpct, noobs nodis  `sep' `nolabel'
			}
		}
		if "`col'"!="" & "`row'"==""{
			quietly egen coltot=sum(freq), by(`v2')
			quietly gen colpct=(freq/coltot)*100
			format colpct %6.2f
			lab var coltot "Column Total"
			lab var colpct "Column Percent"
			if "`nocum'"==""{
			     lab var cumfreq "Cumulative Frequency"
		          lab var cumpct  "Cumulative Percent"
				l `varlist' freq pct cumfreq cumpct colpct,noobs nodis `sep' `nolabel'
			}
			else {
				l `varlist' freq pct colpct, noobs nodis `sep' `nolabel'
			}
		}
		if "`col'"!="" & "`row'"!=""{
			quietly egen rowtot=sum(freq), by(`v1')
			quietly gen  rowpct=(freq/rowtot)*100		
			quietly egen coltot=sum(freq), by(`v2')
			quietly gen colpct=(freq/coltot)*100
			lab var coltot "Column Total"
			lab var colpct "Column Percent"
			lab var rowtot "Row Total"
			lab var rowpct "Row Percent"
			format rowpct colpct %6.2f
			if "`nocum'"==""{
			     lab var cumfreq "Cumulative Frequency"
		          lab var cumpct  "Cumulative Percent"
				l `varlist' freq pct cumfreq cumpct rowpct colpct,noobs nodis `sep' `nolabel'
			}
			else {
				l `varlist' freq pct rowpct colpct, noobs nodis `sep' `nolabel'
			}
		}
		if "`col'"=="" & "`row'"=="" {
 
			format pct cumpct  %6.2f
			if "`nocum'"==""{
			     lab var cumfreq "Cumulative Frequency"
		          lab var cumpct  "Cumulative Percent"
				l `varlist' freq pct cumfreq cumpct ,noobs nodis  `sep' `nolabel'
			}
			else {
				l `varlist' freq pct, noobs nodis  `sep' `nolabel'
			}
		}
		drop `v1' `v2'
	}
	if `i'==3 {
		if "`row'"!="" & "`col'"==""{
			quietly egen rowtot=sum(freq), by(`v1' `v2')
			quietly gen  rowpct=(freq/rowtot)*100
			format rowpct %6.2f
			lab var rowtot "Row Total"
			lab var rowpct "Row Percent"
			if "`nocum'"==""{
			     lab var cumfreq "Cumulative Frequency"
		          lab var cumpct  "Cumulative Percent"
				l `varlist' freq pct cumfreq cumpct rowpct, noobs nodis `sep' `nolabel'
			}
			else {
				l `varlist' freq pct rowpct, noobs nodis `sep' `nolabel'
			}
		}
		
		if "`col'"!="" & "`row'"==""{
			quietly egen coltot=sum(freq), by(`v1' `v3')
			quietly gen colpct=(freq/coltot)*100
			format colpct %6.2f
			lab var coltot "Column Total"
			lab var colpct "Column Percent"
			if "`nocum'"==""{
			     lab var cumfreq "Cumulative Frequency"
		          lab var cumpct  "Cumulative Percent"
				l `varlist' freq pct cumfreq cumpct colpct,noobs nodis `sep' `nolabel'
			}
			else {
				l `varlist' freq pct colpct, noobs nodis `sep' `nolabel'
			}
		}
		
		if "`col'"!="" & "`row'"!=""{
			quietly egen rowtot=sum(freq), by(`v1' `v2')
			quietly gen  rowpct=(freq/rowtot)*100
			quietly egen coltot=sum(freq), by(`v1' `v3')
			quietly gen colpct=(freq/coltot)*100
			format rowpct colpct %6.2f
			lab var rowtot "Row Total"
			lab var rowpct "Row Percent"
			lab var coltot "Column Total"
			lab var colpct "Column Percent"
			if "`nocum'"==""{
			     lab var cumfreq "Cumulative Frequency"
		          lab var cumpct  "Cumulative Percent"
				l `varlist' freq pct cumfreq cumpct rowpct colpct,noobs nodis `sep' `nolabel'
			}
			else {
				l `varlist' freq pct rowpct colpct, noobs nodis `sep' `nolabel'
			}
		}
		
		if "`col'"=="" & "`row'"=="" {
			format pct cumpct  %6.2f
			if "`nocum'"==""{
			     lab var cumfreq "Cumulative Frequency"
		          lab var cumpct  "Cumulative Percent"
				l `varlist' freq pct cumfreq cumpct ,noobs nodis `sep' `nolabel'
			}
			else {
				l `varlist' freq pct, noobs nodis `sep' `nolabel'
			}
		}
		
		drop `v1' `v2' `v3'
	}
	
	if "`saving'"!="" {
	     capture drop label lname
		di
	     save "`saving'"
	}
	
di
clear
restore
end

