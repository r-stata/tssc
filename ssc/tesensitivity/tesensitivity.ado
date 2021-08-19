*! tesensitivity v1.0.0 Linqi Zhang, Paul Diegert, Matt Masten, Alex Poirier 1jan2021

// PROGRAM: tesensitivity
// DESCRIPTION: Main function for tensensitivity package. Primarily a 
//              wrapper for the _tesen ado files. Processes the subcommand
//              and passes the rest of the input to the _tesen program.

program define tesensitivity, eclass byable(recall)
    version 13
	
	if replay() {
		local 0 cpi
	}
	
	// parse the subcommand
	gettoken subcommand 0 : 0
	
	// correct parsing of comma if no space after subcommand
	if regexm("`subcommand'", ",$"){
		local subcommand = substr("`subcommand'", 1, strlen("`subcommand'") - 1)
		local 0 ,`0'
	}
	
	if "`subcommand'" == "cscale" {
	
		_tesen_cscale `0'
		if "`r(cmax)'" != "" | "`r(cquantile)'" != "" { 
			_tesen_display, cscale
		}
	
	}
	else if "`subcommand'" == "cpi" {
		
		if replay() {
			_tesen_display
			exit
		}
		_tesen_cpi `0'

		// display results
		_tesen_display
		
	}
	else if "`subcommand'" == "cpiplot" {
				
		_tesen_plot `0'
		
	}
	
	else if "`subcommand'" == "cpitable" {
		
		_tesen_display `0'
		_tesen_display `0', breakdown
	
	}

end

  



