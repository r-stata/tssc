/***********************************************************
** (C) KEISUKE KONDO
** 
** Release Date: October 24, 2015
** Last Updated: April 22, 2017
** Version: 1.30
** 
** 
** [Contact]
** Email: kondo-keisuke@rieti.go.jp
** URL: https://sites.google.com/site/keisukekondokk/
***********************************************************/
** Version: 1.30
** Improved the program for large-sized spatial weight matrix
** Added "largesize" option
** Version: 1.22
** Bug Fix for diagonal elements of swm(bin) 
** Version: 1.21
** Improved the program for large-sized spatial weight matrix
** Added "nomatsave" option
** Version: 1.20
** Added "wvar()" option for weight variable
** Added "dunit()" option for distance unit
** Version: 1.10
** Added "nostd" option for row standardization
** 
** 

capture program drop spgen
program spgen, sortpreserve rclass
	version 11
	syntax varlist [if] [in], /*
			*/ lat(varname) /*
			*/ lon(varname) /*
			*/ swm(string) /*
			*/ dist(real) /*
			*/ dunit(string) /*
			*/ [ /*
			*/ Order(real 1) /*
			*/ WVAR(varname) /*
			*/ NOMATsave /*
			*/ NOSTD /*
			*/ DMS /*
			*/ APProx /*
			*/ DETail /*
			*/ LARGEsize ]

	/*Variables*/
	local vY `varlist'
	local swmtype = substr("`swm'",1,3)
	local unit = "`dunit'"
	marksample touse
	markout `touse' `lat' `lon' `weight'
	
	/*Check Variable*/
	if( strpos("`vY'"," ") > 0 ){
		display as error "Multiple variables are not allowed."
		exit 103
	}
	
	/*Check Latitude Range*/
	if( `lat' <= -90  | `lat' >= 90 ){
		display as error "lat() must be within -90 to 90."
		exit 198
	}
	
	/*Check Longitude Range*/
	if( `lon' <= -180  | `lon' >= 180 ){
		display as error "lon() must be within -180 to 180."
		exit 198
	}
	
	/*Check Spatial Weight Matrix*/
	if( "`swmtype'" != "bin" & "`swmtype'" != "exp" & "`swmtype'" != "pow" ){
		display as error "swm() must be one of bin, exp, and pow."
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
		display as error "dist() must be more than 0."
		exit 198
	}
	
	/*Check Unit of Distance*/
	if( "`unit'" != "km" & "`unit'" != "mi" ){
		display as error "dunit(unit) must be either km or mi."
		exit 198
	}

	/*Check Order*/
	if( `order' <= 0 ){
		display as error "order() must be more than 0."
		exit 198
	}
	capture confirm integer number `order'
	if( _rc != 0 ){
		display as error "order() must be integer."
		exit 7
	}
	
	/*Weight Variable*/
	local sweight = 0
	if( "`wvar'" != "" ){
		local sweight = 1
	}
	
	/*Distance Matrix Save Option*/
	local matsave = 1
	if( "`nomatsave'" != "" ){
		local matsave = 0
	}
	
	/*Row Standardization of Spatial Weight Matrix*/
	local rowstd = 1
	if( "`nostd'" != "" ){
		local rowstd = 0
		if( `order' != 1 ){
			display as error "order() must be 1."
			exit 198
		}
	}
	
	/*Convert DMS Format to Decimal Format*/
	local fmdms = 0
	if( "`dms'" != "" ){
		local fmdms = 1
	}
	
	/*Approximation of Distance*/
	local appdist = 0
	if( "`approx'" != "" ){
		local appdist = 1
	}
	
	/*Detail*/
	local dispdetail= 0
	if( "`detail'" != "" ){
		local dispdetail = 1
	}
	
	/*Make Variable*/
	local error1 = 0
	local error2 = 0
	if( "`swmtype'" == "bin" ){
		if( `sweight' == 1 ){
			capture confirm new variable splag`order'_`vY'_b_`wvar', exact
			local error1 = _rc
		}
		else if( `sweight' == 0 ){
			capture confirm new variable splag`order'_`vY'_b, exact
			local error1 = _rc
		}
	} 
	else if( "`swmtype'" == "exp" ){
		if( `sweight' == 1 ){
			capture confirm new variable splag`order'_`vY'_e_`wvar', exact
			local error1 = _rc
		}
		else if( `sweight' == 0 ){
			capture confirm new variable splag`order'_`vY'_e, exact
			local error1 = _rc
		}
	} 
	else if( "`swmtype'" == "pow" ){
		if( `sweight' == 1 ){
			capture confirm new variable splag`order'_`vY'_p_`wvar', exact
			local error1 = _rc
		}
		else if( `sweight' == 0 ){
			capture confirm new variable splag`order'_`vY'_p, exact
			local error1 = _rc
		}
	}
	
	/*Error Check*/
	if( `error1' == 110 ){
		display as error "Outcome variables already defined. Change variable name"
		exit 110
	}
	
	/*Large Size Option*/
	local large = 0
	if( "`largesize'" != "" ){
		local large = 1
		local matsave = 0
		local appdist = 1
		local order = 1
	}
	
	/*Call Mata Program*/
	if( `large' == 1 ){
		mata: calcsplag_large("`vY'", "`lat'", "`lon'", `fmdms', "`swmtype'", `dist', "`unit'", `dd', `order', "`wvar'", `sweight', `matsave', `rowstd', `appdist', `dispdetail', "`touse'")
	}
	else if( `large' == 0 ){
		mata: calcsplag("`vY'", "`lat'", "`lon'", `fmdms', "`swmtype'", `dist', "`unit'", `dd', `order', "`wvar'", `sweight', `matsave', `rowstd', `appdist', `dispdetail', "`touse'")
	}
	
	/*Return*/
	return add
	
	/*Label*/
	if( "`swmtype'" == "bin" ){
		if( `rowstd' == 1 ){
			if( `sweight' == 1 ){
				label var splag`order'_`vY'_b_`wvar' "sptial lag, swm(bin), td=`dist', od=`order', row-standadized, weighted"
			}
			else if( `sweight' == 0 ){
				label var splag`order'_`vY'_b "sptial lag, swm(bin), td=`dist', od=`order', row-standadized"
			}
		}
		else if( `rowstd' == 0 ){
			if( `sweight' == 1 ){
				label var splag`order'_`vY'_b_`wvar' "sptial lag, swm(bin), td=`dist', od=`order', no row-standadized, weighted"
			}
			else if( `sweight' == 0 ){
				label var splag`order'_`vY'_b "sptial lag, swm(bin), td=`dist', od=`order', no row-standadized"
			}
		}
		if( `sweight' == 1 ){
			display as txt "{bf:splag`order'_`vY'_b_`wvar'} is generated in the dataset."
		}
		else if( `sweight' == 0 ){
			display as txt "{bf:splag`order'_`vY'_b} is generated in the dataset."
		}
	} 
	else if( "`swmtype'" == "exp" ){
		if( `rowstd' == 1 ){
			if( `sweight' == 1 ){
				label var splag`order'_`vY'_e_`wvar' "sptial lag, swm(exp), td=`dist', dd=`dd', od=`order', row-standadized, weighted"
			}
			else if( `sweight' == 0 ){
				label var splag`order'_`vY'_e "sptial lag, swm(exp), td=`dist', dd=`dd', od=`order', row-standadized"
			}
		}
		else if( `rowstd' == 0 ){
			if( `sweight' == 1 ){
				label var splag`order'_`vY'_e_`wvar' "sptial lag, swm(exp), td=`dist', dd=`dd', od=`order', no row-standadized, weighted"
			}
			else if( `sweight' == 0 ){
				label var splag`order'_`vY'_e "sptial lag, swm(exp), td=`dist', dd=`dd', od=`order', no row-standadized"
			}
		}
		if( `sweight' == 1 ){
			display as txt "{bf:splag`order'_`vY'_e_`wvar'} is generated in the dataset."
		}
		else if( `sweight' == 0 ){
			display as txt "{bf:splag`order'_`vY'_e} is generated in the dataset."
		}
	} 
	else if( "`swmtype'" == "pow" ){
		if( `rowstd' == 1 ){
			if( `sweight' == 1 ){
				label var splag`order'_`vY'_p_`wvar' "sptial lag, swm(pow), td=`dist', dd=`dd', od=`order', row-standadized, weighted"
			}
			else if( `sweight' == 0 ){
				label var splag`order'_`vY'_p "sptial lag, swm(pow), td=`dist', dd=`dd', od=`order', row-standadized"
			}
		}
		else if( `rowstd' == 0 ){
			if( `sweight' == 1 ){
				label var splag`order'_`vY'_p_`wvar' "sptial lag, swm(pow), td=`dist', dd=`dd', od=`order', no row-standadized, weighted"
			}
			else if( `sweight' == 0 ){
				label var splag`order'_`vY'_p "sptial lag, swm(pow), td=`dist', dd=`dd', od=`order', no row-standadized"
			}
		}
		if( `sweight' == 1 ){
			display as txt "{bf:splag`order'_`vY'_p_`wvar'} is generated in the dataset."
		}
		else if( `sweight' == 0 ){
			display as txt "{bf:splag`order'_`vY'_p} is generated in the dataset."
		}
	} 
