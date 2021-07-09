* ADO FILE FOR EFFECTIVENESS SHEET OF CEQ OUTPUT TABLES

* VERSION AND NOTES (changes between versions described under CHANGES)
*! v1.12 31may201p For use with Aug 2017 version of Output Tables
** v1.11 11feb2017 For use with Aug 2017 version of Output Tables
** v1.10 04dec2017 For use with Aug 2017 version of Output Tables
** v1.9 28nov2017 For use with Aug 2017 version of Output Tables
** v1.8 23oct2017 For use with Aug 2017 version of Output Tables
** v1.7 12oct2017 For use with Aug 2017 version of Output Tables
** v1.6 07sept2017 For use with Aug 2017 version of Output Tables
** v1.5 21may2017 For use with Apr 2017 version of Output Tables
** v1.4 03Jan2016 For use with Feb 2016 version of Output Tables
** (beta version; please report any bugs), written by Rodrigo Aranda raranda@tulane.edu

* CHANGES
*  v1.1 Added Poverty options as well as cleaned some bugs 
*  v1.2 Added Beckerman Imervoll, FI/FGP indicators
*  v1.3 Fixed bugs for Beckerman Imervoll and spending effectiveness
*  v1.5 Add version print to excel MWB 
*		Remove income concept from the result and title local since no result is produced for income concept itself
*		Change the way fiscal impoverishemnt was calculated
*		Remove the warning about negative tax values
*		Option flexibilty 
* v1.6  Modified ceqtaxstar, ceqbenstar acording to changes in ceqef. Replaced covgini with 
*		with covconc.
* v1.7  Including warnings for programs that are all 0s. Fixing defitions of incomes w/ & w/o program,
*		specifically for taxes. Including modified ceq
* v1.8  Fixing warning to include all programs by creating and extract variable labels for tempvars
*		having _ceqspend return missing until we fix the function.
* v1.9  Change tempvars in the main for loop starting at line 1963 to normal variables with "___" prefix and manual removing these variables after
*		in order to prevent a variable build up that causes Stata software with a lower memory capacity to error.
* v1.10 Include error for when fiscal intervention variables aren't included.
* v1.11 Modified version _ceqspend based on Ali's formula
* v1.12 Solved issue #61 in github
* NOTES
* 

* TO DO
    
** NOTES



** TO DO

*************************
** PRELIMINARY PROGRAMS *
*************************
// BEGIN returncol (Higgins 2015) 
//  Returns Excel column corresponding to a number
cap program drop returncol
program define returncol, rclass
	confirm integer number `1'
	mata: st_strscalar("col",numtobase26(`1'))
	return local col = col
end // END returncol

#delimit cr

// covgini has been replaced with covconc

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
			*nois assert abs((`tot' - r(sum))/`tot') < 0.0001
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

		if ( `tot' > r(sum) | `tot' == 0 ) { ;
			if `tot' > r(sum) return scalar th_gr = 1
			if `tot' == 0 return scalar th_0 = 1
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
			assert (abs((`tax1'-`tax2')/`tax1') < 0.0001)

			cap drop ____id_taxharm
			cap drop ____ytaxharm
			gen double ____id_taxharm=___taxed
			gen double ____ytaxharm=___new_inc
			return scalar thwarn = 0

			cap drop ___id ___notax ___inc_wght ___cum_inc_wght ___taxed ___last_taxed ___new_inc

		}
		cap drop  ___taxes ___notax ___ww
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
			*nois assert round(`tot',.1) == round(r(sum),.1)
			*nois assert abs((`tot' - r(sum))/`tot') < 0.0001
			
			
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
*quietly {
tempvar difference
gen double `difference' = `postinc'-`preinc'
tempvar pre_shortfall
gen double `pre_shortfall' = `zline' - `preinc'
tempvar post_shortfall
gen double `post_shortfall' = `zline' - `postinc'

sum `difference' [`weight' =`exp'] if `preinc' < `zline'
scalar AB = r(sum)
summarize `difference' [`weight' =`exp']
scalar ABC = r(sum)
summarize `post_shortfall' [`weight' =`exp'] if `preinc' < `zline' & `postinc'>= `zline'
scalar B = -r(sum)
summarize `difference' [`weight'= `exp'] if `postinc' <  `zline'
scalar A1 = r(sum)
summarize `pre_shortfall' [`weight' =`exp'] if `preinc' <  `zline' & `postinc' >= `zline'
scalar A2 = r(sum)
scalar A = A1 + A2
summarize `pre_shortfall' [`weight' =`exp'] if `preinc' < `zline'
scalar AD = r(sum)
scalar VEE = AB/ABC
scalar Spillover = B/AB
scalar PRE = A/ABC
scalar PGE = A/AD

return scalar VEE=VEE
return scalar Spill = Spillover
return scalar PRE = PRE
return scalar PGE = PGE
*}

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
		local ww `exp' //weights
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
			covconc `inc' [pw=`exp']
			local g_f=r(gini)
			covconc `o_inc' [pw=`exp']
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
			qui sum `pov`f'_o' [aw = `exp']
			local p`f'_o=r(mean)
	
			qui sum `pov`f'_f' [aw = `exp']
			local p`f'_f=r(mean)
			local mc`f'=`p`f'_o'-`p`f'_f'
			return scalar mc_p`f'=`mc`f'' //Marginal Contribution of poverty fgt:`f'
			}
		}
		end
			
#delimit cr
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
	tempvar tax1 ben1
	if wordcount("`taxes'")>0{
		gen `tax1'=`taxes'
	}
	if wordcount("`taxes'")==0{
		gen `tax1'=0
	}
	if wordcount("`benef'")>0{

gen `ben1'=`benef'
}
if wordcount("`benef'")==0{
gen `ben1'=0

}
	tempvar notax noben
	qui gen double `notax'=`endinc'+`tax1'
	qui gen double `noben'=`endinc'-`ben1'
	
	*total taxes and transfers;
	qui sum `tax1' [`weight' `exp']
	local T=r(sum)
	qui sum `ben1' [`weight' `exp']
	local B=r(sum)
	local TB=`T'+`B'
	
	tempvar  d_fi d_fg // d_fi_t d_fg_b
	 //lines below commented out by Rosie Li on May 16, 2017 after consulting with Rodrigo Aranda;
	 
	qui gen `d_fi' = min(`startinc',`z') - min(`startinc',`endinc',`z') 
	*qui gen `d_fi_t' = min(`notax',`z') - min(`notax',`endinc',`z')   
	qui gen `d_fg' = min(`endinc',`z') - min(`startinc',`endinc',`z') 
	*qui gen `d_fg_b' = min(`endinc',`z') - min(`noben',`endinc',`z')
	
	foreach v in fi /*fi_t */  fg /* fg_b*/ { 
	qui summ `d_`v'' [`weight' `exp'], meanonly
			local t_`v' = r(sum)
			local pc_`v' = r(mean)
			local n_`v' = r(mean)/`z'
	}
	*Marginal contributions
	foreach m in t pc n{
		if wordcount("`taxes'")>0{

			*local `m'_mc_t=/* ``m'_fi'- */ ``m'_fi_t'
			local `m'_mc = ``m'_fi'
			local mceft_`m'=(`T'/`TB')*(1-(``m'_mc'/`T'))
			local MCEF_`m'=`mceft_`m''
			*scalar MCEF_`m'=`mceft_`m''
			return scalar MCEF_`m' = `mceft_`m''
		}
		if wordcount("`benef'")>0{
			*local `m'_mc_b=``m'_fg_b' /*-``m'_fg' */
			local `m'_mc = ``m'_fg'
			local mcefb_`m'=(`B'/`TB')*((``m'_mc'/`B'))
			local MCEF_`m' = `mcefb_`m''
			*scalar MCEF_`m'=`mcefb_`m''
			return scalar MCEF_`m' = `mcefb_`m''			
		}
		
			**if wordcount("``m'_mc_t'")==0 local mceft_`m'=0
			**if  wordcount("``m'_mc_b'")==0 local mcefb_`m'=0
			
			**else{
			**scalar MCEF_`m'=.
			**return scalar MCEF_`m' = . 
			**	}
	}
end // END _fifgpmc	
*********************
* ceqefext PROGRAM *
*********************

capture program drop ceqefext
program define ceqefext
version 13.0
	#delimit ;
	syntax 
		[using]
		[if] [in] [pweight] 
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
			OPEN
			*
		]
	;
	#delimit cr
	
	***********
	** LOCALS *
	***********
	** general programming locals
	local dit display as text in smcl
	local die display as error in smcl
	local command ceqefext
	local version 1.11
	`dit' "Running version `version' of `command' on `c(current_date)' at `c(current_time)'" _n "   (please report this information if reporting a bug to sean.higgins@ceqinstitute.org and marc.brooks@ceqinstitute.org)"
	
	** income concept options
	#delimit ;
	local inc_opt
		market
		mpluspensions
		netmarket
		gross
		taxable
		disposable
		consumable
		final
	;
	#delimit cr
	local inc_opt_used ""
	foreach incname of local inc_opt {
		if "``incname''"!="" local inc_opt_used `inc_opt_used' `incname' 
	}
	local list_opt2 ""
	foreach incname of local inc_opt_used {
		local `incname'_opt "`incname'(``incname'')" // `incname' will be e.g. market
			// and ``incname'' will be the varname 
		local list_opt2 `list_opt2' `incname'2(``incname'') 
	}
	
	** negative incomes
	foreach v of local inc_opt {
		if "``v''"!="" {
			qui count if ``v''<0 // note `v' is e.g. m, ``v'' is varname
			if r(N) `dit' "Warning: `r(N)' negative values of ``v''"
		}
	}	
	
	local counter=1
	local n_inc_opts = wordcount("`inc_opt_used'")
	foreach incname of local inc_opt_used {
		// preliminary: 
		//	to open only on last iteration of _ceqdomext,
		//  only print warnings and messages once
		if "`open'"!="" & `counter'==`n_inc_opts' {
			local open_opt "open"
		}
		else {
			local open_opt ""
		}
		if `counter'==1 {
			local nodisplay_opt "" 
		}
		else {
			local nodisplay_opt "nodisplay"
		}
		
		local ++counter
	
		_ceqefext `using' `if' `in' [`weight' `exp'], ///
			``incname'_opt' `list_opt2' `options' `open_opt' `nodisplay_opt' ///
			_version("`version'") 
	}
