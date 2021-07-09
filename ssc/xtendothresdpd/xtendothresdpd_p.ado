*! version 1.0.1
*! Predict Program for the Command xtendothresdpd
*! Diallo Ibrahima Amadou
*! All comments are welcome, 15Apr2020



capture program drop xtendothresdpd_p
program xtendothresdpd_p, sortpreserve
	version 16.0
	syntax anything(id="newvarname") [if] [in] [,  xb e stdp difference ]
    local nopts : word count `xb' `e' `stdp' `difference'  
    if `nopts' > 2 {
        display "{err}only two statistics may be specified"
        exit 498
    }	
	local lapartievind = e(datasignaturevars)
	local lasectionopt = e(lesoptionsdp)
	
	if ("`e'" != "") | ("`difference'" != "") {
					syntax newvarname [if] [in] [, e difference]
					quietly tsset
					quietly xtdpd `lapartievind' `if' `in', `lasectionopt'
					predict `typlist' `varlist' `if' `in', `e' `difference'
	}	
	else if ("`stdp'" != "") {
					syntax newvarname [if] [in] [, stdp ]
					quietly tsset
					quietly xtdpd `lapartievind' `if' `in', `lasectionopt'
					predict `typlist' `varlist' `if' `in', `stdp' 
	}
	else {
		syntax newvarname [if] [in] [, xb difference]
		quietly tsset
		quietly xtdpd `lapartievind' `if' `in', `lasectionopt'
		predict `typlist' `varlist' `if' `in', `xb' `difference'
	}
	
end


