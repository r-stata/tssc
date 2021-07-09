/*version 1.0.0 3 March 2008*/
/*version 1.0.1 25 November 2008*/
/*fixes in 1.0.1
    - added seeding number as an argument to avoid getting the same results for simulation occuring on the same second
      thanks to ALlan Garland for noticing the issue
*/
program define skbim
	version 9.2
	/*Generates a dataset of values from bimodal distribution . The two distribution that make up the
    bimodal can be normal or skew-normal and are named d1 and d2 for easier reference below
	requires 6-11 arguments (last 5 are optional)
	the first is the probability of the 1st distribution
	for arguments 2 to 5 we have three different options (defined by argument no 6):
	   option1: mean of d1, var of d1, mean of d2, var of d2
	   option2: bimodal mean, bimodal var, var of d1, var of d2
       option3: bimodal mean, bimodal var, mean of d1, var of d1
    args 7 to 12 are optional: size, seed number, skewness d1, kurtosis d1, skewness d2, kurtosis d2. If they are
    omitted, skewness and kurtosis values for normal distributions are used (sk=0, ku=3) and the size of the dataset
    is used as default

    Uses Ramberg's method and tables - A probability Distribution and its uses in fitting data
    http://www.jstor.org/view/00401706/ap040083/04a00080/0
    The method uses a formula with 4 parameters and parameter values which generate data of various
    degrees of skewness and kurtosis have been provided in the paper. only a few of those have been included
    in the command, but it can easily be updated for specific values*/

    /*arguments*/
    args p_d1 v1 v2 v3 v4 optn bsize snum psk1 ku1 psk2 ku2
    /*VALIDATE INPUT*/
    if "`p_d1'"=="" | "`v1'"=="" | "`v2'"=="" | "`v3'"=="" | "`v4'"=="" | "`optn'"=="" {
        di "command requires at least six numeric arguments - please see help for details"
        error 197
    }
    if `p_d1'<=0 | `p_d1'>=1 {
        di "probability for 1st distribution (argument 1) needs to be within the (0,1) range"
        error 197
    }
    scalar p1 = `p_d1'
    /*for each option possibility verify input and caclulate the rest from bimodal equations*/
    if `optn'==1 {
        di "option 1 selected: m1, var1, m2 & var2"
        if `v2'<=0 | `v4'<=0 {
            di "variances of d1 and d2 (arguments 4&5) need to be positive!"
            error 459
        }
        scalar m1 = `v1'
        scalar var1 = `v2'
        scalar m2 = `v3'
        scalar var2 = `v4'
        scalar mb = p1*m1 + (1-p1)*m2
        scalar varb = p1*var1 + (1-p1)*var2 + p1*(1-p1)*(m1-m2)^2
    }
    else if `optn'==2 {
        di "option 2 selected: mb, varb, var1 & var2"
        if `v2'<=0 | `v3'<=0 | `v4'<=0 {
            di "variances of bimodal, d1 and d2 (arguments 3,4&5) need to be positive!"
            error 459
        }
        scalar mb = `v1'
        scalar varb = `v2'
        scalar var1 = `v3'
        scalar var2 = `v4'
        scalar temp = (varb-p1*var1-(1-p1)*var2) / (p1*(1-p1))
        /*break if there is a problem with the values*/
        if temp<=0 {
            di "cannot proceed with the provided values. it must hold that var(b)-p*var(d1)-(1-p)*var(d2)>=0"
            error 459
        }
        scalar m1 = mb + (1-p1)*sqrt(temp)
        scalar m2 = (mb-p1*m1)/(1-p1)
    }
    else if `optn'==3 {
        di "option 2 selected: mb, varb, m1 & var1"
        if `v2'<=0 | `v4'<=0 {
            di "variances of bimodal and d1 (arguments 3&5) need to be positive!"
            error 459
        }
        scalar mb = `v1'
        scalar varb = `v2'
        scalar m1 = `v3'
        scalar var1 = `v4'
        scalar m2 = (mb-p1*m1)/(1-p1)
        scalar var2 = (varb-p1*(1-p1)*(m1-m2)^2-p1*var1)/(1-p1)
        /*break if there is a problem with the values*/
        if var2<=0 {
            di "cannot proceed with the provided values. it must hold that var(b)>p*var(d1)+p(1-p)*(m1-m2)^2"
            error 459
        }
    }
    else {
        di "option (argument 6) needs to be either 1, 2 or 3"
        error 197
    }
    /*optional arguments skenwness and kurtosis of d1 and d2*/
	if "`psk1'"=="" local psk1 = 0
	if "`ku1'"=="" local ku1 = 3
	if "`psk2'"=="" local psk2 = 0
	if "`ku2'"=="" local ku2 = 3
	if "`bsize'"=="" {
        qui count
        local bsize = `r(N)'
    }
	if "`snum'"=="" {
        local snum = 777
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
    local sk1 = abs(`psk1')
    local sk2 = abs(`psk2')
    /*define lamda values - 2 first columns are skewness and kurtosis for looking up*/
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
    local seednum = `seednum' + mb*10 + varb*10^2 + `bsize' + `time'
    set seed `seednum'
    /*repeat for each of the 2 distributions*/
    forvalues dist=1(1)2 {
        /*look up the lambda values that correspond to the inputed sk and ku*/
        local rownum = rowsof(L)
        local rowhit = 0
        local i = 0
        while `rowhit'==0 & `i'<`rownum' {
            local i = `i' + 1
            if L[`i',1]==`sk`dist'' & L[`i',2]==`ku`dist'' {
                local rowhit = `i'
            }
        }
        if `rowhit'==0 {
            display "lambda matrix does not include skewness or kurtosis values you inputted"
            error 504
        }
        else {
            forvalues i=1(1)4 {
                scalar L`dist'_`i' = L[`rowhit',`i'+2]
            }
        }
    }
    /*set number of observations. if it smaller than the current one avoid error*/
    qui capture set obs `bsize'
    /*DRAW STUDY MEANS FROM POPULATION*/
    local mb = mb
    local m1 = m1
    local m2 = m2
    local varb = varb
    local var1 = var1
    local var2 = var2
    qui capture gen skewbim=.
    if _rc!=0 {
        di "There is already a variable with the same name - delete or rename it and repeat procedure"
        error 4
    }
    /*strings for label*/
    foreach x in mb varb m1 var1 m2 var2 psk1 ku1 psk2 ku2 {
        local `x's = string(``x'',"%2.1g")
    }
    local strlab = "bimodal of m=`mbs' var=`varbs' (m1=`m1s' v1=`var1s' sk1=`psk1s' ku1=`ku1s' m2=`m2s'"
    local strlab = "`strlab' v2=`var2s' sk2=`psk2s' ku2=`ku2s')"
    label var skewbim "`strlab'"
    /*generate the values*/
    forvalues j=1(1)`bsize' {
        /*toss a coin and decide on which distribution this case will follow*/
        local tcoin = uniform()
        if `tcoin' < `p_d1' {
            local dsel = 1
        }
        else {
            local dsel = 2
        }
        /*random uniform dist number that will be used in Ramberg's method*/
        scalar u = uniform()
        if u == 0 {
            scalar u = 10^-20
        }
        /*Ramberg's random num generator - num follow dist w m=0, var=1*/
        scalar Rb = L`dsel'_1+(u^L`dsel'_3 - (1-u)^L`dsel'_4)/L`dsel'_2
        /*rescale to selected distribution's mean and standard deviation*/
        scalar temp = `m`dsel'' + Rb*sqrt(`var`dsel'')
        /*if given negative skewness flip distribution*/
        if `psk`dsel''<0 {
            scalar temp = 2*`m`dsel'' - temp
        }
        qui replace skewbim = temp in `j'
    }
    di "generated `bsize' obs from bimodal distribution of mean=`mbs' & var=`varbs'"
    di "with m1=`m1s' v1=`var1s' sk1=`psk1s' ku1=`ku1s' & m2=`m2s' v2=`var2s' sk2=`psk2s' ku2=`ku2s'"
    di "note: numbers have been rounded to the first decimal for display purposes (in the label as well)"
end
