*!version 10May2017, Rafael Ribas

capture program drop rdcorr
program define rdcorr, rclass
	version 12
	syntax varlist(min=2 num ts) [if] [in] [aweight/], h(numlist) c(name) [ ///
        itt(varlist numeric) Time(varname numeric) nocut ///
        HETer(varname numeric ts) at(real 0) ///
		DISTance(string) ARGument(integer 2) unit(string) ///
        Deriv(integer 0) p(integer 1) Fuzzy(varname numeric ts) ///
        KERnel(string) vce(string) Matches(integer 6) ///
		control(varlist numeric fv ts)]

	local kernel = lower("`kernel'")
	local vce = lower("`vce'")
    local distance = lower("`distance'")
	
	if ("`vce'" == "") loc vce "resid"
	

    * Number of dimensions
    local dim = wordcount("`varlist'")-1

	cap qui mat list `c'
	if _rc!=0 {
		di "{err}`c' is not a matrix"
		exit 198
	}

	loc nh = wordcount("`h'")
	loc row : rownames `c'
	loc row = wordcount("`row'")
	loc col : colnames `c'
	loc col = wordcount("`col'")

	if (`row' < 2) {
        di "{err}At least two cutoffs must be specified"
        exit 198
	}
	if (`dim' < `col') {
        di "{err}More cutoffs (columns of {cmd:c()}) than running variables"
        exit 102
    }
    if (`dim' > `col') {
        di "{err}More running variables than cutoffs (columns of {cmd:c()})"
        exit 103
    }

	marksample touse
	if ("`control'" != "") {
		qui foreach v of varlist `control' {
			replace `touse'=0 if `v'==.
        }
    }
	if ("`time'" != "")  qui replace `touse'=0 if `time'==.
	if ("`itt'" != "") {
        qui foreach v of varlist `itt' {
			replace `touse'=0 if `v'==.
        }
    }
	if ("`fuzzy'" != "") qui replace `touse'=0 if `fuzzy'==.
	if ("`heter'" != "") qui replace `touse'=0 if `heter'==.

	preserve
	qui keep if `touse'

    tokenize `varlist'
	local y `1'
	local Z = trim(subinword("`varlist'","`1'","",1))
	forvalues i = 1/`dim' {
        loc z`i' = word("`Z'",`i')
    }

	forvalues i = 1/`row' {
		forvalues j = 1/`col' {
			local c`i' "`c`i'' `=`c'[`i',`j']'"
		}
	}
	
	if `nh' == 1 {
		loc ph = `h'
		forvalues i = 2/`row' {
			loc h = "`h' `ph'"
		}
	}
	else {
		if `nh'!=`row' {
			di "{err}Length of h() must be equal to number of rows in {cmd:c()}."
			exit 198
		}
	}

	* Time != {0,1}
    if ("`time'" != "") {
        tempname A
        cap qui ta `time', matrow(`A')
        if (_rc==0 & r(r)<=2) { 
            if ((`A'[1,1]!=0 & `A'[1,1]!=1) | (`A'[2,1]!=1 & `A'[2,1]!=.)) {
                di "{err}{cmd:time()} should have values 0 and 1"  
                exit 125
            }
        }
        else {
            di "{err}{cmd:time()} should have values 0 and 1"  
            exit 125
        }
    }

	* Sample weight
	tempvar wgt
	if ("`exp'"=="") { 
		g `wgt' = 1
	}
	if ("`exp'"~="") {
		qui su `exp' if `exp'>0
		qui g `wgt' = `exp'/r(mean) if `exp'>0
	}

    * If more than one dimension
    if (`dim'>1) {

        * ITT != {0,1}
        if ("`itt'" != "") {

            loc nitt = wordcount("`itt'")
            if `nitt'>1 & `nitt'!=`row' {
                di "{err}Number of variables in itt() must be equal to number of rows in {cmd:c()}."
                exit 198
            }

            tokenize `itt'
            forvalues i = 1/`nitt' {
                loc itt`i' ``i''

                loc iitn "`itt`i''"
                tempname A
                cap qui ta `itt`i'', matrow(`A')
                if (_rc==0 & r(r)<=2) { 
                    if ((`A'[1,1]!=0 & `A'[1,1]!=1) | (`A'[2,1]!=1 & `A'[2,1]!=.)) {
                        di "{err}`itt`i'' should have values 0 and 1"  
                        exit 125
                    }
                }
                else {
                    di "{err}`itt`i'' should have values 0 and 1"  
                    exit 125
                }
            }
			if `nitt'==1 {
				forvalues i = 2/`row' {
					tempvar itt`i'
					qui g `itt`i'' = `itt1'
				}
			}
        }
        else {
            forvalues i = 1/`row' {
                tempvar itt`i'
                g `itt`i'' = 1
                if ("`cut'" == "") {
                    qui forvalues j = 1/`dim' {
                        replace `itt`i'' = 0 if `c'[`i',`j']>`z`j''
                    }
                }
            }
        }
		if ("`cut'" == "") {
            forvalues i = 1/`row' {
                qui su `itt`i''
                local err = r(sd)
                if `err' == 0 {
                    di "{err}At least one cutoff not within range"
                    exit 125
                }
                forvalues j = 1/`dim' {
                    qui su `z`j''
                    local err = r(min)
                    if `err' > `c'[`i',`j'] {
                        di "{err}At least one cutoff not within range"
                        exit 125
                    }
                }
            }
        }

        * Distance function
        if "`distance'" == "" | substr("`distance'",1,4) == "maha" {
            local distance  "Mahalanobis"
        }        
        else if "`distance'" == "l2" | substr("`distance'",1,4) == "eucl" | ///
            (substr("`distance'",1,4) == "mink" & `argument'==2) {
            local distance  "Euclidean"
        }
        else if "`distance'" == "l1" | substr("`distance'",1,6) == "manhat" | ///
            substr("`distance'",1,3) == "abs" | ///
            (substr("`distance'",1,4) == "mink" & `argument'==1){
            local distance  "Absolute"
            local argument = 1
        }
        else if substr("`distance'",1,4) == "mink" & `argument'>2 {
            local distance  "L`argument'"
        }
        else if "`distance'" == "l" | substr("`distance'",1,3) == "lon" | ///
            substr("`distance'",1,3) == "lat" {
            local distance  "Latlong"
        }
        else {
            di "{err}{cmd:distance()} incorrectly specified"  
            exit 7
        }

        * Calculating distance to cutoff
        tempname H
        mat `H' = J(1,`row',0)
        loc X ""
        forvalues i = 1/`row' {
            tempvar dist`i'
            qui mdist `Z' [aw=`wgt'], c(`c`i'') gen(`dist`i'') dist(`distance') ///
                replace arg(`argument') unit(`unit') itt(`itt`i'') `cut' precalc
            local X = "`X' `dist`i''"
            mat `H'[1,`i'] = real(word("`h'",`i'))
        }
    }
    else {
        tempname H
        mat `H' = J(1,`row',0)
        loc X ""
        forvalues i = 1/`row' {
            tempvar dist`i'
            qui g `dist`i'' = `Z' - `c`i''
            local X = "`X' `dist`i''"
            mat `H'[1,`i'] = real(word("`h'",`i'))
        }
    }

	**************************** ERRORS

	if ("`p'">"8"){
	 di "{err}{cmd:p()} should be less or equal than 8 for this version of the software package"  
	 exit 125
	}

	if ("`kernel'"~="uni" & "`kernel'"~="uniform" & "`kernel'"~="tri" & ///
		"`kernel'"~="triangular" & "`kernel'"~="epa" & "`kernel'"~="epanechnikov" ///
		& "`kernel'"~="" ){
	 di "{err}{cmd:kernel()} incorrectly specified"  
	 exit 7
	}

	if ("`vce'"~="resid" & "`vce'"~="nn" & "`vce'"~=""){ 
	 di "{err}{cmd:vce()} incorrectly specified"  
	 exit 7
	}

	if (`p'<0 | `deriv'<0 | `matches'<=0){
	 di "{err}{cmd:p()}, {cmd:deriv()} and {cmd:matches()} should be positive"  
	 exit 411
	}

	if (`deriv'>`p' & `deriv'>0){
	 di "{err}{cmd:deriv()} can not be higher than {cmd:p()}"  
	 exit 125
	}


	* Data preparation
	
	tempname C C_Z C01 C_Z01
    mata {

        Y   = st_data(.,("`y' `control'"),   0)
        nk = cols(Y)
        W  = st_data(.,"`wgt'",.)
        X =  st_data(.,"`X'",.)

        nx = cols(X)
        H =  st_matrix("`H'")

		if ("`heter'"!="") {
			Hh = st_data(.,("`heter'"), 0)
			Hh = Hh :- `at'
		}

        if ("`fuzzy'"~="") {
            Z  = st_data(.,("`fuzzy'"), 0)
        }

        c = 0
        p1 = `p' + 1
		d1 = `deriv' + 1
		pp = p1
		if ("`heter'"!="") pp = p1 + d1

        if ("`time'"!="") T = st_data(.,("`time'"),0)
        else T = J(length(X),1,1)

        if ("`cut'"=="" | "`time'"=="") R = X:>=c
        else R = J(rows(X),cols(X),1)
		mR = sum(R)/length(R)
		
		if (mR<1) pp = 2*pp

		dd = d1
		for (j=2; j<=nx; j++) {
			dd = dd, (d1 + (j-1)*pp)
		}

		* If control variables

		Ye = J(rows(Y), 0, 0)
		if ("`fuzzy'"~="") Ze = J(rows(Y), 0, 0)

        if (nk>1) {		
			for (j=1; j<=nx; j++) {
			
				e_p = J(0,nk,0)
				wwh = J(0,1,0)

				if ("`fuzzy'"~="") {
					eZ_p = J(0,1,0)
				}

                for (m=0; m<=1; m++) {
                    for (n=0; n<=1; n++) {

                        X_l = select(X[,j], (T:==m):*(R[,j]:==n):==1)
                        if ("`heter'" != "") Hh_l = select(Hh, (T:==m):*(R[,j]:==n):==1)
					
                        W_l = select(W, (T:==m):*(R[,j]:==n):==1)

                        if (length(X_l)>0) {

                            w = W_l:*kweight(X_l,c,H[j],"`kernel'")

                            X_lw  = select(X_l, w:>0)

                            if ("`heter'" != "") {
                                Hh_lw = select(Hh_l, w:>0)
                            }

                            ww = select(w, w:>0)
    
                            N_lw = length(X_lw)

                            X_lwp = _Xp(X_lw,p1,c)

                            if ("`heter'" != "") {
                                X_lwp = X_lwp, X_lwp[,1::(`deriv'+1)]:*Hh_lw
                            }

                            Gamma_lp = cross(X_lwp,ww,X_lwp)
                            invGamma_lp = invsym(Gamma_lp)

                            e_lp = J(N_lw,nk,.)

                            for (k=1; k<=nk;k++) {
                                y_l = select(Y[,k], (T:==m):*(R[,j]:==n):==1)
    
                                y_lw  = select(y_l,  w:> 0)

                                hat_lp = X_lwp*(invGamma_lp*cross(X_lwp, ww, y_lw))

                                e_lp[,k] = y_lw - hat_lp
                            }

                            e_p = e_p \ e_lp
							wwh = wwh \ ww

                            if ("`fuzzy'"~="") {
                                Z_l  = select(Z, (T:==m):*(R[,j]:==n):==1)
                                Z_lw = select(Z_l,w:>0)
								hat_lp = X_lwp*(invGamma_lp*cross(X_lwp, ww, Z_lw))
								eZ_p = eZ_p \ (Z_lw - hat_lp)
							}
						}		
					}
				}

				ee_p = cross(e_p[,2::nk],wwh,e_p[,2::nk])
				eY_p = cross(e_p[,2::nk],wwh,e_p[,1])
				XB = Y[,2::nk]*invsym(ee_p)*eY_p
				Ye = Ye, Y[,1] - XB

				if ("`fuzzy'"~="") {
					eZe_p =	cross(e_p[,2::nk],wwh,eZ_p)				
					XBZ = Y[,2::nk]*invsym(ee_p)*eZe_p
					Ze = Ze, Z - XB
				}
			}
		}
		else {
			for (j=1; j<=nx; j++) {
				Ye = Ye, Y
				if ("`fuzzy'"~="") Ze = Ze, Z
			}
		}

		* Covariance

		COV = J(pp*nx,pp*nx,0)

		if ("`fuzzy'"~="") {
			COV_Z  = J(pp*nx,pp*nx,0)
			COV_ZY = J(pp*nx,pp*nx,0)
		}
		
		for (m=0; m<=1; m++) {

			Y_l = select(Ye, (T:==m):==1)
			X_l = select(X, (T:==m):==1)
			R_l = select(R, (T:==m):==1)
			W_l = select(W, (T:==m):==1)				
			if ("`heter'" != "") H_l = select(Hh, (T:==m):==1)
			if ("`fuzzy'" != "") Z_l = select(Ze, (T:==m):==1)
			N_l = rows(X_l)

			if (N_l>0) {

				w = J(N_l, 0, .)
				for (i=1; i<=nx; i++) {
					w = w, W_l:*kweight(X_l[,i],c,H[i],"`kernel'")
				}

				Y_lw  = select(Y_l, rowsum(w):>0)
				X_lw  = select(X_l, rowsum(w):>0)
				R_lw  = select(R_l, rowsum(w):>0)
				W_lw  = select(W_l, rowsum(w):>0)
				if ("`heter'" != "") H_lw  = select(H_l, rowsum(w):>0)
				if ("`fuzzy'" != "") Z_lw  = select(Z_l, rowsum(w):>0)

				w_l  = select(w, rowsum(w):>0)
				N_lw  = rows(Y_lw)

				sigma = J(N_lw, nx, 0)
				if ("`fuzzy'"~="") {
					sigmaZ = J(N_lw, nx, 0)
					sigmaZY = J(N_lw, nx, 0)
				}

				for (i=1; i<=nx; i++) {
					
					r = R_lw[,i]

					for (n=0; n<=1; n++) {
						Nr = sum(r:==n)
						if (Nr>0) {
							o = sort(order(r:==n,-1)[1::Nr],1)

							if ("`heter'"=="") {
								sigma[o,i] = rdvcew(X_lw[o,i], Y_lw[o,i], Y_lw[o,i], c, `p', H[i], `matches', "`vce'", "`kernel'",W_lw[o])
								if ("`fuzzy'"~="") {
									sigmaZ[o,i]  = rdvcew(X_lw[o,i], Z_lw[o,i], Z_lw[o,i], c, `p', H[i], `matches', "`vce'", "`kernel'",W_lw[o])
									sigmaZY[o,i] = rdvcew(X_lw[o,i], Y_lw[o,i], Z_lw[o,i], c, `p', H[i], `matches', "`vce'", "`kernel'",W_lw[o])
								}
							}
							else {
								sigma[o,i] = rdvcew2(X_lw[o,i], H_lw[o], Y_lw[o,i], Y_lw[o,i], c, `p', H[i], `deriv', `matches', "`vce'", "`kernel'",W_lw[o])
								if ("`fuzzy'"~="") {
									sigmaZ[o,i]  = rdvcew2(X_lw[o,i], H_lw[o], Z_lw[o,i], Z_lw[o,i], c, `p', H[i], `deriv', `matches', "`vce'", "`kernel'",W_lw[o])
									sigmaZY[o,i] = rdvcew2(X_lw[o,i], H_lw[o], Y_lw[o,i], Z_lw[o,i], c, `p', H[i], `deriv', `matches', "`vce'", "`kernel'",W_lw[o])
								}
							}
						}
					}
					
				}

				e = sqrt(sigma)
				Ve = variance(e)
				iVe = invsym(Ve)

				if ("`fuzzy'"~="") {
					eZ = sqrt(sigmaZ)
					VeZ = variance(eZ)
					iVeZ = invsym(VeZ)

					eZY = sqrt(sigmaZY)
					VeZY = variance(eZY)
					iVeZY = invsym(VeZY)
				}

				XX = J(0,N_lw,.)
				for (i=1; i<=nx; i++) {
				
					xx = _Xp(X_lw[,i],p1,c)

					if ("`heter'"!="") xx = xx, xx[,1::d1]:*H_lw

					if (mR<1) xx = xx:*R_lw[,i], xx

					XX = XX \ (sqrt(w_l[,i]):*xx)'
				}

				XX = XX*XX'

				iXX = invsym((iVe#J(pp,pp,1)):*XX)

				COV = COV + iXX
				
				if ("`fuzzy'"~="") {
					iXZ = invsym((iVeZ#J(pp,pp,1)):*XX)
					COV_Z = COV_Z + iXZ

					iXZY = invsym((iVeZY#J(pp,pp,1)):*XX)
					COV_ZY = COV_ZY + iXZY
				}
			}
		}

		Var = COV[dd,dd]
		dev = sqrt(invsym(diag(Var)))
		Corr = dev*Var*dev
		st_matrix("`C'", (Corr))

		if (`deriv'>0) {
			dd0 = dd :-`deriv'
			Var0 = COV[dd0,dd]
			dev0 = sqrt(invsym(diag(COV[dd0,dd0])))
			Corr0 = dev0*Var0*dev
			st_matrix("`C01'", (Corr0))
		}
		
		if ("`fuzzy'"~="") {
			Var = COV_Z[dd,dd]
			dev = sqrt(invsym(diag(Var)))
			Corr_Z = dev*Var*dev
			st_matrix("`C_Z'", (Corr_Z))
			
			if (`deriv'>0) {
				Var0 = COV_Z[dd0,dd]
				dev0 = sqrt(invsym(diag(COV[dd0,dd0])))
				Corr_Z0 = dev0*Var0*dev
				st_matrix("`C_Z01'", (Corr_Z0))
			}				
		}
	}

	restore
	
	loc Cn
	loc Cn0
	forvalues i = 1/`row' {
		loc Cn = "`Cn' tau`i'"
		if (`deriv'>0) {
			loc Cn0 = "`Cn0' t0_`i'"
		}
	}

	mat coln `C' = `Cn'
	mat rown `C' = `Cn'
	return matrix C = `C'

	if (`deriv'>0) {
		mat coln `C01' = `Cn'
		mat rown `C01' = `Cn0'
		return matrix C01 = `C01'
	}
	
	if ("`fuzzy'"~="") {
		mat coln `C_Z' = `Cn'
		mat rown `C_Z' = `Cn'
		return matrix C_Z = `C_Z'

		if (`deriv'>0) {
			mat coln `C_Z01' = `Cn'
			mat rown `C_Z01' = `Cn0'
			return matrix C_Z01 = `C_Z01'
		}
	}

	return scalar deriv = `deriv'

	mata mata clear
	
end

cap mata mata drop _Xp()
mata
	real matrix _Xp(X,p,c) {
		N = rows(X)
		Xp  = J(N, p, .)
		for (j=1; j<=p; j++) {
			Xp[.,j] = (X:-c):^(j-1)
		}
		return(Xp)
	}
end
