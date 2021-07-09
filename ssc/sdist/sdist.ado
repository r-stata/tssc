***Script for illustrating Central Limit Theorem***

***
//AUTHOR: Marshall A. Taylor
//DATE: January 14, 2018
//NOTE: The goal is to show that the standard error estimated
	//from a single random variable is nearly equivalent to
	//the standard deviation of an empirically-derived sampling
	//distribution, regardless of how the random variable is
	//distributed. Good tutorial for illustrating how the 
	//denominator in the s.e. equation--sqrt(n)--work in
	//practice.
***

program define sdist
version 13.1
preserve

syntax , [samples(real 200) obs(real 500) type(string) par1(real 0) ///
	par2(real 1) round(real 0.001) histplot saveplot1(string) saveplot2(string) ///
	combine repplot lcolor(string) fcolor(string) ///
	bckg(string) nlcolor(string) nlwidth(real .5) nlpattern(string) dots]

qui {

describe
if r(changed)!=0 | r(k)!=0 | r(N)!=0 {
	display as error "Save and/or clear existing data before running -sdist-."
	exit 4
	}

if "`lcolor'"=="" {
	local lcolor "black"
	}
if "`nlcolor'"=="" {
	local nlcolor "black" 
	}
if "`fcolor'"=="" {
	local fcolor "gs6" 
	}
if "`bckg'"=="" {
	local bckg "white" 
	}
if "`nlpatterb'"=="" {
	local nlpattern "solid"
	}

if "`dots'"!="" {
nois _dots 0, title(Preparing for simulation) reps(`samples')
forvalues k = 1/`samples' { //Generate empty variables. Increasing this will
	gen var`k'=.          //result in a more normal sampling distribution.
	nois _dots `k' 0	//Just be sure to adjust var* text in loops below.
	}
}

if "`dots'"=="" {
forvalues k = 1/`samples' {
	gen var`k'=.
	}
}	
	
if "`type'"=="" local type "`par1'+(`par2'-`par1')*runiform()" //default
if "`type'"=="uniform" local type "`par1'+(`par2'-`par1')*runiform()"
if "`type'"=="normal" local type "rnormal(`par1',`par2')"
if "`type'"=="poisson" local type "rpoisson(`par2')"

if "`dots'"!="" {
nois _dots 0, title(Creating `samples' random samples with `obs' observations) ///
	reps(`samples')
foreach i of varlist var1-var`samples' { //Use K (above) to generate K random variables
	set obs `obs'                        //from a distribution w/ n each.
	gen `i'_r = `type'
	sum `i'_r
	gen `i'_mean=r(mean)
	nois _dots `i' 0
	}
}

if "`dots'"=="" {
foreach i of varlist var1-var`samples' { 
	set obs `obs'                        
	gen `i'_r = `type'
	sum `i'_r
	gen `i'_mean=r(mean)
	}
}

if "`dots'"!="" {
nois _dots 0, title(Creating dataset of random samples) reps(`samples')
foreach m of varlist var1-var`samples' { //Drop empty variables used to set random
    nois _dots `m' 0                    //random variables.
	drop `m'
	} 
}

if "`dots'"=="" {
foreach m of varlist var1-var`samples' {
	drop `m'
	}
}

rename var1_r x //Save one set of sample estimates for later comparison to the
drop *_r       //empirically-derived sampling distribution.
xpose, clear varname

