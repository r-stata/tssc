*! version 1.0.5  20oct2016  Ben Jann
*  (still supported by -texdoc- but no longer documented)
program tex
    version 10.1
    if `"${TeXdoc_docname}"'=="" {
        di as txt "(texdoc not initialized; nothing to do)"
        exit
    }
    mata: fput(${TeXdoc_docname_FH}, st_local("0"))
end