end


/*Calculation of Spatially Lagged Variable*/
version 11
mata:
void calcsplag(vY, lat, lon, fmdms, swmtype, dist, unit, dd, order, wvar, sweight, matsave, rowstd, appdist, dispdetail, touse)
{
	/*Check format of latitude and longitude*/
	if( fmdms == 1 ){
		printf("{txt}...Converting DMS format to decimal format\n")
		convlonlat2decimal(lat, lon, touse, &vlat, &vlon)
	} 
	else if( fmdms == 0 ){
		st_view(vlat, ., lat, touse)
		st_view(vlon, ., lon, touse)
	}
	latr = ( pi() / 180 ) * vlat; 
	lonr = ( pi() / 180 ) * vlon; 
	
	/*Make Variable*/
	st_view(vy, ., vY, touse)
	cN = rows(vlon)
	mD = J(cN,cN,0)
	printf("{txt}Size of spatial weight matrix:{res} %8.0f\n", cN)

	/*Make Weight Variable*/
	if( sweight == 1 ){
		st_view(vZ, ., wvar, touse)
	}
	
	/*Make Distance Matrix using Vincenty (1975) */
	if( appdist == 1 ){
		/*Simplified Version of Vincenty Formula*/
		/*Iteration*/
		calcdist2(cN, latr, lonr, unit, &mW)
	} 
	else if( appdist == 0 ){
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
		if( sweight == 0 ){
			mW = ( mW :< dist )
		}
		else if( sweight == 1 ){
			mW = ( mW :< dist ) :* (vZ')
			vZ = .
		}
		_diag(mW,0)
		if( rowstd == 1 ){
			mW = mW :/ rowsum(mW)
		} 
	} 
	else if( swmtype == "exp" ){
		if( sweight == 0 ){
			mW = ( mW :< dist ) :* exp( - dd :* mW ) 
		}
		else if( sweight == 1 ){
			mW = ( mW :< dist ) :* exp( - dd :* mW ) :* (vZ') 
			vZ = .
		}
		_diag(mW,0)
		if( rowstd == 1 ){
			mW = mW :/ rowsum(mW)
		} 
	} 
	else if( swmtype == "pow" ){
		if( sweight == 0 ){
			mW = ( mW :< dist ) :* mW :^(-dd)
		}
		else if( sweight == 1 ){
			mW = ( mW :< dist ) :* mW :^(-dd) :* (vZ')
			vZ = .
		}
		_diag(mW,0)
		if( rowstd == 1 ){
			mW = mW :/ rowsum(mW)
		} 
	}
	
	/*Order of Spatial Lag*/
	mW_O = I(cN)
	for(i=1; i<=order; ++i){
		mW_O = mW * mW_O
	}
	mW = .
	
	/*Spatial Lag*/
	vWY = mW_O * vy
	mW_O = .
	
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
		printf("{txt}{hline 13}{c TT}{hline 62} \n")
		printf("{txt}{space 12} {c |}        Obs.        Mean        S.D.        Min.         Max\n")
		printf("{txt}{hline 13}{c +}{hline 62} \n")
		printf("{txt}{space 4}Distance {c |}{res}  %10.0f  %10.3f  %10.3f  %10.3f  %10.3f\n", 
					cN_vD, dist_mean, dist_sd, dist_min, dist_max )	
		printf("{txt}{hline 13}{c BT}{hline 62} \n")
		if( unit == "km" ){
			printf("{txt}Distance threshold (unit: km):{res} %10.0f\n", dist)
		}
		else if( unit == "mi" ){
			printf("{txt}Distance threshold (unit: mi):{res} %10.0f\n", dist)
		}
		printf("{txt}{hline 76}\n")
	}
	
	/*Return Resutls in Mata to Stata*/
	if( swmtype == "bin" ){
		if( sweight == 1 ){
			st_store(., st_addvar("float","splag"+strofreal(order)+"_"+vY+"_b_"+wvar), st_local("touse"), vWY)
		}
		else if( sweight == 0 ){
			st_store(., st_addvar("float","splag"+strofreal(order)+"_"+vY+"_b"), st_local("touse"), vWY)
		}
	}
	if( swmtype == "exp" ){
		if( sweight == 1 ){
			st_store(., st_addvar("float","splag"+strofreal(order)+"_"+vY+"_e_"+wvar), st_local("touse"), vWY)
		}
		else if( sweight == 0 ){
			st_store(., st_addvar("float","splag"+strofreal(order)+"_"+vY+"_e"), st_local("touse"), vWY)
		}
	}
	if( swmtype == "pow" ){
		if( sweight == 1 ){
			st_store(., st_addvar("float","splag"+strofreal(order)+"_"+vY+"_p_"+wvar), st_local("touse"), vWY)
		}
		else if( sweight == 0 ){
			st_store(., st_addvar("float","splag"+strofreal(order)+"_"+vY+"_p"), st_local("touse"), vWY)
		}
	}

	/*rreturn command in Stata*/
	st_rclear()
	st_numscalar("r(dist_max)", dist_max)
	st_numscalar("r(dist_min)", dist_min)
	st_numscalar("r(dist_sd)", dist_sd)
	st_numscalar("r(dist_mean)", dist_mean)
	st_numscalar("r(od)", order)
	st_numscalar("r(dd)", dd)
	st_numscalar("r(td)", dist)
	st_numscalar("r(N)", cN)
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
	if( sweight == 1 ){
		st_global("r(weight)", wvar)
	} 
	else if( sweight == 0 ){
		st_global("r(weight)", "")
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
	if( rowstd == 1 ){
		st_global("r(swm_std)", "row-standardized")
	}
	else if( rowstd == 0 ){
		st_global("r(swm_std)", "no row-standardized")
	}
	st_global("r(varname)", vY)
	st_global("r(cmd)", "spgen")
}
end

/*Calculation of Spatially Lagged Variable for Large-Sized Data*/
version 11
mata:
void calcsplag_large(vY, lat, lon, fmdms, swmtype, dist, unit, dd, order, wvar, sweight, matsave, rowstd, appdist, dispdetail, touse)
{
	/*Check format of latitude and longitude*/
	if( fmdms == 1 ){
		printf("{txt}...Converting DMS format to decimal format\n")
		convlonlat2decimal(lat, lon, touse, &vlat, &vlon)
	} 
	else if( fmdms == 0 ){
		st_view(vlat, ., lat, touse)
		st_view(vlon, ., lon, touse)
	}
	latr = ( pi() / 180 ) * vlat; 
	lonr = ( pi() / 180 ) * vlon; 
	
	/*Make Variable*/
	st_view(vy, ., vY, touse)
	cN = rows(vlon)
	printf("{txt}Size of spatial weight matrix:{res} %8.0f\n", cN)

	/*Make Weight Variable*/
	if( sweight == 1 ){
		st_view(vZ, ., wvar, touse)
	}
	
	/*Spatial Lagged Variables*/
	printf("{txt}Calculating spatial lagged variable...\n")
	cN_vD = .
	dist_mean = .
	dist_sd = .
	dist_min = .
	dist_max = 0
	mD_L = .
	vDist = J(1,cN,0)
	vW = J(1,cN,0)
	vWY = J(cN,1,0)
	
	for( i=1; i<=cN; ++i ){
		for( j=1; j<=cN; ++j ){
			/*Distance between i and j*/
			difflonr = abs( lonr[i] - lonr[j] )
			numer1 = ( cos(latr[j])*sin(difflonr) )^2
			numer2 = ( cos(latr[i])*sin(latr[j]) - sin(latr[i])*cos(latr[j])*cos(difflonr) )^2
			numer = sqrt( numer1 + numer2 )
			denom = sin(latr[i])*sin(latr[j]) + cos(latr[i])*cos(latr[j])*cos(difflonr)
			vDist[j] = 6378.137 * atan2( denom, numer )
		}
		vDist[i] = .
		/*Convert Unit of Distance*/
		if( unit == "mi" ){
			vDist = 0.621371 :* vDist
		}
		/*Store Min and Max Distance*/
		if( min(vDist) < dist_min ){
			dist_min = min(vDist)
		}
		if( max(vDist) > dist_max ){
			dist_max = max(vDist)
		}
		/*Binary SWM*/
		if( swmtype == "bin" ){
			if( sweight == 0 ){
				vW = ( vDist :< dist )
				vW[i] = 0 
				if(rowstd == 1){
					vW = vW :/ rowsum(vW)
				}
			}
			else if( sweight == 1 ){
				vW = ( ( vDist :< dist ) :* (vZ') )
				vW[i] = 0 
				if(rowstd == 1){
					vW = vW :/ rowsum(vW)
				}
			}
		}
		/*Exponential SWM*/
		if( swmtype == "exp" ){
			if( sweight == 0 ){
				vW = ( vDist :< dist ) :* exp( - dd :* vDist )
				vW[i] = 0 
				if(rowstd == 1){
					vW = vW :/ rowsum(vW)
				}
			}
			else if( sweight == 1 ){
				vW = ( vDist :< dist ) :* exp( - dd :* vDist ) :* (vZ') 
				vW[i] = 0 
				if(rowstd == 1){
					vW = vW :/ rowsum(vW)
				}
			}
		}
		/*Power SWM*/
		if( swmtype == "pow" ){
			if( sweight == 0 ){
				vW = ( vDist :< dist ) :* vDist :^(-dd)
				vW[i] = 0 
				if(rowstd == 1){
					vW = vW :/ rowsum(vW)
				}
			}
			else if( sweight == 1 ){
				vW = ( vDist :< dist ) :* vDist :^(-dd) :* (vZ')
				vW[i] = 0 
				if(rowstd == 1){
					vW = vW :/ rowsum(vW)
				}
			}
		}
		/*Spatial Lagged Variable*/
		vWY[i] = vW * vy
		
		/* Display Iteration Process */
		if( i == 1 ){
			printf("{txt}{c TT}{hline 15}{c TT}\n")
		}
		if( i == trunc(cN/10) ){
			printf("{txt}{c |}Completed:  10%%{c |}\n")
		}
		else if( i == 2*trunc(cN/10) ){
			printf("{txt}{c |}Completed:  20%%{c |}\n")
		}
		else if( i == 3*trunc(cN/10) ){
			printf("{txt}{c |}Completed:  30%%{c |}\n")
		}
		else if( i == 4*trunc(cN/10) ){
			printf("{txt}{c |}Completed:  40%%{c |}\n")
		}
		else if( i == trunc(cN/2) ){
			printf("{txt}{c |}Completed:  50%%{c |}\n")
		}
		else if( i == trunc(cN/2) + trunc(cN/10) ){
			printf("{txt}{c |}Completed:  60%%{c |}\n")
		}
		else if( i == trunc(cN/2) + 2*trunc(cN/10) ){
			printf("{txt}{c |}Completed:  70%%{c |}\n")
		}
		else if( i == trunc(cN/2) + 3*trunc(cN/10) ){
			printf("{txt}{c |}Completed:  80%%{c |}\n")
		}
		else if( i == trunc(cN/2) + 4*trunc(cN/10) ){
			printf("{txt}{c |}Completed:  90%%{c |}\n")
		}
		else if( i == cN ){
			printf("{txt}{c |}Completed: 100%%{c |}\n")
			printf("{txt}{c BT}{hline 15}{c BT}\n")
		}
	}
	
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
		printf("{txt}{hline 13}{c TT}{hline 62} \n")
		printf("{txt}{space 12} {c |}        Obs.        Mean        S.D.        Min.         Max\n")
		printf("{txt}{hline 13}{c +}{hline 62} \n")
		printf("{txt}{space 4}Distance {c |}{res}  %10.0f  %10.3f  %10.3f  %10.3f  %10.3f\n", 
					cN_vD, dist_mean, dist_sd, dist_min, dist_max )	
		printf("{txt}{hline 13}{c BT}{hline 62} \n")
		if( unit == "km" ){
			printf("{txt}Distance threshold (unit: km):{res} %10.0f\n", dist)
		}
		else if( unit == "mi" ){
			printf("{txt}Distance threshold (unit: mi):{res} %10.0f\n", dist)
		}
		printf("{txt}{hline 76}\n")
	}
	
	/*Return Resutls in Mata to Stata*/
	if( swmtype == "bin" ){
		if( sweight == 1 ){
			st_store(., st_addvar("float","splag"+strofreal(order)+"_"+vY+"_b_"+wvar), st_local("touse"), vWY)
		}
		else if( sweight == 0 ){
			st_store(., st_addvar("float","splag"+strofreal(order)+"_"+vY+"_b"), st_local("touse"), vWY)
		}
	}
	if( swmtype == "exp" ){
		if( sweight == 1 ){
			st_store(., st_addvar("float","splag"+strofreal(order)+"_"+vY+"_e_"+wvar), st_local("touse"), vWY)
		}
		else if( sweight == 0 ){
			st_store(., st_addvar("float","splag"+strofreal(order)+"_"+vY+"_e"), st_local("touse"), vWY)
		}
	}
	if( swmtype == "pow" ){
		if( sweight == 1 ){
			st_store(., st_addvar("float","splag"+strofreal(order)+"_"+vY+"_p_"+wvar), st_local("touse"), vWY)
		}
		else if( sweight == 0 ){
			st_store(., st_addvar("float","splag"+strofreal(order)+"_"+vY+"_p"), st_local("touse"), vWY)
		}
	}

	/*rreturn command in Stata*/
	st_rclear()
	st_numscalar("r(dist_max)", dist_max)
	st_numscalar("r(dist_min)", dist_min)
	st_numscalar("r(dist_sd)", dist_sd)
	st_numscalar("r(dist_mean)", dist_mean)
	st_numscalar("r(od)", order)
	st_numscalar("r(dd)", dd)
	st_numscalar("r(td)", dist)
	st_numscalar("r(N)", cN)
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
	if( sweight == 1 ){
		st_global("r(weight)", wvar)
	} 
	else if( sweight == 0 ){
		st_global("r(weight)", "")
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
	if( rowstd == 1 ){
		st_global("r(swm_std)", "row-standardized")
	}
	else if( rowstd == 0 ){
		st_global("r(swm_std)", "no row-standardized")
	}
	st_global("r(varname)", vY)
	st_global("r(cmd)", "spgen")
}
end

/*Convert DMS format to Decimal Format*/
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

/*Vincenty Formula*/
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
	maxIt = 100
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
					printf("{err}Convergence not achieved in Vincenty formula")
					printf("{err}region %f, \t region %f", i, j )
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
	mDist = .
}
end

/*Simplified Version of Vincenty Formula*/
/*Each Iteration*/
/*For Large-Sized Matrix*/
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
