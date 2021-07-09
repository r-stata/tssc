*! version 4.2 18nov2010 -- Ph. Van Kerm    
*   -- update to Stata 11 syntax
* version 4.1 26aug2010 -- Ph. Van Kerm    
*   -- add cdf variability bands
* version 4.0 10mar2010,13jul2010 -- Ph. Van Kerm    
*   -- add cdf() option
* version 3.0 22sep2005 -- Ph. Van Kerm         (SJ3-2: st0037, SJ4-1: st0037_1, SJ?-?: st0037_2)
* version 2.0 5feb2003 -- Ph. Van Kerm         (SJ3-2: st0037, SJ4-1: st0037_1)
* version 1.0 6jan2003


* AKDENSITY is a wrapper to produce 2-stage
* adaptive kernel density estimates.
* Estimates are produced by repeated calls to
* AKDENSITY0. Most of the code is
* drawn from the official KDENSITY command.
* Works both with Stata 7 and Stata 8.
* Bug fix 2005-09: -gauss- option was
*  ineffective in Stata 8 and above
* Also option EPAN2 added (for alternative
*  Epanechnikov kernel)


 program define akdensity , rclass sortpreserve

 version 7.0

 if _caller()<8  {
   syntax varname(numeric) [if] [in] [fw aw] [, /*
		*/ Generate(string) N(integer 50) CDF(string) /*
		*/ Width(real 0.0) BWidth(real 0.0) noGRaph noDENSity /*
		*/ EPan GAUssian EPAN2 Kernel(string) noADAPtive /*
		*/ Symbol(string) Connect(string) /*
		*/ Title(string) AT(varname) NORmal STUdent(int 0) /*
		*/ STDBands(real 0.0) * ]
    }
  else {
    version 8.0
	syntax varname(numeric)			///
		[if] [in] [fw aw] [,		///
		Generate(string)		///
		CDF(string)				///
		AT(varname)			///
		N(integer 50)			///
		Width(real 0.0)			///
		BWidth(real 0.0)		///		
		noADAPtive          ///
		STDBands(real 0.0)  ///
		noGRaph				///
		Kernel(string)			///
		EPanechnikov			///
		GAUssian			///
		EPAN2   		///
		NORmal				///
		STUdent(int 0)			///
		*				///
	]
	if `"`graph'"' != "" {
		_get_gropts , graphopts(`options')
		syntax varname(numeric)			///
			[if] [in] [fw aw] [,		///
			Generate(string)		///
			CDF(string)				///
			AT(varname)			///
			N(integer 50)			///
			Width(real 0.0)			///
			BWidth(real 0.0)		///			
   		    noADAPtive          ///
		    STDBands(real 0.0)  ///
			noGRaph				///
			Kernel(string)			///			
			EPanechnikov			///
			EPAN2			///
			GAUssian			///
		]
	  }
	_get_gropts , graphopts(`options')	///
		getallowed(stopts NORMOPTS plot addplot)
	local options `"`s(graphopts)'"'
	local normopts `"`s(normopts)'"'
	local stopts `"`s(stopts)'"'
	_check4gropts normopts, opt(`normopts')
	_check4gropts stopts, opt(`stopts')
	if `"`normopts'"' != "" {
		local normal normal
	}
	if `"`stopts'"' != "" & `student' < 1 {
		di as err "option student() is required by stopts() option"
		exit 198
	}
	local plot `"`s(plot)'"'
	local addplot `"`s(addplot)'"'	
   // end of added for 8
   }


  version 7.0

	if "`at'"!="" & `n'!=50 {
		di in red "may not specify both the at() and n() options"
		exit 198
	}
    
    ** added 2011-11-18 (to update to Stata 11 -kernel()- option)
    ** copied from kdensity.ado with adjustment to allow only epan epan2 gauss
	local kernel_old  ///
				`epanechnikov'	///
				`gaussian'	///
				`epan2'
	local k : word count `kernel_old'
		if `"`kernel'"' == "" {
			if `k' > 1 {
				di as err "only one kernel may be specified"
				exit 198
			}
			if `k' == 0 {
				local kernel epanechnikov
			}
			else {
				local kernel `kernel_old'
			}
		}
		else {
			if `k' != 0 {
				di as err "kernel(): old syntax "    ///
					  "may not be combined with new syntax"
				exit 198
			}
			local k : word count `kernel'
			if `k' > 1 {
				di as err "only one kernel may be specified"
				exit 198
			}
			_get_kernel_name, kernel(`"`kernel'"')
			local kernel `s(kernel)'
			if `"`kernel'"' == "" {
				di as err "invalid kernel function"
				exit 198
			}
		}  // **end addition 2010-11-18
		
		
	local ix `"`varlist'"'
	local ixl: variable label `ix'
	if `"`ixl'"'=="" {
		local ixl "`ix'"
	}
	
    ** added 2011-11-18 (to update to Stata 11 -bwidth()- option)
    ** copied from kdensity.ado 
	if `bwidth' != 0 {
		if `width' != 0 {
			di as err ///
			     "options width() and bwidth() may not be combined"
			exit 198
		}
		local width = `bwidth'
	}
	if `width' < 0 {
		di as err ///
		     "bandwidth must be positive"
		exit 198
	}
	**end addition 2010-11-18
	
	

	local gen `"`generate'"'

