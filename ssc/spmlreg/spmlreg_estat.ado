*! Date: November 8, 2012
program spmlreg_estat, rclass
        version 11
        if "`e(cmd)'" != "spmlreg" {
                error 301
        }
        gettoken sub rest : 0, parse(", ")
        local lsub = length(`"`sub'"')
        if `"`sub'"' == substr("gof",1,max(3,`lsub')) {
                
                di as err "GOF not available after `e(cmd)'"
                exit 198                
        }
        else estat_default `0'        
        return add       
end
