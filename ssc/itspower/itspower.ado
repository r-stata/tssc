/*Program to estimate power for linear ITS designs with no autocorrelation*/
/*v1.0.0 13 Apr 2018*/
program define itspower, rclass
	/*stata version define*/
	version 14.1
    /*command syntax*/	
    syntax, sn(integer) nuts(integer) lvlmn(real) prepoints(integer) sd(string) corr(string) /* 
	*/ [lvlsd(real 0) clvl(real 95) seed(integer -127) moreon]	
	
	/*INPUTS-model mandatory*/
	//number of simulations
	local simnum=`sn'
	//number of units to be evaluated
	local numuts=`nuts'
	//effect to be identified (ITS level change)
	local lvlmn=`lvlmn'
	if `lvlmn'==0 {
		di as error "Level change cannot be zero"
		error 197
	}
	//number of pre-intervention time points
	local numpts=`prepoints'
	if `numpts'<2 {
		di as error "A minimum of two pre-intervention time-points are required"
		error 197
	}
	
	/*INPUTS-model mandatory => vectors*/
	//correlations
	if "`corr'"=="" {
		di as error "Correlation matrix needs to be provided for each of the `numpts'+1=``numpts'+1' time points"
		error 197
	}
	//SDs
	if "`sd'"=="" {
		di as error "Standard deviation matrix needs to be provided for each of the `numpts'+1=``numpts'+1' time points"
		error 197
	}	
	
	/*INPUTS-general optional*/
	//normaly distributed level change
	if `lvlsd'<0 {
		di as error "lvlsd needs to be positive or zero, since it is a the SD for the level change"
		error 197
	}
	//level
	scalar clvl=`clvl'
	set level `=clvl'
	//seed
	if `seed'!=-127 {
	   set seed `seed'
        }
	//display options
	set more off
	if "`moreon'"!="" {
		set more on
	}

	//string for drawnorm, based on number of time points
	local txtdrnrm = ""
	forvalues i=1(1)`=`numpts'+1' {
		local txtdrnrm = "`txtdrnrm' v`i'" 
	}	
	//counter
	local cntr=0
	//display
	di _newline(2) as text "`numpts' pre-intervention time points. Power to detect a(n) `lvlmn' unit jump due to intervention"
	di "Iterations (50s):"
	//loop
	forvalues i=1(1)`simnum' {
		clear
		qui drawnorm `txtdrnrm', n(`numuts') corr(`corr') sd(`sd')		
		//make changes to mean levels and SD
		qui gen t1=rnormal(`lvlmn',`lvlsd')
		qui replace v`=`numpts'+1'=v`=`numpts'+1'+t1
		qui egen id=seq()
		//reshape long
		qui reshape long v, i(id) j(time)
		rename v outc	
		//regression and prediction
		qui xtset id
		qui xtreg outc time if time<=`numpts'
		qui predict prd if time==`=`numpts'+1', xb
		//compare prediction to observed
		qui gen fvar=outc-prd
		qui ttest fvar==0
		//if positive mean difference and statistically sig 
		if `lvlmn'>0 {
			if r(p)<`=(1-`clvl'/100)' & r(mu_1)>0 {
				local cntr=`cntr'+1
			}
		}
		//if negative mean difference and statistically sig
		else {
			if r(p)<`=(1-`clvl'/100)' & r(mu_1)<0 {
				local cntr=`cntr'+1
			}		
		}
		//display
		if mod(`i',50)==0 {
			di "." _continue
		}
		if mod(`i',2500)==0 {
			di
		}
	}
	local pwrclc = 100*`cntr'/`simnum'
	di _newline(2) as text "%Power: " as result %4.1f `pwrclc'
	local plower = 100*(`pwrclc'/100-invnormal(`=1-(1-`clvl'/100)/2')*sqrt(`pwrclc'/100*(1-`pwrclc'/100)/`simnum'))
	local pupper = 100*(`pwrclc'/100+invnormal(`=1-(1-`clvl'/100)/2')*sqrt(`pwrclc'/100*(1-`pwrclc'/100)/`simnum'))
	di as text "`clvl'%CI: " as result %4.1f `plower' as text " to " as result %4.1f  `pupper'

	/*RETURN SCALARS*/
    return scalar pow = `pwrclc'
    return scalar lpow = `plower'
    return scalar upow = `pupper'	
end
