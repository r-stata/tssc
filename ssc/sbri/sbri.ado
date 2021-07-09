*! v.1.0.0 N.Orsini 25sep2006
* Spearman-Brown reliability 
* Formulas from loneway [R] pag.113 Stata 9 Manual) 
* Post-estimation command of xtreg 

capture program drop sbri
program sbri, eclass
version 8.2
syntax  [ , obs(string)  Format(string)   ]

	if "`obs'" != "" {
		 local n = `obs'
	}
	else {
		local n = e(g_avg)
	}

if "`format'" == "" {
local format = "%3.2f"
}   
else {
local format = "`format'"
}

if replay() {
		if `"`e(cmd)'"'==`"xtreg"' {

                if "`e(model)'" != "ml"   {
                        noi di in red "xtreg, mle not found"
                        exit 301 
					}
				}
			else {
                        noi di in red "xtreg, mle not found"
                        exit 301 
				}						
		}

* di e(sigma_u)^2/(e(sigma_u)^2+ e(sigma_e)^2/`n')

di _n as txt   "Spearman-Brown reliability = " `format' as res (`n'*e(rho))/ (1+(`n'-1)*e(rho))  

// saved results

ereturn scalar sbr = e(sigma_u)^2/[e(sigma_u)^2+ (e(sigma_e)^2/`n')]
ereturn local cmd = "sbri"

end

 

