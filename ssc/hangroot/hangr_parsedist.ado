*! version 1.5.0 09Aug2011 MLB
program define hangr_parsedist, sclass
	syntax [varname(default=none)] ///
	[,                             ///
	dist(string) par(numlist)      ///
	]

	// TLAs (may be) allowed for distribution options 
	local l = max(4, length("`: word 1 of `dist''"))

	// second element in dist() is grouping variable name if dist() is theoretical distribution
	local groupvar : word 2 of `dist'
	local dist : word 1 of `dist'
	if "`dist'" == substr("theoretical", 1, `l') & "`groupvar'" == "" {
		di as err "two elements must be specified in the dist() option when specifying the theoretical distribution in the dist() option"
		di as err "the second element must be the grouping variable"
		exit 198
	}
	if "`dist'" == substr("theoretical", 1, `l') {
		confirm variable `groupvar'
	}
	
	// case-insensitive (allowing Gaussian, Weibull, etc.) 
	local dist = lower("`dist'") 
	
	local XXfit = 0
	if "`varlist'" == "" & "`dist'" == "" {
		if ("`e(cmd)'" == "betafit"     ) | ///
		   ("`e(cmd)'" == "regress"     ) | ///
		   ("`e(cmd)'" == "paretofit"   ) | ///
		   ("`e(cmd)'" == "lognfit"     ) | ///
		   ("`e(cmd)'" == "weibullfit"  ) | ///
		   ("`e(cmd)'" == "gammafit"    ) | ///
		   ("`e(cmd)'" == "gumbelfit"   ) | ///
		   ("`e(cmd)'" == "invgammafit" ) | ///
		   ("`e(cmd)'" == "invgaussfit" ) | ///
		   ("`e(cmd)'" == "dagumfit"    ) | ///
		   ("`e(cmd)'" == "smfit"       ) | ///
		   ("`e(cmd)'" == "gb2fit"      ) | ///
		   ("`e(cmd)'" == "fiskfit"     ) | ///
		   ("`e(cmd)'" == "gevfit"      ) | ///
		   ("`e(cmd)'" == "poisson"     ) | ///
		   ("`e(cmd)'" == "nbreg"       ) | ///
		   ("`e(cmd)'" == "gnbreg"      ) | ///
		   ("`e(cmd)'" == "zip"         ) | ///
		   ("`e(cmd)'" == "zinb"        ) /*| ///
		   ("`e(cmd)'" == "zoib"        ) */{ 
			sreturn local varlist "`e(depvar)'"
			sreturn local weight "`e(wtype)'"
			local exp "`e(wexp)'"
			local exp : subinstr local exp "=" ""
			sreturn local exp "`exp'"
			local XXfit = 1
		}
		else {
			di as err "varlist required when hangroot is not preceded by" 
			di as err "betafit, zoib, paretofit, lognfit, weibullfit, gammafit," 
			di as err "gumbelfit, invgammafit, invgaussfit, dagumfit,"
			di as err "smfit, gb2fit, fiskfit, gevfit, poisson, nbreg,"
			di as err "gnbreg, zip, or zinb"
			exit 100
		}
	}
	if "`varlist'" == "" & "`dist'" != "" {
		di as err "varlist required when specifying the dist() option"
		exit 100
	}
	
	// distribution defaults to beta if betafit was the last model estimated or zoib was last estimated without zero or one inflate part
	//                       to paretao if paretofit was the last model estimated   
	//                       to lognormal if lognfit was the last model estimated
	//                       to weibull if weibullfit was the last model estimated
	//                       to gamma if gammafit was the last model estimated
	//                       to gumbel if gumbelfit was the last model estimated
	//                       to invgamma if invgammafit was the last model estimated
	//                       to wald if invgaussfit was the last model estimated
	//                       to dagum if dagumfit was the last model estimated
	//                       to sm if smfit was the last model estimated
	//                       to gb2 if gb2fit was the last model estimated
	//                       to fisk if fiskfit was the last model estimated
	//                       to poisson if poisson was the last model estimated
	//                       to nb1 if nbreg with mean dispersion was the last model estimated
	//                       to nb2 if nbreg without mean dispersion or gnbreg was the last model estimated
	//                       to zip if zip was the last model estimated
	//                       to zoib if zoib was last model estimated and contained zero and one inflate part
	//                       to zib if zoib was last model estimated and contained only zero inflate part
	//                       to oib if zoib was last model estimated and contained only one inflate part
	// otherwise the default is normal (Gaussian) 
	local withx = 0
	if "`dist'" == "" {
		if "`e(cmd)'" == "regress"  {
			local dist normal
			if `e(df_m)' > 0 {
				local withx = 1
			}
		}
		else if "`e(cmd)'" == "betafit"   {
			local dist beta
			if "`e(mu)'`e(phi)'`e(alpha)'`e(beta)'" == "" {
				local withx = 1
			}
		}
		else if "`e(cmd)'" == "zoib" {
			if "`e(title)'" == "ML fit of beta" {
				local dist beta
				if e(rank) > 2 {
					local withx = 1
				}
			}
			if "`e(title)'" == "ML fit of zib" {
				local dist zib
				local inflate inflate(0)
				if e(rank) > 3 {
					local withx = 1
				}
			}
			if "`e(title)'" == "ML fit of oib" {
				local dist oib
				local inflate inflate(1)
				if e(rank) > 3 {
					local withx = 1
				}
			}
			if "`e(title)'" == "ML fit of zoib" {
				local dist zoib
				local inflate inflate(0 1)
				if e(rank) > 4 {
					local withx = 1
				}
			}
		}
		else if "`e(cmd)'" == "paretofit"  {
			local dist pareto
			if `e(nocov)' == 0 {
				local withx = 1
			}
		}
		else if "`e(cmd)'" == "lognfit"  {
			local dist lognormal
			if `e(nocov)' == 0 {
				local withx = 1
			}
		}
		else if "`e(cmd)'" == "weibullfit" {
			local dist weibull
			if !(`e(length_b_b)' == 1 & `e(length_b_c)' == 1) {
				local withx = 1
			}
		}
		else if "`e(cmd)'" == "gammafit" {
			local dist gamma
			if "`e(alpha)'`e(beta)'" == ""  {
				local withx = 1
			}
		}
		else if "`e(cmd)'" == "gumbelfit"  {
			local dist gumbel
			if "`e(mu)'`e(alpha)'" == "" {
				local withx = 1
			}
		}
		else if "`e(cmd)'" == "invgammafit" {
			local dist invgamma
			if  "`e(alpha)'`e(beta)'" == "" {
				local withx = 1
			}
		}
		else if "`e(cmd)'" == "invgaussfit" {
			local dist wald
			if "`e(mu)'`e(lambda)'" == "" {
				local withx = 1
			}
		}
		else if "`e(cmd)'" == "dagumfit"  {
			local dist dagum
			if `e(nocov)' == 0 {
				local withx = 1
			}
		}
		else if "`e(cmd)'" == "smfit"  {
			local dist sm
			if `e(nocov)' == 0 {
				local withx = 1
			}
		}
		else if "`e(cmd)'" == "gb2fit" {
			local dist gb2
			if `e(nocov)' == 0 {
				local withx = 1
			}
		}
		else if "`e(cmd)'" == "fiskfit" {
			local dist fisk
			if `e(nocov)' == 0 {
				local withx = 1
			}
		}
		else if "`e(cmd)'" == "gevfit"    {
			local dist gev
			if `e(nocov)' == 0 {
				local withx = 1
			}
		}
		else if "`e(cmd)'" == "poisson" {
			 if "`e(offset)'" != ""  {
				di as err "hangroot cannot be used in combination with exposure or offset"
				exit 198
			 }
			local dist poisson
			if e(df_m) != 0 {
				local withx = 1
			}
		}	
		else if "`e(cmd)'" == "nbreg" {
			 if "`e(offset)'" != ""  {
				di as err "hangroot cannot be used in combination with exposure or offset"
				exit 198
			 }
			 if "`e(dispers)'" != "mean" {
				local dist nb1
			 }
			 else {
				local dist nb2
			 }
			 if e(df_m) != 0 {
				local withx = 1
			 } 
		}
		else if "`e(cmd)'" == "gnbreg" {
			 if "`e(offset)'" != ""  {
				di as err "hangroot cannot be used in combination with exposure or offset"
				exit 198
			 }
			 local dist nb2
 			 if e(df_m) != 0 {
				local withx = 1
			 } 
		}
		else if "`e(cmd)'" == "zip" {
			 if "`e(offset)'" != ""  {
				di as err "hangroot cannot be used in combination with exposure or offset"
				exit 198
			 }
			local dist zip
			if e(df_m) + e(df_c) -1 != 0 {
				local withx = 1
			}
		}
		else if "`e(cmd)'" == "zinb" {
			 if "`e(offset)'" != ""  {
				di as err "hangroot cannot be used in combination with exposure or offset"
				exit 198
			 }
			local dist zinb
			if e(df_m) + e(df_c) -1 != 0 {
				local withx = 1
			}
		}
		else {
			local dist normal
		}
	}
	else if "`dist'" == substr("normal", 1, `l')  |  /// 
		"`dist'" == substr("gaussian", 1, `l') {  
		local dist normal 
	}	
	else if "`dist'" == substr("poisson", 1, `l') {
		local dist poisson
	}
	else if "`dist'" == substr("beta", 1, `l') {
		local dist beta
	}/*
	else if "`dist'" == substr("zoib", 1, `l') {
		local dist zoib
		local inflate inflate(0 1)
	}
	else if "`dist'" == substr("oib", 1, `l') {
		local dist oib
		local inflate inflate(1)
	}
	else if "`dist'" == substr("zib", 1, `l') {
		local dist zib
		local inflate(0)
	}*/
	else if "`dist'" == substr("pareto", 1, `l') {
		local dist pareto
	}
	else if "`dist'" == substr("exponential", 1, `l') {
		local dist exponential
	}
	else if "`dist'" == substr("laplace", 1, `l') {
		local dist laplace
	}
	else if "`dist'" == substr("uniform", 1, `l') {
		local dist uniform
	}
	else if "`dist'" == substr("geometric", 1, `l') {
		local dist geometric
	}
	else if "`dist'" == substr("lognormal", 1, `l') {
		local dist lognormal
	}
	else if "`dist'" == substr("weibull", 1, `l') {
		local dist weibull
	}
	else if "`dist'" == substr("gamma", 1, `l') {
		local dist gamma
	}
	else if "`dist'" == substr("gumbel", 1, `l') {
		local dist gumbel
	}
	else if "`dist'" == substr("invgamma", 1, `l') {
		local dist invgamma
	}
	else if "`dist'" == substr("wald", 1, `l') {
		local dist wald
	}
	else if "`dist'" == substr("dagum", 1, `l') {
		local dist dagum
	}
	else if "`dist'" == "sm" {
		local dist sm
	}
	else if "`dist'" == "gb2" {
		local dist gb2
	}
	else if "`dist'" == substr("fisk", 1, `l') {
		local dist fisk
	}
	else if "`dist'" == "gev" {
		local dist gev
	}
	else if "`dist'" == "chi2" {
		local dist chi2 
	}	
	else if "`dist'" == substr("logistic", 1, `l'){
		local dist logistic
	}
	else if "`dist'" == substr("theoretical", 1, `l') {
		local dist "theoretical"
	}
	else if "`dist'" == "nb1" {
		local dist "nb1"
	}
	else if "`dist'" == "nb2" {
		local dist "nb2"
	}
	else if "`dist'" == "zip" {
		local dist "zip"
		local inflate inflate(0)
	}
	else if "`dist'" == "zinb" {
		local dist "zinb"
		local inflate inflate(0)
	}
	else {
		di as err "distribution `dist' not recognized"
		exit 198
	}
	
	// -hangroot- cannot estimate parameters for Weibull, fisk, dagum, sm, gb2, gev, nb, zip, and zinb
	if "`varlist'" != "" & "`dist'" == "fisk" & "`par'" == "" {
		di as error "the best fitting Fisk distribution must be fit using fiskfit"
		di as error "first estimate the model and than type hangroot without varlist"
		di as error "or fix the paramters using the par() option"
		exit 198
	}
	if "`varlist'" != "" & "`dist'" == "weibull" & "`par'" == "" {
		di as error "the best fitting Weibull distribution must be fit using weibullfit"
		di as error "first estimate the model and than type hangroot without varlist"
		di as error "or fix the paramters using the par() option"
		exit 198
	}
	if "`varlist'" != "" & "`dist'" == "dagum" & "`par'" == "" {
		di as error "the best fitting dagum distribution must be fit using dagumfit"
		di as error "first estimate the model and than type hangroot without varlist"
		di as error "or fix the paramters using the par() option"
		exit 198
	}
	if "`varlist'" != "" & "`dist'" == "sm" & "`par'" == "" {
		di as error "the best fitting Singh-Maddala distribution must be fit using smfit"
		di as error "first estimate the model and than type hangroot without varlist"
		di as error "or fix the paramters using the par() option"
		exit 198
	}
	if "`varlist'" != "" & "`dist'" == "gb2" & "`par'" == "" {
		di as error "the best fitting Generalized Beta (Second Kind) distribution must be fit using gb2fit"
		di as error "first estimate the model and than type hangroot without varlist"
		di as error "or fix the paramters using the par() option"
		exit 198
	}
	if "`varlist'" != "" & "`dist'" == "gev" & "`par'" == "" {
		di as error "the best fitting generalized extreme value distribution must be fit using gevfit"
		di as error "first estimate the model and than type hangroot without varlist"
		di as error "or fix the paramters using the par() option"
		exit 198
	}
	if "`varlist'" != "" & ("`dist'" == "nb1" | "`dist'" == "nb2") & "`par'" == "" {
		di as error "the best fitting negative binomial distribution must be fit using nbreg"
		di as error "first estimate the model and than type hangroot without varlist"
		di as error "or fix the paramters using the par() option"
		exit 198
	}
	if "`varlist'" != "" & "`dist'" == "zip" & "`par'" == "" {
		di as error "the best fitting zero inflated Poisson distribution must be fit using zip"
		di as error "first estimate the model and than type hangroot without varlist"
		di as error "or fix the paramters using the par() option"
		exit 198
	}
	if "`varlist'" != "" & "`dist'" == "zinb" & "`par'" == "" {
		di as error "the best fitting zero inflated negative binomial distribution must be fit using zinb"
		di as error "first estimate the model and than type hangroot without varlist"
		di as error "or fix the paramters using the par() option"
		exit 198
	}
	
	sreturn local dist "`dist'"
	sreturn local groupvar "`groupvar'"
	sreturn local XXfit "`XXfit'"
	sreturn local withx "`withx'"
	if "`inflate'" != "" {
		sreturn local inflate "`inflate'"
	}
end
