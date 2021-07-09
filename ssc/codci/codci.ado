program define codci, rclass sortpreserve byable(recall)
	version 9.2
	syntax varname (numeric) [if] [in]  [, 			///
		Level(cilevel)   	]					
	if "`level'"!=""{
		if `level' <= 0 | `level' >= 100 {
		di as err "level() must be between 0 and 100"
		exit 198
		}
	}
	marksample touse 
	qui count if `touse'
	local ntouse = r(N)
	if r(N) == 0 {
		di as error "There are no observations!"
		exit 2000
	}
	tempvar alpha
	scalar `alpha' = 1-((1-`level'/100)/2)
	qui {
		sum `varlist' if `touse', detail
		ret scalar Var=r(Var)
		ret scalar p50 = r(p50)
		ret scalar mean=r(mean)
		ret scalar N = r(N)
		scalar c=return(N)/(return(N)-1)
		if return(p50)==0 {
			di as err /*
			*/ "The median equals zero. No COD"
			exit 198
		}
		else {
			tempvar absl rank ordera orderb ordera2 orderb2
			gen `absl'=abs((`varlist'-return(p50)))
			sum `absl' if `touse'
			local tabsl=r(sum)
			ret scalar tau= (`tabsl'/return(N)) 
			return scalar cod= return(tau)/return(p50)
			scalar del=(return(mean)-return(p50))/return(tau)
			scalar gam=return(Var)/return(tau)^2
			ret scalar astar=round(((return(N)+1)/2)-sqrt(return(N)))
			ret scalar bstar=return(N)-return(astar)+1

			egen `rank' = rank(`varlist')if `touse',t
			gen `ordera'=`varlist' if `rank'==return(astar)
			sum `ordera' if `touse'
			scalar aorder=r(max)
			gen `orderb'=`varlist' if `rank'==return(bstar)
			sum `orderb' if `touse'
			scalar border=r(max)
			ret scalar varleta=((ln(aorder)-ln(border))/4)^2

			scalar se1=sqrt(return(varleta))
			ret scalar varltau= (gam + (del^2)-1)/return(N)
			scalar se2=sqrt(return(varltau))		   
			ret scalar covltle=del*se1/sqrt(return(N))
			scalar k=sqrt(return(varleta)+return(varltau)-2*return(covltle))/(se1+se2)
			ret scalar a=round(((return(N)+1)/2)-(k*invnormal(`alpha')*sqrt(return(N)/4)))
			ret scalar b=return(N)-return(a)+1

			gen `ordera2'=`varlist' if `rank'==return(a)
			sum `ordera2' if `touse'
			scalar aorder2=r(max)
			gen `orderb2'=`varlist' if `rank'==return(b)
			sum `orderb2' if `touse'
			scalar border2=r(max)
			ret scalar L2star=ln(aorder2)
			ret scalar U2star=ln(border2)

			ret scalar L1=ln(c*return(tau))-(k*invnormal(`alpha')*se2)
			ret scalar U1=ln(c*return(tau))+(k*invnormal(`alpha')*se2)
			ret scalar cicod_lb=exp(return(L1)-return(U2star))
			ret scalar cicod_ub=exp(return(U1)-return(L2star))
		}
	}
	di _n in text "{bf} Bonett-Seier's Conf. Interval for COD" 
	di in text  "{bf} in Nonnormal Distributions" 
	di in text _newline(1)"{hline 37}{c TT}{hline 18}
	di "{input}{bf}  Coefficient of Dispersion{sf}{col 38}{c |}"/*
	*/as result %12.2f return(cod)
	di in text"{hline 37}{c +}{hline 18}
	di "{input}{bf}  Conf. Interval for COD  {sf}{col 38}{c |}"
	di in text"{hline 37}{c +}{hline 18}
	di in text "     `level'" "%  " "Lower Limit {col 38}{c |}"/*
	*/as result %12.3f return(cicod_lb)
	di in text "     `level'" "%  " "Upper Limit {col 38}{c |}"/*
	*/as result %12.3f return(cicod_ub)
	di in text"{hline 37}{c BT}{hline 18}
end

exit



