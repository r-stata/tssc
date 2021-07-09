*! N.Orsini, D.Rizzuto, N.Nante
*! Version 1.0 - November 4, 2004
*! Version 1.1 - November 8, 2004
*! Version 1.2 - February 20, 2005

capture program drop gamet
program gamet, rclass
syntax , PAYoff(string) [ ls1(string) ls2(string) player1(string) player2(string) savingpf(string) ///
domist elids neps nefms maximin gtree  npath  /// solutions or equilibirum
 mlabpls(integer 9) mlabppm(integer 3) mlabpp1(integer 12) mlabpp2(integer 9)  textpp(string) texts(string) /// graph options
msizepp(string) msizes(string) aspect(integer 1) /// graph options
*  ] /// all scatter options

version 8

return clear
preserve
clear
qui set obs 0

// get graph options or initiate some values

global npath = "`npath'"

if "`msizepp'" != "" {
				global msizepp = "`msizepp'"
			 }
		else {
			global msizepp = 2
			}

if "`msizes'" != "" {
				global msizes = "`msizes'" 
			 }
		else {
			global msizes = 2
			}
			
if "`textpp'" != "" {
				global textpp = "`textpp'"
			 }
		else {
			global textpp = "medium"
			}

if "`texts'" != "" {
				global texts = "`texts'"
			 }
		else {
			global texts = "small"
			}	
global aspect = `aspect'
global filen = "`savingpf'"
global mlabpls = `mlabpls'
global mlabppm = `mlabppm'
global mlabpp1 = `mlabpp1'
global mlabpp2 = `mlabpp2'
global options = "`options'"

// create payoff matrix

tempname rg cg G blc RG

    if "`payoff'"!="" { 
				matrix input `G' = (`payoff')	
				scalar `rg' = rowsof(`G')
				local rg = `rg'
				global rg = `rg'
				scalar `cg' = colsof(`G')
				local cg = `cg'
				local blc =  `cg'/2
				global blc = `blc'
				* check at least two strategies

				if (`rg' < 2  | `cg' < 4) {
								di in red "At least two strategies for the players"
								exit 198
								}
			   	 } 

// Get the label for the players  

  	   if "`ls1'"!="" { 
				global ls1 = "`ls1'"
				} 
			else {
				global ls1 = "S1"
				}

  	   if "`ls2'"!="" { 
				global ls2 = "`ls2'"	
				} 
			else {
				global ls2 = "S2"
				}

// Get the label for strategies (rows and columns)

    if "`player1'"=="" { 
								
				forv p = 1(1)`rg' {
		
				// by default uppercase letters for player1 
					
					local rp   : word `p'  of  `c(ALPHA)' 	
 					local rp`p' = "`rp'`p'"
					local listrp = "`listrp' `rp`p''"
					global listrp = "`listrp'"
					local eqrows = "`eqrows' eq`p':`rp`p''"
					* di "`rp`p''  --  `listrp'"
				}		

				} 
			else {

                                // check how many pieces of string the user typed

                                local countlabs1 : word count `player1'

                                if  `countlabs1' <  `rg' {
                                                          di as err "Type a string for each strategy of S1"
                                                          exit 198
                                                        }

				forv p = 1(1)`rg' {

					local rp   : word `p'  of  `player1'	
 					local rp`p' = "`rp'"
					local listrp = "`listrp' `rp`p''"
					global listrp = "`listrp'"
					local eqrows = "`eqrows' eq`p':`rp`p''"
					* di "`rp`p''  --  `listrp'"
					}	

				}

    if "`player2'"=="" { 
								
				forv p = 1(1)`blc' {

				//  by default lowercase letters for player2

					local cp   : word `p'  of  `c(alpha)' 	
 					local cp`p' = "`cp'`p'"
				      local listcp = "`listcp' `cp`p''"
					global listcp = "`listcp'"
					* di "`cp`p''  --  `listcp'"
						}		

				} 
			else {

				forv p = 1(1)`blc' {
					local cp   : word `p'  of  `player2'	
 					local cp`p' = "`cp'"
				      local listcp = "`listcp' `cp`p''"
					global listcp = "`listcp'"
					* di "`cp`p''  --  `listcp'"
					}	

				}

