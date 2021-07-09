*!Amadou B. DIALLO
*!AFTPM, The World Bank, and CERDI, Univ. of Auvergne.
*!August 08, 2005
*!Program to compute the concentration index on grouped data using covariance/formula method.
*!It is the equivalent of the excel file provided by Wagstaff and al.
*!http://web.worldbank.org/WBSITE/EXTERNAL/TOPICS/EXTHEALTHNUTRITIONANDPOPULATION/EXTPAH/0,,contentMDK:20216933~menuPK:460204~pagePK:148956~piPK:216618~theSitePK:400476,00.html

#d;

prog concindexg, rclass sortpreserve byable(recall);

cap mat drop A W W2 R SD A A1 A2 A3 A1s A2s A3s F Q CI FR AM FA SIG JJ CCI VCCI SCCI TCCI T 
w f ci fr fa sig jj V A3C FC;

se mo 1;

preserve;

vers 8.2;

syntax varlist(min=1) [if] [in] [aweight pweight fweight] , Welfarevar(varname) 
[ Drop Format(string) SPlitvars(varlist) SE CLean ];

qui drop if `welfarevar' == .;

marksample touse, novar;
if "`by'" ~= "" {;
    markout `touse' `by' , strok;
};

cap so `welfarevar';  // Welfare indicator;

qui ta `welfarevar' [`weight' `exp'] if `touse', m;
loc nn = r(r);

token `varlist';

loc myvars "`varlist'";

// Are there variables with more than 2 modalities? ;

 // Checking that and put variables for analysis in a macro;

if "`splitvars'" ~= "" {;
  token `splitvars';
  loc tosplit "`splitvars'";
  loc rest: list myvars - tosplit ;
  loc splited;
  token `splitvars';
  while "`1'" ~= "" {;
   cap drop `1'_*;
   qui ta `1' , g(`1'_);
   loc splited "`splited' `1'_*";
   mac shift;
  };
  loc fact "`rest' `splited'";
};
else if "`splitvars'" == "" {;
  loc fact "`varlist'";
};

qui unab fact: `fact';

qui foreach i of local fact {;
  nmissing `i';
  if r(N) ==  0 {;
    di _n;
    di in g "There is no missing in variable " in y "`i'." _n;
  };
  else {;
    di _n;
    di in y "`i'" in g " has " in y r(N) in g " missings. You should check it." _n;
  };
};

qui {;

    // Number of persons per quintiles;
    ta `welfarevar' [`weight' `exp'], matcell(W);
    matsum W, col(w);
    sca sw = w[1,1];
    loc n = rowsof(W);

    // Relative percentage of people;
    forv i = 1 / `n' {;
      sca ele = el(W,`i',1) / sw;
      mat W2 = nullmat(W2) \ ele;
    };

    // Cumul % of people;
    Cum W2 V `n';

    // R matrice;
    mat R = 0.5 * el(W2,1,1);
    forv i = 2 / `n' {;
       sca el1 = el(V,`i'-1,1);
       sca el2 = 0.5 * el(W2,`i',1);
       sca ele = el1 + el2;
       mat R = nullmat(R) \ ele;
    };

};

