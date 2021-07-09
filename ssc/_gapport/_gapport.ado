*! version 1.2.1 Oktober 8, 2010 @ 14:13:23
* Calculates seats in party-list proportional representation

* 1.0: initial version
* 1.1: quietly, divisor series in d'Hondt
* 1.2: renamed to apport
* 1.2.1: Bug-fix. Unusal errors of subprograms ignored. fixed.

// Main Program
// ------------

program _gapport, byable(onecall) sortpreserve 
version 10
	gettoken type 0 : 0
	gettoken h    0 : 0 
	gettoken eqs  0 : 0
	
	syntax varname(numeric) [if] [in] 	/// 
	  [ , Size(string) Method(string) 	/// 
	  by(varlist) Threshold(string) Exception(string)]
	marksample touse

	// Tempvars
	// --------

	tempvar ntot nvalid sizevar

	// Defaults and Synonyms
	// ---------------------
	
	if inlist("`method'","dhondt","hagenbach-bischoff","greatest")  /// 
	  local method "jefferson"
	if inlist("`method'","hare-niemeyer","remainder","vinton") 	/// 
	  local method "hamilton"
	if inlist("`method'","stlague","majorfraction")  /// 
	  local method "webster"
	if inlist("`method'","huntington","geometric")  /// 
	  local method "hill"
	if inlist("`method'","harmonic")  /// 
	  local method "dean"
	if inlist("`method'","smallest")  /// 
	  local method "adam"
	if "`method'" == "" local method "jefferson"

	quietly {

		// By Option
		// ---------

		if "`by'"=="" {
			tempvar by
			gen byte `by' = 1
		}

		// Size Option
		// -----------

		if "`size'" == "" gen long `sizevar' = 100
		else {
			capture confirm numeric variable `size'
			if _rc {
				capture confirm integer number `size'
				if _rc {
					display as error "size() not valid"
					exit 198
				}
				else gen long `sizevar' = `size'
			}
			else {
				gen long `sizevar' = `size'
				tempvar isconstant
				by `touse' `by', sort: 	/// 
				  gen `isconstant' = sum(`sizevar' != `sizevar'[_n-1]) if `touse'
				capture by `touse' `by': assert `isconstant'[_N]==1 if `touse'
				if _rc {
					noi display as error "`size' not constant"
					exit _rc
				}
				drop `isconstant'
			}
		}
		
		// Threshold Option
		// ----------------
		
		if "`threshold'" != "" {
			tempvar thresholdvar
			capture confirm numeric variable `threshold'
			if _rc {
				capture confirm number `threshold'
				if _rc {
					display as error "threshold() not valid"
					exit 198
				}
				else gen long `thresholdvar' = `threshold'
			}
			else {
				gen long `thresholdvar' = `threshold'
				tempvar isconstant
				by `touse' `by', sort: 	/// 
				  gen `isconstant' = sum(`thresholdvar' != `thresholdvar'[_n-1])
				capture by `touse' `by': assert `isconstant'[_N]==1 if `thresholdvar' < .
				if _rc {
					noi display as error "`threshold' not constant"
					exit _rc
				}
				drop `isconstant'
			}
			
			bysort `touse' `by': gen long `ntot' = sum(`varlist') if `touse'
			by `touse' `by': replace `touse' = 0  /// 
			  if `varlist'/`ntot'[_N]*100 < `thresholdvar'
		}
		
		// Exception
		// ---------
		
		if `"`exception'"' != `""' {
			replace `touse' = 1 if !mi(`ntot') & `exception'
		}
		
		// Number of valid votes
		// ---------------------
		
		bysort `touse' `by': gen long `nvalid' = sum(`varlist') if `touse'
		by `touse' `by': replace `nvalid' = `nvalid'[_N] if `touse'
		

		// Call Apportionment Method
		// -------------------------

		capture  APPORT_`method' `varlist' `nvalid' `sizevar'  /// 
		  if `touse', by(`by') h(`h')
		if _rc == 9 {
			di as error "Allocated seats don't add up to size. Check results manually"
			exit _rc
		}
		else if _rc {
			exit _rc
		}
}
end


// Hamilton Method
// ---------------
// aka Hare/Niemeyer, largest remainder, Vintons method

program APPORT_hamilton
	syntax varlist if, by(varlist) h(name)
	marksample touse
	args votes nvalid sizevar
		
	tempvar sumseats R rest

	by `touse' `by', sort: 				/// 
	  gen `type' `h' = int(`votes'/`nvalid' * `sizevar') if `touse'
	by `touse' `by': 				/// 
	  gen double `R' = abs((`votes'/`nvalid' * `sizevar') - `h') 	/// 
	  if `touse'
	
	by `touse' `by': gen long `sumseats' = sum(`h') if `touse'
	by `touse' `by': gen long `rest' = `sizevar' - `sumseats'[_N]

	bysort `touse' `by' (`R' `votes'): replace `h' = `h'+1 if _n > (_N - `rest')
end


// Jefferson Method
// -----------------
// aka d'Hondt, Divisor, Hagenbach-Bischoff

program APPORT_jefferson
	syntax varlist if, by(varlist) h(name)
	marksample touse
	args votes nvalid sizevar 

	tempvar control rest tomuch upwardthreshold index j tag

	local D  "(`nvalid'/`sizevar')"

	bysort `touse' `by': gen `type' `h' =  floor(`votes'/`D')  ///
	  if `touse'

	by `touse' `by': gen long `control' = sum(`h') if `touse'
	by `touse' `by': gen long `rest' = abs(`control'[_N]-`sizevar') 

	sum `rest', meanonly
	if r(max) != 0 {

		forv i = 1/`=r(max)' {
			gen double `upwardthreshold'`i' =  `votes'/(`h'+`i') if `touse'
		}
			
		gen `index' = _n
		reshape long `upwardthreshold', i(`index') j(`j')

		bysort `touse' `by' (`upwardthreshold'):  ///
		  gen byte `tag' = _n==(_N-`rest'+1)

		local D "(`upwardthreshold'[_N]-`=epsfloat()')"

		bysort `touse' `by' (`tag'): replace `h' =  floor(`votes'/`D')  ///
		  if `touse' &  `rest'

		drop `tag'
		reshape wide 

		bysort `touse' `by': replace `control' = sum(`h') if `touse'
		by `touse' `by': assert `control'[_N]==`sizevar' if `touse'
	}
