capture program drop albatross_examples
program albatross_examples
	version 11
	`1'
end

program define albatross_example_mean_1
	preserve
	qui{
		clear
		set obs 20
		set seed 100
		gen n = 10+490*runiform()
		gen mean_dif = 0.2*runiform()
		gen sd = 1+4*runiform()
		gen se = sd/sqrt(n)
		gen p = 2*normal(-abs(mean_dif/se))
	}
	albatross n p mean_dif, type(mean) sd(sd)
	restore
end

program define albatross_example_mean_2
	preserve
	qui{
		clear
		set obs 20
		set seed 100
		gen n = 10+490*runiform()
		gen mean_dif = 0.2*runiform()
		gen sd = 1+4*runiform()
		gen se = sd/sqrt(n)
		gen p = 2*normal(-abs(mean_dif/se))
	}
	albatross n p mean_dif, type(mean) sd(sd) adjust
	restore
end

program define albatross_example_proportion_1
	preserve
	qui{
		clear
		set obs 20
		set seed 100
		gen n = 10+490*runiform()
		gen prop_dif = 0.1+0.1*runiform()
		gen se = sqrt(prop_dif*(1-prop_dif)/n)
		gen p = 2*normal(-abs(prop_dif/se))
	}
	albatross n p prop_dif, type(proportion)
	restore
end

program define albatross_example_proportion_2
	preserve
	qui{
		clear
		set obs 20
		set seed 100
		gen n = 10+490*runiform()
		gen prop_dif = 0.1+0.1*runiform()
		gen se = sqrt(prop_dif*(1-prop_dif)/n)
		gen p = 2*normal(-abs(prop_dif/se))
	}
	albatross n p prop_dif, type(proportion) spro(0.15)
	restore
end

program define albatross_example_corr_1
	preserve
	qui{
		clear
		set obs 20
		set seed 100
		gen n = 10+490*runiform()
		gen corr = 0.2*runiform()
		gen se = sqrt((1-corr^2)/n)
		gen p = 2*normal(-abs(corr/se))
		gen by = "Large"
		replace by = "Small" if corr<0.5
	}
	albatross n p corr, type(correlation)
	restore
end

program define albatross_example_corr_2
	preserve
	qui{
		clear
		set obs 20
		set seed 100
		gen n = 10+490*runiform()
		gen corr = 0.2*runiform()
		gen se = sqrt((1-corr^2)/n)
		gen p = 2*normal(-abs(corr/se))
		gen by = "Large"
		replace by = "Small" if corr<0.1
	}
	albatross n p corr, type(correlation) by(by) color
	restore
end

program define albatross_example_md_1
	preserve
	qui{
		clear
		set obs 20
		set seed 100
		gen n = 10+490*runiform()
		gen sd1 = 0.5+0.5*runiform()
		gen sd2 = 0.5+0.5*runiform()
		gen r = 1+3*runiform()
		gen n1 = r*n/(1+r)
		gen n2 = n/(1+r)
		gen sd = (sd1*n1+sd2*n2)/n
		gen md = 0.1+0.1*rnormal()
		gen se = sqrt(sd1^2/n1 + sd2^2/n2)
		gen p = 2*normal(-abs(md/se))
	}
	albatross n p md, type(md) sd(sd)
	restore
end

program define albatross_example_md_2
	preserve
	qui{
		clear
		set obs 20
		set seed 100
		gen n = 10+490*runiform()
		gen sd1 = 0.5+0.5*runiform()
		gen sd2 = 0.5+0.5*runiform()
		gen r = 1+3*runiform()
		gen n1 = r*n/(1+r)
		gen n2 = n/(1+r)
		gen sd = (sd1*n1+sd2*n2)/n
		gen md = 0.1+0.1*rnormal()
		gen se = sqrt(sd1^2/n1 + sd2^2/n2)
		gen p = 2*normal(-abs(md/se))
	}
	albatross n p md, type(md) sd1(sd1) sd2(sd2) r(r) adjust
	restore
end

program define albatross_example_md_3
	preserve
	qui{
		clear
		set obs 20
		set seed 100
		gen n = 10+490*runiform()
		gen sd1 = 0.5+0.5*runiform()
		gen sd2 = 0.5+0.5*runiform()
		gen r = 1+3*runiform()
		gen n1 = r*n/(1+r)
		gen n2 = n/(1+r)
		gen sd = (sd1*n1+sd2*n2)/n
		gen md = 0.1+0.1*rnormal()
		gen se = sqrt(sd1^2/n1 + sd2^2/n2)
		gen p = 2*normal(-abs(md/se))
	}
	albatross n p md, type(md) sd1(sd1) sd2(sd2) r(r) adjust contours(0.2 0.4 0.6)
	restore
end

program define albatross_example_smd_1
	preserve
	qui{
		clear
		set obs 20
		set seed 100
		gen n = 10+490*runiform()
		gen smd = -0.5+0.25*runiform()
		gen r = 1+3*runiform()
		gen se = sqrt((2*(r+1)^2+r*smd^2)/(2*r*n))
		gen p = 2*normal(-abs(smd/se))
		gen range = 1 if p >0.1
		replace p = 0.1 if p > 0.1
	}
	albatross n p smd, type(smd)
	restore
end

program define albatross_example_smd_2
	preserve
	qui{
		clear
		set obs 20
		set seed 100
		gen n = 10+490*runiform()
		gen smd = -0.5+0.25*runiform()
		gen r = 1+3*runiform()
		gen se = sqrt((2*(r+1)^2+r*smd^2)/(2*r*n))
		gen p = 2*normal(-abs(smd/se))
		gen range = 1 if p >0.1
		replace p = 0.1 if p > 0.1
	}
	albatross n p smd, type(smd) range(range)
	restore
end

program define albatross_example_smd_3
	preserve
	qui{
		clear
		set obs 20
		set seed 100
		gen n = 10+490*runiform()
		gen smd = -0.5+0.25*runiform()
		gen r = 1+3*runiform()
		gen se = sqrt((2*(r+1)^2+r*smd^2)/(2*r*n))
		gen p = 2*normal(-abs(smd/se))
		gen range = 1 if p >0.1
		replace p = 0.1 if p > 0.1
	}
	albatross n p smd, type(smd) contours(0.25 0.5) range(range) title("When P values are inexact, data simulated", size(medium))
	restore
end

program define albatross_example_smd_4
	preserve
	qui{
		clear
		set obs 20
		set seed 100
		gen n = 10+490*runiform()
		gen smd = -0.5+0.25*runiform()
		gen r = 1+3*runiform()
		gen se = sqrt((2*(r+1)^2+r*smd^2)/(2*r*n))
		gen p = 2*normal(-abs(smd/se))
		gen range = 1 if p >0.1
		replace p = 0.1 if p > 0.1
	}
	albatross n p smd if n > 250 in 1/10, type(smd) contours(0.25 0.5 1) range(range) title("When P values are inexact (restricted), data simulated", size(small))
	restore
end

program define albatross_example_smd_5
	preserve
	qui{
		clear
		set obs 20
		set seed 100
		gen n = 10+490*runiform()
		gen smd = -0.5+0.25*runiform()
		gen r = 1+3*runiform()
		gen se = sqrt((2*(r+1)^2+r*smd^2)/(2*r*n))
		gen p = 2*normal(-abs(smd/se))
		gen range = 1 if p >0.1
		replace p = 0.1 if p > 0.1
	}
	albatross n p smd, type(smd) nograph fishers stouffers
	restore
end

program define albatross_example_rr_1
	preserve
	qui{
		clear
		set obs 20
		set seed 100
		gen a = 300+200*runiform()
		gen b = a*1.5
		gen c = 300+200*runiform()
		gen d = 300+200*runiform()
		gen n = a+b+c+d
		gen rr = a*(c+d)/(c*(a+b))
		gen n1 = a+b
		gen n2 = c+d
		gen baseline = c/(c+d)
		gen r = n1/n2
		gen se = sqrt(1/a+1/c-1/n1-1/n2)
		gen p_rr = 2*normal(-abs(ln(rr)/se))
		gen e = 1 if ln(rr) >= 0
		replace e = -1 if e == .
		gen by = 1 if a > 400
		replace by = 0 if a <= 400
	}
	albatross n p_rr e, type(rr) baseline(baseline)
	restore
end

program define albatross_example_or_1
	preserve
	qui{
		clear
		set obs 20
		set seed 100
		gen a = 300+200*runiform()
		gen b = a*1.5
		gen c = 300+200*runiform()
		gen d = 300+200*runiform()
		gen n = a+b+c+d
		gen or = a*d/(b*c)
		gen n1 = a+b
		gen n2 = c+d
		gen baseline = c/(c+d)
		gen r = n1/n2
		gen se = sqrt(1/a+1/b+1/c+1/d)
		gen p_or = 2*normal(-abs(ln(or)/se))
		replace p_or = 10^-30 if p_or == 0
		gen e = 1 if ln(or) >= 0
		replace e = -1 if e == .
		gen by = 1 if a > 400
		replace by = 0 if a <= 400
	}
	albatross n p_or e, type(or) baseline(baseline)
	restore
end

program define albatross_example_rr_2
	preserve
	qui{
		clear
		set obs 20
		set seed 100
		gen a = 300+200*runiform()
		gen b = a*1.5
		gen c = 300+200*runiform()
		gen d = 300+200*runiform()
		gen n = a+b+c+d
		gen rr = a*(c+d)/(c*(a+b))
		gen n1 = a+b
		gen n2 = c+d
		gen baseline = c/(c+d)
		gen r = n1/n2
		gen se = sqrt(1/a+1/c-1/n1-1/n2)
		gen p_rr = 2*normal(-abs(ln(rr)/se))
		gen e = 1 if ln(rr) >= 0
		replace e = -1 if e == .
		gen by = 1 if a > 400
		replace by = 0 if a <= 400
	}
	albatross n p_rr e, type(rr) baseline(baseline) r(r) adjust
	restore
end

program define albatross_example_or_2
	preserve
	qui{
		clear
		set obs 20
		set seed 100
		gen a = 300+200*runiform()
		gen b = a*1.5
		gen c = 300+200*runiform()
		gen d = 300+200*runiform()
		gen n = a+b+c+d
		gen or = a*d/(b*c)
		gen n1 = a+b
		gen n2 = c+d
		gen baseline = c/(c+d)
		gen r = n1/n2
		gen se = sqrt(1/a+1/b+1/c+1/d)
		gen p_or = 2*normal(-abs(ln(or)/se))
		replace p_or = 10^-30 if p_or == 0
		gen e = 1 if ln(or) >= 0
		replace e = -1 if e == .
		gen by = 1 if a > 400
		replace by = 0 if a <= 400
	}
	albatross n p_or e, type(or) baseline(baseline) r(r) adjust
	restore
end

program define albatross_example_rr_3
	preserve
	qui{
		clear
		set obs 20
		set seed 100
		gen a = 300+200*runiform()
		gen b = a*1.5
		gen c = 300+200*runiform()
		gen d = 300+200*runiform()
		gen n = a+b+c+d
		gen rr = a*(c+d)/(c*(a+b))
		gen n1 = a+b
		gen n2 = c+d
		gen baseline = c/(c+d)
		gen r = n1/n2
		gen se = sqrt(1/a+1/c-1/n1-1/n2)
		gen p_rr = 2*normal(-abs(ln(rr)/se))
		gen e = 1 if ln(rr) >= 0
		replace e = -1 if e == .
		gen by = 1 if a > 400
		replace by = 0 if a <= 400
	}
	albatross n p_rr e, type(rr) baseline(baseline) r(r) adjust sr(2) sbaseline(0.5) by(by) color
	restore
end

program define albatross_example_or_3
	preserve
	qui{
		clear
		set obs 20
		set seed 100
		gen a = 300+200*runiform()
		gen b = a*1.5
		gen c = 300+200*runiform()
		gen d = 300+200*runiform()
		gen n = a+b+c+d
		gen or = a*d/(b*c)
		gen n1 = a+b
		gen n2 = c+d
		gen baseline = c/(c+d)
		gen r = n1/n2
		gen se = sqrt(1/a+1/b+1/c+1/d)
		gen p_or = 2*normal(-abs(ln(or)/se))
		replace p_or = 10^-30 if p_or == 0
		gen e = 1 if ln(or) >= 0
		replace e = -1 if e == .
		gen by = 1 if a > 400
		replace by = 0 if a <= 400
	}
	albatross n p_or e, type(or) baseline(baseline) r(r) adjust sr(2) sbaseline(0.5) by(by) color
	restore
end