// Attach the payoff matrix row and column labels   

matrix rownames `G' = `eqrows' 

forv p = 1(1)`blc' {
			   local eqcols = "`eqcols' eq`p':`cp`p'' eq`p':`cp`p''"
			  }

matrix colnames `G' = `eqcols' 

return matrix PM = `G', copy	 


* CONVERT THE PAYOFF MATRIX IN VARIABLES AND DISPLAY THE TABLE

			convmv `G'            

* INITIALIZE GLOBALS CONTAINING SAVED RESULT (return clear doesn't clean the previuos global contents?!)

global neps1 = ""
global neps2 = ""
global neps3 = ""
global neps4 = ""
global ldom1 = ""
global ldom2 = ""
global dominant1 = ""
global dominant2 = ""
global ebacki = ""
global elids = ""
global p  
global q 
global expep1
global expep2   

* DOMINANT AND DOMINATED STRATEGIES
 
if "`domist'"!="" { 
			domist _pm1
}	

 
* CHECK RELATION BETWEEN OPTION DOMIST AND ITERELIM

if "`domist'"!="" & "`elids'"!=""  { 
			di _n as err "Select option elids or domist"
			exit 198 			
}


global elids = "`elids'"

* ITERATIVE ELIMINATION OF STRONGLY DOMINATED STRATEGIES
 
if "`elids'"!="" { 

		global enditer = 0 
		global countpf = 1

		while $enditer != 1 {	
		
			di _n in y "Iteration $countpf"

			domist _pm$countpf

			}

}	

* RETURN SAVED RESULT

* about the players and strategies
return local ls1 = "$ls1"
return local ls2 = "$ls2"
return local player1 = "`listrp'"
return local player2 = "`listcp'"
return scalar R = $rg
return scalar C = $blc


* from option domist and elids (latest dominant and dominated strategies)

return local ddsp1 = "$ldom1"
return local ddsp2 = "$ldom2"
return local dtp1 = "$dominant1"
return local dtp2 = "$dominant2"

* NASH EQUILIBRIUM IN PURE STRATEGIES

if "`neps'"!="" { 
			neps _pm1

	* saved nash equilibirum pure strategies
 
	forv i = 1(1)$cnep {
				return local neps`i' = "${neps`i'}"
				}
	}

* RETURN SAVED RESULT

return local ls1 = "$ls1"
return local ls2 = "$ls2"


* NASH EQUILIBRIUM IN MIXED STRATEGIES

if "`nefms'"!="" { 
			nefms _pm1

			return scalar expep1 = $expep1
			return scalar expep2 = $expep2
			return scalar p = $p
			return scalar q = $q
			}

* ZERO-SUM GAME - MAXIMIN 

if "`maximin'"!="" { 
			maximin _pm1

			return local mcmp1= $mcmp1
			return local mrmp2= $mrmp2

	forv i = 1(1)$csp {
				return local sp`i' = "${sp`i'}"
				}

}

* EXTENSIVE FORM - GAME TREE

if "`gtree'"!="" { 
			gtree _pm1 `G'
			return local ebacki = "$ebacki"
}


return local cmd = "gamet"

* SAVING FILES CORRESPONDING TO PAYOFFS MATRIX _pm1, _pm2, ...

if "$countpf" == "" global countpf = 1

if "`savingpf'" != "" {

forv  v = 1(1)$countpf {
			qui copy _pm`v'.dta $filen`v'.dta
				}
 			}	

* ERASE TEMPORARY FILES CORRESPONDING TO PAYOFFS MATRIX _pm1, _pm2, ...

forv  v = 1(1)$countpf {
			capture qui erase _pm`v'.dta
			}


end

capture program drop domist 
program domist 
di in w _n "DOMINATED AND DOMINANT STRATEGIES"
args payofffile

use `payofffile', clear	 

quietly {

bysort $ls2: egen maxp1 = max(ut1)
bysort $ls1: egen maxp2 = max(ut2)
bysort $ls1: gen imaxp1 = cond(maxp1==ut1, 1, .)
bysort $ls1: gen imaxp2 = cond(maxp2==ut2, 1, .)
bysort $ls1: replace maxp1 = cond(imaxp1==1, maxp1, .)
bysort $ls1: replace maxp2 = cond(imaxp2==1, maxp2, .)
bysort $ls1: gen ind = cond(_n==1, 1, .)

* Identify subscript (strategies) for maximum payoff for each player

gen smaxp1 = cond(imaxp1!=.,$ls1, .)
gen smaxp2 = cond(imaxp2!=.,$ls2, .)

}

* create a list with number that identifies strategies for each players and each value label 

qui tab  $ls1  $ls2

local nsp1 = r(r)
local nsp2 = r(c)

* for player 1 

forv i = 1(1)`c(N)' {

		if ind[`i'] == 1 {
			local passp1 = $ls1[`i']
			local nlstp1 = "`nlstp1' `passp1'"
			local vlabsp1 : label ($ls1) `passp1'
			local lvlabsp1 = "`lvlabsp1' `vlabsp1'"
			}
		}

forv i = 1(1)`nsp2' {
			local passp2 = $ls2[`i']
			local nlstp2 = "`nlstp2' `passp2'"
			local vlabsp2 : label ($ls2) `i'
			local lvlabsp2 = "`lvlabsp2' `vlabsp2'"
			}

 
