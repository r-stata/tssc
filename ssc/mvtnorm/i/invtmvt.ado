*! Date    : 03 Jan 2019
*! Version : 1.1
*! Authors : Michael J Grayling & Adrian P Mander

/*
  30/10/17 v1.0 Basic version complete.
  03/01/19 v1.1 Minor changes for speed. Converted delta and sigma to be 
                optional with internal defaults.
*/

program define invtmvt, rclass
version 15.0
syntax , p(real) LOWERTruncation(numlist miss) UPPERTruncation(numlist miss) ///
         [DELta(numlist) Sigma(string) df(integer 1) Tail(string) ///
		 MAX_iter(integer 1000000) TOLerance(real 0.000001) ///
		 INTegrator(string) SHIfts(integer 12) SAMples(integer 1000)]
		 
///// Check input variables ////////////////////////////////////////////////////

if ("`tail'" == "") {
  local tail "lower"
}
if ("`integrator'" == "") {
  local integrator "pmvnormal"
}
if ((`p' < 0) | (`p' > 1)) {
  di "{error}Probability (p) must be between 0 and 1."
} 
local lenlowert:list sizeof lowertruncation
local lenuppert:list sizeof uppertruncation
local lendelta:list  sizeof delta
if (`lenlowert' != `lenuppert') {
  di "{error}Vector of lower truncation limits (lowertruncation) and vector of upper truncation limits (uppertruncation) must be of equal length."
  exit(198)
}
if (`lenlowert' > 100) {
  di "{error}Only truncated multivariate normal distributions of dimension up to 100 are supported."
  exit(198)
}
forvalues i = 1/`lenlowert' {
  local lowerti:word `i' of `lowertruncation'
  local upperti:word `i' of `uppertruncation'
  if ((`lowerti' != .) & (`upperti' != .)) {
    if (`lowerti' >= `upperti') {
      di "{error}Each lower truncation limit (in lowertruncation) must be strictly less than the corresponding upper truncation limit (in uppertruncation)."
      exit(198)
    }
  }
}
if ((`lendelta' != 0) & (`lenlowert' != `lendelta')) {
  di "{error}Vector of non-centrality parameters (delta) and vector of lower truncation limits (lower) must be of equal length."
  exit(198)
}
if ("`sigma'" != "") {
  if (colsof(`sigma') != rowsof(`sigma')) {
    di "{error}Scale matrix Sigma (sigma) must be square."
    exit(198)
  }
  if (`lenlowert' != colsof(`sigma')) {
    di "{error}Vector of lower truncation limits (lowertruncation) must be the same length as the dimension of scale matrix Sigma (sigma)."
    exit(198)
  }
  cap mat chol = cholesky(`sigma')
  if (_rc > 0) {
    di "{error}Scale matrix Sigma (sigma) must be symmetric positive-definite."
    exit(198)
  }
  mat sigma    = (`sigma')
}
else {
  mat sigma    = I(`lenlowert')
}
if (`df' < 0) {
  di "{error}Degrees of freedom (df) must be greater than or equal to zero."
  exit(198)
}
if (("`tail'" != "lower") & ("`tail'" != "upper") & ("`tail'" != "both")) {
  di "{error}tail must be set to one of lower, upper, or both."
  exit(198)
}
if (`shifts' < 1) {
  di "{error}Number of shifts of the Quasi-Monte-Carlo integration algorithm to use (shifts) must be a strictly positive integer."
  exit(198)
}
if (`samples' < 1) {
  di "{error}Number of samples to use in each shift of the Quasi-Monte-Carlo integration algorithm (samples) must be a strictly positive integer."
  exit(198)
}
if (`max_iter' < 1) {
  di "{error}Number of allowed iterations in the quantile (root-)finding algorithm (max_iter) must be a strictly positive integer."
  exit(198)
}
if (`tolerance' < 0) {
  di "{error}The tolerance in the quantile (root-)finding algorithm (tolerance) must be strictly positive."
  exit(198)
}
if (("`integrator'" != "mvnormal") & ("`integrator'" != "pmvnormal")) {
  di "{error}Choice of integrator (integrator) must be mvnormal or pmvnormal."
  exit(198)
}

///// Perform main computations ////////////////////////////////////////////////

local matalowert ""
foreach l of local lowertruncation {
  if "`matalowert'" == "" local matalowert "`l'"
  else local matalowert "`matalowert',`l'"
}
mat lowert  = (`matalowert')
local matauppert ""
foreach l of local uppertruncation {
  if "`matauppert'" == "" local matauppert "`l'"
  else local matauppert "`matauppert',`l'"
}
mat uppert  = (`matauppert')
if (`lendelta' != 0) {
  local matadelta ""
  foreach l of local delta {
    if "`matadelta'" == "" local matadelta "`l'"
    else local matadelta "`matadelta',`l'"
  }
  mat delta = (`matadelta')
}
else {
  mat delta = J(1, `lenlowert', 0)
}
mata: invtmvt_void(`p', `df', "`tail'", `max_iter', `tolerance', "`integrator'", `shifts', `samples')

///// Output ///////////////////////////////////////////////////////////////////

mat returns              = returns
return scalar iterations = returns[5, 1]
return scalar fquantile  = returns[4, 1]
return scalar flag       = returns[3, 1]
return scalar error      = returns[2, 1]
return scalar quantile   = returns[1, 1]
di "{txt}quantile   = {res}" returns[1, 1] "{txt}"
di "{txt}error      = {res}" returns[2, 1] "{txt}"
di "{txt}flag       = {res}" returns[3, 1] "{txt}"
di "{txt}fquantile  = {res}" returns[4, 1] "{txt}"
di "{txt}iterations = {res}" returns[5, 1] "{txt}"
end

///// Mata /////////////////////////////////////////////////////////////////////

mata:

void invtmvt_void(p, df, tail, max_iter, tolerance, integrator, shifts,
                  samples) {
  lowert  = st_matrix("lowert")
  uppert  = st_matrix("uppert")
  delta   = st_matrix("delta")
  Sigma   = st_matrix("sigma")
  st_matrix("returns", invtmvt_mata(p, lowert, uppert, delta, Sigma, df, tail,
                                    max_iter, tolerance, integrator, shifts,
									samples)) 
}	

real colvector invtmvt_mata(real scalar p, real vector lowert,
                            real vector uppert, real vector delta,
                            real matrix Sigma, real scalar df, string tail,
							real scalar max_iter, real scalar tolerance,
							string integrator, real scalar shifts,
							real scalar samples) {		
					
  if (p == 0) {
    return((min(lowert) \ 0 \ 0 \ 0 \ 0))
  }
  else if (p == 1) {
    return((max(uppert) \ 0 \ 0 \ 0 \ 0))
  }
  else {
    k               = rows(Sigma)
	denominator     = mvt_mata(lowert, uppert, delta, Sigma, df, integrator,
	                           shifts, samples, 3)[1]
	a               = min(lowert)
	if (a == .) {
	  a             = -8e307
	}
	b               = max(uppert)
	if (b == .) {
	  b             = 8e307
	}
	fa              = invtmvt_mata_int(a, p, lowert, uppert, delta, Sigma, df,
	                                   tail, integrator, shifts, samples,
									   denominator)
    fb              = invtmvt_mata_int(b, p, lowert, uppert, delta, Sigma, df,
	                                   tail, integrator, shifts, samples,
									   denominator)
	if (((fa < 0) & (fb > 0)) | ((fa > 0) & (fb < 0))) {
      half_tol    = 0.5*tolerance
      c           = b
      fc          = fb
      for (iter = 1; iter <= max_iter; iter++) {
        if (((fb > 0) & (fc > 0)) | ((fb < 0) & (fc < 0))) {
          c       = a
	      fc      = fa
	      d       = b - a
	      e       = d
	    }
	    if (abs(fc) < abs(fb)) {
	      a       = b
	      b       = c
	      c       = a
	      fa      = fb
	      fb      = fc
	      fc      = fa
	    }
	    tol1      = 6e-8*abs(b) + half_tol
	    xm        = 0.5*(c - b)
		if ((abs(xm) <= tol1) | (fb == 0)) {
	      return((b \ abs(0.5*(b - a)) \ 0 \ fb \ iter))
	    }
	    if ((abs(e) >= tol1) & (abs(fa) > abs(fb))) {
	      s       = fb/fa
	      if (a == c) {
	        pi    = 2*xm*s
		    q     = 1 - s
	      }
	      else {
	        q     = fa/fc
		    r     = fb/fc
		    pi    = s*(2*xm*q*(q - r) - (b - a)*(r - 1))
            q     = (q - 1)*(r - 1)*(s - 1)
	      }
	      if (pi > 0) {
	        q     = -q
	      }
	      pi      = abs(pi)
	      if (2*pi < min((3*xm*q - abs(tol1*q), abs(e*q)))) {
	        e     = d
		    d     = pi/q
	      }
	      else {
	        e     = d = xm
	      }
	    }
	    else {
	      e       = d = xm
	    }
	    a         = b
	    fa        = fb
		if (abs(d) > tol1) {
	      b       = b + d
	    }
	    else {
	      b       = b + tol1*sign(xm)
	    }
	    fb        = invtmvt_mata_int(b, p, lowert, uppert, delta, Sigma, df,
	                                 tail, integrator, shifts, samples,
									 denominator)
      }
      return((b \ abs(0.5*(b - a)) \ 1 \ fb \ iter))
	}
	else {
	  return((. \ . \ 2 \ . \ .))
	}
  }
}

real scalar invtmvt_mata_int(real scalar q, real scalar p, real vector lowert,
                             real vector uppert, real vector delta,
                             real matrix Sigma, real scalar df, string tail,
							 string integrator, real scalar shifts,
							 real scalar samples, real scalar denominator) {
  k          = rows(Sigma)
  if (tail == "lower") {
    a        = J(1, k, .)
    b        = J(1, k, q)
  }
  else if (tail == "upper") {
    a        = J(1, k, q)
    b        = J(1, k, .)
  }
  else {
    a        = J(1, k, -q)
    b        = J(1, k, q)
  }
  aact       = J(1, k, 0)
  bact       = J(1, k, 0)
  for (i = 1; i <= k; i++) {
    aact[i]  = max((a[i], lowert[i]))
	bact[i]  = min((b[i], uppert[i]))
  }
  return(mvt_mata(aact, bact, delta, Sigma, df, integrator, shifts, samples,
                  3)[1]/denominator - p)
}


real scalar integrate(real scalar lower, real scalar upper, real vector arg) {
  if (((lower == .) & (upper == .)) | ((lower == 0) & (upper == .)) |
        ((lower != .) & (upper != .))) {
    return(integrate_main(lower, upper, arg))
  }
  else if ((lower == .) & (upper != .)) {
    return(integrate_main(0, upper, arg) + integrate_main(0, ., arg))
  }
  else if ((lower != 0) & (upper == .)) {
    return(integrate_main(lower, 0, arg) + integrate_main(0, ., arg))
  }
  else {
    return(integrate_main(lower, upper, arg))
  }  
}

real matrix integrate_main(real lower, real upper, real vector arg) {
  if ((lower != .) & (upper != .)) {
    rw  = ( .9997137268,  .9984919506,  .9962951347,  .9931249370,
	        .9889843952,  .9838775407,  .9778093585,  .9707857758,
			.9628136543,  .9539007829,  .9440558701,  .9332885350,
			.9216092981,  .9090295710,  .8955616450,  .8812186794,
			.8660146885,  .8499645279,  .8330838799,  .8153892383,
			.7968978924,  .7776279096,  .7575981185,  .7368280898,
			.7153381176,  .6931491994,  .6702830156,  .6467619085,
			.6226088602,  .5978474702,  .5725019326,  .5465970121,
			.5201580199,  .4932107892,  .4657816498,  .4378974022,
			.4095852917,  .3808729816,  .3517885264,  .3223603439,
			.2926171880,  .2625881204,  .2323024818,  .2017898641,
			.1710800805,  .1402031372,  .1091892036,  .0780685828,
			.0468716824,  .0156289844, -.0156289844, -.0468716824,
		   -.0780685828, -.1091892036, -.1402031372, -.1710800805,
		   -.2017898641, -.2323024818, -.2625881204, -.2926171880,
           -.3223603439, -.3517885264, -.3808729816, -.4095852917,
		   -.4378974022, -.4657816498, -.4932107892, -.5201580199,
		   -.5465970121, -.5725019326, -.5978474702, -.6226088602,
           -.6467619085, -.6702830156, -.6931491994, -.7153381176,
		   -.7368280898, -.7575981185, -.7776279096, -.7968978924,
		   -.8153892383, -.8330838799, -.8499645279, -.8660146885,
           -.8812186794, -.8955616450, -.9090295710, -.9216092981,
		   -.9332885350, -.9440558701, -.9539007829, -.9628136543,
		   -.9707857758, -.9778093585, -.9838775407, -.9889843952,
           -.9931249370, -.9962951347, -.9984919506, -.9997137268 \
			.0007346345,  .0017093927,  .0026839254,  .0036559612,
			.0046244501,  .0055884280,  .0065469485,  .0074990733,
            .0084438715,  .0093804197,  .0103078026,  .0112251140,
			.0121314577,  .0130259479,  .0139077107,  .0147758845,
			.0156296211,  .0164680862,  .0172904606,  .0180959407,
            .0188837396,  .0196530875,  .0204032326,  .0211334421,
			.0218430024,  .0225312203,  .0231974232,  .0238409603,
			.0244612027,  .0250575445,  .0256294029,  .0261762192,
            .0266974592,  .0271926134,  .0276611982,  .0281027557,
			.0285168543,  .0289030896,  .0292610841,  .0295904881,
			.0298909796,  .0301622651,  .0304040795,  .0306161866,
            .0307983790,  .0309504789,  .0310723374,  .0311638357,
			.0312248843,  .0312554235,  .0312554235,  .0312248843,
			.0311638357,  .0310723374,  .0309504789,  .0307983790,
            .0306161866,  .0304040795,  .0301622651,  .0298909796,
			.0295904881,  .0292610841,  .0289030896,  .0285168543,
			.0281027557,  .0276611982,  .0271926134,  .0266974592,
            .0261762192,  .0256294029,  .0250575445,  .0244612027,
			.0238409603,  .0231974232,  .0225312203,  .0218430024,
			.0211334421,  .0204032326,  .0196530875,  .0188837396,
            .0180959407,  .0172904606,  .0164680862,  .0156296211,
			.0147758845,  .0139077107,  .0130259479,  .0121314577,
			.0112251140,  .0103078026,  .0093804197,  .0084438715,
            .0074990733,  .0065469485,  .0055884280,  .0046244501,
			.0036559612,  .0026839254,  .0017093927,  .0007346345)
    sum = rw[2, ]:*sf((upper - lower)/2*rw[1, ] :+ (upper + lower)/2, arg)
    return((upper - lower)/2*quadrowsum(sum))
  }
  else if (lower == 0 & upper == .) {
    rw  = (374.9841128000, 355.2613119000, 339.4351019000, 325.6912634000,
	       313.3295340000, 301.9858553000, 291.4401336000, 281.5463283000,
	       272.2011700000, 263.3281685000, 254.8686293000, 246.7762410000, 
           239.0136298000, 231.5500680000, 224.3598948000, 217.4213933000,
		   210.7159729000, 204.2275596000, 197.9421331000, 191.8473694000,
		   185.9323602000, 180.1873909000, 174.6037612000, 169.1736398000,
           163.8899456000, 158.7462485000, 153.7366875000, 148.8559014000,
		   144.0989700000, 139.4613646000, 134.9389050000, 130.5277232000,
		   126.2242308000, 122.0250921000, 117.9271991000, 113.9276512000,
           110.0237356000, 106.2129115000, 102.4927949000,  98.8611460500,
		    95.3158573500,  91.8549432600,  88.4765308200,  85.1788512100,
 	 	    81.9602322200,  78.8190913200,  75.7539294700,  72.7633254300,
            69.8459306400,  67.0004645200,  64.2257101200,  61.5205102900,
		    58.8837639800,  56.3144229900,  53.8114889200,  51.3740103300,
		    49.0010802100,  46.6918335400,  44.4454451100,  42.2611274800,
            40.1381290600,  38.0757323700,  36.0732524100,  34.1300351200,
		    32.2454560000,  30.4189187700,  28.6498541500,  26.9377187300,
		    25.2819938700,  23.6821847600,  22.1378194500,  20.6484479700,
            19.2136415800,  17.8329919500,  16.5061104700,  15.2326276000,
		    14.0121922500,  12.8444711800,  11.7291484900,  10.6659250900,
		     9.6545182440,   8.6946611140,   7.7861023780,   6.9286058290,
             6.1219500310,   5.3659279860,   4.6603468360,   4.0050275820,
		     3.3998048270,   2.8445265430,   2.3390538500,   1.8832608260,
		     1.4770343300,   1.1202738350,    .8128912841,    .5548109376,
              .3459691810,    .1863141021,    .0758036120,    .0143861470 \
		     7.596410e-96,   3.146290e-94,   9.411750e-96,   7.09970e-106,
		     3.82990e-102,   2.953620e-97,   2.133670e-97,   2.228220e-97,
             1.326430e-95,   5.932280e-99,   1.291530e-99,   1.15800e-100,
		     1.657940e-95,   4.53820e-100,   1.815580e-90,   1.437780e-93,
		     2.020360e-91,   1.279760e-88,   6.704800e-86,   2.884880e-83,
             1.037900e-80,   3.152470e-78,   8.153750e-76,   1.809860e-73,
		     3.471850e-71,   5.792630e-69,   8.454960e-67,   1.085370e-64,
		     1.231380e-62,   1.240240e-60,   1.113570e-58,   8.947340e-57,
             6.456270e-55,   4.197750e-53,   2.466810e-51,   1.313980e-49,
		     6.361270e-48,   2.806040e-46,   1.130480e-44,   4.168860e-43,
		     1.410140e-41,   4.383790e-40,   1.254830e-38,   3.313060e-37,
             8.081630e-36,   1.824200e-34,   3.815860e-33,   7.407430e-32,
		     1.336210e-30,   2.242650e-29,   3.506270e-28,   5.112370e-27,
		     6.959200e-26,   8.853230e-25,   1.053590e-23,   1.174020e-22,
             1.226010e-21,   1.200850e-20,   1.104090e-19,   9.536250e-19,
		     7.743090e-18,   5.914430e-17,   4.252610e-16,   2.880120e-15,
		     1.838350e-14,   1.106500e-13,   6.283520e-13,   3.368210e-12,
             1.705060e-11,   8.154800e-11,   3.686330e-10,   1.575600e-09,
		     6.369710e-09,   2.436430e-08,   8.820060e-08,   3.022640e-07,
		     9.808340e-07,   3.014270e-06,   8.774310e-06,    .0000241958,
              .0000632109,    .0001564521,    .0003668548,    .0008148716,
		      .0017143197,    .0034149800,    .0064389510,    .0114854424,
		      .0193678281,    .0308463086,    .0463401336,    .0655510093,
              .0870966385,    .1083141121,    .1254070908,    .1340433397,
		      .1303566130,    .1121151033,    .0796767462,    .0363926059)
    sum = rw[2, ]:*exp(rw[1, ]):*sf(rw[1, ], arg)
    return(quadrowsum(sum))
  }
  else if (lower == . & upper == .) {
    rw  = ( 13.4064873400,  12.82379975000,  12.3429642200,  11.9150619400,
	        11.5214154000,  11.15240439000,  10.8022607500,  10.4671854200,
		    10.1445099400,   9.83226980800,   9.5289658230,   9.2334208900,
             8.9446892170,   8.66199616800,   8.3846969400,   8.1122473110,
		     7.8441823840,   7.58010080800,   7.3196528220,   7.0625310600,
		     6.8084633530,   6.55720703200,   6.3085443610,   6.0622788330,
             5.8182321350,   5.57624164900,   5.3361583600,   5.0978451050,
		     4.8611750920,   4.62603063600,   4.3923020790,   4.1598868550,
		     3.9286886830,   3.69861685900,   3.4695856360,   3.2415136800,
             3.0143235800,   2.78794142400,   2.5622964020,   2.3373204640,
		     2.1129479960,   1.88911553700,   1.6657615090,   1.4428259700,
		     1.2202503910,    .99797743610,    .7759507615,    .5541148236,
              .3324146923,    .11079587240,   -.1107958724,   -.3324146923,
		     -.5541148236,   -.77595076150,   -.9979774361,  -1.2202503910,
		    -1.4428259700,   -1.6657615090,  -1.8891155370,  -2.1129479960,
            -2.3373204640,   -2.5622964020,  -2.7879414240,  -3.0143235800,
		    -3.2415136800,   -3.4695856360,  -3.6986168590,  -3.9286886830,
		    -4.1598868550,   -4.3923020790,  -4.6260306360,  -4.8611750920,
            -5.0978451050,   -5.3361583600,  -5.5762416490,  -5.8182321350,
		    -6.0622788330,   -6.3085443610,  -6.5572070320,  -6.8084633530,
		    -7.0625310600,   -7.3196528220,  -7.5801008080,  -7.8441823840,
            -8.1122473110,   -8.3846969400,  -8.6619961680,  -8.9446892170,
		    -9.2334208900,   -9.5289658230,  -9.8322698080, -10.1445099400,
		   -10.4671854200,  -10.8022607500, -11.1524043900, -11.5214154000,
           -11.9150619400,  -12.3429642200, -12.8237997500, -13.4064873400 \
		     5.908070e-79,    1.972860e-72,   3.083030e-67,   9.019220e-63,
		     8.518880e-59,    3.459480e-55,   7.191530e-52,   8.597560e-49,
             6.420730e-46,    3.185220e-43,   1.100470e-40,   2.748780e-38,
		     5.116230e-36,    7.274570e-34,   8.067430e-32,   7.101810e-30,
		     5.037790e-28,    2.917350e-26,   1.394840e-24,   5.561030e-23,
             1.865000e-21,    5.302320e-20,   1.286830e-18,   2.682490e-17,
		     4.829840e-16,    7.548900e-15,   1.028870e-13,   1.227880e-12,
		     1.287900e-11,    1.191300e-10,   9.747920e-10,   7.075860e-09,
             4.568130e-08,    2.629100e-07,   1.351800e-06,   6.221520e-06,
		      .0000256762,     .0000951716,    .0003172920,    .0009526922,
		      .0025792733,     .0063030003,    .0139156652,    .0277791274,
              .0501758127,     .0820518274,    .1215379868,    .1631300305,
		      .1984628503,     .2188926296,    .2188926296,    .1984628503,
		      .1631300305,     .1215379868,    .0820518274,    .0501758127,
              .0277791274,     .0139156652,    .0063030003,    .0025792733,
		      .0009526922,     .0003172920,    .0000951716,    .0000256762,
		     6.221520e-06,    1.351800e-06,   2.629100e-07,   4.568130e-08,
             7.075860e-09,    9.747920e-10,   1.191300e-10,   1.287900e-11,
		     1.227880e-12,    1.028870e-13,   7.548900e-15,   4.829840e-16,
		     2.682490e-17,    1.286830e-18,   5.302320e-20,   1.865000e-21,
             5.561030e-23,    1.394840e-24,   2.917350e-26,   5.037790e-28,
		     7.101810e-30,    8.067430e-32,   7.274570e-34,   5.116230e-36,
		     2.748780e-38,    1.100470e-40,   3.185220e-43,   6.420730e-46,
             8.597560e-49,    7.191530e-52,   3.459480e-55,   8.518880e-59,
		     9.019220e-63,    3.083030e-67,   1.972860e-72,   5.908070e-79)
    sum = rw[2, ]:*exp(rw[1, ]:^2):*sf(rw[1, ], arg)
    return(quadrowsum(sum))
  }
}

real colvector mvt_mata(real vector lower, real vector upper, real vector delta,
                        real matrix Sigma, real scalar df, string integrator,
						real scalar shifts, real scalar samples,
						real scalar alpha) {
  k                              = rows(Sigma)
  if ((df == 0) | (df == .)) {
    if (integrator == "mvnormal") {
	  for (i = 1; i <= k; i++) {
	    if (lower[i] == .) {
	      lower[i]               = -8e307
	    }
	    if (upper[i] == .) {
	      upper[i]               = 8e307
	    }
	  }
	  return((mvnormalcv(lower, upper, delta, vech(Sigma)') \ .))
	}
	else {
	  return(pmvnormal_mata(lower, upper, delta, Sigma, shifts, samples, alpha))
	}
  }
  else {
    if (k == 1) {
      if ((lower == .) & (upper == .)) {
	    I                    = 1
	  }
	  else if ((lower != .) & (upper == .)) {
	    I                    = 1 - t(df, lower - delta)
	  }
	  else if ((lower == .) & (upper != .)) {
	    I                    = t(df, upper - delta)
	  }
	  else {
	    I                    = t(df, upper - delta) - t(df, lower - delta)
	  }
	  E                      = 0
    }
    else {
      a                      = lower - delta
      b                      = upper - delta
      C                      = J(k, k, 0)
      u                      = y = J(1, k - 1, 0)
      atilde                 = (a[1], J(1, k - 2, 0))
      btilde                 = (b[1], J(1, k - 2, 0))
	  sqrt_Sigma11           = sqrt(Sigma[1, 1])
      for (i = 1; i <= k - 1; i++) {
        args = J(1, k - i + 1, 0)
        for (j = 1; j <= k - i + 1; j++){
          s                  = j + i - 1
          if (i > 1) {
		    y2               = sum(y[1::(i - 1)]:^2)
			Cy               = sum(C[s, 1::(i - 1)]:*y[1::(i - 1)])
			C2               = sum(C[s, 1::(i - 1)]:^2)
            if ((a[s] != .) & (b[s] != .)) {
              args[j]        =
			    t(df + i - 1,
			      sqrt((df + i - 1)/(df + y2))*((b[s] - Cy)/
				                                  sqrt(Sigma[s, s] - C2))) -
				t(df + i - 1,
				  sqrt((df + i - 1)/(df + y2))*((a[s] - Cy)/
						                          sqrt(Sigma[s, s] - C2)))
            }
            else if ((a[s] == .) & (b[s] != .)) {
              args[j]        =
			    t(df + i - 1,
				  sqrt((df + i - 1)/(df + y2))*((b[s] - Cy)/
                                                  sqrt(Sigma[s, s] - C2)))
            }
            else if ((b[s] == .) & (a[s] != .)) {
              args[j]        = 1 -
			    t(df + i - 1,
				  sqrt((df + i - 1)/(df + y2))*((a[s] - Cy)/
                                                  sqrt(Sigma[s, s] - C2)))
            }
            else if ((a[s] == .) & (b[s] == .)) {
              args[j]        = 1
            }
          } 
          else {
            if ((a[s] != .) & (b[s] != .)) {
              args[j]        = t(df, b[s]/sqrt_Sigma11) -
			                     t(df, a[s]/sqrt_Sigma11)
            }
            else if ((a[s] == .) & (b[s] != .)) {
              args[j]        = t(df, b[s]/sqrt_Sigma11)
            }
            else if ((b[s] == .) & (a[s] != .)) {
              args[j]        = 1 - t(df, a[s]/sqrt_Sigma11)
            }
            else if ((a[s] == .) & (b[s] == .)) {
              args[j]        = 1
            }
          }
        }
		ii                   = ww =.
        minindex(args, 1, ii, ww)
        m                    = i - 1 + ii[1]
        if (i != m) {
	      tempa              = a
          tempb              = b
          tempa[i]           = a[m]
          tempa[m]           = a[i]
          a                  = tempa
          tempb[i]           = b[m]
          tempb[m]           = b[i]
          b                  = tempb
          tempSigma          = Sigma
          tempSigma[i, 1::k] = Sigma[m, 1::k]
          tempSigma[m, 1::k] = Sigma[i, 1::k]
          Sigma              = tempSigma
          Sigma[1::k, i]     = tempSigma[1::k, m]
          Sigma[1::k, m]     = tempSigma[1::k, i]
	    }
        if (i > 1) {
          if (i != m) {
		    tempC            = C
            tempC[i, 1::k]   = C[m, 1::k]
            tempC[m, 1::k]   = C[i, 1::k]
            C                = tempC
            C[1::k, i]       = tempC[1::k, m]
            C[1::k, m]       = tempC[1::k, i]
		  }
          C[i, i]            = sqrt(Sigma[i, i] - sum(C[i, 1::(i - 1)]:^2))
          for (s = i + 1; s <= k; s++){
            C[s, i]          =
			  (Sigma[s, i] - sum(C[i, 1::(i - 1)]:*C[s, 1::(i - 1)]))/C[i, i]
          }
		  Cy                 = sum(C[i, 1::(i - 1)]:*y[1::(i - 1)])
          atilde[i]          = (a[i] - Cy)/C[i, i]
          btilde[i]          = (b[i] - Cy)/C[i, i]
        } else {
          C[i, i]            = sqrt(Sigma[i, i])
          C[2::k, i]         = Sigma[2::k, i]/C[i, i]
        }
        arg                  = (df, i)
        u[i]                 =
		  (gamma((df + 1)/2)/(gamma((df + i - 1)/2)*((df + i - 1)*pi())^0.5))*
            integrate(atilde[i], btilde[i], arg)/
                     (t(df + i - 1, btilde[i]) - t(df + i - 1, atilde[i]))
        if (i == 1) {
          y[i]               = u[i]
        }
        else {
          y[i]               =
		    u[i]*sqrt((df + sum(y[1::(i - 1)]:^2))/(df + i - 1))
        }
      }
      C[k, k]                = sqrt(Sigma[k, k] - sum(C[k, 1::(k - 1)]:^2))
	  sqrt_primes            = sqrt((2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37,
	                               41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83,
								   89, 97, 101, 103, 107, 109, 113, 127, 131,
								   137, 139, 149, 151, 157, 163, 167, 173, 179,
								   181, 191, 193, 197, 199, 211, 223, 227, 229,
								   233, 239, 241, 251, 257, 263, 269, 271, 277,
								   281, 283, 293, 307, 311, 313, 317, 331, 337,
								   347, 349, 353, 359, 367, 373, 379, 383, 389,
								   397, 401, 409, 419, 421, 431, 433, 439, 443,
							       449, 457, 461, 463, 467, 479, 487, 491, 499,
								   503, 509, 521, 523, 541)[1::(k - 1)])
      I                      = V = 0
      d                      = J(1, k, 0)
      e                      = J(1, k, 1)
      f                      = J(1, k, 0)
      if (a[1] != .) {
         d[1]                = t(df, a[1]/C[1, 1])
      }
      if (b[1] != .) {
         e[1]                = t(df, b[1]/C[1, 1])
      }
      f                      = (e[1] - d[1], J(1, k - 1, 0))
	  for (i = 1; i <= shifts; i++) {
		Ii                   = 0
        Delta                = runiform(1, k - 1)
        for (j = 1; j <= samples; j++) {
		  u[1]               =
		    invt(df, d[1] + abs(2*mod(j*sqrt_primes[1] + Delta[1], 1) - 1)*
			                  (e[1] - d[1])) 
          y[1]               = u[1]
          for (l = 2; l <= k; l++) {
		    if ((a[l] != .) & (b[l] != .)) {
			  y2             = sum(y[1::(l - 1)]:^2)
			  Cy             = sum(C[l, 1::(l - 1)]:*y[1::(l - 1)])
		      d[l]           = t(df + l - 1,
			                     sqrt((df + l - 1)/(df + y2))*
                                   ((a[l] - Cy)/C[l, l]))
			  e[l]           = t(df + l - 1,
			                     sqrt((df + l - 1)/(df + y2))*
                                   ((b[l] - Cy)/C[l, l]))
		    }
		    else if ((a[l] != .) & (b[l] == .)) {
              d[l]           =
			    t(df + l - 1,
				  sqrt((df + l - 1)/(df + sum(y[1::(l - 1)]:^2)))*
                    ((a[l] - sum(C[l, 1::(l - 1)]:*y[1::(l - 1)]))/C[l, l]))
		    }
            else if ((a[l] == .) & (b[l] != .)) {
              e[l]           =
			    t(df + l - 1,
				  sqrt((df + l - 1)/(df + sum(y[1::(l - 1)]:^2)))*
                    ((b[l] - sum(C[l, 1::(l - 1)]:*y[1::(l - 1)]))/C[l, l]))
            }
		    f[l]             = (e[l] - d[l])*f[l - 1]
            if (l < k) {
              u[l]           =
			    invt(df + l - 1,
				     d[l] + abs(2*mod(j*sqrt_primes[l] + Delta[l], 1) - 1)*
				              (e[l] - d[l]))
              y[l]           =
			    u[l]*sqrt((df + sum(y[1::(l - 1)]:^2))/(df + l - 1))
            }
          }
          Ii                 = Ii + (f[k] - Ii)/j
        }
        del                  = (Ii - I)/i
        I                    = I + del
        V                    = (i - 2)*V/i + del^2
        E                    = alpha*sqrt(V)
      }
    }
  }
  return((I \ E))
}

real colvector pmvnormal_mata(real vector lower, real vector upper, 
                              real vector mean, real matrix Sigma,
							  real scalar shifts, real scalar samples,
							  real scalar alpha) {
  k                             = rows(Sigma)
  if (k == 1) {
    if ((lower == .) & (upper == .)) {
	  I                         = 1
	}
	else if ((lower != .) & (upper == .)) {
	  I                         = 1 - normal((lower - mean)/sqrt(Sigma))
	}
	else if ((lower == .) & (upper != .)) {
	  I                         = normal((upper - mean)/sqrt(Sigma))
	}
	else {
	  sqrt_Sigma                = sqrt(Sigma)
      I                         = normal((upper - mean)/sqrt_Sigma) -
	                                normal((lower - mean)/sqrt_Sigma)
	}
	E                           = 0
  }
  else if (k == 2) {
    if (lower[1] == .) lower[1] = -8e307
	if (lower[2] == .) lower[2] = -8e307
	if (upper[1] == .) upper[1] = 8e307
	if (upper[2] == .) upper[2] = 8e307
	sqrt_Sigma                  = sqrt((Sigma[1, 1], Sigma[2, 2]))
	a                           = (lower - mean):/(sqrt_Sigma[1], sqrt_Sigma[2])
	b                           = (upper - mean):/(sqrt_Sigma[1], sqrt_Sigma[2])
	r                           = Sigma[1, 2]/(sqrt_Sigma[1]*sqrt_Sigma[2])
	I                           =
	  binormal(b[1], b[2], r) + binormal(a[1], a[2], r) -
	    binormal(b[1], a[2], r) - binormal(a[1], b[2], r)
	E                           = 0
  }
  else {
    a                           = lower - mean
    b                           = upper - mean
	C         = J(k, k, 0)
    zero_k_min_2                = J(1, k - 2, 0)
	zero_k_min_1                = (zero_k_min_2, 0)
    y                           = zero_k_min_1
    atilde                      = (a[1], zero_k_min_2)
    btilde                      = (b[1], zero_k_min_2)
	sqrt_Sigma11                = sqrt(Sigma[1, 1])
    args                        = J(1, k, 1)
	for (j = 1; j <= k; j++) {
      if ((a[j] != .) & (b[j] != .)) {
        args[j]                 = normal(b[j]/sqrt_Sigma11) -
			                        normal(a[j]/sqrt_Sigma11) 
      }
      else if ((a[j] == .) & (b[j] != .)) {
        args[j]                 = normal(b[j]/sqrt_Sigma11)
      }
      else if ((b[j] == .) & (a[j] != .)) {
        args[j]                 = 1 - normal(a[j]/sqrt_Sigma11)
      }
    }
	ii                          = ww = .
    minindex(args, 1, ii, ww)
    if (ii[1] != 1) {
	  tempa                     = a
      tempb                     = b
      tempa[1]                  = a[ii[1]]
      tempa[ii[1]]              = a[1]
      a                         = tempa
      tempb[1]                  = b[ii[1]]
      tempb[ii[1]]              = b[1]
      b                         = tempb
      tempSigma                 = Sigma
      tempSigma[1, ]            = Sigma[ii[1], ]
      tempSigma[ii[1], ]        = Sigma[1, ]
      Sigma                     = tempSigma
      Sigma[, 1]                = tempSigma[, ii[1]]
      Sigma[, ii[1]]            = tempSigma[, 1]
	  C[1, 1]                   = sqrt(Sigma[1, 1])
	  C[2::k, 1]                = Sigma[2::k, 1]/C[1, 1]
	}
	else {
	  C[, 1]                     = (sqrt_Sigma11 \ Sigma[2::k, 1]/sqrt_Sigma11)
	}
    if (atilde[1] != btilde[1]) {
	  y[1]                      = (normalden(atilde[1]) - normalden(btilde[1]))/
                                    (normal(btilde[1]) - normal(atilde[1]))
	}
	for (i = 2; i <= k - 1; i++) {
      args                      = J(1, k - i + 1, 1)
	  i_vec                     = 1::(i - 1)
      for (j = 1; j <= k - i + 1; j++) {
        s                       = j + i - 1
		if ((a[s] != .) & (b[s] != .)) {
		    Cy                  = sum(C[s, i_vec]:*y[i_vec])
		    denom               = sqrt(Sigma[s, s] - sum(C[s, i_vec]:^2))
			args[j]             = normal((b[s] - Cy)/denom) -
                                    normal((a[s] - Cy)/denom)
          }
          else if ((a[s] == .) & (b[s] != .)) {
	        args[j]             =
			  normal((b[s] - sum(C[s, i_vec]:*y[i_vec]))/
			           sqrt(Sigma[s, s] - sum(C[s, i_vec]:^2))) 
          }
          else if ((b[s] == .) & (a[s] != .)) {
  	        args[j]             =
			  1 - normal((a[s] - sum(C[s, i_vec]:*y[i_vec]))/
			               sqrt(Sigma[s, s] - sum(C[s, i_vec]:^2)))
          }
      }
	  ii                        = ww = .
      minindex(args, 1, ii, ww)
      m                         = i - 1 + ii[1]
	  if (i != m) {
	    tempa                   = a
        tempb                   = b
        tempa[i]                = a[m]
        tempa[m]                = a[i]
        a                       = tempa
        tempb[i]                = b[m]
        tempb[m]                = b[i]
        b                       = tempb
        tempSigma               = Sigma
        tempSigma[i, ]          = Sigma[m, ]
        tempSigma[m, ]          = Sigma[i, ]
        Sigma                   = tempSigma
        Sigma[, i]              = tempSigma[, m]
        Sigma[, m]              = tempSigma[, i]
		tempC                   = C
        tempC[i, ]              = C[m, ]
        tempC[m, ]              = C[i, ]
        C                       = tempC
        C[, i]                  = tempC[, m]
        C[, m]                  = tempC[, i]
	  }
      C[i, i]                   = sqrt(Sigma[i, i] - sum(C[i, i_vec]:^2))
      i_vec2                    = (i + 1)::k
	  C[i_vec2, i]              =
	    (Sigma[i_vec2, i] - rowsum(J(k - i, 1, C[i, i_vec]):*C[i_vec2, i_vec]))/
		  C[i, i]
	  Cy                        = sum(C[i, i_vec]:*y[i_vec])
      atilde[i]                 = (a[i] - Cy)/C[i, i]
      btilde[i]                 = (b[i] - Cy)/C[i, i]
	  if (atilde[i] != btilde[i]) {
	    y[i]                    = (normalden(atilde[i]) - normalden(btilde[i]))/
                                    (normal(btilde[i]) - normal(atilde[i]))
	  }
    }
    C[k, k] = sqrt(Sigma[k, k] - sum(C[k, 1::(k - 1)]:^2))
	C
    I                           = V = 0
    if (a[1] != .) {
      d                         = J(samples, 1, (normal(a[1]/C[1, 1]), J(1, k - 1, 0)))
    }
	else {
	  d                         = J(samples, k, 0)
	}
    if (b[1] != .) {
      e                         = J(samples, 1, (normal(b[1]/C[1, 1]), J(1, k - 1, 1)))
    }
	else {
	  e                         = J(samples, 1, J(1, k, 1))
	}
    f                           = (e[, 1] - d[, 1], J(samples, k - 1, 0))
	y = J(samples, k - 1, 0)
	Delta                       = runiform(shifts, k - 1)
	samples_sqrt_primes         =
	  (1::samples)*sqrt((2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47,
	                     53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107,
						 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167,
						 173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229,
						 233, 239, 241, 251, 257, 263, 269, 271, 277, 281, 283,
						 293, 307, 311, 313, 317, 331, 337, 347, 349, 353, 359,
						 367, 373, 379, 383, 389, 397, 401, 409, 419, 421, 431,
						 433, 439, 443, 449, 457, 461, 463, 467, 479, 487, 491,
						 499, 503, 509, 521, 523, 541)[1::(k - 1)])
	Ii                          = J(1, shifts, 0)
	"h"
	for (i = 1; i <= shifts; i++) {
	  for (l = 2; l <= k; l++) {
		l_vec                 = 1::(l - 1)
		y[, l - 1]            =
		  invnormal(d[, l - 1] + abs(2*mod(samples_sqrt_primes[, l - 1] :+
       				                     Delta[i, l - 1], 1) :- 1):*
								   (e[, l - 1] - d[, l - 1]))
		if ((a[l] != .) & (b[l] != .)) {
		  Cy                  = rowsum(J(samples, 1, C[l, l_vec]):*y[, l_vec])
		  d[, l]                = normal((a[l] :- Cy)/C[l, l])
	      e[, l]                = normal((b[l] :- Cy)/C[l, l])
		  f[, l]                = (e[, l] :- d[, l]):*f[, l - 1]
		}
		else if ((a[l] != .) & (b[l] == .)) {
          d[, l]                =
	        normal((a[l] :- rowsum(J(samples, 1, C[l, l_vec]):*y[, l_vec]))/C[l, l])
		  f[, l]                = (1 :- d[, l]):*f[, l - 1]
		}
        else if ((a[l] == .) & (b[l] != .)) {
          e[, l]                =
	        normal((b[l] :- rowsum(J(samples, 1, C[l, l_vec]):*y[, l_vec]))/C[l, l])
		  f[, l]                = e[, l]:*f[, l - 1]
        }
		else {
		  f[, l]                = f[, l - 1]
		}
      }
	  for (j = 1; j <= samples; j++) {
	    Ii[i]                   = Ii[i] + (f[j, k] - Ii[i])/j
	  }
	  del                       = (Ii[i] - I)/i
	  I                         = I + del
	  V                         = (i - 2)*V/i + del^2
      E                         = alpha*sqrt(V)
	}
  }
  return((I \ E))
}

real vector sf(real rowvector s, real vector arg) {
  return(s:*(1 :+ (s:^2)/(arg[1] + arg[2] - 1)):^(-(arg[1] + arg[2])/2))
}

end
