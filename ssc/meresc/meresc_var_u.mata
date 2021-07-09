// Extract random effects variance for McKelvy & Zavoina's R²
// version 0.1 Dirk Enzmann & Ulrich Kohler

version 11.1
mata:
	mata clear
	mata set matastrict on
	void meresc_var_u()
	{
		real rowvector B
		string matrix names
		string scalar eq1name
		real colvector re_select
		string matrix re_levels
		real matrix Var_u
		real scalar Var_utot
		real scalar i
		real colvector re_levelselect

		// Get info from Stata
		B = st_matrix("e(b)")
		names = st_matrixcolstripe("e(b)")
		eq1name = st_local("eq1name")

		// Selectors for random effects
		re_select = (names[.,1]:!=eq1name)

		// Level specific Standard Deviations
		re_levels = uniqrows(substr(select(names[.,1],re_select),1,4))
		Var_u = J(1,rows(re_levels),.)
		for (i=1;i<=rows(re_levels);i++) {
			re_levelselect = (
				(substr(names[.,1],1,4):==re_levels[i]) :*
				(substr(names[.,1],1,3):!="atr"))
			Var_u[1,i] = sum(exp(
					select(B',re_levelselect):/st_numscalar(st_local("retyp"))
					):^2)
		}
		Var_utot = sum(Var_u)

		// Bring back my results to Stata
		st_matrix(st_local("Var_u"),Var_u)
		st_numscalar(st_local("Var_ut"),Var_utot)
	}
	mata mosave meresc_var_u(), replace
end
