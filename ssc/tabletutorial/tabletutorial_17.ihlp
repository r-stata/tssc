        eststo clear
        sysuse auto, clear
        eststo: regress price weight mpg
        eststo: regress price weight mpg foreign
        esttab
