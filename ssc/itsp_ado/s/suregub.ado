program drop _all
mata: mata clear

*! suregub  CFBaum 1.0.2  26mar2016
* 1.0.0: initial release
* 1.0.1: compute B-P test  
* 1.0.2: check for non-p.d. sigma

program suregub, eclass
	version 9.2

// from reg3.ado 6.4.1	
// not supported v9	             local cmdline : copy local 0
				local cmdline `0'
// disable options (such as constraints)
				if strpos("`0'",",") {
					di as err _n "Options not permitted"
					exit 198
				}
                /*  Parse (y1 x1 x2) (y2 y1 x2 x3) structure.
                 *  Pick up full varlist (flist), y-array (y`i'), independent
                 *  variables (ind`i') left-hand  sides (lhslist), 
                 *  equation names (eqnm`i') 
                */
                local neq = 0
                
                /*  Parse the equations ([eqname:] y1 [y2 y3 =] x1 x2 x3) 
                 *  and fill in the structures required for estimation */

                gettoken fulleq 0 : 0, parse(" ,[") match(paren)
                IsStop `fulleq'
                while `s(stop)' == 0 { 
                        if "`paren'" != "(" {           /* must be eq */
                                eq ?? `fulleq' 
                                local fulleq "`r(eqname)': `r(eq)'"
                        } 
                        parseEqn `fulleq'

                        /* Set-up equation bookeeping structures */
                        local flist `flist' `depvars' `indvars'
                        tokenize `depvars'
                        local i 1
                        while "``i''" != "" {
                                local neq = `neq' + 1
                                local y`neq' ``i''
                                local lhslist `lhslist' ``i''
                                local ind`neq' `indvars'
                                local cons`neq' = ("`constan'" == "")
                                nameEq "`eqname'" "``i''" "`eqlist'" `neq'
                                local eqnm`neq' = "`s(eqname)'"
                                local eqlist `eqlist' `s(eqname)'
                                local i = `i' + 1
                        }

                        gettoken fulleq 0 : 0, parse(" ,[") match(paren)
                        IsStop `fulleq'
                }
                local 0 `"`fulleq' `0'"'

                if `neq' < 1 { 
                        di in red "equation(s) required" 
                        exit 198
                }


// generate residual series
local minn = 999999
local maxn = 0
forv i=1/`neq' {
	local dv : word `i' of `eqlist'
	local eq`i' = "`dv' `ind`i''"
	qui {
		reg `dv' `ind`i''
		tempvar touse`i' es eps`i'
		g byte `es' = e(sample)
		predict double `eps`i'' if `es', resid
		g byte `touse`i'' = cond(e(sample),1,.)
		su `eps`i'', meanonly
		local maxn = max(`maxn',r(N))
		local minn = min(`minn',r(N))
		}
}
	tempname sigma
	loc pwc
	matrix `sigma' = J(`neq',`neq',0)
// generate pairwise correlation matrix of resids; 
// for comparison with sureg, use divisor N
	local neq1 = `neq'-1
	forv i = 1/`neq1' {
		loc pwc "`pwc' `eps`i''"
		forv j = 2/`neq'  {
			qui correlate `eps`i'' `eps`j'', cov
			mat `sigma'[`i',`i'] = r(Var_1)*(r(N)-1)/(r(N))
			mat `sigma'[`j',`j'] = r(Var_2)*(r(N)-1)/(r(N))
			mat `sigma'[`i',`j'] = r(cov_12)*(r(N)-1)/(r(N))
			mat `sigma'[`j',`i'] = `sigma'[`i',`j']
		}
	}
	loc pwc "`pwc' `eps`neq''"

sca d = det(`sigma')
if d <= 0 {
	di as res _n "Matrix of pairwise residual correlations:"
	pwcorr `pwc'
	di as err _n "Matrix not p.d.: det = " d
	error 
}

// mat test = invsym(`sigma')
// mat li test

