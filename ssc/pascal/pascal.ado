*! Amadou Bassirou DIALLO, Cerdi, Univ. of Auvergne (France)

prog pascal

syntax [, n(real 5)]
loc k = `n'-1
di _n
di in y comb(1,0)
di _n
forv i = 1 / `n' {
   forv j = 0 /`k' {
      if `j'< `i' {
         loc a = comb(`i',`j') 
         loc li `li' `a'
      }
   }
   loc a = comb(`i',`i') 
   loc li `li' `a'
   di in y "`li'"
   loc li 
   di _n
}

end