foreach var of local fact {;

  qui {;

    if "`se'" ~= "" {;
       qui levelsof `welfarevar' , l(l);
       foreach i of local l {;
          su `var' [`weight' `exp'] if `welfarevar' == `i' & `touse';
          loc sd`i' = r(sd);
          mat SD = nullmat(SD) \ `sd`i'' ;
       };
    };

    // Target variable (quintile means);
    ta `welfarevar' `var'  [`weight' `exp'] if `touse', row nof matcell(A) m;

    // Constructing matrice for those with "access";
    mat A1 = A[1...,1];
    mat A2 = A[1...,2];
    mat A3 = A1 + A2;
    loc c = colsof(A);
    Cum A3 A3C `n';

    // Building up the matrice;
    forv i = 1 / `c' {;
      forv j = 1 / `n' {;
          sca ele = (el(A`i',`j',1) / el(A3,`j',1)); 
          mat A`i's = nullmat(A`i's) \ ele;
      };
    };

    // f_mu matrice;
    forv i = 1 / `n' {;
       sca el1 = el(W2,`i',1);
       sca el2 = el(A2s,`i',1);
       sca ele = (el1 * el2);
       mat F = nullmat(F) \ ele;
    };

    // cum_f_mu matrice;
    Cum F FC `n';

    // Computing the sumproduct;
    matsum F, col(f);
    loc fel = f[1,1];

    // q matrice;
    forv i = 1 / `n' {;
      sca ele = el(FC,`i',1) / `fel';
      mat Q = nullmat(Q) \ ele;
    };

    // Concentration Index;
    loc n2 = `n'-1;
    forv i = 1 / `n2' {;
      sca el1 = el(V,`i',1) * el(Q,`i'+1,1);
      sca el2 = el(V,`i'+1,1) * el(Q,`i',1);
      sca ele = el1-el2;
      mat CI = nullmat(CI) \ ele;
    };
    mat CI = nullmat(CI) \ 0;
    matsum CI, col(ci);
    sca ci = ci[1,1];

    // f_mu_R matrice;
    forv i = 1 / `n' {;
       sca el1 = el(F,`i',1);
       sca el2 = el(R,`i',1);
       sca ele = (el1 * el2);
       mat FR = nullmat(FR) \ ele;
    };
    matsum FR, col(fr);
    sca fr = (2 / `fel') * el(fr,1,1)-1;

    // "a" matrice;
    sca el1 = (el(A2s,1,1) / `fel')  ;
    sca el2 = 2 * el(R,1,1) - 1 - ci ;
    sca el3 = 2 - el(Q,1,1);
    mat AM = (el1 * el2) + el3;
    forv i = 2 / `n' {;
       sca el1 = el(A2s,`i',1) / `fel';
       sca el2 = 2 * el(R,`i',1) - 1 - ci;
       sca el3 = 2 - el(Q,`i'-1,1) - el(Q,`i',1);
       sca ele = (el1 * el2)+ el3;
       mat AM = nullmat(AM) \ ele;
    };

    // f*a^2 matrice;
    forv i = 1 / `n' {;
       sca el1 = el(AM,`i',1)^2;
       sca el2 = el(W2,`i',1);
       sca ele = (el1 * el2);
       mat FA = nullmat(FA) \ ele;
    };
    matsum FA, col(fa);
    sca fa = fa[1,1];

    // Calculating the variance of the concentration index;
    if "`se'" ~= "" {;      // If Standrad Errors requested;
       // f x sig tsq etc. matrice;
       sca fa2 = (1 / sw) * (fa - ((1 + ci) ^ 2));
       forv i=1 / `n' {;
          sca el1 = el(W2, `i', 1);
          sca el2 = el(SD, `i', 1)^2;
          sca el3 = (2 * el(R, `i', 1) - 1 - fr ) ^ 2;
          sca ele = (el1 * el2 * el3);
          mat SIG = nullmat(SIG) \ ele ;
          sca el2 = el(A2s, `i', 1);
          sca ele = (el1 * el2);
          mat JJ = nullmat(JJ) \ ele ;
       };
       matsum SIG, col(sig);
       sca sig = sig[1,1];
       matsum JJ, col(jj);
       sca jj = jj[1,1];
       sca fx = (sig / (sw * (jj ^ 2)));
       sca vari = fa2 + fx;
     };
     else {;       // No Standrad Errors available;
       sca vari = (1 / `n') * (fa - ((1 + ci) ^ 2));
     };

    // Standard deviation of the concentration index;
    sca svar = sqrt(vari);

    // Ttest for the concentration index;
    sca ttvar = ci / svar;

  };

  mat CCI = nullmat(CCI) \ ci;
  mat VCCI = nullmat(VCCI) \ vari;
  mat SCCI = nullmat(SCCI) \ svar;
  mat TCCI = nullmat(TCCI) \ ttvar;
  mat T = CCI,VCCI,SCCI,TCCI;

};

mat coln T = CI varCI seCI ttestCI;
mat rown T = `fact';

di _n;
di in g "Final matrice of Concentration Indices on Grouped Data." _n;

if "`format'" ~= "" {;
   mat li T, noh f(`format');
   di _n;
};
else {;
   mat li T, noh;
   di _n;
};

noi di in y "CI :      " in g "Concentration index using formula/covariance method" ;
noi di in y "varCI :   " in g "Variance of the concentration index" ;
noi di in y "seCI :    " in g "Standard errors of the concentration index" ;
noi di in y "ttestCI : " in g "T-test of the concentration index" _n ;

ret mat CIG = T, copy;


// Cleaning;
if "`clean'" ~= "" {;
   mat drop A W W2 R A1 A2 A3 A1s A2s A3s F Q CI FR AM FA CCI VCCI SCCI TCCI T w f V A3C FC;
   sca drop sw ci fr fa vari svar ttvar el eli el1 el2 el3 ele ;
   if "`se'" ~= "" {;     
      mat drop SD SIG JJ ;
      sca drop fa2 sig jj fx ;
   };
};

restore;

end;

prog Cum;
    mac def eli 0;
    forv i = 1 / `3' {;
      sca el = el(`1',`i',1) ;
      sca eli = $eli + el;
      mat `2' = nullmat(`2') \ eli;
      gl eli = eli;
    };
    mac drop eli;
end;

exit;

syntax: concindexg v119 v120 v121 v122 v123 v124 v125 $po, w(quint) d sp(v113 v116 v127) se cl