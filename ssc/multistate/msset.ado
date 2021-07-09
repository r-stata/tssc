*! version 1.0.1 15aug2016 MJC

/*
History
MJC 15aug2016: version 1.0.1 - covariates() added
MJC 12jul2016: version 1.0.0
*/

/*
Development

Problem situations
-> multiple events at the same time - handled by assuming earliest event (by state number) occurs, rest changed to censored
-> event occurs, then next states are all censored at event time - drop at the end of while loop??

-> Assumes everyone starts in original null state
-> Need to label _trans var with value labels eg. 1 "1 -> 2" 2 "1 -> 3"
added _flag

Return list
-> transition matrix
-> frequency matrix
-> panel id variable
*/


program define msset, rclass
	version 14.1
	syntax [if] [in], 									///
						ID(varname numeric)				///
						STATES(varlist numeric) 		/// -Indicator variables for each state-
						TIMES(varlist numeric)			///	-Event/censoring time for each state-
					[									///
						TRANSMatrix(string)				/// -Define a transition matrix-
						CR								///	-Competing risks analysis for default transmat, 0 to each state the only transitions-
						COVariates(varlist numeric)		///	-expand covariates-
					]
					
	//====================================================================================================================================================//
	// Error checks
		
		local Nstates : list sizeof states
		local Nstatetimes : list sizeof times
		if `Nstates'!=`Nstatetimes' {
			di as error "Number of state variables, states(), must match number of state time variables, times()"
			exit 198
		}
		
	//====================================================================================================================================================//
	// Preliminaries
				
		local Nstates = `Nstates' + 1

		//Create core variables
		quietly {
			cap drop _from
			gen _from 			= 1
			label var _from "Starting state"
			cap drop _to
			gen _to 			= .
			label var _to "Receiving state"
			cap drop _status
			gen byte _status	= 0
			label var _status "Event (transition) indicator"
			cap drop _start
			gen double _start 	= 0
			label var _start "Starting time for each transition"
			cap drop _stop
			gen double _stop	= 0
			label var _stop "Stopping time for each transition"
			cap drop _flag
			gen byte _flag		= 0
			label var _flag "Data modified"
		}
		
		//Frequency matrix
		tempname freqmat
		mat `freqmat' = J(`Nstates',`Nstates',0)
		
		//Default transition matrix
		if "`transmatrix'"=="" {
			tempname transmatrix
			mat `transmatrix' = J(`Nstates',`Nstates',.)
			mat roweq `transmatrix' = from
			mat coleq `transmatrix' = to
			forvalues i=1/`Nstates' {
				local names `names' `i'
			}
			mat rownames `transmatrix' = start `states'
			mat colnames `transmatrix' = start `states'
			local index = 1	
			local path = 1
			if "`cr'"=="" {
				while (`index'<`Nstates') {
					forvalues i=`=`index'+1'/`Nstates' {
						mat `transmatrix'[`index',`i'] = `path'
						local `++path'
					}
					local `++index'
				}	
			}
			else {
				forvalues i=`=`index'+1'/`Nstates' {
					mat `transmatrix'[`index',`i'] = `path'
					local `++path'
				}
			}
		}
		
		mata: msprep_setup()	//checks and temp transition matrix
		//mata: msset_paths()		//generate possible paths
		
	//====================================================================================================================================================//
	// Handle transitions
	
		//start with tempbasefile
		tempfile basefile
		qui save `basefile', replace

		local row = 1
		local flag = 1
		while `row'<`Nstates' {

			local Nmoves = `Nmovesmat'[`row',1]
			if `Nmoves'>0 {
			
				//re-load base dataset
				if (`row'!=1) {
					qui use `basefile', clear
					local iftxt & _to==`row'
					local if2txt if _to==`row'
					local if3txt & _from==`row'
				}

				//extract next possible transition variables
				forvalues i=`=`row'+1'/`Nstates' {
					if `transmatrix'[`row',`i']!=. {
						local postrans`row' `postrans`row'' `: word `=`i'-1' of `times''		//possible next states			
						local posstates`row' `posstates`row'' `: word `=`i'-1' of `states''
					}			
				}					
				//Check for multiple next events at the same time
				local Nnextstates : list sizeof postrans`row'
				forvalues j = 1/`=`Nnextstates'-1'{
					local stvar1 : word `j' of `postrans`row''
					local sevar1 : word `j' of `posstates`row''
					forvalues k = `=`j'+1'/`Nnextstates' {
						local stvar2 : word `k' of `postrans`row''
						local sevar2 : word `k' of `posstates`row''	
						tempvar clash_ind_`j'_`k'

						qui egen `clash_ind_`j'_`k'' = diff(`stvar1' `stvar2') if `sevar1'==1 & `sevar2'==1 `iftxt'
						qui count if `clash_ind_`j'_`k''==0
						if `r(N)' {
							local newn = `r(N)' 
							di in yellow "Warning: `newn' observations experienced events `sevar1' and `sevar2' at the same time"
							di in yellow "         `sevar2' has been recoded to censored for these observations."
							di in yellow "         They can be identified using _flag==1"
							qui replace `sevar2' = 0 if `clash_ind_`j'_`k''==0 `iftxt'
							qui replace _flag = `flag' if `clash_ind_`j'_`k''==0 `iftxt'
							local flag = `flag'+1
						}
					}
				}		
				
				//handle core vars
				qui replace _status = 0 `if2txt'
				qui replace _from = `row' `if2txt'
				qui replace _start = _stop `if2txt'
				qui replace _stop = . `if2txt'
				
				//handle to and stop
				forvalues i=`=`row'+1'/`Nstates' {
					if `transmatrix'[`row',`i']!=. {
						local tvar : word `=`i'-1' of `times'
						local stvar : word `=`i'-1' of `states'
						qui replace _to = `i' if `stvar'==1 & `tvar'<_stop  `if3txt'
						qui replace _stop = `tvar' if `stvar'==1 & `tvar'<_stop  `if3txt'  //stop is missing if no event
					}
				}
								
				//Update base dataset
				qui save, replace
				//Reduce to rows in current state
				if `row'!=1 {
					qui keep if _from==`row'
				}
						
				//expand dataset
				qui expand `Nmoves'

				//status event indicator
				local index = 1
				forvalues i=`=`row'+1'/`Nstates' {
					if `transmatrix'[`row',`i']!=. {
						local tvar : word `=`i'-1' of `times'
						local stvar : word `=`i'-1' of `states'
						qui bys `id': replace _to = `i' if _n==`index'
						qui bys `id': replace _status = 1 if `stvar'==1 & _n==`index' & _stop==`tvar'
						local `++index'
					}			
				}			
				
				//No next event, just censoring
				if (`Nmoves'>1) {
					local postrans`row' : subinstr local postrans`row' " " ",", all
					local posstates`row' : subinstr local posstates`row' " " ",", all
					qui bys `id': replace _stop = min(`postrans`row'') if max(`posstates`row'')==0	//replace with minimum censoring time if all next states censored
				}
				else qui replace _stop = `postrans`row'' if `posstates`row''==0
				
				//remove rows where enter event time is same as next censoring time?
				//qui drop if start==stop
				//instead this should flag up to user in stset
				
				//save and continue
				tempfile msfile`row'
				qui save `msfile`row'',replace
				local mergefiles `mergefiles' `msfile`row''
				
			}
			local `++row'
		}
		
		//append files and sort
		local nfiles : list sizeof mergefiles
		qui use `: word 1 of `mergefiles'',clear
		forvalues i=2/`nfiles' {
			local f`i' : word `i' of `mergefiles'
			qui append using `f`i''
		}
		qui sort `id' _from _to
		
		//frequencies
		forvalues i=1/`=`Nstates'-1' {
			forvalues j=2/`Nstates' {
				qui count if _from==`i' & _to==`j' & _status==1
				mat `freqmat'[`i',`j'] = `r(N)'
				local txt`i' `txt`i'' & to==`j'	//!! check when no events for that transition
			}
		}
	
		//generate transition indicator variables
		cap sort `id' _from _to
		qui egen _trans = group(_from _to)
		qui label var _trans "Transition number"
		qui tab _trans, gen(_trans)
		
		// generate transition specific covariates
		if "`covariates'"!="" {
			foreach cov in `covariates' {
				forvalues i=1/`Ntrans' {
					gen `cov'_trans`i' = `cov' * _trans`i'
				}
				di in green "variables `cov'_trans1 to `cov'_trans`Ntrans' created"
			}
		}
		
		//return stuff
		return matrix transmatrix 	= `transmatrix', copy
		return matrix freqmatrix 	= `freqmat'
		return matrix Nnextstates = `Nmovesmat'
		return local id `id'

end
 
mata
void msprep_setup()
{
	tmat = st_matrix(st_local("transmatrix"))
	tmat_ind = tmat:!=.							//indicator matrix
	
	//Error checks
	if (max(diagonal(tmat_ind))>0) {
		errprintf("All elements on the diagonal of transmatrix() must be coded missing = .\n")
		exit(198)
	}
	if (max(lowertriangle(tmat_ind))>0) {
		errprintf("All elements of the lower triangle of transmatrix() must be coded missing = .\n")
		exit(198)
	}
	row = 1
	rtmat = rows(tmat)
	trans = 1
	while (row<rtmat) {
		for (i=row+1;i<=rtmat;i++) {
			if (sum(tmat:==tmat[row,i])>1 & tmat[row,i]!=.) {
				errprintf("Elements in the upper triangle of transmatrix() are not unique\n")
				exit(198)
			}
			if (tmat[row,i]!=. & tmat[row,i]!=trans){
				errprintf("Elements in the upper triangle of transmatrix() must be sequentially numbered from 1,...,K, where K = number of transitions\n")
				exit(198)
			}		
			if (tmat[i,row]!=.) {
				errprintf("Elements in the lower triangle of transmatrix() must be coded missing = .\n")
				exit(198)
			}
			if (tmat[row,i]!=.) trans++
		}
		row++
	}
	st_local("Ntrans",strofreal(trans-1))
	
	for (j=1;j<=rtmat;j++) {
		if (tmat[j,j]!=.) {
			errprintf("Elements in the diagonal of transmatrix() must be coded missing = .\n")
			exit(198)
		}	
	}
	//Post number of transitions
	stata("tempname Nmovesmat")
	st_matrix(st_local("Nmovesmat"),rowsum(tmat_ind,1))
}

end
