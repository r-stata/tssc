program define choi_lr_support_interval_or_eq_0 , rclass
version 14

* Calculate the upper bound for the $k_global support interval
* This program is only called when the estimated OR = 0, in which case
* the lower bound also equals zero.

* This is done using the nl command following an approach described in
* http://www.stata.com/support/faqs/programming/system-of-nonlinear-equations/

* The nl program fits non-linear regression functions by least squares. We get
* an exact solution to an equation by fitting a model with two parameters and 
* two variables. (For some reason this approach doesn't work with only one 
* record). The dependent variable must take the values 1 and 0 in records 1 & 2.

* Suppose we wish to solve f(x) = 0
* We let y = 1 = f(x) +1 in the first record and
*        y = 0 = dummy in the second
* nl then findes the least squares estimates of x and dummy, which will equal
* the value of x that gives f(x) = 0, and dummy = 0, respectively.

    clear // Note that this command does not erase our scalar values.
 
* Calculate the upper bound of the $k_global support interval

* Calculate a starting value assuming a normal approximation of the likelihood function
* We add 1 to any empty cells
 
    local a = y1
    local b = y2
    local c =  n1-`a'
    local d = n2-`b'
    local sigma = sqrt(1/max(`a',1) + 1/`b' +1/`c' + 1/max(`d',1))
    local psi_start = log(max(`a',1)) + log(max(`d',1))  - log(`b')  - log(`c') 
    local log_ub = `psi_start' +`sigma'*sqrt(2*log($k_global))
    local ub = exp(`log_ub')
    local support_start = `log_ub' 
    quietly set obs 2
  
    generate y = 0
    quietly replace y = 1 in 1
 
    quietly nl _choi_support_interval @ y, parameters(psi dummy ) ///
        initial(psi `support_start' dummy 0 )
 
    scalar psi = [psi]_b[_cons]
    scalar dummy = [dummy]_b[_cons]
    scalar LRsupport_ub = exp(psi)
    scalar LRsupport_lb = 0
    choi_lr_hyperg_prob n1 n2 y1 y2 psi

    local k_alpha =strofreal($k_global,"%-10.7g")
    display as result "1/`k_alpha'LSI for the OR = [0, " LRsupport_ub "]"
    return scalar LRsupport_lb =LRsupport_lb
    return scalar LRsupport_ub =LRsupport_ub

end // *****************************************************************
