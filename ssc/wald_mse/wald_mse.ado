*! version 1.0.1 27Mar2017
//wald_mse is a program to evaluate the maximum mean squared-error (MSE) of point 
//estimators of the mean. It takes in the name of an estimator implemented 
//in stata and a sample size and returns the (approximate) maximum MSE of 
//the estimator.

program define wald_mse, rclass
	version 12
	set seed 5
		
	syntax anything , samp_size(real) dist(string) [miss_l(real 0) miss_r(real 1) rdgp_l(real 0) rdgp_r(real 1) mdgp_l(real 0) /*
	*/mdgp_r(real 1) grid(real 0) user_def mc_iter(real 0) h_distance(real 1) true_beta r_shape(real 0) m_shape(real 0) mon_select(real 0)]
	
	tempname cmd est MSE monselect rmeanval mmeanval missval N missl missr hd rdgpl rdgpr mdgpl mdgpr rshape mshape d
    
    //wald_mse will not be able to run a user defined command if there is already data in memory: check if this is the case
    quietly ds
    if("`r(varlist)'" != "" && "`user_def'" != ""){
    	display as error `"wald_mse cannot run a user-defined command while data is in memory, please drop data before continuing."'
    	error 18
    } 
	
	if "`user_def'" == ""{
		local built_indicator 1
	}
	else {
		local built_indicator 0
	}
	
	if "`true_beta'" == ""{
		local tb 0
	}
	else {
		local tb 1
	}
	
	//pass-off workhorse code
	mata: wald_mse_work("`anything'",`samp_size', `miss_l', `miss_r', `rdgp_l', `rdgp_r', `mdgp_l', `mdgp_r',/*
	*/`grid', `built_indicator',`mc_iter',"`dist'",`h_distance',`tb',`r_shape',`m_shape',`mon_select',"`MSE'",/*
	*/"`rmeanval'","`mmeanval'","`missval'")  

	return scalar monselect = `mon_select'
	return scalar rshape = `r_shape'
	return scalar mshape = `m_shape'
	return scalar hd = `h_distance'
	return scalar mdgpr = `mdgp_r'
	return scalar mdgpl = `mdgp_l'
	return scalar rdgpr = `rdgp_r'
	return scalar rdgpl = `rdgp_l'
	return scalar missr = `miss_r'
	return scalar missl = `miss_l'
	return scalar N = `samp_size'
	return scalar missval = `missval'
	return scalar mmeanval = `mmeanval'
	return scalar rmeanval = `rmeanval'
	return scalar MSE = `MSE'
	
		
	return local d = "`dist'"
	return local est = "`anything'"
	return local cmd = "wald_mse"

	
end


mata:

mata set matafavor speed
 
