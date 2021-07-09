*! 1.2.0 NJC 2sep2015 
* 1.1.0 NJC 27aug2015 
* 1.0.0 NJC 20jul2015 
* ipolate 1.3.3  21sep2004
program mipolate, byable(onecall) sort
	version 12          
	syntax varlist(min=2 max=2 numeric) [if] [in], /// 
	GENerate(string) ///
	[ BY(varlist)    /// 
	Epolate          /// 
	Linear           ///
	Cubic            /// 
	Spline           ///
	Idw              /// 
	Idw2(numlist min=1 max=1 >=0)     /// 
	Pchip            ///
	Forward          ///
	Backward         ///
	Nearest          ///  
	Groupwise        /// 
	ties(str) ]

	// syntax checks 
	if _by() {
		if "`by'" != "" {
			di as err /*
			*/ "option by() may not be combined with by prefix"
			exit 190
		}
		local by "`_byvars'"
	}

	if "`ties'" != "" & "`nearest'" == "" { 
		di as err "ties() applies only with nearest" 
		exit 198 
	}

	// ties(): 
	// indulge upper case: 
	// any abbreviations of after, before, minimum, maximum 
	if "`ties'" != "" { 
		local ties = lower("`ties'") 
		local nchar = length("`ties'") 
		local OK = 0 

		if "`ties'" == substr("after", 1, `nchar') { 
			local ties "after" 
			local OK 1 
		} 
		else if "`ties'" == substr("before", 1, `nchar') { 
			local ties "before" 
			local OK 1 
		}
		else if `nchar' == 1 & "`ties'" == "m" { 
			di as err "m ambiguous for ties() option" 
			exit 198
		}
		else if "`ties'" == substr("minimum", 1, `nchar') { 
			local ties "min" 
			local OK 1 
		}
		else if "`ties'" == substr("maximum", 1, `nchar') { 
			local ties "max" 
			local OK 1 
		}

		if !`OK' { 
			di as err "invalid ties() option: see help" 
			exit 198 
		}
	}

	if "`idw2'" != "" local idw "idw" 

	local nopts : word count ///
	`cubic' `spline' `pchip' `idw' `nearest' `linear' ///
	`forward' `backward' `groupwise' 

	if `nopts' > 1 {
		di as err "must specify one interpolation method only" 
	}
	else if `nopts' == 0 local linear "linear" 

	confirm new var `generate'
	tokenize `varlist'
	args usery x 

	local flag = 0 

	quietly {
		tempvar y 
		marksample touse, novarlist 
		replace `touse' = 0 if `x' >= .
		count if `touse' 
		if r(N) == 0 error 2000 

		bysort `touse' `by' `x': /// 
			gen double `y' = sum(`usery') / sum(`usery' < .) if `touse'
		by `touse' `by' `x': replace `y' = `y'[_N]
 
		if "`linear'" != "" { 
			tempvar negy negx xhi yhi xlo ylo m b z 

			gen double `negx' = -`x'
			gen double `negy' = -`y'
			sort `touse' `by' `negx' `negy'
			gen double `xhi' = `x' if `touse'
			gen double `yhi' = `y' if `touse'
			by `touse' `by': replace `yhi' = `yhi'[_n-1] if `y' >= . & `touse'
			by `touse' `by': replace `xhi' = `xhi'[_n-1] if `y' >= . & `touse'

			sort `touse' `by' `x' `y'
			gen double `xlo' = `x' if `touse'
			gen double `ylo' = `y' if `touse'
			by `touse' `by': replace `ylo' = `ylo'[_n-1] if `y' >= . & `touse'
			by `touse' `by': replace `xlo' = `xlo'[_n-1] if `y' >= . & `touse'
			gen double `m' = (`yhi'-`ylo')/(`xhi'-`xlo')
			drop `yhi' `xhi'
			gen double `b' = `ylo' - `m'*`xlo' 
			drop `ylo' `xlo' `negx' `negy'
			gen double `z' = `y' if `touse'
			replace `z' = `m'*`x' + `b' if `touse' & `z' >= .
		}

		else if "`cubic'" != "" { 
			tempvar negx negy ok ok2 x1 x2 x3 x4 y1 y2 y3 y4 m m1 m2 m3 m4 z 
	
			* following values 
			gen double `negx' = -`x'
			gen double `negy' = -`y'

			bysort `touse' `by' (`negx' `negy') : gen `ok' = _n * (`y' < .) 
			by `touse' `by' : replace `ok' = `ok'[_n-1] if !`ok'
			by `touse' `by' : gen `ok2' = `ok'[_n-1] * (`ok' > `ok'[_n-1]) 
			by `touse' `by' : replace `ok2' = `ok2'[_n-1] if !`ok2' 
	
			by `touse' `by' : gen double `x4' = `x'[`ok2'] 
			by `touse' `by' : gen double `y4' = `y'[`ok2'] 
			by `touse' `by' : gen double `x3' = `x'[`ok']
			by `touse' `by' : gen double `y3' = `y'[`ok']

			* preceding values
			bysort `touse' `by' (`x' `y'): replace `ok' = _n * (`y' < .) 
			by `touse' `by' : replace `ok' = `ok'[_n-1] if !`ok'
			by `touse' `by' : replace `ok2' = `ok'[_n-1] * (`ok' > `ok'[_n-1]) 
			by `touse' `by' : replace `ok2' = `ok2'[_n-1] if !`ok2' 

			by `touse' `by' : gen double `x1' = `x'[`ok2'] 
			by `touse' `by' : gen double `y1' = `y'[`ok2'] 
			by `touse' `by' : gen double `x2' = `x'[`ok']
			by `touse' `by' : gen double `y2' = `y'[`ok']

			gen double `m1' = (`x' - `x2') * (`x' - `x3') * (`x' - `x4') /* 
			*/ / ((`x1' - `x2') * (`x1' - `x3') * (`x1' - `x4'))
			gen double `m2' = (`x' - `x1') * (`x' - `x3') * (`x' - `x4') /* 
			*/ / ((`x2' - `x1') * (`x2' - `x3') * (`x2' - `x4'))
			gen double `m3' = (`x' - `x1') * (`x' - `x2') * (`x' - `x4') /* 
			*/ / ((`x3' - `x1') * (`x3' - `x2') * (`x3' - `x4')) 
			gen double `m4' = (`x' - `x1') * (`x' - `x2') * (`x' - `x3') /* 
			*/ / ((`x4' - `x1') * (`x4' - `x2') * (`x4' - `x3')) 
			gen double `m' = /* 
			*/ `m1' * `y1' + `m2' * `y2' + `m3' * `y3' + `m4' * `y4'
		
			gen double `z' = `y' if `touse'
			replace `z' = `m' if `touse' & `z' == .
		}

		else if "`nearest'" != "" { 
			tempvar negx prevy prevx nexty nextx z 
	
			* values before 
			gen double `prevy' = `y' if `touse' & `y' < .   
			gen double `prevx' = `x' if `touse' & `y' < . 
			gen double `nexty' = `prevy' 
			gen double `nextx' = `prevx' 

			bysort `touse' `by' (`x'): replace `prevy' = `prevy'[_n - 1] if `prevy' == .  
			by `touse' `by': replace `prevx' = `prevx'[_n - 1] if `prevx' == .  

			* values after
			gen double `negx' = -`x'
			bysort `touse' `by' (`negx') : replace `nexty' = `nexty'[_n - 1] if `nexty' == .  
			by `touse' `by' : replace `nextx' = `nextx'[_n - 1] if `nextx' == . 
	
			* interpolation 
			gen double `z' = `y' if `touse' 
			replace `z' = `nexty' if (`nextx' - `x') < (`x' - `prevx') & `z' == . & `touse' 
			replace `z' = `prevy' if (`x' - `prevx') < (`nextx' - `x') & `z' == . & `touse' 

			if "`ties'" != "" { 
				if "`ties'" == "after" { 
					replace `z' = `nexty' if (`nextx' - `x') == (`x' - `prevx') & `z' == . & `touse' 
				} 
				else if "`ties'" == "before" {
					replace `z' = `prevy' if (`nextx' - `x') == (`x' - `prevx') & `z' == . & `touse' 
				}
				else if "`ties'" == "min" {
					replace `z' = min(`nexty', `prevy') if (`nextx' - `x') == (`x' - `prevx') & `z' == . & `touse' 
				}
				else if "`ties'" == "max" {
					replace `z' = max(`nexty', `prevy') if (`nextx' - `x') == (`x' - `prevx') & `z' == . & `touse' 
				}
			}
			else replace `z' = (`nexty' + `prevy')/2 if (`nextx' - `x') == (`x' - `prevx') & `z' == . & `touse' 

			local epolate 
		}

		else if "`spline'" != "" { 
			tempvar group z guse zmiss negy negx 

			// only use one of any repeated x 
			by `touse' `by' `x': gen byte `guse' = `touse' & (_n == 1)

			sort `guse' `by' `x' 
	
			if "`by'" != "" { 
				bysort `guse' `by': gen byte `group' = _n == 1 & `guse' 
				by `guse': replace `group' = sum(`group') 
			} 
			else gen byte `group' = 1 

			su `group', meanonly 
			local ng = r(max) 
			gen double `z' = `y' if `touse'
			gen byte `zmiss' = 0 

			forval g = 1/`ng' { 
				replace `guse' = `group' == `g' 
				replace `zmiss' = `guse' & missing(`z') 
				count if `zmiss' 
				if r(N) > 1 { 
				mata : csipolate("`y'", "`x'", "`guse'", "`z'", "`zmiss'") 
				}
			} 
	
			// copy interpolated y to repeated x 	
			bysort `touse' `by' `x' (`z') : ///
			replace `z' = `z'[1] if `touse' & `z' == .  
		
		}

		else if "`pchip'" != "" { 
			tempvar group z guse zmiss 
	
			// only use one of any repeated x 
			by `touse' `by' `x': gen byte `guse' = `touse' & (_n == 1)

			sort `guse' `by' `x' 

			if "`by'" != "" { 
				by `guse' `by': gen byte `group' = _n == 1 & `guse' 
				by `guse': replace `group' = sum(`group') 
			} 
			else gen byte `group' = 1 

			su `group', meanonly 
			local ng = r(max) 
			gen double `z' = `y' if `touse'
			gen byte `zmiss' = 0 

			forval g = 1/`ng' { 
				replace `guse' = `group' == `g' 
				replace `zmiss' = `guse' & missing(`z') 
				count if `guse' & !missing(`z') 

				if r(N) > 2 { 
					mata : ///
					pchipolate("`y'", "`x'", "`guse'", "`z'", "`zmiss'") 
				}
				else local flag = 1 
			} 
	
			// copy interpolated y to repeated x 	
			bysort `touse' `by' `x' (`z') : ///
			replace `z' = `z'[1] if `touse' & `z' == .  

			local epolate 
		}

		else if "`idw'`idw2'" != "" { 
			tempvar group z guse zmiss  

			// only use one of any repeated x 
			by `touse' `by' `x': gen byte `guse' = `touse' & (_n == 1)

			sort `guse' `by' `x' 
	
			if "`by'" != "" { 
				bysort `guse' `by': gen byte `group' = _n == 1 & `guse' 
				by `guse': replace `group' = sum(`group') 
			} 
			else gen byte `group' = 1 

			su `group', meanonly 
			local ng = r(max) 
			gen double `z' = `y' if `touse'
			gen byte `zmiss' = 0 
			if "`idw2'" == "" local idw2 = 2 

			forval g = 1/`ng' { 
				replace `guse' = `group' == `g' 
				replace `zmiss' = `guse' & missing(`z') 
				count if `zmiss' 
				mata : idwipolate("`y'", "`x'", "`guse'", "`z'", "`zmiss'", `idw2') 
			} 
	
			// copy interpolated y to repeated x 	
			bysort `touse' `by' `x' (`z') : ///
			replace `z' = `z'[1] if `touse' & `z' == .  

			local epolate 
		}		
		
		else if "`forward'`backward'" != "" { 
			tempvar z 
			gen double `z' = `y' 

			if "`forward'" != "" { 
				bysort `touse' `by' (`x') : ///
				replace `z' = `z'[_n-1] if `touse' & `z' == . 
			}
			else { 
				tempvar negx 
				gen double `negx' = -`x' 
				bysort `touse' `by' (`negx'): /// 
				replace `z' = `z'[_n-1] if `touse' & `z' == . 
			}

			local epolate 
		}

		else if "`groupwise'" != "" { 
			tempvar z OK  

			bysort `touse' `by' (`y') : ///
			gen byte `OK' = (`y' == `y'[1]) | missing(`y')  
			count if `touse' & !`OK' 

			if r(N) { 
				if "`by'" != "" local text "within groups" 
				di as err ///
			"different non-missing values of `usery' `text'"
				exit 498 
			}

			gen double `z' = `y'  
			by `touse' `by': ///
			replace `z' = `z'[1] if missing(`z') & `touse'  

			local epolate 
		} 

		if `"`epolate'"' != "" {
			sort `touse' `by' `x' `z' /* already sorted */
			tempvar m b M B ismiss 
			by `touse' `by': gen double /*
			*/ `m' = (`z'[_n+1] - `z')/(`x'[_n+1] - `x')
			gen double `b' = `z' - `m'*`x'
			gen double `M' = `m' 
			gen double `B' = `b'
			by `touse' `by': replace `m' = `m'[_n-1] if `m'[_n-1]< .
			by `touse' `by': replace `b' = `b'[_n-1] if `b'[_n-1]< .
			gen byte `ismiss' = `z' >= .
			by `touse' `by': replace `ismiss' = 0 /*
				*/ if _n>1 & `ismiss'[_n-1]==0
			by `touse' `by': replace `z' = `m'[_N]*`x' + `b'[_N] /*
					*/ if `touse' & `ismiss'
			drop `ismiss' `m' `b'
			gen double `negx' = -`x'
			gen double `negy' = -`z'
			sort `touse' `by' `negx' `negy'
			by `touse' `by': replace `M' = `M'[_n-1] if `M'[_n-1] < .
			by `touse' `by': replace `B' = `B'[_n-1] if `B'[_n-1] < .
			gen byte `ismiss' = `z' >= .
			by `touse' `by': replace `ismiss' = 0 /*
				*/ if _n>1 & `ismiss'[_n-1] == 0
			by `touse' `by': replace `z' = `M'[_N]*`x' + `B'[_N] /*
					*/ if `touse' & `ismiss'
		}

		rename `z' `generate'
		compress `generate' 
		count if `generate' >= .
	}

	if `flag' { 
		di as txt "note: at least 3 values needed in any interpolation" 
	} 

	if r(N) > 0 {
		if r(N) != 1 local pl "s" 
		di as txt "(" r(N) `" missing value`pl' generated)"'
	}
end


mata: 

void idwipolate(string scalar yvarname, 
                string scalar xvarname, 
	        string scalar tousename, 
	        string scalar zvarname, 
	        string scalar zmissname,
		real scalar power 
	) { 

real matrix xyvar    
real colvector x, y, where, newz, weight
real scalar i

st_view(xyvar, ., (xvarname, yvarname), tousename) 
x = select(xyvar[,1], (xyvar[,2] :< .)) 
y = select(xyvar[,2], (xyvar[,2] :< .)) 
newz = where = select(xyvar[,1], (xyvar[,2] :== .)) 

for(i = 1; i <= rows(where); i++) { 
	weight = abs(x :- where[i]):^(-power) 
	newz[i] = sum(y :* weight) / sum(weight)
}		
		
st_store(., zvarname, zmissname, newz)   

}

void csipolate(string scalar yvarname, 
               string scalar xvarname, 
	       string scalar tousename, 
	       string scalar zvarname, 
	       string scalar zmissname
	) { 

real matrix xyvar    
real colvector x, y, where 

st_view(xyvar, ., (xvarname, yvarname), tousename) 
x = select(xyvar[,1], (xyvar[,2] :< .)) 
where = select(xyvar[,1], (xyvar[,2] :== .)) 
y = select(xyvar[,2], (xyvar[,2] :< .)) 
st_store(., zvarname, zmissname, spline3eval(spline3(x, y), where))   

}

void pchipolate(string scalar yvarname, 
                string scalar xvarname, 
	        string scalar tousename, 
	        string scalar zvarname, 
	        string scalar zmissname
	) { 

real matrix xyvar    
real colvector x, y, where 

st_view(xyvar, ., (xvarname, yvarname), tousename) 
x = select(xyvar[,1], (xyvar[,2] :< .)) 
where = select(xyvar[,1], (xyvar[,2] :== .)) 
y = select(xyvar[,2], (xyvar[,2] :< .)) 
st_store(., zvarname, zmissname, pchip(x, y, where))   

}

real colvector pchip(real colvector x, real colvector y, real colvector u)
{ 
	real scalar n, nu, k, j
	real colvector h, delta, d, c, b, which, s  

	n = length(x) 
	h = x[2::n] - x[1::n-1] 
	delta = (y[2::n] - y[1::n-1]) :/ h
	d = pchipslopes(h, delta)

	c = (3*delta - 2*d[1::n-1] - d[2::n]) :/ h
	b = (d[1::n-1] - 2*delta + d[2::n]) :/ (h:^2)

	nu = length(u) 
        k = J(nu, 1, 1)
	for (j = 2; j <= n-1; j++) { 
		which = select((1::nu), x[j] :<= u)		
		k[which] = J(length(which), 1, j)
	}

	s = u - x[k]
	return(y[k] + s :* (d[k] + s :* (c[k] + s :* b[k]))) 
}

real colvector function pchipslopes(real colvector h, real colvector delta) {
	real scalar n 
	real colvector d, k, w1, w2
	n = length(h) + 1
	d = J(n, 1, 0)
	k = 1 :+ select((1::n-2), sign(delta[1::n-2]) :* sign(delta[2::n-1]) :> 0) 
	w1 = 2*h[k] + h[k:-1]
	w2 = h[k] + 2*h[k:-1]
	d[k] = (w1 + w2) :/ (w1 :/ delta[k:-1] + w2 :/ delta[k])
	d[1] = pchipend(h[1], h[2], delta[1], delta[2])
	d[n] = pchipend(h[n-1], h[n-2], delta[n-1], delta[n-2])

	return(d)
}

real scalar function pchipend(h1, h2, del1, del2) { 
	real scalar d 
	d = ((2*h1 + h2)*del1 - h1*del2) / (h1 + h2)
	if (sign(d) != sign(del1)) d = 0
        else {
		if (sign(del1) != sign(del2) & (abs(d) > abs(3*del1))) {
			d = 3*del1
		}
	}

	return(d) 	
}

end 
