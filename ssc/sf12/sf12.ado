*! Version	: 0.11
*! Author	: Niels Henrik Bruun, Section for General Practice, Dept. Of Public Health, Aarhus University
/*
2016-12-18 > Minor alterations
2015-12-09 > First version
*/

version 12

program define sf12
	syntax varlist(min=12 max=12)
	* 1  2   3   4   5   6   7   8  9   10  11  12
	* i1 i2a i2b i3a i3b i4a i4b i5 i6a i6b i6c i7

	quietly {
		* WHEN NECESSARY, REVERSE CODE ITEMS SO A HIGHER SCORE MEANS BETTER HEALTH
		*						i1	 i5  i6a i6b
		foreach var of varlist `1' `8' `9' `10' {
			tempvar `var'r
			generate double ``var'r' = 6 - `var' if inlist(`var', 1,2,3,4,5)
		}
		replace ``1'r' = 4.4 if ``1'r' == 4 //i1
		replace ``1'r' = 3.4 if ``1'r' == 3 //i1
		
		* CREATE SCALES AND CODE OUT-OF-RANGE VALUES TO MISSING
		generate double pf = 100 * (`2' + `3' - 2) / 4 ///
			if inlist(`2', 1,2,3) & inlist(`3', 1,2,3) //i2*
		generate double rp = 100 * (`4' + `5' - 2) / 8 ///
			if inlist(`4', 1,2,3,4,5) & inlist(`5', 1,2,3,4,5) //i3*
		generate double bp = 100 * (``8'r' - 1) / 4 if inlist(`8', 1,2,3,4,5) // i5
		generate double gh = 100 * (``1'r' - 1) / 4 if inlist(`1', 1,2,3,4,5) //i1
		generate double vt = 100 * (``10'r' - 1) / 4 if inlist(`10', 1,2,3,4,5) // i6b
		generate double sf = 100 * (`12' - 1) / 4 if inlist(`12', 1,2,3,4,5) // i7
		generate double re = 100 * (`6' + `7' - 2) / 8 ///
			if inlist(`6', 1,2,3,4,5) & inlist(`7', 1,2,3,4,5) // i4*
		generate double mh = 100 * (``9'r' + `11' - 2) / 8 ///
			if inlist(`9', 1,2,3,4,5) & inlist(`11', 1,2,3,4,5) // i6a i6c

		* 1) TRANSFORM SCORES TO Z-SCORES 
		*** US GENERAL POPULATION MEANS AND SD'S ARE USED HERE (NOT AGE/GENDER BASED)
		replace pf = (pf - 81.18122) / 29.10588
		replace rp = (rp - 80.52856) / 27.13526
		replace bp = (bp - 81.74015) / 24.53019
		replace gh = (gh - 72.19795) / 23.19041
		replace vt = (vt - 55.59090) / 24.84380
		replace sf = (sf - 83.73973) / 24.75775
		replace re = (re - 86.41051) / 22.35543
		replace mh = (mh - 70.18217) / 20.50597

		* 2) CREATE PHYSICAL AND MENTAL HEALTH COMPOSITE SCORES
		*** MULTIPLY Z-SCORES BY VARIMAX-ROTATED FACTOR SCORING COEFFICIENTS AND SUM THE PRODUCTS
		generate double agg_phys 	= (pf * 0.42402) + (rp * 0.35119) ///
									+ (bp * 0.31754) + (gh * 0.24954) ///
									+ (vt * 0.02877) + (sf * -.00753) ///
									+ (re * -.19206) + (mh * -.22069)

		generate double agg_ment	= (pf * -.22999) + (rp * -.12329) ///
									+ (bp * -.09731) + (gh * -.01571) ///
									+ (vt * 0.23534) + (sf * 0.26876) ///
									+ (re * 0.43407) + (mh * 0.48581)

		* 3) TRANSFORM COMPOSITE AND SCALE SCORES TO T-SCORES
		foreach var of varlist pf-agg_ment {
			replace `var' = 50 + (`var' * 10)
		}

		* Add labels and notes
		label variable pf "NEMC physical functioning t-score"
		label variable rp "NEMC role limitation physical t-score"
		label variable bp "NEMC pain t-score"
		label variable gh "NEMC general health t-score"
		label variable vt "NEMC vitality t-score"
		label variable re "NEMC role limitation emotional t-score"
		label variable sf "NEMC social functioning t-score"
		label variable mh "NEMC mental health t-score"
		label variable agg_phys "NEMC physical health t-score - sf12"
		label variable agg_ment "NEMC mental health t-score - sf12"
		note pf: Based on `2' (i2a) and `3' (i2b)
		note rp: Based on `4' (i3a) and `5' (i3b)
		note bp: Based on reversed `8' (i5)
		note gh: Based on reversed `1' (i1)
		note vt: Based on reversed `10' (i6b)
		note re: Based on `6' (i4a) and `7' (i4b)
		note sf: Based on `12' (i7)
		note mh: Based on `reversed 9' (i6a) and `11' (i6c)
		note agg_phys: Based on all
		note agg_ment: Based on all
	}
end
