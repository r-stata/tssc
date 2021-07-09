program define choi_lr_testi, rclass
version 14

* This is the immediate version of choi_lr_test

* Calculate statistics for 2x2 tables contitioned on the marginal
* success rate. These include the
*    Conditional maximum likelihood estimate of odds ratio (OR).
*    Conditional likelihood ratio for the null hypothesis that OR = 1
*    LiChoi's likelihood ratio chi-squared test for 2x2 tables
*    The 1/6.8259358 likelihood support interval (LSI) for the OR
*    The 1/k LSI for the OR using some other value of k

* See Choi et al. 2015 PLoS ONE. 10(4): e0121263.

* INPUT:
*    a = number of exposed cases
*    b = number of unexposed cases
*    c = number of exposed controls
*    d = number of unexposed controls
*    k = a value used to calculate the 1/k LSI for the OR.
*        The 1/6.8259358 LSI is calculated by 
*        default, which equals the frequentist 95% confidence 
*        interval for normally distrubuted statistics.

* OUTPUT:
*    or_cond  = Maximum likelihood estimate (MLE) of the odds ratio for
*               exposure among cases vs. controls conditioned
*               on the total number of exposed subjects.
*    clr      = Conditional likelihood ratio for the null hypothesis that OR = 1 
*    chi2_clr = Choi's LR chi-squared statistic. This is equation 9 of Choi et al. 
*    p_choi   = P value associated with the null hypothesis that OR = 1 
*    [lr6pt8lsi_lb, lr6pt8lsi_ub]
*             = likelihood ratio support interval for OR with k = 6.8259358.
*    [lrklsi_lb, lrklsi_ub]
*             = the likelihood ratio support interval for the user's value of k

* SOME OTHER VARIABLES:
*    psi     = the log of an odds ratio estimate.  Not necessarily the MLE
*    psi_mle = the conditional MLE of psi
*    y1      = number of successes on treatment 1
*    y2      = number of successes on treatment 2
*    n1      = number of subjects on treatment 1
*    n2      = number of subjects on treatment 2
*    yplus   = y1 + y2 = the marginal (total) number of successes
*    max_lnf = probability mass function of y1|yplus at psi_mle
*  
* NOTATION
*    Choi et al. discuss a 2x2 table with n1 and n2 subjects on treatments 1 and
*    and 2, respectively with y1 and y2 successes observed on these two treatments.
*    This program is written using their notation. Hence,
*    a + b = n1 = total number of cases = total number of subjects on treatment 1
*    c + d = n2 = total number of controls = total number of subjects on treatment 2
*    a = y1 = number of exposed cases = number of successes on treatment 1
*    c = y2 = number of exposed controls = number of successes on treatment 2

* CALLING SYNTAX
*    choi_lr_testi #a #b #c #d, k(#k) 

    gettoken a 0 : 0, parse(" ,")
    gettoken b 0 : 0, parse(" ,")
    gettoken c 0 : 0, parse(" ,")
    gettoken d 0 : 0, parse(" ,")

    confirm integer number `a'
    confirm integer number `b'
    confirm integer number `c'
    confirm integer number `d'

    if `a'<0 | `b'<0 | `c'<0 | `d'<0 { 
        display as error "negative numbers invalid"
	exit 498
    }
	
* Identify tables with too many zeros

    if `a'*`d'==0 & `b'*`c'==0 {
        display as error "Too many empty cells to estimate OR"
        exit 498
    }
 
    syntax [, K(numlist max=1) Woolf TB COrnfield Exact  Level(cilevel) * ]

    local levopt="level(`level')"

    preserve
       
* Confirm that needed scalars do not exist in the calling program. If they 
* do, save them with another name so that they can be restored when the 
* program ends.

    foreach v in n1 n2 y1 y2 dummy psi p_choi chi2_clr clr max_lnf psi_mle k {
        capture confirm scalar `v'
        if _rc == 0  {
            scalar ______TMP`v' = `v'
         }
    }      
    scalar y1 = `a'
    scalar y2 = `c'
    scalar n2 = `c' + `d'
    scalar n1 = `a' + `b'
