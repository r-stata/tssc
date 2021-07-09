*!Version	: 0.1
*!Author: Niels Henrik Bruun, Section for General Practice, Dept. Of Public Health, Aarhus University
/*
2016-12-18 > First version
*/

version 12

program define qlqc15
	syntax varlist(min=15 max=15 numeric) [, Replace]
	tokenize `varlist'
	
	quietly {
		if "`replace'" != "" capture drop qlq_pf2 qlq_ef qlq_ql2 qlq_fa qlq_nv ///
									qlq_pa qlq_dy qlq_sl qlq_ap qlq_co
		
		*PF2
		generate pfsum = 12 - `1' - `2' - `3' if inlist(`1',1,2,3,4) ///
			& inlist(`2',1,2,3,4) & inlist(`3',1,2,3,4)
		generate qlq_pf2 = pfsum * 100 / 15 if inlist(pfsum,0,1,2,3,4,5)
		 replace qlq_pf2 = 100 / 15 * 7 if pfsum == 6
		 replace qlq_pf2 = 100 / 15 * 9 if pfsum == 7
		 replace qlq_pf2 = 100 / 15 * 11 if pfsum == 8
		 replace qlq_pf2 = 100 / 15 * 14 if pfsum == 9
		drop pfsum
		label variable qlq_pf2 "Physical Functioning"
		notes qlq_pf2: Based on `1' (1=Short walk), `2' (2=In bed) and `3' (3=Need help)

		*EF
		generate efsum = 8 - `13' - `14' if inlist(`13',1,2,3,4) & inlist(`14',1,2,3,4)
		generate qlq_ef = 0 if efsum == 0
		 replace qlq_ef = 2 * 100 / 12 if efsum == 1
		 replace qlq_ef = 5 * 100 / 12 if efsum == 2
		 replace qlq_ef = 50 if efsum == 3
		 replace qlq_ef = 8 * 100 / 12 if efsum == 4
		 replace qlq_ef = 10 * 100 / 12 if efsum == 5
		 replace qlq_ef = 100 if efsum == 6
		drop efsum
		label variable qlq_ef "Emotional Functioning"
		notes qlq_ef: Based on `13' (13=Felt tense) and `14' (14=Felt Depressed)

		*QL2
		generate qlq_ql2 = (`15' - 1) / 6 * 100 if inlist(`15',1,2,3,4,5,6,7)
		label variable qlq_ql2 "Overall quality of life (q30)"
		notes qlq_ql2: Based on `15' (15=Quality of life)

		*FA
		generate fasum = `7' + `11' - 2 if inlist(`7',1,2,3,4) & inlist(`11',1,2,3,4)
		generate qlq_fa = 0 if fasum == 0
		 replace qlq_fa = 2 * 100 / 9 if fasum == 1
		 replace qlq_fa = 3 * 100 / 9 if fasum == 2
		 replace qlq_fa = 4 * 100 / 9 if (`7' == 3 & `11' == 2) | (`7' == 4 & `11' == 1)
		 replace qlq_fa = 5 * 100 / 9 if (`7' == 1 & `11' == 4) | (`7' == 2 & `11' == 3)
		 replace qlq_fa = 6 * 100 / 9 if fasum == 4
		 replace qlq_fa = 8 * 100 / 9 if fasum == 5
		 replace qlq_fa = 100 if fasum == 6
		drop fasum
		label variable qlq_fa "Fatigue"
		notes qlq_fa: Based on `7' (7=Felt weak) and `11' (11=Been tired)

		*NV
		generate qlq_nv = (`9' - 1) / 6 * 100 if inlist(`9',1,2,3,4)
		 replace qlq_nv = (`9' - 2) / 2 * 100  if `9' > 2
		label variable qlq_nv "Nausea/Vomiting"
		notes qlq_nv: Based on `9' (9=Felt nauseated)

		*PA
		generate qlq_pa = (`5' + `12' - 2) / 6 * 100 if inlist(`5',1,2,3,4) & inlist(`12',1,2,3,4)
		label variable qlq_pa "Pain"
		notes qlq_pa: Based on `5' (5=Pain) and `12' (12=Pain inteference)

		*DY
		generate qlq_dy = (`4'- 1) / 3 * 100 if inlist(`4',1,2,3,4)
		label variable qlq_dy "Dyspnoea"
		notes qlq_dy: Based on `4' (4=Short of breath)

		*SL
		generate qlq_sl = (`6'- 1) / 3 * 100 if inlist(`6',1,2,3,4)
		label variable qlq_sl "Insomnia"
		notes qlq_sl: Based on `6' (6=Trouble sleeping)

		*AP
		generate qlq_ap = (`8'- 1) / 3 * 100 if inlist(`8',1,2,3,4)
		label variable qlq_ap "Appetite loss"
		notes qlq_ap: Based on `8' (8=Lacked appetite)

		*CO
		generate qlq_co = (`10'- 1) / 3 * 100 if inlist(`10',1,2,3,4)
		label variable qlq_co "Constipation"
		notes qlq_co: Based on `10' (10=Been constipated)
		
		format %5.2f	qlq_pf2 qlq_ef qlq_ql2 qlq_fa qlq_nv qlq_pa qlq_dy ///
						qlq_sl qlq_ap qlq_co
	}
end
