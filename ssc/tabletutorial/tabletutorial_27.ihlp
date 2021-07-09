        eststo clear
        sysuse auto, clear
        generate y = uniform()
        quietly regress y price weight mpg foreign, noconstant
        estadd summ
        esttab, cells("mean sd min max") nogap nomtitle nonumber
