
** ADO FILE FOR EFFECTIVENESS SHEET OF CEQ OUTPUT TABLES

** VERSION AND NOTES (changes between versions described under CHANGES)
*! v1.10 30jun2018 
** v1.9 11feb2018 For use with Aug 2017 version of Output Tables
** v1.8 04dec2017 For use with Aug 2017 version of Output Tables
** v1.7 28nov2017 For use with Aug 2017 version of Output Tables
** v1.6 14aug2017 For use with July 2017 version of Output Tables
** v1.5 20jul2017 For use with July 2017 version of Output Tables
** v1.4 21may2017 For use with Apr 2017 version of Output Tables
** v1.3 03may2017 For use with Jul 2016 version of Output Tables
** v1.2 03jan2016 For use with Jul 2016 version of Output Tables
** (beta version; please report any bugs), written by Rodrigo Aranda raranda@tulane.edu

** CHANGES
**  v1.10 Fixed ystar_ppp issue, (#50 on Github)
**	v1.9 Modified ceqbensp to use Ali's formula 
**  v1.8 Including warning for when fiscal intervention options are not specified.
**  v1.7 Mofidied _ceqspend to use Ali's formula.
**  v1.6 Including warnings for IE, when sum of programs exceeds starting income.
**		 Modifying ceqtaxharm
**		 Removed tempvar int_ben and int_tax due to redunacy
**		 Change who is messaged in case of error.
**  v1.5 Replacing covgini with covconc and modifiying ceq(tax/ben)star to be more efficient.
**		 Adjusting _fifgpmc removing marginal contributions of tax and benefits, uses only contribution of FI and FGP to effectivness.
**  v1.2 Added Spending effectiveness, changes in Spillover so it shows in Excel, FI/FGP results available for all income concepts **  v1.3 Updated to produce no results for FI/FGP per capita and normalized per capita effectiveness indicator **		 Fix the national poverty line specification to include both variables and scalar condition for Beckerman **		 Add the weight local in subcommands **  v1.4 Add option flexibility for income concept and fiscal interventions ** NOTES
** No spending effectiveness. Results are not feasible for poverty using the whole system.

** TO DO
** See if other indicators can be used (or even make sense) for the system such as s-gini, 90/10, theil, etc.

************************
* PRELIMINARY PROGRAMS *
************************

#delimit cr
// BEGIN returncol (Higgins 2015) 
//  Returns Excel column corresponding to a number
cap program drop returncol
program define returncol, rclass
	confirm integer number `1'
	mata: st_strscalar("col",numtobase26(`1'))
	return local col = col
end // END returncol

* Program to compute Gini coefficient;* GINI USING COVARIANCE FORMULA
* Makes two adjustments relative to the "naive" approach:
*  first is to multiply by (N-1)/N to adjust for the fact that Stata uses sample covariance
*  second is to estimate F(y) using Lerman and Yitzhaki (1989); weighted fractional ranks would give biased estimate
* With these two adjustments, covgini gives same answer as Gini commands based on 
*  discrete formulas to 9 decimal places


// BEGIN _fifgpmc (Edited from _fifgp, Higgins 2015)
//  Calculates fiscal impoverishemnt and fiscal gains of the poor
//   measures for a specific poverty line and two income concepts
capture program drop _fifgpmc
program define _fifgpmc,rclass
	#delimit;
	syntax  [if] [in] [aw] [, 
		z(string)
		taxes(varname)
		benef(varname)
		startinc(varname)
		endinc(varname)
		];
	#delimit cr
	
	if wordcount("`taxes'")==0{
	tempvar taxes
	gen `taxes'=0
	}
	if wordcount("`benef'")==0{
	tempvar benef
	gen `benef'=0
	}
	tempvar notax noben
	qui gen double `notax'=`endinc'+`taxes'
	qui gen double `noben'=`endinc'-`benef'
	
	*total taxes and transfers;
	 sum `taxes' [`weight' `exp']
	local T=abs(r(sum))
	 sum `benef' [`weight' `exp']
	local B=r(sum)
	local TB=`T'+`B'
	
	tempvar  d_fi  d_fg 
	
	qui gen `d_fi' = min(`startinc',`z') - min(`startinc',`endinc',`z')
	*qui gen `d_fi_t' = min(`notax',`z') - min(`notax',`endinc',`z')
	
	*	qui gen `d_fi' = min(`y0',`z') - min(`y0',`y1',`z')
	*qui gen `d_fg' = min(`y1',`z') - min(`y0',`y1',`z')
	
	
	qui gen `d_fg' = min(`endinc',`z') - min(`startinc',`endinc',`z')
	*qui gen `d_fg_b' = min(`endinc',`z') - min(`noben',`endinc',`z')
	
	foreach v in fi fg {
	qui summ `d_`v'' [`weight' `exp'], meanonly
			local t_`v' = r(sum)
			local pc_`v' = r(mean)
			local n_`v' = r(mean)/`z'
	}
	
	*Marginal contributions
	foreach m in t pc n{
		
		*local `m'_mc_t=``m'_fi'-``m'_fi_t'
		*local `m'_mc_b=``m'_fg_b'-``m'_fg'
		
		
		if `T'!=0 /*& (``m'_mc_t'>=0 & ``m'_mc_t'!=0)*/{
			local mceft_`m'=(`T'/`TB')*(1-(``m'_fi'/`T'))
		}
		else{
		local mceft_`m'=0
		}
		if `B'!=0 /*& (``m'_mc_b'>=0 & ``m'_mc_b'!=.)*/{
			local mcefb_`m'=(`B'/`TB')*((``m'_fg'/`B'))
		}
		else{
		local mcefb_`m'=0
		}
		
			*local MCEF_`m'=`mceft_`m''+`mcefb_`m''
			*scalar MCEF_`m'=`mceft_`m''+`mcefb_`m''
			return scalar MCEF_`m' = `mceft_`m''+`mcefb_`m''
		
		}
		

end // END _fifgpmc		
	

* Program to compute ideal tax for impact effectiveness
*generates income variable (ytaxstar) whith ideal taxes 
*rest of observations have no tax income
*var taxstar has the ideal tax for those obs. rest is missing

 
cap program drop ceqtaxstar
program define ceqtaxstar, rclass 
#delimit;
	syntax [if] [in] [pw aw iw fw/] [,
			/*Incomes*/
			startinc(varname)
			endinc(varname)
			taxes(varname)
			]
			;
		#delimit cr	
		
		if "`exp'" == "" {
			local exp = 1
			}
			
		cap drop  ___startinc
		gen double ___startinc = `startinc'
		cap drop ___taxes
		gen double ___taxes = `taxes'
		gsort -___startinc

		replace ___taxes = abs(___taxes)
		qui sum ___taxes [aw=`exp'] 
		local tot=r(sum) //total amount to redistribute
		qui sum ___startinc [aw=`exp'] 
		
		if (`tot' > r(sum) | `tot' == 0 ) {
			if `tot' > r(sum) return scalar t_gr = 1
			if `tot' == 0 return scalar t_0 = 1
			exit
		}
		else {
			// Taking the difference of income b/w one person and then previous
			gen double ___diff_y = ___startinc - ___startinc[_n-1]
			recode ___diff_y (.=0)
			gen double ___cum_w = sum(`exp')
			gen double ___diff_y_i = ___diff_y*___cum_w[_n-1]
			recode ___diff_y_i (.=0)
			gen double ___cum_diff_y_i = sum(___diff_y_i)
			// Determining who is taxed.
			gen ___taxed = (abs(___cum_diff_y_i) < `tot')
			gen ___last_taxed = ___taxed==1 & ___taxed[_n+1]==0

			gen ___id = _n
			sum ___id if ___last_taxed== 1
			assert r(min)==r(max) 
			local which = r(mean) // Giving observation of which person is taxed.
			// Generating optimal tax
			gen double ____taxstar = 0
			replace ____taxstar = ___startinc - ___startinc[`which'] if ___taxed==1

			local still_tax =  `tot' - abs(___cum_diff_y_i[`which'])
			
			local still_tax_per_person = `still_tax' / ___cum_w[`which']

			replace ____taxstar = ____taxstar + `still_tax_per_person' if ___taxed==1

			sum ____taxstar [aw=`exp']
			// Ensuring that we how allocating the exact amount of tax available
			*assert round(`tot',.1) == round(r(sum),.1)
			nois assert abs((`tot' - r(sum))/`tot') < 0.0001
			// Generating optimal income 
			cap drop ____id_taxstar
			cap drop ____ytaxstar
			gen double ____ytaxstar = ___startinc
			replace ____ytaxstar = ____ytaxstar - ____taxstar if ___taxed == 1
			gen ____id_taxstar = ___taxed

			return scalar twarn = 0

			drop ___taxed ___last_taxed ____taxstar ___diff_y ___diff_y_i ///
				 ___cum_diff_y_i ___cum_w ___id 
		}
		drop ___startinc ___taxes
		end
		
	
		
* Program to compute ideal transfer for impact effectiveness
*generates income variable (ybenstar) whith ideal transfers 
*rest of observations have no transfer income
*var benstar has the ideal transfers for those obs. rest is missing
cap program drop ceqbenstar
program define ceqbenstar, rclass 
#delimit;
	syntax [if] [in] [pw aw iw fw/] [,
			/*Incomes*/
			startinc(varname)
			endinc(varname)
			ben(varname)
			]
			;
		#delimit cr	
		
		if "`exp'" == "" {
			local exp = 1
			}
			
		cap drop  ___startinc
		gen double ___startinc = `startinc'
		cap drop  ___ben
		gen double ___ben = `ben'
		sort  ___startinc
		
		qui sum ___ben [aw=`exp'] 
		local tot=r(sum) //total amount to redistribute
		qui sum ___startinc [aw=`exp'] 
		
		if (`tot' > r(sum) | `tot' == 0 ) {
			if `tot' > r(sum) return scalar b_gr = 1
			if `tot' == 0 return scalar b_0 = 1
			exit
		}
		else {
			// Taking the difference of income b/w one person and then previous
			gen double ___diff_y = ___startinc - ___startinc[_n-1]
			recode ___diff_y (.=0)
			gen double ___cum_w = sum(`exp')
			gen double ___diff_y_i = ___diff_y*___cum_w[_n-1]
			recode ___diff_y_i (.=0)
			gen double ___cum_diff_y_i = sum(___diff_y_i)
			// Determining who is taxed.
			gen ___gets_ben = (abs(___cum_diff_y_i) < `tot')
			gen ___last_rec = ___gets_ben==1 & ___gets_ben[_n+1]==0

			gen ___id = _n
			sum ___id if ___last_rec== 1
			assert r(min)==r(max) 
			local which = r(mean) // Giving observation of which person is taxed.

			gen double ____benstar = 0
			replace ____benstar = `startinc'[`which'] - `startinc'   if ___gets_ben==1

			local still_ben =  `tot' - abs(___cum_diff_y_i[`which'])
			local still_ben_per_person = `still_ben' / ___cum_w[`which']
			
			replace ____benstar = ____benstar + `still_ben_per_person' if ___gets_ben==1

			sum ____benstar [aw=`exp']
			// Ensuring that we how allocating the exact amount of benefits available
			*nois assert round(`tot',.1) ==  round(r(sum),.1)
			nois assert abs((`tot' - r(sum))/`tot') < 0.0001
			
			
			cap drop ____id_benstar
			cap drop ____ybenstar
			gen double ____ybenstar = `startinc'
			replace ____ybenstar = ____ybenstar + ____benstar if ___gets_ben == 1
			gen ____id_benstar = ___gets_ben

			return scalar bwarn = 0

			drop ___gets_ben ___last_rec ____benstar ___diff_y ___diff_y_i ///
				 ___cum_diff_y_i ___cum_w ___id 
			}

		drop  ___startinc ___ben

		end
		
		
* Program to compute harm tax formula for poverty impact effectiveness
*generates income variable (ytaxharm) whith ideal taxes 
*rest of observations have no tax income
*var taxharm has the harm tax for those obs. rest is missing

cap program drop ceqtaxharm
program define ceqtaxharm, rclass 
#delimit;
	syntax [if] [in] [pw aw iw fw/] [,
			/*Incomes*/
			endinc(varname)
			taxes(varname)
			]
			;
			#delimit cr
			
		if "`exp'" !="" {
			local aw = "[aw = `exp']" //weights
			local pw = "[pw = `exp']"
		}
		else {
			tempvar ww
			gen `ww' = 1
			}
		*no taxes income
		cap drop ___ww
		gen double ___ww = `exp'
		cap drop ___notax
		gen double ___notax =`endinc'+abs(`taxes')
		cap drop ___taxes
		gen double ___taxes =  `taxes' 
		sort ___notax

		qui sum ___taxes `aw'
		local tot=r(sum) //total amount to redistribute

		qui sum ___notax `aw'

		if `tot' > r(sum) { ;
			return scalar thwarn = 1
			exit
		}
		else {

			gen double ___inc_wght= ___notax*___ww
			gen double ___cum_inc_wght = sum(___inc_wght)
			gen ___taxed = ___cum_inc_wght < `tot'
			gen ___new_inc = ___notax
			replace ___new_inc = 0 if ___taxed == 1
			gen ___last_taxed = 1 if ___taxed == 1 & ___taxed[_n+1] == 0
			gen ___id = _n
			sum ___id if ___last_taxed == 1
			assert r(N) ==1
			local which = r(mean)

			scalar remainder = `tot' - ___cum_inc_wght[`which']
			assert remainder > 0 & remainder < ___cum_inc_wght[`which' + 1] 
			replace ___new_inc = ___notax - (remainder/___ww) in `=`which' + 1'
			cap drop ___taxstar

			gen double ___taxstar = ___notax - ___new_inc

			sum ___taxstar `aw'
			local rsum = r(sum)
			// Ensuring harm tax is equal to amount avaible to tax
			local tax1 = round(`tot',.1)
			local tax2 = round(`rsum',.1) 
			assert (abs((`tax1'-`tax2')/`tax1') < 0.00001)

			cap drop ____id_taxharm
			cap drop ____ytaxharm
			gen double ____id_taxharm=___taxed
			gen double ____ytaxharm=___new_inc
			return scalar thwarn = 0

			cap drop ___id ___notax ___inc_wght ___cum_inc_wght ___taxed ___last_taxed ___new_inc

		}
		cap drop  ___taxes ___notax ___ww
		end

		***Marginal contribution ID
	
	cap program drop _ceqmcid
program define _ceqmcid, rclass 
#delimit;
	syntax [if] [in] [pw aw iw fw/] [,
			/*Incomes*/
			inc(varname)
			sptax(varname)
			spben(varname) 
			pline(string)  
			]
			;
			#delimit cr
			
		if "`exp'" !="" {
			local aw = "[aw = `exp']" //weights
			local pw = "[pw = `exp']"
		}
		local id_tax=0
		local id_ben=0
		
		tempvar inter
		*See if we are dealing with taxes or transfers
		if wordcount("`sptax'")>0{
		local id_tax=1
		gen double `inter'=abs(`sptax')
		
		}
		if wordcount("`spben'")>0{
		local id_ben=1
		gen double `inter'=abs(`spben')
		}
		
		
		if `id_tax'==1{
		tempvar o_inc
		gen double `o_inc'=`inc'+`inter'
		}
		if `id_ben'==1{
		tempvar o_inc
		gen double `o_inc'=`inc'-`inter'
		}
		
		
			*gini final income
			covconc `inc' `pw'
			local g_f=r(gini)
			covconc `o_inc' `pw'
			local g_o=r(gini)
		
			local mc=`g_o'-`g_f'
			return scalar mc_ineq =  `mc' //Marginal Contribution
		
		if wordcount("`pline'")>0{
			tempvar pov0_o pov1_o pov2_o
			tempvar pov0_f pov1_f pov2_f
			gen `pov0_o'=(`o_inc'<`pline')
			gen `pov0_f'=(`inc'<`pline')
			
			qui gen `pov1_o' = max((`pline'-`o_inc')/`pline',0) // normalized povety gap of each individual
			qui gen `pov2_o' = `pov1_o'^2 
			qui gen `pov1_f' = max((`pline'-`inc')/`pline',0) // normalized povety gap of each individual
			qui gen `pov2_f' = `pov1_f'^2 
			forvalues f=0/2{
			qui sum `pov`f'_o' `aw'
			local p`f'_o=r(mean)
			qui sum `pov`f'_f' `aw'
			local p`f'_f=r(mean)
			local mc`f'=`p`f'_o'-`p`f'_f'
			return scalar mc_p`f'=`mc`f'' //Marginal Contribution of poverty fgt:`f'
			}
		}
		end
					
		
