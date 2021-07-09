
//load the Arellano-Bond dataset
    . webuse abdata

//Estimate a second order model (two lags of n) with iid resampling and burn-in initialization
    . xtbcfe n w wL1 k kL1 kL2 ys ysL1 ysL2, bciters(250) res(iid) ini(bi) lags(2)

//Add time dummies to the model
    . xtbcfe n w wL1 k kL1 kL2 ys ysL1 ysL2, bciters(250) res(iid) ini(bi) lags(2) te

//Take temporal heteroscedasticity into account by adjusting the resampling scheme
    . xtbcfe n w wL1 k kL1 kL2 ys ysL1 ysL2, bciters(250) res(thet) ini(bi) lags(2) te

//Relax the convergence criterion from 0.005 to 0.01
    . xtbcfe n w wL1 k kL1 kL2 ys ysL1 ysL2, bciters(250) res(iid) ini(bi) lags(2) te crit(0.01)

//Perform inference on the model with confidence intervals based on the t-distribution
    . xtbcfe n w wL1 k kL1 kL2 ys ysL1 ysL2, bciters(250) res(thet) ini(bi) lags(2) infer(inf_se) infit(50) te

//Perform inference with percentile intervals (note: time intensive!)
    . xtbcfe n w wL1 k kL1 kL2 ys ysL1 ysL2, bciters(250) res(thet) ini(bi) lags(2) infer(inf_ci) infit(1000) te

//Perform inference with percentile intervals and save the bootstrapped distribution of bcfe (note: time intensive!)
    . xtbcfe n w wL1 k kL1 kL2 ys ysL1 ysL2, bciters(250) res(thet) ini(bi) lags(2) infer(inf_ci) infit(1000) te dist(none)
