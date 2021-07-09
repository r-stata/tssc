*! version 2.0 November 14, 2016 @ 10:04:11
*! Perform an optimal matching with Needleman-Wunsch-Algorithm
*! Author: Kohler/Luniak,
*! Option -sadi()- calls programs by Brendan Halpin, University of Limerick
	
* Thanks to Wikipedia.de for nice description of NW
* Source: http://de.wikipedia.org/wiki/Needleman-Wunsch-Algorithmus

*1.0 Initial version
*1.1 undocumented changes
*1.2 undocumented changes
*1.3 undoucmented changes
*1.4 Version distrubted on SSC
*1.5 Bug fix. Sorting != sqclusterdat -> also needed a fix in sqclusterdat.ado
*1.6 Bug fix. reshape wide not possible if cov. varies within id -> SJ version
*1.7 New Option subsequence()
*1.8 tempfiles in compount double quotes
*1.9 version-marker to 9.2. Option idealtype
*1.10 Bug fix. refseqid() returned "not allowed with idealtype".
*1.11 Bug fix. Option Subsequence() did not return its definition to sqclusterdat	
*1.12 New option of SUBcost: min/max/meanprobdistance
*     & checking of symmetric property of subcost matrix
*1.13 Bug fix. issym not found
*1.14 New option "plugin" to call Plugin by brendan.halpin@ul.ie
*1.15 One-to-one mapping of sequences to the alphabet of natural numbers
*1.16 Bug fix. Most frequent sequence were not used automatically as reference frequence
*1.17 Gaps at the beginning does not work with full subcost matrix.
*     We now issue an error message that makes the point clear
*1.18 Save/Restore Distance matrix on/from file
*1.19 Bug fix. refseqid() with floating point sequence identifiers returned an error.
*1.20 Remove bug fix. This is better. 

*2.00 Major new release
* Prepare SQ-Dist for wardslinkage
* Call to SADI

