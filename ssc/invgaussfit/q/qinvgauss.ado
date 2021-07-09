*! 1.0.0 NJC 14 December 2006
program qinvgauss, sort
	version 9 
	syntax varname(numeric) [fweight aweight/] [if] [in] ///
	[, Grid GENerate(namelist max=1) param(numlist min=2 max=2) show(str) * ]
	
	_get_gropts , graphopts(`options') getallowed(RLOPts addplot)
	local options `"`s(graphopts)'"'
	local rlopts `"`s(rlopts)'"'
	local addplot `"`s(addplot)'"'
	_check4gropts rlopts, opt(`rlopts')

	quietly { 
		if "`generate'" != "" { 
			capture confirm new var `generate' 
			if _rc { 
				di as err "generate() must name new variable"
				exit 198 
			}
		}
		
		marksample touse
		local y "`varlist'" 
		count if `y' <= 0 & `touse'
		if r(N) {
			noi di as txt "{p}warning: {res:`y'} has `r(N)' values <= 0;" ///
			" not used in calculations{p_end}"
		}
		replace `touse' = 0 if `y' <= 0
		count if `touse' 
		if r(N) == 0 error 2000 

		if `"`show'"' != ""  { 
			capture count if `show' 
			if _rc { 
				di as err "invalid show() option"
				exit 198 
			} 
			else { 
				count if (`show') & `touse' 
				if r(N) == 0 error 2000 
			}

			local show "& (`show')" 
		}

		if "`param'" != "" { 
			tokenize `param' 
			args mu lambda 
			if `mu' <= 0 | `lambda' <= 0 { 
				di as err "parameters must be positive"
				exit 498 
			}	
		} 	
		else { 
			if "`weight'" != "" { 
				invgausscf `y' if `touse' [`weight' = `exp'] 
			}
			else invgausscf `y' if `touse'
			local mu = r(mu) 
			local lambda = r(lambda) 
		} 
		
		tempvar Z Psubi
		if "`exp'" == "" local exp = 1 
		sort `touse' `y'
		gen float `Psubi' = sum(`touse' * `exp') - 0.5 * `exp' 
		su `touse' [w = `exp'], meanonly 
		replace `Psubi' = `Psubi' / r(sum) if `touse' 
		mata : invinvgaussvar(`mu', `lambda', "`Psubi'", "`touse'", "`Z'") 
		label var `Z' "inverse inverse Gaussian"
		local xttl : var label `Z'
		local fmt : format `y'
		format `fmt' `Z'
	}	
	
	qui if "`grid'" != "" {
		tempvar g use Zgrid 
		gen byte `use' = _n <= 7 
		gen `g' = . 
		tokenize "5 10 25 50 75 90 95" 
		forval i = 1/7 { 
			replace `g' = ``i'' / 100 in `i' 
	        }

		mata : invinvgaussvar(`mu', `lambda', "`g'", "`use'", "`Zgrid'") 
		
		forval i = 1/7 { 
			local igq``i'' : di %4.3f `Zgrid'[`i'] 
		}	

                local xtl "`igq50' `igq5' `igq95'"
                local xn  "`xtl' `igq25' `igq75' `igq10' `igq90'"
		
	        su `y' if `touse', detail
                local ytl = string(r(p50)) + " " ///
		          + string(r(p5)) + " " ///
			  + string(r(p95))  
                local yn = "`ytl'" + " " + /// 
                           string(r(p25)) + " " ///
		         + string(r(p75)) + " " /// 
                         + string(r(p10)) + " " ///
		         + string(r(p90)) 
			 
		local yl yaxis(1 2)		///
			ytitle("", 	///
				axis(2)		///
			)			///
			ylabels(`ytl',		///
				nogrid		///
				axis(2)		///
			)			///
			yticks(`yn',		///
				grid		///
				gmin		///
				gmax		///
				axis(2)		///
			)			///
			// blank

		local xl xaxis(1 2)		///
			xtitle("",		///
				axis(2)		///
			)			///
			xlabels(`xtl',		///
				nogrid		///
				axis(2)		///
			)			///
			xticks(`xn',		///
				grid		///
				gmin		///
				gmax		///
				axis(2)		///
			)			///
			// blank
		local note	///
		`"Grid lines are 5, 10, 25, 50, 75, 90, and 95 percentiles"'
	}

	local yttl : var label `y'
	if `"`yttl'"' == "" local yttl `y'
	if `"`addplot'"' == "" local legend legend(nodraw)

	graph twoway			          ///
	(scatter `y' `Z' if `touse' `show', ///
		sort				  ///
		ytitle(`"`yttl'"')		  ///
		xtitle(`"`xttl'"')		  ///
		`legend'			  ///
		ylabels(, nogrid)		  ///
		xlabels(, nogrid)		  ///
		`yl'				  ///
		`xl'				  ///
		note(`"`note'"')		  ///
		`options'			  ///
	)					  ///
	(function y=x if `touse' `show',          ///
		range(`Z')			  ///
		n(2)				  ///
		clstyle(refline)		  ///
		yvarlabel("Reference")		  ///
		yvarformat(`fmt')		  ///
		`rlopts'			  ///
	)					  ///
	|| `addplot' 
	// blank

	// user will see any message about missing values 
	if "`generate'" != "" { 
		gen `generate' = `Z' 
		label var `generate' "inverse Gaussian quantiles for `y'" 
	}	
end

// Mata functions NJC 14 December 2006

mata : 

// vector = f(y | mu, lambda)
real invgaussden(real scalar mu, 
		 real scalar lambda, 
		 real colvector y) 
{ 
	if (mu <= 0) { 
		displayas("error") 
		printf("mu must be positive\n")
		exit(error(411)) 
	} 

	if (lambda <= 0) { 
		displayas("error") 
		printf("lambda must be positive\n")
		exit(error(411)) 
	} 

	if (sum(y :<= 0)) { 
		displayas("error") 
		printf("values must be positive\n")
		exit(error(411)) 
	} 
	
	return(sqrt(lambda :/ (2 * pi() :* y:^3)) :* 
		exp(-lambda :* (y :- mu):^2 :/ (2 * mu^2 :* y))) 
}

// variable = f(y | mu, lambda)
void invgaussdenvar(real scalar mu, 
		 real scalar lambda, 
		 string scalar varname, 
		 string scalar tousename,
		 string scalar densityname) 
{ 
	real colvector y, density 

	if (mu <= 0) { 
		displayas("error") 
		printf("mu must be positive\n")
		exit(error(411)) 
	} 

	if (lambda <= 0) { 
		displayas("error") 
		printf("lambda must be positive\n")
		exit(error(411)) 
	} 

	y = st_data(., varname, tousename) 

	if (sum(y :<= 0)) { 
		displayas("error") 
		printf("values must be positive\n")
		exit(error(411)) 
	} 

	density = sqrt(lambda :/ (2 * pi() :* y:^3)) :* 
		exp(-lambda :* (y :- mu):^2 :/ (2 * mu^2 :* y))

	st_addvar("double", densityname)
	st_store(., densityname, tousename, density) 
}


// vector = F(y | mu, lambda)
real invgauss(real scalar mu, 
	      real scalar lambda, 
	      real colvector y) 
{ 
	real colvector dist 

	if (mu <= 0) { 
		displayas("error") 
		printf("mu must be positive\n")
		exit(error(411)) 
	} 
	
	if (lambda <= 0) { 
		displayas("error") 
		printf("lambda must be positive\n")
		exit(error(411)) 
	} 

	if (sum(y :<= 0)) { 
		displayas("error") 
		printf("values must be positive\n")
		exit(error(411)) 
	} 

	dist = sqrt(lambda :/ y)
	dist = normal(dist :* (y :/ mu :- 1)) + 
		exp(2 * lambda / mu) :* normal(-dist :* (y :/ mu :+ 1))

	return(dist)
}

// variable = F(y | mu, lambda)
void invgaussvar(real scalar mu, 
	      real scalar lambda, 
	      string scalar varname, 
	      string scalar tousename,
	      string scalar distname) 
{ 
	real colvector y, dist 

	if (mu <= 0) { 
		displayas("error") 
		printf("mu must be positive\n")
		exit(error(411)) 
	} 

	if (lambda <= 0) { 
		displayas("error") 
		printf("lambda must be positive\n")
		exit(error(411)) 
	} 

	y = st_data(., varname, tousename) 

	if (sum(y :<= 0)) { 
		displayas("error") 
		printf("values must be positive\n")
		exit(error(411)) 
	} 

	dist = sqrt(lambda :/ y) 
	dist = normal(dist :* (y :/ mu :- 1)) + 
		exp(2 * lambda / mu) :* normal(-dist :* (y :/ mu :+ 1))

	st_addvar("double", distname)
	st_store(., distname, tousename, dist) 
}


// vector = quantile(P | mu, lambda)
real invinvgauss(real scalar mu, 
	      real scalar lambda, 
	      real colvector p) 
{ 
//       based on algorithm coded in S by 
//	 Dr Paul Bagshaw
//	 Centre National d'Etudes des Telecommunications (DIH/DIPS)
//	 Technopole Anticipa, France
//	 paul.bagshaw@cnet.francetelecom.fr
//	 23 Dec 98

	real colvector y, cum, dy  
	real scalar phi, i 

	if (mu <= 0) { 
		displayas("error") 
		printf("mu must be positive\n")
		exit(error(411)) 
	} 

	if (lambda <= 0) { 
		displayas("error") 
		printf("lambda must be positive\n")
		exit(error(411)) 
	} 

	if (sum(p :<= 0 :| p :>= 1)) { 
		displayas("error") 
		printf("values must be in (0,1)\n")
		exit(error(498)) 
	} 

	phi = lambda / mu
	y = invnormal(p)
	y = 1 :+ y / sqrt(phi) + y:^2 / (2 * phi) + y:^3 / (8 * phi * sqrt(phi))

	for(i = 1; i <= 10; i++) {
		cum = invgauss(1, phi, y)
		dy = (cum :- p) :/ invgaussden(1, phi, y)

		// S : dx <- ifelse(is.finite(dx), dx, ifelse(p > cum, -1, 1))
		//     dx[dx < -1] <- -1
		dy = ((dy :< .) :* dy) + 
			(dy :>= .) :* ((p :<= cum) - (p :> cum)) 
		dy = rowmax((dy, J(length(dy), 1, -1)))  

		if (sum(dy :== 0) == n) break
		y = y - dy
	}
	
	return(y = y * mu) 
}

// variable = quantile(P | mu, lambda)
void invinvgaussvar(real scalar mu, 
	      real scalar lambda, 
	      string scalar varname, 
	      string scalar tousename,
	      string scalar yname) 
{ 
//       based on algorithm coded in S by 
//	 Dr Paul Bagshaw
//	 Centre National d'Etudes des Telecommunications (DIH/DIPS)
//	 Technopole Anticipa, France
//	 paul.bagshaw@cnet.francetelecom.fr
//	 23 Dec 98

	real colvector p, y, cum, dy 
	real scalar n, phi, i 

	if (mu <= 0) { 
		displayas("error") 
		printf("mu must be positive\n")
		exit(error(411)) 
	} 

	if (lambda <= 0) { 
		displayas("error") 
		printf("lambda must be positive\n")
		exit(error(411)) 
	} 

	p = st_data(., varname, tousename) 
	n = length(p) 

	if (sum(p :<= 0 :| p :>= 1)) { 
		displayas("error") 
		printf("values must be in (0,1)\n")
		exit(error(498)) 
	} 

	phi = lambda / mu
	y = invnormal(p)
	y = 1 :+ y / sqrt(phi) + y:^2 / (2 * phi) + y:^3 / (8 * phi * sqrt(phi))

	for(i = 1; i <= 10; i++) {
		cum = invgauss(1, phi, y)
		dy = (cum :- p) :/ invgaussden(1, phi, y)

		// S : dx <- ifelse(is.finite(dx), dx, ifelse(p > cum, -1, 1))
		//     dx[dx < -1] <- -1
		dy = ((dy :< .) :* dy) + 
			(dy :>= .) :* ((p :<= cum) - (p :> cum)) 
		dy = rowmax((dy, J(length(dy), 1, -1)))  

		if (sum (dy :== 0) == n) break
		y = y - dy
	}
	
	y = y :* mu
	st_addvar("double", yname)
	st_store(., yname, tousename, y) 
}

end 