void wald_mse_work(string scalar func_name, real scalar samp_size, real scalar miss_l, real scalar miss_r, 
real scalar rdgp_l, real scalar rdgp_r, real scalar mdgp_l, real scalar mdgp_r, real scalar grid_num, 
real scalar built_in, real scalar MC_iter, string scalar dist, real scalar h_distance, 
real scalar true_beta, real scalar rshape, real scalar mshape,real scalar mon_select, string scalar r_mse, 
string scalar r_mean, string scalar m_mean, string scalar miss_val){
	//--------------Initial error check:-----------------------
	if(samp_size < 0){
		_error("samp_size mispecified: sample size cannot be negative")
	}
	if(miss_l < 0 || miss_r > 1) {
		_error("miss_l or miss_r mispecified: proportion of missing data outside [0,1] range")
	}
	if(miss_l > miss_r){
		_error("miss_l and miss_r mispecified: miss_l cannot be larger than miss_r")
	}
	if(grid_num < 0) {
		_error("grid mispecified: number of grid points cannot be negative")
	}
	//if(built_in !=0 && built_in != 1){
	//	_error("built_in mispecified: must be 0 or 1")
	//}
	if(MC_iter < 0){
		_error("mc_iter mispecified: number of iterations cannot be negative")
	}
	if(rdgp_l < 0 || rdgp_l > 1 || rdgp_r < 0 || rdgp_r > 1){
		_error("rdgp_l mispecified: rdgp endpoints must be between 0 and 1")
	}
	if(mdgp_l < 0 || mdgp_l > 1 || mdgp_r < 0 || mdgp_r > 1){
		_error("mdpg_l mispecfied: mdgp endpoints must be between 0 and 1")
	}
	if(rdgp_l > rdgp_r || mdgp_l > mdgp_r){
		_error("rdgp or mdgp mispecifed: lower endpoints cannot be larger than upper endpoints")
	}
	if(h_distance < 0 || h_distance > 1){
		_error("h_distance mispecifed: Hellinger distance must be between 0 and 1")
	}
	if(rshape !=0 && rshape != 1 && rshape != 2){
		_error("rshape mispecfied: rshape must be 0, 1 or 2")
	}
	if(mshape !=0 && mshape != 1 && mshape != 2){
		_error("mshape mispecified: mshape must be 0, 1 or 2")
	}
	if(mon_select !=0 && mon_select!=1 && mon_select!=2){
		_error("mon_select mispecified: mon_select must be 0, 1 or 2")
	}
	//------------------End error check-----------------------------------
	
	//---------------Initialize parameters and setup grid-----------------
	//default grid_num:
	if(grid_num == 0 && dist == "bernoulli"){
		grid_num = 25
	}
	else if(grid_num == 0 && dist == "continuous"){
		grid_num = 5
	}

	
	//vector of missing parameter:
	miss_range = range(miss_l,miss_r,1/(grid_num-1))   
	miss_num = length(miss_range)
	
	//initialize vector of regrets:
	if(miss_range == 0 && dist == "bernoulli"){
		tot_count = grid_num + 1
	}
	else if(miss_range == 0){
		tot_count = grid_num^2 +1 
	}
	else if(dist == "bernoulli"){
		tot_count = miss_num*(grid_num^2) + 1
	}
	else{
		tot_count = miss_num*(grid_num^4) + 1
	} 
    risk_vector = J(tot_count,1,0)
    
    //these are used to keep track of the "argmax" of the risk_vector
    cr_mean = 0
    cm_mean = 0
    c_missing = 0
    //ftc is used to track how far along the computation is for the "Working..." graphic.
    //This does not work perfectly: was hoping to display exaclty ten "." for any configuration
    //but some configurations display a few more.
    ftc = floor(tot_count/10)
    //Initialize "Working..." graphic
    printf("Working")
    displayflush()
    
    //initialize grid of DGP parameters:
    if(dist == "bernoulli"){
    	//grid of bernoulli parameters for missing and realized data
		grid_miss = rangen(max((0.01,mdgp_l)), min((0.99,mdgp_r)), grid_num)
		grid_real = rangen(max((0.01,rdgp_l)), min((0.99,rdgp_r)), grid_num)
	}
	//grid of alpha/beta parameters when data is continuous
	else{
		if(mdgp_l == mdgp_r){ //This case is pathological: the user should probably never set the upper and lower bounds to be equal
			//I set up the grid to get finer and grow longer as 
			//grid_num increases
			grid_ma = rangen(0.01,sqrt(grid_num)+2,grid_num)
			//If the possible means of the missing data are a single point I use a special grid for the beta parameter:
			grid_mb = ((1-mdgp_r):*grid_ma):/mdgp_r
		}
		else{
			//I use the same grid for both alpha and
			//beta and check whether or not they fall within the interval later: 
			grid_ma = rangen(0.01,sqrt(grid_num)+2,grid_num)
			grid_mb = grid_ma
		}
		if(rdgp_l == rdgp_r){ //This case is pathological: the user should probably never set the upper and lower bounds to be equal
			//same as with mdgp, see above:
			grid_ra = rangen(0.01,sqrt(grid_num)+2,grid_num)
			grid_rb = ((1-rdgp_r):*grid_ra):/rdgp_r
		}
		else{
			//same as with mdgp, see above:
			grid_ra = rangen(0.01,sqrt(grid_num)+2,grid_num)
			grid_rb = grid_ra
		}
	}
        
    //Re-define MC iterations if built-in == 1:
    if(built_in==1 && MC_iter == 0){
    	MC_iter = 3000
    }
    else if (built_in==0 && MC_iter == 0){
    	MC_iter = 500
    }
	//-----------------End initialize----------------------------
	
	
	//---------------Iterating over DGPs:-----------------------
	count = 1
	for(m=1; m<=miss_num; m++) {
		missing = miss_range[m]
	//------------------Binary case:-----------------------------
		if(dist == "bernoulli"){
			for(i=1; i<=grid_num; i++) {
				prob_1 = grid_real[i]  //DGP of 'observed data'
				
				//running monte carlo to find mean and variance of estimator:
				MC_result = MC(func_name,samp_size,prob_1,missing,built_in,dist,MC_iter,true_beta)
				E_delta = MC_result[1]				  
				var_delta = MC_result[2]
			
				//calculating population mean and variance, calculating risk
				//if missing is equal to zero, need to iterate over only realized data DGP:
				if(missing == 0){
					E_y = prob_1
					var_y = E_y - E_y^2
					prev_max = max(risk_vector)
					
					risk_vector[count] = var_delta + (E_y - E_delta)^2
					
					//updating the "argmax" DGPs 
					if(max(risk_vector) > prev_max){
						cr_mean = prob_1
						cm_mean = 0
						c_missing = missing
					}
					
					if(miss_num == 1){
						//if miss_num == 1 and missing == 0 then there's no missing data,
						//so increment by 1
						count++
					}
					else{
						//if miss_num != 1 then count must skip some increments: this is because
						//there is no missing DGP to iterate over.
						count = count + grid_num 
					}
					//update "Working..." graphic
					if(mod(count,ftc) == 0){
						printf(".")
						displayflush()
					}
				}
				//if missing is not equal to zero, need to iterate over both realized and missing
				//data DGPs:
				else {
					for(j=1; j<=grid_num; j++) {
						prob_2 = grid_miss[j]
						
						if(h_dist_bernoulli(prob_1,prob_2) > h_distance){
							count++
							if(mod(count,ftc) == 0){
								printf(".")
								displayflush()
							}
							continue
						}
						if(mon_select!=0){
							if(prob_1 >= prob_2 && mon_select == 1){
								count++
								if(mod(count,ftc) == 0){
									printf(".")
									displayflush()
								}
								continue
							}
							else if(prob_1 <= prob_2 && mon_select == 2){
								count++
								if(mod(count,ftc) == 0){
									printf(".")
									displayflush()
								}
								continue
							}
						}
						E_y = prob_1*(1-missing) + prob_2*missing
						var_y = E_y - E_y^2	
						
						prev_max = max(risk_vector)
						
						risk_vector[count] = var_delta + (E_y - E_delta)^2
						
						if(max(risk_vector) > prev_max){
							cr_mean = prob_1
							cm_mean = prob_2
							c_missing = missing
						}
						
						count++
						if(mod(count,ftc) == 0){
							printf(".")
							displayflush()
						}
					}
				}
			}
			
		}
	//--------------------End Binary Case----------------------------


	//--------------------Continuous Case:---------------------------
		else if (dist == "continuous"){
			for(i=1; i<=grid_num; i++){
				for(j=1;j<=grid_num;j++){
					alpha_1 = grid_ra[i]
					beta_1 = grid_rb[j]
					if(rdgp_l != rdgp_r){ 
						//do an extra check if the mean is within the specified interval
						if(mean_beta(alpha_1,beta_1) < rdgp_l || /*
						*/mean_beta(alpha_1,beta_1) > rdgp_r){
							count = count + grid_num^2
							if(mod(count,ftc) == 0){
								printf(".")
								displayflush()
							}
							continue
						}
					}
					if(rshape != 0){
						//checking if the shape of the beta distribution conforms to the specification
						if((rshape == 1 && (alpha_1 < 1 || beta_1 < 1)) || /*
						*/(rshape == 2 && (alpha_1 >= 1 && beta_1 >= 1))){
							count = count + grid_num^2
							if(mod(count,ftc) == 0){
								printf(".")
								displayflush()
							}
							continue
						}
					}
					params = (alpha_1,beta_1)
					
					//running monte carlo to find mean and variance of estimator:
					MC_result = MC(func_name,samp_size,params,missing,built_in,dist,MC_iter,true_beta)
					E_delta = MC_result[1]				  
					var_delta = MC_result[2]
					
					if(missing == 0){
						E_y = mean_beta(alpha_1,beta_1)
						//var_y = var_beta(alpha_1,beta_1)
						
						prev_max = max(risk_vector)
						
						risk_vector[count] = var_delta + (E_y - E_delta)^2
						
						if(max(risk_vector) > prev_max){
							cr_mean = mean_beta(alpha_1,beta_1)
							cm_mean = 0
							c_missing = missing
						}
						
						if(miss_num == 1){
						count++
						}
						else{
							count = count + grid_num^2 
						}
						//update "Working..." graphic
						if(mod(count,ftc) == 0){
							printf(".")
							displayflush()
						}
					}
								
					else {
						for(k=1; k<=grid_num; k++) {
							for(l=1;l<=grid_num;l++) {
								alpha_2 = grid_ma[k]
								beta_2 = grid_mb[l]
								if(mdgp_l != mdgp_r){ //do an extra check if the mean is within the specified interval
									if(mean_beta(alpha_2,beta_2) < mdgp_l || /*
									*/mean_beta(alpha_2,beta_2) > mdgp_r){
										count++
										if(mod(count,ftc) == 0){
											printf(".")
											displayflush()
										}
										continue
									}
								}
								
								//checking if the shape of the beta distribution conforms to the specification
								if(mshape != 0){ 
									if((mshape == 1 && (alpha_2 < 1 || beta_2 < 1)) || /*
									*/(mshape == 2 && (alpha_2 >= 1 && beta_2 >= 1))){
										count++
										if(mod(count,ftc) == 0){
											printf(".")
											displayflush()
										}
										continue
									}
								}
								if(h_distance < 1){
									if(h_dist_beta(alpha_1,beta_1,alpha_2,beta_2) > h_distance + 0.0001){
										count++
										if(mod(count,ftc) == 0){
											printf(".")
											displayflush()
										}
										continue
									}
								}
								
								if(mon_select!=0){
									if(mean_beta(alpha_1,beta_1) >= mean_beta(alpha_2,beta_2) && mon_select == 1){
										count++
										if(mod(count,ftc) == 0){
											printf(".")
											displayflush()
										}
										continue
									}
									else if(mean_beta(alpha_1,beta_1) <= mean_beta(alpha_2,beta_2) && mon_select == 2){
										count++
										if(mod(count,ftc) == 0){
											printf(".")
											displayflush()
										}
										continue
									}
								}
								
								//some intermediate computations---
								there_E_y = mean_beta(alpha_1,beta_1)
								miss_E_y = mean_beta(alpha_2,beta_2)
								there_var_y = var_beta(alpha_1,beta_1)
								miss_var_y = var_beta(alpha_2,beta_2)
								there_Esq_y = there_var_y + there_E_y^2
								miss_Esq_y = miss_var_y + miss_E_y^2
								E_sq_y = there_Esq_y*(1-missing) + miss_Esq_y*(missing)
								//-----------------------------------
								
								E_y = there_E_y*(1-missing) + miss_E_y*missing
								var_y = E_sq_y - E_y^2
									
								prev_max = max(risk_vector)
								
								risk_vector[count] = var_delta + (E_y - E_delta)^2
								if(max(risk_vector) > prev_max){
									cr_mean = mean_beta(alpha_1,beta_1)
									cm_mean = mean_beta(alpha_2,beta_2)
									c_missing = missing
								}
								
								count++
								if(mod(count,ftc) == 0){
									printf(".")
									displayflush()
								}
							}
						}
					}	
					
				}
			}
		}
		
		else{
		//dist can only be binary or continuous
			_error("dist mispecified: dist must be bernoulli or continuous")
		}
	}
	//-------------------End Continuous Case-------------------------------


	//-----------------End of iterating over DGPs--------------------------
	
	result = max(risk_vector)  //finding maximum regret
	
	if(result==0){ 
		//return an error if wald_mse returns zero, this should only happen if the grid 
		//is so coarse that you "skip" all distributions
		_error("wald_mse returned zero: grid may too coarse, try increasing grid size")
	}

	printf("\nMaximum MSE: %f", result)
	st_numscalar(r_mse,result)
	st_numscalar(r_mean,cr_mean)
	st_numscalar(m_mean,cm_mean)
	st_numscalar(miss_val,c_missing)
	
	
}

