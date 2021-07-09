*! version 1.0.1  Quezada Sanchez AD 10nov2015
*! version 1.0.0  Quezada Sanchez AD 02dec2010

program define lbpower, rclass
	version 8.0

	syntax , NRep(numlist max=1 int) DUR(numlist max=1) Dif(numlist max=1) ///
	CORRjk(numlist max=1) Alpha(numlist max=1) [Power(numlist >0 <1 ascending)] ///
	[NSize(numlist max=1)] [unilateral] 

	preserve
		clear

		if "`power'"!="" & "`nsize'"!="" {
			 di as err "please specify either power or sample size, not both"
			 exit
			 }
		if "`power'"=="" & "`nsize'"=="" {
			di as err "please specify either power or sample size"
			exit
			}

		local var=(3*(`nrep'-1)*(1-`corrjk'))/((`dur'^2)*(`nrep')*(`nrep'+1))
		local d=`dif'/`dur'
		
		if "`unilateral'"=="" {
			local za=invnorm(1-`alpha'/2)
			}
			else {
				local za=invnorm(1-`alpha')
				}
		
		if "`power'"!="" {
			 qui: {
				 gen Power=.
				 gen N=.
				 gen n=.
				 foreach c of local power {
					 local i=`i'+1
					 local valp`i'=`c' 
					 local zb`i'=invnorm(`c')
					 local ns`i'=ceil(((`za'+`zb`i'')^2*2*`var')/(`d'^2))
					 }
				 clear
				 set obs `i'
				 gen power=.
				 gen n=.
				 forvalues x=1/`i' {
					replace power=`valp`x'' in `x'
					replace n=`ns`x'' in `x'
					return scalar n`x'=`ns`x''
					}
				gen N=2*n
				}
			di " "
			di as text "Approximated Sample Size : "
			list, noobs sep(0)
			di "   n = Subjects per treatment group " 
			di "   N = Total of subjects " 
			}
	 
		else {
			 local power=normal(`d'*sqrt(ceil(`nsize')/(2*`var'))-`za') 
			 di " "
			 di as text "Achieved power  = " as res round(`power',0.001)
			 return scalar power=`power'
			}
		
		di " "
		di as text "   Number of repeated measurements = " `nrep'
		di "   Duration of study = " `dur'
		di "   Correlation between repeated measurements Yij,Yik = " `corrjk'
		di "   Diference in probability changes (whole study) = " `dif'
		di "   Diference in probability changes (per unit of time)  = " `d'
		di "   Significance level = " `alpha'
		if "`nsize'"!="" {
			di "   Subjects per treatment group  = " `nsize'
			di "   Total of subjects = " 2*`nsize' 
			}

	restore
end
