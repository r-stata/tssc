*! version 1.00 25-mar-2020
*! authors Pedro Albarran, Raquel Carrasco & Jesus Carro

capture program drop xtprobitunbal
program xtprobitunbal, eclass byable(onecall) prop(xt)
version 13.0

syntax 	varlist(numeric) [if] [in] [aw fw iw pw],	///
		MEANSvars(varlist numeric)					///
		[											///
			GENsubp(string)						///
			INDep(string)							///
			NITERat(int 50) 						///
			QUATP(int 12) 							///
		]

// -----------  initial checks

	if ("`varlist'" == "") {
        di as err "You must specify a dependent variable and one or more control variables"
	    exit 301
    }

	gettoken depvar controls: varlist

	if ("`controls'" == "") {
        di as err "You must also specify at least one control variable"
	    exit 301
    }

// --------------  xtset section
	tempvar panelvar timevar
	capture xtset
	if "`r(panelvar)'" != "" clonevar `panelvar' = `r(panelvar)'
	else {
	   display as error "Panel variable not set."
	   exit 459
	}
	if "`r(timevar)'" != "" clonevar `timevar' = `r(timevar)'
	else {
		 display as error "Time variable not set."
		 exit 459
	}
	lab var `panelvar' "`panelvar'"
	lab var `timevar'  "`timevar'"

//----- define the subpanels --------
	capture drop _subpanel_xtprobitunbal
	if ("`indep'"=="") {
		genSP `panelvar' `timevar', gen(_subpanel_xtprobitunbal)
	}
	else if ("`indep'"=="indep" | "`indep'"=="ind") {
		genSP `panelvar' `timevar', gen(_subpanel_xtprobitunbal) t0only
	}
	else {
		display as error "This option can only be set to 'indep' or leave it blank for default"
	}

	//-----------------------------------

	xtprobitunbal_est `depvar' `controls' `if' `in', xmean(`meansvars')  					///
								id(`panelvar') tim(`timevar') subp(_subpanel_xtprobitunbal) ///
								ni(`niterat') qp(`quatp') cl(`cluster')

	// devuelve: scalares nobserv, nobs_i, llike, mm, maxSP0 (numero de subpaneles originales)
	//         : variable _touse_xtprobitunbal = 1 si observacion utilizada
	//         : r(subps) nombre de cada subpanel usado
	//         : r(subpsN) numero de cada subpanel usado

	local subps  = r(subps)
	local subpsN = r(subpsN)
	local nobs  = nobserv

 	ereturn post b V, obs(`nobs') depname(`depvar')
	ereturn local         cmd   "xtprobitunbal"

	ereturn local touse_var "_touse_xtprobitunbal"

	if ("`gensubp'") != "" {
		gen `gensubp' = _subpanel_xtprobitunbal
		drop _subpanel_xtprobitunbal
		local subpn_var "`gensubp'"
	} 
	else {
		local subpn_var "_subpanel_xtprobitunbal"
	}
	ereturn local subpn_var "`subpn_var'"

	ereturn local controls  "`controls'"
	ereturn local meansvars "`meansvars'"

	ereturn local subps  "`subps'"
	ereturn local subpsN "`subpsN'"

	ereturn scalar n_i   = nobs_i
	ereturn scalar nsubp = mm
	ereturn scalar llike = llike
	ereturn scalar maxSP0 = maxSP0

	ereturn matrix finalV finalV
	ereturn matrix finalB finalB


   di " " 
   di "Minimun Distance Estimation of common parameters"
   di "for Correlated Random Effects dynamic probit    "
   di " "
   di "Number of observations = "  /*
 			*/	as result %8.0f `nobs' " " _skip(14) /*
   */ "Number of groups  = "  /*
` 			*/	as result %10.0f nobs_i
   di " "
   di "Number of sub-panels   = " /*
 			*/	as result %8.0f mm  _skip(15) /*
   */ "Log likelihood    = "  /*
` 			*/	as result %10.2f llike

   ereturn display

   di " "
   di "Subpanels actually used in estimation: "
   di "  `subpsN'" 
   di " "
   di "(Variable `subpn_var' contains the subpanel index)" 
   scalar drop mm llike nobs_i nobserv maxSP0

end

// ----------------------------------------------------------------------------
capture program drop genSP
program def genSP
	version 13.0
	syntax varlist(min=2 max=2 numeric), GENerate(name) [T0only(string)]
	//-- identify to which subpanel an indiv. belongs to
	//-- by default, a subpanel is defined by the pair (initial period, final period):
	//--     ie. all the individuals with the same initial AND final period belong to the same subpanel
	//-- if T0only is provided, a subpanel is defined by the initial period
	//--     in this case, all the individuals with the same initial period belong to the same subpanel

	tempvar temp1 temp2  

	gettoken ID TIME: varlist

	sort `ID' `TIME'

	egen `temp1'=min(`TIME'), by(`ID') // period of first observation for each individual

	if ("`t0only'"=="") {
		egen `temp2'=max(`TIME'), by(`ID') 		// period of last observation for each individual
		egen `generate'=group(`temp1' `temp2') 	// SP indicates subpanels by  diffent initial and ending periods.
	}
	else {
		egen `generate'=group(`temp1') 			// Subpanels, different ONLY BY initial periods.
	}