* Create a list of subscripts which identify the maximun payoff for each player

forv i = 1(1)`c(N)' {

		 	if smaxp1[`i'] != . {
							local  smaxp1 = smaxp1[`i']
							local lsmaxp1 = "`lsmaxp1' `smaxp1'"
						  }
			
		 	if smaxp2[`i'] != . {
							local  smaxp2 = smaxp2[`i']
							local lsmaxp2 = "`lsmaxp2'  `smaxp2'"
						  }
}

* delete repaeated subscripts (or strategies)

local ulsmaxp1 : list uniq lsmaxp1
local ulsmaxp2 : list uniq lsmaxp2

* check and display dominated strategies for player 1 

local nodominated1 : list nlstp1 === ulsmaxp1

if `nodominated1' == 1 {
				di _col(5) as text "No dominated strategy for $ls1"
				}
			else {
				local  dominated1 : list nlstp1 - ulsmaxp1

			foreach v of local dominated1 {
		         local lcmp: label ($ls1) `v' 
			   local ldom1 = "`ldom1'  `lcmp'"

			* drop dominated strategies for player 1
			 qui  drop if $ls1 == `v'
			}

	 di in g _col(5) as text "Dominated strategy for $ls1 is " as res "`ldom1'"
	global ldom1 = "`ldom1'"
}


* check and display dominated strategies for player 2

local nodominated2 : list nlstp2 === ulsmaxp2

if `nodominated2' == 1 {
				di _col(5) as text "No dominated strategy for $ls2"
				}
			else {
				local  dominated2 : list nlstp2 - ulsmaxp2

			foreach v of local dominated2 {
		         local lcmp : label ($ls2) `v' 
			   local ldom2= "`ldom2'  `lcmp'"

			* drop dominated strategies for player 2
			 qui  drop if $ls2 == `v'

			}
	 di in g _col(5) as text "Dominated strategy for $ls2 is " as res "`ldom2'"
	global ldom2 = "`ldom2'"
}



* verify and display dominant strategies for player 1

local dup1 : list nlstp1 & lsmaxp1
local cdup1 : word count `dup1'


 if (`cdup1' == 1) {
		        local dominant1 : label ($ls1) `dup1' 
			  di _col(5) as text "Dominant strategy for $ls1 is " as res "`dominant1'" 
			}
		else {
			 di _col(5) as text "No dominant strategy for $ls1" 
			}

global dominant1 = "`dominant1'"
* verify and display dominant strategies for player 2

local dup2 : list nlstp2 & lsmaxp2
local cdup2 : word count `dup2'

if (`cdup2' == 1) {
		        local dominant2 : label ($ls2) `dup2' 
			  di _col(5) as text "Dominant strategy for $ls2 is " as res "`dominant2'" 
			}
		else {
			 di _col(5) as text "No dominant strategy for $ls2" 
			}
