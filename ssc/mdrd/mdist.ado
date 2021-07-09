*!version 26Aug2016, Rafael Ribas

capture program drop mdist
program define mdist, rclass
	version 12
	syntax varlist(min=2 num ts) [if] [in] [aweight/], [ itt(varname numeric) ///
		nocut c(numlist) DISTance(string) GENerate(string) ARGument(integer 2) ///
		unit(string) replace precalc ]

    qui {

		local unit = lower("`unit'")

        marksample touse
        tokenize `varlist'

        local dim = wordcount("`varlist'")

        if "`precalc'" == "" {

            local distance = lower("`distance'")

            if "`generate'" == "" {
                local generate "_dist"
            }

            if "`replace'" != "" {
                cap drop `generate'
            }

            if "`c'" == "" {
                forvalues i = 1/`dim' {
                    local c "`c' 0"
                }
            }
            if (`dim' < wordcount("`c'")) {
                noi di "{err}More cutoffs than running variables"  
                exit 102
            }
            if (`dim' > wordcount("`c'")) {
                noi di "{err}More running variables than cutoffs"
                exit 103
            }
        }

        tempname C
        mat `C' = real(word("`c'",1))
        forvalues i = 2/`dim' {
            mat `C' = `C', real(word("`c'",`i'))
        }

        if "`precalc'" == "" {    
            * ITT != {0,1}
            if ("`itt'" != "") {
                tempname A
                cap ta `itt', matrow(`A')
                if (_rc==0 & r(r)<=2) { 
                    if ((`A'[1,1]!=0 & `A'[1,1]!=1) | (`A'[2,1]!=1 & `A'[2,1]!=.)) {
                        noi di "{err}{cmd:itt()} should have values 0 and 1"  
                        exit 125
                    }
                }
                else {
                    noi di "{err}{cmd:itt()} should have values 0 and 1"  
                    exit 125
                }
            }
            else {
                tempvar itt
                g `itt' = 1 if `touse'
                if ("`cut'" == "") {
					forvalues i = 1/`dim' {
						replace `itt' = 0 if ``i''<`C'[1,`i']
					}
				}
			}

			if ("`cut'" == "") {
				su `itt'
				local err = r(sd)
				if `err' == 0 {
					noi di "{err}At least one cutoff not within range"
					exit 125
				}
				forvalues i = 1/`dim' {
					su ``i''
					local err = r(min)
					if `err' > `C'[1,`i'] {
						noi di "{err}At least one cutoff not within range"
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
                noi di "{err}{cmd:distance()} incorrectly specified"  
                exit 7
            }
        }

        
		if ("`itt'" == "") {
			tempvar itt
			g `itt'=1 if `touse'
		}

		noi disp in ye "Computing `distance' distance"


        if "`distance'" == "Latlong" {
            if `dim' > 2 {
                noi di "{err}Too many running variables specified"
                exit 103
            }
            else if `dim' < 2 {
                noi di "{err}Too few running variables specified"
                exit 102
            }
            else {
                g double `generate' = .
				tempvar x y

				loc a = 6378.1370
				loc b = 6356.7523
				if substr("`unit'",1,4) == "mile" |  "`unit'" == "mi" {
					loc u = 1/1.609344
				}
				else if "`unit'" == "m" | substr("`unit'",1,4) == "met" {
					loc u = 1000
				}
				else if "`unit'" == "foot" | "`unit'" == "feet" | "`unit'" == "ft" {
					loc u = 1/0.0003048
				}
				else if "`unit'" == "yd" | substr("`unit'",1,4) == "yard" {
					loc u = 1/0.0009144
				}
				else if "`unit'" == "km" | substr("`unit'",1,3) == "kil" | "`unit'" == "" {
					loc u = 1
				}
				else {
				    noi di "{err}{cmd:unit()} incorrectly specified"  
					exit 7
				}

                if lower(substr("`1'",1,2)) == "lo" & lower(substr("`2'",1,2)) == "la" {
					g double `x' = _pi*`1'/180
					g double `y' = _pi*`2'/180
					loc xr = _pi*`C'[1,1]/180
					loc yr = _pi*`C'[1,2]/180
					
					loc radius = `u'*sqrt(((`a'^2)*cos(`C'[1,2]))^2 + ((`b'^2)*sin(`C'[1,2]))^2)/sqrt((`a'*cos(`C'[1,2]))^2 + (`b'*sin(`C'[1,2]))^2)
                }
                else {
					g double `y' = _pi*`1'/180
					g double `x' = _pi*`2'/180
					loc yr = _pi*`C'[1,1]/180
					loc xr = _pi*`C'[1,2]/180
					
					loc radius = `u'*sqrt(((`a'^2)*cos(`C'[1,1]))^2 + ((`b'^2)*sin(`C'[1,1]))^2)/sqrt((`a'*cos(`C'[1,1]))^2 + (`b'*sin(`C'[1,1]))^2)
                }
				replace `generate' =  sin(`y')*sin(`yr') + cos(`y')*cos(`yr')*cos(`xr' - `x')
                replace `generate' = acos(`generate')*`radius'
            }
        }
        else if "`distance'" != "Mahalanobis" {
            g double `generate' = abs(`1' - `C'[1,1])^`argument'
            forvalues i = 2/`dim' {
                replace `generate' = `generate' + abs(``i'' - `C'[1,`i'])^`argument'
            }
            replace `generate' = `generate'^(1/`argument')
        }


        * Sample weight
        tempvar wgt
        if ("`exp'"=="") { 
            g `wgt' = 1 if `touse'
        }
        if ("`exp'"~="") {
            su `exp' if `exp'>0 & `touse'
            g `wgt' = `exp'/r(mean) if `exp'>0 & `touse'
        }
    
		tempname X W Cc X vX ivX D

        mata {
            if ("`distance'" == "Mahalanobis") {
                `X'   = st_data(.,("`varlist'"))
                `W'   = st_data(.,("`wgt'"))
                `Cc' = st_matrix("`C'")
                `X' = `X' :- `Cc'
        
                `vX' = variance(`X', `W')
                `ivX' = invsym(`vX')
        
                `D' = sqrt(rowsum(`X':*(`ivX'*`X'')'))
        
                st_addvar("double", "`generate'")
                st_store(.,"`generate'",`D')
            }
        }
		if ("`distance'" == "Mahalanobis") mata mata drop __*

        replace `generate' = (2*`itt' - 1)*`generate'

        replace `generate' = . if !`touse'
		compress `generate'
        la var `generate' "Distance to cutoff - `distance' function"
    }

end
