*! NJC 2.0.1 6 May 2004 
* NJC 2.0.0 30 March 2004 
* NJC 1.3.0 15 December 1998
* NJC 1.2.2 23 October 1996
* correlation for circular data
program circcorr, rclass 
        version 8.0
        syntax varlist(min=2 max=2) [if] [in]
	
        marksample touse

        qui {
		count if `touse' 
		if r(N) == 0 error 2000
		else local N = r(N)

	        tempvar y x cc ss cs sc c2x s2x c2y s2y
        	tempname A B C D E F G H corr ymean ystr xmean xstr
	        tempname a2y a2x b2y b2x uy ux vy vx Z PvalNZ PvalZ

		tokenize `varlist' 
                gen `y' = `1' * _pi / 180 if `touse'
                gen `x' = `2' * _pi / 180 if `touse'
                gen `cc' = cos(`y') * cos(`x')
                su `cc', meanonly
                scalar `A' = r(sum)
                gen `ss' = sin(`y') * sin(`x')
                su `ss', meanonly
                scalar `B' = r(sum)
                gen `cs' = cos(`y') * sin(`x')
                su `cs', meanonly
                scalar `C' = r(sum)
                gen `sc' = sin(`y') * cos(`x')
                su `sc', meanonly
                scalar `D' = r(sum)
                gen `c2x' = cos(2 * `x')
                su `c2x', meanonly
                scalar `E' = r(sum)
                gen `s2x' = sin(2 * `x')
                su `s2x', meanonly
                scalar `F' = r(sum)
                gen `c2y' = cos(2 * `y')
                su `c2y', meanonly
                scalar `G' = r(sum)
                gen `s2y' = sin(2 * `y')
                su `s2y', meanonly
                scalar `H' = r(sum)
		
                scalar `corr' = 4 * (`A' * `B' - `C' * `D') ///
                	/ sqrt((`N'^2 - `E'^2 - `F'^2) * (`N'^2 - `G'^2 - `H'^2))

                circsummarize `y'
                scalar `ymean' = r(vecmean) * _pi / 180
                scalar `ystr' = r(vecstr) 
                circsummarize `x'
                scalar `xmean' = r(vecmean) * _pi / 180
                scalar `xstr' = r(vecstr) 
		
                replace `c2y' = cos(2 * (`y' - `ymean'))
                su `c2y', meanonly
                scalar `a2y' = r(mean)
                replace `c2x' = cos(2 * (`x' - `xmean'))
                su `c2x', meanonly
                scalar `a2x' = r(mean)
                replace `s2y' = sin(2 * (`y' - `ymean'))
                su `s2y', meanonly
                scalar `b2y' = r(mean)
                replace `s2x' = sin(2 * (`x' - `xmean'))
                su `s2x', meanonly
                scalar `b2x' = r(mean)
                scalar `uy' = (1 - `a2y'^2 - `b2y'^2)/2
                scalar `ux' = (1 - `a2x'^2 - `b2x'^2)/2
                scalar `vy' = `ystr'^2 * (1 - `a2y')
                scalar `vx' = `xstr'^2 * (1 - `a2x')
                // the formula for Z on p.152 of Fisher 1993 is wrong 
                scalar `Z' = sqrt(`N' * `uy' * `ux') * `corr' / sqrt(`vx' * `vy')
                scalar `PvalNZ' = 2 * (1 - normprob(abs(`Z')))
                scalar `PvalZ' = exp(-(abs(`N' * `corr')))
        }

        di _n as txt "Number of data{space 20}" as res %9.0f `N'
        di as txt    "Correlation   {space 20}" as res %9.3f `corr'
        di _n as txt "P-value (2-tailed)"
        di as txt    "    if vector strengths non-zero  " as res %9.3f `PvalNZ'
        di as txt    "    if either vector strength zero" as res %9.3f `PvalZ'

        return scalar N = `N'
        return scalar corr = `corr'
        return scalar Z = `Z'
        return scalar PNZ = `PvalNZ'
        return scalar PZ = `PvalZ'
end
