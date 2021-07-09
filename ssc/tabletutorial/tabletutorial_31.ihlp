        eststo clear
        eststo: reg weight mpg, robust
        eststo: reg weight mpg foreign, robust
        esttab using _example1.tex, replace title(Weight) ///
            se wide label
        
        eststo clear
        eststo: reg price weight mpg, robust
        eststo: reg price weight mpg foreign, robust
        esttab using _example2.tex, replace title(Price) ///
            se wide label
