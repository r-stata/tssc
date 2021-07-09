********************************************************************************************************************************
* pbpredict fits the Preece and Baines 1978 family of growth curves.
* version 1.0
* Author: Adrian Sayers
* Date: 06.03.2013
*
********************************************************************************************************************************
	prog define pbpredict , sclass
	version 9.2
		syntax varlist(min=1 max=1 numeric) [if] [in] , [ model( integer 1)  FITted(string) RESiduals(string) VELocity(string) ACCeleration(string) iterate(integer 100)]

		tokenize `varlist'
			tempname  time
				gen `time' = `1'

// Model 1
	if `model'==1 {
	local gamma =1
	//Fitted
		if "`fitted'"!="" {
			predictnl `fitted' = _b[/h1] -  ((2*( _b[/h1]-_b[/htheta] ) ) / (exp(_b[/s0]*(`time'-_b[/theta])) + exp(_b[/s1]*(`time'-_b[/theta]) )   )) , se( `fitted'_se) force  iterate(`iterate')
						}
	//Residuals
		if "`residuals'"!="" {
			predict `residuals' , res
							}
	//Acceleration
		if "`acceleration'"!="" {
		predictnl `acceleration' = (_b[/h1] - (_b[/h1] -  ((2*( _b[/h1]-_b[/htheta] ) ) / (exp(_b[/s0]*(`time'-_b[/theta])) + exp(_b[/s1]*(`time'-_b[/theta]) )   )) )) * (	((_b[/s0]*exp(`gamma'*_b[/s0]*(`time'-_b[/theta])) + _b[/s1]*exp(`gamma'*_b[/s1]*(`time'-_b[/theta])) ) / ///
			( exp(`gamma'*_b[/s0]*(`time'-_b[/theta])) +exp(`gamma'*_b[/s1]*(`time'-_b[/theta])) ) )^2 ///
				*(-1-`gamma') + ((_b[/s0]*exp(`gamma'*_b[/s0]*(`time'-_b[/theta])) + _b[/s1]*exp(`gamma'*_b[/s1]*(`time'-_b[/theta])) ) / ///
			( exp(`gamma'*_b[/s0]*(`time'-_b[/theta])) +exp(`gamma'*_b[/s1]*(`time'-_b[/theta])) ) )*`gamma'*(_b[/s0]+_b[/s1])-`gamma'*_b[/s0]*_b[/s1]) ///
			, se(`acceleration'_se) force iterate(`iterate')
								}
	//Velocity
		if "`velocity'"!="" {
		predictnl `velocity' =((_b[/s0]*exp(`gamma'*_b[/s0]*(`time'-_b[/theta])) + _b[/s1]*exp(`gamma'*_b[/s1]*(`time'-_b[/theta])) ) / ///
			( exp(`gamma'*_b[/s0]*(`time'-_b[/theta])) +exp(`gamma'*_b[/s1]*(`time'-_b[/theta])) ) ) ///
			* ///
			(_b[/h1]-(_b[/h1] -  ((_b[/h1]-_b[/htheta]) / (((0.5*exp(`gamma'*_b[/s0]*(`time'-_b[/theta]))) + (0.5*exp(`gamma'*_b[/s1]*(`time'-_b[/theta]))))^(1/`gamma'))))) ///
			, se(`velocity'_se) force iterate(`iterate')
							}
					} // end model 1

// Model 2
	if `model'==2 {
	//Fitted
		if "`fitted'"!="" {
			predictnl `fitted' = _b[/h1] -  ((_b[/h1]-_b[/htheta]) / (((0.5*exp(_b[/ga]*_b[/s0]*(`time'-_b[/theta]))) + (0.5*exp(_b[/ga]*_b[/s1]*(`time'-_b[/theta]))))^(1/_b[/ga]))) , se( `fitted'_se)  force iterate(`iterate')
						}
	//Residuals
		if "`residuals'"!="" {
				predict `residuals', res
								}
	//Acceleration
		if "`acceleration'"!="" {
		local gamma =1
		predictnl `acceleration' = (_b[/h1] - (_b[/h1] -  ((_b[/h1]-_b[/htheta]) / (((0.5*exp(_b[/ga]*_b[/s0]*(`time'-_b[/theta]))) + (0.5*exp(_b[/ga]*_b[/s1]*(`time'-_b[/theta]))))^(1/_b[/ga]))))) * (	((_b[/s0]*exp(_b[/ga]*_b[/s0]*(`time'-_b[/theta])) + _b[/s1]*exp(_b[/ga]*_b[/s1]*(`time'-_b[/theta])) ) / ///
			( exp(_b[/ga]*_b[/s0]*(`time'-_b[/theta])) +exp(_b[/ga]*_b[/s1]*(`time'-_b[/theta])) ) )^2 ///
				*(-1-_b[/ga]) + ((_b[/s0]*exp(_b[/ga]*_b[/s0]*(`time'-_b[/theta])) + _b[/s1]*exp(_b[/ga]*_b[/s1]*(`time'-_b[/theta])) ) / ///
			( exp(_b[/ga]*_b[/s0]*(`time'-_b[/theta])) +exp(_b[/ga]*_b[/s1]*(`time'-_b[/theta])) ) )*_b[/ga]*(_b[/s0]+_b[/s1])-_b[/ga]*_b[/s0]*_b[/s1]) ///
			, se(`acceleration'_se) force iterate(`iterate')
								}
	//Velocity
		if "`velocity'"!="" {
		predictnl `velocity' =((_b[/s0]*exp(_b[/ga]*_b[/s0]*(`time'-_b[/theta])) + _b[/s1]*exp(_b[/ga]*_b[/s1]*(`time'-_b[/theta])) ) / ///
			( exp(_b[/ga]*_b[/s0]*(`time'-_b[/theta])) +exp(_b[/ga]*_b[/s1]*(`time'-_b[/theta])) ) ) ///
			* ///
			(_b[/h1]-(_b[/h1] -  ((_b[/h1]-_b[/htheta]) / (((0.5*exp(_b[/ga]*_b[/s0]*(`time'-_b[/theta]))) + (0.5*exp(_b[/ga]*_b[/s1]*(`time'-_b[/theta]))))^(1/_b[/ga]))))) ///
			, se(`velocity'_se) force iterate(`iterate')
							}
					} // end model 2
// Model 3

if `model' ==3 {
	//Fitted
		if "`fitted'"!="" {
			predictnl `fitted' = _b[/h1] - ((4*(_b[/h1]-_b[/htheta])) / ((exp(_b[/P0]*(`time'-_b[/theta])) +  exp(_b[/P1]*(`time'-_b[/theta])))* (1+ exp(_b[/Q1]*(`time'-_b[/theta])))))  , se( `fitted'_se) iterate(`iterate') force
							}
	//Residuals
		if "`residuals'"!="" {
			predict `residuals', res
							}
	     			} // end model 3


					end