end

** For sheet E14. Effectiveness
// BEGIN ceqefext
// BEGIN _ceqefext (Aranda 2016)
capture program drop _ceqefext  
program define _ceqefext, rclass 
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
			/* REPEAT FOR CONCENTRATION MATRIX */
			/* (temporary hack-y patch) */
			market2(varname)
			mpluspensions2(varname)
			netmarket2(varname) 
			gross2(varname)
			taxable2(varname)
			disposable2(varname) 
			consumable2(varname)
			final2(varname)
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
			sheetm(string)
			sheetmp(string)
			sheetn(string)
			sheetg(string)
			sheett(string)
			sheetd(string)
			sheetc(string)
			sheetf(string)
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
			
			BASEyear(real -1)
			/* OTHER OPTIONS 
			NODecile
			NOGroup
			NOCentile
			NOBin
			*/
			NODIsplay
			_version(string)
		]
	;
	#delimit cr
		
	***********
	** LOCALS *
	***********
	** general programming locals
	local dit if "`nodisplay'"=="" display as text in smcl
	local die display as error in smcl
	local command ceqefext
	local version `_version'
	
	
	** income concepts
	local m `market'
	local mp `mpluspensions'
	local n `netmarket'
	local g `gross'
	local t `taxable'
	local d `disposable'
	local c `consumable'
	local f `final'
	local m2 `market2'
	local mp2 `mpluspensions2'
	local n2 `netmarket2'
	local g2 `gross2'
	local t2 `taxable2'
	local d2 `disposable2'
	local c2 `consumable2'
	local f2 `final2'
	local alllist m mp n g t d c f
	local alllist2 m2 mp2 n2 g2 t2 d2 c2 f2
	local incomes = wordcount("`alllist'")
	
	local origlist m mp n g d
	tokenize `alllist' // so `1' contains m; to get the variable you have to do ``1''
	local varlist ""
	local varlist2 ""
	local counter = 1
	
	foreach y of local alllist {
		local varlist `varlist' ``y'' // so varlist has the variable names
		local varlist2 `varlist2' ``y'2'
		// reverse tokenize:
		local _`y' = `counter' // so _m = 1, _mp = 2 (regardless of whether these options included)
		if "``y''"!="" local `y'__ `y' // so `m__' is e.g. m if market() was specified, "" otherwise
		local ++counter
	}
	
	local d_m      = "Market Income"
	local d_mp     = "Market Income + Pensions"
	local d_n      = "Net Market Income"
	local d_g      = "Gross Income"
	local d_t      = "Taxable Income"
	local d_d      = "Disposable Income"
	local d_c      = "Consumable Income"
	local d_f      = "Final Income"
	
	foreach y of local alllist {
		if "``y''"!="" {
			scalar _d_``y'' = "`d_`y''"
		}
	}
	
	
	** transfer and tax categories
	local taxlist dtaxes contribs indtaxes
	local transferlist pensions dtransfers subsidies health education otherpublic
	local programlist  pensions dtransfers dtaxes contribs subsidies indtaxes health education otherpublic
	foreach x of local programlist {
		local allprogs `allprogs' ``x'' // so allprogs has the actual variable names
	}

	** Making sure fiscal intervention options are specificied.
	if  wordcount("`pensions' `dtransfers' `dtaxes' `contribs' `subsidies' `indtaxes' `health' `education' `otherpublic'") == 0 {
		`die' "At least one fiscal intervention option must be specified for ceqefext to function."
		 exit
	}
	
	** weight (if they specified hhsize*hhweight type of thing)
	if strpos("`exp'","*")> 0 { // TBD: what if they premultiplied w by hsize?
		`die' "Please use the household weight in {weight}; this will automatically be multiplied by the size of household given by {bf:hsize}"
		exit
	}
	
	** hsize and hhid
	if wordcount("`hsize' `hhid'")!=1 {
		`die' "Must exclusively specify {bf:hsize} (number of household members for household-level data) or "
		`die' "{bf:hhid} (unique household identifier for individual-level data)"
		exit 198
	}
	
	* ppp conversion
	if (`ppp'==-1 & `cpisurvey'==-1 & `cpibase'==-1) {
		local _ppp = 0
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
	
	************************
	** PRESERVE AND MODIFY *
	************************
	preserve
	if wordcount("`if' `in'")!=0 quietly keep `if' `in'
	
	** collapse to hh-level data
	if "`hsize'"=="" { // i.e., it is individual-level data
		tempvar members
		sort `hhid'
		qui bys `hhid': gen `members' = _N // # members in hh 
		qui bys `hhid': drop if _n>1 // faster than duplicates drop
		local hsize `members'
	}
	
	***********************
	** SVYSET AND WEIGHTS *
	***********************
	cap svydes
	scalar no_svydes = _rc
	if !_rc qui svyset // gets the results saved in return list
	if "`r(wvar)'"=="" & "`exp'"=="" {
		`dit' "Warning: weights not specified in svydes or the command"
		`dit' "Hence, equal weights (simple random sample) assumed"
	}
	else {
		if "`exp'"=="" & "`r(wvar)'"!="" local w `r(wvar)'
		if "`exp'"!="" local w `exp'
		if "`w'"!="" {
			tempvar weightvar
			qui gen double `weightvar' = `w'*`hsize'
			local w `weightvar'
		}
		else local w "`hsize'"
		
		if "`w'"!="" {
			local pw "[pw = `w']"
			local aw "[aw = `w']"
		}
		if "`exp'"=="" & "`r(wvar)'"!="" {
			local weight "pw"
			local exp "`r(wvar)'"
		}
	}
	else if "`r(su1)'"=="" & "`psu'"=="" {
		di as text "Warning: primary sampling unit not specified in svydes or the d1 command's psu() option"
		di as text "P-values will be incorrect if sample was stratified"
	}
	if "`psu'"=="" & "`r(su1)'"!="" {
		local psu `r(su1)'
	}
	if "`strata'"=="" & "`r(strata1)'"!="" {
		local strata `r(strata1)'
	}
	if "`strata'"!="" {
		local opt strata(`strata')
	}
	** now set it:
	if "`exp'"!="" qui svyset `psu' `pw', `opt'
	else           qui svyset `psu', `opt'
	
	************************
	** PRESERVE AND MODIFY *
	************************
	
	** poverty lines
	local povlines `pl1' `pl2' `pl3' `nationalextremepl' `nationalmoderatepl' `otherextremepl' `othermoderatepl'
	*rows foreach poverty line:
	*For Impact Ef. and Spending Ef
	local ref_pl1_1=1
	local ref_pl1_2=2
	local ref_pl2_1=3
	local ref_pl2_2=4
	local ref_pl3_1=5
	local ref_pl3_2=6
	local ref_nationalextremepl_1=7
	local ref_nationalextremepl_2=8
	local ref_nationalmoderatepl_1=9
	local ref_nationalmoderatepl_2=10
	local ref_otherextremepl_1=11
	local ref_otherextremepl_2=12
	local ref_othermoderatepl_1=13
	local ref_othermoderatepl_2=14
	*For FI/FGP
	local rfi_pl1=3
	local rfi_pl2=8
	local rfi_pl3=13
	local rfi_nationalextremepl=18
	local rfi_nationalmoderatepl=23
	local rfi_otherextremepl=28
	local rfi_othermoderatepl=33
	*For Beckerman Imervoll
	local rbk_pl1=1
	local rbk_pl2=5
	local rbk_pl3=9
	local rbk_nationalextremepl=13
	local rbk_nationalmoderatepl=17
	local rbk_otherextremepl=21
	local rbk_othermoderatepl=25
	
	
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
	
	// ! Added the below chunk of code
	foreach pl of local plopts {
		if "``pl''"!="" {
			if _`pl'_isscalar == 0 {
				local pl_tokeep `pl_tokeep' ``pl''
			}
		}
	}
	
	local relevar `varlist2' `allprogs' ///
				  `w' `psu' `strata' ///
				  `pl_tokeep' 
	quietly keep `relevar' 
	
	** missing income concepts
	foreach var of local varlist2 {
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
			}
		}
	}
	
	** missing fiscal interventions 
	foreach var of local allprogs {
		if "`varlist'"=="`market'" {   // so that it only runs once 
			qui count if missing(`var') 
			if "`ignoremissing'"=="" {
				if r(N) {
					`die' "Missing values not allowed; `r(N)' missing values of `var' found"
					`die' "For households that did not receive/pay the tax/transfer, assign 0"
					exit 198
				}
			}
			else {
				if r(N) {
				qui drop if missing(`var')
				di "Warning: `r(N)' observations that are missing `var' were dropped because the user specified {bf:ignoremissing}"
				}
			}
		} 
	}
	
	** columns including disaggregated components and broader categories
	local broadcats dtransfersp dtaxescontribs inkind alltaxes alltaxescontribs alltransfers 
	local dtransfersp `pensions' `dtransfers' 
	local dtaxescontribs `dtaxes' `contribs'
	local inkind `health' `education' `otherpublic' // these contain the variables, or blank if not specified
	local alltransfers `dtransfers' `subsidies' `inkind'
	local alltransfersp
	local alltaxes `dtaxes' `indtaxes'
	local alltaxescontribs `dtaxes' `contribs' `indtaxes'
	
	
	
	foreach cat of local programlist {
		if "``cat''"!="" {
			tempvar v_`cat' // in the locals section despite creating vars
			qui gen `v_`cat''=0 // because necessary for local programcols
			label variable `v_`cat'' "`cat'"
			foreach x of local `cat' {
				qui replace `v_`cat'' = `v_`cat'' + `x' // so e.g. v_dtaxes will be sum of all vars given in dtaxes() option
			}
				// so suppose there are two direct taxes dtr1, dtr2 and two direct taxes dtax1, dtax2
				// then `programcols' will be dtr1 dtr2 dtransfers dtax1 dtax2 dtaxes
		}	
	}
	foreach bc of local broadcats {
		if wordcount("``bc''")>0 { // i.e. if any of the options were specified; for bc=inkind this says if any options health education or otherpublic were specified
			tempvar v_`bc'
			qui gen `v_`bc'' = 0
			label variable `v_`bc'' "`bc'"
			foreach var of local `bc' { // each element will be blank if not specified
				qui replace `v_`bc'' = `v_`bc'' + `var'
			}
		}
	}	

	#delimit ;
	local programcols 
		`pensions' `v_pensions'
		`dtransfers' `v_dtransfers' `v_dtransfersp'
		`dtaxes' `contribs' `v_dtaxescontribs'
		`subsidies' `v_subsidies' `indtaxes' `v_indtaxes'
		`v_alltaxes' `v_alltaxescontribs'
		`health' `education' `otherpublic' `v_inkind'
		`v_alltransfers' `v_alltransfersp'
	;
	local transfercols 
		`pensions' `v_pensions'
		`dtransfers' `v_dtransfers' `v_dtransfersp'
		`subsidies' `v_subsidies'
		`health' `education' `otherpublic' `v_inkind'
		`v_alltransfers' `v_alltransfersp'
	;
	local taxcols: list programcols - transfercols; // set subtraction;
	#delimit cr

	** labels for fiscal intervention column titles
	foreach pr of local allprogs { // allprogs has variable names already
		local d_`pr' : var label `pr'
		if "`d_`pr''"=="" { // ie, if the var didnt have a label
			local d_`pr' `pr'
			`dit' "Warning: variable `pr' not labeled"
		}
		scalar _d_`pr' = "`d_`pr''"
	}
	scalar _d_`v_pensions'         = "All contributory pensions"
	scalar _d_`v_dtransfers'       = "All direct transfers excluding contributory pensions"
	scalar _d_`v_dtransfersp'      = "All direct transfers including contributory pensions"
	scalar _d_`v_contribs'         = "All contributions"
	scalar _d_`v_dtaxes'           = "All direct taxes"
	scalar _d_`v_dtaxescontribs'   = "All direct taxes and contributions"
	scalar _d_`v_subsidies'        = "All indirect subsidies"
	scalar _d_`v_indtaxes'         = "All indirect taxes"
	scalar _d_`v_health'           = "All health"
	scalar _d_`v_education'        = "All education"
	scalar _d_`v_otherpublic'      = "All other public spending" // LOH need to fix that this is showing up even when I don't specify the option
	scalar _d_`v_inkind'           = "All in-kind"
	scalar _d_`v_alltransfers'     = "All transfers and subsidies excluding contributory pensions"
	scalar _d_`v_alltransfersp'    = "All transfers and subsidies including contributory pensions"
	scalar _d_`v_alltaxes'         = "All taxes"
	scalar _d_`v_alltaxescontribs' = "All taxes and contributions"
	
	** results
	local supercols totLCU 
	foreach y of local alllist {
		if "``y''"!="" local supercols `supercols' fi_`y'
	}
	
	** titles 
	local _totLCU   = "Effectiveness"
	
	foreach v of local alllist {
		local uppered = upper("`d_`v''")
		local _fi_`v' = "EFFECTIVENESS WITH RESPECT TO `uppered'"
	}
	
	******************
	** PARSE OPTIONS *
	******************
	
	
	** ado file specific
	foreach vrank of local alllist {
		if "`sheet`vrank''"=="" {
			if "`vrank'"=="mp" local sheet`vrank' "E14.m+p Effectiveness"
			else {
				local sheet`vrank' "E14.`vrank' Effectiveness" // default name of sheet in Excel files
			}
		}
	}
	
	** make sure using is xls or xlsx
	ceq_parse_using using `"`using'"', cmd("ceqefext") open("open")
	
	** create new variables for program categories

	if wordcount("`allprogs'")>0 ///
	foreach pr of local taxcols {
		qui summ `pr', meanonly
		if r(mean)>0 {
			if wordcount("`postax'")>0 local postax `postax', `x'
			else local postax `x'
			qui replace `pr' = -`pr' // replace doesnt matter since we restore at the end
		}
	}
	/* if wordcount("`postax'")>0 {
		`dit' "Taxes appear to be positive values for variable(s) `postax'; replaced with negative for calculations"
	} */
	
	/*foreach y of local alllist {
		local marg`y' ``y''
	}	*/
	** create extended income variables
	*set trace on 
	foreach pr in `pensions' `v_pensions' { // did it this way so if they're missing loop is skipped over, no error
		foreach y in `m__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y''+`pr'
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=abs(`pr')
			scalar _d_``y'_`pr'' =  _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local int`y' `int`y'' `o_`y'_`pr''
			local id`o_`y'_`pr'' "ben"
			qui gen ywo_`o_`y'_`pr'' = ``y''
			qui gen yw_`o_`y'_`pr''  = ``y'' + `o_`y'_`pr''
			local n_`pr' : variable label `pr'
			if "`n_`pr''" != "" {
				local name_`y'_`o_`y'_`pr'' "`n_`pr''"
			}
			else {
				local name_`y'_`o_`y'_`pr''  "`pr'"
			}
			
		}

		foreach y in `mp__' `n__' `g__' `d__' `c__' `f__' { // t excluded bc unclear whether pensions included
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y''- `pr'
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=abs(`pr')
			scalar _d_``y'_`pr'' = _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local int`y' `int`y'' `o_`y'_`pr''
			local id`o_`y'_`pr'' "ben"
			qui gen ywo_`o_`y'_`pr'' = ``y'' - `o_`y'_`pr''
			qui gen yw_`o_`y'_`pr''  = ``y'' 			
			local n_`pr' : variable label `pr'
			if "`n_`pr''" != "" {
				local name_`y'_`o_`y'_`pr'' "`n_`pr''"
			}
			else {
				local name_`y'_`o_`y'_`pr''  "`pr'"
			}
		}
	}

	foreach pr in `dtransfers' `v_dtransfers' {
		foreach y in `m__' `mp__' `n__' {
			tempvar `y'_`pr' 
			qui gen ``y'_`pr'' = ``y'' + `pr'
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=abs(`pr')
			scalar _d_``y'_`pr'' = _d_`pr' 
			local marg`y' `marg`y'' ``y'_`pr''
			local int`y' `int`y'' `o_`y'_`pr''
			local id`o_`y'_`pr'' "ben"
			qui gen ywo_`o_`y'_`pr'' = ``y''
			qui gen yw_`o_`y'_`pr''  = ``y'' + `o_`y'_`pr''
			local n_`pr' : variable label `pr'
			if "`n_`pr''" != "" {
				local name_`y'_`o_`y'_`pr'' "`n_`pr''"
			}
			else {
				local name_`y'_`o_`y'_`pr''  "`pr'"
			}

		}
		foreach y in `g__' `d__' `c__' `f__' { // t excluded bc unclear whether dtransfers included
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' - `pr'
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=abs(`pr')
			scalar _d_``y'_`pr'' = _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local int`y' `int`y'' `o_`y'_`pr''
			local id`o_`y'_`pr'' "ben"
			qui gen ywo_`o_`y'_`pr'' = ``y'' - `o_`y'_`pr''		
			qui gen yw_`o_`y'_`pr'' = ``y''	
			local n_`pr' : variable label `pr'
			if "`n_`pr''" != "" {
				local name_`y'_`o_`y'_`pr'' "`n_`pr''"
			}
			else {
				local name_`y'_`o_`y'_`pr''  "`pr'"
			}
		}
	}
	foreach pr in `v_dtransfersp' {
		foreach y in `m__' { // can't include mp or n here bc they incl pens but not dtransfers // Marc: where is netmarket 
			tempvar `y'_`pr' 
			qui gen ``y'_`pr'' = ``y'' + `pr'
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=abs(`pr')
			scalar _d_``y'_`pr'' = _d_`pr' 
			local marg`y' `marg`y'' ``y'_`pr''
			local int`y' `int`y'' `o_`y'_`pr''
			local id`o_`y'_`pr'' "ben"
			qui gen ywo_`o_`y'_`pr'' = ``y''
			qui gen yw_`o_`y'_`pr''  = ``y'' + `o_`y'_`pr''
			local n_`pr' : variable label `pr'
			if "`n_`pr''" != "" {
				local name_`y'_`o_`y'_`pr'' "`n_`pr''"
			}
			else {
				local name_`y'_`o_`y'_`pr''  "`pr'"
			}
		}
		foreach y in `g__' `d__' `c__' `f__' { // t excluded bc unclear whether dtransfers included
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' - `pr'
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=abs(`pr')
			scalar _d_``y'_`pr'' =_d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''	
			local int`y' `int`y'' `o_`y'_`pr''
			local id`o_`y'_`pr'' "ben"
			qui gen ywo_`o_`y'_`pr'' = ``y'' - `o_`y'_`pr''
			qui gen yw_`o_`y'_`pr''  = ``y'' 
			local n_`pr' : variable label `pr'
			if "`n_`pr''" != "" {
				local name_`y'_`o_`y'_`pr'' "`n_`pr''"
			}
			else {
				local name_`y'_`o_`y'_`pr''  "`pr'"
			}
		}
	}
	foreach pr in `dtaxes' `v_dtaxes' `contribs' `v_contribs' `v_dtaxescontribs' {
		foreach y in `m__' `mp__' `g__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' + `pr' // plus because you already made taxes negative!
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=abs(`pr')
			scalar _d_``y'_`pr'' =_d_`pr' // written as minus since taxes thought of as positive values
			local marg`y' `marg`y'' ``y'_`pr''
			local int`y' `int`y'' `o_`y'_`pr''
			local id`o_`y'_`pr'' "tax"
			qui gen ywo_`o_`y'_`pr'' = ``y''
			qui gen yw_`o_`y'_`pr''  = ``y'' - `o_`y'_`pr''  
			local n_`pr' : variable label `pr'
			if "`n_`pr''" != "" {
				local name_`y'_`o_`y'_`pr'' "`n_`pr''"
			}
			else {
				local name_`y'_`o_`y'_`pr''  "`pr'"
			}
		}
		foreach y in `n__' `t__' `d__' `c__' `f__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' - `pr'
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''= abs(`pr') // Marc: changed this to postive because we need to added taxes to create income w/o program.
			scalar _d_``y'_`pr'' = _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local int`y' `int`y'' `o_`y'_`pr''
			local id`o_`y'_`pr'' "tax"
			qui gen ywo_`o_`y'_`pr'' = ``y'' + `o_`y'_`pr''
			qui gen yw_`o_`y'_`pr''  = ``y''
			local n_`pr' : variable label `pr'
			if "`n_`pr''" != "" {
				local name_`y'_`o_`y'_`pr'' "`n_`pr''"
			}
			else {
				local name_`y'_`o_`y'_`pr''  "`pr'"
			}
		}
	}
	foreach pr in `subsidies' `v_subsidies' {
		foreach y in `m__' `mp__' `n__' `g__' `t__' `d__' {
			tempvar `y'_`pr' 
			qui gen ``y'_`pr'' = ``y'' + `pr'
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=abs(`pr')
			scalar _d_``y'_`pr'' =_d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local int`y' `int`y'' `o_`y'_`pr''
			local id`o_`y'_`pr'' "ben"
			qui gen ywo_`o_`y'_`pr'' = ``y''
			qui gen yw_`o_`y'_`pr''  = ``y'' + `o_`y'_`pr''
			local n_`pr' : variable label `pr'
			if "`n_`pr''" != "" {
				local name_`y'_`o_`y'_`pr'' "`n_`pr''"
			}
			else {
				local name_`y'_`o_`y'_`pr''  "`pr'"
			}
		}
		foreach y in `c__' `f__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' - `pr'
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=abs(`pr')
			scalar _d_``y'_`pr'' = _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local int`y' `int`y'' `o_`y'_`pr''
			local id`o_`y'_`pr'' "ben"
			qui gen ywo_`o_`y'_`pr'' = ``y'' - `o_`y'_`pr''
			qui gen yw_`o_`y'_`pr''  = ``y'' 
			local n_`pr' : variable label `pr'
			if "`n_`pr''" != "" {
				local name_`y'_`o_`y'_`pr'' "`n_`pr''"
			}
			else {
				local name_`y'_`o_`y'_`pr''  "`pr'"
			}
		}
	}
	foreach pr in `indtaxes' `v_indtaxes' {
		foreach y in `m__' `mp__' `n__' `g__' `t__' `d__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' + `pr' // plus because you already made taxes negative!
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=abs(`pr')
			scalar _d_``y'_`pr'' =  _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local int`y' `int`y'' `o_`y'_`pr''
			local id`o_`y'_`pr'' "tax"
			qui gen ywo_`o_`y'_`pr'' = ``y''
			qui gen yw_`o_`y'_`pr''  = ``y'' - `o_`y'_`pr'' 
			local n_`pr' : variable label `pr'
			if "`n_`pr''" != "" {
				local name_`y'_`o_`y'_`pr'' "`n_`pr''"
			}
			else {
				local name_`y'_`o_`y'_`pr''  "`pr'"
			}
		}
		foreach y in `c__' `f__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' - `pr'
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=abs(`pr')
			scalar _d_``y'_`pr'' = _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local int`y' `int`y'' `o_`y'_`pr''
			local id`o_`y'_`pr'' "tax"
			qui gen ywo_`o_`y'_`pr'' = ``y'' + `o_`y'_`pr''
			qui gen yw_`o_`y'_`pr''  = ``y'' 
			local n_`pr' : variable label `pr'
			if "`n_`pr''" != "" {
				local name_`y'_`o_`y'_`pr'' "`n_`pr''"
			}
			else {
				local name_`y'_`o_`y'_`pr''  "`pr'"
			}
		}
	}
	foreach pr in `v_alltaxes' `v_alltaxescontribs' {
		foreach y in `m__' `mp__' `g__' `t__' { // omit n, d which have dtaxes subtr'd but not indtaxes
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' + `pr' // plus because you already made taxes negative!
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=abs(`pr')
			scalar _d_``y'_`pr'' =  _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''	
			local int`y' `int`y'' `o_`y'_`pr''
			local id`o_`y'_`pr'' "tax"
			qui gen ywo_`o_`y'_`pr'' = ``y''
			qui gen yw_`o_`y'_`pr''  = ``y'' - `o_`y'_`pr'' 
			local n_`pr' : variable label `pr'
			if "`n_`pr''" != "" {
				local name_`y'_`o_`y'_`pr'' "`n_`pr''"
			}
			else {
				local name_`y'_`o_`y'_`pr''  "`pr'"
			}
		}
		foreach y in `c__' `f__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' - `pr' 
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=abs(`pr')
			scalar _d_``y'_`pr'' = _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local int`y' `int`y'' `o_`y'_`pr''
			local id`o_`y'_`pr'' "tax"
			qui gen ywo_`o_`y'_`pr'' = ``y'' + `o_`y'_`pr''
			qui gen yw_`o_`y'_`pr''  = ``y'' 
			local n_`pr' : variable label `pr'
			if "`n_`pr''" != "" {
				local name_`y'_`o_`y'_`pr'' "`n_`pr''"
			}
			else {
				local name_`y'_`o_`y'_`pr''  "`pr'"
			}
		}
	}
	foreach pr in `health' `education' `otherpublic' ///
	`v_health' `v_education' `v_otherpublic' `v_inkind' {
		foreach y in `m__' `mp__' `n__' `g__' `t__' `d__' `c__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' + `pr'
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=abs(`pr')
			scalar _d_``y'_`pr'' = _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local int`y' `int`y'' `o_`y'_`pr''
			local id`o_`y'_`pr'' "ben"
			qui gen ywo_`o_`y'_`pr'' = ``y''
			qui gen yw_`o_`y'_`pr''  = ``y'' + `o_`y'_`pr''
			local n_`pr' : variable label `pr'
			if "`n_`pr''" != "" {
				local name_`y'_`o_`y'_`pr'' "`n_`pr''"
			}
			else {
				local name_`y'_`o_`y'_`pr''  "`pr'"
			}
		}
		foreach y in `f__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' - `pr'
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=abs(`pr')
			scalar _d_``y'_`pr'' =  _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
			local int`y' `int`y'' `o_`y'_`pr''
			local id`o_`y'_`pr'' "ben"
			qui gen ywo_`o_`y'_`pr'' = ``y'' - `o_`y'_`pr''
			qui gen yw_`o_`y'_`pr''  = ``y'' 
			local n_`pr' : variable label `pr'
			if "`n_`pr''" != "" {
				local name_`y'_`o_`y'_`pr'' "`n_`pr''"
			}
			else {
				local name_`y'_`o_`y'_`pr''  "`pr'"
			}
		}
	}
	foreach pr in `v_alltransfers' {
		foreach y in `m__' `mp__' `n__' { // omit g, t, d, c which have some transfers
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' + `pr'
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=abs(`pr')
			scalar _d_``y'_`pr'' = _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''	
			local int`y' `int`y'' 
			local id`o_`y'_`pr'' "ben"
			qui gen ywo_`o_`y'_`pr'' = ``y''
			qui gen yw_`o_`y'_`pr''  = ``y'' + `o_`y'_`pr''
			local n_`pr' : variable label `pr'
			if "`n_`pr''" != "" {
				local name_`y'_`o_`y'_`pr'' "`n_`pr''"
			}
			else {
				local name_`y'_`o_`y'_`pr''  "`pr'"
			}
		}
		foreach y in `f__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' - `pr'
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=abs(`pr')
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''	
			local int`y' `int`y'' `o_`y'_`pr''
			local id`o_`y'_`pr'' "ben"
			qui gen ywo_`o_`y'_`pr'' = ``y'' - `o_`y'_`pr''
			qui gen yw_`o_`y'_`pr''  = ``y'' 
			local n_`pr' : variable label `pr'
			if "`n_`pr''" != "" {
				local name_`y'_`o_`y'_`pr'' "`n_`pr''"
			}
			else {
				local name_`y'_`o_`y'_`pr''  "`pr'"
			}
		}
	}
	foreach pr in `v_alltransfersp' {
		foreach y in `m__' { // omit mplusp, n which have pensions, g, t, d, c which have some transfers
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' + `pr'
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=abs(`pr')
			scalar _d_``y'_`pr'' =  _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''	
			local int`y' `int`y'' `o_`y'_`pr''
			local id`o_`y'_`pr'' "ben"
			qui gen ywo_`o_`y'_`pr'' = ``y''
			qui gen yw_`o_`y'_`pr''  = ``y'' + `o_`y'_`pr''
			local n_`pr' : variable label `pr'
			if "`n_`pr''" != "" {
				local name_`y'_`o_`y'_`pr'' "`n_`pr''"
			}
			else {
				local name_`y'_`o_`y'_`pr''  "`pr'"
			}
		}
		foreach y in `f__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' - `pr'
			tempvar o_`y'_`pr'
			qui gen `o_`y'_`pr''=abs(`pr')
			scalar _d_``y'_`pr'' =  _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''	
			local int`y' `int`y'' `o_`y'_`pr''
			local id`o_`y'_`pr'' "ben"
			qui gen ywo_`o_`y'_`pr'' = ``y'' - `o_`y'_`pr''
			qui gen yw_`o_`y'_`pr''  = ``y'' 
			local n_`pr' : variable label `pr'
			if "`n_`pr''" != "" {
				local name_`y'_`o_`y'_`pr'' "`n_`pr''"
			}
			else {
				local name_`y'_`o_`y'_`pr''  "`pr'"
			}
		}		
	}
	*set trace off
	local maxlength = 0
	foreach v of local alllist {
		if "``v''"!="" {
			local length = wordcount("`marg`v''")
			local maxlength = max(`maxlength',`length')
		}
	}
	local colsneeded = (wordcount("`supercols'"))*`maxlength'*2 // *2 is for crossings and p-values
	
	 //! Previously where poverty line locals are located
	
	
	* PPP converted variables
	if (`_ppp') {
		local ppp_calculated = `ppp'*(`cpisurvey'/`cpibase')
		foreach v of local alllist {
			tempvar `v'_ppp
			if "``v''"!="" {
				qui gen ``v'_ppp' = (``v''/`divideby')*(1/`ppp_calculated')
				foreach ext of local marg`v' {
					tempvar `ext'_ppp
					qui gen ``ext'_ppp' = (`ext'/`divideby')*(1/`ppp_calculated')
				}
			}
		}	
	}
	** temporary variables
	tempvar one
	qui gen `one' = 1
	
	
	#delimit;
	
	*Temporary dataset from which to run results;
	qui tempfile orig;
	qui save `orig',replace;
	*****************************************************RUN RESULTS******************************;
	qui{;
	local rowc=0;
	*set trace on ;

	foreach y of local alllist {;
		if "``y''"!="" {;
		use `orig',clear;
			
			local cols = (wordcount("`marg`y''"));
			*Inequality;
			matrix g_ie_`y'=J(1,`cols',.);
			matrix g_se_`y'=J(1,`cols',.);
			*Poverty;
			matrix p_ie_`y'=J(14,`cols',.);
			matrix p_se_`y'=J(14,`cols',.);
			*Fiscal impoverishment;
			matrix fi_`y'=J(35,`cols',.);
			*Beckerman Imervoll Effectiveness Indicators;
			matrix bi_`y'=J(28,`cols',.);
			
			local col = 0 /*1 */ ;  //!
			local colc=0;
				foreach ext of local int`y' {;
				local col=`col'+1;
				local row = 0;
				local rfi=0;
				local rbk=0;			
				
				qui sum ``y'' ;
				local m_`y'=r(mean);
				qui sum `ext' ;
				local m_`ext'=r(mean);
				local is_tax=0;
				local is_ben=0;
				*Generate variables with the individual tax or transfer;
				*if `m_`ext''<`m_`y''{;
				cap drop __int_tax__ ;
				if "`id`ext''"=="tax"{;
					*tempvar int_tax;
					gen double __int_tax__=abs( `ext');
					local is_tax=1;
				
				};
				cap drop __int_ben__ ;
				if "`id`ext''"=="ben"{;
					*tempvar int_ben;
					gen double __int_ben__=abs( `ext');
					local is_ben=1;
				};
				/* if `m_`ext''==`m_`y''{; //IE AND SE are missing if intervention=0;
					matrix g_ie_`y'[1,`col'] =.;
					matrix g_se_`y'[1,`col'] =.;
				}; */
				*tempvar yo;
				cap drop __yo__ __y1__ __`y'o_ppp__ __`y'1_ppp__ ;
				gen double __yo__=ywo_`ext'; ///without transfers (-) without tax (+);
				*tempvar `y'o_ppp;
				gen double __`y'o_ppp__=(__yo__/`divideby')*(1/`ppp_calculated');
				*tempvar y1;
				gen double __y1__ = yw_`ext';
				*tempvar `y'1_ppp;
				gen double __`y'1_ppp__=(__y1__/`divideby')*(1/`ppp_calculated');
					 
					 
				*for taxes;
				if `is_tax'==1 {;

					*****Gini********************;
					
					*Impact effectiveness;
					ceqtaxstar `pw', startinc(__yo__) taxes(__int_tax__);
					local twarn = r(twarn) ; 
					if r(t_gr) == 1{ ;
						nois `dit'  "Sum of `name_`y'_`ext'' exceed ``y'', so impact effectiveness indicator for these taxes on ``y'' not produced" ;
						local warning `warning'  "Sum of ``y'_`ext'' exceed ``y'', so impact effectiveness indicator for these taxes on ``y'' not produced" ;
						local twarn = r(t_gr) ; 
					} ;
					else if r(t_0) == 1{ ;
						nois `dit'  "Sum of `name_`y'_`ext'' equals 0, so impact effectiveness indicator for these taxes on ``y'' not produced" ;
						local warning `warning'  "Sum of ``y'_`ext'' equals 0, so impact effectiveness indicator for these taxes on ``y'' not produced" ;
						local twarn = r(t_0) ; 
					} ;	
					else { ; 	
						*tempvar ystar;
						cap drop ___ystar ;
						gen double ___ystar=____ytaxstar;
						cap drop ____ytaxstar   ____id_taxstar;
						covconc ``y'' `pw';//gini of column income;
						local g1_`y'=r(gini);
						covconc __yo__ `pw';//gini of row income;
						local g2_`yo'=r(gini);
						covconc ___ystar `pw';//gini of star income;
						local g_star=r(gini);
						local imef=(`g2_`yo''-`g1_`y'')/(`g2_`yo''-`g_star');
						matrix g_ie_`y'[1,`col'] =`imef';
					} ;
					local twarn = r(twarn) ; 
					*Spending Effectiveness;
					_ceqmcid `pw', inc(``y'') sptax(__int_tax__) ;
					*If Marg. Cont. is negative, SE is missing;
					if r(mc_ineq)<0{;
						matrix g_se_`y'[1,`col'] =.;

					};
					else{;
						*set trace on ;
						cap drop ___t ; 
						gen double ___t = __y1__ + abs(__int_tax__) ; 
						covconc ___t `pw' ; 
						local gini1 = r(gini) ; 
						covconc __y1__ `pw' ; 
						local gini2 = r(gini) ;
						if abs((`gini1' - `gini2')/`gini1') < 0.009 { ;
							nois `dit' "Difference beween starting and ending Ginis is too small. Spending effectiveness indicator for ``y'' considering ``y'_`ext'' is not produced" ;
					        local warning `warning' `dit' "Difference beween starting and ending Ginis is too small. Spending effectiveness indicator for ``y'' considering ``y'_`ext'' is not produced" ;
									
						} ;

						else { ;
							
							_ceqspend `pw',inc(__y1__) sptax(__int_tax__) ; // Marc: remove capture once debugged fully. ;
							*set trace off ;
							*local spef=r(sp_ef);
							matrix g_se_`y'[1,`col'] = r(sp_ef);
						} ;
						

					};
					*****Poverty********************;
					*Convert to ppp;

					
					 *tempvar int_tax_ppp;
					 cap drop ___int_tax_ppp ;
					 gen double  ___int_tax_ppp=(__int_tax__/`divideby')*(1/`ppp_calculated');
					 *tempvar ystar_ppp;
					 cap drop ___ystar_ppp ;
					 if `twarn' == 0 gen double ___ystar_ppp=(___ystar/`divideby')*(1/`ppp_calculated');
					 *tempvar `y'_ppp;
					 cap drop ___`y'_ppp ;
					 gen double ___`y'_ppp=(``y''/`divideby')*(1/`ppp_calculated');
					
					 
		

			
					
					if wordcount("`povlines'")>0 {; // otherwise produces inequality only;
						foreach p in `plopts'  { ;// plopts includes all lines;
							if "``p''"!="" {	;
								if substr("`p'",1,2)=="pl" {; // these are the PPP lines;
									local _pline = ``p'';
									local vtouse1 __`y'1_ppp__;//1 is for income with intervention;
									local vtouse2 __`y'o_ppp__;//2 is for income without intervention;
									if `twarn' == 0 local vtouse3 ___ystar_ppp;//3 is for ideal income; 
								};
								else if _`p'_isscalar==1 { ;  // if pov line is scalar, // (note this local defined above);
									local _pline = ``p''; // set `_pline' as that scalar and;
									local vtouse1 __y1__   ;// use income with intervention;
									local vtouse2 __yo__;//income without intervention;
									if `twarn' == 0 local vtouse3 ___ystar;//income with ideal intervention;
								};
								else if _`p'_isscalar==0 {; // if pov line is variable,;
									tempvar `v'_normalized1 ; // create temporary variable that is income...;
									tempvar `v'_normalized2 ; // create temporary variable that is income...;
									tempvar `v'_normalized3 ; // create temporary variable that is income...;

									cap drop  ___`v'_normalized1  ___`v'_normalized2 ;
									cap drop  ___`v'_normalized3 ;
									qui gen ___`v'_normalized1 = __y1__/``p'' ;// normalized by pov line @@change;  
									qui gen ___`v'_normalized2 = __yo__/``p'' ;// normalized by pov line  @@change;
									if `twarn' == 0 qui gen ___`v'_normalized3 = ___ystar/``p'' ;// normalized by pov line;

									local _pline = 1            ;           // and normalized pov line is 1;
									local vtouse1 ___`v'_normalized1; // use normalized income in the calculations;
									local vtouse2 ___`v'_normalized2; // use normalized income in the calculations;
									local vtouse3 ___`v'_normalized3; // use normalized income in the calculations;

								};
							
								cap drop 	___zyzfgt1_1 ___zyzfgt2_1 ___zyzfgt1_2 ___zyzfgt2_2 ;
								cap drop	___zyzfgt1_3 ___zyzfgt2_3;					
								*tempvar zyzfgt1_1 zyzfgt2_1 zyzfgt1_2 zyzfgt2_2 zyzfgt1_3 zyzfgt2_3;
								qui gen ___zyzfgt1_1 = max((`_pline'-`vtouse1')/`_pline',0) ;// normalized povety gap of each individual;
								qui gen ___zyzfgt2_1 = ___zyzfgt1_1^2 ;                           // square of normalized poverty gap;
								qui gen ___zyzfgt1_2 = max((`_pline'-`vtouse2')/`_pline',0) ;// normalized povety gap of each individual;
								qui gen ___zyzfgt2_2 = ___zyzfgt1_2^2 ;                           // square of normalized poverty gap;
								if `twarn' == 0 qui gen ___zyzfgt1_3 = max((`_pline'-`vtouse3')/`_pline',0) ;// normalized povety gap of each individual;
								if `twarn' == 0 qui gen ___zyzfgt2_3 = ___zyzfgt1_3^2 ;                           // square of normalized poverty gap;
								
							
							
							
								qui summ ___zyzfgt1_1 `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
								local p1_`y'_orig=r(mean);
								qui summ ___zyzfgt1_2 `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
								local p1_`y'_2=r(mean);
								if `twarn' == 0 qui summ ___zyzfgt1_3 `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
								local p1_`y'_3_st=r(mean);
								
								qui summ ___zyzfgt2_1 `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
								local p2_`y'_orig=r(mean);
								qui summ ___zyzfgt2_2 `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
								local p2_`y'_2=r(mean);
								if `twarn' == 0 qui summ ___zyzfgt2_3 `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
								local p2_`y'_3_st=r(mean);
								*drop  `zyzfgt1_2' `zyzfgt1_1'  `zyzfgt2_2' `zyzfgt2_1';
								*if `twarn' == 0 drop `zyzfgt1_3' `zyzfgt2_3' ;

																****Poverty Impact effectiveness;

								//Marginal contributions for fgt 1,2;
								local mp_1_`p'_`y'=`p1_`y'_2'-`p1_`y'_orig' ;//Observed MC;
								if `twarn' == 0 local mp_1_`p'_`y'_s=`p1_`y'_2'-`p1_`y'_3_st' ;//Star MC;
								local mp_2_`p'_`y'=`p2_`y'_2'-`p2_`y'_orig' ;//Observed MC;
								if `twarn' == 0 local mp_2_`p'_`y'_s=`p2_`y'_2'-`p2_`y'_3_st' ;//Star MC;
								// If Optimal income wasn't created we must skip the taxharm portion of code.
								if `twarn' > 0 local mp_1_`p'_`y'_s = 1 ;
								if `twarn' > 0 local mp_2_`p'_`y'_s = 1 ;
								****For Impact effectiveness there can only be a negative effect, we use the harm formula Ch. 5 CEQ Handbook;
								forval i=1/2 {;
									if `mp_`i'_`p'_`y''<0{;
										ceqtaxharm `pw', endinc(__y1__) taxes(__int_tax__);			
										cap drop ___yharm ;
										*tempvar yharm;
										gen double ___yharm =____ytaxharm;
										cap drop ____ytaxharm   ____id_taxharm;
										*tempvar yharm_ppp;
										cap drop ___yharm_ppp ;
										gen ___yharm_ppp=(___yharm/`divideby')*(1/`ppp_calculated');
									
									
										if "``p''"!="" {	;
											if substr("`p'",-2,2)=="pl" {; // these are the PPP lines;
												local _pline = ``p'';
												local vtouseh ___yharm_ppp;//h is for harm;
											};
								
											else if _`p'_isscalar==1 { ;  // if pov line is scalar, // (note this local defined above);
												local _pline = ``p''; // set `_pline' as that scalar and;
												local vtouseh ___yharm   ;
											};
											else if _`p'_isscalar==0 {; // if pov line is variable,;
												*tempvar `v'_normalizedh ; // create temporary variable that is income...;
												cap drop ___`v'_normalizedh ;
												qui gen ___`v'_normalizedh = ___yharm/``p'' ;// normalized by pov line;  
												local _pline = 1            ;           // and normalized pov line is 1;
												local vtouseh ___`v'_normalizedh; // use normalized income in the calculations;					
											};
									
							
											*tempvar zyzfgt1_h zyzfgt2_h;
											cap drop ___zyzfgt1_h ___zyzfgt2_h;
											qui gen ___zyzfgt1_h = max((`_pline'-`vtouseh')/`_pline',0) ;// normalized povety gap of each individual;
											qui gen ___zyzfgt2_h = ___zyzfgt1_h^2 ;                           // square of normalized poverty gap;							
											
											
											qui summ ___zyzfgt`i'_h `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
											local p`i'_h=r(mean);
									
											local mst_p`i'_h=`p`i'_`y'_3' - `p`i'_h';//Ideal MC with tax formula;
											local eft_`i'_h=(`mp_`i'_`p'_`y''/`mst_p`i'_h')*(-1);
										
								
											*return scalar eft_`i'_h =  `eft_`i'_h';//Impact effectiveness indicator, v has the variable name of the transfer, y=income, p=poverty line ;
									
											local row=`row'+1;
											matrix p_ie_`y'[`ref_`p'_`i'',`col'] = `eft_`i'_h';
											matrix p_se_`y'[`ref_`p'_`i'',`col'] = .;
										

										/*local row=`row'+1;
										matrix p_ie_`y'[`row',`col'] = `eft_2_h';
										matrix p_se_`y'[`row',`col'] = .;*/
										};
									};
								
									else{;
										local row=`row'+1;
									

										matrix p_ie_`y'[`ref_`p'_`i'',`col'] =0;  
										matrix p_se_`y'[`ref_`p'_`i'',`col'] =.;  //!;
								
									};
						};
						tempvar taxesef;
							*gen double `taxesef'=abs(`vtouse2'-`vtouse1');
							cap drop ___taxesef ;
							gen double ___taxesef =abs(`vtouse2'-`vtouse1');
							_fifgpmc `aw',taxes(___taxesef)  startinc(`vtouse2') endinc(`vtouse1') z(`_pline');    //startinc and endinc switched by Rosie Li on May 16, 2017 after consulting with Rodrigo Aranda;
							local rfi=`rfi_`p'';
							matrix fi_`y'[`rfi',`col']=r(MCEF_t);
							local rfi=`rfi'+1;
							matrix fi_`y'[`rfi',`col']=. /*MCEF_pc*/;
							local rfi=`rfi'+1;
							matrix fi_`y'[`rfi',`col']=. /*MCEF_n*/;
							*Beckerman Immervol NOT FOR TAXES SO MISSING VALUES;
							 local rbk=`rbk_`p'';
							 matrix bi_`y'[`rbk',`col']=.;//Vertical Expenditure Efficiency;
							local rbk=`rbk'+1;
							 matrix bi_`y'[`rbk',`col']=.;//Spillover Index;
							 local rbk=`rbk'+1;
							 matrix bi_`y'[`rbk',`col']=.;//Poverty Reduction Efficiency;
							 local rbk=`rbk'+1;
							 matrix bi_`y'[`rbk',`col']=.;//Poverty Gap Efficiency;

						};
						};
						
						};
					
					
					cap drop ___*;
				} ;
				*For transfers;
				if `is_ben'==1{;

				*****Gini********************;
				*Impact effectiveness;
				ceqbenstar `pw', startinc(__yo__) ben(__int_ben__);		   // startinc changed from `yo' to `y' by Rosie Li on May 16, 2017 after consulting with Rodrigo Aranda;
				local bwarn = r(bwarn) ;
				if r(b_gr) ==1 { ;
					nois `dit' "Sum of `name_`y'_`ext'' exceed ``y'', so impact effectiveness indicator for these benefits on ``y'' is not produced" ;
					local warning `warning' "Sum of ``y'_`ext'' exceed ``y'', so impact effectiveness indicator for these benefits on ``y'' is not produced" ;
					local bwarn = r(b_gr) ;
				} ;
				else if r(b_0) ==1 { ;
					nois `dit' "Sum of `name_`y'_`ext'' equals 0, so impact effectiveness indicator for these benefits on ``y'' is not produced" ;
					local warning `warning' "Sum of ``y'_`ext'' equals 0, so impact effectiveness indicator for these benefits on ``y'' is not produced" ;
					local bwarn = r(b_0) ;
				} ;
				else { ; 
					*tempvar ystar;
					cap drop ___ystar ; 
					gen double ___ystar=____ybenstar;
					cap drop  ____ybenstar ____id_benstar ;
					covconc ``y'' `pw';//gini of column income;
					local g1_`y'=r(gini);
					covconc __yo__ `pw';//gini of row income;
					local g2_`yo'=r(gini);
					covconc ___ystar `pw';//gini of star income;
					local g_star=r(gini);
					local imef=(`g2_`yo''-`g1_`y'')/(`g2_`yo''-`g_star');
					matrix g_ie_`y'[1,`col'] =`imef';
				} ;
				*Spending Effectiveness;
				_ceqmcid `pw', inc(__y1__) spben(__int_ben__) ;
				*If Marg. Cont. is negative, SE is missing;
				if r(mc_ineq)<0{;
					matrix g_se_`y'[1,`col'] =.;

				};
				else{;
					cap drop ___t ; 
					gen double ___t = __y1__ - abs(__int_ben__) ; 
					covconc ___t `pw' ; 
					local gini1 = r(gini) ; 
					covconc __y1__ `pw' ; 
					local gini2 = r(gini) ;
					if abs((`gini1' - `gini2')/`gini1') < 0.009 { ;
						nois `dit' "Difference beween starting and ending Ginis is too small. Spending effectiveness indicator for ``y'' considering ``y'_`ext'' is not produced" ;
					    local warning `warning' `dit' "Difference beween starting and ending Ginis is too small. Spending effectiveness indicator for ``y'' considering ``y'_`ext'' is not produced" ;
								
					} ;

					else { ;
						
								
						_ceqspend `pw',inc(__y1__) spben(__int_ben__); // ! Remove capture once debugged.
						*local spef=r(sp_ef);
						matrix g_se_`y'[1,`col'] = r(sp_ef);


					} ; 
				};
				*********Poverty************;
			
				*Convert to ppp;
				 *tempvar int_ben_ppp;
				 cap drop ___int_ben_ppp ;
				 gen double  ___int_ben_ppp=(__int_ben__/`divideby')*(1/`ppp_calculated');
				 *tempvar ystar_ppp;
				 cap drop ___ystar_ppp ; 
				 if `bwarn' == 0 gen double ___ystar_ppp=(___ystar/`divideby')*(1/`ppp_calculated');
				 *tempvar `y'_ppp;
				 cap drop ___`y'_ppp;
				 gen double ___`y'_ppp=(``y''/`divideby')*(1/`ppp_calculated');
				
				
				if wordcount("`povlines'")>0 {; // otherwise produces inequality only;
				foreach p in `plopts'  { ;// plopts includes all lines;
					if "``p''"!="" {	;
						if substr("`p'",1,2)=="pl" {; // these are the PPP lines;
							local _pline = ``p'';
							local vtouse1 __`y'1_ppp__;//1 is for original;
							local vtouse2 __`y'o_ppp__;//2 is for income without intervention;
							if `bwarn' == 0 local vtouse3 ___ystar_ppp;//3 is for ideal income; 
						};
						else if _`p'_isscalar==1 { ;  // if pov line is scalar, // (note this local defined above);
							local _pline = ``p''; // set `_pline' as that scalar and;
							local vtouse1 __y1__   ;// use original income variable;
							local vtouse2 __yo__;//income without intervention;
							if `bwarn' == 0 local vtouse3 ___ystar;//income with ideal intervention;
						};
						else if _`p'_isscalar==0 {; // if pov line is variable,;
							*tempvar `v'_normalized4 ; // create temporary variable that is income...;  
							*tempvar `v'_normalized5 ; // create temporary variable that is income...;
							*tempvar `v'_normalized6 ; // create temporary variable that is income...;
							cap drop  ___`v'_normalized4 ___`v'_normalized5 ;
							cap drop ___`v'_normalized6 ;  
							qui gen ___`v'_normalized4 = __y1__/``p'' ;// normalized by pov line;  
							qui gen ___`v'_normalized5 = __yo__/``p'' ;// normalized by pov line;
							/*qui gen ``v'_normalized2' = `yo'/``p'' ;// normalized by pov line;*/
							if `bwarn' == 0 qui gen ___`v'_normalized6 = ___ystar/``p'' ;// normalized by pov line;

							local _pline = 1            ;           // and normalized pov line is 1;
							/*
							local vtouse1 ``v'_normalized4'; // use normalized income in the calculations @@change;
							local vtouse2 ``v'_normalized5'; // use normalized income in the calculations @@change;
							local vtouse3 ``v'_normalized6'; // use normalized income in the calculations @@change;
							*/
							local vtouse1 ___`v'_normalized4; // use normalized income in the calculations @@change;
							local vtouse2 ___`v'_normalized5; // use normalized income in the calculations @@change;
							local vtouse3 ___`v'_normalized6; // use normalized income in the calculations @@change;
						};
						
						
						*tempvar zyzfgt1_1 zyzfgt2_1 zyzfgt1_2 zyzfgt2_2 zyzfgt1_3 zyzfgt2_3;
						cap drop ___zyzfgt1_1 ___zyzfgt2_1 ___zyzfgt1_2 ___zyzfgt2_2 ;
						cap drop ___zyzfgt1_3 ___zyzfgt2_3;
						qui gen double ___zyzfgt1_1 = max((`_pline'-`vtouse1')/`_pline',0) ;// normalized povety gap of each individual;
						qui gen double ___zyzfgt2_1 = ___zyzfgt1_1^2 ;                           // square of normalized poverty gap;

						qui gen double ___zyzfgt1_2 = max((`_pline'-`vtouse2')/`_pline',0) ;// normalized povety gap of each individual;


						qui gen double ___zyzfgt2_2 = ___zyzfgt1_2^2 ;                           // square of normalized poverty gap;
						if `bwarn' == 0 qui gen double ___zyzfgt1_3 = max((`_pline'-`vtouse3')/`_pline',0) ;// normalized povety gap of each individual;
						if `bwarn' == 0 qui gen double ___zyzfgt2_3 = ___zyzfgt1_3^2 ;                           // square of normalized poverty gap;
						

						qui summ ___zyzfgt1_1 `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
						local p1_`y'_orig=r(mean);
						qui summ ___zyzfgt1_2 `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
						local p1_`y'_2=r(mean);
						if `bwarn' == 0 qui summ ___zyzfgt1_3 `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
						local p1_`y'_3_st=r(mean);
							
						qui summ ___zyzfgt2_1 `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
						local p2_`y'_orig=r(mean);
						qui summ ___zyzfgt2_2 `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
						local p2_`y'_2=r(mean);
						if `bwarn' == 0 qui summ ___zyzfgt2_3 `aw', meanonly; // `if' `in' restrictions already taken care of by `touse' above;	
						local p2_`y'_3_st=r(mean);
						
							
						//Marginal contributions for fgt 1,2;
						local mp_1_`p'_`y'=`p1_`y'_2'-`p1_`y'_orig';//Observed MC;
						if `bwarn' == 0 local mp_1_`p'_`y'_s=`p1_`y'_2'-`p1_`y'_3_st';//Star MC;
						local mp_2_`p'_`y'=`p2_`y'_2'-`p2_`y'_orig';//Observed MC;
						if `bwarn' == 0 local mp_2_`p'_`y'_s=`p2_`y'_2'-`p2_`y'_3_st';//Star MC;
						// If warning was produced we should skip this section.
						if `bwarn' == 0 local mp_1_`p'_`y'_s= 1 ;
						if `bwarn' == 0 local mp_2_`p'_`y'_s= 1 ;
						forval i=1/2 {;
							****Poverty Impact effectiveness;
							****For Impact effectiveness with Transfers there can only be a positive effect;
							if `mp_`i'_`p'_`y''>0{;
								*Impact effectiveness;
								*Ystar already exists;
								*local mst_p`i'_h=`p`i'_`y'_3' - `p`i'_h';//Ideal MC with tax formula;
								scalar eft_`i' =  (`mp_`i'_`p'_`y''/`mp_`i'_`p'_`y'_s');//MC/MCstar;
							
								local row=`row'+1;
								matrix p_ie_`y'[`ref_`p'_`i'',`col'] = eft_`i';
								****Poverty Spending effectiveness;
								*tempvar bentouse;
								cap drop ___bentouse;
								gen double ___bentouse=abs(`vtouse1'-`vtouse2');
								//! Uncomment after fixed.
								*cap drop ___t ; 
								*gen double ___t = `vtouse2'+  abs(___bentouse) ; 
								covconc `vtouse1' `pw' ; 
								local gini1 = r(gini) ; 
								covconc `vtouse2' `pw' ; 
								local gini2 = r(gini) ;
								if abs((`gini1' - `gini2')/`gini1') < 0.009 { ;
									nois `dit' "Difference beween starting and ending Ginis is too small. Poverty spending effectiveness indicator for ``y'' considering ``y'_`ext'' is not produced" ;
					                local warning `warning' `dit' "Difference beween starting and ending Ginis is too small. Poverty spending effectiveness indicator for ``y'' considering ``y'_`ext'' is not produced" ;
									
								} ;

								else { ;
									

									ceqbensp  `pw', startinc(`vtouse2') ben(___bentouse) zz(`_pline') obj1(`p1_`y'_orig') obj2(`p2_`y'_orig');	
									matrix p_se_`y'[`ref_`p'_`i'',`col'] = r(sp_ef_pov_`i')  ;  							
								} ;

							};
							else{;
								local row=`row'+1;

								
								matrix p_ie_`y'[`ref_`p'_`i'',`col'] =0 /*.*/;
								matrix p_se_`y'[`ref_`p'_`i'',`col'] =0 /*.*/;
							};
							
						};
						*tempvar benef;
						cap drop ___benef;
						gen double ___benef=abs(`vtouse2'-`vtouse1');
						_fifgpmc `aw',benef(___benef)  startinc(`vtouse2') endinc(`vtouse1') z(`_pline');  //startinc and endinc switched by Rosie Li on May 16, 2017 after consulting with Rodrigo Aranda;
						local rfi=`rfi_`p'';
						matrix fi_`y'[`rfi',`col']=r(MCEF_t);
						local rfi=`rfi'+1;
						matrix fi_`y'[`rfi',`col']=. /*MCEF_pc*/;
						local rfi=`rfi'+1;
						matrix fi_`y'[`rfi',`col']=. /*MCEF_n*/;
						
						
						*Beckerman Immervol ;

						ceqbeck `aw',preinc(`vtouse2') postinc(`vtouse1') zline(`_pline');
						
						
						
						 local rbk=`rbk_`p'';
						 local disp=r(VEE);
						 matrix bi_`y'[`rbk',`col']=r(VEE);//Vertical Expenditure Efficiency;
						local rbk=`rbk'+1;
						 matrix bi_`y'[`rbk',`col']=r(Spill);//Spillover Index;
						 local rbk=`rbk'+1;
						 matrix bi_`y'[`rbk',`col']=r(PRE);//Poverty Reduction Efficiency;
						 local rbk=`rbk'+1;
						 matrix bi_`y'[`rbk',`col']=r(PGE);//Poverty Gap Efficiency;

					
					
					};
				};
				cap drop ___*;
				
					
				};
				
				
			
			
			
			
				};
			
			
				};
				
			};
			};
};//end quietly;
			#delimit cr	
	*****************
	** SAVE RESULTS *
	*****************
	if `"`using'"'!="" {
		// "
		`dit' `"Writing to "`using'"; may take several minutes"'
		local startcol_o = 4 // this one will stay fixed (column B)

		// Print information
		local date `c(current_date)'
		local titlesprint
		local titlerow = 7
		local trow1 = 9
		local trow2 = 27
		local trow3 = 45
		local trow4 =82

		local titlecol = 1
		local titlelist country surveyyear authors date 
		
		// Print version number on Excel sheet
		local versionprint A4=("Results produced by version `version' of `command' on `c(current_date)' at `c(current_time)'")

		foreach y of local alllist {
			local startcol = `startcol_o'
			local titles`y'
			if "``y''"!="" {
				local r_g_ie=10
				local r_g_se=28
				local r_p_ie=12
				local r_p_se=30
				local r_fi=46
				local r_bi=83
				
				foreach x in g_ie g_se p_ie p_se fi bi{
				
				qui	putexcel D`r_`x''=matrix(`x'_`y') using `"`using'"',keepcellformat modify sheet("`sheet`y''")

				}
				
					foreach ext of local marg`y' {
						returncol `startcol'
						local titles1`y' `titles1`y'' `r(col)'`trow1'=(_d_`ext')
						local titles2`y' `titles2`y'' `r(col)'`trow2'=(_d_`ext')
						local titles3`y' `titles3`y'' `r(col)'`trow3'=(_d_`ext')
						local titles4`y' `titles4`y'' `r(col)'`trow4'=(_d_`ext')
						local startcol=`startcol'+1 
						
					}
				
				
				#delimit;
				local date `c(current_date)';		
				local titlesprint;
				local titlerow = 3;
				local titlecol = 1;
				local titlelist country surveyyear authors date ppp baseyear cpibase cpisurvey ppp_calculated scenario group project ;

				foreach title of local titlelist {;
				returncol `titlecol';
				if "``title''"!="" & "``title''"!="-1" 
				local  titlesprint `titlesprint' `r(col)'`titlerow'=("``title''");
				local titlecol = `titlecol' + 1;
				};
				qui putexcel `titlesprint'  `versionprint' `titles1`y'' `titles2`y'' `titles3`y'' `titles4`y'' using `"`using'"', modify keepcellformat sheet("`sheet`y''");

				#delimit cr
				
			}
		}
		}
    *********
    ** OPEN *
    *********
    if "`open'"!="" & "`c(os)'"=="Windows" {
         shell start `using' // doesn't work with "" or `""' so I already changed `open' to "" if using has spaces, 
    }
    else if "`open'"!="" & "`c(os)'"=="MacOSX" {
         shell open `using'
    }
    else if "`open'"!="" & "`c(os)'"=="Unix" {
         shell xdg-open `using'
    }
	
	*************
	** CLEAN UP *
	*************
	quietly putexcel clear
	restore // note this also restores svyset
	
end	// END ceqefext








