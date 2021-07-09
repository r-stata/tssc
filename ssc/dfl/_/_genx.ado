*! version 2.0  20 dez 2010
* _genx program define bug
* version 1.0.1  9 fev 2005
* version 1.0.0  04/07/97  -- by John DiNardo

program define _genx

    version 4.0
        local varlist "req new max(1)"
        local options "MIN(real 0.0) MAX(real 0.0) NBINs(integer 1)"
        tempvar new
        parse "`*'"
        rename `varlist' `new'
    qui desc
    local oobs=_result(1)
    if "`min'"==""{ di in red "You must specify a minimum bound"
                exit 198
          }
    if "`max'"==""{ di in red "You must specify a maximum bound"
                exit 198
          }
    if `max'<=`min' { di in red "Your maximum bound must be greater than your minimum bound"
                exit 198
          }
    if "`nbins'"==""{ di in red "You must specify a number of bins"
                exit 198
          }
    if `nbins' <=1 { di in red "You must specify nbins"
                exit 198
        }
    if `nbins' >=`oobs' { di in red "You must specify fewer bins than obs"
                exit 198
        }
    qui replace `new'=`min' if _n==1
    qui replace `new'=(`max' -`min')/(`nbins'-1) if _n <=`nbins' & _n > 1
    qui replace `new'=sum(`new')
    qui replace `new'=. if _n > `nbins'
    rename `new' `varlist'
    disp in gr "A new variable called `varlist' has been created"
    disp in gr "with `nbins' bins ranging from `min' to `max'."

end
