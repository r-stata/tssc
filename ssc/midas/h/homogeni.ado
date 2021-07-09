program homogeni, rclass

syntax anything [, Level(int 95) Format(string) ]

tempname Q K df I2 I22 varI2 lb_I2 ub_I2 levelci 
tokenize "`anything'"
scalar `Q' = `1'
scalar `df' = `2'
scalar `K' = `df' + 1


if `level' <10 | `level'>99 { 
 di in red "level() invalid"
 exit 198
}   

scalar `levelci' = `level' * 0.005 + 0.50

if "`format'" == "" { 
 local formatI2 = "%4.2f"
 local formatH = "%4.2f"
}   
else {
 local formatI2 = "`format'"
 local formatH = "`format'"
}

preserve
tempname varI2 lb_I2 ub_I2 
scalar H2 = `Q' / `df'
scalar I2 = max(0, (100*(`Q' -`df')/(`Q' )) )
scalar I22 = max(0, (H2-1)/H2)
if sqrt(H2) < 1 scalar H2 = 1
if `Q' > `K'  {
 scalar SElnH1 = .5*[(log(`Q')-ln(`df')) / ( sqrt(2*`Q') - sqrt(2*`K'-3) )]
}
else {
 scalar SElnH1 = sqrt( ( 1/(2*(`K'-2) )*(1-1/(3*(`K'-2)^2)) )  )
}
scalar `varI2'  = 4*SElnH1^2/exp(4*log(sqrt(H2)))
scalar `lb_I2' = I22-invnorm(`levelci')*sqrt(`varI2')
scalar `ub_I2' = I22+invnorm(`levelci')*sqrt(`varI2')

if  `lb_I2' < 0 {
 scalar  `lb_I2' = 0
}
else scalar `lb_I2' = `lb_I2'
if  `ub_I2' > 1 {
 scalar  `ub_I2' = 1
}
else scalar `ub_I2' = `ub_I2'

return scalar Isq = min(100, 100 * I22)
return scalar Isqlo = max(0, 100 * `lb_I2')
return scalar Isqhi = min(100, 100 * `ub_I2')
return scalar df = `df'
return scalar Q = `Q'

end



