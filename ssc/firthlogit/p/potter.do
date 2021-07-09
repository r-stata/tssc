clear *
set more off
input byte y float x1 float x2 byte x3
0 -1.9  -5.3  -43
0 -1.5   3.9  -15
0 -0.1  -5.2  -32
0  0.5  27.5    8
0  0.8  -3    -12
0  0.8  -1.6   -2
0  0.9   3.4    1
0  2.3  23.4   14
1 -5.6 -13.1   -1
1 -5.3 -19.8  -33
1 -2.4   1.8   -9
1 -2.3  -7.4    4
1 -2    -5.7   -7
1 -1.7  -3.9   13
1 -0.6  -2.4   -7
1 -0.5 -14.5  -12
1 -0.1 -10.2   -5
1 -0.1  -9.9  -11
1  0.4 -17.2   -9
1  0.7 -10.7  -10
1  1.1  -4.5  -15
end
generate double x1iqr = x1 / 2.6
generate double x2iqr = x2 / 8.6
generate double x3iqr = x3 / 11
firthlogit y x1iqr x2iqr x3iqr, or
estimates store Full
constraint define 1 x1iqr
constraint define 2 x2iqr
constraint define 3 x3iqr
forvalues i = 1/3 {
    quietly firthlogit y x1iqr x2iqr x3iqr, constraints(`i')
    lrtest Full .
}
/* Agreement with Heinze, G. 2006. A comparative investigation of methods for
  logistic regression with separated or nearly separated data.
  _Statistics in Medicine_ 25:4216--26. (Table 1 of electronic preprint.) */
exit