//Code to run the Monte Carlo to find the mean and variance of the estimator in 
//repeated samples:
matrix MC(string scalar func_name,real scalar samp_size,p,real scalar missing, 
real scalar built_in,string scalar dist,real scalar MC_iter, real scalar true_beta){
	MC_num = MC_iter
	sim_vector = J(1,MC_num,0) 
	
	//rbinomial doesn't like true zeros and ones so I move a bit inside the
	//interval:
	if(missing == 0){
		missingf = 1*10^(-8)
	}
	else if(missing == 1){
		missingf = 1-(1*10^(-8))
	}
	else {
		missingf = missing
	}
	
	//This piece of the function runs if the command is user-defined. It must put the 
	//generated data back into stata every iteration of the Monte Carlo which slows down the
	//computations.
	if(built_in == 0){
	                     
		for(i=1; i<=MC_num; i++){

		
			//finding number of responses:
			realized_miss = rbinomial(samp_size,1,1,missingf)
			number_missing = sum(realized_miss)
		
			//generating data and estimating mean:
			//initialize fake data:
			stata("capture drop data")
			string_ss = strofreal(samp_size)
			stata("quietly set obs" + " " + string_ss) 
			stata("gen data = 0")
			
			//generate fake data and put into stata:
			if(dist=="bernoulli"){
				new_data = rbinomial(samp_size,1,1,p)
			}
			else{
				p1 = p[1]
				p2 = p[2]
				if(p1 < 0.05 || p2 < 0.15){
				//approximating beta with small paramaters by a binomial:
				//I need to do this because MATA's beta RNG doesn't support
				//small paramter values. I have also created my own random
				//beta generator called gen_mat_beta, but it runs very slowly.
				//It gets used if true_beta is set to one.
					if(true_beta == 0){
						new_data = rbinomial(samp_size,1,1,p1/(p1+p2))
					}
					else if(true_beta == 1){
						new_data = gen_mat_beta(samp_size,MC_num,p1,p2)
					}
					else{
						_error("true_beta must be between 0 and 1")
					}
				}
				else {
					new_data = rbeta(samp_size,1,p1,p2)
				}
			}
			
			if(number_missing != 0){
				new_data[1::number_missing] = J(number_missing,1,.)
			}
			st_store(.,("data"),new_data)             
	
			//evaluate estimator on data:
			stata("quietly" + " " + func_name + " " + "data") 
			sim_vector[i] = st_matrix("e(b)")
		}
	}
	
	else{
		realized_miss = rbinomial(samp_size,MC_num,1,1-missingf)
		//initialize fake data:
		if(dist=="bernoulli"){
			new_data = rbinomial(samp_size,MC_num,1,p)
		}
		else{
			p1 = p[1]
			p2 = p[2]
			if(p1 < 0.05 || p2 < 0.15){
			//approximating beta with small parameters by a binomial:
			//see above.
				if(true_beta == 0){
					new_data = rbinomial(samp_size,MC_num,1,p1/(p1+p2))
				}
				else if(true_beta == 1){
					new_data = gen_mat_beta(samp_size,MC_num,p1,p2)
				}
				else{
					_error("true_beta must be 0 or 1")
				}
			}
			else {
				new_data = rbeta(samp_size,MC_num,p1,p2)
			}
		}
		
		//trick to add missing data into the data set.
		//division by zero results in a missing data entry.
		new_data = new_data:/realized_miss	
		
		//Run one of the built-in functions:---------------------------
		if(func_name == "mean") {
			sim_vector = vec_my_mean(new_data)
		}
		else if(func_name == "midmean") {
			sim_vector = vec_mid_mean(new_data)
		}
		else if(func_name == "MMRzero") {
			sim_vector = vec_HL_mean(new_data)
		}
		else {
			printf("\n")
			_error("Not a valid built-in estimator: specify user_def if command is user defined")
		}
		//--------------------------------------------------------------
	}		
  
	//return mean and variance:
	if(built_in == 0){
		stata("capture drop data")
	}
	return(mean(sim_vector'),variance(sim_vector'))	            
}


