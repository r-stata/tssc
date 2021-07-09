*! version 1.1.1 04June2017 Mauricio Caceres Bravo, caceres@nber.org
*! Mata files for alogit.ado

version 13.1

///////////////////////////////////////////////////////////////////////
//                       Main alogit function                        //
///////////////////////////////////////////////////////////////////////

// capture mata: mata drop alogit()
// capture mata: mata drop _alogit_exact()
// capture mata: mata drop _alogit_exact_fast()
// capture mata: mata drop _alogit_exact_loop()
//
// capture mata: mata drop alogit_logisticden()
// capture mata: mata drop alogit_combos()
// capture mata: mata drop _alogit_binadd_reverse()

// dlabels = `dlabels'
// aloglik = &`mata_loglik'()
// predict = &`mata_predict'()

mata

// Main alogit function to perform the optimization
transmorphic function alogit(string rowvector dlabels,
                             pointer(function) aloglik,
                             pointer(function) predict)
{
    transmorphic M

    // Stata options
    string scalar model, method, algorithm, defgood, consider
    real scalar asexp, getc, getdef, reps, pll, fast

    // Data from Stata
    real matrix x, xz, info
    real colvector y, defcons
    real rowvector b

    // Auxiliary variables for optimization
    real colvector phi0, Pc0, nj_i, nc_i
    real matrix C, U0, C0, PC0

    // moptimize options
    real scalar difficult,
                technique,
                iterate,
                tolerance,
                ltolerance,
                nrtolerance

    string scalar exp,
                  nolog,
                  gradient,
                  hessian,
                  showstep,
                  showtolerance,
                  coefdiffs,
                  trace,
                  nonrtolerance,
                  norescale

    // Auxiliary variables for this function
    real scalar loglik, i, nj
    string scalar nstr, jstr
    real rowvector panel

    // Parse options from Stata
    // ------------------------

    exp       = st_local("exp")             // Exponential version
    model     = st_local("model")           // Model (dsc or alogit)
    method    = st_local("method")          // Method (exact, importance)
    algorithm = st_local("algorithm")       // Algorithm (matrix, loop, fast, faster)
    reps      = strtoreal(st_local("reps")) // Repetitions for importance
    defgood   = st_local("default")         // Default good
    consider  = st_local("consider")        // Consider goods

    // whether to compute the likelihood for exp(b)
    asexp = ( exp == "exp" )

    // Whether to process a default good or consideration goods
    // getcons = (consider != "") & (defgood == "")
    getdef = (defgood != "") & (consider == "")

    // Print the likelihood; don't optimize
    pll  = (st_local("loglik") == "loglik")

    // Will only generate C for model(alogit) and alg(matrix)
    getc = ((model == "alogit") & (algorithm == "matrix"))

    // If the computations are done in C, skip (*predict) since that
    // will be called directly from alogit.ado
    fast = ((algorithm == "fast") | (algorithm == "faster"))

    // Initialize optimization programs
    // --------------------------------

    M = moptimize_init()

    // Turn off intercepts (will add constant in .ado files as applicable)
    moptimize_init_eq_cons(M, 1, "off")
    moptimize_init_eq_cons(M, 2, "off")

    // Mark sample to use; grab grouping variable
    moptimize_init_touse(M, st_local("touse"))
    moptimize_init_by(M, st_local("group"))

    // Set up choice sets by grouping variable
    info  = panelsetup(*moptimize_util_by(M), 1)
    panel = panelstats(info)
    if (panel[3] == panel[4]) {
        nstr = strtrim(sprintf("%21.0gc", panel[1]))
        jstr = strtrim(sprintf("%21.0gc", panel[3]))
        printf("Balanced panel. n = " + nstr + ", j = " + jstr + "\n")
    }
    else {
        nstr = strtrim(sprintf("%21.0gc", panel[1]))
        jstr = strtrim(sprintf("%21.0gc", panel[3]))
        jstr = jstr + " to " + strtrim(sprintf("%21.0gc", panel[4]))
        printf("Unbalanced panel. n = " + nstr + ", j = " + jstr + "\n")
    }

    // Set up optimization variables
    // -----------------------------

    if (fast) {
        moptimize_init_userinfo(M, 1, algorithm)
        moptimize_init_userinfo(M, 8, asexp)
    }
    else {
        // Grab the data
        x  = st_data(., st_local("xvars"),  st_local("touse"))
        xz = st_data(., st_local("xzvars"), st_local("touse"))
        // xb  = x  * st_matrix("b0")'
        // xzd = xz * st_matrix("d0")'

        // Default good
        defcons = st_data(., defgood + consider,  st_local("touse"))
        moptimize_init_userinfo(M, 9, defcons)

        if (method == "exact") {
            // Aux for computing choice sets
            nj   = panel[4]
            nj_i = info[, 2] :- info[, 1] :+ 1
            nc_i = getc? (2:^nj_i :- 1): .
            C    = getc? alogit_combos(nj): .

            // Pass user variables to compute the exact likelihood
            moptimize_init_userinfo(M, 1, C)
            moptimize_init_userinfo(M, 2, nc_i)
            moptimize_init_userinfo(M, 3, nj_i)
            moptimize_init_userinfo(M, 4, getdef)
            moptimize_init_userinfo(M, 5, x)
            moptimize_init_userinfo(M, 6, xz)
            moptimize_init_userinfo(M, 7, info)
            moptimize_init_userinfo(M, 8, asexp)
        }
        else if (method == "importance") {
            // Get a random sample of choice sets
            phi0 = invlogit(xz * st_matrix("d0")')
            U0   = runiform(rows(xz), reps)
            C0   = phi0 :> U0
            Pc0  = C0 :* log(phi0) :+ (1 :- C0) :* log(1 :- phi0)

            // Get the probabilities of the choice sets sample
            PC0  = J(rows(info), reps, .)
            for (i = 1; i <= rows(info); i++) {
                PC0[i, ] = exp(colsum(panelsubmatrix(Pc0, i, info)))
            }

            // Pass user variables to compute the importance likelihood
            moptimize_init_userinfo(M, 1, C0)
            moptimize_init_userinfo(M, 2, PC0)
            moptimize_init_userinfo(M, 3, reps)
            moptimize_init_userinfo(M, 4, U0)
            moptimize_init_userinfo(M, 5, x)
            moptimize_init_userinfo(M, 6, xz)
            moptimize_init_userinfo(M, 7, info)
            moptimize_init_userinfo(M, 8, 0)
        }
    }

    // Set up optimization
    // -------------------

    // Set the evaluator to compute the importance likelihood
    moptimize_init_evaluator(M, aloglik)
    moptimize_init_evaluatortype(M, st_local("eval"))

    // Set dependent variable, independent vars
    moptimize_init_depvar(M, 1, st_local("depvar"))
    moptimize_init_eq_indepvars(M, 1, st_local("xvars"))
    moptimize_init_eq_indepvars(M, 2, st_local("xzvars"))

    // Label the things
    moptimize_init_eq_name(M, 1, "PY")
    moptimize_init_eq_name(M, 2, "PA")
    moptimize_init_eq_colnames(M, 2, dlabels)

    // Set up the starting parameters
    moptimize_init_eq_coefs(M, 1, asexp? exp(st_matrix("b0")): st_matrix("b0"))
    moptimize_init_eq_coefs(M, 2, asexp? exp(st_matrix("d0")): st_matrix("d0"))

    // Make the display pretty
    moptimize_init_valueid(M, "log likelihood")

    // Pass user options to moptimize()
    // --------------------------------

    difficult   = st_numscalar("difficult")
    technique   = st_local("technique")
    iterate     = st_numscalar("iterate")
    tolerance   = strtoreal(st_local("tolerance"))
    ltolerance  = strtoreal(st_local("ltolerance"))
    nrtolerance = strtoreal(st_local("nrtolerance"))

    if (difficult)        moptimize_init_singularHmethod(M, "hybrid")
    if (technique != "")  moptimize_init_technique(M, technique)
    if (iterate >= 0)     moptimize_init_conv_maxiter(M, iterate)
    if (tolerance   > 0)  moptimize_init_conv_ptol(M , tolerance)
    if (ltolerance  > 0)  moptimize_init_conv_vtol(M , ltolerance)
    if (nrtolerance > 0)  moptimize_init_conv_nrtol(M, nrtolerance)

    nolog         = (st_local("nolog")         == "")? "on":  "off"
    gradient      = (st_local("gradient")      == "")? "off": "on"
    hessian       = (st_local("hessian")       == "")? "off": "on"
    showstep      = (st_local("showstep")      == "")? "off": "on"
    showtolerance = (st_local("showtolerance") == "")? "off": "on"
    coefdiffs     = (st_local("coefdiffs")     == "")? "off": "on"
    trace         = (st_local("trace")         == "")? "off": "on"
    nonrtolerance = (st_local("nonrtolerance") == "")? "off": "on"
    norescale     = (st_local("norescale")     == "")? "on":  "off"

    moptimize_init_trace_value(M,      nolog)
    moptimize_init_trace_gradient(M,   gradient)
    moptimize_init_trace_Hessian(M,    hessian)
    moptimize_init_trace_step(M,       showstep)
    moptimize_init_trace_tol(M,        showtolerance)
    moptimize_init_trace_coefdiffs(M,  coefdiffs)
    moptimize_init_trace_coefs(M,      trace)
    moptimize_init_conv_ignorenrtol(M, nonrtolerance)
    moptimize_init_search_rescale(M ,  norescale)
    moptimize_init_nmsimplexdeltas(M, 1)

    // Run the routine and put the results in Stata
    // --------------------------------------------

    if (pll) {
        // Print likelihood at default/user-provided parameters
        b = asexp? exp((st_matrix("b0"), st_matrix("d0"))): st_matrix("b0"), st_matrix("d0")
        y = moptimize_init_depvar(M, 1)
        loglik = (*predict)(M, y, x, xz, defcons, method, "ll", b)
        printf("log-likelihood = " + strtrim(sprintf("%21.4f\n", loglik)))
        st_numscalar("ll", loglik)
    }
    else {
        // Run the optimization
        printf("\n")
        moptimize(M)
        if (!fast) {

            // Get average P(empty set)
            y = moptimize_init_depvar(M, 1)
            st_numscalar("mp0", (*predict)(M, y, x, xz, defcons, method, "mp0"))

            // Get average P(attention)
            if (model == "dsc") {
                st_numscalar("mp1", (*predict)(M, y, x, xz, defcons, method, "mp1"))
            }
            else {
                st_numscalar("mp1", .)
            }
        }
        // For fast, these are done in alogit.ado
    }
    return(M)
}

///////////////////////////////////////////////////////////////////////
//                         Exact Likelihood                          //
///////////////////////////////////////////////////////////////////////

// Loglik for exact alogit, matrix version
void function _alogit_exact(transmorphic M,
                            real scalar todo,
                            real rowvector b,
                            fv, g, H)
{

    // Function variables
    real matrix x, xz, info, C, xbmat, xzdmat
    real colvector nj_i, nc_i
    real colvector y, defcons, xb, xzd
    real rowvector bb, gd
    real scalar asexp, kx, kxz, ktot, getdef, nc_0

    // Function helpers
    real matrix xdphi_ij, xphi_ij
    real colvector exb, phi_ij, lphi_c, lphi_nc

    // Loop variables to use for the likelihood
    real scalar i
    real matrix Ci, Ciall, PY
    real colvector y_ij, exb_ij, dc_ij
    real colvector Cisel, lPA
    real rowvector PA, PY_ij

    // Loop variables to use for the gradient
    real colvector dLdP
    real rowvector dLdP_aux, dLdb_k, dLdg_k
    real matrix x_ij, xz_ij, xphi_i
    real matrix dPdb_k_aux, dPdg_k_aux

    // Loop variables to use for the Hessian
    real scalar l, k
    real matrix hb, hg, hbg, haux
    real matrix dPdb_l0, dLdb_kl1, dLdb_kl2, dLdb_kl3, dLdb_kl0, dPdb_kl
    real matrix dPdb_kl_aux, dPdg_lk_aux, dPdbg_lk
    real matrix dPdg_kl0, dLdg_kl

    // Variables to use in the computation
    // -----------------------------------

    C       = moptimize_init_userinfo(M, 1) // Choice sets
    nc_i    = moptimize_init_userinfo(M, 2) // Goods per group
    nj_i    = moptimize_init_userinfo(M, 3) // 2^nc_i - 1
    getdef  = moptimize_init_userinfo(M, 4) // Get default or consider
    x       = moptimize_init_userinfo(M, 5) // utility vars
    xz      = moptimize_init_userinfo(M, 6) // attention vars
    info    = moptimize_init_userinfo(M, 7) // pos of each group in data
    asexp   = moptimize_init_userinfo(M, 8) // Estimate exp(b) isntead of b
    defcons = moptimize_init_userinfo(M, 9) // default good/consider goods
    y       = moptimize_util_depvar(M, 1)   // outcome (choice)
    kx      = cols(x)
    kxz     = cols(xz)
    ktot    = kx + kxz

    if ( asexp ) {
        bb      = b[|1 \ kx|]       // beta
        gd      = b[|kx + 1 \ .|]   // gamma, delta
        xbmat   = (bb :^ x)         // exp(b)^x * b
        xzdmat  = (gd :^ xz)        // exp(g, d)^(x, z)
        xb      = xbmat[, 1]        // prod(exp(b)^x over kx) = exp(xb)
        xzd     = xzdmat[, 1]       // prod(exp(g, d)^(x, z) over kx + kz) = exp(xg + zd)
        for (k = 2; k <= kx; k++)  xb  = xb  :* xbmat[, k]
        for (k = 2; k <= kxz; k++) xzd = xzd :* xzdmat[, k]
    }
    else {
        xb  = moptimize_util_xb(M, b, 1)  // x * b
        xzd = moptimize_util_xb(M, b, 2)  // x * g + z * d
    }

    phi_ij = asexp? (xzd :/ (1 :+ xzd)): invlogit(xzd) // Get phi for P(attention)
    if (!getdef) phi_ij[selectindex(defcons), ] = J(sum(defcons), 1, 1)

    _editvalue(phi_ij, 1, 1 - epsilon(1)) // Numerical precision foo
    _editvalue(phi_ij, 0, epsilon(1))     // Numerical precision foo

    xphi_ij  = phi_ij :* xz       // Helper for the gradient
    exb      = asexp? xb: exp(xb) // Helper for P(Y)
    lphi_c   = log(phi_ij)        // Helpers for P(A) since Mata
    lphi_nc  = log(1 :- phi_ij)   // does not have a prod function.

    // Helper for the Hessian
    xdphi_ij = ( asexp? (xzd :/ (1 :+ xzd):^2): alogit_logisticden(xzd) ) :* xz
    if (!getdef) xdphi_ij[selectindex(defcons), ] = J(sum(defcons), kxz, 0)

    H  = J(ktot, ktot,  0) // Hessian
    g  = J(1, ktot,  0)    // Gradient
    fv = 0                 // Log likelihood

    // Loop over individuals
    // ---------------------

    for (i = 1; i <= rows(info); i++) {
        // Drop individuals with > 1 or 0 goods chosen
        y_ij = panelsubmatrix(y, i, info)
        if(sum(y_ij) != 1) continue
        dc_ij = panelsubmatrix(defcons, i, info)

        // Get choice sets by individual
        nc_0  = getdef? 1: nc_i[i] - 2^(nj_i[i] - sum(dc_ij)) + 2
        Ciall = C[|nc_0, 1 \ nc_i[i] + 1, nj_i[i]|]
        Cisel = selectindex(Ciall[, selectindex(y_ij)])
        Ci    = J(1, nj_i[i], 0) \ Ciall[Cisel, ]

        // Compute the likelihood
        // ----------------------

        // Probability of each choice set. We want to compute P(Y |
        // c, theta) P(c | theta); we compute P(c | theta) / (total
        // for P(Y)) and then sum over all the choice sets
        lPA    = Ci * panelsubmatrix(lphi_c, i, info) +
                 (1 :- Ci) * panelsubmatrix(lphi_nc, i, info)
        PA     = rowshape(exp(lPA), 1)
        exb_ij = panelsubmatrix(exb, i, info)
        PY     = rowshape(exb_ij, 1) :* (Ci :/ (Ci * exb_ij))

        _editmissing(PY, 0)
        if (getdef) PY[1, selectindex(dc_ij)] = 1
        PY_ij = PA * PY

        // Compute the likelihood
        fv = fv + log(PY_ij) * y_ij

        // Compute the gradient and the Hessian
        // ------------------------------------

        if (todo >= 1) {
            dLdP     = y_ij :/ colshape(PY_ij, 1)
            dLdP_aux = PY * dLdP
            x_ij     = panelsubmatrix(x,  i, info)
            xz_ij    = panelsubmatrix(xz, i, info)
            xphi_i   = panelsubmatrix(xphi_ij, i, info)'

            // Compute the gradient
            dPdb_k_aux = (PY * x_ij)'
            dPdg_k_aux = ((Ci * xz_ij) :- rowshape(rowsum(xphi_i), 1))'

            dLdb_k = PY_ij * (x_ij  :* dLdP) - ((dPdb_k_aux :* PA) * dLdP_aux)'
            dLdg_k = ((PA :* dPdg_k_aux) * dLdP_aux)'
            g = g + (dLdb_k, dLdg_k)

            // Compute the Hessian
            if (todo == 2) {
                hb  = dLdb_k' * dLdb_k
                hg  = dLdg_k' * dLdg_k
                hbg = dLdb_k' * dLdg_k

                // For betas
                for (k = 1; k <= kx; k++) {
                    for (l = k; l <= kx; l++) {
                        dPdb_l0  = PY :* x_ij[, l]' - PY :* (PY * x_ij[, l])
                        dLdb_kl1 = dPdb_l0 :* x_ij[, k]'
                        dLdb_kl2 = dPdb_l0 :* colshape(dPdb_k_aux[k, ], 1)
                        dLdb_kl3 = PY :* (dPdb_l0 * x_ij[, k])
                        dLdb_kl0 = dLdb_kl1 -  dLdb_kl2 - dLdb_kl3
                        dPdb_kl  = (PA * dLdb_kl0) * dLdP
                        H[k, l]  = H[k, l] + dPdb_kl - hb[k, l]
                    }

                    // Cross partials
                    dPdb_kl_aux = PY :* x_ij[, k]' - (PY * x_ij[, k]) :* PY
                    for (l = 1; l <= kxz; l++) {
                        dPdg_lk_aux = rowshape((Ci * xz_ij[, l]) :- sum(xphi_i[l, ]), 1) :* PA
                        dPdbg_lk = (dPdg_lk_aux * dPdb_kl_aux) * dLdP
                        H[k, kx + l] = H[k, kx + l] + dPdbg_lk - hbg[k, l]
                    }
                }

                // For gamma, delta
                haux = uppertriangle(panelsubmatrix(xdphi_ij, i, info)' * xz_ij)
                for (k = 1; k <= kxz; k++) {
                    for (l = k; l <= kxz; l++) {
                        dPdg_kl0   = (dPdg_k_aux[l, ] :* dPdg_k_aux[k, ] :- haux[k, l]) :* PA
                        dLdg_kl    = dPdg_kl0 * dLdP_aux - hg[k, l]
                        H[kx + k, kx + l] = H[kx + k, kx + l] + dLdg_kl
                    }
                }
            }
        }
    }
    if ( todo == 2 ) H = makesymmetric(uppertriangle(H)')
    if ( asexp ) {
        if (todo >= 1) g = g :/ b
        if (todo == 2) H = H :/ (b' * b) :- diag(g :/ b)
    }
}

// Compute the likelihood, gradient, and Hessian in C
void function _alogit_exact_fast(transmorphic M,
                                 real scalar todo,
                                 real rowvector b,
                                 fv, g, H)
{
    real scalar ktot
    ktot = st_numscalar("__alogit_ktot")
    H    = J(ktot, ktot,  0);
    g    = J(1, ktot,  0);
    st_numscalar("__alogit_ll", .)
    st_matrix("__alogit_b", b)
    st_numscalar("__alogit_todo", todo)
    if (moptimize_init_userinfo(M, 1) == "fast") {
        stata("plugin call aloglik_fast " + st_local("fastcall") + " alogit")
    }
    else {
        stata("plugin call aloglik_faster " + st_local("fastcall") + " alogit")
    }
    if (todo >= 1) g = st_matrix("__alogit_g")
    if (todo == 2) H = makesymmetric(uppertriangle(st_matrix("__alogit_H"))')
    fv = st_numscalar("__alogit_ll")
    if ( moptimize_init_userinfo(M, 8) ) {
        if (todo >= 1) g = g :/ b
        if (todo == 2) H = H :/ (b' * b) :- diag(g :/ b)
    }
}

// Loglik for exact alogit, loop version
void function _alogit_exact_loop(transmorphic M,
                                 real scalar todo,
                                 real rowvector b,
                                 fv, g, H)
{

    // Function variables
    real matrix x, xz, info, xbmat, xzdmat
    real colvector y, defcons, xb, xzd, nj_i
    real rowvector bb, gd
    real scalar asexp, kx, kxz, ktot, getdef

    // Function helpers
    real matrix xdphi_ij, xphi_ij
    real colvector exb, phi_ij, lphi_c, lphi_nc

    // Loop variables to use for the likelihood
    real scalar i, k, sel
    real scalar PY_ijc, PY_ij, PA
    real colvector y_ij, exb_ij
    real colvector lphi_c_ij, lphi_nc_ij, PY
    real rowvector c

    // Loop variables to use for the gradient
    real matrix x_ij, xz_ij, xphi_i, PYx_ij_mat
    real rowvector x_ij_sel, PYx_ij, cxz_ij, xphi_isum
    real rowvector dPdb_aux, dPdg_aux
    real rowvector dLdb_k, dLdg_k

    // Loop variables to use for the Hessian
    real matrix hb, hg, hbg, haux, xdphi_i
    real rowvector x_ijPY
    real matrix dPdb_kl_1, dPdb_kl_2, dLdb_aux
    real matrix dPdg_l_aux, dLdbg_aux
    real matrix dLdg_aux

    // Variables to use in the computation
    // -----------------------------------

    // Get choice sets, xb, and xg + zd
    nj_i    = moptimize_init_userinfo(M, 3) // Goods per group
    getdef  = moptimize_init_userinfo(M, 4) // Get default or consider
    x       = moptimize_init_userinfo(M, 5) // utility vars
    xz      = moptimize_init_userinfo(M, 6) // attention vars
    info    = moptimize_init_userinfo(M, 7) // pos of each group in data
    asexp   = moptimize_init_userinfo(M, 8) // Estimate exp(b) isntead of b
    defcons = moptimize_init_userinfo(M, 9) // default good/consider goods
    y       = moptimize_util_depvar(M, 1)   // outcome (choice)
    kx      = cols(x)
    kxz     = cols(xz)
    ktot    = kx + kxz

    if ( asexp ) {
        bb      = b[|1 \ kx|]       // beta
        gd      = b[|kx + 1 \ .|]   // gamma, delta
        xbmat   = (bb :^ x)         // exp(b)^x * b
        xzdmat  = (gd :^ xz)        // exp(g, d)^(x, z)
        xb      = xbmat[, 1]        // prod(exp(b)^x over kx) = exp(xb)
        xzd     = xzdmat[, 1]       // prod(exp(g, d)^(x, z) over kx + kz) = exp(xg + zd)
        for (k = 2; k <= kx; k++)  xb  = xb  :* xbmat[, k]
        for (k = 2; k <= kxz; k++) xzd = xzd :* xzdmat[, k]
    }
    else {
        xb  = moptimize_util_xb(M, b, 1)  // x * b
        xzd = moptimize_util_xb(M, b, 2)  // x * g + z * d
    }

    phi_ij = asexp? (xzd :/ (1 :+ xzd)): invlogit(xzd) // Get phi for P(attention)
    if (!getdef) phi_ij[selectindex(defcons), ] = J(sum(defcons), 1, 1)

    _editvalue(phi_ij, 1, 1 - epsilon(1))  // Numerical precision foo
    _editvalue(phi_ij, 0, epsilon(1))      // Numerical precision foo

    xphi_ij  = phi_ij :* xz        // Helper for the gradient
    exb      = asexp? xb: exp(xb)  // Helper for P(Y)
    lphi_c   = log(phi_ij)         // Helper for P(A)
    lphi_nc  = log(1 :- phi_ij)    // Helper for P(A)

    // Helper for the Hessian
    xdphi_ij = ( asexp? (xzd :/ (1 :+ xzd):^2): alogit_logisticden(xzd) ) :* xz
    if (!getdef) xdphi_ij[selectindex(defcons), ] = J(sum(defcons), kxz, 0)

    // Initialize values
    H  = J(ktot, ktot,  0) // Hessian
    g  = J(1, ktot,  0)    // Gradient
    fv = 0                 // Log likelihood

    // Loop over individuals
    // ---------------------

    for (i = 1; i <= rows(info); i++) {

        // Drop individuals with > 1 or 0 goods chosen
        // -------------------------------------------

        y_ij = panelsubmatrix(y, i, info)
        if(sum(y_ij) != 1) continue

        lphi_c_ij  = panelsubmatrix(lphi_c, i, info)
        lphi_nc_ij = panelsubmatrix(lphi_nc, i, info)
        exb_ij     = panelsubmatrix(exb, i, info)
        x_ij       = (todo >= 1)? panelsubmatrix(x,  i, info): .
        xz_ij      = (todo >= 1)? panelsubmatrix(xz, i, info): .
        xphi_i     = (todo >= 1)? panelsubmatrix(xphi_ij, i, info)': .
        xdphi_i    = (todo >= 1)? panelsubmatrix(xdphi_ij, i, info): .

        // Initialize P(Y)
        // ---------------

        sel    = selectindex(y_ij)
        if (getdef) {
            // If you specify a default good, start with the empty set
            c  = J(1, nj_i[i], 0)
            PY = panelsubmatrix(defcons, i, info)
        }
        else {
            // Otherwise, start with the first set that includes the
            // choice and the goods that must be considered.
            c  = panelsubmatrix(defcons, i, info)'
            while (c[sel] == 0) _alogit_binadd_reverse(c)
            PY = c' :* exb_ij :/ (c * exb_ij)
        }
        PA     = exp(c * lphi_c_ij + (1 :- c) * lphi_nc_ij)
        PY_ijc = PA * PY[sel]
        PY_ij  = PY_ijc

        //  Gradient and Hessian
        // ---------------------

        if (todo >= 1) {
            x_ij_sel = x_ij[sel, ]

            // These are defined this way to use in the Hessian
            PYx_ij_mat = PY :* x_ij
            PYx_ij     = colsum(PYx_ij_mat)
            cxz_ij     = c * xz_ij

            // Gradient helpers
            dPdb_aux = PYx_ij * PY_ijc
            dPdg_aux = cxz_ij * PY_ijc

            // Hessian helpers
            xphi_isum = rowshape(rowsum(xphi_i), 1)
            if (todo >= 2) {
                // For beta
                x_ijPY     = x_ij_sel :- PYx_ij
                dPdb_kl_1  = x_ijPY' * x_ijPY
                dPdb_kl_2  = x_ij' * PYx_ij_mat - PYx_ij' * PYx_ij
                dLdb_aux   = (dPdb_kl_1 - dPdb_kl_2) :* PY_ijc

                // Cross partials
                dPdg_l_aux = cxz_ij :- xphi_isum
                dLdbg_aux  = (x_ijPY' * dPdg_l_aux) :* PY_ijc

                // For gamma, delta
                haux       = uppertriangle(xdphi_i' * xz_ij)
                dLdg_aux   = (dPdg_l_aux' * dPdg_l_aux) :* PY_ijc
            }
        }

        // Loop through all consideration sets
        // -----------------------------------

        while (!min(c)) {
             _alogit_binadd_reverse(c)
            if (c[sel] == 0) continue

            // Contribute to P(Y)
            // ------------------

            PY     = c' :* exb_ij :/ (c * exb_ij)
            PA     = exp(c * lphi_c_ij + (1 :- c) * lphi_nc_ij)
            PY_ijc = PA * PY[sel]
            PY_ij  = PY_ij + PY_ijc

            // Gradient and Hessian
            // --------------------

            if (todo >= 1) {

                // Defined this way to use in the Hessian
                PYx_ij_mat = PY :* x_ij
                PYx_ij     = colsum(PYx_ij_mat)
                cxz_ij     = c * xz_ij

                // Gradient helpers
                dPdb_aux = dPdb_aux + PYx_ij * PY_ijc
                dPdg_aux = dPdg_aux + cxz_ij * PY_ijc

                // Hessian
                if (todo == 2) {
                    // For beta
                    x_ijPY     = x_ij_sel :- PYx_ij
                    dPdb_kl_1  = x_ijPY' * x_ijPY
                    dPdb_kl_2  = x_ij' * PYx_ij_mat - PYx_ij' * PYx_ij
                    dLdb_aux   = dLdb_aux + (dPdb_kl_1 - dPdb_kl_2) :* PY_ijc

                    // Cross partials
                    dPdg_l_aux = cxz_ij :- xphi_isum
                    dLdbg_aux  = dLdbg_aux + (x_ijPY' * dPdg_l_aux) :* PY_ijc

                    // For gamma
                    dLdg_aux   = dLdg_aux + (dPdg_l_aux' * dPdg_l_aux) :* PY_ijc
                }
            }
        }

        // Compute the likelihood
        // ----------------------

        fv = fv + log(PY_ij)

        //  Gradient and Hessian
        // ---------------------

        if (todo >= 1) {
            dLdb_k = x_ij_sel :- dPdb_aux :/ PY_ij
            dLdg_k = dPdg_aux :/ PY_ij :- xphi_isum

            g = g + (dLdb_k, dLdg_k)

            // Hessian
            if (todo == 2) {
                hb  = (dLdb_aux  / PY_ij) :- dLdb_k' * dLdb_k
                hbg = (dLdbg_aux / PY_ij) :- dLdb_k' * dLdg_k
                hg  = (dLdg_aux  / PY_ij) :- dLdg_k' * dLdg_k :- haux
                H   = H :+ ((hb, hbg) \ (hbg', hg))
            }
        }

    }
    if (todo == 2) H = makesymmetric(uppertriangle(H)')
    if ( asexp ) {
        if (todo >= 1) g = g :/ b
        if (todo == 2) H = H :/ (b' * b) :- diag(g :/ b)
    }
}

///////////////////////////////////////////////////////////////////////
//                         Helper Functions                          //
///////////////////////////////////////////////////////////////////////

// Logistic density (prior to Stata 14, this was not provided by Mata)
real function alogit_logisticden(real x)
{
    return(invlogit(x) :/ (1 :+ exp(x)))
}

// All the choice sets of nj products in one matrix
real matrix function alogit_combos(real scalar nj)
{
    real scalar nc, i, j
    real matrix C
    string scalar z
    nc = 2^nj
    C  = J(nc, nj, 0)
    for (j = 1; j < nc; j++) {
        z = strreverse(inbase(2, j))
        for (i = 1; i <= strlen(z); i++) {
            C[j + 1, i] = strtoreal(substr(z, i, 1))
        }
    }
    return(C)
}

// Add one to a vector representing a binary number in reverse
// (i.e. first entry is 0s, last is 2^J-1). In testing, using this
// function was faster than using a function that adds one to a vector
// representing a binary number in order.
void function _alogit_binadd_reverse(real rowvector c)
{
    real scalar i
    i = 1
    while (c[i]) {
        c[i] = 0
        i++
    }
    c[i] = 1
}
end
///////////////////////////////////////////////////////////////////////
//                        Alternative Models                         //
///////////////////////////////////////////////////////////////////////

// capture mata: mata drop _alogit_importance()

mata

// Loglik for importance sampler, only one loop
void function _alogit_importance(transmorphic M,
                                 real scalar todo,
                                 real rowvector b,
                                 fv, g, H)
{
    // Function variables
    real matrix x, xz, info, C, PC0
    real colvector y, def, xb, xzd
    real scalar R, kx, kxz, ktot

    // Function helpers
    real matrix xdphi_ij, xphi_ij
    real colvector exb, phi_ij, lphi_c, lphi_nc

    // Loop variables to use for the likelihood
    real scalar i
    string scalar err_noprob
    real matrix Ci, PY
    real colvector y_ij, exb_ij, d_ij
    real colvector lPA
    real rowvector PAPC0, PY_ij, lPY_ij, ll

    // Loop variables to use for the gradient
    real colvector dLdP
    real rowvector dPdb_k, dLdb_k, dPdg_k
    real matrix x_ij, xz_ij, xphi_i
    real matrix dPdb_k_aux, dPdg_k_aux

    // Loop variables to use for the Hessian
    real scalar l, k
    real matrix haux
    real matrix dPdb_l0, dLdb_kl1, dLdb_kl2, dLdb_kl3, dLdb_kl0, dPdb_kl, dLdbg_kl
    real matrix dPdb_kl_aux, dPdg_lk_aux, dPdbg_lk, dPdg_l
    real matrix dPdg_l_aux, dPdg_kl0, dLdg_kl, dPdg_l0

    // Variables to use in the computation
    // -----------------------------------

    // Get choice sets, xb, and xg + zd
    C      = moptimize_init_userinfo(M, 1) // Choice sets
    PC0    = moptimize_init_userinfo(M, 2) // Importance weights
    R      = moptimize_init_userinfo(M, 3) // Repetitions
    x      = moptimize_init_userinfo(M, 5) // utility vars
    xz     = moptimize_init_userinfo(M, 6) // attention vars
    info   = moptimize_init_userinfo(M, 7) // pos of each group in data
    def    = moptimize_init_userinfo(M, 9) // default good
    xb     = moptimize_util_xb(M, b, 1)    // x * b
    xzd    = moptimize_util_xb(M, b, 2)    // x *g + z * d
    y      = moptimize_util_depvar(M, 1)   // outcome (choice)
    kx     = cols(x)
    kxz    = cols(xz)
    ktot   = kx + kxz

    phi_ij   = invlogit(xzd)              // Get phi for P(attention)
    _editvalue(phi_ij, 1, 1 - epsilon(1)) // Numerical precision foo
    _editvalue(phi_ij, 0, epsilon(1))     // Numerical precision foo

    xdphi_ij = alogit_logisticden(xzd) :* xz // Helper for the Hessian
    xphi_ij  = phi_ij :* xz                  // Helper for the gradient
    exb      = exp(xb)                       // Helper for P(Y)
    lphi_c   = log(phi_ij)                   // Helpers for P(A) since Mata
    lphi_nc  = log(1 :- phi_ij)              // does not have a prod function.

    H  = J(ktot, ktot,  0) // Hessian
    g  = J(1, ktot,  0)    // Gradient
    fv = 0                 // Log likelihood

    // Loop over individuals
    // ---------------------

    for (i = 1; i <= rows(info); i++) {
        y_ij = panelsubmatrix(y, i, info)
        if(sum(y_ij) != 1) continue
        d_ij = selectindex(panelsubmatrix(def, i, info))

        // Grab the sampled choice sets
        Ci = panelsubmatrix(C, i, info)'

        // Compute the likelihood
        // ----------------------

        // Probability of each choice set. We want to compute P(Y |
        // c, theta) P(c | theta); we compute P(c | theta) / (total
        // for P(Y)) and then sum over all the choice sets
        lPA    = Ci * panelsubmatrix(lphi_c, i, info) +
                 (1 :- Ci) * panelsubmatrix(lphi_nc, i, info)
        PAPC0  = rowshape(exp(lPA), 1) :/ PC0[i, ]
        exb_ij = panelsubmatrix(exb, i, info)
        PY     = rowshape(exb_ij, 1) :* (Ci :/ (Ci * exb_ij))
        _editmissing(PY, 0)
        _editmissing(PAPC0, 0)
        PY_ij  = PAPC0 * PY

        if (st_local("noprob") == "error") {
            if (sum(!(PY_ij :> 0)) > 0) {
                err_noprob = "The sampler returned probabilities = 0\n" +
                "To fix this, try\n" +
                "- Increasing 'reps'\n" +
                "- Run with -noprob(drop)- to force 0s in the likelihood.\n"
                errprintf(err_noprob)
                exit()
            }
        }

        // Compute the likelihood
        lPY_ij       = PY_ij / R
        lPY_ij[d_ij] = lPY_ij[d_ij]
        ll = log(lPY_ij)
        _editmissing(ll, 0)
        fv = fv + ll * y_ij

        // Figure out if none of the goods were chosen, and the prob of that
        if(sum(y_ij) == 0) {
            fv = fv + sum(panelsubmatrix(lphi_nc, i, info))
        }

        // Compute the gradient and the Hessian
        // ------------------------------------

        if (todo >= 1) {
            dLdP   = y_ij :/ colshape(PY_ij, 1)
            x_ij   = panelsubmatrix(x,  i, info)
            xz_ij  = panelsubmatrix(xz, i, info)
            xphi_i = panelsubmatrix(xphi_ij, i, info)'
            _editmissing(dLdP, 0)

            // For betas
            for (k = 1; k <= kx; k++) {
                dPdb_k_aux = PY * x_ij[, k]
                dPdb_k = PY_ij :* x_ij[, k]' - ((dPdb_k_aux' :* PAPC0) * PY)
                dLdb_k = dPdb_k * dLdP
                g[, k] = g[, k] + dLdb_k

                if (todo == 2) {
                    for (l = k; l <= kx; l++) {
                        dPdb_l0  = PY :* x_ij[, l]' - PY :* (PY * x_ij[, l])
                        dLdb_kl1 = dPdb_l0 :* x_ij[, k]'
                        dLdb_kl2 = dPdb_l0 :* dPdb_k_aux
                        dLdb_kl3 = PY :* (dPdb_l0 * x_ij[, k])
                        dLdb_kl0 = dLdb_kl1 -  dLdb_kl2 - dLdb_kl3
                        dPdb_kl  = ((PAPC0 * dLdb_kl0) * dLdP)
                        dLdbg_kl = (dPdb_k :* (PAPC0 * dPdb_l0)) * (dLdP:^2)
                        H[k, l]  = H[k, l] + dPdb_kl - dLdbg_kl
                    }

                    // Cross partials
                    dPdb_kl_aux = PY :* x_ij[, k]' - (PY * x_ij[, k]) :* PY
                    for (l = 1; l <= kxz; l++) {
                        dPdg_lk_aux = rowshape((Ci * xz_ij[, l]) :- sum(xphi_i[l, ]), 1) :* PAPC0
                        dPdbg_lk = (dPdg_lk_aux * dPdb_kl_aux) * dLdP
                        dPdg_l   =  dPdg_lk_aux * PY
                        H[k, kx + l] = H[k, kx + l] + dPdbg_lk - (dPdb_k :* dPdg_l) * (dLdP:^2)
                    }
                }
            }

            // For gamma, delta
            haux = uppertriangle(panelsubmatrix(xdphi_ij, i, info)' * xz_ij)
            for (k = 1; k <= kxz; k++) {
                dPdg_k_aux = rowshape((Ci * xz_ij[, k]) :- sum(xphi_i[k, ]), 1)
                dPdg_k = (dPdg_k_aux :* PAPC0) * PY
                g[, kx + k] = g[, kx + k] + dPdg_k * dLdP

                if (todo == 2) {
                    for (l = k; l <= kxz; l++) {
                        dPdg_l_aux = rowshape((Ci * xz_ij[, l]) :- sum(xphi_i[l, ]), 1)
                        dPdg_kl0 = (dPdg_l_aux :* dPdg_k_aux :- haux[k, l]) :* PAPC0
                        dPdg_l0  = (dPdg_l_aux :* PAPC0) * PY
                        dLdg_kl  = (dPdg_kl0 * PY) * dLdP - (dPdg_k :* dPdg_l0) * (dLdP:^2)
                        H[kx + k, kx + l] = H[kx + k, kx + l] + dLdg_kl
                    }
                }
            }
            if(sum(y_ij) == 0) {
                g = g - (J(1, kx, 0), rowsum(xphi_i)')
                if (todo == 2) {
                    H[|kx + 1, kx + 1 \ ., .|] = H[|kx + 1, kx + 1 \ ., .|] - haux
                }
            }
        }
    }
    if (todo == 2) H = makesymmetric(uppertriangle(H)')
}
end
///////////////////////////////////////////////////////////////////////
//                     alogit prediction helpers                     //
///////////////////////////////////////////////////////////////////////

// capture mata: mata drop alogit_predict()
// capture mata: mata drop alogit_counterfactual()
// capture mata: mata drop alogit_predict_loop()
// capture mata: mata drop alogit_counterfactual_loop()

mata

// Prediction (various model fits, elasticity, etc.)
real function alogit_predict(transmorphic M,
                             real matrix y,
                             real matrix x,
                             real matrix xz,
                             real matrix defcons,
                             string scalar method,
                             string scalar predict,
                             | real rowvector b)
{

    // Function variables
    real matrix info, C
    real colvector select, nj_i, nc_i
    real colvector xb, xzd
    real scalar kx, getdef, nc_0, ipos, apos, db, dg, R, dydx, nj
    string scalar afit
    real rowvector b0

    // Function helpers
    real colvector exb, phi_ij, lphi_c, lphi_nc, phi0, Pc0
    real matrix PC0

    // Loop variables to use for the likelihood
    real scalar i, p0
    real matrix Ci, PY
    real colvector y_ij, exb_ij, dc_ij, phi_i
    real colvector lPA, dPYPC
    real rowvector PA, PY_ij, PAPC0, ll, dPY_ij, lPY_ij

    // Variables to return
    real scalar mp0, loglik
    real colvector P_ij, PYC_ij, P0_i, dP_ij

    // Variables to use in the computation
    // -----------------------------------

    moptimize_init_touse(M, st_local("touse"))
    moptimize_init_by(M, st_local("group"))

    info   = panelsetup(*moptimize_util_by(M), 1)
    select = selectindex(st_data(., st_local("touse"), st_local("e(sample)")))

    // Parse vector to use
    if (args() == 7) {
        afit = st_local("afit")
        b0   = moptimize_init_eq_coefs(M, 1), moptimize_init_eq_coefs(M, 2)
        b    = (afit == "loglik")? b0: moptimize_result_coefs(M)
    }
    kx = cols(x)
    if ( moptimize_init_userinfo(M, 8) ) b = log(b)

    // For derivatives, elasticities
    dydx = (predict == "dpycdpc") | (predict == "dpyc") | (predict == "dpc")
    if (dydx) {
        ipos = strtoreal(st_local("ipos"))
        apos = strtoreal(st_local("apos"))
        db   = (ipos == 0)? 1 : b[ipos]
        dg   = (apos == 0)? 1 : b[kx + apos]
    }

    // Linear predictions
    xb  = x  * b[|1 \ kx|]'
    if (predict == "u") return(xb)
    xzd = xz * b[|kx + 1 \ .|]'
    if (predict == "a") return(xzd)

    // P(Attention)
    getdef = (st_local("e(default)") != "") & (st_local("e(consider)") == "")
    getdef = getdef | ((st_local("default") != "") & (st_local("consider") == ""))
    phi_ij = invlogit(xzd)
    if (!getdef) phi_ij[selectindex(defcons), ] = J(sum(defcons), 1, 1)
    if (predict == "pa") return(phi_ij)

    // Helpers for loop
    _editvalue(phi_ij, 1, 1 - epsilon(1))
    _editvalue(phi_ij, 0, epsilon(1))
    exb      = exp(xb)
    lphi_c   = log(phi_ij)
    lphi_nc  = log(1 :- phi_ij)

    // Various parsing for different methods
    if (method == "importance") {
        R    = moptimize_init_userinfo(M, 3)
        phi0 = invlogit(xz * moptimize_init_eq_coefs(M, 2)')
        C    = phi0 :> moptimize_init_userinfo(M, 4)[select, ]
        Pc0  = C :* log(phi0) :+ (1 :- C) :* log(1 :- phi0)
        PC0  = J(rows(info), R, .)
        for (i = 1; i <= rows(info); i++) {
            PC0[i, ] = exp(colsum(panelsubmatrix(Pc0, i, info)))
        }
    }
    else {
        nj   = panelstats(info)[4]
        nj_i = info[, 2] :- info[, 1] :+ 1
        nc_i = 2:^nj_i :- 1
        C    = alogit_combos(nj)
    }

    loglik = mp0 = 0
    P_ij   = PYC_ij = P0_i = dP_ij = J(rows(y), 1, .)
    for (i = 1; i <= rows(info); i++) {
        y_ij = panelsubmatrix(y, i, info)
        if(sum(y_ij) != 1) {
            // if (sum(y_ij) > 1) {
            //     errprintf("dropped group with multiple positive outcomes\n")
            // }
            // if (sum(y_ij) == 0) {
            //     errprintf("dropped group with no positive outcomes\n")
            // }
            continue
        }

        exb_ij = panelsubmatrix(exb, i, info)
        PYC_ij[|info[i, ]'|] = exb_ij / sum(exb_ij)
        if (predict == "pyc") continue

        p0  = exp(sum(panelsubmatrix(lphi_nc, i, info)))
        mp0 = mp0 + p0
        if (predict == "mp0") continue
        P0_i[|info[i, ]'|] = J(length(y_ij), 1, p0)
        if (predict == "p0") continue

        dc_ij  = panelsubmatrix(defcons, i, info)
        if (method == "exact") {
            if (getdef) {
                Ci = C[|1, 1 \ nc_i[i] + 1, nj_i[i]|]
            }
            else {
                nc_0 = nc_i[i] - 2^(nj_i[i] - sum(dc_ij)) + 2
                Ci = J(1, nj_i[i], 0) \ C[|nc_0, 1 \ nc_i[i] + 1, nj_i[i]|]
            }
        }
        else if (method == "importance") {
            Ci = panelsubmatrix(C, i, info)'
        }
        lPA    = Ci * panelsubmatrix(lphi_c, i, info) +
                 (1 :- Ci) * panelsubmatrix(lphi_nc, i, info)
        PA     = rowshape(exp(lPA), 1)
        PY     = rowshape(exb_ij, 1) :* (Ci :/ (Ci * exb_ij))
        _editmissing(PY, 0)
        if (getdef & (method == "exact")) PY[1, selectindex(dc_ij)] = 1

        ///////////////
        //  Margins  //
        ///////////////
        if (predict == "dpycdpc") {
            phi_i = rowshape(panelsubmatrix(phi_ij, i, info), 1)
            dPYPC = (1 :- PY) :* db :+ (Ci :- phi_i) :* dg
        }
        else if (predict == "dpyc") {
            dPYPC = (1 :- PY) :* db
        }
        else if (predict == "dpc") {
            phi_i = rowshape(panelsubmatrix(phi_ij, i, info), 1)
            dPYPC = (Ci :- phi_i) :* dg
        }
        else {
            dPYPC = 1
        }
        ///////////////
        //  Margins  //
        ///////////////

        if (method == "exact") {
            PY_ij  = PA * PY
            dPY_ij = PA * (PY :* dPYPC)
            ll     = log(PY_ij)
        }
        else if (method == "importance")  {
            PAPC0  = PA :/ PC0[i, ]
            _editmissing(PAPC0, 0)
            PY_ij  = (PAPC0 * PY) / R
            dPY_ij = (PAPC0 * (PY :* dPYPC)) / R
            ll     = log(PY_ij)
            _editmissing(ll, 0)
        }

        loglik = loglik + ll * y_ij
        P_ij[|info[i, ]'|]  = colshape(PY_ij, 1)
        dP_ij[|info[i, ]'|] = colshape(dPY_ij, 1)
    }
    mp0 = mp0 / (i - 1)

         if (predict == "py")  return(P_ij)
    else if (predict == "pyc") return(PYC_ij)
    else if (predict == "ll")  return(loglik)
    else if (predict == "p0")  return(P0_i)
    else if (predict == "mp0") return(mp0)
    else if (dydx)             return(dP_ij)
}

// Counterfactual (user-provider likelihood and/or P(A))
real function alogit_counterfactual(real colvector u,
                                    real colvector phi,
                                    real colvector defcons,
                                    real matrix info)
{
    real scalar i, nj, getdef, nc_0 
    real matrix C, Ci, PY
    real colvector P_ij, select, nj_i, nc_i
    real colvector exb, lphi_c, lphi_nc
    real colvector u_ij, y_ij, exb_ij, dc_ij, lPA
    real rowvector PA, PY_ij

    getdef  = (st_local("e(default)") != "") & (st_local("e(consider)") == "")
    getdef  = getdef | ((st_local("default") != "") & (st_local("consider") == ""))
    if (!getdef) phi[selectindex(defcons), ] = J(sum(defcons), 1, 1)
    _editvalue(phi, 1, 1 - epsilon(1))
    _editvalue(phi, 0, epsilon(1))

    select  = selectindex(st_data(., st_local("touse")))
    nj      = panelstats(info)[4]
    nj_i    = info[, 2] :- info[, 1] :+ 1
    nc_i    = 2:^nj_i :- 1
    C       = alogit_combos(nj)
    exb     = exp(u)
    lphi_c  = log(phi)
    lphi_nc = log(1 :- phi)
    P_ij    = J(rows(u), 1, .)

    for (i = 1; i <= rows(info); i++) {
        if(!anyof(select, info[i, 1]) & !anyof(select, info[i, 2])) continue
        u_ij  = panelsubmatrix(u, i, info)
        y_ij  = max(u_ij) :== u_ij
        dc_ij = panelsubmatrix(defcons, i, info)
        if (getdef) {
            Ci = C[|1, 1 \ nc_i[i] + 1, nj_i[i]|]
        }
        else {
            nc_0 = nc_i[i] - 2^(nj_i[i] - sum(dc_ij)) + 2
            Ci = C[|nc_0, 1 \ nc_i[i] + 1, nj_i[i]|]
        }

        if(sum(y_ij) != 1) {
            // if(sum(y_ij) > 1) {
            //     errprintf("dropped group with multiple positive outcomes\n")
            // }
            // else if(sum(y_ij) == 0) {
            //     errprintf("dropped group with no positive outcomes\n")
            // }
            continue
        }

        lPA    = Ci * panelsubmatrix(lphi_c, i, info) +
                 (1 :- Ci) * panelsubmatrix(lphi_nc, i, info)
        PA     = rowshape(exp(lPA), 1)
        exb_ij = panelsubmatrix(exb, i, info)
        PY     = rowshape(exb_ij, 1) :* (Ci :/ (Ci * exb_ij))
        _editmissing(PY, 0)
        if (getdef) PY[1, selectindex(dc_ij)] = 1
        PY_ij  = PA * PY
        P_ij[|info[i, ]'|] = colshape(PY_ij, 1)
    }
    return(P_ij)
}

// Predict using loop algorithm
real function alogit_predict_loop(transmorphic M,
                                  real matrix y,
                                  real matrix x,
                                  real matrix xz,
                                  real matrix defcons,
                                  string scalar method,
                                  string scalar predict,
                                  | real rowvector b)
{
    // Function variables
    real matrix info
    real colvector nj_i, xb, xzd
    real scalar kx, getdef, ipos, apos, db, dg, dydx
    string scalar afit
    real rowvector b0

    // Function helpers
    real colvector exb, phi_ij, lphi_c, lphi_nc

    // Loop variables to use for the likelihood
    real scalar i, sel, PA, p0
    real colvector y_ij, exb_ij, phi_i, lphi_c_ij, lphi_nc_ij
    real colvector dPYPC, PY, PY_ijc, PY_ij
    real rowvector c, dPY_ij

    // Variables to return
    real scalar mp0, loglik
    real colvector P_ij, PYC_ij, P0_i, dP_ij

    if (method != "exact") {
        errprintf("-algorithm(loop)- only available for -method(exact)-")
        exit()
    }

    // Variables to use in the computation
    // -----------------------------------

    // Re-initialize info, group if user changed them
    moptimize_init_touse(M, st_local("touse"))
    moptimize_init_by(M, st_local("group"))

    info = panelsetup(*moptimize_util_by(M), 1)
    nj_i = info[, 2] :- info[, 1] :+ 1

    // Use user coefficients if passed
    if (args() == 7) {
        afit = st_local("afit")
        b0   = moptimize_init_eq_coefs(M, 1), moptimize_init_eq_coefs(M, 2)
        b    = (afit == "loglik")? b0: moptimize_result_coefs(M)
    }
    kx  = cols(x)
    if ( moptimize_init_userinfo(M, 8) ) b = log(b)

    // Helper for derivatives/elasticities
    dydx = (predict == "dpycdpc") | (predict == "dpyc") | (predict == "dpc")
    if (dydx) {
        ipos = strtoreal(st_local("ipos"))
        apos = strtoreal(st_local("apos"))
        db   = (ipos == 0)? 1 : b[ipos]
        dg   = (apos == 0)? 1 : b[kx + apos]
    }

    // New fit!
    xb  = x  * b[|1 \ kx|]'
    if (predict == "u") return(xb)
    xzd = xz * b[|kx + 1 \ .|]'
    if (predict == "a") return(xzd)
    phi_ij = invlogit(xzd)
    getdef = (st_local("e(default)") != "") & (st_local("e(consider)") == "")
    getdef = getdef | ((st_local("default") != "") & (st_local("consider") == ""))
    if (!getdef) phi_ij[selectindex(defcons), ] = J(sum(defcons), 1, 1)
    if (predict == "pa") return(phi_ij)

    // For the likelihood, P(A), P(Y)
    _editvalue(phi_ij, 1, 1 - epsilon(1))  // Numerical precision foo
    _editvalue(phi_ij, 0, epsilon(1))      // Numerical precision foo
    exb      = exp(xb)                     // Helper for P(Y)
    lphi_c   = log(phi_ij)                 // Helper for P(A)
    lphi_nc  = log(1 :- phi_ij)            // Helper for P(A)

    // Loop through individuals
    loglik = mp0 = 0
    P_ij   = PYC_ij = P0_i = dP_ij = J(rows(y), 1, .)
    for (i = 1; i <= rows(info); i++) {

        y_ij = panelsubmatrix(y, i, info)
        if(sum(y_ij) != 1) {
            // if(sum(y_ij) > 1) {
            //     errprintf("dropped group with multiple positive outcomes\n")
            // }
            // else if(sum(y_ij) == 0) {
            //     errprintf("dropped group with no positive outcomes\n")
            // }
            continue
        }

        exb_ij = panelsubmatrix(exb, i, info)
        PYC_ij[|info[i, ]'|] = exb_ij / sum(exb_ij)
        if (predict == "pyc") continue

        lphi_c_ij  = panelsubmatrix(lphi_c, i, info)
        lphi_nc_ij = panelsubmatrix(lphi_nc, i, info)

        p0  = exp(sum(lphi_nc_ij))
        mp0 = mp0 + p0
        if (predict == "mp0") continue
        P0_i[|info[i, ]'|] = J(length(y_ij), 1, p0)
        if (predict == "p0") continue

        // Initialize P(Y)
        // ---------------

        sel    = selectindex(y_ij)
        if (getdef) {
            // If you specify a default good, start with the empty set
            c  = J(1, nj_i[i], 0)
            PY = panelsubmatrix(defcons, i, info)
        }
        else {
            // Otherwise, start with the first set that includes the
            // the goods that must be considered.
            c  = panelsubmatrix(defcons, i, info)'
            PY = c' :* exb_ij :/ (c * exb_ij)
        }
        PA     = exp(c * lphi_c_ij + (1 :- c) * lphi_nc_ij)
        PY_ijc = PA :* PY
        PY_ij  = PA * PY[sel]

        ///////////////
        //  Margins  //
        ///////////////
        if (predict == "dpycdpc") {
            phi_i = panelsubmatrix(phi_ij, i, info)
            dPYPC = (1 :- PY) :* db :+ (c' :- phi_i) :* dg
        }
        else if (predict == "dpyc") {
            dPYPC = (1 :- PY) :* db
        }
        else if (predict == "dpc") {
            phi_i = panelsubmatrix(phi_ij, i, info)
            dPYPC = (c' :- phi_i) :* dg
        }
        else {
            dPYPC = 1
        }
        dPY_ij = PA :* PY :* dPYPC
        ///////////////
        //  Margins  //
        ///////////////

        while (!min(c)) {
             _alogit_binadd_reverse(c)
            PA     = exp(c * lphi_c_ij + (1 :- c) * lphi_nc_ij)
            PY     = c' :* exb_ij :/ (c * exb_ij)
            PY_ijc = PY_ijc :+ PA :* PY
            PY_ij  = PY_ij + PA * PY[sel]
            ///////////////
            //  Margins  //
            ///////////////
            if (predict == "dpycdpc") {
                phi_i = panelsubmatrix(phi_ij, i, info)
                dPYPC = (1 :- PY) :* db :+ (c' :- phi_i) :* dg
            }
            else if (predict == "dpyc") {
                dPYPC = (1 :- PY) :* db
            }
            else if (predict == "dpc") {
                phi_i = panelsubmatrix(phi_ij, i, info)
                dPYPC = (c' :- phi_i) :* dg
            }
            else {
                dPYPC = 1
            }
            dPY_ij = dPY_ij :+ PA :* (PY :* dPYPC)
            ///////////////
            //  Margins  //
            ///////////////
        }

        loglik = loglik + log(PY_ij)
        P_ij[|info[i, ]'|]  = PY_ijc
        dP_ij[|info[i, ]'|] = dPY_ij
    }
    mp0 = mp0 / (i - 1)

         if (predict == "py")  return(P_ij)
    else if (predict == "pyc") return(PYC_ij)
    else if (predict == "ll")  return(loglik)
    else if (predict == "p0")  return(P0_i)
    else if (predict == "mp0") return(mp0)
    else if (dydx)             return(dP_ij)
}



// Counterfactual using loop algorithm
real colvector function alogit_counterfactual_loop(real colvector u,
                                                   real colvector phi,
                                                   real colvector defcons,
                                                   real matrix info)
{
    real scalar i, getdef, sel, PA
    real colvector P_ij, select, nj_i, PY, PY_ijc
    real colvector exb, lphi_c, lphi_nc, lphi_c_ij, lphi_nc_ij
    real colvector u_ij, y_ij, exb_ij
    real rowvector c

    getdef  = (st_local("e(default)") != "") & (st_local("e(consider)") == "")
    getdef  = getdef | ((st_local("default") != "") & (st_local("consider") == ""))
    if (!getdef) phi[selectindex(defcons), ] = J(sum(defcons), 1, 1)
    _editvalue(phi, 1, 1 - epsilon(1))
    _editvalue(phi, 0, epsilon(1))

    select  = selectindex(st_data(., st_local("touse")))
    nj_i    = info[, 2] :- info[, 1] :+ 1
    exb     = exp(u)
    lphi_c  = log(phi)
    lphi_nc = log(1 :- phi)
    P_ij    = J(rows(u), 1, .)

    for (i = 1; i <= rows(info); i++) {
        if(!anyof(select, info[i, 1]) & !anyof(select, info[i, 2])) continue
        u_ij = panelsubmatrix(u, i, info)
        y_ij = max(u_ij) :== u_ij

        if(sum(y_ij) != 1) {
            // if(sum(y_ij) > 1) {
            //     errprintf("dropped group with multiple positive outcomes\n")
            // }
            // else if(sum(y_ij) == 0) {
            //     errprintf("dropped group with no positive outcomes\n")
            // }
            continue
        }

        lphi_c_ij  = panelsubmatrix(lphi_c, i, info)
        lphi_nc_ij = panelsubmatrix(lphi_nc, i, info)
        exb_ij     = panelsubmatrix(exb, i, info)

        // Initialize P(Y)
        // ---------------

        sel    = selectindex(y_ij)
        if (getdef) {
            // If you specify a default good, start with the empty set
            c  = J(1, nj_i[i], 0)
            PY = panelsubmatrix(defcons, i, info)
        }
        else {
            // Otherwise, start with the first set that includes the
            // goods that must be considered.
            c  = panelsubmatrix(defcons, i, info)'
            PY = c' :* exb_ij :/ (c * exb_ij)
        }
        PA     = exp(c * lphi_c_ij + (1 :- c) * lphi_nc_ij)
        PY_ijc = PA :* PY

        // Loop through all consideration sets
        // -----------------------------------

        while (!min(c)) {
             _alogit_binadd_reverse(c)
            PA     = exp(c * lphi_c_ij + (1 :- c) * lphi_nc_ij)
            PY     = c' :* exb_ij :/ (c * exb_ij)
            PY_ijc = PY_ijc :+ PA :* PY
        }

        P_ij[|info[i, ]'|] = PY_ijc
    }
    return(P_ij)
}
end
///////////////////////////////////////////////////////////////////////
//                           DSC functions                           //
///////////////////////////////////////////////////////////////////////

// capture mata: mata drop _alogit_dsc_exact()
// capture mata: mata drop _alogit_dsc_exact_fast()
// capture mata: mata drop alogit_dsc_predict()
// capture mata: mata drop alogit_dsc_counterfactual()

mata

// Loglik for DSC model, only one loop
void function _alogit_dsc_exact(transmorphic M,
                                real scalar todo,
                                real rowvector b,
                                fv, g, H)
{
    // Function variables
    real matrix x, xz, info, xbmat, xzdmat
    real colvector y, def, xb, xzd, d_sel
    real rowvector bb, gd
    real scalar asexp, kx, kxz, ktot

    // Function helpers
    real matrix xdphi_ij
    real colvector exb, pa_ij, pi_ij

    // Loop variables to use for the likelihood
    real scalar i, k, sel, PA
    real colvector y_ij, exb_ij, d_ij, PY, PY_ij, P_ij

    // Loop variables to use for the gradient
    real scalar index, dLdP
    real rowvector dLdb_k, dLdg_k, dLdb_k_aux
    real matrix x_ij, xz_ij, xdphi_i

    // Loop variables to use for the Hessian
    real rowvector PYx_ij
    real matrix hb, hg, hbg
    real matrix dPdb_kl1_1, dPdb_kl2_1, dPdb_kl2_2, dPdb_kl
    real matrix dPdbg_kl
    real matrix dPdgd_aux, dPdgd_kl

    // Variables to use in the computation
    // -----------------------------------

    // Get choice sets, xb, and xg + zd
    x     = moptimize_init_userinfo(M, 5) // utility vars
    xz    = moptimize_init_userinfo(M, 6) // attention vars
    info  = moptimize_init_userinfo(M, 7) // pos of each group in data
    asexp = moptimize_init_userinfo(M, 8) // Estimate exp(b) isntead of b
    def   = moptimize_init_userinfo(M, 9) // default good
    y     = moptimize_util_depvar(M, 1)   // outcome (choice)
    kx    = cols(x)
    kxz   = cols(xz)
    ktot  = kx + kxz

    if ( asexp ) {
        bb      = b[|1 \ kx|]      // beta
        gd      = b[|kx + 1 \ .|]  // gamma, delta
        xbmat   = (bb :^ x)        // exp(b)^x * b
        xzdmat  = (gd :^ xz)       // exp(g, d)^(x, z)
        xb      = xbmat[, 1]       // prod(exp(b)^x over kx) = exp(xb)
        xzd     = xzdmat[, 1]      // prod(exp(g, d)^(x, z) over kx + kz) = exp(xg + zd)
        for (k = 2; k <= kx; k++)  xb  = xb  :* xbmat[, k]
        for (k = 2; k <= kxz; k++) xzd = xzd :* xzdmat[, k]
    }
    else {
        xb  = moptimize_util_xb(M, b, 1) // x * b
        xzd = moptimize_util_xb(M, b, 2) // x * g + z * d
    }

    d_sel = selectindex(def)  // Index of default goods
    xzd   = xzd[d_sel]        // P(A) only depends on default good

    // Get phi for P(attention)
    pa_ij = asexp? (xzd :/ (1 :+ xzd)): invlogit(xzd)

    _editvalue(pa_ij, 1, 1 - epsilon(1)) // Numerical precision foo
    _editvalue(pa_ij, 0, epsilon(1))     // Numerical precision foo

    pi_ij = 1 :- pa_ij         // Get phi for P(inattention)
    exb   = asexp? xb: exp(xb) // Helper for P(Y)

    // Helpers for the Hessian, gradient
    xdphi_ij = ( asexp? (xzd :/ (1 :+ xzd):^2): alogit_logisticden(xzd) ) :* xz[d_sel, ]

    H  = J(ktot, ktot,  0)  // Hessian
    g  = J(1, ktot,  0)     // Gradient
    fv = 0                  // Log likelihood

    // Loop over individuals
    // ---------------------

    for (i = 1; i <= rows(info); i++) {
        // Drop individuals with > 1 or 0 goods chosen
        y_ij = panelsubmatrix(y, i, info)
        if(sum(y_ij) != 1) continue

        // Compute the likelihood
        // ----------------------

        // Probability of each choice set. We want to compute P(Y |
        // c, theta) P(c | theta); we compute P(c | theta) / (total
        // for P(Y)) and then sum over all the choice sets
        sel    = selectindex (y_ij)
        d_ij   = panelsubmatrix(def, i, info)
        exb_ij = panelsubmatrix(exb, i, info)
        PY     = exb_ij :/ sum(exb_ij)
        PA     = pa_ij[i]
        PY_ij  = PA :* PY
        P_ij   = PY_ij + d_ij :* pi_ij[i]

        // Compute the likelihood
        fv = fv + log(P_ij[sel])

        // Compute the gradient and the Hessian
        // ------------------------------------

        if (todo >= 1) {
            index   = selectindex (d_ij)
            dLdP    = 1 / P_ij[sel]
            x_ij    = panelsubmatrix(x, i, info)
            xdphi_i = xdphi_ij[i, ]

            // Gradient
            dLdb_k_aux = (x_ij[sel, ] :- PY' * x_ij)
            dLdb_k = dLdb_k_aux * PY_ij[sel] * dLdP
            dLdg_k = xdphi_i :* (PY[sel] - (sel == index)) * dLdP

            g = g :+ (dLdb_k, dLdg_k)

            if (todo == 2) {
                xz_ij = xz[d_sel[i], ]

                // Hessian, beta
                PYx_ij     = PY' * x_ij
                dPdb_kl1_1 = dLdb_k_aux' * dLdb_k_aux
                dPdb_kl2_1 = PYx_ij' * PYx_ij
                dPdb_kl2_2 = x_ij' * diag(PY) * x_ij
                dPdb_kl    = (dPdb_kl1_1 - (dPdb_kl2_2 - dPdb_kl2_1)) * PY_ij[sel]

                // Hessian, cross
                dPdbg_kl   = PY[sel] * (dLdb_k_aux' * xdphi_i)

                // Hessian, gamma, delta
                dPdgd_aux  = (1 - 2 * PA) * (PY[sel] - (sel == index))
                dPdgd_kl   = dPdgd_aux * (xdphi_i' * xz_ij)

                // Hessian
                hb  = dLdP :* dPdb_kl  :- dLdb_k' * dLdb_k
                hg  = dLdP :* dPdgd_kl :- dLdg_k' * dLdg_k
                hbg = dLdP :* dPdbg_kl :- dLdb_k' * dLdg_k
                H = H :+ ((hb, hbg) \ (hbg', hg))
            }
        }
    }
    if (todo == 2) H = makesymmetric(H')
    if ( asexp ) {
        if (todo >= 1) g = g :/ b
        if (todo == 2) H = H :/ (b' * b) :- diag(g :/ b)
    }
}

void function _alogit_dsc_exact_fast(transmorphic M,
                                     real scalar todo,
                                     real rowvector b,
                                     fv, g, H)
{
    real scalar ktot
    ktot = st_numscalar("__alogit_ktot")
    H    = J(ktot, ktot,  0);
    g    = J(1, ktot,  0);
    st_numscalar("__alogit_ll", .)
    st_matrix("__alogit_b", b)
    st_numscalar("__alogit_todo", todo)
    if (moptimize_init_userinfo(M, 1) == "fast") {
        stata("plugin call aloglik_fast " + st_local("fastcall") + " dsc")
    }
    else {
        stata("plugin call aloglik_faster " + st_local("fastcall") + " dsc")
    }
    if (todo >= 1) g = st_matrix("__alogit_g")
    if (todo == 2) H = makesymmetric(uppertriangle(st_matrix("__alogit_H"))')
    fv = st_numscalar("__alogit_ll")
    if ( moptimize_init_userinfo(M, 8) ) {
        if (todo >= 1) g = g :/ b
        if (todo == 2) H = H :/ (b' * b) :- diag(g :/ b)
    }
}

///////////////////////////////////////////////////////////////////////
//                      DSC prediction helpers                       //
///////////////////////////////////////////////////////////////////////

real function alogit_dsc_predict(transmorphic M,
                                 real matrix y,
                                 real matrix x,
                                 real matrix xz,
                                 real matrix def,
                                 string scalar method,
                                 string scalar predict,
                                 | real rowvector b)
{

    // Function variables
    real matrix info
    real colvector xb, xzd, d_sel
    real scalar kx, ipos, apos, db, dg, dydx
    string scalar afit
    real rowvector b0

    // Function helpers
    real colvector exb, phi_ij, pa_ij, pi_ij

    // Loop variables to use for the likelihood
    real scalar i, PA, PI
    real colvector y_ij, exb_ij, d_ij
    real colvector dPYPC, dPYPC0, PY, PY_ij
    real rowvector dPY_ij

    // Variables to return
    real scalar mp0, mp1, loglik
    real colvector P_ij, PYC_ij, P0_i, dP_ij

    if (method == "importance") {
        errprintf("-method(importance)- is not available for -model(dsc)-\n")
        exit()
    }

    // Variables to use in the computation
    // -----------------------------------

    // Re-initialize info, group if user changed them
    moptimize_init_touse(M, st_local("touse"))
    moptimize_init_by(M, st_local("group"))

    info = panelsetup(*moptimize_util_by(M), 1)

    // Use user coefficients if passed
    if (args() == 7) {
        afit = st_local("afit")
        b0   = moptimize_init_eq_coefs(M, 1), moptimize_init_eq_coefs(M, 2)
        b    = (afit == "loglik")? b0: moptimize_result_coefs(M)
    }
    kx  = cols(x)
    if ( moptimize_init_userinfo(M, 8) ) b = log(b)

    // Helper for derivatives/elasticities
    dydx = (predict == "dpycdpc") | (predict == "dpyc") | (predict == "dpc")
    if (dydx) {
        ipos = strtoreal(st_local("ipos"))
        apos = strtoreal(st_local("apos"))
        db   = (ipos == 0)? 1 : b[ipos]
        dg   = (apos == 0)? 1 : b[kx + apos]
    }

    // New fit!
    xb  = x  * b[|1 \ kx|]'
    if (predict == "u") return(xb)
    xzd = xz * b[|kx + 1 \ .|]'
    if (predict == "a") return(xzd)

    // For the likelihood, P(A), P(Y)
    d_sel = selectindex(def)
    pa_ij = invlogit(xzd[d_sel])
    _editvalue(pa_ij, 1, 1 - epsilon(1))
    _editvalue(pa_ij, 0, epsilon(1))
    pi_ij = 1 :- pa_ij
    exb   = exp(xb)

    // Loop through individuals
    loglik = mp0 = mp1 = 0
    P_ij   = PYC_ij = P0_i = dP_ij = phi_ij = J(rows(y), 1, .)
    for (i = 1; i <= rows(info); i++) {
        y_ij = panelsubmatrix(y, i, info)
        if(sum(y_ij) != 1) {
            // if(sum(y_ij) > 1) {
            //     errprintf("dropped group with multiple positive outcomes\n")
            // }
            // else if(sum(y_ij) == 0) {
            //     errprintf("dropped group with no positive outcomes\n")
            // }
            continue
        }

        exb_ij = panelsubmatrix(exb, i, info)
        PY     = exb_ij :/ sum(exb_ij)
        PYC_ij[|info[i, ]'|] = PY
        if (predict == "pyc") continue

        d_ij = panelsubmatrix(def, i, info)
        PI   = pi_ij[i]
        PA   = pa_ij[i]

        P0_i[|info[i, ]'|] = J(length(y_ij), 1, PI)
        if (predict == "p0") continue

        phi_ij[|info[i, ]'|] = J(rows(y_ij), 1, PA)
        if (predict == "pa") continue

        mp0 = mp0 + PI
        if (predict == "mp0") continue

        mp1 = mp1 + PA
        if (predict == "mp1") continue

        _editmissing(PY, 0)
        PY_ij = PA :* PY + d_ij :* PI
        P_ij[|info[i, ]'|] = PY_ij
        if (predict == "py") continue

        loglik = loglik + log(PY_ij[selectindex(y_ij)])
        if (predict == "ll") continue

        ///////////////
        //  Margins  //
        ///////////////
        if (predict == "dpycdpc") {
            dPYPC0 = (PA * PI * dg) :* (PY :- 1)
            dPYPC  = (1 :- PY) :* db
        }
        else if (predict == "dpyc") {
            dPYPC0 = 0
            dPYPC  = (1 :- PY) :* db
        }
        else if (predict == "dpc") {
            dPYPC0 = (PA * PI * dg) :* (PY :- 1)
            dPYPC  = 0
        }
        else {
            dPYPC0 = 0
            dPYPC  = 1
        }
        ///////////////
        //  Margins  //
        ///////////////

        dPY_ij = (PA :* PY :* dPYPC) + d_ij :* dPYPC0
        dP_ij[|info[i, ]'|]  = dPY_ij
    }
    mp0 = mp0 / (i - 1)
    mp1 = mp1 / (i - 1)

         if (predict == "py")  return(P_ij)
    else if (predict == "pyc") return(PYC_ij)
    else if (predict == "pa")  return(phi_ij)
    else if (predict == "ll")  return(loglik)
    else if (predict == "p0")  return(P0_i)
    else if (predict == "mp0") return(mp0)
    else if (predict == "mp1") return(mp1)
    else if (dydx)             return(dP_ij)
}

real colvector function alogit_dsc_counterfactual(real colvector u,
                                                  real colvector phi,
                                                  real colvector def,
                                                  real matrix info)
{
    real scalar i, PA, PI
    real colvector P_ij, select, PY
    real colvector exb, pa_ij, PY_ij
    real colvector u_ij, y_ij, exb_ij, d_ij

    select = selectindex(st_data(., st_local("touse")))
    exb    = exp(u)
    pa_ij  = phi[selectindex(def)]
    _editvalue(pa_ij, 1, 1 - epsilon(1))
    _editvalue(pa_ij, 0, epsilon(1))
    P_ij   = J(rows(u), 1, .)

    for (i = 1; i <= rows(info); i++) {
        if(!anyof(select, info[i, 1]) & !anyof(select, info[i, 2])) continue
        u_ij = panelsubmatrix(u, i, info)
        y_ij = max(u_ij) :== u_ij

        if(sum(y_ij) != 1) {
            // if(sum(y_ij) > 1) {
            //     errprintf("dropped group with multiple positive outcomes\n")
            // }
            // else if(sum(y_ij) == 0) {
            //     errprintf("dropped group with no positive outcomes\n")
            // }
            continue
        }
        d_ij   = panelsubmatrix(def, i, info)
        PI     = 1 - pa_ij[i]
        PA     = pa_ij[i]
        exb_ij = panelsubmatrix(exb, i, info)
        PY     = exb_ij :/ sum(exb_ij)
        _editmissing(PY, 0)
        PY_ij  = PA :* PY
        P_ij[|info[i, ]'|] = PY_ij + d_ij :* PI
    }
    return(P_ij)
}
end