end


// Webster’s method
// -----------------

program APPORT_webster
	syntax varlist if, by(varlist) h(name)
	marksample touse
	args votes nvalid sizevar 

	tempvar control rest tomuch downwardthreshold upwardthreshold tag index j

	local D  "(`nvalid'/`sizevar')"
	local Tau ".5"

	bysort `touse' `by': gen `type' `h' =  floor(`votes'/`D' + `Tau')  ///
	  if `touse'

	by `touse' `by': gen long `control' = sum(`h') if `touse'
	by `touse' `by': gen long `rest' = abs(`control'[_N]-`sizevar')
	by `touse' `by': gen byte `tomuch' = `control'[_N] > `sizevar' if `rest'!=0

	sum `rest', meanonly
	if r(max) != 0 {

		forv i = 1/`=r(max)' {
			gen double `upwardthreshold'`i' =  `votes'/(`h'+`i'-.5) if `touse'
			gen double `downwardthreshold'`i' =  cond(`h'>`i'-1,`votes'/((`h'-`i') + .5),.) if `touse'
		}

		gen `index' = _n
		reshape long `upwardthreshold' `downwardthreshold', i(`index') j(`j')

		bysort `touse' `by' (`downwardthreshold'): gen byte `tag' = _n==`rest' if `tomuch' 
		bysort `touse' `by' (`upwardthreshold'): replace `tag' = _n==(_N-`rest'+1) if !`tomuch' 
	
		local D "cond(`tomuch',(`downwardthreshold'[_N]+`=epsfloat()'),(`upwardthreshold'[_N]-`=epsfloat()'))"
		
		bysort `touse' `by' (`tag'): replace `h' =  floor(`votes'/`D' + `Tau')  ///
		  if `touse' &  `rest' 
		
		drop `tag'
		reshape wide 

		bysort `touse' `by': replace `control' = sum(`h') if `touse'
		by `touse' `by': assert `control'[_N]==`sizevar' if `touse'
	}
end

// Hill’s method
// -----------------

program APPORT_hill
	syntax varlist if, by(varlist) h(name)
	marksample touse
	args votes nvalid sizevar 

	tempvar control rest tomuch downwardthreshold upwardthreshold tag index j

	local D  "(`nvalid'/`sizevar')"
	local threshold  "(sqrt(floor(`votes'/`D')*ceil(`votes'/`D')))"
	local Tau "(`threshold' - floor(`votes'/`D'))"

	bysort `touse' `by': gen `type' `h' =  ceil(`votes'/`D' - `Tau')  ///
	  if `touse'

	by `touse' `by': gen long `control' = sum(`h') if `touse'
	by `touse' `by': gen long `rest' = abs(`control'[_N]-`sizevar')
	by `touse' `by': gen byte `tomuch' = `control'[_N] > `sizevar' if `rest'!=0

	sum `rest', meanonly
	if r(max) != 0 {

		forv i = 1/`=r(max)' {
			gen double `downwardthreshold'`i' =  cond(`h'>`i'-1,`votes'/sqrt((`h'-`i')*`h'),.) if `touse'
			gen double `upwardthreshold'`i' =  `votes'/sqrt(`h'*(`h'+`i')) if `touse'
		}
		
		gen `index' = _n
		reshape long `upwardthreshold' `downwardthreshold', i(`index') j(`j')

		bysort `touse' `by' (`downwardthreshold'): gen byte `tag' = _n==`rest' if `tomuch' 
		bysort `touse' `by' (`upwardthreshold'): replace `tag' = _n==(_N-`rest'+1) if !`tomuch' 

		local D "cond(`tomuch',(`downwardthreshold'[_N]+`=epsfloat()'),(`upwardthreshold'[_N]-`=epsfloat()'))"
		
		bysort `touse' `by' (`tag'): replace `h' =  ceil(`votes'/`D'- `Tau')  ///
		  if `touse' &  `rest' 

		drop `tag'
		reshape wide 

		bysort `touse' `by': replace `control' = sum(`h') if `touse'
		by `touse' `by': assert `control'[_N]==`sizevar' if `touse'
	}