//-----------------------------Utility Functions-----------------------------

//mean of a beta distribution
scalar mean_beta(real scalar alpha, real scalar beta){
	x = (alpha)/(alpha+beta)
	return(x)
}

//variance of a beta distribution
scalar var_beta(alpha,beta){
	x = (alpha*beta)/((alpha+beta)^2*(alpha+beta+1))
	return (x)
}

//pdf of a beta distribution
scalar beta_f(a,b){
	return ((gamma(a)*gamma(b))/gamma(a+b))
}

//hellinger distance between two betas
scalar h_dist_beta(alpha1,beta1,alpha2,beta2){
	return (sqrt(1 - beta_f((alpha1+alpha2)/2,(beta1+beta2)/2)/(beta_f(alpha1,beta1)*beta_f(alpha2,beta2))^(0.5)))
}

//hellinger distance between two bernoullis
scalar h_dist_bernoulli(p1,p2){
	q1 = 1 - p1
	q2 = 1 - p2
	return ((1/sqrt(2))*sqrt((sqrt(p1) - sqrt(p2))^2 + (sqrt(q1) - sqrt(q2))^2))
}

//generate one beta random variable
scalar gen_beta(a,b){
	s_1 = 10
	s_2 = 10
	while(s_1 + s_2 > 1){
		u_1 = runiform(1,1)
		u_2 = runiform(1,1)
		s_1 = u_1^(1/a)
		s_2 = u_2^(1/b)
	}
	y = s_1/(s_1+s_2)
	return(y)
}

