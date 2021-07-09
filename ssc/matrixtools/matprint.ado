*! Part of package matrixtools v. 0.24
*! Support: Niels Henrik Bruun, nhbr@ph.au.dk
* 2018-09-09 Option for removing row header from print
* 2017-01-06 Rewritten 
* TODO: option no rowlabels
* TODO: To excel! to word?
program define matprint
	version 12.1
	syntax anything(name=matrixexpression) [using/]/*
		*/[,/*
			*/Style(string) /*
			*/Decimals(string) /*
			*/noRowheaders /*
			*/TItle(string) /*
			*/TOp(string) /*
			*/Undertop(string) /*
			*/Bottom(string) /*
			*/Replace /*
			*/noEqstrip /*
			*/Hidesmall(integer 0) /*
		*/]

	tempname matrixname
	matrix `matrixname' = `matrixexpression'

	capture mata: __decimals = `decimals'
	if _rc mata: __decimals = 2	
	if `=`hidesmall' <= 0' local hidesmall .
	
	// Returned lines lines are accessible from Mata in variable tbl
	mata: __lm = nhb_mt_labelmatrix()
	mata: __lm.from_matrix("`matrixname'")
	if "`rowheaders'" != "" {
		mata: __lm.row_equations("")
		mata: __lm.row_names("")
	}
	mata: __tbl = __lm.print(	"`style'",  __decimals, ///
								"`eqstrip'" == "", `hidesmall', ///
								"`title'", "`top'", "`undertop'", "`bottom'", ///
								"`using'", "`replace'" == "replace")
	capture mata: mata drop __decimals
	capture mata: mata drop __lm
	capture mata: mata drop __tbl
	end
