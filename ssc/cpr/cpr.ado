* results for each n-tuple of values from Cartesian product
program define cpr
*! 2.0.0 NJC 21 January 1999
* 1.2.0 NJC 12 June 1998
* 1.1.0 NJC 4 June 1998
        version 6.0

        tokenize "`0'", parse("\,:")

        local nocolon = 1
        local i = 1
        while "``i''" != "" {
                if "``i''" == ":" { local nocolon = 0 }
                local i = `i' + 1
        }

        local last = `i' - 1

        if `nocolon' | "`1'" == ":" | "``last''" == ":" {
                di in r "invalid syntax"
                exit 198
        }

        local i = 1  /* arguments */
        local j = 0  /* lists */
        while "``i''" != ":" {
                 if "``i''" == "," { /* start of -cp- options */
                        local i = `i' + 1
                        local nopts : word count ``i''
                        local k = 1
                        while `k' <= `nopts' {
                                local opt : word `k' of ``i''
                                if substr("`opt'",1,1) == "p" {
                                        global pause "pause"
                                }
                                else if substr("`opt'",1,3) == "noh" {
                                        global header "no"
                                }
                                else if substr("`opt'",1,3) == "nos" {
                                        global stop "no"
                                }
                                else {
                                        di in r "invalid syntax"
                                        exit 198
                                }
                                local k = `k' + 1
                        }
                }
                else if "``i''" != "\" { /* a list */
                        local j = `j' + 1
                        if `j' == 6 {
                                di in r "6 or more lists not supported"
                                exit 198
                        }
                        capture numlist "``i''"
                        if _rc == 0 { local list`j' "`r(numlist)'" }
                        else local list`j' "``i''"
                        local n`j' : word count `list`j''
                        local k = 1
                        while `k' <= `n`j'' {
                                local l`j'`k' : word `k' of `list`j''
                                local k = `k' + 1
                        }
                }
                local i = `i' + 1
        }

        if "`n2'" == "" | "`n2'" == "0" { local n2 = 1 }
        if "`n3'" == "" | "`n3'" == "0" { local n3 = 1 }
        if "`n4'" == "" | "`n4'" == "0" { local n4 = 1 }
        if "`n5'" == "" | "`n5'" == "0" { local n5 = 1 }

        /* the Stata command */
        local i = `i' + 1
        while `i' <= `last' {
                local cmd "`cmd'``i'' "
                local i = `i' + 1
        }
        global cmd "`cmd'"

        di

        local i = 1
        while `i' <= `n1' {
                local j = 1
                while `j' <= `n2' {
                        local k = 1
                        while `k' <= `n3' {
                                local l = 1
                                while `l' <= `n4' {
                                        local m = 1
                                        while `m' <= `n5' {
                                                Doit /*
                                        */ `l1`i'' `l2`j'' `l3`k'' `l4`l'' `l5`m''
                                                local m = `m' + 1
                                        }
                                        local l = `l' + 1
                                }
                                local k = `k' + 1
                        }
                        local j = `j' + 1
                }
                local i = `i' + 1
        }

        global pause
        global header
        global stop
end

program def Doit
        version 6.0
        args A1 A2 A3 A4 A5
        tokenize "$cmd"
        while "`1'" != "" {
                local incmd "`incmd'`1'"
                if "`2'" != "" { local incmd "`incmd'#" }
                mac shift
        }
        local length = length("`incmd'")
        local i = 1
        while `i' <= `length' {
                local char = substr("`incmd'",`i',1)
                if "`char'" == "@" {
                        local i = `i' + 1
                        local char = substr("`incmd'",`i',1)
                        if "`char'" >= "1" & "`char'" <= "5" {
                                local outcmd "`outcmd'`A`char''"
                        }
                }
                else if "`char'" == "#" { local outcmd "`outcmd' " }
                else { local outcmd "`outcmd'`char'" }
                local i = `i' + 1
        }
        if "$header" != "no" { di in bl "-> `outcmd'" }
        if "$stop" == "no" { local nostop "capture noi" }
        `nostop' `outcmd'
        if "$stop" == "no" & _rc {
                if _rc == 1 {
                        global pause
                        global header
                        global stop
                        exit 1
                }
                di in bl "r(" _rc ");"
        }
        if "$pause" == "pause" { more }
        di
end
