/// illuration Code for panelhetro


/// 0. Initialization


use panelinit
xtset id period

/// 1. Empiricl CDF Estimaton

phecdf y, method("hpj") acov_order(0) acor_order(1)

/// 2. Moment Estimation

phmoment y, method("hpj") boot(200) acov_order(0) acor_order(1)

ereturn list
matrix list e(ci)
matrix list e(se)
matrix list e(est)

/// 3. Kernel Density Estimation

phkd y, method("hpj") acov_order(0) acor_order(1)
