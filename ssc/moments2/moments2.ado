*! 1.1.1 20-Jan-2013 Dirk Enzmann - modified version of Nick Cox's -moments-, version 1.1.0, 24-SEP-2004
program moments2, byable(recall) rclass
        version 8.2
        syntax [varlist] [if] [in] [aweight fweight] ///
        [, Matname(str) Format(str) Type(name) ALLobs variablenames by(varlist) * ]

        qui {
                ds `varlist', has(type numeric)
                local varlist "`r(varlist)'"

                if "`allobs'" != "" marksample touse, novarlist
                else marksample touse

                if ("`type'") == "" local type = "G"
                else if !inlist("`type'","b","b3","g","g3","G","G3") {
                   di as err ///
                   "option type() needs one of b, b3, g, g3, G, or G3 (default: G)"
                   exit 198
                }

                count if `touse'
                if r(N) == 0 error 2000

                local ng : word count `varlist'

                if "`by'" != "" {
                        if `ng' > 1 {
                                di as err ///
                                "by() cannot be combined with `ng' variables"
                                exit 198
                        }
                        tempvar group
                        egen `group' = group(`by') if `touse', label
                        su `group', meanonly
                        local ng = r(max)
                }
                else tokenize `varlist'

                if `ng' > _N {
                        preserve
                        set obs `ng'
                }

                tempvar a id n mean SD skewness kurtosis which
                tempname mylbl

                gen long `which' = _n
                compress `which'

                gen `n' = ""
                label var `n' "n"

                foreach s in mean SD skewness kurtosis {
                        gen double ``s'' = .
                        label var ``s'' "`s'"
                }

                tempname su_p99 su_p95 su_p90 su_p75 su_p50 su_p25 su_p10 su_p5 su_p1
                tempname su_max su_min su_sum su_sd su_Var su_mean su_sum_w su_N

                if "`matname'" != ""  mat `matname' = J(`ng',5,0)

                forval i = 1/`ng' {
                        if "`by'" != "" {
                                su `varlist' [`weight' `exp'] ///
                                if `touse' & `group' == `i', detail
                        }
                        else    su ``i'' if `touse' [`weight' `exp'], detail

                        sca `su_p99' = r(p99)
                        sca `su_p95' = r(p95)
                        sca `su_p90' = r(p90)
                        sca `su_p75' = r(p75)
                        sca `su_p50' = r(p50)
                        sca `su_p25' = r(p25)
                        sca `su_p10' = r(p10)
                        sca `su_p5' = r(p5)
                        sca `su_p1' = r(p1)
                        sca `su_max' = r(max)
                        sca `su_min' = r(min)
                        sca `su_sum' = r(sum)
                        sca `su_sd' = r(sd)
                        sca `su_Var' = r(Var)
                        sca `su_mean' = r(mean)
                        sca `su_sum_w' = r(sum_w)
                        sca `su_N' = r(N)

                        replace `n' = string(r(N)) in `i'
                        replace `mean' = r(mean) in `i'
                        replace `SD' = r(sd) in `i'
                        if "`type'" == "b" {
			replace `skewness' = r(skewness)*((r(N)-1)/r(N))^(3/2) in `i'
			replace `kurtosis' = r(kurtosis)*((r(N)-1)/r(N))^2 in `i'
		      }
                        else if "`type'" == "b3" {
			replace `skewness' = r(skewness)*((r(N)-1)/r(N))^(3/2) in `i'
			replace `kurtosis' = r(kurtosis)*((r(N)-1)/r(N))^2-3 in `i'
		      }
                        else if "`type'" == "G" {
			replace `skewness' = r(skewness)*sqrt(r(N)*(r(N)-1))/(r(N)-2) in `i'
			replace `kurtosis' = r(kurtosis)*(r(N)^2-1)/((r(N)-2)*(r(N)-3))-3*(r(N)-1)^2/((r(N)-2)*(r(N)-3)) in `i'
		      }
		      else if "`type'" == "G3" {
                           replace `skewness' = r(skewness)*sqrt(r(N)*(r(N)-1))/(r(N)-2) in `i'
 			replace `kurtosis' = r(kurtosis)*(r(N)^2-1)/((r(N)-2)*(r(N)-3))-3*(r(N)-1)^2/((r(N)-2)*(r(N)-3))+3 in `i'
		      }
		      else if "`type'" == "g" {
                           replace `skewness' = r(skewness) in `i'
 			replace `kurtosis' = r(kurtosis)-3 in `i'
		      }
		      else if "`type'" == "g3" {
                           replace `skewness' = r(skewness) in `i'
 			replace `kurtosis' = r(kurtosis) in `i'
		      }

                        if "`matname'" != "" {
                           mat `matname'[`i',1] = r(N)
                           mat `matname'[`i',2] = r(mean)
                           mat `matname'[`i',3] = r(sd)
                           if "`type'" == "b" {
			   mat `matname'[`i',4] = r(skewness)*((r(N)-1)/r(N))^(3/2)
			   mat `matname'[`i',5] = r(kurtosis)*((r(N)-1)/r(N))^2
		         }
                           else if "`type'" == "b3" {
			   mat `matname'[`i',4] = r(skewness)*((r(N)-1)/r(N))^(3/2)
			   mat `matname'[`i',5] = r(kurtosis)*((r(N)-1)/r(N))^2-3
		         }
			else if "`type'" == "G" {
                              mat `matname'[`i',4] = r(skewness)*sqrt(r(N)*(r(N)-1))/(r(N)-2)
			   mat `matname'[`i',5] = r(kurtosis)*(r(N)^2-1)/((r(N)-2)*(r(N)-3))-3*(r(N)-1)^2/((r(N)-2)*(r(N)-3))
			}
			else if "`type'" == "G3" {
                              mat `matname'[`i',4] = r(skewness)*sqrt(r(N)*(r(N)-1))/(r(N)-2)
                              mat `matname'[`i',5] = r(kurtosis)*(r(N)^2-1)/((r(N)-2)*(r(N)-3))-3*(r(N)-1)^2/((r(N)-2)*(r(N)-3))+3
			}
			else if "`type'" == "g" {
                              mat `matname'[`i',4] = r(skewness)
                              mat `matname'[`i',5] = r(kurtosis)-3
			}
			else if "`type'" == "g3" {
                              mat `matname'[`i',4] = r(skewness)
                              mat `matname'[`i',5] = r(kurtosis)
			}
                        }

                        if "`by'" != "" {
                                local V = trim(`"`: label (`group') `i''"')
                                local rownames `"`rownames' `"`V'"'"'
                        }
                        else {
                                local V = trim(`"`: variable label ``i'''"')
                                if "`variablenames'" != "" | `"`V'"' == "" {
                                        local V "``i''"
                                }
                        }
                        label def `mylbl' `i' `"`V'"', modify

                }

                if "`matname'" != "" {
                        mat colnames `matname' = n mean SD skewness kurtosis
                        if "`by'" != "" {
                                capture mat rownames `matname' = `rownames'
                                if _rc {
                                        numlist "1/`ng'"
                                        mat rownames `matname' = `r(numlist)'
                                }
                        }
                        else mat rownames `matname' = `varlist'
                }

                label val `which' `mylbl'
                if "`by'" != "" label var `which' "Group"
                else if "`allobs'" != "" label var `which' "Variable"
                else label var `which' "n = `r(N)'"

                local fmt "format(%9.3f)"
                if "`format'" != "" {
                        tokenize `format'

                        if "`4'" != "" {
                                tempvar skurtosis
                                gen `skurtosis' = string(`kurtosis', "`4'")
                                label var `skurtosis' "kurtosis"
                                local kurtosis "`skurtosis'"
                        }

                        if "`3'" != "" {
                                tempvar sskewness
                                gen `sskewness' = string(`skewness', "`3'")
                                label var `sskewness' "skewness"
                                local skewness "`skewness'"
                        }

                        if "`2'" != "" {
                                tempvar sSD
                                gen `sSD' = string(`SD', "`2'")
                                label var `sSD' "SD"
                                local SD "`sSD'"
                        }

                        tempvar smean
                        gen `smean' = string(`mean', "`1'")
                        label var `smean' "mean"
                        local mean "`smean'"
                }

                if "`allobs'`by'" != "" local shown "`n'"
        }

        tabdisp `which' if `which' <= `ng', ///
        c(`shown' `mean' `SD' `skewness' `kurtosis') `options' `fmt'

        return local type = "`type'"
        return scalar p99 = `su_p99'
        return scalar p95 = `su_p95'
        return scalar p90 = `su_p90'
        return scalar p75 = `su_p75'
        return scalar p50 = `su_p50'
        return scalar p25 = `su_p25'
        return scalar p10 = `su_p10'
        return scalar p5 = `su_p5'
        return scalar p1 = `su_p1'
        return scalar max = `su_max'
        return scalar min = `su_min'
        return scalar sum = `su_sum'
        return scalar kurtosis = `kurtosis'[`ng']
        return scalar skewness = `skewness'[`ng']
        return scalar sd = `su_sd'
        return scalar Var = `su_Var'
        return scalar mean = `su_mean'
        return scalar sum_w = `su_sum_w'
        return scalar N = `su_N'
end
