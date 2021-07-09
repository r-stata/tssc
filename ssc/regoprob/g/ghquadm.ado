program define ghquadm
* stolen from gllamm6 who stole it from rfprobit (Bill Sribney)
	version 4.0

	parse "`*'", parse(" ")
	local n = `1'
	if `n' + 2 > _N  {
		di in red  /*
		*/ "`n' + 2 observations needed to compute quadrature points"
		exit 2001
	}

	tempname x w xx ww a b
	local i 1
	local m = int((`n' + 1)/2)
	matrix x = J(1,`m',0)
	matrix w = x
	while `i' <= `m' {
		if `i' == 1 {
			scalar `xx' = sqrt(2*`n'+1)-1.85575*(2*`n'+1)^(-1/6)
		}
		else if `i' == 2 { scalar `xx' = `xx'-1.14*`n'^0.426/`xx' }
		else if `i' == 3 { scalar `xx' = 1.86*`xx'-0.86*x[1,1] }
		else if `i' == 4 { scalar `xx' = 1.91*`xx'-0.91*x[1,2] }
		else { 
			local im2 = `i' -2
			scalar `xx' = 2*`xx'-x[1,`im2']
		}
		hermite `n' `xx' `ww'
		matrix x[1,`i'] = `xx'
		matrix w[1,`i'] = `ww'
		local i = `i' + 1
	}
	if mod(`n', 2) == 1 { matrix x[1,`m'] = 0}
/* start in tails */
	matrix `b' = (1,1)
	matrix w = w#`b'
	matrix w = w[1,1..`n']
	matrix `b' = (1,-1)
	matrix x = x#`b'
	matrix x = x[1,1..`n']
/* other alternative (left to right) */
/*
	above: matrix x = J(1,`n',0)
	while ( `i'<=`n'){
		matrix x[1, `i'] = -x[1, `n'+1-`i']
		matrix w[1, `i'] = w[1, `n'+1-`i']
		local i = `i' + 1
	}
*/
	matrix `2' = x
	matrix `3' = w
end


program define hermite  /* integer n, scalar x, scalar w */
* stolen from gllamm6 who stole it from rfprobit (Bill Sribney)
	version 4.0
	local n "`1'"
	local x "`2'"
	local w "`3'"
	local last = `n' + 2
	tempname i p
	matrix `p' = J(1,`last',0)
	scalar `i' = 1
	while `i' <= 10 {
		matrix `p'[1,1]=0
		matrix `p'[1,2] = _pi^(-0.25)
		local k = 3
		while `k'<=`last'{
			matrix `p'[1,`k'] = `x'*sqrt(2/(`k'-2))*`p'[1,`k'-1] /*
			*/	- sqrt((`k'-3)/(`k'-2))*`p'[1,`k'-2]
			local k = `k' + 1
		}
		scalar `w' = sqrt(2*`n')*`p'[1,`last'-1]
		scalar `x' = `x' - `p'[1,`last']/`w'
		if abs(`p'[1,`last']/`w') < 3e-14 {
			scalar `w' = 2/(`w'*`w')
			exit
		}
		scalar `i' = `i' + 1
	}
	di in red "hermite did not converge"
	exit 499
end
