*! autofmt 1.0.0 01oct2009 roywada@hotmail.com
*! automatic formating of a significant number of digits

program define autofmt, rclass
version 7.0

syntax, input(string) [dec(integer 3) less(integer 0) parse(string) strict]
* parse( ) takes only one character; " " is always included as a parse

if `"`parse'"'=="" {
        local parse " "
}

local rest `"`input'"'
local count 0

if "`rest'"~="" {
        * handles the possibility the first token is empty
        gettoken first rest: rest, parse("`parse'")
        local first=trim(`"`first'"')
        if `"`first'"'==`"`parse'"' {
                local count=`count'+1
                local input`count' ""
        }
        else {
                local count=`count'+1
                local input`count' `"`first'"'
        }
}
while "`rest'"~="" {
        gettoken first rest: rest, parse("`parse'")
        local first=trim(`"`first'"')
        if `"`first'"'~=`"`parse'"' {
                local count=`count'+1
                local input`count' `"`first'"'
        }
}

if `count'==0 {
        * input( ) was left empty
        exit
}

if "`strict'"=="strict" {
	local one 0
}
else {
	local one 1
}


*** run as many times

forval num=1/`count' {

        * confirm a number
        capture confirm number `input`num''
        local rc=_rc
        
        * run if not missing and is a number
        if "`input`num''"~="." & "`input`num''"~="" & `rc'==0 {
                local times=0
                local left=0
                
                * integer checked by modified mod function
                if round((`input`num'' - int(`input`num'')),0.0000000001)==0 {
                        local whole=1
                }
                else {
                        local whole=0
                        * non-interger
                         if `input`num''<. {
                                
                                * digits that need to be moved if it were only decimals: take the ceiling of log 10 of absolute value of decimals
                                local times=abs(int(ln(abs(`input`num''-int(`input`num'')))/ln(10)-1))  
                                
                                * the whole number: take the ceiling of log 10 of absolute value
                                local left=int(ln(abs(`input`num''))/ln(10)+1)
                        }
                }
                
                
                * assign the fixed decimal values into aadec
                if `whole'==1 {
                        local aadec=0
                }
                else if .>`left' & `left'>0 {
                        * reduce the left by one if more than zero to accept one extra digit
                        if `left'<=`dec' {
                                local aadec=`dec'-`left'+`one'
                        }
                        else {
                                local aadec=0
                        }
                }
                else {
                        local aadec=`times'+`dec'-1
                }
                
                if "`less'"=="" {
                        * needs to between 0 and 11
                        if `aadec'<0 {
                                local aadec=0
                        }
                        *if `aadec'<11 {
                        if `aadec'<7 {
                                * use fixed
                                local fmt "`aadec'f"
                        }
                        else {
                                * use exponential
                                local fmt "`=`dec'-1'e"
                        }
                }
                else {
                        * needs to between 0 and 11
                        local aadec=`aadec'-`less'
                        if `aadec'<0 {
                                local aadec=0
                        }
                        *if `aadec'<10 {
                        if `aadec'<7 {
                                * use fixed
                                local fmt "`aadec'f"
                        }
                        else {
                                * use exponential
                                local fmt "`=`dec'-1'e"
                        }
                }
                
                * make it exponential if too big
                if `input`num''>1000000 & `input`num''<. {
                        local fmt "`=`dec'-0'e"                
                }
                
                * make it exponential if too negative (small)
                if `input`num''<-1000000 & `input`num''<. {
                        local fmt "`=`dec'-0'e"                
                }
                
                local fmt`num' `fmt'
                local aadec`num' `aadec'
                
                local output`num'=string(`input`num'',"%12.`fmt'")
                
                return scalar deci`num'=`aadec'
                return local fmt`num'="`fmt'"
                return local input`num'="`input`num''"
                
                return local output`num'=`"`output`num''"'

        }
        else {
                * it is a missing value, empty, or non-number
                local output`num'=trim(`"`input`num''"')
                
                return scalar deci`num'=.
                return local fmt`num'="."
                if "`input`num''"=="" {
                        * return a dot when empty
                        return local input`num'="."
                }
                else {
                        return local input`num'="`input`num''"
                }
                
                return local output`num'=`"`output`num''"'

        }
}
end
exit


















