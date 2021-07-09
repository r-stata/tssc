*! version 1.0.0 20Sep2019 MLB
program define twby_ex
version 11.2
if `1' == 1 {
	Msg preserve
	preserve
	Xeq webuse auto2, clear
	Xeq twby foreign rep78 : scatter price weight
	restore
	Msg restore
}
else if `1' == 2 {
	Msg preserve
	preserve
    Xeq webuse auto2, clear
    Xeq replace weight = 0.00045359237*weight
    Xeq label variable weight "Weight (tonnes)"
    Xeq replace price = price / 1000
    Xeq label variable price "Price (1000s {c S|})"
    Xeq twby foreign rep78, compact :    ///
            scatter price weight,        ///
	        ylab(,angle(0)) xlab(1(.5)2)
	restore
	Msg restore
}
else if `1' ==  3 {
	Msg preserve
	preserve
    Xeq sysuse nlsw88, clear

	Xeq gen byte urban = c_city + smsa if !missing(c_city,smsa)
	Xeq label define urban 2 "central city" ///
					       1 "suburban"     ///
				           0 "rural"
	Xeq label value urban urban
	Xeq label variable urban "urbanicity"

	Xeq gen byte marst = !never_married + married if !missing(never_married,married)
	Xeq label define marst 0 "never married" ///
                           1 "widowed/divorced" ///
				           2 "married"
	Xeq label value marst marst
	Xeq label var marst "marital status"
				   
	Xeq gen byte edcat = cond(grade <  12, 1,     ///
                         cond(grade == 12, 2,     ///
                         cond(grade <  16, 3,4))) ///
                         if !missing(grade)
	Xeq label variable edcat "education"
	Xeq label define edcat 1 "< highschool"    ///
                           2 "highschool"      ///
                           3 "some college"    ///
                           4 "college"            
	Xeq label value edcat edcat				   

	Xeq bys edcat: tab urban marst, row nofreq

	Xeq contract edcat marst urban, zero nomiss
	Xeq egen tot = total(_freq), by(urban edcat)
	Xeq gen perc = _freq / tot *100

	Xeq gen lab = strofreal(perc, "%5.0f")
	Xeq gen y = -5

	Xeq twby urban marst ,                                             ///
                compact left xoffset(0.5) legend(off)                  ///
                title("Percentage in each marital status"              ///
	                  "given education and urbanicity") :              ///
            twoway bar perc edcat ,                                    ///
	            xlab(1/4, val alt) yscale(range(0 75))                 ///
	            ylab(none) ytitle("") barw(.5)                      || ///
	        scatter y edcat ,                                          ///
	            msymbol(none) mlab(lab) mlabpos(0) mlabcolor(black)
	restore
	Msg restore
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
