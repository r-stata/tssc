        eststo clear
        sysuse auto, clear
        eststo: reg price weight mpg, robust
        eststo: reg price weight mpg foreign, robust
        esttab using _example.txt, tab replace plain label
