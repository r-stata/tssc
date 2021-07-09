program define buildmlib
	capture erase lstpm2.mlib
	mata: mata set matastrict off
	local stpm2dir: word 1 of `c(adopath)'	
	qui {
			do "`stpm2dir'/stpm2_matacode.mata"

			mata: mata mlib create lstpm2, dir(.) replace
			mata: mata mlib add    lstpm2 *(), dir(.)
			mata: mata d *()  
			mata mata clear
			mata mata mlib index
	}
end