global dominant2 = "`dominant2'"


* check if there are dominated strategies for both players

if ("`ldom1'" == "") & ("`ldom2'" == "") {	
	global enditer = 1 
	}
 else {

 	keep $ls1 $ls2 ut1 ut2 cut

	* get the highest length of the string cut

	gen lcut = length(cut)
	sort lcut
	tempname maxlcut
	scalar `maxlcut' = lcut in l
	local maxlcut =  `maxlcut'

	* display the residual payoff matrix
	
	if ("$elids" != "") tabdisp $ls1 $ls2 , cellvar(cut) cellwidth(`maxlcut') center

	* save the dataset 
      * list $ls1 $ls2 ut1 ut2 cut,   sep(0) nol
      
	global countpf = $countpf + 1

	qui save `"`c(pwd)'\_pm$countpf"', replace

	}


end


capture program drop neps
program neps
di in w _n "NASH EQUILIBRIUM IN PURE STRATEGIES"
args payofffile
use `payofffile', clear	

quietly {

bysort $ls2: egen maxp1 = max(ut1)
bysort $ls1: egen maxp2 = max(ut2)
bysort $ls1: gen imaxp1 = cond(maxp1==ut1, 1, .)
bysort $ls1: gen imaxp2 = cond(maxp2==ut2, 1, .)
bysort $ls1: replace maxp1 = cond(imaxp1==1, maxp1, .)
bysort $ls1: replace maxp2 = cond(imaxp2==1, maxp2, .)
bysort $ls1: gen ind = cond(_n==1, 1, .)

* Identify subscript (strategies) for maximum payoff for each player

gen smaxp1 = cond(imaxp1!=.,$ls1, .)
gen smaxp2 = cond(imaxp2!=.,$ls2, .)

}

* create a list with number that identifies strategies for each players and each value label 

qui tab  $ls1  $ls2

local nsp1 = r(r)
local nsp2 = r(c)

* for player 1 

forv i = 1(1)`c(N)' {

		if ind[`i'] == 1 {
			local passp1 = $ls1[`i']
			local nlstp1 = "`nlstp1' `passp1'"
			local vlabsp1 : label ($ls1) `passp1'
			local lvlabsp1 = "`lvlabsp1' `vlabsp1'"
			}
		}

forv i = 1(1)`nsp2' {
			local passp2 = $ls2[`i']
			local nlstp2 = "`nlstp2' `passp2'"
			local vlabsp2 : label ($ls2) `i'
			local lvlabsp2 = "`lvlabsp2' `vlabsp2'"
			}


* Create a list of subscripts which identify the maximun payoff for each player

forv i = 1(1)`c(N)' {

		 	if smaxp1[`i'] != . {
							local  smaxp1 = smaxp1[`i']
							local lsmaxp1 = "`lsmaxp1' `smaxp1'"
						  }
			
		 	if smaxp2[`i'] != . {
							local  smaxp2 = smaxp2[`i']
							local lsmaxp2 = "`lsmaxp2'  `smaxp2'"
						  }
}

* Identify Nash equilibrium in pure strategies

qui gen neps = 1 if (imaxp1==imaxp2) & (imaxp1!=. & imaxp2 != .)

qui count if neps == 1
local nneps = r(N)

local cnep = 0

if `nneps' == 0 {
		   di in g _col(5) "None"
			}
	else	{

forv n = 1(1)`c(N)' {

