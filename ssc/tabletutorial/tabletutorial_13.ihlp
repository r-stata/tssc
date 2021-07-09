        sysuse auto, clear
        regress price weight mpg for
        mat V = e(V)
        mat2txt, matrix(V) saving(example.txt) replace ///
            title(This is a variance matrix)
