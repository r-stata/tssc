program define mclgen
  version 6
  syntax varlist(max=1)
  tempvar newy

  quietly tab `varlist'
  global ncat=r(r)
  if $ncat > 12 {
    display "Response factor `varlist' has more than 12 categories."
    exit
  }
  
  * transform the data into a person-choice file
  gen __strata=_n
  expand $ncat
  sort __strata
  gen byte `newy'=mod(_n-1,$ncat)+1
  gen byte __didep=(`varlist'==`newy')
  * finished with the original dependent
  * transform it into response factor
  quietly replace `varlist'=`newy'
  global respfact "`varlist'"

  display _newline "Your response factor is $respfact with $ncat categories."
  display "Its main effects form the intercept of a multinomial logistic model,"
  display "interactions with independent variables form their effects."
end
