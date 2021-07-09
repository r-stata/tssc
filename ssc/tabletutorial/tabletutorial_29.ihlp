        eststo clear
        sysuse auto, clear
        
        eststo: reg weight mpg
        eststo: reg weight mpg foreign
        esttab using _example1.tex, replace title(Weight)
        
        eststo clear
        eststo: reg price weight mpg
        eststo: reg price weight mpg foreign
        esttab using _example2.tex, replace title(Price)
