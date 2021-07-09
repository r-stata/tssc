*!Program to convert help files into pdf in Windows environment. Requires Ghostscript and Ghostview.
*! By P. Wilner Jeanty
*! Date: December 12, 2009
*! Update: February 6, 2010
prog define hlp2winpdf
	version 9.2
	syntax, CDName(string) [replace]
	foreach hpf of local cdname {
		capture findfile `hpf'.sthlp
		if !_rc qui return list
		else {
			capture findfile `hpf'.hlp
			if !_rc qui return list
			else {
				di as err "The command {bf:`hpf'} or its help file does not exist"
				exit 601
			}
		}
	}	
	foreach hpf of local cdname {		
		qui translate "`r(fn)'" `hpf'.ps, translator(smcl2ps) replace
		cap confirm new file `hpf'.pdf
		if _rc & "`replace'" !=""  erase `hpf'.pdf 
		else if !_rc & "`replace'"!="" di as txt "(Note: File `hpf'.pdf not found)"
		else if _rc & "`replace'"=="" confirm new file `hpf'.pdf	
		qui !epstopdf `hpf'.ps
	}
	foreach hpf of local cdname {
		erase `hpf'.ps
	}
	di as txt _n "All .pdf files are saved to the current working directory `c(pwd)'"				 		
end


