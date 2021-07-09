*! slideviewer.ado - program to enable subdirectory navigation for SMCL slides in Stata
*! EBooth <ebooth@tamu.edu>
*! Version 1.1 : Last Updated: Feb 2012
** Version 1.0 : Jan 2012

program def slideviewer, rclass
syntax anything, [Subdir(str asis) Post]

qui {
	
	*--error checking
	loc anything:subinstr local anything ".smcl" "", all
	if `"`subdir'"' == "" loc subdir `"`c(pwd)'//ignore//"'
	if `"`subdir'"' != "" {
	
		cap confirm file `"`subdir'//`anything'.smcl"'
		 if _rc {
		 	di as error `"File `subdir' does not exist -- be sure to specify the entire path to the subfolder!"'
			exit 198
			}
			}
	
	**--change slides
	qui win manage close viewer
	qui view `"`subdir'//`anything'.smcl"'
	
	**--post results to rclass
	return local lastslide   `"`anything'"'
	return local totalscore  `"${totalscore}"'
	
}
end

