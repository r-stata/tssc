*! version 1.1.3  03apr2020  Ben Jann & Simon Seiler

version 11
mata:
mata set matastrict on

void udiff_lf2(transmorphic scalar ML, real scalar todo, real rowvector b, 
    real colvector lnf, real matrix S, real matrix H)
{
    real scalar    i, ii, k, kk, K, j, jj, J, base, N, r, rr, c, cc, done
    real rowvector out
    real colvector Y, Yout, D
    real matrix    Zphi, Xpsi, Wtheta, Q, expQ, P, XpsiYi, sumPXpsi, kj, djk
    
    // constant fluidity model
    if (st_global("UDIFF_mtype")=="0") {
        udiff_lf2_m0(ML, todo, b, lnf, S, H)
        return
    }
    
    // read globals
    K    = strtoreal(st_global("UDIFF_nunidiff"))
    J    = strtoreal(st_global("UDIFF_nout"))
    out  = strtoreal(tokens(st_global("UDIFF_out")))
    base = strtoreal(st_global("UDIFF_ibase"))
    
    // get rid of base outcome
    out = select(out, (1..J):!=base)
    J = J - 1
    
    // get Y and compute equation-level linear predictors
    Y = moptimize_util_depvar(ML, 1); N = rows(Y)
    i = 0
    Zphi = J(N, K, 0)
    for (k=1; k<=K; k++) Zphi[,k] = exp(moptimize_util_xb(ML, b, ++i)) // !!
    Xpsi = J(N, K*J, .); ii = 0; kj = J(K, J, .)
    for (k=1; k<=K; k++) {
        for (j=1; j<=J; j++) {
            Xpsi[,++ii] = moptimize_util_xb(ML, b, ++i)
            kj[k, j] = ii
        }
    }
    Wtheta = J(N, J, 0)
    for (j=1; j<=J; j++) Wtheta[,j] = moptimize_util_xb(ML, b, ++i)
    
    // compute outcome-level linear predictors
    Q = J(N, J, 0)
    for (j=1; j<=J; j++) Q[,j] = Wtheta[,j] + rowsum(Xpsi[, kj[,j]] :* Zphi)
    
    // compute denominator
    expQ = exp(Q)
    D = rowsum(expQ) :+ 1
    
    // generate matrix to select outcomes
    Yout = (Y:==J(N, 1, out))
    
    // fill in likelihood
    lnf = rowsum(Q :* Yout) - ln(D)
    if (todo==0) return
    
    // compute probabilities for all outcomes
    P = expQ :/ D
    
    // sum(P * Xpsi)
    sumPXpsi = J(N, K, 0)
    for (k=1; k<=K; k++) sumPXpsi[,k] = rowsum(P :* Xpsi[, kj[k,]])
    
    // XPsi for observed outcome
    XpsiYi = J(N, K, 0)
    for (k=1; k<=K; k++) XpsiYi[,k] = rowsum(Xpsi[, kj[k,]] :* Yout) 
    
    // derivatives for Phi
    S = J(N, K + K*J + J, .)
    S[|1,1 \ N,K|] = (XpsiYi - sumPXpsi) :* Zphi        // dPhi
    i = K + 1
    for (k=1; k<=K; k++) {                              // dPsi
        S[|1,i \ N,i+J-1|] = (Yout - P) :* Zphi[,k]
        i = i + J
    }
    S[|1,i \ N,.|] = Yout - P                           // dTheta
    if (todo==1) return
    
    // generate d_jk = P*(XPsi - sum(P*Xpsi))*exp(ZPhi)
    djk = J(N, K*J, .)
    for (k=1; k<=K; k++) {
        for (j=1; j<=J; j++) {
            djk[,kj[k,j]] = P[,j] :* (Xpsi[,kj[k,j]] - sumPXpsi[,k]) :* Zphi[,k]
        }
    }
    
    // fill in Hessian
    H = J(length(b), length(b), .)
    r = rr = 1
    for (k=1; k<=K; k++) {
        c = cc = 1
        done = 0
        for (kk=1; kk<=K; kk++) {           // dPhi*dPhi
            if (k==kk)
                done = udiff_lf2_H(ML, r, c, lnf, H, rr, cc,
                (XpsiYi[,k] - rowsum((djk[,kj[k,]] + P):*Xpsi[,kj[k,]]))
                :* Zphi[,k])
            else
                done = udiff_lf2_H(ML, r, c, lnf, H, rr, cc,
                -rowsum(djk[,kj[kk,]]:*Xpsi[,kj[k,]]) :* Zphi[,k])
            if (done) break
        }
    }
    for (k=1; k<=K; k++) {
        for (j=1; j<=J; j++) {
            c = cc = 1
            for (kk=1; kk<=K; kk++) {       // dPsi*dPhi
                if (k==kk)
                    done = udiff_lf2_H(ML, r, c, lnf, H, rr, cc,
                    (Yout[,j] - djk[,kj[k,j]] - P[,j]) :* Zphi[,k])
                else
                    done = udiff_lf2_H(ML, r, c, lnf, H, rr, cc,
                    -djk[,kj[kk,j]] :* Zphi[,k])
            }
            done = 0
            for (kk=1; kk<=K; kk++) {
                for (jj=1; jj<=J; jj++) {   // dPsi*dPsi
                    if (j==jj)
                        done = udiff_lf2_H(ML, r, c, lnf, H, rr, cc,
                        P[,j] :* (P[,j] :- 1) :* Zphi[,k] :* Zphi[,kk])
                    else
                        done = udiff_lf2_H(ML, r, c, lnf, H, rr, cc,
                        P[,j] :* P[,jj] :* Zphi[,k] :* Zphi[,kk])
                    if (done) break
                }
                if (done) break
            }
        }
    }
    for (j=1; j<=J; j++) {
        c = cc = 1
        for (k=1; k<=K; k++) {              // dTheta*dPhi
            done = udiff_lf2_H(ML, r, c, lnf, H, rr, cc, -djk[,kj[k,j]])
        }
        for (k=1; k<=K; k++) {
            for (jj=1; jj<=J; jj++) {       // dTheta*dPsi
                if (j==jj)
                    done = udiff_lf2_H(ML, r, c, lnf, H, rr, cc,
                    P[,j] :* (P[,j] :- 1) :* Zphi[,k])
                else
                    done = udiff_lf2_H(ML, r, c, lnf, H, rr, cc,
                    P[,j] :* P[,jj] :* Zphi[,k])
            }
        }
        done = 0
        for (jj=1; jj<=J; jj++) {           // dTheta*dTheta
            if (j==jj)
                done = udiff_lf2_H(ML, r, c, lnf, H, rr, cc,
                P[,j] :* (P[,j] :- 1))
            else
                done = udiff_lf2_H(ML, r, c, lnf, H, rr, cc, P[,j] :* P[,jj])
            if (done) break
        }
    }
}

