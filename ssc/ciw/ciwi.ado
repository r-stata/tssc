*! 1.0.1 NJC 19 Sept 2004 
* 1.0.0 NJC 12 Nov 2002 
program define ciwi, rclass
	version 7
	gettoken n 0 : 0 
	confirm integer number `n'
	gettoken k 0 : 0, parse(" ,")  
	confirm integer number `k'
	syntax [ , Level(integer $S_level) ] 
	if `level' < 10 | `level' > 99 { 
		error 198
	}
	
	local ttl "    Mean"
	local tt1 "    Obs "
	
	ret scalar N = `n'
	ret scalar mean = `k' / `n'
	ret scalar se = sqrt((return(mean))*(1-return(mean))/`n')
	
	tempname z A B C lb ub
	scalar `z' = invnorm((100 + `level') / 200)
	scalar `A' = 2 * `k' + (`z')^2
	scalar `B' = /* 
	*/ `z' * sqrt((`z')^2 + 4 * `n' * return(mean) * (1 - return(mean)))
	scalar `C' = 2 * (`n' + (`z')^2) 
	scalar `lb' = (`A' - `B') / `C'  
	scalar `ub' = (`A' + `B') / `C' 
	ret scalar lb = `lb'
	ret scalar ub = `ub' 
	
	/* double save in S_# and r()  */
	global S_1 `return(N)'
	global S_3 `return(mean)'
	global S_4 `return(se)'
	global S_5 `return(lb)'
	global S_6 `return(ub)'

	di in smcl in gr _col(56) /*
	*/ "{hline 3} Wilson Score {hline 3}"
	
	#delimit ;
	di in smcl in gr
"    Variable {c |} `tt1'    `ttl'    Std. Err.       [`level'% Conf. Interval]"
	_n "{hline 13}{c +}{hline 61}" ;
	di in smcl in gr "             {c |}" _col(14) 
		in yel %8.0f return(N)
	 	_col(27) %9.0g return(mean)
	 	_col(39) %9.0g return(se)
	 	_col(55) %9.0g return(lb)
	 	_col(67) %9.0g return(ub) in gr  ;
	#delimit cr
end
