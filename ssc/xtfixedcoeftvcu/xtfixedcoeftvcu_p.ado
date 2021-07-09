*! version 1.0.0
*! Predict program for the command xtfixedcoeftvcu
*! Diallo Ibrahima Amadou
*! All comments are welcome, 06Jan2016





capture program drop xtfixedcoeftvcu_p
program xtfixedcoeftvcu_p, sortpreserve
    version 13.1
	syntax anything(id="newvarname") [if] [in] [,  xball xbeta xalpha xlambda fcresids  ]

    local nopts : word count `xball' `xbeta' `xalpha' `xlambda' `fcresids'
    if `nopts' >1 {
        display "{err}only one statistic may be specified"
        exit 498
    }	
	local lignecom = e(cmdline)
	local nomcom = e(cmd)
	gettoken firstsansv restoptions : lignecom, parse(",")
	local lesvariables: list firstsansv - nomcom
    quietly {
             tsset
             local panelvarrs "`r(panelvar)'"
             local timevarrs  "`r(timevar)'"
             tempfile maindata sampledata
             sort `panelvarrs' `timevarrs'
             save `maindata',replace
             return clear
			 tempvar myztouse
             selectionechant `lesvariables' `if' `in', zvarselfc(`myztouse') 
			 keep if `myztouse' == 1
	         capture drop _resultxbeta _resultxalpha _resultxlambda _resultxball _resultfcresids  
	         generate double _resultxbeta    = .
	         generate double _resultxalpha   = .
	         generate double _resultxlambda  = .
	         generate double _resultxball    = .
	         generate double _resultfcresids = .
	}
	


	if "`xbeta'" != "" {
						syntax newvarname [if] [in] [, xbeta ]
						quietly {
								 makepredictionfc `lesvariables'  `if' `in'
								 generate `typlist' `varlist'  = _resultxbeta `if' `in'
								 label variable `varlist' "Linear prediction from the ConstantCoefs equation only"
								 sort `panelvarrs' `timevarrs'
								 keep `panelvarrs' `timevarrs' `varlist'
								 save `sampledata',replace
								 capture clear
								 quietly use `maindata', clear
								 merge 1:1 `panelvarrs' `timevarrs' using `sampledata'
								 drop _merge
								 count if `varlist' >= .
								 local nbmissres = r(N)
						}
						if `nbmissres' > 0 {
											display as text "(`nbmissres' missing values generated)"
						}
						quietly capture drop _resultxbeta _resultxalpha _resultxlambda _resultxball _resultfcresids 
						exit
	}
	


	if "`xalpha'" != "" {
						 syntax newvarname [if] [in] [, xalpha ]
						 quietly {
								  makepredictionfc `lesvariables'  `if' `in'
								  generate `typlist' `varlist'  = _resultxalpha `if' `in'
								  label variable `varlist' "Linear prediction from the GroupSpecCoefs equation only"
								  sort `panelvarrs' `timevarrs'
								  keep `panelvarrs' `timevarrs' `varlist'
								  save `sampledata',replace
								  capture clear
								  quietly use `maindata', clear
								  merge 1:1 `panelvarrs' `timevarrs' using `sampledata'
								  drop _merge
								  count if `varlist' >= .
								  local nbmissres = r(N)
						 }
						 if `nbmissres' > 0 { 
											 display as text "(`nbmissres' missing values generated)"
						 }
						 quietly capture drop _resultxbeta _resultxalpha _resultxlambda _resultxball _resultfcresids 
						 exit
	}



	if "`xlambda'" != "" {
						  syntax newvarname [if] [in] [, xlambda ]
						  quietly {
								   makepredictionfc `lesvariables'  `if' `in'
								   generate `typlist' `varlist'  = _resultxlambda `if' `in'
								   label variable `varlist' "Linear prediction from the TimeSpecCoefs equation only"
								   sort `panelvarrs' `timevarrs'
								   keep `panelvarrs' `timevarrs' `varlist'
								   save `sampledata',replace
								   capture clear
								   quietly use `maindata', clear
								   merge 1:1 `panelvarrs' `timevarrs' using `sampledata'
								   drop _merge
								   count if `varlist' >= .
								   local nbmissres = r(N)
						  }
						  if `nbmissres' > 0 {
											  display as text "(`nbmissres' missing values generated)"
						  }
						  quietly capture drop _resultxbeta _resultxalpha _resultxlambda _resultxball _resultfcresids 
						  exit
	}



	if "`fcresids'" != "" {
						   syntax newvarname [if] [in] [, fcresids ]
						   quietly {
								    makepredictionfc `lesvariables'  `if' `in'
								    generate `typlist' `varlist'  = _resultfcresids `if' `in'
								    label variable `varlist' "Residuals from all the equations taken together"
								    sort `panelvarrs' `timevarrs'
								    keep `panelvarrs' `timevarrs' `varlist'
								    save `sampledata',replace
								    capture clear
								    quietly use `maindata', clear
								    merge 1:1 `panelvarrs' `timevarrs' using `sampledata'
								    drop _merge
								    count if `varlist' >= .
								    local nbmissres = r(N)
						   }
						   if `nbmissres' > 0 {
											   display as text "(`nbmissres' missing values generated)"	
						   }
						   quietly capture drop _resultxbeta _resultxalpha _resultxlambda _resultxball _resultfcresids 
						   exit
	}



	syntax newvarname [if] [in] [, xball ]
	quietly {
			 makepredictionfc `lesvariables'  `if' `in'
	         generate `typlist' `varlist'  = _resultxball `if' `in'
			 label variable `varlist' "Linear prediction from all the equations taken together"
			 sort `panelvarrs' `timevarrs'
			 keep `panelvarrs' `timevarrs' `varlist'
			 save `sampledata',replace
			 capture clear
			 quietly use `maindata', clear
			 merge 1:1 `panelvarrs' `timevarrs' using `sampledata'
			 drop _merge
			 count if `varlist' >= .
			 local nbmissres = r(N)
	}
	if `nbmissres' > 0 {
						display as text "(`nbmissres' missing values generated)"
	}
	quietly capture drop _resultxbeta _resultxalpha _resultxlambda _resultxball _resultfcresids 
	
	
	
