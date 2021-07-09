{smcl}
{hline}
{cmd:help: {helpb iot}}{space 50} {cmd:dialog:} {bf:{dialog iot}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:iot: Leontief Input-Output Table}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb iot##01:Syntax}{p_end}
{p 5}{helpb iot##02:Options}{p_end}
{p 5}{helpb iot##03:Description}{p_end}
{p 5}{helpb iot##04:Saved Results}{p_end}
{p 5}{helpb iot##05:References}{p_end}

{p 1}*** {helpb iot##06:Examples}{p_end}

{p 5}{helpb iot##07:Authors}{p_end}

{p2colreset}{...}
{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 5 5 6}
{opt iot} {varlist} , {opt fd(vars)} {err: [ {opt inv:t(#)}  {opt ml(var)} {opt exp:ort(var)} {opt imp:ort(var)} {opt fc(var)}}{p_end} 
{p 8 5 6}
{opt pall piost pis pos pist post pcmt pcm pssr pcheck pia padjia pinvia pmliou}{p_end} 
{p 8 5 6}
{opt  pmliot pmlio1 pmlio2 piot1 piot2 piot3 pioth pioth1 pioth2 pioth3}{p_end} 
{p 8 5 6}
{opt format(#)} {opt save(file_name)} {opt list txt} {err:]}{p_end}

{p2colreset}{...}
{marker 02}{bf:{err:{dlgtab:Options}}}

{col 3}{opt * varlist}{col 20}Input-Output Sectors (Intermediate Input-Output).

{col 3}{opt * fd(vars)}{col 20}Final Demand.

{col 5}{opt inv:t(1, 2)}{col 20}Leontief Inverse Matrix Type:
{col 20}1- Non-Competitive Import Type: {(I-A)^-1} (Simplified Model excluding Import)
{col 20}2-     Competitive Import Type: {[I-(I-M)A]^-1}

{col 5}{opt fc(var)}{col 20}Final Demand Prediction.

{col 5}{opt exp:ort(var)}{col 20}Export Variable.

{col 5}{opt imp:ort(var)}{col 20}Import Variable (Positive).
{col 20}if Import Variable is included among Final Demand variables.
{col 20}in fd( ) option, it must be Negative.

{col 5}{opt ml(var)}{col 20}Multiplier = Change Final Demand in each sector
{col 20}to get new level of total demand. Default is (1).

{col 5}{opt format(#)}{col 20}Set variables' output format, i.e:
{col 20}format(10.3fc) , format(12.0f)

{col 5}{opt list}{col 20}Add Input-Output Variables to Data List.

{col 3}{opt save(file_name)}{col 20}Save Input-Output Table Results in File (*.csv).

{col 5}{opt txt}{col 20}Save Results in text File (*.txt) instead of (*.csv).

{col 5}{opt pall}{col 20}Print All Tables

{col 5}{opt piost}{col 20}Print Input-Output Sectors Transactions

{col 5}{opt pis}{col 20}Print Input Share (%) in Intermediate Input (Ij)

{col 5}{opt pos}{col 20}Print Output Share (%) in Intermediate Output (Oi)

{col 5}{opt pist}{col 20}Print Intermediate Input & Value Added Share in Total Output

{col 5}{opt post}{col 20}Print Intermediate & Final Output Share in Total Output

{col 5}{opt pcmt}{col 20}Print [(A)] Technical Coefficients Matrix Table

{col 5}{opt pcm}{col 20}Print [(A)] Technical Coefficients Matrix

{col 5}{opt pssr}{col 20}Print (SSR) Self Sufficiency Ratio

{col 5}{opt pcheck}{col 20}Print Check Input-Output Table Matrix

{col 5}{opt pia}{col 20}Print [(I-A)] Leontief Matrix

{col 5}{opt padjia}{col 20}Print [a(I-A)] Adjusted Leontief Matrix

{col 5}{opt pinvia}{col 20}Print [inv(I-A)] Leontief Inverse Matrix

{col 5}{opt pmliou}{col 20}Print [MLIOU] Unit Input-Output Multiplier Table

{col 5}{opt pmliot}{col 20}Print [MLIOT] Total Input-Output Multiplier Table

{col 5}{opt pmlio1}{col 20}Print Total Input-Output Multiplier [Final Output (Demand)]

{col 5}{opt pmlio2}{col 20}Print Total Input-Output Multiplier [Total Output (Demand)]

{col 5}{opt piot1}{col 20}Print Input-Output Sectors

{col 5}{opt piot2}{col 20}Print Output Sectors

{col 5}{opt piot3}{col 20}Print Input Sectors

{col 5}{opt pioth}{col 20}Print Predicted (h) Leontief Input-Output Table

{col 5}{opt pioth1}{col 20}Print Predicted Input-Output Sectors

{col 5}{opt pioth2}{col 20}Print Predicted Output Sectors

{col 5}{opt pioth3}{col 20}Print Predicted Input Sectors

{p2colreset}{...}
{marker 03}{bf:{err:{dlgtab:Description}}}

{col 4}{cmd:iot} estimates Leontief Input-Output Table.

=========================================================
        ***  Leontief Input-Output Table  ***
=========================================================
 +-----------------------------------------------------+
 | Sector | S1  S2  S3  .. Si  |  Oi   |  Yi   | (R)Xi |
 |========|====================|=======|=======|=======|
 |     S1 | X11 X12 X13 .. X1j |  O1   |  Y1   |  X1   |
 |     S2 | X21 X22 X23 .. X2j |  O2   |  Y2   |  X2   |
 |     S3 | X31 X32 X33 .. X3j |  O3   |  Y3   |  X3   |
 |     .. | ... ... ... .. ... |  ..   |  ..   |  ..   |
 |     Sj | Xi1 Xi2 Xi3 .. Xij |  Oi   |  Yi   |  Xi   |
 |=====================================================|
 |     Ij | I1  I2  I3  .. Ij  | Oi=Ij |       |       |
 +--------+--------------------+-------+-------+-------+
 |     Vj | V1  V2  V3  .. Vj  |       | Yi=Vj |       |
 +--------+--------------------+-------+-------+-------+
 |  (C)Xj | X1  X2  X3  .. Xj  |       |       | Xi=Xj |
 +=====================================================+
 | Oi = Intermediate Output (Demand)  (O1, O2,..., Oi) |
 | Yi = Final        Output (Demand)  (Y1, Y2,..., Yi) |
 | Xi = Total        Output (Demand)  (X1, X2,..., Xi) |
 -------------------------------------------------------
 | Ij = Intermediate Input (Supply)   (I1, I2,..., Ij) |
 | Vj = Value Added        (GDP)      (V1, V2,..., Vj) |
 | Xj = Total        Input (Supply)   (X1, X2,..., Xj) |
 -------------------------------------------------------
 |    (A) = Technical Coefficients Matrix              |
 |    (I) = Identity Matrix (n x n)                    |
 |  (I-A) = Leontief Matrix                            |
 | i(I-A) = Leontief Inverse Matrix (Multiplier)       |
 -------------------------------------------------------

{col 4}{cmd:iot} can estimate the following results:
{col 7}- Leontief Input-Output Table
{col 7}- Input-Output Sectors Transactions
{col 7}- Input Share (%) in Intermediate Input (Ij)
{col 7}- Output Share (%) in Intermediate Output (Oi)
{col 7}- [(A)] Technical Coefficients Matrix Table
{col 7}- [(A)] Technical Coefficients Matrix
{col 7}- Check Input-Output Table Matrix
{col 7}- [(I-A)] Leontief Matrix
{col 7}- [a(I-A)] Adjusted Leontief Matrix
{col 7}- [inv(I-A)] Leontief Inverse Matrix
{col 7}- [MLIOU] Unit Input-Output Multiplier Table
{col 7}- [MLIOT] Total Input-Output Multiplier Table
{col 7}- Total Input-Output Multiplier [Final Output (Demand)]
{col 7}- Total Input-Output Multiplier [Total Output (Demand)]
{col 7}- Predicted (h) Leontief Input-Output Table

 ** Final Demand =
  + Household Final Consumption Expenditure
  + Government Final Consumption Expenditure
  + NPISHs Final Consumption Expenditure
  + Gross Fixed Capital formation
  + Changes in Inventories
  + Export
 ** Total Final Demand = Final Demand - Import

{p2colreset}{...}
{marker 04}{bf:{err:{dlgtab:Saved Results}}}

{p 2 4 2}{cmd:iot} saves the following results in {cmd:e()}:

Matrixes       
{col 4}{cmd:e(a)}{col 20}(A) Technical Coefficients Matrix
{col 4}{cmd:e(check)}{col 20}Check I-O Table Matrix
{col 4}{cmd:e(ia)}{col 20}(I-A) Leontief Technical Coefficients Matrix
{col 4}{cmd:e(invia)}{col 20}inv(I-A) Leontief Technical Coefficients Inverse Matrix
{col 4}{cmd:e(inviam)}{col 20}Total Input-Output Multiplier
{col 4}{cmd:e(mliou)}{col 20}Unit Input-Output Multiplier Table
{col 4}{cmd:e(mliot)}{col 20}Total Input-Output Multiplier Table
{col 4}{cmd:e(adjia)}{col 20}Adjusted (I-A) Leontief Technical Coefficients Matrix
{col 4}{cmd:e(ml)}{col 20}Input-Output Table Multiplier
{col 4}{cmd:e(iot)}{col 20}Leontief Input-Output Table Results
{col 4}{cmd:e(iott)}{col 20}Leontief Input-Output Table
{col 4}{cmd:e(ioth)}{col 20}Predicted Leontief Input-Output Table

{marker 05}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Chiang, Alpha (1984)
{cmd: "Fundamental Methods of Mathematical Economics",}
{it:3rd ed., McGraw-Hill Book Company Inc., New York, USA}.

{p 4 8 2}Dowling, Edward Thomas (1992)
{cmd: "Introduction to Mathematical Economics",}
{it:{it:2nd ed. New York, McGraw-Hill - Schaum's Outlines}.

{p 4 8 2}Heady, Earl O. & Carter, Harlod O (1959)
{cmd: "Input-Output Models as Techniques of Analysis for Interregional Competition",}
{it:J. Farm Econ., Vol. 41, No. 5, Dec., 1959}; 978-991.

{p 4 8 2}Leontief, Wassily W (1953)
{cmd: "Studies in the Structure of the American Economy",}
{it:New York & Oxford Press USA}.

{p 4 8 2}Sadoulet, Elisabeth & Alain Dejanvry (1993)
{cmd: "Quantitative Development Policy Analysis",}
{it:Agric. and Resource Econ., Univ. of California, USA}.

{bf:{err:*** Estimation Input-Output Model in other Software ***}}

{bf:{err:*** (1) Lindo Software: Input-Output Model (Minimum Model):}}

 Min   X1 +  X2 +  X3
 s.t.
    1)  0.857143 X1  - 0.4000 X2 - 0.0769 X3 > 50
    2) -0.357143 X1  + 0.9333 X2 - 0.6154 X3 > 10  
    3) -0.285714 X1  - 0.2000 X2 + 0.8462 X3 > 40
 End

  Global optimal solution found.
  Objective value:		419.9879
  Infeasibilities:		0.000000
  Total solver iterations:	3

  Variable  Value              Reduced Cost
  X1        139.9959           0.000000
  X2        150.0004           0.000000
  X3        129.9916           0.000000

  Row      Slack or Surplus    Dual Price
  1        419.9879           -1.000000
  2        0.000000           -4.186084
  3        0.000000           -3.791164
  4        0.000000           -4.319301
{hline}

{bf:{err:*** (2) Lindo Software: Input-Output Model (Maximum Model):}}

 Max  50 X1 + 10 X2 + 40 X3
 s.t.
    1)  0.85714 X1 - 0.35714 X2 - 0.28571 X3 < 1
    2) -0.40000 X1 + 0.93333 X2 - 0.20000 X3 < 1  
    3) -0.07692 X1 - 0.61538 X2 + 0.84615 X3 < 1
 End

  Global optimal solution found.
  Objective value:		419.9977
  Infeasibilities:		0.000000
  Total solver iterations:	3

  Variable  Value              Reduced Cost
  X1        4.186114           0.000000
  X2        3.791103           0.000000
  X3        4.319524           0.000000

  Row    Slack or Surplus      Dual Price
  1        419.9977            1.000000
  2        0.000000            139.9994
  3        0.000000            149.9989
  4        0.000000            129.9994
{hline}

{bf:{err:*** (3) SHAZAM Software: Input-Output Model (Solve Sets of Equations):}}

 Samp 1 1
 NL 3 / NC=3 SoLve
  EQ 90 -(0.1429*X1 + 0.4000*X2 + 0.0769*X3)
  EQ 140-(0.3571*X1 + 0.0667*X2 + 0.6154*X3)
  EQ 90 -(0.2857*X1 + 0.2000*X2 + 0.1538*X3)
 End

 COEFFICIENT STARTING VALUES
 X1         1.0000      X2         1.0000      X3         1.0000
       100 MAXIMUM ITERATIONS, CONVERGENCE =   0.100000E-04

 INITIAL STATISTICS :
 TIME =     0.0000 SEC.   ITER. NO.     0   FUNCT. EVALUATIONS     1
 FUNCTION VALUE=   35284.22     FUNCTION VALUE/N =   35284.22
 COEFFICIENTS
    1.000000       1.000000       1.000000
 GRADIENT
   -175.8513      -125.7857      -212.2669

 INTERMEDIATE STATISTICS :
 TIME =     0.0000 SEC.   ITER. NO.    15   FUNCT. EVALUATIONS    18
 FUNCTION VALUE=  0.1953562E-12 FUNCTION VALUE/N =  0.1953562E-12
 COEFFICIENTS
    140.0638       149.9767       129.9639
 GRADIENT
   0.3935958E-06  0.2209917E-06  0.5493805E-06

 FINAL STATISTICS :
 TIME =     0.0000 SEC.   ITER. NO.    16   FUNCT. EVALUATIONS    19
 FUNCTION VALUE=  0.1953562E-12 FUNCTION VALUE/N =  0.1953562E-12
 COEFFICIENTS
    140.0638       149.9767       129.9639
 GRADIENT
   0.3935958E-06  0.2209917E-06  0.5493805E-06
       COEFFICIENT
 X1        140.06
 X2        149.98
 X3        129.96
{hline}

{p2colreset}{...}
{marker 06}{bf:{err:{dlgtab:Examples}}}

 {stata clear all}

 {stata sysuse iot.dta, clear}

 {stata format * %15.3fc}
 {stata format * %15.3f}

 {stata "iot s1 s2 s3 , invt(1) fd(y1 y2 y3 y4 y5 y6) pall"}

 {stata "iot s1 s2 s3 , invt(1) fd(y1 y2 y3 y4) export(exp) import(imp) pall"}

 {stata "iot s1 s2 s3 , invt(2) fd(y1 y2 y3 y4) export(exp) import(imp) pall"}

 {stata "iot s1 s2 s3 , fd(fd)"}

 {stata "iot s1 s2 s3 , fd(fd) ml(ml) format(10.3f)"}

 {stata "iot s1 s2 s3 , fd(fd) ml(ml) list"}
 {stata "iot s1 s2 s3 , fd(fd) ml(ml) list save(D:\iot)"}

 {stata "iot s1 s2 s3 , fd(fd) fc(yh) ml(ml)"}
 {stata "iot s1 s2 s3 , fd(fd) fc(yh) ml(ml) list"}
 {stata "iot s1 s2 s3 , fd(fd) fc(yh) ml(ml) save(D:\iot)"}
 {stata "iot s1 s2 s3 , fd(fd) fc(yh) ml(ml) save(D:\iot) list"}

 {stata matlist e(a)}
 {stata matlist e(check)}
 {stata matlist e(ia)}
 {stata matlist e(adjia)}
 {stata matlist e(invia)}
 {stata matlist e(ml)}
 {stata matlist e(mliou)}
 {stata matlist e(mliot)}
 {stata matlist e(iot)}
 {stata matlist e(iott)}
 {stata matlist e(ioth)}

 {stata ereturn list}

 {stata matrix Aij_= e(a)}
 {stata svmat  Aij_}

 {stata matrix Mij_= e(invia)}
 {stata svmat  Mij_}
{hline}

 {stata "clear all"}
 {stata "sysuse iot.dta, clear"}
 {stata "format * %15.3fc"}
 {stata "format * %15.3f"}
 {stata "iot s1 s2 s3 , invt(1) fd(fd) fc(yh) ml(ml) pall list save(D:\iot)"}

============================================================
        ***  Leontief Input-Output Table  ***
============================================================
 +---------------------------------------------------------+
 | Sector | S1   S2   S3  ...  Si  |  Oi   |  Yi   | (R)Xi |
 |========|========================|=======|=======|=======|
 |     S1 | X11  X12  X13 ...  X1j |  O1   |  Y1   |  X1   |
 |     S2 | X21  X22  X23 ...  X2j |  O2   |  Y2   |  X2   |
 |     S3 | X31  X32  X33 ...  X3j |  O3   |  Y3   |  X3   |
 |     .. | ...  ...  ... ... ...  |  ..   |  ..   |  ..   |
 |     Sj | Xi1  Xi2  Xi3 ...  Xij |  Oi   |  Yi   |  Xi   |
 |=========================================================|
 |     Ij | I1   I2   I3  ...  Ij  | Oi=Ij |       |       |
 +--------+------------------------+-------+-------+-------+
 |     Vj | V1   V2   V3  ...  Vj  |       | Yi=Vj |       |
 +--------+------------------------+-------+-------+-------+
 |  (C)Xj | X1   X2   X3  ...  Xj  |       |       | Xi=Xj |
 +=========================================================+
 |  Oi = Intermediate Output (Demand)    (O1, O2,..., Oi)  |
 |  Yi = Final        Output (Demand)    (Y1, Y2,..., Yi)  |
 |  Xi = Total        Output (Demand)    (X1, X2,..., Xi)  |
 -----------------------------------------------------------
 |  Ij = Intermediate Input (Supply)     (I1, I2,..., Ij)  |
 |  Vj = Value Added        (GDP)        (V1, V2,..., Vj)  |
 |  Xj = Total        Input (Supply)     (X1, X2,..., Xj)  |
 -----------------------------------------------------------
 |         (A) = Technical Coefficients Matrix             |
 |         (I) = Identity Matrix (n x n)                   |
 |   (I-A) = Leontief Matrix (Non-Competitive Import Model)|
 | [I-(I-M)*A] = Leontief Matrix (Competitive Import Model)|
 |    (I-A)^-1 = Leontief Inverse Matrix (Multiplier)      |
 -----------------------------------------------------------

*** Leontief Input-Output Table ***
+---------------------------------------------------------------+
|  Sector |     s1      s2      s3      Oi        Yi |   (R) Xi |
|---------+------------------------------------------+----------|
|      s1 |     20      60      10      90        50 |      140 |
|      s2 |     50      10      80     140        10 |      150 |
|      s3 |     40      30      20      90        40 |      130 |
|      Ij |    110     100     110     320         . |        . |
|      Vj |     30      50      20       .       100 |        . |
|---------+------------------------------------------+----------|
|  (C) Xj |    140     150     130       .         . |      420 |
+---------------------------------------------------------------+
* (Oi) Intermediate Output = (Ij) Intermediate Input =  320
* (Yi) Final Output        = (Vj) Value Added        =  100
* (Xi) Total Output        = (Xj) Total Input        =  420
-----------------------------------------------------------------
 *** Non-Competitive Import Model ***
 *** Sectors Name: s1 s2 s3
 *** Final Demand: fd
 *** Sectors Matrix: (3 x 3)

*** Input-Output Sectors Transactions ***
+--------------------------------------------------------+
|       Sector |       s1        s2        s3 | Total(R) |
|--------------+------------------------------+----------|
|           s1 |        1         1         1 |        3 |
|           s2 |        1         1         1 |        3 |
|           s3 |        1         1         1 |        3 |
|--------------+------------------------------+----------|
|     Total(C) |        3         3         3 |        . |
+--------------------------------------------------------+

*** Input Share (%) in Intermediate Input (Ij) ***
+-----------------------------------------+
|   Sector |       s1        s2        s3 |
|----------+------------------------------|
|       s1 |   18.182    60.000     9.091 |
|       s2 |   45.455    10.000    72.727 |
|       s3 |   36.364    30.000    18.182 |
|----------+------------------------------|
| Total(C) |  100.000   100.000   100.000 |
+-----------------------------------------+

*** Output Share (%) in Intermediate Output (Oi) ***
+----------------------------------------------------+
|   Sector |       s1        s2        s3 | Total(R) |
|----------+------------------------------+----------|
|       s1 |   22.222    66.667    11.111 |  100.000 |
|       s2 |   35.714     7.143    57.143 |  100.000 |
|       s3 |   44.444    33.333    22.222 |  100.000 |
+----------------------------------------------------+

*** Intermediate Input & Value Added Share in Total Intput ***
+---------------------------------------------------------------------+
|       Sector |       Ij |  Ijs (%) |       Vj |  Vjs (%) |       Xj |
|--------------+----------+----------+----------+----------+----------|
|           s1 |   110.00 |    78.57 |    30.00 |    21.43 |   140.00 |
|           s2 |   100.00 |    66.67 |    50.00 |    33.33 |   150.00 |
|           s3 |   110.00 |    84.62 |    20.00 |    15.38 |   130.00 |
+---------------------------------------------------------------------+
* (Ij) = Intermediate Intput
* (Ijs)= Intermediate Intput Share in Total Intput (Xj)
* (Vj) = Value Added
* (Vjs)= Value Added Share in Total Intput (Xj)
* (Xj) = Total Intput
-------------------------------------------------------------------------

*** Intermediate & Final Output Share in Total Output ***
+--------------------------------------------------------------------------+
|       Sector |        Oi |   Ois (%) |        Yi |   Yis (%) |        Xi |
|--------------+-----------+-----------+-----------+-----------+-----------|
|           s1 |     90.00 |     64.29 |     50.00 |     35.71 |    140.00 |
|           s2 |    140.00 |     93.33 |     10.00 |      6.67 |    150.00 |
|           s3 |     90.00 |     69.23 |     40.00 |     30.77 |    130.00 |
+--------------------------------------------------------------------------+
* (Oi) = Intermediate Output
* (Ois)= Intermediate Output Share in Total Output (Xi)
* (Yi) = Final Output
* (Yis)= Final Output Share in Total Output (Xi)
* (Xi) = Total Output
-------------------------------------------------------------------------

*** [(A)] Technical Coefficients Matrix Table ***
+-----------------------------------------------+
|       Sector |       s1 |       s2 |       s3 |
|--------------+----------+----------+----------|
|           s1 |   0.1429 |   0.4000 |   0.0769 |
|           s2 |   0.3571 |   0.0667 |   0.6154 |
|           s3 |   0.2857 |   0.2000 |   0.1538 |
|  Value Added |   0.7857 |   0.6667 |   0.8462 |
|  Total Input |   1.0000 |   1.0000 |   1.0000 |
+-----------------------------------------------+

*** [(A)] Technical Coefficients Matrix ***
+-----------------------------------------------+
|       Sector |       s1 |       s2 |       s3 |
|--------------+----------+----------+----------|
|           s1 |   0.1429 |   0.4000 |   0.0769 |
|           s2 |   0.3571 |   0.0667 |   0.6154 |
|           s3 |   0.2857 |   0.2000 |   0.1538 |
+-----------------------------------------------+

*** Check Input-Output Table Matrix ***
+-----------------------------------------------------------------+
|          Sector |           Oi1 |           Oi2 |    Difference |
|-----------------+---------------+---------------+---------------|
|              s1 |        90.000 |        90.000 |         0.000 |
|              s2 |       140.000 |       140.000 |         0.000 |
|              s3 |        90.000 |        90.000 |         0.000 |
+-----------------------------------------------------------------+
 * Oi1 = Xi - Y
 * Oi2 = A * Xi
--------------------------------------------------------------------

*** [(I-A)] Leontief Matrix ***
+-----------------------------------------------+
|       Sector |       s1 |       s2 |       s3 |
|--------------+----------+----------+----------|
|           s1 |   0.8571 |  -0.4000 |  -0.0769 |
|           s2 |  -0.3571 |   0.9333 |  -0.6154 |
|           s3 |  -0.2857 |  -0.2000 |   0.8462 |
+-----------------------------------------------+

*** [a(I-A)] Adjusted Leontief Matrix ***
+---------------------------------------------+
|     Sector |       s1 |       s2 |       s3 |
|------------+----------+----------+----------|
|         s1 |   0.6667 |   0.3538 |   0.3179 |
|         s2 |   0.4780 |   0.7033 |   0.5549 |
|         s3 |   0.3381 |   0.2857 |   0.6571 |
+---------------------------------------------+

*** {(I-A)^-1} Leontief Inverse Matrix ***
+-----------------------------------------------+
|       Sector |       s1 |       s2 |       s3 |
|--------------+----------+----------+----------|
|           s1 |   1.8821 |   0.9990 |   0.8976 |
|           s2 |   1.3495 |   1.9855 |   1.5667 |
|           s3 |   0.9545 |   0.8066 |   1.8552 |
+-----------------------------------------------+

*** [MLIOU] Unit Input-Output Multiplier Table ***
+-------------------------------------------------------------------------+
|     Sector |        s1         s2         s3     Total(R) |         IRR |
|------------+----------------------------------------------+-------------|
|         s1 |     1.882      0.999      0.898        3.779 |       0.922 |
|         s2 |     1.350      1.986      1.567        4.902 |       1.196 |
|         s3 |     0.954      0.807      1.855        3.616 |       0.882 |
|   Total(C) |     4.186      3.791      4.320       12.297 |           . |
|------------+----------------------------------------------+-------------|
|        IER |     1.021      0.925      1.054            . |       3.000 |
+-------------------------------------------------------------------------+
 * IRR = Index Response Ratio = Index Sensitivity Dispersion
 * IER = Index Effect   Ratio = Index Power Dispersion
-------------------------------------------------------------------------

*** [MLIOT] Total Input-Output Multiplier Table ***
+-------------------------------------------------------------------------+
|     Sector |        s1         s2         s3     Total(R) |         IRR |
|------------+----------------------------------------------+-------------|
|         s1 |     1.882      0.999      0.898        3.779 |       0.922 |
|         s2 |     1.350      1.986      1.567        4.902 |       1.196 |
|         s3 |     0.954      0.807      1.855        3.616 |       0.882 |
|   Total(C) |     4.186      3.791      4.320       12.297 |           . |
|------------+----------------------------------------------+-------------|
|        IER |     1.021      0.925      1.054            . |       3.000 |
+-------------------------------------------------------------------------+
 * IRR = Index Response Ratio = Index Sensitivity Dispersion
 * IER = Index Effect   Ratio = Index Power Dispersion
-------------------------------------------------------------------------

*** Total Input-Output Multiplier [Final Output (Demand)] ***
+--------------------------------------------------------------------+
|    Sector |           ML           MLT            Yi           Yim |
|-----------+--------------------------------------------------------|
|        s1 |        1.000         3.779        50.000        51.000 |
|        s2 |        1.000         4.902        10.000        11.000 |
|        s3 |        1.000         3.616        40.000        41.000 |
|-----------+--------------------------------------------------------|
|     Total |        3.000        12.297       100.000       103.000 |
+--------------------------------------------------------------------+
 * ML  = Multiplier Variable
 * MLT = Total Multiplier
 * Yi  = Final Output (Demand)
 * Yim = Final Output (Demand) after Multiplier
-------------------------------------------------------------------------

*** Total Input-Output Multiplier [Total Output (Demand)] ***
+--------------------------------------------------------------------+
|    Sector |           ML           MLT            Xi           Xim |
|-----------+--------------------------------------------------------|
|        s1 |        1.000         3.779       140.000       143.779 |
|        s2 |        1.000         4.902       150.000       154.902 |
|        s3 |        1.000         3.616       130.000       133.616 |
|-----------+--------------------------------------------------------|
|     Total |        3.000        12.297       420.000       432.297 |
+--------------------------------------------------------------------+
 * ML  = Multiplier Variable
 * MLT = Total Multiplier
 * Xi  = Total Output (Demand) (Xi) (Xi = Xj)
 * Xim = Total Output (Demand) after Multiplier
----------------------------------------------------------------------

-----------------------------------------------------
*** Leontief Input-Output Table Results ***
-----------------------------------------------------

*** Input-Output Sectors ***

+-----------------------------------------------------------------------+
|          Sector |              s1 |              s2 |              s3 |
|-----------------+-----------------+-----------------+-----------------|
|              s1 |          20.000 |          60.000 |          10.000 |
|              s2 |          50.000 |          10.000 |          80.000 |
|              s3 |          40.000 |          30.000 |          20.000 |
+-----------------------------------------------------------------------+
* (Oi) Intermediate Output (Rows)
* (Ij) Intermediate Input  (columns)
-------------------------------------------------------------------------

*** Output Sectors ***
+-----------------------------------------------------------------------+
|          Sector |              Oi |              Yi |              Xi |
|-----------------+-----------------+-----------------+-----------------|
|              s1 |          90.000 |          50.000 |         140.000 |
|              s2 |         140.000 |          10.000 |         150.000 |
|              s3 |          90.000 |          40.000 |         130.000 |
+-----------------------------------------------------------------------+
* (Oi) Intermediate Output
* (Yi) Final Output
* (Xi) Total Output
-------------------------------------------------------------------------

*** Input Sectors ***
+-----------------------------------------------------------------------+
|          Sector |              Ij |              Vj |              Xj |
|-----------------+-----------------+-----------------+-----------------|
|              s1 |         110.000 |          30.000 |         140.000 |
|              s2 |         100.000 |          50.000 |         150.000 |
|              s3 |         110.000 |          20.000 |         130.000 |
+-----------------------------------------------------------------------+
* (Ij) Intermediate Input
* (Vj) Value Added
* (Xj) Total Input
-------------------------------------------------------------------------

*** Predicted (h) Leontief Input-Output Table ***
+-----------------------------------------------------------------------+
|  Sector |       s1        s2        s3       Oih       Yih |  (R) Xih |
|---------+--------------------------------------------------+----------|
|      s1 |     28.8      89.0      13.8     131.6      70.0 |    201.6 |
|      s2 |     72.0      14.8     110.6     197.4      25.0 |    222.4 |
|      s3 |     57.6      44.5      27.7     129.7      50.0 |    179.7 |
|     Ijh |    158.4     148.3     152.1     458.8         . |        . |
|     Vjh |     43.2      74.1      27.7         .     145.0 |        . |
|---------+--------------------------------------------------+----------|
| (C) Xjh |    201.6     222.4     179.7         .         . |    603.8 |
+-----------------------------------------------------------------------+
* (Oih) Intermediate Output = (Ijh) Intermediate Input =        458.785
* (Yih) Final Output        = (Vjh) Value Added        =        145.000
* (Xih) Total Output        = (Xjh) Total Input        =        603.785
----------------------------------------------------------------------
 *** Sectors Name: s1 s2 s3
 *** Predicted Final Demand: yh
 *** Sectors Matrix: (3 x 3)
-------------------------------------------------------------------------

*** Predicted Input-Output Sectors ***
+-----------------------------------------------------------------------+
|          Sector |              s1 |              s2 |              s3 |
|-----------------+-----------------+-----------------+-----------------|
|              s1 |          28.800 |          88.976 |          13.826 |
|              s2 |          72.001 |          14.829 |         110.610 |
|              s3 |          57.601 |          44.488 |          27.653 |
+-----------------------------------------------------------------------+
* (Oih) Predicted Intermediate Output (Rows)
* (Ijh) Predicted Intermediate Input  (columns)
-------------------------------------------------------------------------

*** Predicted Output Sectors ***
+-----------------------------------------------------------------------+
|          Sector |             Oih |             Yih |             Xih |
|-----------------+-----------------+-----------------+-----------------|
|              s1 |         131.603 |          70.000 |         201.603 |
|              s2 |         197.441 |          25.000 |         222.441 |
|              s3 |         129.741 |          50.000 |         179.741 |
+-----------------------------------------------------------------------+
* (Oih) Predicted Intermediate Output
* (Yih) Predicted Final Output
* (Xih) Predicted Total Output
-------------------------------------------------------------------------

*** Predicted Input Sectors ***
+-----------------------------------------------------------------------+
|          Sector |             Ijh |             Vjh |             Xjh |
|-----------------+-----------------+-----------------+-----------------|
|              s1 |         158.402 |          43.201 |         201.603 |
|              s2 |         148.294 |          74.147 |         222.441 |
|              s3 |         152.089 |          27.653 |         179.741 |
+-----------------------------------------------------------------------+
* (Ijh) Predicted Intermediate Input
* (Vjh) Predicted Value Added
* (Xjh) Predicted Total Input
-------------------------------------------------------------------------

    variable |       sum
-------------+----------
         _s1 |        110.000
         _s2 |        100.000
         _s3 |        110.000
         _Oi |        320.000
         _Ij |        320.000
         _Yi |        100.000
         _Vj |        100.000
         _Xi |        420.000
         _Xj |        420.000
       _s1_h |        158.402
       _s2_h |        148.294
       _s3_h |        152.089
        _Oih |        458.785
        _Ijh |        458.785
        _Yih |        145.000
        _Vjh |        145.000
        _Xih |        603.785
        _Xjh |        603.785
         _ML |         12.297
        _Yim |        103.000
        _Xim |        432.297
------------------------

*** Save Input-Output Table (IOT) ***
*** (IOT) Results File Has Been saved in:

 Data Directory:   D:\Stata\SSC
 Open File:        D:\iot.csv
{hline}

{p2colreset}{...}
{marker 07}{bf:{err:{dlgtab:Authors}}}

- {hi:Emad Abd Elmessih Shehata}
  {hi:Professor (PhD Economics)}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email: {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

- {hi:Sahra Khaleel A. Mickaiel}
  {hi:Professor (PhD Economics)}
  {hi:Cairo University - Faculty of Agriculture - Department of Economics - Egypt}
  {hi:Email: {browse "mailto:sahra_atta@hotmail.com":sahra_atta@hotmail.com}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/pmi764.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/pmi764.htm"}}

{bf:{err:{dlgtab:IOT Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih & Sahra Khaleel A. Mickaiel (2015)}{p_end}
{p 1 10 1}{cmd:IOT: "Stata Module to Estimate Leontief Input-Output Table (IOT)"}{p_end}

	{browse "http://ideas.repec.org/c/boc/bocode/s458024.html"}

	{browse "http://econpapers.repec.org/software/bocbocode/s458024.htm"}

{title:Online Help:}

{bf:*** Distributed Lag Models}
{helpb almon1}{col 12}Shirley Almon Polynomial Distributed Lag Model{col 75}(ALMON1)
{helpb almon}{col 12}Shirley Almon Generalized Polynomial Distributed Lag Model{col 75}(ALMON)
{helpb dlagaj}{col 12}Alt France-Jan Tinbergen Distributed Lag Model{col 75}(DLAGAJ)
{helpb dlagdj}{col 12}Dale Jorgenson Rational Distributed Lag Model{col 75}(DLAGDJ)
{helpb dlagfd}{col 12}Frank De Leeuw Inverted V Distributed Lag Model{col 75}(DLAGFD)
{helpb dlagif}{col 12}Irving Fisher Arithmetic Distributed Lag Model{col 75}(DLAGIF)
{helpb dlagmf}{col 12}Milton Fridman Partial Adjustment-Adaptive Expectations
{col 12}Distributed Lag Model{col 75}(DLAGMF)
{helpb dlagmn}{col 12}Marc Nerlove Partial Adjustment Distributed Lag Model{col 75}(DLAGMN)
{helpb dlagrs}{col 12}Robert Solow Pascal Triangle Distributed Lag Model{col 75}(DLAGRS)
{helpb dlagrw}{col 12}Rudolf Wolffram Segmenting Partial Adjustment Distributed Lag{col 75}(DLAGRW)
{helpb dlagtq}{col 12}Tweeten-Quance Partial Adjustment Distributed Lag Model{col 75}(DLAGTQ)
{hline 83}

{bf:*** Demand System Models}
{helpb dsles}{col 12}Linear Expenditure System (LES){col 75}(DSLES)
{helpb dseles}{col 12}Extended Linear Expenditure System (ELES){col 75}(DSELES)
{helpb dsqes}{col 12}Quadratic Expenditure System (QES){col 75}(DSQES)
{helpb dsrot}{col 12}Rotterdam Demand System{col 75}(DSROT)
{helpb dsroti}{col 12}Inverse Rotterdam Demand System{col 75}(DSROTI)
{helpb dsaidsla}{col 12}Linear Approximation Almost Ideal Demand System (AIDS-LA){col 75}(DSAIDSLA)
{helpb dsaidsfd}{col 12}First Difference Almost Ideal Demand System (AIDS-FD){col 75}(DSAIDSFD)
{helpb dsaidsi}{col 12}Inverse Almost Ideal Demand System(AIDS-I) {col 75}(DSAIDSI)
{helpb dsarm}{col 12}Primal Armington Demand System{col 75}(DSARM)
{helpb dsengel}{col 12}Engel Demand System{col 75}(DSENGEL)
{helpb dsgads}{col 12}Generalized AddiLog Demand System (GADS){col 75}(DSGADS)
{helpb dstlog}{col 12}Transcendental Logarithmic Demand System{col 75}(DSTLOG)
{helpb dsw}{col 12}Working Demand System{col 75}(DSW)
{hline 83}
{helpb pfm}{col 12}Production Function Models{col 75}(PFM)
{hline 83}
{helpb ffm}{col 12}Profit Function Models{col 75}(FFM)
{hline 83}
{helpb cfm}{col 12}Cost Function Models{col 75}(CFM)
{helpb costreg}{col 12}Quadratic and Cubic Cost Functions{col 75}(COSTREG)
{hline 83}
{helpb iic}{col 12}Investment Indicators Criteria{col 75}(IIC)
{hline 83}
{helpb iot}{col 12}Leontief Input - Output Table{col 75}(IOT)
{hline 83}
{helpb index}{col 12}Index Numbers{col 75}(INDEX)
{hline 83}
{helpb mef}{col 12}Marketing Efficiency Models{col 75}(MEF)
{hline 83}
{helpb pam}{col 12}Policy Analysis Matrix{col 75}(PAM)
{helpb pem}{col 12}Partial Equilibrium Model{col 75}(PEM)
{hline 83}
{bf:*** Financial Analysis Models}
{helpb fam}{col 12}Financial Analysis Models{col 75}(FAM)
{helpb xbcr}{col 12}Benefit-Cost Ratio{col 75}(XBCR)
{helpb xirr}{col 12}Internal Rate of Return{col 75}(XIRR)
{helpb xmirr}{col 12}Modified Internal Rate of Return{col 75}(XMIRR)
{helpb xnfv}{col 12}Net Future Value{col 75}(XNFV)
{helpb xnpv}{col 12}Net Present Value{col 75}(XNPV)
{helpb xpp}{col 12}Payback Period{col 75}(XPP)
{hline 83}
{bf:*** Trade Models}
{helpb wtm}{col 12}World Trade Models{col 75}(WTM)
{helpb wtic}{col 12}World Trade Indicators Criteria{col 75}(WTIC)
{helpb wtrgc}{col 12}World Trade Regional Geographical Concentration{col 75}(WTRGC)
{helpb wtsgc}{col 12}World Trade Sectoral Geographical Concentration{col 75}(WTSGC)
{helpb wtrca}{col 12}World Trade Revealed Comparative Advantage{col 75}(WTRCA)
{hline 83}

{psee}
{p_end}

