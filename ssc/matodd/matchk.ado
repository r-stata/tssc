program def matchk
* matrix?
* matchk `1'
*! 1.0.0 NJC 5 July 1998
    version 5.0
    if "`1'" == "" | "`2'" != "" {
        di in r "invalid syntax"
        exit 198
    }
    tempname C
    mat `C' = `1'
end
