*! -tmap-: Master program                                                      
*! Version 2.0 - 4 January 2004 (beta)                                         
*! Version 1.2 - 23 July 2004                                                  
*! Version 1.1 - 14 July 2004 (reviewed by NJC)                                
*! Version 1.0 - 24 January 2004                                               
*! Author: Maurizio Pisati                                                     
*! Department of Sociology and Social Research                                 
*! University of Milano Bicocca (Italy)                                        
*! maurizio.pisati@unimib.it                                                   




*  ----------------------------------------------------------------------------
*  1. Define program                                                           
*  ----------------------------------------------------------------------------

program tmap
version 8.2




*  ----------------------------------------------------------------------------
*  2. Parse syntax                                                             
*  ----------------------------------------------------------------------------

gettoken COMMAND OPT : 0, parse(" ,")

local OKlist "choropleth propsymbol deviation label dot" 

/*  Allow abbreviations to at least 3 letters */
local len = length("`COMMAND'") 
if `len' < 3 error 198 
	
local found 0 
foreach OK of local OKlist { 
	if "`COMMAND'" == substr("`OK'", 1 , `len') { 
		tmap_`OK' `OPT'
		local found 1 
		continue, break 
	}
}
	
/* Error falls through */
if !`found' {
	di as err "unknown tmap subcommand"
	exit 198 
} 	




*  ----------------------------------------------------------------------------
*  3. End program                                                              
*  ----------------------------------------------------------------------------

end
