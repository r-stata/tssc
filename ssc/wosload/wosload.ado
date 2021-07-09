*! 2.0 VERSION OF WOSLOAD
program define wosload
	
	version 8.2
	
quietly {
local total_files = 0

forvalues h = 1(1)100 {

	
global fname = "``h''"

if "$fname" != "" { 

noi: di as text "Processing file " "${fname}.txt" 

copy ${fname}.txt ${fname}_01.txt, replace
filefilter ${fname}_01.txt ${fname}_02.txt, from(\LQ) to("") replace
filefilter ${fname}_02.txt ${fname}_03.txt, from(\RQ) to("") replace
filefilter ${fname}_03.txt ${fname}_0.txt, from(\Q) to("") replace


insheet using ${fname}_0.txt, clear
g long_addr = 0

local cnt = _N
local replace1 = 0
local replace2 = 1

quietly {
forvalues i = 1(1)`cnt' {
	if strlen(c1) >= 240 in `i' {
		replace long_addr = 1 in `i'
		local remove = c1 in `i'
		filefilter ${fname}_`replace1'.txt ${fname}_`replace2'.txt, from("`remove'") to(" ") replace
		erase ${fname}_`replace1'.txt
		local ++replace1
		local ++replace2
	}
}
}
count if long_addr
local toolongnum = r(N)
g mergeid = _n
sort mergeid
save main_file`h'.dta, replace

insheet using ${fname}_`toolongnum'.txt, clear
keep c1
rename c1 c1_1
g mergeid = _n
sort mergeid
save addresses_temp_merge`h'.dta, replace

local p = 0
local q = 1
copy ${fname}_`toolongnum'.txt ${fname}_temp2_0.txt, replace
erase ${fname}_`toolongnum'.txt 

*FIXING FILE WHERE SOME OBSERVATIONS ARE OVER 244x2 LENGTH
count if strlen(c1) >=240
local p = r(N)

while `p' > 0 {

		local ++q
		insheet using ${fname}_temp`q'_0.txt, clear
		local cnt = _N
		local replace1 = 0
		local replace2 = 1
		g long_addr`q' = 0
	
		quietly {
		forvalues i = 1(1)`cnt' {
			if strlen(c1) >= 240 in `i' {
				replace long_addr`q' = 1 in `i'
				local remove = c1 in `i'
				filefilter ${fname}_temp`q'_`replace1'.txt ${fname}_temp`q'_`replace2'.txt, from("`remove'") to(" ") replace
				erase ${fname}_temp`q'_`replace1'.txt
				local ++replace1
				local ++replace2
			}
		}
		}
		
		count if long_addr
		local toolongnum = r(N)
		g mergeid = _n
		keep mergeid long_addr`q'
		sort mergeid
		save long_addr_file`q'.dta, replace

		insheet using ${fname}_temp`q'_`toolongnum'.txt, clear
		keep c1
		rename c1 c1_`q'
		g mergeid = _n
		sort mergeid
		merge mergeid using long_addr_file`q'.dta
		capture: erase long_addr_file`q'.dta
		drop _merge
		replace c1_`q' = "" if long_addr`q' == 0
		sort mergeid
		save long_addr_merge`q'.dta, replace
		
		
		count if strlen(c1_`q')>=240 
		local p = r(N)
		local r = `q' + 1
		
		if `p' > 0 {
			copy ${fname}_temp`q'_`toolongnum'.txt ${fname}_temp`r'_0.txt  
			}
		erase ${fname}_temp`q'_`toolongnum'.txt
		}

global c1_num = `q'


use main_file`h'.dta, clear
merge mergeid using addresses_temp_merge`h'.dta
drop _merge
replace c1_1 = "" if long_addr==0
g file = "$fname"
forvalues x = 2(1)`q' {
	sort mergeid
	merge mergeid using long_addr_merge`x'.dta
	drop _merge
	erase long_addr_merge`x'.dta
	}
	
