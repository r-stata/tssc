*! ifwins Version 1.0.2 dan_blanchette@unc.edu 23Feb2010
*! the carolina population center, unc-ch
* - made it so that in ranges like:  in -5/L  work
** ifwins Version 1.0.1 dan.blanchette@duke.edu  10Nov2009
** Center for Entrepreneurship and Innovation Duke University's Fuqua School of Business
** ifwins Version 1.0.0 dan.blanchette@duke.edu  25Feb2009

program ifwins
version 9
local version : di "version " string(_caller()) ":"
capture _on_colon_parse `0'
if c(rc) | `"`s(after)'"' == "" {
	if !c(rc) {
		local 0 `"`s(before)'"'
	}
	if replay() {
		if "`e(prefix)'" != "ifwins" {
			error 301  // last estimates not found error message
			// error command exits
		}
		else {
			// just re-display e()
			estimates replay
			exit
		}
	}
}

Ifwins `0'
end

program Ifwins
version 9

local cmdline `"ifwins `0'"'
capture _on_colon_parse `0'

// reset 0 before -syntax- so that options of the command submitted to -ifwins- don't create an invalid option message
local 0 `"`s(before)'"'

syntax [varlist]  [if] [in] 

local command `"`s(after)'"'
tokenize `"`command'"'
local cmd `1'


//remove `cmd' from `command'
local I_esample : subinstr local command `"`cmd'"' " "
// extract the if and in from `command'
I_esample `I_esample'
if `"`r(if)'"' != "" | `"`r(in)'"' != "" {
	di as err "options {cmd:if} and {cmd:in} are not allowed in the command submitted to {help ifwins:ifwins}"
	di as err "since {help ifwins:ifwins} subsets the data for the command submitted"
	exit 198
}

capture unabcmd `cmd'
if c(rc) == 0 {
	if  inlist(`"`r(cmd)'"',"browse","edit","list") {
		I_lbe `I_esample'
		local options `r(options)'
		local varlist `r(varlist)'
        	if `"`if'"' != "" { //take out the if in `if'
			local if : subinstr local if "if" " "
		}
        	else if `"`if'"' == "" {
			local if _N > 0
		}
        	if `"`in'"' != "" {
                	tempvar left_n right_n diff
                	scalar `left_n'  = `: word 2 of `: subinstr local in "/" " " ''
                	scalar `right_n' = `: word 3 of `: subinstr local in "/" " " ''
			quietly count if `if'
			if r(N) < `right_n' {
				scalar `diff' = `right_n' - `left_n'
				scalar `left_n' = r(N) - `diff'
				if `left_n' <= 0  {
				 	scalar `left_n' = 1
				}
				scalar `right_n' = r(N) 
			}
                	local sumif if `if' & inrange(sum((`if') != 0),`= `left_n'',`= `right_n'') 
        	}
        	else if `"`in'"' == "" {
                        	local sumif if `if'
        	}
		
		`cmd' `varlist' `sumif' , `options'
		exit
	}
}
	
// if command is not list, browse, or edit:
preserve
quietly {
	if `"`if'"' != ""  {
		keep `if'
		if _N == 0 {
			noisily di as err "no observations for the {help if:if} condition"
			exit 198
		} 
	}
	if `"`in'"' != "" {
                tempvar new_n left_n right_n diff 
                scalar `new_n' = _N
		scalar `left_n'  = `: word 2 of `: subinstr local in "/" " " ''
		scalar `right_n' = `: word 3 of `: subinstr local in "/" " " ''
		if `new_n' < `right_n'  {
			scalar `diff' = `right_n' - `left_n'
			if `diff' < 0 {
				scalar `diff' = 1  // make it so that it at least has one obs
			}
			scalar `left_n' = `new_n' - `diff'
			if `left_n' <= 0 {
				scalar `left_n' = 1  
			}
			local in = "in `= `left_n''/`= `new_n''"
		}
		keep `in'
	}
}
`command' 
restore

end


program I_esample, rclass
version 9
syntax [anything (name=vcetype equalok)] [aweight fweight pweight iweight/]  [if] [in]  [, *]
return local if `if'
return local in `in'
return local varlist `anything'
return local options `options'

end

program I_lbe, rclass
version 9
syntax [varlist]  [if] [in]  [, *]
return local varlist `varlist'
return local options `options'

end

