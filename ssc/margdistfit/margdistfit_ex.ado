*! version 1.2.0 20Dec2011
*  version 1.0.1 21Nov2011
*  version 1.0.0 14Nov2011
program define margdistfit_ex
	version 10.1
	
	if `1' == 1 {
		Msg preserve
		preserve

		Xeq sysuse nlsw88, clear
		Xeq gen lnw = ln(wage)
		Xeq reg lnw grade ttl_exp tenure union
		Xeq margdistfit, qq

		Msg restore 
		restore
	}
	if `1' == 2 {
		Msg preserve
		preserve
		
		Xeq sysuse auto, clear
		Xeq reg price mpg foreign
		Xeq margdistfit, pp

		Msg restore
		restore
	}
	if `1' == 3 {
		Msg preserve
		preserve
		
		Xeq set seed 12345
		Xeq drop _all
		Xeq set obs 500
		Xeq gen x = runiform() < .5
		Xeq gen y = -2 + 4*x + rnormal()
		Xeq regres y x
		Xeq margdistfit, hangroot(jitter(5))
		
		Msg restore
		restore
	}
	if `1' == 4 {
		Msg preserve
		preserve
		Xeq use http://www.stata-press.com/data/lf2/couart2,clear
		Xeq mkspline ment1 20 ment2 = ment
	  
		Msg * this is just to ensure that graph names do not conflict
		Msg * with any graph name you have open
		Msg tempname poisson zip nb zinb
	    tempname poisson zip nb zinb
		
		Xeq poisson art fem mar kid5 phd ment1 ment2
		Msg margdistfit, hangroot(susp notheor jitter(2)) title(poisson) name(`poisson')
		margdistfit, hangroot(susp notheor jitter(2)) title(poisson) name(`poisson')
		
		Xeq zip art fem mar kid5 phd ment1 ment2, inflate(_cons)
		Msg margdistfit, hangroot(susp notheor jitter(2)) title(zip) name(`zip')
		margdistfit, hangroot(susp notheor jitter(2)) title(zip) name(`zip')
	  
		Xeq nbreg art fem mar kid5 phd ment1 ment2
		Msg margdistfit, hangroot(susp notheor jitter(2)) title(nbreg) name(`nb')
		margdistfit, hangroot(susp notheor jitter(2)) title(nbreg) name(`nb')
		
		Xeq zinb art fem mar kid5 phd ment1 ment2, inflate(_cons)
		Msg margdistfit, hangroot(susp notheor jitter(2)) title(zinb) name(`zinb')
		margdistfit, hangroot(susp notheor jitter(2)) title(zinb) name(`zinb')
		
		Msg restore
		restore
	}
end

program Msg
        di as txt
        di as txt "-> " as res `"`0'"'
end

program Xeq, rclass
        di as txt
        di as txt `"-> "' as res `"`0'"'
        `0'
end
	
