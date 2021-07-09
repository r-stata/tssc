/*******************************************************************************


Demo of excelclean 

Author: Lu Han 
Last update: 08 Jul 2018

*******************************************************************************/

capture program drop excelclean_demo 
program define excelclean_demo 

global demo_home "https://github.com/hanlulong/excelclean/raw/master" 

di "Example 1: Oragnising downloaded excel files from Bankscope"

capture mkdir "demo_bankscope"
di "Copying Example Files"
copy "${demo_home}/examples/Bankscope/A.xlsx" "demo_bankscope/A.xlsx"
copy "${demo_home}/examples/Bankscope/B.xlsx" "demo_bankscope/B.xlsx"
copy "${demo_home}/examples/Bankscope/C.xlsx" "demo_bankscope/C.xlsx"

di as result "Files of example 1 are saved under demo_bankscope/"
di " "
di " "
di " "
di as result  "Command Executed:" 
di as result `"excelclean , datadir("demo_bankscope") sheet("Results") cellrange("B1")  "'
di as result `"             pivot integrate wordfilter(`"" Quarter""')  droplist("N_ID TON_ID")"'
di " "
di " "
di " "

qui excelclean , datadir("demo_bankscope") sheet("Results") cellrange("B1")  ///
             pivot integrate wordfilter(`"" Quarter""')  droplist("N_ID TON_ID")

di as result "All Done! The integrated dataset is saved under demo_bankscope/clean.dta"			 

di " "
di " "
di " "
			 
di "Example 2: Oragnising downloaded excel files from SNL"

capture mkdir "demo_SNL"
di "Copying Example Files"
copy "${demo_home}/examples/SNL/A.xlsx" "demo_SNL/A.xlsx"


di as result "Files of example 2 are saved under demo_SNL/"

di " "
di " "
di " "
di as result `"Command Executed:"
di as result `"excelclean , datadir("demo_SNL") sheet("Sheet1") "'
di as result `"             cellrange("A2") pivot namerange(4) namelines("1 3") "'
di " "
di " "
di " "

qui excelclean , datadir("demo_SNL") sheet("Sheet1") cellrange("A2") pivot namerange(4) namelines("1 3")
              
di as result "All Done! The integrated dataset is saved under demo_SNL/clean.dta"			 

end 