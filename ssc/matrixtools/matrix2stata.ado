*! Part of package matrixtools v. 0.24
*! Support: Niels Henrik Bruun, nhbr@ph.au.dk
program matrix2stata, rclass
	version 12.1
	syntax anything(name=matrixexp), [Clear Ziprows]
	
	* TODO: prefix
	tempname varnames matrixname
	capture matrix `matrixname' = `matrixexp'
	if ! _rc {
		`clear'
		mata: st_local("varnames", matrix2stata("`matrixname'", "`matrixexp'", "`ziprows'" != ""))
		tokenize `"`varnames'"'
		if "`ziprows'" == "" strtonum `1' `2'
		*else drop if `1' == " "
		return local variable_names = `"`varnames'"'
	}
	else return local variable_names = ""
end


mata:
	function matrix2stata(	string scalar matname, 
							string scalar matexp,
							real scalar ziprows)
	{
		string rowvector names1, names2, roweqnames, tmpnm
		real scalar rc, r, R, C, place
		real colvector position
		matrix values, tmpval
		
		if ( (values=st_matrix(matname)) != J(0,0,.) ) {
			names2 = nhb_mt_matrix_stripe(matname, 1, 0)
			roweqnames = nhb_mt_matrix_stripe(matname, 0, 0)
			if ( ziprows ) {
				names1 = strtoname(matexp + "_roweqnames")
				R = rows(values)
				C = cols(values)
				tmpnm = roweqnames
				roweqnames = tmpnm[1,1] \ tmpnm[1,2]
				tmpval = values
				values = J (1, C, .) \ tmpval[1,.]
				position = 1::2
				place = 2
				for(r=2;r<=R;r++) {
					if ( tmpnm[r-1,1] != tmpnm[r,1] ) {
						roweqnames = roweqnames \ tmpnm[r,1]
						position = position \ (place=place+2)
						values = values \ J (1, C, .)
					}
					roweqnames = roweqnames \ tmpnm[r,2]
					position = position \ ++place
					values = values \ tmpval[r,.]
				}
			position = (place+1) :- position // reverse order
			rc = nhb_sae_addvars(names1, position)
			st_vldrop(names1)
			st_vlmodify(names1, position, roweqnames)
			st_varvaluelabel(names1, names1)
			} else {
				names1 = strtoname((matexp :+ ("_eq", "_names")))
				// Add roweq and rownames as 2 variables
				rc = nhb_sae_addvars(names1, roweqnames)
			}
			if ( all(names2[1, .] :== "") ) {
				names2 = strtoname(matexp :+ "_" :+ names2[2, .])
			} else {
				names2 = strtoname(names2[1, .] :+ "_" :+ names2[2, .])
			}
			// Add content of matrix
			rc = nhb_sae_addvars(names2, values)
			return( invtokens((names1, names2)) )
		} else {
			return("")
		}
	}
end
