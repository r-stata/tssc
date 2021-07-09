program _desspss, rclass
   version 8.2

	syntax using/


   /* Written by Sergiy Radyakin, The World Bank, January 2008
      Version 1.0   (Requires UseSPSS.plu)

      usespss.ado might have more useful comments

   */

     capture confirm file `"`using'"'
     if _rc {
       display as error "Error! SPSS file does not exist"
       error(601)
     }

     plugin call DesSPSSExternal, `"`using'"' `""' 10 1
     
     if `"`finished'"'!="101" {

       display as error "Something went wrong while analysing the file"
       display as error "Most probably the file is not in SPSS *.sav format"
       display as error "Please examine the diagnostic messages above"
       error 9999
       
     }

     display as text "DESSPSS Report"
     display as text `"=============="'

     display as text "SPSS System file: " as result `"`macval(using)'"'
     return local filename `"`macval(using)'"'

     display as text "Created (date): " as result `"`SPSS_creation_date'"'
     return local date `"`SPSS_creation_date'"'

     display as text "Created (time): " as result `"`SPSS_creation_time'"'
     return local time `"`SPSS_creation_time'"'

     display as text "SPSS product: " as result _asis `"`macval(SPSS_product)'"'
     return local product `"`=trim(`"`macval(SPSS_product)'"')'"'

     display as text "File label (if present): " as result `"`SPSS_file_label'"'

     display as text "File size (as stored on disk): " as result `"`SPSS_file_size' bytes"'
     return scalar filesize =`SPSS_file_size'

     display as text "Data size: " as result `"`SPSS_data_size' bytes"'
     return scalar datasize = `SPSS_data_size'

     if `SPSS_file_compressed'==-1 {
       display as text "Data stored in compressed format"
       return scalar compressed=1
     }
     else {
       display as text "Data stored in not compressed format"
       return scalar compressed=0
     }

     if (`SPSS_bo'==-1) {
       display as text "This file is likely to originate from a Windows platform (LoHi byte order)"
       return local byte_order="LoHi"
     }
     else {
       display as text "This file is likely to originate from a Mac/Unix platform (HiLo byte order)"
       return local byte_order="HiLo"
     }

     display

     display as text "Number of cases (observations): " as result `"`SPSS_case_count'"'
     return scalar N = `SPSS_case_count'

     display as text "Number of variables: " as result `"`SPSS_var_count'"'
     return scalar k = `SPSS_var_count'

     display as text "Case size: " as result `"`=`SPSS_case_size'*8' bytes"'
     return scalar width = `=`SPSS_case_size'*8'

     display as text "----------------------------------------------------------------------"

     display
     display "Variables:"
     display

	//The code below is borrowed from Stata's standard describe command

			local wid = 2
                        local n : list sizeof SPSS_varlist
                        if `n'==0 {
                                exit
                        }

                        foreach x of local SPSS_varlist {
                                local wid = max(`wid', length(`"`x'"'))
                        }

                        local wid = `wid' + 2
                        local cols = int((`c(linesize)'+1)/`wid')
                        if `cols' < 2 {
                                foreach x of local `SPSS_varlist' {
                                        di as txt `col' `"`x'"'
                                }
                                exit
                        }
                        local lines = `n'/`cols'
                        local lines = int(cond(`lines'>int(`lines'), `lines'+1, `lines'))
                        forvalues i=1(1)`lines' {
                                local top = min((`cols')*`lines'+`i', `n')
                                local col = 1
                                forvalues j=`i'(`lines')`top' {
                                        local x : word `j' of `SPSS_varlist'
                                        di as txt _column(`col') "`x'" _c
                                        local col = `col' + `wid'
                                }
                                di as txt
                        }
         return local varlist `SPSS_varlist'

end

program define DesSPSSExternal, plugin using("UseSPSS.plu")

// --- END OF FILE ---