/* drop 2010-11-17 -- treated above 
	local kflag = ( (`"`epan'"' != `""') + (`"`gauss'"' != `""') + (`"`epan2'"' != `""') )
	if `kflag' > 1 {
		di in red `"only one kernel may be specified"'
		exit 198
	}

    if `"`gauss'"'  != `""' {
       local kernel=`"Gaussian"'
       }
	else {
		if `"`epan2'"'  !=  `""'  {
       		local kernel=`"Alternative Epanechnikov"'
        }
        else {
       local kernel=`"Epanechnikov"'
        }
	}
*/

	marksample use
	qui count if `use'
	if r(N)==0 {
           error 2000
           }

	tokenize `gen'
	local wc : word count `gen'
	if `wc' {
		if `wc' == 1 {
			if `"`at'"' == `""' {
				error 198
			}
			confirm new var `1'
			local yl  `"`1'"'
			local xl `"`at'"'
			local nsave 1
		}
		else {
			if `wc' != 2 {
                    error 198
                    }
			confirm new var `1'
			confirm new var `2'
			local xl  `"`1'"'
			local yl  `"`2'"'
			local nsave 2
		}
	}
	else {
		local xl   `"X"'
		local yl   `"Density"'
		local nsave 0
	}

	if ("`cdf'" != "") {
		if ! (("`at'" != "") | (`wc' == 2) ) {
			di in red `"cdf() requires at() or generate(var1 var2) options be specified"'
			exit 198
		}
		confirm new var `cdf'
		loc cdfopt cdf(`cdf')
	}
		
	if (`stdbands' > 0.0) & (`wc' >= 0) {
		confirm new var `yl'_up
		confirm new var `yl'_lo
		if ("`cdf'" != "") {
			confirm new var `cdf'_up
			confirm new var `cdf'_lo
			}
		}


	tempvar d m
	qui gen double `m'=.

	if `"`at'"' != `""' {
		qui count if `at' != .
		local n = r(N)
		qui replace `m' = `at'
		local srtlst : sortedby
		tempvar obssrt
		gen `obssrt' = _n
		sort `m' `obssrt'
	}
	else {
		if `"`n'"'!= `""' {
			if `n' <= 1 {
                    local n = 50
                    }
			if `n' > _N {
				local n = _N
				noi di in gr `"(n() set to "' `n' `")"'
			}
		}
	}


	quietly summ `ix' [`weight'`exp'] if `use', detail
	local ixmean = r(mean)
	local ixsig = r(Var)
	local ixsd = r(sd)

	tempname wwidth
	scalar `wwidth' = `width'
	if `wwidth' <= 0.0 {
		scalar `wwidth' = min( sqrt(r(Var)), (r(p75)-r(p25))/1.349)
		scalar `wwidth' = 0.9*`wwidth'/(r(N)^.20)
	}

	tempname delta wid
	scalar `delta' = (r(max)-r(min)+2*`wwidth')/(`n'-1)
	scalar `wid'   = r(N) * `wwidth'

	if `"`at'"' == `""' {
		qui replace `m' = r(min)-`wwidth'+(_n-1)*`delta' in 1/`n'
	}

    if (`stdbands')>0 {
      loc nbands = `stdbands'
      loc nbands "stdbands(`nbands')"
      }

	tempvar tmpd tmplambda tmph
	if "`adaptive'"=="" {
	  ** 2010-11-18: replace gauss epan epan2 by kernel
		di as text "Two-stage adaptive kernel density estimation"
		di as text "Step 1: Pilot density and local bandwidth factors estimation"
		qui akdensity0 `ix' [`weight'`exp'] if `use' , at(`m') generate(`tmpd') /*
		   */ width(`wwidth') lambda(`tmplambda') double  `kernel'
		qui gen double `tmph' = (`wwidth')*(`tmplambda')
		di as text "Step 2: Adaptive kernel density estimation"
		qui akdensity0 `ix' [`weight'`exp'] if `use' , at(`m') generate(`d') /*
		   */ width(`tmph') `nbands' double   `kernel' `cdfopt'
        }
	else {
		di as text "Standard kernel density estimation"
		qui akdensity0 `ix' [`weight'`exp'] if `use' , at(`m') generate(`d') /*
		   */ width(`wwidth') double `nbands'   `kernel' `cdfopt'   
        }

	label var `d' `"`yl'"'
	label var `m' `"`ixl'"'

    if (`stdbands')>0 {
      	label var `d'_up `"Variability bands upper limit"'
      	label var `d'_lo `"Variability bands lower limit"'
        loc varbands "`d'_up `d'_lo"
        }

	qui summ `d' in 1/`n', meanonly
	local scale = 1/(`n'*r(mean))

	if `"`density'"' != `""' {
		qui replace `d' = `d'*`scale' in 1/`n'
	}

    tempname tmp1 tmp2 tmp3

   	if _caller() < 8 {
      version 7.0
	  if `"`graph'"'==`""' {
		if `"`symbol'"'  == `""' {local symbol `"o"'}
		if `"`connect'"' == `""' {local connect `"l"' }
		if `"`title'"'   == `""' {
			local title `"Kernel Density Estimate"'
		}
		if `"`normal'"' != `""' {
			tempvar znorm
			scalar `tmp1' = 1/sqrt(2*_pi*`ixsig')
			scalar `tmp2' = -0.5/`ixsig'
			qui gen `znorm' = `tmp1'*exp(`tmp2'*(`m'-`ixmean')^2)
			local symbol `"`symbol'i"'
			local connect `"`connect'l"'
			if `"`density'"' != `""' {
				tempvar fz
				qui gen `fz' = sum(`znorm')
				qui replace `znorm' = `znorm'/`fz'[_N]
			}
		}
		if `student' > 0 {
			tempvar tm
			scalar `tmp1' = exp(lngamma((`student'+1)/2)) /*
                                */ / exp(lngamma(`student'/2)) /*
                                */ * 1/sqrt(`student'*_pi)
			scalar `tmp2' = (`student'+1)/2
			scalar `tmp3' = sqrt(`ixsig')
			qui gen `tm' = `tmp1' * 1/((1+((`m'-`ixmean') /*
				*/ / `tmp3' )^2/`student')^`tmp2')
			local symbol `"`symbol'i"'
			local connect `"`connect'l"'
			tempvar ft
			qui gen `ft' = sum(`tm')
			if `"`density'"' != `""' {
				qui replace `tm' = `tm'/`ft'[_N]
			}
			else {
				qui replace `tm' = `tm'/`ft'[_N]/`scale'
			}
		}
      graph `d' `znorm' `tm' `varbands' `m', s(`symbol'ii) c(`connect'l[-]l[-]) /*
		*/ title(`"`title'"') `options'
	   }
    }
    else {
      version 8.0
      if `"`graph'"'==`""' {
		if `"`normal'"' != "" | `student' > 0 {
			sum `m', mean
			if `"`normal'"' != `""' {
				local Ngraph				///
				(function normden(x,`ixmean',`ixsd'),	///
					range(`r(min)' `r(max)')	///
					yvarlabel("Normal density")	///
					`normopts'			///
				)
			}
		    if `student' > 0 {
				local Tgraph				///
				(function				///
					tden = 				///
					tden(`student',			///
						(x-`ixmean')/`ixsd'	///
					)/`ixsd'			///
				,					///
					range(`r(min)' `r(max)')	///
					yvarlabel(			///
				`"t density, df = `student'"'		///
					)				///
					`stopts'			///
				)
			}
		}

		if (`stdbands')>0 {
		  local BNDSgraph				///
		    (line `d'_up `m',					///
			 ytitle(`"Density (with `stdbands'*S.E. bands)"')			///
		     )						///
		    (line `d'_lo `m')
          }

		graph twoway					///
		(line `d' `m',					///
			ytitle(`"Density"')			///
			xtitle(`"`ixl'"')			///
			legend(cols(1))				///
			`options'				///
		)						///
		`BNDSgraph'					///
		`Ngraph'					///
		`Tgraph'					///
		|| `plot'  || `addplot'				///
		// blank
	  }
    }

   version 7.0

	/* double save in S_# and r() */
	ret clear
	ret local kernel `"`kernel'"'
	ret scalar width = `wwidth'
	ret scalar n = `n'           /* (sic) */
	ret scalar scale = `scale'
	ret scalar stdband = `stdbands'

	global S_1   `"`kernel'"'
	global S_3 = `wwidth'
	global S_2 = `n'
	global S_4 = `scale'
	global S_5 = `stdbands'

   if `nsave' == 1 {
		label var `d' `"density: `ixl'"'
		rename `d' `yl'
	}
	else if `nsave' == 2 {
		label var `m' `"`ixl'"'
		label var `d' `"density: `ixl'"'
		rename `d' `yl'
		rename `m' `xl'
	}

	if ("`cdf'" != "") {
		lab var `cdf' `"smooth cdf: `ixl'"'
	}
	
   if (inlist(`nsave',1,2)) & (`stdbands'>0) {
       	label var `d'_up `"density: `ixl' (variability bands upper limit)"'
       	label var `d'_lo `"density: `ixl' (variability bands lower limit)"'
		rename `d'_lo `yl'_lo
		rename `d'_up `yl'_up
		if ("`cdf'" != "") {
	       	label var `cdf'_up `"smooth cdf: `ixl' (variability bands upper limit)"'
   	    	label var `cdf'_lo `"smooth cdf: `ixl' (variability bands lower limit)"'
			}
       	}

	if "`at'" != "" {
		sort `srtlist' `obssrt'
	}
end
** added 2011-11-18 (to update to Stata 11 -kernel()- option)
** copied from kdensity.ado with adjustment to allow only epan epan2 gauss
// parsing facility to retrieve kernel name
program _get_kernel_name, sclass
	syntax , KERNEL(string)
	local kernlist epan2 epanechnikov gaussian 
	local maxabbrev 5 2 3
	tokenize `maxabbrev'
	local i = 1
	foreach kern of local kernlist {
		if substr("`kern'",1,length(`"`kernel'"')) == `"`kernel'"' ///
					     & length(`"`kernel'"') >= ``i'' {
			sreturn local kernel `kern'
			continue, break
		}
		else {
			sreturn local kernel
		}
		local ++i
	}
end

