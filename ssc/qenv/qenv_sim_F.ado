*! 1.1.0 MLB 06 March 2013
*! 1.0.0 MLB 05 March 2013
program define qenv_sim_F
	if c(stata_version) < 11 {
		version 9
	}
	else {
		version 11
	}
    use `1', clear
    bsample
	if c(stata_version) < 11 {
		xi: reg ysim mpg i.rep78 foreign weight lnprice
	}
	else {
		reg ysim mpg i.rep78 foreign weight lnprice
	}
    
    test weight lnprice
end
