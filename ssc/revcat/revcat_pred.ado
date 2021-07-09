program define revcat_pred
version 11.2

syntax newvarname(min=1) [if] [in] [ , level(integer `c(level)') * ]
local p `varlist'

if "`e(cmd)'"!="revcat"{
	di as error "revcat_pred may only be called after running revcat"
	exit
}
	
quietly{
	tempname b
	matrix `b'=e(b)
	local nv : word count `e(depvar)'
	local pos : word 1 of `e(depvar)'
	local age : word 2 of `e(depvar)'
	if `nv'==3{
		local date : word 3 of `e(depvar)'
	}
	else{
		tempvar date
		gen byte `date'=0
	}

	marksample touse `if' `in', novarlist
	markout `touse' `age' `date'

	local n=colnumb(`b',"log_rho:")
	local n1=colnumb(`b',"log_lambda2:")
	local n2=colnumb(`b',"log_r2:")

	if(`n2'<.) local rr=1
	else local rr=0
	tempname c	
	if `n1'<. | `n2'<.{
		matrix `c'=e(change)
		matrix `c'=(`c' \ 1E20)
	}
	else{
		matrix `c'=(1E20)
	}
	local nl=rowsof(`c')
	local r=`nl'+1

	local w `options'
	if "`w'"!=""{
		local w `options'
		local predictable=0
		local ii=0
		forval i=1/`nl'{
			if "`w'"=="lambda`i'"{
				local predictable=1
				local ii=`i'
			}
		}
		if "`w'"=="rho" local predictable=1
		if "`w'"=="lambda" local predictable=1
		if `predictable'==0{
			di as error "Option `w' not allowed"
			exit
		}
		if "`w'"!="lambda"{
			if("`w'"=="rho" | "`w'"=="lambda1" | `rr'==0) local exp xb(log_`w')
			else local exp xb(log_r`ii') + xb(log_lambda1)
			predictnl `p'=`exp' if `touse' , ci(l_`p' u_`p')  level(`level')
			foreach x in `p' l_`p' u_`p'{
				replace `x'=exp(`x') if `touse'
			}
		}
		else{
			forval i=1/`nl'{
				if(`i'==1 | `rr'==0) local exp xb(log_lambda`i')
				else local exp xb(log_r`i') + xb(log_lambda1)
				predictnl `p'`i'=`exp' if `touse' , ci(l_`p'`i' u_`p'`i')  level(`level')
				foreach x in `p' l_`p' u_`p'{
					replace `x'`i'=exp(`x'`i') if `touse'
				}
			}
		}
		exit
	}
		
	tempname t0
	scalar `t0'=-1E20
	forval i=1/`nl'{
		tempname t`i'
		scalar `t`i''=`c'[`i',1]
		tempvar log_lambda`i' lambda`i' 
		if(`i'==1 | `rr'==0){
			predict double `log_lambda`i''  if `touse', xb equation(#`i')
			gen double `lambda`i''=exp(`log_lambda`i'') if `touse'
		}
		else{
			tempvar log_r`i' r`i' 
			predict double `log_r`i''  if `touse', xb equation(#`i')
			gen double `r`i''=exp(`log_r`i'') if `touse'
			gen double `log_lambda`i''=`log_r`i'' + `log_lambda1' if `touse'
			gen double `lambda`i''=exp(`log_lambda`i'') if `touse'
		}
	}
	tempvar log_rho rho
	predict double `log_rho'  if `touse', xb equation(#`r')
	gen double `rho'=exp(`log_rho') if `touse'

	if `e(age)'==0{
		tempvar birth
		gen double `birth'=`date'-`age'
		local d `date'
	}
	else{
		local birth 0 
		local d `age'
	}
	gen `p'=0 if `touse'
	
	foreach x in s q e de dql dqr{
		tempvar `x'
		gen double ``x''=.
	}
	forval i=1/`r'{
		tempvar g`i'
		gen double `g`i''=0 if `touse'
	}
	forval i=1/`nl'{
		local j=`i'-1
		local L `lambda`i''
		replace `q'=`L'/(`L'+`rho') 

		replace `s'=0 if `touse'
		replace `s'=`t`i''-`birth' if `d'>`t`i''  & `birth'<=`t`i'' & `birth'>`t`j'' & `touse'
		replace `s'=`d'-`birth' if `d'<=`t`i'' & `d'>`t`j''  & `birth'<=`t`i'' & `birth'>`t`j'' & `touse'
		replace `s'=`t`i''-`t`j''  if `d'>`t`i''  & `birth'<=`t`j'' & `touse'
		replace `s'=`d'-`t`j''  if `d'<=`t`i'' & `d'>`t`j'' & `birth'<=`t`j'' & `touse'

		replace `e'=exp(-(`L'+`rho')*`s')

		replace `de'=-`s'*`e'
		replace `dql'=`rho'/(`L'+`rho')^2
		replace `dqr'=-`L'/(`L'+`rho')^2
		
		forval k=1/`j'{
			replace `g`k''=`e'*`g`k''
		}
		replace `g`i''=-`e'*`dql' + (`p'-`q')*`de' + `dql'
		replace `g`r''=(`g`r''-`dqr')*`e' + (`p'-`q')*`de' + `dqr'

		replace `p'=(`p'-`q')*`e' + `q'
	}
	
	if `rr'~=0{	
		forval i=1/`nl'{
			if `i'==1{
				forval j=2/`nl'{
					replace `g`i''=`g`i'' + `r`j''*`g`j''
				}
			}
			else{		
				replace `g`i''=`lambda1'*`g`i''
			}
		}
	}
			
	forval i=1/`nl'{
		replace `g`i''=`lambda`i''*`g`i''/(`p'*(1-`p'))
	}
	replace `g`r''=`rho'*`g`r''/(`p'*(1-`p'))
	
	tempvar se
	tempname V
	matrix `V'=e(V)

	gen double `se'=0 if `touse'
	
	local m=`n'-(`nl'+1)
	if(`m'==0){
		forval i=1/`r'{
			forval j=1/`r'{	
				replace `se' = `se' + `g`i''*`g`j''*`V'[`i', `j']
			}
		}
	}
	else{
		local s : colnames `b' 
		forval i=1/`n'{
			forval j=1/`n'{
				if `i'>`m'{
					local ki=`i'-`m'
					local xi 1
				}
				else{
					local ki=1
					local xi : word `i' of `s'
				}
				if `j'>`m'{
					local kj=`j'-`m'
					local xj 1
				}
				else{
					local kj=1
					local xj : word `j' of `s'
				}
				replace `se' = `se' + `g`ki''*`g`kj''*`xi'*`xj'*`V'[`i', `j']
			}
		}
	}
	
	tempname z
	scalar `z'=invnormal(1-0.5*(1-`level'/100))
	
	replace `se'=sqrt(`se')
	gen l_`p'=invlogit(logit(`p')-`z'*`se')
	gen u_`p'=invlogit(logit(`p')+`z'*`se')
	replace l_`p'=0 if `p'==0 &`touse'
	replace u_`p'=0 if `p'==0 &`touse'
}
end
