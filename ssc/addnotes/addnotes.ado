*! addnotes
*! version 1.4
*! 09 Dec 2005
*! Jeff Arnold, jeffrey DOT arnold AT ny DOT frb DOT org

program define addnotes
    version 8
    syntax using,                               ///
        [VARiables(varlist)                     ///
        data                                    ///
        text(string asis)]

    if `"`variables'"' == "" & `"`data'"' == "" & `"`text'"' == "" {
        di as error "Specify varlist(), data, and/or text()"
        error 198
    }

    tempname txtfile

    file open `txtfile' `using', write text append 

        * Adding Data Label
        if `"`data'"' ~= "" {
            local label : data label 
            file write `txtfile' "Dataset: `label'" _n
        }

        * Adding Variable Labels
        if `"`variables'"' ~= "" {
            file write `txtfile' "Variable Definitions" _n
            foreach var of local variables{
                local label : variable label `var' 
                file write `txtfile' `"`var' "`label'""' _n
            }
        }

        * Adding Additional Text Notes
        if `"`text'"' ~= "" {
            file write `txtfile' `text'
        }

    file close `txtfile' 
            
end

