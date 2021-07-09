*! version 1.2.3 MLB 03Feb2011
program define proprcspline_ex
	Msg preserve
	preserve
	if `1' == 1 {
		Xeq sysuse nlsw88, clear
    
		Xeq gen marst = cond(never_married, 1,           ///
			    cond(married, 2, 3))                 ///
		            if !missing(married, never_married)
		Xeq label define marst 1 "never married"         ///
		                       2 "married"               ///
		                       3 "divorced/widowed"
		Xeq label value marst marst
    
		Xeq proprcspline marst grade, xlab(0(5)15) 
	}
	if `1' == 2 {
		Xeq sysuse nlsw88, clear
	   
		Xeq gen marst = cond(never_married, 1,           ///
			    cond(married, 2, 3))                 ///
		            if !missing(married, never_married)
		Xeq label define marst 1 "never married"         ///
		                       2 "married"               ///
		                       3 "divorced/widowed"
		Xeq label value marst marst
	   
		Xeq proprcspline marst grade, xlab(0(5)15)       ///
		            rareaopt1(color(red))                ///
		            rareaopt2(color(blue))               ///
		            rareaopt3(color(gs10))
	}
	if `1' == 3 {
		Xeq sysuse nlsw88, clear
    
		Xeq gen marst = cond(never_married, 1,           ///
		                cond(married, 2, 3))             ///
		            if !missing(married, never_married)
		Xeq label define marst 1 "never married"         ///
		                       2 "married"               ///
		                       3 "divorced/widowed"
		Xeq label value marst marst

		Xeq label define c_city 1 "in central city"      ///
		                        0 "outside central city"
		Xeq label value c_city c_city
		
		Xeq proprcspline marst grade, xlab(0(5)15)       ///
		                          by(c_city, note(""))   
	}                              
	if `1' == 4 {
		Xeq sysuse nlsw88, clear
    
		Xeq gen marst = cond(never_married, 1,           ///
		                cond(married, 2, 3))             ///
		            if !missing(married, never_married)
		Xeq label define marst 1 "never married"         ///
		                       2 "married"               ///
		                       3 "divorced/widowed"
		Xeq label value marst marst

		Xeq label define c_city 1 "in central city"      ///
		                        0 "outside central city"
		Xeq label value c_city c_city
		
		Xeq gen black = race == 2 if race < .
		Xeq label define black 1 "black"                 ///
		                   0 "non-black"
		Xeq label value black black    

		Xeq proprcspline marst grade black, xlab(0(5)15) ///
		                          by(c_city, note(""))   ///
								  at(black 0)
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
