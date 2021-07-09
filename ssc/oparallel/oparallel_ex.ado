program define oparallel_ex
	if `1' == 1 {
		Msg preserve
		preserve
		Xeq use "http://www.indiana.edu/~jslsoc/stata/spex_data/ordwarm2.dta", clear
		Xeq ologit warm white ed prst male yr89 age
		Xeq oparallel
		Msg restore
		restore
	}
	
	if `1' == 2 {
		Msg preserve
		preserve
		Xeq use "http://www.indiana.edu/~jslsoc/stata/spex_data/ordwarm2.dta", clear
		Xeq ologit warm white ed prst age
		Xeq oparallel, brant asl mcci 
		Msg restore
		restore
	}
	
	if `1' == 3 {
		capture which qenvchi2
		if _rc local noqenv "qenv"
		capture which qplot
		if _rc local noqplot "qplot"
		capture which simpplot
		if _rc local nosimpplot "simpplot"
		
		if "`noqenv'`noqplot'`nosimpplot'" != "" {
			di as err "this example requires the `noqenv' `noqplot' `nosimpplot' packages"
			exit
		}
		
		Msg preserve
		preserve
		Xeq use "http://www.indiana.edu/~jslsoc/stata/spex_data/ordwarm2.dta", clear
		Xeq ologit warm white ed prst male yr89 age
		Msg tempfile reps
		tempfile reps
		Msg oparallel, brant asl saving(\`reps')
		oparallel, brant asl saving(`reps')
		Msg use \`reps', clear
		use `reps', clear
		
		Xeq qenvchi2 Brant_stat, gen(lb ub) df(12) overall reps(5000)
		Msg tempname a b
		tempname a b
		Msg qplot Brant_stat lb ub, ms(oh none ..) c(. l l) lc(gs10 ..) ///
			legend(off) ytitle("Brant test statistic") trscale(invchi2(12,@)) ///
			xtitle("{&chi}{sup:2}(12) quantiles") ///
			scheme(s2color) ylab(,angle(horizontal)) name(\`a')

		qplot Brant_stat lb ub, ms(oh none ..) c(. l l) lc(gs10 ..) ///
			legend(off) ytitle("Brant test statistic") trscale(invchi2(12,@)) ///
			xtitle("{&chi}{sup:2}(12) quantiles") ///
			scheme(s2color) ylab(,angle(horizontal)) name(`a')			
			
		Msg simpplot Brant_p, scheme(s2color) ylab(,angle(horizontal)) name(\`b')
		simpplot Brant_p, scheme(s2color) ylab(,angle(horizontal)) name(`b')
		Msg restore
		restore
	}
end

program Msg
    di as txt
    di as txt "-> " as res `"`macval(0)'"'
end

program Xeq
    di as txt
    di as txt `"-> "' as res `"`0'"'
    `0'
end
