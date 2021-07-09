        eststo clear
        
        eststo: reg weight mpg
        eststo: reg weight mpg foreign
        
        eststo: reg price weight mpg
        eststo: reg price weight mpg foreign
        
        esttab using example.tex, replace                   ///
            label booktabs nonumber                         ///
            page(dcolumn)                                   ///
            alignment(D{.}{.}{-1})                          ///
            mgroups(A B, pattern(1 0 1 0)                   ///
                prefix(\multicolumn{@span}{c}{) suffix(})   ///
                span erepeat(\cmidrule(lr){@span}))
