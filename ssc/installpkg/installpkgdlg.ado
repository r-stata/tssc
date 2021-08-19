cap prog drop installpkgdlg
prog define installpkgdlg
	
	syntax, [from(string)     ///
			 dirc(string)     ///
			 FORCE              ///
			 REPLACE            ///
				   ]


if (`"`from'"'!=""&`"`dirc'"'!=""){

	di _n "note: dirc() is ignored as from() is specified"

}
	

if (`"`from'"'==""){
	if(`"`dirc'"'==""){
		di as error "either from() or dirc() should be specified"
		error 198
	}
	else{

		local from `dirc'
	}
}


	// get the install file names of anything
	di _n(1) "{title:Executing the installpkg command}" _n
	di as txt "installpkg, from(`from') `replace' `force' "   _n 
	
	// call the installpkg function 
	installpkg, from(`from')  `replace' `force'        
	
end