end






program selectionechant, sortpreserve
        syntax varlist(ts) [if] [in], zvarselfc(string)
        marksample touse
        tempvar countsoul
        qui {
             tsset
             local ivar "`r(panelvar)'"
             bysort `touse' `ivar': gen long `countsoul' = _N
             sum `countsoul' if `touse', meanonly
             tempvar  mc
             gen `mc' = .
             replace `mc' = 1 if `countsoul' == r(max) & `touse'
             markout `touse' `mc'
             rename `touse' `zvarselfc'
        }

end





program makepredictionfc, sortpreserve
        syntax varlist(ts) [if] [in]
        marksample touse
        qui count if `touse'
        tempvar counthawka
        quietly {
				 tsset
                 local ivar "`r(panelvar)'"
                 bysort `touse' `ivar': gen long `counthawka' = _N
                 sum `counthawka' if `touse', meanonly
                 tempvar  mc
                 gen `mc' = .
                 replace `mc' = 1 if `counthawka' == r(max) & `touse'
                 markout `touse' `mc'
                 tokenize `varlist'
                 local first `1'
                 macro shift
                 local rest `*'
                 tsset
                 local pvarvh "`r(panelvar)'"
                 local timevarkda  "`r(timevar)'"
				 tempname matzbcoefs
				 matrix define `matzbcoefs' = e(b)
		}
	    mata: _mz_fabricationfc( "`first'", "`rest'", "`pvarvh'", "`timevarkda'", "`touse'", "`matzbcoefs'" )
end






mata:





void _mz_fabricationfc( string scalar first, string scalar rest, string scalar panelvar, string scalar timevar, string scalar touse, string scalar matbin )
{
	real matrix x0, ptyx, info, yxm, ovyx, TX, XTILDE, xonevar, xtwovar, XINFMTX, semixiftwo, semixifone, xthreevar, xonevarcst, xtwovarcst, xthreevarcst
	real colvector y0, pvar, tvar, TY, DepVar, betacst, p1pred1, alphastar, p2pred1, lambdastar, p3pred1, matbcrit2, pallpred, fcresidsall
	real rowvector s, matbcrit
	real scalar NN, NT, TT, k1, k 
	string rowvector lvx 
	string scalar lvy, lvp, lvtm
	
	lvy = tokens(first); lvx = tokens(rest); lvp = tokens(panelvar); lvtm = tokens(timevar);  
	st_view(y0,., lvy, touse); st_view(x0,., st_tsrevar(lvx), touse); st_view(pvar,., lvp, touse); st_view(tvar,., lvtm, touse);
	ptyx = (pvar, tvar, y0, x0)
    info = panelsetup(ptyx, 1, 2, 0); s = panelstats(info);
    NN = s[1]; NT = s[2] ; TT = s[4];
	yxm = ptyx[.,(3..cols(ptyx))]
	k1 = cols(yxm)
    ovyx = J(NT,k1, missingof(yxm))
	for (i=1; i<=NN; i++) {
						   ovyx[|(i-1)*TT+1,1\i*TT,.|] = panelsubmatrix(yxm, i, info)
	}
	TX = ovyx[., (2..cols(ovyx))]
    TY = ovyx[., 1]
	k = cols(TX)
	XTILDE = J(NT,NN*k, 0) 
	for (i=1; i<=NN; i++) {
						   XTILDE[|(i-1)*TT+1, (i-1)*k+1 \ i*TT, i*k|] = panelsubmatrix(TX, i, info)
	}
	xtwovar = XTILDE
	xonevar = TX
	DepVar = TY
	XINFMTX = J(NT,TT*k,0)
	semixiftwo = J(TT,TT*k,0)
	for (i=1; i<=NN; i++) {
						   semixifone = panelsubmatrix(TX, i, info)
						   for (j=1; j<=TT; j++) {
												  semixiftwo[|j,(j-1)*k+1\j,j*k|] = semixifone[j,.]
						   }
						   XINFMTX[|(i-1)*TT+1, 1 \ i*TT, .|] = semixiftwo
    }
	matbcrit      = st_matrix(matbin)
	matbcrit2     = matbcrit'
	xthreevar     = XINFMTX
    xonevarcst    = (xonevar,J(rows(xonevar),1,1))
	betacst       = matbcrit2[|1 \ k+1|]
	p1pred1       = xonevarcst*betacst
	xtwovarcst    = (xtwovar,J(rows(xtwovar),1,1))
	alphastar     = matbcrit2[|k+2 \ NN*k+1+k+1|]
	p2pred1       = xtwovarcst*alphastar
	xthreevarcst  = (xthreevar,J(rows(xthreevar),1,1))
	lambdastar    = matbcrit2[|NN*k+1+k+1+1 \ .|]
	p3pred1       = xthreevarcst*lambdastar
	pallpred      = p1pred1 :+ p2pred1 :+ p3pred1
	fcresidsall   = DepVar :- pallpred
 	st_store(., "_resultxbeta", p1pred1)
	st_store(., "_resultxalpha", p2pred1)
	st_store(., "_resultxlambda", p3pred1)
	st_store(., "_resultxball", pallpred)
	st_store(., "_resultfcresids", fcresidsall)
    
	
	
}








end




