program define expand_n
	// Program copies the dataset by a given factor and numbers the duplicated observations 
	// (1 for original, then 2 and so on)
	//
	// Syntax is: expand_n (expansion factor), generate(duplicates tag)
	//
	//
	//

	version 6
	syntax anything(name = n), Generate(name)

	confirm new var `generate'
	confirm integer number `n'

	if mod(`n', 1) != 0 | `n' <= 0 {
		di as error "Enter a positive integer"
		exit 198
	}

	qui tempname temp123
	gen `generate' = 1
	gen `temp123' = _n

	qui tempfile x
	qui save `x', replace

	local n = `n' - 1
	forval i = 1/`n' {
		qui replace `temp123' = `temp123' + _N
		qui replace `generate' = `generate' + 1

		qui merge 1:1 `temp123' using `x', assert(1 2) nogen
	}

	sort `temp123'
	drop `temp123'
	end
