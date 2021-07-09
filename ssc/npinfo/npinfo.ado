*! version 1.0  18june2014  Sebastian Pink

program define npinfo

	version 11

	syntax varlist, id(varlist) npcov(varlist) replace [dyads(string)]
	

	
	quietly{
	
	
	* Avoid mistakes
	* -------------- +
	// ID in one variable
	if `: word count `id'' > 1 {
		di as err "ID has to be one variable."
		exit
	}
	// dyads' variable name has to be one word
	if `: word count `dyads'' > 1 {
		di as err "Dyadic variable can't be named with a space."
		exit
	}
	
	
		
	
	
	* Step 1: Extract information from network partners and merge to focus person
	* --------------------------------------------------------------------------- +
	
	// Generate two tempfiles
	forv tmpfle = 1/2 {
		tempfile tmpfle`tmpfle'
	}
	
	
	// save original state of dataset
	save `tmpfle1', replace
	
	// Merge every information to the pertaining network partner
	foreach np of varlist `varlist' {
		
			// Prepare requested information about network partners
			keep `id' `npcov'
			rename `id' `np'
			loc npcovars_added ""
			foreach npcovar of varlist `npcov' {
				rename `npcovar' `np'_`npcovar'
				loc npcovars_added "`npcovars_added' `np'_`npcovar'"
			}
			save `tmpfle2', replace
		
			// Merge requested information to network partners
			use `tmpfle1', clear
			merge n:1 `np' using `tmpfle2', keep(1 3)
			foreach npcovar of varlist `npcov' {
				replace `np'_`npcovar' = .a if _merge == 1 // Indicate nodes without participation (unit-nonresponse)
			}
			drop _merge
			
			order `npcovars_added', after(`np')
			save `tmpfle1', replace
		
	}

	
	

	
	
	* [Optional] Step 2: Make a dyadic dataset according to the network partners
	* -------------------------------------------------------------------------- +
	if "`dyads'" != "" {
	
		// Rename variables according to a unique scheme to get them reshaped properly
		unab oldvarlist: `varlist'
	
		forv npvar = 1/`: word count `oldvarlist'' {
	
			// Identifier
			ren `: word `npvar' of `oldvarlist'' `dyads'`npvar'
	
			// NP-Variables
			foreach npcovariate in `npcov' {
				ren `: word `npvar' of `oldvarlist''_`npcovariate' `dyads'`npvar'_`npcovariate'
			}
		}

		// Generate reshape syntax
		loc reshape_syntax "`dyads'@"
		foreach npcovariate in `npcov' {
			loc reshape_syntax "`reshape_syntax' `dyads'@_`npcovariate'"
		}
		
		// Reshape data to long
		reshape long `reshape_syntax', i(`id') j(newvar)
		drop newvar
		
			* If one node has no outgoing ties, this node should 
			* nevertheless be kept because it denotes an isolate. Therefore, the syntax deleting
			* empty links generated via reshape have to respect those nodes.
			* This is crucial for longitudinal networks. If these nodes aren't entailed, 
			* between two time points the set of nodes might differ while individual
			* information on the same node is available in both time points.
			bys `id': egen npinfo_helper1 = max(`dyads') 
			drop if mi(`dyads') & !mi(npinfo_helper1)
			bys `id': drop if mi(npinfo_helper1) & _n > 1
			drop npinfo_helper1
			
	sort `id'
	
	}
	
	}
		
end
		
		
* END.
