*! version 0.1 30/12/2017

// enable touse??
program define msboxes
	version 14.2
	syntax /*[if][in]*/, Xvalues(numlist) 			///
						Yvalues(numlist) 			///
						ID(varname) 				///
						[TRANSMATrix(name) 			///
						STATENames(string asis) 	///
						BOXHeight(real 0.3) 		///
						BOXWidth(real 0.2) 			///
						YRANge(string) 				///
						XRANge(string) 				///
						YSIZE(string) 				///
						XSIZE(string) 				///
						GRid 						///
						INTERactive					///	
						JSONPath(string) 			///
						CR							///
						]
	//marksample touse
	
	tempvar endstate
	
	// check tranmatrix exists
	if "`cr'" != "" {
		if "`transmatrix'" != "" {
			di "do not specify both the transmatrix and cr option"
			exit 198
		}
		summ _to, meanonly
		local tmpNstates `r(max)'
		tempname transmatrix
		matrix `transmatrix' = J(`tmpNstates',`tmpNstates',.)
		forvalues i = 2/`tmpNstates' {
			local tmptrans = `i' - 1
			matrix `transmatrix'[1,`i'] = `tmptrans'
		}
	}	
	else {
		cap confirm matrix `transmatrix'
		if _rc>0 {
			di as error "transmatrix(`transmatrix') not found"
			exit 198
		}
	}
	
	local Nstates = rowsof(`transmatrix')
	
	// Checks for interactive options
	if "`jsonpath'" != "" & "`interactive'" == "" {
		di as error "You have used the jsonpath option without using the interactive option."
		exit 198
	}
	if "`interactive'" != "" {
		if "`jsonpath'" != "" {
			mata st_local("direxists",strofreal(direxists("`jsonpath'")))
			if !`direxists' {
				di as error "Folder `jsonpath' does not exist."
				exit 198
			}
			mata st_local("jsonfile",pathjoin("`jsonpath'","msboxes.json"))
		}
		else {
			local jsonfile msboxes.json
		}
		capture confirm file "`jsonfile'"
		if !_rc {
			capture erase "`jsonfile'"
			if _rc {
				display as error "`jsonfile' cannot be deleted'"
			}
		}
	}
	
	
	if "`yrange'" == "" {
		local ymin 0
		local ymax 1
	}
	else {
		numlist "`yrange'", ascending min(2) max(2)
		local ymin = word("`r(numlist)'",1)
		local ymax = word("`r(numlist)'",2)	
	}
	if "`xrange'" == "" {
		local xmin 0
		local xmax 1
	}
	else {
		numlist "`xrange'", ascending min(2) max(2)
		local xmin = word("`r(numlist)'",1)
		local x	max = word("`r(numlist)'",2)	
	}	
	if "`ysize'" != "" local ysize ysize(`ysize')
	if "`xsize'" != "" local xsize xsize(`xsize')
	

	// Check data seems to be stset correctly
	confirm var _trans 
	confirm var _status
	confirm var _start
	confirm var _stop
	
	// Xvalues and Yvalues
	if (wordcount("`xvalues'") != `Nstates') | (wordcount("`yvalues'") != `Nstates') {
		di as error "xvalues and yvalues must be of length `Nstates' (the number of states)"
		exit 198
	}
	local wc : word count `statenames'
	if `"`statenames'"' != "" & `wc' != `Nstates' {
		di as error "Length of statenames option should be equal to `Nstates'" ///
					"(The number of states)"
		exit 198
	}

// ============================================================================	
//	set up 
// ============================================================================	

	qui summ _trans
	local Ntransitions `r(max)'

	forvalues i = 1/`Nstates' {
		local Absorbing`i' 1
		forvalues j = 1/`Nstates' {
			if el(`transmatrix',`i',`j') != . {
				local Absorbing`i' 0
				continue, break
			}
		}
	}
	
// end state (assumes some ordering)
	tempvar maxeventtime totalmiss
	qui bysort `id' (_trans): egen `maxeventtime' = max(_stop*_status )
	qui bysort `id' (_trans): gen `endstate' = _to if _stop == `maxeventtime' & _status==1 
	qui bysort `id' (_trans): egen `totalmiss' = total(`endstate'==.)
	qui bysort `id' (_trans): replace `endstate' = _from if `totalmiss' == _N & _n==1

