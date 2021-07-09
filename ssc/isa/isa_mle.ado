* capture program drop isa_mle

*********************************************************************
*	CORE LIKELIHOOD FUNCTION OF IMBENS(2003)

program define isa_mle
	version 9
	args lnf mu1 mu2 sigma
	quietly replace `lnf'=ln(1/2*(1/sqrt(2*_pi*`sigma'^2))*exp((-1/(2*`sigma'^2))*($ML_y1-`mu1')^2)*((exp(`mu2')^$ML_y2)/(1+exp(`mu2'))) /*
	*/ +1/2*(1/sqrt(2*_pi*`sigma'^2))*exp((-1/(2*`sigma'^2))*($ML_y1-`mu1'- scalar(delta))^2)*((exp(`mu2'+scalar(alpha))^$ML_y2)/(1+exp(`mu2'+scalar(alpha)))))
end
