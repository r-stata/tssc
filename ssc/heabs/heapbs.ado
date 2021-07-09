** ensure bootstrapped data set is open **

cap program drop heapbs
program heapbs, rclass
	version 8.2
	syntax, [				///
	lci(varname numeric) 	///
	uci(varname numeric) 	///
	ref(real 0) 			///
	inb(varname numeric)	///
	draw 					///
	cost(varname numeric) 	///
	effect(varname numeric) ///	
	w2p(real 0) 			///
	lineopts(string)		///
	scatteropts(string)		///
	meanopts(string)		///
	ellipopts(string)		///
	* 						///
	]
		
		
	** Probability of Miscoverage **
	
if "`lci'" != "" & "`uci'" != ""  {	
	
	qui count if missing(`lci')
	local missing`lci' = r(N)
	if `missing`lci'' != 0 {
		di in red "Error: Missing Data detected in `lci'"
		exit 456
	} 
	
	qui count if missing(`uci')
	local missing`uci' = r(N)
	if `missing`uci'' != 0 {
		di in red "Error: Missing Data detected in `uci'"
		exit 457
	} 
	
	
	if `lci' > `uci' {
	di in red "Error Lower CI is larger than Upper CI"
	exit
	}
	
	
	qui	count if (`lci' > `ref' | `ref' > `uci' ) & `ref'!=.
		local positives = r(N)
	qui	count if `lci' < `ref' & `ref' < `uci'  & `ref'!=.
		local negatives = r(N)
		di ""
		di "Probability of Miscoverage = " 100* `positives'/(`positives'+`negatives') "%"
	return scalar pmc = 100* `positives'/(`positives'+`negatives')
	}
	
	** Probability of Cost Effectiveness **
	if "`inb'" != "" {
	
	 qui count if missing(`inb')
	local missinginb = r(N)
	if `missinginb' != 0 {
		di in red "Error: Missing Data detected in `inb'"
		exit 456
	} 
	
	qui	count if `inb' >= 0 & `inb' < .
		local positives = r(N)
	qui	count if `inb' < 0
		local negatives = r(N)
		return scalar pce = 100* `positives'/(`positives'+`negatives')
		di "Probability of Cost Effectiveness = " 100 * `positives'/(`positives'+`negatives') "%"
	
	}
	
	if "`draw'" == "draw" {
	qui summarize `cost', meanonly
	local costmean = r(mean)
	qui summarize `effect', meanonly
	local effmean = r(mean)
		local maxeff = r(max)
		
		 if `w2p' > 0 {
		 ellip `cost' `effect',  means c(f) color(red) lpattern(dash) level(95) xti("Effect") yti("Cost") legend(order(1 "95% CI" 3 " Mean Average" 4 "Threshold" ))  ///
                                plot( (scatter `cost' `effect', msize(tiny) color(black) yline(0,lc(black)) xline(0,lc(black)) `scatteropts') (scatteri  `costmean' `effmean', color(mint) `meanopts' ) (function y=`w2p'*x , range(0 `maxeff') `lineopts' )) `ellipopts'   `options'
} 
else {
                ellip `cost' `effect',  means c(f) color(red) lpattern(dash) level(95) xti("Effect") yti("Cost") legend(order(1 "95% CI" 3 " Mean Average" ))  ///
                                plot( (scatter `cost' `effect', msize(tiny) color(black) yline(0,lc(black)) xline(0,lc(black)) `scatteropts'  ) (scatteri  `costmean' `effmean', color(mint) `meanopts' )  ) `ellipopts' `options'
				}
                }
	*
	
	end
		

		