// Default State Names
	if `"`statenames'"' == "" {
		forvalues i = 1/`Nstates' {
			local statenames `statenames' State_`i'
		}
	}
	
// Start and end state for each transition
   forvalues i=1/`Nstates' {
		forvalues j=1/`Nstates' {
			if el(`transmatrix',`i',`j') != . {
				local tmptrans = el(`transmatrix',`i',`j')
				local trans`tmptrans'_start `i'
				local trans`tmptrans'_stop `j'
			}
		}
	}
	

// ============================================================================
// Do calculations
// ============================================================================	

// Number at risk at start
	tempvar fromfirst
	bysort `id' _from: gen `fromfirst' = _n==1
	forvalues i = 1/`Nstates' {
		qui count if _from == `i' & `fromfirst' & !`Absorbing`i''
		local Nstart`i' `r(N)'
		qui count if `endstate' == `i' 
		local Nend`i' `r(N)'
	}
// Number of subjects transitioning
	forvalues i = 1/`Ntransitions' {
		qui count if _trans==`i' & _status == 1 
		local Nevents`i' `r(N)'
	}
	
// ============================================================================
// Draw Graph
// ============================================================================	

// state names
	forvalues i = 1/`Nstates' {
		local x = word("`xvalues'",`i')
		local y = real(word("`yvalues'",`i')) + `boxheight'/3 
		local text: word `i' of `statenames'
		local statetext `statetext' text(`y' `x' "`text'", placement(c))
	}
	
// boxes
	forvalues i = 1/`Nstates' {
		local x1 = real(word("`xvalues'",`i')) - `boxwidth'/2
		local x2 = real(word("`xvalues'",`i')) + `boxwidth'/2
		local y1 = real(word("`yvalues'",`i')) - `boxheight'/2		
		local y2 = real(word("`yvalues'",`i')) + `boxheight'/2		
		local boxes `boxes' (pci `y1' `x1' `y1' `x2' `y1' `x1' `y2' `x1' `y2' `x1' `y2' `x2' `y2' `x2' `y1' `x2', lcolor(black))
	}
	
// Number at Start
	forvalues i = 1/`Nstates' {
		local x = real(word("`xvalues'",`i')) - `boxwidth'/2 + 0.01
		local y = real(word("`yvalues'",`i')) - `boxheight'/3 
		local text = "`Nstart`i''"
		local Nstarttext `Nstarttext' text(`y' `x' "`text'", placement(e))
	}
// Number at End
	forvalues i = 1/`Nstates' {
		local x = real(word("`xvalues'",`i')) + `boxwidth'/2 -0.01
		local y = real(word("`yvalues'",`i')) - `boxheight'/3 
		local text = "`Nend`i''"
		local Nendtext `Nendtext' text(`y' `x' "`text'", placement(w))
	}	
	
	
