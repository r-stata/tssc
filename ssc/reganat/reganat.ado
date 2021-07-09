* Version 1.0. June 10th, 2009
* Author: Valerio Filoso, filoso@unina.it

program define reganat
		version 10.1
		syntax varlist [if] [in] [aw fw pw iw/] [, Dis(varlist) Label(varname) BIScat BILine Reg NOLegend NOCovlist Scheme(string)]

		preserve
		tokenize `varlist'
		local dependent `1'
		mac shift
		local independent `*'
		set graphics off

		* --------------------------------------------------------------------------------------	
		* Variables to plot
		* --------------------------------------------------------------------------------------	
		if "`dis'" == "" {
			local tobep = "`independent'"
		}
		else {
			local tobep = "`dis'"
		}

		* --------------------------------------------------------------------------------------	
		* Header: General information to be displayed
		* --------------------------------------------------------------------------------------	
		display "Dependent variable: `dependent'"
		display "Independent variables: `independent'"
		display "Plotting: `tobep'"
		if "`label'" != "" {
			display "Label variable: `label'" 
		}

		* --------------------------------------------------------------------------------------	
		* Displaying the multivariate model, if requested
		* --------------------------------------------------------------------------------------	
		if `"`reg'"'!="" {
			regress `varlist' `if' `in' 
		}

		* --------------------------------------------------------------------------------------	
		* Size of marker in scatterplot
		* --------------------------------------------------------------------------------------	
		cap: count `if' `in'
		if r(N) > 500 {
			local size = "tiny"
		}
		else {
			local size = "small"
		}

		* --------------------------------------------------------------------------------------	
		* Extraction of variables' labels 
		* --------------------------------------------------------------------------------------	
		local lbldepvar : variable label `dependent'
		if "`lbldepvar'" == "" {
			local lbldepvar = "`dependent'"
		}

		* --------------------------------------------------------------------------------------	
		* A string with the list of controls
		* --------------------------------------------------------------------------------------	
		cap: local stringa = ""
		foreach x of local independent {
			local etichetta : variable label `x'
			if "`etichetta'" == "" {
				local etichetta = "`x'"
			}
			local stringa = "`stringa', `etichetta'"
			}  
		local stringa = substr("`stringa'",2,.)

		* --------------------------------------------------------------------------------------	
		* Markers for observations in the scatterplot, if selected
		* --------------------------------------------------------------------------------------	
		if "`label'" == "" {
			local etich = ""
		}
		else {
			local etich = "mlabel(`label') mlabsize(tiny) mlabposition(9) msize(`size')"
		}

		cap: macro drop totvar
		local totvar = 0 

		* --------------------------------------------------------------------------------------	
		* Preparing the graphs for each variable to be printed
		* --------------------------------------------------------------------------------------	
		foreach x of local tobep {

			local totvar = `totvar' + 1
			local lblx : variable label `x'

			if "`lblx'" == "" {
				local lblx = "`x'"
			}

			local covariates = subinword("`independent'","`x'","",1)

			cap: regress `x' `covariates' `if' `in'
			predict resid_`x' `if' `in', residuals
			label variable resid_`x' "`x'"

			* Dropping all the missing obs
			cap: keep if e(sample)

			* Subtracting the relevant mean
			cap: summarize `x'
			gen `x'_std = `x'-r(mean)

			* Generate regression parameters estimates
			cap: regress `dependent' `independent' `if' `in'
			local beta = string(_b[`x'],"%9.3f")
			local sebeta = string(_se[`x'],"%9.3f")

			cap: regress `dependent' `x' `if' `in'
			local betab = string(_b[`x'],"%9.3f")
			local sebetab = string(_se[`x'],"%9.3f")

			* Scatterplots

		* --------------------------------------------------------------------------------------	
		* Adding the bivariate scatterplot
		* --------------------------------------------------------------------------------------	
			if `"`biscat'"'!="" {
				local biscat "(scatter `dependent' `x'_std `if' `in', `etich' msymbol(triangle))"
				local legscat "Scatterplot: Dots = Transformed data, Triangles = Original data."
			}

		* --------------------------------------------------------------------------------------	
		* Adding the bivariate regression line
		* --------------------------------------------------------------------------------------	
			if `"`biline'"'!="" {
				local capt "caption(`"Bivariate slope: `betab' (`sebetab')"', bexpand justification(left) size(small))"
				local biline "(lfit `dependent' `x'_std `if' `in', lwidth(medium) lpattern(dash) caption(`"Bivariate slope: `betab' (`sebetab')"', size(small) justification(left)) note("Multivariate slope: `beta' (`sebeta')", justification(left) size(small)))"

				* --------------------------------------------------------------------------------------	
				* Adding or removing the legend
				* --------------------------------------------------------------------------------------	
				if `"`nolegend'"'=="" {
					local note "caption(`"Regression lines: Solid = Multivariate, Dashed = Bivariate."' "`legscat'", size(small) alignment(middle) position(6) justification(center) box bexpand bmargin(medlarge) span)"
				}
				else {
					local note ""
				}
			}


		* --------------------------------------------------------------------------------------	
		* Preparing the single graphs, with several options
		* --------------------------------------------------------------------------------------	
			scatter `dependent' resid_`x' `if' `in', xtitle("") ytitle("") `etich' xsca(titlegap(2)) ylabel(minmax) xlabel(minmax, nogextend) ymtick(##5) xmtick(##5) ///
			name(`x', replace) legend(off) title("`lblx'", span) || ///
			lfit `dependent' resid_`x' `if' `in', lpattern(solid) lwidth(medium)  xlabel(, labsize(vsmall)) ylabel(, labsize(vsmall)) ///
			note("Multivariate slope: `beta' (`sebeta')", bexpand justification(left) size(small)) || ///
			`biline' || ///
			`biscat'
			}

		* --------------------------------------------------------------------------------------	
		* Adding or removing the list of covariates
		* --------------------------------------------------------------------------------------	
			if `"`nocovlist'"'=="" {
				local covlist "note("Covariates: `stringa'.", bexpand size(medsmall) justification(center) alignment(middle))"
			}
			else {
				local covlist ""
			}

		* --------------------------------------------------------------------------------------	
		* Defining the composite graph's style
		* --------------------------------------------------------------------------------------	
			if `"`scheme'"'!="" {
				local schema "`scheme'"
			}
			else {
				local schema "sj"
			}

		* --------------------------------------------------------------------------------------	
		* Building up the composite graph
		* --------------------------------------------------------------------------------------	
		set graphics on
		graph combine `tobep', ///
		title("Regression Anatomy", span) subtitle("Dependent variable: `lbldepvar'", span) ///
		`covlist' ///
		`note' ///
		`nota' ///
		scheme(`schema') commonscheme

		restore
end
