        eststo clear
        sysuse auto, clear
        eststo: reg price weight mpg
        eststo: reg price weight mpg foreign
        esttab using _example.txt, tab replace plain
