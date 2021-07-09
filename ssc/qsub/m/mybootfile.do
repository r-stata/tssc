postfile results i proportion using _output/boot`1'.dta, replace

webuse bsample1 ,clear
set rngstream `1'
set seed 1
bsample

ci proportion female ,  wald
post results (`1') (`r(proportion)') 
postclose results


