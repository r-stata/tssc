/*

							  Stata Weaver Package
					   Developed by E. F. Haghish (2014)
			  Center for Medical Biometry and Medical Informatics
						University of Freiburg, Germany
						
						  haghish@imbi.uni-freiburg.de

		
                  The Weaver Package comes with no warranty    	
	
	Description
	===========
	
	shows Stata codes and hides the Results. 
 
*/

		
program codes
*version 11	
	
	****************************************************************************
	* the "cod" command
	*
	* - execute the command
	* - append the command to Weaver log
	****************************************************************************
	
	version `c(stata_version)': `0'
				
    tempname canvas
	cap file open `canvas' using `"$weaverFullPath"', write text append  
	
	if "$weaverMarkup" == "html" {
		if "$weaverstyle" == "minimal" {
			cap file write `canvas' `"<pre class="sh_stata" >. "' 				///
			`"`macval(0)'"' _n 
		}
		else {
			cap file write `canvas' `"<pre class="sh_stata" >"' 				///
			`"`macval(0)'"' _n 
		}
		cap file write `canvas' "</pre>" _n(3) 
	}
	
	if "$weaverMarkup" == "latex" {
		cap file write `canvas'  												///
		`"\begin{verbatim}. `macval(0)'\end{verbatim}"' 
	}
		
	if "$weaver" == "" {
		di as txt _n(2) "{hline}"
		di as error "{bf:Warning}" 
		di as txt "{help weaver}'s html log file is off!" 
		di as txt "{hline}{smcl}"	_n
	}
	
end
	