****Spending Effectiveness program;
cap program drop _ceqspend
program define _ceqspend, rclass 
#delimit;
	syntax [if] [in] [pw aw iw fw/] [,
			/*Incomes*/
			inc(varname)
			sptax(varname)
			spben(varname)
			]
			;
			#delimit cr
			
		// note variable names represent column names in Effectives_SE Cal.xlsx in Methods folder of CEQStataPackage shared dropbox folder
		local id_tax=0
		local id_ben=0

		set type double 
		*See if we are dealing with taxes or transfers


		tempvar G
		qui gen double `G' = `inc'

		if wordcount("`sptax'")>0{

		local id_tax=1
		tempvar F E
		qui gen double `F'=abs(`sptax')
		qui gen double `E' = `G'+ `F'

		} 


		if wordcount("`spben'")>0{
		local id_ben=1
		tempvar F E
		qui gen double `F' =abs(`spben')
		qui gen double `E' = `G'-`F'
		
		}

		
	

		if `id_ben' == 1 {
			sort `E'  // Because we are dealing with benefits
			tempvar C D
			qui sum `exp' 
			qui gen double `C' = `exp'/r(sum) // normalizing the weights
			qui gen double `D' = sum(`C') // culmative sum of weights

			tempvar B
			qui gen int `B' = _n // generating observation number, ith person
			 
			tempvar S T 
			qui gen double `S' = `E'[_n+1] - `E' // diff in starting income between i and ith person
			qui gen double `T' = `S'*`D' in 1
			qui replace `T' = `S'*`D' + `T'[_n-1] if _n>1 // Sum of differnce in OI.

			tempvar F_hat w_F
			qui gen double `F_hat' = `D'[_n-1] + `C'/2 // empirical distribution / rankings
			qui replace `F_hat' = `C'/2 in 1
			qui gen double `w_F' = `C'*`F_hat' // weighted rankings
			qui summ  `w_F'
			scalar Fbar = r(sum) // average weighted rankings

			// Based on theory this should always be .5
			assert abs(Fbar-.5) <= 0.0001

		    tempvar W X 
		    qui gen double `W' = (`F_hat' - Fbar)*`C' // difference with avg. weighted rankings
			qui gen double `X' = `W' in 1
			qui replace  `X' = `W' + `X'[_n-1] if _n>1  // culmative sum of diff with avg weighted rankings

			tempvar Y Z 
			qui gen double `Y' = `X'*`S' // Multiplying X with difference in original income
			qui gen double `Z' = `Y' in 1
			qui replace `Z' = `Y' + `Z'[_n-1] if _n>1 // Culmative sum of difference times culmative sum of weight rankings difference

			tempvar AD 
			qui qui gen double `AD' = 2*`Z'

			qui covconc `E' [pw=`C']
			scalar Gini_OI = r(gini)

			qui summarize `E' [aw=`C'], meanonly
			scalar mu_OI = r(mean)

			tempvar Gini_star

			qui gen double `Gini_star' = (mu_OI*Gini_OI + `AD')/(mu_OI + `T')
			

			// suppose the observed ending income Gini is saved in scalar Gini_EI
			qui covconc `G' [pw=`C']
			scalar Gini_EI = r(gini)

			tempvar higher_gini
			qui gen byte `higher_gini' = (`Gini_star' < Gini_EI) & ///
								   (`Gini_star'[_n-1] > Gini_EI ) 
			


				// note higher_gini is column AG
				
			qui summ `B' if `higher_gini'==1
			assert r(min)==r(max) // just one obs
			local which = r(mean) 

			// Composition of s
			// signs change depending on tax or benefit
			scalar  AT2 = (Gini_OI*mu_OI + `AD') in `=`which'-1'
			
			scalar AV2 = (mu_OI + `T') in `=`which'-1'
			
			scalar AR2 = `D' in `which'

			scalar AX2 = 2*`X' in `which'

			*scalar s = (AT2 - Gini_EI*AV2)/(Gini_EI*AR2 - AX2) // scalar wasn't storing value
			local s = (AT2 - Gini_EI*AV2)/(Gini_EI*AR2 - AX2)
			
			tempvar AJ AK AZ BA 
			qui gen double `AJ' = (`E'[`which'] - `E')*(`B' <= `which')

			qui gen double `AK' = `E' + `AJ'

			qui gen double `AZ' = (`AJ' +`s')*(`B'<= `which')

			qui gen double `BA' = `AZ' + `E'

			covconc `BA' [pw=`C']
			 
			assert abs(r(gini) - Gini_EI)/Gini_EI < 0.0001


			qui summ `AZ' [aw=`C']

			scalar tot_EHB = r(sum)

			qui summ `F' [aw=`C']

			scalar tot_TB = r(sum)

			return scalar sp_ef = tot_EHB / tot_TB
		}

		if `id_tax' == 1 {
			*set trace on
			sort `E' // even though we are dealing with taxes the orderings are still intended to be from least to greatest, the reverse
			tempvar B // comes with a second wieght variable we create
			gen `B' = _n
			

			sum `exp'
			tempvar C D
			gen double `C' = `exp'/r(sum)
			gen double `D' = sum(`C')

			
			// Storing value for starting income Gini
			covconc `E' [pw=`C']
			scalar Gini_OI = r(gini)
			
			// suppose the observed ending income Gini is saved in scalar Gini_EI
			covconc `G' [pw=`C']
			scalar Gini_EI = r(gini)

			tempvar F_hat
			gen double `F_hat' = `D'[_n-1] + `C'/2
			replace `F_hat' = `C'/2 in 1
			tempvar w_F
			gen double `w_F' = `C' * `F_hat'
			summ `w_F'
			scalar Fbar = r(sum)

			assert abs(r(sum)-.5)/.5 < 0.00001
			tempvar W
			gen double `W' = (`F_hat' - Fbar)*`C'

			tempvar  S 
			gen double `S' =  `E' - `E'[_n-1] 

			gsort - `E'
			tempvar Drev T
			gen double `Drev' = sum(`C')
			gen double `T' = `S'*`Drev' in 1
			replace `T' = `S'*`Drev' + `T'[_n-1] if _n>1

			tempvar X 
			gen double `X' = `W' in 1
			replace `X' = `W' + `X'[_n-1] if _n>1

			tempvar Y Z
			gen double `Y' = `X'*`S'
			gen double `Z' = `Y' in 1
			replace `Z' = `Y' + `Z'[_n-1] if _n>1

			tempvar AD
			gen double `AD' = 2*`Z'

			// Resort based on starting income to calculate Ginis 

			sort `E'



			summarize `E' [aw=`C'], meanonly
			scalar mu_OI = r(mean)
			
			tempvar Gini_star
			gen double `Gini_star' = (mu_OI*Gini_OI - `AD')/(mu_OI - `T')
				// remember to change to negative signs in both numerator and denom
				//  when doing it for taxes


			tempvar higher_gini
		       gen byte `higher_gini' = (`Gini_star' < Gini_EI) & (`Gini_star'[_n+1] > Gini_EI)
				// note higher_gini is column AG
			*qui gen byte `higher_gini' = (`Gini_star' < Gini_EI) & ///
							(`Gini_star'[_n-1] > Gini_EI ) 

			summ `B' if `higher_gini'==1
			assert r(min)==r(max) // just one obs
			local which = r(mean)

			scalar  AT2 = (Gini_OI*mu_OI - `AD') in `=`which'+1'
			scalar AV2 = (mu_OI - `T') in `=`which'+1'
			scalar AR2 = `Drev' in `which'
			scalar AX2 = 2*`X' in `which'

			*scalar s = (AT2 - Gini_EI*AV2)/(AX2-Gini_EI*AR2) // scalar not returning value
			local s = (AT2 - Gini_EI*AV2)/(AX2-Gini_EI*AR2)			

			tempvar AJ AK AZ BA
			gen double `AJ' = (`E'[`which'] - `E')*(`B' >=`which')



			gen double `AK' = `E' + `AJ'

			gen double `AZ' = (`AJ' - `s')*(`B'>=`which')

			gen double `BA' = `AZ' + `E'

 			covconc `BA' [pw=`C']

			assert abs(r(gini) - Gini_EI)/Gini_EI < 0.0001


			summ `AZ' [aw=`C']

			scalar tot_EHB = -1*r(sum)

			summ `F' [aw=`C']

			scalar tot_TB = r(sum)

			scalar se_ind = tot_EHB / tot_TB
			*set trace off
		}
		

		scalar drop tot_EHB tot_TB Gini_EI Gini_OI  ///
		  AR2 AX2 AT2 AV2 mu_OI Fbar
