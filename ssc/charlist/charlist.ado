*! NJC 1.3.0 28 Feb 2014 
* NJC 1.2.1 28 Feb 2014 
* NJC 1.2.0 17 Jul 2008 
* NJC 1.1.0 17 Dec 2002 
program charlist, rclass
	version 9 
	syntax varname(string) [if] [in] 
	marksample touse, novarlist

	tempname sepchars chars ascii 

	scalar `sepchars' = ""
	scalar `chars' = ""
	scalar `ascii' = ""
	
	* not 0: see [P] file formats .dta 
	forval i = 1/255 { 
		capture assert index(`varlist', char(`i')) == 0 if `touse' 
		if _rc {
			scalar `sepchars' = `sepchars' + char(`i') + " " 
			scalar `chars' = `chars' + char(`i') 
			scalar `ascii' = `ascii' + "`i' "   
		}
	} 
	
	di as text `chars' 
	return local ascii = scalar(`ascii')
	return local sepchars = scalar(`sepchars')
	return local chars = scalar(`chars') 
end 