local a=`samples'+1

sum v1 in 2/`a' //Getting empirically-derived mean and standard deviation of
local sa_mean=round(r(mean),`round') //the sampling distribution.
local sa_sd=round(r(sd),`round')

if "`saveplot1'"!="" {
if "`repplot'"!="" {
if "`histplot'"!="" {
	hist v1 in 2/`a', freq normal fcolor(`fcolor') lcolor(`lcolor') ///
		normopts(lcolor(`nlcolor') lwidth(`nlwidth') lpattern(`nlpattern')) ///
		xtitle("Empirical Sampling Distribution of `samples' X-bars" ///
		"{&mu}{sub:x-bar} = `sa_mean'; {&sigma}{sub:X-bar} = `sa_sd'") ///
		graphregion(fcolor(`bckg')) saving(`saveplot1', replace) name(plot1, replace)
				}
			}
		}

if "`saveplot1'"=="" {
if "`repplot'"!="" {
if "`saveplot2'"=="" {
if "`histplot'"!="" {
	hist v1 in 2/`a', freq normal fcolor(`fcolor') lcolor(`lcolor') ///
		normopts(lcolor(`nlcolor') lwidth(`nlwidth') lpattern(`nlpattern')) ///
		xtitle("Empirical Sampling Distribution of `samples' X-bars" ///
		"{&mu}{sub:x-bar} = `sa_mean'; {&sigma}{sub:X-bar} = `sa_sd'") ///
		graphregion(fcolor(`bckg')) saving(plot1.gph, replace) name(plot1, replace)
					}
				}
			}
		}
		
if "`saveplot1'"=="" {
if "`repplot'"!="" {
if "`saveplot2'"!="" {
if "`histplot'"!="" {
	hist v1 in 2/`a', freq normal fcolor(`fcolor') lcolor(`lcolor') ///
		normopts(lcolor(`nlcolor') lwidth(`nlwidth') lpattern(`nlpattern')) ///
		xtitle("Empirical Sampling Distribution of `samples' X-bars" ///
		"{&mu}{sub:x-bar} = `sa_mean'; {&sigma}{sub:X-bar} = `sa_sd'") ///
		graphregion(fcolor(`bckg')) name(plot1, replace)
					}
				}
			}
		}
		
if "`saveplot1'"=="" {
if "`repplot'"=="" {
if "`histplot'"!="" {
	hist v1 in 2/`a', freq normal fcolor(`fcolor') lcolor(`lcolor') ///
		normopts(lcolor(`nlcolor') lwidth(`nlwidth') lpattern(`nlpattern')) ///
		xtitle("Empirical Sampling Distribution of `samples' X-bars" ///
		"{&mu}{sub:x-bar} = `sa_mean'; {&sigma}{sub:X-bar} = `sa_sd'") ///
		graphregion(fcolor(`bckg')) name(plot1, replace)
				}
			}
		}
	
if "`saveplot1'"!="" {
if "`repplot'"=="" {
if "`histplot'"!="" {
	hist v1 in 2/`a', freq normal fcolor(`fcolor') lcolor(`lcolor') ///
		normopts(lcolor(`nlcolor') lwidth(`nlwidth') lpattern(`nlpattern')) ///
		xtitle("Empirical Sampling Distribution of `samples' X-bars" ///
		"{&mu}{sub:x-bar} = `sa_mean'; {&sigma}{sub:X-bar} = `sa_sd'") ///
		graphregion(fcolor(`bckg')) saving(`saveplot1') name(plot1, replace)
				}
			}
		}

xpose, clear varname

ci x //Getting standard error estimate from a single sample.
local x_se=round(r(se),`round')
sum x
local x_mean=round(r(mean),`round')
local x_sd=round(r(sd),`round')

local diff = round(abs(`sa_sd'-`x_se'),`round')

if "`saveplot2'"!="" {
if "`repplot'"!="" {
if "`histplot'"!="" { 
	hist x, freq normal fcolor(`fcolor') lcolor(`lcolor') ///
		normopts(lcolor(`nlcolor') lwidth(`nlwidth') lpattern(`nlpattern')) ///
		xtitle("Distribution of a Single X" ///
		"X-bar = `x_mean'; {it:s} = `x_sd'; se{sub:X-bar} = `x_se'") ///
		graphregion(fcolor(`bckg')) saving(`saveplot2', replace) name(plot2, replace)
				}
			}
		}

if "`saveplot2'"=="" {
if "`repplot'"!="" {
if "`saveplot1'"=="" {
if "`histplot'"!="" {
	hist x, freq normal fcolor(`fcolor') lcolor(`lcolor') ///
		normopts(lcolor(`nlcolor') lwidth(`nlwidth') lpattern(`nlpattern')) ///
		xtitle("Distribution of a Single X" ///
		"X-bar = `x_mean'; {it:s} = `x_sd'; se{sub:X-bar} = `x_se'") ///
		graphregion(fcolor(`bckg')) saving(plot2.gph, replace) name(plot2, replace)
					}		
				}
			}
		}
		
if "`saveplot2'"=="" {
if "`repplot'"!="" {
if "`saveplot1'"!="" {
if "`histplot'"!="" {
	hist x, freq normal fcolor(`fcolor') lcolor(`lcolor') ///
		normopts(lcolor(`nlcolor') lwidth(`nlwidth') lpattern(`nlpattern')) ///
		xtitle("Distribution of a Single X" ///
		"X-bar = `x_mean'; {it:s} = `x_sd'; se{sub:X-bar} = `x_se'") ///
		graphregion(fcolor(`bckg')) name(plot2, replace)
					}		
				}
			}
		}
		
if "`saveplot2'"=="" {
if "`repplot'"=="" {
if "`histplot'"!="" {
	hist x, freq normal fcolor(`fcolor') lcolor(`lcolor') ///
		normopts(lcolor(`nlcolor') lwidth(`nlwidth') lpattern(`nlpattern')) ///
		xtitle("Distribution of a Single X" ///
		"X-bar = `x_mean'; {it:s} = `x_sd'; se{sub:X-bar} = `x_se'") ///
		graphregion(fcolor(`bckg')) name(plot2, replace)
				}		
			}
		}	

if "`saveplot2'"!="" {
if "`repplot'"=="" {
if "`histplot'"!="" {
	hist x, freq normal fcolor(`fcolor') lcolor(`lcolor') ///
		normopts(lcolor(`nlcolor') lwidth(`nlwidth') lpattern(`nlpattern')) ///
		xtitle("Distribution of a Single X" ///
		"X-bar = `x_mean'; {it:s} = `x_sd'; se{sub:X-bar} = `x_se'") ///
		graphregion(fcolor(`bckg')) saving(`saveplot2') name(plot2, replace)
				}		
			}
		}	
	
mat S = J(3,1,.)
mat S[1,1] = `sa_sd'
mat S[2,1] = `x_se'
mat S[3,1] = `diff'
mat rownames S = sig_Xb se_Xb abs(diff)
mat colnames S = sd/se
noisily: matlist(S)  
noisily: disp ""               
noisily: disp "The difference between sig_Xb and se_Xb is `diff'. The larger"
noisily: disp "this difference, the poorer the single X variable standard error approximates"
noisily: disp "the standard deviation of the sampling distribution. This may be due to one"
noisily: disp "of two things: a small number of samples and/or a small sample size."

if "`combine'"!="" {
if "`saveplot1'"!="" & "`saveplot2'"!="" {
gr combine `saveplot1' `saveplot2' , ///
	col(1) imargin(0 0 0 0) graphregion(margin(l=22 r=22) fcolor(white))
		}
	}

if "`combine'"!="" {
if "`repplot'"!="" {
if "`saveplot1'"=="" & "`saveplot2'"=="" {
gr combine plot1.gph plot2.gph, ///
	col(1) imargin(0 0 0 0) graphregion(margin(l=22 r=22) fcolor(white)) 
			}
		}
	}

if "`combine'"!="" {
if "`saveplot1'"!="" & "`saveplot2'"=="" {
gr combine `saveplot1' plot2.gph, ///
	col(1) imargin(0 0 0 0) graphregion(margin(l=22 r=22) fcolor(white)) 
		}
	}	

if "`combine'"!="" {
if "`saveplot1'"=="" & "`saveplot2'"!="" {
gr combine plot1.gph `saveplot2' , ///
	col(1) imargin(0 0 0 0) graphregion(margin(l=22 r=22) fcolor(white)) 
		}
	}	

if "`combine'"!="" {
if "`histplot'"!="" {
if "`saveplot1'"=="" & "`saveplot2'"=="" & "`repplot'"=="" {
	disp as error "Need to save plots before combining them."
	exit 302
			}
		}
	}

if "`combine'"!="" {
if "`histplot'"=="" {
	disp as error "No plots were created to combine. Specify -histplot-."
	exit 302
		}
	}
	
clear	
}
end
