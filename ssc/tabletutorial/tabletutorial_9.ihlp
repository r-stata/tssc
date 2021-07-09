        sysuse auto, clear
        file open fh using example.txt, write replace
        file write fh "variable" _tab "mean" _tab "sd"
        foreach v of varlist price-foreign  {
            summarize `v'
            file write fh _n "`v'" _tab (r(mean)) _tab (r(sd))
        }
        file close fh
        type example.txt
