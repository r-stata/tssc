*! version 1.6.7 22Jul2016

// program to generate centiles of the survival distribution for stpm2 models
// this is called from stpm2_pred
// replacement of previous Newton-Raphson approach so that better compatability
// when using predictnl combined with the centile option

program define stpm2_centpred, 
	syntax newvarname [if] [in] [, centile(string) CENTOL(real 0.0000001) UPPERLIMIT(real 100) OFFSET(string) CI UNCURED LEVel(real `c(level)')]
	local newvarname `varlist'
	marksample touse, novarlist

/* Check moremata is installed */
	capture mata mata which mm_root
	if _rc >0 {
		display in yellow "You need to install the moremata additional functions to use the centile option." 
		display in yellow "These can be installed using,"
		display in yellow ". {stata ssc install moremata}"
		exit 198 
	}
	
	qui count if `touse'
	local N `r(N)'

	if r(N)==0 {
		error 2000 /* no observations */
	}
	if "`e(scale)'" == "theta" {
		local theta = exp([ln_theta][_cons])
	}
	if "`uncured'" != "" {
		tempvar pi
		predict `pi' if `touse', cure
	}
	quietly gen double `newvarname' = . if `touse'
	mata centiletime()
	if "`ci'" != ""  {
		tempvar lnln_s lnln_s_se h tp_se
		tempvar ln_cent_time s_tp		
		if "`uncured'" == "" {
			qui gen double `ln_cent_time' = ln(`newvarname') if `touse'
			if "`e(scale)'" == "hazard" {
				qui predictnl double `lnln_s' = predict(xb timevar(`newvarname') `offset') if `touse', se(`lnln_s_se')
			}
			else if "`e(scale)'" == "odds" {
				qui predictnl double `lnln_s' = ln(ln(1+exp(predict(xb timevar(`newvarname') `offset')))) if `touse', se(`lnln_s_se')
			}
			else if "`e(scale)'" == "normal" {
				qui predictnl double `lnln_s' = ln(-ln(normal(predict(xb timevar(`newvarname') `offset')))) if `touse', se(`lnln_s_se') 
			}
			else if "`e(scale)'" == "log" {
				qui predictnl double `lnln_s' = ln(-ln(1 - exp(predict(xb timevar(`newvarname') `offset')))) if `touse', se(`lnln_s_se') 
			}			
			else if "`e(scale)'" == "theta" {
				qui predictnl double `lnln_s' = ln(ln(exp(predict(xb timevar(`newvarname') `offset'))*exp(predict(xb timevar(`newvarname') `offset'))+1)/exp(xb(ln_theta))) if `touse', se(`lnln_s_se')
			}
			qui predict double `s_tp' if `touse', surv `offset' timevar(`newvarname')
			qui predict double `h' if `touse', hazard timevar(`newvarname')  
		}
		else if  "`uncured'" != "" {
			qui predictnl double `lnln_s' = ln(-(ln(predict(surv timevar(`newvarname')) - predict(cure) + 100*epsdouble()) - ln(1 - predict(cure)))) if `touse', se(`lnln_s_se') force
			qui predict  `s_tp' if `touse', surv uncured `offset' timevar(`newvarname')
			qui predict `h' if `touse', hazard uncured timevar(`newvarname')  
			
		}
		qui replace `s_tp' = ln(`s_tp') if `touse'
		qui gen double `tp_se' = -`s_tp'*`lnln_s_se'/`h' if `touse'
		qui gen double `newvarname'_lci = `newvarname' - invnormal(1-0.5*(1-`level'/100))*`tp_se' if `touse'
		qui gen double `newvarname'_uci = `newvarname' + invnormal(1-0.5*(1-`level'/100))*`tp_se' if `touse'
	}
end

	