end


// Dean’s method
// -----------------

program APPORT_dean
	syntax varlist if, by(varlist) h(name)
	marksample touse
	args votes nvalid sizevar 

	tempvar control rest tomuch downwardthreshold upwardthreshold tag index j

	local D  "(`nvalid'/`sizevar')"
	local threshold  "2 * floor(`votes'/`D')  * (floor(`votes'/`D') +1) / (2 * floor(`votes'/`D') +1)"
	local Tau "(`threshold' - floor(`votes'/`D'))"
	
	bysort `touse' `by': gen `type' `h' =  ceil(`votes'/`D' - `Tau')  ///
	  if `touse'
	
	by `touse' `by': gen long `control' = sum(`h') if `touse'
	by `touse' `by': gen long `rest' = abs(`control'[_N]-`sizevar')
	by `touse' `by': gen byte `tomuch' = `control'[_N] > `sizevar' if `rest'!=0

	sum `rest', meanonly
	if r(max) != 0 {
		
		forv i = 1/`=r(max)' {
			gen double `upwardthreshold'`i'   =  `votes'/((2*`h'*(`h'+`i'))/(`h' + (`h'+`i'))) if `touse'
			gen double `downwardthreshold'`i' =  cond(`h'>`i'-1,`votes'/((2*(`h'-`i')*`h')/((`h'-`i') + `h')),.) if `touse'
		}
		
		gen `index' = _n
		reshape long `upwardthreshold' `downwardthreshold', i(`index') j(`j')

		bysort `touse' `by' (`downwardthreshold'): gen byte `tag' = _n==`rest' if `tomuch' 
		bysort `touse' `by' (`upwardthreshold'): replace `tag' = _n==(_N-`rest'+1) if !`tomuch' 

		local D "cond(`tomuch',(`downwardthreshold'[_N]+`=epsfloat()'),(`upwardthreshold'[_N]-`=epsfloat()'))"
		
		bysort `touse' `by' (`tag'): replace `h' =  ceil(`votes'/`D'- `Tau')  ///
		  if `touse' &  `rest' 

		drop `tag'
		reshape wide 
		
		bysort `touse' `by': replace `control' = sum(`h') if `touse'
		bysort `touse' `by': replace `control' = `control'[_N] if `touse'

		by `touse' `by': assert `control'[_N]==`sizevar' if `touse'
	}
end

// Adam
// ----

program APPORT_adam
	syntax varlist if, by(varlist) h(name)
	marksample touse
	args votes nvalid sizevar 

	tempvar control rest tomuch downwardthreshold index j tag

	local D  "(`nvalid'/`sizevar')"

	bysort `touse' `by': gen `type' `h' =  ceil(`votes'/`D')  ///
	  if `touse'

	by `touse' `by': gen long `control' = sum(`h') if `touse'
	by `touse' `by': gen long `rest' = abs(`control'[_N]-`sizevar') 

	sum `rest', meanonly
	if r(max) != 0 {

		forv i = 1/`=r(max)' {
			gen double `downwardthreshold'`i' =  `votes'/(`h'-`i') if `touse' & (`h'-`i') > 0
		}
			
		gen `index' = _n
		reshape long `downwardthreshold', i(`index') j(`j')

		bysort `touse' `by' (`downwardthreshold'):  ///
		  gen byte `tag' = _n==(`rest')

		local D "(`downwardthreshold'[_N]+`=epsfloat()')"

		bysort `touse' `by' (`tag'): replace `h' =  ceil(`votes'/`D')  ///
		  if `touse' &  `rest'

		drop `tag'
		reshape wide 

		bysort `touse' `by': replace `control' = sum(`h') if `touse'
		by `touse' `by': assert `control'[_N]==`sizevar' if `touse'
	}
end


exit


