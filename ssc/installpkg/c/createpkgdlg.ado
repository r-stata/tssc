/*
Credit declaration
This command is a minor modification version of makedlg.ado from

    E. F. Haghish
    University of Göttingen
    haghish@med.uni-goesttingen.de
    https://github.com/haghish

*/

cap prog drop createpkgdlg
prog createpkgdlg
	
	syntax [anything] [,      ///
			REPLACE           ///
			FORCE             ///
			title(str)        ///
			Version(str)      /// 
			Description(str)  ///
			AUThor(str)       ///
			url(str)          ///
	        install(str)      ///
			INPLUS           ///
				 ]

	
	// get the install file names of anything
  	local pwd `c(pwd)'
	local install : subinstr local install "\" "/", all
	tokenize `"`install'"', parse(" ")	
	mata: st_local("pathdir",regexr("`1'","/[^/]+$",""))
	qui cd "`pathdir'"
	while !missing("`1'") {
		mata: st_local("fname",pathbasename("`1'"))
		if missing("`inst'") local inst = "`fname'"
		else local inst = "`inst';`fname'"	
		macro shift
	} 

	
	di _n(2) "{title:Executing the make2 command}" _n
	di as txt "make2 `anything', replace toc pkg  version(`version')" _col(77) " ///" _n ///
	   `"     author("`author'")"' _col(77) " ///" _n ///
	   `"     url("`url'")"' _col(77) " ///" _n ///
	   `"     title("`title'")"' _col(77) " ///" _n ///
	   `"     description("`description'")"' _col(77) " ///" _n ///
       `"     install("`inst'")"' _col(77)  _n 	   
	
	// call the make2 function 
	make2 `anything',                    ///
	      toc                          ///
		  pkg                          ///
		 `readme'                       ///
		 replace                        ///
		 title(`title')                 ///
	     version(`version')             ///
		 license("`license'")           ///
	     description(`description')     ///
		 author(`author')               ///
		 affiliation(`affiliation')     ///
		 email(`email')                 ///
		 url(`url')                     ///
	     install("`inst'")              ///
		 ancillary("`anc'")
	
   qui cd "`pwd'"

	if("`inplus'"!="" | "`replace'"!="" | "`force'"!=""){
		di _n(2) "{title:Executing the net install command}" _n
		di as txt `"net install `anything',  from(`pathdir') `replace' `force'"' _n 	
		
		net install `anything' , from(`pathdir') `replace' `force'
	}
		
		
		
	
end


