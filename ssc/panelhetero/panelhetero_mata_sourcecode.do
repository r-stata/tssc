/* Mata function library for 
Ryo Okui and Takahide Yanagi. Kernel Estimation for Panel Data       
   with Heterogeneous Dynamics. 2019.
Ryo Okui and Takahide Yanagi. Panel Data Analysis with Heterogeneous 
   Dynamics. 2019. */

/* Contents
1. Basic
  1.1. Autocovariance
  1.2. Autocorrelation
2. Empirical CDF Estimation
  2.1. Naive Estimation
  2.2. Half-Panel-Jackknife Estimation
  2.3. Third-Order-Jackknife Estimation
3. Moment Estimation
  3.1. Naive Estimation
  3.2. Half-Panel-Jackknife Estimation
  3.3. Third-Order-Jackknife Estimation
4. Kernel Density Estimation
  4.1. Naive Estimation
  4.2. Half-Panel-Jackknife Estimation
  4.3. Third-Order-Jackknife Estimation
*/

version 14.0
mata:
mata clear

///  1. Basic

// 1.1. Autocovariance

function mataacov (y, acov_order){
	k = acov_order
	s = length(y)
	mean_est = sum(y) / s
	y1 = y[1::s-k]
	y2 = y[k+1::s]
	acov_est = sum((y1 :- mean_est) :* (y2 :- mean_est)) / (s - k)
	return(acov_est)
}

// 1.2. Autocorrelation

function mataacor (y, acor_order){
	acor_est = mataacov(y, acor_order) / mataacov(y, 0)
	return(acor_est)
}

///  2. Empirical CDF estimation

function m_freq(x, X){
    est = mean(X:<=x)
    return(est)
}

// 2.1. Naive Estimation 