g c1_count = $c1_num + 1
	
save finished_file`h'.dta, replace




erase ${fname}_01.txt 
erase ${fname}_02.txt 
erase ${fname}_03.txt  
erase addresses_temp_merge`h'.dta 
erase main_file`h'.dta
local ++total_files
}
}

use finished_file1.dta, clear
forvalues j = 2(1)`total_files' {
append using finished_file`j'.dta
erase finished_file`j'.dta
}

egen c1_cnt = max(c1_count)
drop c1_count
rename c1_cnt c1_count
rename long_addr long_addr1
rename c1 c1_0

*THERE ARE SOME WHERE THE ADDRESS IS 243 LONG SO IT IMPORTED
*A SECOND PART, BUT THE SECOND PART IS JUST BLANK. THESE
*ARE CODED AS JUST HAVING A FIRST PART HERE
local cnt = c1_count - 1 in 1

*IDENTIFYING FALSE POSITIVES FOR LONG_ADDR
forvalues x = 1(1)`cnt' {
	local y = `x' - 1
	replace long_addr`x' = 0 if c1_`x' == ""
	replace long_addr`x' = 0 if (substr(c1_`y',243,1)=="]")
	}
	
	
capture: label var fn "File Name"
capture: label var vr "Version Number"
capture: label var pt "Publication Type"
capture: label var au "Authors"
capture: label var af "Author Full Name"
capture: label var ca "Group Authors"
capture: label var ti "Document Title"
capture: label var ed "Editors"
capture: label var so "Publication Name"
capture: label var se "Book Series Title"
capture: label var bs "Book Series Subtitle"
capture: label var la "Language"
capture: label var dt "Document Type"
capture: label var ct "Conference Title"
capture: label var cy "Conference Date"
capture: label var ho "Conference Host"
capture: label var cl "Conference Location"
capture: label var sp "Conference Sponsors"
capture: label var de "Author Keywords"
capture: label var id "Keyword Plus"
capture: label var ab "Abstract"
capture: label var c1_0 "Author Address"
capture: label var rp "Reprint Address"
capture: label var em "Email Address"
capture: label var fu "Funding Agency and Grant Number"
capture: label var fx "Funding Text"
capture: label var cr "Cited References"
capture: label var nr "Cited Reference Count"
capture: label var tc "Times Cited"
capture: label var pu "Publisher"
capture: label var pi "Publisher Address"
capture: label var sc "Subject Category"
capture: label var sn "ISSBN"
capture: label var bn "ISBN"
capture: label var j9 "29-Character Source Abbreviation"
capture: label var ji "ISO Source Abbreviation"
capture: label var pd "Publication Date"
capture: label var py "Year Published"
capture: label var vl "Volume"
capture: label var is "Issue"
capture: label var pn "Part Number"
capture: label var su "Supplement"
capture: label var si "Special Issue"
capture: label var bp "Beginning Page"
capture: label var ep "Ending Page"
capture: label var ar "Article Number"
capture: label var pg "Page Count"
capture: label var di "Digital Object Identifier (DOI)"
capture: label var sc "Subject Category"
capture: label var ga "Document Delivery Number"
capture: label var ut "Unique Article Identifier"
capture: label var er "End of Record"
capture: label var ef "End of File"
capture: label var long_addr "Address In Two Variables"
capture: label var c1_count "Number of Extra Address Variables"
drop v5* mergeid 
}

foreach var of varlist * {

capture: count if strlen(`var')>=243
if `r(N)' > 0 & _rc==0 & substr("`var'",1,3)!="c1_" {
	quietly: g `var'_long = (strlen(`var')>=243)
	di "`var' contains " `r(N)' " potentially truncated observations"
	}
capture: drop c1_?_long
}	

erase finished_file1.dta

quietly: count if c1_1 !=""
if r(N)==0 {
drop c1_count c1_1
}

end

*END OF FILE
