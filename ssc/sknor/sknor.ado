/*version 1.0.0 3 March 2008*/
/*version 1.0.1 25 November 2008*/
/*fixes in 1.0.1
    - added seeding number as an argument to avoid getting the same results for simulation occuring on the same second
      thanks to ALlan Garland for noticing the issue
*/
program define sknor
	version 9.2
	/*Generates a dataset of values from a skew-normal unimodal distribution
	requires 5 arguments: mean, variance, skweness, kurtosis and size of the genereated sample.
    Can be used for generating normal sample for sk=0 and ku=3
    Uses Ramberg's method and tables - A probability Distribution and its uses in fitting data
    http://www.jstor.org/view/00401706/ap040083/04a00080/0
    The method uses a formula with 4 parameters and parameter values which generate data of various
    degrees of skewness and kurtosis have been provided in the paper. only a few of those have been included
    the command, but it can easily be updated specific values*/
    /*arguments*/
	args bsize snum mu tvar psk ku
	/*if no arguments inutted then some default values for normal distribution used*/
	if "`mu'"=="" local mu = 0
	if "`tvar'"=="" local tvar = 1
	if "`psk'"=="" local psk = 0
	if "`ku'"=="" local ku = 3
	if "`bsize'"=="" {
        qui count
        local bsize = `r(N)'
    }
	if "`snum'"=="" {
        local snum = 777
    }
    /*VALIDATE INPUT*/
    if `tvar'<0 {
        display "variance needs to be positive"
        error 197
    }
    /*just in case an invalid sample size has been provided*/
    if `bsize'<=0 {
        di "invalid sample size provided, current num of obs will be used instead"
        qui count
        local bsize = `r(N)'
    }
    if `bsize'!=int(`bsize') {
        di "invalid sample size provided, provided number will be truncated"
        local bsize = int(`bsize')
    }
    /*if negative skewness provided take into account*/
    local sk = abs(`psk')
    /*define lamda values - 2 first columns are skewness and kurtosis for looking up - last 4 the formula's parameters*/
    matrix input L = (0, 1.75, 0 , 0.5943, 1.4501, 1.4501\ /*
    */ 0, 3, 0, 0.1974, 0.1349, 0.1349\ 0, 4, 0, 0.0262, 0.0148, 0.0148\ /*
    */ 0, 5, 0, -0.0870, -0.0433, -0.0433\ 0, 6, 0, -0.1686, -0.0802, -0.0802\ /*
    */ 0, 7, 0, -0.2306, -0.1045, -0.1045\ 0, 8, 0, -0.2800, -0.1223, -0.1223\ /*
    */ 0, 9, 0, -0.3203, -0.1359, -0.1359\ 0, 3.2, 0, 0.1563, 0.1016, 0.1016\ /*
    */ 0, 3.3, 0, 0.1371, 0.0872, 0.0872\ 0, 3.4, 0, 0.1191, 0.0742, 0.0742\ /*
    */ 0, 3.6, 0, 0.0852, 0.0512, 0.0512\ 0, 4.4, 0, -0.0241, -0.0130, -0.0130\ /*
    */ 0.5, 4, -0.290, 0.0604, 0.0259, 0.0447\ 0.5, 5, -0.188, -0.0546, -0.0236, -0.0333\ /*
    */ 0.5, 6, -0.142, -0.1398, -0.0591, -0.0764\ 0.5, 7, -0.117, -0.2050, -0.0845, -0.1042\ /*
    */ 0.5, 8, -0.101, -0.2567, -0.1035, -0.1238\ 0.5, 9, -0.089, -0.2986, -0.1181, -0.1384\ /*
    */ 1, 4, -0.886, 0.1333, 0.0193, 0.1588\ 1, 5, -0.533, 0.0340, 0.009695, 0.0285\ /*
    */ 1, 6, -0.379, -0.0562, -0.0187, -0.0388\ 1, 7, -0.215, -0.2356, -0.0844, -0.1249\ /*
    */ 1, 8, -0.248, -0.1878, -0.0670, -0.1058\ 1, 9, -0.215, -0.2356, -0.0844, -0.1249\ /*
    */ 1, 10, -0.191, -0.2752, -0.0985, -0.1393\ 0.5, 3, -0.639, 0.2006, 0.0630, 0.2307\ /*
    */ 1.5, 6, -0.957, 0.0622, 0.003907, 0.0677\ 1.5, 7, -0.684, -0.0115, -0.002088, -0.009875\ /*
    */ 1.5, 8, -0.536, -0.0767, -0.0184, -0.0565\ 1.5, 9, -0.443, -0.1330, -0.0362, -0.0880\ /*
    */ 1.5, 10, -0.382, -0.1803, -0.0524, -0.1104\ 1.5, 11, -0.338, -0.2202, -0.0665, -0.1271\ /*
    */ 1.5, 12, -0.305, -0.2544, -0.0786, -0.1401\ 2, 9, -0.993, -0.001081, -0.00000407, -0.001076\ /*
    */ 2, 10, -0.796, -0.0538, -0.005187, -0.0458\ 2, 11, -0.670, -0.1005, -0.0154, -0.0766\ /*
    */ 2, 12, -0.579, -0.1423, -0.0273, -0.0995\ 2, 13, -0.515, -0.1784, -0.0388, -0.1168\ /*
    */ 2, 14, -0.466, -0.2101, -0.0495, -0.1305\ 2, 15, -0.428, -0.2380, -0.0592, -0.1415)
    /*randomly set the seed number because it is set and not random*/
    local seednum = `snum'
    local time = c(current_time) /*get time to add to seed number*/
    local time : subinstr local time ":" "", all /*remove all the :s*/
    local seednum = `seednum' + `sk'*10^4 + `ku'*10^2 + `bsize' + `time'
    set seed `seednum'
    /*look up the lambda values that correspond to the inputed sk and ku*/
    local rownum = rowsof(L)
    local rowhit = 0
    local i = 0
    while `rowhit'==0 & `i'<`rownum' {
        local i = `i' + 1
        if L[`i',1]==`sk' & L[`i',2]==`ku' {
            local rowhit = `i'
        }
    }
    if `rowhit'==0 {
        display "lambda matrix does not include skewness or kurtosis values you inputted - sorry"
        error 504
    }
    else {
        forvalues i=1(1)4 {
            scalar L`i' = L[`rowhit',`i'+2]
        }
    }
    /*set number of observations. if it smaller than the current one avoid error*/
    qui capture set obs `bsize'
    /*DRAW STUDY MEANS FROM POPULATION*/
    qui capture gen skewnormal=.
    if _rc!=0 {
        di "There is already a variable with the same name - delete or rename it and repeat procedure"
        error 4
    }
    label var skewnormal "sample of `bsize' obs from skew-normal dist of mean=`mu' var=`tvar' sk=`psk' & ku=`ku'"
    /*generate values loop*/
    forvalues j=1(1)`bsize' {
        /*random uniform dist number that will be used in Ramberg's method*/
        scalar u = uniform()
        if u == 0 {
            scalar u = 10^-20
        }
        /*Ramberg's random num generator*/
        scalar Rb = L1+(u^L3 - (1-u)^L4)/L2
        /*rescale to skewed distribution according to mean and standard deviation*/
        scalar temp = `mu' + Rb*sqrt(`tvar')
        /*if given negative skewness flip distribution*/
        if `psk'<0 {
            scalar temp = 2*`mu' - temp
        }
        qui replace skewnormal = temp in `j'
    }
    di "generated sample of `bsize' obs from skew-normal dist of mean=`mu' var=`tvar' sk=`psk' & ku=`ku'"
end
