capture mata: mata drop xtmixediou_predict()
capture mata: mata drop IOUcov()
capture mata: mata drop Browniancov()
mata:
void xtmixediou_predict(string vector idvar, string vector timevar, ///
                   string vector dependent, string vector xvars, string vector zvars, ///
			       string colvector Bestimates, string matrix varBestimates, string matrix Gestimates, ///
				   string matrix Westimates, real scalar sigmaSquared, ///
			       string vector xbvar, string vector stdpvar, string vector fittedvar)
{
	real scalar numberOfPanels, panel, ni, numberOfWparas
	real colvector id, time, timei, beta, Y, Yi, ZuplusiouBLUP, fitted, fittedi
	real colvector xb, stdp, xbi, stdpi
	real matrix X, Z, G, Wparameters, panelInfo, Xi, Zi, invVi, varbeta, oneMatrix, minMatrix, timei_s, timei_t, Wi
	pointer(function) rowvector fnarray_Rcov

	// CREATE VIEWS
	st_view(id=.,.,idvar)
	st_view(time=.,.,timevar)
	st_view(Y=.,.,dependent)
    st_view(X=.,.,tokens(xvars))
    st_view(Z=.,.,tokens(zvars))
    st_view(xb=.,.,xbvar)
    st_view(stdp=.,.,stdpvar)
    st_view(fitted=.,.,fittedvar)

	beta = st_matrix(Bestimates)
	varbeta = st_matrix(varBestimates)
	G = st_matrix(Gestimates)
	Wparameters = st_matrix(Westimates)
	numberOfWparas = cols(Wparameters)	
	
	// FUNCTION ARRAYS
	fnarray_Rcov = (&Browniancov(),&IOUcov())
	
	// SET UP THE PANEL SET-UP
	panelInfo = panelsetup(id,1)
	numberOfPanels = panelstats(panelInfo)[1]
	
	for(panel=1; panel<=numberOfPanels; panel++) {
		ni = panelInfo[panel,2] - panelInfo[panel,1] + 1
			
		Yi = panelsubmatrix(Y,panel,panelInfo)
		Xi = panelsubmatrix(X,panel,panelInfo)
		Zi = panelsubmatrix(Z,panel,panelInfo)
		timei = panelsubmatrix(time,panel,panelInfo)
		panelsubview(xbi,xb,panel,panelInfo)
		panelsubview(stdpi,stdp,panel,panelInfo)
		panelsubview(fittedi,fitted,panel,panelInfo)

		oneMatrix = J(ni,ni,1)
		minMatrix = makesymmetric(lowertriangle(timei' :* oneMatrix))
		timei_s = timei :* oneMatrix 
		timei_t = timei':* oneMatrix 
		
		// GENERATE COVARIANCE MATRIX Wi
		(*fnarray_Rcov[numberOfWparas])(Wparameters, oneMatrix, timei_s, timei_t, minMatrix, Wi=.)
		
		invVi = invsym(Zi*G*Zi' + Wi + sigmaSquared:*I(ni))
		 
		ZuplusiouBLUP = (Zi*G*Zi'+Wi)*invVi*(Yi-Xi*beta)
		
		xbi[|1,1 \ ni,1|] = Xi*beta 
		 
		stdpi[|1,1 \ ni,1|] = sqrt(diagonal(Xi*varbeta*Xi'))
		 
		// fitted = xbeta + zu + s (WHERE s IS A REALIZATION OF THE IOU OR BROWNIAN MOTION PROCESS)
		fittedi[|1,1 \ ni,1|] = xbi + ZuplusiouBLUP
		
	} // END OF panel FOR-LOOP
	
} // END OF FUNCTION xtmixediou_predict()

void IOUcov(real rowvector Wparameters, real matrix oneMatrix, real matrix timeVari_s, real matrix timeVari_t, real matrix minMatrix, real matrix Wi)
{
	real scalar aLpha, tau
	
	aLpha = Wparameters[1,1]
	tau = Wparameters[1,2]
	Wi = (tau^2)/((aLpha^3)*2):*(2*aLpha:*minMatrix + exp(-aLpha:*timeVari_s) + exp(-aLpha:*timeVari_t) - oneMatrix ///
		 - exp(-aLpha:*abs(timeVari_t-timeVari_s)))

} // END OF FUNCTION IOUcov()

void Browniancov(real rowvector Wparameters, real matrix oneMatrix, real matrix timeVari_s, real matrix timeVari_t, real matrix minMatrix, real matrix Wi)
{
	real scalar phi

	phi = Wparameters[1,1]
	Wi = phi:*minMatrix

} // END OF FUNCTION Browniancov()
end
