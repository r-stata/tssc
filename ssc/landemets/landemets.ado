*! version 1.1.4 24may2013

/*
History
24may2013: version 1.1.4 - bug in plot option corrected (the idea in the old lines 103-108 of version 1.1.2 is recovered in the new lines 132-141)
								 - more intensive use of the abbreviations
								 - parentheses in the conditions of 'if' and 'while' removed (not in the mata part)
08apr2013: version 1.1.3 - beta option added
								 - theta option added
								 - print function modified
								 - lines 103-108 of version 1.1.2 (calling tempvar, mat coln and svmat in relation with boundalpha) deleted 
16feb2013: version 1.1.2 - when computing asymmetric boundaries, different alpha spending functions may be used on each side
								 - rho may be a numlist of two numbers; now there is no default value for rho
	                      - internally, methods are recoded in methodmat: obf -> 1, poc -> 2, pow -> 3
								 - tempvar used for creating the names of variables derived from boundalpha matrix
							    - tempnames are not necessary for matrices; they are not used anymore
								 - names of t and alpha columns of boundalpha matrix substituted with time and cumalpha
								 - plot option added
								 - in print function, "boundaries" instead of "bounds" and other minor changes
							    - changes in the values returned in r()  
07feb2013: version 1.1.1
*/ 

pr landemets, rclass
	version 12.1
	syntax [, ///
		t(numlist sort >0 <=1)				/// interim monitoring times 
		Alpha(numlist >0 <1 max=2)			/// type I error(s)
		Method(string)							/// alpha spending function(s)	
      Rho(numlist >0 max=2)				/// parameter(s) of alpha spending function(s) in the power family
		Onesided									/// compute one-sided boundaries (default is twosided boundaries)
		Beta(numlist sort >0 <1 max=5)	/// type II error
		THeta(numlist sort >0 max=5)		/// standardized treatment difference
		Plot										/// plot the boundaries
	]

	capt mata mata which mm_root()	
	if _rc {
		di as err "mm_root() from -moremata- is required; type -ssc install moremata- to install it"
		exit 499
	}
	if "`t'" == "" loc t "1"
	loc dimt: word count `t'
	mat tmat = J(`dimt', 1, .)
	loc i 1
	foreach val of loc t {
		mat tmat[`i', 1] = `val'
		loc ++i
	}
	if "`alpha'" == "" loc alpha "0.05"
	loc dimalpha: word count `alpha'
	mat alphamat = J(`dimalpha', 1, .)
	loc i 1
	foreach val of loc alpha {
		mat alphamat[`i', 1] = `val'
		loc ++i
	}
	if "`method'" == "" loc method "obf"
	loc dimmethod: word count `method'	
	mat methodmat = J(`dimmethod', 1, .)
	loc i 1
	foreach val of loc method {
	   if "`val'" == "obf" mat methodmat[`i', 1] = 1
		else {
			if "`val'" == "poc" mat methodmat[`i', 1] = 2
			else {
				if "`val'" == "pow" mat methodmat[`i', 1] = 3
			}
		} 
		loc ++i
	}
	loc dimrho: word count `rho'
	mat rhomat = J(`dimmethod', 1, .)
	loc i 1
	loc found 0
	foreach val of loc rho {
		while `i' <= `dimmethod' & !`found' {
			if methodmat[`i', 1] == 3 {
				mat rhomat[`i', 1] = `val'
				loc ++found
			}
			loc ++i
	   }
		if `found' loc --found
	}
	if `dimalpha' != `dimmethod' {
		di as err "alpha and method options do not have the same length"
		exit 198
	}
	if (`dimmethod' == 1 & methodmat[1, 1] == .) | (`dimmethod' == 2 & (methodmat[1, 1] == . | methodmat[2, 1] == .)) {
		di as err "Unknown alpha spending function or incorrect syntax. Valid values:" _newline "a) obf (for O'Brien-Fleming type), poc (for Pocock type), pow (for power family) or" _newline "b) any two of the values in a) separated by one or more blank spaces"
		exit 198
	}
	if (`dimmethod' == 1 & methodmat[1, 1] == 3 & rhomat[1, 1] == .) | (`dimmethod' == 2 & ((methodmat[1, 1] == 3 & rhomat[1, 1] == .) | (methodmat[2, 1] == 3 & rhomat[2, 1] == .))) {
		di as err "rho parameter(s) not entered"
		exit 198
	}
	if (`dimmethod' == 1 & methodmat[1, 1] != 3 & `dimrho' == 1) | /// 
		(`dimmethod' == 2 & (methodmat[1, 1] != 3 | methodmat[2, 1] != 3) & `dimrho' == 2) | ///
		(`dimmethod' == 2 & methodmat[1, 1] != 3 & methodmat[2, 1] != 3 & `dimrho' == 1) {
		di as err "unused rho parameter(s)"
		exit 198
	}
	loc bilateral = 1
	if "`onesided'" != "" loc bilateral = 0
	if `bilateral' == 0 & `dimalpha' == 2 {
		di as err "onesided option used with alpha of length 2 (which implies two-sided boundaries)"
		exit 198
	}
	loc dimbeta: word count `beta'
	loc dimtheta: word count `theta'
	if `dimbeta' > 0 & `dimtheta' > 0 {
		di as err "only one of the beta and theta options can be used at the same time"
		exit 198
	}
	if `dimbeta' > 0 mat betamat = J(`dimbeta', 1, .)
	else  mat betamat = (.)
	loc i 1
	foreach val of loc beta {
		mat betamat[`i', 1] = `val'
		loc ++i
	}
	if `dimtheta' > 0 mat thetamat = J(`dimtheta', 1, .)
	else  mat thetamat = (.)
	loc i 1
	foreach val of loc theta {
		mat thetamat[`i', 1] = `val'
		loc ++i
	}
	mata: landemetsmata("alphamat", `dimalpha', "methodmat", "rhomat", "tmat", `dimt', `bilateral', "betamat", `dimbeta', "thetamat", `dimtheta')
	if "`plot'" != "" {
		if `bilateral' == 1 { 
			mat boundalphaplot = boundalpha[1..., 1..3]
			tempvar time lower upper
			mat coln boundalphaplot = `time' `lower' `upper'
		}
		else {
			mat boundalphaplot = boundalpha[1..., 1..2]
			tempvar time upper
			mat coln boundalphaplot = `time' `upper' 
		}
		qui svmat boundalphaplot, names(col) 
		loc limsup = ceil(`upper'[1])
		if `dimalpha' == 1 {
			loc methodtitle = methodlong
			loc alphatitle "`alpha'"
			if `bilateral' {
				loc liminf = -`limsup'
				graph twoway connected `upper' `lower' `time', mcolor(red red) lcolor(blue blue) legend(off) ///
					xtitle("Time") xlabel(`t') ytitle("{it:Z}-value") ylabel(`liminf'(1)`limsup') ///
					title("Alpha spending function: `methodtitle'" ///
						"{it:{&alpha}} = `alphatitle'.", size(*0.8))
				}
			else {
				loc liminf = 0
				graph twoway connected `upper' `time', mcolor(red) lcolor(blue) legend(off) ///
					xtitle("Time") xlabel(`t') ytitle("{it:Z}-value") ylabel(`liminf'(1)`limsup') ///
					title("Alpha spending function: `methodtitle'" ///
						"{it:{&alpha}} = `alphatitle'.", size(*0.8))
			}
		}	
		else {
			loc liminf = floor(`lower'[1])
			loc methodlowertitle = methodlonglower
			loc methoduppertitle = methodlongupper
			loc alphalowertitle = alphamat[1, 1]
			loc alphauppertitle = alphamat[2, 1]
			graph twoway connected `upper' `lower' `time', mcolor(red red) lcolor(blue blue) legend(off) ///
				xtitle("Time") xlabel(`t') ytitle("{it:Z}-value") ylabel(`liminf'(1)`limsup') ///
				title("Alpha spending function: lower, `methodlowertitle'; upper, `methoduppertitle'" ///
					"{it:{&alpha}}: lower, `alphalowertitle'; upper, `alphauppertitle'", size(*0.7))
		}
	}
   ret sca K = `dimt'
 if `dimbeta' > 0 | `dimtheta' > 0 {
		mat coln betatheta = beta theta
		ret mat beta_theta betatheta
	}
	if `bilateral' == 1 mat coln boundalpha = time lower upper cumalpha diffalpha
	else mat coln boundalpha = time upper cumalpha diffalpha
	ret mat bound_alpha boundalpha
	if `dimalpha' == 1 {
	   ret loc method = methodlong
		ret sca alpha = `alpha'
	}
	else {
		ret loc method_lower = methodlonglower
		ret loc method_upper = methodlongupper
		ret sca alpha_lower = alphamat[1, 1]
		ret sca alpha_upper = alphamat[2, 1]
	}
	ret loc bound_type = boundtype
end

version 12
mata:

function landemetsmata(alphamat, dimalpha, methodmat, rhomat, tmat, dimt, bilateral, betamat, dimbeta, thetamat, dimtheta) {
   n = 251
   symorone = 2 - dimalpha 
	t = st_matrix(tmat)
	alpha = st_matrix(alphamat)
	methodmat = st_matrix(methodmat)
	rhomat = st_matrix(rhomat)
	betamat = st_matrix(betamat)
	thetamat = st_matrix(thetamat)
	cs = J(dimt, dimalpha, .)	
	if (symorone) {
		alphat = alphafun(t, alpha, methodmat, rhomat, bilateral, symorone)
      find_c(n, alphat, t, dimt, cs, bilateral, symorone)	
	}
	else {
		alphatlow = alphafun(t, alpha[1], methodmat[1], rhomat[1], bilateral, symorone)
		alphatupp = alphafun(t, alpha[2], methodmat[2], rhomat[2], bilateral, symorone)
		alphatasym = (alphatlow, alphatupp)
		alphat = alphatasym[., 1] + alphatasym[., 2]
      find_c(n, alphatasym, t, dimt, cs, bilateral, symorone)
	}
	diffalphat = J(dimt, 1, alphat[1])
	for (i = 2; i <= dimt; i++) {
		diffalphat[i] = alphat[i] - alphat[i-1]
	}
	if (bilateral & symorone) resultmat = (t, -cs, cs, alphat, diffalphat)
   else resultmat = (t, cs, alphat, diffalphat) 
	st_matrix("boundalpha", resultmat)
	bound = bound_name(bilateral, symorone)
	st_strscalar("boundtype", bound)
	if (dimalpha == 1) st_strscalar("methodlong", methodn2name(methodmat, rhomat))
	else {
		st_strscalar("methodlonglower", methodn2name(methodmat[1], rhomat[1]))
		st_strscalar("methodlongupper", methodn2name(methodmat[2], rhomat[2]))		
	}
	betatheta = J(max((dimbeta, dimtheta)), 2, .)
	if (dimbeta > 0) {
	   betatheta[., 1] = betamat
		for (i = 1; i <= dimbeta; i++) {
			betatheta[i, 2] = find_betatheta(n, betamat[i], thetamat, t, dimt, cs :* sqrt(t), bilateral, symorone)
		} 
	}
	else if (dimtheta > 0) {
		betatheta[., 2] = thetamat
		for (i = 1; i <= dimtheta; i++) {
			betatheta[i, 1] = find_betatheta(n, betamat, thetamat[i], t, dimt, cs :* sqrt(t), bilateral, symorone)
		}
	}
	st_matrix("betatheta", betatheta) 
	print(bound, alpha, dimalpha, t, dimt, cs, alphat, diffalphat, methodmat, rhomat, bilateral, betatheta, dimbeta, dimtheta)
}

function alphafun(t, alpha, methodmat, rhomat, bilateral, symorone) {
	if (methodmat == 1) return(((1 + bilateral*symorone) * 2) :* (1 :- normal(invnormal(1 - alpha / 2 / (1 + bilateral*symorone)) :/ sqrt(t)))) // for two-sided symorone bounds one must multiply and divide by 2
	else {
		if (methodmat == 2) return(alpha :* log(1 :+ (exp(1) :-1) :* t))
		else {
			if (methodmat == 3) return(alpha :* t:^rhomat)
		}
	}
}

function find_c(n, alphat, t, dimt, cs, bilateral, symorone) {
	if (symorone) {
		cs[1] = sqrt(t[1]) * invnormal(1 - alphat[1] / (1 + bilateral))
		if(cs[1] >= .) cs[1] = 8.209536152 * sqrt(t[1])  // 8.209536152 is apparently the largest value returned by invnormal() 
		if (bilateral) x = rangen(-cs[1], cs[1], n)
		else x = rangen(-8.209536152, cs[1], n)
	}
	else {
	 	cs[1, 1] = sqrt(t[1]) * invnormal(alphat[1, 1])
		if(-cs[1, 1] >= .) cs[1, 1] = -8.209536152 * sqrt(t[1]) 
		cs[1, 2] = sqrt(t[1]) * invnormal(1- alphat[1, 2])
		if(cs[1, 2] >= .) cs[1, 2] = 8.209536152 * sqrt(t[1]) 
		x = rangen(cs[1, 1], cs[1, 2], n)
	}
	y = normalden(x, 0, sqrt(t[1]))
	ynext = J(n, 1, .)
	for (i = 2; i <= dimt; i++) {
	   if(symorone) {
			rc = mm_root(z = ., &objective_c2(), 0.001, 10, 0, 1000, n, alphat[i] - alphat[i-1], sqrt(t[i] - t[i-1]), x, y, cs[i-1], bilateral, symorone)
		 	if (rc != 0) z = .
			cs[i] = z
		}
		else {
			rc = mm_root(z = ., &objective_c2(), -10, -0.001, 0, 1000, n, alphat[i, 1] - alphat[i-1, 1], sqrt(t[i] - t[i-1]), x, y, cs[i-1, 2] - cs[i-1, 1], bilateral, symorone)
		   if (rc != 0) z = .
			cs[i, 1] = z
			rc = mm_root(z = ., &objective_c2(), 0.001, 10, 0, 1000, n, alphat[i, 2] - alphat[i-1, 2], sqrt(t[i] - t[i-1]), x, y, cs[i-1, 2] - cs[i-1, 1], bilateral, symorone)
			if (rc != 0) z = .
			cs[i, 2] = z 	
		}
		if (symorone) { 
		   if (bilateral) {
				xnext = rangen(-cs[i], cs[i], n)
				step = 2 * cs[i-1] / (n - 1)		
			}
		   else {
				xnext = rangen(-8.209536152, cs[i], n)
				step = (cs[i-1] - (-8.209536152)) / (n - 1)
			}
		}
		else {
			xnext = rangen(cs[i, 1], cs[i, 2], n)
			step = (cs[i - 1, 2] - cs[i - 1, 1]) / (n - 1)	
		}
		for (j = 1; j <= n; j++) {
			ynext[j] = simpson(y :* normalden(xnext[j] :- x, 0, sqrt(t[i] - t[i-1])), n, step)
		}
		x = xnext
		y = ynext
	}
	cs = cs :/ sqrt(t)
}

function objective_c2(c, n, alpha, t, x, y, cprev, bilateral, symorone) {
	if(c < 0) integrand = y :* normal((c :- x) :/ t)
	else 	integrand = y :* (1 :- normal((c :- x) :/ t))  
	if (bilateral) step = (1 + symorone) * cprev / (n - 1)
	else step = (cprev - (-8.209536152)) / (n - 1)
	return((1 + bilateral * symorone) * simpson(integrand, n, step) - alpha)
}

function simpson(y, n, step) {
	temp = y[1] - y[n];
	for (i = 1; i <= (n-1)/2; i++) {
		temp = temp + 4 * y[2*i] + 2 * y[2*i + 1]
	}
  	return(step * temp / 3)
}

function	bound_name(bilateral, symorone) {
   if (bilateral) {
		if (symorone) return("Two-sided")
		else return("Asymmetric") 
	}
	else return("One-sided")
}

function	find_betatheta(n, beta, theta, t, dimt, cs, bilateral, symorone){
		rc = mm_root(z = ., &objective_betatheta(), 0.001, 10, 0, 1000, n, beta, theta, t, dimt, cs, bilateral, symorone)
		if (rc != 0) z = .
		return(z)
}

function	objective_betatheta(v, n, beta, theta, t, dimt, cs, bilateral, symorone){
	if (beta < .) {
		v1 = v 
		v2 = beta
	}
	else if (theta < .) {
		v1 = theta
		v2 = v
	}
	if (symorone) {
		if (bilateral) x = rangen(-cs[1], cs[1], n)
		else x = rangen(-8.209536152 * sqrt(t[1]), cs[1], n)
		y = normalden(x :- (v1 * t[1]), 0, sqrt(t[1]))
		ynext = J(n, 1, .)
		for (i = 2; i <= dimt; i++) {
			if (bilateral){
				xnext = rangen(-cs[i], cs[i], n)
				step = 2 * cs[i-1] / (n - 1)				
			}
			else {
				xnext = rangen(-8.209536152 * sqrt(t[i] - t[i-1]), cs[i], n) // pensar si esta bien multiplicado por sqrt()
				step = (cs[i-1] - (-8.209536152 * sqrt(t[i] - t[i-1])))/ (n - 1)
			}
			for (j = 1; j <= n; j++) {
				ynext[j] = simpson(y :* normalden(xnext[j] :- x :- (v1 * (t[i] - t[i-1])), 0, sqrt(t[i] - t[i-1])), n, step)
			}
			x = xnext
			y = ynext
		}
		if (bilateral) step = 2 * cs[dimt] / (n - 1)
		else step = (cs[dimt] - (-8.209536152 * sqrt(t[dimt] - t[dimt-1]))) / (n - 1)
	}
	else {
		x = rangen(cs[1, 1], cs[1, 2], n)
		y = normalden(x :- (v1 * t[1]), 0, sqrt(t[1]))
		ynext = J(n, 1, .)
		for (i = 2; i <= dimt; i++) {
			xnext = rangen(cs[i, 1], cs[i, 2], n)
			step = (cs[i-1, 2] - cs[i-1, 1]) / (n - 1)				
			for (j = 1; j <= n; j++) {
				ynext[j] = simpson(y :* normalden(xnext[j] :- x :- (v1 * (t[i] - t[i-1])), 0, sqrt(t[i] - t[i-1])), n, step)
			}
			x = xnext
			y = ynext
		}
		step = (cs[dimt, 2] - cs[dimt, 1]) / (n - 1)
	}
	return(simpson(y, n, step) - v2)
}

function print(bound, alpha, dimalpha, t, dimt, cs, alphat, diffalphat, methodmat, rhomat, bilateral, betatheta, dimbeta, dimtheta) {
	printf("\n")
	printf("{res}{space 1}%s {txt}boundaries\n", bound)
	printf("\n")
	if (dimalpha == 1) {
	   printf("{txt}{space 1}Alpha spending function: {res}%10s \n", methodn2name(methodmat, rhomat))
		printf("\n")
		printf("{txt}{space 1}Alpha: {res}%5.4g \n", alpha[1])
	}
	else {
		printf("{txt}{space 1}Alpha spending function:\n")
		printf("{txt}{space 4}Lower boundary: {res}%s \n", methodn2name(methodmat[1], rhomat[1]))
		printf("{txt}{space 4}Upper boundary: {res}%s \n", methodn2name(methodmat[2], rhomat[2]))		
		printf("\n")
		printf("{txt}{space 1}Alpha:\n")
		printf("{txt}{space 4}Lower boundary: {res}%5.4g \n", alpha[1])
		printf("{txt}{space 4}Upper boundary: {res}%5.4g \n", alpha[2])		
	}
	printf("\n")
	printf("{txt}{space 1}Number of interim analyses: {res}%2.0f \n", dimt)
	printf("\n")
	if (bilateral) {
		printf("{space 1}{hline 70}\n")
		printf("{txt}{space 18}boundaries \n")
		printf("{space 14}{hline 18}\n")
		printf("{space 2}i{space 5}t_i{space 5}lower{space 5}upper{space 4}alpha(t_i){space 2}alpha(t_i)-alpha(t_i-1)\n")
		printf("{space 1}{hline 70}\n")
		if (dimalpha == 1) {
			for (i = 1; i <= dimt; i++) {
				printf("{res}{space 1}%2.0f %7.4g %9.5g %9.5g %13.4g %24.4g \n", i, t[i], -cs[i], cs[i], alphat[i], diffalphat[i])
			}
		}
		else {
			for (i = 1; i <= dimt; i++) {
				printf("{res}{space 1}%2.0f %7.4g %9.5g %9.5g %13.4g %24.4g \n", i, t[i], cs[i, 1], cs[i, 2], alphat[i], diffalphat[i])
			}
		}
		printf("{space 1}{hline 70}\n")
	}
	else {
		printf("{space 1}{hline 67}\n")
		printf("{txt}{space 2}i{space 5}t_i{space 3}upper boundary{space 4}alpha(t_i){space 2}alpha(t_i)-alpha(t_i-1)\n")
		printf("{space 1}{hline 67}\n")
		for (i = 1; i <= dimt; i++) {
			printf("{res}{space 1}%2.0f %7.4g %16.5g %13.4g %24.4g \n", i, t[i], cs[i], alphat[i], diffalphat[i])
		}
		printf("{space 1}{hline 67}\n")
	}
	if (dimbeta > 0 | dimtheta > 0) {
		printf("\n{space 1}{hline 17}\n")
		if (dimbeta > 0) {
			printf("{txt}{space 2}beta{space 6}theta\n")
			printf("{space 1}{hline 17}\n")
			for (i = 1; i <= dimbeta; i++) {
				printf("{res}{space 1}%5.4g %10.5g \n", betatheta[i,1], betatheta[i,2])
			}
		}
		else {
			printf("{txt}{space 2}theta{space 6}beta\n")
			printf("{space 1}{hline 17}\n")
			for (i = 1; i <= dimtheta; i++) {
				printf("{res}{space 1}%5.4g %10.5g \n", betatheta[i,2], betatheta[i,1])
			}
		}
		printf("{space 1}{hline 17}\n")
	}
}
 
function	methodn2name(methodn, rhomat) {
   if (methodn == 1) return("O'Brien-Fleming type")
	else { 
		if (methodn == 2) return("Pocock type")
		else {
			if (methodn == 3) return(invtokens(("power family (rho ", strofreal(rhomat), ")"), ""))
		}
	}
}
end
