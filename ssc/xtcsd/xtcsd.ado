*! version 1.1.1 	R.E. De Hoyos and V. Sarafidis 16may2006
* Test for cross-sectional dependence in panel data models
* Part of the code taken from C. Baum's -xttest2- 
* Following Pesaran (2004) and Frees (2005)
* version 1.0.2 -> Handling unbalanced panels
* version 1.1.0 -> Making it a post-estimation command
* version 1.1.1 -> Fixing the bug in the p-values

cap program drop xtcsd
program define xtcsd, rclass sortpreserve
	version 6
	
	syntax, [PESaran FREes FRIedman SHOW ABS]

	preserve
	if "`e(cmd)'"!="xtreg" { 
		di in red "last estimates not xtreg"
		exit 301
	}
	if "`e(model)'" !="fe" & "`e(model)'" !="re" { 
		error 301 
	}
	if "`pesaran'"=="" & "`frees'"=="" & "`friedman'"==""  {
		di in red "Method option not specified"
		exit
	}
	if ("`pesaran'"~="" & ("`frees'"~="" | "`friedman'"~="")) | ("`frees'"~="" & "`friedman'"~="")  {
		di in red "Too many method options specified"
		exit
	}

	qui tsset 
	local id "`r(panelvar)'"
	local time "`r(timevar)'"

	qui predict double __e if e(sample), e

	qui drop if e(sample)==0
	local ng "`e(N_g)'"				//# of cross sectional units
	local tb "`e(g_min)'"				//Binding constraint in time units

	*Modifying the data set to get a column of residuals for each cross-section
	tempvar id2
	qui egen `id2' = group(`id')
	qui levels `id2' `if' `in', local(csunit)
	qui keep __e `id2' `time'
	qui reshape wide __e, i(`time') j(`id2') 

	*Taking into account only minimum T accross ID within Frees test
	if "`frees'" != "" | "`friedman'" != "" {
		foreach c of local csunit {
			qui drop if __e`c'==.
		}
		local minT = _N
	}  
		

	*Checking for enough matrix resources
	local npanel = r(N)
	qui query memory
	if `npanel' > r(matsize) {					 
		di in r _n "Error: inadequate matsize; must be at least `npanel'"
		error 908
	}

	*Creating the covariance matrix
	tempname COR E F ABS
	mat `E' = J(`ng',`ng',1)
	if "`friedman'" !="" {
		mat `F' = J(`ng',`ng',1)
	}
	if "`abs'" !="" {
		mat `ABS' = J(`ng',`ng',1)
	}
	if "`show'" !="" {
		mat `COR' = J(`ng',`ng',1)
	}
	
	foreach i of local csunit {
		foreach j of local csunit {
			if "`frees'"=="" & "`friedman'"=="" | "`pesaran'"!="" {
				qui cap corr __e`i' __e`j'
				if _rc==2000 | `r(N)'==2 {
					di as err "Error: The panel is highly unbalanced." 
					di as err "Not enough common observations across panel to perform Pesaran's test."
					error 2001
                        }
				mat `E'[`i',`j'] = `r(rho)'*sqrt(`r(N)')
				if "`abs'" != "" {
					mat `ABS'[`i',`j'] = abs(`r(rho)')
				}
				if "`show'" != "" {
					mat `COR'[`i',`j'] = `r(rho)'
				}			 		
			}
			else {									
				qui spearman __e`i' __e`j'
				mat `E'[`i',`j'] = (`r(rho)')^2				
				if "`friedman'" != "" {
					mat `F'[`i',`j'] = `r(rho)'
				}
				if "`show'" !="" | "`abs'"!="" {
					qui corr __e`i' __e`j'
					if "`abs'" != "" {
						mat `ABS'[`i',`j'] = abs(`r(rho)')
					}
					if "`show'" != "" {
						mat `COR'[`i',`j'] = `r(rho)'
					}
				}
			}
		}
	}
	 
	di " "

	*Displaying Correlation Matrix

    	if "`show'"!="" {
		di in gr "Correlation matrix of residuals:"		
    		mat list `COR', nohead format(%9.4f)
    	}
    	
	*Creating a 1x1 ``matrix'' with the sum of the matrix E (inlcuding element by element multiplication by T_{ij})
	tempname A B 
	mat `A' = J(colsof(`E'),1,1)
    	mat `B' = `A''*`E'*`A'

	*Critical Values for Frees Test for T<=30; coming from Frees' Q distribution
	*Significance at the  10%	5%	1% levels
	local T4	0.582210758	0.839114984	1.421135642
	local T5	0.489238114	0.685977181	1.10456324
	local T6	0.412658998	0.567636868	0.902706907
	local T7	0.358288118	0.492251034	0.767775969
	local T8	0.316868873	0.432452369	0.660545679
	local T9	0.282784751	0.382564287	0.581080225
	local T10	0.255853719	0.342858814	0.519780382
	local T11	0.233292559	0.310295348	0.464867739
	local T12	0.213585942	0.283763514	0.425186549
	local T13	0.198350566	0.262031641	0.390109604
	local T14	0.184133643	0.243101807	0.360299337
	local T15	0.171938209	0.226202271	0.335078763
	local T16	0.161163782	0.211642005	0.312465021
	local T17	0.152050026	0.199631597	0.292842932
	local T18	0.143773435	0.188844992	0.276263341
	local T19	0.135985199	0.178176611	0.260105614
	local T20	0.129385699	0.169520436	0.246825304
	local T21	0.1230993	0.161076942	0.23378533
	local T22	0.117399185	0.153662139	0.222533364
	local T23	0.112413921	0.147049964	0.212859171
	local T24	0.107792641	0.140834061	0.203408604
	local T25	0.103534605	0.134976492	0.19467908
	local T26	0.099552324	0.129701827	0.186993823
	local T27	0.095832193	0.124819992	0.179400199
	local T28	0.092370839	0.120406029	0.172627827
	local T29	0.089158218	0.11597072	0.16598793
	local T30	0.086149177	0.111918056	0.159835289

	*Tests 
	if "`frees'"=="" & "`friedman'"=="" | "`pesaran'"!="" {
		local pesaran = sqrt(2/(`ng'*(`ng'-1)))*(`B'[1,1]-trace(`E'))/2
		di " "
    		di in gr "Pesaran's test of cross sectional independence = "/*
    		*/in ye %9.3f `pesaran' in gr ", Pr = " %6.4f /*
    		*/ in ye 2*(1-norm(abs(`pesaran')))					 

	    	ret scalar pesaran = `pesaran'
	}
	else {
		if "`frees'" !="" {
			local rave2 = (2/(`ng'*(`ng'-1)))*(`B'[1,1]-trace(`E'))/2  
			local frees = `ng'*(`rave2'- (1/(`tb'-1)))
			if `minT' < 31 {
				if `minT' < 4 { 
					di in red "Error: the distribution of Frees' Q statistic requires T>3"
				}
				else {	
					local alpha1 : word 1 of `T`minT'' 
					local alpha2 : word 2 of `T`minT''
					local alpha3 : word 3 of `T`minT''
					di " "
			    		di in gr "  Frees' test of cross sectional independence = "/*
			    		*/in ye %9.3f `frees' 
					di in gr "|--------------------------------------------------------|"
					di in gr "  Critical values from Frees' Q distribution"
					di in gr "			alpha = 0.10 :" in ye %9.4f `alpha1'
					di in gr "			alpha = 0.05 :" in ye %9.4f `alpha2'
					di in gr "			alpha = 0.01 :" in ye %9.4f `alpha3'
				}
			}
			else {
				scalar seq1 = (32/25)*(((`minT'+2)^2)/((`minT'-1)^3*(`minT'+1)^2))
				scalar seq2 = (4/25)*(((5*`minT'+6)^2*(`minT'-3))/((`minT'*(`minT'-1)^2)*(`minT'+1)^2))
				scalar seq = sqrt(seq1+seq2)
				di " "
		    		di in gr "Frees' test of cross sectional independence = "/*
		    		*/in ye %9.3f `frees' in gr ", Pr = " %6.4f /*
				*/ in ye 2*(1-norm(`frees'/seq))
				di " " 
				di in ye "Warning: A normal distribution had been used to approximate Frees' Q distribution" 
			}
			ret scalar frees = `frees'
		}
		if "`friedman'" !="" {
			tempname FRI
			mat `FRI' = `A''*`F'*`A'
			local rave = (2/(`ng'*(`ng'-1)))*(`FRI'[1,1]-trace(`F'))/2		
			local fried = (`tb'-1)*((`ng'-1)*`rave'+1)
			di " "
			di in gr "Friedman's test of cross sectional independence = "/*
	    		*/in ye %9.3f `fried' in gr ", Pr = " %6.4f /*
	    		*/ in ye 1-chi2((`ng'-1),`fried')
			ret scalar fried = `fried'
		}
	}		

	if "`abs'"!="" {						
		tempname D
		mat `D' = `A''*`ABS'*`A'
		local absv =  (`D'[1,1]-trace(`ABS'))/2
		local absvm = `absv'*2/(`ng'*(`ng'-1))
		di " "
		di in gr "Average absolute value of the off-diagonal elements = " /*
		*/ in ye %9.3f `absvm' ""
	}
	
end
