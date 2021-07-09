// Rescale estimation matrices with variance scaling factor
// version 0.3 - Ulrich Kohler & Dirk Enzmann

version 11.1
mata:
	mata clear
	mata set matastrict on
	void meresc(
		real scalar vsf
		)
	{

		real matrix VSF
		real rowvector B
		real matrix V
		string matrix names
		string scalar eq1name
		real colvector fe_select
		real colvector re_select
		string matrix re_levels
		real matrix Var_ur
		real scalar i
		real colvector re_levelselect

		// Get info from Stata
		B = st_matrix("e(b)")
		V = st_matrix("e(V)")
		names = st_matrixcolstripe("e(b)")
		eq1name = st_local("eq1name")

		// Selectors for fixed and random effects
		fe_select = (names[.,1]:==eq1name)
		re_select = (names[.,1]:!=eq1name)

		// Rescale coefs
		VSF = J(1,cols(B),vsf)
		B = B :* ((1:-fe_select'):+VSF:*fe_select')
		B = B :+ log(VSF:^2):/2  :*  re_select'

		// Rescale Variance
		VSF = J(rows(V),cols(V),1)
		fe_select = VSF :* fe_select :* fe_select'
		VSF = VSF :- fe_select :+ vsf :* fe_select
		V = V :* VSF:^2

		// Add level specific Standard Deviations
		re_levels = uniqrows(substr(select(names[.,1],re_select),1,4))
		Var_ur = J(1,rows(re_levels),.)
		for (i=1;i<=rows(re_levels);i++) {
			re_levelselect = (
				(substr(names[.,1],1,4):==re_levels[i]) :*
				(substr(names[.,1],1,3):!="atr"))
			Var_ur[1,i] = sum(exp(
					select(B',re_levelselect):/st_numscalar(st_local("retyp"))
					):^2)
		}

		// Bring back my results to Stata
		st_matrix("_b",B)
		st_matrix("_V",V)
		st_matrix(st_local("Var_ur"),Var_ur)

		st_matrixcolstripe("_b", names)
		st_matrixrowstripe("_V", names)
		st_matrixcolstripe("_V", names)

	}
	mata mosave meresc(), replace
end
