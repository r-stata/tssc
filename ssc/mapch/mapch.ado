*! version 1.0.1 Ward Vanlaar 29febr2008

program mapch
	version 10
	syntax varlist(max=3) [if] [in]
	
	if "`3'"!="" & "`3'"!="if" & "`3'"!="in" {
			mapch_3 `0'
	}
	else {
			mapch_2 `0'
	}
end

*/TO MAP CHAINS IN CASE REAL TIME IS AVAILABLE
program mapch_3
	version 10
	syntax varlist(max=3) [if] [in]
	marksample touse, strok
	
		*/TO CHECK IF VARIABLES END AND BEGIN ARE UNIQUE
		preserve
		quietly keep if `touse'==1
		tempfile original
		quietly save "`original'", replace
		foreach x in `1' `2' {
			sort `x'
			tempvar test
			by `x': generate `test' = _N
			quietly count if `test'!=1
			local count = r(N)
			capture assert `count'==0
			if _rc!=0 {
				display as error "`x' not unique: at least one value of `x' appears more than once"
				exit 9
			}
		}
	
		*/TO CHECK IF EACH STEP IN CHAINS OCCURRED AT DIFFERENT TIME
		quietly {
			tempvar group newpicd test
			generate `group'=1
			generate `newpicd'=`1'
			tempfile master using
			save "`master'"
			replace `group'=2
			replace `newpicd'=`2'
			save "`using'"
			use "`master'", clear
			append using "`using'"
			sort `newpicd' `3'
			by `newpicd' `3': generate `test' = _N
			count if `test'!=1
			local count = r(N)
			capture assert `count'==0
			if _rc!=0 {
				display as error "mapping chains revealed that 2 steps in at least one chain occurred at the same time"
				exit 9
			}
		}
	
		restore
	
		*/TO MAP CHAINS
		preserve
		quietly keep if `touse'==1 
		quietly {
			tempvar link1 test1 test2
			generate `link1' = `2'
			tempfile master1 using1 using2
			save "`using1'"
			replace `link1' = `1'
			save "`master1'"
			append using "`using1'"
			sort `link1' `3'
			by `link1': generate `test1'=_N
			drop if `test1'!=2
			by `link1': assert `2'[_n]==`1'[_n+1] if _n<_N
			by `link1': generate str recent=`2'[_N]
			sort `1' `3'
			by `1': generate `test2'=_N
			by `1': drop if `2'!=recent & `test2'>1
			save "`using2'"
			use "`original'", clear
			sort `1'
			merge `1' using "`using2'"
			replace recent=`2' if recent==""
			drop _merge
			save mapping, replace
		
			local N=_N
			local i1=1
			while `i1'<=`N'+1 {
				tempvar link2`i1' test3`i1' test4`i1'
				generate `link2`i1'' = recent
				tempfile master2`i1' using3`i1' using4`i1'
				save "`using3`i1''"
				replace `link2`i1'' = `1'
				save "`master2`i1''"
				append using "`using3`i1''"
				replace recent =""
				sort `link2`i1'' `3'
				by `link2`i1'': generate `test3`i1''=_N
				drop if `test3`i1''==1
				by `link2`i1'': assert `2'[_n]==`1'[_n+1] if _n<_N
				by `link2`i1'': replace recent=`2'[_N]
				count
				local count`i1'=r(N)
				if `i1'>1 {
					capture assert `count`i1''!=`count`i2''
					if _rc!=0 {
						sort `1' `3'
						by `1': generate `test4`i1''=_N
						by `1': drop if `2'!=recent & `test4`i1''>1
						save "`using4`i1''"
						use "`original'", clear
						sort `1'
						merge `1' using "`using4`i1''"
						replace recent=`2' if recent==""
						drop _merge
						sort recent `3'
						noisily di
						noisily di as text _dup(20) "*"
						noisily di %~20s "* Mapping complete *"
						noisily di as text _dup(20) "*"
						noisily di
						noisily display as result "Frequency of NoOfEvents:"
						sort recent
						noisily {
							by recent: generate NoOfEvents=_N
							tabulate NoOfEvents, m
							di
						}
						local i3 = 1
						while `i3'<`i1'+2 {
							count if NoOfEvents==`i3'
							local count`i3'=r(N)
							noisily display as result "The number of `i3'-step chains is equal to `count`i3''/`i3'"
							local i3 = `i3'+1
						}
						keep `1' `2' `3' recent NoOfEvents
						save mapping, replace
						restore, not
						exit
					}
				}	
				sort `1' `3'
				by `1': generate `test4`i1''=_N
				by `1': drop if `2'!=recent & `test4`i1''>1
				save "`using4`i1''"
				use "`original'", clear
				sort `1'
				merge `1' using "`using4`i1''"
				replace recent=`2' if recent==""
				drop _merge
				save mapping, replace
				local i2=`i1'
				local i1=`i1'+1
			}
		}
end


*/TO MAP CHAINS IN CASE REAL TIME IS NOT AVAILABLE	
program mapch_2
	version 10
	syntax varlist(max=2) [if] [in]
	marksample touse, strok
	
	*/TO CHECK IF VARIABLES END AND BEGIN ARE UNIQUE
	preserve
	quietly keep if `touse'==1
	tempfile original
	quietly save "`original'", replace
	foreach x in `1' `2' {
		sort `x'
		tempvar test
		by `x': generate `test' = _N
		quietly count if `test'!=1
		local count = r(N)
		capture assert `count'==0
		if _rc!=0 {
			display as error "`x' not unique: at least one value of `x' appears more than once"
			exit 9
		}
	}
	
	*/TO MAP CHAINS
	quietly {
		tempvar link test1 test2
		generate `link' = `2'
		tempfile master using1 using2
		save "`using1'"
		replace `link' = `1'
		save "`master'"
		append using "`using1'"
		sort `link'
		by `link': generate `test1'=_N
		drop if `test1'!=2
		by `link': generate date=1 if `2'==`link'
		by `link': replace date=2 if `2'!=`link'
		sort `link' date
		by `link': assert `2'[_n]==`1'[_n+1] if _n<_N
		by `link': generate str recent=`2'[_N]
		sort `1'
		by `1': generate `test2'=_N
		by `1': drop if `2'!=recent & `test2'>1
		save "`using2'"
		use "`original'", clear
		sort `1'
		merge `1' using "`using2'"
		replace recent=`2' if recent==""
		drop _merge
		save mapping, replace

		local N=_N
		local i1=1
		while `i1'<=`N'+1 {
			tempvar link1`i1' link2`i1' test3`i1' test4`i1' test5 test6
			generate `link2`i1'' = recent
			tempfile master2`i1' using3`i1' using4`i1'
			save "`using3`i1''"
			replace `link2`i1'' = `1'
			save "`master2`i1''"
			append using "`using3`i1''"
			generate `link1`i1'' = recent
			replace recent =""
			sort `link2`i1''
			by `link2`i1'': generate `test3`i1''=_N
			drop if `test3`i1''==1
			sort `link2`i1'' date
			by `link2`i1'': replace date=2 if `1'==`link2`i1'' & _N==2 
			by `link2`i1'': generate `test5' = 1 if `1'==`link2`i1'' & _N==2 
			by `link2`i1'': egen `test6' = sum(`test5')
			by `link2`i1'': replace date=1 if `test6'==1 & `1'!=`link2`i1''
			by `link2`i1'': replace date=_N if `link1`i1''!=`link2`i1'' & `test6'==0
			sort `link2`i1'' date
			by `link2`i1'': assert `2'[_n]==`1'[_n+1] if _n<_N
			by `link2`i1'': replace recent=`2'[_N]
			count
			local count`i1'=r(N)
			if `i1'>1 {
				capture assert `count`i1''!=`count`i2''
				if _rc!=0 {
					sort `1' date
					by `1': generate `test4`i1''=_N
					by `1': drop if `2'!=recent & `test4`i1''>1
					save "`using4`i1''"
					use "`original'", clear
					sort `1'
					merge `1' using "`using4`i1''"
					replace recent=`2' if recent==""
					drop _merge
					sort recent date
					noisily di
					noisily di as text _dup(20) "*"
					noisily di %~20s "* Mapping complete *"
					noisily di as text _dup(20) "*"
					noisily di
					noisily display as result "Frequency of NoOfEvents:"
					sort recent
					noisily {
						by recent: generate NoOfEvents=_N
						tabulate NoOfEvents, m
						di
					}
					local i3 = 1
					while `i3'<`i1'+2 {
						count if NoOfEvents==`i3'
						local count`i3'=r(N)
						noisily display as result "The number of `i3'-step chains is equal to `count`i3''/`i3'"
						local i3 = `i3'+1
					}
					keep `1' `2' date recent NoOfEvents
					save mapping, replace
					restore, not
					exit
				}
			}	
			sort `1' date
			by `1': generate `test4`i1''=_N
			by `1': drop if `2'!=recent & `test4`i1''>1
			save "`using4`i1''"
			use "`original'", clear
			sort `1'
			merge `1' using "`using4`i1''"
			replace recent=`2' if recent==""
			drop _merge
			save mapping, replace
			local i2=`i1'
			local i1=`i1'+1
		}
	}
end

exit
end