end

	
	****Poverty Spending effectiveness;
* Program to computepoverty spending effectiveness for FGT1 and FGT2
*generates scalars  sp_ef_pov_1 and sp_ef_pov_2
cap program drop ceqbensp
program define ceqbensp, rclass 
	#delimit;
	syntax [if] [in] [pw aw iw fw/] [,
			/*Incomes*/
			startinc(varname)
			endinc(varname)
			ben(varname)
			zz(string)
			obj1(string)
			obj2(string)

			*
			]
			;
	#delimit cr
		
		scalar A = `zz'
		scalar B = _N
		tempvar D C
		gen double `D' = `exp'
		gen int `C' = _n

		tempvar G H I
		gen double `G' = `startinc'
		gen double `H' = `ben'
		gen double `I' = `G' + `H'

		if 	"`obj1'" != "" {
			// Poverty gap calculation
			tempvar opt_ben
			gen double `opt_ben' = min(`H',A-`G')*(`G'<A) // optimal benefits according to alis agorithm in Spending Effectiveness for the poverty indicators_Nov 24, 2017.

			sum `opt_ben' [aw=`D']
			scalar prime1 = r(sum)

			sum  `H' [aw=`D']
			scalar tot_ben1 = r(sum)

			return scalar sp_ef_pov_1 = prime1/tot_ben1
			scalar drop prime1 tot_ben1
		}

		if "`obj2'" != "" {
			sum `D'
			scalar E = r(sum)
			tempvar F
			gen double `F' = sum(`D') // Cumulative weight 

			tempvar J K L M
			gen double `J' = ((A - `G')^2/A^2)*(`G'<A) // SGR for OI

			gen double `L' =  ((A - `I')^2/A^2)*(`I'<A) // SGR EI

			sum `J' [aw=`D']
			scalar N = r(mean) // Squared poverty gap ratio for OI

			sum `L' [aw=`D'] // Squared poverty gap ratio for EI
			scalar O = r(mean)

			scalar P = N-O // Marg contribution between OI and EI
			local P = N-O  // Also using local because there have been issues with using scalar.
			

			scalar Q = A^2*E*P // Target Value 1

			tempvar R S T U V W X Y
			gen double  `R' = min(`G'[_n+1] - `G', A -`G')*(`G'<A) // Diff in OI bw I and I+1th person for poor

			gen double `S' = (A-`G')*(`G'<A) // z - y_i

			gen double `T' = `R'^2 // DIfference squared.

			gen double `U' = (2*`R'*`S') - `T' // 2*(diff)*(z-y_i) - (diff)^2

			gen double `V' = `U'*`F' // U times cumulative sum of weights

			gen double `W' = `V'/(A^2*E) // V scaled by pov line and sum of weights

			gen double `X' = `W' in 1
			replace `X' = `W' + `X'[_n-1] if `C' > 1

			gen byte `Y' = (`X' <= P & `X'[_n+1] > P)

			summ `C' if `Y' == 1
			assert r(min) == r(max)
			local which = r(mean)
			scalar AA = (`C'+1)  in `which' // person after J

			scalar AC = P - `X' in `which' // Remained MC

			scalar AD = A^2*E*AC
			tempvar AE
			gen `AE' = `X' > P & `X'[_n-1] < P // Adjusted Y column
			local p = P

		    summ `C' if `AE' == 1
			assert r(min) == r(max)
			local which2 = r(mean)
			scalar AG = `S' in `which2' // z-y_J
			scalar AH = AG^2 // (z-y_J)^2
			scalar AJ = `F' in `which2'

			scalar AK = (2*AG+sqrt(4*AH - 4*(AD/AJ)))/2 // First root of equation

			scalar AL = (2*AG - sqrt(4*AH - 4*(AD/AJ)))/2 // second root of equation

			scalar AM = min(max(AL,0),max(AK,0)) // taking smallest root greter than 0.

			scalar AO = `G' in `which2'
			tempvar AP AQ AR
			gen double `AP' = ((AO-`G') + AM)*(`G'<=AO) // Optimum benefit

			gen double `AQ' = `G' + `AP' // New EI

			gen double `AR' = ((A - `AQ')/A)^2*(`AQ'<A)

			sum `AR' [aw=`D']
			scalar AT= r(mean)

			*scalar AU = N - AT
			local AU = N - AT

		        *assert (`AU' == `P')
			assert abs(((`AU' - `P')/`P')) < 0.0001

			summ `AP' [aw=`D']
			scalar prime2 = r(sum)

			summ `H' [aw=`D']
			scalar tot_ben2 = r(sum)

			return scalar sp_ef_pov_2 = prime2/tot_ben2

			scalar drop E N O P Q AA AC AD AG AH AJ AK AL AM AO AT prime2 tot_ben2

		}

		scalar drop A B 
end


			
****************************************************
***Beckerman Imervoll program
cap program drop ceqbeck
program define ceqbeck, rclass sortpreserve
#delimit;
	syntax [if] [in] [pw aw iw fw/] [,
			/*Incomes*/
			preinc(varname)
			postinc(varname)
			/* POVERTY LINES */
			zline(string)
			]
			;
#delimit cr			
	quietly {
		if "`exp'" !="" {
			local aw = "[aw = `exp']" //weights
			}
		tempvar difference
		gen double `difference' = `postinc'-`preinc'
		tempvar pre_shortfall
		gen double `pre_shortfall' = `zline' - `preinc'
		tempvar post_shortfall
		gen double `post_shortfall' = `zline' - `postinc'

		sum `difference' `aw' if `preinc' < `zline'
		scalar AB = r(sum)
		summarize `difference' `aw' 
		scalar ABC = r(sum)
		summarize `post_shortfall' `aw'  if `preinc' < `zline' & `postinc'>= `zline'
		scalar B = -r(sum)
		summarize `difference' `aw'  if `postinc' <  `zline'
		scalar A1 = r(sum)
		summarize `pre_shortfall'`aw'  if `preinc' <  `zline' & `postinc' >= `zline'
		scalar A2 = r(sum)
		scalar A = A1 + A2
		summarize `pre_shortfall' `aw'  if `preinc' < `zline'
		scalar AD = r(sum)
		scalar VEE = AB/ABC
		scalar Spillover = B/AB
		scalar PRE = A/ABC
		scalar PGE = A/AD

		return scalar VEE=VEE
		return scalar Spill = Spillover
		return scalar PRE = PRE
		return scalar PGE = PGE


	}

end




*********************
* ceqef PROGRAM *
*********************

capture program drop ceqef
program define ceqef
	version 13.0   
	#delimit ;
	syntax 
		[using/]
		[if] [in] [pweight/] 
		[, 
			/* INCOME CONCEPTS: */
			Market(varname)
			Mpluspensions(varname)
			Netmarket(varname) 
			Gross(varname)
			Taxable(varname)
			Disposable(varname) 
			Consumable(varname)
			Final(varname)
			/* FISCAL INTERVENTIONS: */
			Pensions   (varlist)
			DTRansfers (varlist)
			DTAXes     (varlist) 
			CONTribs(varlist)
			SUbsidies  (varlist)
			INDTAXes   (varlist)
			HEALTH     (varlist)
			EDUCation  (varlist)
			OTHERpublic(varlist)
			/* PPP CONVERSION */
			PPP(real -1)
			CPISurvey(real -1)
			CPIBase(real -1)
			YEARly
			MOnthly
			DAily
			/* SURVEY INFORMATION */
			HHid(varname)
			HSize(varname) 
			PSU(varname) 
			Strata(varname)
			/* POVERTY LINES */
			PL1(real 1.25)
			PL2(real 2.50)
			PL3(real 4.00)
			NATIONALExtremepl(string)   
			NATIONALModeratepl(string)  
			OTHERExtremepl(string)      
			OTHERModeratepl(string)			
			/* EXPORTING TO CEQ MASTER WORKBOOK: */
			sheet(string)
			OPEN
			/* GROUP CUTOFFS */
			cut1(real 1.25)
			cut2(real 2.5)
			cut3(real 4)
			cut4(real 10)
			cut5(real 50)
			/* INFORMATION CELLS */
			COUNtry(string)
			SURVeyyear(string) /* string because could be range of years */
			AUTHors(string)
			SCENario(string)
			GROUp(string)
			PROJect(string)
			
			BASEyear(real -1)*

			/** DROP MISSING VALUES */
			IGNOREMissing
		]
	;

*****General Options;
* general programming locals;
	local dit display as text in smcl;
	local die display as error in smcl;
	local command ceqef;
	local version 1.10;
	`dit' "Running version `version' of `command' on `c(current_date)' at `c(current_time)'" _n "   (please report this information if reporting a bug to sean.higgins@ceqinstitute.org and marc.brooks@ceqinstitute.org)"; //";
	qui{;
	* weight (if they specified hhsize*hhweight type of thing);
	if strpos("`exp'","*")> 0 { ;
		`die' "Please use the household weight in {weight}, this will automatically be multiplied by the size of household given by {bf:hsize}";
		exit;
	};
	
	* hsize and hhid;
	if wordcount("`hsize' `hhid'")!=1 {;
		`die' "Must exclusively specify {bf:hsize} (number of household members for household-level data) or ";
		`die' "{bf:hhid} (unique household identifier for individual-level data)";
		exit 198;
	};
	* make sure using is xls or xlsx;
	ceq_parse_using using `"`using'"', cmd("ceqef") open("open");
	
	//";
	
	***********************
	* PRESERVE AND MODIFY *
	***********************;
	set type double;



	preserve;
	if wordcount("`if' `in'")!=0 quietly keep `if' `in';
	
	* collapse to hh-level data;
	if "`hsize'"=="" { ;// i.e., it is individual-level data;
		tempvar members;
		sort `hhid';
		qui bys `hhid': gen `members' = _N; // # members in hh ;
		qui bys `hhid': drop if _n>1; // faster than duplicates drop;
		local hsize `members';
	};
	
	
	**********************
	* SVYSET AND WEIGHTS *
	**********************;
	cap svydes;
	scalar no_svydes = _rc;
	if !_rc qui svyset ;// gets the results saved in return list;
	if "`r(wvar)'"=="" & "`exp'"=="" {;
		`dit' "Warning: weights not specified in svydes or the command";
		`dit' "Hence, equal weights (simple random sample) assumed";
	};
	else {;
		if "`exp'"=="" & "`r(wvar)'"!="" local w `r(wvar)';
		if "`exp'"!="" local w `exp';
		if "`w'"!="" {;
			tempvar weightvar;
			qui gen double `weightvar' = `w'*`hsize';
			local w `weightvar';
		};
		else local w "`hsize'";
		
		if "`w'"!="" {;
			local pw "[pw = `w']";
			local aw "[aw = `w']";
		};
		if "`exp'"=="" & "`r(wvar)'"!="" {;
			local weight "pw";
			local exp "`r(wvar)'";
		};
	};
	else if "`r(su1)'"=="" & "`psu'"=="" {;
		di as text "Warning: primary sampling unit not specified in svydes or the d1 command's psu() option";
		di as text "P-values will be incorrect if sample was stratified";
	};
	if "`psu'"=="" & "`r(su1)'"!="" {;
		local psu `r(su1)';
	};
	if "`strata'"=="" & "`r(strata1)'"!="" {;
		local strata `r(strata1)';
	};
	if "`strata'"!="" {;
		local opt strata(`strata');
	};
	* now set it:;
	if "`exp'"!="" qui svyset `psu' `pw', `opt';
	else           qui svyset `psu', `opt';

	
		* temporary variables;
	tempvar one;
	qui gen `one' = 1;
	
	* create pseudo income concepts when users did not specify income concepts;
	foreach concept in market mpluspensions netmarket gross taxable disposable consumable final {;
		if "``concept''"=="" {;
			tempvar `concept';
			qui gen ``concept'' = -1;
		};
	};
	

	**********
	* LOCALS *
	**********;
	
	* income concepts;
	local m `market';
	local mp `mpluspensions';
	local n `netmarket';
	local g `gross';
	local t `taxable';
	local d `disposable';
	local c `consumable';
	local f `final';
	local alllist m mp n g t d c f;
	local alllist2 m mp n g t d c f;
	local incomes = wordcount("`alllist'");
	local origlist m mp n g d;
	tokenize `alllist'; // so `1' contains m; to get the variable you have to do ``1'';
	local varlist "";
	local varlist2 "";
	local counter = 1;
	foreach y of local alllist {;
		local varlist `varlist' ``y''; // so varlist has the variable names;
		local varlist2 `varlist' ``y'2';
		// reverse tokenize:;
		local _`y' = `counter'; // so _m = 1, _mp = 2 (regardless of whether these options included);
		if "``y''"!="" local `y'__ `y' ;// so `m__' is e.g. m if market() was specified, "" otherwise;
		local ++counter;
	};

	local d_m      = "Market Income";
	local d_mp     = "Market Income + Pensions";
	local d_n      = "Net Market Income";
	local d_g      = "Gross Income";
	local d_t      = "Taxable Income";
	local d_d      = "Disposable Income";
	local d_c      = "Consumable Income";
	local d_f      = "Final Income";
	foreach y of local alllist {;
		if "``y''"!="" {;
			scalar _d_``y'' = "`d_`y''";
		};
	};
	

	** missing income concepts
	foreach var of local varlist {
		qui count if missing(`var')  
		if "`ignoremissing'"=="" {
			if r(N) {
				`die' "Missing values not allowed; `r(N)' missing values of `var' found" 
				exit 198
			}
		}
		else {
			if r(N) {
				qui drop if missing(`var')
				`dit' "Warning: `r(N)' observations that are missing `var' were dropped because the user specified {bf:ignoremissing}"
				local warning `warning' "Warning: `r(N)' observations that are missing `var' were dropped because the user specified the ignoremissing option."
			}
		}
    }
    ** Checking if fiscal intervention options are specificied.
	if  wordcount("`pensions' `dtransfers' `dtaxes' `contribs' `subsidies' `indtaxes' `health' `education' `otherpublic'") == 0 {
		`dit' "Warning: No fiscal intervention options were specified, therefore impact and spending effectiveness indicators are not produced."
		 local warning `warning' "Warning: No fiscal intervention options were specified, therefore impact and spending effectiveness indicators are not produced."
	}
	
	* negative incomes;
	foreach v of local alllist {;
		if "``v''"!="" {;
			qui count if ``v''<0; 
			if r(N) `dit' "Warning: `r(N)' negative values of ``v''";
		};
	};	
	#delimit cr
	* poverty lines
	local povlines `pl1' `pl2' `pl3' `nationalextremepl' `nationalmoderatepl' `otherextremepl' `othermoderatepl'
	local plopts pl1 pl2 pl3 nationalextremepl nationalmoderatepl otherextremepl othermoderatepl
	foreach p of local plopts {
		if "``p''"!="" {
			cap confirm number ``p'' // `p' is the option name eg pl125 so ``p'' is what the user supplied in the option
			if !_rc scalar _`p'_isscalar = 1 // !_rc = ``p'' is a number
			else { // if _rc, i.e. ``p'' not number
				cap confirm numeric variable ``p''
				if _rc {
					`die' "Option " in smcl "{opt `p'}" as error " must be specified as a scalar or existing variable."
					exit 198
				}
				else scalar _`p'_isscalar = 0 // else = if ``p'' is numeric variable
			}
		}
	}
	scalar _relativepl_isscalar = 1 // `relativepl' created later
	* ppp conversion
	if (`ppp'==-1 & `cpisurvey'==-1 & `cpibase'==-1) {
		local _ppp = 0
		local divideby = 1
		local ppp_calculated = 1
		`dit' "Warning: results by income group and bin not produced since {bf:ppp} option not specified."
	}
	else local _ppp = 1
	if (`_ppp' & min(`ppp',`cpisurvey',`cpibase')==-1) {
		`die' "To convert to PPP, must provide {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase} options"
		exit 198
	}
	if (`_ppp'==0 & wordcount("`daily' `monthly' `yearly'")>0) {
		`die' "{bf:daily}, {bf:monthly}, or {bf:yearly} options require use of {bf:ppp}, {bf:cpisurvey}, and {bf:cpibase}"
		exit 198
	}
	if (`_ppp' & wordcount("`daily' `monthly' `yearly'")==0) {
		`dit' "Warning: {bf:daily}, {bf:monthly}, or {bf:yearly} options not specified; variables assumed to be in {bf:yearly} local currency units"
		local yearly yearly
	}
	if (wordcount("`daily' `monthly' `yearly'")>1) {
		`die' "{bf:daily}, {bf:monthly}, and {bf:yearly} options are exclusive"
		exit 198
	}
	if ("`daily'"!="")        local divideby = 1
	else if ("`monthly'"!="") local divideby = 365/12
	else if ("`yearly'"!="")  local divideby = 365

	* transfer and tax categories
	local taxlist dtaxes contribs indtaxes
	local transferlist pensions dtransfers subsidies health education otherpublic
	local programlist  pensions dtransfers dtaxes contribs subsidies indtaxes health education otherpublic
	foreach x of local programlist {
		local allprogs `allprogs' ``x'' // so allprogs has the actual variable names
	}


	* columns including disaggregated components and broader categories
	local broadcats dtransfersp dtaxescontribs inkind alltaxes alltaxescontribs alltransfers 
	local dtransfersp `pensions' `dtransfers' 
	local dtaxescontribs `dtaxes' `contribs'
	local inkind `health' `education' `otherpublic' // these contain the variables, or blank if not specified
	local alltransfers `dtransfers' `subsidies' `inkind'
	local alltransfersp
	local alltaxes `dtaxes' `indtaxes'
	local alltaxescontribs `dtaxes' `contribs' `indtaxes'
	
	**********
	*Tax and Transfer options between core income concepts
	**********
	
	qui su `taxable'
	local mean1 = r(mean)
	qui su `gross'
	local mean2 = r(mean)
	if `mean1'!=-1 & `mean2'!=-1 {
		tempvar taxdif
		gen double  `taxdif'=`taxable'-`gross' 
		replace `taxdif'=0 if  (`taxdif')>0
		replace `taxdif'=abs(`taxdif')
	}
	**********
	*Market Income
	**********
	*From Market income to Market Income plus pensions
	if "`pensions'"!="" { 
		tempvar ben_m_mp
		egen double `ben_m_mp' =rsum(`pensions') 
		local bname_m_mp = `" `pensions' "' // "
	}
	*From Market income to Net Market Income
	
	if "`dtaxes'"!="" {
		tempvar tax_m_n
		egen double `tax_m_n'=rsum(`dtaxes')
		local tname_m_n = `" `dtaxes' "' // "
	} 
	if "`pensions'"!="" {
		tempvar ben_m_n
		egen double `ben_m_n'=rsum(`pensions')
		local bname_m_n = `" `pensions' "' // "
	}
	*From Market income to Gross Income
	*gen double `tax_m_g'=0
	
	if "`dtransfers'"!="" | "`pensions'"!="" {
		tempvar /*tax_m_g*/ ben_m_g
		egen double `ben_m_g'=rsum(`pensions' `dtransfers')
		local bname_m_g = `" `pensions' `dtransfers' "' // "
	}
	*From Market income to Taxable Income
	if "`taxdif'"!="" {
		tempvar tax_m_t 
		gen double `tax_m_t'=`taxdif'
		local tname_m_t = `" `taxdif' "'
	}
	if "`dtransfers'"!="" | "`pensions'"!="" {
		tempvar ben_m_t
		egen double `ben_m_t'=rsum(`pensions' `dtransfers')
		local bname_m_t = `" `pensions' `dtransfers' "' // "
	}
	*From Market income to Disposable Income 
	if "`dtaxes'"!="" {
		tempvar tax_m_d
		egen double `tax_m_d'=rsum(`dtaxes')
		local tname_m_d = `" `dtaxes' "'
	}
	if "`dtransfers'"!="" | "`pensions'"!="" {
		tempvar ben_m_d
		egen double `ben_m_d'=rsum(`pensions' `dtransfers')
		local bname_m_d = `" `pensions' `dtransfers' "' // "
	}
	*From Market income to Consumable Income
	if "`dtaxes'"!="" | "`indtaxes'"!="" {
		tempvar tax_m_c
		egen double `tax_m_c'=rsum(`dtaxes' `indtaxes')
		local tname_m_c = `" `dtaxes' `indtaxes' "' // "
	}

	if "`dtransfers'"!="" | "`pensions'"!="" | "`subsidies'"!="" {
		tempvar ben_m_c
		egen double `ben_m_c'=rsum(`pensions' `dtransfers' `subsidies')
		local bname_m_c = `" `pensions' `dtransfers' `subsidies' "' // "
	}
	
	*From Market income to Final Income
	if "`dtaxes'"!="" | "`indtaxes'"!="" {
		tempvar tax_m_f
		egen double `tax_m_f'=rsum(`dtaxes' `indtaxes')
		local tname_m_f = `" `dtaxes' `indtaxes' "'
	}
	if "`dtransfers'"!="" | "`pensions'"!="" | "`subsidies'"!="" | "`inkind'"!="" { // "
		tempvar ben_m_f
		egen double `ben_m_f'=rsum(`pensions' `dtransfers' `subsidies' `inkind')
		local bname_m_f = `" `pensions' `dtransfers' `subsidies' `inkind' "' // "
	}
	
	**********
	*Market Income plus Pensions
	**********
	*From Market income plus Pensions to Net Market Income
	if "`dtaxes'"!="" {
		tempvar tax_mp_n /*ben_mp_n*/
		egen double `tax_mp_n'=rsum(`dtaxes')
		local tname_mp_n = `" `dtaxes' "' // "
	}
	**gen double `ben_mp_n'=0
	*From Market income plus Pensions to Gross Income
	
	**gen double `tax_mp_g'=0
	if "`dtransfers'"!="" {
		tempvar /*tax_mp_g*/ ben_mp_g
		egen double `ben_mp_g'=rsum(`dtransfers')
		local bname_mp_g = `" `dtransfers' "' // "
	}
	*From Market income plus Pensions to Taxable Income
	if "`taxdif'"!="" {
		tempvar tax_mp_t 
		gen double `tax_mp_t'=`taxdif'
		local tname_mp_t = `" `taxdif' "' // "
	}
	if "`dtransfers'"!="" {
		tempvar ben_mp_t
		egen double `ben_mp_t'=rsum(`dtransfers')
		local bname_mp_t = `" `dtransfers' "' // "
	}
	*From Market income plus Pensions to Disposable Income
	if "`dtaxes'"!="" {
		tempvar tax_mp_d 
		egen double `tax_mp_d'=rsum(`dtaxes')
		local tname_mp_d = `" `dtaxes' "' // "
	}
	if "`dtransfers'"!="" {
		tempvar ben_mp_d
		egen double `ben_mp_d'=rsum(`dtransfers')
		local bname_mp_d = `" `dtranfers' "' // "
	}
	*From Market income plus Pensions to Consumable Income 
	if "`dtaxes'"!="" | "`indtaxes'"!="" {
		tempvar tax_mp_c
		egen double `tax_mp_c'=rsum(`dtaxes' `indtaxes')
		local tname_mp_c = `" `dtaxes' `indtaxes' "' // "
	}
	if "`dtransfers'"!="" | "`subsidies'"!="" {
		tempvar ben_mp_c
		egen double `ben_mp_c'=rsum(`dtransfers' `subsidies')
		local bname_mp_c = `" `dtransfers' `subsidies' "' // "
	}
	*From Market income plus Pensions to Final Income 
	if "`dtaxes'"!="" | "`indtaxes'"!="" {
		tempvar tax_mp_f
		egen double `tax_mp_f'=rsum(`dtaxes' `indtaxes')
		local tname_mp_f = `" `dtaxes' `indtaxes' "' // "
	}
	if "`dtransfers'"!="" | "`subsidies'"!="" | "`inkind'"!="" {
		tempvar ben_mp_f
		egen double `ben_mp_f'=rsum(`dtransfers' `subsidies' `inkind')
		local bname_mp_f = `" `dtransfers' `subsidies' `inkind' "' // "
	}

	**********
	*Net Market Income 
	**********
	*From Net Market income to Gross Income
	
	if "`tax_m_d'"!="" {
		tempvar tax_n_g 
		gen double `tax_n_g'=`tax_m_d'
		local tname_n_g =  `" `tname_m_d' "' // " 
	}
	if "`dtransfers'"!="" {
		tempvar /*tax_n_g*/ ben_n_g
		egen double `ben_n_g'=rsum(`dtransfers' ) 
		local bname_n_g = `" `dtransfers' "' // "
	}
	**replace `ben_n_g'=`ben_n_g'-abs(`tax_m_d')
	*From Net Market income to Taxable Income
		
	if "`dtransfers'"!="" & "`taxdif'"!="" {
		tempvar tax_n_t dtr 
		egen double `dtr'=rsum(`dtransfers')
		gen double `tax_n_t'=`taxdif'+ abs(`dtr')
		local tname_n_t = `" `tax_n_t' `dtransfers' "' // "
	}
	
	if "`dtransfers'"!="" {
		tempvar ben_n_t
		egen double `ben_n_t'=rsum(`dtransfers')
		local bname_n_t = `" `dtransfers' "' // "
	}
	*From Net Market income to Disposable Income
	*gen double `tax_n_d'=0
	if "`dtransfers'"!="" {
		tempvar /*tax_n_d*/ ben_n_d
		egen double `ben_n_d'=rsum(`dtransfers')
		local bname_n_d = `" `dtransfers' "' // "
	}
	*From Net Market income to Consumable Income
	
	if "`indtaxes'"!="" {
		tempvar tax_n_c
		egen double `tax_n_c'=rsum(`indtaxes')
		local tname_n_c = `" `indtaxes' "' // "
	}
	
	if "`dtransfers'"!="" | "`subsidies'"!="" {
		tempvar ben_n_c
		egen double `ben_n_c'=rsum(`dtransfers' `subsidies')
		local bname_n_c = `" `dtransfers' `subsidies' "' // "
	}
	*From Net Market income to Final Income
	
	if "`indtaxes'"!="" {
		tempvar tax_n_f 
		egen double `tax_n_f'=rsum(`indtaxes')
		local tname_n_f = `" `indtaxes' "' // "
	}
	
	if "`dtransfers'"!="" | "`subsidies'"!="" | "`inkind'"!="" {
		tempvar ben_n_f
		egen double `ben_n_f'=rsum(`dtransfers' `subsidies' `inkind')
		local bname_n_f = `" `dtransfers' `subsidies' `inkind' "' // "
	}
	
	**********
	*Gross Income 
	**********
	
	*From Gross income to Taxable Income
	
	if "`taxdif'"!="" {
		tempvar tax_g_t /*ben_g_t*/
		gen double `tax_g_t'=`taxdif'
		local tname_g_t = `" `taxdif' "' // "
	}
	*gen double `ben_g_t'=0
	*From Gross income to Disposable Income
	
	if "`dtaxes'"!="" {
		tempvar tax_g_d /*ben_g_d*/
		egen double `tax_g_d'=rsum(`dtaxes')
		local tname_g_d = `" `dtaxes' "' // "
	}
	*gen double `ben_g_d'=0
	*From Gross income to Consumable Income
	
	if "`dtaxes'"!="" | "`indtaxes'"!="" {
		tempvar tax_g_c 
		egen double `tax_g_c'=rsum(`dtaxes' `indtaxes')
		local tname_g_c = `" `dtaxes' `indtaxes' "' // "
	}
	
	if "`subsidies'"!="" {
		tempvar ben_g_c
		egen double `ben_g_c'=rsum(`subsidies')
		local bname_g_c = `" `subsidies' "' // "
	}
	*From Gross income to Final Income
	
	if "`dtaxes'"!="" | "`indtaxes'"!="" {
		tempvar tax_g_f 
		egen double `tax_g_f'=rsum(`dtaxes' `indtaxes')
		local tname_g_f = `" `dtaxes' `indtaxes' "' // "
	}
	
	if "`subsidies'"!="" | "`inkind'"!="" {
		tempvar ben_g_f
		egen double `ben_g_f'=rsum(`subsidies' `inkind')
		local bname_g_f = `" `subsidies' `inkind' "' // "
	}
	
	**********
	*Taxable Income 
	**********

	*From Taxable income to Disposable Income
	
	if "`dtaxes'"!="" {
		tempvar tax_t_d
		egen double `tax_t_d'=rsum(`dtaxes')
		local tname_t_d = `" `dtaxes' "' // "
	}
	
	if "`taxdif'"!="" {
		tempvar ben_t_d
		gen double `ben_t_d'=`taxdif'
		local bname_t_d = `" `taxdif' "' // "
	}
	*From Taxable income to Consumable Income
	
	if "`dtaxes'"!="" | "`indtaxes'"!="" {
		tempvar tax_t_c 
		egen double `tax_t_c'=rsum(`dtaxes' `indtaxes')
		local tname_t_c = `" `dtaxes' `indtaxes' "' // "
	}
	
	if "`taxdif'"!="" | "`subsidies'"!="" {
		tempvar ben_t_c
		egen double `ben_t_c'=rsum(`taxdif' `subsidies')
		local bname_t_c = `" `taxdif' `subsidies' "' // "
	}
	*From Taxable income to Final Income
	
	if "`dtaxes'"!="" | "`indtaxes'"!="" {
		tempvar tax_t_f 
		egen double `tax_t_f'=rsum(`dtaxes' `indtaxes')
		local tname_t_f = `" `dtaxes' `indtaxes' "' // "
	}
	
	if "`taxdif'"!="" | "`subsidies'"!="" | "`inkind'"!="" {
		tempvar ben_t_f
		egen double `ben_t_f'=rsum(`taxdif' `subsidies' `inkind')
		local bname_t_f = `" `taxdif' `subsidies' `inkind' "' // "
    }	
	
	**********
	*Disposable Income 
	**********
	*From Disposable income to Consumable Income
	
	if "`indtaxes'"!="" {
		tempvar tax_d_c 
		egen double `tax_d_c'=rsum(`indtaxes')
		local tname_d_c = `" `indtaxes' "' // "
	}
	
	if "`subsidies'"!="" {
		tempvar ben_d_c
		egen double `ben_d_c'=rsum(`subsidies')
		local bname_d_c = `" `subsidies' "' // "
	}
	*From Disposable income to Final Income
	
	if "`indtaxes'"!="" {
		tempvar tax_d_f
		egen double `tax_d_f'=rsum(`indtaxes')
		local tname_d_f = `" `indtaxes' "' // "
	}
	
	if "`subsidies'"!="" | "`inkind'"!="" {
		tempvar ben_d_f
		egen double `ben_d_f'=rsum(`subsidies' `inkind')
		local bname_d_f = `" `subsidies' `inkind' "' // "
	}
	
	**********
	*Consumable Income 
	**********
	*From Consumable income to Final Income
	*gen double `tax_c_f'=0
	
	if "`subsidies'"!="" | "`inkind'"!="" {
		tempvar /*tax_c_f*/ ben_c_f
		egen double `ben_c_f'=rsum(`subsidies' `inkind')
		local bname_c_f = `" `subsidies' `inkind' "' // "
	}
	
	******Rows******
	local rw_ie_pl1_1=3
	local rw_ie_pl1_2=4
	local rw_ie_pl2_1=5
	local rw_ie_pl2_2=6
	local rw_ie_pl3_1=7
	local rw_ie_pl3_2=8
	local rw_ie_nationalextremepl_1=9
	local rw_ie_nationalextremepl_2=10
	local rw_ie_nationalmoderatepl_1=11
	local rw_ie_nationalmoderatepl_2=12
	local rw_ie_otherextremepl_1=13
	local rw_ie_otherextremepl_2=14
	local rw_ie_othermoderatepl_1=15
	local rw_ie_othermoderatepl_2=16
	
	local rw_se_pl1_1=19
	local rw_se_pl1_2=20
	local rw_se_pl2_1=21
	local rw_se_pl2_2=22
	local rw_se_pl3_1=23
	local rw_se_pl3_2=24
	local rw_se_nationalextremepl_1=25
	local rw_se_nationalextremepl_2=26
	local rw_se_nationalmoderatepl_1=27
	local rw_se_nationalmoderatepl_2=28
	local rw_se_otherextremepl_1=29
	local rw_se_otherextremepl_2=30
	local rw_se_othermoderatepl_1=31
	local rw_se_othermoderatepl_2=32
	*For Beckerman Imervoll
	local rbk_pl1=33
	local rbk_pl2=37
	local rbk_pl3=41
	local rbk_nationalextremepl=45
	local rbk_nationalmoderatepl=49
	local rbk_otherextremepl=53
	local rbk_othermoderatepl=57
	*For FI/FGP
	local rfi_pl1=62
	local rfi_pl2=65
	local rfi_pl3=68
	local rfi_nationalextremepl=71
	local rfi_nationalmoderatepl=74
	local rfi_otherextremepl=77
	local rfi_othermoderatepl=80
	

	
	* PPP converted variables
	if (`_ppp') {
		local ppp_calculated = `ppp'*(`cpisurvey'/`cpibase')
		foreach v of local alllist {
			tempvar `v'_ppp
			if "``v''"!="" {
				qui gen ``v'_ppp' = (``v''/`divideby')*(1/`ppp_calculated')
			}
		}	
	}
	
	#delimit;
	
	*Effectiveness matrices for each income concept;
	foreach y of local 	alllist{;//generate matrices for results;
		matrix `y'_ef = J(82,8,.);
	};
	
	
	*Calculate Effectiveness indicators;
	foreach rw of local 	alllist{;//row income concept;
		foreach cc of local alllist{;//column income concept;	
			if ("`rw'" !="`cc'") & (`_`rw''<`_`cc'') {;
			****TAXES AND TRANSFERS for R and N;
			
					qui su ``rw'';
					local inc1 = r(mean);
					qui su ``cc'';
					local inc2 = r(mean);
					if `inc1'== -1 {;
						forval i = 1/82 {;
							matrix `rw'_ef[`i',`_`cc''] = .;
						};
					
					};
					if `inc2'==-1 {;
						forval i = 1/82 {;
							matrix `rw'_ef[`i',`_`cc''] = .;
						};
					};
					if `inc1'!=-1 & `inc2'!=-1 {;
						if "`tax_`rw'_`cc''"!=""{;
							tempvar taxesef;
							gen double `taxesef'=abs(`tax_`rw'_`cc'');
							
						};
						if "`ben_`rw'_`cc''"!=""{;
							tempvar benef;
							gen double `benef'=`ben_`rw'_`cc'';
						};
						local yes= wordcount("`benef'")+wordcount("`taxesef'");
						if (wordcount("`tax_`rw'_`cc''")>0 | wordcount("`ben_`rw'_`cc''")>0){; //ESTIMATE EFFECTIVENESS INDICATORS FOR CASES THAT APPLY;
							*impact effectiveness;
							/*if wordcount("`benef'")>0{;
								ceqbenstar [w=`w'], endinc(``cc'') ben(`benef');
							};
							if wordcount("`taxesef'")>0{;
								ceqtaxstar [w=`w'], endinc(``cc'') taxes(`taxesef');
							};*/
							if wordcount("`tax_`rw'_`cc''")>0 & wordcount("`ben_`rw'_`cc''")>0{;
								tempvar ystar;
								gen double `ystar'=``rw'';
								*set trace on ;
								ceqtaxstar `pw', startinc(``rw'') taxes(`taxesef');	
								*set trace off ;
								local twarn = 0 ; 
								if r(t_gr) == 1{ ;
									nois `dit'  "Sum of `tname_`rw'_`cc'' exceed ``rw'', so impact effectiveness indicator not produced from ``rw'' to ``cc''" ;
									local warning `warning'  "Sum of `tname_`rw'_`cc'' exceed ``rw'', so impact effectiveness indicator not produced from ``rw'' to ``cc''" ;
									local twarn = r(t_gr) ; 
								} ;
								else if r(t_0) == 1{ ;
									nois `dit'  "Sum of `tname_`rw'_`cc'' is 0, so impact effectiveness indicator not produced from ``rw'' to ``cc''" ;
									local warning `warning'  "Sum of `tname_`rw'_`cc'' exceed ``rw'', so impact effectiveness indicator not produced from ``rw'' to ``cc''" ;
									local twarn = r(t_0) ; 
								} ;
							
								ceqbenstar `pw', startinc(``rw'') ben(`benef');
								local bwarn = 0 ;
								if r(b_gr) ==1 { ;
									nois `dit' "Sum of `bname_`rw'_`cc'' exceed ``rw'', so impact effectiveness indicator for ``rw'' to ``cc'' excludes benefits or is not produced" ;
									local warning `warning' "Sum of `bname_`rw'_`cc'' exceed ``rw'', so impact effectiveness indicator for ``rw'' to ``cc'' excludes benefits or is not produced" ;
									local bwarn = r(b_gr) ;
								} ;
								else if r(b_0) ==1 { ;
									nois `dit' "Sum of `bname_`rw'_`cc'' exceed ``rw'', so impact effectiveness indicator for ``rw'' to ``cc'' excludes benefits or is not produced" ;
									local warning `warning' "Sum of `bname_`rw'_`cc'' exceed ``rw'', so impact effectiveness indicator for ``rw'' to ``cc'' excludes benefits or is not produced" ;
									local bwarn = r(b_0) ;
								} ;
								
								if `bwarn' == 0 & `twarn' == 0 { ;
									replace `ystar'=____ybenstar if ____id_benstar==1 & ____id_taxstar!=1;
									replace `ystar'=____ytaxstar if ____id_taxstar==1 & ____id_benstar!=1;
									tempvar temptax;
									gen double	`temptax'=``rw''-	____ytaxstar if ____id_benstar==1 & ____id_taxstar==1;			
									tempvar tempben;
									gen double	`tempben'=	____ybenstar - ``rw'' if ____id_benstar==1 & ____id_taxstar==1;
									replace `ystar'=``rw'' - `temptax' +`tempben' if ____id_benstar==1 & ____id_taxstar==1;			
									cap drop ____ytaxstar ____ybenstar ____id_benstar ____id_taxstar ;
									cap drop `temptax' `tempben';
								};
								else  { ;
									local bwarn = 1 ;
									local twarn = 1 ;
								};
							};
							if wordcount("`tax_`rw'_`cc''")>0 & wordcount("`ben_`rw'_`cc''")==0{;
								*set trace on;
								ceqtaxstar `pw' , startinc(``rw'') taxes(`taxesef') ;
								*set trace off;
								local twarn = 0 ;
								if  r(t_gr) ==1 { ;
									nois `dit' "Sum of `tname_`rw'_`cc'' exceed ``rw'', so impact effectiveness indicator not produced from ``rw'' to ``cc''" ;
									local warning `warning' "Sum of `tname_`rw'_`cc'' exceed ``rw'', so impact effectiveness indicator not produced from ``rw'' to ``cc''" ;								
									local twarn = r(t_gr) ; 
								} ;
								else if  r(t_0) ==1 { ;
									nois `dit' "Sum of `tname_`rw'_`cc'' is 0, so impact effectiveness indicator not produced from ``rw'' to ``cc''" ;
									local warning `warning' "Sum of `tname_`rw'_`cc'' is 0, so impact effectiveness indicator not produced from ``rw'' to ``cc''" ;								
									local twarn = r(t_0) ; 
								} ;
								else !(r(t_0) == 1 | r(t_gr) == 1) {;
									tempvar ystar;
									gen double `ystar'=____ytaxstar;
									cap drop ____ytaxstar ____ybenstar ____id_benstar ____id_taxstar;
								};
							};
							if wordcount("`tax_`rw'_`cc''")==0 & wordcount("`ben_`rw'_`cc''")>0{;
								ceqbenstar `pw', startinc(``rw'') ben(`benef');		
								local bwarn = 0 ;
								if r(b_gr) == 1 { ;
									nois `dit' "Sum of `bname_`rw'_`cc'' is 0, so impact effectiveness indicator not produced from ``rw'' to ``cc''" ;
									local warning `warning' "Sum of `bname_`rw'_`cc'' exceed ``rw'', so impact effectiveness indicator not produced from ``rw'' to ``cc''" ;
									local bwarn = r(b_gr) ;
								} ;
								else if r(b_0) == 1 { ;
									nois `dit' "Sum of `bname_`rw'_`cc'' is 0, so impact effectiveness indicator not produced from ``rw'' to ``cc''" ;
									local warning `warning' "Sum of `bname_`rw'_`cc'' exceed ``rw'', so impact effectiveness indicator not produced from ``rw'' to ``cc''" ;
									local bwarn = r(b_0) ;
								} ;
								if !(r(b_0) == 1 | r(b_gr) == 1) {;			
									tempvar ystar;
									gen double `ystar'=____ybenstar;
									cap drop ____ytaxstar ____ybenstar ____id_benstar ____id_taxstar;
								};
								
								if !( "`bwarn'" == "1" & "`twarn'" == "1" ) { ;
									covconc ``cc'' `pw'; //gini of column income;
										local g1_`cc'=r(gini);
										di "`rw' ``rw''";
										covconc ``rw'' `pw'; //gini of row income;
										local g2_`rw'=r(gini);
										covconc `ystar' `pw'; //gini of star income;
										local g_star=r(gini);
										local imef=(`g2_`rw''-`g1_`cc'')/(`g2_`rw''-`g_star');
										matrix `rw'_ef[1,`_`cc'']=`imef';
								};
							};
							*noisily di in red "INEQ IMPACT EFF. `rw' `cc' Row= `row'";
						
							*IMPACT EFFECTIVENESS FOR POVERTY (WHEN THERE IS ONLY TAXES OR ONLY TRANSFERS);	
							*Convert to ppp;
							if "`tax_`rw'_`cc''"!=""{;
									tempvar int_tax_ppp;
									gen double  `int_tax_ppp'=(`tax_`rw'_`cc''/`divideby')*(1/`ppp_calculated');
							};
							if "`ben_`rw'_`cc''"!=""{;
								tempvar int_ben_ppp;
								gen double  `int_ben_ppp'=(`ben_`rw'_`cc''/`divideby')*(1/`ppp_calculated');
							};
								
							/*tempvar int_tax;
							gen double `int_tax'=abs(`tax_`rw'_`cc'');
							tempvar int_ben;
							gen double `int_ben'=`ben_`rw'_`cc'';

							 tempvar int_tax_ppp;
							 gen double  `int_tax_ppp'=(`int_tax'/`divideby')*(1/`ppp_calculated');
							 
							 tempvar int_ben_ppp;
							 gen double  `int_ben_ppp'=(`int_ben'/`divideby')*(1/`ppp_calculated');
							 */
							 
							tempvar `rw'_ppp;
							gen double ``rw'_ppp'=(``rw''/`divideby')*(1/`ppp_calculated');
							tempvar `cc'_ppp;
							gen double ``cc'_ppp'=(``cc''/`divideby')*(1/`ppp_calculated');
							** if (wordcount("`tax_`rw'_`cc''")>0 & wordcount("`ben_`rw'_`cc''")==0) { ;
								** above line was leading to error (issue 50 on Github);
								tempvar ystar_ppp;
								gen double `ystar_ppp'=(`ystar'/`divideby')*(1/`ppp_calculated');
								** } ;
							local row=2;
							
							*noisily di in red "Begin of POV IMPACT EFF. `rw' `cc' Row= `row'";

							*Only taxes MC<0 so harm formula);
							if (wordcount("`tax_`rw'_`cc''")>0 & wordcount("`ben_`rw'_`cc''")==0) {;
								*if wordcount("`ben_`rw'_`cc''")==0) & wordcount("`tax_`rw'_`cc''")>0 {;
								foreach p in `plopts'{;
									if "``p''"!=""{;
										if substr("`p'",1,2)=="pl" {; // these are the PPP lines;
											local _pline = ``p'';
											local vtouse1 ``cc'_ppp';//1 is for original;
											local vtouse2 ``rw'_ppp';//2 is for income without intervention;
											local vtouse3 `ystar_ppp';//3 is for ideal income; 
										};
										else if _`p'_isscalar==1 { ;  // if pov line is scalar, // (note this local defined above);
											local _pline = ``p''; // set `_pline' as that scalar and;
											local vtouse1 ``cc''   ;// use original income variable;
											local vtouse2 ``rw'';//income without intervention;
											local vtouse3 `ystar';//income with ideal intervention;
										};
										else if _`p'_isscalar==0 {; // if pov line is variable,;
											tempvar `v'_normalized1 ; // create temporary variable that is income...;
											tempvar `v'_normalized2 ; // create temporary variable that is income...;
											tempvar `v'_normalized3 ; // create temporary variable that is income...;
											
											qui gen ``v'_normalized1' = ``cc''/``p'' ;// normalized by pov line;   
											qui gen ``v'_normalized2' = ``rw''/``p'' ;// normalized by pov line;
											qui gen ``v'_normalized3' = `ystar'/``p'' ;// normalized by pov line;
											
											local _pline = 1            ;           // and normalized pov line is 1;
											local vtouse1 ``v'_normalized1'; // use normalized income in the calculations;
											local vtouse2 ``v'_normalized2'; // use normalized income in the calculations;
											local vtouse3 ``v'_normalized3'; // use normalized income in the calculations;
										};
			
										tempvar zyzfgt1_1 zyzfgt2_1 zyzfgt1_2 zyzfgt2_2 zyzfgt1_3 zyzfgt2_3 ;   // zyzfgt2_2 added by Rosie on May 21st;
										qui gen `zyzfgt1_1' = max((`_pline'-`vtouse1')/`_pline',0) ;// normalized povety gap of each individual;
										qui gen `zyzfgt2_1' = `zyzfgt1_1'^2 ;                           // square of normalized poverty gap;
										qui gen `zyzfgt1_2' = max((`_pline'-`vtouse2')/`_pline',0) ;// normalized povety gap of each individual;
										qui gen `zyzfgt2_2' = `zyzfgt1_2'^2 ;                           // square of normalized poverty gap;
										qui gen `zyzfgt1_3' = max((`_pline'-`vtouse3')/`_pline',0) ;// normalized povety gap of each individual;
										qui gen `zyzfgt2_3' = `zyzfgt1_3'^2 ;                           // square of normalized poverty gap;
							
										forval i=1/2 {;
											qui summ `zyzfgt`i'_1' `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
											local p`i'_orig=r(mean);
											qui summ `zyzfgt`i'_2' `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
											local p`i'_wo=r(mean);
											qui summ `zyzfgt`i'_3' `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
											local p`i'_3=r(mean);
											
											drop  `zyzfgt`i'_3' `zyzfgt`i'_2' `zyzfgt`i'_1';
							
											****Poverty Impact effectiveness;
											//Marginal contributions for fgt 1,2;
											local mp_`i'_`p'_`rc'=`p`i'_2_wo'-`p`i'_orig'; //Observed MC;
										
											****For Impact effectiveness there can only be a negative effect, we use the harm formula Ch. 5 CEQ Handbook;
											if `mp_`i'_`p'_`rc''<0{;
												ceqtaxharm `pw', endinc(``cc'') taxes(`tax_`rw'_`cc'');
												if r(thwarn) == 1 { ;
													nois `dit' "Sum of `tname_`rw'_`cc'' exceed ``rw'', so impact effectiveness indicator not produced from ``rw'' to ``cc''" ;
									                local warning `warning' "Sum of `tname_`rw'_`cc'' exceed ``rw'', so impact effectiveness indicator not produced from ``rw'' to ``cc''" ;
													local row=`row'+1;	
												} ;
												else { ;			
													tempvar yharm;
													gen double `yharm'=____ytaxharm;
													cap drop ____ytaxharm   ____id_taxharm;
													tempvar yharm_ppp;
													gen `yharm_ppp'=(`yharm'/`divideby')*(1/`ppp_calculated');
									
									
													if "``p''"!="" {	;
														if substr("`p'",1,2)=="pl" {; // these are the PPP lines;
															local _pline = ``p'';
															local vtouseh `yharm_ppp';//h is for harm;
														};
									
														else if _`p'_isscalar==1 { ;  // if pov line is scalar, // (note this local defined above);
															local _pline = ``p''; // set `_pline' as that scalar and;
															local vtouseh `yharm'   ;
														};
														else if _`p'_isscalar==0 {; // if pov line is variable,;
															tempvar `v'_normalizedh ; // create temporary variable that is income...;
															qui gen ``v'_normalizedh' = `yharm'/``p'' ;// normalized by pov line;  
															local _pline = 1            ;           // and normalized pov line is 1;
															local vtouseh ``v'_normalizedh'; // use normalized income in the calculations;					
														};
								
								
														tempvar zyzfgt1_h zyzfgt2_h;
														qui gen `zyzfgt1_h' = max((`_pline'-`vtouseh')/`_pline',0) ;// normalized povety gap of each individual;
														qui gen `zyzfgt2_h' = `zyzfgt1_h'^2 ;                           // square of normalized poverty gap;							
														
														
														qui summ `zyzfgt`i'_h' `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
														local p`i'_h=r(mean);
														
														local mst_p`i'_h=`p`i'_3' - `p`i'_h';//Ideal MC with tax formula;
														local eft_`i'_h=(`mp_`i'_`p'_`rc''/`mst_p`i'_h')*(-1);
														*return scalar eft_`i'_h =  `eft_`i'_h';//Impact effectiveness indicator, v has the variable name of the transfer, y=income, p=poverty line ;
														
														local row=`row'+1;					
														matrix `rw'_ef[`rw_ie_`p'_`i'',`_`cc''] = `eft_`i'_h';

														*noisily di in green "Doing POV IMPACT EFF. TAXES `rw' `cc' Row= `row'";

														/*local row=`row'+1;
														matrix p_ie_`y'[`row',`col'] = `eft_2_h';
														matrix p_se_`y'[`row',`col'] = .;*/
														};
													};
												};
											else{;
												local row=`row'+1;
												matrix `rw'_ef[`rw_ie_`p'_`i'',`_`cc''] =.;
		
											};
										};
			
									};
								};
							};
							*Only Benefits;
							local rowsp=18;
							if wordcount("`tax_`rw'_`cc''")==0 &  wordcount("`ben_`rw'_`cc''")>0{;
								if wordcount("`povlines'")>0 {; // otherwise produces inequality only;
									foreach p in `plopts'  { ;// plopts includes all lines;
										if "``p''"!="" {	;
											if substr("`p'",1,2)=="pl" {; // these are the PPP lines;
												local _pline = ``p'';
												local vtouse1 ``cc'_ppp';//1 is for original;
												local vtouse2 ``rw'_ppp';//2 is for income without intervention;
												local vtouse3 `ystar_ppp';//3 is for ideal income; 
											};
											else if _`p'_isscalar==1 { ;  // if pov line is scalar, // (note this local defined above);
												local _pline = ``p''; // set `_pline' as that scalar and;
												local vtouse1 ``cc''   ;// use original income variable;
												local vtouse2 ``rw'';//income without intervention;
												local vtouse3 `ystar';//income with ideal intervention;
											};
											else if _`p'_isscalar==0 {; // if pov line is variable,;
												tempvar `v'_normalized4 ; // create temporary variable that is income...;  
												tempvar `v'_normalized5 ; // create temporary variable that is income...;
												tempvar `v'_normalized6 ; // create temporary variable that is income...;

												qui gen ``v'_normalized4' = ``cc''/``p'' ;// normalized by pov line;  
												qui gen ``v'_normalized5' = ``rw''/``p'' ;// normalized by pov line;
												/*qui gen ``v'_normalized2' = `ext'/``p'' ;// normalized by pov line;*/
												qui gen ``v'_normalized6' = `ystar'/``p'' ;// normalized by pov line;

												local _pline = 1            ;           // and normalized pov line is 1;
												local vtouse1 ``v'_normalized4'; // use normalized income in the calculations;
												local vtouse2 ``v'_normalized5'; // use normalized income in the calculations;
												local vtouse3 ``v'_normalized6'; // use normalized income in the calculations;

											};
							
							
											tempvar zyzfgt1_1 zyzfgt2_1 zyzfgt1_2 zyzfgt2_2 zyzfgt1_3 zyzfgt2_3;
											qui gen `zyzfgt1_1' = max((`_pline'-`vtouse1')/`_pline',0) ;// normalized povety gap of each individual;
											qui gen `zyzfgt2_1' = `zyzfgt1_1'^2 ;                           // square of normalized poverty gap;
											qui gen `zyzfgt1_2' = max((`_pline'-`vtouse2')/`_pline',0) ;// normalized povety gap of each individual;
											qui gen `zyzfgt2_2' = `zyzfgt1_2'^2 ;                           // square of normalized poverty gap;
											qui gen `zyzfgt1_3' = max((`_pline'-`vtouse3')/`_pline',0) ;// normalized povety gap of each individual;
											qui gen `zyzfgt2_3' = `zyzfgt1_3'^2 ;                           // square of normalized poverty gap;
							
											qui summ `zyzfgt1_1' `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
											local p1_`y'_orig=r(mean);
											qui summ `zyzfgt1_2' `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
											local p1_`y'_2=r(mean);
											qui summ `zyzfgt1_3' `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
											local p1_`y'_3_st=r(mean);
								
											qui summ `zyzfgt2_1' `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
											local p2_`y'_orig=r(mean);
											qui summ `zyzfgt2_2' `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
											local p2_`y'_2=r(mean);
											qui summ `zyzfgt2_3' `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
											local p2_`y'_3_st=r(mean);
										
											drop  `zyzfgt1_3' `zyzfgt1_2' `zyzfgt1_1' `zyzfgt2_3' `zyzfgt2_2' `zyzfgt2_1';
								
											//Marginal contributions for fgt 1,2;
											local mp_1_`p'=`p1_`y'_2'-`p1_`y'_orig';//Observed MC;
											local mp_1_`p'_s=`p1_`y'_2'-`p1_`y'_3_st';//Star MC;
											local mp_2_`p'=`p2_`y'_2'-`p2_`y'_orig';//Observed MC;
											local mp_2_`p'_s=`p2_`y'_2'-`p2_`y'_3_st';//Star MC;
								
								
						
											****Poverty Impact effectiveness;
											****For Impact effectiveness with Transfers there can only be a positive effect;
											forval i=1/2 {;
												if `mp_`i'_`p''>0{;
													*Impact effectiveness;
													*Ystar already exists;
													*local mst_p`i'_h=`p`i'_`y'_3' - `p`i'_h';//Ideal MC with tax formula;
													scalar eft_`i' =  (`mp_`i'_`p''/`mp_`i'_`p'_s');//MC/MCstar;
													
													local row=`row'+1;
													matrix `rw'_ef[`rw_ie_`p'_`i'',`_`cc''] = eft_`i';	
																

													local rowsp=`rowsp'+1;

													****Poverty Spending effectiveness;
													tempvar bentouse;
													gen double `bentouse'=abs(`vtouse1'-`vtouse2');
													//! Uncomment out once fixed
													****Poverty Spending effectiveness;
													*tempvar bentouse;
													cap drop ___bentouse;
													gen double ___bentouse=abs(`vtouse1'-`vtouse2');
													//! Uncomment after fixed.
													cap drop ___t ; 
													gen double ___t = `vtouse2'+  abs(`bentouse') ; 
													covconc ``cc'' `pw' ; 
													local gini1 = r(gini) ; 
													covconc ``rw'' `pw' ; 
													local gini2 = r(gini) ;
													if abs((`gini1' - `gini2')/`gini1') < 0.009 { ;
														nois `dit' "Difference beween starting and ending Ginis is too small. Poverty spending effectiveness indicator for ``cc'' to ``rw'' is not produced" ;
										                local warning `warning' `dit' "Difference beween starting and ending Ginis is too small. Poverty spending effectiveness indicator for  ``cc'' to ``rw'' is not produced" ;
													} ;

													else { ;
							
														ceqbensp  `pw', startinc(`vtouse2') ben(`bentouse') zz(`_pline') obj1(`p1_`y'_orig') obj2(`p2_`y'_orig');	
														local dip = r(sp_ef_pov_`i') ;
														if "`p1_`y'_orig'" ! = "" { ;
															local squared = 1  ;
														} ;
														else if "`p2_`y'_orig'" != "" { ;
															local squared = 2 ;
														} ;

														matrix `rw'_ef[`rw_se_`p'_`i'',`_`cc''] = r(sp_ef_pov_`i');	

													} ;
												};
												else{;
													local row=`row'+1;
													matrix `rw'_ef[`rw_ie_`p'_`i'',`_`cc''] = .;			
													local rowsp=`rowsp'+1;
													matrix `rw'_ef[`rw_se_`p'_`i'',`_`cc''] = .;
												};
												*noisily di in green "Doing POV IMPACT EFF. BEN `rw' `cc' Row= `row'";

								
											};
		
										};
		
									};
								};
							};
		
							*noisily di in red "End of POV IMPACT EFF. `rw' `cc' Row= `row'";
						};
		
						*SPENDING EFFECTIVENESS FOR INEQUALITY;
						
						local row=17;
						*Only TAXES with  MC>0 , with poverty it never happens with taxes;
						
						if wordcount("`tax_`rw'_`cc''")>0 & wordcount("`ben_`rw'_`cc''")==0{;
							_ceqmcid `pw', inc(``cc'') sptax(`tax_`rw'_`cc'') ;
							*If Marg. Cont. is negative, SE is missing;
							if r(mc_ineq)<0{;
								matrix `rw'_ef[17,`_`cc''] = .;
							};
							else{;
								cap drop ___t ; 
								gen double ___t = ``rw'' + abs(`tax_`rw'_`cc'') ; 
								covconc ___t `pw' ; 
								local gini1 = r(gini) ; 
								covconc ``rw'' `pw' ; 
								local gini2 = r(gini) ;
								if abs((`gini1' - `gini2')/`gini1') < 0.009 { ;
									nois `dit' "Difference beween starting and ending Ginis is too small. Spending effectiveness indicator for ``cc'' to ``rw'' is not produced" ;
									local warning `warning' `dit' "Difference beween starting and ending Ginis is too small. Spending effectiveness indicator for ``cc'' to ``rw'' is not produced" ;
																	
								} ;

								else { ;
									_ceqspend `pw',inc(``cc'') sptax(`tax_`rw'_`cc'');
									local spef=r(sp_ef);
									matrix `rw'_ef[17,`_`cc''] =`spef';
								} ;
							};
						};
						
		
		
						*Only TRANSFERS with  MC>0 ;

						if wordcount("`tax_`rw'_`cc''")==0 & wordcount("`ben_`rw'_`cc''")>0{;
							*Spending Effectiveness;
							_ceqmcid `pw', inc(``cc'') spben(`ben_`rw'_`cc'') ;
							*If Marg. Cont. is negative, SE is missing;
							if r(mc_ineq)<0{;
								matrix `rw'_ef[17,`_`cc''] = .;
							};
							else{;
								cap drop ___t ; 
								gen double ___t = ``rw'' - abs(`ben_`rw'_`cc'') ; 
								covconc ___t `pw' ; 
								local gini1 = r(gini) ; 
								covconc ``rw'' `pw' ; 
								local gini2 = r(gini) ;
								if abs((`gini1' - `gini2')/`gini1') < 0.009 { ;
									nois `dit' "Difference beween starting and ending Ginis is too small. Spending effectiveness indicator for ``cc'' to ``rw'' is not produced" ;
									local warning `warning' `dit' "Difference beween starting and ending Ginis is too small. Spending effectiveness indicator for ``cc'' to ``rw'' is not produced" ;
										
								} ;

								else { ;
								*set trace on ;
									_ceqspend `pw',inc(``cc'') spben(`ben_`rw'_`cc'');
									*set trace off;
									local spef=r(sp_ef);
									matrix `rw'_ef[17,`_`cc''] =`spef';
								} ;

							};
						};
						*Beckerman Imervoll Effectiveness Indicators (row 2 to 30);
						local row=33;
						*noisily di in red "Begin of BECK EFF. `rw' `cc' Row= `row'";
						// line 1608 to 1621 updated by Rosie on May 3rd, 2017;
						foreach p in `plopts'{;
							if "``p''"!=""{;
								if substr("`p'",1,2)!="pl" {; // these are the national PL;
									if _`p'_isscalar==1 { ; 
										local z= (``p''/`divideby')*(1/`ppp_calculated');
									};
									else if _`p'_isscalar==0 {;
										tempvar z;
										qui gen `z'= (``p''/`divideby')*(1/`ppp_calculated');
									};
								};	
								if substr("`p'",1,2)=="pl" {; // these are the national PL;
									local z= ``p'';
								};	
						
								ceqbeck `aw' ,preinc(``rw'_ppp') postinc(``cc'_ppp') zline(`z');
								local rowbk=`rbk_`p'';
								matrix `rw'_ef[`rowbk',`_`cc'']=r(VEE);//Vertical Expenditure Efficiency;
								local rowbk=`rowbk'+1;
								matrix `rw'_ef[`rowbk',`_`cc'']=r(Spill);//Spillover Index;
								local rowbk=`rowbk'+1;
								matrix `rw'_ef[`rowbk',`_`cc'']=r(PRE);//Poverty Reduction Efficiency;
								local rowbk=`rowbk'+1;
								matrix `rw'_ef[`rowbk',`_`cc'']=r(PGE);//Poverty Gap Efficiency;
								local rowbk=`rowbk'+1;	
							};
							else{;
								local row=`row'+4;
							};
						};
						*noisily di in red "End of BECK EFF. `rw' `cc' Row= `row'";

						*FI/FGP (row 62 to  to 82);
						local row=62;
						*noisily di in red "Begin of FI/FGP EFF. `rw' `cc' Row= `row'";

						****TAXES AND TRANSFERS for R and N;
						if "`tax_`rw'_`cc''"!=""{;
							tempvar taxesef;
							gen double `taxesef'=abs((`tax_`rw'_`cc''/`divideby')*(1/`ppp_calculated'));
						};
						if "`ben_`rw'_`cc''"!=""{;
							tempvar benef;
							gen double `benef'=(`ben_`rw'_`cc''/`divideby')*(1/`ppp_calculated');
						};
			
						local yes= wordcount("`tax_`rw'_`cc''")+wordcount("`ben_`rw'_`cc''");
						if `yes'>0{; //ESTIMATE EFFECTIVENESS INDICATORS FOR CASES THAT APPLY;
							foreach p in `plopts'{;
								if "``p''"!=""{;
									if substr("`p'",1,2)!="pl" {; // these are the national PL;
										local z= (``p''/`divideby')*(1/`ppp_calculated');
									};	
									if substr("`p'",1,2)=="pl" {; // these are the national PL;
										local z= ``p'';
									};
									*FI/FGP effectiveness;
									
									if wordcount("`tax_`rw'_`cc''")>0 & wordcount("`ben_`rw'_`cc''")>0{;
										_fifgpmc `aw',taxes(`taxesef') benef(`benef') startinc(``rw'_ppp') endinc(``cc'_ppp') z(`z');
										local rowfi=`rfi_`p'';
										matrix `rw'_ef[`rowfi',`_`cc'']=r(MCEF_t);
										local rowfi=`rowfi'+1;
										matrix `rw'_ef[`rowfi',`_`cc'']=.;
										local rowfi=`rowfi'+1;
										matrix `rw'_ef[`rowfi',`_`cc'']=.;
										local rowfi=`rowfi'+1;
						
									};
									if wordcount("`tax_`rw'_`cc''")>0 & wordcount("`ben_`rw'_`cc''")==0{;
									*noisily di in green "HEEEEEEEEEEEEEEREEEEE" in red "`rw' to `cc'";


										_fifgpmc `aw',taxes(`taxesef') startinc(``rw'_ppp') endinc(``cc'_ppp') z(`z');
										local rowfi=`rfi_`p'';
										matrix `rw'_ef[`rowfi',`_`cc'']=r(MCEF_t);
										local rowfi=`rowfi'+1;
										matrix `rw'_ef[`rowfi',`_`cc'']=.;
										local rowfi=`rowfi'+1;
										matrix `rw'_ef[`rowfi',`_`cc'']=.;
										local rowfi=`rowfi'+1;
						
				

										*noisily di r(MCEF_t);
										*noisily di r(MCEF_pc);
										*noisily di r(MCEF_n);
									};
									if wordcount("`tax_`rw'_`cc''")==0 & wordcount("`ben_`rw'_`cc''")>0{;
										_fifgpmc `aw', benef(`benef') startinc(``rw'_ppp') endinc(``cc'_ppp') z(`z');
										local rowfi=`rfi_`p'';
										matrix `rw'_ef[`rowfi',`_`cc'']=r(MCEF_t);
										local rowfi=`rowfi'+1;
										matrix `rw'_ef[`rowfi',`_`cc'']=.;
										local rowfi=`rowfi'+1;
										matrix `rw'_ef[`rowfi',`_`cc'']=.;
										local rowfi=`rowfi'+1;
								
										*noisily di in green "FI/FGP INCOME COL:`cc':`_`cc'', row: `row', real col: `_`cc''";
									};
								};
								**else{;
								**local row=`row'+3;
								**};
							};
						};
		
						*noisily di in red "End of FI/FGP EFF. `rw' `cc' Row= `row'";

					};
			};
				*noisily matrix list `rw'_ef;
		};
	};
	
	
	****************
	* SAVE RESULTS *
	****************;
		if `"`using'"'!="" {; // "
			`dit' `"Writing to "`using'", may take several minutes"';
		
			if "`sheet'"=="" local sheet=`"E9. Effectiveness"';	
			*Rows for core income concept results;	
			/*local r_m=11;
			local r_mp=64;
			local r_n=117;
			local r_g=170;
			local r_t=223;
			local r_d=276;
			local r_c=329;
			local r_f=382;*/
			
			local r_m=11;
			local r_mp=95;
			local r_n=179;
			local r_g=263;
			local r_t=347;
			local r_d=431;
			local r_c=515;
			local r_f=599;
			foreach y of local 	alllist{;
			qui	putexcel D`r_`y''=matrix(`y'_ef) using `"`using'"',keepcellformat modify sheet("`sheet'") ; // "

			};
		local date `c(current_date)';		
		local titlesprint;
		local titlerow = 3;
		local titlecol = 1;
		local titlelist country surveyyear authors date ppp baseyear cpibase cpisurvey ppp_calculated scenario group project;

		foreach title of local titlelist {;
			returncol `titlecol';
			if "``title''"!="" & "``title''"!="-1" 
				local  titlesprint `titlesprint' `r(col)'`titlerow'=("``title''");
			local titlecol = `titlecol' + 1;
		};
				qui putexcel `titlesprint'  using `"`using'"', modify keepcellformat sheet("`sheet'"); 

			qui	putexcel A4=("Results produced by version `version' of `command' on `c(current_date)' at `c(current_time)'") using `"`using'"',  modify keepcellformat  sheet("`sheet'");   // "

			
		
		};
    ********
    * OPEN *
    ********;
		if "`open'"!="" & "`c(os)'"=="Windows" {;
			shell start `using'; // doesn't work with "" or `""' so I already changed `open' to "" if using has spaces, ;
		};
		else if "`open'"!="" & "`c(os)'"=="MacOSX" {;
			shell open `using';
		};
		else if "`open'"!="" & "`c(os)'"=="Unix" {;
			shell xdg-open `using';
		};
	
	************
	* CLEAN UP *
	************;
		quietly putexcel clear;
		restore;
	
	
	
	end;	// END ceqef;

	