mata:
function brentsurvcent(x, 
	real scalar lncentile, 
	string scalar scale,
	transmorphic parameters,
	real matrix options,
	string matrix tvclist,
	real matrix tvccov,
	transmorphic knots,
	real matrix Xcov,
	transmorphic Rmatrix)
{	
// extract options
	hascons = options[1]
	hastvc = options[2]
	orthog = options[3]
	offset = options[4]
	cure = options[5]
	reverse = options[6]
// covariates
	if(orthog) X = Xcov, rcsgen_core(x,asarray(knots,"baseline"),0,reverse,asarray(Rmatrix,"baseline"))
	else X = Xcov, rcsgen_core(x,asarray(knots,"baseline"),0,reverse)

	for(i=1;i<=cols(tvclist);i++) {
		if(orthog) X = X,tvccov[i]:*rcsgen_core(x,asarray(knots,tvclist[i]),0,reverse,asarray(Rmatrix,tvclist[i]))
		else X = X,tvccov[i]:*rcsgen_core(x,asarray(knots,tvclist[i]),0,reverse)
	}
	if(hascons) X = X,1

	
// return function
	if(!cure) {
		if(scale == "hazard")		return(lncentile + exp(offset + X*asarray(parameters,"beta")')) 
		else if(scale == "odds")	return(lncentile + ln(1 + exp(offset + X*asarray(parameters,"beta")'))) 
		else if(scale == "normal")	return(lncentile - lnnormal(-(offset + X*asarray(parameters,"beta")'))) 
		else if(scale == "log")		return(lncentile - ln(1 - exp(offset + X*asarray(parameters,"beta")')))
		else if(scale == "theta")	return(lncentile + 1:/asarray(parameters,"theta") :* log(asarray(parameters,"theta"):*exp(offset + X*asarray(parameters,"beta")') :+ 1)) 
	}
	else {
		return(lncentile - ln(exp(-exp((offset + X*asarray(parameters,"beta")'))) - asarray(parameters,"pi") + epsilon(100)) + ln(1 - asarray(parameters,"pi")))
	}
}

function centiletime()
{
	touse = st_local("touse")
	orthog = st_global("e(orthog)") != ""
	rcsbaseoff = st_global("e(rcsbaseoff)") != "" 
	scale = st_global("e(scale)")
	centile = st_data(.,st_local("centile"),touse)
	centol = strtoreal(st_local("centol"))
	upperlimit = strtoreal(st_local("upperlimit"))
	Nobs = strtoreal(st_local("N"))
	hascons = st_global("e(noconstant)") == "" 	
	hasoffset = st_global("e(offset1)") != ""
	hastvc = st_global("e(tvc)") != ""
	tvclist = tokens(st_global("e(tvc)"))
	hasvarlist = st_global("e(varlist)") != ""
	cure = st_local("uncured") != ""
	reverse = st_global("e(reverse)") != ""

	if(hastvc) tvccov = st_data(.,tvclist,touse)
	else tvccov = J(Nobs,0,.)
	
	if(hasoffset) offset = st_data(.,st_global("e(offset1)"),touse)
	else offset = J(Nobs,1,0)	
	parameters = asarray_create()
	options = (hascons,hastvc,orthog,.,.,.)
	Nparameters = st_numscalar("e(nxbterms)")
	asarray(parameters,"beta", st_matrix("e(b)")[1..Nparameters])
	if(scale=="theta") asarray(parameters,"theta", strtoreal(st_local("theta")))
	if(cure) pi = st_data(.,st_local("pi"),touse) 

	if(hasvarlist) {
		Xcov = st_data(.,tokens(st_global("e(varlist)")),touse)
	}
	else Xcov = J(Nobs,0,.)
	knots = asarray_create()
	if(!rcsbaseoff) {
		asarray(knots,"baseline",strtoreal(tokens(st_global("e(ln_bhknots)"))))
	}
	if(hastvc) {
		for(i=1;i<=cols(tvclist);i++) {
			asarray(knots,tvclist[i],strtoreal(tokens(st_global("e(ln_tvcknots_"+tvclist[i]+")")))) 
		}
	}
	
	Rmatrix = asarray_create()
	if(orthog & !rcsbaseoff) asarray(Rmatrix,"baseline",st_matrix("e(R_bh)"))
	else asarray(Rmatrix,"baseline","")
	if(hastvc) {
			for(i=1;i<=cols(tvclist);i++) {
				asarray(Rmatrix,tvclist[i],st_matrix("e(R_"+tvclist[i]+")"))
			}
	}
	tret = J(Nobs,1,.)
	lncentile = ln(centile)
	for(i=1;i<=Nobs;i++) {
		options[4] = offset[i]
		options[5] = cure
		options[6] = reverse
		if(cure) asarray(parameters,"pi", pi[i]) 
		tmp = mm_root(x=.,&brentsurvcent(),-100,upperlimit,centol,1000,lncentile[i],scale,parameters,options,
		tvclist,tvccov[i,],knots,Xcov[i,],Rmatrix)
		tret[i] = exp(x)
	}
	st_store(.,st_local("newvarname"),touse,tret)
}


//calculate splines with provided knots
real matrix rcsgen_core(	real colvector variable,	///
							real rowvector knots, 		///
							real scalar deriv,			///
							real scalar reverse, |		///
							real matrix rmatrix			///
						)
{
	real scalar  Nobs, Nknots, kmin, kmax, interior, Nparams
	real matrix splines, knots2

	//======================================================================================================================================//
	// Extract knot locations

		Nobs 	= rows(variable)
		Nknots 	= cols(knots)
		if(Nknots>1) {
			kmin 	= knots[1,1]
			kmax 	= knots[1,Nknots]
			if (Nknots==2) interior = 0
			else interior = Nknots - 2
			Nparams = interior + 1		
		}
		else Nparams = 1

		splines = J(Nobs,Nparams,.)
	//======================================================================================================================================//
	// Calculate splines

	if(!reverse) {
		if (Nparams>1) {
			lambda = J(Nobs,1,(kmax:-knots[,2..Nparams]):/(kmax:-kmin))
			knots2 = J(Nobs,1,knots[,2..Nparams])
		}
		
		if (deriv==0) {
			splines[,1] = variable
			if (Nparams>1) {
				splines[,2..Nparams] = (variable:-knots2):^3 :* (variable:>knots2) :- lambda:*((variable:-kmin):^3):*(variable:>kmin) :- (1:-lambda):*((variable:-kmax):^3):*(variable:>kmax) 
			}
		}
	}
	else if(reverse) {
		knotsrev = sort(knots',-1)'
		if (Nparams>1) {
			lambda = J(Nobs,1,(knotsrev[,2..Nparams]  :-kmin):/(kmax:-kmin))
			knots2 = J(Nobs,1,knotsrev[,2..Nparams])
		}

		
		if (deriv==0) {
			splines[,Nparams] = variable
			if (Nparams>1) {
				//splines[,2..Nparams] = (variable:-knots2):^3 :* (variable:>knots2) :- lambda:*((variable:-kmin):^3):*(variable:>kmin) :- (1:-lambda):*((variable:-kmax):^3):*(variable:>kmax) 
				splines[,1..(Nparams-1)] = (knots2:-variable):^3 :* (knots2:>variable) :- lambda:*((kmax:-variable):^3):*(kmax:>variable) :- (1:-lambda):*((kmin:-variable):^3):*(kmin:>variable) 
			}
		}
	}	
	
	
/*
		else if (deriv==1) {
			splines[,1] = J(Nobs,1,1)
			if (Nparams>1) {
				splines[,2..Nparams] = 3:*(variable:-knots2):^2 :* (variable:>knots2) :- lambda:*(3:*(variable:-kmin):^2):*(variable:>kmin) :- (1:-lambda):*(3:*(variable:-kmax):^2):*(variable:>kmax) 	
			}
		}
		else if (deriv==2) {
			splines[,1] = J(Nobs,1,0)
			if (Nparams>1) {
				splines[,2..Nparams] = 6:*(variable:-knots2) :* (variable:>knots2) :- lambda:*(6:*(variable:-kmin)):*(variable:>kmin) :- (1:-lambda):*(6:*(variable:-kmax)):*(variable:>kmax) 	
			}
		}
		else if (deriv==3) {
			splines[,1] = J(Nobs,1,0)
			if (Nparams>1) {
				splines[,2..Nparams] = 6:*(variable:>knots2) :- lambda:*6:*(variable:>kmin) :- (1:-lambda):*6:*(variable:>kmax)
			}
		}
*/	
		//orthog
		if (args()==5) {
			real matrix rmat
			rmat = luinv(rmatrix)
			if (deriv==0) splines = (splines,J(Nobs,1,1)) * rmat[,1..Nparams]
			else splines = splines * rmat[1..Nparams,1..Nparams]
			if(reverse) {
				sp_lastknot = J(1,Nparams,0)
				sp_lastknot[1,Nparams] = kmax
				splines = splines :- ((sp_lastknot,1)*rmat)[1,1..Nparams]
			}
			
		}
		
		return(splines)
}
end




