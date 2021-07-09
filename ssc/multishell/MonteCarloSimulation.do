**Please change paths


program define MonteCarloSim , rclass 
syntax anything 
  clear
  set obs `anything'
  drawnorm x e
  gen y = 1 + 0.5 * x + e
  reg y x
  return scalar x = _b[x]
end 

clear
forvalues n = 50 (10) 130 {
simulate bx = r(x) , reps(1000) : MonteCarloSim `n'
save "YOUR PATH\multishell\test\results\results_`n'", replace  
} 
