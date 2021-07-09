*!jrule version 1.0
*!Written 04May2018
*!Written by Julian Aichholzer
*** Define program -jrule- and syntax structure ***
capture program drop jrule
program define jrule // begin definition of program
version 12
syntax [, Delta(real 0.1) Power(real 0.80) MINchi(real 3.841) CAlpha(real .05) DFtest(integer 1)]
*** Compute chi2 values from critical alpha level
local chioftest = invchi2tail(`dftest',`calpha') // calculate chi2-value at critical alpha (`calpha')
*** Compute modifiction indices ***
quietly estat mindices, minchi2(`minchi') // minchi defined by setting of critical alpha
*** Define matrices used for decision rules ***
mat OUTPUT = r(mindices) // Matrix OUTPUT contains full -estat mi- output
local mirows = rowsof(OUTPUT) // extract number of rows in A

mat MI = OUTPUT[1...,1] // vector with modification indices
mat EPC = OUTPUT[1...,4] // vector with traditional EPC values
mat SEPC = OUTPUT[1...,5] // vector with standardized EPC values
mat ABSEPC = J(`mirows',1,0) // vector with absolute values of the EPC
forvalues i = 1/`mirows' {
		 matrix ABSEPC[`i',1]= abs(EPC[`i',1])
	}
mat SW= J(`mirows',1,0) // vector with scaling weight for Delta
forvalues i = 1/`mirows' {
		 matrix SW[`i',1]= SEPC[`i',1]/EPC[`i',1]
	}
mat DELTAW= J(`mirows',1,0) // vector with delta values used for calculating power
forvalues i = 1/`mirows' {
		 matrix DELTAW[`i',1]= (`delta'/ SW[`i',1]) 
	}
mat EPCDEL= J(`mirows',1,0) // vector with EPC/delta ratio
forvalues i = 1/`mirows' {
		 matrix EPCDEL[`i',1]= (ABSEPC[`i',1]/DELTAW[`i',1]) 
	}	
mat NCP= J(`mirows',1,0) // vector with NCP values = noncentrality parameter
forvalues i = 1/`mirows' {
		 matrix NCP[`i',1]= ((MI[`i',1]/ (EPC[`i',1]^2) )*(DELTAW[`i',1]^2)) // uses rescaled delta to calculate NCP 
	}
mat POW= J(`mirows',1,0) // vector with power values 
forvalues i = 1/`mirows' {
	matrix POW[`i',1]= 	nchi2tail(`dftest', NCP[`i',1], `chioftest') // noncentral chi-square distribution for NCP at critical alpha
	}
*** Decision rule vector ***
mat DEC= J(`mirows',1,0) // matrix with decision rules
forvalues i = 1/`mirows' {
	if el(POW,`i',1)<`power' & el(MI,`i',1)>=`chioftest' {
                            matrix DEC[`i',1]=  1
                    }
	else if el(POW,`i',1)>=`power' & el(MI,`i',1)>=`chioftest' {
                            matrix DEC[`i',1]=  2
                    }
	else if el(POW,`i',1)>=`power' & el(MI,`i',1)<`chioftest' {
                            matrix DEC[`i',1]=  3
                    }
	else if el(POW,`i',1)<`power' & el(MI,`i',1)<`chioftest' {
                            matrix DEC[`i',1]=  4
                    }			
			}		
*** Output matrix ***
mat RNAME=r(mindices_pclass) // add row names from estat mi
local rnames : rownames OUTPUT // dis "`rnames'"
mat RES= MI,EPC,SEPC,DELTAW,POW,DEC,EPCDEL
mat rownames RES = `rnames'
mat colnames RES  = "MI" "EPC" "StdYX_EPC" "dw" "Power" "Decision" "EPC/dw"
matlist RES, noheader format(%9.2f) twidth(30) lines(oneline) title("Judgement rule criteria:")
dis _newline "Decision rules (for all MI>=" as res %3.2f `minchi' as text "; Delta>" as res %3.2f ///
`delta' as text "; Power>=" as res %3.2f `power' as text "; crit. Alpha<" as res %3.2f `calpha' as text "):" _newline ///
 _newline as text ///
"1 = Misspecified (because p(MI)<" as res %3.2f `calpha' as text "; Power<" as res %3.2f `power' as text ")" _newline ///
"2 = Inspect EPC/dw ratio (because p(MI)<" as res %3.2f `calpha' as text "; Power>=" as res %3.2f `power' as text ")" _newline ///
"3 = NOT misspecified (because p(MI)>=" as res %3.2f `calpha' as text " (n.s.); Power>=" as res %3.2f `power' as text ")" _newline ///
"4 = Inconclusive (because p(MI)>=" as res %3.2f `calpha' as text " (n.s.); Power<" as res %3.2f `power' as text ")" ///
_newline ///
as text "{hline }" 
end // program ends here

