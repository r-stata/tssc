*! aaniv 1.0.2 12July2019 austinnichols@gmail.com
* aaniv 1.0.1 10July2019 also had some typos
* aaniv 1.0.0 3July2019 had some typos
prog def aaniv, eclass
version 11.2
if replay() {
  syntax [anything] [, EForm(string) Level(real 95) ]
  eret di, eform(`eform') level(`level')
  }
else {
 syntax [anything(name=0)] [if] [in] [aw fw pw iw/] [, deltase * ]
		ivparse `0'
		local y	`s(lhs)'
		local endo `s(endo)'
		local x `s(inexog)'
		local exexog `s(exexog)'
 cap assert wordcount(`"`y'"')==1
 if _rc!=0 {
  error 198
  }
 cap assert wordcount(`"`endo'"')==1
 if _rc!=0 {
  di as err "current version only supports one endogenous treatment variable"
  error 198
  }
 cap assert wordcount(`"`exexog'"')==1
 if _rc!=0 {
  di as err "current version only supports one excluded exogenous variable (i.e. one instrument)"
  error 198
  }
 cap which ivreg2
 if _rc!=0 {
  cap ssc inst ivreg2
  }
 if "`x'"=="" loc partial "_cons"
 else loc partial `x'
 qui ivreg2 `y' (`endo'=`exexog') `x' [`weight'=`exp'], partial(`partial') noid savesfirst `options'
 tempname iv se b v delta x2 tau beta B V 
 tempvar touse
 g byte `touse'=e(sample)
 scalar `iv'=_b[`endo']
 scalar `se'=_se[`endo']
 qui est rest _ivreg2_sfirst_`y'
 mat `b'=e(b)
 mat `v'=e(V)
 if !("`deltase'"=="") {
   scalar `se'=sqrt(`v'[1,1]/`b'[1,2]^2+`v'[2,2]*`b'[1,1]^2*`b'[1,2]^(-4)-`v'[1,2]*`b'[1,1]*`b'[1,2]^(-3))
   }
 if `b'[1,2]>0 {
  }
 else scalar `delta'=.
 scalar `delta'=`b'[1,1]-`b'[1,2]*`v'[1,2]/`v'[2,2]
 scalar `x2'=-abs(`b'[1,2]/sqrt(`v'[2,2]))
 scalar `tau'=(`v'[2,2]^(-1/2))*normal(`x2')/normalden(`x2')
 if mi(`=normal(`x2')/normalden(`x2')') {
  di as err "inverse Mills ratio out of bounds; substituting unity for estimated Mills ratio"
  scalar `tau'=(`v'[2,2]^(-1/2))
  loc converged=0
  }
 else loc converged=1
 scalar `beta'=(`delta')*(`tau')+`v'[1,2]/`v'[2,2]
 mat `B'=scalar(`beta')
 mat `V'=scalar(`se')^2
 mat rownames `B'=y1
 mat colnames `B'=`endo'
 mat rownames `V'=`endo'
 mat colnames `V'=`endo'
 qui count if `touse'
 loc N = r(N)
 eret post `B' `V', esample(`touse')
 ereturn scalar N = `N'
 ereturn local depvar "`y'"
 ereturn scalar converged=`converged'
 ereturn local version "1.0.0"
 ereturn local cmd "aaniv"
 ereturn local properties "b V"
 eret di, eform(`eform') level(`level')
 }
end

* below adapted from -ivreg2- on SSC (itself adapted from official Stata -ivreg-):
program define ivparse, sclass
	version 11.2
		syntax [anything(name=0)]	
		local n 0
		gettoken lhs 0 : 0, parse(" ,[") match(paren)
		IsStop `lhs'
		while `s(stop)'==0 {
			if "`paren'"=="(" {
				local ++n
				if `n'>1 { 
di as err `"syntax is "(all instrumented variables = instrument variables)""'
					exit 198
				}
				gettoken p lhs : lhs, parse(" =")
				while "`p'"!="=" {
					if "`p'"=="" {
di as err `"syntax is "(all instrumented variables = instrument variables)""'
di as err `"the equal sign "=" is required"'
						exit 198
					}
					local endo `endo' `p'
					gettoken p lhs : lhs, parse(" =")
				}
				local exexog `lhs'
			}
			else {
				local inexog `inexog' `lhs'
			}
			gettoken lhs 0 : 0, parse(" ,[") match(paren)
			IsStop `lhs'
		}
// lhs attached to front of inexog
		gettoken lhs inexog	: inexog
		local endo			: list retokenize endo
		local inexog		: list retokenize inexog
		local exexog		: list retokenize exexog
		sreturn local lhs			`lhs'
		sreturn local endo			`endo'
		sreturn local inexog		`inexog'
		sreturn local exexog 		`exexog'
		sreturn local partial		`partial'

end
program define IsStop, sclass
				/* sic, must do tests one-at-a-time, 
				 * 0, may be very large */
	version 11.2
	if `"`0'"' == "[" {		
		sret local stop 1
		exit
	}
	if `"`0'"' == "," {
		sret local stop 1
		exit
	}
	if `"`0'"' == "if" {
		sret local stop 1
		exit
	}
* per official ivreg 5.1.3
	if substr(`"`0'"',1,3) == "if(" {
		sret local stop 1
		exit
	}
	if `"`0'"' == "in" {
		sret local stop 1
		exit
	}
	if `"`0'"' == "" {
		sret local stop 1
		exit
	}
	else sret local stop 0
end