if neps[`n'] == 1 {
		local cnep = `cnep'+1 

			local passnep1 = $ls1[`n']
			local passnep2 = $ls2[`n']
			local vlabsp1 : label ($ls1) `passnep1'
			local vlabsp2 : label ($ls2) `passnep2'
       
			di in g _col(5) "`cnep'. `vlabsp1' `vlabsp2' " in y cut[`n']
			global neps`cnep' = "`vlabsp1' `vlabsp2'"
			}
		}	
		
	}

global cnep = `cnep'

end 

capture program drop nefms
program nefms
di in w _n "NASH EQUILIBRIUM IN FULLY MIXED STRATEGIES"
args payofffile

use `payofffile', clear	

* check if there are 4 observations (R and C == 2)

if `c(N)' != 4 {
		    di as err "option nefms works only if R and C are equal to 2"
		    exit 198
		   }

* get the label 

			local passnepA1 = $ls1[1]
			local passnepB1 = $ls1[3]
			local passnepa1 = $ls2[1]
			local passnepb1 = $ls2[2]

			local vlabspA1 : label ($ls1) `passnepA1'
			local vlabspB1 : label ($ls1) `passnepB1'
			local vlabspa1 : label ($ls2) `passnepa1'
			local vlabspb1 : label ($ls2) `passnepb1'

* search probabilities for player 2

tempname MSNE MSNE1 MSNE2

* FORMULA PLAYER 1

scalar `MSNE1'  = ( ut2[4]-ut2[3] ) / [(ut2[1]+ut2[4]) - (ut2[3]+ut2[2]) ]

if  abs(`MSNE1' - 0) < 0.001 scalar `MSNE1' = 0

* Check 0<p<1 and 0<q<1 

local nofully1 = 0
local nofully2 = 0

if `MSNE1'<=0 | `MSNE1'>=1 { 
				 *  di _col(5) as text "No fully mixed strategies"
				  local nofully1 = 1  
				}


* FORMULA PLAYER 2

scalar `MSNE2' = (ut1[4]-ut1[2]) / [ (ut1[1]+ut1[4]) - (ut1[2]+ut1[3]) ]

if  abs(`MSNE2' - 0) < 0.001 scalar `MSNE2' = 0

if `MSNE2'<=0 | `MSNE2'>=1 { 
				*  di _col(5) as text "No fully mixed strategies"
				  local nofully2 = 1  
				}
	

if `nofully1' != 1 & `nofully2' != 1 { 

di  in g _col(5) as text " p = " as res %3.2f `MSNE1'
di  in g _col(5) as text " q = " as res %3.2f `MSNE2'


* mixed-strategy solution

di _n as res _col(5) "(" %3.2f `MSNE1' "*[`vlabspA1']+" %3.2f 1-`MSNE1' "*[`vlabspB1'], " %3.2f `MSNE2' "*[`vlabspa1']+" %3.2f 1-`MSNE2' "*[`vlabspb1'])"

