clear *
set more off
// Collett dataset with "outliers removed" as presented in brochure by Cytel, Inc.
input byte obs float fibrinogen byte globulin byte response
1 2.52 38 0
2 2.56 31 0
3 2.19 33 0
4 2.18 31 0
5 3.41 37 0
6 2.46 36 0
7 3.22 38 0
8 2.21 37 0
9 3.15 39 0
10 2.60 41 0
11 2.29 36 0
12 2.35 29 0
13 5.06 37 1
14 3.34 32 1
15 3.15 36 0
16 3.53 46 1
17 2.68 34 0
18 2.60 38 0
19 2.23 37 0
20 2.88 30 0
21 2.65 46 0
22 2.28 36 0
23 2.67 39 0
24 2.29 31 0
25 2.15 31 0
26 2.54 28 0
27 3.93 32 1
28 3.34 30 0
29 2.99 36 0
30 3.32 35 0
end
quietly summarize fibrinogen, detail
scalar define iqr = r(p75) - r(p25)
generate double fibrinogen_iqr = fibrinogen / scalar(iqr)
firthlogit response fibrinogen_iqr globulin, or 
/* Agreement with Heinze, G. 2006. A comparative investigation of methods for
  logistic regression with separated or nearly separated data.
  _Statistics in Medicine_ 25:4216--26. (Page 10 of electronic preprint.) */
exit