end


// ----------------------------------------------------------------------------
capture program drop xtprobitunbal_est
program define xtprobitunbal_est, rclass
	version 13.0
	syntax varlist [if] [in], xmean(varlist) id(varname) tim(varname) subp(varname) ///
					[					///
					ni(int 50) 			///
					qp(int 12) 			///
					cl(varname) 		///
					]

	gettoken y x : varlist

	tempvar y0 LY anno_i

	local totvar= wordcount("`x' `xmean'")
	local nvars = wordcount("`x'")
	local nmeds = wordcount("`xmean'")

	local ncomon=1+`nvars'

	local tot= 1 + `nvars'  + 1  +`nmeds'+ 1     + 1
		// lag + x vars + IC + means + const + varianza error

	//--- Generate initial condition
	sort `id' `tim'
	qby `id': gen `y0'=`y'[1]

	//---- Generate means (first observation not included in mean)
	sort `id' `time'
	qby `id': gen int `anno_i'=_n

	quietly foreach j in `xmean' {
		tempvar mm_`j' 
		egen `mm_`j'' = mean(`j') if `anno_i'!=1, by(`id')
		replace  `mm_`j''=`mm_`j''[_n+1] if `mm_`j''==.
		local xxmean = "`xxmean' `mm_`j''"

		local nam_xxmean = "`nam_xxmean' M`j'"
	}

	quietly xtset `r(panelvar)' `r(timevar)'

scalar nobserv = 0
scalar nobs_i  = 0
scalar llike   =0
scalar mm=0
capture drop _touse_xtprobitunbal
gen _touse_xtprobitunbal = 0

if "`if'"!="" {
	local myif = " `if' &"
}
else {
	local myif = " if "
}

local touse_subp = ""
local touse_subpN = ""

