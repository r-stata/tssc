*! version 2.0.1 September 23, 2014 David Roodman
*! version 1.0.1   November 2, 2007 Scott Merryman    
*! Based on on -betafit- by Cox, Jenkins, and Buis
* rewritten by David Roodman 9/8/14
cap program drop gevfit_lf2
program gevfit_lf2
	version 11.0
	args todo b lng lng_sig lng_xi lng_mu H
	tempvar x sig xi mu
	mleval `sig'=`b', eq(1) $gev_scale_scalar
	if `sig'<=0 exit // works well enough if sig is a variable
	mleval `xi' =`b', eq(2) $gev_shape_scalar
	mleval `mu' =`b', eq(3) $gev_loc_scalar
	qui {
		gen double `x' = ($S_MLy - `mu') / `sig' if $ML_samp
		tempvar xi_x one_plus_xi_x ln_one_plus_xi_x f inv_xi absxi gumbel gumbel2
		if "$gev_shape_scalar"!="" {
			scalar `inv_xi' = 1/`xi'
			scalar `gumbel'  = abs(`xi')<1e-10
			scalar `gumbel2' = abs(`xi')<1e-5
		}
		else {
			gen `absxi' = abs(`xi') if $ML_samp
			gen byte `gumbel'  = `absxi'<1e-10
			gen byte `gumbel2' = `absxi'<1e-5			
			gen double `inv_xi' = 1/`xi' if $ML_samp
		}
		gen double `xi_x' = `xi' * `x' if $ML_samp
		gen double `one_plus_xi_x' = 1 + `xi_x' if $ML_samp
		gen double `ln_one_plus_xi_x' = ln(`one_plus_xi_x') if $ML_samp
		gen double `f' = cond(`gumbel', exp(-`x'), (`one_plus_xi_x')^-`inv_xi') if $ML_samp
		replace `lng' = -ln(`sig') - cond(`gumbel', `x'+`f', (`inv_xi'+1)*`ln_one_plus_xi_x' + `f') if $ML_samp
		if `todo' {
			tempvar lng_x neg_inv_sig inv_sig2 f_x f_xi x2 one_plus_xi
			gen double `x2' = `x'*`x' if $ML_samp
			if "$gev_shape_scalar"!="" scalar `one_plus_xi' = 1+`xi'
			  else                 gen double `one_plus_xi' = 1+`xi' if $ML_samp
			if "$gev_scale_scalar"!="" scalar `neg_inv_sig' = -1/`sig'
			  else                 gen double `neg_inv_sig' = -1/`sig' if $ML_samp
			gen double   `f_x' = -1/`one_plus_xi_x'                                          if $ML_samp // actually f_x/f
			gen double  `f_xi' = `inv_xi'*(-`x'/`one_plus_xi_x'+`inv_xi'*`ln_one_plus_xi_x') if $ML_samp // actually f_xi/f
			gen double `lng_x' = cond(`gumbel', `f'-1              , `f_x' *(`one_plus_xi'-`f')        ) if $ML_samp
			replace   `lng_xi' = cond(`gumbel', `x2'*.5*(1-`f')-`x', `f_xi'*(`one_plus_xi'-`f')+ln(`f')) if $ML_samp
			replace   `lng_mu' = `neg_inv_sig' * `lng_x'        if $ML_samp
			replace  `lng_sig' = `neg_inv_sig' + `x' * `lng_mu' if $ML_samp
			if `todo'==2 {
				tempvar f_xx f_xxi f_xixi lng_xx lng_xxi lng_xixi lng_musig lng_muxi f_xi2 one_plus_xi_x2
				tempname d2mumu d2musig d2muxi d2sigsig d2sigxi d2xixi
				gen double `one_plus_xi_x2' = `one_plus_xi_x'*`one_plus_xi_x' if $ML_samp
				gen double `f_xi2' = `f_xi'*`f_xi' if $ML_samp
				gen double `f_xx' = `one_plus_xi'/`one_plus_xi_x2' if $ML_samp // actually f_xx/f
				gen double `f_xxi' = -`f_x' * ((`inv_xi'+1)*`x'/`one_plus_xi_x' - `ln_one_plus_xi_x'/(`xi'*`xi')) if $ML_samp // actually f_xxi/f
				gen double `f_xixi' = ((`inv_xi'*`x2'/`one_plus_xi_x2'-2/`xi'*`f_xi')+`f_xi2') if $ML_samp // actually f_xixi/f
				gen double `lng_xx'   = cond(`gumbel2', -`f'                                       , `one_plus_xi'*(`f_xx'  -`f_x' *`f_x' )         -`f_xx'  *`f') if $ML_samp
				gen double `lng_xxi'  = cond(`gumbel2', (`x2'*.5-`x')*`f'+`x'-1                    , `one_plus_xi'*(`f_xxi' -`f_x' *`f_xi')  +`f_x' -`f_xxi' *`f') if $ML_samp
				gen double `lng_xixi' = cond(`gumbel2', `x2'*(`f'*((2/3)*`x'-`x2'*.25)-(2/3)*`x'+1), `one_plus_xi'*(`f_xixi'-`f_xi2'      )+2*`f_xi'-`f_xixi'*`f') if $ML_samp
				if "$gev_scale_scalar"!="" {
					gen double `lng_musig' = `lng_x' + `x'*`lng_xx' if $ML_samp
					local lng_muxi `lng_xxi' // lng_muxi needs to be multiplied by -1/sig, but do that after summing for efficiency
					mlmatsum `lng' `d2mumu' = `lng_xx', eq(3)
					mlmatsum `lng' `d2musig' = `lng_musig', eq(1,3)
					mlmatsum `lng' `d2muxi' = `lng_muxi', eq(2,3)
					mlmatsum `lng' `d2sigsig' = (1/`sig') * `x' * `lng_musig' - `lng_sig', eq(1)
					mlmatsum `lng' `d2sigxi' = `x' * `lng_muxi', eq(1,2)
					mat `d2muxi'   = -`d2muxi'/`sig'
					mat `d2sigxi'  = -`d2sigxi'/`sig'
					mat `d2musig'  = `d2musig'/`sig'^2
					mat `d2sigsig' = `d2sigsig'/`sig'
					mat `d2mumu'   = `d2mumu'/`sig'^2
				}
				else {
					gen double `inv_sig2' = `neg_inv_sig' * `neg_inv_sig' if $ML_samp
					gen double `lng_musig' = `inv_sig2' * (`lng_x' + `x'*`lng_xx') if $ML_samp
					gen double `lng_muxi' = `neg_inv_sig' * `lng_xxi' if $ML_samp
					mlmatsum `lng' `d2mumu'   = `inv_sig2' * `lng_xx', eq(3)
					mlmatsum `lng' `d2musig'  = `lng_musig', eq(1,3)
					mlmatsum `lng' `d2muxi'   = `lng_muxi', eq(2,3)
					mlmatsum `lng' `d2sigsig' = `x' * `lng_musig' + `neg_inv_sig' * `lng_sig', eq(1)
					mlmatsum `lng' `d2sigxi'  = `x' * `lng_muxi', eq(1,2)
				}
				mlmatsum `lng' `d2xixi' = `lng_xixi', eq(2)
				mat `H' = `d2sigsig',`d2sigxi',`d2musig' \ `d2sigxi'',`d2xixi',`d2muxi' \ `d2musig'',`d2muxi'', `d2mumu'
			}
		}
	}
end
