
*! checkreg3  CFBaum 1.1.1  11oct2007
* 1.0.1: initial release
* 1.1.0: correction to rank condition per DMD, Wooldridge method
* 1.1.1: disallow options such as constraints

program checkreg3, rclass
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
                 *  Pick up full varlist (flist), y-array (y`i'), indendent
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

tempname a g b 
matrix `a' = I(`neq')
forv i=1/`neq' {
	foreach w of local ind`i' {
		local pos: list posof "`w'" in eqlist
		if `pos' {
			mat `a'[`i',`pos'] = -0.5
		}
	}
}
mat rownames `a' = `eqlist'
mat colnames `a' = `eqlist'
// reverse signs to concatenate with g
mat `a' = -`a'
di _n "Endogenous coefficients matrix"
mat list `a', noheader

local exog : list uniq flist
local exog : list exog - eqlist
local nexog : list sizeof exog
matrix `g' = J(`neq',`nexog',0)
forv i=1/`neq' {
	foreach w of local ind`i' {
		local pos: list posof "`w'" in exog
		if `pos' {
			mat `g'[`i',`pos'] = 0.5
		}
	}
}
mat rownames `g' = `eqlist'
mat colnames `g' = `exog'
di _n "Exogenous coefficients matrix"
mat list `g', noheader
di " "
mat `b' = `a',`g'
mata: mm_checkrank("`b'")
end

version 9.2
mata:
void mm_checkrank(string scalar b)
{
	real scalar neq, nc
	B = st_matrix(b)
	neq = rows(B)
	nc = cols(B)
	sysok = 1
	display(" ")
	for(i=1;i<=neq;i++) {
		nul = mm_which(B[i,.]:==0)
		RR = J(cols(nul),nc,0)
		for(j=1;j<=cols(nul);j++) {
			RR[j,nul[j]] = 1
		}
		ridM = rank(RR*B')
		if (ridM == neq-1) {
			display("Eq "+strofreal(i)+" is identified")
		}
		else {
			display("Eq "+strofreal(i)+" fails rank condition for identification")
			sysok = 0
		}
	}
	display(" ")
	if (sysok) display("System is identified")
	else 
		display("Rank deficiency: System is not identified")
}
end

*! mm_which.mata
*! version 1.0.2, Ben Jann, 17apr2007
version 9.2
mata:

real matrix mm_which(real vector I)
{
        if (cols(I)!=1) return(select(1..cols(I), I))
        else return(select(1::rows(I), I))
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