*
* Do conventional case-control analysis
*
    cci `a' `b' `c' `d', `woolf' `tb' `cornfield' `exact' `levopt' `options'
    local log_or_unconditional = log(r(or))
    return scalar p        = r(p)        //two-sided p-value from the 2x2 chi^2 statistic without continuity correction
    return scalar p1_exact = r(p1_exact) //chi-squared or one-sided exact significance
    return scalar p_exact  = r(p_exact)  //two-sided exact significance
    return scalar or       = r(or)       //Unconditioned MLE of the odds ratio
    return scalar lb_or    = r(lb_or)    //lower bound of CI for or
    return scalar ub_or    = r(ub_or)    //upper bound of CI for or
    return scalar afe      = r(afe)      //attributable (prev.) fraction among exposed
    return scalar lb_afe   = r(lb_afe)   //lower bound of CI for afe
    return scalar ub_afe   = r(ub_afe)   //upper bound of CI for afe
    return scalar afp      = r(afp)      //attributable fraction for the population
    return scalar chi2     = r(chi2)     //2x2 chi^2 statistic without continuity correction
    display " "
    clear
    quietly set obs 1
    gen  y1 = y1
    gen  y2 = y2
    

* Calculate the MLE of psi = log(or_cond)

* See http://www.stata.com/features/overview/maximum-likelihood-estimation/
* for an introduction to Stata's ml program. The example given in this URL
* was modified to maximize the likelihood function given in equation 7 of 
* Choi et al. 2015.

* Identify if estimated OR = 0, infinity, of some positive number
    if `a'*`d'>0 & `b'*`c'>0  { // all cells are positive

        quietly ml model lf choi_lr_hypergeom  (y1=)
        quietly ml init `log_or_unconditional', copy
        quietly ml maximize
  
* The preceding command returns _b[_cons] which is the MLE of psi, 
* and e(ll) which is the maximum value of the log likelihood function

        scalar psi_mle = _b[_cons]
        scalar max_lnf = e(ll)

* Calculate the probability of the observed results under the null hypothesis 
* that psi = 0.

        choi_lr_hyperg_prob n1 n2 y1 y2 0
  
* r(lnf) equals the log of the probability mass function when psi = 0

        scalar clr = exp(max_lnf - r(lnf))
        scalar chi2_clr = -2*(r(lnf)-max_lnf)
        scalar p_choi = chi2tail(1, chi2_clr)
        display as result " "
        display as result "Likelihood ratio statistics conditioned on the marginal exposure rate"
        display as result " "
        display as result "Maximum likelihood estimate (MLE) of odds ratio      = "exp(psi_mle)
        display as result "Likelihood ratio under the null hypothesis           = "clr
        display as result "Likelihood ratio chi-squared statistic               = "chi2_clr 
        display as result "P value for the null hypothesis that the OR equals 1 = "p_choi

        return scalar or_cond   = exp(_b[_cons])
        return scalar clr   = clr
        return scalar chi2_clr = chi2_clr
        return scalar p_choi    =  p_choi
        global k_global = 6.8259358
    
* Calculate the 1/6.8259358 LSI for the OR

        choi_lr_support_interval 
        return scalar lr6pt8lsi_lb =LRsupport_lb
        return scalar lr6pt8lsi_ub =LRsupport_ub

* Calculate the 1/k LSI for the OR
        if "`k'"~="" {
	    global k_global = `k'
	    choi_lr_support_interval
	    return scalar lrklsi_lb =LRsupport_lb
	    return scalar lrklsi_ub =LRsupport_ub
        }
    }
    else if `a'*`d'>0 & `b'*`c'==0  { // Estimated OR = infinity
        
* Equation (7) of Choi et al 2015 approaches 1 as psi approaches infinity
* A proof of this is given in Equn7whenAcellEquals0.pdf, which is stored in
* my dropbox folder \OFFICE_desktop\ChoiFisherTest\Stata Program\ado\withZeros
    
        scalar max_lnf = 0
        choi_lr_hyperg_prob n1 n2 y1 y2 0
        scalar clr = exp(max_lnf - r(lnf))
        scalar chi2_clr = -2*(r(lnf)-max_lnf)
        scalar p_choi = chi2tail(1, chi2_clr)
        display as result " "
        display as result "Likelihood ratio statistics conditioned on the marginal exposure rate"
        display as result " "
        display as result "Maximum likelihood estimate (MLE) of odds ratio      = infinity"
        display as result "Likelihood ratio under the null hypothesis           = "clr
        display as result "Likelihood ratio chi-squared statistic               = "chi2_clr 
        display as result "P value for the null hypothesis that the OR equals 1 = "p_choi
        
        return scalar or_cond   = .
        return scalar clr   = clr
        return scalar chi2_clr = chi2_clr
        return scalar p_choi    =  p_choi
        global k_global = 6.8259358
    
