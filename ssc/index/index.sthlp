{smcl}
{hline}
{cmd:help: {helpb index}}{space 50} {cmd:dialog:} {bf:{dialog index}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:index: Price, Quantity, and Value Index Numbers}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb index##01:Syntax}{p_end}
{p 5}{helpb index##02:Options}{p_end}
{p 5}{helpb index##03:Description}{p_end}

{p 1}*** {helpb index##04:Index Applications}{p_end}

{p 1}*** {helpb index##05:Examples}{p_end}

{p 5}{helpb index##06:Authors}{p_end}

{p2colreset}{...}
{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 3 5 6}
{opt index} {bf:LHS = RHS} {ifin} , {err: [} {opt lhs(str)} {opt rhs(str)} {opt base(#)} 
 {opt year(#)} {opt panel} {opt id(#)} {opt it(#)} {opt ch:ain} {opt li:st} {opt sum:m}
 {opt sim:ple} {opt save(file_name)}{err:]}{p_end}

{p2colreset}{...}
{marker 02}{bf:{err:{dlgtab:Options}}}

{synoptset 15}{...}

{synopt:{opt lhs( )}}LHS: Left  Hand Side = Price - Quantity [ LHS( P, Q ) ]; default (p){p_end}

{synopt:{opt rhs( )}}RHS: Right Hand Side = Quantity - Value [ RHS( Q, V ) ]; default (q){p_end}

{synopt:{opt base(#)}}Base Time Period; default (1){p_end}

{synopt:{opt year(#)}}Starting Year Period; default (1){p_end}

{synopt:{opt id(var)}}Cross Sections ID variable name}}{p_end}

{synopt:{opt it(var)}}Time Series ID variable name{p_end}

{synopt:{opt sim:ple}}Display Simple Price, Quantity, and Value Index Numbers{p_end}

{synopt:{opt ch:ain}}Print Main Price & Quantity Index Numbers with chain{p_end}

{synopt:{opt sum:m}}Report Summary Statistics{p_end}

{synopt:{opt li:st}}Add Index Numbers Variables to Data File{p_end}

{synopt:{opt save(file_name)}}Save Results in File (*.txt){p_end}

{p2colreset}{...}
{marker 03}{bf:{err:{dlgtab:Description}}}
{pstd}
{cmd:index} estimates Quantity, and Value Index Numbers, i.e., Divisia (Tornqvist–Theil), Paasche, Laspeyres, Fisher, Marshall-Edgeworth, Walsh, Bowley, Mitchell, Geometric Laspeyres, Harmonic Mean, and Simple Index Numbers.

{pstd}
An index number measures the relative change in price, quantity, value, or some other item of interest from one time period to another. 

{pstd}
A simple index number measures the relative change in just one variable.

{pstd}
An index is a convenient way to express a change in a diverse group of items. 
Converting data to indexes also makes it easier to assess the trend in a series composed of exceptionally large numbers. 

* Unweighted Indexes
  1- Simple Average of the Price Indexes
2- Simple Aggregate Index
* Weighted Indexes
  1- Lespeyres Price Index
  2- Paasche Price Index
  3- Fisher’s Price Index

{pstd}
Laspeyres’ index tends to overweight goods whose prices have increased.

{pstd}
Paasche’s index tends to overweight goods whose prices have have decreased.

{pstd}
Fisher’s ideal index  was developed in an attempt to offset these shortcomings.
It is the geometric mean of the Laspeyres and Paasche indexes.

{pstd}
* Comparison of the Laspeyres, Paasche and Fisher

{pstd}
If price and quantity changes (weighted by values) are negatively correlated, then Laspeyres index exceeds Paasche index.

{pstd}
if weighted price and quantity changes are positively correlated, then Paasche index exceeds Laspeyres index. Because consumers are usually pricetakers, they typically react to price changes by substituting goods or services that have become relatively cheaper for those that have
become relatively more expensive.; the substitution effect.

{pstd}
Geometric Laspeyres index: A weighted geometric average of the price relatives using the expenditure shares of the price reference period as weights. Also called Logarithmic Laspeyres index

{pstd}
Bowley Index: The arithmetic average of the Laspeyres price index and the Paasche price index.


* Laspeyres versus Paasche Index:

{pstd}
When is Laspeyres most appropriate and when is Paasche the better choice?

* Laspeyres
 * Advantages
  1- Requires quantity data from only the base period.
  2- This allows a more meaningful comparison over time.
  3- The changes in the index can be attributed to changes in the price.
 * Disadvantages:
  1- Does not reflect changes in buying patterns over time.
  2- it may overweight goods whose prices increase.

* Paasche
 * Advantages:
  1- Because it uses quantities from the current period.
  2- it reflects current buying habits. 

 * Disadvantages:
  1- It requires quantity data for the current year.
  2- Because different quantities are used each year
  3- impossible to attribute changes in index to changes in price alone.
  4- tends to overweight the goods whose prices have declined.
  5- It requires the prices to be recomputed each year.

* Chained vs non-chained calculations[edit]

{pstd}
we have always had our price indices relative to some fixed base period.
An alternative is to take the base period for each time period to be the immediately
preceding time period. This can be done with any of the above indices.

{p2colreset}{...}
{marker 04}{bf:{err:{dlgtab:Index Applications:}}}

====================================================
*** Price, Quantity, and Value Index Numbers     ***
----------------------------------------------------
 *  (1) Divisia (Tornqvist–Theil) Index            *
 *  (2) Paasche Index                              *
 *  (3) Laspeyres Index                            *
 *  (4) Fisher Index                               *
 *  (5) Marshall-Edgeworth Index                   *
 *  (6) Walsh Index                                *
 *  (7) Bowley Index                               *
 *  (8) Mitchell Index                             *
 *  (9) Geometric Laspeyres Index                  *
 * (10) Harmonic Mean Index                        *
----------------------------------------------------

{bf:* Definition:}
 * Po = Price    at base time
 * Qo = Quantity at base time
 * Pt = Price    at time t
 * Qt = Quantity at time t
 * Yo = ALL Values at base time
 * Yt = ALL Values at time t
 * Wo = (Po*Qo) / Yo
 * Wt = (Pt*Qt) / Yt

--------------------------------------------------
{bf:{err:(1) Divisia (Tornqvist–Theil Index):}}

 * TT_P = Sum{ 0.5 * (Wo+Wt) * [ln(Pt)-ln(Po)] }
 * TT_Q = Sum{ 0.5 * (Wo+Wt) * [ln(Qt)-ln(Qo)] }

     +-----------------------------------------------------------+
     |     _Year |     _TT_P |     _TT_Q |    _TT_Pc |    _TT_Qc |
     |-----------+-----------+-----------+-----------+-----------|
  1. |         1 |       100 |       100 |       100 |       100 |
  2. |         2 |  121.6498 |  114.4852 |  121.6498 |  114.4852 |
  3. |         3 |  171.3751 |       150 |  173.2402 |  148.4146 |
  4. |         4 |  213.9295 |  166.9038 |  216.5502 |  164.9051 |
  5. |         5 |  270.3362 |  184.9538 |  275.1124 |   181.739 |
  6. |         6 |  318.0049 |  218.9944 |  323.7102 |  215.1335 |
     +-----------------------------------------------------------+
     * _TT_P  = Divisia Price    Index
     * _TT_Q  = Divisia Quantity Index
     * _TT_Pc = Divisia Chained Price    Index
     * _TT_Qc = Divisia Chained Quantity Index

---------------------------------------------------------------------------------
T   P1   Q1   P2   Q2   P1tQ1t P2tQ2t  Y     W1      W2      D1     D2     _TT_P
    (1)  (2)  (3)  (4)  (5)    (6)    (7)    (8)     (9)     (10)   (11)   (12)
---------------------------------------------------------------------------------
    (1)  (2)  (3)  (4)  (1*2)  (3*4)  (5+6)  (5/7)   (6/7)                (10/11*100)
---------------------------------------------------------------------------------
1   6    10   4    20   60     80     140    0.43    0.57    0.00   0.00   100.00
2   7    10   5    25   70     125    195    0.36    0.64    0.06   0.14   121.65
3   8    15   8    30   120    240    360    0.33    0.67    0.11   0.43   171.38
4   10   17   10   33   170    330    500    0.34    0.66    0.20   0.56   213.93
5   14   20   12   35   280    420    700    0.40    0.60    0.35   0.64   270.34
6   15   25   15   40   375    600    975    0.38    0.62    0.37   0.78   318.00
---------------------------------------------------------------------------------
     D1 = 10 = 0.5*(8 + 8_1)*(ln(1) - ln(1_1))
     D2 = 11 = 0.5*(9 + 9_1)*(ln(3) - ln(3_1))
  _TT_P = exp(D1+D2)*100


 * Divisia (Tornqvist–Theil Index) (another method):
---------------------------------------------------------------------------------
T  P1  Q1  P2  Q2    RP1   W1     Ws1    D1    RP2   W2     Ws2     D2    _TT_P
---------------------------------------------------------------------------------
1  6   10  4   1.00  1.00  0.43   0.43   1.00  1.00  0.57   0.57    1.00   100.00
2  7   10  5   1.17  1.17  0.36   0.39   1.06  1.25  0.64   0.61    1.14   121.65
3  8   15  8   1.33  1.33  0.33   0.38   1.12  2.00  0.67   0.62    1.54   171.38
4  10  17  10  1.67  1.67  0.34   0.38   1.22  2.50  0.66   0.62    1.76   213.93
5  14  20  12  2.33  2.33  0.40   0.41   1.42  3.00  0.60   0.59    1.90   270.34
6  15  25  15  2.50  2.50  0.38   0.41   1.45  3.75  0.62   0.59    2.19   318.00
---------------------------------------------------------------------------------
	RP1 = P1t/P1o		RP2 = P2t/P2o
	W1  = P1t*Q1t/Y		W2  = P2t*Q2t/Y
	Ws1 = (W1t+W1o)/2 =	Ws2 = (W2t+W2o)/2 = 
	D1  = Q1t ^ Ws1		D2  =  Q2t ^ Ws2
      _TT_P = D1*D2*100

 * Chaind Divisia (Tornqvist–Theil Index):
------------------------------------------------------------------------------------
T   P1   Q1   P2   Q2   P1tQ1t P2tQ2t Y    W1     W2    D1    D2     X         Y
    (1)  (2)  (3)  (4)  (5)    (6)   (7)   (8)    (9)   (10)  (11)  (12)      (13)
------------------------------------------------------------------------------------
    (1)  (2)  (3)  (4)  (1*2)  (3*4) (5+6) (5/7)  (6/7)           (10/11*100)  T
------------------------------------------------------------------------------------
1   6    10   4    20   60     80    140   0.43   0.57  0.00  0.00  100.0   100.0
2   7    10   5    25   70     125   195   0.36   0.64  0.06  0.14  121.6   121.6
3   8    15   8    30   120    240   360   0.33   0.67  0.05  0.31  142.4   173.2
4   10   17   10   33   170    330   500   0.34   0.66  0.08  0.15  125.0   216.6
5   14   20   12   35   280    420   700   0.40   0.60  0.12  0.11  127.0   275.1
6   15   25   15   40   375    600   975   0.38   0.62  0.03  0.14  117.7   323.7
------------------------------------------------------------------------------------
   D1 = 10 = 0.5*(W1t + W1t_1)*(ln(P1t) - ln(P1t_1))
   D2 = 11 = 0.5*(W2t + W2t_1)*(ln(P2t) - ln(21t_1))
 _TT_Pc (1) = X:1                                   = 100.0
 _TT_Pc (2) = X:2 * Y:1 / 100 = 121.6 * 100.0 / 100 = 121.6
 _TT_Pc (3) = X:3 * Y:2 / 100 = 142.4 * 121.6 / 100 = 173.2
 _TT_Pc (4) = X:4 * Y:3 / 100 = 125.0 * 173.2 / 100 = 216.6
 _TT_Pc (5) = X:5 * Y:4 / 100 = 127.0 * 216.6 / 100 = 275.1
 _TT_Pc (6) = X:6 * Y:5 / 100 = 117.7 * 275.1 / 100 = 323.7

--------------------------------------------------
{bf:{err:(2) Paasche Index:}}

 * P_P = Sum[Pt*Qt] / Sum(Po*Qt]
 * P_Q = Sum[Pt*Qt] / Sum(Pt*Qo]

     +-----------------------------------------------------------+
     |     _Year |      _P_P |      _P_Q |     _P_Pc |     _P_Qc |
     |-----------+-----------+-----------+-----------+-----------|
  1. |         1 |       100 |       100 |       100 |       100 |
  2. |         2 |   121.875 |  114.7059 |   121.875 |  114.7059 |
  3. |         3 |  171.4286 |       150 |  172.0588 |   147.479 |
  4. |         4 |  213.6752 |  166.6667 |  215.0735 |  163.8656 |
  5. |         5 |  269.2308 |  184.2105 |  273.7299 |  180.9241 |
  6. |         6 |  314.5161 |  216.6667 |  321.5502 |  213.8194 |
     +-----------------------------------------------------------+
     * _P_P = Paasche Price    Index
     * _P_Q = Paasche Quantity Index
     * _P_Pc = Paasche Chained Price    Index
     * _P_Qc = Paasche Chained Quantity Index

---------------------------------------------------------------------------------
T   P1   Q1   P2   Q2   P1tQ1t   P2tQ2t   PtQt  P1oQ1t  P2oQ2   PoQt   _P_P
---------------------------------------------------------------------------------
    (1)  (2)  (3)  (4)  (5)      (6)      (7)   (8)     (9)     (10)   (11)
---------------------------------------------------------------------------------
    1    2    3    4    1*2      3*4      5+6   1*2     3*4     8+9   7/10*100
---------------------------------------------------------------------------------
1   6    10   4    20   60       80       140   60      80      140   100.00
2   7    10   5    25   70       125      195   60      100     160   121.88
3   8    15   8    30   120      240      360   90      120     210   171.43
4   10   17   10   33   170      330      500   102     132     234   213.68
5   14   20   12   35   280      420      700   120     140     260   269.23
6   15   25   15   40   375      600      975   150     160     310   314.52
---------------------------------------------------------------------------------

 * Chaind Paasche Index:
------------------------------------------------------------------------------------
T   P1  Q1  P2  Q2  P1tQ1t P2tQ2t D1   P1oQ1t  P2oQ2  D2    X       Y
    (1) (2) (3) (4) (5)    (6)    (7)  (8)     (9)    (10)  (11)    (12)
------------------------------------------------------------------------------------
    1   2   3   4   1*2    3*4    5+6   1*2    3*4    8+9   7/10*100
------------------------------------------------------------------------------------
1   6   10  4   20  60     80     140   60     80     140   100.0   100.0
2   7   10  5   25  70     125    195   60     100    160   121.9   121.9
3   8   15  8   30  120    240    360   105    150    255   141.2   172.1
4   10  17  10  33  170    330    500   136    264    400   125.0   215.1
5   14  20  12  35  280    420    700   200    350    550   127.3   273.7
6   15  25  15  40  375    600    975   350    480    830   117.5   321.6
------------------------------------------------------------------------------------
   D1 = P1t   * Q1t + P2t   * Q2t
   D1 = P1t-1 * Q1t + P2t-1 * Q2t
 _P_Pc (1) = X:1                                   = 100.0
 _P_Pc (2) = X:2 * Y:1 / 100 = 121.9 * 100.0 / 100 = 121.9
 _P_Pc (3) = X:3 * Y:2 / 100 = 141.2 * 121.9 / 100 = 172.1
 _P_Pc (4) = X:4 * Y:3 / 100 = 125.0 * 172.1 / 100 = 215.1
 _P_Pc (5) = X:5 * Y:4 / 100 = 127.3 * 215.1 / 100 = 273.7
 _P_Pc (6) = X:6 * Y:5 / 100 = 117.5 * 273.7 / 100 = 321.6


--------------------------------------------------
{bf:{err:(3) Laspeyres Index:}}

 * L_P = Sum[Pt*Qo] / Sum[Po*Qo]
 * L_Q = Sum[Pt*Qt] / Sum[Po*Qo]

     +-----------------------------------------------------------+
     |     _Year |      _P_P |      _P_Q |     _P_Pc |     _P_Qc |
     |-----------+-----------+-----------+-----------+-----------|
  1. |         1 |       100 |       100 |       100 |       100 |
  2. |         2 |   121.875 |  114.7059 |   121.875 |  114.7059 |
  3. |         3 |  171.4286 |       150 |  172.0588 |   147.479 |
  4. |         4 |  213.6752 |  166.6667 |  215.0735 |  163.8656 |
  5. |         5 |  269.2308 |  184.2105 |  273.7299 |  180.9241 |
  6. |         6 |  314.5161 |  216.6667 |  321.5502 |  213.8194 |
     +-----------------------------------------------------------+
     * _P_P = Paasche Price    Index
     * _P_Q = Paasche Quantity Index
     * _P_Pc = Paasche Chained Price    Index
     * _P_Qc = Paasche Chained Quantity Index

---------------------------------------------------------------------------------
T    P1   Q1   P2   Q2   P1tQ1o   P2tQ2o P1Q1   P1oQ1o  P2oQ2o  PoQo   _L_P
     (1)  (2)  (3)  (4)  (5)      (6)    (7)    (8)     (9)     (10)   (11)
---------------------------------------------------------------------------------
     1    2    3    4    1*2      3*4    5+6    1*2     3*4     8+9    7/10*100
---------------------------------------------------------------------------------
1    6    10   4    20   60       80     140    60      80      140    100.00
2    7    10   5    25   70       100    170    60      80      140    121.43
3    8    15   8    30   80       160    240    60      80      140    171.43
4    10   17   10   33   100      200    300    60      80      140    214.29
5    14   20   12   35   140      240    380    60      80      140    271.43
6    15   25   15   40   150      300    450    60      80      140    321.43
---------------------------------------------------------------------------------


--------------------------------------------------
{bf:{err:(4) Fisher Index:}}

 * F_P = Sum[ sqrt(Laspeyres_P * Paasche_P) ]
 * F_Q = Sum[ sqrt(Laspeyres_Q * Paasche_Q) ]

     +-----------------------------------------------------------+
     |     _Year |      _F_P |      _F_Q |     _F_Pc |     _F_Qc |
     |-----------+-----------+-----------+-----------+-----------|
  1. |         1 |       100 |       100 |       100 |       100 |
  2. |         2 |  121.6516 |  114.4956 |  121.6516 |  114.4956 |
  3. |         3 |  171.4286 |       150 |  173.2051 |  148.4615 |
  4. |         4 |  213.9803 |  166.9046 |  216.5063 |  164.9572 |
  5. |         5 |  270.3274 |  184.9609 |  275.0413 |  181.7909 |
  6. |         6 |  317.9536 |  219.0347 |  323.6229 |  215.1976 |
     +-----------------------------------------------------------+
     * _F_P = Fisher Price    Index
     * _F_Q = Fisher Quantity Index
     * _F_Pc = Fisher Chained Price    Index
     * _F_Qc = Fisher Chained Quantity Index

---------------------------------------------------------------------
T	P1	Q1	P2	Q2	Pach	Lasp	_F_P
	(1)	(2)	(3)	(4)	(5)	(6)	(7)
---------------------------------------------------------------------
	1	2	3	4			sqrt(5*6)*100
---------------------------------------------------------------------
1	6	10	4	20	100	100	100.00
2	7	10	5	25	122	121	121.65
3	8	15	8	30	171	171	171.43
4	10	17	10	33	214	214	213.98
5	14	20	12	35	269	271	270.33
6	15	25	15	40	315	321	317.95
---------------------------------------------------------------------


--------------------------------------------------
{bf:{err:(5) Marshall-Edgeworth Index:}}

 * ME_P = Sum[Pt*(Qo+Qt)] / Sum[(Po*Qo)+(Po*Qt)]
 * ME_Q = Sum[Qt*(Po+Pt)] / Sum[(Po*Qo)+(Pt*Qo)]

     +-----------------------------------+
     |     _Year |     _ME_P |     _ME_Q |
     |-----------+-----------+-----------|
  1. |         1 |       100 |       100 |
  2. |         2 |  121.6667 |  114.5161 |
  3. |         3 |  171.4286 |       150 |
  4. |         4 |  213.9037 |  166.8182 |
  5. |         5 |       270 |  184.6154 |
  6. |         6 |  316.6667 |  217.7966 |
     +-----------------------------------+
     * _ME_P = Marshall-Edgeworth Price    Index
     * _ME_Q = Marshall-Edgeworth Quantity Index

-------------------------------------------------------------------------
T   P1   Q1   P2   Q2    M1    M2    D1    P1Q1   P2Q2   D2    _ME_P
    (1)  (2)  (3)  (4)   (5)   (6)   (7)   (8)    (9)    (10)  (11)
-------------------------------------------------------------------------
    1    2    3    4                 5+6                 8+9   7/10*100
-------------------------------------------------------------------------
1   6    10   4    20    120   160   280   120    160    280   100.00
2   7    10   5    25    140   225   365   120    180    300   121.67
3   8    15   8    30    200   400   600   150    200    350   171.43
4   10   17   10   33    270   530   800   162    212    374   213.90
5   14   20   12   35    420   660   1080  180    220    400   270.00
6   15   25   15   40    525   900   1425  210    240    450   316.67
-------------------------------------------------------------------------

   M1 = P1t*(Q1o+Q1t) = 1   * (2_1 + 2)
   M2 = P2o*(Q2o+Q2t) = 3_1 * (4_1 + 4)
 P1Q1 = P1tQ1t        = (1_1 * 2_1) + (1_1 + 2)  
 P2Q2 = P2oQ2o        = (3_1 * 4_1) + (3_1 + 4)


--------------------------------------------------
{bf:{err:(6) Walsh Index:}}

 * W_P = Sum[Pt*sqrt(Qo*Qt)] / Sum[Po*sqrt(Qo*Qt)]
 * W_Q = Sum[Qt*sqrt(Po*Pt)] / Sum[Qo*sqrt(Po*Pt)]
 
     +-----------------------------------+
     |     _Year |      _W_P |      _W_Q |
     |-----------+-----------+-----------|
  1. |         1 |       100 |       100 |
  2. |         2 |  121.6542 |  114.4964 |
  3. |         3 |  171.4286 |       150 |
  4. |         4 |  213.9808 |   166.899 |
  5. |         5 |  270.3337 |  184.9528 |
  6. |         6 |  317.9893 |  218.9898 |
     +-----------------------------------+
     * _W_P = Walsh Price    Index
     * _W_Q = Walsh Quantity Index

-------------------------------------------------------------------------
T   P1   Q1   P2   Q2    M1    M2    D1    P1Q1   P2Q2   D2    _ME_P
    (1)  (2)  (3)  (4)   (5)   (6)   (7)   (8)    (9)    (10)  (11)
-------------------------------------------------------------------------
    1    2    3    4                 5+6                 8+9   7/10*100
------------------------------------------------------------------------
1   6    10   4    20    60    80    140   60     80     140   100.00
2   7    10   5    25    70    112   182   60     89     149   121.65
3   8    15   8    30    98    196   294   73     98     171   171.43
4   10   17   10   33    130   257   387   78     103    181   213.98
5   14   20   12   35    198   317   515   85     106    191   270.33
6   15   25   15   40    237   424   661   95     113    208   317.99
-------------------------------------------------------------------------
   M1 = P1t*(Q1o*Q1t)^0.5 = 1 * (2_1 * 2)^0.5
   M2 = P2t*(Q2o+Q2t)^0.5 = 3 * (4_1 * 4)^0.5
 P1Q1 = P1tQ1t        = 1_1*(2_1 * 2)^0.5
 P2Q2 = P2oQ2o        = 3_1*(4_1 * 4)^0.5


--------------------------------------------------
{bf:{err:(7) Bowley Index:}}

 * B_P = Sum[ 0.5*(Laspeyres_P + Paasche_P) ]
 * B_Q = Sum[ 0.5*(Laspeyres_Q + Paasche_Q) ]

     +-----------------------------------------------------------+
     |     _Year |      _B_P |      _B_Q |     _B_Pc |     _B_Qc |
     |-----------+-----------+-----------+-----------+-----------|
  1. |         1 |       100 |       100 |       100 |       100 |
  2. |         2 |  121.6518 |  114.4958 |  121.6518 |  114.4958 |
  3. |         3 |  171.4286 |       150 |  173.2116 |  148.4671 |
  4. |         4 |  213.9805 |  166.9048 |  216.5145 |  164.9634 |
  5. |         5 |  270.3297 |  184.9624 |  275.0522 |   181.798 |
  6. |         6 |  317.9724 |  219.0476 |   323.636 |  215.2064 |
     +-----------------------------------------------------------+
     * _B_P = Bowley Price    Index
     * _B_Q = Bowley Quantity Index
     * _B_Pc = Bowley Chained Price    Index
     * _B_Qc = Bowley Chained Quantity Index

---------------------------------------------------------------------
T	P1	Q1	P2	Q2	Pach	Lasp	_F_P
	(1)	(2)	(3)	(4)	(5)	(6)	(7)
---------------------------------------------------------------------
	1	2	3	4			0.5(5+6)*100
---------------------------------------------------------------------
1	6	10	4	20	100	100	100.00
2	7	10	5	25	122	121	121.65
3	8	15	8	30	171	171	171.43
4	10	17	10	33	214	214	213.98
5	14	20	12	35	269	271	270.33
6	15	25	15	40	315	321	317.97
---------------------------------------------------------------------


--------------------------------------------------
{bf:{err:(8) Mitchell Index:}}

 * WtP  = 0.5 * (Po+ Pt)
 * WtQ  = 0.5 * (Qo+ Qt)
 * M_P  = Sum[Pt*WtQ] / Sum[Po*WtQ]
 * M_Q  = Sum[Qt*WtP] / Sum[Qo*WtP]
 * M_Pw = Sum[(Pt*WtQ/Po)] / Sum[WtQ]
 * M_Qw = Sum[(Qt*WtP/Qo)] / Sum[WtP]

     +-----------------------------------------------------------+
     |     _Year |      _M_P |      _M_Q |     _M_Pw |     _M_Qw |
     |-----------+-----------+-----------+-----------+-----------|
  1. |         1 |       100 |       100 |       100 |       100 |
  2. |         2 |  121.6667 |  114.5161 |  122.4359 |  110.2273 |
  3. |         3 |  171.4286 |       150 |  177.7778 |       150 |
  4. |         4 |  213.9037 |  166.8182 |   221.875 |  167.6667 |
  5. |         5 |       270 |  184.6154 |  276.4706 |  188.8889 |
  6. |         6 |  316.6667 |  217.7966 |  328.9474 |    226.25 |
     +-----------------------------------------------------------+
     * _M_P = Mitchell Price    Index
     * _M_Q = Mitchell Quantity Index

--------------------------------------------------------------------------------------
T   P1   Q1   P2   Q2   W1     W2    P1tW1   P2tW2 D1    P1oW1 P2oW2 D2    _M_P
    (1)  (2)  (3)  (4)  (5)    (6)   (7)     (8)   (9)   (10)  (11)  (12)  (13)
--------------------------------------------------------------------------------------
    1    2    3    4                 1*5     3*6   7+8   1*5   3*6   10+11  10/11*100
--------------------------------------------------------------------------------------
1   6    10   4    20   10.0   20.0  60.0    80    140   60    80    140   100.00
2   7    10   5    25   10.0   22.5  70.0    113   183   60    90    150   121.67
3   8    15   8    30   12.5   25.0  100.0   200   300   75    100   175   171.43
4   10   17   10   33   13.5   26.5  135.0   265   400   81    106   187   213.90
5   14   20   12   35   15.0   27.5  210.0   330   540   90    110   200   270.00
6   15   25   15   40   17.5   30.0  262.5   450   713   105   120   225   316.67
--------------------------------------------------------------------------------------
 * W1  = 0.5 * (P1o+ P1t)
 * W2  = 0.5 * (P2o+ P2t)

-----------------------------------------------------------------------
T   P1   Q1   P2   Q2   W1     W2    P1W    P2W    D1   D2    _M_Pw
    (1)  (2)  (3)  (4)  (5)    (6)   (7)    (8)    (9)  (10)  (11)
-----------------------------------------------------------------------
    1    2    3    4                 1*5    3*6    7+8  5+6   9/10*100
-----------------------------------------------------------------------
1   6    10   4    20   10.0   20.0  10.0   20.0   30   30    100.00
2   7    10   5    25   10.0   22.5  11.7   28.1   40   33    122.44
3   8    15   8    30   12.5   25.0  16.7   50.0   67   38    177.78
4   10   17   10   33   13.5   26.5  22.5   66.3   89   40    221.88
5   14   20   12   35   15.0   27.5  35.0   82.5   118  43    276.47
6   15   25   15   40   17.5   30.0  43.8   112.5  156  48    328.95
-----------------------------------------------------------------------
 P1W = P1t * W1 / P1o
 P2W = P2t * W2 / P2o


--------------------------------------------------
{bf:{err:(9) Geometric Laspeyres Index:}}

 * GL_P = Sum{ (Wo) * [ln(Pt)-ln(Po)] }
 * GL_Q = Sum{ (Wo) * [ln(Qt)-ln(Qo)] }

     +-----------------------------------+
     |     _Year |     _GL_P |     _GL_Q |
     |-----------+-----------+-----------|
  1. |         1 |       100 |       100 |
  2. |         2 |  121.3581 |  113.5997 |
  3. |         3 |  168.0979 |       150 |
  4. |         4 |  210.1224 |  167.1246 |
  5. |         5 |  269.3674 |   185.307 |
  6. |         6 |  315.1836 |   220.071 |
     +-----------------------------------+
     * _GL_P = Geometric Mean Price    Index
     * _GL_Q = Geometric Mean Quantity Index

------------------------------------------------------------------
T    P1   Q1    P2   Q2    Wo1     Wo2     D1      D2      _GL_P
     (1)  (2)   (3)  (4)   (5)     (6)     (7)     (8)     (9)
------------------------------------------------------------------
1    6    10    4    20    0.43    0.57    0.00    0.00    100.00
2    7    10    5    25    0.43    0.57    0.07    0.13    121.36
3    8    15    8    30    0.43    0.57    0.12    0.40    168.10
4    10   17    10   33    0.43    0.57    0.22    0.52    210.12
5    14   20    12   35    0.43    0.57    0.36    0.63    269.37
6    15   25    15   40    0.43    0.57    0.39    0.76    315.18
------------------------------------------------------------------
 Wo1   = P1o * Q1o / Yo
 Wo2   = P2o * Q2o / Yo 
 D1    = W1o * [ln(P1t) - ln(P1o)]
 D2    = W2o * [ln(P2t) - ln(P2o)]
 _GL_P = exp(D1+D2)*100


--------------------------------------------------
{bf:{err:(10) Harmonic Mean Index:}}

 * HM_P = Sum[Po*Qo] / Sum[(Po^2)*Qo/Pt]
 * HM_Q = Sum[Po*Qo] / Sum[(Qo^2)*Po/Qt]

     +-----------------------------------+
     |     _Year |     _HM_P |     _HM_Q |
     |-----------+-----------+-----------|
  1. |         1 |       100 |       100 |
  2. |         2 |  121.2871 |  112.9032 |
  3. |         3 |  164.7059 |       150 |
  4. |         4 |  205.8824 |  167.1064 |
  5. |         5 |  267.2727 |  184.9057 |
  6. |         6 |  308.8235 |    218.75 |
     +-----------------------------------+
     * _HM_P = Harmonic Mean Price    Index
     * _HM_Q = Harmonic Mean Quantity Index

------------------------------------------------------------------------------------
T   P1   Q1   P2   Q2   P1oQ1o   P2oQ2o   D1   P1oQ1oP1  P2oQ2oP2   D2     _H_P
    (1)  (2)  (3)  (4)  (5)     (6)      (7)   (8)       (9)        (10)   (11)
------------------------------------------------------------------------------------
    1    2    3    4    1*2     3*4      5+6   1*2/1     3*4/3      8+9    7/10*100
------------------------------------------------------------------------------------
1   6    10   4    20   60      80       140   60        80         140    100.00
2   7    10   5    25   60      80       140   51        64         115    121.29
3   8    15   8    30   60      80       140   45        40         85     164.71
4   10   17   10   33   60      80       140   36        32         68     205.88
5   14   20   12   35   60      80       140   26        27         52     267.27
6   15   25   15   40   60      80       140   24        21         45     308.82
------------------------------------------------------------------------------------

--------------------------------------------------
 *** Simple Price, Quantity,and Value Index Numbers ***


  +-----------------------------------------------------------------------------------+
  |     _Year |      _P_1 |     _IP_1 |      _Q_1 |     _IQ_1 |      _V_1 |     _IV_1 |
  |-----------+-----------+-----------+-----------+-----------+-----------+-----------|
  |         1 |         6 |       100 |        10 |       100 |        60 |       100 |
  |         2 |         7 |  116.6667 |        10 |       100 |        70 |  116.6667 |
  |         3 |         8 |  133.3333 |        15 |       150 |       120 |       200 |
  |         4 |        10 |  166.6667 |        17 |       170 |       170 |  283.3333 |
  |         5 |        14 |  233.3333 |        20 |       200 |       280 |  466.6667 |
  |         6 |        15 |       250 |        25 |       250 |       375 |       625 |
  +-----------------------------------------------------------------------------------+
     * _IP = Simple Price    Index [ Pt / Po * 100 ]
     * _IQ = Simple Quantity Index [ Qt / Qo * 100 ]
     * _IV = Simple Value    Index [ Vt / Vo * 100 ]

{p2colreset}{...}
{marker 05}{bf:{err:{dlgtab:Examples}}}

  {stata clear all}

  {stata sysuse index.dta, clear}

  {stata "index p1 p2 = q1 q2 , summ list chain simple"}

{pstd}
{stata "index p1 p2 = q1 q2 , lhs(p) rhs(q) base(1) summ list chain year(2000) simple save(Index)"}

{pstd}
{stata "index p1 p2 = q1 q2 , panel id(id) it(t) lhs(p) rhs(q)  base(1) summ list chain year(2000) simple"}

  {stata "index p1 p2 = q1 q2 , lhs(p) rhs(q) simple"}

  {stata "index p1 p2 = v1 v2 , lhs(p) rhs(v) simple"}

  {stata "index q1 q2 = v1 v2 , lhs(q) rhs(v) simple"}
{hline}

. clear all
. sysuse index.dta, clear
. index p1 p2 = q1 q2 , lhs(p) rhs(q) base(1) summ list chain year(2000) simple save(Index)

==================================================
***  Price, Quantity, and Value Index Numbers  ***
--------------------------------------------------
 *  (1) Divisia Index (Tornqvist–Theil)          *
 *  (2) Paasche Index                            *
 *  (3) Laspeyres Index                          *
 *  (4) Fisher Index                             *
 *  (5) Marshall-Edgeworth Index                 *
 *  (6) Walsh Index                              *
 *  (7) Bowley Index                             *
 *  (8) Mitchell Index                           *
 *  (9) Geometric Laspeyres Index                *
 * (10) Harmonic Mean Index                      *
--------------------------------------------------
 * LHS: Left  Hand Side = Price     [ LHS( P ) ]
 * RHS: Right Hand Side = Quantity  [ RHS( Q ) ]

 * Po = Price    at base time    * Pt = Price    at time t
 * Qo = Quantity at base time    * Qt = Quantity at time t
 * Yo = ALL Values at base time  * Yt = ALL Values at time t

--------------------------------------------------
 *** (1) Divisia Index (Tornqvist–Theil) ***

 *   Wo = (Po*Qo) / Yo
 *   Wt = (Pt*Qt) / Yt
 * TT_P = Sum{ 0.5 * (Wo+Wt) * [ln(Pt)-ln(Po)] }
 * TT_Q = Sum{ 0.5 * (Wo+Wt) * [ln(Qt)-ln(Qo)] }

     +-----------------------------------------------------------+
     |     _Year |     _TT_P |     _TT_Q |    _TT_Pc |    _TT_Qc |
     |-----------+-----------+-----------+-----------+-----------|
  1. |      2000 |       100 |       100 |       100 |       100 |
  2. |      2001 |  121.6498 |  114.4852 |  121.6498 |  114.4852 |
  3. |      2002 |  171.3751 |       150 |  173.2402 |  148.4146 |
  4. |      2003 |  213.9295 |  166.9038 |  216.5502 |  164.9051 |
  5. |      2004 |  270.3362 |  184.9538 |  275.1124 |   181.739 |
  6. |      2005 |  318.0049 |  218.9944 |  323.7102 |  215.1335 |
     +-----------------------------------------------------------+
     * _TT_P  = Divisia Price    Index
     * _TT_Q  = Divisia Quantity Index
     * _TT_Pc = Divisia Chained Price    Index
     * _TT_Qc = Divisia Chained Quantity Index

--------------------------------------------------
 *** (2) Paasche Index ***

 * P_P = Sum[Pt*Qt] / Sum(Po*Qt]
 * P_Q = Sum[Pt*Qt] / Sum(Pt*Qo]

     +-----------------------------------------------------------+
     |     _Year |      _P_P |      _P_Q |     _P_Pc |     _P_Qc |
     |-----------+-----------+-----------+-----------+-----------|
  1. |      2000 |       100 |       100 |       100 |       100 |
  2. |      2001 |   121.875 |  114.7059 |   121.875 |  114.7059 |
  3. |      2002 |  171.4286 |       150 |  172.0588 |   147.479 |
  4. |      2003 |  213.6752 |  166.6667 |  215.0735 |  163.8656 |
  5. |      2004 |  269.2308 |  184.2105 |  273.7299 |  180.9241 |
  6. |      2005 |  314.5161 |  216.6667 |  321.5502 |  213.8194 |
     +-----------------------------------------------------------+
     * _P_P  = Paasche Price    Index
     * _P_Q  = Paasche Quantity Index
     * _P_Pc = Paasche Chained Price    Index
     * _P_Qc = Paasche Chained Quantity Index

--------------------------------------------------
 *** (3) Laspeyres Index ***

 * L_P = Sum[Pt*Qo] / Sum[Po*Qo]
 * L_Q = Sum[Pt*Qt] / Sum[Po*Qo]

     +-----------------------------------------------------------+
     |     _Year |      _L_P |      _L_Q |     _L_Pc |     _L_Qc |
     |-----------+-----------+-----------+-----------+-----------|
  1. |      2000 |       100 |       100 |       100 |       100 |
  2. |      2001 |  121.4286 |  114.2857 |  121.4286 |  114.2857 |
  3. |      2002 |  171.4286 |       150 |   174.359 |  149.4505 |
  4. |      2003 |  214.2857 |  167.1429 |  217.9487 |  166.0562 |
  5. |      2004 |  271.4286 |  185.7143 |   276.359 |  182.6618 |
  6. |      2005 |  321.4286 |  221.4286 |  325.7088 |  216.5847 |
     +-----------------------------------------------------------+
     * _L_P  = Laspeyres Price    Index
     * _L_Q  = Laspeyres Quantity Index
     * _L_Pc = Laspeyres Chained Price    Index
     * _L_Qc = Laspeyres Chained Quantity Index

--------------------------------------------------
 *** (4) Fisher Index ***

 * F_P = Sum[ sqrt(Laspeyres_P * Paasche_P) ]
 * F_Q = Sum[ sqrt(Laspeyres_Q * Paasche_Q) ]

     +-----------------------------------------------------------+
     |     _Year |      _F_P |      _F_Q |     _F_Pc |     _F_Qc |
     |-----------+-----------+-----------+-----------+-----------|
  1. |      2000 |       100 |       100 |       100 |       100 |
  2. |      2001 |  121.6516 |  114.4956 |  121.6516 |  114.4956 |
  3. |      2002 |  171.4286 |       150 |  173.2051 |  148.4615 |
  4. |      2003 |  213.9803 |  166.9046 |  216.5063 |  164.9572 |
  5. |      2004 |  270.3274 |  184.9609 |  275.0413 |  181.7909 |
  6. |      2005 |  317.9536 |  219.0347 |  323.6229 |  215.1976 |
     +-----------------------------------------------------------+
     * _F_P  = Fisher Price    Index
     * _F_Q  = Fisher Quantity Index
     * _F_Pc = Fisher Chained Price    Index
     * _F_Qc = Fisher Chained Quantity Index

--------------------------------------------------
 *** (5) Marshall-Edgeworth Index ***

 * ME_P = Sum[Pt*(Qo+Qt)] / Sum[(Po*Qo)+(Po*Qt)]
 * ME_Q = Sum[Qt*(Po+Pt)] / Sum[(Po*Qo)+(Pt*Qo)]

     +-----------------------------------+
     |     _Year |     _ME_P |     _ME_Q |
     |-----------+-----------+-----------|
  1. |      2000 |       100 |       100 |
  2. |      2001 |  121.6667 |  114.5161 |
  3. |      2002 |  171.4286 |       150 |
  4. |      2003 |  213.9037 |  166.8182 |
  5. |      2004 |       270 |  184.6154 |
  6. |      2005 |  316.6667 |  217.7966 |
     +-----------------------------------+
     * _ME_P = Marshall-Edgeworth Price    Index
     * _ME_Q = Marshall-Edgeworth Quantity Index

--------------------------------------------------
 *** (6) Walsh Index ***

 * W_P = Sum[Pt*sqrt(Qo*Qt)] / Sum[Po*sqrt(Qo*Qt)]
 * W_Q = Sum[Qt*sqrt(Po*Pt)] / Sum[Qo*sqrt(Po*Pt)]

     +-----------------------------------+
     |     _Year |      _W_P |      _W_Q |
     |-----------+-----------+-----------|
  1. |      2000 |       100 |       100 |
  2. |      2001 |  121.6542 |  114.4964 |
  3. |      2002 |  171.4286 |       150 |
  4. |      2003 |  213.9808 |   166.899 |
  5. |      2004 |  270.3337 |  184.9528 |
  6. |      2005 |  317.9893 |  218.9898 |
     +-----------------------------------+
     * _W_P = Walsh Price    Index
     * _W_Q = Walsh Quantity Index

--------------------------------------------------
 *** (7) Bowley Index ***

 * B_P = Sum[ 0.5*(Laspeyres_P + Paasche_P) ]
 * B_Q = Sum[ 0.5*(Laspeyres_Q + Paasche_Q) ]

     +-----------------------------------------------------------+
     |     _Year |      _B_P |      _B_Q |     _B_Pc |     _B_Qc |
     |-----------+-----------+-----------+-----------+-----------|
  1. |      2000 |       100 |       100 |       100 |       100 |
  2. |      2001 |  121.6518 |  114.4958 |  121.6518 |  114.4958 |
  3. |      2002 |  171.4286 |       150 |  173.2116 |  148.4671 |
  4. |      2003 |  213.9805 |  166.9048 |  216.5145 |  164.9634 |
  5. |      2004 |  270.3297 |  184.9624 |  275.0522 |   181.798 |
  6. |      2005 |  317.9724 |  219.0476 |   323.636 |  215.2064 |
     +-----------------------------------------------------------+
     * _B_P  = Bowley Price    Index
     * _B_Q  = Bowley Quantity Index
     * _B_Pc = Bowley Chained Price    Index
     * _B_Qc = Bowley Chained Quantity Index

--------------------------------------------------
 *** (8) Mitchell Index ***

 * WtP  = 0.5 * (Po+ Pt)
 * WtQ  = 0.5 * (Qo+ Qt)
 * M_P  = Sum[Pt*WtQ] / Sum[Po*WtQ]
 * M_Q  = Sum[Qt*WtP] / Sum[Qo*WtP]
 * M_Pw = Sum[(Pt*WtQ/Po)] / Sum[WtQ]
 * M_Qw = Sum[(Qt*WtP/Qo)] / Sum[WtP]

     +-----------------------------------------------------------+
     |     _Year |      _M_P |      _M_Q |     _M_Pw |     _M_Qw |
     |-----------+-----------+-----------+-----------+-----------|
  1. |      2000 |       100 |       100 |       100 |       100 |
  2. |      2001 |  121.6667 |  114.5161 |  122.4359 |  110.2273 |
  3. |      2002 |  171.4286 |       150 |  177.7778 |       150 |
  4. |      2003 |  213.9037 |  166.8182 |   221.875 |  167.6667 |
  5. |      2004 |       270 |  184.6154 |  276.4706 |  188.8889 |
  6. |      2005 |  316.6667 |  217.7966 |  328.9474 |    226.25 |
     +-----------------------------------------------------------+
     * _M_P = Mitchell Price    Index
     * _M_Q = Mitchell Quantity Index

--------------------------------------------------
 *** (9) Geometric Laspeyres Index ***

 * GL_P = Sum{ Wo * [ln(Pt)-ln(Po)] }
 * GL_Q = Sum{ Wo * [ln(Qt)-ln(Qo)] }

     +-----------------------------------+
     |     _Year |     _GL_P |     _GL_Q |
     |-----------+-----------+-----------|
  1. |      2000 |       100 |       100 |
  2. |      2001 |  121.3581 |  113.5997 |
  3. |      2002 |  168.0979 |       150 |
  4. |      2003 |  210.1224 |  167.1246 |
  5. |      2004 |  269.3674 |   185.307 |
  6. |      2005 |  315.1836 |   220.071 |
     +-----------------------------------+
     * _GL_P = Geometric Laspeyres Price    Index
     * _GL_Q = Geometric Laspeyres Quantity Index

--------------------------------------------------
 *** (10) Harmonic Mean Index ***

 * HM_P = Sum[Po*Qo] / Sum[(Po^2)*Qo/Pt]
 * HM_Q = Sum[Po*Qo] / Sum[(Qo^2)*Po/Qt]

     +-----------------------------------+
     |     _Year |     _HM_P |     _HM_Q |
     |-----------+-----------+-----------|
  1. |      2000 |       100 |       100 |
  2. |      2001 |  121.2871 |  112.9032 |
  3. |      2002 |  164.7059 |       150 |
  4. |      2003 |  205.8824 |  167.1064 |
  5. |      2004 |  267.2727 |  184.9057 |
  6. |      2005 |  308.8235 |    218.75 |
     +-----------------------------------+
     * _HM_P = Harmonic Mean Price    Index
     * _HM_Q = Harmonic Mean Quantity Index

-------------------------------------------------------
 *** Simple Price, Quantity, and Value Index Numbers ***

 * Simple Index Number for Commodity: q1

  +-----------------------------------------------------------------------------------+
  |     _Year |      _P_1 |     _IP_1 |      _Q_1 |     _IQ_1 |      _V_1 |     _IV_1 |
  |-----------+-----------+-----------+-----------+-----------+-----------+-----------|
  |      2000 |         6 |       100 |        10 |       100 |        60 |       100 |
  |      2001 |         7 |  116.6667 |        10 |       100 |        70 |  116.6667 |
  |      2002 |         8 |  133.3333 |        15 |       150 |       120 |       200 |
  |      2003 |        10 |  166.6667 |        17 |       170 |       170 |  283.3333 |
  |      2004 |        14 |  233.3333 |        20 |       200 |       280 |  466.6667 |
  |      2005 |        15 |       250 |        25 |       250 |       375 |       625 |
  +-----------------------------------------------------------------------------------+

 * Simple Index Number for Commodity: q2

  +-----------------------------------------------------------------------------------+
  |     _Year |      _P_2 |     _IP_2 |      _Q_2 |     _IQ_2 |      _V_2 |     _IV_2 |
  |-----------+-----------+-----------+-----------+-----------+-----------+-----------|
  |      2000 |         4 |       100 |        20 |       100 |        80 |       100 |
  |      2001 |         5 |       125 |        25 |       125 |       125 |    156.25 |
  |      2002 |         8 |       200 |        30 |       150 |       240 |       300 |
  |      2003 |        10 |       250 |        33 |       165 |       330 |     412.5 |
  |      2004 |        12 |       300 |        35 |       175 |       420 |       525 |
  |      2005 |        15 |       375 |        40 |       200 |       600 |       750 |
  +-----------------------------------------------------------------------------------+
     * _IP = Price    Simple Index Number [ Pt / Po * 100 ]
     * _IQ = Quantity Simple Index Number [ Qt / Qo * 100 ]
     * _IV = Value    Simple Index Number [ Vt / Vo * 100 ]

---------------------------------------------------------------------------
*** Report Summary Statistics ***
----------------------------------------------------------------------

 * (1) Summary Statistics for Price Index Numbers:

    Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
       _TT_P |         6    199.2159    84.87735        100   318.0049
        _P_P |         6    198.4543    83.66524        100   314.5161
        _L_P |         6         200    86.07068        100   321.4286
        _F_P |         6    199.2236    84.85943        100   317.9536
       _ME_P |         6    198.9443    84.43953        100   316.6667
        _W_P |         6    199.2311    84.87001        100   317.9893
        _B_P |         6    199.2271    84.86504        100   317.9724
        _M_P |         6    198.9443    84.43953        100   316.6667
       _M_Pw |         6    204.5844    88.69904        100   328.9474
       _GL_P |         6    197.3549    84.07363        100   315.1836
       _HM_P |         6    194.6619    82.06486        100   308.8235
      _TT_Pc |         6    201.7105    87.24368        100   323.7102
       _P_Pc |         6    200.7146    86.39321        100   321.5502
       _L_Pc |         6     202.634    88.02825        100   325.7088
       _F_Pc |         6    201.6712    87.20775        100   323.6229
       _B_Pc |         6    201.6777    87.21306        100    323.636

----------------------------------------------------------------------
 * (2) Summary Statistics for Quantity Index Numbers:

    Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
       _TT_Q |         6    155.8895     44.3191        100   218.9944
        _P_Q |         6     155.375    43.50843        100   216.6667
        _L_Q |         6    156.4286     45.1641        100   221.4286
        _F_Q |         6    155.8993     44.3296        100   219.0347
       _ME_Q |         6    155.6244    43.92439        100   217.7966
        _W_Q |         6    155.8897    44.31533        100   218.9898
        _B_Q |         6    155.9018    44.33346        100   219.0476
        _M_Q |         6    155.6244    43.92439        100   217.7966
       _M_Qw |         6    157.1721    47.77395        100     226.25
       _GL_Q |         6     156.017    44.84983        100    220.071
       _HM_Q |         6    155.6109    44.55306        100     218.75
      _TT_Qc |         6    154.1129    42.74157        100   215.1335
       _P_Qc |         6    153.4657    42.19345        100   213.8194
       _L_Qc |         6    154.8398     43.3437        100   216.5847
       _F_Qc |         6    154.1505    42.76605        100   215.1976
       _B_Qc |         6    154.1551    42.76961        100   215.2064
------------------------------------------------------------------------------

------------------------------------------------------------------------------
 *** Main Price & Quantity Index Numbers with CHAIN ***

 * (1) (Divisia - Paasche - Laspeyres - Fisher) Index Numbers *

     +---------------------------------------------------------------------------------------+
     |    _TT_P |     _P_P |     _L_P |     _F_P |    _TT_Q |     _P_Q |     _L_Q |     _F_Q |
     |----------+----------+----------+----------+----------+----------+----------+----------|
  1. |      100 |      100 |      100 |      100 |      100 |      100 |      100 |      100 |
  2. | 121.6498 |  121.875 | 121.4286 | 121.6516 | 114.4852 | 114.7059 | 114.2857 | 114.4956 |
  3. | 171.3751 | 171.4286 | 171.4286 | 171.4286 |      150 |      150 |      150 |      150 |
  4. | 213.9295 | 213.6752 | 214.2857 | 213.9803 | 166.9038 | 166.6667 | 167.1429 | 166.9046 |
  5. | 270.3362 | 269.2308 | 271.4286 | 270.3274 | 184.9538 | 184.2105 | 185.7143 | 184.9609 |
  6. | 318.0049 | 314.5161 | 321.4286 | 317.9536 | 218.9944 | 216.6667 | 221.4286 | 219.0347 |
     +---------------------------------------------------------------------------------------+
     * _TT_P = Divisia   Price Index         * _TT_Q = Divisia   Quantity Index
     *  _P_P = Paasche   Price Index         *  _P_Q = Paasche   Quantity Index
     *  _L_P = Laspeyres Price Index         *  _L_Q = Laspeyres Quantity Index
     *  _F_P = Fisher    Price Index         *  _F_Q = Fisher    Quantity Index
--------------------------------------------------------------------------------

 * (2) (Divisia - Paasche - Laspeyres - Fisher) Chained Index Numbers *

     +---------------------------------------------------------------------------------------+
     |   _TT_Pc |    _P_Pc |    _L_Pc |    _F_Pc |   _TT_Qc |    _P_Qc |    _L_Qc |    _F_Qc |
     |----------+----------+----------+----------+----------+----------+----------+----------|
  1. |      100 |      100 |      100 |      100 |      100 |      100 |      100 |      100 |
  2. | 121.6498 |  121.875 | 121.4286 | 121.6516 | 114.4852 | 114.7059 | 114.2857 | 114.4956 |
  3. | 173.2402 | 172.0588 |  174.359 | 173.2051 | 148.4146 |  147.479 | 149.4505 | 148.4615 |
  4. | 216.5502 | 215.0735 | 217.9487 | 216.5063 | 164.9051 | 163.8656 | 166.0562 | 164.9572 |
  5. | 275.1124 | 273.7299 |  276.359 | 275.0413 |  181.739 | 180.9241 | 182.6618 | 181.7909 |
  6. | 323.7102 | 321.5502 | 325.7088 | 323.6229 | 215.1335 | 213.8194 | 216.5847 | 215.1976 |
     +---------------------------------------------------------------------------------------+
     * _TT_P = Divisia   Chained Price Index * _TT_Q = Divisia   Chained Quantity Index
     *  _P_P = Paasche   Chained Price Index *  _P_Q = Paasche   Chained Quantity Index
     *  _L_P = Laspeyres Chained Price Index *  _L_Q = Laspeyres Chained Quantity Index
     *  _F_P = Fisher    Chained Price Index *  _F_Q = Fisher    Chained Quantity Index
--------------------------------------------------------------------------------

 * Price Index Results File Has Been saved in:
 Data Directory:   D:\Stata
 Open File:        Index.txt
--------------------------------------------------

{p2colreset}{...}
{marker 06}{bf:{err:{dlgtab:Authors}}}

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
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/pmi520.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/pmi520.htm"}}

{bf:{err:{dlgtab:INDEX Citation}}}

{p 1}{cmd:Emad Abd Elmessih Shehata & Mickaiel, Sahra Khaleel A. (2015)}{p_end}
{p 1 10 1}{cmd:INDEX: "Stata Module to Estimate Price, Quantity, and Value Index Numbers"}{p_end}


{title:Online Help:}

{helpb index}{col 8}Index Numbers{col 57}(index)
{helpb cfm}{col 8}Cost Function Models{col 57}(CFM)
{helpb index}{col 8}Financial Analysis Models{col 57}(index)
{helpb gcrtm}{col 8}Geographical Concentration Regional Trade Models{col 57}(GCRTM)
{helpb gcstm}{col 8}Geographical Concentration Sectoral Trade Models{col 57}(GCSTM)
{helpb iic}{col 8}Investment Indicators Criteria{col 57}(IIC)
{helpb iot}{col 8}Leontief Input - Output Table{col 57}(IOT)
{helpb mef}{col 8}Marketing Efficiency Models{col 57}(MEF)
{helpb pam}{col 8}Policy Analysis Matrix{col 57}(PAM)
{helpb pem}{col 8}Partial Equilibrium Model{col 57}(PEM)
{helpb rcatm}{col 8}Revealed Comparative Advantage Trade Models{col 57}(RCATM)
{helpb tic}{col 8}Trade Indicators Criteria{col 57}(TIC)
{helpb tim}{col 8}Trade Indicators Models{col 57}(TIM)
{helpb xbcr}{col 8}Benefit-Cost Ratio{col 57}(BCR)
{helpb xirr}{col 8}Internal Rate of Return{col 57}(xirr)
{helpb xmirr}{col 8}Modified Internal Rate of Return{col 57}(MIRR)
{helpb xnfv}{col 8}Net Future Value{col 57}(NFV)
{helpb xnpv}{col 8}Net Present Value{col 57}(XNPV)
{helpb xpp}{col 8}Payback Period{col 57}(PP)

{psee}
{p_end}

