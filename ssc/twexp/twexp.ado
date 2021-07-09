
program define twexp, eclass

    * Gravity Fixed-effects estimators
    * By Vincenzo Verardi FNRS-UNamur and Koen Jochmans, University of Cambridge

    version 13.0

    cap mata: mata drop myVar()
    cap mata: mata drop quadf()
    cap mata: mata drop myVarB()
    cap mata: mata drop QuadratifFunction()
    cap mata: mata set matafavor speed

    if replay()& "`e(cmd)'"=="twexp" {
        ereturn  display
        exit
    }

    syntax varlist [if] [in] , indm(varlist) indn(varlist) model(string) [Nose INITial(string)]

    capt mata mata which mm_which()
    if _rc {
        di as error "-moremata- is required; type -ssc install moremata- to obtain it"
        exit 499
    }

    capt which vlookup

    if _rc {
        di as error "vlookup is required; type -findit vlookup- to obtain it"
        exit 499
    }

	if _rc {
        di as error "swapval is required; type -findit swapval- to obtain it"
        exit 499
    }

    tempvar gid eid touse both indn2 indm2

    mark `touse' `if' `in'
    markout `touse' `varlist'

    local dv: word 1 of `varlist'
    local exp: list varlist -dv
	local nvar: word count `exp'

	egen `indn2'=group(`indn')
	egen `indm2'=group(`indm')

	qui replace `indn'=`indn2'
	qui replace `indm'=`indm2'

	qui levelsof `indn'
	local r1=r(r)

	qui levelsof `indm'
	local r2=r(r)

	if `r2'>`r1' {
		swapval `indn' `indm'
	}

    preserve

	if "`initial'"=="" {
		tempname initial
		matrix init_MM=J(`nvar',1,0)
	}

	else {
		if rowsof(`initial')!=`nvar'&colsof(`initial')!=1 {
			noi di ""
			noi di in r "Dimension of `initial' should be `nvar'x1" 
			exit(148)
		}
		matrix init_MM=`initial'
	}

	qui gen `both'=`indm'==`indn'
	qui sum `both'
	local sl=r(sum)
	*local sl=1
	/*
	   capture drop _fillin
	   fillin `indm' `indn'
	   capture drop _fillin
	   fillin `indn'  `indm'
	*/

    egen `gid'=group(`indn')
    vlookup `indm', generate(`eid') key(`indn') value(`gid')


    qui reg `varlist', noc
	local N=e(N)
    matrix b=e(b)
    matrix V=e(V)

    ereturn post b V , depname(`dv')

    tempvar nose1
    gen `nose1'=1

    if "`nose'"!="" {
        qui replace `nose1'=0
    }


	if `sl'!=0 {
		if "`model'"=="GMM1" {
			mata: reshape("`varlist'","`gid'","`eid'","`nose1'","`touse'")
		}

		else if "`model'"=="GMM2" {
			mata: reshape2("`varlist'","`gid'","`eid'","`nose1'","`touse'")
		}

		else {
			di in r "Model should either be GMM1 or GMM2"
			exit 138
		}
		matrix B=B'

		ereturn repost b=B V=V1
		di in green ""
		di in green "{col 55} Number of obs =" in yellow %8.0f `N'
		ereturn display
	}

	else {
		di in r "Self-links are needed with the twexp command, please use twgravity"
	}
end

mata

    void reshape(string scalar varlist, string scalar gid, string scalar eid, string scalar nose1, string scalar touse)

    {
        st_view(exp=.,.,tokens(varlist),touse)
        st_view(importer=.,.,tokens(gid),touse)
        st_view(exporter=.,.,tokens(eid),touse)
        st_view(nose=.,.,tokens(nose1),touse)
        exp=(exp[,2..cols(exp)],exp[,1])

		n=mm_nunique(importer)
        m=mm_nunique(exporter)


        nvar=cols(exp)
        dX=asarray_create("real",1)
        for (v=1;v<=nvar;v++) {
            X1=J(m,n,0)
            for (i=1;i<=rows(exp);i++) {
                k=exporter[i]
                j=importer[i]

				X1[k,j]=exp[i,v]

            }

			if (v<nvar) {
				X1=X1:-mean(mean(X1)')
			}


            asarray(dX,v,X1)
        }
        Y=asarray(dX,nvar)
        asarray_remove(dX,nvar)

        psi=J(nvar-1,1,0)

        ///x: initial value

        x=st_matrix("init_MM")
        tol=1e-5
        maxit=100
        smalleststep=0.5^20
        it=1
        condition=1
        improvement=1
        k=length(x)
        ///evaluate function
			Z=QuadraticForm(dX,Y,x)

        f=asarray(Z,"criterion")
        g=asarray(Z,"score")
        H=asarray(Z,"Hessian")
        J=asarray(Z,"H")

        while (it<=maxit & condition==1 & improvement==1) {

            s1=rows(H)
            s2=cols(H)
            if (s1==s2&s2>1) {
                d=-luinv(H)*g
            }

            else {
                d=-g:/H
            }


            step=1
            improvement=0
            while (step>=smalleststep & improvement==0) {
                bounded=0

                Z=QuadraticForm(dX,Y,x:+step*d)

                ff=asarray(Z,"criterion")
                gg=asarray(Z,"score")
                HH=asarray(Z,"Hessian")
                JJ=asarray(Z,"H")
				M=asarray(Z,"S")
				if (sqrt(M'*M)==0) {
					stata(`"noi di in r "Convergence not achieved - try alternative starting values"')
					exit(error(498))
				}
                f0=(ff-f)/abs(f)
                bounded=(missing(HH)==0)

                if (f0>=-1e-5&bounded==1) {
                    improvement=1
                    condition=(sqrt(step*step*(d'*d))>tol)
                    condition=condition*((ff-f)>tol)
                    x=x+step*d
                    f=ff
                    g=gg
                    H=HH
                    J=JJ
					M=asarray(Z,"S")
                }

                else {
                    step=step/2
                }
                it=it+1
            }

        }
        it=it-1

		nn=exp(lnfactorial(n) - (lnfactorial(2) + lnfactorial(n-2)))
		mm=exp(lnfactorial(m) - (lnfactorial(2) + lnfactorial(m-2)))
		rho=nn*mm

		if ((sqrt(M'*M):/rho)>1e-1) {
			stata(`"noi di in r "Convergence to a local solution - check starting values""')
		}

		if (sum(nose)>0) {
            V=myVar(dX,Y,x)
            J=luinv(J/rho)
            Upsilon=J*V*J'/(n*m)
        }

        else {
            Upsilon=J(k,k,0)
        }

        if (missing(Upsilon)>0)  {
            Upsilon=J(k,k,0)
            stata(`"noi di in r "Warning: Asymptotic variance could not be calculated""')
        }

        st_matrix("V1",Upsilon)
        st_matrix("B",x)
    }

	void reshape2(string scalar varlist, string scalar gid, string scalar eid, string scalar nose1, string scalar touse)

    {
        st_view(exp=.,.,tokens(varlist),touse)
        st_view(importer=.,.,tokens(gid),touse)
        st_view(exporter=.,.,tokens(eid),touse)
        st_view(nose=.,.,tokens(nose1),touse)
        exp=(exp[,2..cols(exp)],exp[,1])
        n=mm_nunique(importer)
        m=mm_nunique(exporter)

        nvar=cols(exp)
        dX=asarray_create("real",1)
        for (v=1;v<=nvar;v++) {
            X1=J(n,n,0)
            for (i=1;i<=rows(exp);i++) {
                k=exporter[i]
                j=importer[i]

				X1[k,j]=exp[i,v]

            }

			if (v<nvar) {
				X1=X1:-mean(mean(X1)')
			}


            asarray(dX,v,X1)
        }
        Y=asarray(dX,nvar)
        asarray_remove(dX,nvar)

        psi=J(nvar-1,1,0)

        ///x: initial value

        x=st_matrix("init_MM")
        tol=1e-5
        maxit=100
        smalleststep=0.5^20
        it=1
        condition=1
        improvement=1
        k=length(x)

        ///evaluate function
			Z=QuadraticForm2(dX,Y,x)

        f=asarray(Z,"criterion")
        g=asarray(Z,"score")
        H=asarray(Z,"Hessian")
        J=asarray(Z,"H")

        while (it<=maxit & condition==1 & improvement==1) {
            s1=rows(H)
            s2=cols(H)
            if (s1==s2&s2>1) {
                d=-luinv(H)*g
            }

            else {
                d=-g:/H
            }


            step=1
            improvement=0
            while (step>=smalleststep & improvement==0) {
                bounded=0

                Z=QuadraticForm2(dX,Y,x:+step*d)

                ff=asarray(Z,"criterion")
                gg=asarray(Z,"score")
                HH=asarray(Z,"Hessian")
                JJ=asarray(Z,"H")
				M=asarray(Z,"S")

				if (sqrt(M'*M)==0) {
					stata(`"noi di in r "Convergence not achieved - try alternative starting values"')
					exit(error(498))
				}

                f0=(ff-f)/abs(f)
                bounded=(missing(HH)==0)

                if (f0>=-1e-5&bounded==1) {
                    improvement=1
                    condition=(sqrt(step*step*(d'*d))>tol)
                    condition=condition*((ff-f)>tol)
                    x=x+step*d
                    f=ff
                    g=gg
                    H=HH
                    J=JJ
					M=asarray(Z,"S")
                }

                else {
                    step=step/2
                }
                it=it+1
            }

        }

        it=it-1

		nn=exp(lnfactorial(n) - (lnfactorial(2) + lnfactorial(n-2)))
		mm=exp(lnfactorial(m) - (lnfactorial(2) + lnfactorial(m-2)))
		rho=nn*mm

		if ((sqrt(M'*M):/rho)>1e-1) {
			stata(`"noi di in r "Convergence to a local solution - check starting values""')
		}
        if (sum(nose)>0) {
            V=myVar2(dX,Y,x)
            J=luinv(J/rho)
            Upsilon=J*V*J'
            Upsilon=Upsilon/(n*m)
            se = sqrt(diagonal(Upsilon))
        }

        else {
            Upsilon=J(k,k,0)
        }

        if (missing(Upsilon)>0)  {
            Upsilon=J(k,k,0)
            stata(`"noi di in r "Warning: Asymptotic variance could not be calculated""')
        }

        st_matrix("V1",Upsilon)
        st_matrix("B",x)
    }

	function QuadraticForm(dX,Y,psi) {

		n=cols(Y)
		m=rows(Y)
        d=rows(psi)


        index = J(m,n,0)

        for(k=1;k<=d;k++) {
            index=index+asarray(dX,k)*psi[k]
        }

        phi=exp(index)
        error=Y:/phi

        error_i=rowsum(error)
        error_j=colsum(error)
        m_error=colsum(rowsum(error))

        d_error=asarray_create("real",1)
        d_error_i=asarray_create("real",1)
        d_error_j=asarray_create("real",1)
        m_derror=asarray_create("real",1)

        for(k=1;k<=d;k++) {
			d_error_k=error:*asarray(dX,k)
			asarray(d_error,k,d_error_k)

			d_error_i_k=rowsum(d_error_k)
			asarray(d_error_i,k,d_error_i_k)

			d_error_j_k=colsum(d_error_k)
			asarray(d_error_j,k,d_error_j_k)

			m_derror_k=colsum(rowsum(d_error_k))
			asarray(m_derror,k,m_derror_k)
        }

		S=J(d,1,0)

		for(k=1;k<=d;k++) {
			S[k] = colsum(rowsum(error:*asarray(dX,k)))*colsum(rowsum(error)) - colsum(rowsum((error_i*error_j):*asarray(dX,k)))
		}

		c_error = error:*error

		H=J(d,d,0)

		for(k=1;k<=d;k++) {
			for(j=1;j<=d;j++) {
				H[k,j] = colsum(rowsum(asarray(dX,k):*error:*(asarray(dX,j)*m_error:+asarray(m_derror,j)) - asarray(dX,k):*(error_i*asarray(d_error_j,j)+asarray(d_error_i,j)*error_j)))
			}
		}
		H = -H

        criterion = -  S'*S
        score     = -2*H'*S
        Hessian   = -2*H'*H
        res=asarray_create()
        asarray(res,"H",H)
        asarray(res,"criterion",criterion)
        asarray(res,"score",score)
        asarray(res,"Hessian",Hessian)
		asarray(res,"S",S)
        return(res)

    }

	function myVar(dX,Y,psi) {
		n=cols(Y)
		m=rows(Y)
        d=rows(psi)
        index = J(m,n,0)

        for(k=1;k<=d;k++) {
			X_k=asarray(dX,k)
            index=index+X_k*psi[k]
        }


        phi=exp(index)
        error=Y:/phi

		uXu = asarray_create("real",1)
		xu = asarray_create("real",1)
		xu_i= asarray_create("real",1)
		xu_j= asarray_create("real",1)
		xuu_j= asarray_create("real",1)
		xuu_i= asarray_create("real",1)

		u   = rowsum(colsum(error))

		u_i = rowsum(error)
		u_j = colsum(error)


		for(k=1;k<=d;k++) {
		
			xerror_k=error:*asarray(dX,k)

			uXu_k=error*asarray(dX,k)'*error
			
			asarray(uXu,k,uXu_k)

			xu_k=colsum(rowsum(xerror_k))
			asarray(xu,k,xu_k)

			xu_i_k = rowsum(xerror_k)
			asarray(xu_i,k,xu_i_k)

			xu_j_k = colsum(xerror_k)
			asarray(xu_j,k,xu_j_k)

			xuu_j_k = colsum(asarray(dX,k):*(u_i*J(1,n,1)))
			asarray(xuu_j,k,xuu_j_k)

			xuu_i_k = rowsum(asarray(dX,k):*(J(m,1,1)*u_j))
			asarray(xuu_i,k,xuu_i_k)
		}

		xi= asarray_create("real",1)
		for(k=1;k<=d;k++) {
			xi_k = error:*(asarray(dX,k)*u:+asarray(xu,k))-(asarray(dX,k):*(u_i*u_j)+asarray(uXu,k)) + (asarray(xu_i,k)*u_j+u_i*asarray(xu_j,k)) - error:*(asarray(xuu_i,k)*J(1,n,1)+J(m,1,1)*asarray(xuu_j,k))
			xi_k = 4*xi_k/((n-1)*(m-1))
			asarray(xi,k,xi_k)
		}

		mVar=J(d,d,.)
		for(k=1;k<=d;k++) {
			for(j=1;j<=d;j++) {
				mVar[k,j] = mean(mean(asarray(xi,k):*asarray(xi,j))')
			}
		}

		return(mVar)
	}

	function QuadraticForm2(dX,Y,psi) {

        n=cols(Y)
        m=rows(Y)
        d=rows(psi)
        index = J(m,n,0)

        for(k=1;k<=d;k++) {
			X_k=asarray(dX,k)
            index=index+X_k*psi[k]
			asarray(dX,k,X_k)
        }

        phi=exp(index)

		S=J(d,1,0)

		for(k=1;k<=d;k++) {
			S[k]=colsum(rowsum(asarray(dX,k):*(Y:*(phi*Y'*phi)-phi:*(Y*phi'*Y))))
		}

		H = J(d,d,0)
		for(k=1;k<=d;k++) {
			for(j=1;j<=d;j++) {
				H[k,j] =  colsum(rowsum(asarray(dX,k):*Y:*((phi:*asarray(dX,j))*Y'*phi) + asarray(dX,k):*Y:*(phi*Y'*(phi:*asarray(dX,j)))-asarray(dX,k):*phi:*asarray(dX,j):*(Y*phi'*Y)-asarray(dX,k):*phi:*(Y*(phi:*asarray(dX,j))'*Y)))
			}
		}

        criterion = -  S'*S
        score     = -2*H'*S
        Hessian   = -2*H'*H
        res=asarray_create()
        asarray(res,"H",H)
        asarray(res,"criterion",criterion)
        asarray(res,"score",score)
        asarray(res,"Hessian",Hessian)
		asarray(res,"S",S)
        return(res)
    }

	function myVar2(dX,Y,psi) {
		Y=select(Y,rowsum(Y):!=0)
		n=cols(Y)
		m=rows(Y)
		d=rows(psi)

		index = J(m,n,0)

		for(k=1;k<=d;k++) {
			X_k=asarray(dX,k)
			X_k=X_k[1..m,]
            index=index+X_k*psi[k]
			asarray(dX,k,X_k)
        }

		phi=exp(index)

		xi= asarray_create("real",1)

		for(k=1;k<=d;k++) {
			T1 =  asarray(dX,k):*Y:*(phi*Y'*phi)
			T2 = -asarray(dX,k):*phi:*(Y*phi'*Y) 
			T3 = -Y:*((phi:*asarray(dX,k))*Y'*phi)
			T4 =  phi:*((asarray(dX,k):*Y)*phi'*Y)
			T5 = -Y:*(phi*Y'*(phi:*asarray(dX,k)))
			T6 =  phi:*(Y*phi'*(asarray(dX,k):*Y))
			T7 =  Y:*(phi*(asarray(dX,k):*Y)'*phi)
			T8 = -phi:*(Y*(phi:*asarray(dX,k))'*Y)

			T = T1+T2+T3+T4+T5+T6+T7+T8
			xi_k = 4*T/((n-1)*(m-1))
			asarray(xi,k,xi_k)
		}
		mVar=J(d,d,.)
		for(k=1;k<=d;k++) {
			for(j=1;j<=d;j++) {
				mVar[k,j] = mean(mean(asarray(xi,k):*asarray(xi,j))')
			}
		}

		return(mVar)
	}

end
exit

