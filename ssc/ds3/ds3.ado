*! NJC 1.2.3 5 February 2002
*! NJC 1.2.2 24 September 2001
* each tab replaced by spaces
program define ds3, rclass
    version 7

    * update for Stata/SE 1 February 2002 
    local smax = cond("$S_StataSE" == "SE", 245, 81) 
    
    syntax [varlist] [if] [in] [, NUMeric STRing1 byte int long float double /* 
    */ STRing2(numlist int >0 <`smax') COmplement ANY(str asis) ALL(str asis) /*
    */ NONE(str asis) HAS(str) NOT(str) case Detail /* 
    */ COLs(numlist int max=1 >0 <13) PLACEholder(str) LOcal(str) GLobal(str) ]

    * checking for number of has(), not(), any(), all(), none() options 
    local ntopts = 0 
    foreach opt in has not any all none { 
        if `"``opt''"' != "" { 
            local testopts "`testopts'`opt'"
            local Testopts "`Testopts'`opt' " 
            local ntopts = `ntopts' + 1 
        }
    }
    
    if `ntopts' > 1 { 
        di as err "may not combine `Testopts'options" 
        exit 198 
    }    

    if "`placeholder'" != "" { 
        local np : word count `placeholder' 
        if `np' > 1 { 
            di as err "placeholder must be single symbol or word" 
            exit 198 
        }
        local X "`placeholder'" 
    }         
    else local X "X" 

    if `"`any'`all'`none'"' != "" { 
        if !index(`"`any'`all'`none'"',"`X'") { 
            di as err "`testopts' does not contain `X'" 
            exit 198
        }
        
        * identifying conditions which will fail with numbers | strings 
        * test condition, first substituting the number 1 
        local thistest : subinstr local `testopts' "`X'" "1", all 
        capture count if `thistest' 
        local numtest = cond(_rc, 0, 1) 
        
        * next substituting string "a" 
        local thistest : subinstr local `testopts' "`X'" `""a""', all 
        capture count if `thistest' 
        local strtest = cond(_rc, 0, 1) 
        if !`numtest' & !`strtest' { /* failed both */ 
                di as err "invalid `testopts' option" 
                exit 198 
        }         
    }        

    if `"`not'"' != "" { 
        local has "`not'"
        local not 1 
    }    
    else local not 0                        

    if `"`has'"' != "" {
        * what kind of thing? which particular thing(s)? 
        tokenize `has'  
        args what 
        mac shift 
        local which "`*'"

        * first element should start var | val | f | c  
        local what = lower("`what'")
        
        local l = length("`what'") 
        
        if "`what'" == substr("varlabel",1,max(4,`l')) { 
            local what "varl" 
        } 
        else if "`what'" == substr("vallabel",1,max(4,`l')) {
            local what "vall" 
        } 
        else if "`what'" == substr("format",1,max(1,`l')) { 
            if "`which'" == "" { BadHas `not' } 
            local what "f" 
        } 
        else if "`what'" == substr("char",1,max(1,`l')) { 
            local what "c" 
        }     
        else BadHas `not' 

        * to lower case: fewer problems if `which' is longer than 80 chars 
        if "`case'" != "" { 
            local case 1 
            foreach word in `which' { 
                local lower = lower("`word'") 
                local which2 "`which2' `lower'" 
            } 
            local which "`which2'"
        }     
        else local case 0 
    } 

    * what restrictions on types of variables? 
    local nopts : word count /* 
    */ `numeric' `string1' `byte' `int' `long' `float' `double' `string2' 

    if `nopts' == 0 { /* none */ 
        local list "`varlist'" 
    } 
    else { /* some */  
        foreach opt in numeric string1 { 
            local `opt' = "``opt''" != "" 
        }
        
        local types "`byte' `int' `long' `float' `double'" 
        if "`string2'" != "" { 
            foreach n of local string2 { 
                local types "`types'str`n' " 
            }
        }
        local ntypes : word count `types' 
 
        foreach x of local varlist {
            local OK 0 
            if `string1' | `numeric' {
                capture confirm string variable `x'
                local isstr = _rc == 0 
                if `isstr' & `string1' { 
                    local OK 1 
                } 
                if !`isstr' & `numeric' { 
                    local OK 1
                }      
            } 
            if `ntypes' { 
                local type : type `x'
                foreach t of local types { 
                    if "`t'" == "`type'" {
                        local OK 1
                    }
                }
            }
            if `OK' { local list "`list'`x' " } 
        }
    } 

    * complement of varlist? 
    if "`complement'" != "" { 
        foreach y of varlist _all { 
            local found 0 
            foreach x of local list { 
                if "`x'" == "`y'" { 
                    local found 1 
                    continue, break 
                }
            }    
            if !`found' { local clist "`clist'`y' " } 
        }
        local list "`clist'" 
    }    

    if `ntopts' == 0 { tokenize `list' } 
                
    * implementation of has() or not()    
    if `"`has'"' != "" {
        * variable or value labels 
        if "`what'" == "varl" | "`what'" == "vall" {  
            local kind = /* 
            */ cond("`what'" == "varl", "variable", "value") 
            if `"`which'"' == "" { /* any label */
                local op = cond(`not', "==", "!=") 
                foreach x of local list { 
                    local lbl : `kind' label `x' 
                    if `"`lbl'"' `op' "" { 
                        local list2 "`list2'`x' " 
                    } 
                }
            }    
            else { /* some label pattern */
                if `not' { /* must match no pattern */ 
                    foreach x of local list { 
                        local lbl : `kind' label `x' 
                        if `case' { 
                            local lbl = lower(`"`lbl'"') 
                        } 
                        local found 0 
                        foreach w of local which { 
                            if match(`"`lbl'"',`"`w'"') { 
                                local found 1 
                                continue, break 
                            }     
                        } 
                        if !`found' { 
                            local list2 "`list2' `x'" 
                        }     
                    } 
                }
                else { /* can match any pattern */ 
                    foreach x of local list { 
                        local lbl : `kind' label `x' 
                        if `case' { 
                            local lbl = lower(`"`lbl'"') 
                        } 
                        foreach w of local which { 
                            if match(`"`lbl'"',`"`w'"') { 
                                local list2 "`list2'`x' " 
                                continue, break 
                            } 
                        } 
                    }
                }    
            } 
        } /* end of code for variable or value labels */
        * formats 
        else if "`what'" == "f" { 
            if `not' { /* must match no pattern */ 
                foreach x of local list { 
                    local fmt : format `x' 
                    if `case' { 
                        local fmt = lower(`"`fmt'"') 
                    } 
                    local found 0 
                    foreach w of local which { 
                        if match(`"`fmt'"',`"`w'"') | /* 
                        */ match(`"`fmt'"',`"%`w'"') { 
                            local found 1 
                            continue, break 
                        }     
                    } 
                    if !`found' { 
                        local list2 "`list2' `x'" 
                    }     
                } 
            }
            else { /* can match any pattern */ 
                foreach x of local list { 
                    local fmt : format `x' 
                    if `case' { 
                        local fmt = lower(`"`fmt'"') 
                    } 
                    foreach w of local which { 
                        if match(`"`fmt'"',`"`w'"') | /* 
                        */ match(`"`fmt'"',`"%`w'"') { 
                            local list2 "`list2'`x' " 
                            continue, break 
                        } 
                    } 
                }
            }
        } /* end of code for formats */ 
        * characteristics 
        else {  
            if `"`which'"' == "" { /* any char */
                local op = cond(`not', "==", "!=") 
                foreach x of local list { 
                    local chr : char `x'[] 
                    if `"`chr'"' `op' "" { 
                        local list2 "`list2'`x' " 
                    } 
                }
            }    
            else { /* some char pattern */
                if `not' { /* must match no pattern */ 
                    foreach x of local list { 
                        local chr : char `x'[]
                        local found 0 
                        foreach c of local chr { 
                            if `case' { 
                                local c = lower(`"`c'"') 
                            } 
                            foreach w of local which { 
                                if match(`"`c'"',`"`w'"') { 
                                    local found 1 
                                    continue, break 
                                }     
                            } 
                        }    
                        if !`found' { 
                            local list2 "`list2' `x'" 
                        }     
                    } 
                }
                else { /* can match any pattern */ 
                    foreach x of local list { 
                        local chr : char `x'[] 
                        local found 0 
                        foreach c of local chr { 
                            if `case' { 
                                local c = lower(`"`c'"') 
                            } 
                            foreach w of local which { 
                                if match(`"`c'"',`"`w'"') { 
                                    local found 1 
                                    local list2 "`list2'`x' " 
                                    continue, break 
                                } 
                            } 
                            if `found' { continue, break } 
                        }
                    }    
                }    
            } 
        } /* end of code for characteristics */    
        
        tokenize `list2' 
    }

    * implementation of any(), all(), none()        
    if `"`any'`all'`none'"' != "" {
        marksample touse, strok novarlist 
        qui count if `touse' 
        local N = r(N)

        foreach v of local list { 
            capture confirm string variable `v' 
            local isstr = _rc == 0 
            if (`isstr' & `strtest') | (!`isstr' & `numtest') {
                local thistest : subinstr local `testopts' "`X'" "`v'", all
                qui count if `thistest' & `touse' 
                if "`testopts'" == "any" & r(N) > 0 { 
                    local list2 "`list2'`v' " 
                }
                else if "`testopts'" == "none" & r(N) == 0 {
                    local list2 "`list2'`v' " 
                }
                else if "`testopts'" == "all" & r(N) == `N' { 
                    local list2 "`list2'`v' " 
                }
            }        
        }
        
        tokenize `list2' 
    }        
 
    if "`*'" != "" { 
        if "`detail'" != "" { describe `*' }
        else {
            if "`cols'" == "" { local cols = 8 }        

            if `cols' == 1 { local length = 78 }
            else if `cols' == 2 { local length = 38 }         
            else if `cols' == 3 { local length = 24 }
            else if `cols' == 4 { local length = 18 }
            else if `cols' == 5 { local length = 14 }
            else if `cols' == 6 { local length = 11 }
            else if `cols' == 7 { local length = 9 }
            else if `cols' == 8 { local length = 8 }         
            else if `cols' == 9 { local length = 6 }         
            else if `cols' == 10 { local length = 6 }         
            else if `cols' == 11 { local length = 5 }         
            else if `cols' == 12 { local length = 4 }         
            
            local lp1 = `length' + 1 
            local i 1
            while "``i''" != "" {
                if (mod(`i' - 1, `cols') == 0 & `i' != 1) { di }
                local abname = abbrev("``i''",`length')
                local l = `lp1' - length("`abname'") + (mod(`i', `cols') != 0)
                di in gr "`abname'" _skip(`l') _c
                local i = `i' + 1
            }
            di
        }
        return local varlist `*'
    }    

    * undocumented, for now         
    if "`local'" != "" { c_local `local' "`*'" } 
    if "`global'" != "" { global `global' "`*'" } 
end

program def BadHas
    args not 
    if `not' { 
        di as err "invalid not() option" 
    } 
    else di as err "invalid has() option" 
    exit 198
end     
exit

