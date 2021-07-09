program define mcq_lik

version 8.0

	args todo b lnf
	tempvar  theta1 tmp1 myb2 d0a d0b d1 d2 d3 d4 d5 
	capture matrix `myb2'=`b'
	mleval `theta1'=`b', eq(1)
	quietly gen double `tmp1'=exp(`theta1')/(1+(exp(`theta1')))
	mlsum `lnf'= $ML_y1*ln(`tmp1')+ (1-$ML_y1)*ln(1-`tmp1')

note:  Calculation of penalties.

scalar `d1'=((`myb2'[1,2]/`myb2'[1,1])<0.0001)*((`myb2'[1,2]/`myb2'[1,1])- 0.0001)^2
	scalar `d2'=((`myb2'[1,2]/`myb2'[1,1])>1)*((`myb2'[1,2]/`myb2'[1,1])-1)^2
	scalar `d3'=((`myb2'[1,1])<-10)*((`myb2'[1,1])+10)^2
	scalar `d4'=((`myb2'[1,1])>-.2)*((`myb2'[1,1])+.2)^2
	scalar `d5'=((`myb2'[1,2])>-.001)*((`myb2'[1,2])+.001)^2
	scalar `d0a'=(`d2'+`d4')
	scalar `d0b'=(`d1'+`d3'+`d5')
	
	scalar `lnf'=`lnf'-((`d0a'+`d0b')*5000)
	if `lnf'==. { 

		exit

		}

end