// arrows & arrow text
	forvalues i = 1/`Ntransitions' {
		// horizontal
		if 	word("`yvalues'",`trans`i'_start') == word("`yvalues'",`trans`i'_stop') {
			local lefttoright = real(word("`xvalues'",`trans`i'_start')) < real(word("`xvalues'",`trans`i'_stop'))
			local y1 = real(word("`yvalues'",`trans`i'_start'))
			local x1 = real(word("`xvalues'",`trans`i'_start')) + (cond(`lefttoright',1,-1)*`boxwidth'/2)
			local y2 = real(word("`yvalues'",`trans`i'_stop')) 
			local x2 = real(word("`xvalues'",`trans`i'_stop')) + (cond(`lefttoright',-1,1)*`boxwidth'/2)
			
			local ytext = real(word("`yvalues'",`trans`i'_start')) + 0.01
			local xtext = (real(word("`xvalues'",`trans`i'_start')) + real(word("`xvalues'",`trans`i'_stop')))/2
	
			local arrowtext `arrowtext' text(`ytext' `xtext' "`Nevents`i''", placement(n))
			
		} 
		else if word("`xvalues'",`trans`i'_start') == word("`xvalues'",`trans`i'_stop') {
			local toptobottom = real(word("`yvalues'",`trans`i'_start')) > real(word("`yvalues'",`trans`i'_stop'))
			local y1 = real(word("`yvalues'",`trans`i'_start')) + (cond(`toptobottom',-1,1)*`boxheight'/2)
			local x1 = real(word("`xvalues'",`trans`i'_start'))
			local y2 = real(word("`yvalues'",`trans`i'_stop')) + (cond(`toptobottom',1,-1)*`boxheight'/2)
			local x2 = real(word("`xvalues'",`trans`i'_stop')) 
			
			local ytext = (real(word("`yvalues'",`trans`i'_start')) + real(word("`yvalues'",`trans`i'_stop')))/2
			local xtext = (real(word("`xvalues'",`trans`i'_start')) -0.01)
	
			local arrowtext `arrowtext' text(`ytext' `xtext' "`Nevents`i''", placement(w))
			
		}
		else {
			local cutoff 0.5
			local gradient =  abs(real(word("`yvalues'",`trans`i'_start')) - real(word("`yvalues'",`trans`i'_stop'))) ///
							/ abs(real(word("`xvalues'",`trans`i'_start')) - real(word("`xvalues'",`trans`i'_stop')))
			
			local textleft = (real(word("`xvalues'",`trans`i'_start')) > real(word("`xvalues'",`trans`i'_stop')))				
			if 	`gradient' < `cutoff' {
				local lefttoright = real(word("`xvalues'",`trans`i'_start')) < real(word("`xvalues'",`trans`i'_stop'))
				local y1 = real(word("`yvalues'",`trans`i'_start'))
				local x1 = real(word("`xvalues'",`trans`i'_start')) + (cond(`lefttoright',1,-1)*`boxwidth'/2)
				local y2 = real(word("`yvalues'",`trans`i'_stop')) 
				local x2 = real(word("`xvalues'",`trans`i'_stop')) + (cond(`lefttoright',-1,1)*`boxwidth'/2)
				
				local ytext = (real(word("`yvalues'",`trans`i'_start')) + real(word("`yvalues'",`trans`i'_stop')))/2
				local xtext = (real(word("`xvalues'",`trans`i'_start')) + real(word("`xvalues'",`trans`i'_stop')))/2 + cond(`textleft',-1,1)*0.02
	
				local arrowtext `arrowtext' text(`ytext' `xtext' "`Nevents`i''", placement(`=cond(`textleft',"w","e")'))
			}
			else {
				local toptobottom = real(word("`yvalues'",`trans`i'_start')) > real(word("`yvalues'",`trans`i'_stop'))
				local y1 = real(word("`yvalues'",`trans`i'_start')) + (cond(`toptobottom',-1,1)*`boxheight'/2)
				local x1 = real(word("`xvalues'",`trans`i'_start'))
				local y2 = real(word("`yvalues'",`trans`i'_stop')) + (cond(`toptobottom',1,-1)*`boxheight'/2)
				local x2 = real(word("`xvalues'",`trans`i'_stop')) 

				local ytext = (real(word("`yvalues'",`trans`i'_start')) + real(word("`yvalues'",`trans`i'_stop')))/2
				local xtext = (real(word("`xvalues'",`trans`i'_start')) + real(word("`xvalues'",`trans`i'_stop')))/2 + (cond(`textleft',-1,1)*0.02)
	
				local arrowtext `arrowtext' text(`ytext' `xtext' "`Nevents`i''", placement(`=cond(`textleft',"w","e")'))
				
			}
		}
		local arrowstextx `arrowstextx' `xtext'
		local arrowstexty `arrowstexty' `ytext'
		
		local arrows `arrows' (pcarrowi `y1' `x1' `y2' `x2', color(red) barbsize(1) msize(2))
		local arrowsx1 `arrowsx1' `x1' 
		local arrowsy1 `arrowsy1' `y1' 
		local arrowsx2 `arrowsx2' `x2' 
		local arrowsy2 `arrowsy2' `y2' 
	}
// arrow text


// Grid option
if "`grid'" == "" {
	local xlab xlab(minmax,nolabels noticks nogrid) 
	local ylab ylab(minmax,nolabels noticks nogrid) 
}
else {
	local xlab xlab(,grid  glcolor(gs7)) 
	local ylab ylab(,grid  glcolor(gs7))
}

// save to JSON file
if `"`interactive'"' != "" {
	mata: WriteJson()
}



// Now plot everything
	twoway (scatteri `ymin' `xmin' `ymax' `xmax', msymbol(none)) ///
			`boxes' ///
			`arrows', ///
			xscale(off range(`xmin' `xmax')) ///
			yscale(off range(`ymin' `ymax')) ///
			`statetext' ///
			`Nstarttext' ///
			`Nendtext' ///
			`arrowtext' ///
			`ylab' ///
			`xlab' ///
			graphregion(color(white) margin(0 0 0 0)) bgcolor(white) ///
			plotregion(margin(0 0 0 0)) ///
			`ysize' `xsize' ///
			legend(off)
end

program closeallfiles
	forvalues i=0(1)50 {
		capture mata: fclose(`i')
	}
end


	
mata
function WriteJson() {
	filename = st_local("jsonfile")
	Nstates = st_local("Nstates")
	Ntransitions = st_local("Ntransitions")	
	boxwidth = strtoreal(st_local("boxwidth"))
	boxheight = strtoreal(st_local("boxheight"))
	xvalues = invtokens(strofreal(strtoreal(tokens(st_local("xvalues"))) :- 0.5:*boxwidth),",")
	yvalues = invtokens(strofreal(strtoreal(tokens(st_local("yvalues"))) :+ 0.5:*boxheight),",")
	ymin = st_local("ymin")
	ymax = st_local("ymax")
	xmin = st_local("xmin")
	xmax = st_local("xmax")
	statenames = tokens(st_local("statenames"))
	statenames = invtokens(`"""' :+ statenames :+ `"""',",")
	
	arrowsx1 = "["+invtokens(tokens(st_local("arrowsx1")),",")+"]"
	arrowsy1 = "["+invtokens(tokens(st_local("arrowsy1")),",")+"]"
	arrowsx2 = "["+invtokens(tokens(st_local("arrowsx2")),",")+"]"
	arrowsy2 = "["+invtokens(tokens(st_local("arrowsy2")),",")+"]"
	
	arrows = `"{"x1":"' + arrowsx1 + `","y1":"'+arrowsy1+`","x2":"'+arrowsx2 +`","y2":"'+arrowsy2+"}"
	arrowstextx = "["+invtokens(tokens(st_local("arrowstextx")),",")+"]"
	arrowstexty = "["+invtokens(tokens(st_local("arrowstexty")),",")+"]"
	arrowstext = `"{"x":"' + arrowstextx + `","y":"'+arrowstexty+"}"
// open file
	fh = fopen(filename, "w")
	fput(fh,"msboxes = {")
	fput(fh,`""Nstates":"' + Nstates + ",")
	fput(fh,`""Ntransitions":"' + Ntransitions + ",")
	fput(fh, `""xvalues": ["' + xvalues + "],")
	fput(fh, `""yvalues": ["' + yvalues + "],")
	fput(fh,`""ymin":"' + ymin + ",")
	fput(fh,`""ymax":"' + ymax + ",")
	fput(fh,`""xmin":"' + xmin + ",")
	fput(fh,`""xmax":"' + xmax + ",")
	fput(fh,`""boxwidth":"' + strofreal(boxwidth) + ",")
	fput(fh,`""boxheight":"' + strofreal(boxheight) + ",")
	fput(fh,`""statenames": ["' + statenames + `"],"')
	fput(fh,`""arrows": "' + arrows + ",")
	fput(fh,`""arrowstext": "' + arrowstext)
	fput(fh,"}")
	fclose(fh)
}
end
	