function m_neecdf(data, acov_order, acor_order, B) {
    N = rows(data)
	S = cols(data)
	grid = 100
	
	mean_est = J(N, 1, 0)
	acov_est = J(N, 1, 0)
	acor_est = J(N, 1, 0)
	
	for (i = 1; i <= N; i++) {
	    mean_est[i] = mean(data[i,.]')
		acov_est[i] = mataacov(data[i,.], acov_order)
		acor_est[i] = mataacor(data[i,.], acor_order)
	}
	
	mean_lim = (min(mean_est), max(mean_est))
    acov_lim = (min(acov_est), max(acov_est))
    acor_lim = (min(acor_est), max(acor_est))
    
	mean_grid = rangen(mean_lim[1], mean_lim[2], grid)
	acov_grid = rangen(acov_lim[1], acov_lim[2], grid)
	acor_grid = rangen(acor_lim[1], acor_lim[2], grid)
	
	mean_ecdf = J(grid, 1, 0)
	acov_ecdf = J(grid, 1, 0)
	acor_ecdf = J(grid, 1, 0)
	
	mean_UCI = J(grid, 1, 0)
	acov_UCI = J(grid, 1, 0)
	acor_UCI = J(grid, 1, 0)
	
    mean_LCI = J(grid, 1, 0)
	acov_LCI = J(grid, 1, 0)
	acor_LCI = J(grid, 1, 0)

	for (i=1; i<=grid; i++) {
	    mean_ecdf[i] = m_freq(mean_grid[i], mean_est)
	    acov_ecdf[i] = m_freq(acov_grid[i], acov_est)
		acor_ecdf[i] = m_freq(acor_grid[i], acor_est)
		
		estimate_boot = J(B, 3, 0)
	    for (b = 1; b <= B; b++) {
		    index_boot = rdiscrete(N, 1, J(N, 1, 1/N))
		    estimate_boot[b,1] = m_freq(mean_grid[i], mean_est[index_boot]) - mean_ecdf[i]
			estimate_boot[b,2] = m_freq(acov_grid[i], acov_est[index_boot]) - acov_ecdf[i]
			estimate_boot[b,3] = m_freq(acor_grid[i], acor_est[index_boot]) - acor_ecdf[i]
	    }
	
	    mean_LCI[i] = mean_ecdf[i] + mm_quantile(estimate_boot[, 1], 1, 0.025)
		mean_UCI[i] = mean_ecdf[i] + mm_quantile(estimate_boot[, 1], 1, 0.975)
		
		acov_LCI[i] = acov_ecdf[i] + mm_quantile(estimate_boot[, 2], 1, 0.025)
		acov_UCI[i] = acov_ecdf[i] + mm_quantile(estimate_boot[, 2], 1, 0.975)
		
		acor_LCI[i] = acor_ecdf[i] + mm_quantile(estimate_boot[, 3], 1, 0.025)
		acor_UCI[i] = acor_ecdf[i] + mm_quantile(estimate_boot[, 3], 1, 0.975)
	}
	
	temp=st_addvar("double", "mean_ecdf")
    temp=st_addvar("double", "acov_ecdf")
    temp=st_addvar("double", "acor_ecdf")
    temp=st_addvar("double", "mean_grid")
	temp=st_addvar("double", "acov_grid")
	temp=st_addvar("double", "acor_grid")
	
	temp=st_addvar("double", "mean_LCI")
    temp=st_addvar("double", "acov_LCI")
    temp=st_addvar("double", "acor_LCI")
    temp=st_addvar("double", "mean_UCI")
	temp=st_addvar("double", "acov_UCI")
	temp=st_addvar("double", "acor_UCI")
	
    st_addobs(max((0,grid  - st_nobs())))
    st_store(.,"mean_ecdf", mean_ecdf\J(st_nobs()-rows(mean_ecdf),1,.))
    st_store(.,"acov_ecdf", acov_ecdf\J(st_nobs()-rows(acov_ecdf),1,.))
    st_store(.,"acor_ecdf", acor_ecdf\J(st_nobs()-rows(acor_ecdf),1,.))
    st_store(.,"mean_grid", mean_grid\J(st_nobs()-rows(mean_grid),1,.))
	st_store(.,"acov_grid", acov_grid\J(st_nobs()-rows(acov_grid),1,.))
    st_store(.,"acor_grid", acor_grid\J(st_nobs()-rows(acor_grid),1,.))
	
	st_store(.,"mean_LCI", mean_LCI\J(st_nobs()-rows(mean_LCI),1,.))
    st_store(.,"acov_LCI", acov_LCI\J(st_nobs()-rows(acov_LCI),1,.))
    st_store(.,"acor_LCI", acor_LCI\J(st_nobs()-rows(acor_LCI),1,.))
	st_store(.,"mean_UCI", mean_UCI\J(st_nobs()-rows(mean_UCI),1,.))
    st_store(.,"acov_UCI", acov_UCI\J(st_nobs()-rows(acov_UCI),1,.))
    st_store(.,"acor_UCI", acor_UCI\J(st_nobs()-rows(acor_UCI),1,.))
}


// 2.2. Half-Panel-Jackknife Estimation

function hpjecdfest1(x, X, X1, X2) {
    est = m_freq(x, X)
	est1 = m_freq(x, X1)
    est2 = m_freq(x, X2)
	
	hpjest = 2 * est - (est1 + est2) / 2
	
	if (hpjest < 0) {
	    hpjest = 0
	}
	if (hpjest > 1){
	    hpjest = 1
	}
    return(hpjest)
}

function hpjecdfest2(x, X, X1, X2, X3, X4) {
    est = m_freq(x, X)
	est1 = m_freq(x, X1)
    est2 = m_freq(x, X2)
	est3 = m_freq(x, X3)
    est4 = m_freq(x, X4)
	
	
	hpjest = 2 * est - (est1 + est2 + est3 + est4) / 4
	
	if (hpjest < 0) {
	    hpjest = 0
	}
	if (hpjest > 1){
	    hpjest = 1
	}
    return(hpjest)
}

function m_hpjecdf(data, acov_order, acor_order, B) {
    N = rows(data)
	S = cols(data)
	grid = 100

	if (mod(S,2)==0) {
	    mean_est = J(N, 1, 0)
	    acov_est = J(N, 1, 0)
	    acor_est = J(N, 1, 0)
	
	    data1 = data[,1::(S/2)]
	    data2 = data[,(S/2+1)::S]
		
	    mean_est1 = J(N, 1, 0)
	    mean_est2 = J(N, 1, 0)
		
	    acov_est1 = J(N, 1, 0)
	    acor_est1 = J(N, 1, 0)
	    
		acov_est2 = J(N, 1, 0)
	    acor_est2 = J(N, 1, 0)
		
		for(i=1; i<=N ;i++){
		    mean_est[i] = mean(data[i,.]')
			acov_est[i] = mataacov(data[i,.], acov_order)
			acor_est[i] = mataacor(data[i,.], acor_order)
			
		    mean_est1[i] = mean(data1[i,.]')
			acov_est1[i] = mataacov(data1[i,.], acov_order)
			acor_est1[i] = mataacor(data1[i,.], acor_order)
			
			mean_est2[i] = mean(data2[i,.]')
			acov_est2[i] = mataacov(data2[i,.], acov_order)
			acor_est2[i] = mataacor(data2[i,.], acor_order)
		}
		
		mean_lim = (min(mean_est), max(mean_est))
        acov_lim = (min(acov_est), max(acov_est))
        acor_lim = (min(acor_est), max(acor_est))
    
	    mean_grid = rangen(mean_lim[1], mean_lim[2], grid)
	    acov_grid = rangen(acov_lim[1], acov_lim[2], grid)
	    acor_grid = rangen(acor_lim[1], acor_lim[2], grid)
	
	    mean_ecdf = J(grid, 1, 0)
	    acov_ecdf = J(grid, 1, 0)
	    acor_ecdf = J(grid, 1, 0)
		
		mean_UCI = J(grid, 1, 0)
		acov_UCI = J(grid, 1, 0)
		acor_UCI = J(grid, 1, 0)
		
		mean_LCI = J(grid, 1, 0)
		acov_LCI = J(grid, 1, 0)
		acor_LCI = J(grid, 1, 0)
		
		for (i=1; i<= grid; i++){
		    mean_ecdf[i] = hpjecdfest1(mean_grid[i], mean_est, mean_est1, mean_est2)
			acov_ecdf[i] = hpjecdfest1(acov_grid[i], acov_est, acov_est1, acov_est2)
			acor_ecdf[i] = hpjecdfest1(acor_grid[i], acor_est, acor_est1, acor_est2)
			
			estimate_boot = J(B, 3, 0)
	        for (b = 1; b <= B; b++) {
		        index_boot = rdiscrete(N, 1, J(N, 1, 1/N))
		        estimate_boot[b,1] = hpjecdfest1(mean_grid[i], mean_est[index_boot], mean_est1[index_boot], mean_est2[index_boot]) - mean_ecdf[i]
			    estimate_boot[b,2] = hpjecdfest1(acov_grid[i], acov_est[index_boot], acov_est1[index_boot], acov_est2[index_boot]) - acov_ecdf[i]
			    estimate_boot[b,3] = hpjecdfest1(acor_grid[i], acor_est[index_boot], acor_est1[index_boot], acor_est2[index_boot]) - acor_ecdf[i]
			}
	
			mean_LCI[i] = mean_ecdf[i] + mm_quantile(estimate_boot[, 1], 1, 0.025)
			mean_UCI[i] = mean_ecdf[i] + mm_quantile(estimate_boot[, 1], 1, 0.975)
		
			acov_LCI[i] = acov_ecdf[i] + mm_quantile(estimate_boot[, 2], 1, 0.025)
			acov_UCI[i] = acov_ecdf[i] + mm_quantile(estimate_boot[, 2], 1, 0.975)
		
			acor_LCI[i] = acor_ecdf[i] + mm_quantile(estimate_boot[, 3], 1, 0.025)
			acor_UCI[i] = acor_ecdf[i] + mm_quantile(estimate_boot[, 3], 1, 0.975)
			}
			
		mean_data = sort((mean_ecdf, mean_LCI, mean_UCI), 1)
		acov_data = sort((acov_ecdf, acov_LCI, acov_UCI), 1)
		acor_data = sort((acor_ecdf, acor_LCI, acor_UCI), 1)
		mean_ecdf = mean_data[,1]
		mean_LCI = mean_data[,2]
		mean_UCI = mean_data[,3]
		acov_ecdf = acov_data[,1]
		acov_LCI = acov_data[,2]
		acov_UCI = acov_data[,3]
		acor_ecdf = acor_data[,1]
		acor_LCI = acor_data[,2]
		acor_UCI = acor_data[,3]
		
	}	
	else{
	    mean_est = J(N, 1, 0)
	    acov_est = J(N, 1, 0)
	    acor_est = J(N, 1, 0)
		
		data1 = data[., 1::floor(S/2)]
		data2 = data[., (floor(S/2)+1)::S]
		data3 = data[.,1::(floor(S/2)+1)]
		data4 = data[.,(floor(S/2)+2)::S]
		
		mean_est1 = J(N, 1, 0)
		mean_est2 = J(N, 1, 0)
		mean_est3 = J(N, 1, 0)
		mean_est4 = J(N, 1, 0)
		
		acov_est1 = J(N, 1, 0)
		acov_est2 = J(N, 1, 0)
		acov_est3 = J(N, 1, 0)
		acov_est4 = J(N, 1, 0)
		
		acor_est1 = J(N, 1, 0)
		acor_est2 = J(N, 1, 0)
		acor_est3 = J(N, 1, 0)
		acor_est4 = J(N, 1, 0)
		
		for(i=1; i<=N; i++){
		    mean_est[i] = mean(data[i,.]')
			mean_est1[i] = mean(data1[i,.]')
			mean_est2[i] = mean(data2[i,.]')
			mean_est3[i] = mean(data3[i,.]')
			mean_est4[i] = mean(data4[i,.]')
			
			acov_est[i] = mataacov(data[i,.], acov_order)
			acov_est1[i] = mataacov(data1[i,.], acov_order)
			acov_est2[i] = mataacov(data2[i,.], acov_order)
			acov_est3[i] = mataacov(data3[i,.], acov_order)
			acov_est4[i] = mataacov(data4[i,.], acov_order)
	
			acor_est[i] = mataacor(data[i,.], acor_order)
			acor_est1[i] = mataacor(data1[i,.], acor_order)
			acor_est2[i] = mataacor(data2[i,.], acor_order)
			acor_est3[i] = mataacor(data3[i,.], acor_order)
			acor_est4[i] = mataacor(data4[i,.], acor_order)
		} 
		
		mean_lim = (min(mean_est), max(mean_est))
        acov_lim = (min(acov_est), max(acov_est))
        acor_lim = (min(acor_est), max(acor_est))
    
	    mean_grid = rangen(mean_lim[1], mean_lim[2], grid)
	    acov_grid = rangen(acov_lim[1], acov_lim[2], grid)
	    acor_grid = rangen(acor_lim[1], acor_lim[2], grid)
	
	    mean_ecdf = J(grid, 1, 0)
	    acov_ecdf = J(grid, 1, 0)
	    acor_ecdf = J(grid, 1, 0)
		
		mean_UCI = J(grid, 1, 0)
		acov_UCI = J(grid, 1, 0)
		acor_UCI = J(grid, 1, 0)
	
		mean_LCI = J(grid, 1, 0)
		acov_LCI = J(grid, 1, 0)
		acor_LCI = J(grid, 1, 0)
		
		for (i=1; i<= grid; i++){
		    mean_ecdf[i] = hpjecdfest2(mean_grid[i], mean_est, mean_est1, mean_est2, mean_est3, mean_est4)
			acov_ecdf[i] = hpjecdfest2(acov_grid[i], acov_est, acov_est1, acov_est2, acov_est3, acov_est4)
			acor_ecdf[i] = hpjecdfest2(acor_grid[i], acor_est, acor_est1, acor_est2, acor_est3, acor_est4)
			
			estimate_boot = J(B, 3, 0)
	        for (b = 1; b <= B; b++) {
		        index_boot = rdiscrete(N, 1, J(N, 1, 1/N))
		        estimate_boot[b,1] = hpjecdfest2(mean_grid[i], mean_est[index_boot], mean_est1[index_boot], mean_est2[index_boot], mean_est3[index_boot], mean_est4[index_boot]) - mean_ecdf[i]
			    estimate_boot[b,2] = hpjecdfest2(acov_grid[i], acov_est[index_boot], acov_est1[index_boot], acov_est2[index_boot], acov_est3[index_boot], acov_est4[index_boot]) - acov_ecdf[i]
			    estimate_boot[b,3] = hpjecdfest2(acor_grid[i], acor_est[index_boot], acor_est1[index_boot], acor_est2[index_boot], acor_est3[index_boot], acor_est4[index_boot]) - acor_ecdf[i]
			}
	
			mean_LCI[i] = mean_ecdf[i] + mm_quantile(estimate_boot[, 1], 1, 0.025)
			mean_UCI[i] = mean_ecdf[i] + mm_quantile(estimate_boot[, 1], 1, 0.975)
		
			acov_LCI[i] = acov_ecdf[i] + mm_quantile(estimate_boot[, 2], 1, 0.025)
			acov_UCI[i] = acov_ecdf[i] + mm_quantile(estimate_boot[, 2], 1, 0.975)
		
			acor_LCI[i] = acor_ecdf[i] + mm_quantile(estimate_boot[, 3], 1, 0.025)
			acor_UCI[i] = acor_ecdf[i] + mm_quantile(estimate_boot[, 3], 1, 0.975)
			}
			
		mean_data = sort((mean_ecdf, mean_LCI, mean_UCI), 1)
		acov_data = sort((acov_ecdf, acov_LCI, acov_UCI), 1)
		acor_data = sort((acor_ecdf, acor_LCI, acor_UCI), 1)
		mean_ecdf = mean_data[,1]
		mean_LCI = mean_data[,2]
		mean_UCI = mean_data[,3]
		acov_ecdf = acov_data[,1]
		acov_LCI = acov_data[,2]
		acov_UCI = acov_data[,3]
		acor_ecdf = acor_data[,1]
		acor_LCI = acor_data[,2]
		acor_UCI = acor_data[,3]
	}
	
	temp=st_addvar("double", "mean_ecdf")
    temp=st_addvar("double", "acov_ecdf")
    temp=st_addvar("double", "acor_ecdf")
    temp=st_addvar("double", "mean_grid")
	temp=st_addvar("double", "acov_grid")
	temp=st_addvar("double", "acor_grid")
	
	temp=st_addvar("double", "mean_LCI")
    temp=st_addvar("double", "acov_LCI")
    temp=st_addvar("double", "acor_LCI")
    temp=st_addvar("double", "mean_UCI")
	temp=st_addvar("double", "acov_UCI")
	temp=st_addvar("double", "acor_UCI")
	
    st_addobs(max((0,grid  - st_nobs())))
    st_store(.,"mean_ecdf", mean_ecdf\J(st_nobs()-rows(mean_ecdf),1,.))
    st_store(.,"acov_ecdf", acov_ecdf\J(st_nobs()-rows(acov_ecdf),1,.))
    st_store(.,"acor_ecdf", acor_ecdf\J(st_nobs()-rows(acor_ecdf),1,.))
    st_store(.,"mean_grid", mean_grid\J(st_nobs()-rows(mean_grid),1,.))
	st_store(.,"acov_grid", acov_grid\J(st_nobs()-rows(acov_grid),1,.))
    st_store(.,"acor_grid", acor_grid\J(st_nobs()-rows(acor_grid),1,.))
	
	st_store(.,"mean_LCI", mean_LCI\J(st_nobs()-rows(mean_LCI),1,.))
    st_store(.,"acov_LCI", acov_LCI\J(st_nobs()-rows(acov_LCI),1,.))
    st_store(.,"acor_LCI", acor_LCI\J(st_nobs()-rows(acor_LCI),1,.))
	st_store(.,"mean_UCI", mean_UCI\J(st_nobs()-rows(mean_UCI),1,.))
    st_store(.,"acov_UCI", acov_UCI\J(st_nobs()-rows(acov_UCI),1,.))
    st_store(.,"acor_UCI", acor_UCI\J(st_nobs()-rows(acor_UCI),1,.))
}

// 2.3. Third-Order-Jackknife


/*computing TOJ empirical CDF estimate for T equivalent to 0 modulo 6
	x point at which the empirical CDF is estimated
	X vector of original cross-sectional data
	X21 vector of half-panel cross-sectional data based on time series 1 ~ T/2
	X22 vector of half-panel cross-sectional data based on time series (T/2 + 1) ~ T
	X31 vector of one-third-panel cross-sectional data based on time series 1 ~ T/3
	X32 vector of one-third-panel cross-sectional data based on time series (T/3 + 1) ~ 2 * T/3
	X33 vector of one-third-panel cross-sectional data based on time series 2 * T/3 + 1 ~ T
*/

function tojecdfest0(x, X, X21, X22, X31, X32, X33) {

	// estimates
    est = m_freq(x, X)
    est21 = m_freq(x, X21)
    est22 = m_freq(x, X22)
    est31 = m_freq(x, X31)
    est32 = m_freq(x, X32)
    est33 = m_freq(x, X33)

	// TOJ estimate
    tojest = 3.536 * est - 4.072 * (est21 + est22) / 2 + 1.536 * (est31 + est32 + est33) / 3
	
	// correction to ensure valid estimates
	if (tojest < 0) {
	    tojest = 0
	}
	if (tojest > 1){
	    tojest = 1
	}
  
    return(tojest)
}

/* computing TOJ empirical CDF estimate for T equivalent to 1 modulo 6
	x point at which the empricial CDF is estimated
	X vector of original cross-sectional data
    X21 vector of half-panel cross-sectional data based on time series 1 ~ floor(T/2)
	X22 vector of half-panel cross-sectional data based on time series (floor(T/2) + 1) ~ T
	X23 vector of half-panel cross-sectional data based on time series 1 ~ ceiling(T/2)
	X24 vector of half-panel cross-sectional data based on time series (ceiling(T/2) + 1) ~ T
	X31 vector of one-third-panel cross-sectional data based on time series 1 ~ floor(T/3)
	X32 vector of one-third-panel cross-sectional data based on time series (floor(T/3) + 1) ~ (2 * floor(T/3)) 
	X33 vector of one-third-panel cross-sectional data based on time series (2 * floor(T/3) + 1) ~ T
	X34 vector of one-third-panel cross-sectional data based on time series 1 ~ floor(T/3)
	X35 vector of one-third-panel cross-sectional data based on time series (floor(T/3) + 1) ~ (2 * floor(T/3) + 1)
	X36 vector of one-third-panel cross-sectional data based on time series (2 * floor(T/3) + 2) ~ T
	X37 vector of one-third-panel cross-sectional data based on time series 1 ~ ceiling(T/3)
	X38 vector of one-third-panel cross-sectional data based on time series (ceiling(T/3) + 1) ~ (2 * floor(T/3) + 1)
	X39 vector of one-third-panel cross-sectional data based on time series (2 * floor(T/3) + 2) ~ T
*/
function tojecdfest1(x, X, X21, X22, X23, X24, X31, X32, X33, X34, X35, X36, X37, X38, X39) {

	// estimates
	est = m_freq(x, X)
	est21 = m_freq(x, X21)
    est22 = m_freq(x, X22)
	est23 = m_freq(x, X23)
	est24 = m_freq(x, X24)
	est31 = m_freq(x, X31)
	est32 = m_freq(x, X32)
	est33 = m_freq(x, X33)
	est34 = m_freq(x, X34)
	est35 = m_freq(x, X35)
	est36 = m_freq(x, X36)
	est37 = m_freq(x, X37)
	est38 = m_freq(x, X38)
	est39 = m_freq(x, X39)
	
	// TOJ estimate
	tojest = 3.536 * est - 4.072 * (est21 + est22 + est23 + est24) / 4 + 1.536 * (est31 + est32 + est33 + est34 + est35 + est36 + est37 + est38 + est39) / 9

	// correction to ensure valid estimates
	if (tojest < 0) {
	    tojest = 0
	}
	if (tojest > 1){
	    tojest = 1
	}
	
	return(tojest)
}

/* computing TOJ empirical CDF estimate for T equivalent to 2 modulo 6
	x point at which the empirical CDF is estimated
	X vector of original cross-sectional data
	X21 vector of half-panel cross-sectional data based on time series 1 ~ T/2
	X22 vector of half-panel cross-sectional data based on time series (T/2 + 1) ~ T
	X31 vector of one-third-panel cross-sectional data based on time series 1 ~ floor(T/3)
	X32 vector of one-third-panel cross-sectional data based on time series (floor(T/3) + 1) ~ (2 * floor(T/3) + 1) 
	X33 vector of one-third-panel cross-sectional data based on time series (2 * ceiling(T/3)) ~ T
	X34 vector of one-third-panel cross-sectional data based on time series 1 ~ ceiling(T/3)
	X35 vector of one-third-panel cross-sectional data based on time series (ceiling(T/3) + 1) ~ (2 * floor(T/3) + 1)
	X36 vector of one-third-panel cross-sectional data based on time series (2 * ceiling(T/3)) ~ T
	X37 vector of one-third-panel cross-sectional data based on time series 1 ~ ceiling(T/3)
	X38 vector of one-third-panel cross-sectional data based on time series (ceiling(T/3) + 1) ~ (2 * ceiling(T/3))
	X39 vector of one-third-panel cross-sectional data based on time series (2 * ceiling(T/3) + 1) ~ T
*/

function tojecdfest2(x, X, X21, X22, X31, X32, X33, X34, X35, X36, X37, X38, X39) {

	// estimates
	est = m_freq(x, X)
	est21 = m_freq(x, X21)
    est22 = m_freq(x, X22)
	est31 = m_freq(x, X31)
	est32 = m_freq(x, X32)
	est33 = m_freq(x, X33)
	est34 = m_freq(x, X34)
	est35 = m_freq(x, X35)
	est36 = m_freq(x, X36)
	est37 = m_freq(x, X37)
	est38 = m_freq(x, X38)
	est39 = m_freq(x, X39)
	
	// TOJ estimate
	tojest = 3.536 * est - 4.072 * (est21 + est22) / 2 + 1.536 * (est31 + est32 + est33 + est34 + est35 + est36 + est37 + est38 + est39) / 9

	// correction to ensure valid estimates
	if (tojest < 0) {
	    tojest = 0
	}
	if (tojest > 1){
	    tojest = 1
	}
	
	return(tojest)
}

/* computing TOJ empirical CDF estimate for T equivalent to 3 modulo 6
	x point at which the empirical CDF is estimated
	X vector of original cross-sectional data
	X21 vector of half-panel cross-sectional data based on time series 1 ~ floor(T/2)
	X22 vector of half-panel cross-sectional data based on time series (floor(T/2) + 1) ~ T
	X23 vector of half-panel cross-sectional data based on time series 1 ~ ceiling(T/2)
	X24 vector of half-panel cross-sectional data based on time series (ceiling(T/2) + 1) ~ T
	X31 vector of one-third-panel cross-sectional data based on time series 1 ~ T/3
	X32 vector of one-third-panel cross-sectional data based on time series (T/3 + 1) ~ 2 * T/3
	X33 vector of one-third-panel cross-sectional data based on time series 2 * T/3 + 1 ~ T
*/
function tojecdfest3(x, X, X21, X22, X23, X24, X31, X32, X33) {

	// estimates
	est = m_freq(x, X)
	est21 = m_freq(x, X21)
    est22 = m_freq(x, X22)
	est23 = m_freq(x, X23)
	est24 = m_freq(x, X24)
	est31 = m_freq(x, X31)
	est32 = m_freq(x, X32)
	est33 = m_freq(x, X33)
	
	// TOJ estimate
	tojest = 3.536 * est - 4.072 * (est21 + est22 + est23 + est24) / 4 + 1.536 * (est31 + est32 + est33) / 3

	// correction to ensure valid estimates
	if (tojest < 0) {
	    tojest = 0
	}
	if (tojest > 1){
	    tojest = 1
	}
	
    return(tojest)
}

/* computing TOJ empirical CDF estimate for T equivalent to 4 modulo 6
	x point at which the empirical CDF is estimated
	X vector of original cross-sectional data
	X21 vector of half-panel cross-sectional data based on time series 1 ~ T/2
	X22 vector of half-panel cross-sectional data based on time series (T/2 + 1) ~ T
	X31 vector of one-third-panel cross-sectional data based on time series 1 ~ floor(T/3)
	X32 vector of one-third-panel cross-sectional data based on time series (floor(T/3) + 1) ~ (2 * floor(T/3)) 
	X33 vector of one-third-panel cross-sectional data based on time series (2 * floor(T/3) + 1) ~ T
	X34 vector of one-third-panel cross-sectional data based on time series 1 ~ floor(T/3)
	X35 vector of one-third-panel cross-sectional data based on time series (floor(T/3) + 1) ~ (2 * floor(T/3) + 1)
	X36 vector of one-third-panel cross-sectional data based on time series (2 * floor(T/3) + 2) ~ T
	X37 vector of one-third-panel cross-sectional data based on time series 1 ~ ceiling(T/3)
	X38 vector of one-third-panel cross-sectional data based on time series (ceiling(T/3) + 1) ~ (2 * floor(T/3) + 1)
	X39 vector of one-third-panel cross-sectional data based on time series (2 * floor(T/3) + 2) ~ T
*/
function tojecdfest4(x, X, X21, X22, X31, X32, X33, X34, X35, X36, X37, X38, X39) {

	// estimates
	est = m_freq(x, X)
	est21 = m_freq(x, X21)
    est22 = m_freq(x, X22)
	est31 = m_freq(x, X31)
	est32 = m_freq(x, X32)
	est33 = m_freq(x, X33)
	est34 = m_freq(x, X34)
	est35 = m_freq(x, X35)
	est36 = m_freq(x, X36)
	est37 = m_freq(x, X37)
	est38 = m_freq(x, X38)
	est39 = m_freq(x, X39)
	
	// TOJ estimate
	tojest = 3.536 * est - 4.072 * (est21 + est22) / 2 + 1.536 * (est31 + est32 + est33 + est34 + est35 + est36 + est37 + est38 + est39) / 9

	// correction to ensure valid estimates
	if (tojest < 0) {
	    tojest = 0
	}
	if (tojest > 1){
	    tojest = 1
	}
  
	return(tojest)
}

/* computing TOJ empirical CDF estimate for T equivalent to 5 modulo 6

	x point at which the empirical CDF is estimated
	X vector of original cross-sectional data
	X21 vector of half-panel cross-sectional data based on time series 1 ~ floor(T/2)
	X22 vector of half-panel cross-sectional data based on time series (floor(T/2) + 1) ~ T
	X23 vector of half-panel cross-sectional data based on time series 1 ~ ceiling(T/2)
	X24 vector of half-panel cross-sectional data based on time series (ceiling(T/2) + 1) ~ T
	X31 vector of one-third-panel cross-sectional data based on time series 1 ~ floor(T/3)
	X32 vector of one-third-panel cross-sectional data based on time series (floor(T/3) + 1) ~ (2 * floor(T/3) + 1) 
	X33 vector of one-third-panel cross-sectional data based on time series (2 * ceiling(T/3)) ~ T
	X34 vector of one-third-panel cross-sectional data based on time series 1 ~ ceiling(T/3)
	X35 vector of one-third-panel cross-sectional data based on time series (ceiling(T/3) + 1) ~ (2 * floor(T/3) + 1)
	X36 vector of one-third-panel cross-sectional data based on time series (2 * ceiling(T/3)) ~ T
	X37 vector of one-third-panel cross-sectional data based on time series 1 ~ ceiling(T/3)
	X38 vector of one-third-panel cross-sectional data based on time series (ceiling(T/3) + 1) ~ (2 * ceiling(T/3))
	X39 vector of one-third-panel cross-sectional data based on time series (2 * ceiling(T/3) + 1) ~ T
*/
function tojecdfest5(x, X, X21, X22, X23, X24, X31, X32, X33, X34, X35, X36, X37, X38, X39) {

	// estimates
	est = m_freq(x, X)
	est21 = m_freq(x, X21)
    est22 = m_freq(x, X22)
	est23 = m_freq(x, X23)
	est24 = m_freq(x, X24)
	est31 = m_freq(x, X31)
	est32 = m_freq(x, X32)
	est33 = m_freq(x, X33)
	est34 = m_freq(x, X34)
	est35 = m_freq(x, X35)
	est36 = m_freq(x, X36)
	est37 = m_freq(x, X37)
	est38 = m_freq(x, X38)
	est39 = m_freq(x, X39)
	
	// TOJ estimate
	tojest = 3.536 * est - 4.072 * (est21 + est22 + est23 + est24) / 4 + 1.536 * (est31 + est32 + est33 + est34 + est35 + est36 + est37 + est38 + est39) / 9
	
	// correction to ensure valid estimates
	if (tojest < 0) {
	    tojest = 0
	}
	if (tojest > 1){
	    tojest = 1
	}

	return(tojest)
}


function m_tojecdf(data, acov_order, acor_order, B) {
    N = rows(data)
	S = cols(data)
	grid = 100
	
	mean_est = J(N,1,0)
	acov_est = J(N,1,0)
	acor_est = J(N,1,0)
	
	for (i=1; i<=N; i++){
	    mean_est[i] = mean(data[i,.]')
		acov_est[i] = mataacov(data[i,.], acov_order)
		acor_est[i] = mataacor(data[i,.], acor_order)
	}
	
	if (mod(S,6) == 0) {
	    data21 = data[., 1::(S / 2)]
		data22 = data[., (S / 2 + 1)::S]
		data31 = data[., 1::(S / 3)]
		data32 = data[., (S / 3 + 1)::(2*S / 3)]
		data33 = data[., (2 * S / 3 + 1)::S]
	    
		mean_est21 = J(N,1,0)
		mean_est22 = J(N,1,0)
		mean_est31 = J(N,1,0)
		mean_est32 = J(N,1,0)
		mean_est33 = J(N,1,0)
	
		acov_est21 = J(N,1,0)
		acov_est22 = J(N,1,0)
		acov_est31 = J(N,1,0)
		acov_est32 = J(N,1,0)
		acov_est33 = J(N,1,0)
        
		acor_est21 = J(N,1,0)
		acor_est22 = J(N,1,0)
		acor_est31 = J(N,1,0)
		acor_est32 = J(N,1,0)
		acor_est33 = J(N,1,0)
		
		for (i=1 ; i<=N ; i++){
			mean_est21[i] = mean(data21[i,.]')
			mean_est22[i] = mean(data22[i,.]')
			mean_est31[i] = mean(data31[i,.]')
			mean_est32[i] = mean(data32[i,.]')
			mean_est33[i] = mean(data33[i,.]')
	
			acov_est21[i] = mataacov(data21[i,.], acov_order) 
			acov_est22[i] = mataacov(data22[i,.], acov_order)
			acov_est31[i] = mataacov(data31[i,.], acov_order)
			acov_est32[i] = mataacov(data32[i,.], acov_order)
			acov_est33[i] = mataacov(data33[i,.], acov_order)
		    
			acor_est21[i] = mataacor(data21[i,.], acor_order)
			acor_est22[i] = mataacor(data22[i,.], acor_order)
			acor_est31[i] = mataacor(data31[i,.], acor_order)
			acor_est32[i] = mataacor(data32[i,.], acor_order)
			acor_est33[i] = mataacor(data33[i,.], acor_order)
		}
		
		mean_lim = (min(mean_est), max(mean_est))
        acov_lim = (min(acov_est), max(acov_est))
        acor_lim = (min(acor_est), max(acor_est))
    
	    mean_grid = rangen(mean_lim[1], mean_lim[2], grid)
	    acov_grid = rangen(acov_lim[1], acov_lim[2], grid)
	    acor_grid = rangen(acor_lim[1], acor_lim[2], grid)
	
	    mean_ecdf = J(grid, 1, 0)
	    acov_ecdf = J(grid, 1, 0)
	    acor_ecdf = J(grid, 1, 0)
		
		mean_UCI = J(grid, 1, 0)
		acov_UCI = J(grid, 1, 0)
		acor_UCI = J(grid, 1, 0)
	
		mean_LCI = J(grid, 1, 0)
		acov_LCI = J(grid, 1, 0)
		acor_LCI = J(grid, 1, 0)
		
		for (i = 1; i <= grid; i++) {
			mean_ecdf[i] = tojecdfest0(mean_grid[i], mean_est, mean_est21, mean_est22, mean_est31, mean_est32, mean_est33)
			acov_ecdf[i] = tojecdfest0(acov_grid[i], acov_est, acov_est21, acov_est22, acov_est31, acov_est32, acov_est33)
			acor_ecdf[i] = tojecdfest0(acor_grid[i], acor_est, acor_est21, acor_est22, acor_est31, acor_est32, acor_est33)
			
			estimate_boot = J(B, 3, 0)
	        for (b = 1; b <= B; b++) {
		        index_boot = rdiscrete(N, 1, J(N, 1, 1/N))
		        estimate_boot[b,1] = tojecdfest0(mean_grid[i], mean_est[index_boot], mean_est21[index_boot], mean_est22[index_boot], mean_est31[index_boot], mean_est32[index_boot], mean_est33[index_boot]) - mean_ecdf[i]
			    estimate_boot[b,2] = tojecdfest0(acov_grid[i], acov_est[index_boot], acov_est21[index_boot], acov_est22[index_boot], acov_est31[index_boot], acov_est32[index_boot], acov_est33[index_boot]) - acov_ecdf[i]
			    estimate_boot[b,3] = tojecdfest0(acor_grid[i], acor_est[index_boot], acor_est21[index_boot], acor_est22[index_boot], acor_est31[index_boot], acor_est32[index_boot], acor_est33[index_boot]) - acor_ecdf[i]
				}
	
			mean_LCI[i] = mean_ecdf[i] + mm_quantile(estimate_boot[, 1], 1, 0.025)
			mean_UCI[i] = mean_ecdf[i] + mm_quantile(estimate_boot[, 1], 1, 0.975)
		
			acov_LCI[i] = acov_ecdf[i] + mm_quantile(estimate_boot[, 2], 1, 0.025)
			acov_UCI[i] = acov_ecdf[i] + mm_quantile(estimate_boot[, 2], 1, 0.975)
		
			acor_LCI[i] = acor_ecdf[i] + mm_quantile(estimate_boot[, 3], 1, 0.025)
			acor_UCI[i] = acor_ecdf[i] + mm_quantile(estimate_boot[, 3], 1, 0.975)
			}
			
		mean_data = sort((mean_ecdf, mean_LCI, mean_UCI), 1)
		acov_data = sort((acov_ecdf, acov_LCI, acov_UCI), 1)
		acor_data = sort((acor_ecdf, acor_LCI, acor_UCI), 1)
		
		mean_ecdf = mean_data[,1]
		mean_LCI = mean_data[,2]
		mean_UCI = mean_data[,3]
		
		acov_ecdf = acov_data[,1]
		acov_LCI = acov_data[,2]
		acov_UCI = acov_data[,3]
		
		acor_ecdf = acor_data[,1]
		acor_LCI = acor_data[,2]
		acor_UCI = acor_data[,3]
		
	} else if (mod(S,6)==1){

    // split  panel data for T equivalent to 1 modulo 6
		data21 = data[., 1::floor(S / 2)]
		data22 = data[., (floor(S / 2) + 1)::S]
		data23 = data[., 1::ceil(S / 2)]
		data24 = data[., (ceil(S / 2) + 1)::S]
		data31 = data[., 1::floor(S / 3)]
		data32 = data[., (floor(S / 3) + 1)::(2 * floor(S / 3))]
		data33 = data[., (2 * floor(S / 3) + 1)::S]
		data34 = data[., 1::floor(S / 3)]
		data35 = data[., (floor(S / 3) + 1)::(2 * floor(S / 3) + 1)]
		data36 = data[., (2 * floor(S / 3) + 2)::S]
		data37 = data[., 1::ceil(S / 3)]
		data38 = data[., (ceil(S / 3) + 1)::(2 * floor(S / 3) + 1)]
		data39 = data[., (2 * floor(S / 3) + 2)::S]

     // estimated quantities for split panel data
		mean_est21 = J(N,1,0)
		mean_est22 = J(N,1,0)
		mean_est23 = J(N,1,0)
		mean_est24 = J(N,1,0)
		mean_est31 = J(N,1,0)
		mean_est32 = J(N,1,0)
		mean_est33 = J(N,1,0)
		mean_est34 = J(N,1,0)
		mean_est35 = J(N,1,0)
		mean_est36 = J(N,1,0)
		mean_est37 = J(N,1,0)
		mean_est38 = J(N,1,0)
		mean_est39 = J(N,1,0)
    
        acov_est21 = J(N,1,0)
		acov_est22 = J(N,1,0)
		acov_est23 = J(N,1,0)
		acov_est24 = J(N,1,0)
		acov_est31 = J(N,1,0)
		acov_est32 = J(N,1,0)
		acov_est33 = J(N,1,0)
		acov_est34 = J(N,1,0)
		acov_est35 = J(N,1,0)
		acov_est36 = J(N,1,0)
		acov_est37 = J(N,1,0)
		acov_est38 = J(N,1,0)
		acov_est39 = J(N,1,0)
		
	    acor_est21 = J(N,1,0)
		acor_est22 = J(N,1,0)
		acor_est23 = J(N,1,0)
		acor_est24 = J(N,1,0)
		acor_est31 = J(N,1,0)
		acor_est32 = J(N,1,0)
		acor_est33 = J(N,1,0)
		acor_est34 = J(N,1,0)
		acor_est35 = J(N,1,0)
		acor_est36 = J(N,1,0)
		acor_est37 = J(N,1,0)
		acor_est38 = J(N,1,0)
		acor_est39 = J(N,1,0)

        for (i=1 ; i<=N ; i++){
			mean_est21[i] = mean(data21[i,.]')
			mean_est22[i] = mean(data22[i,.]')
			mean_est23[i] = mean(data23[i,.]')
			mean_est24[i] = mean(data24[i,.]')
			mean_est31[i] = mean(data31[i,.]')
			mean_est32[i] = mean(data32[i,.]')
			mean_est33[i] = mean(data33[i,.]')
		    mean_est34[i] = mean(data34[i,.]')
			mean_est35[i] = mean(data35[i,.]')
			mean_est36[i] = mean(data36[i,.]')
		    mean_est37[i] = mean(data37[i,.]')
			mean_est38[i] = mean(data38[i,.]')
			mean_est39[i] = mean(data39[i,.]')
		
			acov_est21[i] = mataacov(data21[i,.], acov_order) 
			acov_est22[i] = mataacov(data22[i,.], acov_order)
			acov_est23[i] = mataacov(data23[i,.], acov_order) 
			acov_est24[i] = mataacov(data24[i,.], acov_order)
			acov_est31[i] = mataacov(data31[i,.], acov_order)
			acov_est32[i] = mataacov(data32[i,.], acov_order)
			acov_est33[i] = mataacov(data33[i,.], acov_order)
			acov_est34[i] = mataacov(data34[i,.], acov_order)
            acov_est35[i] = mataacov(data35[i,.], acov_order)
			acov_est36[i] = mataacov(data36[i,.], acov_order)
			acov_est37[i] = mataacov(data37[i,.], acov_order)
            acov_est38[i] = mataacov(data38[i,.], acov_order)
			acov_est39[i] = mataacov(data39[i,.], acov_order)
                
			acor_est21[i] = mataacor(data21[i,.], acor_order)
			acor_est22[i] = mataacor(data22[i,.], acor_order)
			acor_est23[i] = mataacor(data23[i,.], acor_order)
			acor_est24[i] = mataacor(data24[i,.], acor_order)
			acor_est31[i] = mataacor(data31[i,.], acor_order)
			acor_est32[i] = mataacor(data32[i,.], acor_order)
			acor_est33[i] = mataacor(data33[i,.], acor_order)
			acor_est34[i] = mataacor(data34[i,.], acor_order)
			acor_est35[i] = mataacor(data35[i,.], acor_order)
			acor_est36[i] = mataacor(data36[i,.], acor_order)
			acor_est37[i] = mataacor(data37[i,.], acor_order)
			acor_est38[i] = mataacor(data38[i,.], acor_order)
			acor_est39[i] = mataacor(data39[i,.], acor_order)	
		}
		
		mean_lim = (min(mean_est), max(mean_est))
        acov_lim = (min(acov_est), max(acov_est))
        acor_lim = (min(acor_est), max(acor_est))
    
	    mean_grid = rangen(mean_lim[1], mean_lim[2], grid)
	    acov_grid = rangen(acov_lim[1], acov_lim[2], grid)
	    acor_grid = rangen(acor_lim[1], acor_lim[2], grid)
	
	    mean_ecdf = J(grid, 1, 0)
	    acov_ecdf = J(grid, 1, 0)
	    acor_ecdf = J(grid, 1, 0)
		   
		mean_UCI = J(grid, 1, 0)
		acov_UCI = J(grid, 1, 0)
		acor_UCI = J(grid, 1, 0)
	
		mean_LCI = J(grid, 1, 0)
		acov_LCI = J(grid, 1, 0)
		acor_LCI = J(grid, 1, 0)
		
		for (i = 1; i <= grid; i++) {
			mean_ecdf[i] = tojecdfest1(mean_grid[i], mean_est, mean_est21, mean_est22, mean_est23, mean_est24, mean_est31, mean_est32, mean_est33, mean_est34, mean_est35, mean_est36, mean_est37, mean_est38, mean_est39)
			acov_ecdf[i] = tojecdfest1(acov_grid[i], acov_est, acov_est21, acov_est22, acov_est23, acov_est24, acov_est31, acov_est32, acov_est33, acov_est34, acov_est35, acov_est36, acov_est37, acov_est38, acov_est39)
			acor_ecdf[i] = tojecdfest1(acor_grid[i], acor_est, acor_est21, acor_est22, acor_est23, acor_est24, acor_est31, acor_est32, acor_est33, acor_est34, acor_est35, acor_est36, acor_est37, acor_est38, acor_est39)
		
			estimate_boot = J(B, 3, 0)
			
	        for (b = 1; b <= B; b++) {
		        index_boot = rdiscrete(N, 1, J(N, 1, 1/N))
		        estimate_boot[b,1] = tojecdfest1(mean_grid[i], mean_est[index_boot], mean_est21[index_boot], mean_est22[index_boot], mean_est23[index_boot], mean_est24[index_boot], mean_est31[index_boot], mean_est32[index_boot], mean_est33[index_boot], mean_est34[index_boot], mean_est35[index_boot], mean_est36[index_boot], mean_est37[index_boot], mean_est38[index_boot], mean_est39[index_boot]) - mean_ecdf[i]
			    estimate_boot[b,2] = tojecdfest1(acov_grid[i], acov_est[index_boot], acov_est21[index_boot], acov_est22[index_boot], acov_est23[index_boot], acov_est24[index_boot], acov_est31[index_boot], acov_est32[index_boot], acov_est33[index_boot], acov_est34[index_boot], acov_est35[index_boot], acov_est36[index_boot], acov_est37[index_boot], acov_est38[index_boot], acov_est39[index_boot]) - acov_ecdf[i]
			    estimate_boot[b,3] = tojecdfest1(acor_grid[i], acor_est[index_boot], acor_est21[index_boot], acor_est22[index_boot], acor_est23[index_boot], acor_est24[index_boot], acor_est31[index_boot], acor_est32[index_boot], acor_est33[index_boot], acor_est34[index_boot], acor_est35[index_boot], acor_est36[index_boot], acor_est37[index_boot], acor_est38[index_boot], acor_est39[index_boot]) - acor_ecdf[i]
				}
	
			mean_LCI[i] = mean_ecdf[i] + mm_quantile(estimate_boot[, 1], 1, 0.025)
			mean_UCI[i] = mean_ecdf[i] + mm_quantile(estimate_boot[, 1], 1, 0.975)
		
			acov_LCI[i] = acov_ecdf[i] + mm_quantile(estimate_boot[, 2], 1, 0.025)
			acov_UCI[i] = acov_ecdf[i] + mm_quantile(estimate_boot[, 2], 1, 0.975)
		
			acor_LCI[i] = acor_ecdf[i] + mm_quantile(estimate_boot[, 3], 1, 0.025)
			acor_UCI[i] = acor_ecdf[i] + mm_quantile(estimate_boot[, 3], 1, 0.975)
			}
			
		mean_data = sort((mean_ecdf, mean_LCI, mean_UCI), 1)
		acov_data = sort((acov_ecdf, acov_LCI, acov_UCI), 1)
		acor_data = sort((acor_ecdf, acor_LCI, acor_UCI), 1)
		
		mean_ecdf = mean_data[,1]
		mean_LCI = mean_data[,2]
		mean_UCI = mean_data[,3]
		
		acov_ecdf = acov_data[,1]
		acov_LCI = acov_data[,2]
		acov_UCI = acov_data[,3]
		
		acor_ecdf = acor_data[,1]
		acor_LCI = acor_data[,2]
		acor_UCI = acor_data[,3]
		
	} else if (mod(S,6)==2){
    
    // split  panel data for T equivalent to 2 modulo 6
		data21 = data[., 1::(S / 2)]
		data22 = data[., (S / 2 + 1)::S]
		data31 = data[., 1::floor(S / 3)]
		data32 = data[., (floor(S / 3) + 1)::(2 * floor(S / 3) + 1) ]
		data33 = data[., (2 * ceil(S / 3))::S]
		data34 = data[., 1::ceil(S / 3)]
		data35 = data[., (ceil(S / 3) + 1)::(2 * floor(S / 3) + 1)]
		data36 = data[., (2 * ceil(S / 3))::S]
		data37 = data[., 1::ceil(S / 3)]
		data38 = data[., (ceil(S / 3) + 1)::(2 * ceil(S / 3))]
		data39 = data[., (2 * ceil(S / 3) + 1)::S]

    // estimated quantities for split panel data
		mean_est21 = J(N,1,0)
		mean_est22 = J(N,1,0)
		mean_est31 = J(N,1,0)
		mean_est32 = J(N,1,0)
		mean_est33 = J(N,1,0)
		mean_est34 = J(N,1,0)
		mean_est35 = J(N,1,0)
		mean_est36 = J(N,1,0)
		mean_est37 = J(N,1,0)
		mean_est38 = J(N,1,0)
		mean_est39 = J(N,1,0)
    
        acov_est21 = J(N,1,0)
		acov_est22 = J(N,1,0)
		acov_est31 = J(N,1,0)
		acov_est32 = J(N,1,0)
		acov_est33 = J(N,1,0)
		acov_est34 = J(N,1,0)
		acov_est35 = J(N,1,0)
		acov_est36 = J(N,1,0)
		acov_est37 = J(N,1,0)
		acov_est38 = J(N,1,0)
		acov_est39 = J(N,1,0)
		
	    acor_est21 = J(N,1,0)
		acor_est22 = J(N,1,0)
		acor_est31 = J(N,1,0)
		acor_est32 = J(N,1,0)
		acor_est33 = J(N,1,0)
		acor_est34 = J(N,1,0)
		acor_est35 = J(N,1,0)
		acor_est36 = J(N,1,0)
		acor_est37 = J(N,1,0)
		acor_est38 = J(N,1,0)
		acor_est39 = J(N,1,0)

        for (i=1 ; i<=N ; i++){
			mean_est21[i] = mean(data21[i,.]')
			mean_est22[i] = mean(data22[i,.]')
			mean_est31[i] = mean(data31[i,.]')
			mean_est32[i] = mean(data32[i,.]')
			mean_est33[i] = mean(data33[i,.]')
		    mean_est34[i] = mean(data34[i,.]')
			mean_est35[i] = mean(data35[i,.]')
			mean_est36[i] = mean(data36[i,.]')
		    mean_est37[i] = mean(data37[i,.]')
			mean_est38[i] = mean(data38[i,.]')
			mean_est39[i] = mean(data39[i,.]')
		
			acov_est21[i] = mataacov(data21[i,.], acov_order) 
			acov_est22[i] = mataacov(data22[i,.], acov_order)
			acov_est31[i] = mataacov(data31[i,.], acov_order)
			acov_est32[i] = mataacov(data32[i,.], acov_order)
			acov_est33[i] = mataacov(data33[i,.], acov_order)
			acov_est34[i] = mataacov(data34[i,.], acov_order)
            acov_est35[i] = mataacov(data35[i,.], acov_order)
			acov_est36[i] = mataacov(data36[i,.], acov_order)
			acov_est37[i] = mataacov(data37[i,.], acov_order)
            acov_est38[i] = mataacov(data38[i,.], acov_order)
			acov_est39[i] = mataacov(data39[i,.], acov_order)
                
			acor_est21[i] = mataacor(data21[i,.], acor_order)
			acor_est22[i] = mataacor(data22[i,.], acor_order)
			acor_est31[i] = mataacor(data31[i,.], acor_order)
			acor_est32[i] = mataacor(data32[i,.], acor_order)
			acor_est33[i] = mataacor(data33[i,.], acor_order)
			acor_est34[i] = mataacor(data34[i,.], acor_order)
			acor_est35[i] = mataacor(data35[i,.], acor_order)
			acor_est36[i] = mataacor(data36[i,.], acor_order)
			acor_est37[i] = mataacor(data37[i,.], acor_order)
			acor_est38[i] = mataacor(data38[i,.], acor_order)
			acor_est39[i] = mataacor(data39[i,.], acor_order)	
		}
		
		
		mean_lim = (min(mean_est), max(mean_est))
        acov_lim = (min(acov_est), max(acov_est))
        acor_lim = (min(acor_est), max(acor_est))
    
	    mean_grid = rangen(mean_lim[1], mean_lim[2], grid)
	    acov_grid = rangen(acov_lim[1], acov_lim[2], grid)
	    acor_grid = rangen(acor_lim[1], acor_lim[2], grid)
	
	    mean_ecdf = J(grid, 1, 0)
	    acov_ecdf = J(grid, 1, 0)
	    acor_ecdf = J(grid, 1, 0)
		   
		mean_UCI = J(grid, 1, 0)
		acov_UCI = J(grid, 1, 0)
		acor_UCI = J(grid, 1, 0)
	
		mean_LCI = J(grid, 1, 0)
		acov_LCI = J(grid, 1, 0)
		acor_LCI = J(grid, 1, 0)
		
		for (i = 1; i <= grid; i++) {
			mean_ecdf[i] = tojecdfest2(mean_grid[i], mean_est, mean_est21, mean_est22, mean_est31, mean_est32, mean_est33, mean_est34, mean_est35, mean_est36, mean_est37, mean_est38, mean_est39)
			acov_ecdf[i] = tojecdfest2(acov_grid[i], acov_est, acov_est21, acov_est22, acov_est31, acov_est32, acov_est33, acov_est34, acov_est35, acov_est36, acov_est37, acov_est38, acov_est39)
			acor_ecdf[i] = tojecdfest2(acor_grid[i], acor_est, acor_est21, acor_est22, acor_est31, acor_est32, acor_est33, acor_est34, acor_est35, acor_est36, acor_est37, acor_est38, acor_est39)
		
			estimate_boot = J(B, 3, 0)
			
	        for (b = 1; b <= B; b++) {
		        index_boot = rdiscrete(N, 1, J(N, 1, 1/N))
		        estimate_boot[b,1] = tojecdfest2(mean_grid[i], mean_est[index_boot], mean_est21[index_boot], mean_est22[index_boot], mean_est31[index_boot], mean_est32[index_boot], mean_est33[index_boot], mean_est34[index_boot], mean_est35[index_boot], mean_est36[index_boot], mean_est37[index_boot], mean_est38[index_boot], mean_est39[index_boot]) - mean_ecdf[i]
			    estimate_boot[b,2] = tojecdfest2(acov_grid[i], acov_est[index_boot], acov_est21[index_boot], acov_est22[index_boot], acov_est31[index_boot], acov_est32[index_boot], acov_est33[index_boot], acov_est34[index_boot], acov_est35[index_boot], acov_est36[index_boot], acov_est37[index_boot], acov_est38[index_boot], acov_est39[index_boot]) - acov_ecdf[i]
			    estimate_boot[b,3] = tojecdfest2(acor_grid[i], acor_est[index_boot], acor_est21[index_boot], acor_est22[index_boot], acor_est31[index_boot], acor_est32[index_boot], acor_est33[index_boot], acor_est34[index_boot], acor_est35[index_boot], acor_est36[index_boot], acor_est37[index_boot], acor_est38[index_boot], acor_est39[index_boot]) - acor_ecdf[i]
				}
	
			mean_LCI[i] = mean_ecdf[i] + mm_quantile(estimate_boot[, 1], 1, 0.025)
			mean_UCI[i] = mean_ecdf[i] + mm_quantile(estimate_boot[, 1], 1, 0.975)
		
			acov_LCI[i] = acov_ecdf[i] + mm_quantile(estimate_boot[, 2], 1, 0.025)
			acov_UCI[i] = acov_ecdf[i] + mm_quantile(estimate_boot[, 2], 1, 0.975)
		
			acor_LCI[i] = acor_ecdf[i] + mm_quantile(estimate_boot[, 3], 1, 0.025)
			acor_UCI[i] = acor_ecdf[i] + mm_quantile(estimate_boot[, 3], 1, 0.975)
			}
			
		mean_data = sort((mean_ecdf, mean_LCI, mean_UCI), 1)
		acov_data = sort((acov_ecdf, acov_LCI, acov_UCI), 1)
		acor_data = sort((acor_ecdf, acor_LCI, acor_UCI), 1)
		
		mean_ecdf = mean_data[,1]
		mean_LCI = mean_data[,2]
		mean_UCI = mean_data[,3]
		
		acov_ecdf = acov_data[,1]
		acov_LCI = acov_data[,2]
		acov_UCI = acov_data[,3]
		
		acor_ecdf = acor_data[,1]
		acor_LCI = acor_data[,2]
		acor_UCI = acor_data[,3]
		
	} else if (mod(S,6) == 3) {
    
		// split  panel data for T equivalent to 3 modulo 6
		data21 = data[., 1::floor(S / 2)]
		data22 = data[., (floor(S / 2) + 1)::S]
		data23 = data[., 1::ceil(S / 2)]
		data24 = data[., (ceil(S / 2) + 1)::S]
		data31 = data[., 1::(S / 3)]
		data32 = data[., (S / 3 + 1)::(2*S / 3)]
		data33 = data[., (2 * S / 3 + 1)::S]

		// estimated quantities for split panel data
		mean_est21 = J(N,1,0)
		mean_est22 = J(N,1,0)
		mean_est23 = J(N,1,0)
		mean_est24 = J(N,1,0)
		mean_est31 = J(N,1,0)
		mean_est32 = J(N,1,0)
		mean_est33 = J(N,1,0)
    
        acov_est21 = J(N,1,0)
		acov_est22 = J(N,1,0)
		acov_est23 = J(N,1,0)
		acov_est24 = J(N,1,0)
		acov_est31 = J(N,1,0)
		acov_est32 = J(N,1,0)
		acov_est33 = J(N,1,0)
		
	    acor_est21 = J(N,1,0)
		acor_est22 = J(N,1,0)
		acor_est23 = J(N,1,0)
		acor_est24 = J(N,1,0)
		acor_est31 = J(N,1,0)
		acor_est32 = J(N,1,0)
		acor_est33 = J(N,1,0)

        for (i=1 ; i<=N ; i++){
			mean_est21[i] = mean(data21[i,.]')
			mean_est22[i] = mean(data22[i,.]')
			mean_est23[i] = mean(data23[i,.]')
			mean_est24[i] = mean(data24[i,.]')
			mean_est31[i] = mean(data31[i,.]')
			mean_est32[i] = mean(data32[i,.]')
			mean_est33[i] = mean(data33[i,.]')
		
			acov_est21[i] = mataacov(data21[i,.], acov_order) 
			acov_est22[i] = mataacov(data22[i,.], acov_order)
			acov_est23[i] = mataacov(data23[i,.], acov_order) 
			acov_est24[i] = mataacov(data24[i,.], acov_order)
			acov_est31[i] = mataacov(data31[i,.], acov_order)
			acov_est32[i] = mataacov(data32[i,.], acov_order)
			acov_est33[i] = mataacov(data33[i,.], acov_order)
                
			acor_est21[i] = mataacor(data21[i,.], acor_order)
			acor_est22[i] = mataacor(data22[i,.], acor_order)
			acor_est23[i] = mataacor(data23[i,.], acor_order)
			acor_est24[i] = mataacor(data24[i,.], acor_order)
			acor_est31[i] = mataacor(data31[i,.], acor_order)
			acor_est32[i] = mataacor(data32[i,.], acor_order)
			acor_est33[i] = mataacor(data33[i,.], acor_order)	
		}
		
		mean_lim = (min(mean_est), max(mean_est))
        acov_lim = (min(acov_est), max(acov_est))
        acor_lim = (min(acor_est), max(acor_est))
    
	    mean_grid = rangen(mean_lim[1], mean_lim[2], grid)
	    acov_grid = rangen(acov_lim[1], acov_lim[2], grid)
	    acor_grid = rangen(acor_lim[1], acor_lim[2], grid)
	
	    mean_ecdf = J(grid, 1, 0)
	    acov_ecdf = J(grid, 1, 0)
	    acor_ecdf = J(grid, 1, 0)
		   
		mean_UCI = J(grid, 1, 0)
		acov_UCI = J(grid, 1, 0)
		acor_UCI = J(grid, 1, 0)
	
		mean_LCI = J(grid, 1, 0)
		acov_LCI = J(grid, 1, 0)
		acor_LCI = J(grid, 1, 0)
		
		for (i = 1; i <= grid; i++) {
			mean_ecdf[i] = tojecdfest3(mean_grid[i], mean_est, mean_est21, mean_est22, mean_est23, mean_est24, mean_est31, mean_est32, mean_est33)
			acov_ecdf[i] = tojecdfest3(acov_grid[i], acov_est, acov_est21, acov_est22, acov_est23, acov_est24, acov_est31, acov_est32, acov_est33)
			acor_ecdf[i] = tojecdfest3(acor_grid[i], acor_est, acor_est21, acor_est22, acor_est23, acor_est24, acor_est31, acor_est32, acor_est33)
		
			estimate_boot = J(B, 3, 0)
			
	        for (b = 1; b <= B; b++) {
		        index_boot = rdiscrete(N, 1, J(N, 1, 1/N))
		        estimate_boot[b,1] = tojecdfest3(mean_grid[i], mean_est[index_boot], mean_est21[index_boot], mean_est22[index_boot], mean_est23[index_boot], mean_est24[index_boot], mean_est31[index_boot], mean_est32[index_boot], mean_est33[index_boot]) - mean_ecdf[i]
			    estimate_boot[b,2] = tojecdfest3(acov_grid[i], acov_est[index_boot], acov_est21[index_boot], acov_est22[index_boot], acov_est23[index_boot], acov_est24[index_boot], acov_est31[index_boot], acov_est32[index_boot], acov_est33[index_boot]) - acov_ecdf[i]
			    estimate_boot[b,3] = tojecdfest3(acor_grid[i], acor_est[index_boot], acor_est21[index_boot], acor_est22[index_boot], acor_est23[index_boot], acor_est24[index_boot], acor_est31[index_boot], acor_est32[index_boot], acor_est33[index_boot]) - acor_ecdf[i]
				}
	
			mean_LCI[i] = mean_ecdf[i] + mm_quantile(estimate_boot[, 1], 1, 0.025)
			mean_UCI[i] = mean_ecdf[i] + mm_quantile(estimate_boot[, 1], 1, 0.975)
		
			acov_LCI[i] = acov_ecdf[i] + mm_quantile(estimate_boot[, 2], 1, 0.025)
			acov_UCI[i] = acov_ecdf[i] + mm_quantile(estimate_boot[, 2], 1, 0.975)
		
			acor_LCI[i] = acor_ecdf[i] + mm_quantile(estimate_boot[, 3], 1, 0.025)
			acor_UCI[i] = acor_ecdf[i] + mm_quantile(estimate_boot[, 3], 1, 0.975)
			}
			
		mean_data = sort((mean_ecdf, mean_LCI, mean_UCI), 1)
		acov_data = sort((acov_ecdf, acov_LCI, acov_UCI), 1)
		acor_data = sort((acor_ecdf, acor_LCI, acor_UCI), 1)
		
		mean_ecdf = mean_data[,1]
		mean_LCI = mean_data[,2]
		mean_UCI = mean_data[,3]
		
		acov_ecdf = acov_data[,1]
		acov_LCI = acov_data[,2]
		acov_UCI = acov_data[,3]
		
		acor_ecdf = acor_data[,1]
		acor_LCI = acor_data[,2]
		acor_UCI = acor_data[,3]

	} else if (mod(S,6)==4) {

    // split  panel data for T equivalent to 4 modulo 6
		data21 = data[., 1::(S / 2)]
		data22 = data[., (S / 2 + 1)::S]
		data31 = data[., 1::floor(S / 3)]
		data32 = data[., (floor(S / 3) + 1)::(2 * floor(S / 3))]
		data33 = data[., (2 * floor(S / 3) + 1)::S]
		data34 = data[., 1::floor(S / 3)]
		data35 = data[., (floor(S / 3) + 1)::(2 * floor(S / 3) + 1)]
		data36 = data[., (2 * floor(S / 3) + 2)::S]
		data37 = data[., 1::ceil(S / 3)]
		data38 = data[., (ceil(S / 3) + 1)::(2 * floor(S / 3) + 1)]
		data39 = data[., (2 * floor(S / 3) + 2)::S]

        // estimated quantities for split panel data
		mean_est21 = J(N,1,0)
		mean_est22 = J(N,1,0)
		mean_est31 = J(N,1,0)
		mean_est32 = J(N,1,0)
		mean_est33 = J(N,1,0)
		mean_est34 = J(N,1,0)
		mean_est35 = J(N,1,0)
		mean_est36 = J(N,1,0)
		mean_est37 = J(N,1,0)
		mean_est38 = J(N,1,0)
		mean_est39 = J(N,1,0)
    
        acov_est21 = J(N,1,0)
		acov_est22 = J(N,1,0)
		acov_est31 = J(N,1,0)
		acov_est32 = J(N,1,0)
		acov_est33 = J(N,1,0)
		acov_est34 = J(N,1,0)
		acov_est35 = J(N,1,0)
		acov_est36 = J(N,1,0)
		acov_est37 = J(N,1,0)
		acov_est38 = J(N,1,0)
		acov_est39 = J(N,1,0)
		
	    acor_est21 = J(N,1,0)
		acor_est22 = J(N,1,0)
		acor_est31 = J(N,1,0)
		acor_est32 = J(N,1,0)
		acor_est33 = J(N,1,0)
		acor_est34 = J(N,1,0)
		acor_est35 = J(N,1,0)
		acor_est36 = J(N,1,0)
		acor_est37 = J(N,1,0)
		acor_est38 = J(N,1,0)
		acor_est39 = J(N,1,0)

        for (i=1 ; i<=N ; i++){
			mean_est21[i] = mean(data21[i,.]')
			mean_est22[i] = mean(data22[i,.]')
			mean_est31[i] = mean(data31[i,.]')
			mean_est32[i] = mean(data32[i,.]')
			mean_est33[i] = mean(data33[i,.]')
		    mean_est34[i] = mean(data34[i,.]')
			mean_est35[i] = mean(data35[i,.]')
			mean_est36[i] = mean(data36[i,.]')
		    mean_est37[i] = mean(data37[i,.]')
			mean_est38[i] = mean(data38[i,.]')
			mean_est39[i] = mean(data39[i,.]')
		
			acov_est21[i] = mataacov(data21[i,.], acov_order) 
			acov_est22[i] = mataacov(data22[i,.], acov_order)
			acov_est31[i] = mataacov(data31[i,.], acov_order)
			acov_est32[i] = mataacov(data32[i,.], acov_order)
			acov_est33[i] = mataacov(data33[i,.], acov_order)
			acov_est34[i] = mataacov(data34[i,.], acov_order)
            acov_est35[i] = mataacov(data35[i,.], acov_order)
			acov_est36[i] = mataacov(data36[i,.], acov_order)
			acov_est37[i] = mataacov(data37[i,.], acov_order)
            acov_est38[i] = mataacov(data38[i,.], acov_order)
			acov_est39[i] = mataacov(data39[i,.], acov_order)
                
			acor_est21[i] = mataacor(data21[i,.], acor_order)
			acor_est22[i] = mataacor(data22[i,.], acor_order)
			acor_est31[i] = mataacor(data31[i,.], acor_order)
			acor_est32[i] = mataacor(data32[i,.], acor_order)
			acor_est33[i] = mataacor(data33[i,.], acor_order)
			acor_est34[i] = mataacor(data34[i,.], acor_order)
			acor_est35[i] = mataacor(data35[i,.], acor_order)
			acor_est36[i] = mataacor(data36[i,.], acor_order)
			acor_est37[i] = mataacor(data37[i,.], acor_order)
			acor_est38[i] = mataacor(data38[i,.], acor_order)
			acor_est39[i] = mataacor(data39[i,.], acor_order)	
		}
		
		mean_lim = (min(mean_est), max(mean_est))
        acov_lim = (min(acov_est), max(acov_est))
        acor_lim = (min(acor_est), max(acor_est))
    
	    mean_grid = rangen(mean_lim[1], mean_lim[2], grid)
	    acov_grid = rangen(acov_lim[1], acov_lim[2], grid)
	    acor_grid = rangen(acor_lim[1], acor_lim[2], grid)
	
	    mean_ecdf = J(grid, 1, 0)
	    acov_ecdf = J(grid, 1, 0)
	    acor_ecdf = J(grid, 1, 0)
		
		mean_UCI = J(grid, 1, 0)
		acov_UCI = J(grid, 1, 0)
		acor_UCI = J(grid, 1, 0)
	
		mean_LCI = J(grid, 1, 0)
		acov_LCI = J(grid, 1, 0)
		acor_LCI = J(grid, 1, 0)
		
		for (i = 1; i <= grid; i++) {
			mean_ecdf[i] = tojecdfest4(mean_grid[i], mean_est, mean_est21, mean_est22, mean_est31, mean_est32, mean_est33, mean_est34, mean_est35, mean_est36, mean_est37, mean_est38, mean_est39)
			acov_ecdf[i] = tojecdfest4(acov_grid[i], acov_est, acov_est21, acov_est22, acov_est31, acov_est32, acov_est33, acov_est34, acov_est35, acov_est36, acov_est37, acov_est38, acov_est39)
			acor_ecdf[i] = tojecdfest4(acor_grid[i], acor_est, acor_est21, acor_est22, acor_est31, acor_est32, acor_est33, acor_est34, acor_est35, acor_est36, acor_est37, acor_est38, acor_est39)
		
			estimate_boot = J(B, 3, 0)
			
	        for (b = 1; b <= B; b++) {
		        index_boot = rdiscrete(N, 1, J(N, 1, 1/N))
		        estimate_boot[b,1] = tojecdfest4(mean_grid[i], mean_est[index_boot], mean_est21[index_boot], mean_est22[index_boot], mean_est31[index_boot], mean_est32[index_boot], mean_est33[index_boot], mean_est34[index_boot], mean_est35[index_boot], mean_est36[index_boot], mean_est37[index_boot], mean_est38[index_boot], mean_est39[index_boot]) - mean_ecdf[i]
			    estimate_boot[b,2] = tojecdfest4(acov_grid[i], acov_est[index_boot], acov_est21[index_boot], acov_est22[index_boot], acov_est31[index_boot], acov_est32[index_boot], acov_est33[index_boot], acov_est34[index_boot], acov_est35[index_boot], acov_est36[index_boot], acov_est37[index_boot], acov_est38[index_boot], acov_est39[index_boot]) - acov_ecdf[i]
			    estimate_boot[b,3] = tojecdfest4(acor_grid[i], acor_est[index_boot], acor_est21[index_boot], acor_est22[index_boot], acor_est31[index_boot], acor_est32[index_boot], acor_est33[index_boot], acor_est34[index_boot], acor_est35[index_boot], acor_est36[index_boot], acor_est37[index_boot], acor_est38[index_boot], acor_est39[index_boot]) - acor_ecdf[i]
				}
	
			mean_LCI[i] = mean_ecdf[i] + mm_quantile(estimate_boot[, 1], 1, 0.025)
			mean_UCI[i] = mean_ecdf[i] + mm_quantile(estimate_boot[, 1], 1, 0.975)
		
			acov_LCI[i] = acov_ecdf[i] + mm_quantile(estimate_boot[, 2], 1, 0.025)
			acov_UCI[i] = acov_ecdf[i] + mm_quantile(estimate_boot[, 2], 1, 0.975)
		
			acor_LCI[i] = acor_ecdf[i] + mm_quantile(estimate_boot[, 3], 1, 0.025)
			acor_UCI[i] = acor_ecdf[i] + mm_quantile(estimate_boot[, 3], 1, 0.975)
			}
			
		mean_data = sort((mean_ecdf, mean_LCI, mean_UCI), 1)
		acov_data = sort((acov_ecdf, acov_LCI, acov_UCI), 1)
		acor_data = sort((acor_ecdf, acor_LCI, acor_UCI), 1)
		
		mean_ecdf = mean_data[,1]
		mean_LCI = mean_data[,2]
		mean_UCI = mean_data[,3]
		
		acov_ecdf = acov_data[,1]
		acov_LCI = acov_data[,2]
		acov_UCI = acov_data[,3]
		
		acor_ecdf = acor_data[,1]
		acor_LCI = acor_data[,2]
		acor_UCI = acor_data[,3]
		
	} else {

		// split  panel data for T equivalent to 5 modulo 6
		data21 = data[., 1::floor(S / 2)]
		data22 = data[., (floor(S / 2) + 1)::S]
		data23 = data[., 1::ceil(S / 2)]
		data24 = data[., (ceil(S / 2) + 1)::S]
		data31 = data[., 1::floor(S / 3)]
		data32 = data[., (floor(S / 3) + 1)::(2 * floor(S / 3) + 1) ]
		data33 = data[., (2 * ceil(S / 3))::S]
		data34 = data[., 1::ceil(S / 3)]
		data35 = data[., (ceil(S / 3) + 1)::(2 * floor(S / 3) + 1)]
		data36 = data[., (2 * ceil(S / 3))::S]
		data37 = data[., 1::ceil(S / 3)]
		data38 = data[., (ceil(S / 3) + 1)::(2 * ceil(S / 3))]
		data39 = data[., (2 * ceil(S / 3) + 1)::S]
        
		// estimated quantities for split panel data
		mean_est21 = J(N,1,0)
		mean_est22 = J(N,1,0)
		mean_est23 = J(N,1,0)
		mean_est24 = J(N,1,0)
		mean_est31 = J(N,1,0)
		mean_est32 = J(N,1,0)
		mean_est33 = J(N,1,0)
		mean_est34 = J(N,1,0)
		mean_est35 = J(N,1,0)
		mean_est36 = J(N,1,0)
		mean_est37 = J(N,1,0)
		mean_est38 = J(N,1,0)
		mean_est39 = J(N,1,0)
    
        acov_est21 = J(N,1,0)
		acov_est22 = J(N,1,0)
		acov_est23 = J(N,1,0)
		acov_est24 = J(N,1,0)
		acov_est31 = J(N,1,0)
		acov_est32 = J(N,1,0)
		acov_est33 = J(N,1,0)
		acov_est34 = J(N,1,0)
		acov_est35 = J(N,1,0)
		acov_est36 = J(N,1,0)
		acov_est37 = J(N,1,0)
		acov_est38 = J(N,1,0)
		acov_est39 = J(N,1,0)
		
	    acor_est21 = J(N,1,0)
		acor_est22 = J(N,1,0)
		acor_est23 = J(N,1,0)
		acor_est24 = J(N,1,0)
		acor_est31 = J(N,1,0)
		acor_est32 = J(N,1,0)
		acor_est33 = J(N,1,0)
		acor_est34 = J(N,1,0)
		acor_est35 = J(N,1,0)
		acor_est36 = J(N,1,0)
		acor_est37 = J(N,1,0)
		acor_est38 = J(N,1,0)
		acor_est39 = J(N,1,0)

        for (i=1 ; i<=N ; i++){
			mean_est21[i] = mean(data21[i,.]')
			mean_est22[i] = mean(data22[i,.]')
			mean_est23[i] = mean(data23[i,.]')
			mean_est24[i] = mean(data24[i,.]')
			mean_est31[i] = mean(data31[i,.]')
			mean_est32[i] = mean(data32[i,.]')
			mean_est33[i] = mean(data33[i,.]')
		    mean_est34[i] = mean(data34[i,.]')
			mean_est35[i] = mean(data35[i,.]')
			mean_est36[i] = mean(data36[i,.]')
		    mean_est37[i] = mean(data37[i,.]')
			mean_est38[i] = mean(data38[i,.]')
			mean_est39[i] = mean(data39[i,.]')
		
			acov_est21[i] = mataacov(data21[i,.], acov_order) 
			acov_est22[i] = mataacov(data22[i,.], acov_order)
			acov_est23[i] = mataacov(data23[i,.], acov_order) 
			acov_est24[i] = mataacov(data24[i,.], acov_order)
			acov_est31[i] = mataacov(data31[i,.], acov_order)
			acov_est32[i] = mataacov(data32[i,.], acov_order)
			acov_est33[i] = mataacov(data33[i,.], acov_order)
			acov_est34[i] = mataacov(data34[i,.], acov_order)
            acov_est35[i] = mataacov(data35[i,.], acov_order)
			acov_est36[i] = mataacov(data36[i,.], acov_order)
			acov_est37[i] = mataacov(data37[i,.], acov_order)
            acov_est38[i] = mataacov(data38[i,.], acov_order)
			acov_est39[i] = mataacov(data39[i,.], acov_order)
                
			acor_est21[i] = mataacor(data21[i,.], acor_order)
			acor_est22[i] = mataacor(data22[i,.], acor_order)
			acor_est23[i] = mataacor(data23[i,.], acor_order)
			acor_est24[i] = mataacor(data24[i,.], acor_order)
			acor_est31[i] = mataacor(data31[i,.], acor_order)
			acor_est32[i] = mataacor(data32[i,.], acor_order)
			acor_est33[i] = mataacor(data33[i,.], acor_order)
			acor_est34[i] = mataacor(data34[i,.], acor_order)
			acor_est35[i] = mataacor(data35[i,.], acor_order)
			acor_est36[i] = mataacor(data36[i,.], acor_order)
			acor_est37[i] = mataacor(data37[i,.], acor_order)
			acor_est38[i] = mataacor(data38[i,.], acor_order)
			acor_est39[i] = mataacor(data39[i,.], acor_order)	
		}
		
		mean_lim = (min(mean_est), max(mean_est))
        acov_lim = (min(acov_est), max(acov_est))
        acor_lim = (min(acor_est), max(acor_est))
    
	    mean_grid = rangen(mean_lim[1], mean_lim[2], grid)
	    acov_grid = rangen(acov_lim[1], acov_lim[2], grid)
	    acor_grid = rangen(acor_lim[1], acor_lim[2], grid)
	
	    mean_ecdf = J(grid, 1, 0)
	    acov_ecdf = J(grid, 1, 0)
	    acor_ecdf = J(grid, 1, 0)
		
		mean_UCI = J(grid, 1, 0)
		acov_UCI = J(grid, 1, 0)
		acor_UCI = J(grid, 1, 0)
	
		mean_LCI = J(grid, 1, 0)
		acov_LCI = J(grid, 1, 0)
		acor_LCI = J(grid, 1, 0)
		
		for (i = 1; i <= grid; i++) {
			mean_ecdf[i] = tojecdfest5(mean_grid[i], mean_est, mean_est21, mean_est22, mean_est23, mean_est24, mean_est31, mean_est32, mean_est33, mean_est34, mean_est35, mean_est36, mean_est37, mean_est38, mean_est39)
			acov_ecdf[i] = tojecdfest5(acov_grid[i], acov_est, acov_est21, acov_est22, acov_est23, acov_est24, acov_est31, acov_est32, acov_est33, acov_est34, acov_est35, acov_est36, acov_est37, acov_est38, acov_est39)
			acor_ecdf[i] = tojecdfest5(acor_grid[i], acor_est, acor_est21, acor_est22, acor_est23, acor_est24, acor_est31, acor_est32, acor_est33, acor_est34, acor_est35, acor_est36, acor_est37, acor_est38, acor_est39)
		
			estimate_boot = J(B, 3, 0)
			
	        for (b = 1; b <= B; b++) {
		        index_boot = rdiscrete(N, 1, J(N, 1, 1/N))
		        estimate_boot[b,1] = tojecdfest5(mean_grid[i], mean_est[index_boot], mean_est21[index_boot], mean_est22[index_boot], mean_est23[index_boot], mean_est24[index_boot], mean_est31[index_boot], mean_est32[index_boot], mean_est33[index_boot], mean_est34[index_boot], mean_est35[index_boot], mean_est36[index_boot], mean_est37[index_boot], mean_est38[index_boot], mean_est39[index_boot]) - mean_ecdf[i]
			    estimate_boot[b,2] = tojecdfest5(acov_grid[i], acov_est[index_boot], acov_est21[index_boot], acov_est22[index_boot], acov_est23[index_boot], acov_est24[index_boot], acov_est31[index_boot], acov_est32[index_boot], acov_est33[index_boot], acov_est34[index_boot], acov_est35[index_boot], acov_est36[index_boot], acov_est37[index_boot], acov_est38[index_boot], acov_est39[index_boot]) - acov_ecdf[i]
			    estimate_boot[b,3] = tojecdfest5(acor_grid[i], acor_est[index_boot], acor_est21[index_boot], acor_est22[index_boot], acor_est23[index_boot], acor_est24[index_boot], acor_est31[index_boot], acor_est32[index_boot], acor_est33[index_boot], acor_est34[index_boot], acor_est35[index_boot], acor_est36[index_boot], acor_est37[index_boot], acor_est38[index_boot], acor_est39[index_boot]) - acor_ecdf[i]
				}
	
			mean_LCI[i] = mean_ecdf[i] + mm_quantile(estimate_boot[, 1], 1, 0.025)
			mean_UCI[i] = mean_ecdf[i] + mm_quantile(estimate_boot[, 1], 1, 0.975)
		
			acov_LCI[i] = acov_ecdf[i] + mm_quantile(estimate_boot[, 2], 1, 0.025)
			acov_UCI[i] = acov_ecdf[i] + mm_quantile(estimate_boot[, 2], 1, 0.975)
		
			acor_LCI[i] = acor_ecdf[i] + mm_quantile(estimate_boot[, 3], 1, 0.025)
			acor_UCI[i] = acor_ecdf[i] + mm_quantile(estimate_boot[, 3], 1, 0.975)
			}
			
		mean_data = sort((mean_ecdf, mean_LCI, mean_UCI), 1)
		acov_data = sort((acov_ecdf, acov_LCI, acov_UCI), 1)
		acor_data = sort((acor_ecdf, acor_LCI, acor_UCI), 1)
		
		mean_ecdf = mean_data[,1]
		mean_LCI = mean_data[,2]
		mean_UCI = mean_data[,3]
		
		acov_ecdf = acov_data[,1]
		acov_LCI = acov_data[,2]
		acov_UCI = acov_data[,3]
		
		acor_ecdf = acor_data[,1]
		acor_LCI = acor_data[,2]
		acor_UCI = acor_data[,3]
	}
	
	temp=st_addvar("double", "mean_ecdf")
    temp=st_addvar("double", "acov_ecdf")
    temp=st_addvar("double", "acor_ecdf")
    temp=st_addvar("double", "mean_grid")
	temp=st_addvar("double", "acov_grid")
	temp=st_addvar("double", "acor_grid")
	
	temp=st_addvar("double", "mean_LCI")
    temp=st_addvar("double", "acov_LCI")
    temp=st_addvar("double", "acor_LCI")
    temp=st_addvar("double", "mean_UCI")
	temp=st_addvar("double", "acov_UCI")
	temp=st_addvar("double", "acor_UCI")
	
    st_addobs(max((0,grid  - st_nobs())))
    st_store(.,"mean_ecdf", mean_ecdf\J(st_nobs()-rows(mean_ecdf),1,.))
    st_store(.,"acov_ecdf", acov_ecdf\J(st_nobs()-rows(acov_ecdf),1,.))
    st_store(.,"acor_ecdf", acor_ecdf\J(st_nobs()-rows(acor_ecdf),1,.))
    st_store(.,"mean_grid", mean_grid\J(st_nobs()-rows(mean_grid),1,.))
	st_store(.,"acov_grid", acov_grid\J(st_nobs()-rows(acov_grid),1,.))
    st_store(.,"acor_grid", acor_grid\J(st_nobs()-rows(acor_grid),1,.))
	
	st_store(.,"mean_LCI", mean_LCI\J(st_nobs()-rows(mean_LCI),1,.))
    st_store(.,"acov_LCI", acov_LCI\J(st_nobs()-rows(acov_LCI),1,.))
    st_store(.,"acor_LCI", acor_LCI\J(st_nobs()-rows(acor_LCI),1,.))
	st_store(.,"mean_UCI", mean_UCI\J(st_nobs()-rows(mean_UCI),1,.))
    st_store(.,"acov_UCI", acov_UCI\J(st_nobs()-rows(acov_UCI),1,.))
    st_store(.,"acor_UCI", acor_UCI\J(st_nobs()-rows(acor_UCI),1,.))
}


///  3. Moment Estimation

// 3.1. Naive Estimation

function momentest (quantity, indices) {
	mean_est = quantity[indices, 1]
	acov_est = quantity[indices, 2]
	acor_est = quantity[indices, 3]
	
	mean_mean = sum(mean_est) / length(mean_est)
	acov_mean = sum(acov_est) / length(acov_est)
	acor_mean = sum(acor_est) / length(acor_est)
	
	mean_var = variance(mean_est)
	acov_var = variance(acov_est)
	acor_var = variance(acor_est)
	
	mean_acov_cor = correlation((mean_est, acov_est))[2,1]
	mean_acor_cor = correlation((mean_est, acor_est))[2,1]
	acov_acor_cor = correlation((acov_est, acor_est))[2,1]
	
	estimate = (mean_mean, acov_mean, acor_mean, mean_var, acov_var, acor_var, mean_acov_cor, mean_acor_cor, acov_acor_cor)
	
	return(estimate)
}

function m_nemoment (data, acov_order, acor_order, B) {
	N = rows(data)
	S = cols(data)
	level = 0.95
	mean_est = J(N, 1, 0)
	acov_est = J(N, 1, 0)
	acor_est = J(N, 1, 0)
	
	for (i = 1; i <= N; i++) {
	    mean_est[i] = mean(data[i,.]')
		acov_est[i] = mataacov(data[i,.], acov_order)
		acor_est[i] = mataacor(data[i,.], acor_order)
	}
	equantity = (mean_est, acov_est, acor_est)
	
	estimate_value = momentest(equantity, 1::N)
	number_par = length(estimate_value)
	estimate_boot = J(B, number_par, 0)
	for (b = 1; b <= B; b++) {
		index_boot = rdiscrete(N, 1, J(N, 1, 1/N))
		estimate_boot[b,.] = momentest(equantity, index_boot)
	}
	
	se = sqrt(diagonal(variance(estimate_boot)))
	quantile_boot_1 = mm_quantile(estimate_boot, 1, 0.975)
	quantile_boot_2 = mm_quantile(estimate_boot, 1, 0.025)
	ci_1 = 2 * estimate_value - quantile_boot_1
	ci_2 = 2 * estimate_value - quantile_boot_2
	ci = (ci_1 \ ci_2)
	result =  (estimate_value', se, ci')
	
	st_matrix("est", estimate_value')
	st_matrix("se", se)
	st_matrix("ci", ci')
	
	printf("\n")
    printf("Estimates for Moments.\n")
    printf("Parameters                                              Estimate          \n")
    printf("________________________________________________________________ \n")
    printf("Mean of Mean                                            %f\n",estimate_value[1])
	printf("Mean of Autocovariance                                  %f\n",estimate_value[2])
	printf("Mean of Autocorrelation                                 %f\n",estimate_value[3])
	printf("Variance of Mean                                        %f\n",estimate_value[4])
	printf("Variance of Autocovariance                              %f\n",estimate_value[5])
	printf("Variance of Autocorrelation                             %f\n",estimate_value[6])
	printf("Correlation between Mean and Autocovariance             %f\n",estimate_value[7])
	printf("Correlation between Mean and Autocorrelation            %f\n",estimate_value[8])
	printf("Correlation between Autocovariance and Autocorelation   %f\n",estimate_value[9])
	
	printf("\n")
    printf("%f %% Confidence Intervals for Moments.\n", level*100)
    printf("Parameters                                              Low                   High\n")
    printf("__________________________________________________________________________________\n")
    printf("Mean of Mean                                            %f        %f\n",ci_1[1],ci_2[1])
	printf("Mean of Autocovariance                                  %f        %f\n",ci_1[2],ci_2[2])
	printf("Mean of Autocorrelation                                 %f        %f\n",ci_1[3],ci_2[3])
	printf("Variance of Mean                                        %f        %f\n",ci_1[4],ci_2[4])
	printf("Variance of Autocovariance                              %f        %f\n",ci_1[5],ci_2[5])
	printf("Variance of Autocorrelation                             %f        %f\n",ci_1[6],ci_2[6])
	printf("Correlation between Mean and Autocovariance             %f        %f\n",ci_1[7],ci_2[7])
	printf("Correlation between Mean and Autocorrelation            %f        %f\n",ci_1[8],ci_2[8])
	printf("Correlation between Autocovariance and Autocorelation   %f        %f\n",ci_1[9],ci_2[9])
	
	printf("\n")
    printf("Standard Errors for Moments.\n")
    printf("Parameters                                              Stanadard Errors          \n")
    printf("________________________________________________________________________\n")
    printf("Mean of Mean                                            %f\n",se[1])
	printf("Mean of Autocovariance                                  %f\n",se[2])
	printf("Mean of Autocorrelation                                 %f\n",se[3])
	printf("Variance of Mean                                        %f\n",se[4])
	printf("Variance of Autocovariance                              %f\n",se[5])
	printf("Variance of Autocorrelation                             %f\n",se[6])
	printf("Correlation between Mean and Autocovariance             %f\n",se[7])
	printf("Correlation between Mean and Autocorrelation            %f\n",se[8])
	printf("Correlation between Autocovariance and Autocorelation   %f\n",se[9])
	
}

// 3.2. Half-Panel-Jackknife Moment Estimation

function hpjmomentest1(quantity, indices){
	mean_est = quantity[indices, 1]
	mean_est1 = quantity[indices, 2]
	mean_est2 = quantity[indices, 3]
	
	acov_est = quantity[indices, 4]
	acov_est1 = quantity[indices, 5]
	acov_est2 = quantity[indices, 6]
	
	acor_est = quantity[indices, 7]
	acor_est1 = quantity[indices, 8]
	acor_est2 = quantity[indices, 9]
	
	mean_mean = sum(mean_est) / length(mean_est)
	mean_mean1 = sum(mean_est1) / length(mean_est1)
	mean_mean2 = sum(mean_est2) / length(mean_est2)

	acov_mean = sum(acov_est) / length(acov_est)
	acov_mean1 = sum(acov_est1) / length(acov_est1)
	acov_mean2 = sum(acov_est2) / length(acov_est2)

	acor_mean = sum(acor_est) / length(acor_est)
	acor_mean1 = sum(acor_est1) / length(acor_est1)
	acor_mean2 = sum(acor_est2) / length(acor_est2)
	
	mean_var = variance(mean_est)
	mean_var1 = variance(mean_est1)
	mean_var2 = variance(mean_est2)
	
	acov_var = variance(acov_est)
	acov_var1 = variance(acov_est1)
	acov_var2 = variance(acov_est2)
	
	acor_var = variance(acor_est)
	acor_var1 = variance(acor_est1)
	acor_var2 = variance(acor_est2)
	
	mean_acov_cor = correlation((mean_est, acov_est))[2,1]
	mean_acov_cor1 = correlation((mean_est1, acov_est1))[2,1]
	mean_acov_cor2 = correlation((mean_est2, acov_est2))[2,1]
	
	mean_acor_cor = correlation((mean_est, acor_est))[2,1]
	mean_acor_cor1 = correlation((mean_est1, acor_est1))[2,1]
	mean_acor_cor2 = correlation((mean_est2, acor_est2))[2,1]
	
	acov_acor_cor = correlation((acov_est, acor_est))[2,1]
	acov_acor_cor1 = correlation((acov_est1, acor_est1))[2,1]
	acov_acor_cor2 = correlation((acov_est2, acor_est2))[2,1]
	
	estimate_1 = (mean_mean, acov_mean, acor_mean, mean_var, acov_var, acor_var, mean_acov_cor, mean_acor_cor, acov_acor_cor)
	estimate_2 = (mean_mean1, acov_mean1, acor_mean1, mean_var1, acov_var1, acor_var1, mean_acov_cor1, mean_acor_cor1, acov_acor_cor1)
	estimate_3 = (mean_mean2, acov_mean2, acor_mean2, mean_var2, acov_var2, acor_var2, mean_acov_cor2, mean_acor_cor2, acov_acor_cor2)

	hpjestimate = 2 * estimate_1 - (estimate_2 + estimate_3) / 2
	return(hpjestimate)
}

function hpjmomentest2(quantity, indices){
	mean_est = quantity[indices, 1]
	mean_est1 = quantity[indices, 2]
	mean_est2 = quantity[indices, 3]
	mean_est3 = quantity[indices, 4]
	mean_est4 = quantity[indices, 5]
	
	acov_est = quantity[indices, 6]
	acov_est1 = quantity[indices, 7]
	acov_est2 = quantity[indices, 8]
	acov_est3 = quantity[indices, 9]
	acov_est4 = quantity[indices, 10]
	
	acor_est = quantity[indices, 11]
	acor_est1 = quantity[indices, 12]
	acor_est2 = quantity[indices, 13]
	acor_est3 = quantity[indices, 14]
	acor_est4 = quantity[indices, 15]
	
	mean_mean = sum(mean_est)/length(mean_est)
	mean_mean1 = sum(mean_est1)/length(mean_est1)
	mean_mean2 = sum(mean_est2)/length(mean_est2)
	mean_mean3 = sum(mean_est3)/length(mean_est3)
	mean_mean4 = sum(mean_est4)/length(mean_est4)

	acov_mean = sum(acov_est)/length(acov_est)
	acov_mean1 = sum(acov_est1)/length(acov_est1)
	acov_mean2 = sum(acov_est2)/length(acov_est2)
	acov_mean3 = sum(acov_est3)/length(acov_est3)
	acov_mean4 = sum(acov_est4)/length(acov_est4)

	acor_mean = sum(acor_est)/length(acor_est)
	acor_mean1 = sum(acor_est1)/length(acor_est1)
	acor_mean2 = sum(acor_est2)/length(acor_est2)
	acor_mean3 = sum(acor_est3)/length(acor_est3)
	acor_mean4 = sum(acor_est4)/length(acor_est4)
	
	mean_var = variance(mean_est)
	mean_var1 = variance(mean_est1)
	mean_var2 = variance(mean_est2)
	mean_var3 = variance(mean_est3)
	mean_var4 = variance(mean_est4)
	
	acov_var = variance(acov_est)
	acov_var1 = variance(acov_est1)
	acov_var2 = variance(acov_est2)
	acov_var3 = variance(acov_est3)
	acov_var4 = variance(acov_est4)
	
	acor_var = variance(acor_est)
	acor_var1 = variance(acor_est1)
	acor_var2 = variance(acor_est2)
	acor_var3 = variance(acor_est3)
	acor_var4 = variance(acor_est4)
	
	mean_acov_cor = correlation((mean_est, acov_est))[2,1]
	mean_acov_cor1 = correlation((mean_est1, acov_est1))[2,1]
	mean_acov_cor2 = correlation((mean_est2, acov_est2))[2,1]
	mean_acov_cor3 = correlation((mean_est3, acov_est3))[2,1]
	mean_acov_cor4 = correlation((mean_est4, acov_est4))[2,1]
	
	mean_acor_cor = correlation((mean_est, acor_est))[2,1]
	mean_acor_cor1 = correlation((mean_est1, acor_est1))[2,1]
	mean_acor_cor2 = correlation((mean_est2, acor_est2))[2,1]
	mean_acor_cor3 = correlation((mean_est3, acor_est3))[2,1]
	mean_acor_cor4 = correlation((mean_est4, acor_est4))[2,1]
	
	acov_acor_cor = correlation((acov_est, acor_est))[2,1]
	acov_acor_cor1 = correlation((acov_est1, acor_est1))[2,1]
	acov_acor_cor2 = correlation((acov_est2, acor_est2))[2,1]
	acov_acor_cor3 = correlation((acov_est3, acor_est3))[2,1]
	acov_acor_cor4 = correlation((acov_est4, acor_est4))[2,1]
	
	estimate_1 = (mean_mean, acov_mean, acor_mean, mean_var, acov_var, acor_var, mean_acov_cor, mean_acor_cor, acov_acor_cor)
	estimate_2 = (mean_mean1, acov_mean1, acor_mean1, mean_var1, acov_var1, acor_var1, mean_acov_cor1, mean_acor_cor1, acov_acor_cor1)
	estimate_3 = (mean_mean2, acov_mean2, acor_mean2, mean_var2, acov_var2, acor_var2, mean_acov_cor2, mean_acor_cor2, acov_acor_cor2)
	estimate_4 = (mean_mean3, acov_mean3, acor_mean3, mean_var3, acov_var3, acor_var3, mean_acov_cor3, mean_acor_cor3, acov_acor_cor3)
	estimate_5 = (mean_mean4, acov_mean4, acor_mean4, mean_var4, acov_var4, acor_var4, mean_acov_cor4, mean_acor_cor4, acov_acor_cor4)

	hpjestimate = 2 * estimate_1 - (estimate_2 + estimate_3 + estimate_4 + estimate_5) / 4
	return(hpjestimate)
}

function m_hpjmoment(data, acov_order, acor_order, B){
	N = rows(data)
	S = cols(data)
	level = 0.95
	
    if (mod(S,2)==0) {
	    mean_est = J(N, 1, 0)
	    acov_est = J(N, 1, 0)
	    acor_est = J(N, 1, 0)
	
	    data1 = data[,1::(S/2)]
	    data2 = data[,(S/2+1)::S]
		
	    mean_est1 = J(N, 1, 0)
	    mean_est2 = J(N, 1, 0)
		
	    acov_est1 = J(N, 1, 0)
	    acor_est1 = J(N, 1, 0)
	    
		acov_est2 = J(N, 1, 0)
	    acor_est2 = J(N, 1, 0)
		
		for(i=1; i<=N ;i++){
		    mean_est[i] = mean(data[i,.]')
			acov_est[i] = mataacov(data[i,.], acov_order)
			acor_est[i] = mataacor(data[i,.], acor_order)
			
		    mean_est1[i] = mean(data1[i,.]')
			acov_est1[i] = mataacov(data1[i,.], acov_order)
			acor_est1[i] = mataacor(data1[i,.], acor_order)
			
			mean_est2[i] = mean(data2[i,.]')
			acov_est2[i] = mataacov(data2[i,.], acov_order)
			acor_est2[i] = mataacor(data2[i,.], acor_order)
		}
		equantity2 = (mean_est, mean_est1, mean_est2, acov_est, acov_est1, acov_est2, acor_est, acor_est1, acor_est2)
		estimate_value = hpjmomentest1(equantity2, 1::N)
	
		number_par = length(estimate_value)
		estimate_boot = J(B, number_par, 0)
		
		for (b = 1; b <= B; b++) {
			index_boot = rdiscrete(N, 1, J(N, 1, 1/N))
			estimate_boot[b,] = hpjmomentest1(equantity2, index_boot)
		}
		
		se = sqrt(diagonal(variance(estimate_boot)))
		quantile_boot_1 = mm_quantile(estimate_boot, 1, 0.975)
		quantile_boot_2 = mm_quantile(estimate_boot, 1, 0.025)	
		ci_1 = 2 * estimate_value - quantile_boot_1
		ci_2 = 2 * estimate_value - quantile_boot_2
		ci = (ci_1 \ ci_2)
		result =  (estimate_value', se, ci')
	}
		
	else{
	    mean_est = J(N, 1, 0)
	    acov_est = J(N, 1, 0)
	    acor_est = J(N, 1, 0)
		
		data1 = data[., 1::floor(S/2)]
		data2 = data[., (floor(S/2)+1)::S]
		data3 = data[.,1::(floor(S/2)+1)]
		data4 = data[.,(floor(S/2)+2)::S]
		
		mean_est1 = J(N, 1, 0)
		mean_est2 = J(N, 1, 0)
		mean_est3 = J(N, 1, 0)
		mean_est4 = J(N, 1, 0)
		
		acov_est1 = J(N, 1, 0)
		acov_est2 = J(N, 1, 0)
		acov_est3 = J(N, 1, 0)
		acov_est4 = J(N, 1, 0)
		
		acor_est1 = J(N, 1, 0)
		acor_est2 = J(N, 1, 0)
		acor_est3 = J(N, 1, 0)
		acor_est4 = J(N, 1, 0)
		
		for(i=1; i<=N; i++){
		    mean_est[i] = mean(data[i,.]')
			mean_est1[i] = mean(data1[i,.]')
			mean_est2[i] = mean(data2[i,.]')
			mean_est3[i] = mean(data3[i,.]')
			mean_est4[i] = mean(data4[i,.]')
			
			acov_est[i] = mataacov(data[i,.], acov_order)
			acov_est1[i] = mataacov(data1[i,.], acov_order)
			acov_est2[i] = mataacov(data2[i,.], acov_order)
			acov_est3[i] = mataacov(data3[i,.], acov_order)
			acov_est4[i] = mataacov(data4[i,.], acov_order)
	
			acor_est[i] = mataacor(data[i,.], acor_order)
			acor_est1[i] = mataacor(data1[i,.], acor_order)
			acor_est2[i] = mataacor(data2[i,.], acor_order)
			acor_est3[i] = mataacor(data3[i,.], acor_order)
			acor_est4[i] = mataacor(data4[i,.], acor_order)
		} 
		
		equantity3 = (mean_est,mean_est1,mean_est2,mean_est3,mean_est4, ///
		              acov_est,acov_est1,acov_est2,acov_est3,acov_est4, ///
				      acor_est,acor_est1,acor_est2,acor_est3,acor_est4)
	
		estimate_value = hpjmomentest2(equantity3, 1::N)
	
		number_par = length(estimate_value)
		estimate_boot = J(B, number_par, 0)
		for (b = 1; b <= B; b++) {
			index_boot = rdiscrete(N, 1, J(N, 1, 1/N))
			estimate_boot[b,.] = hpjmomentest2(equantity3, index_boot)
		}
		se = sqrt(diagonal(variance(estimate_boot)))
		quantile_boot_1 = mm_quantile(estimate_boot, 1, 0.975)
		quantile_boot_2 = mm_quantile(estimate_boot, 1, 0.025)
		ci_1 = 2 * estimate_value - quantile_boot_1
		ci_2 = 2 * estimate_value - quantile_boot_2
		ci = (ci_1 \ ci_2)
	    result =  (estimate_value', se, ci')
	}
	
	st_matrix("est", estimate_value')
	st_matrix("se", se)
	st_matrix("ci", ci')
	
	printf("\n")
    printf("Estimates for Moments.\n")
    printf("Parameters                                              Estimate          \n")
    printf("________________________________________________________________ \n")
    printf("Mean of Mean                                            %f\n",estimate_value[1])
	printf("Mean of Autocovariance                                  %f\n",estimate_value[2])
	printf("Mean of Autocorrelation                                 %f\n",estimate_value[3])
	printf("Variance of Mean                                        %f\n",estimate_value[4])
	printf("Variance of Autocovariance                              %f\n",estimate_value[5])
	printf("Variance of Autocorrelation                             %f\n",estimate_value[6])
	printf("Correlation between Mean and Autocovariance             %f\n",estimate_value[7])
	printf("Correlation between Mean and Autocorrelation            %f\n",estimate_value[8])
	printf("Correlation between Autocovariance and Autocorelation   %f\n",estimate_value[9])
	
	printf("\n")
    printf("%f %% Confidence Intervals for Moments.\n", level*100)
    printf("Parameters                                              Low                   High\n")
    printf("__________________________________________________________________________________\n")
    printf("Mean of Mean                                            %f        %f\n",ci_1[1],ci_2[1])
	printf("Mean of Autocovariance                                  %f        %f\n",ci_1[2],ci_2[2])
	printf("Mean of Autocorrelation                                 %f        %f\n",ci_1[3],ci_2[3])
	printf("Variance of Mean                                        %f        %f\n",ci_1[4],ci_2[4])
	printf("Variance of Autocovariance                              %f        %f\n",ci_1[5],ci_2[5])
	printf("Variance of Autocorrelation                             %f        %f\n",ci_1[6],ci_2[6])
	printf("Correlation between Mean and Autocovariance             %f        %f\n",ci_1[7],ci_2[7])
	printf("Correlation between Mean and Autocorrelation            %f        %f\n",ci_1[8],ci_2[8])
	printf("Correlation between Autocovariance and Autocorelation   %f        %f\n",ci_1[9],ci_2[9])
	
	printf("\n")
    printf("Standard Errors for Moments.\n")
    printf("Parameters                                              Stanadard Errors          \n")
    printf("________________________________________________________________________\n")
    printf("Mean of Mean                                            %f\n",se[1])
	printf("Mean of Autocovariance                                  %f\n",se[2])
	printf("Mean of Autocorrelation                                 %f\n",se[3])
	printf("Variance of Mean                                        %f\n",se[4])
	printf("Variance of Autocovariance                              %f\n",se[5])
	printf("Variance of Autocorrelation                             %f\n",se[6])
	printf("Correlation between Mean and Autocovariance             %f\n",se[7])
	printf("Correlation between Mean and Autocorrelation            %f\n",se[8])
	printf("Correlation between Autocovariance and Autocorelation   %f\n",se[9])
}

// 3.3. Third-Order-Jackknife Moment Estimation


function tojmomentest0(quantity, indices){
	mean_est = quantity[indices, 1]
	mean_est21 = quantity[indices, 2]
	mean_est22 = quantity[indices, 3]
	mean_est31 = quantity[indices, 4]
	mean_est32 = quantity[indices, 5]
	mean_est33 = quantity[indices, 6]
	
	acov_est = quantity[indices, 7]
	acov_est21 = quantity[indices, 8]
	acov_est22 = quantity[indices, 9]
	acov_est31 = quantity[indices, 10]
	acov_est32 = quantity[indices, 11]
	acov_est33 = quantity[indices, 12]
	
	acor_est = quantity[indices, 13]
	acor_est21 = quantity[indices, 14]
	acor_est22 = quantity[indices, 15]
	acor_est31 = quantity[indices, 16]
	acor_est32 = quantity[indices, 17]
	acor_est33 = quantity[indices, 18]
	
	mean_mean = sum(mean_est) / length(mean_est)
	mean_mean21 = sum(mean_est21) / length(mean_est21)
	mean_mean22 = sum(mean_est22) / length(mean_est22)
	mean_mean31 = sum(mean_est31) / length(mean_est31)
	mean_mean32 = sum(mean_est32) / length(mean_est32)
	mean_mean33 = sum(mean_est33) / length(mean_est33)
	
	acov_mean = sum(acov_est) / length(acov_est)
	acov_mean21 = sum(acov_est21) / length(acov_est21)
	acov_mean22 = sum(acov_est22) / length(acov_est22)
	acov_mean31 = sum(acov_est31) / length(acov_est31)
	acov_mean32 = sum(acov_est32) / length(acov_est32)
	acov_mean33 = sum(acov_est33) / length(acov_est33)
	
	acor_mean = sum(acor_est) / length(acor_est)
	acor_mean21 = sum(acor_est21) / length(acor_est21)
	acor_mean22 = sum(acor_est22) / length(acor_est22)
	acor_mean31 = sum(acor_est31) / length(acor_est31)
	acor_mean32 = sum(acor_est32) / length(acor_est32)
	acor_mean33 = sum(acor_est33) / length(acor_est33)

	mean_var = variance(mean_est)
	mean_var21 = variance(mean_est21)
	mean_var22 = variance(mean_est22)
	mean_var31 = variance(mean_est31)
	mean_var32 = variance(mean_est32)
	mean_var33 = variance(mean_est33)
	
	acov_var = variance(acov_est)
	acov_var21 = variance(acov_est21)
	acov_var22 = variance(acov_est22)
	acov_var31 = variance(acov_est31)
	acov_var32 = variance(acov_est32)
	acov_var33 = variance(acov_est33)
	
	acor_var = variance(acor_est)
	acor_var21 = variance(acor_est21)
	acor_var22 = variance(acor_est22)
	acor_var31 = variance(acor_est31)
	acor_var32 = variance(acor_est32)
	acor_var33 = variance(acor_est33)
	
	mean_acov_cor = correlation((mean_est, acov_est))[2,1]
	mean_acov_cor21 = correlation((mean_est21, acov_est21))[2,1]
	mean_acov_cor22 = correlation((mean_est22, acov_est22))[2,1]
	mean_acov_cor31 = correlation((mean_est31, acov_est31))[2,1]
	mean_acov_cor32 = correlation((mean_est32, acov_est32))[2,1]
	mean_acov_cor33 = correlation((mean_est33, acov_est33))[2,1]
	
	mean_acor_cor = correlation((mean_est, acor_est))[2,1]
	mean_acor_cor21 = correlation((mean_est21, acor_est21))[2,1]
	mean_acor_cor22 = correlation((mean_est22, acor_est22))[2,1]
	mean_acor_cor31 = correlation((mean_est31, acor_est31))[2,1]
	mean_acor_cor32 = correlation((mean_est32, acor_est32))[2,1]
	mean_acor_cor33 = correlation((mean_est33, acor_est33))[2,1]
	
	acov_acor_cor = correlation((acov_est, acor_est))[2,1]
	acov_acor_cor21 = correlation((acov_est21, acor_est21))[2,1]
	acov_acor_cor22 = correlation((acov_est22, acor_est22))[2,1]
	acov_acor_cor31 = correlation((acov_est31, acor_est31))[2,1]
	acov_acor_cor32 = correlation((acov_est32, acor_est32))[2,1]
	acov_acor_cor33 = correlation((acov_est33, acor_est33))[2,1]
	
	est = (mean_mean, acov_mean, acor_mean, mean_var, acov_var, acor_var, mean_acov_cor, mean_acor_cor, acov_acor_cor)
	est21 = (mean_mean21, acov_mean21, acor_mean21, mean_var21, acov_var21, acor_var21, mean_acov_cor21, mean_acor_cor21, acov_acor_cor21)
	est22 = (mean_mean22, acov_mean22, acor_mean22, mean_var22, acov_var22, acor_var22, mean_acov_cor22, mean_acor_cor22, acov_acor_cor22)
    est31 = (mean_mean31, acov_mean31, acor_mean31, mean_var31, acov_var31, acor_var31, mean_acov_cor31, mean_acor_cor31, acov_acor_cor31)
	est32 = (mean_mean32, acov_mean32, acor_mean32, mean_var32, acov_var32, acor_var32, mean_acov_cor32, mean_acor_cor32, acov_acor_cor32)
    est33 = (mean_mean33, acov_mean33, acor_mean33, mean_var33, acov_var33, acor_var33, mean_acov_cor33, mean_acor_cor33, acov_acor_cor33)
	
	// TOJ estimate
    tojest = 3.536 * est - 4.072 * (est21 + est22) / 2 + 1.536 * (est31 + est32 + est33) / 3
  
    return(tojest)
}

function tojmomentest1(quantity, indices){

	mean_est = quantity[indices, 1]
	mean_est21 = quantity[indices, 2]
	mean_est22 = quantity[indices, 3]
	mean_est23 = quantity[indices, 4]
	mean_est24 = quantity[indices, 5]	
	mean_est31 = quantity[indices, 6]
	mean_est32 = quantity[indices, 7]
	mean_est33 = quantity[indices, 8]
	mean_est34 = quantity[indices, 9]
	mean_est35 = quantity[indices, 10]
	mean_est36 = quantity[indices, 11]
	mean_est37 = quantity[indices, 12]
	mean_est38 = quantity[indices, 13]
	mean_est39 = quantity[indices, 14]
	
	acov_est = quantity[indices, 15]
	acov_est21 = quantity[indices, 16]
	acov_est22 = quantity[indices, 17]
	acov_est23 = quantity[indices, 18]
	acov_est24 = quantity[indices, 19]
	acov_est31 = quantity[indices, 20]
	acov_est32 = quantity[indices, 21]
	acov_est33 = quantity[indices, 22]
	acov_est34 = quantity[indices, 23]
	acov_est35 = quantity[indices, 24]
	acov_est36 = quantity[indices, 25]
	acov_est37 = quantity[indices, 26]
	acov_est38 = quantity[indices, 27]
	acov_est39 = quantity[indices, 28]
	
	acor_est = quantity[indices, 29]
	acor_est21 = quantity[indices, 30]
	acor_est22 = quantity[indices, 31]
	acor_est23 = quantity[indices, 32]
	acor_est24 = quantity[indices, 33]
	acor_est31 = quantity[indices, 34]
	acor_est32 = quantity[indices, 35]
	acor_est33 = quantity[indices, 36]
	acor_est34 = quantity[indices, 37]
	acor_est35 = quantity[indices, 38]
	acor_est36 = quantity[indices, 39]
	acor_est37 = quantity[indices, 40]
	acor_est38 = quantity[indices, 41]
	acor_est39 = quantity[indices, 42]
	
	mean_mean = sum(mean_est) / length(mean_est)
	mean_mean21 = sum(mean_est21) / length(mean_est21)
	mean_mean22 = sum(mean_est22) / length(mean_est22)
	mean_mean23 = sum(mean_est23) / length(mean_est23)
	mean_mean24 = sum(mean_est24) / length(mean_est24)
	mean_mean31 = sum(mean_est31) / length(mean_est31)
	mean_mean32 = sum(mean_est32) / length(mean_est32)
	mean_mean33 = sum(mean_est33) / length(mean_est33)
	mean_mean34 = sum(mean_est34) / length(mean_est34)
	mean_mean35 = sum(mean_est35) / length(mean_est35)
	mean_mean36 = sum(mean_est36) / length(mean_est36)
	mean_mean37 = sum(mean_est37) / length(mean_est37)
	mean_mean38 = sum(mean_est38) / length(mean_est38)
	mean_mean39 = sum(mean_est39) / length(mean_est39)
	
	acov_mean = sum(acov_est) / length(acov_est)
	acov_mean21 = sum(acov_est21) / length(acov_est21)
	acov_mean22 = sum(acov_est22) / length(acov_est22)
	acov_mean23 = sum(acov_est23) / length(acov_est23)
	acov_mean24 = sum(acov_est24) / length(acov_est24)
	acov_mean31 = sum(acov_est31) / length(acov_est31)
	acov_mean32 = sum(acov_est32) / length(acov_est32)
	acov_mean33 = sum(acov_est33) / length(acov_est33)
	acov_mean34 = sum(acov_est34) / length(acov_est34)
	acov_mean35 = sum(acov_est35) / length(acov_est35)
	acov_mean36 = sum(acov_est36) / length(acov_est36)
	acov_mean37 = sum(acov_est37) / length(acov_est37)
	acov_mean38 = sum(acov_est38) / length(acov_est38)
	acov_mean39 = sum(acov_est39) / length(acov_est39)
	
	acor_mean = sum(acor_est) / length(acor_est)
	acor_mean21 = sum(acor_est21) / length(acor_est21)
	acor_mean22 = sum(acor_est22) / length(acor_est22)
	acor_mean23 = sum(acor_est23) / length(acor_est23)
	acor_mean24 = sum(acor_est24) / length(acor_est24)
	acor_mean31 = sum(acor_est31) / length(acor_est31)
	acor_mean32 = sum(acor_est32) / length(acor_est32)
	acor_mean33 = sum(acor_est33) / length(acor_est33)
	acor_mean34 = sum(acor_est34) / length(acor_est34)
	acor_mean35 = sum(acor_est35) / length(acor_est35)
	acor_mean36 = sum(acor_est36) / length(acor_est36)
	acor_mean37 = sum(acor_est37) / length(acor_est37)
	acor_mean38 = sum(acor_est38) / length(acor_est38)
	acor_mean39 = sum(acor_est39) / length(acor_est39)

	mean_var = variance(mean_est)
	mean_var21 = variance(mean_est21)
	mean_var22 = variance(mean_est22)
	mean_var23 = variance(mean_est23)
	mean_var24 = variance(mean_est24)
	mean_var31 = variance(mean_est31)
	mean_var32 = variance(mean_est32)
	mean_var33 = variance(mean_est33)
	mean_var34 = variance(mean_est34)
	mean_var35 = variance(mean_est35)
	mean_var36 = variance(mean_est36)
	mean_var37 = variance(mean_est37)
	mean_var38 = variance(mean_est38)
	mean_var39 = variance(mean_est39)
	
	acov_var = variance(acov_est)
	acov_var21 = variance(acov_est21)
	acov_var22 = variance(acov_est22)
	acov_var23 = variance(acov_est23)
	acov_var24 = variance(acov_est24)
	acov_var31 = variance(acov_est31)
	acov_var32 = variance(acov_est32)
	acov_var33 = variance(acov_est33)
	acov_var34 = variance(acov_est34)
	acov_var35 = variance(acov_est35)
	acov_var36 = variance(acov_est36)
	acov_var37 = variance(acov_est37)
	acov_var38 = variance(acov_est38)
	acov_var39 = variance(acov_est39)
	
	acor_var = variance(acor_est)
	acor_var21 = variance(acor_est21)
	acor_var22 = variance(acor_est22)
	acor_var23 = variance(acor_est23)
	acor_var24 = variance(acor_est24)
	acor_var31 = variance(acor_est31)
	acor_var32 = variance(acor_est32)
	acor_var33 = variance(acor_est33)
	acor_var34 = variance(acor_est34)
	acor_var35 = variance(acor_est35)
	acor_var36 = variance(acor_est36)
	acor_var37 = variance(acor_est37)
	acor_var38 = variance(acor_est38)
	acor_var39 = variance(acor_est39)
	
	mean_acov_cor = correlation((mean_est, acov_est))[2,1]
	mean_acov_cor21 = correlation((mean_est21, acov_est21))[2,1]
	mean_acov_cor22 = correlation((mean_est22, acov_est22))[2,1]
	mean_acov_cor23 = correlation((mean_est23, acov_est23))[2,1]
	mean_acov_cor24 = correlation((mean_est24, acov_est24))[2,1]
	mean_acov_cor31 = correlation((mean_est31, acov_est31))[2,1]
	mean_acov_cor32 = correlation((mean_est32, acov_est32))[2,1]
	mean_acov_cor33 = correlation((mean_est33, acov_est33))[2,1]
	mean_acov_cor34 = correlation((mean_est34, acov_est34))[2,1]
	mean_acov_cor35 = correlation((mean_est35, acov_est35))[2,1]
	mean_acov_cor36 = correlation((mean_est36, acov_est36))[2,1]
	mean_acov_cor37 = correlation((mean_est37, acov_est37))[2,1]
	mean_acov_cor38 = correlation((mean_est38, acov_est38))[2,1]
	mean_acov_cor39 = correlation((mean_est39, acov_est39))[2,1]
	
	mean_acor_cor = correlation((mean_est, acor_est))[2,1]
	mean_acor_cor21 = correlation((mean_est21, acor_est21))[2,1]
	mean_acor_cor22 = correlation((mean_est22, acor_est22))[2,1]
	mean_acor_cor23 = correlation((mean_est23, acor_est23))[2,1]
	mean_acor_cor24 = correlation((mean_est24, acor_est24))[2,1]
	mean_acor_cor31 = correlation((mean_est31, acor_est31))[2,1]
	mean_acor_cor32 = correlation((mean_est32, acor_est32))[2,1]
	mean_acor_cor33 = correlation((mean_est33, acor_est33))[2,1]
	mean_acor_cor34 = correlation((mean_est34, acor_est34))[2,1]
	mean_acor_cor35 = correlation((mean_est35, acor_est35))[2,1]
	mean_acor_cor36 = correlation((mean_est36, acor_est36))[2,1]
	mean_acor_cor37 = correlation((mean_est37, acor_est37))[2,1]
	mean_acor_cor38 = correlation((mean_est38, acor_est38))[2,1]
	mean_acor_cor39 = correlation((mean_est39, acor_est39))[2,1]
	
	acov_acor_cor = correlation((acov_est, acor_est))[2,1]
	acov_acor_cor21 = correlation((acov_est21, acor_est21))[2,1]
	acov_acor_cor22 = correlation((acov_est22, acor_est22))[2,1]
	acov_acor_cor23 = correlation((acov_est23, acor_est23))[2,1]
	acov_acor_cor24 = correlation((acov_est24, acor_est24))[2,1]
	acov_acor_cor31 = correlation((acov_est31, acor_est31))[2,1]
	acov_acor_cor32 = correlation((acov_est32, acor_est32))[2,1]
	acov_acor_cor33 = correlation((acov_est33, acor_est33))[2,1]
	acov_acor_cor34 = correlation((acov_est34, acor_est34))[2,1]
	acov_acor_cor35 = correlation((acov_est35, acor_est35))[2,1]
	acov_acor_cor36 = correlation((acov_est36, acor_est36))[2,1]
	acov_acor_cor37 = correlation((acov_est37, acor_est37))[2,1]
	acov_acor_cor38 = correlation((acov_est38, acor_est38))[2,1]
	acov_acor_cor39 = correlation((acov_est39, acor_est39))[2,1]
	
	est = (mean_mean, acov_mean, acor_mean, mean_var, acov_var, acor_var, mean_acov_cor, mean_acor_cor, acov_acor_cor)
	est21 = (mean_mean21, acov_mean21, acor_mean21, mean_var21, acov_var21, acor_var21, mean_acov_cor21, mean_acor_cor21, acov_acor_cor21)
	est22 = (mean_mean22, acov_mean22, acor_mean22, mean_var22, acov_var22, acor_var22, mean_acov_cor22, mean_acor_cor22, acov_acor_cor22)
    est23 = (mean_mean23, acov_mean23, acor_mean23, mean_var23, acov_var23, acor_var23, mean_acov_cor23, mean_acor_cor23, acov_acor_cor23)
	est24 = (mean_mean24, acov_mean24, acor_mean24, mean_var24, acov_var24, acor_var24, mean_acov_cor24, mean_acor_cor24, acov_acor_cor24)
    est31 = (mean_mean31, acov_mean31, acor_mean31, mean_var31, acov_var31, acor_var31, mean_acov_cor31, mean_acor_cor31, acov_acor_cor31)
	est32 = (mean_mean32, acov_mean32, acor_mean32, mean_var32, acov_var32, acor_var32, mean_acov_cor32, mean_acor_cor32, acov_acor_cor32)
    est33 = (mean_mean33, acov_mean33, acor_mean33, mean_var33, acov_var33, acor_var33, mean_acov_cor33, mean_acor_cor33, acov_acor_cor33)
	est34 = (mean_mean34, acov_mean34, acor_mean34, mean_var34, acov_var34, acor_var34, mean_acov_cor34, mean_acor_cor34, acov_acor_cor34)
	est35 = (mean_mean35, acov_mean35, acor_mean35, mean_var35, acov_var35, acor_var35, mean_acov_cor35, mean_acor_cor35, acov_acor_cor35)
    est36 = (mean_mean36, acov_mean36, acor_mean36, mean_var36, acov_var36, acor_var36, mean_acov_cor36, mean_acor_cor36, acov_acor_cor36)
	est37 = (mean_mean37, acov_mean37, acor_mean37, mean_var37, acov_var37, acor_var37, mean_acov_cor37, mean_acor_cor37, acov_acor_cor37)
	est38 = (mean_mean38, acov_mean38, acor_mean38, mean_var38, acov_var38, acor_var38, mean_acov_cor38, mean_acor_cor38, acov_acor_cor38)
    est39 = (mean_mean39, acov_mean39, acor_mean39, mean_var39, acov_var39, acor_var39, mean_acov_cor39, mean_acor_cor39, acov_acor_cor39)
	
	// TOJ estimate
	tojest = 3.536 * est - 4.072 * (est21 + est22 + est23 + est24) / 4 + 1.536 * (est31 + est32 + est33 + est34 + est35 + est36 + est37 + est38 + est39) / 9
	
	return(tojest)
}


function tojmomentest2(quantity, indices){

	mean_est = quantity[indices, 1]
	mean_est21 = quantity[indices, 2]
	mean_est22 = quantity[indices, 3]
	mean_est31 = quantity[indices, 4]
	mean_est32 = quantity[indices, 5]
	mean_est33 = quantity[indices, 6]
	mean_est34 = quantity[indices, 7]
	mean_est35 = quantity[indices, 8]
	mean_est36 = quantity[indices, 9]
	mean_est37 = quantity[indices, 10]
	mean_est38 = quantity[indices, 11]
	mean_est39 = quantity[indices, 12]
	
	acov_est = quantity[indices, 13]
	acov_est21 = quantity[indices, 14]
	acov_est22 = quantity[indices, 15]
	acov_est31 = quantity[indices, 16]
	acov_est32 = quantity[indices, 17]
	acov_est33 = quantity[indices, 18]
	acov_est34 = quantity[indices, 19]
	acov_est35 = quantity[indices, 20]
	acov_est36 = quantity[indices, 21]
	acov_est37 = quantity[indices, 22]
	acov_est38 = quantity[indices, 23]
	acov_est39 = quantity[indices, 24]
	
	acor_est = quantity[indices, 25]
	acor_est21 = quantity[indices, 26]
	acor_est22 = quantity[indices, 27]
	acor_est31 = quantity[indices, 28]
	acor_est32 = quantity[indices, 29]
	acor_est33 = quantity[indices, 30]
	acor_est34 = quantity[indices, 31]
	acor_est35 = quantity[indices, 32]
	acor_est36 = quantity[indices, 33]
	acor_est37 = quantity[indices, 34]
	acor_est38 = quantity[indices, 35]
	acor_est39 = quantity[indices, 36]
	
	mean_mean = sum(mean_est) / length(mean_est)
	mean_mean21 = sum(mean_est21) / length(mean_est21)
	mean_mean22 = sum(mean_est22) / length(mean_est22)
	mean_mean31 = sum(mean_est31) / length(mean_est31)
	mean_mean32 = sum(mean_est32) / length(mean_est32)
	mean_mean33 = sum(mean_est33) / length(mean_est33)
	mean_mean34 = sum(mean_est34) / length(mean_est34)
	mean_mean35 = sum(mean_est35) / length(mean_est35)
	mean_mean36 = sum(mean_est36) / length(mean_est36)
	mean_mean37 = sum(mean_est37) / length(mean_est37)
	mean_mean38 = sum(mean_est38) / length(mean_est38)
	mean_mean39 = sum(mean_est39) / length(mean_est39)
	
	acov_mean = sum(acov_est) / length(acov_est)
	acov_mean21 = sum(acov_est21) / length(acov_est21)
	acov_mean22 = sum(acov_est22) / length(acov_est22)
	acov_mean31 = sum(acov_est31) / length(acov_est31)
	acov_mean32 = sum(acov_est32) / length(acov_est32)
	acov_mean33 = sum(acov_est33) / length(acov_est33)
	acov_mean34 = sum(acov_est34) / length(acov_est34)
	acov_mean35 = sum(acov_est35) / length(acov_est35)
	acov_mean36 = sum(acov_est36) / length(acov_est36)
	acov_mean37 = sum(acov_est37) / length(acov_est37)
	acov_mean38 = sum(acov_est38) / length(acov_est38)
	acov_mean39 = sum(acov_est39) / length(acov_est39)
	
	acor_mean = sum(acor_est) / length(acor_est)
	acor_mean21 = sum(acor_est21) / length(acor_est21)
	acor_mean22 = sum(acor_est22) / length(acor_est22)
	acor_mean31 = sum(acor_est31) / length(acor_est31)
	acor_mean32 = sum(acor_est32) / length(acor_est32)
	acor_mean33 = sum(acor_est33) / length(acor_est33)
	acor_mean34 = sum(acor_est34) / length(acor_est34)
	acor_mean35 = sum(acor_est35) / length(acor_est35)
	acor_mean36 = sum(acor_est36) / length(acor_est36)
	acor_mean37 = sum(acor_est37) / length(acor_est37)
	acor_mean38 = sum(acor_est38) / length(acor_est38)
	acor_mean39 = sum(acor_est39) / length(acor_est39)

	mean_var = variance(mean_est)
	mean_var21 = variance(mean_est21)
	mean_var22 = variance(mean_est22)
	mean_var31 = variance(mean_est31)
	mean_var32 = variance(mean_est32)
	mean_var33 = variance(mean_est33)
	mean_var34 = variance(mean_est34)
	mean_var35 = variance(mean_est35)
	mean_var36 = variance(mean_est36)
	mean_var37 = variance(mean_est37)
	mean_var38 = variance(mean_est38)
	mean_var39 = variance(mean_est39)
	
	acov_var = variance(acov_est)
	acov_var21 = variance(acov_est21)
	acov_var22 = variance(acov_est22)
	acov_var31 = variance(acov_est31)
	acov_var32 = variance(acov_est32)
	acov_var33 = variance(acov_est33)
	acov_var34 = variance(acov_est34)
	acov_var35 = variance(acov_est35)
	acov_var36 = variance(acov_est36)
	acov_var37 = variance(acov_est37)
	acov_var38 = variance(acov_est38)
	acov_var39 = variance(acov_est39)
	
	acor_var = variance(acor_est)
	acor_var21 = variance(acor_est21)
	acor_var22 = variance(acor_est22)
	acor_var31 = variance(acor_est31)
	acor_var32 = variance(acor_est32)
	acor_var33 = variance(acor_est33)
	acor_var34 = variance(acor_est34)
	acor_var35 = variance(acor_est35)
	acor_var36 = variance(acor_est36)
	acor_var37 = variance(acor_est37)
	acor_var38 = variance(acor_est38)
	acor_var39 = variance(acor_est39)
	
	mean_acov_cor = correlation((mean_est, acov_est))[2,1]
	mean_acov_cor21 = correlation((mean_est21, acov_est21))[2,1]
	mean_acov_cor22 = correlation((mean_est22, acov_est22))[2,1]
	mean_acov_cor31 = correlation((mean_est31, acov_est31))[2,1]
	mean_acov_cor32 = correlation((mean_est32, acov_est32))[2,1]
	mean_acov_cor33 = correlation((mean_est33, acov_est33))[2,1]
	mean_acov_cor34 = correlation((mean_est34, acov_est34))[2,1]
	mean_acov_cor35 = correlation((mean_est35, acov_est35))[2,1]
	mean_acov_cor36 = correlation((mean_est36, acov_est36))[2,1]
	mean_acov_cor37 = correlation((mean_est37, acov_est37))[2,1]
	mean_acov_cor38 = correlation((mean_est38, acov_est38))[2,1]
	mean_acov_cor39 = correlation((mean_est39, acov_est39))[2,1]
	
	mean_acor_cor = correlation((mean_est, acor_est))[2,1]
	mean_acor_cor21 = correlation((mean_est21, acor_est21))[2,1]
	mean_acor_cor22 = correlation((mean_est22, acor_est22))[2,1]
	mean_acor_cor31 = correlation((mean_est31, acor_est31))[2,1]
	mean_acor_cor32 = correlation((mean_est32, acor_est32))[2,1]
	mean_acor_cor33 = correlation((mean_est33, acor_est33))[2,1]
	mean_acor_cor34 = correlation((mean_est34, acor_est34))[2,1]
	mean_acor_cor35 = correlation((mean_est35, acor_est35))[2,1]
	mean_acor_cor36 = correlation((mean_est36, acor_est36))[2,1]
	mean_acor_cor37 = correlation((mean_est37, acor_est37))[2,1]
	mean_acor_cor38 = correlation((mean_est38, acor_est38))[2,1]
	mean_acor_cor39 = correlation((mean_est39, acor_est39))[2,1]
	
	acov_acor_cor = correlation((acov_est, acor_est))[2,1]
	acov_acor_cor21 = correlation((acov_est21, acor_est21))[2,1]
	acov_acor_cor22 = correlation((acov_est22, acor_est22))[2,1]
	acov_acor_cor31 = correlation((acov_est31, acor_est31))[2,1]
	acov_acor_cor32 = correlation((acov_est32, acor_est32))[2,1]
	acov_acor_cor33 = correlation((acov_est33, acor_est33))[2,1]
	acov_acor_cor34 = correlation((acov_est34, acor_est34))[2,1]
	acov_acor_cor35 = correlation((acov_est35, acor_est35))[2,1]
	acov_acor_cor36 = correlation((acov_est36, acor_est36))[2,1]
	acov_acor_cor37 = correlation((acov_est37, acor_est37))[2,1]
	acov_acor_cor38 = correlation((acov_est38, acor_est38))[2,1]
	acov_acor_cor39 = correlation((acov_est39, acor_est39))[2,1]
	
	est = (mean_mean, acov_mean, acor_mean, mean_var, acov_var, acor_var, mean_acov_cor, mean_acor_cor, acov_acor_cor)
	est21 = (mean_mean21, acov_mean21, acor_mean21, mean_var21, acov_var21, acor_var21, mean_acov_cor21, mean_acor_cor21, acov_acor_cor21)
	est22 = (mean_mean22, acov_mean22, acor_mean22, mean_var22, acov_var22, acor_var22, mean_acov_cor22, mean_acor_cor22, acov_acor_cor22)
    est31 = (mean_mean31, acov_mean31, acor_mean31, mean_var31, acov_var31, acor_var31, mean_acov_cor31, mean_acor_cor31, acov_acor_cor31)
	est32 = (mean_mean32, acov_mean32, acor_mean32, mean_var32, acov_var32, acor_var32, mean_acov_cor32, mean_acor_cor32, acov_acor_cor32)
    est33 = (mean_mean33, acov_mean33, acor_mean33, mean_var33, acov_var33, acor_var33, mean_acov_cor33, mean_acor_cor33, acov_acor_cor33)
	est34 = (mean_mean34, acov_mean34, acor_mean34, mean_var34, acov_var34, acor_var34, mean_acov_cor34, mean_acor_cor34, acov_acor_cor34)
	est35 = (mean_mean35, acov_mean35, acor_mean35, mean_var35, acov_var35, acor_var35, mean_acov_cor35, mean_acor_cor35, acov_acor_cor35)
    est36 = (mean_mean36, acov_mean36, acor_mean36, mean_var36, acov_var36, acor_var36, mean_acov_cor36, mean_acor_cor36, acov_acor_cor36)
	est37 = (mean_mean37, acov_mean37, acor_mean37, mean_var37, acov_var37, acor_var37, mean_acov_cor37, mean_acor_cor37, acov_acor_cor37)
	est38 = (mean_mean38, acov_mean38, acor_mean38, mean_var38, acov_var38, acor_var38, mean_acov_cor38, mean_acor_cor38, acov_acor_cor38)
    est39 = (mean_mean39, acov_mean39, acor_mean39, mean_var39, acov_var39, acor_var39, mean_acov_cor39, mean_acor_cor39, acov_acor_cor39)
	
	// TOJ estimate
	tojest = 3.536 * est - 4.072 * (est21 + est22) / 2 + 1.536 * (est31 + est32 + est33 + est34 + est35 + est36 + est37 + est38 + est39) / 9
	
	return(tojest)
}

function tojmomentest3(quantity, indices){

	mean_est = quantity[indices, 1]
	mean_est21 = quantity[indices, 2]
	mean_est22 = quantity[indices, 3]
	mean_est23 = quantity[indices, 4]
	mean_est24 = quantity[indices, 5]	
	mean_est31 = quantity[indices, 6]
	mean_est32 = quantity[indices, 7]
	mean_est33 = quantity[indices, 8]
	
	acov_est = quantity[indices, 9]
	acov_est21 = quantity[indices, 10]
	acov_est22 = quantity[indices, 11]
	acov_est23 = quantity[indices, 12]
	acov_est24 = quantity[indices, 13]
	acov_est31 = quantity[indices, 14]
	acov_est32 = quantity[indices, 15]
	acov_est33 = quantity[indices, 16]
	
	acor_est = quantity[indices, 17]
	acor_est21 = quantity[indices, 18]
	acor_est22 = quantity[indices, 19]
	acor_est23 = quantity[indices, 20]
	acor_est24 = quantity[indices, 21]
	acor_est31 = quantity[indices, 22]
	acor_est32 = quantity[indices, 23]
	acor_est33 = quantity[indices, 24]
	
	mean_mean = sum(mean_est) / length(mean_est)
	mean_mean21 = sum(mean_est21) / length(mean_est21)
	mean_mean22 = sum(mean_est22) / length(mean_est22)
	mean_mean23 = sum(mean_est23) / length(mean_est23)
	mean_mean24 = sum(mean_est24) / length(mean_est24)
	mean_mean31 = sum(mean_est31) / length(mean_est31)
	mean_mean32 = sum(mean_est32) / length(mean_est32)
	mean_mean33 = sum(mean_est33) / length(mean_est33)
	
	acov_mean = sum(acov_est) / length(acov_est)
	acov_mean21 = sum(acov_est21) / length(acov_est21)
	acov_mean22 = sum(acov_est22) / length(acov_est22)
	acov_mean23 = sum(acov_est23) / length(acov_est23)
	acov_mean24 = sum(acov_est24) / length(acov_est24)
	acov_mean31 = sum(acov_est31) / length(acov_est31)
	acov_mean32 = sum(acov_est32) / length(acov_est32)
	acov_mean33 = sum(acov_est33) / length(acov_est33)
	
	acor_mean = sum(acor_est) / length(acor_est)
	acor_mean21 = sum(acor_est21) / length(acor_est21)
	acor_mean22 = sum(acor_est22) / length(acor_est22)
	acor_mean23 = sum(acor_est23) / length(acor_est23)
	acor_mean24 = sum(acor_est24) / length(acor_est24)
	acor_mean31 = sum(acor_est31) / length(acor_est31)
	acor_mean32 = sum(acor_est32) / length(acor_est32)
	acor_mean33 = sum(acor_est33) / length(acor_est33)
	
	mean_var = variance(mean_est)
	mean_var21 = variance(mean_est21)
	mean_var22 = variance(mean_est22)
	mean_var23 = variance(mean_est23)
	mean_var24 = variance(mean_est24)
	mean_var31 = variance(mean_est31)
	mean_var32 = variance(mean_est32)
	mean_var33 = variance(mean_est33)
	
	acov_var = variance(acov_est)
	acov_var21 = variance(acov_est21)
	acov_var22 = variance(acov_est22)
	acov_var23 = variance(acov_est23)
	acov_var24 = variance(acov_est24)
	acov_var31 = variance(acov_est31)
	acov_var32 = variance(acov_est32)
	acov_var33 = variance(acov_est33)
	
	acor_var = variance(acor_est)
	acor_var21 = variance(acor_est21)
	acor_var22 = variance(acor_est22)
	acor_var23 = variance(acor_est23)
	acor_var24 = variance(acor_est24)
	acor_var31 = variance(acor_est31)
	acor_var32 = variance(acor_est32)
	acor_var33 = variance(acor_est33)
	
	mean_acov_cor = correlation((mean_est, acov_est))[2,1]
	mean_acov_cor21 = correlation((mean_est21, acov_est21))[2,1]
	mean_acov_cor22 = correlation((mean_est22, acov_est22))[2,1]
	mean_acov_cor23 = correlation((mean_est23, acov_est23))[2,1]
	mean_acov_cor24 = correlation((mean_est24, acov_est24))[2,1]
	mean_acov_cor31 = correlation((mean_est31, acov_est31))[2,1]
	mean_acov_cor32 = correlation((mean_est32, acov_est32))[2,1]
	mean_acov_cor33 = correlation((mean_est33, acov_est33))[2,1]
	
	mean_acor_cor = correlation((mean_est, acor_est))[2,1]
	mean_acor_cor21 = correlation((mean_est21, acor_est21))[2,1]
	mean_acor_cor22 = correlation((mean_est22, acor_est22))[2,1]
	mean_acor_cor23 = correlation((mean_est23, acor_est23))[2,1]
	mean_acor_cor24 = correlation((mean_est24, acor_est24))[2,1]
	mean_acor_cor31 = correlation((mean_est31, acor_est31))[2,1]
	mean_acor_cor32 = correlation((mean_est32, acor_est32))[2,1]
	mean_acor_cor33 = correlation((mean_est33, acor_est33))[2,1]
	
	acov_acor_cor = correlation((acov_est, acor_est))[2,1]
	acov_acor_cor21 = correlation((acov_est21, acor_est21))[2,1]
	acov_acor_cor22 = correlation((acov_est22, acor_est22))[2,1]
	acov_acor_cor23 = correlation((acov_est23, acor_est23))[2,1]
	acov_acor_cor24 = correlation((acov_est24, acor_est24))[2,1]
	acov_acor_cor31 = correlation((acov_est31, acor_est31))[2,1]
	acov_acor_cor32 = correlation((acov_est32, acor_est32))[2,1]
	acov_acor_cor33 = correlation((acov_est33, acor_est33))[2,1]
	
	est = (mean_mean, acov_mean, acor_mean, mean_var, acov_var, acor_var, mean_acov_cor, mean_acor_cor, acov_acor_cor)
	est21 = (mean_mean21, acov_mean21, acor_mean21, mean_var21, acov_var21, acor_var21, mean_acov_cor21, mean_acor_cor21, acov_acor_cor21)
	est22 = (mean_mean22, acov_mean22, acor_mean22, mean_var22, acov_var22, acor_var22, mean_acov_cor22, mean_acor_cor22, acov_acor_cor22)
    est23 = (mean_mean23, acov_mean23, acor_mean23, mean_var23, acov_var23, acor_var23, mean_acov_cor23, mean_acor_cor23, acov_acor_cor23)
	est24 = (mean_mean24, acov_mean24, acor_mean24, mean_var24, acov_var24, acor_var24, mean_acov_cor24, mean_acor_cor24, acov_acor_cor24)
    est31 = (mean_mean31, acov_mean31, acor_mean31, mean_var31, acov_var31, acor_var31, mean_acov_cor31, mean_acor_cor31, acov_acor_cor31)
	est32 = (mean_mean32, acov_mean32, acor_mean32, mean_var32, acov_var32, acor_var32, mean_acov_cor32, mean_acor_cor32, acov_acor_cor32)
    est33 = (mean_mean33, acov_mean33, acor_mean33, mean_var33, acov_var33, acor_var33, mean_acov_cor33, mean_acor_cor33, acov_acor_cor33)
	
	// TOJ estimate
	tojest = 3.536 * est - 4.072 * (est21 + est22 + est23 + est24) / 4 + 1.536 * (est31 + est32 + est33) / 3

    return(tojest)
}

function tojmomentest4(quantity, indices){

	mean_est = quantity[indices, 1]
	mean_est21 = quantity[indices, 2]
	mean_est22 = quantity[indices, 3]
	mean_est31 = quantity[indices, 4]
	mean_est32 = quantity[indices, 5]
	mean_est33 = quantity[indices, 6]
	mean_est34 = quantity[indices, 7]
	mean_est35 = quantity[indices, 8]
	mean_est36 = quantity[indices, 9]
	mean_est37 = quantity[indices, 10]
	mean_est38 = quantity[indices, 11]
	mean_est39 = quantity[indices, 12]
	
	acov_est = quantity[indices, 13]
	acov_est21 = quantity[indices, 14]
	acov_est22 = quantity[indices, 15]
	acov_est31 = quantity[indices, 16]
	acov_est32 = quantity[indices, 17]
	acov_est33 = quantity[indices, 18]
	acov_est34 = quantity[indices, 19]
	acov_est35 = quantity[indices, 20]
	acov_est36 = quantity[indices, 21]
	acov_est37 = quantity[indices, 22]
	acov_est38 = quantity[indices, 23]
	acov_est39 = quantity[indices, 24]
	
	acor_est = quantity[indices, 25]
	acor_est21 = quantity[indices, 26]
	acor_est22 = quantity[indices, 27]
	acor_est31 = quantity[indices, 28]
	acor_est32 = quantity[indices, 29]
	acor_est33 = quantity[indices, 30]
	acor_est34 = quantity[indices, 31]
	acor_est35 = quantity[indices, 32]
	acor_est36 = quantity[indices, 33]
	acor_est37 = quantity[indices, 34]
	acor_est38 = quantity[indices, 35]
	acor_est39 = quantity[indices, 36]
	
	mean_mean = sum(mean_est) / length(mean_est)
	mean_mean21 = sum(mean_est21) / length(mean_est21)
	mean_mean22 = sum(mean_est22) / length(mean_est22)
	mean_mean31 = sum(mean_est31) / length(mean_est31)
	mean_mean32 = sum(mean_est32) / length(mean_est32)
	mean_mean33 = sum(mean_est33) / length(mean_est33)
	mean_mean34 = sum(mean_est34) / length(mean_est34)
	mean_mean35 = sum(mean_est35) / length(mean_est35)
	mean_mean36 = sum(mean_est36) / length(mean_est36)
	mean_mean37 = sum(mean_est37) / length(mean_est37)
	mean_mean38 = sum(mean_est38) / length(mean_est38)
	mean_mean39 = sum(mean_est39) / length(mean_est39)
	
	acov_mean = sum(acov_est) / length(acov_est)
	acov_mean21 = sum(acov_est21) / length(acov_est21)
	acov_mean22 = sum(acov_est22) / length(acov_est22)
	acov_mean31 = sum(acov_est31) / length(acov_est31)
	acov_mean32 = sum(acov_est32) / length(acov_est32)
	acov_mean33 = sum(acov_est33) / length(acov_est33)
	acov_mean34 = sum(acov_est34) / length(acov_est34)
	acov_mean35 = sum(acov_est35) / length(acov_est35)
	acov_mean36 = sum(acov_est36) / length(acov_est36)
	acov_mean37 = sum(acov_est37) / length(acov_est37)
	acov_mean38 = sum(acov_est38) / length(acov_est38)
	acov_mean39 = sum(acov_est39) / length(acov_est39)
	
	acor_mean = sum(acor_est) / length(acor_est)
	acor_mean21 = sum(acor_est21) / length(acor_est21)
	acor_mean22 = sum(acor_est22) / length(acor_est22)
	acor_mean31 = sum(acor_est31) / length(acor_est31)
	acor_mean32 = sum(acor_est32) / length(acor_est32)
	acor_mean33 = sum(acor_est33) / length(acor_est33)
	acor_mean34 = sum(acor_est34) / length(acor_est34)
	acor_mean35 = sum(acor_est35) / length(acor_est35)
	acor_mean36 = sum(acor_est36) / length(acor_est36)
	acor_mean37 = sum(acor_est37) / length(acor_est37)
	acor_mean38 = sum(acor_est38) / length(acor_est38)
	acor_mean39 = sum(acor_est39) / length(acor_est39)

	mean_var = variance(mean_est)
	mean_var21 = variance(mean_est21)
	mean_var22 = variance(mean_est22)
	mean_var31 = variance(mean_est31)
	mean_var32 = variance(mean_est32)
	mean_var33 = variance(mean_est33)
	mean_var34 = variance(mean_est34)
	mean_var35 = variance(mean_est35)
	mean_var36 = variance(mean_est36)
	mean_var37 = variance(mean_est37)
	mean_var38 = variance(mean_est38)
	mean_var39 = variance(mean_est39)
	
	acov_var = variance(acov_est)
	acov_var21 = variance(acov_est21)
	acov_var22 = variance(acov_est22)
	acov_var31 = variance(acov_est31)
	acov_var32 = variance(acov_est32)
	acov_var33 = variance(acov_est33)
	acov_var34 = variance(acov_est34)
	acov_var35 = variance(acov_est35)
	acov_var36 = variance(acov_est36)
	acov_var37 = variance(acov_est37)
	acov_var38 = variance(acov_est38)
	acov_var39 = variance(acov_est39)
	
	acor_var = variance(acor_est)
	acor_var21 = variance(acor_est21)
	acor_var22 = variance(acor_est22)
	acor_var31 = variance(acor_est31)
	acor_var32 = variance(acor_est32)
	acor_var33 = variance(acor_est33)
	acor_var34 = variance(acor_est34)
	acor_var35 = variance(acor_est35)
	acor_var36 = variance(acor_est36)
	acor_var37 = variance(acor_est37)
	acor_var38 = variance(acor_est38)
	acor_var39 = variance(acor_est39)
	
	mean_acov_cor = correlation((mean_est, acov_est))[2,1]
	mean_acov_cor21 = correlation((mean_est21, acov_est21))[2,1]
	mean_acov_cor22 = correlation((mean_est22, acov_est22))[2,1]
	mean_acov_cor31 = correlation((mean_est31, acov_est31))[2,1]
	mean_acov_cor32 = correlation((mean_est32, acov_est32))[2,1]
	mean_acov_cor33 = correlation((mean_est33, acov_est33))[2,1]
	mean_acov_cor34 = correlation((mean_est34, acov_est34))[2,1]
	mean_acov_cor35 = correlation((mean_est35, acov_est35))[2,1]
	mean_acov_cor36 = correlation((mean_est36, acov_est36))[2,1]
	mean_acov_cor37 = correlation((mean_est37, acov_est37))[2,1]
	mean_acov_cor38 = correlation((mean_est38, acov_est38))[2,1]
	mean_acov_cor39 = correlation((mean_est39, acov_est39))[2,1]
	
	mean_acor_cor = correlation((mean_est, acor_est))[2,1]
	mean_acor_cor21 = correlation((mean_est21, acor_est21))[2,1]
	mean_acor_cor22 = correlation((mean_est22, acor_est22))[2,1]
	mean_acor_cor31 = correlation((mean_est31, acor_est31))[2,1]
	mean_acor_cor32 = correlation((mean_est32, acor_est32))[2,1]
	mean_acor_cor33 = correlation((mean_est33, acor_est33))[2,1]
	mean_acor_cor34 = correlation((mean_est34, acor_est34))[2,1]
	mean_acor_cor35 = correlation((mean_est35, acor_est35))[2,1]
	mean_acor_cor36 = correlation((mean_est36, acor_est36))[2,1]
	mean_acor_cor37 = correlation((mean_est37, acor_est37))[2,1]
	mean_acor_cor38 = correlation((mean_est38, acor_est38))[2,1]
	mean_acor_cor39 = correlation((mean_est39, acor_est39))[2,1]
	
	acov_acor_cor = correlation((acov_est, acor_est))[2,1]
	acov_acor_cor21 = correlation((acov_est21, acor_est21))[2,1]
	acov_acor_cor22 = correlation((acov_est22, acor_est22))[2,1]
	acov_acor_cor31 = correlation((acov_est31, acor_est31))[2,1]
	acov_acor_cor32 = correlation((acov_est32, acor_est32))[2,1]
	acov_acor_cor33 = correlation((acov_est33, acor_est33))[2,1]
	acov_acor_cor34 = correlation((acov_est34, acor_est34))[2,1]
	acov_acor_cor35 = correlation((acov_est35, acor_est35))[2,1]
	acov_acor_cor36 = correlation((acov_est36, acor_est36))[2,1]
	acov_acor_cor37 = correlation((acov_est37, acor_est37))[2,1]
	acov_acor_cor38 = correlation((acov_est38, acor_est38))[2,1]
	acov_acor_cor39 = correlation((acov_est39, acor_est39))[2,1]
	
	est = (mean_mean, acov_mean, acor_mean, mean_var, acov_var, acor_var, mean_acov_cor, mean_acor_cor, acov_acor_cor)
	est21 = (mean_mean21, acov_mean21, acor_mean21, mean_var21, acov_var21, acor_var21, mean_acov_cor21, mean_acor_cor21, acov_acor_cor21)
	est22 = (mean_mean22, acov_mean22, acor_mean22, mean_var22, acov_var22, acor_var22, mean_acov_cor22, mean_acor_cor22, acov_acor_cor22)
    est31 = (mean_mean31, acov_mean31, acor_mean31, mean_var31, acov_var31, acor_var31, mean_acov_cor31, mean_acor_cor31, acov_acor_cor31)
	est32 = (mean_mean32, acov_mean32, acor_mean32, mean_var32, acov_var32, acor_var32, mean_acov_cor32, mean_acor_cor32, acov_acor_cor32)
    est33 = (mean_mean33, acov_mean33, acor_mean33, mean_var33, acov_var33, acor_var33, mean_acov_cor33, mean_acor_cor33, acov_acor_cor33)
	est34 = (mean_mean34, acov_mean34, acor_mean34, mean_var34, acov_var34, acor_var34, mean_acov_cor34, mean_acor_cor34, acov_acor_cor34)
	est35 = (mean_mean35, acov_mean35, acor_mean35, mean_var35, acov_var35, acor_var35, mean_acov_cor35, mean_acor_cor35, acov_acor_cor35)
    est36 = (mean_mean36, acov_mean36, acor_mean36, mean_var36, acov_var36, acor_var36, mean_acov_cor36, mean_acor_cor36, acov_acor_cor36)
	est37 = (mean_mean37, acov_mean37, acor_mean37, mean_var37, acov_var37, acor_var37, mean_acov_cor37, mean_acor_cor37, acov_acor_cor37)
	est38 = (mean_mean38, acov_mean38, acor_mean38, mean_var38, acov_var38, acor_var38, mean_acov_cor38, mean_acor_cor38, acov_acor_cor38)
    est39 = (mean_mean39, acov_mean39, acor_mean39, mean_var39, acov_var39, acor_var39, mean_acov_cor39, mean_acor_cor39, acov_acor_cor39)
	
	// TOJ estimate
	tojest = 3.536 * est - 4.072 * (est21 + est22) / 2 + 1.536 * (est31 + est32 + est33 + est34 + est35 + est36 + est37 + est38 + est39) / 9

	return(tojest)
}

function tojmomentest5(quantity, indices){

	mean_est = quantity[indices, 1]
	mean_est21 = quantity[indices, 2]
	mean_est22 = quantity[indices, 3]
	mean_est23 = quantity[indices, 4]
	mean_est24 = quantity[indices, 5]	
	mean_est31 = quantity[indices, 6]
	mean_est32 = quantity[indices, 7]
	mean_est33 = quantity[indices, 8]
	mean_est34 = quantity[indices, 9]
	mean_est35 = quantity[indices, 10]
	mean_est36 = quantity[indices, 11]
	mean_est37 = quantity[indices, 12]
	mean_est38 = quantity[indices, 13]
	mean_est39 = quantity[indices, 14]
	
	acov_est = quantity[indices, 15]
	acov_est21 = quantity[indices, 16]
	acov_est22 = quantity[indices, 17]
	acov_est23 = quantity[indices, 18]
	acov_est24 = quantity[indices, 19]
	acov_est31 = quantity[indices, 20]
	acov_est32 = quantity[indices, 21]
	acov_est33 = quantity[indices, 22]
	acov_est34 = quantity[indices, 23]
	acov_est35 = quantity[indices, 24]
	acov_est36 = quantity[indices, 25]
	acov_est37 = quantity[indices, 26]
	acov_est38 = quantity[indices, 27]
	acov_est39 = quantity[indices, 28]
	
	acor_est = quantity[indices, 29]
	acor_est21 = quantity[indices, 30]
	acor_est22 = quantity[indices, 31]
	acor_est23 = quantity[indices, 32]
	acor_est24 = quantity[indices, 33]
	acor_est31 = quantity[indices, 34]
	acor_est32 = quantity[indices, 35]
	acor_est33 = quantity[indices, 36]
	acor_est34 = quantity[indices, 37]
	acor_est35 = quantity[indices, 38]
	acor_est36 = quantity[indices, 39]
	acor_est37 = quantity[indices, 40]
	acor_est38 = quantity[indices, 41]
	acor_est39 = quantity[indices, 42]
	
	mean_mean = sum(mean_est) / length(mean_est)
	mean_mean21 = sum(mean_est21) / length(mean_est21)
	mean_mean22 = sum(mean_est22) / length(mean_est22)
	mean_mean23 = sum(mean_est23) / length(mean_est23)
	mean_mean24 = sum(mean_est24) / length(mean_est24)
	mean_mean31 = sum(mean_est31) / length(mean_est31)
	mean_mean32 = sum(mean_est32) / length(mean_est32)
	mean_mean33 = sum(mean_est33) / length(mean_est33)
	mean_mean34 = sum(mean_est34) / length(mean_est34)
	mean_mean35 = sum(mean_est35) / length(mean_est35)
	mean_mean36 = sum(mean_est36) / length(mean_est36)
	mean_mean37 = sum(mean_est37) / length(mean_est37)
	mean_mean38 = sum(mean_est38) / length(mean_est38)
	mean_mean39 = sum(mean_est39) / length(mean_est39)
	
	acov_mean = sum(acov_est) / length(acov_est)
	acov_mean21 = sum(acov_est21) / length(acov_est21)
	acov_mean22 = sum(acov_est22) / length(acov_est22)
	acov_mean23 = sum(acov_est23) / length(acov_est23)
	acov_mean24 = sum(acov_est24) / length(acov_est24)
	acov_mean31 = sum(acov_est31) / length(acov_est31)
	acov_mean32 = sum(acov_est32) / length(acov_est32)
	acov_mean33 = sum(acov_est33) / length(acov_est33)
	acov_mean34 = sum(acov_est34) / length(acov_est34)
	acov_mean35 = sum(acov_est35) / length(acov_est35)
	acov_mean36 = sum(acov_est36) / length(acov_est36)
	acov_mean37 = sum(acov_est37) / length(acov_est37)
	acov_mean38 = sum(acov_est38) / length(acov_est38)
	acov_mean39 = sum(acov_est39) / length(acov_est39)
	
	acor_mean = sum(acor_est) / length(acor_est)
	acor_mean21 = sum(acor_est21) / length(acor_est21)
	acor_mean22 = sum(acor_est22) / length(acor_est22)
	acor_mean23 = sum(acor_est23) / length(acor_est23)
	acor_mean24 = sum(acor_est24) / length(acor_est24)
	acor_mean31 = sum(acor_est31) / length(acor_est31)
	acor_mean32 = sum(acor_est32) / length(acor_est32)
	acor_mean33 = sum(acor_est33) / length(acor_est33)
	acor_mean34 = sum(acor_est34) / length(acor_est34)
	acor_mean35 = sum(acor_est35) / length(acor_est35)
	acor_mean36 = sum(acor_est36) / length(acor_est36)
	acor_mean37 = sum(acor_est37) / length(acor_est37)
	acor_mean38 = sum(acor_est38) / length(acor_est38)
	acor_mean39 = sum(acor_est39) / length(acor_est39)

	mean_var = variance(mean_est)
	mean_var21 = variance(mean_est21)
	mean_var22 = variance(mean_est22)
	mean_var23 = variance(mean_est23)
	mean_var24 = variance(mean_est24)
	mean_var31 = variance(mean_est31)
	mean_var32 = variance(mean_est32)
	mean_var33 = variance(mean_est33)
	mean_var34 = variance(mean_est34)
	mean_var35 = variance(mean_est35)
	mean_var36 = variance(mean_est36)
	mean_var37 = variance(mean_est37)
	mean_var38 = variance(mean_est38)
	mean_var39 = variance(mean_est39)
	
	acov_var = variance(acov_est)
	acov_var21 = variance(acov_est21)
	acov_var22 = variance(acov_est22)
	acov_var23 = variance(acov_est23)
	acov_var24 = variance(acov_est24)
	acov_var31 = variance(acov_est31)
	acov_var32 = variance(acov_est32)
	acov_var33 = variance(acov_est33)
	acov_var34 = variance(acov_est34)
	acov_var35 = variance(acov_est35)
	acov_var36 = variance(acov_est36)
	acov_var37 = variance(acov_est37)
	acov_var38 = variance(acov_est38)
	acov_var39 = variance(acov_est39)
	
	acor_var = variance(acor_est)
	acor_var21 = variance(acor_est21)
	acor_var22 = variance(acor_est22)
	acor_var23 = variance(acor_est23)
	acor_var24 = variance(acor_est24)
	acor_var31 = variance(acor_est31)
	acor_var32 = variance(acor_est32)
	acor_var33 = variance(acor_est33)
	acor_var34 = variance(acor_est34)
	acor_var35 = variance(acor_est35)
	acor_var36 = variance(acor_est36)
	acor_var37 = variance(acor_est37)
	acor_var38 = variance(acor_est38)
	acor_var39 = variance(acor_est39)
	
	mean_acov_cor = correlation((mean_est, acov_est))[2,1]
	mean_acov_cor21 = correlation((mean_est21, acov_est21))[2,1]
	mean_acov_cor22 = correlation((mean_est22, acov_est22))[2,1]
	mean_acov_cor23 = correlation((mean_est23, acov_est23))[2,1]
	mean_acov_cor24 = correlation((mean_est24, acov_est24))[2,1]
	mean_acov_cor31 = correlation((mean_est31, acov_est31))[2,1]
	mean_acov_cor32 = correlation((mean_est32, acov_est32))[2,1]
	mean_acov_cor33 = correlation((mean_est33, acov_est33))[2,1]
	mean_acov_cor34 = correlation((mean_est34, acov_est34))[2,1]
	mean_acov_cor35 = correlation((mean_est35, acov_est35))[2,1]
	mean_acov_cor36 = correlation((mean_est36, acov_est36))[2,1]
	mean_acov_cor37 = correlation((mean_est37, acov_est37))[2,1]
	mean_acov_cor38 = correlation((mean_est38, acov_est38))[2,1]
	mean_acov_cor39 = correlation((mean_est39, acov_est39))[2,1]
	
	mean_acor_cor = correlation((mean_est, acor_est))[2,1]
	mean_acor_cor21 = correlation((mean_est21, acor_est21))[2,1]
	mean_acor_cor22 = correlation((mean_est22, acor_est22))[2,1]
	mean_acor_cor23 = correlation((mean_est23, acor_est23))[2,1]
	mean_acor_cor24 = correlation((mean_est24, acor_est24))[2,1]
	mean_acor_cor31 = correlation((mean_est31, acor_est31))[2,1]
	mean_acor_cor32 = correlation((mean_est32, acor_est32))[2,1]
	mean_acor_cor33 = correlation((mean_est33, acor_est33))[2,1]
	mean_acor_cor34 = correlation((mean_est34, acor_est34))[2,1]
	mean_acor_cor35 = correlation((mean_est35, acor_est35))[2,1]
	mean_acor_cor36 = correlation((mean_est36, acor_est36))[2,1]
	mean_acor_cor37 = correlation((mean_est37, acor_est37))[2,1]
	mean_acor_cor38 = correlation((mean_est38, acor_est38))[2,1]
	mean_acor_cor39 = correlation((mean_est39, acor_est39))[2,1]
	
	acov_acor_cor = correlation((acov_est, acor_est))[2,1]
	acov_acor_cor21 = correlation((acov_est21, acor_est21))[2,1]
	acov_acor_cor22 = correlation((acov_est22, acor_est22))[2,1]
	acov_acor_cor23 = correlation((acov_est23, acor_est23))[2,1]
	acov_acor_cor24 = correlation((acov_est24, acor_est24))[2,1]
	acov_acor_cor31 = correlation((acov_est31, acor_est31))[2,1]
	acov_acor_cor32 = correlation((acov_est32, acor_est32))[2,1]
	acov_acor_cor33 = correlation((acov_est33, acor_est33))[2,1]
	acov_acor_cor34 = correlation((acov_est34, acor_est34))[2,1]
	acov_acor_cor35 = correlation((acov_est35, acor_est35))[2,1]
	acov_acor_cor36 = correlation((acov_est36, acor_est36))[2,1]
	acov_acor_cor37 = correlation((acov_est37, acor_est37))[2,1]
	acov_acor_cor38 = correlation((acov_est38, acor_est38))[2,1]
	acov_acor_cor39 = correlation((acov_est39, acor_est39))[2,1]
	
	est = (mean_mean, acov_mean, acor_mean, mean_var, acov_var, acor_var, mean_acov_cor, mean_acor_cor, acov_acor_cor)
	est21 = (mean_mean21, acov_mean21, acor_mean21, mean_var21, acov_var21, acor_var21, mean_acov_cor21, mean_acor_cor21, acov_acor_cor21)
	est22 = (mean_mean22, acov_mean22, acor_mean22, mean_var22, acov_var22, acor_var22, mean_acov_cor22, mean_acor_cor22, acov_acor_cor22)
    est23 = (mean_mean23, acov_mean23, acor_mean23, mean_var23, acov_var23, acor_var23, mean_acov_cor23, mean_acor_cor23, acov_acor_cor23)
	est24 = (mean_mean24, acov_mean24, acor_mean24, mean_var24, acov_var24, acor_var24, mean_acov_cor24, mean_acor_cor24, acov_acor_cor24)
    est31 = (mean_mean31, acov_mean31, acor_mean31, mean_var31, acov_var31, acor_var31, mean_acov_cor31, mean_acor_cor31, acov_acor_cor31)
	est32 = (mean_mean32, acov_mean32, acor_mean32, mean_var32, acov_var32, acor_var32, mean_acov_cor32, mean_acor_cor32, acov_acor_cor32)
    est33 = (mean_mean33, acov_mean33, acor_mean33, mean_var33, acov_var33, acor_var33, mean_acov_cor33, mean_acor_cor33, acov_acor_cor33)
	est34 = (mean_mean34, acov_mean34, acor_mean34, mean_var34, acov_var34, acor_var34, mean_acov_cor34, mean_acor_cor34, acov_acor_cor34)
	est35 = (mean_mean35, acov_mean35, acor_mean35, mean_var35, acov_var35, acor_var35, mean_acov_cor35, mean_acor_cor35, acov_acor_cor35)
    est36 = (mean_mean36, acov_mean36, acor_mean36, mean_var36, acov_var36, acor_var36, mean_acov_cor36, mean_acor_cor36, acov_acor_cor36)
	est37 = (mean_mean37, acov_mean37, acor_mean37, mean_var37, acov_var37, acor_var37, mean_acov_cor37, mean_acor_cor37, acov_acor_cor37)
	est38 = (mean_mean38, acov_mean38, acor_mean38, mean_var38, acov_var38, acor_var38, mean_acov_cor38, mean_acor_cor38, acov_acor_cor38)
    est39 = (mean_mean39, acov_mean39, acor_mean39, mean_var39, acov_var39, acor_var39, mean_acov_cor39, mean_acor_cor39, acov_acor_cor39)
	
	// TOJ estimate
	tojest = 3.536 * est - 4.072 * (est21 + est22 + est23 + est24) / 4 + 1.536 * (est31 + est32 + est33 + est34 + est35 + est36 + est37 + est38 + est39) / 9

	return(tojest)
}

function m_tojmoment(data, acov_order, acor_order, B){
	N = rows(data)
	S = cols(data)
	
	mean_est = J(N, 1, 0)
	acov_est = J(N, 1, 0)
	acor_est = J(N, 1, 0)
	
	for (i=1; i<=N; i++){
	    mean_est[i] = mean(data[i,.]')
		acov_est[i] = mataacov(data[i,.], acov_order)
		acor_est[i] = mataacor(data[i,.], acor_order)
	}
	
	if (mod(S,6) == 0) {
	    data21 = data[., 1::(S / 2)]
		data22 = data[., (S / 2 + 1)::S]
		data31 = data[., 1::(S / 3)]
		data32 = data[., (S / 3 + 1)::(2*S / 3)]
		data33 = data[., (2 * S / 3 + 1)::S]
	    
		mean_est21 = J(N,1,0)
		mean_est22 = J(N,1,0)
		mean_est31 = J(N,1,0)
		mean_est32 = J(N,1,0)
		mean_est33 = J(N,1,0)
	
		acov_est21 = J(N,1,0)
		acov_est22 = J(N,1,0)
		acov_est31 = J(N,1,0)
		acov_est32 = J(N,1,0)
		acov_est33 = J(N,1,0)
        
		acor_est21 = J(N,1,0)
		acor_est22 = J(N,1,0)
		acor_est31 = J(N,1,0)
		acor_est32 = J(N,1,0)
		acor_est33 = J(N,1,0)
		
		for (i=1 ; i<=N ; i++){
			mean_est21[i] = mean(data21[i,.]')
			mean_est22[i] = mean(data22[i,.]')
			mean_est31[i] = mean(data31[i,.]')
			mean_est32[i] = mean(data32[i,.]')
			mean_est33[i] = mean(data33[i,.]')
	
			acov_est21[i] = mataacov(data21[i,.], acov_order) 
			acov_est22[i] = mataacov(data22[i,.], acov_order)
			acov_est31[i] = mataacov(data31[i,.], acov_order)
			acov_est32[i] = mataacov(data32[i,.], acov_order)
			acov_est33[i] = mataacov(data33[i,.], acov_order)
		    
			acor_est21[i] = mataacor(data21[i,.], acor_order)
			acor_est22[i] = mataacor(data22[i,.], acor_order)
			acor_est31[i] = mataacor(data31[i,.], acor_order)
			acor_est32[i] = mataacor(data32[i,.], acor_order)
			acor_est33[i] = mataacor(data33[i,.], acor_order)
		}
		
		equantity = (mean_est, mean_est21, mean_est22, mean_est31, mean_est32, ///
				mean_est33, acov_est, acov_est21, acov_est22, acov_est31, acov_est32, ///
				acov_est33, acor_est, acor_est21, acor_est22, acor_est31, acor_est32, acor_est33)
		estimate_value = tojmomentest0(equantity, 1::N)
	
		number_par = length(estimate_value)
		estimate_boot = J(B, number_par, 0)
		
		for (b = 1; b <= B; b++) {
			index_boot = rdiscrete(N, 1, J(N, 1, 1/N))
			estimate_boot[b,] = tojmomentest0(equantity, index_boot)
		}
		
		se = sqrt(diagonal(variance(estimate_boot)))
		quantile_boot_1 = mm_quantile(estimate_boot, 1, 0.975)
		quantile_boot_2 = mm_quantile(estimate_boot, 1, 0.025)	
		ci_1 = 2 * estimate_value - quantile_boot_1
		ci_2 = 2 * estimate_value - quantile_boot_2
		ci = (ci_1 \ ci_2)
		result =  (estimate_value', se, ci')
		
	} else if (mod(S,6)==1){

    // split  panel data for T equivalent to 1 modulo 6
		data21 = data[., 1::floor(S / 2)]
		data22 = data[., (floor(S / 2) + 1)::S]
		data23 = data[., 1::ceil(S / 2)]
		data24 = data[., (ceil(S / 2) + 1)::S]
		data31 = data[., 1::floor(S / 3)]
		data32 = data[., (floor(S / 3) + 1)::(2 * floor(S / 3))]
		data33 = data[., (2 * floor(S / 3) + 1)::S]
		data34 = data[., 1::floor(S / 3)]
		data35 = data[., (floor(S / 3) + 1)::(2 * floor(S / 3) + 1)]
		data36 = data[., (2 * floor(S / 3) + 2)::S]
		data37 = data[., 1::ceil(S / 3)]
		data38 = data[., (ceil(S / 3) + 1)::(2 * floor(S / 3) + 1)]
		data39 = data[., (2 * floor(S / 3) + 2)::S]

     // estimated quantities for split panel data
		mean_est21 = J(N,1,0)
		mean_est22 = J(N,1,0)
		mean_est23 = J(N,1,0)
		mean_est24 = J(N,1,0)
		mean_est31 = J(N,1,0)
		mean_est32 = J(N,1,0)
		mean_est33 = J(N,1,0)
		mean_est34 = J(N,1,0)
		mean_est35 = J(N,1,0)
		mean_est36 = J(N,1,0)
		mean_est37 = J(N,1,0)
		mean_est38 = J(N,1,0)
		mean_est39 = J(N,1,0)
    
        acov_est21 = J(N,1,0)
		acov_est22 = J(N,1,0)
		acov_est23 = J(N,1,0)
		acov_est24 = J(N,1,0)
		acov_est31 = J(N,1,0)
		acov_est32 = J(N,1,0)
		acov_est33 = J(N,1,0)
		acov_est34 = J(N,1,0)
		acov_est35 = J(N,1,0)
		acov_est36 = J(N,1,0)
		acov_est37 = J(N,1,0)
		acov_est38 = J(N,1,0)
		acov_est39 = J(N,1,0)
		
	    acor_est21 = J(N,1,0)
		acor_est22 = J(N,1,0)
		acor_est23 = J(N,1,0)
		acor_est24 = J(N,1,0)
		acor_est31 = J(N,1,0)
		acor_est32 = J(N,1,0)
		acor_est33 = J(N,1,0)
		acor_est34 = J(N,1,0)
		acor_est35 = J(N,1,0)
		acor_est36 = J(N,1,0)
		acor_est37 = J(N,1,0)
		acor_est38 = J(N,1,0)
		acor_est39 = J(N,1,0)

        for (i=1 ; i<=N ; i++){
			mean_est21[i] = mean(data21[i,.]')
			mean_est22[i] = mean(data22[i,.]')
			mean_est23[i] = mean(data23[i,.]')
			mean_est24[i] = mean(data24[i,.]')
			mean_est31[i] = mean(data31[i,.]')
			mean_est32[i] = mean(data32[i,.]')
			mean_est33[i] = mean(data33[i,.]')
		    mean_est34[i] = mean(data34[i,.]')
			mean_est35[i] = mean(data35[i,.]')
			mean_est36[i] = mean(data36[i,.]')
		    mean_est37[i] = mean(data37[i,.]')
			mean_est38[i] = mean(data38[i,.]')
			mean_est39[i] = mean(data39[i,.]')
		
			acov_est21[i] = mataacov(data21[i,.], acov_order) 
			acov_est22[i] = mataacov(data22[i,.], acov_order)
			acov_est23[i] = mataacov(data23[i,.], acov_order) 
			acov_est24[i] = mataacov(data24[i,.], acov_order)
			acov_est31[i] = mataacov(data31[i,.], acov_order)
			acov_est32[i] = mataacov(data32[i,.], acov_order)
			acov_est33[i] = mataacov(data33[i,.], acov_order)
			acov_est34[i] = mataacov(data34[i,.], acov_order)
            acov_est35[i] = mataacov(data35[i,.], acov_order)
			acov_est36[i] = mataacov(data36[i,.], acov_order)
			acov_est37[i] = mataacov(data37[i,.], acov_order)
            acov_est38[i] = mataacov(data38[i,.], acov_order)
			acov_est39[i] = mataacov(data39[i,.], acov_order)
                
			acor_est21[i] = mataacor(data21[i,.], acor_order)
			acor_est22[i] = mataacor(data22[i,.], acor_order)
			acor_est23[i] = mataacor(data23[i,.], acor_order)
			acor_est24[i] = mataacor(data24[i,.], acor_order)
			acor_est31[i] = mataacor(data31[i,.], acor_order)
			acor_est32[i] = mataacor(data32[i,.], acor_order)
			acor_est33[i] = mataacor(data33[i,.], acor_order)
			acor_est34[i] = mataacor(data34[i,.], acor_order)
			acor_est35[i] = mataacor(data35[i,.], acor_order)
			acor_est36[i] = mataacor(data36[i,.], acor_order)
			acor_est37[i] = mataacor(data37[i,.], acor_order)
			acor_est38[i] = mataacor(data38[i,.], acor_order)
			acor_est39[i] = mataacor(data39[i,.], acor_order)	
		}
		
		equantity = (mean_est, mean_est21, mean_est22, mean_est23, mean_est24, mean_est31, mean_est32, mean_est33, mean_est34, mean_est35,  ///
					mean_est36, mean_est37, mean_est38, mean_est39, acov_est, acov_est21, acov_est22, acov_est23, acov_est24, acov_est31,   ///
					acov_est32, acov_est33, acov_est34, acov_est35, acov_est36, acov_est37, acov_est38, acov_est39, acor_est, acor_est21,   ///
					acor_est22, acor_est23, acor_est24, acor_est31, acor_est32, acor_est33, acor_est34, acor_est35, acor_est36, acor_est37, ///
					acor_est38, acor_est39)
		estimate_value = tojmomentest1(equantity, 1::N)
	
		number_par = length(estimate_value)
		estimate_boot = J(B, number_par, 0)
		
		for (b = 1; b <= B; b++) {
			index_boot = rdiscrete(N, 1, J(N, 1, 1/N))
			estimate_boot[b,] = tojmomentest1(equantity, index_boot)
		}
		
		se = sqrt(diagonal(variance(estimate_boot)))
		quantile_boot_1 = mm_quantile(estimate_boot, 1, 0.975)
		quantile_boot_2 = mm_quantile(estimate_boot, 1, 0.025)	
		ci_1 = 2 * estimate_value - quantile_boot_1
		ci_2 = 2 * estimate_value - quantile_boot_2
		ci = (ci_1 \ ci_2)
		result =  (estimate_value', se, ci')
		
	} else if (mod(S,6)==2){
    
    // split  panel data for T equivalent to 2 modulo 6
		data21 = data[., 1::(S / 2)]
		data22 = data[., (S / 2 + 1)::S]
		data31 = data[., 1::floor(S / 3)]
		data32 = data[., (floor(S / 3) + 1)::(2 * floor(S / 3) + 1) ]
		data33 = data[., (2 * ceil(S / 3))::S]
		data34 = data[., 1::ceil(S / 3)]
		data35 = data[., (ceil(S / 3) + 1)::(2 * floor(S / 3) + 1)]
		data36 = data[., (2 * ceil(S / 3))::S]
		data37 = data[., 1::ceil(S / 3)]
		data38 = data[., (ceil(S / 3) + 1)::(2 * ceil(S / 3))]
		data39 = data[., (2 * ceil(S / 3) + 1)::S]

    // estimated quantities for split panel data
		mean_est21 = J(N,1,0)
		mean_est22 = J(N,1,0)
		mean_est31 = J(N,1,0)
		mean_est32 = J(N,1,0)
		mean_est33 = J(N,1,0)
		mean_est34 = J(N,1,0)
		mean_est35 = J(N,1,0)
		mean_est36 = J(N,1,0)
		mean_est37 = J(N,1,0)
		mean_est38 = J(N,1,0)
		mean_est39 = J(N,1,0)
    
        acov_est21 = J(N,1,0)
		acov_est22 = J(N,1,0)
		acov_est31 = J(N,1,0)
		acov_est32 = J(N,1,0)
		acov_est33 = J(N,1,0)
		acov_est34 = J(N,1,0)
		acov_est35 = J(N,1,0)
		acov_est36 = J(N,1,0)
		acov_est37 = J(N,1,0)
		acov_est38 = J(N,1,0)
		acov_est39 = J(N,1,0)
		
	    acor_est21 = J(N,1,0)
		acor_est22 = J(N,1,0)
		acor_est31 = J(N,1,0)
		acor_est32 = J(N,1,0)
		acor_est33 = J(N,1,0)
		acor_est34 = J(N,1,0)
		acor_est35 = J(N,1,0)
		acor_est36 = J(N,1,0)
		acor_est37 = J(N,1,0)
		acor_est38 = J(N,1,0)
		acor_est39 = J(N,1,0)

        for (i=1 ; i<=N ; i++){
			mean_est21[i] = mean(data21[i,.]')
			mean_est22[i] = mean(data22[i,.]')
			mean_est31[i] = mean(data31[i,.]')
			mean_est32[i] = mean(data32[i,.]')
			mean_est33[i] = mean(data33[i,.]')
		    mean_est34[i] = mean(data34[i,.]')
			mean_est35[i] = mean(data35[i,.]')
			mean_est36[i] = mean(data36[i,.]')
		    mean_est37[i] = mean(data37[i,.]')
			mean_est38[i] = mean(data38[i,.]')
			mean_est39[i] = mean(data39[i,.]')
		
			acov_est21[i] = mataacov(data21[i,.], acov_order) 
			acov_est22[i] = mataacov(data22[i,.], acov_order)
			acov_est31[i] = mataacov(data31[i,.], acov_order)
			acov_est32[i] = mataacov(data32[i,.], acov_order)
			acov_est33[i] = mataacov(data33[i,.], acov_order)
			acov_est34[i] = mataacov(data34[i,.], acov_order)
            acov_est35[i] = mataacov(data35[i,.], acov_order)
			acov_est36[i] = mataacov(data36[i,.], acov_order)
			acov_est37[i] = mataacov(data37[i,.], acov_order)
            acov_est38[i] = mataacov(data38[i,.], acov_order)
			acov_est39[i] = mataacov(data39[i,.], acov_order)
                
			acor_est21[i] = mataacor(data21[i,.], acor_order)
			acor_est22[i] = mataacor(data22[i,.], acor_order)
			acor_est31[i] = mataacor(data31[i,.], acor_order)
			acor_est32[i] = mataacor(data32[i,.], acor_order)
			acor_est33[i] = mataacor(data33[i,.], acor_order)
			acor_est34[i] = mataacor(data34[i,.], acor_order)
			acor_est35[i] = mataacor(data35[i,.], acor_order)
			acor_est36[i] = mataacor(data36[i,.], acor_order)
			acor_est37[i] = mataacor(data37[i,.], acor_order)
			acor_est38[i] = mataacor(data38[i,.], acor_order)
			acor_est39[i] = mataacor(data39[i,.], acor_order)	
		}
		
		equantity = (mean_est, mean_est21, mean_est22, mean_est31, mean_est32, mean_est33, mean_est34, mean_est35,  ///
					mean_est36, mean_est37, mean_est38, mean_est39, acov_est, acov_est21, acov_est22, acov_est31,   ///
					acov_est32, acov_est33, acov_est34, acov_est35, acov_est36, acov_est37, acov_est38, acov_est39, acor_est, acor_est21,   ///
					acor_est22, acor_est31, acor_est32, acor_est33, acor_est34, acor_est35, acor_est36, acor_est37, ///
					acor_est38, acor_est39)
		estimate_value = tojmomentest2(equantity, 1::N)
	
		number_par = length(estimate_value)
		estimate_boot = J(B, number_par, 0)
		
		for (b = 1; b <= B; b++) {
			index_boot = rdiscrete(N, 1, J(N, 1, 1/N))
			estimate_boot[b,] = tojmomentest2(equantity, index_boot)
		}
		
		se = sqrt(diagonal(variance(estimate_boot)))
		quantile_boot_1 = mm_quantile(estimate_boot, 1, 0.975)
		quantile_boot_2 = mm_quantile(estimate_boot, 1, 0.025)	
		ci_1 = 2 * estimate_value - quantile_boot_1
		ci_2 = 2 * estimate_value - quantile_boot_2
		ci = (ci_1 \ ci_2)
		result =  (estimate_value', se, ci')
		
	} else if (mod(S,6) == 3) {
    
		// split  panel data for T equivalent to 3 modulo 6
		data21 = data[., 1::floor(S / 2)]
		data22 = data[., (floor(S / 2) + 1)::S]
		data23 = data[., 1::ceil(S / 2)]
		data24 = data[., (ceil(S / 2) + 1)::S]
		data31 = data[., 1::(S / 3)]
		data32 = data[., (S / 3 + 1)::(2*S / 3)]
		data33 = data[., (2 * S / 3 + 1)::S]

		// estimated quantities for split panel data
		mean_est21 = J(N,1,0)
		mean_est22 = J(N,1,0)
		mean_est23 = J(N,1,0)
		mean_est24 = J(N,1,0)
		mean_est31 = J(N,1,0)
		mean_est32 = J(N,1,0)
		mean_est33 = J(N,1,0)
    
        acov_est21 = J(N,1,0)
		acov_est22 = J(N,1,0)
		acov_est23 = J(N,1,0)
		acov_est24 = J(N,1,0)
		acov_est31 = J(N,1,0)
		acov_est32 = J(N,1,0)
		acov_est33 = J(N,1,0)
		
	    acor_est21 = J(N,1,0)
		acor_est22 = J(N,1,0)
		acor_est23 = J(N,1,0)
		acor_est24 = J(N,1,0)
		acor_est31 = J(N,1,0)
		acor_est32 = J(N,1,0)
		acor_est33 = J(N,1,0)

        for (i=1 ; i<=N ; i++){
			mean_est21[i] = mean(data21[i,.]')
			mean_est22[i] = mean(data22[i,.]')
			mean_est23[i] = mean(data23[i,.]')
			mean_est24[i] = mean(data24[i,.]')
			mean_est31[i] = mean(data31[i,.]')
			mean_est32[i] = mean(data32[i,.]')
			mean_est33[i] = mean(data33[i,.]')
		
			acov_est21[i] = mataacov(data21[i,.], acov_order) 
			acov_est22[i] = mataacov(data22[i,.], acov_order)
			acov_est23[i] = mataacov(data23[i,.], acov_order) 
			acov_est24[i] = mataacov(data24[i,.], acov_order)
			acov_est31[i] = mataacov(data31[i,.], acov_order)
			acov_est32[i] = mataacov(data32[i,.], acov_order)
			acov_est33[i] = mataacov(data33[i,.], acov_order)
                
			acor_est21[i] = mataacor(data21[i,.], acor_order)
			acor_est22[i] = mataacor(data22[i,.], acor_order)
			acor_est23[i] = mataacor(data23[i,.], acor_order)
			acor_est24[i] = mataacor(data24[i,.], acor_order)
			acor_est31[i] = mataacor(data31[i,.], acor_order)
			acor_est32[i] = mataacor(data32[i,.], acor_order)
			acor_est33[i] = mataacor(data33[i,.], acor_order)	
		}
		
		equantity = (mean_est, mean_est21, mean_est22, mean_est23, mean_est24, mean_est31, mean_est32, mean_est33, ///
					acov_est, acov_est21, acov_est22, acov_est23, acov_est24, acov_est31,   ///
					acov_est32, acov_est33, acor_est, acor_est21,   ///
					acor_est22, acor_est23, acor_est24, acor_est31, acor_est32, acor_est33)
		estimate_value = tojmomentest3(equantity, 1::N)
	
		number_par = length(estimate_value)
		estimate_boot = J(B, number_par, 0)
		
		for (b = 1; b <= B; b++) {
			index_boot = rdiscrete(N, 1, J(N, 1, 1/N))
			estimate_boot[b,] = tojmomentest3(equantity, index_boot)
		}
		
		se = sqrt(diagonal(variance(estimate_boot)))
		quantile_boot_1 = mm_quantile(estimate_boot, 1, 0.975)
		quantile_boot_2 = mm_quantile(estimate_boot, 1, 0.025)	
		ci_1 = 2 * estimate_value - quantile_boot_1
		ci_2 = 2 * estimate_value - quantile_boot_2
		ci = (ci_1 \ ci_2)
		result =  (estimate_value', se, ci')
		
	} else if (mod(S,6)==4) {

    // split  panel data for T equivalent to 4 modulo 6
		data21 = data[., 1::(S / 2)]
		data22 = data[., (S / 2 + 1)::S]
		data31 = data[., 1::floor(S / 3)]
		data32 = data[., (floor(S / 3) + 1)::(2 * floor(S / 3))]
		data33 = data[., (2 * floor(S / 3) + 1)::S]
		data34 = data[., 1::floor(S / 3)]
		data35 = data[., (floor(S / 3) + 1)::(2 * floor(S / 3) + 1)]
		data36 = data[., (2 * floor(S / 3) + 2)::S]
		data37 = data[., 1::ceil(S / 3)]
		data38 = data[., (ceil(S / 3) + 1)::(2 * floor(S / 3) + 1)]
		data39 = data[., (2 * floor(S / 3) + 2)::S]

        // estimated quantities for split panel data
		mean_est21 = J(N,1,0)
		mean_est22 = J(N,1,0)
		mean_est31 = J(N,1,0)
		mean_est32 = J(N,1,0)
		mean_est33 = J(N,1,0)
		mean_est34 = J(N,1,0)
		mean_est35 = J(N,1,0)
		mean_est36 = J(N,1,0)
		mean_est37 = J(N,1,0)
		mean_est38 = J(N,1,0)
		mean_est39 = J(N,1,0)
    
        acov_est21 = J(N,1,0)
		acov_est22 = J(N,1,0)
		acov_est31 = J(N,1,0)
		acov_est32 = J(N,1,0)
		acov_est33 = J(N,1,0)
		acov_est34 = J(N,1,0)
		acov_est35 = J(N,1,0)
		acov_est36 = J(N,1,0)
		acov_est37 = J(N,1,0)
		acov_est38 = J(N,1,0)
		acov_est39 = J(N,1,0)
		
	    acor_est21 = J(N,1,0)
		acor_est22 = J(N,1,0)
		acor_est31 = J(N,1,0)
		acor_est32 = J(N,1,0)
		acor_est33 = J(N,1,0)
		acor_est34 = J(N,1,0)
		acor_est35 = J(N,1,0)
		acor_est36 = J(N,1,0)
		acor_est37 = J(N,1,0)
		acor_est38 = J(N,1,0)
		acor_est39 = J(N,1,0)

        for (i=1 ; i<=N ; i++){
			mean_est21[i] = mean(data21[i,.]')
			mean_est22[i] = mean(data22[i,.]')
			mean_est31[i] = mean(data31[i,.]')
			mean_est32[i] = mean(data32[i,.]')
			mean_est33[i] = mean(data33[i,.]')
		    mean_est34[i] = mean(data34[i,.]')
			mean_est35[i] = mean(data35[i,.]')
			mean_est36[i] = mean(data36[i,.]')
		    mean_est37[i] = mean(data37[i,.]')
			mean_est38[i] = mean(data38[i,.]')
			mean_est39[i] = mean(data39[i,.]')
		
			acov_est21[i] = mataacov(data21[i,.], acov_order) 
			acov_est22[i] = mataacov(data22[i,.], acov_order)
			acov_est31[i] = mataacov(data31[i,.], acov_order)
			acov_est32[i] = mataacov(data32[i,.], acov_order)
			acov_est33[i] = mataacov(data33[i,.], acov_order)
			acov_est34[i] = mataacov(data34[i,.], acov_order)
            acov_est35[i] = mataacov(data35[i,.], acov_order)
			acov_est36[i] = mataacov(data36[i,.], acov_order)
			acov_est37[i] = mataacov(data37[i,.], acov_order)
            acov_est38[i] = mataacov(data38[i,.], acov_order)
			acov_est39[i] = mataacov(data39[i,.], acov_order)
                
			acor_est21[i] = mataacor(data21[i,.], acor_order)
			acor_est22[i] = mataacor(data22[i,.], acor_order)
			acor_est31[i] = mataacor(data31[i,.], acor_order)
			acor_est32[i] = mataacor(data32[i,.], acor_order)
			acor_est33[i] = mataacor(data33[i,.], acor_order)
			acor_est34[i] = mataacor(data34[i,.], acor_order)
			acor_est35[i] = mataacor(data35[i,.], acor_order)
			acor_est36[i] = mataacor(data36[i,.], acor_order)
			acor_est37[i] = mataacor(data37[i,.], acor_order)
			acor_est38[i] = mataacor(data38[i,.], acor_order)
			acor_est39[i] = mataacor(data39[i,.], acor_order)	
		}
		
		equantity = (mean_est, mean_est21, mean_est22, mean_est31, mean_est32, mean_est33, mean_est34, mean_est35,  ///
					mean_est36, mean_est37, mean_est38, mean_est39, acov_est, acov_est21, acov_est22, acov_est31,   ///
					acov_est32, acov_est33, acov_est34, acov_est35, acov_est36, acov_est37, acov_est38, acov_est39, acor_est, acor_est21,   ///
					acor_est22, acor_est31, acor_est32, acor_est33, acor_est34, acor_est35, acor_est36, acor_est37, ///
					acor_est38, acor_est39)
		estimate_value = tojmomentest4(equantity, 1::N)
	
		number_par = length(estimate_value)
		estimate_boot = J(B, number_par, 0)
		
		for (b = 1; b <= B; b++) {
			index_boot = rdiscrete(N, 1, J(N, 1, 1/N))
			estimate_boot[b,] = tojmomentest4(equantity, index_boot)
		}
		
		se = sqrt(diagonal(variance(estimate_boot)))
		quantile_boot_1 = mm_quantile(estimate_boot, 1, 0.975)
		quantile_boot_2 = mm_quantile(estimate_boot, 1, 0.025)	
		ci_1 = 2 * estimate_value - quantile_boot_1
		ci_2 = 2 * estimate_value - quantile_boot_2
		ci = (ci_1 \ ci_2)
		result =  (estimate_value', se, ci')
		
	} else {

		// split  panel data for T equivalent to 5 modulo 6
		data21 = data[., 1::floor(S / 2)]
		data22 = data[., (floor(S / 2) + 1)::S]
		data23 = data[., 1::ceil(S / 2)]
		data24 = data[., (ceil(S / 2) + 1)::S]
		data31 = data[., 1::floor(S / 3)]
		data32 = data[., (floor(S / 3) + 1)::(2 * floor(S / 3) + 1) ]
		data33 = data[., (2 * ceil(S / 3))::S]
		data34 = data[., 1::ceil(S / 3)]
		data35 = data[., (ceil(S / 3) + 1)::(2 * floor(S / 3) + 1)]
		data36 = data[., (2 * ceil(S / 3))::S]
		data37 = data[., 1::ceil(S / 3)]
		data38 = data[., (ceil(S / 3) + 1)::(2 * ceil(S / 3))]
		data39 = data[., (2 * ceil(S / 3) + 1)::S]
        
		// estimated quantities for split panel data
		mean_est21 = J(N,1,0)
		mean_est22 = J(N,1,0)
		mean_est23 = J(N,1,0)
		mean_est24 = J(N,1,0)
		mean_est31 = J(N,1,0)
		mean_est32 = J(N,1,0)
		mean_est33 = J(N,1,0)
		mean_est34 = J(N,1,0)
		mean_est35 = J(N,1,0)
		mean_est36 = J(N,1,0)
		mean_est37 = J(N,1,0)
		mean_est38 = J(N,1,0)
		mean_est39 = J(N,1,0)
    
        acov_est21 = J(N,1,0)
		acov_est22 = J(N,1,0)
		acov_est23 = J(N,1,0)
		acov_est24 = J(N,1,0)
		acov_est31 = J(N,1,0)
		acov_est32 = J(N,1,0)
		acov_est33 = J(N,1,0)
		acov_est34 = J(N,1,0)
		acov_est35 = J(N,1,0)
		acov_est36 = J(N,1,0)
		acov_est37 = J(N,1,0)
		acov_est38 = J(N,1,0)
		acov_est39 = J(N,1,0)
		
	    acor_est21 = J(N,1,0)
		acor_est22 = J(N,1,0)
		acor_est23 = J(N,1,0)
		acor_est24 = J(N,1,0)
		acor_est31 = J(N,1,0)
		acor_est32 = J(N,1,0)
		acor_est33 = J(N,1,0)
		acor_est34 = J(N,1,0)
		acor_est35 = J(N,1,0)
		acor_est36 = J(N,1,0)
		acor_est37 = J(N,1,0)
		acor_est38 = J(N,1,0)
		acor_est39 = J(N,1,0)

        for (i=1 ; i<=N ; i++){
			mean_est21[i] = mean(data21[i,.]')
			mean_est22[i] = mean(data22[i,.]')
			mean_est23[i] = mean(data23[i,.]')
			mean_est24[i] = mean(data24[i,.]')
			mean_est31[i] = mean(data31[i,.]')
			mean_est32[i] = mean(data32[i,.]')
			mean_est33[i] = mean(data33[i,.]')
		    mean_est34[i] = mean(data34[i,.]')
			mean_est35[i] = mean(data35[i,.]')
			mean_est36[i] = mean(data36[i,.]')
		    mean_est37[i] = mean(data37[i,.]')
			mean_est38[i] = mean(data38[i,.]')
			mean_est39[i] = mean(data39[i,.]')
		
			acov_est21[i] = mataacov(data21[i,.], acov_order) 
			acov_est22[i] = mataacov(data22[i,.], acov_order)
			acov_est23[i] = mataacov(data23[i,.], acov_order) 
			acov_est24[i] = mataacov(data24[i,.], acov_order)
			acov_est31[i] = mataacov(data31[i,.], acov_order)
			acov_est32[i] = mataacov(data32[i,.], acov_order)
			acov_est33[i] = mataacov(data33[i,.], acov_order)
			acov_est34[i] = mataacov(data34[i,.], acov_order)
            acov_est35[i] = mataacov(data35[i,.], acov_order)
			acov_est36[i] = mataacov(data36[i,.], acov_order)
			acov_est37[i] = mataacov(data37[i,.], acov_order)
            acov_est38[i] = mataacov(data38[i,.], acov_order)
			acov_est39[i] = mataacov(data39[i,.], acov_order)
                
			acor_est21[i] = mataacor(data21[i,.], acor_order)
			acor_est22[i] = mataacor(data22[i,.], acor_order)
			acor_est23[i] = mataacor(data23[i,.], acor_order)
			acor_est24[i] = mataacor(data24[i,.], acor_order)
			acor_est31[i] = mataacor(data31[i,.], acor_order)
			acor_est32[i] = mataacor(data32[i,.], acor_order)
			acor_est33[i] = mataacor(data33[i,.], acor_order)
			acor_est34[i] = mataacor(data34[i,.], acor_order)
			acor_est35[i] = mataacor(data35[i,.], acor_order)
			acor_est36[i] = mataacor(data36[i,.], acor_order)
			acor_est37[i] = mataacor(data37[i,.], acor_order)
			acor_est38[i] = mataacor(data38[i,.], acor_order)
			acor_est39[i] = mataacor(data39[i,.], acor_order)	
		}
		
		equantity = (mean_est, mean_est21, mean_est22, mean_est23, mean_est24, mean_est31, mean_est32, mean_est33, mean_est34, mean_est35,  ///
					mean_est36, mean_est37, mean_est38, mean_est39, acov_est, acov_est21, acov_est22, acov_est23, acov_est24, acov_est31,   ///
					acov_est32, acov_est33, acov_est34, acov_est35, acov_est36, acov_est37, acov_est38, acov_est39, acor_est, acor_est21,   ///
					acor_est22, acor_est23, acor_est24, acor_est31, acor_est32, acor_est33, acor_est34, acor_est35, acor_est36, acor_est37, ///
					acor_est38, acor_est39)
		estimate_value = tojmomentest5(equantity, 1::N)
	
		number_par = length(estimate_value)
		estimate_boot = J(B, number_par, 0)
		
		for (b = 1; b <= B; b++) {
			index_boot = rdiscrete(N, 1, J(N, 1, 1/N))
			estimate_boot[b,] = tojmomentest5(equantity, index_boot)
		}
		
		se = sqrt(diagonal(variance(estimate_boot)))
		quantile_boot_1 = mm_quantile(estimate_boot, 1, 0.975)
		quantile_boot_2 = mm_quantile(estimate_boot, 1, 0.025)	
		ci_1 = 2 * estimate_value - quantile_boot_1
		ci_2 = 2 * estimate_value - quantile_boot_2
		ci = (ci_1 \ ci_2)
		result =  (estimate_value', se, ci')
	}
	
	st_matrix("est", estimate_value')
	st_matrix("se", se)
	st_matrix("ci", ci')
	
	printf("\n")
    printf("Estimates for Moments.\n")
    printf("Parameters                                              Estimate          \n")
    printf("________________________________________________________________ \n")
    printf("Mean of Mean                                            %f\n",estimate_value[1])
	printf("Mean of Autocovariance                                  %f\n",estimate_value[2])
	printf("Mean of Autocorrelation                                 %f\n",estimate_value[3])
	printf("Variance of Mean                                        %f\n",estimate_value[4])
	printf("Variance of Autocovariance                              %f\n",estimate_value[5])
	printf("Variance of Autocorrelation                             %f\n",estimate_value[6])
	printf("Correlation between Mean and Autocovariance             %f\n",estimate_value[7])
	printf("Correlation between Mean and Autocorrelation            %f\n",estimate_value[8])
	printf("Correlation between Autocovariance and Autocorelation   %f\n",estimate_value[9])
	
	printf("\n")
    printf("%f %% Confidence Intervals for Moments.\n", 95)
    printf("Parameters                                              Low                   High\n")
    printf("__________________________________________________________________________________\n")
    printf("Mean of Mean                                            %f        %f\n",ci_1[1],ci_2[1])
	printf("Mean of Autocovariance                                  %f        %f\n",ci_1[2],ci_2[2])
	printf("Mean of Autocorrelation                                 %f        %f\n",ci_1[3],ci_2[3])
	printf("Variance of Mean                                        %f        %f\n",ci_1[4],ci_2[4])
	printf("Variance of Autocovariance                              %f        %f\n",ci_1[5],ci_2[5])
	printf("Variance of Autocorrelation                             %f        %f\n",ci_1[6],ci_2[6])
	printf("Correlation between Mean and Autocovariance             %f        %f\n",ci_1[7],ci_2[7])
	printf("Correlation between Mean and Autocorrelation            %f        %f\n",ci_1[8],ci_2[8])
	printf("Correlation between Autocovariance and Autocorelation   %f        %f\n",ci_1[9],ci_2[9])
	
	printf("\n")
    printf("Standard Errors for Moments.\n")
    printf("Parameters                                              Stanadard Errors          \n")
    printf("________________________________________________________________________\n")
    printf("Mean of Mean                                            %f\n",se[1])
	printf("Mean of Autocovariance                                  %f\n",se[2])
	printf("Mean of Autocorrelation                                 %f\n",se[3])
	printf("Variance of Mean                                        %f\n",se[4])
	printf("Variance of Autocovariance                              %f\n",se[5])
	printf("Variance of Autocorrelation                             %f\n",se[6])
	printf("Correlation between Mean and Autocovariance             %f\n",se[7])
	printf("Correlation between Mean and Autocorrelation            %f\n",se[8])
	printf("Correlation between Autocovariance and Autocorelation   %f\n",se[9])
}

///  4. Kernel Density Estimation

// 4.1. Naive Estimation of Kernel Density
function nekdest (x, X, h) {
    N = length(X)
	
    k = normalden((x :- X)/h)
    est = sum(k)/(N*h)
	se = sqrt((1 / (N - 1)) * ((1 / (N * h^2)) * sum(k:^2) - est^2))
    return((est, se))
}

function m_nekd (data, acov_order, acor_order){
    N = rows(data)
	S = cols(data)
	grid = 100
	
	mean_est = J(N,1,0)
	acov_est = J(N,1,0)
	acor_est = J(N,1,0)
	
	mean_UCI = J(grid,1,0)
	acov_UCI = J(grid,1,0)
	acor_UCI = J(grid,1,0)
	
	mean_LCI = J(grid,1,0)
	acor_LCI = J(grid,1,0)
	acov_LCI = J(grid,1,0)
	
	mean_se = J(grid,1,0)
	acov_se = J(grid,1,0)
	acor_se = J(grid,1,0)
	
	for (i=1 ; i<=N ; i++){
	    mean_est[i] = mean(data[i,.]')
		acov_est[i] = mataacov(data[i,.], acov_order) 
		acor_est[i] = mataacor(data[i,.], acor_order)
	}
	
	mean_bw = kdens_bw_dpi(mean_est, level = 2)
	acov_bw = kdens_bw_dpi(acov_est, level = 2)
	acor_bw = kdens_bw_dpi(acor_est, level = 2)
	
	mean_lim = (min(mean_est), max(mean_est))
    acov_lim = (min(acov_est), max(acov_est))
    acor_lim = (min(acor_est), max(acor_est))
    
	mean_grid = rangen(mean_lim[1], mean_lim[2], grid)
	acov_grid = rangen(acov_lim[1], acov_lim[2], grid)
	acor_grid = rangen(acor_lim[1], acor_lim[2], grid)
	
	mean_dest = J(grid, 1, 0)
	acov_dest = J(grid, 1, 0)
	acor_dest = J(grid, 1, 0)
	
	for (i = 1; i <= grid; i++) {
	    k = nekdest(mean_grid[i], mean_est, mean_bw)
		mean_dest[i] = k[1]
		mean_se[i] = k[2]
		mean_LCI[i] = max((0,mean_dest[i] - 1.96 * mean_se[i]))
		mean_UCI[i] = mean_dest[i] + 1.96 * mean_se[i]
		
		k = nekdest(acov_grid[i], acov_est, acov_bw)
		acov_dest[i] = k[1]
		acov_se[i] = k[2]
		acov_LCI[i] = max((0,acov_dest[i] - 1.96 * acov_se[i]))
		acov_UCI[i] = acov_dest[i] + 1.96 * acov_se[i]
		
		k = nekdest(acor_grid[i], acor_est, acor_bw)
		acor_dest[i] = k[1]
		acor_se[i] = k[2]
		acor_LCI[i] = max((0,acor_dest[i] - 1.96 * acor_se[i]))
		acor_UCI[i] = acor_dest[i] + 1.96 * acor_se[i]
	}
	
	temp=st_addvar("double", "mean_dest")
    temp=st_addvar("double", "acov_dest")
    temp=st_addvar("double", "acor_dest")
    temp=st_addvar("double", "mean_grid")
	temp=st_addvar("double", "acov_grid")
	temp=st_addvar("double", "acor_grid")
	
	temp=st_addvar("double", "mean_LCI")
    temp=st_addvar("double", "acov_LCI")
    temp=st_addvar("double", "acor_LCI")
    temp=st_addvar("double", "mean_UCI")
	temp=st_addvar("double", "acov_UCI")
	temp=st_addvar("double", "acor_UCI")
	
    st_addobs(max((0,grid  - st_nobs())))
    st_store(.,"mean_dest", mean_dest\J(st_nobs()-rows(mean_dest),1,.))
    st_store(.,"acov_dest", acov_dest\J(st_nobs()-rows(acov_dest),1,.))
    st_store(.,"acor_dest", acor_dest\J(st_nobs()-rows(acor_dest),1,.))
    st_store(.,"mean_grid", mean_grid\J(st_nobs()-rows(mean_grid),1,.))
	st_store(.,"acov_grid", acov_grid\J(st_nobs()-rows(acov_grid),1,.))
    st_store(.,"acor_grid", acor_grid\J(st_nobs()-rows(acor_grid),1,.))
	
	st_store(.,"mean_LCI", mean_LCI\J(st_nobs()-rows(mean_LCI),1,.))
    st_store(.,"acov_LCI", acov_LCI\J(st_nobs()-rows(acov_LCI),1,.))
    st_store(.,"acor_LCI", acor_LCI\J(st_nobs()-rows(acor_LCI),1,.))
	st_store(.,"mean_UCI", mean_UCI\J(st_nobs()-rows(mean_UCI),1,.))
    st_store(.,"acov_UCI", acov_UCI\J(st_nobs()-rows(acov_UCI),1,.))
    st_store(.,"acor_UCI", acor_UCI\J(st_nobs()-rows(acor_UCI),1,.))
}

// 4.2. Half-Panel-Jackknife 

function hpjkdest1 (x, X, X1, X2, h) {
    N = length(X)
	
	est = sum(normalden((x :- X)/h))/(N * h)
	k = normalden((x :- X)/h)
	
	est1 = sum(normalden((x :- X1)/h))/(N * h)
	k1 = normalden((x :- X1)/h)
	
	est2= sum(normalden((x :- X2)/h))/(N * h)
    k2 = normalden((x :- X2)/h)
	
	hpjest = 2 * est - (est1 + est2) / 2
	kest = 2 * k - (k1 + k2) / 2
	se = sqrt((1 / (N - 1)) * ((1 / (N * h^2)) * sum(kest:^2) - hpjest^2))
	
	return((hpjest, se))
}

function hpjkdest2 (x, X, X1, X2, X3, X4, h) {
    N = length(X)
	
	est = sum(normalden((x :- X)/h))/(N * h)
	k = normalden((x :- X)/h)
	
	est1 = sum(normalden((x :- X1)/h))/(N * h)
	k1 = normalden((x :- X1)/h)
	
	est2= sum(normalden((x :- X2)/h))/(N * h)
    k2 = normalden((x :- X2)/h)
	
	est3 = sum(normalden((x :- X3)/h))/(N * h)
	k3 = normalden((x :- X3)/h)
	
	est4= sum(normalden((x :- X4)/h))/(N * h)
	k4 = normalden((x :- X4)/h)
	
    hpjest = 2 * est - (est1 + est2 + est3 + est4) / 4
	kest = 2 * k - (k1 + k2 + k3 + k4) / 4
	se = sqrt((1 / (N - 1)) * ((1 / (N * h^2)) * sum(kest:^2) - hpjest^2))
	
	return((hpjest, se))
}


function m_hpjkd (data, acov_order, acor_order) {
    N = rows(data)
	S = cols(data)
	grid = 100
	
	mean_est = J(N,1,0)
	acov_est = J(N,1,0)
	acor_est = J(N,1,0)
	
	for (i=1 ; i<=N ; i++){
	    mean_est[i] = mean(data[i,.]')
		acov_est[i] = mataacov(data[i,.], acov_order) 
		acor_est[i] = mataacor(data[i,.], acor_order)
	}

	mean_bw = kdens_bw_dpi(mean_est, level = 2)
	acov_bw = kdens_bw_dpi(acov_est, level = 2)
	acor_bw = kdens_bw_dpi(acor_est, level = 2)
	
	mean_lim = (min(mean_est), max(mean_est))
    acov_lim = (min(acov_est), max(acov_est))
    acor_lim = (min(acor_est), max(acor_est))
    
	mean_grid = rangen(mean_lim[1], mean_lim[2], grid)
	acov_grid = rangen(acov_lim[1], acov_lim[2], grid)
	acor_grid = rangen(acor_lim[1], acor_lim[2], grid)
	
	mean_dest = J(grid, 1, 0)
	acov_dest = J(grid, 1, 0)
	acor_dest = J(grid, 1, 0)
	
	mean_UCI = J(grid,1,0)
	acov_UCI = J(grid,1,0)
	acor_UCI = J(grid,1,0)
	
	mean_LCI = J(grid,1,0)
	acor_LCI = J(grid,1,0)
	acov_LCI = J(grid,1,0)
	
	mean_se = J(grid,1,0)
	acov_se = J(grid,1,0)
	acor_se = J(grid,1,0)
	
	if (mod(S,2) == 0) {
	    data1 = data[., 1::(S / 2)]
        data2 = data[., (S / 2 + 1)::S]
	    
		mean_est1 = J(N,1,0)
	    acov_est1 = J(N,1,0)
	    acor_est1 = J(N,1,0)
		
		mean_est2 = J(N,1,0)
	    acov_est2 = J(N,1,0)
	    acor_est2 = J(N,1,0)
		
	    for (i=1 ; i<=N ; i++){
	        mean_est1[i] = mean(data1[i,.]')
		    acov_est1[i] = mataacov(data1[i,.], acov_order) 
		    acor_est1[i] = mataacor(data1[i,.], acor_order)
			
			mean_est2[i] = mean(data2[i,.]')
		    acov_est2[i] = mataacov(data2[i,.], acov_order) 
		    acor_est2[i] = mataacor(data2[i,.], acor_order)
	    }
		
	    for (i = 1; i <= grid; i++) {
	        k = hpjkdest1(mean_grid[i], mean_est, mean_est1, mean_est2, mean_bw)
			mean_dest[i] = k[1]
			mean_se[i] = k[2]
		    mean_LCI[i] = max((0,mean_dest[i] - 1.96 * mean_se[i]))
		    mean_UCI[i] = max((0,mean_dest[i] + 1.96 * mean_se[i]))
			mean_dest[i] = max((0,mean_dest[i]))
			
		    k = hpjkdest1(acov_grid[i], acov_est, acov_est1, acov_est2, acov_bw)
			acov_dest[i] = k[1]
		    acov_se[i] = k[2]
		    acov_LCI[i] = max((0,acov_dest[i] - 1.96 * acov_se[i]))
		    acov_UCI[i] = max((0,acov_dest[i] + 1.96 * acov_se[i]))
			acov_dest[i] = max((0,acov_dest[i]))
		
		    k = hpjkdest1(acor_grid[i], acor_est, acor_est1, acor_est2, acor_bw)
			acor_dest[i] = k[1]
		    acor_se[i] = k[2]
		    acor_LCI[i] = max((0,acor_dest[i] - 1.96 * acor_se[i]))
		    acor_UCI[i] = max((0,acor_dest[i] + 1.96 * acor_se[i]))
			acor_dest[i] = max((0,acor_dest[i]))
	    }    
	}
	else {
	    data1 = data[., 1::floor(S / 2)]
        data2 = data[., (floor(S / 2) + 1)::S]
        data3 = data[., 1::ceil(S / 2)]
        data4 = data[., (ceil(S / 2) + 1)::S]
	    
		mean_est1 = J(N,1,0)
	    acov_est1 = J(N,1,0)
	    acor_est1 = J(N,1,0)
		
		mean_est2 = J(N,1,0)
	    acov_est2 = J(N,1,0)
	    acor_est2 = J(N,1,0)
		
		mean_est3 = J(N,1,0)
	    acov_est3 = J(N,1,0)
	    acor_est3 = J(N,1,0)
		
		mean_est4 = J(N,1,0)
	    acov_est4 = J(N,1,0)
	    acor_est4 = J(N,1,0)
		
		for (i=1 ; i<=N ; i++){
	        mean_est1[i] = mean(data1[i,.]') 
		    acov_est1[i] = mataacov(data1[i,.], acov_order) 
		    acor_est1[i] = mataacor(data1[i,.], acor_order)
			
			mean_est2[i] = mean(data2[i,.]') 
		    acov_est2[i] = mataacov(data2[i,.], acov_order) 
		    acor_est2[i] = mataacor(data2[i,.], acor_order)
			
			mean_est3[i] = mean(data3[i,.]') 
		    acov_est3[i] = mataacov(data3[i,.], acov_order) 
		    acor_est3[i] = mataacor(data3[i,.], acor_order)
			
			mean_est4[i] = mean(data4[i,.]')
		    acov_est4[i] = mataacov(data4[i,.], acov_order) 
		    acor_est4[i] = mataacor(data4[i,.], acor_order)
	    }
		for (i = 1; i <= grid; i++) {
	        k = hpjkdest2(mean_grid[i], mean_est, mean_est1, mean_est2, mean_est3, mean_est4, mean_bw)
			mean_dest[i] = k[1]
		    mean_se[i] = k[2]
			mean_LCI[i] = max((0,mean_dest[i] - 1.96 * mean_se[i]))
			mean_UCI[i] = max((0,mean_dest[i] + 1.96 * mean_se[i]))
			mean_dest[i] = max((0,mean_dest[i]))
			
		    k = hpjkdest2(acov_grid[i], acov_est, acov_est1, acov_est2, acov_est3, acov_est4, acov_bw)
			acov_dest[i] = k[1]
		    acov_se[i] = k[2]
		    acov_LCI[i] = max((0,acov_dest[i] - 1.96 * acov_se[i]))
		    acov_UCI[i] = max((0,acov_dest[i] + 1.96 * acov_se[i]))
			acov_dest[i] = max((0,acov_dest[i]))
			
		    k = hpjkdest2(acor_grid[i], acor_est, acor_est1, acor_est2, acor_est3, acor_est4, acor_bw)
			acor_dest[i] = k[1]
		    acor_se[i] = k[2]
		    acor_LCI[i] = max((0,acor_dest[i] - 1.96 * acor_se[i]))
		    acor_UCI[i] = max((0,acor_dest[i] + 1.96 * acor_se[i]))
			acor_dest[i] = max((0,acor_dest[i]))
	    }  
	}
    	
    temp=st_addvar("double", "mean_dest")
    temp=st_addvar("double", "acov_dest")
    temp=st_addvar("double", "acor_dest")
    temp=st_addvar("double", "mean_grid")
	temp=st_addvar("double", "acov_grid")
	temp=st_addvar("double", "acor_grid")
	
	temp=st_addvar("double", "mean_LCI")
    temp=st_addvar("double", "acov_LCI")
    temp=st_addvar("double", "acor_LCI")
    temp=st_addvar("double", "mean_UCI")
	temp=st_addvar("double", "acov_UCI")
	temp=st_addvar("double", "acor_UCI")
	
    st_addobs(max((0,grid  - st_nobs())))
    st_store(.,"mean_dest", mean_dest\J(st_nobs()-rows(mean_dest),1,.))
    st_store(.,"acov_dest", acov_dest\J(st_nobs()-rows(acov_dest),1,.))
    st_store(.,"acor_dest", acor_dest\J(st_nobs()-rows(acor_dest),1,.))
    st_store(.,"mean_grid", mean_grid\J(st_nobs()-rows(mean_grid),1,.))
	st_store(.,"acov_grid", acov_grid\J(st_nobs()-rows(acov_grid),1,.))
    st_store(.,"acor_grid", acor_grid\J(st_nobs()-rows(acor_grid),1,.))
	
	st_store(.,"mean_LCI", mean_LCI\J(st_nobs()-rows(mean_LCI),1,.))
    st_store(.,"acov_LCI", acov_LCI\J(st_nobs()-rows(acov_LCI),1,.))
    st_store(.,"acor_LCI", acor_LCI\J(st_nobs()-rows(acor_LCI),1,.))
	st_store(.,"mean_UCI", mean_UCI\J(st_nobs()-rows(mean_UCI),1,.))
    st_store(.,"acov_UCI", acov_UCI\J(st_nobs()-rows(acov_UCI),1,.))
    st_store(.,"acor_UCI", acor_UCI\J(st_nobs()-rows(acor_UCI),1,.))
}

// 4.3. Third-Order-Jackknife


/*computing TOJ kernel density estimate for T equivalent to 0 modulo 6
	x point at which the density is estimated
	X vector of original cross-sectional data
	X21 vector of half-panel cross-sectional data based on time series 1 ~ T/2
	X22 vector of half-panel cross-sectional data based on time series (T/2 + 1) ~ T
	X31 vector of one-third-panel cross-sectional data based on time series 1 ~ T/3
	X32 vector of one-third-panel cross-sectional data based on time series (T/3 + 1) ~ 2 * T/3
	X33 vector of one-third-panel cross-sectional data based on time series 2 * T/3 + 1 ~ T
	h bandwidth
*/

function tojkdest0(x, X, X21, X22, X31, X32, X33, h) {

	// sample size
    N = length(X)

	// estimates
	est = sum(normalden( (x :- X) / h)) /  (N * h)
	est21 = sum(normalden( (x :- X21) / h)) /  (N * h)
	est22 = sum(normalden( (x :- X22) / h)) /  (N * h)
	est31 = sum(normalden( (x :- X31) / h)) /  (N * h)
	est32 = sum(normalden( (x :- X32) / h)) /  (N * h)
	est33 = sum(normalden( (x :- X33) / h)) /  (N * h)
	
	k = normalden((x :- X)/h)
	k21 = normalden((x :- X21)/h)
	k22 = normalden((x :- X22)/h)
	k31 = normalden((x :- X31)/h)
	k32 = normalden((x :- X32)/h)
	k33 = normalden((x :- X33)/h)
	
	// TOJ estimate
    tojest = 3.536 * est - 4.072 * (est21 + est22) / 2 + 1.536 * (est31 + est32 + est33) / 3
	kest = 3.536 * k - 4.072 * (k21 + k22) / 2 + 1.536 * (k31 + k32 + k33) / 3
	se = sqrt((1 / (N - 1)) * ((1 / (N * h^2)) * sum(kest:^2) - tojest^2))
  
  return((tojest, se))
}

/* computing TOJ kernel density estimate for T equivalent to 1 modulo 6
	x point at which the density is estimated
	X vector of original cross-sectional data
    X21 vector of half-panel cross-sectional data based on time series 1 ~ floor(T/2)
	X22 vector of half-panel cross-sectional data based on time series (floor(T/2) + 1) ~ T
	X23 vector of half-panel cross-sectional data based on time series 1 ~ ceiling(T/2)
	X24 vector of half-panel cross-sectional data based on time series (ceiling(T/2) + 1) ~ T
	X31 vector of one-third-panel cross-sectional data based on time series 1 ~ floor(T/3)
	X32 vector of one-third-panel cross-sectional data based on time series (floor(T/3) + 1) ~ (2 * floor(T/3)) 
	X33 vector of one-third-panel cross-sectional data based on time series (2 * floor(T/3) + 1) ~ T
	X34 vector of one-third-panel cross-sectional data based on time series 1 ~ floor(T/3)
	X35 vector of one-third-panel cross-sectional data based on time series (floor(T/3) + 1) ~ (2 * floor(T/3) + 1)
	X36 vector of one-third-panel cross-sectional data based on time series (2 * floor(T/3) + 2) ~ T
	X37 vector of one-third-panel cross-sectional data based on time series 1 ~ ceiling(T/3)
	X38 vector of one-third-panel cross-sectional data based on time series (ceiling(T/3) + 1) ~ (2 * floor(T/3) + 1)
	X39 vector of one-third-panel cross-sectional data based on time series (2 * floor(T/3) + 2) ~ T
	h bandwidth
*/
function tojkdest1(x, X, X21, X22, X23, X24, X31, X32, X33, X34, X35, X36, X37, X38, X39, h) {

	// sample size
    N = length(X)

	// estimates
	est = sum(normalden( (x :- X) / h)) /  (N * h)
	est21 = sum(normalden( (x :- X21) / h)) /  (N * h)
    est22 = sum(normalden( (x :- X22) / h)) /  (N * h)
	est23 = sum(normalden( (x :- X23) / h)) /  (N * h)
	est24 = sum(normalden( (x :- X24) / h)) /  (N * h)
	est31 = sum(normalden( (x :- X31) / h)) /  (N * h)
	est32 = sum(normalden( (x :- X32) / h)) /  (N * h)
	est33 = sum(normalden( (x :- X33) / h)) /  (N * h)
	est34 = sum(normalden( (x :- X34) / h)) /  (N * h)
	est35 = sum(normalden( (x :- X35) / h)) /  (N * h)
	est36 = sum(normalden( (x :- X36) / h)) /  (N * h)
	est37 = sum(normalden( (x :- X37) / h)) /  (N * h)
	est38 = sum(normalden( (x :- X38) / h)) /  (N * h)
	est39 = sum(normalden( (x :- X39) / h)) /  (N * h)
	
	k = normalden((x :- X)/h)
	k21 = normalden((x :- X21)/h)
	k22 = normalden((x :- X22)/h)
	k23 = normalden((x :- X23)/h)
	k24 = normalden((x :- X24)/h)
	k31 = normalden((x :- X31)/h)
	k32 = normalden((x :- X32)/h)
	k33 = normalden((x :- X33)/h)
	k34 = normalden((x :- X34)/h)
	k35 = normalden((x :- X35)/h)
	k36 = normalden((x :- X36)/h)
	k37 = normalden((x :- X37)/h)
	k38 = normalden((x :- X38)/h)
	k39 = normalden((x :- X39)/h)	

	// TOJ estimate
	tojest = 3.536 * est - 4.072 * (est21 + est22 + est23 + est24) / 4 + 1.536 * (est31 + est32 + est33 + est34 + est35 + est36 + est37 + est38 + est39) / 9
	kest = 3.536 * k - 4.072 * (k21 + k22 + k23 + k24) / 4 + 1.536 * (k31 + k32 + k33 + k34 + k35 + k36 + k37 + k38 + k39) / 9
	se = sqrt((1 / (N - 1)) * ((1 / (N * h^2)) * sum(kest:^2) - tojest^2))
	
  
	return((tojest, se))
}

/* computing TOJ kernel density estimate for T equivalent to 2 modulo 6
	x point at which the density is estimated
	X vector of original cross-sectional data
	X21 vector of half-panel cross-sectional data based on time series 1 ~ T/2
	X22 vector of half-panel cross-sectional data based on time series (T/2 + 1) ~ T
	X31 vector of one-third-panel cross-sectional data based on time series 1 ~ floor(T/3)
	X32 vector of one-third-panel cross-sectional data based on time series (floor(T/3) + 1) ~ (2 * floor(T/3) + 1) 
	X33 vector of one-third-panel cross-sectional data based on time series (2 * ceiling(T/3)) ~ T
	X34 vector of one-third-panel cross-sectional data based on time series 1 ~ ceiling(T/3)
	X35 vector of one-third-panel cross-sectional data based on time series (ceiling(T/3) + 1) ~ (2 * floor(T/3) + 1)
	X36 vector of one-third-panel cross-sectional data based on time series (2 * ceiling(T/3)) ~ T
	X37 vector of one-third-panel cross-sectional data based on time series 1 ~ ceiling(T/3)
	X38 vector of one-third-panel cross-sectional data based on time series (ceiling(T/3) + 1) ~ (2 * ceiling(T/3))
	X39 vector of one-third-panel cross-sectional data based on time series (2 * ceiling(T/3) + 1) ~ T
	h bandwidth
*/

function tojkdest2(x, X, X21, X22, X31, X32, X33, X34, X35, X36, X37, X38, X39, h) {

	// sample size
	N = length(X)

	// estimates
	est = sum(normalden( (x :- X) / h)) /  (N * h)
	est21 = sum(normalden( (x :- X21) / h)) /  (N * h)
	est22 = sum(normalden( (x :- X22) / h)) /  (N * h)
	est31 = sum(normalden( (x :- X31) / h)) /  (N * h)
	est32 = sum(normalden( (x :- X32) / h)) /  (N * h)
	est33 = sum(normalden( (x :- X33) / h)) /  (N * h)
	est34 = sum(normalden( (x :- X34) / h)) /  (N * h)
	est35 = sum(normalden( (x :- X35) / h)) /  (N * h)
	est36 = sum(normalden( (x :- X36) / h)) /  (N * h)
	est37 = sum(normalden( (x :- X37) / h)) /  (N * h)
	est38 = sum(normalden( (x :- X38) / h)) /  (N * h)
	est39 = sum(normalden( (x :- X39) / h)) /  (N * h)
	
	k = normalden((x :- X)/h)
	k21 = normalden((x :- X21)/h)
	k22 = normalden((x :- X22)/h)
	k31 = normalden((x :- X31)/h)
	k32 = normalden((x :- X32)/h)
	k33 = normalden((x :- X33)/h)
	k34 = normalden((x :- X34)/h)
	k35 = normalden((x :- X35)/h)
	k36 = normalden((x :- X36)/h)
	k37 = normalden((x :- X37)/h)
	k38 = normalden((x :- X38)/h)
	k39 = normalden((x :- X39)/h)

	// TOJ estimate
	tojest = 3.536 * est - 4.072 * (est21 + est22) / 2 + 1.536 * (est31 + est32 + est33 + est34 + est35 + est36 + est37 + est38 + est39) / 9
	kest = 3.536 * k - 4.072 * (k21 + k22) / 2 + 1.536 * (k31 + k32 + k33 + k34 + k35 + k36 + k37 + k38 + k39) / 9
	se = sqrt((1 / (N - 1)) * ((1 / (N * h^2)) * sum(kest:^2) - tojest^2))
	
	return((tojest, se))
}

/* computing TOJ kernel density estimate for T equivalent to 3 modulo 6
	x point at which the density is estimated
	X vector of original cross-sectional data
	X21 vector of half-panel cross-sectional data based on time series 1 ~ floor(T/2)
	X22 vector of half-panel cross-sectional data based on time series (floor(T/2) + 1) ~ T
	X23 vector of half-panel cross-sectional data based on time series 1 ~ ceiling(T/2)
	X24 vector of half-panel cross-sectional data based on time series (ceiling(T/2) + 1) ~ T
	X31 vector of one-third-panel cross-sectional data based on time series 1 ~ T/3
	X32 vector of one-third-panel cross-sectional data based on time series (T/3 + 1) ~ 2 * T/3
	X33 vector of one-third-panel cross-sectional data based on time series 2 * T/3 + 1 ~ T
	h bandwidth
*/
function tojkdest3(x, X, X21, X22, X23, X24, X31, X32, X33, h) {

	// sample size
    N = length(X)

	// estimates
	est = sum(normalden( (x :- X) / h)) /  (N * h)
	est21 = sum(normalden( (x :- X21) / h)) /  (N * h)
	est22 = sum(normalden( (x :- X22) / h)) /  (N * h)
	est23 = sum(normalden( (x :- X23) / h)) /  (N * h)
	est24 = sum(normalden( (x :- X24) / h)) /  (N * h)
	est31 = sum(normalden( (x :- X31) / h)) /  (N * h)
	est32 = sum(normalden( (x :- X32) / h)) /  (N * h)
	est33 = sum(normalden( (x :- X33) / h)) /  (N * h)
	
	k = normalden((x :- X)/h)
	k21 = normalden((x :- X21)/h)
	k22 = normalden((x :- X22)/h)
	k23 = normalden((x :- X23)/h)
	k24 = normalden((x :- X24)/h)
	k31 = normalden((x :- X31)/h)
	k32 = normalden((x :- X32)/h)
	k33 = normalden((x :- X33)/h)

	// TOJ estimate
	tojest = 3.536 * est - 4.072 * (est21 + est22 + est23 + est24) / 4 + 1.536 * (est31 + est32 + est33) / 3
	kest = 3.536 * k - 4.072 * (k21 + k22 + k23 + k24) / 4 + 1.536 * (k31 + k32 + k33) / 3
	se = sqrt((1 / (N - 1)) * ((1 / (N * h^2)) * sum(kest:^2) - tojest^2))

    return((tojest, se))
}

/* computing TOJ kernel density estimate for T equivalent to 4 modulo 6
	x point at which the density is estimated
	X vector of original cross-sectional data
	X21 vector of half-panel cross-sectional data based on time series 1 ~ T/2
	X22 vector of half-panel cross-sectional data based on time series (T/2 + 1) ~ T
	X31 vector of one-third-panel cross-sectional data based on time series 1 ~ floor(T/3)
	X32 vector of one-third-panel cross-sectional data based on time series (floor(T/3) + 1) ~ (2 * floor(T/3)) 
	X33 vector of one-third-panel cross-sectional data based on time series (2 * floor(T/3) + 1) ~ T
	X34 vector of one-third-panel cross-sectional data based on time series 1 ~ floor(T/3)
	X35 vector of one-third-panel cross-sectional data based on time series (floor(T/3) + 1) ~ (2 * floor(T/3) + 1)
	X36 vector of one-third-panel cross-sectional data based on time series (2 * floor(T/3) + 2) ~ T
	X37 vector of one-third-panel cross-sectional data based on time series 1 ~ ceiling(T/3)
	X38 vector of one-third-panel cross-sectional data based on time series (ceiling(T/3) + 1) ~ (2 * floor(T/3) + 1)
	X39 vector of one-third-panel cross-sectional data based on time series (2 * floor(T/3) + 2) ~ T
	h bandwidth
*/
function tojkdest4(x, X, X21, X22, X31, X32, X33, X34, X35, X36, X37, X38, X39, h) {

	// sample size
	N = length(X)

	// estimates
	est = sum(normalden( (x :- X) / h)) /  (N * h)
	est21 = sum(normalden( (x :- X21) / h)) /  (N * h)
	est22 = sum(normalden( (x :- X22) / h)) /  (N * h)
	est31 = sum(normalden( (x :- X31) / h)) /  (N * h)
	est32 = sum(normalden( (x :- X32) / h)) /  (N * h)
	est33 = sum(normalden( (x :- X33) / h)) /  (N * h)
	est34 = sum(normalden( (x :- X34) / h)) /  (N * h)
	est35 = sum(normalden( (x :- X35) / h)) /  (N * h)
	est36 = sum(normalden( (x :- X36) / h)) /  (N * h)
	est37 = sum(normalden( (x :- X37) / h)) /  (N * h)
	est38 = sum(normalden( (x :- X38) / h)) /  (N * h)
	est39 = sum(normalden( (x :- X39) / h)) /  (N * h)
	
	k = normalden((x :- X)/h)
	k21 = normalden((x :- X21)/h)
	k22 = normalden((x :- X22)/h)
	k31 = normalden((x :- X31)/h)
	k32 = normalden((x :- X32)/h)
	k33 = normalden((x :- X33)/h)
	k34 = normalden((x :- X34)/h)
	k35 = normalden((x :- X35)/h)
	k36 = normalden((x :- X36)/h)
	k37 = normalden((x :- X37)/h)
	k38 = normalden((x :- X38)/h)
	k39 = normalden((x :- X39)/h)

	// TOJ estimate
	tojest = 3.536 * est - 4.072 * (est21 + est22) / 2 + 1.536 * (est31 + est32 + est33 + est34 + est35 + est36 + est37 + est38 + est39) / 9
	kest = 3.536 * k - 4.072 * (k21 + k22) / 2 + 1.536 * (k31 + k32 + k33 + k34 + k35 + k36 + k37 + k38 + k39) / 9
	se = sqrt((1 / (N - 1)) * ((1 / (N * h^2)) * sum(kest:^2) - tojest^2))
	
	return((tojest, se))
}

/* computing TOJ kernel density estimate for T equivalent to 5 modulo 6

	x point at which the density is estimated
	X vector of original cross-sectional data
	X21 vector of half-panel cross-sectional data based on time series 1 ~ floor(T/2)
	X22 vector of half-panel cross-sectional data based on time series (floor(T/2) + 1) ~ T
	X23 vector of half-panel cross-sectional data based on time series 1 ~ ceiling(T/2)
	X24 vector of half-panel cross-sectional data based on time series (ceiling(T/2) + 1) ~ T
	X31 vector of one-third-panel cross-sectional data based on time series 1 ~ floor(T/3)
	X32 vector of one-third-panel cross-sectional data based on time series (floor(T/3) + 1) ~ (2 * floor(T/3) + 1) 
	X33 vector of one-third-panel cross-sectional data based on time series (2 * ceiling(T/3)) ~ T
	X34 vector of one-third-panel cross-sectional data based on time series 1 ~ ceiling(T/3)
	X35 vector of one-third-panel cross-sectional data based on time series (ceiling(T/3) + 1) ~ (2 * floor(T/3) + 1)
	X36 vector of one-third-panel cross-sectional data based on time series (2 * ceiling(T/3)) ~ T
	X37 vector of one-third-panel cross-sectional data based on time series 1 ~ ceiling(T/3)
	X38 vector of one-third-panel cross-sectional data based on time series (ceiling(T/3) + 1) ~ (2 * ceiling(T/3))
	X39 vector of one-third-panel cross-sectional data based on time series (2 * ceiling(T/3) + 1) ~ T
	h bandwidth
*/
function tojkdest5(x, X, X21, X22, X23, X24, X31, X32, X33, X34, X35, X36, X37, X38, X39, h) {

	// sample size
	N = length(X)

	// estimates
	est = sum(normalden( (x :- X) / h)) /  (N * h)
	est21 = sum(normalden( (x :- X21) / h)) /  (N * h)
	est22 = sum(normalden( (x :- X22) / h)) /  (N * h)
	est23 = sum(normalden( (x :- X23) / h)) /  (N * h)
	est24 = sum(normalden( (x :- X24) / h)) /  (N * h)
	est31 = sum(normalden( (x :- X31) / h)) /  (N * h)
	est32 = sum(normalden( (x :- X32) / h)) /  (N * h)
	est33 = sum(normalden( (x :- X33) / h)) /  (N * h)
	est34 = sum(normalden( (x :- X34) / h)) /  (N * h)
	est35 = sum(normalden( (x :- X35) / h)) /  (N * h)
	est36 = sum(normalden( (x :- X36) / h)) /  (N * h)
	est37 = sum(normalden( (x :- X37) / h)) /  (N * h)
	est38 = sum(normalden( (x :- X38) / h)) /  (N * h)
	est39 = sum(normalden( (x :- X39) / h)) /  (N * h)
	
	k = normalden((x :- X)/h)
	k21 = normalden((x :- X21)/h)
	k22 = normalden((x :- X22)/h)
	k23 = normalden((x :- X23)/h)
	k24 = normalden((x :- X24)/h)
	k31 = normalden((x :- X31)/h)
	k32 = normalden((x :- X32)/h)
	k33 = normalden((x :- X33)/h)
	k34 = normalden((x :- X34)/h)
	k35 = normalden((x :- X35)/h)
	k36 = normalden((x :- X36)/h)
	k37 = normalden((x :- X37)/h)
	k38 = normalden((x :- X38)/h)
	k39 = normalden((x :- X39)/h)

	// TOJ estimate
	tojest = 3.536 * est - 4.072 * (est21 + est22 + est23 + est24) / 4 + 1.536 * (est31 + est32 + est33 + est34 + est35 + est36 + est37 + est38 + est39) / 9
	kest = 3.536 * k - 4.072 * (k21 + k22 + k23 + k24) / 4 + 1.536 * (k31 + k32 + k33 + k34 + k35 + k36 + k37 + k38 + k39) / 9
	se = sqrt((1 / (N - 1)) * ((1 / (N * h^2)) * sum(kest:^2) - tojest^2))
	
	return((tojest, se))
}


function m_tojkd(data, acov_order, acor_order) {
    N = rows(data)
	S = cols(data)
	grid = 100
	
	mean_est = J(N,1,0)
	acov_est = J(N,1,0)
	acor_est = J(N,1,0)
	for (i=1 ; i<=N ; i++){
	    mean_est[i] = mean(data[i,.]')
		acov_est[i] = mataacov(data[i,.], acov_order) 
		acor_est[i] = mataacor(data[i,.], acor_order)
	}

	mean_bw = kdens_bw_dpi(mean_est, level = 2)
	acov_bw = kdens_bw_dpi(acov_est, level = 2)
	acor_bw = kdens_bw_dpi(acor_est, level = 2)
	
	mean_lim = (min(mean_est), max(mean_est))
    acov_lim = (min(acov_est), max(acov_est))
    acor_lim = (min(acor_est), max(acor_est))
    
	mean_grid = rangen(mean_lim[1], mean_lim[2], grid)
	acov_grid = rangen(acov_lim[1], acov_lim[2], grid)
	acor_grid = rangen(acor_lim[1], acor_lim[2], grid)
	
	mean_dest = J(grid, 1, 0)
	acov_dest = J(grid, 1, 0)
    acor_dest = J(grid, 1, 0)
	
	mean_UCI = J(grid,1,0)
	acov_UCI = J(grid,1,0)
	acor_UCI = J(grid,1,0)
	
	mean_LCI = J(grid,1,0)
	acor_LCI = J(grid,1,0)
	acov_LCI = J(grid,1,0)
	
	mean_se = J(grid,1,0)
	acov_se = J(grid,1,0)
	acor_se = J(grid,1,0)

	if (mod(S,6) == 0) {
	    
		data21 = data[., 1::(S / 2)]
		data22 = data[., (S / 2 + 1)::S]
		data31 = data[., 1::(S / 3)]
		data32 = data[., (S / 3 + 1)::(2*S / 3)]
		data33 = data[., (2 * S / 3 + 1)::S]
	    
		mean_est21 = J(N,1,0)
		mean_est22 = J(N,1,0)
		mean_est31 = J(N,1,0)
		mean_est32 = J(N,1,0)
		mean_est33 = J(N,1,0)
	
		acov_est21 = J(N,1,0)
		acov_est22 = J(N,1,0)
		acov_est31 = J(N,1,0)
		acov_est32 = J(N,1,0)
		acov_est33 = J(N,1,0)
	
		acor_est21 = J(N,1,0)
		acor_est22 = J(N,1,0)
		acor_est31 = J(N,1,0)
		acor_est32 = J(N,1,0)
		acor_est33 = J(N,1,0)
		
		for (i=1 ; i<=N ; i++){
			mean_est21[i] = mean(data21[i,.]')
			mean_est22[i] = mean(data22[i,.]')
			mean_est31[i] = mean(data31[i,.]')
			mean_est32[i] = mean(data32[i,.]')
			mean_est33[i] = mean(data33[i,.]')
		
			acov_est21[i] = mataacov(data21[i,.], acov_order) 
			acov_est22[i] = mataacov(data22[i,.], acov_order)
			acov_est31[i] = mataacov(data31[i,.], acov_order)
			acov_est32[i] = mataacov(data32[i,.], acov_order)
			acov_est33[i] = mataacov(data33[i,.], acov_order)
		
			acor_est21[i] = mataacor(data21[i,.], acor_order)
			acor_est22[i] = mataacor(data22[i,.], acor_order)
			acor_est31[i] = mataacor(data31[i,.], acor_order)
			acor_est32[i] = mataacor(data32[i,.], acor_order)
			acor_est33[i] = mataacor(data33[i,.], acor_order)
		}
		for (i = 1; i <= grid; i++) {
			k = tojkdest0(mean_grid[i], mean_est, mean_est21, mean_est22, mean_est31, mean_est32, mean_est33, mean_bw)
			mean_dest[i] = k[1]
		    mean_se[i] = k[2]
		    mean_LCI[i] = max((0,mean_dest[i] - 1.96 * mean_se[i]))
		    mean_UCI[i] = max((0,mean_dest[i] + 1.96 * mean_se[i]))
			mean_dest[i] = max((0,mean_dest[i]))
			
			k = tojkdest0(acov_grid[i], acov_est, acov_est21, acov_est22, acov_est31, acov_est32, acov_est33, acov_bw)
			acov_dest[i] = k[1]
		    acov_se[i] = k[2]
		    acov_LCI[i] = max((0,acov_dest[i] - 1.96 * acov_se[i]))
		    acov_UCI[i] = max((0,acov_dest[i] + 1.96 * acov_se[i]))
			acov_dest[i] = max((0,acov_dest[i]))
			
			k = tojkdest0(acor_grid[i], acor_est, acor_est21, acor_est22, acor_est31, acor_est32, acor_est33, acor_bw)
			acor_dest[i] = k[1]
		    acor_se[i] = k[2]
		    acor_LCI[i] = max((0,acor_dest[i] - 1.96 * acor_se[i]))
		    acor_UCI[i] = max((0,acor_dest[i] + 1.96 * acor_se[i]))
			acor_dest[i] = max((0,acor_dest[i]))
		}    	
	} else if (mod(S,6)==1){

    // split  panel data for T equivalent to 1 modulo 6
		data21 = data[., 1::floor(S / 2)]
		data22 = data[., (floor(S / 2) + 1)::S]
		data23 = data[., 1::ceil(S / 2)]
		data24 = data[., (ceil(S / 2) + 1)::S]
		data31 = data[., 1::floor(S / 3)]
		data32 = data[., (floor(S / 3) + 1)::(2 * floor(S / 3))]
		data33 = data[., (2 * floor(S / 3) + 1)::S]
		data34 = data[., 1::floor(S / 3)]
		data35 = data[., (floor(S / 3) + 1)::(2 * floor(S / 3) + 1)]
		data36 = data[., (2 * floor(S / 3) + 2)::S]
		data37 = data[., 1::ceil(S / 3)]
		data38 = data[., (ceil(S / 3) + 1)::(2 * floor(S / 3) + 1)]
		data39 = data[., (2 * floor(S / 3) + 2)::S]

     // estimated quantities for split panel data
		mean_est21 = J(N,1,0)
		mean_est22 = J(N,1,0)
		mean_est23 = J(N,1,0)
		mean_est24 = J(N,1,0)
		mean_est31 = J(N,1,0)
		mean_est32 = J(N,1,0)
		mean_est33 = J(N,1,0)
		mean_est34 = J(N,1,0)
		mean_est35 = J(N,1,0)
		mean_est36 = J(N,1,0)
		mean_est37 = J(N,1,0)
		mean_est38 = J(N,1,0)
		mean_est39 = J(N,1,0)
    
        acov_est21 = J(N,1,0)
		acov_est22 = J(N,1,0)
		acov_est23 = J(N,1,0)
		acov_est24 = J(N,1,0)
		acov_est31 = J(N,1,0)
		acov_est32 = J(N,1,0)
		acov_est33 = J(N,1,0)
		acov_est34 = J(N,1,0)
		acov_est35 = J(N,1,0)
		acov_est36 = J(N,1,0)
		acov_est37 = J(N,1,0)
		acov_est38 = J(N,1,0)
		acov_est39 = J(N,1,0)
		
	    acor_est21 = J(N,1,0)
		acor_est22 = J(N,1,0)
		acor_est23 = J(N,1,0)
		acor_est24 = J(N,1,0)
		acor_est31 = J(N,1,0)
		acor_est32 = J(N,1,0)
		acor_est33 = J(N,1,0)
		acor_est34 = J(N,1,0)
		acor_est35 = J(N,1,0)
		acor_est36 = J(N,1,0)
		acor_est37 = J(N,1,0)
		acor_est38 = J(N,1,0)
		acor_est39 = J(N,1,0)

        for (i=1 ; i<=N ; i++){
			mean_est21[i] = mean(data21[i,.]')
			mean_est22[i] = mean(data22[i,.]')
			mean_est23[i] = mean(data23[i,.]')
			mean_est24[i] = mean(data24[i,.]')
			mean_est31[i] = mean(data31[i,.]')
			mean_est32[i] = mean(data32[i,.]')
			mean_est33[i] = mean(data33[i,.]')
		    mean_est34[i] = mean(data34[i,.]')
			mean_est35[i] = mean(data35[i,.]')
			mean_est36[i] = mean(data36[i,.]')
		    mean_est37[i] = mean(data37[i,.]')
			mean_est38[i] = mean(data38[i,.]')
			mean_est39[i] = mean(data39[i,.]')
		
			acov_est21[i] = mataacov(data21[i,.], acov_order) 
			acov_est22[i] = mataacov(data22[i,.], acov_order)
			acov_est23[i] = mataacov(data23[i,.], acov_order) 
			acov_est24[i] = mataacov(data24[i,.], acov_order)
			acov_est31[i] = mataacov(data31[i,.], acov_order)
			acov_est32[i] = mataacov(data32[i,.], acov_order)
			acov_est33[i] = mataacov(data33[i,.], acov_order)
			acov_est34[i] = mataacov(data34[i,.], acov_order)
            acov_est35[i] = mataacov(data35[i,.], acov_order)
			acov_est36[i] = mataacov(data36[i,.], acov_order)
			acov_est37[i] = mataacov(data37[i,.], acov_order)
            acov_est38[i] = mataacov(data38[i,.], acov_order)
			acov_est39[i] = mataacov(data39[i,.], acov_order)
                
			acor_est21[i] = mataacor(data21[i,.], acor_order)
			acor_est22[i] = mataacor(data22[i,.], acor_order)
			acor_est23[i] = mataacor(data23[i,.], acor_order)
			acor_est24[i] = mataacor(data24[i,.], acor_order)
			acor_est31[i] = mataacor(data31[i,.], acor_order)
			acor_est32[i] = mataacor(data32[i,.], acor_order)
			acor_est33[i] = mataacor(data33[i,.], acor_order)
			acor_est34[i] = mataacor(data34[i,.], acor_order)
			acor_est35[i] = mataacor(data35[i,.], acor_order)
			acor_est36[i] = mataacor(data36[i,.], acor_order)
			acor_est37[i] = mataacor(data37[i,.], acor_order)
			acor_est38[i] = mataacor(data38[i,.], acor_order)
			acor_est39[i] = mataacor(data39[i,.], acor_order)	
		}
		
		for (i = 1; i <= grid; i++) {
			k = tojkdest1(mean_grid[i], mean_est, mean_est21, mean_est22, mean_est23, mean_est24, mean_est31, mean_est32, mean_est33, mean_est34, mean_est35, mean_est36, mean_est37, mean_est38, mean_est39, mean_bw)
			mean_dest[i] = k[1]
			mean_se[i] = k[2]
			mean_LCI[i] = max((0,mean_dest[i] - 1.96 * mean_se[i]))
		    mean_UCI[i] = max((0,mean_dest[i] + 1.96 * mean_se[i]))
			mean_dest[i] = max((0,mean_dest[i]))
			
			k = tojkdest1(acov_grid[i], acov_est, acov_est21, acov_est22, acov_est23, acov_est24, acov_est31, acov_est32, acov_est33, acov_est34, acov_est35, acov_est36, acov_est37, acov_est38, acov_est39, acov_bw)
			acov_dest[i] = k[1]
		    acov_se[i] = k[2]
		    acov_LCI[i] = max((0,acov_dest[i] - 1.96 * acov_se[i]))
		    acov_UCI[i] = max((0,acov_dest[i] + 1.96 * acov_se[i]))
			acov_dest[i] = max((0,acov_dest[i]))
			
			k = tojkdest1(acor_grid[i], acor_est, acor_est21, acor_est22, acor_est23, acor_est24, acor_est31, acor_est32, acor_est33, acor_est34, acor_est35, acor_est36, acor_est37, acor_est38, acor_est39, acor_bw)
			acor_dest[i] = k[1]
		    acor_se[i] = k[2]
		    acor_LCI[i] = max((0,acor_dest[i] - 1.96 * acor_se[i]))
		    acor_UCI[i] = max((0,acor_dest[i] + 1.96 * acor_se[i]))
			acor_dest[i] = max((0,acor_dest[i]))
		}
		
	} else if (mod(S,6)==2){
    
    // split  panel data for T equivalent to 2 modulo 6
		data21 = data[., 1::(S / 2)]
		data22 = data[., (S / 2 + 1)::S]
		data31 = data[., 1::floor(S / 3)]
		data32 = data[., (floor(S / 3) + 1)::(2 * floor(S / 3) + 1) ]
		data33 = data[., (2 * ceil(S / 3))::S]
		data34 = data[., 1::ceil(S / 3)]
		data35 = data[., (ceil(S / 3) + 1)::(2 * floor(S / 3) + 1)]
		data36 = data[., (2 * ceil(S / 3))::S]
		data37 = data[., 1::ceil(S / 3)]
		data38 = data[., (ceil(S / 3) + 1)::(2 * ceil(S / 3))]
		data39 = data[., (2 * ceil(S / 3) + 1)::S]

    // estimated quantities for split panel data
		mean_est21 = J(N,1,0)
		mean_est22 = J(N,1,0)
		mean_est31 = J(N,1,0)
		mean_est32 = J(N,1,0)
		mean_est33 = J(N,1,0)
		mean_est34 = J(N,1,0)
		mean_est35 = J(N,1,0)
		mean_est36 = J(N,1,0)
		mean_est37 = J(N,1,0)
		mean_est38 = J(N,1,0)
		mean_est39 = J(N,1,0)
    
        acov_est21 = J(N,1,0)
		acov_est22 = J(N,1,0)
		acov_est31 = J(N,1,0)
		acov_est32 = J(N,1,0)
		acov_est33 = J(N,1,0)
		acov_est34 = J(N,1,0)
		acov_est35 = J(N,1,0)
		acov_est36 = J(N,1,0)
		acov_est37 = J(N,1,0)
		acov_est38 = J(N,1,0)
		acov_est39 = J(N,1,0)
		
	    acor_est21 = J(N,1,0)
		acor_est22 = J(N,1,0)
		acor_est31 = J(N,1,0)
		acor_est32 = J(N,1,0)
		acor_est33 = J(N,1,0)
		acor_est34 = J(N,1,0)
		acor_est35 = J(N,1,0)
		acor_est36 = J(N,1,0)
		acor_est37 = J(N,1,0)
		acor_est38 = J(N,1,0)
		acor_est39 = J(N,1,0)

        for (i=1 ; i<=N ; i++){
			mean_est21[i] = mean(data21[i,.]')
			mean_est22[i] = mean(data22[i,.]')
			mean_est31[i] = mean(data31[i,.]')
			mean_est32[i] = mean(data32[i,.]')
			mean_est33[i] = mean(data33[i,.]')
		    mean_est34[i] = mean(data34[i,.]')
			mean_est35[i] = mean(data35[i,.]')
			mean_est36[i] = mean(data36[i,.]')
		    mean_est37[i] = mean(data37[i,.]')
			mean_est38[i] = mean(data38[i,.]')
			mean_est39[i] = mean(data39[i,.]')
		
			acov_est21[i] = mataacov(data21[i,.], acov_order) 
			acov_est22[i] = mataacov(data22[i,.], acov_order)
			acov_est31[i] = mataacov(data31[i,.], acov_order)
			acov_est32[i] = mataacov(data32[i,.], acov_order)
			acov_est33[i] = mataacov(data33[i,.], acov_order)
			acov_est34[i] = mataacov(data34[i,.], acov_order)
            acov_est35[i] = mataacov(data35[i,.], acov_order)
			acov_est36[i] = mataacov(data36[i,.], acov_order)
			acov_est37[i] = mataacov(data37[i,.], acov_order)
            acov_est38[i] = mataacov(data38[i,.], acov_order)
			acov_est39[i] = mataacov(data39[i,.], acov_order)
                
			acor_est21[i] = mataacor(data21[i,.], acor_order)
			acor_est22[i] = mataacor(data22[i,.], acor_order)
			acor_est31[i] = mataacor(data31[i,.], acor_order)
			acor_est32[i] = mataacor(data32[i,.], acor_order)
			acor_est33[i] = mataacor(data33[i,.], acor_order)
			acor_est34[i] = mataacor(data34[i,.], acor_order)
			acor_est35[i] = mataacor(data35[i,.], acor_order)
			acor_est36[i] = mataacor(data36[i,.], acor_order)
			acor_est37[i] = mataacor(data37[i,.], acor_order)
			acor_est38[i] = mataacor(data38[i,.], acor_order)
			acor_est39[i] = mataacor(data39[i,.], acor_order)	
		}
		
		for (i = 1; i <= grid; i++) {
			k = tojkdest2(mean_grid[i], mean_est, mean_est21, mean_est22, mean_est31, mean_est32, mean_est33, mean_est34, mean_est35, mean_est36, mean_est37, mean_est38, mean_est39, mean_bw)
			mean_dest[i] = k[1]
		    mean_se[i] = k[2]
		    mean_LCI[i] = max((0,mean_dest[i] - 1.96 * mean_se[i]))
		    mean_UCI[i] = max((0,mean_dest[i] + 1.96 * mean_se[i]))
			mean_dest[i] = max((0,mean_dest[i]))
			
			k = tojkdest2(acov_grid[i], acov_est, acov_est21, acov_est22, acov_est31, acov_est32, acov_est33, acov_est34, acov_est35, acov_est36, acov_est37, acov_est38, acov_est39, acov_bw)
			acov_dest[i] = k[1]
		    acov_se[i] = k[2]
		    acov_LCI[i] = max((0,acov_dest[i] - 1.96 * acov_se[i]))
		    acov_UCI[i] = max((0,acov_dest[i] + 1.96 * acov_se[i]))
			acov_dest[i] = max((0,acov_dest[i]))
			
			k = tojkdest2(acor_grid[i], acor_est, acor_est21, acor_est22, acor_est31, acor_est32, acor_est33, acor_est34, acor_est35, acor_est36, acor_est37, acor_est38, acor_est39, acor_bw)
			acor_dest[i] = k[1]
		    acor_se[i] = k[2]
		    acor_LCI[i] = max((0,acor_dest[i] - 1.96 * acor_se[i]))
		    acor_UCI[i] = max((0,acor_dest[i] + 1.96 * acor_se[i]))
			acor_dest[i] = max((0,acor_dest[i]))
			
		}
		
	} else if (mod(S,6) == 3) {
    
		// split  panel data for T equivalent to 3 modulo 6
		data21 = data[., 1::floor(S / 2)]
		data22 = data[., (floor(S / 2) + 1)::S]
		data23 = data[., 1::ceil(S / 2)]
		data24 = data[., (ceil(S / 2) + 1)::S]
		data31 = data[., 1::(S / 3)]
		data32 = data[., (S / 3 + 1)::(2*S / 3)]
		data33 = data[., (2 * S / 3 + 1)::S]

		// estimated quantities for split panel data
		mean_est21 = J(N,1,0)
		mean_est22 = J(N,1,0)
		mean_est23 = J(N,1,0)
		mean_est24 = J(N,1,0)
		mean_est31 = J(N,1,0)
		mean_est32 = J(N,1,0)
		mean_est33 = J(N,1,0)
    
        acov_est21 = J(N,1,0)
		acov_est22 = J(N,1,0)
		acov_est23 = J(N,1,0)
		acov_est24 = J(N,1,0)
		acov_est31 = J(N,1,0)
		acov_est32 = J(N,1,0)
		acov_est33 = J(N,1,0)
		
	    acor_est21 = J(N,1,0)
		acor_est22 = J(N,1,0)
		acor_est23 = J(N,1,0)
		acor_est24 = J(N,1,0)
		acor_est31 = J(N,1,0)
		acor_est32 = J(N,1,0)
		acor_est33 = J(N,1,0)

        for (i=1 ; i<=N ; i++){
			mean_est21[i] = mean(data21[i,.]')
			mean_est22[i] = mean(data22[i,.]')
			mean_est23[i] = mean(data23[i,.]')
			mean_est24[i] = mean(data24[i,.]')
			mean_est31[i] = mean(data31[i,.]')
			mean_est32[i] = mean(data32[i,.]')
			mean_est33[i] = mean(data33[i,.]')
		
			acov_est21[i] = mataacov(data21[i,.], acov_order) 
			acov_est22[i] = mataacov(data22[i,.], acov_order)
			acov_est23[i] = mataacov(data23[i,.], acov_order) 
			acov_est24[i] = mataacov(data24[i,.], acov_order)
			acov_est31[i] = mataacov(data31[i,.], acov_order)
			acov_est32[i] = mataacov(data32[i,.], acov_order)
			acov_est33[i] = mataacov(data33[i,.], acov_order)
                
			acor_est21[i] = mataacor(data21[i,.], acor_order)
			acor_est22[i] = mataacor(data22[i,.], acor_order)
			acor_est23[i] = mataacor(data23[i,.], acor_order)
			acor_est24[i] = mataacor(data24[i,.], acor_order)
			acor_est31[i] = mataacor(data31[i,.], acor_order)
			acor_est32[i] = mataacor(data32[i,.], acor_order)
			acor_est33[i] = mataacor(data33[i,.], acor_order)	
		}
		
		for (i = 1; i <= grid; i++) {
			k = tojkdest3(mean_grid[i], mean_est, mean_est21, mean_est22, mean_est23, mean_est24, mean_est31, mean_est32, mean_est33, mean_bw)
			mean_dest[i] = k[1]
		    mean_se[i] = k[2]
		    mean_LCI[i] = max((0,mean_dest[i] - 1.96 * mean_se[i]))
		    mean_UCI[i] = max((0,mean_dest[i] + 1.96 * mean_se[i]))
			mean_dest[i] = max((0,mean_dest[i]))
			
			k = tojkdest3(acov_grid[i], acov_est, acov_est21, acov_est22, acov_est23, acov_est24, acov_est31, acov_est32, acov_est33, acov_bw)
			acov_dest[i] = k[1]
		    acov_se[i] = k[2]
		    acov_LCI[i] = max((0,acov_dest[i] - 1.96 * acov_se[i]))
		    acov_UCI[i] = max((0,acov_dest[i] + 1.96 * acov_se[i]))
			acov_dest[i] = max((0,acov_dest[i]))
			
			k = tojkdest3(acor_grid[i], acor_est, acor_est21, acor_est22, acor_est23, acor_est24, acor_est31, acor_est32, acor_est33, acor_bw)
			acor_dest[i] = k[1]
		    acor_se[i] = k[2]
		    acor_LCI[i] = max((0,acor_dest[i] - 1.96 * acor_se[i]))
		    acor_UCI[i] = max((0,acor_dest[i] + 1.96 * acor_se[i]))
			acor_dest[i] = max((0,acor_dest[i]))
		}

	} else if (mod(S,6)==4) {

    // split  panel data for T equivalent to 4 modulo 6
		data21 = data[., 1::(S / 2)]
		data22 = data[., (S / 2 + 1)::S]
		data31 = data[., 1::floor(S / 3)]
		data32 = data[., (floor(S / 3) + 1)::(2 * floor(S / 3))]
		data33 = data[., (2 * floor(S / 3) + 1)::S]
		data34 = data[., 1::floor(S / 3)]
		data35 = data[., (floor(S / 3) + 1)::(2 * floor(S / 3) + 1)]
		data36 = data[., (2 * floor(S / 3) + 2)::S]
		data37 = data[., 1::ceil(S / 3)]
		data38 = data[., (ceil(S / 3) + 1)::(2 * floor(S / 3) + 1)]
		data39 = data[., (2 * floor(S / 3) + 2)::S]

        // estimated quantities for split panel data
		mean_est21 = J(N,1,0)
		mean_est22 = J(N,1,0)
		mean_est31 = J(N,1,0)
		mean_est32 = J(N,1,0)
		mean_est33 = J(N,1,0)
		mean_est34 = J(N,1,0)
		mean_est35 = J(N,1,0)
		mean_est36 = J(N,1,0)
		mean_est37 = J(N,1,0)
		mean_est38 = J(N,1,0)
		mean_est39 = J(N,1,0)
    
        acov_est21 = J(N,1,0)
		acov_est22 = J(N,1,0)
		acov_est31 = J(N,1,0)
		acov_est32 = J(N,1,0)
		acov_est33 = J(N,1,0)
		acov_est34 = J(N,1,0)
		acov_est35 = J(N,1,0)
		acov_est36 = J(N,1,0)
		acov_est37 = J(N,1,0)
		acov_est38 = J(N,1,0)
		acov_est39 = J(N,1,0)
		
	    acor_est21 = J(N,1,0)
		acor_est22 = J(N,1,0)
		acor_est31 = J(N,1,0)
		acor_est32 = J(N,1,0)
		acor_est33 = J(N,1,0)
		acor_est34 = J(N,1,0)
		acor_est35 = J(N,1,0)
		acor_est36 = J(N,1,0)
		acor_est37 = J(N,1,0)
		acor_est38 = J(N,1,0)
		acor_est39 = J(N,1,0)

        for (i=1 ; i<=N ; i++){
			mean_est21[i] = mean(data21[i,.]')
			mean_est22[i] = mean(data22[i,.]')
			mean_est31[i] = mean(data31[i,.]')
			mean_est32[i] = mean(data32[i,.]')
			mean_est33[i] = mean(data33[i,.]')
		    mean_est34[i] = mean(data34[i,.]')
			mean_est35[i] = mean(data35[i,.]')
			mean_est36[i] = mean(data36[i,.]')
		    mean_est37[i] = mean(data37[i,.]')
			mean_est38[i] = mean(data38[i,.]')
			mean_est39[i] = mean(data39[i,.]')
		
			acov_est21[i] = mataacov(data21[i,.], acov_order) 
			acov_est22[i] = mataacov(data22[i,.], acov_order)
			acov_est31[i] = mataacov(data31[i,.], acov_order)
			acov_est32[i] = mataacov(data32[i,.], acov_order)
			acov_est33[i] = mataacov(data33[i,.], acov_order)
			acov_est34[i] = mataacov(data34[i,.], acov_order)
            acov_est35[i] = mataacov(data35[i,.], acov_order)
			acov_est36[i] = mataacov(data36[i,.], acov_order)
			acov_est37[i] = mataacov(data37[i,.], acov_order)
            acov_est38[i] = mataacov(data38[i,.], acov_order)
			acov_est39[i] = mataacov(data39[i,.], acov_order)
                
			acor_est21[i] = mataacor(data21[i,.], acor_order)
			acor_est22[i] = mataacor(data22[i,.], acor_order)
			acor_est31[i] = mataacor(data31[i,.], acor_order)
			acor_est32[i] = mataacor(data32[i,.], acor_order)
			acor_est33[i] = mataacor(data33[i,.], acor_order)
			acor_est34[i] = mataacor(data34[i,.], acor_order)
			acor_est35[i] = mataacor(data35[i,.], acor_order)
			acor_est36[i] = mataacor(data36[i,.], acor_order)
			acor_est37[i] = mataacor(data37[i,.], acor_order)
			acor_est38[i] = mataacor(data38[i,.], acor_order)
			acor_est39[i] = mataacor(data39[i,.], acor_order)	
		}
		
		for (i = 1; i <= grid; i++) {
			k = tojkdest4(mean_grid[i], mean_est, mean_est21, mean_est22, mean_est31, mean_est32, mean_est33, mean_est34, mean_est35, mean_est36, mean_est37, mean_est38, mean_est39, mean_bw)
			mean_dest[i] = k[1]
		    mean_se[i] = k[2]
		    mean_LCI[i] = max((0,mean_dest[i] - 1.96 * mean_se[i]))
		    mean_UCI[i] = max((0,mean_dest[i] + 1.96 * mean_se[i]))
			mean_dest[i] = max((0,mean_dest[i]))
			
			k = tojkdest4(acov_grid[i], acov_est, acov_est21, acov_est22, acov_est31, acov_est32, acov_est33, acov_est34, acov_est35, acov_est36, acov_est37, acov_est38, acov_est39, acov_bw)
			acov_dest[i] = k[1]
		    acov_se[i] = k[2]
		    acov_LCI[i] = max((0,acov_dest[i] - 1.96 * acov_se[i]))
		    acov_UCI[i] = max((0,acov_dest[i] + 1.96 * acov_se[i]))
			acov_dest[i] = max((0,acov_dest[i]))
			
			k = tojkdest4(acor_grid[i], acor_est, acor_est21, acor_est22, acor_est31, acor_est32, acor_est33, acor_est34, acor_est35, acor_est36, acor_est37, acor_est38, acor_est39, acor_bw)
			acor_dest[i] = k[1]
		    acor_se[i] = k[2]
		    acor_LCI[i] = max((0,acor_dest[i] - 1.96 * acor_se[i]))
		    acor_UCI[i] = max((0,acor_dest[i] + 1.96 * acor_se[i]))
			acor_dest[i] = max((0,acor_dest[i]))
		}
		
	} else {

		// split  panel data for T equivalent to 5 modulo 6
		data21 = data[., 1::floor(S / 2)]
		data22 = data[., (floor(S / 2) + 1)::S]
		data23 = data[., 1::ceil(S / 2)]
		data24 = data[., (ceil(S / 2) + 1)::S]
		data31 = data[., 1::floor(S / 3)]
		data32 = data[., (floor(S / 3) + 1)::(2 * floor(S / 3) + 1) ]
		data33 = data[., (2 * ceil(S / 3))::S]
		data34 = data[., 1::ceil(S / 3)]
		data35 = data[., (ceil(S / 3) + 1)::(2 * floor(S / 3) + 1)]
		data36 = data[., (2 * ceil(S / 3))::S]
		data37 = data[., 1::ceil(S / 3)]
		data38 = data[., (ceil(S / 3) + 1)::(2 * ceil(S / 3))]
		data39 = data[., (2 * ceil(S / 3) + 1)::S]
        
		// estimated quantities for split panel data
		mean_est21 = J(N,1,0)
		mean_est22 = J(N,1,0)
		mean_est23 = J(N,1,0)
		mean_est24 = J(N,1,0)
		mean_est31 = J(N,1,0)
		mean_est32 = J(N,1,0)
		mean_est33 = J(N,1,0)
		mean_est34 = J(N,1,0)
		mean_est35 = J(N,1,0)
		mean_est36 = J(N,1,0)
		mean_est37 = J(N,1,0)
		mean_est38 = J(N,1,0)
		mean_est39 = J(N,1,0)
    
        acov_est21 = J(N,1,0)
		acov_est22 = J(N,1,0)
		acov_est23 = J(N,1,0)
		acov_est24 = J(N,1,0)
		acov_est31 = J(N,1,0)
		acov_est32 = J(N,1,0)
		acov_est33 = J(N,1,0)
		acov_est34 = J(N,1,0)
		acov_est35 = J(N,1,0)
		acov_est36 = J(N,1,0)
		acov_est37 = J(N,1,0)
		acov_est38 = J(N,1,0)
		acov_est39 = J(N,1,0)
		
	    acor_est21 = J(N,1,0)
		acor_est22 = J(N,1,0)
		acor_est23 = J(N,1,0)
		acor_est24 = J(N,1,0)
		acor_est31 = J(N,1,0)
		acor_est32 = J(N,1,0)
		acor_est33 = J(N,1,0)
		acor_est34 = J(N,1,0)
		acor_est35 = J(N,1,0)
		acor_est36 = J(N,1,0)
		acor_est37 = J(N,1,0)
		acor_est38 = J(N,1,0)
		acor_est39 = J(N,1,0)

        for (i=1 ; i<=N ; i++){
			mean_est21[i] = mean(data21[i,.]')
			mean_est22[i] = mean(data22[i,.]')
			mean_est23[i] = mean(data23[i,.]')
			mean_est24[i] = mean(data24[i,.]')
			mean_est31[i] = mean(data31[i,.]')
			mean_est32[i] = mean(data32[i,.]')
			mean_est33[i] = mean(data33[i,.]')
		    mean_est34[i] = mean(data34[i,.]')
			mean_est35[i] = mean(data35[i,.]')
			mean_est36[i] = mean(data36[i,.]')
		    mean_est37[i] = mean(data37[i,.]')
			mean_est38[i] = mean(data38[i,.]')
			mean_est39[i] = mean(data39[i,.]')
		
			acov_est21[i] = mataacov(data21[i,.], acov_order) 
			acov_est22[i] = mataacov(data22[i,.], acov_order)
			acov_est23[i] = mataacov(data23[i,.], acov_order) 
			acov_est24[i] = mataacov(data24[i,.], acov_order)
			acov_est31[i] = mataacov(data31[i,.], acov_order)
			acov_est32[i] = mataacov(data32[i,.], acov_order)
			acov_est33[i] = mataacov(data33[i,.], acov_order)
			acov_est34[i] = mataacov(data34[i,.], acov_order)
            acov_est35[i] = mataacov(data35[i,.], acov_order)
			acov_est36[i] = mataacov(data36[i,.], acov_order)
			acov_est37[i] = mataacov(data37[i,.], acov_order)
            acov_est38[i] = mataacov(data38[i,.], acov_order)
			acov_est39[i] = mataacov(data39[i,.], acov_order)
                
			acor_est21[i] = mataacor(data21[i,.], acor_order)
			acor_est22[i] = mataacor(data22[i,.], acor_order)
			acor_est23[i] = mataacor(data23[i,.], acor_order)
			acor_est24[i] = mataacor(data24[i,.], acor_order)
			acor_est31[i] = mataacor(data31[i,.], acor_order)
			acor_est32[i] = mataacor(data32[i,.], acor_order)
			acor_est33[i] = mataacor(data33[i,.], acor_order)
			acor_est34[i] = mataacor(data34[i,.], acor_order)
			acor_est35[i] = mataacor(data35[i,.], acor_order)
			acor_est36[i] = mataacor(data36[i,.], acor_order)
			acor_est37[i] = mataacor(data37[i,.], acor_order)
			acor_est38[i] = mataacor(data38[i,.], acor_order)
			acor_est39[i] = mataacor(data39[i,.], acor_order)	
		}
		
		for (i = 1; i <= grid; i++) {
			k = tojkdest5(mean_grid[i], mean_est, mean_est21, mean_est22, mean_est23, mean_est24, mean_est31, mean_est32, mean_est33, mean_est34, mean_est35, mean_est36, mean_est37, mean_est38, mean_est39, mean_bw)
			mean_dest[i] = k[1]
		    mean_se[i] = k[2]
		    mean_LCI[i] = max((0,mean_dest[i] - 1.96 * mean_se[i]))
		    mean_UCI[i] = max((0,mean_dest[i] + 1.96 * mean_se[i]))
			mean_dest[i] = max((0,mean_dest[i]))
			
			k = tojkdest5(acov_grid[i], acov_est, acov_est21, acov_est22, acov_est23, acov_est24, acov_est31, acov_est32, acov_est33, acov_est34, acov_est35, acov_est36, acov_est37, acov_est38, acov_est39, acov_bw)
			acov_dest[i] = k[1]
		    acov_se[i] = k[2]
		    acov_LCI[i] = max((0,acov_dest[i] - 1.96 * acov_se[i]))
		    acov_UCI[i] = max((0,acov_dest[i] + 1.96 * acov_se[i]))
			acov_dest[i] = max((0,acov_dest[i]))
			
			k = tojkdest5(acor_grid[i], acor_est, acor_est21, acor_est22, acor_est23, acor_est24, acor_est31, acor_est32, acor_est33, acor_est34, acor_est35, acor_est36, acor_est37, acor_est38, acor_est39, acor_bw)
			acor_dest[i] = k[1]
		    acor_se[i] = k[2]
		    acor_LCI[i] = max((0,acor_dest[i] - 1.96 * acor_se[i]))
		    acor_UCI[i] = max((0,acor_dest[i] + 1.96 * acor_se[i]))
			acor_dest[i] = max((0,acor_dest[i]))
		}
	}
	
    temp=st_addvar("double", "mean_dest")
    temp=st_addvar("double", "acov_dest")
    temp=st_addvar("double", "acor_dest")
    temp=st_addvar("double", "mean_grid")
	temp=st_addvar("double", "acov_grid")
	temp=st_addvar("double", "acor_grid")
	
	temp=st_addvar("double", "mean_LCI")
    temp=st_addvar("double", "acov_LCI")
    temp=st_addvar("double", "acor_LCI")
    temp=st_addvar("double", "mean_UCI")
	temp=st_addvar("double", "acov_UCI")
	temp=st_addvar("double", "acor_UCI")
	
    st_addobs(max((0,grid  - st_nobs())))
    st_store(.,"mean_dest", mean_dest\J(st_nobs()-rows(mean_dest),1,.))
    st_store(.,"acov_dest", acov_dest\J(st_nobs()-rows(acov_dest),1,.))
    st_store(.,"acor_dest", acor_dest\J(st_nobs()-rows(acor_dest),1,.))
    st_store(.,"mean_grid", mean_grid\J(st_nobs()-rows(mean_grid),1,.))
	st_store(.,"acov_grid", acov_grid\J(st_nobs()-rows(acov_grid),1,.))
    st_store(.,"acor_grid", acor_grid\J(st_nobs()-rows(acor_grid),1,.))
	
	st_store(.,"mean_LCI", mean_LCI\J(st_nobs()-rows(mean_LCI),1,.))
    st_store(.,"acov_LCI", acov_LCI\J(st_nobs()-rows(acov_LCI),1,.))
    st_store(.,"acor_LCI", acor_LCI\J(st_nobs()-rows(acor_LCI),1,.))
	st_store(.,"mean_UCI", mean_UCI\J(st_nobs()-rows(mean_UCI),1,.))
    st_store(.,"acov_UCI", acov_UCI\J(st_nobs()-rows(acov_UCI),1,.))
    st_store(.,"acor_UCI", acor_UCI\J(st_nobs()-rows(acor_UCI),1,.))
	
}

 

mata mlib create lpanelhetero, dir(PERSONAL) replace
mata mlib add lpanelhetero *()
mata mlib index
end
