*! Part of package matrixtools v. 0.24
*! Support: Niels Henrik Bruun, nhbr@ph.au.dk
*2017-10-09 > If only one variable is chosen, row names are set to row equations. And row euations are removed
*2017-10-08 > Option COLby added
*2017-10-08 > Smoothed data for percentiles
*2017-10-08 > Option noLabel added
*2017-10-08 > Option Verbose added

* TODO proportion ci ?
* TODO meta data statistics - integer booleans?

program define sumat, rclass
	version 12.1
	syntax varlist [if] [in] [using], /*
		*/STATistics(string)/*
		*/[/*
			*/coleq(string)/*
			*/roweq(string)/*
			*/Ppct(integer 95)/*
			*/ROWby(varname)/*
			*/COLby(varname)/*
			*/Total /*
			*/Full /*
			*/noLabel /*
			*/Hide(integer 0)/*
			*/Verbose /*
			matprint options
			*/Style(passthru)/*
			*/Decimals(passthru)/*
			*/TItle(passthru)/*
			*/TOp(passthru)/*
			*/Undertop(passthru)/*
			*/Bottom(passthru)/*
			*/Replace(passthru)/*
		*/]

	if `hide' < 0 {
		display "{error:hide must have a non-negative integer argument. Is set to 0}"
		local `hide' 0
	}

	capture drop __if_in
	mark __if_in `if' `in'
	quietly summarize __if_in
	local __N `=r(sum)'
	
	mata: __add_quietly = !(__verbose=("`verbose'" != ""))
	mata: __lm = lmtable("`rowby'", "`colby'", "`total'" != "", "`varlist'", "`statistics'", ///
		`ppct', `__N', `hide', `hide', "`label'" != "", __verbose, __add_quietly)

	if "`roweq'" != "" mata: __lm.row_equations(`"`roweq'"')
	if "`coleq'" != "" mata: __lm.column_equations(`"`coleq'"')

	mata: st_rclear()
	mata: __lm.to_matrix("r(sumat)")
	
	*** matprint ***************************************************************
	matprint r(sumat) `using',	`style' `decimals' `title' `top' `undertop' `bottom' `replace'
	****************************************************************************
	capture drop __if_in
	return add
end

mata:
	real rowvector values(string scalar var, | real scalar total)
	{
		real rowvector vals
	
		vals = nhb_sae_unique_values(var, "", "", 1)
		if ( total != 0 | vals == J(1, 0, .) ) vals = vals, .t
		return(vals)
	}

	string matrix conditions(string scalar rvar, string scalar cvar, | real scalar total)
	{
		real scalar r, c, R, C
		real rowvector cvals, rvals
		string scalar rcond, ccond
		string matrix conds

		cvals = values(cvar, total)
		C = cols(cvals)
		rvals = values(rvar, total)
		R = cols(rvals)
		conds = J(R, C, "")
		for(r=1;r<=R;r++) {
			rcond = rvals[r] == .t ? "" : sprintf("& %s == %f", rvar, rvals[r])
			for(c=1;c<=C;c++) {
				ccond = cvals[c] == .t ? "" : sprintf("& %s == %f", cvar, cvals[c])
				conds[r,c] = sprintf("if __if_in %s %s", rcond, ccond)
			}
		}
		return(conds)
	}

	class nhb_mt_labelmatrix scalar lmtable(	string scalar rvar, 
												string scalar cvar, 
												real scalar total,
												string scalar varlist, 
												string scalar statistics, 
												real scalar ppct,
												real scalar N,
												real scalar smooth_width,
												real scalar hide,
												real scalar nolabel,
												real scalar showcode,
												real scalar addquietly						
												)
	{
		colvector eq, nm
		real scalar r, c, v, R, C, V, cval, rval
		real rowvector cvals, rvals
		string scalar rlbl, clbl, rvlbl, cvlbl
		string rowvector vlst
		string matrix conds
		class nhb_mt_labelmatrix scalar rlm, clm, lmcell

		rvals = values(rvar)
		cvals = values(cvar)
		conds = conditions(rvar, cvar, total)
		C = cols(conds)
		R = rows(conds)
		vlst = tokens(varlist)
		V = cols(vlst)
		
		if ( nolabel | ( rlbl = (rvar != "" ? st_varlabel(rvar) : "") ) == "" ) rlbl = rvar
		if ( nolabel | ( clbl = (cvar != "" ? st_varlabel(cvar) : "") ) == "" ) clbl = cvar
		for(c=1;c<=C;c++) {
			if ( (cval=cvals[c]) == .t ) cvlbl = "Total"
			else cvlbl = nolabel ? strofreal(cval) : nhb_sae_labelsof(cvar, cval)
			for(r=1;r<=R;r++) {
				if ( (rval=rvals[r]) == .t ) rvlbl = "Total"
				else rvlbl = nolabel ? strofreal(rval) : nhb_sae_labelsof(rvar, rval)
				for(v=1;v<=V;v++) {
					lmcell = nhb_sae_summary_row(	vlst[v], 
													statistics, 
													"", 
													conds[r,c], 
													"", 
													ppct, 
													N, 
													smooth_width, 
													hide, 
													nolabel, 
													showcode, 
													addquietly
													)
					if ( rvar != "" ) lmcell.row_equations(rval != .t ? sprintf("%s(%s)", rlbl, rvlbl) : "Total")
					if ( cvar != "" ) lmcell.column_equations(cval != .t ? sprintf("%s(%s)", clbl, cvlbl) : "Total")
					if ( r * v == 1 ) {
						clm = lmcell
					} else {
						clm.append(lmcell)
					}
				}
			}
			if ( c == 1 ) rlm = clm
			else {
				rlm.add_sideways(clm)
			}
		}
		
		if ( V == 1 & rlm.row_equations() != "" ) {
			rlm.row_names(rlm.row_equations())
			rlm.row_equations("")
		}
		return(rlm)
	}
end