mata: mm_suregub(`neq',"`eqlist'","`sigma'")
di _n "Seemingly unrelated regressions for an unbalanced panel"
di _n "Min obs per unit = `minn'"
di    "Max obs per unit = `maxn'"
mat b = r(b)
mat V = r(V)
eret clear
// mat list b
// mat list V
eret post b V
eret local cmd "suregub"
eret local minobs `minn'
eret local maxobs `maxn'
eret display

// automatically calc B-P statistic, based on minobs
//       if "`corr'" != "" {
                di
                di in gr "Correlation matrix of residuals:"
                tempname mymat 
//                mat `mymat' = corr(e(Sigma))
                mat `mymat' = corr(`sigma')
                mat list `mymat', nohead format(%9.4f)
                tempname CCp
                mat `CCp' = `mymat' * `mymat''
//               local tsig = (trace(`CCp') - e(k_eq))*e(N) / 2
//               local df = `e(k_eq)' * (`e(k_eq)' - 1) / 2
                local tsig = (trace(`CCp') - `neq')*`minn' / 2
                local df = `neq' * (`neq' - 1) / 2
                di
                di in gr "Breusch-Pagan test of independence: chi2(`df') = " /*
                */ in ye %9.3f `tsig' in gr ", Pr = " %6.4f /*
                */ in ye chiprob(`df',`tsig')

//                est scalar chi2_bp = `tsig'
//                est scalar df_bp   = `df'
                eret scalar chi2_bp = `tsig'
                eret scalar df_bp   = `df'

                /* Double saves */
//                global S_3 `e(df_bp)'
//                global S_4 `e(chi2_bp)'
//        }

end

version 9.2
mata:
void mm_suregub(real scalar neq, string scalar eqlist, string scalar ssigma)
{

	pointer (real matrix) rowvector eq
	pointer (real matrix) rowvector xx
	pointer (real matrix) rowvector yy
	eq = J(1,neq,NULL)
	xx = J(1,neq,NULL)
	yy = J(1,neq,NULL)
	
	isigma = invsym(st_matrix(ssigma))
//	isigma
	
	nrow = 0
	ncol = 0
	string rowvector coefname, eqn
	string matrix mstripe
	for(i=1;i<=neq;i++) {
		lt = "touse"+strofreal(i)
		touse = st_local(lt)
		st_view(tt,.,touse)
		le = "eq"+strofreal(i)
		eqv = st_local(le)
		vars=tokens(eqv)
		v = vars[|1,.|]
// pull in full matrix, including missing values
		st_view(eqq,.,v)
		eq[i] = &(tt :* eqq)
// matrix eq[i] is [y|X] for ith eqn
		eqname=v[1]
		stripe = v[2::cols(v)], "_cons"
		coefname = coefname, stripe
		eqn = eqn, J(1,cols(v),eqname)

// form X, assuming constant term
		nrow = nrow + rows(*eq[i])
		iota = J(rows(*eq[i]),1,1)

		xx[i] = &((*eq[i])[| 1,2 \ .,. |],iota)
		ncol = ncol + cols(*xx[i])
// form y
		yy[i] = &(*eq[i])[.,1]
	}

	XX = J(ncol,ncol,0)
	YY = J(ncol,1,0)	
	ii = 0
	for(i=1;i<=neq;i++) {
		i2 = cols(*xx[i])
		xi = *xx[i]
		jj = 0
		for(j=1;j<=neq;j++) {
			xj = *xx[j]
			j2 = cols(*xx[j])
			yj = *yy[j]
			XX[| ii+1,jj+1 \ ii+i2,jj+j2 |] = isigma[i,j] :* cross(xi,xj)
			YY[| ii+1, 1 \ ii+i2, 1 |] = YY[| ii+1, 1 \ ii+i2, 1 |] + isigma[i,j] :* cross(xi,yj)
			jj = jj + j2
		}
		ii = ii + i2
	}
// compute SUR beta (X' [Sigma^-1 # I] X)^-1 (X' [Sigma^-1 # I] y) 
	vee = invsym(XX)
	beta = vee*YY
	st_matrix("r(b)",beta')
	mstripe=eqn',coefname'
	st_matrixcolstripe("r(b)",mstripe)
	st_matrix("r(V)",vee)
	st_matrixrowstripe("r(V)",mstripe)
	st_matrixcolstripe("r(V)",mstripe)
}
end

program define parseEqn    
		version 6    

        /* see if we have an equation name */
        gettoken token uu : 0, parse(" =:")   /* rare, pull twice if found */
        gettoken token2 : uu, parse(" =:")     /* rare, pull twice if found */
        if index("`token2'", ":") != 0 {
                gettoken token  0 : 0, parse(" =:")      /* sic, to set 0 */
                gettoken token2 0 : 0, parse(" =:")      /* sic, to set 0 */
                c_local eqname  `token'
        } 
        else    c_local eqname 

        /* search just for "=" */
        gettoken token 0 : 0, parse(" =")
        while "`token'" != "=" & "`token'" != "" {
                local depvars `depvars' `token'
                gettoken token 0 : 0, parse(" =")
        }

        if "`token'" == "=" {
                tsunab depvars : `depvars'
                syntax [varlist(ts)] [ , noConstant ]
        } 
        else {                          /* assume single depvar */
                local 0 `depvars'
                syntax varlist(ts) [ , noConstant ]
                gettoken depvars varlist : varlist
        }

        c_local depvars `depvars'
        c_local indvars `varlist'
        c_local constan `constan'
end

program define IsStop, sclass
		version 6
        if           `"`0'"' == "[" /*
                */ | `"`0'"' == "," /*
                */ | `"`0'"' == "if" /*
                */ | `"`0'"' == "in" /*
                */ | `"`0'"' == "" {
                sret local stop 1
        }
        else    sret local stop 0
end


/*  Drop all duplicate tokens from list */

program define DropDup   /* <newlist> : <list> */
		version 6
        args        newlist     /*  name of macro to store new list
                */  colon       /*  ":"
                */  list        /*  list with possible duplicates */

        gettoken token list : list
        while "`token'" != "" {
                local fixlist `fixlist' `token'
                local list : subinstr local list "`token'" "", word all
                gettoken token list : list
        }

        c_local `newlist' `fixlist'
end


/*  Remove all tokens in dirt from full */
 *  Returns "cleaned" full list in cleaned */

program define Subtract   /* <cleaned> : <full> <dirt> */
		version 6
        args        cleaned     /*  macro name to hold cleaned list
                */  colon       /*  ":"
                */  full        /*  list to be cleaned 
                */  dirt        /*  tokens to be cleaned from full */
        
        tokenize `dirt'
        local i 1
        while "``i''" != "" {
                local full : subinstr local full "``i''" "", word all
                local i = `i' + 1
        }

        c_local `cleaned' `full'       /* cleans up extra spaces */
end

/*  Returns tokens found in both lists in the macro named by matches.
 *  Duplicates must be duplicated in both lists to be considered
 *  matches a 2nd, 3rd, ... time.  */

program define Matches   
		version 6
        args        matches     /*  macro name to hold cleaned list
                */  colon       /*  ":"
                */  list1       /*  a list of tokens
                */  list2       /*  a second list of tokens */

        tokenize `list1'
        local i 1
        while "``i''" != "" {
                local list2 : subinstr local list2 "``i''" "", /*
                        */ word count(local count)
                if `count' > 0 {
                        local matlist `matlist' ``i''
                }
                local i = `i' + 1
        }

        c_local `matches' `matlist'
end

/*  Find all occurances in List of tokens in FindList and replace with 
 *  corresponding token from SubsList.  Assumes FindList and SubstList 
 *  have same number of elements.
*/ 

program define Subst, sclass    /*  <NewList> : <List> <FindList> <SubstList> */
		version 6
        args        newname     /*  macro name to hold list after replacements
                */  colon       /*  ":"
                */  list        /*  varlist with tokens to be replaced
                */  fndList     /*  list of tokens to be replaced 
                */  subList     /*  varlist with replacement tokens */

        tokenize `fndList'
        local i 1
        while "``i''" != "" {
                gettoken repltok subList : subList
                local list : subinstr local list "``i''" "`repltok'", word all
                local i = `i' + 1
        }

        c_local `newname' `list'
end

/*  determine equation name */

program define nameEq, sclass
		version 6
        args        eqname      /* user specified equation name
                */  depvar      /* dependent variable name
                */  eqlist      /* list of current equation names 
                */  neq         /* equation number */
        
        if "`eqname'" != "" {
                if index("`eqname'", ".") {
di in red "may not use periods (.) in equation names: `eqname'"
                }
                local eqlist : subinstr local eqlist "`eqname'" "`eqname'", /*
                        */ word count(local count)    /* overkill, but fast */
                if `count' > 0 {
di in red "may not specify duplicate equation names: `eqname'"
                        exit 198
                }
                sreturn local eqname `eqname'
                exit
        }
        
        local depvar : subinstr local depvar "." "_", all

        if length("`depvar'") > 32 {
                local depvar "eq`neq'"
        }
        Matches dupnam : "`eqlist'" "`depvar'"
        if "`dupnam'" != "" {
                sreturn local eqname = substr("`neq'`depvar'", 1, 32)
        }
        else {
                sreturn local eqname `depvar'
        }
end









