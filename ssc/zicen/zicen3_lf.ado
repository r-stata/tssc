program zicen3_lf
   version 12
	args todo b lnf 
	tempvar xb1 xb2 lnsigma1 lnsigma2 sigma1 sigma2 lj lpr1 lpr2 pr0 pr1 pr2
	
	mleval `xb1'=`b', eq(1)
	mleval `xb2'=`b', eq(2)
	mleval `lpr1'=`b', eq(3) 
   mleval `lpr2'=`b', eq(4) 
	mleval `lnsigma1'=`b', scalar eq(5) 
	mleval `lnsigma2'=`b', scalar eq(6) 

	quietly { 
	gen double `sigma1' = exp(`lnsigma1')
	gen double `sigma2' = exp(`lnsigma2')
	gen double `pr1'    = exp(`lpr1')/(1+exp(`lpr1')+exp(`lpr2'))
	gen double `pr2'    = exp(`lpr2')/(1+exp(`lpr1')+exp(`lpr2'))
	gen double `pr0'    = 1-`pr1'-`pr2' 
	
	gen double `lj'=`pr0'+`pr1'*normal(-`xb1'/`sigma1')+`pr2'*normal(-`xb2'/`sigma2') /*
	            */ if  $ML_y1 ==0
	replace    `lj'=`pr1'*normalden($ML_y1,`xb1',`sigma1')+`pr2'* normalden($ML_y1,`xb2',`sigma2') /*
	            */ if  $ML_y1 > 0
	mlsum `lnf' = ln(`lj')
   }
	
	if (`todo'==0 | `lnf' >=.) exit
end
