
          program define MonteCarloSim , rclass 
            syntax anything 
              clear
			  tokenize `anything'
			  local n = `1'
			  local t = `2'
              set obs `=`n'*`t''
			  egen id = seq(), block(`t')
			  by id, sort: gen t = _n
			  xtset id t
              drawnorm x e
              gen y = 1 + 0.5 * x + e
              xtreg y x, fe
              return scalar x = _b[x]
          end 

          clear
          forvalues n = 30 (10) 50 {
			forvalues t = 30(10)50 {
				simulate bx = r(x) , reps(1000) : MonteCarloSim `n' `t'
				save "PATH1\multishell\test\results\results_`n'_`t'", replace  
			}
          } 
