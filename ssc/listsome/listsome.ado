*! version 1.1.3, 07sep2014, Robert Picard, picard@netbox.com      
program listsome

	version 9
	
	syntax [varlist] [if] [in] , ///
	[ ///
	MAXimum(integer 20) ///
	RANDom ///
	* ]
	
	if _N == 0 error 2000

	if `maximum' <= 0 error 411
	
	if "`random'" != "" {
		tempvar generate
		if `"`if'`in'"' != "" {
			marksample touse, novarlist
			mata: tag_it_touse("`generate'",`maximum', "`touse'")
		}
		else {
			mata: tag_it("`generate'",`maximum')
		}
		list `varlist' if `generate', `options'
	}
	else {
		if `"`if'`in'"' != "" {
			marksample touse, novarlist
			list `varlist' if `touse' & sum(`touse') <= `maximum', `options'
		}
		else {
			list `varlist' if _n <= `maximum', `options'
		}
	}

	
end  


version 9.2
mata:
mata set matastrict on


void tag_it_touse(

	string scalar tagvar,		// name of new variable to generate
	real scalar count, 			// number of draws
	string scalar touse			// varname of sample indicator variable
	
	)
{

	real colvector	///
		insample,	///	touse sample indicator
		iobs,		/// indices of observations in the touse sample
		u1, 		/// primary uniformly distributed random variates
		pick,		/// indicator for picked observations
		isub,		/// indices of obs in subset used to make final picks
		u1sub,		/// subset of u1 used to make final picks
		u2sub,		/// secondary random variates to break ties in u1sub
		ix,			/// indices/x matrix that is sorted for final picks
		ipick		/// indices of final picks.

	real scalar		///
		nobs, 		///	number of observations
		cutoff,		///	a value such that sum(u1 :< cutoff)  ~== count
		highcut,	/// a value such that sum(u1 :< highcut) > count
		lowcut,		/// a value such that sum(u1 :< lowcut)  < count
		nlow,		/// equal to sum(x :< lowcut)
		n			/// stores sum(x :< cutoff) while iterating


	// select obs included in the sample
	insample = st_data(.,touse)
	iobs = select(range(1,st_nobs(),1),insample)
	nobs = length(iobs)
	if (nobs == 0) exit(error(2000))
	
	// roll back the number of draws if > number of observations
	count = (nobs < count ? nobs : count)
	
	// primary uniformly distributed random variate on [0,1)
	u1 = uniform(nobs, 1)
	
	// initial estimate of cutoff needed for sum(u1 :< cutoff) == count
	cutoff = count / nobs

	// refine cutoff by finding high and low cutoff values
	n = sum(u1 :< cutoff)
	if (n > count) {
		highcut = cutoff
		while (n > count) {
			cutoff = cutoff - 1.05 * (n - count) / nobs
			n = sum(u1 :< cutoff)
		}
		lowcut = cutoff
		nlow = n
	}
	else if (n < count) {
		lowcut = cutoff
		nlow = n
		while (n < count) {
			cutoff = cutoff + 1.05 * (count - n) / nobs
			n = sum(u1 :< cutoff)
		}
		highcut = cutoff
	}
	
	pick = J(st_nobs(),1,0)
	
	if (n != count) {
	
		// pick obs with u1 below lowcut
		ipick = select(range(1,nobs,1), u1 :< lowcut)
		pick[iobs[ipick]] = J(length(ipick),1,1)

		// select a subset with u1 in the range of [lowcut,highcut]
		isub = select(range(1,nobs,1), u1 :>= lowcut :& u1 :<= highcut)
		
		// sort u1 within the subset; because uniform() draws random
		// numbers with replacement (see http://blog.stata.com/tag/random-numbers/),
		// duplicates may arise. Use an secondary vector of random numbers
		// to break such ties. Finally, adding the indices makes the
		// sort fully replicable no matter what
		u1sub =  u1[isub]
		u2sub = uniform(length(isub), 1)
		ix = sort((isub, u1sub, u2sub), (2,3,1))
		
		// pick remaining obs to reach the requested count
		ipick = ix[|1,1 \ count-nlow,1|]
		pick[iobs[ipick]] = J(length(ipick),1,1)
		
		st_store(., st_addvar("byte", tagvar),  pick)
		
	}
	else {
	
		// the cutoff selects exactly count observations
		pick[iobs[select(range(1,nobs,1), u1 :< cutoff)]] = J(count,1,1)
		st_store(., st_addvar("byte", tagvar), pick)
		
	}

}


void tag_it(

	string scalar tagvar,		// name of new variable to generate
	real scalar count 			// number of draws
	
	)
{

	real colvector	///
		u1, 		/// primary uniformly distributed random variates
		pick,		/// indicator for picked observations
		isub,		/// indices of obs in subset used to make final picks
		u1sub,		/// subset of u1 used to make final picks
		u2sub,		/// secondary random variates to break ties in u1sub
		ix,			/// indices/x matrix that is sorted for final picks
		ipick		/// indices of final picks.
		
	real scalar		///
		nobs, 		///	number of observations
		cutoff,		///	a value such that sum(u1 :< cutoff)  ~== count
		highcut,	/// a value such that sum(u1 :< highcut) > count
		lowcut,		/// a value such that sum(u1 :< lowcut)  < count
		nlow,		/// equal to sum(x :< lowcut)
		n			/// stores sum(x :< cutoff) while iterating
		

	// roll back the number of draws if > number of observations
	nobs = st_nobs()
	count = (nobs < count ? nobs : count)
	
	// primary uniformly distributed random variate on [0,1)
	u1 = uniform(nobs, 1)
	
	// initial estimate of cutoff needed for sum(u1 :< cutoff) == count
	cutoff = count / nobs

	// refine cutoff by finding high and low cutoff values
	n = sum(u1 :< cutoff)
	if (n > count) {
		highcut = cutoff
		while (n > count) {
			cutoff = cutoff - 1.05 * (n - count) / nobs
			n = sum(u1 :< cutoff)
		}
		lowcut = cutoff
		nlow = n
	}
	else if (n < count) {
		lowcut = cutoff
		nlow = n
		while (n < count) {
			cutoff = cutoff + 1.05 * (count - n) / nobs
			n = sum(u1 :< cutoff)
		}
		highcut = cutoff
	}
	
	if (n != count) {

		// pick obs with u1 below lowcut
		pick = u1 :< lowcut
		
		// select a subset with u1 in the range of [lowcut,highcut]
		isub = select(range(1,nobs,1), u1 :>= lowcut :& u1 :<= highcut)
		
		// sort u1 within the subset; because uniform() draws random
		// numbers with replacement (see http://blog.stata.com/tag/random-numbers/),
		// duplicates may arise. Use an secondary vector of random numbers
		// to break such ties. Finally, adding the indices makes the
		// sort fully replicable no matter what
		u1sub =  u1[isub]
		u2sub = uniform(length(isub), 1)
		ix = sort((isub, u1sub, u2sub), (2,3,1))
		
		// pick remaining obs to reach the requested count
		ipick = ix[|1,1 \ count-nlow,1|]
		pick[ipick] = J(length(ipick),1,1)
		st_store(., st_addvar("byte", tagvar), pick)
				
	}
	else st_store(., st_addvar("byte", tagvar), u1 :< cutoff)

}

end
