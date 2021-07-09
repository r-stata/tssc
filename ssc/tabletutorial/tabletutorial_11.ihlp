        capture program drop mysumtab
        program define mysumtab
            syntax varlist using [, replace append ] 
            tempname fh
            file open `fh' `using', write `replace' `append'
            file write `fh' "variable" _tab "mean" _tab "sd"
            foreach v of local varlist {
                quietly summarize `v'
                file write `fh' _n "`v'" _tab (r(mean)) _tab (r(sd))
            }
            file close `fh'
        end
        
        sysuse nlsw88, clear
        mysumtab * using example.txt, replace
        type example.txt
