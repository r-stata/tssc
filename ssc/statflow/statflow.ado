//! version 1.0 31DEC2018  DIME Analytics bbdaniels@gmail.com

// statflow - Stata module for dynamically updating flowcharts in Excel.

cap prog drop statflow
prog def statflow

syntax [anything] using [if] [in] , [replace]

// Setup

  preserve
  version 13.1

  tempfile theData
  	save `theData', replace

  cap mat drop theResults

// Create template if specified

  qui if "`anything'" == "template" {
    clear
    set obs 1
    gen logic = ""
    gen var = ""
    gen stat = ""
    gen value = ""
    export excel `using' , first(var) `replace'
  exit
  }

// Load the flowchart spreadsheet

  marksample touse
  keep if `touse'

	import excel `using', first clear allstring

	keep stat var logic value
  drop value
    gen value = .


	drop if logic == ""

// Do the calculatons...

	qui count

  // Error if no instructions
  if `r(N)' == 0 {
    di as err "There are no entries in that sheet."
  exit
  }

  // Otherwise calculate all the requested stats
	qui forvalues i = 1/`r(N)' {

    // Load each request
		local theLogic = logic[`i']
		local theVar = var[`i']
		local theStat = stat[`i']
			local theStat = "\`r(`theStat')'"

		tempfile a
			qui save `a', replace

    // Calculate the value from original data // TODO: not reload the dataset every time?
		use `theData', clear
		qui su `theVar' if `theLogic' , d
		local theValue = `theStat'

    // Replace the value in the stat sheet
		use `a', clear
		qui replace value = `theValue' in `i'
	}

// Print everything back to the same sheet

	mkmat value , mat(theResults)
	putexcel D2 = matrix(theResults) `using', modify

end

// Have a lovely day!
