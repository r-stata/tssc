program define revcat_ll
version 11.2

local pos "$ML_y1"
local age "$ML_y2"
local date "$ML_y3"

quietly{
	local args todo b ll
	local nl=rowsof(revcat_mat)
	local r=`nl'+1
	local np=cond($revcat_smooth==1, `r'+1, `r')
	forval i=1/`nl'{
		local args `args' g`i'
	}
	local args `args' g`r'
	if($revcat_smooth==1) local args `args' g`np'
	args `args' H
	tempname t0
	scalar `t0'=-1E20
	
	forval i=1/`nl'{
		tempname t`i'
		scalar `t`i''=revcat_mat[`i',1]
		tempvar log_lambda`i' lambda`i'
		if(`i'==1 | $revcat_rr==0){
			mleval `log_lambda`i''=`b', eq(`i')
			gen double `lambda`i''=exp(`log_lambda`i'') if $ML_samp
		}
		else{
			tempvar log_r`i' r`i' 
			mleval `log_r`i''=`b', eq(`i')
			gen double `r`i''=exp(`log_r`i'') if $ML_samp
			gen double `log_lambda`i''=`log_r`i'' + `log_lambda1' if $ML_samp
			gen double `lambda`i''=exp(`log_lambda`i'') if $ML_samp
		}
	}
	tempvar log_rho rho
	mleval `log_rho'=`b', eq(`r')
	gen double `rho'=exp(`log_rho') if $ML_samp
	if($revcat_smooth==1){
		tempvar log_sigma sigma
		mleval `log_sigma'=`b', eq(`np')
		gen double `sigma'=exp(`log_sigma') if $ML_samp
	}
	if $revcat_age==0{
		tempvar birth
		gen double `birth'=`date'-`age' if $ML_samp
		local d `date'
	}
	else{
		local birth 0 
		local d `age'
	}
	tempvar p
	gen double `p'=0 if $ML_samp

	foreach x in s q e de dql dqr d2e d2ql d2qr d2qlr d3{
		tempvar `x'
		gen double ``x''=.
	}
	forval i=1/`np'{
		replace `g`i''=0 if $ML_samp
	}
	forval i=1/`np'{
		forval j=`i'/`np'{
			tempvar h_`i'_`j'
			gen double `h_`i'_`j''=0 if $ML_samp
		}
	}
	
	forval i=1/`nl'{
		local j=`i'-1
		local L `lambda`i''
		replace `q'=`L'/(`L'+`rho') if $ML_samp

		replace `s'=0 if $ML_samp
		replace `s'=`t`i''-`birth' if `d'>`t`i''  & `birth'<=`t`i'' & `birth'>`t`j'' & $ML_samp
		replace `s'=`d'-`birth' if `d'<=`t`i'' & `d'>`t`j''  & `birth'<=`t`i'' & `birth'>`t`j'' & $ML_samp
		replace `s'=`t`i''-`t`j''  if `d'>`t`i''  & `birth'<=`t`j'' & $ML_samp
		replace `s'=`d'-`t`j''  if `d'<=`t`i'' & `d'>`t`j'' & `birth'<=`t`j'' & $ML_samp

		replace `e'=exp(-(`L'+`rho')*`s') if $ML_samp

		replace `de'=-`s'*`e' if $ML_samp
		replace `dql'=`rho'/(`L'+`rho')^2
		replace `dqr'=-`L'/(`L'+`rho')^2

		replace `d3'=1/(`L'+`rho')^3 if $ML_samp
		replace `d2e'=(`s')^2*`e' if $ML_samp
		replace `d2ql'=-2*`rho'*`d3' if $ML_samp
		replace `d2qr'=2*`L'*`d3' if $ML_samp
		replace `d2qlr'=(`L'-`rho')*`d3' if $ML_samp

		replace `h_`i'_`i''=-2*`de'*`dql'-`e'*`d2ql'+(`p'-`q')*`d2e'+ `d2ql' if $ML_samp
		replace `h_`r'_`r''=`h_`r'_`r''*`e' + 2*`g`r''*`de' - `d2qr'*`e' - 2*`dqr'*`de' + (`p'-`q')*`d2e' + `d2qr' if $ML_samp
		replace `h_`i'_`r''=-`de'*`dql'+(`g`r''-`dqr')*`de' + (`p'-`q')*`d2e' + (1-`e')*`d2qlr' if $ML_samp
		forval k=1/`j'{
			replace `h_`k'_`i''=`de'*`g`k'' if $ML_samp
			replace `h_`k'_`r''=`de'*`g`k'' + `e'*`h_`k'_`r'' if $ML_samp
			forval l=1/`k'{
				replace `h_`l'_`k''=`e'*`h_`l'_`k'' if $ML_samp
			}
		}

		forval k=1/`j'{
			replace `g`k''=`e'*`g`k''  if $ML_samp
		}
		replace `g`i''=-`e'*`dql' + (`p'-`q')*`de' + `dql' if $ML_samp
		replace `g`r''=(`g`r''-`dqr')*`e' + (`p'-`q')*`de' + `dqr' if $ML_samp

		replace `p'=(`p'-`q')*`e' + `q' if $ML_samp
	}

	replace `ll'= `pos'*log(`p')+(1-`pos')*log(1-`p') if $ML_samp
	
	//*****************************************************************************************
	//*****************************************************************************************
	
	if($revcat_smooth==1){
		su $ML_w if $ML_samp
		local N=r(sum)
		tempname Sf
		scalar `Sf'=0
		forval i=2/`nl'{
			local j=`i'-1
			scalar `Sf'=`Sf' + (`log_lambda`i''-`log_lambda`j'')^2
		}
		tempname sn
		scalar `sn'=1/(`sigma'^2*`N') 

		replace `ll'=`ll'  - ((`nl'-1)*`log_sigma' + 1/(2*`sigma'^2)*`Sf')/`N' if $ML_samp
	}
	
	//*****************************************************************************************
	//*****************************************************************************************
	
	if(`todo'==0) exit

	tempvar dldp
	gen double `dldp'=(`pos'-`p')/(`p'*(1-`p')) if $ML_samp
	
	forval i=1/`nl'{
		if(`i'==1 | $revcat_rr==0) local y`i' `lambda`i''
		else local y`i' `r`i''
	}
	local y`r' `rho'
	
	tempvar d2ldp
	gen double `d2ldp'=-`pos'/`p'^2 - (1-`pos')/(1-`p')^2 if $ML_samp

	forval i=1/`r'{
		forval j=`i'/`r'{
			replace `h_`i'_`j''= `h_`i'_`j''*`dldp' + `g`i''*`g`j''*`d2ldp'
		}
	}
	forval i=1/`r'{
		replace `g`i''=`dldp'*`g`i''
	}
	
	//*****************************************************************************************
	//*****************************************************************************************

	if($revcat_smooth==1){
		forval i=1/`nl'{
			local j=`i'-1
			local k=`i'+1
			replace `h_`i'_`i''=`h_`i'_`i'' + cond(`i'==1 | `i'==`nl', -`sn', -2*`sn')/(`lambda`i'')^2 

			if(`i'==1 & `nl'>1) replace `h_`i'_`i''=`h_`i'_`i''  + (-`log_lambda`k''+`log_lambda`i'')*`sn'/(`lambda`i'')^2
			if(`i'>1 & `i'<`nl') replace `h_`i'_`i''=`h_`i'_`i''  + (2*`log_lambda`i''-`log_lambda`k''-`log_lambda`j'')*`sn'/(`lambda`i'')^2
			if(`i'==`nl' & `i'>1) replace `h_`i'_`i''=`h_`i'_`i''  + (`log_lambda`i''-`log_lambda`j'')*`sn'/(`lambda`i'')^2
						
			if (`i'==1 & `nl'>1) replace `h_`i'_`np''=2*(-`log_lambda`k''+`log_lambda`i'')*`sn' if $ML_samp
			if (`i'>1 & `i'<`nl') replace `h_`i'_`np''=2*(2*`log_lambda`i''-`log_lambda`k''-`log_lambda`j'')*`sn' if $ML_samp
			if (`i'==`nl' & `i'>1) replace `h_`i'_`np''=2*(`log_lambda`i''-`log_lambda`j'')*`sn' if $ML_samp
		
			if (`i'<`nl') replace `h_`i'_`k''=`h_`i'_`k'' + `sn'/(`lambda`i''*`lambda`k'')			
		}
		replace `h_`np'_`np''=`h_`np'_`np'' - 2*`Sf'*`sn'
	
		forval i=1/`nl'{
			local j=`i'-1
			local k=`i'+1
			if(`i'==1 & `nl'>1) replace `g`i''=`g`i'' - (-`log_lambda`k''+`log_lambda`i'')*`sn'/(`lambda`i'')
			if(`i'>1 & `i'<`nl') replace `g`i''=`g`i'' - (2*`log_lambda`i''-`log_lambda`k''-`log_lambda`j'')*`sn'/(`lambda`i'')
			if(`i'==`nl' & `i'>1) replace `g`i''=`g`i'' - (`log_lambda`i''-`log_lambda`j'')*`sn'/(`lambda`i'')
		}
	}
		
	//*****************************************************************************************
	//*****************************************************************************************
	if($revcat_rr==1){
		forval i=2/`nl'{
			replace `h_1_1'=`h_1_1' + 2*`r`i''*`h_1_`i'' + `r`i''*`r`i''*`h_`i'_`i''
			forval j=`=`i'+1'/`nl'{
				replace `h_1_1'=`h_1_1' + 2*`r`i''*`r`j''*`h_`i'_`j''
			}
			replace `h_1_`r''=`h_1_`r'' + `r`i''*`h_`i'_`r''
			replace `h_`i'_`r''=`lambda1'*`h_`i'_`r''
		
			if($revcat_smooth==1) replace `h_1_`np''=`h_1_`np'' + `h_`i'_`np''
		}	
	
		forval i=2/`nl'{
			replace `h_1_`i''=`lambda1'*`h_1_`i'' + `g`i''
			forval j=2/`i'{
				replace `h_1_`i''=`h_1_`i'' + `lambda`j''*`h_`j'_`i''
			}
			forval j=`=`i'+1'/`nl'{
				replace `h_1_`i''=`h_1_`i'' + `lambda`j''*`h_`i'_`j''
			}
		}				
	
		tempvar lambda12
		gen double `lambda12'=(`lambda1')^2
		forval i=2/`nl'{
			forval j=`i'/`nl'{
				replace `h_`i'_`j''=`lambda12'*`h_`i'_`j''
			}
		}
	
		forval i=2/`nl'{
			replace `g1'=`g1' + `r`i''*`g`i''
			replace `g`i''=`lambda1'*`g`i''
		}
	}			
	//*****************************************************************************************
	//*****************************************************************************************
	
	forval i=1/`r'{
		replace `g`i''=(`y`i'')*`g`i''
		replace `h_`i'_`i''=(`y`i'')^2*`h_`i'_`i'' + `g`i''
		forval j=`=`i'+1'/`r'{
			replace `h_`i'_`j''=(`y`i'')*(`y`j'')*`h_`i'_`j''
		}
	}
	
	if($revcat_smooth==1) replace `g`np''=(-(`nl'-1) + 1/`sigma'^2*`Sf')/`N' if $ML_samp

	if(`todo'==1) exit
	
	//*****************************************************************************************
	//*****************************************************************************************
	
	tempname lnf
	forval i=1/`np'{
		tempname d_`i'_`i'
		mlmatsum `lnf' `d_`i'_`i''=`h_`i'_`i'', eq(`i')
		forval j=`=`i'+1'/`np'{
			tempname d_`i'_`j'
			mlmatsum `lnf' `d_`i'_`j''=`h_`i'_`j'', eq(`i', `j')
		}
	}

	local hd
	forval i=1/`np'{
		tempname row`i'
		forval j=1/`np'{
			if(`j'==1) matrix `row`i''=`d_`j'_`i'''
			else if(`i'>=`j') matrix `row`i''=(`row`i'', `d_`j'_`i''')
			else matrix `row`i''=(`row`i'', `d_`i'_`j'')
		}
		if(`i'==1) local hd `hd' `row`i''
		else local hd `hd' \ `row`i''
	}
	matrix `H'=(`hd')
}
end
