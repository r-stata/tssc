program zicen2_lf
   version 12
	args todo b lnf 
	tempvar xb1 lnsigma1 sigma1 lj lpr1 pr1 pr0
	
	mleval `xb1' = `b', eq(1)
	mleval `lpr1' = `b', eq(2) 
	mleval `lnsigma1' = `b', scalar eq(3) 

	quietly {
	   gen double `sigma1' = exp(`lnsigma1')
	   gen double `pr1'    = exp(`lpr1') / (1+exp(`lpr1'))
	   gen double `pr0'    = 1 - `pr1'

	   gen double `lj' = `pr0' + `pr1'*normal(-`xb1'/`sigma1')      if  $ML_y1 ==0
	   replace    `lj' = `pr1'*normalden($ML_y1, `xb1', `sigma1')   if  $ML_y1 > 0
	   mlsum `lnf' = ln(`lj')
   } 
	if (`todo'==0 | `lnf' >=.) exit
end