program sqom, rclass
version 9.2

	syntax [anything] [if] [in] [, SUBSEQuence(string) IDEALtype(string)       ///
	  k(int 0) INDELcost(real 1) name(string)                       ///
	  SUBcost(string) STandard(string) REFseqid(string) full sadi(string) ///
	  clear replace *]

	// SQ-Data
	// -------

	if "`_dta[SQis]'" == "" {
		di as error "data not declared as SQ-data; use -sqset-"
		exit 9
	}


	// Branch Program
	// --------------

	if "`:word 1 of `anything''" == "save" {
		gettoken subcmd rest:0
		_SQOMSAVE using `rest'
		exit
	}

	else if "`:word 1 of `anything''" == "use" {
		gettoken subcmd rest:0
		_SQOMUSE using `rest'
		exit
	}

	else if "`:word 1 of `anything''" != "" {
		di as error "`anything' not allowed"
		exit 198
	}


	// Declarations
	// ------------

	tempvar gap epiid epicount SQom SQid cutter N length
	tempfile SQorig SQrefseq noshrink results 

	// Store definition for sqclusterdat
	// ----------------------------------
	
	char _dta[SQomsample] `if' `in'
	char _dta[SQomsubcost] `subcost'
	
	// Defaults
	// --------

	local full = cond("`full'"=="full",1,0)
   if "`sadi'" != "" {
		local full 1
		capture which oma
		if _rc {
			di "{err} SADI not installed."
			di "{txt} Install SADI with -ssc install sadi- for option -sadi()-"
			exit _rc
		}
	}

	if !`full' capture drop _SQdist

	quietly {

		// Error Checks
		// ------------
    
		if "`name'" != "" & "`full'" == "" confirm new variable `name'
		else if "`name'" != "" & "`full'" != "" {
			gettoken Dname replace: name
			if "`replace'" == "" confirm new file `Dname'
		}

		// either refseqid or ideqltype
		if "`refseqid'" != "" & "`idealtype'" != "" {
			noi di as error "idealtype() not allowed with refseqid()"
			exit 198
		}

		// Negative Substitution Costs?
			local check = real("`subcost'")
		if `check' <= 0   {
			noi di as error "subcost(<=0) invalid"
			exit 198
		}

		// Construct the subcost matrix
		// ----------------------------
    
		if "`subcost'" == "" {
			local subcost = `indelcost'*2
			if "`sadi'" != "" {
				if inlist("`sadi'","hamming","hollister","twed") local subcost 1

				// SADI allways requires a matrix
				tab `_dta[SQis]'
				matrix SQsubcost = J(`r(r)',`r(r)',`subcost') - I(`r(r)')*`subcost'
			}
		}
		capture confirm number `subcost'
		if _rc {
			if inlist("`subcost'","rawdistance","maxprobdistance","minprobdistance","meanprobdistance") {
				if "`subcost'" == "rawdistance" {
					capture confirm numeric variable `_dta[SQis]'
					if _rc {
						noi di as error ///
					  	"subcost(rawdistance) not allowed with string variables"
						exit 189
					}
					else if "`sadi'" != "" {
						levelsof `_dta[SQis]', local(ELEMENTS)
						matrix ROWS = J(`:word count `ELEMENTS'',`:word count `ELEMENTS'',.)
						local rows = subinstr("`ELEMENTS'"," ",",",.)
						foreach element of local ELEMENTS {
							matrix ROWS[`element',1] = `rows'
						}
						mata:  st_matrix("SQsubcost",abs(st_matrix("ROWS") - st_matrix("ROWS")'))
						matrix drop ROWS
					}
					local subcost -1
				}
				// generate the probability matrix
				else{
					tempvar SQis_moved
					by `_dta[SQiis]', sort: gen `SQis_moved' = `_dta[SQis]'[_n-1]
					tab `_dta[SQis]' `SQis_moved', matcell(notsymprob)
					
 					count if `_dta[SQis]' < . &  `SQis_moved' < .
					matrix notsymprob = notsymprob/r(N)
					matrix notsymsubcost = notsymprob
					local col = colsof(notsymsubcost)
					local row = rowsof(notsymsubcost) 
					forvalues i = 1(1)`col' {
							forvalues j = 1(1)`row'{
								matrix notsymsubcost[`i',`j']= (1-notsymsubcost[`i',`j'])*2 //*2 for indelcosts
							}
						}					

					//SQsubcost matrix should be symmetric
					matrix SQsubcost = notsymsubcost
					//maximal costs
					if("`subcost'" == "maxprobdistance" ){
						forvalues i = 1(1)`col' {
							forvalues j = 1(1)`row'{
								if(`i'==`j'){
								matrix SQsubcost[`i',`j']= 0	
								}
								else{
								local maxsub = max(notsymsubcost[`i',`j'],notsymsubcost[`j',`i'])
								matrix SQsubcost[`i',`j']= `maxsub'
								matrix SQsubcost[`j',`i']= `maxsub'
								}
							}
						}
					}

					//minimal costs
					if("`subcost'" == "minprobdistance" ){
						forvalues i = 1(1)`col' {
							forvalues j = 1(1)`row'{
								if(`i'==`j'){
								matrix SQsubcost[`i',`j']= 0	
								}
								else{
								local minsub = min(notsymsubcost[`i',`j'],notsymsubcost[`j',`i'])
								matrix SQsubcost[`i',`j']= `minsub'
								matrix SQsubcost[`j',`i']= `minsub'
								}
							}
						}
					}

					if("`subcost'" == "meanprobdistance" ){
						forvalues i = 1(1)`col' {
							forvalues j = 1(1)`row'{
								if(`i'==`j'){
								matrix SQsubcost[`i',`j']= 0	
								}
								else{
								local meansub = 2-notsymprob[`i',`j']-notsymprob[`j',`i']
								matrix SQsubcost[`i',`j']= `meansub'
								matrix SQsubcost[`j',`i']= `meansub'
								}
							}
						}
					}

					
					noi matrix list SQsubcost
					levelsof `_dta[SQis]', local(Element)
					local levels: subinstr local Element `" "' `","' , all 
					matrix levels = `levels'
					matrix rownames SQsubcost = `Element'
					matrix colnames SQsubcost = `Element'
					local subcost 0
				}
			}
			else {
				capture matrix SQsubcost = `subcost'
				if _rc{
					noi di as error ///
					  "subcost() invalid: specify number, -rawdistance-, -minprobdistance-, -maxprobdistance- or matrix"
					exit 198
				}
				//is subcostmatrix symmetric?
				local issym = issymmetric(SQsubcost)
				if !`issym'{
					noi di as error ///
					  "subcostmatrix invalid: subcostmatrix is not symmetric"
					exit 198
				}
				
				levelsof `_dta[SQis]', local(Element)
				local levels: subinstr local Element `" "' `","' , all 
				matrix levels = `levels'
				matrix rownames SQsubcost = `Element'
				matrix colnames SQsubcost = `Element'
				local subcost 0
			}
        
		}

		// Shrink the Data -> Speed
		// ------------------------
    
		marksample touse
		if "`subsequence'" != "" {
			quietly replace `touse' = 0 if !inrange(`_dta[SQtis]',`subsequence')
			char _dta[SQomsubseq] if !inrange(`_dta[SQtis]',`subsequence')
		}
		preserve
		
		// Drop Sequences with Gaps 
		if "`gapinclude'" == "" {
			tempvar lcensor rcensor gap
			by `_dta[SQiis]' (`_dta[SQtis]'), sort: gen `lcensor' = sum(!mi(`_dta[SQis]'))
			by `_dta[SQiis]' (`_dta[SQtis]'): gen `rcensor' = sum(mi(`_dta[SQis]'))
			by `_dta[SQiis]' (`_dta[SQtis]'): ///
			  replace `rcensor' = ((_N-_n) == (`rcensor'[_N]-`rcensor'[_n])) & mi(`_dta[SQis]')
			by `_dta[SQiis]' (`_dta[SQtis]'): ///
			  gen `gap' = sum(mi(`_dta[SQis]') & `lcensor' & !`rcensor')
			by `_dta[SQiis]' (`_dta[SQtis]'): ///
			  replace `touse' = 0 if `gap'[_N]>0
		}
		keep if `touse'
		if _N == 0 {
			noi di as text "(No observations)"
			exit
		}
		capture by `_dta[SQiis]' (`_dta[SQtis]'): assert `lcensor'[1]!=0
		if `subcost'==0 & _rc==9 {
			di as error "Don't use full subcost matrix on non ltrimmed sequences"
			exit 9
		}
		drop `lcensor' `rcensor'

		// Handle Standardisation Option
		capture confirm integer number `standard'
		if !_rc {
			drop if `_dta[SQtis]' > `standard'
			local standard none
		}
		else if "`standard'" == "cut" {
			drop if `_dta[SQis]' >= . & !`gap' 
			by `_dta[SQiis]' (`_dta[SQtis]'), sort: gen `cutter' = _N if !`gap'
			sum `cutter', meanonly
			drop if `_dta[SQtis]' > r(min)
			local standard none
		}
		else if "`standard'" == "" {
			local standard longest
		}
		else if "`standard'" != "none" & "`standard'" != "longer" {
			noi di as error "standard() invalid"
			exit 198
		}

		// SADI requires length. 
		if "`sadi'" != "" {
			by `_dta[SQiis]' (`_dta[SQtis]'), sort: gen `length' = _N
			sum `length', meanonly
			local maxlength = r(max)
		}
		
		//One-to-one mapping of sequences to the alphabet 1,2,..,n
		//Condition: no raw distance
		if ("`subcost'" != "rawdistance") {
			tempvar newalph
			gen `newalph'= .
			levelsof `_dta[SQis]', local(Element)
		
			local newelement 1

			foreach l of local Element{
				replace `newalph' = `newelement++' if `_dta[SQis]'== `l'
			}
			replace `_dta[SQis]' = `newalph'
		}

		// Reshape Wide
		sum `_dta[SQtis]', meanonly
		local tfirst = r(min)
		keep `_dta[SQis]' `_dta[SQiis]' `_dta[SQtis]' `=cond("`sadi'"!="","`length'","")'
		reshape wide `_dta[SQis]', i(`_dta[SQiis]') j(`_dta[SQtis]') 
		unab varlist: `_dta[SQis]'*

		// Store reference sequence
		if "`refseqid'" != "" {
			save `"`results'"'
			capture confirm numeric variable `_dta[SQiis]'
			if !_rc {
				count if `_dta[SQiis]' == `refseqid'
				capture assert r(N) > 0
				if _rc {
					noi di as error "reference sequence does not exist"
					exit 198
				}
				keep if `_dta[SQiis]' == `refseqid'
			}
			else {
				count if `_dta[SQiis]' == "`refseqid'"
				capture assert r(N) > 0
				if _rc {
					noi di as error "reference sequence does not exist"
					exit 198
				}
				keep if `_dta[SQiis]' == "`refseqid'"
			}
			save `"`SQrefseq'"'
			use `"`results'"', clear
		}

		// Handle idealtype()
		if "`idealtype'" != "" {
			local SQiis `_dta[SQiis]'
			local SQtis `_dta[SQtis]'
			local SQis `_dta[SQis]'
			sum `_dta[SQiis]' 
		    local last = r(max)+1
			save "`results'"
			drop _all
			gen  `SQiis' = .
			gen  `SQtis' = .
			gen  `SQis'  = .

			local i `tfirst'
			local counter 1
			foreach epi in `idealtype' {
				if strpos("`epi'",":") {
					gettoken element times: epi, parse(:)
					local times: subinstr local times ":" "", all
				}
				else {
					local element `epi'
					local times 1
				}
				forv j = 1/`times' {
					set obs `counter'
					replace `SQiis' = `last' in `counter'
					replace `SQtis' = `i++' in `counter'
					replace `SQis' = `element' in `counter++'
				}
			}
			reshape wide `SQis', i(`SQiis') j(`SQtis')
			save `"`SQrefseq'"'
			use `"`results'"', clear
			}
		
		// Store a copy
		by `varlist' (`_dta[SQiis]'), sort: gen `SQid' = 1 if _n==1
		replace `SQid' = sum(`SQid')
		sort `SQid'
		save `"`noshrink'"'

		// Keep only one Sequence of each type
		by `varlist', sort: gen `N' = _N
		by `SQid', sort: keep if _n==1
		if "`refseqid'" != "" | "`idealtype'" != "" append using `"`SQrefseq'"'

		// Call the Mata-Function from lsq.lib (Source-Code: lsq.mata)
			if !`full' {
			sort `N'
			capture drop _SQdist
			mata: sqomref("`varlist'",`indelcost',"`standard'",`k',`subcost')
			drop if `SQid'==.
			sort `SQid'
			save `"`results'"', replace

			use `"`noshrink'"', clear 
			merge `SQid' using `"`results'"'
			assert _merge ==3
			drop _merge
			keep `_dta[SQiis]' _SQdist
			label var _SQdist ///
			  `"sqom with k(`k') indel(`indelcost') subcost(`subcost') refseqid(`refseqid') "'	
			if "`name'" != "" ren _SQdist `name'	
			sort `_dta[SQiis]'
			save `"`results'"', replace

			restore
			sort `_dta[SQiis]'
			merge `_dta[SQiis]' using `"`results'"'
			assert _merge!=2
			drop _merge
			noi di as text `"Distance Variable saved as"' ///
			  as res `" `=cond("`name'"=="","_SQdist","`name'")' "'
		}

		if `full' {

			// Use Brendan Halpins Plugin
				if `"`sadi'"' != `""'  {
				if "`standard'"=="none" local standard standard(none)
				if "`standard'"=="longest" local standard standard(`maxlength')
				if "`standard'"=="longer" local standard standard(longer)
				
				if "`k'"!="0" {
					noi as txt di "Option -k(`k')-, ignored with sqom, plugin"
				}
				if "`sadi'" == "hamming" local required subsmat(SQsubcost) pwdist(SQdist)
				else if inlist("`sadi'","oma","omav") local required indel(`indelcost') subsmat(SQsubcost) length(`length') `standard' pwdist(SQdist)
				else if inlist("`sadi'","twed","hollister") local required subsmat(SQsubcost) length(`length') `standard' pwdist(SQdist)
				else if inlist("`sadi'","dynhamming") local required pwdist(SQdist)
				
				noi di as text "Running plugin; Please cite Brandan Halpin's work"
				noi `sadi' `varlist' , `required'  `options' 
				noi mata: sqexpand()
				}

			// Use Mata
			else {

				noi di as text "Perform " ///
				  as res _N*(_N-1)/2 ///
				  as text " Comparisons with Needleman-Wunsch Algorithm"

				noi di as text "Running mata function"
				mata: sqomfull("`varlist'",`indelcost',"`standard'",`k',`subcost')
				noi mata: sqexpand()
			}
			restore
			noi di as text "Distance matrix saved as " as res "SQdist"

		}
	}
	
	// Return
	// ------

	return local name =cond("`name'"=="","_SQdist","`name'")

end

program _SQOMSAVE
version 11
	syntax using/ [, replace]
	gettoken file ext:using, parse(".")
	if "`ext'" == "" local ext .mmat
	if "`replace'" == "" {
		confirm new file `"`file'`ext'"'
	}
	else if "`replace'" != "" {
		capture confirm file `"`file'`ext'"'
		if _rc==601 di as text "(note: file `file'`ext' not found)"
		erase `"`file'`ext'"'
	}
	mata:sqomsave(`"`file'`ext'"')
end

program _SQOMUSE
version 11
	syntax using/ [, clear]
	gettoken file ext:using, parse(".")
	if "`ext'" == "" local ext .mmat
	if "`clear'" == "" {
		capture confirm matrix SQdist
		if !_rc {
			di as error "No! SQdist already exist."
			exit 198
		}
	}
	mata:sqompush(`"`file'`ext'"')
end


exit




	
