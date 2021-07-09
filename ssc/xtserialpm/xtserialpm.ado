

*xtserialpml V1.0.1   1-Apr-2019
*Koen Jochmans University of Cambdridge and Vincenzo Verardi, FNRS-UNamur

program define xtserialpm, rclass

    version 10.1

    if replay()& "`e(cmd)'"=="xtserialpm" {
        ereturn  display
        exit
    }

    syntax varlist [if] [in] , [Center]

    tempname touse gid2

    mark `touse' `if' `in'
    markout `touse' `varlist'

    capture tsset

    capture local ivar "`r(panelvar)'"
    if "`ivar'"=="" {
        di as err "must tsset data and specify panelvar"
        exit 459
    }
    capture local tvar "`r(timevar)'"
    if "`tvar'" == "" {
        di as err "must tsset data and specify timevar"
        exit 459
    }

    preserve
    qui keep if `touse'
    tsfill, full
    qui xtdescribe
    if r(min)!=r(max) {
        di "Panel is not balanced"
    }

    local dv: word 1 of `varlist'
    local exp: list varlist -dv
    egen `gid2'=group(`ivar')

    tempvar center0

    if "`center'"=="" {
		gen `center0'=0
    }

    else {
		gen `center0'=1
    }

    mata: test("`varlist'","`gid2'","`touse'","`center0'")
    local q=res_MAT_xxx[1,3]
    local stat=res_MAT_xxx[1,1]
    local p=res_MAT_xxx[1,2]

    di as txt ""
    di as txt "Jochmans portmanteau test for within-group correlation in panel data. "
    di as txt "H0: no within-group correlation"
    di as txt _col(5) "Chi-sq(" %3.0f `q'  ")   =  "     ///
        as res %10.3f `stat'
    di as txt _col(5) "Prob > Chi-sq =  " as res %11.4f `p'

    ret scalar stat = `stat'
    ret scalar df   = `q'
    ret scalar p    = `p'


end

mata

    void test(string scalar varlist, string scalar gid2, string scalar touse, string scalar center0)
    {
        st_view(X0=.,.,tokens(varlist))
        st_view(gid=.,.,tokens(gid2))
        st_view(center=.,.,tokens(center0))

        X0=(X0,J(rows(X0),1,1))


        v=J(1,cols(X0),1)
        v[1,1]=0
        Y=X0[,1]
        dX=select(X0,v)
        Y=rowshape(Y,max(gid))
        K=cols(dX)
        X=asarray_create("real",1)
        for(k=1;k<=K;k++) {
            asarray(X,k,rowshape(dX[,k],max(gid)))
        }

        G=rows(Y)
        N=cols(Y)
        df = N*(N-1)/2-1
        Dy=(Y :!= .)

        Dx=J(rows(Y),cols(Y),1)
        for(k=1;k<=K;k++) {
			Dx=Dx:*(asarray(X,k) :!= .)
        }

        D=Dy:*Dx
        Ng= rowsum(D)
        Ig = (Ng:>1)
        Y=select(Y,Ig)
        D=select(D,Ig)
        Ng=select(Ng,Ig)

        for(k=1;k<=K;k++) {
            Xk=asarray(X,k)
            Xk=select(Xk,Ig)
            Xk=mm_cond(D:==0,-999, Xk)
            asarray(X,k,Xk)
        }

        G=rows(Y)
        N=cols(Y)

        Y=mm_cond(D:==0,-999, Y)
        dY=D:*Y:-(rowsum(D:*Y):/Ng)*J(1,N,1)

        dX=asarray_create("real",1)
        for(k=1;k<=K;k++) {
			Xk=D:*asarray(X,k)-(rowsum(D:*asarray(X,k)):/Ng)*J(1,N,1)
            Xk=mm_cond(D:==0,-999, Xk)
            asarray(dX,k,Xk)
        }

        dY=mm_cond(D:==0,-999, dY)
        XY=J(K,1,0)
        XX=J(K,K,0)

        for(k1=1;k1<=K;k1++) {
            XY[k1, 1] = mean(rowsum(D:*(asarray(dX,k1):*dY)))
            for(k2=1;k2<=K;k2++) {
                XX[k1,k2] = mean(rowsum(D:*(asarray(dX,k1):*asarray(dX,k2))))
            }
        }

        b=invsym(XX)*XY

	E=dY

for(k=1;k<=K;k++) {
E=E-asarray(dX,k)*b[k]
}

e=E
e=mm_cond(D:==0,0,e)
A=J(G,K,0)

for(k=1;k<=K;k++) {
A[,k]=rowsum(D:*(asarray(dX,k):*E))
omega=(invsym(XX)*A')'
}

asyvar = (omega'*omega)/G^2
se = sqrt(diag(asyvar))

E=Y
for(k=1;k<=K;k++) {
E=E-asarray(X,k)*b[k]
}

DE=E[,2..cols(E)]-E[,1..cols(E)-1]
DD =D[,1..cols(D)-1]:*D[,2..cols(D)]


s=J(1,0,0)
for(t=1;t<=N-2;t++) {
s=(s,range(1,t,1)')
}

ss=J(0,1,0)
for(t=2;t<=N-1;t++) {
ss=(ss\t*J(t-1,1,1))
}

ZDE = (((D[,s]:*E[,s]):*(DD[,ss]:*DE[,ss])), (D[ ,3..N]:*E[,3..N]:*(DD[,1..cols(DD)-1]:*DE[,1..cols(DE)-1])))'
ZDX = J(df,K,0)

for(k=1;k<=K;k++) {
DX = asarray(X,k)[,2..cols(asarray(X,k))]-asarray(X,k)[,1..cols(asarray(X,k))-1]
ZDX[,k] = mean((((D[ ,s]:*E[,s]):*(DD[,ss]:*DX[,ss])) , (D[,3..N]:*E[,3..N]:*(DD[,1..cols(DD)-1]:*DX[,1..cols(DD)-1]))))'
}


if (cols(asarray(dX,1))>1) {
vg = ZDE - ZDX*omega'
}

else {
vg=ZDE
}

v=mean(vg')'
V1 = (vg*vg')/G
V2 = ((vg:-v)*(vg:-v)')/G

if (max(center)==1) {
V=V2
}

else {
V=V1
}

st = G*v'*invsym(V)*v
pv = 1-chi2(df,st)
res=(st,pv,df)
st_matrix("res_MAT_xxx",res)
}
end
