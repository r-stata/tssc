*! GHR and NJC 1.0.1 20 October 2010
* forked from fs.ado 1.0.5 (by NJC, Nov 2006)
* from the user's perspective, difference is handling of hidden files
* as matter of programming, the "syntax" parsing is different to allow the use of the "all" option
* the ParseSpec and DisplayInCols programs are exactly the same as in fs.ado 1.0.5
program fsx, rclass   
        syntax [anything] [, All ]
        version 8
        if `"`anything'"' == "" local anything * 
        foreach f of local anything {
                if index("`f'", "/") | index("`f'", "\") ///
                 | index("`f'", ":") | inlist(substr("`f'", 1, 1), ".", "~") { 
                        ParseSpec `f'
                        local files : dir "`d'" files "`f'"
                }
                else local files : dir . files "`f'"
                local files2 ""
                foreach f of local files {
                    if "`all'"=="all" {
                        local files2 "`files2' `f'"
                    }
                    else {
                        if index("`f'",".")!=1 {
                            local files2 "`files2' `f'"
                        }
                    }
                }
                local Files "`Files'`files2' " 
        }       
        DisplayInCols res 0 2 0 `Files' 
        if trim(`"`Files'"') != "" { 
                return local files `"`Files'"' 
        }       
end     

program ParseSpec
        args f 

        // first we need to strip off directory or folder information 

        // if both "/" and "\" occur we want to know where the 
        // last occurrence is -- which will be the first in 
        // the reversed string 
        // if only one of "/" and "\" occurs, index() will 
        // return 0 in the other case 
        
        local where1 = index(reverse("`f'"), "/")
        local where2 = index(reverse("`f'"), "\") 
        if `where1' & `where2' local where = min(`where1', `where2') 
        else                   local where = max(`where1', `where2') 

        // map to position in original string and 
        // extract the directory or folder 
        local where = min(length("`f'"), 1 + length("`f'") - `where') 
        local d = substr("`f'", 1, `where') 

        // absolute references start with "/" or "\" or "." or "~" 
        // or contain ":"  
        local abs = inlist(substr("`f'", 1, 1), "/", "\", ".", "~") 
        local abs = `abs' | index("`f'", ":")
        
        // prefix relative references 
        if !`abs' local d "./`d'" 
        
        // fix references to root 
        else if "`d'" == "/" | "`d'" == "\" { 
                local pwd "`c(pwd)'" 
                local pwd : subinstr local pwd "\" "/", all 
                local d = substr("`pwd'", 1, index("`pwd'","/"))
        } 

        // absent filename list 
        if "`f'" == "`d'" local f "*" 
        else              local f = substr("`f'", `= `where' + 1', .)

        //  return to caller
        c_local f "`f'"
        c_local d "`d'" 
end 

program DisplayInCols /* sty #indent #pad #wid <list>*/
        gettoken sty    0 : 0
        gettoken indent 0 : 0
        gettoken pad    0 : 0
        gettoken wid    0 : 0

        local indent = cond(`indent'==. | `indent'<0, 0, `indent')
        local pad    = cond(`pad'==. | `pad'<1, 2, `pad')
        local wid    = cond(`wid'==. | `wid'<0, 0, `wid')
        
        local n : list sizeof 0
        if `n'==0 { 
                exit
        }

        foreach x of local 0 {
                local wid = max(`wid', length(`"`x'"'))
        }

        local wid = `wid' + `pad'
        local cols = int((`c(linesize)'+1-`indent')/`wid')

        if `cols' < 2 { 
                if `indent' {
                        local col "column(`=`indent'+1)"
                }
                foreach x of local 0 {
                        di as `sty' `col' `"`x'"'
                }
                exit
        }
        local lines = `n'/`cols'
        local lines = int(cond(`lines'>int(`lines'), `lines'+1, `lines'))

        /* 
             1        lines+1      2*lines+1     ...  cols*lines+1
             2        lines+2      2*lines+2     ...  cols*lines+2
             3        lines+3      2*lines+3     ...  cols*lines+3
             ...      ...          ...           ...               ...
             lines    lines+lines  2*lines+lines ...  cols*lines+lines

             1        wid
        */


        * di "n=`n' cols=`cols' lines=`lines'"
        forvalues i=1(1)`lines' {
                local top = min((`cols')*`lines'+`i', `n')
                local col = `indent' + 1 
                * di "`i'(`lines')`top'"
                forvalues j=`i'(`lines')`top' {
                        local x : word `j' of `0'
                        di as `sty' _column(`col') "`x'" _c
                        local col = `col' + `wid'
                }
                di as `sty'
        }
end
