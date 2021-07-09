
program yxview_parea_draw
	.style.area.setgdifull

	gdi shadepattern = `.pattern'
	gdi shadechange

	local dropx = "`.bar_drop_to.stylename'" == "x"
	if `dropx' {
		local min = `.`.plotregion'.yscale.curmin'
		local max = `.`.plotregion'.yscale.curmax'
	}
	else {
		local min = `.`.plotregion'.xscale.curmin'
		local max = `.`.plotregion'.xscale.curmax'
	}
	if `.base' < . {
		local base `.base'
	}
	else {
		if `min' <= 0 & `max' >= 0 local base 0
		else                       local base = cond(`max' < 0 , `max' , `min')
	}
	.serset.set			// just in case
	draw_parea `dropx' `base'	// draw
end

program draw_parea
	args dropx base
	local n : serset N
	while `n' > 0 &							///
	     (`=serset(`.xvar', `n')' >= . | `=serset(`.yvar', `n')' >= .) {
		local --n
	}

	local beg 1
	while `beg' <= `n' &						///
	     (`=serset(`.xvar', `beg')' >= . | `=serset(`.yvar', `beg')' >= .) {
		local ++beg
	}

	if `beg' >= `n' {
		exit
	}

	if ! 0`.style.connect_missings' {
		draw_separate_pareas `dropx' `base' `beg' `n'
		exit
	}

	if `dropx' {

		gdi moveto `=serset(`.xvar', `beg')' `=serset(`.yvar', `beg')'
		gdi polybegin

		forvalues j = `beg'/`n' {
		     gdi lineto `=serset(`.xvar', `j')' `=serset(`.yvar', `j')'
		}

		if `.drop_base.istrue' {
			gdi lineto `=serset(`.xvar', `n')' `base'
			gdi lineto `=serset(`.xvar',  `beg')'  `base'
		}
		gdi lineto `=serset(`.xvar',  `beg')' `=serset(`.yvar',  `beg')'

		gdi polyend

	}
	else {

		gdi moveto `=serset(`.yvar', `beg')' `=serset(`.xvar', `beg')'
		gdi polybegin

		forvalues j = `beg'/`n' {
		     gdi lineto `=serset(`.yvar', `j')' `=serset(`.xvar', `j')'
		}

		if `.drop_base.istrue' {
			gdi lineto `base' `=serset(`.xvar', `n')'
			gdi lineto `base' `=serset(`.xvar',  `beg')'
		}
		gdi lineto `=serset(`.yvar', `beg')' `=serset(`.xvar',  `beg')'

		gdi polyend
	}
end

program draw_separate_pareas
	args dropx base beg n

	local j `beg'
	local rrr=0
	if `dropx' {
	    while `j' <= `n' {
	    	local beg0 `j'
		gdi moveto `=serset(`.xvar', `beg0')' `=serset(`.yvar', `beg0')'
		gdi polybegin

		while `j' <= `n' {
		    if (`=serset(`.xvar', `j')' >= . |		///
		    	`=serset(`.yvar', `j')' >= .) {
			local ++j
			continue, break
		    }
		    gdi lineto `=serset(`.xvar', `j')' `=serset(`.yvar', `j')'
		    local ++j
		}

		if `.drop_base.istrue' {
			gdi lineto `=serset(`.xvar', `n')' `base'
			gdi lineto `=serset(`.xvar',  `beg0')'  `base'
		}
		gdi lineto `=serset(`.xvar', `beg0')' `=serset(`.yvar', `beg0')'

		gdi polyend
	    }
	}
	else {
	    while `j' <= `n' {
	    	local beg0 `j'

		gdi moveto `=serset(`.yvar', `beg0')' `=serset(`.xvar', `beg0')'
		gdi polybegin

		while `j' <= `n' {
		    if (`=serset(`.xvar', `j')' >= . |		///
		    	`=serset(`.yvar', `j')' >= .) {
			local ++j
			continue, break
		    }
		    gdi lineto `=serset(`.yvar', `j')' `=serset(`.xvar', `j')'
		    local ++j
		}

		if `.drop_base.istrue' {
			gdi lineto `base' `=serset(`.xvar', `n')'
			gdi lineto `base' `=serset(`.xvar',  `beg0')'
		}
		gdi lineto `=serset(`.yvar', `beg0')' `=serset(`.xvar', `beg0')'

		gdi polyend
	    }
	}
end


