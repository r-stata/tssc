*!version 26Apr2017, Rafael Ribas

capture program drop mdrd
program define mdrd, eclass
	version 12
	syntax varlist(min=2 num ts) [if] [in] [aweight/], [ c(numlist) ///
        Deriv(integer 0) Time(varname numeric) nocut itt(varname numeric) ///
		DISTance(string) ARGument(integer 2) unit(string) p(integer 1) ///
        q(integer 0) Fuzzy(varname numeric ts) HETer(varlist numeric ts) ///
        at(numlist) control(varlist numeric fv ts) KERnel(string) ///
        h(real 0) b(real 0) rho(real 0) BWSelect(string) SCALEBw(real 1) ///		
		SCALEPar(real 1) SCALERegul(real 1) vce(string) Matches(integer 6) ///
		Level(cilevel) all NOWARNing HCoef]

	local kernel = lower("`kernel'")
	local bwselect = upper("`bwselect'")
	local vce = lower("`vce'")
    local distance = lower("`distance'")

    * Number of dimensions
    local dim = wordcount("`varlist'")-1

    if "`c'" == "" {
        forvalues i = 1/`dim' {
            local c "`c' 0"
        }
    }

    if (`dim' < wordcount("`c'")) {
        di "{err}More cutoffs than running variables"  
        exit 102
    }
    if (`dim' > wordcount("`c'")) {
        di "{err}More running variables than cutoffs"
        exit 103
    }

    * Cutoff matrix
    tempname C
    mat `C' = real(word("`c'",1))
    forvalues i = 2/`dim' {
        mat `C' = `C', real(word("`c'",`i'))
    }

	marksample touse
	if ("`control'" != "") {
		qui foreach v of varlist `control' {
			replace `touse'=0 if `v'==.
        }
    }
	if ("`time'" != "")  qui replace `touse'=0 if `time'==.
	if ("`itt'" != "") 	 qui replace `touse'=0 if `itt'==.
	if ("`fuzzy'" != "") qui replace `touse'=0 if `fuzzy'==.
	if ("`heter'" != "") {
		qui foreach v of varlist `heter' {
			replace `touse'=0 if `v'==.
        }
    }

	preserve
	qui keep if `touse'

    qui count
    loc T = r(N)
    if `T'==0 {
        di "{err}no observations"  
        exit 2000
    }


    tokenize `varlist'
	local y `1'

    local X
    forvalues i = 1/`dim' {
        local j = `i' + 1
        local x`i' ``j''
        local X "`X' `x`i''"
    }
    local X = trim("`X'")

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

			loc iitn "`itt'"
            tempname A
            cap qui ta `itt', matrow(`A')
            if (_rc==0 & r(r)<=2) { 
                if ((`A'[1,1]!=0 & `A'[1,1]!=1) | (`A'[2,1]!=1 & `A'[2,1]!=.)) {
                    di "{err}{cmd:itt()} should have values 0 and 1"  
                    exit 125
                }
            }
            else {
                di "{err}{cmd:itt()} should have values 0 and 1"  
                exit 125
            }
        }
        else {
            tempvar itt
            g `itt' = 1
			if ("`cut'" == "") {
				qui forvalues i = 1/`dim' {
					replace `itt' = 0 if `x`i''<`C'[1,`i']
				}
			}
		}
		if ("`cut'" == "") {
			qui su `itt'
			local err = r(sd)
			if `err' == 0 {
				di "{err}At least one cutoff not within range"
				exit 125
			}
			forvalues i = 1/`dim' {
				qui su `x`i''
				local err = r(min)
				if `err' > `C'[1,`i'] {
					di "{err}At least one cutoff not within range"
					exit 125
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
        tempvar x
        mdist `X' [aw=`wgt'], gen(`x') c(`c') dist(`distance') ///
            arg(`argument') unit(`unit') itt(`itt') `cut' precalc

        local c = 0
    }
    else {
        local c = `C'[1,1]
        local x `x1'
    }

	* Values per period

	tempvar x_l0 x_r0 x_l1 x_r1

    if ("`time'"!="") {
        if ("`cut'"=="") {
            qui gen `x_l0' = `x' if `x'<`c' & `time'==0
            qui gen `x_r0' = `x' if `x'>=`c' & `time'==0

            qui gen `x_l1' = `x' if `x'<`c' & `time'==1
            qui gen `x_r1' = `x' if `x'>=`c' & `time'==1
        }
        else {
            qui gen `x_r0' = `x' if `time'==0
            qui gen `x_r1' = `x' if `time'==1
        }
    }
    else {
        qui gen `x_l1' = `x' if `x'<`c'
        qui gen `x_r1' = `x' if `x'>=`c'
    }

	qui su `x'
	local x_min = r(min)
	local x_max = r(max)
    
	qui su `x_r1'
	local N_r1 = r(N)
	local range_r1 = abs(r(max)-r(min))

    local N_r0 = `N_r1'
    local N_l0 = `N_r1'
    local N_l1 = `N_r1'
    local range_r0 = `range_r1'
    local range_l0 = `range_r1'
    local range_l1 = `range_r1'

    if ("`time'"!="") {
        qui su `x_r0' 
        local N_r0 = r(N)
        local range_r0 = abs(r(max)-r(min))

        if ("`cut'"=="") {
            qui su `x_l0'
            local N_l0 = r(N)
            local range_l0 = abs(r(max)-r(min))
        }
    }
    if ("`time'"=="" | "`cut'"=="") {
        qui su `x_l1'
        local N_l1 = r(N)
        local range_l1 = abs(r(max)-r(min))
    }

    local range = min(`range_r0',`range_l0',`range_r1',`range_l1')

	* Heterogeneity at at()
	if ("`heter'" != "") {

        loc hdim = wordcount("`heter'")
        if "`at'" == "" {
            forvalues i = 1/`hdim' {
                local at "`at' 0"
            }
        }
        if (`hdim' < wordcount("`at'")) {
            di "{err}More points in {command}at() {err}than {inp:{it:hetervars}}"
            exit 102
        }
        if (`hdim' > wordcount("`at'")) {
            di "{err}Less points in {command}at() {err}than {inp:{it:hetervars}}"
            exit 103
        }

        * Points matrix
        tempname AT
        mat `AT' = real(word("`at'",1))
		if `hdim' > 1 {
			forvalues i = 2/`hdim' {
				mat `AT' = `AT', real(word("`at'",`i'))
			}
		}
        forvalues i = 1/`hdim' {
            tempname h`i'
			loc hh = word("`heter'",`i')
            g `h`i'' = `hh'
            qui su `h`i''
            loc h_min = r(min)
            loc h_max = r(max)
            loc h_sd = r(sd)
            loc hsd`i' = max((`h_min' - `AT'[1,`i']), max(0,(`AT'[1,`i']- `h_max')))/`h_sd'
        }
	}
	else loc hdim = 0

	if (`deriv'>0 & `p'==1 & `q'==0) local p = `deriv'+1
	if (`q'==0)						 local q = `p'+1

	local p1 = `p' + 1
	local q1 = `q' + 1


	**************************** ERRORS

	if (`c'!=. & (`c'<=`x_min' | `c'>=`x_max') & "`cut'"=="") {
	 di "{err}{cmd:c()} should be set within the range of `x'"  
	 exit 125
	}
	
	if (`N_l0'<10 | `N_r0'<10 | `N_l1'<10 | `N_r1'<10){
	 di "{err}Not enough observations to perform calculations"  
	 exit 2001
	}

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

	if ("`bwselect'"~="CCT" & "`bwselect'"~="IK" & "`bwselect'"~=""){
	 di "{err}{cmd:bwselect()} incorrectly specified"  
	 exit 7
	}

	if ("`vce'"~="resid" & "`vce'"~="nn" & "`vce'"~=""){ 
	 di "{err}{cmd:vce()} incorrectly specified"  
	 exit 7
	}

	if (`p'<0 | `q'<=0 | `deriv'<0 | `matches'<=0 | `scaleregul'<0){
	 di "{err}{cmd:p()}, {cmd:q()}, {cmd:deriv()}, {cmd:matches()} and {cmd:scaleregul()} should be positive"  
	 exit 411
	}
		
	if (`p'>=`q' & `q'>0){
	 di "{err}{cmd:q()} should be higher than {cmd:p()}"  
	 exit 125
	}
	
	if (`deriv'>`p' & `deriv'>0 ){
	 di "{err}{cmd:deriv()} can not be higher than {cmd:p()}"  
	 exit 125
	}
	
	if (`scalebw'<=0) {
	 di "{err}{cmd:scalebw()}should be greater than 0"  
	 exit 125
	 }

	if (`rho'>1 | `rho'<0){
	 di "{err}{cmd:rho()}should be set between 0 and 1"  
	 exit 125
	}

	if `h'>0  local bwselect = "Manual"

	local use_rho = 0
		
	if (`h'==0 & `b'==0 & `rho'>0) local use_rho = 1
	if (`h'>0 & `b'==0 & `rho'==0) local b = `h'
	
	disp in yellow "Preparing data." 


	* Select bandwidth (add controls!)
	
	if ("`h'"=="0" & "`bwselect'"=="IK") {
		disp in ye "Computing bandwidth selectors."
		qui ddbwsel `y' `x' [aw=`wgt'], time(`time') `cut' c(`c') deriv(`deriv') ///
			p(`p') q(`q') bwselect(`bwselect') rho(`rho') kernel(`kernel') vce(`vce') ///
			precalc scaleregul(`scaleregul') control(`control') heter(`heter') at(`at') ///
			nowarn
		local h = `scalebw'*e(h_IK)
		local b = `scalebw'*e(b_IK)
	}
	else if "`h'"=="0" {
		disp in ye "Computing bandwidth selectors."
		local bwselect "CCT"
		qui ddbwsel `y' `x' [aw=`wgt'], time(`time') `cut' c(`c') deriv(`deriv') ///
			p(`p') q(`q') matches(`matches') bwselect(`bwselect') rho(`rho') ///
			kernel(`kernel') vce(`vce') precalc scaleregul(`scaleregul') ///
			heter(`heter') at(`at') control(`control') nowarn
		local h = `scalebw'*e(h_CCT)
		local b = `scalebw'*e(b_CCT)
	}

	if (`use_rho'==1 & `rho'>0) {
		local b = `h'/`rho'
	}

	if (`h'>0 & `rho'>0) {
		local b = `h'/`rho'
	}
	
	if ("`kernel'"=="epanechnikov" | "`kernel'"=="epa") {
		local kernel_type = "Epanechnikov"
	}
	else if ("`kernel'"=="uniform" | "`kernel'"=="uni") {
		local kernel_type = "Uniform"
	}
	else  {
		local kernel_type = "Triangular"
	}

	
	* Data preparation
	
	mata {
        Y   = st_data(.,("`y' `control'"),   0)
        nk = cols(Y)

        X   = st_data(.,("`x'"),   0)
        W   = st_data(.,("`wgt'"), 0)

		if ("`heter'"!="") {
			H = st_data(.,("`heter'"), 0)
            At = st_matrix("`AT'")
			H = H :- At
		}

        if ("`fuzzy'"~="") {
            Z  = st_data(.,("`fuzzy'"), 0)
        }

        c = `c'
        p1 = `p' + 1
        q1 = `q' + 1

        if ("`time'"!="") T = st_data(.,("`time'"),0)
        else T = J(length(X),1,1)

        if ("`cut'"=="" | "`time'"=="") R = X:>=c
        else R = J(length(X),1,1)

        factor_p = J(p1, 1, .);	factor_q = J(q1, 1, .)
        Hp_vec = J(p1, 1, .)
		
        for (j=1; j<=q1; j++) {
		    factor_q[j] = factorial(j-1)

			if (j<=p1) {
				factor_p[j] = factorial(j-1)
				Hp_vec[j] = `h'^(-(j-1))
			}
		}
		if ("`heter'"!="") {
            for (i=1; i<=`hdim'; i++) {
                factor_p = factor_p \ factor_p[1::(`deriv'+1)]
                factor_q = factor_q \ factor_q[1::(`deriv'+1)]
                Hp_vec = Hp_vec \ Hp_vec[1::(`deriv'+1)]
            }
		}

        Hp = diag(Hp_vec)


		* If control variables

        if (nk>1) {
		
			display("Orthogonalizing w.r.t. control variables.")
		
            e_p = J(0,nk,0);     e_q = J(0,nk,0)
            Yh = J(0,nk,0);      Yb = J(0,nk,0)
            whh = J(0,1,0);      wbb = J(0,1,0)

			if ("`fuzzy'"~="") {
				eZ_p = J(0,1,0)
				eZ_q = J(0,1,0)
				Zh = J(0,1,0)
				Zb = J(0,1,0)
			}

			for (m=0; m<=1; m++) {
				for (n=0; n<=1; n++) {

					X_l = select(X, (T:==m):*(R:==n):==1)
					if ("`heter'" != "") H_l = select(H, (T:==m):*(R:==n):==1)
					
					W_l = select(W, (T:==m):*(R:==n):==1)

					if (length(X_l)>0) {

						wh_l = W_l:*kweight(X_l,`c',`h',"`kernel'")
						wb_l = W_l:*kweight(X_l,`c',`b',"`kernel'")

						Xh_l  = select(X_l,  wh_l:> 0)
						Xb_l  = select(X_l,  wb_l:> 0)

						if ("`heter'" != "") {
							Hh_l = select(H_l, wh_l:> 0)
							Hb_l = select(H_l, wb_l:> 0)
						}

						whh_l = select(wh_l, wh_l:> 0)
						wbb_l = select(wb_l, wb_l:> 0)
    
						Nh_l = length(Xh_l);	Nb_l = length(Xb_l)
						Xh_lp = J(Nh_l,p1,.)
						Xb_lq = J(Nb_l,q1,.)

						for (j=1; j<=q1; j++)  {
							if (j<=p1) {
								Xh_lp[.,j] = (Xh_l:-c):^(j-1)
							}
							Xb_lq[.,j] = (Xb_l:-c):^(j-1)
						}
						if ("`heter'" != "") {
                            for (i=1; i<=`hdim'; i++) {
                                Xh_lp = Xh_lp, Xh_lp[,1::(`deriv'+1)]:*Hh_l[,i]
                                Xb_lq = Xb_lq, Xb_lq[,1::(`deriv'+1)]:*Hb_l[,i]
                            }
						}
	
						if (Nh_l<5 | Nb_l<5) {
							display("{err}Not enough observations to perform calculations")
							exit(1)
						}

						Gammah_lp = cross(Xh_lp,whh_l,Xh_lp); Gammab_lq = cross(Xb_lq,wbb_l,Xb_lq)
						invGammah_lp = invsym(Gammah_lp); invGammab_lq = invsym(Gammab_lq)

						e_lp = J(Nh_l,nk,.); e_lq = J(Nb_l,nk,.)
						Yh_l = J(Nh_l,nk,.); Yb_l = J(Nb_l,nk,.)

						for (k=1; k<=nk;k++) {
							y_l = select(Y[,k], (T:==m):*(R:==n):==1)
    
							yh_l  = select(y_l,  wh_l:> 0)
							yb_l  = select(y_l,  wb_l:> 0)

							hat_lp = Xh_lp*(invGammah_lp*cross(Xh_lp, whh_l, yh_l))
							hat_lq = Xb_lq*(invGammab_lq*cross(Xb_lq, wbb_l, yb_l))

							e_lp[,k] = yh_l - hat_lp
							e_lq[,k] = yb_l - hat_lq

							Yh_l[,k] = yh_l
							Yb_l[,k] = yb_l
						}

						e_p = e_p \ e_lp
						e_q = e_q \ e_lq
						whh = whh \ whh_l
						wbb = wbb \ wbb_l
						Yh = Yh \ Yh_l
						Yb = Yb \ Yb_l

						if ("`fuzzy'"~="") {
							Z_l  = select(Z, (T:==m):*(R:==n):==1)
    
							Zh_l = select(Z_l,wh_l:>0)
							Zb_l = select(Z_l,wb_l:>0)

							hat_lp = Xh_lp*(invGammah_lp*cross(Xh_lp, whh_l, Zh_l))
							hat_lq = Xb_lq*(invGammab_lq*cross(Xb_lq, wbb_l, Zb_l))
    
							eZ_p = eZ_p \ (Zh_l - hat_lp)
							eZ_q = eZ_q \ (Zb_l - hat_lq)
							Zh = Zh \ Zh_l
							Zb = Zb \ Zb_l
						}
					}
				}
			}

			ee_p = cross(e_p[,2::nk],whh,e_p[,2::nk])
			eY_p = cross(e_p[,2::nk],whh,e_p[,1])
            XB_p = Yh[,2::nk]*invsym(ee_p)*eY_p

			ee_q = cross(e_q[,2::nk],wbb,e_q[,2::nk])
			eY_q = cross(e_q[,2::nk],wbb,e_q[,1])
            XB_q = Yb[,2::nk]*invsym(ee_q)*eY_q

            Yp = Yh[,1] - XB_p; Yq = Yb[,1] - XB_q

			if ("`fuzzy'"~="") {
				eZe_p =	cross(e_p[,2::nk],whh,eZ_p)
				eZe_q = cross(e_q[,2::nk],wbb,eZ_q)
				
				XG_p = Yh[,2::nk]*invsym(ee_p)*eZe_p
                XG_q = Yb[,2::nk]*invsym(ee_q)*eZe_q
    
                Zp = Zh - XG_p; Zq = Zb - XG_q
			}
        }


		* Estimating Yhat per sample

		display("Calculating predicted outcome per sample.")

		Nh0 = 0
		Nb0 = 0

		tau_cl_t = J(0,1,0)
		tau_bc_t = J(0,1,0)
		V_cl_t = J(0,1,0)
		V_rb_t = J(0,1,0)
		
		if ("`fuzzy'"~="") {
			tau_Z_cl_t = J(0,1,0)
			tau_Z_bc_t = J(0,1,0)
			V_Z_cl_t = J(0,1,0)
			V_Z_rb_t = J(0,1,0)
			V_ZY_t = J(0,1,0)
			Cov_t = J(0,1,0)
			Cov_ZY_t = J(0,1,0)
			Cov_Z_t = J(0,1,0)
			V_cl_tq = J(0,1,0)
			V_Z_cl_tq = J(0,1,0)
			V_ZY_cl_tq = J(0,1,0)
		}
		if ("`heter'"!="" & "`hcoef'"!="") {
			coef_t = J(0,`hdim',0)
			Vcoef_t = J(`hdim',`hdim',0)

			if ("`fuzzy'"~="") {
				coef_Z_t = J(0,`hdim',0)
				Vcoef_Z_t = J(`hdim',`hdim',0)
				Vcoef_ZY_t = J(`hdim',`hdim',0)
				VcoefZ_Y_t = J(1,`hdim',0)
				Vcoef_Yd_t = J(1,`hdim',0)
				Vcoef_Zd_t = J(1,`hdim',0)
			}
		}

		for (m=0; m<=1; m++) {
			for (n=0; n<=1; n++) {

				Y_l = select(Y[,1], (T:==m):*(R:==n):==1)
				X_l = select(X, (T:==m):*(R:==n):==1)
				W_l = select(W, (T:==m):*(R:==n):==1)
				N_l = length(X_l)

				if ("`heter'" != "") H_l = select(H, (T:==m):*(R:==n):==1)
				
				if (N_l>0) {
        
					wh_l = W_l:*kweight(X_l,`c',`h',"`kernel'")
					wb_l = W_l:*kweight(X_l,`c',`b',"`kernel'")
					
					uh_l = (X_l:-c)/`h'
					uhh_l=select(uh_l, wh_l:> 0)
	
					Xh_l  = select(X_l,  wh_l:> 0)
					Xb_l  = select(X_l,  wb_l:> 0)

					if ("`heter'" != "") {
						Hh_l = select(H_l, wh_l:> 0)
						Hb_l = select(H_l, wb_l:> 0)
					}
					
					whh_l = select(wh_l, wh_l:> 0)
					wbb_l = select(wb_l, wb_l:> 0)
		
					Wh_l  = select(W_l,  wh_l:> 0)
					Wb_l  = select(W_l,  wb_l:> 0)
		
					Nh_l = length(Xh_l);	Nb_l = length(Xb_l)
					X_lp  = J(N_l,	p1,	.)
					X_lq  = J(N_l,	q1,	.)
					Xh_lp = J(Nh_l,	p1,	.)
					Xb_lq = J(Nb_l,	q1,	.)
		
					for (j=1; j<=q1; j++)  {
						if (j<=p1) {
							X_lp[.,j]  = (X_l:-c):^(j-1)
							Xh_lp[.,j] = (Xh_l:-c):^(j-1)
						}
						X_lq[.,j]  = (X_l:-c):^(j-1)
						Xb_lq[.,j] = (Xb_l:-c):^(j-1)
					}
					if ("`heter'" != "") {
                        for (i=1; i<=`hdim'; i++) {
                            X_lp  = X_lp, X_lp[,1::(`deriv'+1)]:*H_l[,i]
                            X_lq  = X_lq, X_lq[,1::(`deriv'+1)]:*H_l[,i]
                            Xh_lp = Xh_lp, Xh_lp[,1::(`deriv'+1)]:*Hh_l[,i]
                            Xb_lq = Xb_lq, Xb_lq[,1::(`deriv'+1)]:*Hb_l[,i]
                        }
					}
		
					tth = "Nh" + strofreal(m) + strofreal(n)
					ttb = "Nb" + strofreal(m) + strofreal(n)
					st_numscalar(tth, Nh_l[1,1])
					st_numscalar(ttb, Nb_l[1,1])
	
					if (Nh_l<5 | Nb_l<5) {
						display("{err}Not enough observations to perform calculations")
						exit(1)
					}

					Gamma_lp = cross(X_lp,wh_l,X_lp); Gamma_lq = cross(X_lq,wb_l,X_lq)
					Gammah_lp = cross(Xh_lp,whh_l,Xh_lp); Gammab_lq = cross(Xb_lq,wbb_l,Xb_lq)
	  
					invGamma_lp  = invsym(Gamma_lp)
					invGamma_lq  = invsym(Gamma_lq)
					invGammah_lp = invsym(Gammah_lp)
					invGammab_lq = invsym(Gammab_lq)

					Yh_l = select(Y_l,  wh_l:> 0)
					Yb_l = select(Y_l,  wb_l:> 0)
	
					if (nk>1) {    
						Yh_l = Yp[(1+Nh0)::(Nh_l+Nh0),]
						Yb_l = Yq[(1+Nb0)::(Nb_l+Nb0),]
					}
		
					if ("`fuzzy'"~="") {
						Z_l  = select(Z, (T:==m):*(R:==n):==1)
						Zh_l = select(Z_l,wh_l:>0)
						Zb_l = select(Z_l,wb_l:>0)
		
						if (nk>1) {
							Zh_l = Zp[(1+Nh0)::(Nh_l+Nh0),]
							Zb_l = Zq[(1+Nb0)::(Nb_l+Nb0),]
						}
					}
					Nh0 = Nh0 + Nh_l
					Nb0 = Nb0 + Nb_l

					if ("`heter'"=="") {
						sigmah_l = rdvcew(Xh_l, Yh_l, Yh_l, c, `p', `h', `matches', "`vce'", "`kernel'",Wh_l)
						sigmab_l = rdvcew(Xb_l, Yb_l, Yb_l, c, `p', `h', `matches', "`vce'", "`kernel'",Wb_l)
					}
					else {
						sigmah_l = rdvcew2(Xh_l, Hh_l, Yh_l, Yh_l, c, `p', `h', `deriv', `matches', "`vce'", "`kernel'",Wh_l)
						sigmab_l = rdvcew2(Xb_l, Hb_l, Yb_l, Yb_l, c, `p', `h', `deriv', `matches', "`vce'", "`kernel'",Wb_l)
					}

					Psih_lp = cross(Xh_lp, whh_l:*sigmah_l:*whh_l, Xh_lp)
					Psib_lq = cross(Xb_lq, wbb_l:*sigmab_l:*wbb_l, Xb_lq)
		
					tau_lp = factor_p:*(invGammah_lp*cross(Xh_lp, whh_l, Yh_l))
					tau_lq = factor_q:*(invGammab_lq*cross(Xb_lq, wbb_l, Yb_l))
		
					V_lp = invGammah_lp*Psih_lp*invGammah_lp
					V_lq = invGammab_lq*Psib_lq*invGammab_lq
			
					if (`b'>=`h'){
						whb_l = select(wh_l,wb_l:>0)
						Xb_lp = select(X_lp,wb_l:>0)
						Psi_lpq = cross(Xb_lp,whb_l:*sigmab_l:*wbb_l,Xb_lq)
					}
					else {
						wbh_l = select(wb_l,wh_l:>0)
						Xh_lq = select(X_lq,wh_l:>0)
						Psi_lpq = cross(Xh_lp,whh_l:*sigmah_l:*wbh_l,Xh_lq)
					}
	
					Cov_l = invGamma_lp*Psi_lpq*invGamma_lq

					v_lp = (Xh_lp:*whh_l)'*(uhh_l:^(`p'+1))
		
					BiasConst_lp = factorial(`deriv')*invsym(Hp)*invGamma_lp*v_lp 
	
					tau_l_cl = tau_lp[`deriv'+1,1]
					tau_l_bc = tau_lp[`deriv'+1,1] - (tau_lq[`p'+2,1]*BiasConst_lp[`deriv'+1,1])*(`h'^(`p'+1-`deriv')/factorial(`p'+1))
	
					V_l_cl = factorial(`deriv')^2*V_lp[`deriv'+1,`deriv'+1] 
					V_l_rb = factorial(`deriv')^2*V_lp[`deriv'+1,`deriv'+1] + factorial(`p'+1)^2*V_lq[`p'+2,`p'+2]*(BiasConst_lp[`deriv'+1]*`h'^(`p'+1-`deriv')/factorial(`p'+1))^2 - 2*factorial(`deriv')*factorial(`p'+1)*Cov_l[`deriv'+1,`p'+2]*(BiasConst_lp[`deriv'+1]*`h'^(`p'+1-`deriv')/factorial(`p'+1))
					
					tau_cl_t = tau_cl_t \ tau_l_cl
					tau_bc_t = tau_bc_t \ tau_l_bc
					V_cl_t = V_cl_t \ V_l_cl
					V_rb_t = V_rb_t \ V_l_rb

					if ("`fuzzy'"~="") {
			
						*********** First Stage ***************
						tau_Z_lp = factor_p:*(invGammah_lp*cross(Xh_lp, whh_l, Zh_l))
						tau_Z_lq = factor_q:*(invGammab_lq*cross(Xb_lq, wbb_l, Zb_l))

						if ("`heter'"=="") {
							sigmah_Z_l = rdvcew(Xh_l, Zh_l, Zh_l, c, `p', `h', `matches', "`vce'", "`kernel'",Wh_l)
							sigmab_Z_l = rdvcew(Xb_l, Zb_l, Zb_l, c, `p', `h', `matches', "`vce'", "`kernel'",Wb_l)
						}
						else {
							sigmah_Z_l = rdvcew2(Xh_l, Hh_l, Zh_l, Zh_l, c, `p', `h', `deriv', `matches', "`vce'", "`kernel'",Wh_l)
							sigmab_Z_l = rdvcew2(Xb_l, Hb_l, Zb_l, Zb_l, c, `p', `h', `deriv', `matches', "`vce'", "`kernel'",Wb_l)
						}

						Psih_Z_lp = cross(Xh_lp, whh_l:*sigmah_Z_l:*whh_l, Xh_lp)
						Psib_Z_lq = cross(Xb_lq, wbb_l:*sigmab_Z_l:*wbb_l, Xb_lq)
						
						if (`b'>=`h') {
							Psi_Z_lpq = cross(Xb_lp,whb_l:*sigmab_Z_l:*wbb_l,Xb_lq);    
						}
						else {
							Psi_Z_lpq = cross(Xh_lp,whh_l:*sigmah_Z_l:*wbh_l,Xh_lq);    
						} 
				
						V_Z_lp = invGammah_lp*Psih_Z_lp*invGammah_lp
						V_Z_lq = invGammab_lq*Psib_Z_lq*invGammab_lq
			
						Cov_Z_l = invGamma_lp*Psi_Z_lpq*invGamma_lq
			
						tau_Z_l_cl = tau_Z_lp[`deriv'+1,1]
						tau_Z_l_bc = tau_Z_lp[`deriv'+1,1] - (tau_Z_lq[`p'+2,1]*BiasConst_lp[`deriv'+1,1])*(`h'^(`p'+1-`deriv')/factorial(`p'+1))
						
						V_Z_l_cl = factorial(`deriv')^2*V_Z_lp[`deriv'+1,`deriv'+1]
						V_Z_l_rb = V_Z_l_cl + factorial(`p'+1)^2*V_Z_lq[`p'+2,`p'+2]*(BiasConst_lp[`deriv'+1]*`h'^(`p'+1-`deriv')/factorial(`p'+1))^2 - 2*factorial(`deriv')*factorial(`p'+1)*Cov_Z_l[`deriv'+1,`p'+2]*(BiasConst_lp[`deriv'+1]*`h'^(`p'+1-`deriv')/factorial(`p'+1))
						
						tau_Z_cl_t = tau_Z_cl_t \ tau_Z_l_cl
						tau_Z_bc_t = tau_Z_bc_t \ tau_Z_l_bc

						V_Z_cl_t = V_Z_cl_t \ V_Z_l_cl
						V_Z_rb_t = V_Z_rb_t \ V_Z_l_rb


						****************** Second Stage
						if ("`heter'"=="") {
							sigmah_ZY_l = rdvcew(Xh_l, Yh_l, Zh_l, c, `p', `h', `matches', "`vce'", "`kernel'",Wh_l)
							sigmab_ZY_l = rdvcew(Xb_l, Yb_l, Zb_l, c, `p', `h', `matches', "`vce'", "`kernel'",Wb_l)
						}
						else {
							sigmah_ZY_l = rdvcew2(Xh_l, Hh_l, Yh_l, Zh_l, c, `p', `h', `deriv', `matches', "`vce'", "`kernel'",Wh_l)
							sigmab_ZY_l = rdvcew2(Xb_l, Hb_l, Yb_l, Zb_l, c, `p', `h', `deriv', `matches', "`vce'", "`kernel'",Wb_l)
						}
						
						Psih_ZY_lp = cross(Xh_lp, whh_l:*sigmah_ZY_l:*whh_l, Xh_lp)
						Psib_ZY_lq = cross(Xb_lq, wbb_l:*sigmab_ZY_l:*wbb_l, Xb_lq)
						
						if (`b'>=`h'){
							Psi_ZY_lpq = cross(Xb_lp,whb_l:*sigmab_ZY_l:*wbb_l,Xb_lq);    
						}
						else {
							Psi_ZY_lpq = cross(Xh_lp,whh_l:*sigmah_ZY_l:*wbh_l,Xh_lq);    
						} 
						
						Cov_ZY_l = invGamma_lp*Psi_ZY_lpq*invGamma_lq
								
						V_ZY_lp = invGammah_lp*Psih_ZY_lp*invGammah_lp
						V_ZY_lq = invGammab_lq*Psib_ZY_lq*invGammab_lq
			
						V_cl_lq    = factorial(`p'+1)^2*V_lq[`p'+2,`p'+2]
						V_Z_cl_lq  = factorial(`p'+1)^2*V_Z_lq[`p'+2,`p'+2]
						V_ZY_cl_lq = factorial(`p'+1)^2*V_ZY_lq[`p'+2,`p'+2]

						V_ZY_l_cl = factorial(`deriv')^2*V_ZY_lp[`deriv'+1,`deriv'+1]
						V_ZY_t = V_ZY_t \ V_ZY_l_cl

						Cov_t = Cov_t \ (Cov_l[`deriv'+1,`p'+2]*BiasConst_lp[`deriv'+1])
						Cov_ZY_t = Cov_ZY_t \ (Cov_ZY_l[`deriv'+1,`p'+2]*BiasConst_lp[`deriv'+1])
						Cov_Z_t = Cov_Z_t \ (Cov_Z_l[`deriv'+1,`p'+2]*BiasConst_lp[`deriv'+1])

						V_cl_tq    = V_cl_tq \ (V_cl_lq*BiasConst_lp[`deriv'+1]^2)
						V_Z_cl_tq  = V_Z_cl_tq \ (V_Z_cl_lq*BiasConst_lp[`deriv'+1]^2)
						V_ZY_cl_tq = V_ZY_cl_tq \ (V_ZY_cl_lq*BiasConst_lp[`deriv'+1]^2)
					}			

					if ("`heter'"!="" & "`hcoef'"!="") {
						s = (`deriv' + 1)*(1::`hdim'):+p1
						coef_t = coef_t \ tau_lp[s,1]'

						Vcoef_t = Vcoef_t + factorial(`deriv')^2*V_lp[s,s]

						if ("`fuzzy'"~="") {
							coef_Z_t = coef_Z_t \ tau_Z_lp[s,1]'

							Vcoef_Z_t = Vcoef_Z_t + factorial(`deriv')^2*V_Z_lp[s,s]
							Vcoef_ZY_t = Vcoef_ZY_t + factorial(`deriv')^2*V_ZY_lp[s,s]
							VcoefZ_Y_t = VcoefZ_Y_t + factorial(`deriv')^2*V_ZY_lp[`deriv'+1,s]
							Vcoef_Yd_t = Vcoef_Yd_t + V_lp[`deriv'+1,s]
							Vcoef_Zd_t = Vcoef_Zd_t + V_Z_lp[`deriv'+1,s]
						}
					}
				}
			}
		}
        
		if ("`cut'"=="" & "`time'"!="") {
			tau_cl = `scalepar'*(tau_cl_t[4,] - tau_cl_t[3,] - tau_cl_t[2,] + tau_cl_t[1,])
			tau_bc = `scalepar'*(tau_bc_t[4,] - tau_bc_t[3,] - tau_bc_t[2,] + tau_bc_t[1,])

			if ("`fuzzy'"~="") {
				tau_Z_cl = tau_Z_cl_t[4,] - tau_Z_cl_t[3,] - tau_Z_cl_t[2,] + tau_Z_cl_t[1,]
				tau_Z_bc = tau_Z_bc_t[4,] - tau_Z_bc_t[3,] - tau_Z_bc_t[2,] + tau_Z_bc_t[1,]
			}
			if ("`heter'"!="" & "`hcoef'"!="") {
				hcoef = coef_t[4,] - coef_t[3,] - coef_t[2,] + coef_t[1,]

				if ("`fuzzy'"~="") {
					hcoef_Z = coef_Z_t[4,] - coef_Z_t[3,] - coef_Z_t[2,] + coef_Z_t[1,]
					hcoef_F = (hcoef/tau_Z_cl) - (hcoef_Z*tau_cl/(tau_Z_cl^2))
				}
			}
		}
		else {
			tau_cl = `scalepar'*(tau_cl_t[2,] - tau_cl_t[1,])
			tau_bc = `scalepar'*(tau_bc_t[2,] - tau_bc_t[1,])

			if ("`fuzzy'"~="") {
				tau_Z_cl = tau_Z_cl_t[2,] - tau_Z_cl_t[1,]
				tau_Z_bc = tau_Z_bc_t[2,] - tau_Z_bc_t[1,]
			}
			if ("`heter'"!="" & "`hcoef'"!="") {
				hcoef = coef_t[2,] - coef_t[1,]

				if ("`fuzzy'"~="") {
					hcoef_Z = coef_Z_t[2,] - coef_Z_t[1,]
					hcoef_F = (hcoef/tau_Z_cl) - (hcoef_Z*tau_cl/(tau_Z_cl^2))
				}
			}

		}
		
		V_cl   = `scalepar'^2*(sum(V_cl_t))
		V_rb   = `scalepar'^2*(sum(V_rb_t))

		if ("`fuzzy'"~="") {

			tau_F_cl = tau_cl/tau_Z_cl
			tau_F_bc = tau_bc/tau_Z_bc

			V_Z_cl   = sum(V_Z_cl_t)
			V_Z_rb   = sum(V_Z_rb_t)

			V_ZY_cl = `scalepar'*sum(V_ZY_t)
			V_F_cl  = (1/tau_Z_cl^2)*V_cl + (tau_cl^2/tau_Z_cl^4)*V_Z_cl -(2*tau_cl/tau_Z_cl^3)*V_ZY_cl

			C_F_pq    = `scalepar'^2*(factorial(`deriv')*factorial(`p'+1)):*((1/tau_Z_cl^2):*Cov_t - (2*`scalepar'*tau_cl/tau_Z_cl^3):*Cov_ZY_t + (tau_cl^2/tau_Z_cl^4):*Cov_Z_t)
			V_F_rb_t2 = -2*(sum(C_F_pq))*`h'^(`p'+1-`deriv')/factorial(`p'+1)

            V_F_cl_q  = `scalepar'^2*(1/tau_Z_cl^2):*V_cl_tq + (tau_cl^2/tau_Z_cl^4):*V_Z_cl_tq - (2*`scalepar'*tau_cl/tau_Z_cl^3):*V_ZY_cl_tq
            V_F_rb_t3 = sum(V_F_cl_q)*(`h'^(`p'+1-`deriv')/factorial(`p'+1))^2

			V_F_rb = V_F_cl + V_F_rb_t2 + V_F_rb_t3
		}

		if ("`heter'"!="" & "`hcoef'"!="") {

			Vhcoef = Vcoef_t

			if ("`fuzzy'"~="") {
				Vhcoef_Z = Vcoef_Z_t

				VcF_t1 = V_cl*(hcoef_Z:^2)/(tau_Z_cl^4)
				VcF_t2 = V_Z_cl*((2:*hcoef_Z:*tau_cl :- tau_Z_cl:*hcoef):^2)/(tau_Z_cl^6)
				VcF_t3 = diagonal(Vhcoef/(tau_Z_cl^2))'
				VcF_t4 = diagonal(Vhcoef_Z*(tau_cl^2)/(tau_Z_cl^4))'
				VcF_t5 = -2*V_ZY_cl*hcoef_Z:*(2*tau_cl*hcoef_Z - tau_Z_cl*hcoef)/(tau_Z_cl^6)
				VcF_t6 = -2*diagonal(tau_cl*Vcoef_ZY_t/(tau_Z_cl^3))'
				VcF_t7 = -2*hcoef_Z:*Vcoef_Zd_t/(tau_Z_l_cl^3)
				VcF_t8 = 2*tau_cl*(tau_Z_cl*hcoef - 2*tau_cl*hcoef_Z):*Vcoef_Zd_t/(tau_Z_cl^5)
				VcF_t9 = 2*(3*tau_cl*hcoef_Z - tau_Z_cl*hcoef):*VcoefZ_Y_t/(tau_Z_cl^4)

				Vhcoef_F = VcF_t1 :+ VcF_t2 :+ VcF_t3 :+ VcF_t4 :+ VcF_t5 :+ VcF_t6 :+ VcF_t7 :+ VcF_t8 :+ VcF_t9
			}
		}

		* Exporting results
		
        quant = -invnormal(abs((1-(`level'/100))/2))
        se_cl = sqrt(V_cl)
        se_rb = sqrt(V_rb)
        t_cl =  tau_cl/se_cl;t_bc =  tau_bc/se_cl;t_rb =  tau_bc/se_rb

        if ("`time'"=="") {
			st_numscalar("mu_y_r_cl", tau_cl_t[2,]) 
			st_numscalar("mu_y_l_cl", tau_cl_t[1,])
			st_numscalar("mu_y_r_bc", tau_bc_t[2,])
			st_numscalar("mu_y_l_bc", tau_bc_t[1,])
		}
        else if ("`time'"!="" & "`cut'"=="") {
			st_numscalar("mu_y_r0_cl", tau_cl_t[2,]); st_numscalar("mu_y_r1_cl", tau_cl_t[4,])
			st_numscalar("mu_y_l0_cl", tau_cl_t[1,]); st_numscalar("mu_y_l1_cl", tau_cl_t[3,])
			st_numscalar("mu_y_r0_bc", tau_bc_t[2,]); st_numscalar("mu_y_r1_bc", tau_bc_t[4,])
			st_numscalar("mu_y_l0_bc", tau_bc_t[1,]); st_numscalar("mu_y_l1_bc", tau_bc_t[3,])
		}
        else {
			st_numscalar("mu_y_1_cl", tau_cl_t[2,]) 
			st_numscalar("mu_y_0_cl", tau_cl_t[1,])
			st_numscalar("mu_y_1_bc", tau_bc_t[2,])
			st_numscalar("mu_y_0_bc", tau_bc_t[1,])
		}

        st_numscalar("tau_cl", tau_cl)
        st_numscalar("tau_bc", tau_bc)
        st_numscalar("se_cl", sqrt(V_cl))
        st_numscalar("se_rb", sqrt(V_rb))
        st_numscalar("t_cl", tau_cl/se_cl)
        st_numscalar("t_bc", tau_bc/se_cl)
        st_numscalar("t_rb", tau_bc/se_rb)
        st_numscalar("quant", -invnormal(abs((1-(`level'/100))/2)))
        st_numscalar("ci_l_cl", tau_cl[1,1] - quant*se_cl)
        st_numscalar("ci_r_cl", tau_cl[1,1] + quant*se_cl)
        st_numscalar("ci_l_bc", tau_bc[1,1] - quant*se_cl)
        st_numscalar("ci_r_bc", tau_bc[1,1] + quant*se_cl)
        st_numscalar("ci_l_rb", tau_bc[1,1] - quant*se_rb)
        st_numscalar("ci_r_rb", tau_bc[1,1] + quant*se_rb)
        st_numscalar("pv_cl", 2*normal(-abs(t_cl)))
        st_numscalar("pv_bc", 2*normal(-abs(t_bc)))
        st_numscalar("pv_rb", 2*normal(-abs(t_rb)))
        st_matrix("b", (tau_bc))
        st_matrix("V", (V_rb))
	
        if ("`all'"~="") {
            st_matrix("b", (tau_cl,tau_bc,tau_bc))
            st_matrix("V", (V_cl,0,0 \ 0,V_cl,0 \0,0,V_rb))
        }

		if ("`heter'"!="" & "`hcoef'"!="") {
			st_matrix("hcoef", hcoef)
			st_matrix("Vhcoef", Vhcoef)
		}

        if ("`fuzzy'"~="") {

			if ("`time'"=="") {
				st_numscalar("mu_Z_r_cl", tau_Z_cl_t[2,]) 
				st_numscalar("mu_Z_l_cl", tau_Z_cl_t[1,])
				st_numscalar("mu_Z_r_bc", tau_Z_bc_t[2,])
				st_numscalar("mu_Z_l_bc", tau_Z_bc_t[1,])
			}
			else if ("`time'"!="" & "`cut'"=="") {
				st_numscalar("mu_Z_r0_cl", tau_Z_cl_t[2,]); st_numscalar("mu_Z_r1_cl", tau_Z_cl_t[4,])
				st_numscalar("mu_Z_l0_cl", tau_Z_cl_t[1,]); st_numscalar("mu_Z_l1_cl", tau_Z_cl_t[3,])
				st_numscalar("mu_Z_r0_bc", tau_Z_bc_t[2,]); st_numscalar("mu_Z_r1_bc", tau_Z_bc_t[4,])
				st_numscalar("mu_Z_l0_bc", tau_Z_bc_t[1,]); st_numscalar("mu_Z_l1_bc", tau_Z_bc_t[3,])
			}
			else {
				st_numscalar("mu_Z_1_cl", tau_Z_cl_t[2,]) 
				st_numscalar("mu_Z_0_cl", tau_Z_cl_t[1,])
				st_numscalar("mu_Z_1_bc", tau_Z_bc_t[2,])
				st_numscalar("mu_Z_0_bc", tau_Z_bc_t[1,])
			}
        
            st_numscalar("tau_Z_cl", tau_Z_cl)
            st_numscalar("tau_Z_bc", tau_Z_bc)
            se_Z_cl = sqrt(V_Z_cl);se_Z_rb = sqrt(V_Z_rb)
            t_Z_cl =  tau_Z_cl/se_Z_cl;t_Z_bc =  tau_Z_bc/se_Z_cl;t_Z_rb =  tau_Z_bc/se_Z_rb
            st_numscalar("se_Z_cl", se_Z_cl)
            st_numscalar("se_Z_rb", se_Z_rb)
            st_numscalar("t_Z_cl", tau_Z_cl/se_Z_cl);
            st_numscalar("t_Z_bc", tau_Z_bc/se_Z_cl);st_numscalar("t_Z_rb", tau_Z_bc/se_Z_rb);
            st_numscalar("ci_Z_l_cl", tau_Z_cl - quant*se_Z_cl)
            st_numscalar("ci_Z_r_cl", tau_Z_cl + quant*se_Z_cl);st_numscalar("ci_Z_l_bc", tau_Z_bc - quant*se_Z_cl)
            st_numscalar("ci_Z_r_bc", tau_Z_bc + quant*se_Z_cl);st_numscalar("ci_Z_l_rb", tau_Z_bc - quant*se_Z_rb)
            st_numscalar("ci_Z_r_rb", tau_Z_bc + quant*se_Z_rb);
            st_numscalar("t_Z_cl",  tau_Z_cl/se_Z_cl);st_numscalar("t_Z_bc",  tau_Z_bc/se_Z_cl);st_numscalar("t_Z_rb",  tau_Z_bc/se_Z_rb)
            st_numscalar("pv_Z_cl", 2*normal(-abs(t_Z_cl)));st_numscalar("pv_Z_bc", 2*normal(-abs(t_Z_bc)));st_numscalar("pv_Z_rb", 2*normal(-abs(t_Z_rb)))
        
            se_F_cl = sqrt(V_F_cl)
            se_F_rb = sqrt(V_F_rb)
            t_F_cl =  tau_F_cl/se_F_cl
            t_F_bc =  tau_F_bc/se_F_cl
            t_F_rb =  tau_F_bc/se_F_rb
            
            st_numscalar("tau_F_cl", tau_F_cl[1,1])
            st_numscalar("tau_F_bc", tau_F_bc[1,1])
            st_numscalar("se_F_cl", se_F_cl)
            st_numscalar("se_F_rb", se_F_rb)
            st_numscalar("t_F_cl", tau_F_cl/se_F_cl)
            st_numscalar("t_F_bc", tau_F_bc/se_F_cl)
            st_numscalar("t_F_rb", tau_F_bc/se_F_rb)
            st_numscalar("ci_F_l_cl", tau_F_cl[1,1] - quant*se_F_cl)
            st_numscalar("ci_F_r_cl", tau_F_cl[1,1] + quant*se_F_cl)
            st_numscalar("ci_F_l_bc", tau_F_bc[1,1] - quant*se_F_cl)
            st_numscalar("ci_F_r_bc", tau_F_bc[1,1] + quant*se_F_cl)
            st_numscalar("ci_F_l_rb", tau_F_bc[1,1] - quant*se_F_rb)
            st_numscalar("ci_F_r_rb", tau_F_bc[1,1] + quant*se_F_rb)
            st_numscalar("pv_F_cl", 2*normal(-abs(t_F_cl)))
            st_numscalar("pv_F_bc", 2*normal(-abs(t_F_bc)))
            st_numscalar("pv_F_rb", 2*normal(-abs(t_F_rb)))
            
            st_matrix("b", (tau_F_bc))
            st_matrix("V", (V_F_rb))

			if ("`heter'"!="" & "`hcoef'"!="") {
				st_matrix("hcoef_Z", hcoef_Z)
				st_matrix("Vhcoef_Z", Vhcoef_Z)
				st_matrix("hcoef_F", hcoef_F)
				st_matrix("Vhcoef_F", Vhcoef_F)
			}
        
            if ("`all'"~="") {
                st_matrix("b", (tau_F_cl,tau_F_bc,tau_F_bc))
                st_matrix("V", (V_F_cl,0,0 \ 0,V_F_cl,0 \0,0,V_F_rb))
            }
        }

        display("Estimation completed.")
	}

	************************************************
	********* OUTPUT TABLE *************************
	************************************************
	local alpha = `h'/`b'
	loc cr = string(`c',"%7.0g")

	disp ""
	if ("`deriv'"=="0") disp "Estimates using local polynomial regression." 
	else disp "Estimates using local polynomial regression. Derivative of order " `deriv' "."

	disp ""
    if ("`time'"=="") {
        disp in smcl in gr "{ralign 21: Cutoff c = `cr'}"     _col(22) " {c |} " _col(24) in gr %10s "Left of c"   _col(36) in gr %11s "Right of c" _col(61) in gr "Number of obs = "  in yellow %10.0f (`N_r0'+`N_l1')
        if ("`vce'" == "resid") disp in smcl in gr "{hline 22}{c +}{hline 23}"                                                                      _col(61) in gr "vce           = "  in yellow "{ralign 10:residual}" 
        else 					disp in smcl in gr "{hline 22}{c +}{hline 23}"                                                                      _col(61) in gr "NN matches    = "  in yellow %10.0f `matches'
		disp in smcl in gr "{ralign 21:Number of obs}"        _col(22) " {c |} " _col(24) as result %10.0f Nh10    _col(36) %11.0f  Nh11            _col(61) in gr "BW type       = "  in yellow "{ralign 10:`bwselect'}" 
        disp in smcl in gr "{ralign 21:Order loc. poly. (p)}" _col(22) " {c |} " _col(24) as result %10.0f `p'     _col(36) %11.0f  `p'             _col(61) in gr "Kernel type   = "  in yellow "{ralign 10:`kernel_type'}" 
        disp in smcl in gr "{ralign 21:Order bias (q)}"       _col(22) " {c |} " _col(24) as result %10.0f `q'     _col(36) %11.0f  `q'                               
        disp in smcl in gr "{ralign 21:BW loc. poly. (h)}"    _col(22) " {c |} " _col(27) as result %8.0g `h'      _col(39) %8.0g   `h' 
        disp in smcl in gr "{ralign 21:BW bias (b)}"          _col(22) " {c |} " _col(27) as result %8.0g `b'      _col(39) %8.0g   `b'
        disp in smcl in gr "{ralign 21:rho (h/b)}"            _col(22) " {c |} " _col(24) as result %10.3f `alpha' _col(36) %11.3f  `alpha'
    
        sca Nhm = min(Nh10,Nh11)
        sca Nbm = min(Nh10,Nh11)
    }
    if ("`time'"!="" & "`cut'"!="") {
        disp in smcl in gr "{ralign 21: Reference c = `cr'}"   _col(22) " {c |} " _col(24) in gr %10s "Time 0"     _col(36) in gr %11s "Time 1"     _col(61) in gr "Number of obs = "  in yellow %10.0f (`N_r0'+`N_l1')
        if ("`vce'" == "resid") disp in smcl in gr "{hline 22}{c +}{hline 23}"                                                                      _col(61) in gr "vce           = "  in yellow "{ralign 10:residual}" 
        else 					disp in smcl in gr "{hline 22}{c +}{hline 23}"                                                                      _col(61) in gr "NN matches    = "  in yellow %10.0f `matches'
        disp in smcl in gr "{ralign 21:Number of obs}"        _col(22) " {c |} " _col(24) as result %10.0f Nh01    _col(36) %11.0f  Nh11              _col(61) in gr "BW type       = "  in yellow "{ralign 10:`bwselect'}" 
        disp in smcl in gr "{ralign 21:Order loc. poly. (p)}" _col(22) " {c |} " _col(24) as result %10.0f `p'     _col(36) %11.0f  `p'               _col(61) in gr "Kernel type   = "  in yellow "{ralign 10:`kernel_type'}" 
        disp in smcl in gr "{ralign 21:Order bias (q)}"       _col(22) " {c |} " _col(24) as result %10.0f `q'     _col(36) %11.0f  `q'                               
        disp in smcl in gr "{ralign 21:BW loc. poly. (h)}"    _col(22) " {c |} " _col(27) as result %8.0g `h'      _col(39) %8.0g  `h' 
        disp in smcl in gr "{ralign 21:BW bias (b)}"          _col(22) " {c |} " _col(27) as result %8.0g `b'      _col(39) %8.0g  `b'
        disp in smcl in gr "{ralign 21:rho (h/b)}"            _col(22) " {c |} " _col(24) as result %10.3f `alpha' _col(36) %11.3f  `alpha'

        sca Nhm = min(Nh01,Nh11)
        sca Nbm = min(Nb01,Nb11)
    }
    if ("`time'"!="" & "`cut'"=="") {
        disp in smcl in gr "{ralign 21: Cutoff c = `cr'}"   _col(22) " {c |} " _col(24) in gr %10s "Left of c" _col(36) in gr %11s "Right of c"     _col(61) in gr "Number of obs = "  in yellow %10.0f (`N_r0'+`N_l1')
        if ("`vce'" == "resid") disp in smcl in gr "{hline 22}{c +}{hline 23}"                                                                      _col(61) in gr "vce           = "  in yellow "{ralign 10:residual}" 
        else 					disp in smcl in gr "{hline 22}{c +}{hline 23}"                                                                      _col(61) in gr "NN matches    = "  in yellow %10.0f `matches'
        disp in smcl in gr "{ralign 21:Number of obs, t = 0}" _col(22) " {c |} " _col(24) as result %10.0f Nh00    _col(36) %11.0f  Nh01              _col(61) in gr "BW type       = "  in yellow "{ralign 10:`bwselect'}" 
        disp in smcl in gr "{ralign 21:Number of obs, t = 1}" _col(22) " {c |} " _col(24) as result %10.0f Nh10    _col(36) %11.0f  Nh11              _col(61) in gr "Kernel type   = "  in yellow "{ralign 10:`kernel_type'}" 
        disp in smcl in gr "{ralign 21:Order loc. poly. (p)}" _col(22) " {c |} " _col(24) as result %10.0f `p'     _col(36) %11.0f  `p' 
        disp in smcl in gr "{ralign 21:Order bias (q)}"       _col(22) " {c |} " _col(24) as result %10.0f `q'     _col(36) %11.0f  `q'                               
        disp in smcl in gr "{ralign 21:BW loc. poly. (h)}"    _col(22) " {c |} " _col(27) as result %8.0g `h'     _col(39) %8.0g  `h' 
        disp in smcl in gr "{ralign 21:BW bias (b)}"          _col(22) " {c |} " _col(27) as result %8.0g `b'     _col(39) %8.0g  `b'
        disp in smcl in gr "{ralign 21:rho (h/b)}"            _col(22) " {c |} " _col(24) as result %10.3f `alpha' _col(36) %11.3f  `alpha'

        sca Nhm = min(Nh00,Nh01,Nh10,Nh11)
        sca Nbm = min(Nb00,Nb01,Nb10,Nb11)
    }


	if ("`fuzzy'"=="" & "`all'"=="") {
		disp ""
		disp "Outcome: `y'. Running Variable: `X'."
		disp in smcl in gr "{hline 22}{c TT}{hline 63}"
		disp in smcl in gr "{ralign 21:Method}"            _col(22) " {c |} " _col(26) %9s "Coef."         _col(38) %9s "Std. Err."     _col(48) %6s "z"        _col(55) %8s "P>|z|"    _col(65) %22s `"[`level'% Conf. Interval]"' _n  "{hline 22}{c +}{hline 63}"
		disp in smcl in gr "{ralign 21:Conventional}"      _col(22) " {c |} " _col(26) in ye %9.0g tau_cl  _col(37) %9.0g se_cl         _col(48) %7.2f t_cl     _col(55) %8.3f  pv_cl   _col(66) %9.0g ci_l_cl _col(78) %9.0g ci_r_cl 
		disp in smcl in gr "{ralign 21:Robust}"            _col(22) " {c |} " _col(26) in ye %9.0g tau_bc  _col(37) %9.0g se_rb         _col(48) %7.2f t_rb     _col(55) %8.3f  pv_rb   _col(66) %9.0g ci_l_rb _col(78) %9.0g ci_r_rb
		disp in smcl in gr "{hline 22}{c BT}{hline 63}"
	}
	else if ("`all'"=="") {
		disp ""
		disp "Structural Estimates. Outcome: `y'. Running variable: `X'. Treatment: `fuzzy'."
		disp in smcl in gr "{hline 22}{c TT}{hline 63}"
		disp in smcl in gr "{ralign 21:Method}"            _col(22) " {c |} " _col(26) %9s "Coef."          _col(38) %9s "Std. Err."    _col(48) %6s "z"        _col(55) %8s "P>|z|"    _col(65) %22s `"[`level'% Conf. Interval]"' _n  "{hline 22}{c +}{hline 63}"
		disp in smcl in gr "{ralign 21:Conventional}"      _col(22) " {c |} " _col(26) in ye %9.0g tau_F_cl _col(37) %9.0g se_F_cl      _col(48) %7.2f t_F_cl   _col(55) %8.3f  pv_F_cl _col(66) %9.0g  ci_F_l_cl _col(78) %9.0g ci_F_r_cl 
		disp in smcl in gr "{ralign 21:Robust}"            _col(22) " {c |} " _col(26) in ye %9.0g tau_F_bc _col(37) %9.0g se_F_rb      _col(48) %7.2f t_F_rb   _col(55) %8.3f  pv_F_rb _col(66) %9.0g  ci_F_l_rb _col(78) %9.0g ci_F_r_rb   
		disp in smcl in gr "{hline 22}{c BT}{hline 63}"

		disp ""
		disp in yellow "First-Stage Estimates. Outcome: `fuzzy'. Running variable: `X'."
		disp in smcl in gr "{hline 22}{c TT}{hline 63}"
		disp in smcl in gr "{ralign 21:Method}"            _col(22) " {c |} " _col(26) %9s "Coef."          _col(38) %9s "Std. Err."    _col(48) %6s "z"        _col(55) %8s "P>|z|"    _col(65) %22s `"[`level'% Conf. Interval]"' _n  "{hline 22}{c +}{hline 63}"
		disp in smcl in gr "{ralign 21:Conventional}"      _col(22) " {c |} " _col(26) in ye %9.0g tau_Z_cl _col(37) %9.0g se_Z_cl      _col(48) %7.2f t_Z_cl   _col(55) %8.3f  pv_Z_cl _col(66) %9.0g  ci_Z_l_cl _col(78) %9.0g ci_Z_r_cl 
		disp in smcl in gr "{ralign 21:Robust}"            _col(22) " {c |} " _col(26) in ye %9.0g tau_Z_bc _col(37) %9.0g se_Z_rb      _col(48) %7.2f t_Z_rb   _col(55) %8.3f  pv_Z_rb _col(66) %9.0g  ci_Z_l_rb _col(78) %9.0g ci_Z_r_rb
		disp in smcl in gr "{hline 22}{c BT}{hline 63}"
	}

	if ("`all'"~="" & "`fuzzy'"=="") {
		disp ""
		disp "Outcome: `y'. Running Variable: `X'."
		disp in smcl in gr "{hline 22}{c TT}{hline 63}"
		disp in smcl in gr "{ralign 21:Method}"         _col(22) " {c |} " _col(26) %9s "Coef."             _col(38) %9s "Std. Err."    _col(48) %6s "z"        _col(55) %8s "P>|z|"    _col(65) %22s `"[`level'% Conf. Interval]"' _n  "{hline 22}{c +}{hline 63}"
		disp in smcl in gr "{ralign 21:Conventional}"   _col(22) " {c |} " _col(26) in ye %9.0g tau_cl      _col(37) %9.0g se_cl        _col(48) %7.2f t_cl     _col(55) %8.3f  pv_cl   _col(66) %9.0g  ci_l_cl _col(78) %9.0g ci_r_cl  
		disp in smcl in gr "{ralign 21:Bias-corrected}" _col(22) " {c |} " _col(26) in ye %9.0g tau_bc      _col(37) %9.0g se_cl        _col(48) %7.2f t_bc     _col(55) %8.3f  pv_bc   _col(66) %9.0g  ci_l_bc _col(78) %9.0g ci_r_bc  
		disp in smcl in gr "{ralign 21:Robust}"         _col(22) " {c |} " _col(26) in ye %9.0g tau_bc      _col(37) %9.0g se_rb        _col(48) %7.2f t_rb     _col(55) %8.3f  pv_rb   _col(66) %9.0g  ci_l_rb _col(78) %9.0g ci_r_rb  
		disp in smcl in gr "{hline 22}{c BT}{hline 63}"
	}

	if ("`all'"~="" & "`fuzzy'"~="") {
		disp ""
		disp "Structural Estimates. Outcome: `y'. Running variable: `X'. Treatment: `fuzzy'."
		disp in smcl in gr "{hline 22}{c TT}{hline 63}"
		disp in smcl in gr "{ralign 21:Method}"         _col(22) " {c |} " _col(26) %9s "Coef."             _col(38) %9s "Std. Err."    _col(48) %6s "z"        _col(55) %8s "P>|z|"    _col(65) %22s `"[`level'% Conf. Interval]"' _n  "{hline 22}{c +}{hline 63}"
		disp in smcl in gr "{ralign 21:Conventional}"   _col(22) " {c |} " _col(26) in ye %9.0g tau_F_cl    _col(37) %9.0g se_F_cl      _col(48) %7.2f t_F_cl   _col(55) %8.3f  pv_F_cl _col(66) %9.0g  ci_F_l_cl _col(78) %9.0g ci_F_r_cl  
		disp in smcl in gr "{ralign 21:Bias-corrected}" _col(22) " {c |} " _col(26) in ye %9.0g tau_F_bc    _col(37) %9.0g se_F_cl      _col(48) %7.2f t_F_bc   _col(55) %8.3f  pv_F_bc _col(66) %9.0g  ci_F_l_bc _col(78) %9.0g ci_F_r_bc  
		disp in smcl in gr "{ralign 21:Robust}"         _col(22) " {c |} " _col(26) in ye %9.0g tau_F_bc    _col(37) %9.0g se_F_rb      _col(48) %7.2f t_F_rb   _col(55) %8.3f  pv_F_rb _col(66) %9.0g  ci_F_l_rb _col(78) %9.0g ci_F_r_rb  
		disp in smcl in gr "{hline 22}{c BT}{hline 63}"

		disp ""
		disp in yellow "First-Stage Estimates. Outcome: `fuzzy'. Running variable: `X'."
		disp in smcl in gr "{hline 22}{c TT}{hline 63}"
		disp in smcl in gr "{ralign 21:Method}"            _col(22) " {c |} " _col(26) %9s "Coef."          _col(38) %9s "Std. Err."    _col(48) %6s "z"        _col(55) %8s "P>|z|"    _col(65) %22s `"[`level'% Conf. Interval]"' _n  "{hline 22}{c +}{hline 63}"
		disp in smcl in gr "{ralign 21:Conventional}"      _col(22) " {c |} " _col(26) in ye %9.0g tau_Z_cl _col(37) %9.0g se_Z_cl      _col(48) %7.2f t_Z_cl   _col(55) %8.3f  pv_Z_cl _col(66) %9.0g  ci_Z_l_cl _col(78) %9.0g ci_Z_r_cl 
		disp in smcl in gr "{ralign 21:Bias-corrected}"    _col(22) " {c |} " _col(26) in ye %9.0g tau_Z_bc _col(37) %9.0g se_Z_cl      _col(48) %7.2f t_Z_bc   _col(55) %8.3f  pv_Z_bc _col(66) %9.0g  ci_Z_l_bc _col(78) %9.0g ci_Z_r_bc  
		disp in smcl in gr "{ralign 21:Robust}"            _col(22) " {c |} " _col(26) in ye %9.0g tau_Z_bc _col(37) %9.0g se_Z_rb      _col(48) %7.2f t_Z_rb   _col(55) %8.3f  pv_Z_rb _col(66) %9.0g  ci_Z_l_rb _col(78) %9.0g ci_Z_r_rb
		disp in smcl in gr "{hline 22}{c BT}{hline 63}"
	}
	
	if ("`heter'"!="" & "`hcoef'"!="") {
		loc quant = -invnormal(abs((1-(`level'/100))/2))
		disp ""
		disp "Marginal Effect of {cmd:heter()} on the Reduced-Form Estimate. Outcome: `y'."
		disp in smcl in gr "{hline 22}{c TT}{hline 63}"
		disp in smcl in gr "{ralign 21:{it: hetervar}}" _col(22) " {c |} " _col(26) %9s "Coef."             _col(38) %9s "Std. Err."    _col(48) %6s "z"        _col(55) %8s "P>|z|"    _col(65) %22s `"[`level'% Conf. Interval]"' _n  "{hline 22}{c +}{hline 63}"
				
		forvalues i = 1/`hdim' {
			loc aa = word("`heter'",`i')
			loc a = hcoef[1,`i']
			loc se = sqrt(Vhcoef[`i',`i'])
			disp in smcl in gr "{ralign 21: `aa'}"   _col(22) " {c |} " _col(26) in ye %9.0g `a'    _col(37) %9.0g `se'      _col(48) %7.2f `a'/`se'   _col(55) %8.3f  2*normal(-abs(`a'/`se')) _col(66) %9.0g  `a' - `quant'*`se' _col(78) %9.0g `a' + `quant'*`se'
		}
		disp in smcl in gr "{hline 22}{c BT}{hline 63}"

		if ("`fuzzy'"~="") {
			disp ""
			disp "Marginal Effect of {cmd:heter()} on the First-Stage Estimate. Outcome: `fuzzy'."
			disp in smcl in gr "{hline 22}{c TT}{hline 63}"
			disp in smcl in gr "{ralign 21:{it: hetervar}}" _col(22) " {c |} " _col(26) %9s "Coef."             _col(38) %9s "Std. Err."    _col(48) %6s "z"        _col(55) %8s "P>|z|"    _col(65) %22s `"[`level'% Conf. Interval]"' _n  "{hline 22}{c +}{hline 63}"

			forvalues i = 1/`hdim' {
				loc aa = word("`heter'",`i')
				loc a = hcoef_Z[1,`i']
				loc se = sqrt(Vhcoef_Z[`i',`i'])
				disp in smcl in gr "{ralign 21: `aa'}"   _col(22) " {c |} " _col(26) in ye %9.0g `a'    _col(37) %9.0g `se'      _col(48) %7.2f `a'/`se'   _col(55) %8.3f  2*normal(-abs(`a'/`se')) _col(66) %9.0g  `a' - `quant'*`se' _col(78) %9.0g `a' + `quant'*`se'
			}
			disp in smcl in gr "{hline 22}{c BT}{hline 63}"

			disp ""
			disp "Marginal Effect of {cmd:heter()} on the Structural Estimate. Outcome: `y'. Treatment: `fuzzy'."
			disp in smcl in gr "{hline 22}{c TT}{hline 63}"
			disp in smcl in gr "{ralign 21:{it: hetervar}}" _col(22) " {c |} " _col(26) %9s "Coef."             _col(38) %9s "Std. Err."    _col(48) %6s "z"        _col(55) %8s "P>|z|"    _col(65) %22s `"[`level'% Conf. Interval]"' _n  "{hline 22}{c +}{hline 63}"

			forvalues i = 1/`hdim' {
				loc aa = word("`heter'",`i')
				loc a = hcoef_F[1,`i']
				loc se = sqrt(Vhcoef_F[1,`i'])
				disp in smcl in gr "{ralign 21: `aa'}"   _col(22) " {c |} " _col(26) in ye %9.0g `a'    _col(37) %9.0g `se'      _col(48) %7.2f `a'/`se'   _col(55) %8.3f  2*normal(-abs(`a'/`se')) _col(66) %9.0g  `a' - `quant'*`se' _col(78) %9.0g `a' + `quant'*`se'
			}
			disp in smcl in gr "{hline 22}{c BT}{hline 63}"
		}
	}
	
	if ("`control'"!="" | "`heter'"!="") {
		loc cvars ""
		if ("`control'"!="") {
			local cvars "Control variables: `control'. "
		}
		if ("`heter'"!="") {
			loc a = `AT'[1,1]
			loc aa = word("`heter'",1)
			local cvars "`cvars'Effect at `aa' = `a'"
			if `hdim' > 1 {
				forvalues i = 2/`hdim' {
					loc a = `AT'[1,`i']
					loc aa = word("`heter'",`i')
					local cvars "`cvars', `aa' = `a'"
				}
			}
			loc cvars "`cvars'."
		}
		disp in yellow "`cvars'"
	}

	if ("`scalepar'"!="1") {
		disp "Scale parameter: " `scalepar' 
	}
	if ("`scaleregul'"!="1") {
		disp "Scale regularization: " `scaleregul'
	}
	
	if ("`warning'"=="") {	
		if (`h'>=`range') {
			disp in red "WARNING: bandwidth {it:h} greater than the range of the data."
		}
	
		if (`b'>=`range') {
			disp in red "WARNING: Note that the bandwidth {it:b} is greater than the range of the data."
		}
	
		if (Nhm<20) {
			disp in red "WARNING: bandwidth {it:h} too low."
		}
	
		if (Nbm<20) {
			disp in red "WARNING: bandwidth {it:b} too low."
		}
		if ("`fuzzy'"~="" & "`bwselect'"~="Manual") {
			disp in ye "WARNING: The estimated bandwidths correspond to the reduced-form estimation of `y' on `X'."
		}
		if ("`control'"~="" & "`bwselect'"!="Manual") {
			disp in ye "WARNING: The estimated bandwidths do not control for `control'."
		}
		if ("`heter'"!="") {
			forvalues i = 1/`hdim' {
				loc a = `AT'[1,`i']
				loc aa = word("`heter'",`i')
				if (`hsd`i''>=1) disp in red "WARNING: {cmd:at(}{inp:`a'}{cmd:)} is `hsd`i'' std. dev. out of {inp:`aa'} range."
				else if (`hsd`i''>0) disp in ye "WARNING: {cmd:at(}{inp:`a'}{cmd:)} is `hsd`i'' std. dev. out of {inp:`aa'} range."
			}
		}
	}

	matrix rownames V = Estimate
	matrix colnames V = Estimate
	matrix colnames b = Estimate
	
	local tempo: colfullnames V
	matrix rownames V = `tempo'

	if ("`all'"~="") {
		matrix rownames V = Conventional Bias-corrected Robust
		matrix colnames V = Conventional Bias-corrected Robust
		matrix colnames b = Conventional Bias-corrected Robust
	}

	local ci_l_rb = round(ci_l_rb,0.001)
	local ci_r_rb = round(ci_r_rb,0.001)
	
	restore

	*ereturn clear
    if ("`time'"=="") 				 	 loc N = Nh10 + Nh11
    else if ("`time'"!="" & "`cut'"!="") loc N = Nh01 + Nh11
    else 							     loc N = Nh00 + Nh10 + Nh01 + Nh11

	if ("`exp'"!="") ereturn post b V [aw=`exp'], esample(`touse') obs(`N')
	else 			 ereturn post b V, esample(`touse') obs(`N')

    if ("`time'"=="") {
        ereturn scalar N_l = Nh10
        ereturn scalar N_r = Nh11
		ereturn scalar range_l = `range_l1'
		ereturn scalar range_r = `range_r1'
    }
    else if ("`time'"!="" & "`cut'"!="") {
        ereturn scalar N_0 = Nh01
        ereturn scalar N_1 = Nh11
		ereturn scalar range_0 = `range_r0'
        ereturn scalar range_1 = `range_r1'
    }
    else {
        ereturn scalar N_l0 = Nh00
        ereturn scalar N_r0 = Nh01
        ereturn scalar N_l1 = Nh10
        ereturn scalar N_r1 = Nh11
		ereturn scalar range_l0 = `range_l0'
		ereturn scalar range_r0 = `range_r0'
        ereturn scalar range_l1 = `range_l1'
        ereturn scalar range_r1 = `range_r1'
    }

    if (`dim'>1) {
		mat rown `C' = c
		mat coln `C' = `X'
		ereturn matrix c = `C'
	}
	else 		 ereturn scalar c = `c'

	ereturn scalar p = `p'
	ereturn scalar q = `q'
	ereturn scalar deriv = `deriv'
	if ("`heter'" != "") {
		if (`hdim'>1) {
			mat rown `AT' = at
			mat coln `AT' = `heter'
			ereturn matrix at = `AT'
		}
		else	ereturn scalar at = `AT'[1,1]
	}
	ereturn scalar bw_h = `h'
	ereturn scalar bw_b = `b'
	ereturn scalar rho  = `alpha'
	ereturn scalar level = `level'
	if ("`vce'" != "resid") ereturn scalar matches = `matches'

	tempname CI
	if ("`fuzzy'"=="") {
		ereturn scalar tau_cl = tau_cl
		ereturn scalar tau_bc = tau_bc
		ereturn scalar se_cl  = se_cl
		ereturn scalar se_rb  = se_rb
		ereturn scalar pv_cl = pv_cl
		ereturn scalar pv_bc = pv_bc
		ereturn scalar pv_rb = pv_rb

		mat `CI' = ci_l_cl, ci_r_cl \ ci_l_bc, ci_r_bc \ ci_l_rb, ci_r_rb
		mat coln `CI' = "`level'%-LL" "`level'%-UL"
		mat rown `CI' = "Conventional" "Bias-corrected" "Robust"
	}
	else {
		ereturn scalar tau_cl = tau_F_cl
		ereturn scalar tau_bc = tau_F_bc
		ereturn scalar se_cl  = se_F_cl
		ereturn scalar se_rb  = se_F_rb
		ereturn scalar pv_cl  = pv_F_cl
		ereturn scalar pv_bc  = pv_F_bc
		ereturn scalar pv_rb  = pv_F_rb

		mat `CI' = ci_F_l_cl, ci_F_r_cl \ ///
				   ci_F_l_bc, ci_F_r_bc \ ///
				   ci_F_l_rb, ci_F_r_rb
		mat coln `CI' = "`level'%-LL" "`level'%-UL"
		mat rown `CI' = "Conventional" "Bias-corrected" "Robust"

		ereturn scalar tau_Z_cl = tau_Z_cl
		ereturn scalar tau_Z_bc = tau_Z_bc
		ereturn scalar se_Z_cl  = se_Z_cl
		ereturn scalar se_Z_rb  = se_Z_rb
		ereturn scalar pv_Z_cl  = pv_Z_cl
		ereturn scalar pv_Z_bc  = pv_Z_bc
		ereturn scalar pv_Z_rb  = pv_Z_rb

		tempname ZCI
		mat `ZCI' = ci_Z_l_cl, ci_Z_r_cl \ ///
				    ci_Z_l_bc, ci_Z_r_bc \ ///
				    ci_Z_l_rb, ci_Z_r_rb
		mat coln `ZCI' = "`level'%-LL" "`level'%-UL"
		mat rown `ZCI' = "Conventional" "Bias-corrected" "Robust"
	}

	tempname Yhat Zhat
    if ("`time'"=="") {
		mat `Yhat' = mu_y_l_cl, mu_y_r_cl \ mu_y_l_bc, mu_y_r_bc
		mat coln `Yhat' = Left Right

		if ("`fuzzy'"!="") {
			mat `Zhat' = mu_Z_l_cl, mu_Z_r_cl \ mu_Z_l_bc, mu_Z_r_bc
			mat coln `Zhat' = Left Right
		}
    }
    else if ("`time'"!="" & "`cut'"=="") {
		mat `Yhat' = mu_y_l0_cl, mu_y_r0_cl, mu_y_l1_cl, mu_y_r1_cl ///
				   \ mu_y_l0_bc, mu_y_r0_bc, mu_y_l1_bc, mu_y_r1_bc
		mat coln `Yhat' = Left0 Right0 Left1 Right1

		if ("`fuzzy'"!="") {
			mat `Zhat' = mu_Z_l0_cl, mu_Z_r0_cl, mu_Z_l1_cl, mu_Z_r1_cl \ ///
						 mu_Z_l0_bc, mu_Z_r0_bc, mu_Z_l1_bc, mu_Z_r1_bc
			mat coln `Zhat' = Left0 Right0 Left1 Right1	
		}
    }
    else {
		mat `Yhat' = mu_y_0_cl, mu_y_0_cl \ mu_y_0_bc, mu_y_0_bc
		mat coln `Yhat' = Time0 Time1
		
		if ("`fuzzy'"!="") {
			mat `Zhat' = mu_Z_0_cl, mu_Z_0_cl \ mu_Z_0_bc, mu_Z_0_bc
			mat coln `Zhat' = Time0 Time1

		}
    }
	mat rown `Yhat' = Conventional Bias-corrected
	ereturn matrix yhat `Yhat'
	ereturn matrix ci `CI'

	if ("`fuzzy'"!="") {
		mat rown `Zhat' = Conventional Bias-corrected
		ereturn matrix zhat `Zhat'
		ereturn matrix z_ci `ZCI'
	}	

	if ("`distance'"!="") ereturn local distance "`distance'"
	ereturn local kernel 	"`kernel_type'"
	ereturn local bwselect 	"`bwselect'"
	
	if ("`vce'" == "resid") ereturn local vce "resid"
	else 					ereturn local vce "nn"
	
    if ("`control'" != "") ereturn local controls  "`control'"
	if ("`heter'"   != "") ereturn local heter     "`heter'"
	if ("`ittn'"    != "") ereturn local itt	   "`ittn'"
	if ("`time'"    != "") ereturn local time 	   "`time'"
	ereturn local runningvar "`X'"
	ereturn local fuzzy 	"`fuzzy'"
	ereturn local depvar 	"`y'"

	if ("`heter'"!="" & "`hcoef'"!="") {
		mat coln hcoef = `heter'
		mat rown hcoef = d`deriv'

		ereturn matrix hcoef = hcoef

		mat coln Vhcoef = `heter'
		mat rown Vhcoef = `heter'

		ereturn matrix Vhcoef = Vhcoef
		
		if ("`fuzzy'"!="") {
			mat coln hcoef_Z = `heter'
			mat rown hcoef_Z = d`deriv'
			ereturn matrix hcoef_Z = hcoef_Z

			mat coln Vhcoef_Z = `heter'
			mat rown Vhcoef_Z = `heter'
			ereturn matrix Vhcoef_Z = Vhcoef_Z

			mat coln hcoef_F = `heter'
			mat rown hcoef_F = d`deriv'
			ereturn matrix hcoef_F = hcoef_F

			mat Vhcoef_F = diag(Vhcoef_F)
			mat coln Vhcoef_F = `heter'
			mat rown Vhcoef_F = `heter'
			ereturn matrix Vhcoef_F = Vhcoef_F
		}
	}

	*mata mata clear
	
end
