*! version 1.0.1  25sep2014  Ben Jann

program addplot
    version 9
    local caller : di _caller()
    _on_colon_parse `0'
    local plots `"`s(before)'"'
    local cmd   `"`s(after)'"'
    gettoken name : plots
    capt confirm name `name'
    if _rc==0 {
        gettoken name plots : plots
    }
    else local name
    if `"`plots'"'!="" {
        numlist `"`plots'"', integer range(>=1)
        local plots `r(numlist)'
    }
    if `"`name'"'=="" {
        gr_current name :
    }
    else {
        capt classutil d `name'
        if _rc {
            di as err `"graph `name' not found"'
            exit 111
        }
    }
    if `"`plots'"'=="" {
        local grtype `"`.`name'.graphfamily'"'
        if `"`grtype'"'=="twoway" {
            version `caller': .`name'.parse `cmd'
            graph display `name'
            exit
        }
        local nplots `"`.`name'.n'"'
        capt confirm integer number `nplots'
        if _rc==0 {
            forv plot = 1/`nplots' {
                if `"`.`name'.graphs[`plot'].graphfamily'"'=="twoway" {
                    local plots `plots' `plot'
                }
            }
        }
        if `"`plots'"'=="" {
            di as err "no twoway subgraphs found in `name'"
            exit 111
        }
    }
    else {
        foreach plot of local plots {
            capt classutil d `name'.graphs[`plot']
            if _rc {
                di as err `"subgraph `plot' not found"'
                exit 111
            }
            local grtype `"`.`name'.graphs[`plot'].graphfamily'"'
            if `"`grtype'"'!="twoway" {
                di as err `"subgraph `plot' not twoway"'
                exit 498
            }
        }
    }
    foreach plot of local plots {
        version `caller': .`name'.graphs[`plot'].parse `cmd'
    }
    graph display `name'
end
