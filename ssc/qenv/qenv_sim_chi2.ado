*! 1.0.0 MLB 06 March 2013
*! 1.0.0 MLB 05 March 2013
program define qenv_sim_chi2
	if c(stata_version) < 11 {
		version 9
	}
	else {
		version 11
	}
    use `1', clear
    bsample
	if c(stata_version) < 11 {
		glm ysim union grade black ttl_exp ttl_exp2, link(log) vce(robust) family(poisson)
		test ttl_exp ttl_exp2
	}
	else {
		glm ysim union grade black c.ttl_exp##c.ttl_exp, link(log) vce(robust) family(poisson)
		test ttl_exp c.ttl_exp#c.ttl_exp
	}
end	

