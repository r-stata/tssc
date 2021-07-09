*! hetred. ado version 1.1.1 December 2007
*! Nikolaos A. Patsopoulos (npatsop@cc.uoi.gr)


* Program definition
program define hetred, rclass sortpreserve
	version 8.0
	syntax varlist(min=2 max=2 numeric) [if] [in], i2h(integer) i2l(integer) ID(varname) ///
	[random tuples max]
	marksample touse
	tokenize `varlist' // resolve varlist into the two parts
	local E `1' // ln of effect size
	local SE `2' // standard error of ln of effect size
	
	
	
	* check if data exist
	qui count if `touse'
	local data=r(N)
	
	
	if `data'==0 {
		di in red "If statement failed. Please check if data exist."
		exit
	}	

	* check if more than one study with the same lnES and SElnES exist
	tempvar _id 
	qui gen `_id'=0
	local _idN=2
	while `_idN'!=1 {
		qui {
			bysort `E' `SE': replace `_id'=_n if `touse'
			count if `_id'>1 & `touse'
			replace `SE'=`SE'+(`_id'-1)*0.0001 if `_id'>1 
			sum `_id' if `touse', detail
		}
		local _idN=r(max)
		* di `_idN'
		* list `E' `SE' `_id' if `touse'
	}


	* check if 0<=i2l<=100:
	if (`i2l'>100) | (`i2h'>100) | (`i2l'<0) | (`i2h'<0) {
		di as err "i2h and i2l must be between 0 and 100"
		exit 
	}
	
	
	

	

	

	
	
	* Overall estimates
	qui metan `E' `SE' if `touse', `random' eform nograph
	local ovES = r(ES)
	local ovSElnES = r(selogES)
	local ovQ = r(het)
	local ovdf = r(df)
	local ovIsquare = max(0,(100*(`ovQ'-`ovdf')/`ovQ'))
	local IsquareStart=`ovIsquare'
	* display `ovES' " " `ovSElnES' " " `ovQ' " " `ovdf' " " `ovIsquare' "%"


	if `IsquareStart'<`i2h' {
		display as err "I-squared is " %3.1f `IsquareStart' "% , which is less than wanted i2h: " `i2h' "%." 
		exit
	}			
	
	
	if `IsquareStart'<=`i2l' {
		di in red "I-squared already <=`i2l'%!"
		exit
	}		



	*  Meta-analysis estimate ommiting one study each step
	tempvar theta setheta Q df Isquare stop 
	qui sum `E' if  `touse', detail
	local n=r(N) // number of studies
	qui {
		gen `theta' =.
		gen `setheta' =.
		gen `Q' =.
		gen `df' =.
		gen `Isquare' =.
		gen  `stop'=0 // stop the loop if this equals 1
	}				

				tempvar include s step
				qui {	
					gen `include' =.
					replace `include'=1  if `touse'
					gen `s'=_n  // study id
					gen `step'=0  
				}

				local step_i=1 // count for steps
				local k=`n'
				while (`k'>2 & `stop'==0) {
					qui replace `s'=.
					gsort -`include'
					qui replace `s'=_n if `include'==1 
			
					local i=1
					qui sum `E' if `include'==1 , detail
					local n=r(N) // number of studies
					while (`i'<=`n' & `stop'==0) {
						qui {
							metan `E' `SE' if `s'!=`i' & `include'==1 , `random' eform nograph
							replace `theta'=r(ES) in `i'
							replace `setheta'=r(selogES) in `i'
							replace `Q'=r(het) in `i'
							replace `df'=r(df) in `i'
							replace `Isquare'=max(0,(100*(`Q'-`df')/`Q')) in `i'
						}
						local i=`i'+1
					}
					gsort -`Isquare'
					* list `id' `theta' `setheta' `Q' `df' `Isquare' `include' `E' `SE' if `include'==1 & `touse' 
	
	
					tempvar lowIsq j bestQ
					qui sum `Isquare' if `include'==1 , detail 
					gen `lowIsq' =r(min) // lowest Isquare
					// qui replace `lowIsq'=`i2l' if `lowIsq'<`i2l'
					qui sum `E' if `Isquare'<=`i2l' & `include'==1 
					gen `j' =r(N) 
 
					qui {
						
						
						count if `Isquare'<=`i2l'
						local ties=r(N)
						
						if `ties'>1 { // choose study in case of ties
							noi di as text "There are " `ties' " different studies that drop I-squared below " `i2l'
							noi di
							 
							capture confirm ex `max'
							if !_rc {
								sum `Q' if `Isquare'<=`i2l'
								gen `bestQ'=r(max)
								// replace `step'=`step_i' if `Q'==`bestQ' & `include'==1 
							}
							else {
								sum `Q' if `Isquare'<=`i2l'
								gen `bestQ'=r(min)
							}
							replace `step'=`step_i' if `Q'==`bestQ' & `include'==1
							replace `include'=0 if `Isquare'<=`i2l' & `Q'==`bestQ' 
							//replace `stop'=1 if `lowIsq'<=`i2l'
							 
						}						
						else {
							replace `step'=`step_i' if `Isquare'==`lowIsq' & `include'==1
							replace `include'=0 if `Isquare'==`lowIsq'
							//replace `stop'=1 if `Isquare'<=`i2l'
							 
						}
					*	replace `Isquare'=. if `Isquare'==`lowIsq'
					}
				
					* display "Studies that will be omitted:" 
					* list `id' `Isquare' if `Isquare'==`lowIsq' & `include'==0
					local step_i=`step_i'+1
					local k=`n'-`j'
					qui replace `stop'=1 if `lowIsq'<=`i2l'
					
				}
			

					

	

					display in white "Data BEFORE omission of studies:"	

					qui metan `E' `SE' if `touse', `random' eform nograph
					local ovES1: di %6.2f r(ES)
					local ovlCI1: di %6.2f r(ci_low)
					local ovuCI1: di %6.2f r(ci_upp)
					local ovQ1: di %6.2f r(het)
					local ovdf1: di %6.0f r(df)
					local ovIsquare1: di %4.1f max(0,(100*(`ovQ1'-`ovdf1')/`ovQ1'))
					local phet1: di %6.5f r(p_het)
					
					local h1=`ovQ1'/`ovdf1'

					if sqrt(`h1') <1 local h1=1
					if `ovQ1'>(`ovdf1'+1) {
						local selnh1=.5*[(log(`ovQ1')-ln(`ovdf1'))/(sqrt(2*`ovQ1') - sqrt(2*(`ovdf1'+1)-3))]
					}
					else {
						local selnh1=sqrt((1/(2*(`ovdf1'-1))*(1-1/(3*(`ovdf1'-1)^2))))
					}


					local l_h1=exp(log(sqrt(`h1')) - invnorm(0.975)*`selnh1')
					local u_h1=exp(log(sqrt(`h1')) + invnorm(0.975)*`selnh1')
					if `l_h1' <1 local l_h1=1				

					local l_I1: di %4.1f 100*max(0, (`l_h1'^2-1)/`l_h1'^2)
					local u_I1: di %4.1f 100*(`u_h1'^2-1)/`u_h1'^2



					

					display as text "Effect size and 95% CI: " as res `ovES1' " (" `ovlCI1' "-" `ovuCI1' ")"
					display in gr "Q: " in ye `ovQ1'
					display in gr "degrees of freedom: " in ye `ovdf1'
					display in gr "I square: " in ye `ovIsquare1' "%" " (" `l_I1' "%-" `u_I1' "%)"
					display in gr "p for heterogeneity: " in ye `phet1'
					display in gr "--------------------------------------------"
					
					
					display in white "Data AFTER omission of studies:"


					qui count if `include'==1
					local enoughn=r(N)
					if `enoughn'!=0 { // test if there are enough studies to perform meta-analysis
					qui metan `E' `SE' if `include'==1 , `random' eform nograph
					local ovES2: di %06.2f r(ES)
					local ovSElnES2 = r(selogES)
					local ovlCI2: di %6.2f r(ci_low)
					local ovuCI2: di %6.2f r(ci_upp)
					local ovQ2 = r(het)
					local ovdf2 = r(df)
					local ovIsquare2 = max(0,(100*(`ovQ2'-`ovdf2')/`ovQ2'))
					local phet2 = r(p_het)

					local h2=`ovQ2'/`ovdf2'

				
					

					if sqrt(`h2') <1 local h2=1
					if `ovQ2'>(`ovdf2'+1) {
						local selnh2=.5*[(log(`ovQ2')-ln(`ovdf2'))/(sqrt(2*`ovQ2') - sqrt(2*(`ovdf2'+1)-3))]
					}
					else {
						local selnh2=sqrt((1/(2*(`ovdf2'-1))*(1-1/(3*(`ovdf2'-1)^2))))
					}

				
					


					local l_h2=exp(log(sqrt(`h2')) - invnorm(0.975)*`selnh2')
					local u_h2=exp(log(sqrt(`h2')) + invnorm(0.975)*`selnh2')
					if `l_h2'<1 local l_h2=1
				

					local l_I2: di %4.1f 100*max(0, (`l_h2'^2-1)/`l_h2'^2)
					local u_I2: di %4.1f 100*(`u_h2'^2-1)/`u_h2'^2
				


					display as text "Effect size and 95% CI: " as res `ovES2' " (" `ovlCI2' "-"  `ovuCI2' ")"
					display in gr "Q: " in ye `ovQ2'
					display in gr "degrees of freedom: " in ye `ovdf2'
					display in gr "I square: " in ye `ovIsquare2' "%" " (" `l_I2' "%-" `u_I2' "%)"
					display in gr "p for heterogeneity: " in ye `phet2'

					display
					display

					display in white "Studies excluded: "
					qui sort `step'
					di in gr "	Study	Step	I-squared"
					list `id' `step' `Isquare' if `include'==0, noobs noheader 
					}

					else {
						di as err "No combination drops I-squared to wanted level: " %4.1f `i2l' "%"
					exit 
					}

				* Return values from algorithm 1:
				qui count if `include'==0
				local ex1=r(N)
				
				return scalar ES_1=`ovES2'
				return scalar lnES_1=`ovSElnES2'
				return scalar lowCI_1=`ovlCI2'
				return scalar uppCI_1=`ovuCI2'
				return scalar Q_1=`ovQ2'
				return scalar df_1=`ovdf2'
				return scalar phet_1=`phet2'
				return scalar per_ex_1=(`ex1'/`n')*100
				return scalar ex_1=`ex1'
				return scalar I2_1=`ovIsquare2'
				
				cap drop _step
				qui gen _step=.
				qui replace _step=`step' if `touse'
					

				
				* Here starts algorithm2

				local ncomb=0
				local I2_2min=`ovIsquare2'
				local I2_2max=`ovIsquare2'
				local ex2min=`ex1'
				local ex2max=`ex1'
				local Q2min=`ovQ2'
				local Q2max=`ovQ2'
				local df2min=`ovdf2'
				local df2max=`ovdf2'

				qui replace `include'=1 if `touse'
				qui sort `include'
				
				capture confirm ex `tuples' 
				if !_rc { // this needs fixing
					qui count if `touse'
					local n2=r(N)
					//local imax =( 2^`n2' - 1 ) // -`_n1'
					*local n2=`n'  // -1
					* di `imax' " " `_n1' " " `n2'
					cap drop _tuplesMin
					cap drop  _tuplesMax
					qui gen _tuplesMin=.
					qui gen _tuplesMax=.
					cap label drop include 
					label define include 0 "excluded" 1 "included"
					label val _tuplesMin include
					label val _tuplesMax include
	
					local k = 1 
					forval I = 2/`ex1' { 
						local bin=""
						forval i=1/`I' {
							local bin="`bin'"+"1"
						}
						while length("`bin'")<`n2' {
							local bin "`bin'0"
						} 
						
						scalar u=`n2'
						scalar y=`I'
						local binex="" // stop binary 
						forval i=1/`I' {
							local binex="`binex'"+"1"
						}
						while length("`binex'")<`n2' {
							local binex "0`binex'"
						} 

					 	while "`binex'"!="`bin'" {
							plugin call hplugin, u y _bin
						
							

							local bin : subinstr local bin "1" "1", ///
							all count(local n1)

							if `n1' == `I' { 
				 
								forval j = 1 / `n2' { 
									local char = substr("`bin'",`j',1) 

									qui replace `include'=0 in `j' if `char'==1 

								}
 
								qui metan `E' `SE' if `include'==1 & `touse', `random' eform nograph
								local Q=r(het)
								local df=r(df) 
								local I2=max(0,(100*(`Q'-`df')/`Q'))
								qui count if `include'==0
								local ex=r(N)
								if `I2'<=`i2l' {
									local ncomb=`ncomb'+1
									di as res "tuple`k': "
	
									di as text "Excluded: " as res `ex'
									list `id' if `include'==0, noobs table 
									di as text "I-squared: " as res `I2'
									di as text "Q: " as res `Q'
									di as text "df: " as res `df'	
									
									if (`df'>`df2min') {
										local Q2min=`Q'
										local I2_2min=`I2'
										local df2min=`df'
										local ex2min=`ex'
										qui replace _tuplesMin=`include'
									}
									if (`Q'<=`Q2min' & `df'==`df2min') {
										local Q2min=`Q'
										local I2_2min=`I2'
										local df2min=`df'
										local ex2min=`ex'
										qui replace _tuplesMin=`include'
									}

									if (`df'>`df2max') {
										local Q2max=`Q'
										local I2_2max=`I2'
										local df2max=`df'
										local ex2max=`ex'
										qui replace _tuplesMax=`include'
									}  
									

									if (`Q'>=`Q2max'  & `df'==`df2max') {
										local Q2max=`Q'
										local I2_2max=`I2'
										local df2max=`df'
										local ex2max=`ex'
										qui replace _tuplesMax=`include'
									}  

								}
							
							c_local tuple`++k'
							qui replace `include'=1 if `touse'
							}
						}
					* return values from algorithm 2
				
					return scalar ncomb=`ncomb'
					return scalar I2_2min=`I2_2min'
					return scalar I2_2max=`I2_2max'
					return scalar ex2min=`ex2min'
					return scalar ex2max=`ex2max'
					return scalar Q2min=`Q2min'
					return scalar Q2max=`Q2max'
					return scalar df2min=`df2min'
					return scalar df2max=`df2max'

					
				}
				
				}
				//else {
				//}
	drop _LCI _UCI _WT

	preserve
	end

program define hplugin, plugin using("hetred.plugin")
