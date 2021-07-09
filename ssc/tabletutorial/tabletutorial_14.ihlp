        estimates clear
        sysuse auto, clear
        bysort foreign: eststo: regress price weight mpg
        eststo dir
        estwrite * using mymodels, replace
