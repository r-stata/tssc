*! version 1.0.0 MLB 22May2009
program define mfxrcspline_ex
	Msg preserve
	preserve

	if `1' == 1 {
		Xeq sysuse nlsw88, clear
	
		Xeq recode grade 0/5=5
		
		Xeq mkspline2 grades = grade, cubic nknots(3)
		Xeq logit never_married grades*
		
		Xeq adjustrcspline, name(__ex_adjustrcspline1)
		Xeq mfxrcspline, name(__ex_mfxrcspline1)
	}
	else if `1' == 2 {
		Xeq sysuse uslifeexp, clear
		
		Xeq mkspline2 ys = year, cubic 
		Xeq reg le ys* if year != 1918
		
		Xeq adjustrcspline if year != 1918, ///
	    	        addplot(scatter le year if year != 1918, msymbol(Oh) || ///
	    	                scatter le year if year == 1918, msymbol(X) )   ///
	    	        ytitle("life expectancy")                               ///
	    	        name(__ex_adjustrcspline2)                              /// 
		        note("1918 was excluded from the computations because of the Spanish flu")
		
		Xeq mfxrcspline if year != 1918, name(__ex_mfxrcspline2)
	}
	else if `1' == 3 {
		Xeq sysuse nlsw88, clear
		
		Xeq recode grade 0/5=5
		
		Xeq mkspline2 grades = grade, cubic nknots(3)
		Xeq logit never_married grades*

		Xeq mfxrcspline, customdydxb("invlogit(xb())*invlogit(-1*xb())")
	}
	else if `1' == 4 {
		Xeq sysuse nlsw88, clear

		Xeq recode grade 0/5=5
	
		Xeq mkspline2 grades = grade, cubic nknots(3)
		Xeq logit never_married grades*

		Xeq glm never_married grades* south, link(cloglog) family(binomial)
		Xeq mfxrcspline, at(south=0)	
	}
	else if `1' == 5 {
		Xeq sysuse cancer, clear
		Xeq gen long id = _n
		Xeq stset studytime, failure(died) id(id)
			
		Xeq stsplit t, every(1)
		
		Xeq mkspline2 ts=t, cubic nknots(3)
		Xeq xi: streg i.drug age ts*, dist(exp)
		
		if c(stata_version) >= 11 {
			Xeq mfxrcspline , at(_Idrug_2=0 _Idrug_3=0) ///
							  link("log")               ///
							  noci                      ///
							  ytitle("{&part} hazard / {&part} time")
		}
		else {
			Xeq mfxrcspline , at(_Idrug_2=0 _Idrug_3=0) ///
							  link("log")               ///
							  noci                      ///
							  ytitle("d hazard / d time")
		}
	}
	
	Msg restore 
	restore
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

