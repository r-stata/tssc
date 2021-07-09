// Calculate correlation metric from coefficient vectors
// version 0.3 Implements new standard error
// version 0.4 Remove bug in concomitant function
// version 0.5 Set SE to missing for option SE
// version 0.6 WIP

version 11

mata:
	mata clear
	mata set matastrict on
	
	
	// The KHB-Method
	// -------------
	
	void khb(
		string rowvector SURxnames,
		string rowvector FULLznames,
		string rowvector FULLxnames,
		string scalar Method
		)
	{
		
		// Declaration
		real rowvector SURb
		real matrix SURcov
		string matrix SURnames
		real colvector SURxselector
		real rowvector FULLb
		real matrix FULLcov
		string matrix FULLnames
		real rowvector REDUCEDb
		real matrix REDUCEDcov
		string matrix REDUCEDnames
		real colvector xselector
		real colvector zselector
		real matrix deriv
		real matrix sigma
		real colvector breduced
		real colvector bfull
		real colvector bdiff
		real colvector bdisentangle
		real colvector bnaive
		real matrix Vreduced
		real matrix Vfull
		real matrix Vdiff
		real matrix V
		real rowvector b
		string matrix eqnames
		string matrix rowcolnames
		real scalar i

		// Get info from Stata
		SURb = st_matrix("_SURb")
		SURcov = st_matrix("_SURcov")
		SURnames = st_matrixcolstripe("_SURb")
		FULLb = st_matrix("_FULLb")
		FULLcov = st_matrix("_FULLcov")
		FULLnames = st_matrixcolstripe("_FULLb")
		REDUCEDb = st_matrix("_REDUCEDb")
		REDUCEDcov = st_matrix("_REDUCEDcov")
		REDUCEDnames = st_matrixcolstripe("_REDUCEDb")

		// De-select constants, ommited variables and base categories
		SURxselector = khb_touse(SURnames)

		// Selector for Zvars from full model
		zselector = khb_touse(FULLnames) :* khb_tag(FULLnames,FULLznames)

		// Selector for Xvars of both, full and reduced model
		xselector = khb_touse(FULLnames) :* khb_tag(FULLnames,FULLxnames)

		// Vector of _used_ cofficients
		bfull = select(FULLb,xselector')
		breduced = select(REDUCEDb,xselector')
		bdiff = breduced :- bfull

		// Covariance Matrix  full model and reduced models
		Vfull = khb_select(FULLcov,xselector)
		Vreduced = khb_select(REDUCEDcov,xselector)

		// Covariance Matrix of Difference
		deriv = khb_deriv(FULLb,SURb,SURxselector,SURnames,SURxnames,zselector)
		sigma = khb_sigma(FULLcov,SURcov,SURxselector,SURnames,SURxnames,zselector,FULLznames)

		Vdiff = deriv * sigma * deriv'

		Vdiff = Vdiff[|1,1 \ cols(FULLxnames),cols(FULLxnames)|]
		if (Method == "APE") Vdiff = Vdiff * 0  // Sets SE to missing
		
		// Make Coefficient Vector and Variance/Covarince Matrix
		b = vec(breduced \ bfull \ bdiff)
		V = diag(vec((diagonal(Vreduced)' \ diagonal(Vfull)' \ diagonal(Vdiff)')))
		
		// Row and Column names
		eqnames = vec((
				select(FULLnames[.,2],xselector),
				select(FULLnames[.,2],xselector),
				select(FULLnames[.,2],xselector))')
		
		rowcolnames = "Reduced", "Full", "Diff"
		for (i=2;i<=rows(eqnames)/3;i++) {
			rowcolnames = rowcolnames, "Reduced", "Full", "Diff"
		}
		rowcolnames = eqnames, rowcolnames'
		
		// Return to Stata
		st_matrix("_b",b')
		st_matrix("_V",V)
		st_matrix("_Vdiff",Vdiff)
		
		st_matrixcolstripe("_b", rowcolnames)
		st_matrixrowstripe("_V", rowcolnames)
		st_matrixcolstripe("_V", rowcolnames)
		
	}
	
	// The summary table
	// -----------------

	void khb_summary(
		string matrix NAIVExnames
		)
	{
		real matrix summary
		real matrix NAIVEb
		string matrix NAIVEnames
		real matrix nselector
		real matrix b
		string matrix bnames
		real matrix bnaive
		real matrix breduced
		real matrix bfull
		
		NAIVEb = st_matrix("_NAIVEb")
		NAIVEnames = st_matrixcolstripe("_NAIVEb")
		
		b = st_matrix("_b")'
		bnames = st_matrixcolstripe("_b")
		nselector = khb_touse(NAIVEnames) :* khb_tag(NAIVEnames,NAIVExnames)
		
		bnaive = select(NAIVEb,nselector')
		breduced = select(b, (J(rows(b),1, "Reduced") :== bnames[.,2]))
		bfull = select(b, (J(rows(b),1, "Full") :== bnames[.,2]))

		summary = breduced:/bfull
		summary = summary, J(rows(breduced),cols(breduced),100) :* (breduced :- bfull):/breduced
		summary = summary, breduced:/bnaive'
		
		st_matrix("_SUMMARY", summary)
		st_matrixrowstripe("_SUMMARY", (J(rows(summary),1,""),NAIVExnames'))
		
	}


	// Disentangle table
	// ----------------

	void khb_disentangle(
		string rowvector FULLznames,
		string rowvector FULLxnames)
	
	{
		// Declarations
		real matrix SURb
		real matrix SURcov
		string matrix SURnames
		real matrix SURxselector
		real matrix FULLb
		real matrix FULLcov
		string matrix FULLnames
		real matrix FULLzselector
		real matrix DIFFb
		string matrix DIFFnames
		real matrix bdisentangle
		real matrix SEdisentangle
		real scalar i
		string matrix eqnames
		string colvector znames 
		real matrix p1
		real matrix p2
		string matrix rownames
		string matrix colnames
		
		// Get info from Stata
		SURb = st_matrix("_SURb")
		SURcov = st_matrix("_SURcov")
		SURnames = st_matrixcolstripe("_SURb")
		FULLb = st_matrix("_FULLb")
		FULLcov = st_matrix("_FULLcov")
		FULLnames = st_matrixcolstripe("_FULLb")
		DIFFb = st_matrix("_b")
		DIFFnames = st_matrixcolstripe("_b")
		
		// Selector for Xvar from SUR model
		SURxselector = khb_touse(SURnames) :* khb_tag(SURnames,FULLxnames)
		
		// Selector for Zvars from full model
		FULLzselector = khb_touse(FULLnames) :* khb_tag(FULLnames,FULLznames)
	
		// Matrizes of _used_ cofficients
		FULLb = diag(select(FULLb,FULLzselector'))
		SURb = rowshape(select(SURb,SURxselector'),rows(FULLb))
		
		// Differences
		bdisentangle = FULLb * SURb
		
		// Standard errors
		FULLcov = diagonal(khb_select(FULLcov,FULLzselector))'
		SURcov = diagonal(khb_select(SURcov,SURxselector))'
		SEdisentangle = sqrt(
			(rowshape(SURcov,cols(FULLb))' * diag(FULLb:^2))' + 
			diag(FULLcov) * SURb:^2)
		
		// Percentage of difference
		p1 = select(DIFFb,(J(cols(DIFFb),1,"Diff") :== DIFFnames[.,2])')
		p1 = bdisentangle * diag(1:/p1)
		
		// Percentage of Reduced model effect
		p2 = select(DIFFb,(J(cols(DIFFb),1,"Reduced") :== DIFFnames[.,2])')
		p2 = bdisentangle * diag(1:/p2)
		
		// Prepare matrixes for returning to Stata
		bdisentangle = vec(bdisentangle)
		SEdisentangle = vec(SEdisentangle)
		p1= vec(p1)
		p2= vec(p2)
		
		// Set row and column names
		eqnames = FULLxnames
		znames = FULLznames'
		for (i=2;i<=cols(FULLznames);i++) {
			eqnames = eqnames \ FULLxnames
		}
		for (i=2;i<=cols(FULLxnames);i++) {
			znames = znames \ FULLznames'
		}
		rownames = vec(eqnames), znames
		colnames = J(4,1,""), ("Coef" \ "Std_Err"\ "P_Diff"\ "P_Reduced")
		
		// Return to Stata
		st_matrix("_DISENTANGLE",(bdisentangle,SEdisentangle,100:*p1,100:*p2))
		st_matrixrowstripe("_DISENTANGLE", rownames)
		st_matrixcolstripe("_DISENTANGLE", colnames)
	}
	
	// Derivative Matrix with dimension Z + (Z*X) times X
	// ---------------------------------------------------
	
	real matrix khb_deriv(
		real rowvector FULLb,
		real rowvector SURb,
		real colvector SURxselector,
		string matrix SURnames,
		string rowvector SURxnames,
		real colvector zselector)
	{
		
		real matrix deriv
		real matrix newline
		real matrix i
		real matrix j

		deriv = select(SURb,
			(SURxselector :*
				J(rows(SURnames),1,SURxnames[1,1]) :==
				SURnames[.,2])')

		for (i=1; i<=cols(SURxnames);i++) {
			deriv = deriv, select(FULLb,zselector')
		}
		
		for (i=2; i<=cols(SURxnames);i++) {
			newline = select(
				SURb,(SURxselector :* J(rows(SURnames),1,SURxnames[1,i])
					:== SURnames[.,2])')
			for (j=1; j<=cols(SURxnames);j++) {
				newline = newline, select(FULLb,zselector')
			}
			deriv = (deriv  \ newline)
		}
		
		return(deriv)
	}

	
	// Sigma matrix with dimension  Z + (Z*X) times Z + (Z*X)
	// ------------------------------------------------------
	
	real matrix khb_sigma(
		real matrix FULLcov,
		real matrix SURcov,
		real colvector SURxselector,
		string matrix SURnames,
		string rowvector SURxnames,
		real colvector zselector,
		string matrix FULLznames)
	{
		
		real matrix sigma
		real matrix i

		sigma = khb_select(FULLcov,zselector)
		
		sigma = sigma,
		J(rows(sigma),cols(FULLznames),0) \
		J(cols(FULLznames),cols(sigma),0),
		khb_select(SURcov,
			(SURxselector :* J(rows(SURnames),1,SURxnames[1,1]) :== SURnames[.,2]))
		
		for (i=2; i<=cols(SURxnames);i++) {
			sigma = sigma,
			J(rows(sigma),cols(FULLznames),0) \
			J(cols(FULLznames),cols(sigma),0),
			khb_select(SURcov,
				(SURxselector :* J(rows(SURnames),1,SURxnames[1,i]) :== SURnames[.,2]))
			
		}
		
		return(sigma)
	}
	
	// Function to deselect constants and ommited
	// ------------------------------------------
	
	real matrix khb_touse(
		string matrix input
		)
	{
		real matrix output 
		output =  (input[.,2]:!="_cons") :* (!strpos(input[.,2],"o.") )
		return(output)
	}	
	
	// Function to select KxK Submatrix from XxX Matrix
	// ------------------------------------------------
	
	real matrix khb_select(
		real matrix input,
		real vector selector
		)
	{
		real matrix output 
		output = select(select(input, selector'), selector)
		return(output)
	}


	// Function to tag names in a namestripe 
	// -------------------------------------

	real matrix khb_tag(
		string matrix namestripe,
		string rowvector namelist
		)

	{
		real matrix tag
		real scalar i
		tag = J(rows(namestripe),1,0)
		for (i=1;i<=cols(namelist);i++) {
			tag = tag :+
			   (J(rows(namestripe),1,namelist[1,i]) :== namestripe[.,2])
		}
		return(tag)
	}

		
	// Compile into a libary
	mata mlib create lkhb, replace
	mata mlib add lkhb           ///
	  khb()                      /// KHB-Method
	  khb_deriv()                /// Derivatives
	  khb_sigma()                /// Sigma
	  khb_disentangle()          /// Disentangle
	  khb_summary()              /// Summary
	  khb_touse()                /// Remove constants, ommiteds, etc. 
	  khb_select()               /// Selection of Submatrixes
	  khb_tag()                  /// Tag names

	mata mlib index

end
exit


