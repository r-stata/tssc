   // Jun 21 2012 00:27:44
   // QnD program to count spells in wide format data
   // Consecutive sequences in the same state count as a spell
   // Missing counts as a valid value, so gaps count as spells
   // Syntax
   // nspells varlist (min=2), gen:erate(string)
   // Option: generate(string) generates a new variable
   // Example: . nspells m1-m36, gen(nsp)
   //          . tab nsp
program nspells
   syntax varlist (min=2), GENerate(string)
   gen `generate' = 1
   local nvars : word count `varlist'
   local state : word 1 of `varlist'
   forvalues x = 2/`nvars' {
      local oldstate `state'
      local state : word `x' of `varlist'
      qui replace `generate' = `generate' + (`state' != `oldstate')
      }
end
      
