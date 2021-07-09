program def matcfm
* matrices conformable for multiplication?
* matcfm `1' `2'
*! 1.0.0 NJC 19 July 1998
    version 5.0
    if "`1'" == "" | "`2'" == "" | "`3'" != "" {
        di in r "invalid syntax"
        exit 198
    }
    tempname C
    mat `C' = `1' * `2'
end