quietly {
	sum `subp'
	local maxSP0=r(max)
	scalar maxSP0=`maxSP0'
	forvalues X=1/`maxSP0' {
		capture xtprobit `y' l.`y' `x' `y0' `xxmean', re iter(`ni') intpoints(`qp'), `myif' `subp'==`X'

		if (e(converged)==1) {
			scalar nobserv = nobserv + e(N)
			scalar nobs_i  = nobs_i  + e(N_g)
			scalar llike   = llike   + e(ll)
			scalar mm      = mm + 1

			local touse_subp  = "`touse_subp' SubPanel_`X'"
			local touse_subpN = "`touse_subpN' `X'"

			replace _touse_xtprobitunbal = _touse_xtprobitunbal + e(sample)

			local regnames = "l.`y' `x' `y'0 `nam_xxmean' _cons lnsig2u"

			tempname BB VV
			mat `BB' = e(b)
			mat colnames `BB' = `regnames'
			mat coleq `BB' ="subp`X'"

			mat `VV' = e(V)
			mat colnames `VV' = `regnames'
			mat rownames `VV' = `regnames'

			if (`X'==1) {
				mat bigB = `BB'
				mat bigV = `VV'
			}

			if (`X'>=2) {
				mat bigB = ( bigB , `BB' )

				scalar nnr=rowsof(bigV)
				scalar nnc=colsof(bigV)
				mat bigV = ( bigV,  J(nnr,`tot',0) \ J(`tot',nnc,0), `VV' )
			}
		}
		else {
			di as error "Warning: subpanel `X' cannot be used in estimation"
		}
	}
}

scalar drop nnr nnc

	local dd=`tot'-`ncomon'          // number of NON-common parameters
	local pos=`tot'*(mm)            // total number of parameters before MD
	local puniq=`ncomon'+`dd'*(mm)  // total number of parameters after MD
 
	matrix bigG=J(`pos',`puniq',0)

	local mm = mm
	mata: genbigG2()

	matrix finalV=invsym(bigG'*invsym(bigV)*bigG)                               // puniq x puniq
	matrix finalB=invsym(bigG'*invsym(bigV)*bigG)*bigG'*invsym(bigV)*bigB'      // puniq x 1

	mata: finales()


local Vnames  = "l.`y' `x'"

local SPnames = "Common"
local ncomon1 = `ncomon'-1
forvalues i=1/`ncomon1' {
	local SPnames = "`SPnames' Common"
}

foreach X of local touse_subp {
	local Vnames  = "`Vnames' `y'0 `nam_xxmean' _cons lnsig2u"

	forvalues j=1/`dd' {
		local SPnames = "`SPnames' `X'"
	}
}

mat rownames finalB = `Vnames'
mat roweq    finalB = `SPnames'

mat rownames finalV = `Vnames'
mat roweq    finalV = `SPnames'

mat colnames finalV = `Vnames'
mat coleq    finalV = `SPnames'

mat drop bigG bigB bigV

return local subps  "`touse_subp'"
return local subpsN "`touse_subpN'"

mat b=finalB[1..`ncomon',1]
mat b=b'
mat V=finalV[1..`ncomon',1..`ncomon']


end


capture mata : mata drop genbigG2()
mata:
    void genbigG2(){
	G = st_matrix("bigG")

    mm = strtoreal(st_local("mm"))

	ncomon = strtoreal(st_local("ncomon"))
	tot  = strtoreal(st_local("tot"))
	dd   = strtoreal(st_local("dd"))
	pos  = strtoreal(st_local("pos"))
	puniq= strtoreal(st_local("puniq"))

	Ic = I(ncomon)
	In = I(dd)

	G1 = (Ic \ J(dd,ncomon,0) )

	G2 = J(pos,puniq-ncomon,0)
	G2[ncomon+1..ncomon+dd,1..dd] = In

	for (X=2; X<=mm; X++) {

		G1 = (G1 \ (Ic \ J(dd,ncomon,0) ) )

		c0 = (X-1)*dd + 1
		c1 = (X-1)*dd + dd

		r0 = ncomon + (X-1)*tot + 1
		r1 = ncomon + (X-1)*tot + dd

		G2[r0..r1, c0..c1]=In

	}

	G = (G1,G2)

	st_replacematrix("bigG",G)
    }
end

capture mata : mata drop finales()
mata:
    void finales(){

    B = st_matrix("finalB")
    V = st_matrix("finalV")

    mm = strtoreal(st_local("mm"))

	ncomon = strtoreal(st_local("ncomon"))
	tot  = strtoreal(st_local("tot"))
	dd   = strtoreal(st_local("dd"))
	pos  = strtoreal(st_local("pos"))
	puniq= strtoreal(st_local("puniq"))

	L = I(puniq)

	for (X=1; X<=mm; X++) {

            pnc1=ncomon+(X-1)*dd+dd

            B[pnc1,1]=exp(B[pnc1,1])

            L[pnc1,pnc1]=B[pnc1,1]
    }

    V = L'*V*L

  	st_replacematrix("finalB",B)
   	st_replacematrix("finalV",V)

    }
end