//generate a matrix of beta random variables
matrix gen_mat_beta(n,MC_num,a,b){
	result = J(n,MC_num,0)
	for(i=1; i<=n; i++){
		for(j=1; j<=MC_num; j++){
			result[i,j] = gen_beta(a,b)
		}
	}
	return(result)
}
//-----------------------------------------------------------------------------


//-----------------------------Built-in estimators-----------------------------
//This is a version of the mean that returns 0.5 if there is no realized data
matrix vec_my_mean(data){
	remain_data = data :!= .
	num_remain_data = colsum(remain_data)
	m = colsum(data):/num_remain_data
	_editmissing(m,0.5)
	return(m)
}

//This is the midmean estimator
matrix vec_mid_mean(data){
	remain_data = data :!=  .
	num_remain_data = colsum(remain_data)
	num_total_data = J(1,cols(data),rows(data))
	prop_remain = num_remain_data:/num_total_data
	m = colsum(data):/num_remain_data
	_editmissing(m,0.5)
	result = m:*prop_remain :+ J(1,cols(data),0.5):*(J(1,cols(data),1):-prop_remain)
	return(result)
}

//This is the MMRzero Hodges and Lehmann estimator.
matrix vec_HL_mean(data){
	remain_data = data :!= .
	num_remain_data = colsum(remain_data)
	samp_mean = colsum(data):/num_remain_data
	m = (samp_mean:*sqrt(num_remain_data):+J(1,cols(data),0.5)):/(sqrt(num_remain_data):+ J(1,cols(data),1))
	_editmissing(m,0.5)
	return(m)
}
//-----------------------------------------------------------------------------


end


