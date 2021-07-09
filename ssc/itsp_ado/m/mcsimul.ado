
*! mcsimul v1.0.0  CFBaum 11aug2008
program mcsimul, rclass
     version 10.1
     syntax varname(numeric) [, mu(real 75)] 
     tempvar y1 y2 
     
     generate `y1' = `varlist' + invnorm(uniform()) * 0.20 * zmu
     generate `y2' = `varlist' + invnorm(uniform()) * 0.20 * z_factor
     ttest `y1' = `mu'
     return scalar p1 = r(p)
     ttest `y2' = `mu'
     return scalar p2 = r(p)
end