di _n as text _col(5) "Expected equilibrium payoff for " as res "$ls1"
di   in g _col(5) %3.2f as text  `MSNE2' "*" ut1[1] "+(1-" %3.2f `MSNE2' ")*" ut1[2] " = " as res  chop(`MSNE2'*ut1[3]+(1-`MSNE2')*ut1[4], 0.00001)
di in g _col(5) %3.2f  as text  `MSNE2'  "*" ut1[3] "+(1-" %3.2f `MSNE2' ")*" ut1[4] " = "  as res  chop( `MSNE2'*ut1[3]+(1-`MSNE2')*ut1[4], 0.00001) 

di _n as text _col(5) "Expected equilibrium payoff for " as res "$ls2"
di  in g _col(5) as text %3.2f `MSNE1'  "*" ut2[1] "+(1-" %3.2f `MSNE1'  ")*" ut2[3] " = " as res chop(`MSNE1' *ut2[1]+(1-`MSNE1' )*ut2[3], 0.00001)  
di in g _col(5) as text %3.2f `MSNE1'  "*" ut2[2] "+(1-" %3.2f `MSNE1'  ")*" ut2[4] " = " as res  chop(`MSNE1' *ut2[2]+(1-`MSNE1' )*ut2[4], 0.00001)  
global expep1 = chop(`MSNE2'*ut1[3]+(1-`MSNE2')*ut1[4], 0.00001) 
global expep2 = chop(`MSNE1' *ut2[1]+(1-`MSNE1' )*ut2[3], 0.00001)
global p = `MSNE1'
global q = `MSNE2'
}
else {
	di _col(5) as text "No fully mixed strategies"
	global expep1 = .
	global expep2 = .
	global p = .
	global q = .
}


 


end 

capture program drop maximin
program maximin 

di in w _n "ZERO-SUM GAME - MAXIMIN CRITERION"

args payofffile
use `payofffile', clear	 
tempname mincolmax maxrowmin
  

* check if the sum within each cell of the table is zero

capture assert ut1 + ut2 == 0

if _rc != 0 {
		di in red "This is not a zero-sum game! check all pairs of payoffs"
		exit 198
		}

* seek the column maximum for player 1 

quietly {

bysort $ls2: egen maxp1 = max(ut1)
bysort $ls1: egen maxp2 = max(ut2)
bysort $ls1: gen imaxp1 = cond(maxp1==ut1, 1, .)
bysort $ls1: gen imaxp2 = cond(maxp2==ut2, 1, .)
bysort $ls1: replace maxp1 = cond(imaxp1==1, maxp1, .)
bysort $ls1: replace maxp2 = cond(imaxp2==1, maxp2, .)

* minimum row maximum for player 2 is just the opposite maximum payoff maxp2

gen rmmaxp2 = - maxp2

bysort $ls1: gen ind = cond(_n==1, 1, .)

* Identify subscript (strategies) for maximum payoff for each player

gen smaxp1 = cond(imaxp1!=.,$ls1, .)
gen smaxp2 = cond(imaxp2!=.,$ls2, .)

}
 
* pick up the minimum value of maxp1 and rmmaxp2

qui su maxp1,d
scalar `mincolmax' = r(min)
qui su maxp1 rmmaxp2,d
scalar `maxrowmin' = r(max)


di in g _col(5)  "Minimal Column Maximum of $ls1 = "  `mincolmax'
di  in g _col(5)  "Maximal Row Minimum of -{$ls2} = " -`maxrowmin'

global mcmp1= `mincolmax'
global mrmp2= -`maxrowmin'

* take the label for the saddle-point 

qui gen sp = 1 if (imaxp1==imaxp2) & (imaxp1!=. & imaxp2 != .)

qui count if sp == 1
local nsp = r(N)

local csp = 0

if `nsp' == 0 {
		   di in g _col(5) "No saddle-point"
			}
	else	{


forv n = 1(1)`c(N)' {

if sp[`n'] == 1 {
		local csp = `csp'+1 

			local passnep1 = $ls1[`n']
			local passnep2 = $ls2[`n']
			local vlabsp1 : label ($ls1) `passnep1'
			local vlabsp2 : label ($ls2) `passnep2'
       
			di in g _col(5) "Saddle-point = " in y "`vlabsp1' `vlabsp2'"  
			global sp`csp' = "`vlabsp1' `vlabsp2'"  
			}
		}	
		
	}

global csp = `csp'

end 

capture program drop gtree
program gtree

args payofffile G
use `payofffile' , clear	 

tempname rrg rcg 

scalar `rrg' = rowsof(`G')
local rrg = `rrg'
local rrg = `rrg'
scalar `rcg' = colsof(`G')
local rcg = `rcg'
local rblc =  `rcg'/2

local s1s2 = `rrg'*`rblc'
local ps =  `rrg' + `s1s2'

local OBS = (`ps'*2)+(`ps'-1)
* di "OBS = `OBS'"

* STRUCTURE AND COORDINATES OF GAME TREE

qui set obs `OBS'

qui gen y = .
qui gen x = .

gen id = _n

local minbl1 = 1
local maxbl1 = (`rrg'*2)+`rrg'

local minbl2 = `maxbl1' + 1 
local maxbl2 = `minbl2' + `s1s2'* 2 +  (`s1s2'-2)   


* assign values to coordinate y of block1 of game tree
quietly {
 
forv i = 1(3)`maxbl1' {
replace x  = 0  in `i' 
replace y  = 0  in `i' 
}

* assign values to coordinate x of block1 of game tree
 
forv i = 2(3)`maxbl1' {
replace x  = 50  in `i' 
}

* assign values to coordinate x of block2 of game tree
 
 
forv i = `minbl2'(3)`maxbl2' {
replace x  = 50  in `i' 
}

* assign values to coordinate x of block2 of game tree

local minbl2b = `minbl2' + 1

forv i = `minbl2b'(3)`maxbl2' {
replace x  = 100  in `i' 
}
}

* calculate the y coordinate of block1 and block2

*  found step block1 
local sbl1 = 200/`rrg'

*  found step block2
local sbl2 = 200/`s1s2'

* calculate the y coordinate of block1

local startybl1 = -100 + (`sbl1'/2)
local k = 2
local c = 1
forv i = `startybl1'(`sbl1')100 {

local s`c' = `i'
qui replace y = `i' in `k'
local k = `k'+3
local c = `c' + 1
}	

* calculate the y coordinate of block2   

local startybl2 = -100 + (`sbl2'/2)

local c = 1
forv i = `startybl2'(`sbl2')100 {

local b`c' = `i'
local c = `c' + 1
}	

quietly {
* replace y in block 2 - part 1

local x = `minbl2'
local step1 = 3

forv a = 1(1)`rrg' {

	forv c = 1(1)`rblc' {

	replace y = `s`a'' in `x'
	local x  = `x'+3
	}	
}

* replace y in block 2 - part 2

local x = `minbl2'+1

forv a = 1(1)`s1s2' {

	replace y = `b`a'' in `x'
	local x  = `x'+3
	}	
}

