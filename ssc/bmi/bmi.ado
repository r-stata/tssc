*! version 1.0.0  //  Ariel Linden 15feb2019 

program define bmi
version 11.0

	syntax newvarname, Ht(varlist max=1) Wt(varlist max=1) [ Metric Category(string) ]
	
		tempvar wtm htm2
		
		// Convert pounds to kilograms and inches to meters
		if "`metric'" == "" {
			gen `wtm' = `wt' * 0.45359237
			gen `htm2' = (`ht' * 0.0254)^2
			gen `varlist' = `wtm' / `htm2'
		}
		else gen double `varlist' = `wt' / `ht'^2
		
		if "`category'" != "" {
			gen double `category' = cond(`varlist' <16.001, 1, ///
                cond(inrange(`varlist',16.001,16.999), 2, ///
                cond(inrange(`varlist',17.000,18.499), 3, ///
                cond(inrange(`varlist',18.500,24.999), 4, ///
				cond(inrange(`varlist',25.000,29.999), 5, ///
				cond(inrange(`varlist',30.000,34.999), 6, ///
				cond(inrange(`varlist',35.000,39.999), 7, ///
				cond(`varlist' > 39.999, 8,.))))))))

			//  WHO categories from http://apps.who.int/bmi/index.jsp?introPage=intro_3.html
			label define bmi_cat 1 "Severe thinness" 2 "Moderate thinness" 3 ///
				"Mild thinness" 4 "Normal range" 5 "Pre-obese" 6 "Obese class I" ///
				7 "Obese class II" 8 "Obese class III", modify

			label values `category' bmi_cat	
		}
		
end
