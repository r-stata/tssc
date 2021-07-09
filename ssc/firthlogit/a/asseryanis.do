clear *
set more off
/* Asseryanis dataset from Heinze, G. 1999. The application of Firth�s procedure to
  Cox and logistic regression. Technical Report 10/1999, updated in January 2001.
  University of Vienna, Department of Medical Computer Sciences */
input NV1 PI1 EH1 HG1 NV2 PI2 EH2 HG2 NV3 PI3 EH3 HG3
0 13 1.64 0 0 28 1.50 0 0 29 2.02 0
0 16 2.26 0 0 11 1.33 0 0 15 2.29 0
0 8 3.14 0 0 19 2.37 0 0 12 2.33 0
0 34 2.68 0 0 10 1.82 0 0 3 2.90 0
0 20 1.28 0 0 10 3.13 0 0 20 1.70 0
0 5 2.31 0 0 18 1.31 0 0 23 1.41 0
0 17 1.80 0 0 14 1.92 0 0 12 2.25 0
0 10 1.68 0 0 21 1.64 0 0 22 1.54 0
0 26 1.56 0 0 11 2.01 0 0 42 1.97 0
0 17 2.31 0 0 17 1.88 0 0 15 1.75 0
0 8 2.01 0 0 25 1.93 0 0 13 2.16 0
0 7 1.89 0 0 16 2.11 0 0 14 2.57 0
0 20 3.15 0 0 19 1.29 0 0 19 1.37 0
0 10 1.23 0 0 15 1.72 0 0 12 3.61 0
0 18 1.27 0 0 33 0.75 0 0 13 2.04 0
0 16 1.76 0 0 24 1.92 0 0 10 2.17 0
0 18 2.00 0 0 48 1.84 1 0 12 1.69 1
0 8 2.64 1 0 12 1.11 1 1 49 0.27 1
0 29 0.88 1 0 19 1.61 1 0 6 1.84 1
0 12 1.27 1 0 2 1.18 1 0 5 1.30 1
0 20 1.37 1 1 22 1.44 1 0 17 0.96 1
1 38 0.97 1 1 40 1.18 1 1 11 1.01 1
1 22 1.14 1 1 5 0.93 1 1 21 0.98 1
1 7 0.88 1 1 0 1.17 1 0 5 0.35 1
1 25 0.91 1 0 21 1.19 1 1 19 1.02 1
1 15 0.58 1 0 15 1.06 1 0 33 0.85 1
0 7 0.97 1 . . . . . . . .
end
compress
generate int dummy = _n
reshape long NV PI EH HG, i(dummy) j(junk)
drop dummy junk
firthlogit HG NV PI EH
estimates store A
constraint define 1 EH PI
firthlogit HG NV PI EH, constraints(1)
lrtest A .
/* Agreement with multiple-variable PLR test result on Page 39 of technical report. */
exit