* Calculate the 1/6.8259358 LSI for the OR
        choi_lr_support_interval_big_or
        return scalar lr6pt8lsi_lb =LRsupport_lb
        return scalar lr6pt8lsi_ub =.

* To comfirm this lower bound execute the next three lines
*           local debug_psi = log(LRsupport_lb)		//debug
*           choi_lr_hyperg_prob n1 n2 y1 y2 `debug_psi' //debug
*           di "LR at lb = " 1/exp(r(lnf)) 		//debug

* Calculate the 1/k LSI for the OR
        if "`k'"~="" {
            global k_global = `k'
            choi_lr_support_interval_big_or
            return scalar lrklsi_lb =LRsupport_lb
            return scalar lrklsi_ub =.
* To comfirm this lower bound execute the next three lines    
*               local debug_psi = log(LRsupport_lb)		//debug
*               choi_lr_hyperg_prob n1 n2 y1 y2 `debug_psi' 	//debug
*               di "LR at lb = " 1/exp(r(lnf)) 			//debug
        }

    }
    else if `a'*`d'==0 & `b'*`c'>0  { // Estimated OR = 0
    
    * Equation (7) of Choi et al 2015 approaches 1 as psi approaches minus infinity
    * A proof of this is given in Equn7whenAcellEquals0.pdf, which is stored in
    * my dropbox folder \OFFICE_desktop\ChoiFisherTest\Stata Program\ado\withZeros
    
        scalar max_lnf = 0
        choi_lr_hyperg_prob n1 n2 y1 y2 0
        scalar clr = exp(max_lnf - r(lnf))
        scalar chi2_clr = -2*(r(lnf)-max_lnf)
        scalar p_choi = chi2tail(1, chi2_clr)
        display as result " "
        display as result "Likelihood ratio statistics conditioned on the marginal exposure rate"
        display as result " "
        display as result "Maximum likelihood estimate (MLE) of odds ratio      = 0"
        display as result "Likelihood ratio under the null hypothesis           = "clr
        display as result "Likelihood ratio chi-squared statistic               = "chi2_clr 
        display as result "P value for the null hypothesis that the OR equals 1 = "p_choi
        
        return scalar or_cond   = 0
        return scalar clr   = clr
        return scalar chi2_clr = chi2_clr
        return scalar p_choi    =  p_choi
        global k_global = 6.8259358
    
* Calculate the 1/6.8259358 LSI for the OR
        choi_lr_support_interval_or_eq_0 
        return scalar lr6pt8lsi_lb =0
        return scalar lr6pt8lsi_ub =LRsupport_ub
        
* To comfirm this upper bound execute the next three lines    
*           local debug_psi = log(LRsupport_ub)		//debug
*           choi_lr_hyperg_prob n1 n2 y1 y2 `debug_psi' //debug
*           di "LR at ub = " 1/exp(r(lnf)) 		//debug

* Calculate the 1/k LSI for the OR
        if "`k'"~="" {
            global k_global = `k'
            choi_lr_support_interval_or_eq_0 
            return scalar lrklsi_lb =0
            return scalar lrklsi_ub =LRsupport_ub
* To comfirm this upper bound execute the next three lines    
*               local debug_psi = log(LRsupport_ub)		//debug
*               choi_lr_hyperg_prob n1 n2 y1 y2 `debug_psi' 	//debug
*               di "LR at ub = " 1/exp(r(lnf)) 			//debug
        }
    }
    
*   Restore any scalar values from the calling program that have been changed

    foreach v in n1 n2 y1 y2 dummy psi p_choi chi2_clr clr max_lnf psi_mle k {
        capture confirm scalar ______TMP`v'
        if _rc == 0  {
            scalar `v' = ______TMP`v'
            scalar drop ______TMP`v'
        }
    }

end // ********************************************************
