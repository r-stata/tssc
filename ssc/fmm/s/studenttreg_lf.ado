*! version 2.1.0 12feb2012
*! author: Partha Deb
* version 1.0.0 12jul2007
* version 1.0.0 12jul2007

program studenttreg_lf
	version 9.2

	args todo b lnf g negH g1 g2

	tempname xb lnsigma sigma dfpl1 z z2bydf inv1plz2bydf ///
						G1 G2 h11 h21 h22 H11 H21 H22 

	mleval `xb' = `b', eq(1)
	mleval `lnsigma' = `b', eq(2)

	quietly {
		gen double `sigma' = exp(`lnsigma')
		gen double `dfpl1' = $fmm_tdf + 1
		gen double `z' = ($ML_y-`xb')/`sigma'
		gen double `z2bydf' = (`z'^2)/$fmm_tdf
		gen double `inv1plz2bydf' = 1/(1 + `z2bydf')

		mlsum `lnf' = ln(tden($fmm_tdf,`z')/`sigma')

		replace `g1' = `dfpl1' * `inv1plz2bydf' * `z' / ($fmm_tdf*`sigma')
		replace `g2' = `dfpl1' * `inv1plz2bydf' * `z2bydf' - 1

		mlvecsum `lnf' `G1' = `g1', eq(1)
		mlvecsum `lnf' `G2' = `g2', eq(2)
		matrix `g' = (`G1', `G2')

		gen double `h11' = `dfpl1' * `inv1plz2bydf' / ($fmm_tdf*(`sigma'^2)) ///
												* (`inv1plz2bydf' * 2 * `z2bydf' - 1)
		gen double `h21' = -2 * `dfpl1' * `inv1plz2bydf' * `z' / ($fmm_tdf*`sigma') ///
														* (1 - `inv1plz2bydf' * `z2bydf')
		gen double `h22' = 2 * `dfpl1' * `inv1plz2bydf' * `z2bydf'	///
												* (`inv1plz2bydf' * `z2bydf' - 1)

		mlmatsum `lnf' `H11' = -`h11', eq(1,1)
		mlmatsum `lnf' `H21' = -`h21', eq(2,1)
		mlmatsum `lnf' `H22' = -`h22', eq(2,2)
		matrix `negH' = (`H11',`H21'' \	///
										 `H21',`H22')
	}

end
