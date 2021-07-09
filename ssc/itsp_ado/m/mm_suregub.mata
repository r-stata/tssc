version 10.1
mata: mata clear
mata: mata set matastrict on
mata:
// mm_suregub 1.0.0  CFBaum 11aug2008
void mm_suregub(real scalar neq, 
                string scalar eqlist, 
                string scalar ssigma)
{
        real matrix isigma, tt, eqq, iota, XX, YY, xi, xj, yj, vee
        real vector beta
        real scalar nrow, ncol, i, ii, i2, jj, j, j2
        string scalar lt, touse, le, eqname, eqv
        string vector v, vars, stripe
        pointer (real matrix) rowvector eq
        pointer (real matrix) rowvector xx
        pointer (real matrix) rowvector yy
        
        eq = xx = yy = J(1, neq, NULL)
        isigma = invsym(st_matrix(ssigma))        
        nrow = 0
        ncol = 0
        string rowvector coefname, eqn
        string matrix mstripe
// equation loop 1
        for(i = 1; i <= neq; i++) {
                lt = "touse" + strofreal(i)
                touse = st_local(lt)
                st_view(tt, ., touse)
                le = "eq" + strofreal(i)
                eqv = st_local(le)
                vars = tokens(eqv)
                v = vars[|1, .|]
// pull in full matrix, including missing values
                st_view(eqq, ., v)
                eq[i] = &(tt :* eqq)
// matrix eq[i] is [y|X] for ith eqn
                eqname = v[1]
                stripe = v[2::cols(v)], "_cons"
                coefname = coefname, stripe
                eqn = eqn, J(1, cols(v), eqname)

// form X, assuming constant term
                nrow = nrow + rows(*eq[i])
                iota = J(rows(*eq[i]), 1, 1)

                xx[i] = &((*eq[i])[| 1,2 \ .,. |], iota)
                ncol = ncol + cols(*xx[i])
// form y
                yy[i] = &(*eq[i])[.,1]
        }
        XX = J(ncol, ncol, 0)
        YY = J(ncol, 1, 0)        
        ii = 0
// equation loop 2
        for(i=1; i<=neq; i++) {
                i2 = cols(*xx[i])
                xi = *xx[i]
                jj = 0
                for(j=1; j<=neq; j++) {
                        xj = *xx[j]
                        j2 = cols(*xx[j])
                        yj = *yy[j]
                        XX[| ii+1, jj+1 \ ii+i2, jj+j2 |] = isigma[i, j] :* cross(xi, xj)
                        YY[| ii+1, 1 \ ii+i2, 1 |] = YY[| ii+1, 1 \ ii+i2, 1 |] + ///
                                                     isigma[i, j] :* cross(xi, yj)
                        jj = jj + j2
                }
                ii = ii + i2
        }
// compute SUR beta (X' [Sigma^-1 # I] X)^-1 (X' [Sigma^-1 # I] y) 
        vee = invsym(XX)
        beta = vee * YY
        st_matrix("r(b)", beta')
        mstripe=eqn', coefname'
        st_matrixcolstripe("r(b)", mstripe)
        st_matrix("r(V)", vee)
        st_matrixrowstripe("r(V)", mstripe)
        st_matrixcolstripe("r(V)", mstripe)
}
end

mata: mata mosave mm_suregub(), dir(PERSONAL) replace