real scalar udiff_lf2_H(transmorphic scalar ML, real scalar r, real scalar c,
    real colvector lnf, real matrix H, real scalar rr, real scalar cc, 
    real colvector l2)
{
    real scalar a, b, done
    real matrix h
    
    h = moptimize_util_matsum(ML, r, c, l2, lnf[1])
    a = rows(h)-1; b = cols(h)-1
    H[|rr,cc \ rr+a,cc+b|] = h
    done = (r==c)
    if (done) {
        rr = rr + a + 1
        r++
    }
    else H[|cc,rr \ cc+b,rr+a|] = h'
    cc = cc + b + 1
    c++
    return(done)
}

void udiff_lf2_m0(transmorphic scalar ML, real scalar todo, real rowvector b, 
    real colvector lnf, real matrix S, real matrix H)
{
    real scalar    i, ii, k, kk, K, j, jj, J, base, N, r, rr, c, cc, done
    real rowvector out
    real colvector Y, Yout, D
    real matrix    Xpsi, Wtheta, Q, expQ, P, kj
    
    // read globals
    K    = strtoreal(st_global("UDIFF_nunidiff"))
    J    = strtoreal(st_global("UDIFF_nout"))
    out  = strtoreal(tokens(st_global("UDIFF_out")))
    base = strtoreal(st_global("UDIFF_ibase"))
    
    // get rid of base outcome
    out = select(out, (1..J):!=base)
    J = J - 1
    
    // get Y and compute equation-level linear predictors
    Y = moptimize_util_depvar(ML, 1); N = rows(Y)
    i = 0
    Xpsi = J(N, K*J, .); ii = 0; kj = J(K, J, .)
    for (k=1; k<=K; k++) {
        for (j=1; j<=J; j++) {
            Xpsi[,++ii] = moptimize_util_xb(ML, b, ++i)
            kj[k, j] = ii
        }
    }
    Wtheta = J(N, J, 0)
    for (j=1; j<=J; j++) Wtheta[,j] = moptimize_util_xb(ML, b, ++i)
    
    // compute outcome-level linear predictors
    Q = J(N, J, 0)
    for (j=1; j<=J; j++) Q[,j] = Wtheta[,j] + rowsum(Xpsi[, kj[,j]])
    
    // compute denominator
    expQ = exp(Q)
    D = rowsum(expQ) :+ 1
    
    // generate matrix to select outcomes
    Yout = (Y:==J(N, 1, out))
    
    // fill in likelihood
    lnf = rowsum(Q :* Yout) - ln(D)
    if (todo==0) return
    
    // compute probabilities for all outcomes
    P = expQ :/ D
    
    // derivatives for Phi
    S = J(N, K*J + J, .)
    i = 1
    for (k=1; k<=K; k++) {                  // dPsi
        S[|1,i \ N,i+J-1|] = Yout - P
        i = i + J
    }
    S[|1,i \ N,.|] = Yout - P               // dTheta
    if (todo==1) return
    
    // fill in Hessian
    H = J(length(b), length(b), .)
    r = rr = 1
    for (k=1; k<=K; k++) {
        for (j=1; j<=J; j++) {
            c = cc = 1
            done = 0
            for (kk=1; kk<=K; kk++) {
                for (jj=1; jj<=J; jj++) {   // dPsi*dPsi
                    if (j==jj)
                        done = udiff_lf2_H(ML, r, c, lnf, H, rr, cc,
                        P[,j] :* (P[,j] :- 1))
                    else
                        done = udiff_lf2_H(ML, r, c, lnf, H, rr, cc,
                        P[,j] :* P[,jj])
                    if (done) break
                }
                if (done) break
            }
        }
    }
    for (j=1; j<=J; j++) {
        c = cc = 1
        for (k=1; k<=K; k++) {
            for (jj=1; jj<=J; jj++) {       // dTheta*dPsi
                if (j==jj)
                    done = udiff_lf2_H(ML, r, c, lnf, H, rr, cc,
                    P[,j] :* (P[,j] :- 1))
                else
                    done = udiff_lf2_H(ML, r, c, lnf, H, rr, cc,
                    P[,j] :* P[,jj])
            }
        }
        done = 0
        for (jj=1; jj<=J; jj++) {           // dTheta*dTheta
            if (j==jj)
                done = udiff_lf2_H(ML, r, c, lnf, H, rr, cc,
                P[,j] :* (P[,j] :- 1))
            else
                done = udiff_lf2_H(ML, r, c, lnf, H, rr, cc, P[,j] :* P[,jj])
            if (done) break
        }
    }
}

end
exit
