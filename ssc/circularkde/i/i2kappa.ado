*! ISHU 1.0.0 09 July 2012
* Based on NJC 1.0.1 29 April 2004
* and NJC 1.0.0 1 August 2001 
* IO(kappa)
* and Fisher (1993) formulas
* verified with the values from Batschelet´s Table F                                       
program i2kappa, rclass 
	version 9.0
	args kappa garbage 
	
	if "`kappa'" == "" | "`garbage'" != "" { 
		di as error "use as i0kappa #"
		exit 198 
	} 
	quietly {
	i0kappa `kappa'  
    local i0kappa = r(i0kappa)
	*di as res `i0kappa'
    i1kappa `kappa'
	local i1kappa = r(i1kappa)
    }
    local i2kappa = `i0kappa'-(2/`kappa')*`i1kappa'
	di as res `i2kappa' 
    return scalar i2kappa = `i2kappa'
end	
	
