*! version 1.0.0 11Apr2016 MLB
program define stdtable_ex
if `1' == 1 {
    Msg preserve
    preserve
    Xeq use "http://www.maartenbuis.nl/software/mob.dta", clear
    Xeq tab row col [fw=pop]
    restore
    Msg restore
}
else if `1' == 2 {
    Msg preserve
    preserve
    Xeq use "http://www.maartenbuis.nl/software/mob.dta", clear
    Xeq stdtable row col [fw=pop]
    restore
    Msg restore
}
else if `1' == 3 {
    Msg preserve
    preserve
    Xeq use "http://www.maartenbuis.nl/software/homogamy.dta", clear
    Xeq stdtable racem racef [fw=freq], by(marcoh)
    restore
    Msg restore
}
else if `1' == 4 {
    Msg preserve
    preserve
    Xeq use "http://www.maartenbuis.nl/software/homogamy.dta", clear
    Xeq stdtable racem racef [fw=freq] , by(marcoh) replace format(%5.0f)
		Xeq gen y = -6
    Xeq twby racem racef, compact left xoffset(0.4) legend(off): ///
         twoway bar std marcoh, barw(8) ||                   ///
         scatter y marcoh, msymbol(i) mlab(std) mlabpos(0)   ///
         yscale(range(0 100)) ylab(none) ytitle("")          ///
         xlab(1950(10)2010, val angle(30))
    restore
    Msg restore
}
    
else if `1' == 5 {
    Msg preserve
    preserve
    Xeq clear all
	Xeq use "http://www.maartenbuis.nl/software/homogamy.dta", clear

	Xeq stdtable racem racef [fw=freq], ///
		by(marcoh, base(2010)) row raw replace format(%5.0f)

	Xeq gen marcoh1 = marcoh - 2 
	Xeq gen marcoh2 = marcoh + 2 
	Xeq gen y = -7

	Xeq twby racem racef , compact left xoffset(.4)                           ///
		title("Raw row percentages and row percentages standardized"      ///
			  "to marginal distributions of marriage cohort 2010-2017") : ///
		twoway bar _freq marcoh1 , barwidth(4) scheme(s1color)         || ///
			   bar std   marcoh2 , barwidth(4)                            ///
			   legend(order(1 "raw" 2 "standardized"))                    ///
			   ytitle(row percentages)                                    ///
			   xlab(1950 "1950-1959"                                      ///
					1960 "1960-1969"                                      ///
					1970 "1970-1979"                                      ///
					1980 "1980-1989"                                      ///
					1990 "1990-1999"                                      ///
					2000 "2000-2009"                                      ///
					2010 "2010-2017", angle(30))                          ///
			   yscale(off range(0 105)) ytitle("") ylab(none)          || ///
			   scatter y marcoh1 ,                                        ///
			   msymbol(i) mlab(_freq) mlabpos(0) mlabcolor(black)      || ///
			   scatter std marcoh2 ,                                      ///
			   msymbol(i) mlab(std) mlabpos(12) mlabcolor(black) 
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