* ELEMENTS TO BE DISPLAYED ON THE GRAPH

* DISPLAY GAME TREE

quietly {

gen mark1 = " "
gen mark1p = .
replace mark1 = "$ls1" in 1
replace mark1p = $mlabpls in 1 

* mark1 axis 2
local x = 2
forv a = 1(1)`rrg' {
replace mark1 = "$ls2" in `x'
replace mark1p = $mlabpls in `x'
local x = `x' + 3 
}

* label axis 3

local x = `minbl2'+1
 
local k = `s1s2'

forv a = 1(1)`s1s2' {
replace mark1 = cut[`k'] in `x'
replace mark1p = $mlabppm in `x'
local k = `k'-1
local x = `x' + 3 
}

* mlabpls(integer 9) mlabppm(integer 3) mlabpp1(integer 12) mlabpp2(integer 9)

* label for strategies

gen mark2 = " "
gen mark2p = .

local listrp = "$listrp"
tokenize `listrp'

local k = 2
forv a = `rrg'(-1)1 {
 
replace mark2 = "``a''" in `k'
replace mark2p = $mlabpp1 in `k'
local k = `k'+3
}


local k = `OBS'

forv o = 1(1)`rrg' {

local listcp = "$listcp"
tokenize `listcp'

forv a = 1(1)`rblc' {

replace mark2 = "``a''" in `k'
replace mark2p = $mlabpp2 in `k'
local k = `k'-3
}

}

* BACKWARD INDUCTION SOLUTION

qui bysort $ls1: egen indmaxp2 = max(ut2)
qui bysort $ls1: gen imaxp2 = cond(indmaxp2==ut2, 1, .) if indmaxp2!= .

qui replace ut1 = . if imaxp2 == .

qui su ut1
gen imaxp1 = cond(ut1==r(max), 1, .) 

qui decode $ls1, gen(lp1)
qui decode $ls2, gen(lp2)

qui egen seq = seq() , from(1) to(`OBS') block(3)

* get the solution

