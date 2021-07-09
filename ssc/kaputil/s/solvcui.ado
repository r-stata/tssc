*! version 1.0.0 DH 29Sep2004.
program define solvcui, rclass
    version 8.0
    syntax anything(id="coefficients")
    local n : word count `anything'
    if `n'!=3 & `n'!=4 {
        di as error "3 or 4 coefficients required"
    }
	tokenize `anything'
    forvalues i=1/`n' {
        confirm number ``i''
    }
    if `n'==3 {
        local e=`1'
        local f=`2'
        local g=`3'
    }
    else {
        if `1'==0 {
            return scalar x3=.
            solvqui `2' `3' `4'
            return add
        	exit
        }
	    local e=`2'/`1'
   		local f=`3'/`1'
   		local g=`4'/`1'
    }
    local q=((`e')^2-3*`f')/9
    local r=(2*(`e'^3)-9*`e'*`f'+27*`g')/54
    if (`r')^2<`q'^3 {
        local theta=acos(`r'/sqrt(`q'^3))
        local x1=-2*sqrt(`q')*cos(`theta'/3)-`e'/3
        local x2=-2*sqrt(`q')*cos((`theta'+2*c(pi))/3)-`e'/3
        local x3=-2*sqrt(`q')*cos((`theta'-2*c(pi))/3)-`e'/3
		sortroots, roots(`x1' `x2' `x3')
        return add
    }
    else {
        local a=-sign(`r')*(abs(`r')+sqrt((`r')^2-`q'^3))^(1/3)
        if `a'!=0 {
            local b=`q'/`a'
        }
        else {
            local b 0
        }
        return scalar x3=.
        return scalar x2=.
        return scalar x1=`a'+`b'-`e'/3
    }
end

program define sortroots, rclass
    syntax , roots(numlist min=3 max=3 sort)
    tokenize `roots'
    return scalar x3=`3'
    return scalar x2=`2'
    return scalar x1=`1'
end
