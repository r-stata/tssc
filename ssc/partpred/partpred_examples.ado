program define partpred_examples

	version 11.1
	preserve
	clear

	if `1' == 1 {
		DIS webuse brcancer
		DIS stset rectime, failure(censrec=1) scale(365.25)
		DIS gen age = x1
		DIS gen age2 = age^2
		DIS stcox age age2 hormon
		DIS partpred hr_age, for(age age2) ref(age 60 age2 3600) ci(hr_age_lci hr_age_uci) eform
		DIS twoway	(rarea hr_age_lci hr_age_uci age, sort pstyle(ci)) ///
				(line hr_age age, sort) ///
				, legend(off) xtitle(age) ytitle(Hazard Ratio)
	}
	
	if `1' == 2 {	
		DIS webuse brcancer
		DIS stset rectime, failure(censrec=1) scale(365.25)
		DIS gen age = x1
		DIS gen age2 = age^2
		DIS stcox (c.age c.age2)##hormon
		DIS partpred hr_hormon if hormon==1, for(1.hormon 1.hormon#c.age 1.hormon#c.age2) ci(hr_hormon_lci hr_hormon_uci) eform
		DIS twoway	(rarea hr_hormon_lci hr_hormon_uci age, sort pstyle(ci)) ///
				(line hr_hormon age, sort) ///
				, legend(off) xtitle(age) ytitle(Hazard Ratio)
	}
	
	restore
end

program define DIS
	display as input ". `0'"
	`0'
end
