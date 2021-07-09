*! version 1.1.4 28jun2018 daniel klein
program kappaetci
	version 11.2
	
	syntax anything(id = "integer") 	///
	[ , 								///
		Tab 							///
		CATegories(numlist missingokay) ///
		FREquency 				/// ignored
		noRETURN 						/// not documented
		* 								///
	]
	
	_kappaetci_strip_invalid_opts , `options'
	
	preserve
	
	tempname rresults matrow matcol
	
	nobreak {
		_return hold `rresults'
		capture noisily break {
			quietly tabi `anything' ///
				, replace matrow(`matrow') matcol(`matcol')
			if ((r(r) == 1) & (r(c) == 1)) {
				display as err "ratings do not vary"
				exit 459
			}
			if ("`categories'" != "") {
				kappaetci_replace `matrow' `matcol' `categories'
				local options `options' categories(`categories')
			}
			if ("`tab'" != "") {
				tabulate row col [fweight = pop] , cell nokey missing
			}
			kappaetc row col [fweight = pop] , `options'
		}
		if (_rc) {
			local rc = _rc
			_return restore `rresults'
			exit `rc'
		}
		
		if ("`return'" != "") {
			_return restore `rresults'
		}
		else {
			_return drop `rresults'
		}
	}
	
	restore
end

program _kappaetci_strip_invalid_opts
	version 11.2
	syntax [ , FREquency ACM(passthru) ICC(passthru) * ]
	local 0 , options `frequency' `acm' `icc'
	syntax , OPTIONS
end

program kappaetci_replace
	version 11.2
	
	gettoken matrow 0 : 0
	gettoken matcol 0 : 0
	
	mata : st_local("maxcat", ///
		strofreal(max(st_matrix("`matrow'")\ vec(st_matrix("`matcol'")))))
	
	local ncat : word count `0'
	if (`ncat' != `maxcat') {
		local rc = 122 + (`ncat' > `maxcat')
		display as err "option categories() invalid -- " _continue
		error `rc'
	}
	
	rename row row_o
	rename col col_o
	
	tokenize `0'
	
	quietly {
		generate double row = row_o
		generate double col = col_o
		forvalues j = 1/`ncat' {
			replace row = ``j'' if (row_o == `j')
			replace col = ``j'' if (col_o == `j')
		}
		drop row_o 
		drop col_o
	}
	
	summarize pop if (mi(row) & mi(col)) , meanonly
	if (r(sum)) {
		display as txt "note: " r(sum) ///
		" subjects not classified by either rater"
	}
end
exit

1.1.4	28jun2018	code polish
1.1.3	24feb2018	strip invalid options for kappaetc subroutines
1.1.2	30jan2018	exit with error if ratings do not vary
1.1.1	18dec2017	count of subjects not classified by either rater
					new option noreturn (not documented)
					submitted to SJ
1.1.0	06may2017	bug fix get maximum (number of) categories from data
					pass option categories() along to kappaetc
					repeated options no longer allowed
1.0.0	17jan2017	first release