forv a = 1(1)`s1s2' {

if (imaxp1[`a'] == 1) & (imaxp2[`a']==1) {
			local backs = cut[`a']
			local sol1 = lp1[`a']
			local sol2 = lp2[`a']
			}
		}

* identify the point of backward equilibrium to draw a line

forv a = 1(1)`OBS' {
 
if (mark2[`a']=="`sol1'") & (mark1[`a']=="$ls2") {
			local p1 = seq[`a']
			}

if (mark2[`a']=="`sol2'") & (mark1[`a']=="`backs'") {
			local p2 = seq[`a']
			}

		}

} // end quietly

* DISPLAY RESULTS OF BACKWARD INDUCTION

di in w _n "BACKWARD INDUCTION"
di in g _col(5) in g "Equilibrium path: " in y "`sol1' `sol2'"  
di in g _col(5) in g "Payoffs pair: " in y "`backs'"

global ebacki = "`sol1' `sol2'"

* FINAL GRAPH OF A GAME TREE

if "$npath" != "" {

 			 tw (scatter y x, c(l) cmissing(n)  xscale(off) yscale(off)  mlabel(mark1) mlabvposition(mark1p) mlabsize($textpp)   msize($msizepp)   ///
 				graphregion(style(none) color(white)) msymbol(i) plotregion(style(none) color(white)) legend(nodraw)  ylabel(, nogrid) ) ///
 			(scatter y x, c(l) cmissing(n)  xscale(off) yscale(off) msymbol(i)  clwidth(medium) clcolor(sand) mlabsize($texts)   msize($msizes)  mlabcolor(red) mlabgap(2) mlabel(mark2) ///
					mlabvposition(mark2p)  aspect($aspect)  $options  ) 
			 }
		else {

 tw (scatter y x, c(l) cmissing(n)  xscale(off) yscale(off)  mlabel(mark1) mlabvposition(mark1p) mlabsize($textpp)   msize($msizepp)   ///
 		graphregion(style(none) color(white)) msymbol(i) plotregion(style(none) color(white)) legend(nodraw)  ylabel(, nogrid) ) ///
 (scatter y x, c(l) cmissing(n)  xscale(off) yscale(off) msymbol(i)  clwidth(medium) clcolor(sand) mlabsize($texts)   msize($msizes)  mlabcolor(red) mlabgap(2) mlabel(mark2) ///
		mlabvposition(mark2p)   ) ///
 (scatter y x if seq==`p1', recast(line)    clcolor(green)  )  ///
 (scatter y x if seq==`p2', recast(line)    clcolor(green)   ) ///
 (scatter y x in 1, msymbol(T)   mcolor(green)  )  ///
 (scatter y x if (mark2=="`sol1'" & mark1=="$ls2"), msymbol(T) mcolor(green) aspect($aspect)  $options ) 

			 }

end


capture program drop convmv
program convmv
args G
tempname rrg rcg  

tempfile payoffmatrix  

tempvar sp1 sp2 ut ut1 ut2 p1 p2 
capture gen `ut1' = .
capture gen `ut2' = .

scalar `rrg' = rowsof(`G')
local rrg = `rrg'
local rrg = `rrg'
scalar `rcg' = colsof(`G')
local rcg = `rcg'
local rblc =  `rcg'/2
local lcol : colnames(`G')
local lrow : rownames(`G')

local OBS = `rrg'*`rblc'
qui set obs `OBS'

capture egen `sp1' = seq() , from(1) to(`rrg') b(`rblc')

capture bysort `sp1':  gen `sp2' = _n

local cobs = 1
forv i = 1(1)`rrg' {
		
	forv j = 1(2)`rcg' {
		scalar `p1' = `G'[`i', `j']
		qui replace `ut1' = `p1' in `cobs'
		local cobs = `cobs' +1 
			}
	}

local cobs = 1
forv i = 1(1)`rrg' {

	forv j = 2(2)`rcg' {
		
		scalar `p2' = `G'[`i', `j']
 		qui replace `ut2' = `p2' in `cobs'
		local cobs = `cobs' +1 
		 }
	}

capture gen `ut' = "("+ string(`ut1') + "; "  + string(`ut2') + ")"

* DISPLAY TABLE 

* define labels for the variable names and values

label var `sp1'  "$ls1"
label var `sp2'  "$ls2"

local i 1
foreach v of global listrp {
			local lstrp = "`lstrp' `i' `v' "
			local i = `i' + 1
			}

local i 1
foreach v of global listcp {
			local lstcp = "`lstcp' `i' `v' "
			local i = `i' + 1
			}

label define strarp `lstrp', modify
label values `sp1' strarp

label define stracp `lstcp', modify
label values `sp2' stracp

* list `sp1' `sp2' `ut1' `ut2' `ut', nol 

tabdisp `sp1' `sp2', cellvar(`ut') center

rename `sp1'    $ls1
rename `sp2'    $ls2
rename `ut1'    ut1
rename `ut2'    ut2
rename `ut'     cut

qui  save `"`c(pwd)'\_pm1"', replace

end

