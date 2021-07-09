/*******************************************************************************
** (C) KEISUKE KONDO
** 
** Release Date: March 31, 2018
** Version: 1.00
** 
** [Contact]
** Email: kondo-keisuke@rieti.go.jp
** URL: https://sites.google.com/site/keisukekondokk/
*******************************************************************************/

capture program drop moransi
program moransi, sortpreserve rclass
	version 11
	syntax varlist [if] [in], /*
			*/ lat(varname) /*
			*/ lon(varname) /*
			*/ swm(string) /*
			*/ dist(real) /*
			*/ dunit(string) /*
			*/ [ /*
			*/ DMS /*
			*/ APProx /*
			*/ Detail /*
			*/ NOMATsave ]
	
	local vY `varlist'
	local swmtype = substr("`swm'",1,3)
	local unit = "`dunit'"
	marksample touse
	markout `touse' `vY' `lon' `lat'
	
	/*Check Variable*/
	if( strpos("`vY'"," ") > 0 ){
		display as error "Multiple variables are not allowed."
		exit 198
	}
	
	/*Check Latitude Range*/
	qui: sum `lat'
	local max_lat = r(max)
	local min_lat = r(min)
	if( `max_lat' < -90 | `min_lat' < -90 ){
		display as error "lat() must be within -90 to 90."
		exit 198
	}
	if( `max_lat' > 90 | `min_lat' > 90 ){
		display as error "lat() must be within -90 to 90."
		exit 198
	}
	
	/*Check Longitude Range*/
	qui: sum `lon'
	local max_lon = r(max)
	local min_lon = r(min)
	if( `max_lon' < -180 | `min_lon' < -180 ){
		display as error "lon() must be within -180 to 180."
		exit 198
	}
	if( `max_lon' > 180 | `min_lon' > 180 ){
		display as error "lon() must be within -180 to 180."
		exit 198
	}
	
	/*Check Spatial Weight Matrix*/
	if( "`swmtype'" != "bin" & "`swmtype'" != "exp" & "`swmtype'" != "pow" ){
		display as error "swm(swmtype) must be one of bin, exp, and pow."
		exit 198
	}

	/*Check Distance Decay Parameter of Spatial Weight Matrix*/
	if( "`swmtype'" == "bin" ){
		local dd = . /*not used*/
	}
	else if( "`swmtype'" == "exp" ){
		local dd = real(substr("`swm'",strpos("`swm'","exp")+length("exp")+1,.))
		if( `dd' <= 0 ){
			display as error "Distance-decay parameter must be more than 0."
			exit 198
		}
		else if( `dd' == . ){
			display as error "Numerical type is expected for distance-decay parameter."
			exit 198
		}
	}
	else if( "`swmtype'" == "pow" ){
		local dd = real(substr("`swm'",strpos("`swm'","pow")+length("pow")+1,.))
		if( `dd' <= 0 ){
			display as error "Distance-decay parameter must be more than 0."
			exit 198
		}
		else if( `dd' == . ){
			display as error "Numerical type is expected for distance-decay parameter."
			exit 198
		}
	}
	
	/*Check Parameter Range*/
	if( `dist' <= 0 ){
		display as error "dist(#) must be more than 0."
		exit 198
	}
	
	/*Check Unit of Distance*/
	if( "`unit'" != "km" & "`unit'" != "mi" ){
		display as error "dunit(unit) must be either km or mi."
		exit 198
	}

	/*DMS or Decimal*/
	local fmdms = 0
	if( "`dms'" != "" ){
		local fmdms = 1
	}
	
	/*Approximation of Distance*/
	local appdist = 0
	if( "`approx'" != "" ){
		local appdist = 1
	}
	
	/*Display Details*/
	local dispdetail= 0
	if( "`detail'" != "" ){
		local dispdetail = 1
	}
	
	/*Distance Matrix Save Option*/
	local matsave = 1
	if( "`nomatsave'" != "" ){
		local matsave = 0
	}
	
	/*Large Size Option*/
	local large = 0
	if( "`largesize'" != "" ){
		local large = 1
		local matsave = 0
		local appdist = 1
	}
	
	/*Extend Outcome Variables of Getis-Ord G*i(d) Statistic*/
	local generateallbin = 0
	if( "`genallbin'" != "" ){
		if( "`swmtype'" == "bin" ){
			local generateallbin = 1
		}
		else if( "`swmtype'" == "exp" | "`swmtype'" == "pow" ){
			display as error "genallbin option is invalid when either swm(exp #) or swm(pow #) is specified."
			exit 198
		}
	}
	
	/*Make Variables for Error Check*/
	local error1 = 0
	local error2 = 0
	local error3 = 0
	local error4 = 0
	local error5 = 0
	if( "`swmtype'" == "bin" ){
		capture confirm new variable go_z_`vY'_b, exact
		local error1 = _rc
		capture confirm new variable go_p_`vY'_b, exact
		local error2 = _rc
		if( `generateallbin' == 1 ){
			capture confirm new variable go_u_`vY'_b, exact
			local error3 = _rc
			capture confirm new variable go_e_`vY'_b, exact
			local error4 = _rc
			capture confirm new variable go_s_`vY'_b, exact
			local error5 = _rc
		}
	}
	else if( "`swmtype'" == "exp" ){
		capture confirm new variable go_z_`vY'_e, exact
		local error1 = _rc
		capture confirm new variable go_p_`vY'_e, exact
		local error2 = _rc
	} 
	else if( "`swmtype'" == "pow" ){
		capture confirm new variable go_z_`vY'_p, exact
		local error1 = _rc
		capture confirm new variable go_p_`vY'_p, exact
		local error2 = _rc
	}

	/*Error Check*/
	if( `error1' == 110 | `error2' == 110 | `error3' == 110 | `error4' == 110 | `error5' == 110 ){
		display as error "Outcome variables already exist. Change variable names."
		exit 110
	}
	
	/*+++++CALL Mata Program+++++*/
	mata: calcmoransi("`vY'", "`lon'", "`lat'", `fmdms', "`swmtype'", `dist', "`unit'", `dd', `appdist', `dispdetail', `matsave', "`touse'")
	/*+++++END Mata Program+++++*/
	
	/*Return rclass*/
	return add
	
end

version 11
mata:
void calcmoransi(vY, lon, lat, fmdms, swmtype, dist, unit, dd, appdist, dispdetail, matsave, touse)
{
	/*Make Variable*/
	if( fmdms == "1" ){
		printf("Convert DMS format to Decimal format.")
		convlonlat2decimal(lon, lat, touse, &vlon, &vlat)		
	} else {
		st_view(vlon, ., lon, touse)
		st_view(vlat, ., lat, touse)
	}
	latr = ( pi() / 180 ) * vlat; 
	lonr = ( pi() / 180 ) * vlon; 

	/*Make Variable*/
	st_view(vy, ., vY, touse)
	cN = rows(vlon)
	mW = J(cN,cN,0)
	printf("{txt}Size of spatial weight matrix:{res} %8.0f\n", cN)

	/*Make Distance Matrix using Vincenty (1975) */
	if( appdist == 1 ){
		/*Simplified Version of Vincenty Formula*/
		calcdist2(cN, latr, lonr, unit, &mW)
	} 
	else {
		/*Vincenty Formula*/
		calcdist1(cN, latr, lonr, unit, &mW)
	}

	/*Summary Statistics of Distance Matrix*/
	mD_L = lowertriangle(mW)
	vD = select(vech(mD_L), vech(mD_L):>0)
	cN_vD = rows(vD)
	dist_mean = mean(vD)
	dist_sd = sqrt(variance(vD))
	dist_min = min(vD)
	dist_max = max(vD)
	vD = .
	if( matsave == 0 ){
		mD_L = .
	}
	
	/*Spatial Weight Matrix*/
	if( swmtype == "bin" ){
		mW = ( mW :< dist )
	} 
	else if( swmtype == "exp" ){
		mW = ( mW :< dist ) :* exp( - dd :* mW ) 
	} 
	else if( swmtype == "pow" ){
		mW = ( mW :< dist ) :* ( mW:^(-dd) )
	}
	_diag(mW,0)
	mW = mW :/ rowsum( mW )

	/*Moran Scatterplot*/
	vsy = ( vy :- mean(vy) ) :/ sqrt( variance(vy) )
	vwsy = mW * vsy

	/*Moran's I from Definition*/
	dS0 = colsum( rowsum(mW) )
	dI = (cN/dS0) * (vsy'vwsy) / (vsy'vsy)

	/*Calculate Expectation and Variance of Moran's I*/
	dS1 = 0.5 * colsum( rowsum( (mW :+ mW'):^2 ) )
	dS2 = 1. * colsum( ( rowsum(mW :+ mW') ):^2 )
	dD = cN * colsum( vsy:^4 ) / (colsum(vsy:^2))^2
	dC = (cN-1)*(cN-2)*(cN-3)*dS0^2
	dB = dD * ( (cN^2-cN)*dS1 - 2*cN*dS2 + 6*dS0^2 )
	dA = cN * ( (cN^2-3*cN+3)*dS1 - cN*dS2 + 3*dS0^2 )

	/*Calculate Z-value of Moran's I*/
	dEI = - 1 / ( cN - 1 )
	dEI2 = (dA-dB) / dC
	dVI = dEI2 - (dEI)^2
	dSEI = sqrt(dVI)
	dZI = (dI-dEI) / dSEI
	dPI = 2 * ( 1 - normal(dZI) )

	/*Display Summary Statistics of Distances*/
	printf("\n")
	if( appdist == 1 ){
		if( unit == "km" ){
			printf("{txt}Distance by simplified version of Vincenty formula (unit: km)\n")
		}
		else if( unit == "mi" ){
			printf("{txt}Distance by simplified version of Vincenty formula (unit: mi)\n")
		}
	}
	else if( appdist == 0 ){
		if( unit == "km" ){
			printf("{txt}Distance by Vincenty formula (unit: km)\n")
		}
		else if( unit == "mi" ){
			printf("{txt}Distance by Vincenty formula (unit: mi)\n")
		}
	}
	if( dispdetail == 1 ){
		printf("{txt}{hline 13}{c TT}{hline 63} \n")
		printf("{txt}{space 12} {c |}{space 8}Obs.{space 8}Mean{space 9}S.D.{space 9}Min.{space 9}Max.\n")
		printf("{txt}{hline 13}{c +}{hline 63} \n")
		printf("{txt}{space 4}Distance {c |}{res}  %10.0f  %10.3f   %10.3f   %10.3f   %10.3f\n", 
					cN_vD, dist_mean, dist_sd, dist_min, dist_max )	
		printf("{txt}{hline 13}{c BT}{hline 63} \n")
		if( unit == "km" ){
			printf("{txt}Distance threshold (unit: km):{res} %10.0f\n", dist)
		}
		else if( unit == "mi" ){
			printf("{txt}Distance threshold (unit: mi):{res} %10.0f\n", dist)
		}
		printf("{txt}{hline 77}\n")
	}

	/*For Long Variable Name*/
	sVarLen2 = strlen(vY)
	if( sVarLen2 > 12 ){
		sY = substr(vY,1,10) + "~" + substr(vY,sVarLen2,1)
	}
	else{
		sY = vY
	}

	/*Results of Moran's I*/
	printf("\n")
	printf("{txt}Moran's I Statistic {space 32} Number of Obs = {res}%8.0f \n",cN)
	printf("{txt}{hline 13}{c TT}{hline 63} \n")
	printf("{txt}{space 4}Variable {c |}  Moran's I{space 9}E(I){space 8}SE(I){space 9}Z(I){space 6}p-value \n")
	printf("{hline 13}{c +}{hline 63} \n")
	printf("{txt}%12s {c |} {res}%10.5f   %10.5f   %10.5f   %10.5f   %10.5f \n", sY,dI,dEI,dSEI,dZI,dPI )
	printf("{txt}{hline 13}{c BT}{hline 63} \n")
	printf("{txt}Null Hypothesis: Spatial Randomization\n")

	/*rreturn command in Stata*/
	st_rclear()
	st_numscalar("r(dist_max)", dist_max)
	st_numscalar("r(dist_min)", dist_min)
	st_numscalar("r(dist_sd)", dist_sd)
	st_numscalar("r(dist_mean)", dist_mean)
	st_numscalar("r(dd)", dd)
	st_numscalar("r(td)", dist)
	st_numscalar("r(N)", cN)
	st_numscalar("r(pI)", dPI)
	st_numscalar("r(zI)", dZI)
	st_numscalar("r(seI)", dSEI)
	st_numscalar("r(EI)", dEI)
	st_numscalar("r(I)", dI)
	st_matrix("r(D)", mD_L)
	if( swmtype == "bin" ){
		st_global("r(swm)", "binary")
	} 
	else if( swmtype == "exp" ){
		st_global("r(swm)", "exponential")
	}
	else if( swmtype == "pow" ){
		st_global("r(swm)", "power")
	}
	if( unit == "km" ){ 
		st_global("r(dunit)", "km")
	}
	else if( unit == "mi" ){
		st_global("r(dunit)", "mi")
	}
	if( appdist == 1 ){
		st_global("r(dist_type)", "approximation")
	}
	else if( appdist == 0 ){
		st_global("r(dist_type)", "exact")
	}
	st_global("r(varname)", vY)
	st_global("r(cmd)", "moransi")
}
end

/*## MATA ## Convert DMS format to Decimal Format*/
version 11
mata:
void convlonlat2decimal(lat, lon, touse, vlat, vlon)
{
	st_view(vlat_, ., lat, touse)
	st_view(vlon_, ., lon, touse)
	(*vlat) = floor(vlat_) :+ (floor((vlat_:-floor(vlat_)):*100):/60) :+ (floor((vlat_:*100:-floor(vlat_:*100)):*100):/3600)
	(*vlon) = floor(vlon_) :+ (floor((vlon_:-floor(vlon_)):*100):/60) :+ (floor((vlon_:*100:-floor(vlon_:*100)):*100):/3600)
}
end

/*## MATA ## Vincenty Formula*/
/*Each Iteration*/
version 11
mata:
void calcdist1(cN, latr, lonr, unit, mW)
{
	/*Variables*/
	mDist = J(cN,cN,0)
	a = 6378.137
	b = 6356.752314245
	f = (a-b)/a
	eps = 1e-12
	maxIt = 100000
	itr = 0
	cItr = cN*(cN-1)/2
	
	/*Distance between i and j*/
	for( i=1; i<=cN; ++i ){
		for(j=i+1; j<=cN; ++j){
			U1 = atan( (1-f)*tan(latr[i]) )
			U2 = atan( (1-f)*tan(latr[j]) )
			L = lonr[i] - lonr[j]
			lam = L
			l1_lam = lam
			cnt = 0
			/*Iteration for Vincenty Formula*/
			do{
				numer1 = ( cos(U2)*sin(lam) )^2;
				numer2 = ( cos(U1)*sin(U2) - sin(U1)*cos(U2)*cos(lam) )^2;
				numer = sqrt( numer1 + numer2 );
				denom = sin(U1)*sin(U2) + cos(U1)*cos(U2)*cos(lam);
				sig = atan2( denom, numer );
				sinalp = (cos(U1)*cos(U2)*sin(lam)) / sin(sig);
				cos2alp = 1 - sinalp^2;
				cos2sigm = cos(sig) - ( 2*sin(U1)*sin(U2) ) / cos2alp;
				C = f/16 * cos2alp * ( 4+f*(4-3*cos2alp) );
				lam = L + (1-C)*f*sinalp*( sig+C*sin(sig)*( cos2sigm+C*cos(sig)*(-1+2*cos2sigm^2) ) );
				cri = abs( lam - l1_lam );
				l1_lam = lam;
				if( cnt++ > maxIt ){
					printf("{err}Convergence not achieved in Vincenty formula \n")
					printf("{err}region %f, \t region %f \n", i, j )
					printf("{err}Add approx option to avoid convergence error \n")
					exit(error(430))
				}
			}while( cri > eps )
			/*After Iteration*/
			u2 = cos2alp * ( (a^2-b^2)/b^2 )
			A = 1 + (u2/16384) * ( 4096 + u2*(-768+u2*(320-175*u2)) )
			B = u2/1024 * (256 + u2*(-128+u2*(74-47*u2)) )
			dsig = B*sin(sig)*( cos2sigm + 0.25*B*( cos(sig)*(-1+2*cos2sigm^2)-1/6*B*cos2sigm*(-3+4*sin(sig)^2)*(-3+4*cos2sigm) ) )
			mDist[i,j] = b*A*(sig-dsig)
			/* Display Iteration Process */
			++itr
			if( itr == 1 ){
				printf("{txt}Calculating bilateral distance...\n")
			}
			else if( itr == cItr ){
				printf("{txt}Calculating spatial weight matrix...\n")
			}
		}
	}

	/*Convert Unit of Distance*/
	if( unit == "mi" ){
		mDist = 0.621371 :* mDist
	}

	/*Return Distance Matrix*/
	mDist = mDist + mDist'
	(*mW) = mDist
}
end

/*## MATA ## Simplified Version of Vincenty Formula*/
/*Each Iteration*/
version 11
mata:
void calcdist2(cN, latr, lonr, unit, mW)
{
	/*Variables*/
	mDist = J(cN,cN,0)
	itr = 0
	cItr = cN*(cN-1)/2
	
	/*Distance between i and j*/
	for( i=1; i<=cN; ++i ){
		for(j=i+1; j<=cN; ++j){
			difflonr = abs( lonr[i] - lonr[j] )
			numer1 = ( cos(latr[j])*sin(difflonr) )^2
			numer2 = ( cos(latr[i])*sin(latr[j]) - sin(latr[i])*cos(latr[j])*cos(difflonr) )^2
			numer = sqrt( numer1 + numer2 )
			denom = sin(latr[i])*sin(latr[j]) + cos(latr[i])*cos(latr[j])*cos(difflonr)
			mDist[i,j] = 6378.137 * atan2( denom, numer )
			/* Display Iteration Process */
			++itr
			if( itr == 1 ){
				printf("{txt}Calculating bilateral distance...\n")
			}
			else if( itr == cItr ){
				printf("{txt}Calculating spatial weight matrix...\n")
			}
		}
	}

	/*Convert Unit of Distance*/
	if( unit == "mi" ){
		mDist = 0.621371 :* mDist
	}

	/*Return Distance Matrix*/
	mDist = mDist + mDist'
	(*mW) = mDist
	mDist = .
}
end
