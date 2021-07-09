// Analyses of haloperidol data to illustrate metamiss command

use "haloperidol.dta", clear


* Available case analysis (two equivalent commands):

metan r1 f1 r2 f2, rr fixedi label(namevar=author)

metamiss r1 f1 m1 r2 f2 m2, rr id(author) aca


* ICA-0, impute missing as zeroes (two equivalent commands):

metamiss r1 f1 m1 r2 f2 m2, rr id(author) ica0 w4

metamiss r1 f1 m1 r2 f2 m2, rr id(author) ica0(m1 m2) w4


* Impute using reasons for missingness:

metamiss r1 f1 m1 r2 f2 m2, fixed id(author) ica0(df1 df2) ///
	ica1(ds1 ds2) icapc(dc1 dc2) icap(dg1 dg2) w4

	
* Fixed equal IMORs (two equivalent commands):

metamiss r1 f1 m1 r2 f2 m2, rr id(author) imor(2) nograph

metamiss r1 f1 m1 r2 f2 m2, rr id(author) logimor(log(2)) nograph


* Fixed opposite IMORs:

metamiss r1 f1 m1 r2 f2 m2, rr id(author) imor(2 1/2) nograph


* Random equal IMORs:

metamiss r1 f1 m1 r2 f2 m2, rr id(author) logimor(0) sdlogimor(1) ///
        corrlogimor(1)

		
* Random uncorrelated IMORs:

metamiss r1 f1 m1 r2 f2 m2, rr id(author) logimor(0) sdlogimor(1) ///
	corrlogimor(0)

	
* Possible ways to improve - unlikely to make much difference in practice:

metamiss r1 f1 m1 r2 f2 m2, rr id(author) logimor(0) sdlogimor(1) ///
       corrlogimor(1) method(mc) reps(10000)

metamiss r1 f1 m1 r2 f2 m2, rr id(author) logimor(0) sdlogimor(1) ///
       corrlogimor(0) method(gh) nip(50)
