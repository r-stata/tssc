**1st version: July 4th 2021

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// Program : mfelogit
///// This function implements the estimators of the bounds on the AME/ATE proposed in DDL.
///// The output of this program prints the table containing the estimation results.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

quietly capture program drop mfelogit
program define mfelogit, eclass
	version 15.0
		
syntax varlist [if] [in], id(string) time(string) [listT(string) method(string) cluster(string) level(string) eps(string) listX(string) ratio(string)]

gettoken depvar indepvar: varlist

/******************************************************/
	/* Selection of observations [if] [in] options (begin) */
	preserve
	marksample touse, novarlist 
	/* novarlist option: no automatic drop of missing values, cf. checks in 
	ado-files db_from_* */
	quietly: keep if `touse'
	/* Selecton of observations [if] [in] options (end) */
/****************************************************/


quietly xtset  `id' `time' 
local dimX = `:word count `indepvar''

mata: listY = tokens("`depvar'")
mata: listX0 = tokens("`indepvar'")
mata: dimX =  cols(listX0)

mata: valid = J(1,dimX,1)
scalar count = 1
scalar n_vardiscard = 0

foreach val of varlist `indepvar' {
	quietly xtsum `val'
	if (`=r(sd_w)' <= 0.005) {
	   mata: valid[1,st_numscalar("count")] = 0
	   local vardiscard `vardiscard'  "`val'"
	   scalar n_vardiscard =  n_vardiscard +1
	}
	scalar count = count + 1 
}


quietly levelsof `time', local("tall0")
mata: tall0 =  tokens(st_local("tall0"))

local numitems = wordcount("`tall0'")

tsfill
keep  `id' `time' `varlist' `cluster'
quietly reshape wide `varlist' `cluster', i(`id') j(`time')

mata: Option = J(1,1,"quick")
capture confirm variable `method'
if _rc!=7 { 
	 mata: Option = tokens("`method'") 
} 

capture confirm string variable `level'
if _rc!=7 { 
	 mata: alpha0 = tokens("`level'") 
} 

else {
	
    mata: alpha0 = J(1,1,"0.05")
}

	
capture confirm string variable `ratio'
if _rc!=7 { 
	 mata: ratio = tokens("`ratio'") 
} 

else {
    mata: ratio = J(1,1,"10")
}

mata: eps = J(1,1,"")
capture confirm variable `eps'
if _rc!=7 { 
	
	 mata: eps = tokens("`eps") 
} 

mata: cluster = J(1,1,"") 
capture confirm variable `cluster'
if _rc!=7{ 
	 mata: cluster = tokens("`cluster'") 
} 

mata: computeX = J(1,1,"") 
capture confirm variable `listX'
if _rc!=7 { 
	 mata: computeX = tokens("`listX'") 
} 

mata: computeT = J(1,1,"") 
capture confirm variable `listT'
if _rc!=7 {
	mata: computeT = tokens("`listT'")
} 

mata : out = mata_mfelogit(listY, listX0, tall0, Option, alpha0, eps,cluster, computeT, computeX, ratio, valid)



tempname mat_results mat_results_CMLE
matrix mat_results = r(mat_results)
matrix mat_results_CMLE = r(mat_results_CMLE)

local mat_results_rows
forvalues j = 1/`=r(rows_results)'{
    local mat_results_rows `mat_results_rows' `r(res`j')'
}

matrix rownames mat_results = `mat_results_rows'


local lowerCI =  "[`r(alpha0)'" + "% Conf."
local upperCI =  "Interval]"
if(`=r(Optionval)'){
	if(`=r(OptionTinf)'){
		matrix colnames mat_results =  "Estimate" "`lowerCI'" "`upperCI'"
	}
	
	else{
		matrix colnames mat_results = "Period"  "Estimate" "`lowerCI'" "`upperCI'"
	}
} 

else {
	
	if(`=r(OptionTinf)'){
		matrix colnames mat_results = "[Bounds "  "estimates]" "`lowerCI'" "`upperCI'"
	}
	
	else {
		matrix colnames mat_results = "Period" "[Bounds "  "estimates]" "`lowerCI'" "`upperCI'"
		
	}
}



local mat_results_CMLE_rows = ""
forvalues j = 1/`=r(rows_results_CMLE)'{
    local mat_results_CMLE_rows `mat_results_CMLE_rows' `r(CMLE`j')'
}
matrix rownames mat_results_CMLE = `mat_results_CMLE_rows'
matrix colnames mat_results_CMLE =  "Point Est." "Std. Err." "p-value"

ereturn scalar ndiscard = `=r(ndiscard)'
ereturn scalar n = `=r(n)'
ereturn scalar maxT =  `=r(maxT)'

local discard_obs =  "Nb of discarded individuals: " +  "`r(ndiscard)'"
local obs =  "Nb of observed individuals: " + "`r(n)'"
local maxT =  "Maximal number of observed periods: " + "`r(maxT)'"
local Option_c =  "The method used to compute AME/ATE is the quick method (i.e. the second method in DDL)." 
if(!`=r(Optionval)'){ 
     local  Option_c =  "The method used to compute AME/ATE is the sharp method (i.e. the first method in DDL)."
}


local Footnote_1 = " "

if(n_vardiscard==1){
      local Footnote_1 = "The variable " + "`vardiscard'" + " has been discarded because it is likely to be constant over time."
}
if(n_vardiscard>1){
      local Footnote_1 = "The variables " + "`vardiscard'" +" have been discarded because they are likely to be constant over time."
}
  
display "`Footnote_1'"
estout matrix(mat_results_CMLE), mlabels("") prehead("Estimates of coefficients in the fixed effect logit model (CMLE)") 
estout matrix(mat_results), mlabels("")  prehead("Estimates of the Average Marginal Effects in the fixed effect logit model") postfoot(Notes:  {break} `obs' {break} `discard_obs'  {break} `maxT' {break} `Option_c')

/******************/
/* Output (begin) */
ereturn matrix  mat_results = mat_results 
ereturn matrix  mat_results_CMLE = mat_results_CMLE

ereturn local vardiscard = "`vardiscard'"
ereturn local obs = "`obs'"
ereturn local discard_obs= "`discard_obs'"


ereturn local cmd_arguments "`0'"
ereturn local cmd "mfelogit"
/* Output (end) */
/****************/
end


**1st version: July 4th 2021

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// myeval4: for the computation of the loglikelihood. 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

cap mata mata drop myeval4()
mata:
void myeval4(todo, beta, Y,X, v, g, H){
	v= log_lik_FE_logit(beta, Y,X)
}
end 


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// myeval_lin: for the computation of the linear estimator of beta, which serves as a starting point for the loglikelihood.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

cap mata mata drop myeval_lin()
mata:
void myeval_lin(todo, beta, Y,X, v, g, H){
	v= reg_lin(beta, Y,X)
}
end 

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// trunc_m: This function truncates m_hat until it belongs to the moment space. The
///// truncated moment is put in m_trun.
///// Sigma is an estimator of the "variance" of m_hat, or more accurately, of
///// the asymptotic variance of m_hat, properly normalized.
/////param m_hat the estimated sequence of moments
/////param Sigma is an estimator of the "variance" of m_hat, or more accurately, of the asymptotic variance of m_hat, properly normalized.
/////param n the sample size
/////param ind_Sig_pos indicates if Sigma is invertible
/////
/////return A list containing:
/////
///// m_trun: the truncated value of m_hat, which belongs to the moment space;
/////
///// indic=0 if m_hat was not truncated. Otherwise, indic=1 if we are above the upper bound, indic=-1 if we are  below the lower bound.
/////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

cap mata mata drop trunc_m()
mata: 
pointer matrix function trunc_m (real matrix m_hat, | real matrix  Sigma , real scalar n0 , real scalar ind_Sig_pos){

  T=rows(m_hat);
  
  if( n0!=NULL){
    ct = sqrt(2*log(log(n0)));
  }
  
  k=0
  indic = 0
  m0 = (1,m_hat')'
  
  
  if( ind_Sig_pos==NULL){
	  if( Sigma==NULL && n0==NULL){
		Sigma = 0;
		ind_Sig_pos = 0
	  }else{
		ind_Sig_pos = det(Sigma)>0
	  }
  }else{
      ind_Sig_pos = 0
  }
  
  while( (indic == 0) && (k < T)){
    k=k+1;  
    ell = round(k/2);
    if( mod(k,2)==1){
      Bkp1 = hankel(m_hat[1..ell],m_hat[ell..k])
      Akp1 = hankel(m0[1..ell],m0[ell..k])
      Hinf = det(Bkp1)
      Hsup = det(Akp1 :- Bkp1)
  
     if( Sigma!=NULL && n0!=NULL && ind_Sig_pos){
        /*# % We apply the Jacobi formula to estimate the variance of Hinf and
        # % Hsup*/
        L = rows(Bkp1)
        Jac_inf = J(1,T,0)
        Adj_inf = adjoint1(Bkp1)
        for(i=1;i<=T;i++){
          bx = (range(1,L,1))*J(1,L,1) + J(L,1,1)*range(1,L,1)'
          Jac_inf[i] = sum(diag(Adj_inf :* (bx :==(i+1))))
        }
        s_inf = sqrt(Jac_inf* Sigma* Jac_inf');
        Jac_sup =J(1,T,0);
        Adj_sup = adjoint1(Akp1 :- Bkp1)
        for (i=1;i<=T;i++){
             bx = (range(1,L,1))*J(1,L,1) + J(L,1,1)*range(1,L,1)'
            Jac_sup[1,i] = sum(diag(Adj_sup :* ((bx :==(i+2)) :- (bx :==(i+1) )))); 
        }
        s_sup = sqrt(Jac_sup* Sigma * (Jac_sup'));
        if( min((Hinf/s_inf,Hsup/s_sup))<=ct){
                indic = 2*(Hinf/s_inf>Hsup/s_sup) - 1;
         }
        }else{
            if(min((Hinf,Hsup))<=1e-10){
                indic = 2*(Hinf>Hsup) - 1
			}
        }
      }else{
        Akp1 = hankel(m0[1..(ell+1)],m0[(ell+1)..(k+1)]);
        Bk = hankel(m_hat[1..ell],m_hat[ell..(k-1)]);
        Ck = hankel(m_hat[2..(ell+1)],m_hat[(ell+1)..k])
        Hinf = det(Akp1);
        Hsup = det(Bk :- Ck);
      
      if( Sigma!=NULL && n0!=NULL && ind_Sig_pos){
            L = rows(Akp1);
            Jac_inf = J(1,T,0);
            Adj_inf = adjoint1(Akp1);
            for( i=1; i<=T;i++){
                bx = (range(1,L,1))*J(1,L,1) + J(L,1,1)*range(1,L,1)'
                Jac_inf[i] = sum(diag((Adj_inf :* (bx :==(i+2)))));
            }                 
            s_inf = sqrt(Jac_inf * Sigma * (Jac_inf'));
            Jac_sup = J(1,T,0);
            Adj_sup = adjoint1(Bk :- Ck);
            for(i=1;i<=T;i++){
              bx = range(1,L-1,1)*J(1,L-1,1) + J(L-1,1,1)*range(1,L-1,1)'
				Jac_sup[1,i] = sum(diag(Adj_sup :* ((bx :==(i+1)) :- (bx :==(i) )))); 
             }
			 	 
            s_sup = sqrt(Jac_sup * Sigma * (Jac_sup'));
            if( min((Hinf/s_inf,Hsup/s_sup))<=ct ){
                indic = 2*(Hinf/s_inf>Hsup/s_sup) - 1;
            }		
			
      }else if( min((Hinf,Hsup))<=1e-10){
                indic = 2*(Hinf>Hsup) - 1;
      }
    }
  }
  
  if( k==1){
     /* # % In this very peculiar case, the distribution is either the Dirac at 0
      #% or 1*/
      m_trun = (norm(m_hat:-1, 1) < norm(m_hat, 1));
  }else if(indic!=0){
      m_trun = m_hat[1..(k-1)];
  }else{
     m_trun = m_hat;
  }

 
out= J(2,1,NULL)
out[1] = &m_trun
out[2] = &indic

if(out[1,1]==NULL){
    out = trunc_m(m_hat, NULL, NULL, ind_Sig_pos = 0)
 }

return(out)                                                
}
end 






////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// bound_mom: Bound on the T0+1-th moment given the vector of first moments m.
///// param m the vector m until m_{T0}
///// param T0 the lenght of the vector of moments m
///// param indic We may have length(m)<T0 if m is at the boundary. In this case, this 3rd
///// argument (indic) is required, with indic=1 if the next element of m is =
///// to the upper bound, indic=-1 if it is = to the lower bound
///// 
///// return return the bounds on the T0+1-th moment
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


cap mata mata drop bound_mom()
mata:
real matrix function bound_mom(real matrix m,real scalar T, real scalar indic){
  
  res=J(2,1,0);
  
  if (cols(m)<T){
 /* # % Boundary case: qinf=qsup
  # % We complete the vector m until m_{T+1}*/
    T1 = cols(m);
    if (indic==-1){
  /*  # % We are at the lower bound*/
      if (mod(T1,2)==0){
       /* # % Even case*/
        for (t=T1;t<=T;t++){
          m0=m[(t-T1+1)..(t-T1/2+1)]
          m1=m[(t-T1/2+1)..cols(m)];
          m10=(m1,0);
          y1=det(hankel(m0',m10'))
          m11=(m1,1);
          y2=det(hankel(m0',m11'));
		  if(t+1<=cols(m)){
			m[t+1] = y1/(y1-y2);
		}else{
			m = (m  ,y1/(y1-y2))
		}
        }
      }else{
       /*# % Odd case*/
        for (t= T1;t<=T;t++){
          if( t==T1){
            m0=(1,m[1..((T1+1)/2)])
          }else{
            m0 = m[(t-T1)..(t-(T1-1)/2)]
          }
        m1=m[(t-(T1-1)/2)..cols(m)];
        m10=(m1,0);
        y1=det(hankel(m0',m10'));
        m11=(m1,1);
        y2=det(hankel(m0',m11'));
		if(t+1<=cols(m)){
			m[t+1] = y1/(y1-y2);
		}else{
			m = (m  ,y1/(y1-y2))
		}
      }
    }
  }else{
     /* # % We are at the upper bound*/
      if (mod(T1,2)==0){
     /*  # % Even case*/
      for (t=T1;t<=T;t++){
        if (t==T1){
          m0=(1,m[1..T1/2]) - m[1..(T1/2+1)]
        }else{
          m0=m[(t-T1)..(t-T1/2)] - m[(t-T1+1)..(t-T1/2+1)]; 
        }
        m1=m[(t-T1/2)..(cols(m)-1)] - m[(t-T1/2+1)..cols(m)];
        m10 = (m1,m[cols(m)]);
        y1=det(hankel(m0',m10'));
        m11=(m1,m[cols(m)]-1);
        y2=det(hankel(m0',m11'));
		if(t+1<=cols(m)){
			m[t+1] = y1/(y1-y2);
		}else{
			m = (m  ,y1/(y1-y2))
		}
      }
    }else{
     /* # % Odd case*/
	if(T1==1){
            /*#% Bernoulli case*/
            m=J(T+1,1,m[1])
         }else{
			for (t= T1;t<=T;t++){
			  m0=m[(t-T1+1)..(t-(T1-1)/2)] - m[(t-T1+2)..(t-(T1-3)/2)];
			  m1=m[(t-(T1-1)/2)..(cols(m)-1)] - m[(t-(T1-3)/2)..cols(m)];
			  m10 =(m1,m[cols(m)]);
			  y1=det(hankel(m0',m10'));
			  m11=(m1,m[cols(m)]-1);
			  y2=det(hankel(m0',m11'));
	 
			  if(t+1<=cols(m)){
				m[t+1] = y1/(y1-y2);
				}else{
				m = (m  ,y1/(y1-y2))
			  }
			}
		  }
		}
	}
  res[1]=m[cols(m)];
  res[2]=m[cols(m)];
}else{
     /* # % Interior case: qinf < qsup*/
    if(cols(m)>T){
      m=m[1..T]
    }
  
    /*  # % T even*/
    if (mod(T,2)==0){
      /*  # % Lower bound*/
      m0=m[1..(T/2+1)]
      m1=m[(T/2+1)..cols(m)]
      m10=(m1,0)
      y1=det(hankel(m0',m10'))
      m11=(m1,1)
      y2=det(hankel(m0',m11'))
      res[1] = y1/(y1-y2)
      
      m0=(1,m[1..(T/2)]) - m0;
      m1=m[(T/2)..(cols(m)-1)] - m[(T/2+1)..cols(m)];
      m10 = (m1,m[cols(m)]);
      y1=det(hankel(m0',m10'));
      m11=(m1,m[cols(m)]-1);
      y2=det(hankel(m0',m11'));
      res[2] = y1/(y1-y2);
    }else{
       /* # % T odd*/
      m0=(1,m[1..((T+1)/2)])
      m1=m[((T+1)/2)..cols(m)]
      m10=(m1,0)
      y1=det(hankel(m0',m10'))
      m11=(m1,1)
      y2=det(hankel(m0',m11'));
      res[1]= y1/(y1-y2)
      
      m0=m[1..((T+1)/2)]- m[2..((T+3)/2)]
      m1=m[((T+1)/2)..(cols(m)-1)] - m[((T+3)/2)..cols(m)];
      m10=(m1,m[cols(m)]);
      y1=det(hankel(m0',m10'));
      m11=(m1,m[cols(m)]-1);
      y2=det(hankel(m0',m11'));
      res[2] = y1/(y1-y2);
    }
  }
  
  
  
  if(sum(res:==.)>0){
    if(m[1]==0){
      res=J(2,1,0)
    }else{
      res=bound_mom(m[1],T,1);
    }
  }
  
  return(res)
}
end 




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// infl_func_beta : Compute the influence function of beta hat: E(d^2ln L/dbeta^2)^{-1}  x (ln L/dbeta)(Yi|Xi,beta).
/////param beta the parameter at which the influence function is computed
/////param Y a matrix of size nxT containing the values of the dependent variable Y
/////param X an array of size nxTxdimX containing the values of the covariates X
/////param Call a vector of size n containing the indexes of the hypothetical clusters for the individuals
/////
/////return a vector of size nx1 containing the value of the influence function
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

cap mata mata drop infl_func_beta()
/* We compute the influence function of beta hat: E[d^2ln L/dbeta^2]^{-1}  x (ln L/dbeta)(Yi|Xi,beta). 
*/
mata: 
real matrix function infl_func_beta(real matrix beta,real matrix Y,pointer matrix X, real matrix Call){
  
  /*## modif pour dim (X) de taille > 1. */
	T = rows(X) 
	XT_u = (*(X[T,1]))
	n = rows(XT_u) 
	k = cols(XT_u)
	S = rowsum(Y)
  

    /*##   grid_T   */
 	Tall =  J(rows(Y),1,.)
	for(i=1;i<=rows(Y);i++){
		Tall[i,1] = isnot(Y[i,])
	} 
  
   /*## Max of the Tinf in dataset*/
	Tmax = max(Tall)

  /*### find the distibution of Tinf in the population and sample size*/
	  count1 = 0
	  for(t=1;t<=Tmax;t++){
		if(sum(Tall:==t)>0){
			count1 = count1 +1
		}
	  }
	 
	  grid_T = J(1,count1,.)
	  n_dist = J(1,count1,.)
	  count10 = 0
	  for(t=1;t<=Tmax;t++){
		if(sum(Tall:==t)>0){
		  count10 =count10 +1
		  grid_T[1,count10] = t
		  n_dist[1,count10] = sum(Tall:==t)
		}
	  }

 
   V =J(n,Tmax,0);
   index =J(n,Tmax,0);
   for(ti0=1;ti0<= length(grid_T);ti0++){
	  ti = grid_T[ti0]
	  indexes = selectindex(Tall:==ti)
	  for( t=1;t<=ti; t++){
	  	sub = *(X[t,1])
		index[indexes,t] = (sub[indexes ,]*beta')
	  }
	}
    V = exp(index)
	score = J(k,n,0);
  
	
	denom = J(n,1,.)
	for(ti0=1;ti0<= length(grid_T);ti0++){
	  ti = grid_T[ti0]
	  indexes = selectindex(Tall:==ti)
	  denom[indexes ,1] = C_S_fun(S[indexes,1],V[indexes,1..ti]);
	}


	J_denom =J(n,Tmax,.)
	/*hess_denom = array(.,c(n,Tmax,Tmax));
	XX = array(.,c(n,Tmax,Tmax));*/
	

  if(Call[1,1]==.){

	  for(ti0=1;ti0<= length(grid_T);ti0++){
		ti = grid_T[ti0]
		if(ti==1){
		  t= 1
		  indexes = selectindex(Tall:==ti)
		  J_denom[indexes,t] = V[indexes,t]/denom[indexes,1];
		}else{
			for(t=1;t<=ti;t++){
			  indexes = selectindex(Tall:==ti)
			  V0 = V[indexes,1..ti]
			  J_denom[indexes,t] = V[indexes,t]:*C_S_fun(S[indexes]:-1, V0[,selectindex((1..ti):!=t)]):/denom[indexes];
			}
		}
	  }

 
	/*# % Computation of (ln L/dbeta)(Yi|Xi,beta).*/
    for(j=1; j<=k;j++){
		Xtemp = J(n,T,0)
		for(t=1;t<=T;t++){
			Xtemp[,t] = (*(X[t,1]))[,j]
		}
	  score[j,] = rowsum(Xtemp:*(Y :- J_denom))';
      /*score[j,] = t(apply(X[,,j]*(Y - J_denom),1,sum));*/
    }

	
	info_Fish = variance(score')
  
  
	}else{

		nb_clust =length(uniqrows(Call))
		civals = uniqrows(Call)
		info_Fish = 0
		for(ci=1;ci<=nb_clust;ci++){
			
			cival = civals[ci]
			for(ti0=1;ti0<= length(grid_T);ti0++){
			ti = grid_T[ti0]
			if(ti==1){
			  t= 1
			  indexes = selectindex(Tall:==ti :& Call:==cival)
			  J_denom[indexes,t] = V[indexes,t]:/denom[indexes,1];
			}else{
				for(t=1;t<=ti;t++){
				  indexes2 = selectindex(Tall:==ti :& Call:==cival)
				  indexes = selectindex(Tall:==ti)
				  V0 = V[indexes2,1..ti]
				  J_denom[indexes2,t] = V[indexes2,t]:*C_S_fun(S[indexes2]:-1, V0[,selectindex((1..ti):!=t)]):/denom[indexes2];
				}
			}
		  }
		
	
		/*# % Computation of (ln L/dbeta)(Yi|Xi,beta).*/
		for(j=1; j<=k;j++){
			Xtemp = J(sum(Call :==cival),T,0)
			indexes = selectindex(Call :==cival)
			for(t=1;t<=T;t++){
				Xtemp[,t] = (*(X[t,1]))[indexes,j]
			}
			score[j,indexes] = rowsum(Xtemp:*(Y[indexes ,] :- J_denom[indexes ,]))';
		/*score[j,] = t(apply(X[,,j]*(Y - J_denom),1,sum));*/
		}
			
		info_Fish = info_Fish :+ variance(score');


		}
  }
  
   
  res = cholsolve(info_Fish, score, 10^(-7))'
  return(res)
}
end 


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// reg_lin :  Evaluate the mean square error loss function of linear regression by pooling, to obtain a starting value for the conditional maximum likelihood estimator.
/////
/////param beta the value at which the loss is computed
/////param Y a matrix of size nxT containing the values of the dependent variable Y
/////param X an array of size nxTxdimX containing the values of the covariates Xs
/////
/////return the value of the mean square error loss function of linear regression at beta
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

cap mata mata drop reg_lin() 
mata: 
real scalar function reg_lin(beta,Y, X){

  /*# [n, T, k]=size(X);
  ## change for dim(X) >1*/
  T = rows(X) 
  XT_u = (*(X[T,1]))
  n = rows(XT_u) 
  k = cols(XT_u)
  index=J(n,T,0) 
	
  	for( j=1;j<=k;j++){
		Xtemp = J(n,T,0)
		for(t=1;t<=T;t++){
			Xtemp[,t] = (*(X[t,1]))[,j]
		}
		index = index :+ Xtemp:*beta[1,j]
  	}
	
  /*# % Careful, we actually take - the log, as we minimize the function at the
  # % end.*/
  f = - sum(rowsum(Y :- index):^2)

  return(f)
}
end 


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// log_lik_FE_logit: Evaluate the conditional loglikelihood function of the panel data logit at beta
/////
///// If Y or X contain NA for some individuals at periods, these individuals-periods only are discarded.
/////param beta the value at which the loss is computed
/////param Y a matrix of size nxT containing the values of the dependent variable Y
/////param X an array of size nxTxdimX containing the values of the covariates Xs
/////
/////return the value of the conditional loglikelihood function at beta
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


cap mata mata drop log_lik_FE_logit()
mata: 
real scalar function log_lik_FE_logit(real matrix beta,real matrix Y, pointer matrix X){
	
	T = rows(X) 
	XT_u = (*(X[T,1]))
	n = rows(XT_u) 
    k = cols(XT_u)
	
	
	index=J(n,T,0) 
	
  	for( j=1;j<=k;j++){
		Xtemp = J(n,T,0)
		for(t=1;t<=T;t++){
			Xtemp[,t] = (*(X[t,1]))[,j]
		}
		index = index :+ Xtemp:*beta[1,j]
  	}
	
	Tall =  J(rows(Y),1,.)
   for(i=1;i<=rows(Y);i++){
	Tall[i,1] = isnot(Y[i,])
   } 
  
   /*## Max of the Tinf in dataset*/
   Tmax = max(Tall)

  /*### find the distibution of Tinf in the population and sample size*/
  count1 = 0
  for(t=1;t<=Tmax;t++){
    if(sum(Tall:==t)>0){
		count1 = count1 +1
    }
  }
 
  grid_T = J(1,count1,.)
  count10 = 0
  for(t=1;t<=Tmax;t++){
    if(sum(Tall:==t)>0){
	  count10 =count10 +1
      grid_T[1,count10] = t
    }
  }
 
	V = exp(index)
	S = rowsum(Y)

	denom = J(n,1,.)
	for(ti0=1;ti0<= length(grid_T);ti0++){
	  ti = grid_T[ti0]
	  indexes = selectindex(Tall:==ti)
	  denom[indexes ,1] = C_S_fun(S[indexes,1],V[indexes,1..ti]);
	}


	/*# % Careful, we actually take - the log, as we minimize the function at the
	# % end.*/
	f =sum(rowsum(Y:*index)  :- log(denom))

	return(f)
}
end 



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// C_S_fun : Computes by induction one of the elementary symm. polynomial on each row
/////of V1, matrix of size n x T.
/////
/////If S1 is scalar, computes the S1-th elem. symm. polynomial
/////If S1 is a n-column vector, computes, for row i, the S1(i)-th elem. symm.
/////polynomial.
/////
/////param S1 the vector of values for the statistic S.
/////param V1 the matrix of size n x T which coefficients are
/////          used in the elementary symm. polynomial.
/////
/////return a vector if S1 is scalar, or a matrix otherwise, containing
/////the elementary symm. polynomial on each row of V1.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

cap mata mata drop C_S_fun()
mata: 
real matrix function C_S_fun(real matrix S1, real matrix V1){

n0=rows(V1)
T0=cols(V1)

if (rows(S1)==1){
  if (S1<0 || S1>T0){
    res=0
  }else if(S1==0){
    res=1
  }else if(S1==T0){
    if(cols(V1)>1){
      /*res=matrix(apply(V1,1,prod),dim(V1)[1],1)*/
	  res = myrowproduct(V1)
    }else{
      res=V1
    }
  }else{
    
    VT_1 = V1[,range(1,cols(V1)-1,1)]
    res=V1[,T0] :* C_S_fun(S1:-1,VT_1) :+ C_S_fun(S1,VT_1);
    
  }
}else{
  res=J(n0,1,0);
  if(sum(S1:==0)!=0){
    res= J(n0,1,1):*(S1:==0);
  }
  if(sum(S1:==T0)!=0){
      /*res[S1==T]=apply(matrix(V1[S1==T,],sum(S1==T),dim(V1)[2])   ,1,prod);*/
	  temp = myrowproduct( V1:*(S1:==T0))
	  res = res:*(S1:!=T0) + temp:*(S1:==T0) 
    }
  indic = S1:>0 :& S1:<T0
  ss= sum(indic)
  if(ss>0){
   /* VT = matrix(V1[indic,T], sum(indic),1);
    VT_1= matrix( V1[indic,1:(dim(V1)[2]-1)], sum(indic), (dim(V1)[2]-1) )  
    Sind= matrix(S1[indic], sum(indic),1)
    res[indic]=VT*C_S_fun(Sind-1,VT_1)+C_S_fun(Sind,VT_1);*/
 
    VT = J(ss,1,0)
	VT_1= J(ss,cols(V1)-1,0)
	Sind = J(ss,1,0)
	l=1
	for(j=1;j<=rows(indic);j++){
		if(indic[j,1]==1){
			VT[l,1]=V1[j,T0]
			VT_1[l,]=V1[j,range(1,cols(V1)-1,1)]
			Sind[l,1] = S1[j,1]
			l=l+1
		}
	}
	
	mat0 = C_S_fun(Sind:-1,VT_1)
	mat1 = C_S_fun(Sind,VT_1)
	l=1
	for(j=1;j<=rows(indic);j++){
		if(indic[j,1]==1){
			res[j,1]=VT[l,1]*mat0[l,1] + mat1[l,1]
			l=l+1
		}
	}
 }
}
 return(res)
}
end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// isnot: sum the elements which are  not NA
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

cap mata mata drop isnot()
mata: 
real scalar function isnot(x){
  res = sum((x:!= .))
  return( res)

 }
end 


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////  best_approx_poly: This function returns the coefficients (functions of v=exp(x'beta0)) of
/////the best (in the uniform sense) approximation  of Omega(.,x) by a
/////polynomial of degree T.
/////
/////param Vtilde_min1 is the vector of coefficients exp((x-x_T)'beta0)-1 appearing
/////in Omega
/////param grid_T1 a vector containing the different values of the maximal number of periods observed
/////param Tinf0 a vector of size nx1 containing the number of periods observed for each individual
/////
/////return  the coefficients of the best approximation of Omega(.,x) by polynomial of degree T.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


cap mata mata drop best_approx_poly()
mata: 
pointer matrix function best_approx_poly(real matrix Vtilde_min1,real matrix grid_T1,real matrix Tinf0){

n = rows(Vtilde_min1) 
Tmax = cols(Vtilde_min1)
coeffs_Omega = J(n,Tmax+3,.); 


/*Vtilde_min1 = V[,range(1,(T-1),1)]:/V[,T] :- 1*/

for (i=1;i<=n;i++){
	T =Tinf0[i]
    if (T>1){
		v = Vtilde_min1[i,1..(T-1)]
    }
    /*# % Coefficients of the polynomial corresponding to the product in Omega(.,x)*/
    temp=J(T,1,0);
    temp[T,1]=1
   
    if(T==2){
      temp[1,1]=v;
    }else{
      for (j=0; j<=(T-2);j++){
          temp[T-2-j+1,1]=sum(mycolproduct(combnk(v,j+1))');
      }
    }
	
   /* # % Coefficients of Omega(.,x) (in decreasing order of exponents)*/
    coeffs_Omega[i,1..(T+2)]=conv((-1,1),(temp',0));
}


cheb_coeff=J(max(grid_T1),1,NULL)
for(t=1;t<=length(grid_T1);t++){
  T = grid_T1[t]
  cheb_coeff[T,1] = &coeff_Cheb01(T+1);
}

res = J(rows(coeffs_Omega),cols(coeffs_Omega)-1,.)
for(ti0 =1; ti0<=length(grid_T1) ; ti0++){
  ti = 	grid_T1[ti0]
  lab = (*cheb_coeff[ti,])
  res[selectindex(Tinf0:==ti),1..(ti+1)] = coeffs_Omega[selectindex(Tinf0:==ti),2..(ti+2)]  :- coeffs_Omega[selectindex(Tinf0:==ti),1]*lab[range(2,rows(lab),1)]':/(2^(ti+1))
}


g = coeffs_Omega[,1]

out = (&res,&g)     
return(out)
}
end 


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// myCI4:  compute the CI function 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

cap mata mata drop myCI4()
mata:
void myCI4(todo, q, term, alpha1,binf,bsup, v, g, H){
	v=  (normal(q+term)-normal(-q)-1+alpha1)^2 + (q<binf)*10^20 + (q>bsup)*10^20 
}
end 


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// quantile_IM: Computes the quantile suggested by Imbens & Manski 2004 in order to have
/////CI with as. size of 1-alpha. It solves Eq. (2) in Stoye (2009)
/////
/////param alpha the level for the confidence intervals
/////param bounds1 the estimated bounds
/////param std_bounds1  the estimated standard errors for the bounds
/////
/////return the value of the quantile suggested by Imbens & Manski 2004
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

cap mata mata drop quantile_IM()
mata: 
real matrix function quantile_IM(real scalar alpha1, real matrix bounds2, real matrix std_bounds2){

  term = (bounds2[2]-bounds2[1]):/max(std_bounds2);
  binf = invnormal(1-alpha1)
  bsup = invnormal(1-alpha1/2)

  /*C = (-1,1)'
  c = ( bsup, binf )'
  Cc = (C,c)*/
  
   O = optimize_init()
   optimize_init_evaluator(O, &myCI4())
   optimize_init_evaluatortype(O, "d0") 
   optimize_init_which(O,"min")
   optimize_init_argument(O, 1, term)
   optimize_init_argument(O, 2, alpha1)
    optimize_init_argument(O, 3, binf)
	 optimize_init_argument(O,4, bsup)
   /*optimize_init_constraints(O,Cc)*/
   optimize_init_params(O,(binf+bsup)/2) 
   optimize_init_verbose(O,0)
   optimize_init_tracelevel(O, "none")
   res = optimize(O)
  
return(res)
}
end 


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// compute_average_AME: Compute the average of the average marginal effects over all the periods between 1 and Tinf.
/////
/////param output a list containing the outputs of the estimation of the bounds on the AME for the periods between 1 and Tinf.
/////param Option chosen method to compute the AME: either sharp or quick. Default is quick.
/////param Tinf vector of size n x1 containing the number of periods observed for each individual.
/////param dimX the number of covariates
/////param selectX the vector of selected covariates to compute the AME.
/////If NULL then bounds are computed for all covariates. NULL by default.
/////param CIOption the option for the choice of the type of confidence intervals for the quick method, either CI2 or CI3. Default is CI2.
/////param alpha the confidence level for the confidence intervals. Default is 5\%.
/////param g_labels a matrix nx1 containing the individual labels refering to the type of attrition observed and described in the table G_types.
/////param G_types a matrix describing the different possible types of attrition observed in the dataset
/////param G_indic a matrix nxT containing the individual periods observed (0 if unobserved)
/////
/////return  A list containing the values of : Option, n, Tmax,
/////
///// Delta_hat: either the estimator of the bounds on the average of Delta (sharp method) or the approximation of Delta (quick method) over the periods;
/////
///// length_CI: the length of the confidence intervals;
/////
///// et: the estimated standard error of the influence function(s), either of the two bounds on the average of Delta (sharp method) or of
/////the approximation of Delta (quick method);
/////
///// bias_sup: the estimated upper bound on the bias (quick method);
/////
/////CI: the confidence intervals at the alpha level;
/////
/////b_hat: the estimated value of beta0 using the conditional maximum likelihood estimator;
/////
/////std_b: the estimated standard deviation of the inflence function of the  conditional maximum likelihood estimator of beta;
/////
///// influence: the matrix of size n x dimX containing the inflence function of the  conditional maximum likelihood estimator of beta;
/////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


cap mata mata drop compute_average_AME()
mata:
pointer matrix function compute_average_AME(pointer matrix output,string scalar Option,real matrix Tinf,
											real scalar dimX,real matrix selectX,string scalar CIOption, real scalar alpha, real scalar attri, real matrix g_labels, real matrix G_types){

  /*## find length of output.*/
  Tmax =  rows(output)-1
  n = rows(Tinf)

   /*### number of variables to compute the AME/ATE*/

  /* # Option..*/
  if(Option=="quick"){
  	
    Delta_hat = J(1, length(selectX),0)
    bias_sup  = J(1, length(selectX),0)
    infl = J(n,dimX,0)

    for(t_end=1;t_end<=Tmax;t_end++){
      if(attri==1){
          sel_g = G_types[,t_end]:==1
       /*  # discard observations if T not in periods.*/
        Tall = J(rows(g_labels),1,.)
        for(g =1; g<=length( sel_g);g++){
          if(sel_g[g]){
            indexes = selectindex(g_labels:==g)
            Tall[indexes,1]=J(sum(g_labels:==g),1,t_end)
          }
        }
      }else{
        Tall = -pmax(-t_end,-Tinf)
       /* # discard observations if T < t_end*/
	   indexes0=selectindex(Tall :< t_end)
	   if(length(indexes0)>0){
        Tall[ indexes0,] = J(sum(Tall :< t_end),1,.)
	   }
	   
	   
      }
    out_cur = (*output[t_end,1])
    /*for_average = out_cur$for_average
    # Compute average of all estimators at period t
    Delta_hat =  Delta_hat + for_average[[1]]*/
	for_average = (*out_cur[13,1])
	Delta_hat =  Delta_hat :+ (*for_average[1,1])
	
    /*# Compute average of associated biases
    bias_sup   = bias_sup + for_average[[2]] # + out_cur$bias_sup*/
	bias_sup   = bias_sup :+ (*for_average[2,1])'
	
    /*# Compute average of influence functions
    # infl[Tinf>=t_end ,] = infl[Tinf>=t_end ,]  + out_cur$influence
    infl[!is.na(Tall),] = infl[!is.na(Tall) ,]  + out_cur$influence*/
		influence=(*out_cur[12,1])
		infl[selectindex(Tall:!=.),] = infl[selectindex(Tall:!=.),]  :+ influence
	   
    }

    infl = infl:/(Tinf*J(1,dimX,1))
    /*### Apply the IC construction method*/

    et = J(1,dimX, 0)
	et =et :+ diagonal(sqrt(variance(infl)))';

    et =et:/sqrt(rows(infl))
    et = et[selectX]
    eps_n = (2*log(log(n)))^(1/2)/sqrt(rows(infl))

	if( CIOption == "CI3"){
      length_CI = 2 :* et :*  sqrt(invnchi2(1,  ncp = ((bias_sup + eps_n):/et):^2,0.95))
    }else{
      length_CI = 2 :* et :*  sqrt(invnchi2(1,  ncp = (bias_sup:/et):^2,0.95))
    }
    /*### compute CI*/

    CI = (Delta_hat)'*J(1,2,1)
    CI[,1] = CI[,1] :- length_CI'/2
    CI[,2] = CI[,2] :+  length_CI'/2
	
	
  }else{

    Delta_hat = J(length(selectX),2,0)

    infl = J(dimX,1,NULL)
    for(k=1;k<=dimX;k++){
      infl[k,1]=&J(n,2,0)
    }


    for(t_end=1;t_end<=Tmax;t_end++){
     /* # attributes(out_cur)
      out_cur = output[[t_end]]
      for_average = out_cur$for_average*/
	  out_cur = (*output[t_end,1])
	  for_average = (*out_cur[13,1])
	  Delta_hat =  Delta_hat :+ (*for_average[1,1])
	  
  /*    # Compute average of all estimators at period t
      Delta_hat =  Delta_hat + for_average[[1]] #+ out_cur$Delta_hat
     # Compute average of influence functions*/
      for(k=1;k<=dimX;k++){
     /*   infl[[k]] = infl[[k]]  + out_cur$influence[[k]]*/
      (*infl[k,1]) = (*infl[k,1])  :+ (*(*out_cur[12,1])[k,1])
	 }
     /* # dim( out_cur$influence[[k]])*/

    }

    for(k=1;k<=dimX;k++){
      (*infl[k,1])= (*infl[k,1]):/(Tinf*J(1,cols(*infl[k,1]),1))
    }
   /* # Delta_hat = Delta_hat/Tmax
    # infl = infl/(matrix(Tinf,n,1)%*%rep(1,dimX))
    ### Apply the IC construction method*/


   /*# Delta_hat[,1] - length_CI/2*/
    length_CI= J(1,length(selectX),.)
	et=J(dimX,2, .)
    for(k=1;k<=length(selectX);k++){
      /*et[k,] =apply(infl[[k]][!is.na(Tall),],2,std)/sqrt(n_s);*/
	  et[k,] = diagonal(sqrt(variance((*infl[k,]))))':/sqrt(n)
    }
    et=et[selectX,]
    bias_sup = J(2,1,0)

    time = 0;
	nb_var = length(selectX)
    CI = J(nb_var,2,.)

   /* ## compute CI at level alpha.
    # k=1*/
	b_hat = (*out_cur[10,1])
	for(k=1;k<=nb_var;k++){
      quant = quantile_IM(alpha, Delta_hat[k,], et[k,]);
      phi_alpha = sqrt(n)*abs(b_hat[k])/sqrt(variance((*infl[k,])))[1,1] > invnormal(1-alpha/2)
      if(phi_alpha){
        CI[k,] = (Delta_hat[k,1] :- quant* et[k,1], Delta_hat[k,2] :+ quant*et[k,2])
      }else{
        CI[k,] = (min(0,Delta_hat[k,1] - quant* et[k,1]), max(0,Delta_hat[k,2] + quant*et[k,2]));
      }

      length_CI[k] = CI[k,2] - CI[k,1]

    }



  }


  out = J(13,1,NULL)
  out[1,1] = &Option
  out[2,1] = &n
  out[3,1] = &"average"
  /*out[4,1] = */
  out[4,1] = &Delta_hat
  out[5,1] = &length_CI
  out[6,1] = &et
  out[7,1] = &bias_sup
  out[8,1] = &CI
 /* out[10,1] = NA*/
  out[10,1] = &(*out_cur[10,1])
  out[11,1] = &(*out_cur[11,1])
  out[12,1] = &infl

  /*names(out) <- c("Option","n","Tmax","Time","Delta_hat","length_CI","et","bias_sup","CI","phi_alpha","b_hat","std_b", "influence")*/

 return(out)
}
end




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// compute_AME: Function which compute the AME at different values of T according to the selected values of compute_T
/////
/////
///// param Yall matrix n x T containing the values of the dependent variable Yt
/////param Xall array of dimensions n x T x dimX containing the values of the predictors at the different periods.
/////param Call matrix n x 1 containing the identifiers of the clusters to which each individual belongs. Default is NULL
/////param Option chosen method to compute the AME: either sharp or quick. Default is quick.
/////param selectX the vector of selected covariates to compute the AME.
/////If NULL then bounds are computed for all covariates. NULL by default.
/////param compute_T the vector of selected periods to compute the AME.
/////If NULL, then as described in Section 5.4 of DDL, AME is computed at min supp (T).
/////If specified to ``all",  the AME is computed at all available periods but the average over the latter is also computed. Default is NULL.
/////param alpha  the confidence level for the confidence intervals. Default is 5\%.
/////param CIOption the option for the choice of the type of confidence intervals for the quick method, either CI2 or CI3. Default is CI2.
/////param g_labels a matrix nx1 containing the individual labels referring to the type of attrition observed and described in the table G_types.
/////param G_types a matrix describing the different possible types of attrition observed in the dataset
/////param G_indic a matrix nxT containing the individual periods observed (0 if unobserved)
/////param nbCores the number of cores used by the program to compute the AME for the ``sharp" method.
/////param ratio the ratio R in DDL for the nonparametric estimator of the conditional moments of S
/////
/////return a list of all the outputs of compute_AME_t containing the different results of the estimation of the different values of T considered.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



cap mata mata drop compute_AME()
mata: 
pointer matrix function compute_AME(real matrix Yall,pointer matrix Xall, real matrix Call, string scalar Option, real matrix selectX, string matrix compute_T,
										real scalar alpha, string scalar CIOption, real matrix g_labels ,real matrix G_types, real matrix G_indic, 
										real scalar ratio){
  /* compute_T = NULL
   selectX = NULL
   alpha = 0.05
   CIOption = "CI2"
  ## Compute the Tinf = min( Supp(T)) for all individuals*/
  Tinf =  J(rows(Yall),1,.)
  for(i=1;i<=rows(Yall);i++){
    Tinf[i,1] = isnot(Yall[i,])
   } 
  
  
  
  
  
   /*## Max of the Tinf in dataset*/
  Tmax = max(Tinf)

   /*## Get the dimension of X*/
   dimX=cols((*Xall[1,1]))
 
  /*### find the distibution of Tinf in the population and sample size*/
  count1 = 0
  for(t=1;t<=Tmax;t++){
    if(sum(Tinf:==t)>0){
		count1 = count1 +1
    }
  }
  
  
  grid_T = J(1,count1,.)
  n_dist = J(1,count1,.)
  count10 = 0
  for(t=1;t<=Tmax;t++){
    if(sum(Tinf:==t)>0){
	  count10 =count10 +1
      grid_T[1,count10] = t
      n_dist[1,count10] = sum(Tinf:==t)
    }
  }
  

  prop_T = n_dist/sum(n_dist)

   /*## number of clusters*/
  if(Call==NULL){
    Call1 = J(1, rows(Yall),1)
  }else{
    Call1 =  Call
  }

  /*## compute combinatorial numbers at all possible dates in the dataset.*/  
  mat_C_k_T=  J(Tmax,1,NULL)
  cheb_coeff= J(Tmax,1,NULL)
  for(t= 1; t<=length(grid_T);t++){
  	  T0 = grid_T[t]
	  M1 =  range(0, T0, 1)*J(1,T0+1,1)-J(1,T0+1,1)'*range(0, T0, 1)'
	  M11 = J(1,T0+1,T0) - range(0,T0,1)'
	  mat_C_k_T[T0,1] = &chooseM(J(T0+1,1,1)*M11,M1)
	  cheb_coeff[T0,1]  = &revorder(coeff_Cheb01(T0+1)')
  }

   /*## consider linear regression est. /4 as starting point*/
  Olin = optimize_init()
  optimize_init_evaluator(Olin, &myeval_lin())
  optimize_init_evaluatortype(Olin, "d0") 
  optimize_init_argument(Olin, 1, Yall)
  optimize_init_argument(Olin, 2, Xall)
  optimize_init_params(Olin, J(1,dimX,0)) 
  optimize_init_verbose(Olin, 0)
  optimize_init_tracelevel(Olin, "none")
  b_lin = optimize(Olin)
  start_point = b_lin/4

   /*### estimate loglikelihood.
  # ** insert catching errors ex: delete constant variables, ect..*/
  O = optimize_init()
  optimize_init_evaluator(O, &myeval4())
  optimize_init_evaluatortype(O, "d0") 
  optimize_init_argument(O, 1, Yall)
  optimize_init_argument(O, 2, Xall)
  optimize_init_params(O, start_point) 
  optimize_init_verbose(O, 0)
  optimize_init_tracelevel(O, "none")
  b_hat = optimize(O)

  /*# Compute the influence function of beta_hat. Useful for inference on
  # Delta, at the end*/
  
  phi_b = infl_func_beta(b_hat,Yall, Xall, Call1);
  std_b = sqrt(diagonal(variance(phi_b)))/sqrt(rows(phi_b))

 
   /* append_name <- function(x){return(paste0("T_",x))}*/
   /*### compute only at last period*/
  if(compute_T[1,1] =="" ){
    Tall = Tinf
	output =J(1,1,NULL)
    res =  compute_AME_t(Yall,Xall, prop_T, grid_T,n_dist,Tmax,Tall,Tinf,Call1,mat_C_k_T,
                                            cheb_coeff,b_hat,alpha, CIOption ,Option,dimX,  selectX, phi_b, std_b , ratio) 
   output[1,1] = &res

    /*names(  output) <- c("Tinf")*/
  }else if( compute_T[1,1] !="" & compute_T[1,1] !="all"){
     /*## compute for selected periods
    # t0=1
    # compute_T= c(2,3)*/
	
	output =J(length(compute_T),1,NULL)
	
    for(t0 =1; t0<=length(compute_T);t0++){
      t_end = strtoreal(compute_T[t0])
       /*## Tall is the T at which the effect is computed, which is different according to the label g (if T is in the list of observed periods)
      # , g_labels  , G_types, G_indic)

      # find types containing t_end*/
      if(G_types[1,1] !=.){
        sel_g = G_types[,t_end]:==1
       /*  # discard observations if T not in periods.*/
        Tall = J(rows(g_labels),1,.)
        for(g=1;g<=length( sel_g);g++){
          if(sel_g[g]){
		  	indexes = selectindex(g_labels:==g)
            Tall[indexes,1]=J(sum(g_labels:==g),1,t_end)
          }
        }
      }else{
        Tall = - pmax(-t_end,-Tinf)
        /* # discard observations if T < t_end*/
		indexes0 = selectindex(Tall :< t_end)
		if(length(indexes0)>0){
			Tall[indexes0] =J(sum(Tall :< t_end),1,.)
		}
      }
       /*# cbind( Tall,dataX[,,1])*/
      grid_T0 = 0
      n_dist0 = 0
      for(t= 1; t<=Tmax; t++){
	  	indexes1 = selectindex(Tall:!=.)
        if(sum(Tinf[indexes1]:==t)>0){
          grid_T0 = (grid_T0 , t)
          n_dist0 = (n_dist0,sum(Tinf[indexes1]:==t))
        }
      }
	  grid_T0 = grid_T0[2..length(grid_T0)]
	  n_dist0 =  n_dist0[2..length(n_dist0)]
      prop_T0 = n_dist0:/sum(n_dist0)

      /* # Tall = pmin(t_end,Tinf)
      # discard observations if T < t_end
      # Tall[Tall < t_end] <- NA*/

     /*  # grid_T0 = grid_T =3
      # grid_T0[grid_T0>t_end] = t_end*/
      output[t0,1] = &compute_AME_t(Yall,Xall, prop_T0,	 grid_T0,n_dist0,Tmax,Tall,Tinf,Call1,mat_C_k_T,
                                              cheb_coeff,b_hat,alpha, CIOption ,Option,dimX,  selectX , phi_b, std_b ,  ratio)

								  
    }
  
    /*names(  output) <- apply(matrix(compute_T,length(compute_T),1),1,append_name )*/
  }else{
    /* ## compute for all periods*/

	output= J(Tmax+1,1,NULL)
    for(t_end=1;t_end<=Tmax;t_end++){
     /*  # find types containing t_end*/
      if(G_types[1,1] !=.){
        sel_g = G_types[,t_end]:==1
       /*  # discard observations if T not in periods.*/
        Tall = J(rows(g_labels),1,.)
        for(g =1; g<=length( sel_g);g++){
          if(sel_g[g]){
            indexes = selectindex(g_labels:==g)
            Tall[indexes,1]=J(sum(g_labels:==g),1,t_end)
          }
        }
      }else{
         Tall = -pmax(-t_end,-Tinf)
        /* # discard observations if T < t_end*/
		indexes0 = selectindex(Tall :< t_end)
		if(length(indexes0)>0){
			Tall[indexes0] = J(sum(Tall :< t_end),1,.)
		}
      }

      
       /*# cbind( Tall,dataX[,,1])*/
      grid_T0 = 0
      n_dist0 = 0
      for(t= 1; t<=Tmax; t++){
	  	indexes1 = selectindex(Tall:!=.)
        if(sum(Tinf[indexes1]:==t)>0){
          grid_T0 = (grid_T0 , t)
          n_dist0 = (n_dist0,sum(Tinf[indexes1]:==t))
        }
      }
	  grid_T0 = grid_T0[2..length(grid_T0)]
	  n_dist0 =  n_dist0[2..length(n_dist0)]
      prop_T0 = n_dist0:/sum(n_dist0)
	  
      output[t_end,1]  = &compute_AME_t(Yall,Xall, prop_T0, grid_T0,n_dist0,Tmax,Tall,Tinf,Call1,mat_C_k_T,
                                                 cheb_coeff,b_hat,alpha, CIOption ,Option,dimX,  selectX, phi_b, std_b , ratio)
												 
    }
    /* ### add computation of average.*/

	attri = G_types[1,1] !=.
	/*if(attri ==0){
		G_types = J(0,2,2)
		g_labels = J(0,2,2)
	}*/
    output[Tmax+1,1] = &compute_average_AME(output,Option,Tinf,dimX,selectX,CIOption,alpha, attri , g_labels, G_types) 

    /* names(  output) <- c(apply(matrix(1:Tmax,length(1:Tmax),1),1,append_name ),"average")*/
   /*  ## add name average*/
  }

  return( output)
}
end 



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// compute_AME_t : Function which compute the AME at a specified value of T contained in Tall.
/////
/////param Yall matrix n x T containing the values of the dependent variable Yt.
/////param Xall array of dimensions n x T x dimX containing the values of the predictors at the different periods.
/////param prop_T a vector containin the proportions of the different numbers of periods observed in the dataset.
/////param grid_T a vector containing the different numbers of periods observed in the dataset.
/////param n_dist a vector containing the number of individuals which are observed for T periods, where T is given in grid_T
/////param Tmax the maximal number of periods observed in the dataset
/////param Tall vector of size n x1 containing the specified values of T where we compute the AME.
/////param Tinf vector of size n x1 containing the number of periods observed for each individual.
/////param Call1 matrix n x 1 containing the identifiers of the clusters to which each individual belongs. Default is NULL
/////param mat_C_k_T a matrix containing the combinatorial numbers.
////param cheb_coeff the coefficients of the Chebyshev polynomials T_n.
/////param b_hat the estimated value of beta0 using the conditional maximum likelihood estimator.
/////param alpha the confidence level for the confidence intervals. Default is 5\%.
/////param CIOption the option for the choice of the type of confidence intervals for the quick method, either CI2 or CI3. Default is CI2.
/////param Option  chosen method to compute the AME: either sharp or quick. Default is quick.
/////param dimX the number of covariates
/////param selectX the vector of selected covariates to compute the AME.
/////If NULL then bounds are computed for all covariates. NULL by default.
/////param phi_b the matrix of size n x dimX containing the influence function of the  conditional maximum likelihood estimator of beta.
/////param std_b the estimated standard deviation of the influence function of the  conditional maximum likelihood estimator of beta.
/////param nbCores the number of cores used by the program to compute the AME for the ``sharp" method.
/////param ratio the ratio R in DDL for the nonparametric estimator of the conditional moments of S
/////
/////return A list containing the values of : Option, n, Tmax, Time (computational time),
///// Delta_hat: either the estimator of the bounds on Delta (sharp method) or the approximation of Delta (quick method);
/////
/////length_CI: the length of the confidence intervals;
/////
/////et: the estimated standard error of the influence function(s), either of the two bounds on Delta (sharp method) or of
/////the approximation of Delta (quick method);
/////
///// bias_sup: the estimated upper bound on the bias (quick method);
/////
///// CI: the confidence intervals at the alpha level;
/////
///// phi_alpha: the phi alpha statistic intervening in the computation of the confidence interval of the sharp method;
/////
/////b_hat: the estimated value of beta0 using the conditional maximum likelihood estimator;
/////std_b: the estimated standard deviation of the influence function of the  conditional maximum likelihood estimator of beta;
/////influence: the matrix of size n x dimX containing the influence function of the  conditional maximum likelihood estimator of beta;
/////
///// for_average: a list containing the estimated values of Delta(x) and the influence function weighted by the values of Tinf, to compute the
///// average of the AME over all the observed periods.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




cap mata mata drop compute_AME_t()
mata: 
pointer matrix function compute_AME_t(real matrix Yall, pointer matrix Xall,real matrix prop_T, real matrix grid_T,real matrix n_dist,
									real scalar Tmax,real matrix Tall,real matrix Tinf, real matrix Call1, pointer matrix mat_C_k_T, pointer matrix cheb_coeff,
									real matrix b_hat,real scalar alpha, string scalar CIOption , string scalar Option,real scalar dimX,real matrix selectX, real matrix phi_b,
									real matrix std_b, real scalar ratio){

  /*### parameters for the sharp method.
  # ratio=10*/
  RK = 1/(2*sqrt(pi()));  /* #% int K^2(u)du*/
  kappa2 = 1; /* #% int u^2 K(u)du */

  /*c_hat = vector("list")*/

  /*### number of variables to compute the AME/ATE*/
  if(selectX[1,1]==.){
    nb_var = dimX
    selectX = 1..dimX
  }else{
    nb_var = length(selectX)
  }

  /*### to stock the phi_alpha stat.*/
  phi_alpha_m= J(nb_var,1,NULL)
  grid_T0 = sort(uniqrows(Tall),1)
  grid_T0 = grid_T0[selectindex(grid_T0:!=.),]
  /*# dim(Xall)
  ## Estimation, either "quick" or "sharp"*/
  if(Option == "quick"){


	n_1 = sum(Tall:!=.)
	X = J(Tmax,1,NULL)
	for (j=1; j<=Tmax; j++){
	 	lab = (*Xall[j,]) 
		X[j,1]=&lab[selectindex(Tall:!=.),]
	}

	Y = Yall[selectindex(Tall:!=.),]
   
    Tall0 = Tall[selectindex(Tall:!=.),]
    Tinf0 = Tinf[selectindex(Tall:!=.),]
    Call10 = Call1[selectindex(Tall:!=.),]
    grid_T1 = grid_T[selectindex(grid_T :>=min( Tall0 ))]

	civals = uniqrows(Call10)
    /*# Tmax = max(grid_T1)
    # X = Xall
    # Y = Yall*/
    n = n_1
   /* # T <- dim(X)[2]
    ## stock the sample size*/
    n_s = n

	/*lab = (*X[1,]) 
    dimX = cols(&lab[selectindex(Tall:!=.),])*/
    
    S = rowsum(Y)
	
    XT =  J(n,dimX,.) 
    for (ti0=1; ti0<=length(grid_T0); ti0++){ 
		ti = grid_T0[ti0]
        if(sum(Tall0:==ti)>0){
		  lab = (*X[ti,]) 
          XT[selectindex(Tall0:==ti),] =  lab[selectindex(Tall0:==ti),]
        }
    }

    index = J(n,Tmax,.)

    for (ti0=1; ti0<=length(grid_T1); ti0++){ 
		ti = grid_T1[ti0]
		for (t=1;t<=ti;t++){
		  lab = *(X[t,1])
          index[selectindex(Tinf0:==ti),t] = (lab[selectindex(Tinf0:==ti),])*b_hat'
        }
     }
    V = exp(index);


   Vtilde = J(rows(V),cols(V),.)
   for (ti0=1; ti0<=length(grid_T1); ti0++){ 
	  ti = grid_T1[ti0]
	  lab = J(sum(Tinf0:==ti),1,.)
	  for(i0=1;i0<=sum(Tinf0:==ti);i0++){
	  	 lab[i0,1]=V[selectindex(Tinf0:==ti)[i0],Tall0[selectindex(Tinf0:==ti)[i0]]]
	  }
      Vtilde[selectindex(Tinf0:==ti),] =  V[selectindex(Tinf0:==ti),]:/(lab*J(1,cols(V),1)) 
	}

    Vtilde_min1 =  J(rows(V),Tmax -1,.)

    for (ti0=1; ti0<=length(grid_T1); ti0++){ 
	  ti = grid_T1[ti0]
      if(ti>=2){
        ind = 1..ti
        Vtilde_min1[selectindex(Tinf0:==ti),1..(ti-1)] =  Vtilde[selectindex(Tinf0:==ti), ind[selectindex(ind:!=Tall0[selectindex(Tinf0:==ti)][1])] ]:- 1;
      }
    }

    out=best_approx_poly(Vtilde_min1,grid_T1,Tinf0);
	res = (*out[1])
    g= (*out[2]) 
		  

	 	  
	Xtilde = J(dimX,1,NULL)
	for (j=1; j<=dimX; j++){
		Xtilde[j,1]=&J(n,Tmax,.)
	}
    for(j=1; j<=dimX; j++){
		Xtemp = J(n,Tmax,0)
		for(t=1;t<=Tmax;t++){
			Xtemp[,t] = (*(X[t,1]))[,j]
		}
		(*(Xtilde[j,1])) = Xtemp :- XT[,j]*J(1,Tmax,1)
     }  
    
		  
    C_S_vec = J(n,1,.)
    for(ti0 =1; ti0<= length(grid_T1);ti0++){
	  ti = grid_T1[ti0]
      C_S_vec[selectindex(Tinf0:==ti),] = C_S_fun(S[selectindex(Tinf0:==ti),1],Vtilde[selectindex(Tinf0:==ti),1..ti]);
    }
       	  
    mat_combin = J(n,max(grid_T1)+1,.)
    for(ti0 =1; ti0<= length(grid_T1);ti0++){
	  ti = grid_T1[ti0]
	  T_minus_t = J(sum(Tinf0:==ti),1,1)*(ti :- range(0,ti,1))'
	  S_minus_t =  S[selectindex(Tinf0:==ti),]*J(1,ti+1,1) :- J(sum(Tinf0:==ti),1,1)*range(0,ti,1)'  
      mat_combin[selectindex(Tinf0:==ti),1..(ti+1)]  = chooseM(T_minus_t,S_minus_t):/(C_S_vec[selectindex(Tinf0:==ti),]*J(1,ti+1,1))
    }

    Mat_fin  = J(n,max(grid_T1)+1,.)
    Mat_a  =J(n,max(grid_T1)+1,.)
 
    for(ti0 =1; ti0<= length(grid_T1);ti0++){
	  ti = grid_T1[ti0]
	  sel0 = selectindex(Tinf0:==ti)
	  for(j=1;j<=sum(Tinf0:==ti);j++){
			j0 = sel0[j]
		  	Mat_a[j0,1..(ti+1)]= revorder(res[j0,1..(ti+1)])
	  }
      Mat_fin[sel0 ,1..(ti+1)] = Mat_a[sel0,1..(ti+1)]:*mat_combin[sel0,1..(ti+1)];
    }     

	moy_fin = sum(Mat_fin)/rows(Mat_fin)
    Delta_hat = b_hat[selectX]' :* moy_fin
          
    for_average = J(3,1,NULL)
	lab1 =  b_hat[selectX] * sum((Mat_fin):/(Tinf0*J(1,cols(mat_combin),1)))/n_s;
    for_average[1,1] = &lab1
	
    m0 = mat_combin[,1]
    m0[selectindex(m0:==.),] = J(sum(m0:==.),1,0)
    g[selectindex(g:==.),] = J(sum(g:==.),1,0)

    /*# Estimation of the maximal bias*/
	bias_sup = abs(b_hat[selectX]') :* m0'*abs(g:/4:^Tinf0):/(n_s*2);
	lab2 = abs(b_hat[selectX]') :*  m0'*abs(g:/(4:^Tinf0:*Tinf0)):/(n_s*2)
    for_average[2,1] = &lab2

    /*# Influence function of Delta_hat*/
    term1 =  rowsum(Mat_fin)*b_hat :+ moy_fin :* phi_b[selectindex(Tall:!=.),]  
    for_term2 = J(n_s,1,0)
     
     for (k=1;k<=dimX;k++){
            deriv_C_S = J(n,1,0)
			Xtilde0 = (*Xtilde[k,1])
			
			for(ti0=1;ti0<=length(grid_T1);ti0++){
				ti = grid_T1[ti0]
				index = selectindex(Tinf0:==ti)
				if(ti==1){
					t=1
					deriv_C_S[index,] = deriv_C_S[index,] :+ Xtilde0[index,t]:*Vtilde[index,t]
				}else{
					for(t=1;t<=ti;t++){
						Mt = Vtilde[index,selectindex((1..ti):!=t)]
						deriv_C_S[index,] = deriv_C_S[index,] :+ Xtilde0[index,t]:*Vtilde[index,t]:*C_S_fun(S[index,]:-1, Mt  );
				  }
			
			  }
			}
              
           
            deriv_e = J(n,Tmax+1,0)
			
			for(ti0=1;ti0<=length(grid_T1);ti0++){
				ti = grid_T1[ti0]
				if(ti!=1){
					index = selectindex(Tinf0:==ti)
					Vtilde0 = Vtilde_min1[index,]
				
					for(t=1;t<=(ti-1);t++){
						for(u=1;u<=(ti-1);u++){     
						  Vtilde00 = Vtilde0[,1..(ti-1)]
						  Mt = Vtilde00[,selectindex((1..(ti-1)):!=t)]
						  deriv_e[index,t+1] = deriv_e[index,t+1] :+ Xtilde0[index,u]:*Vtilde[index,u]:*C_S_fun(t-1, Mt:-1)
					   }
					}
				}
			}
           
			deriv_lambda = J(n,Tmax+2,0);
			for(ti0=1;ti0<=length(grid_T1);ti0++){
				ti = grid_T1[ti0]
				index = selectindex(Tinf0:==ti)
				deriv_lambda[index,range(3,ti+2,1)] = deriv_e[index,range(2,ti+1,1)]-deriv_e[index,range(1,ti,1)];
            }
            /*# Derivative of the coeff a_t wrt beta*/
			deriv_a = deriv_lambda[,1..(Tmax+1)]
			for(ti0=1;ti0<=length(grid_T1);ti0++){
				ti = grid_T1[ti0]
				index = selectindex(Tinf0:==ti)
				cheb = (*cheb_coeff[ti,1])
				deriv_a[index,1..(ti+1)] = deriv_lambda[index,range(1,ti+1,1)] :- deriv_lambda[index,(ti+2)]*cheb[1,1..(ti+1)]:/(2^(ti+1));
            }
			
            /*# moy_deriv = (T+1)*mean(mat_combin*(deriv_a - bsxfun(@times, Mat_a, deriv_C_S/C_S_vec)),'all');*/
            moy_deriv = sum(mat_combin:*(deriv_a :-  Mat_a:* ((deriv_C_S:/C_S_vec)*J(1,cols(Mat_a),1))))/n;
          
            for_term2 = for_term2 :+ moy_deriv:*phi_b[selectindex(Tall:!=.),k]
	
    } /*## end of the for k loop*/

	
	
	term2 = for_term2 * b_hat; 

    infl =  Re(term1 :+ term2);


    nb_clust =length(uniqrows(Call10))
    et = J(1,dimX,0)
    for(ci=1;ci<=nb_clust;ci++){
      /*if(dimX==1){
        et =et + var(infl[Call10==ci ,])
      }else{*/
	    cival = civals[ci]
        et =et :+ diagonal(variance(infl[selectindex(Call10:==  cival ),]))'; 
    }

    et =sqrt(et):/sqrt(rows(infl))
    et = et[selectX]
	eps_n = 0
	if(CIOption==""){
		CIOption0 = "CI2"
	}else{
		eps_n = strtoreal(CIOption)
		CIOption0 = "CI3"
		if(eps_n==0){
		 eps_n = (2*log(log(n)))^(1/2)/sqrt(rows(infl))
		}
	}

    if( CIOption0 == "CI3"){
      length_CI = 2 :* et :*  sqrt(invnchi2(1,  ncp = ((bias_sup :+ eps_n)':/et):^2,0.95))
    }else{
      length_CI = 2 :* et :*  sqrt(invnchi2(1,  ncp = (bias_sup':/et):^2,0.95))
    }
    /*### compute CI*/

    CI =  Delta_hat*J(1,2,1)
    CI[,1] = CI[,1] :- length_CI'/2
    CI[,2] = CI[,2] :+  length_CI'/2


  }else{ /*### end of Option 1 "quick".*/

    n = rows(Yall)
    nb_clust =length(uniqrows(Call1))
	civals = uniqrows(Call1)
    
	infl = J(dimX,1,NULL)
    for(k=1;k<= dimX;k++){
      infl[k,1]=&J(n,2,0)
    }

    Tall0 = Tall[selectindex(Tall:!=.),]
    grid_T1 = grid_T[selectindex(grid_T :>=min( Tall0 ))]
    n_s = sum(Tall:!=.)
    for_average = J(3,1,NULL)
	
	 boundsall = J(nb_clust*length(grid_T1),1,NULL)

	 
	 
    /*
    # ti0=1
    # ci =1*/
    count = 1
    for(ci=1; ci<=nb_clust;ci++){
      for(ti1=1;ti1<=length(grid_T1);ti1++){

	    cival=civals[ci]
        T = grid_T1[ti1]

        selecti = selectindex(Tinf:==T  :& Call1:==cival :& (Tall:!=.))
		n1 = sum(Tinf:==T  :& Call1:==cival :& (Tall:!=.))
		
        Y = Yall[selecti,1..T]
		
		 X = J(T,1,NULL)
		  for (j=1; j<=T; j++){
			X[j,1]=&J(n1,dimX,0)
	      }
		  for(j=1; j<=T; j++){
		  	Xt =(*Xall[j,]) 
			(*(X[j,1])) = Xt[selecti,]
	      }
          
		Tall0 = Tall[selecti,]

        /*# % Compute the influence function of beta_hat. Useful for inference on
        # % Delta, at the end.*/
        phi  = phi_b[selecti,]

        n = rows(*X[1,1])
        T = rows(X)
        dimX = cols(*X[1,1])
  
		T_minus_t = J(n,1,1)*(T :- range(0,T,1))'
        S =rowsum(Y)  
	
		XT =  J(n,dimX,.) 
		for (ti0=1; ti0<=length(grid_T0); ti0++){ 
			ti = grid_T0[ti0]
			if(sum(Tall0:==ti)>0){
			  lab = (*X[ti,]) 
			  XT[selectindex(Tall0:==ti),] =  lab[selectindex(Tall0:==ti),]
			}
		}

   
       /* #
        # # % Parameter used to compute numerical derivatives wrt beta and gamma*/
        hderiv=1e-3;
        /*#

        # % Initialisation
        # options=optimoptions('fminunc','Display','off');
        # b_hat = optim(par = beta0, log_lik_FE_logit,Y=Y,X=X)$par*/


        index = J(n,T,0)

        /*# % Step 2: bounds on the AME

        # % We first need nonparametric estimators of mt(x).
        # % We use mt(x)=ct(x)/c0(x) for t\geq 0, with (c0(x),...,cT(x))'
        # % = A x (Pr(S=0|X=x)/C0(x;beta0),...,Pr(S=T|X=x)/CT(x;beta0).

        ## test if X of dim > 2*/
          /*## test if X of dim > 2*/
        for (t=1;t<=T;t++){
           index[,t] = *(X[t,1])*b_hat';
        }
		   

        /*# % Intercept assuming that Y_T on X_T is a logit: used for the
        # % computation of the bandwidth below*/
		intercept = estim_intercept(Y,index);
		index_int = intercept :+ index;
        V = exp(index);
        
        /*# %% Computation of the bandwidth for local linear estimation.
        # % We fix h so that estimated avg absolute bias = ratio * estimated
        # % avg asymp. std dev. To estimate both, we assume that the fixed
        # % effect is actually constant (and then estimated by intercept).


        # % Uniform draws on Supp(X). Used below to get the bandwidth.*/
		n_mx = 2000
		mx= J(dimX,1,NULL)
		  for (j=1; j<=dimX; j++){
			mx[j,1]=&J(n_mx,T,0)
	      }
		
		scaling = J(dimX,T,1)
		  for(k=1;k<=dimX; k++){
		  	for(t=1;t<=T;t++){
					scaling[k,t] =  max((*X[t,1])[,k])-min((*X[t,1])[,k])
					(*mx[k,1])[,t] =  min((*X[t,1])[,k]):+ (J(n_mx,1,1):*scaling[k,t]):* runiform(n_mx,1)
			}
		 }
    
	
        scaling0 = myrowproduct(myrowproduct(scaling)')
		index_bis= J(n_mx,T,0)
		for(k=1;k<=dimX; k++){
			index_bis = index_bis :+ (*mx[k,1]) :* b_hat[k];  
		}
		
	
		C_mat = J(n,T+1,0);
		PSt_X = J(n,T+1,0);
	    h = J(1,T+1,0);
		for (t=0;t<=T;t++){
		  if(t==0){
		  	C_mat[,t+1] = C_S_fun(t,V):*J(n,1,1)
		  }else{
		  	C_mat[,t+1] = C_S_fun(t,V);
		  }
		   /*# % Computation of the avg std dev: (R(k)^q int sigma^2(x)dx/n)^{1/2} 
		  # % (see Hansen's notes). We use the uniform draws above. The 
		  # % estimator is an average of sigma^2(x) over these draws        */
		  mean_approx_St = exp(t:*intercept):*myrowproduct((1:-Lambda(intercept:+index_bis))):* C_S_fun(t,exp(index_bis));
		  std_approx_St = scaling0*sqrt(RK^(dimX*T) :* mean(mean_approx_St:*(1:-mean_approx_St)):/n);
		  
		  
		   /*# % Computation of the average absolute bias*/
		  mean_approx_St = exp(t:*intercept):*myrowproduct(Lambda(index_int)):*C_mat[,t+1];
		  d0c = cols(Lambda(index_int))
		  d0r = rows(Lambda(index_int))
		  
		  term1 = J(d0r, d0c,0)
		  term2 = J(d0r, d0c,0)
		  
		  if (t==0){
			deriv_log_C = 0;
			for(k=1;k<=dimX;k++){
				term1 = term1 :+(deriv_log_C :+ b_hat[k] :* Lambda(index_int)):^2;
				term2 = term2 :+ deriv_log_C:*(b_hat[k] :- deriv_log_C) :+ b_hat[k]:^2:*Lambda_prime(index_int); 
			}
			term1 =term1:^2
		  }else{
			bbx = V:* (C_mat[,t]*J(1,cols(V),1))
			for(k=1;k<=dimX;k++){
				deriv_log_C = b_hat[k] :* ( bbx :/ (C_mat[,t+1]*J(1,cols(bbx),1)))  
				term1 =term1 :+(deriv_log_C :+ b_hat[k] :* Lambda(index_int)):^2;
				term2 =term2 :+ deriv_log_C:*(b_hat[k] :- deriv_log_C) :+ b_hat[k]:^2:*Lambda_prime(index_int); 
			}
			term1 =term1:^2
		  }
		 
		 
		 bias_approx_St = sum(sum(abs( (mean_approx_St*J(1,cols(term1),1)):*(term1:+term2))))/(cols(term1)*rows(term1));
		  
		  
		  /*# % Choice of the bandwidth*/
		  h[1,t+1] = (std_approx_St :/ (sqrt(ratio) :* bias_approx_St)):^(1/(2+dimX*T/2));
		}
    
		 
		for (t=0; t<=T;t++){    
		  St = (S:==t);
		  if(t==T){
			out =  local_lin(St, X,h[,t+1]);
			ES_T = (*out[1])
			f= (*out[2])
		  }else{
			out = local_lin(St,  X,h[,t+1]);
			ES_T =  (*out[1])
		  }
		  PSt_X[,t+1] = -pmax(-1,-pmax(0,ES_T));
		}
		
		
		   /*### case PSt_X==0*/
        temp0 = rowsum(abs(PSt_X))
        totreat = (1..rows(PSt_X))[selectindex(temp0:==0)]

        if(length(totreat)>0){

          for(i0=1;i0<=length(totreat);i0++){
            i1 = totreat[i0]
            values =J(n, 1,0)
            for(k=1;k<=dimX;k++){
			 X0 = J(n,T,.)
			 for(t=1;t<=T;t++){
			 	X0[,t] = (*X[t,1])[,k]
			 }	
				
              values =  values :+ rowsum((X0:-J(n,1,1)*X0[i1,]):^2)
            }

            nonzero = (values,!(temp0:==0), (1..rows(PSt_X))')
            nonzero0 = nonzero [selectindex(nonzero[,2]:==1),]
			kk = minindex(nonzero0 [,1],1, v0=., .)
            ref = nonzero0 [v0,]
            i00 = ref[3]

            PSt_X[i1,] = PSt_X[i00,]
          }
        }

        PSt_X = PSt_X :/ (rowsum(PSt_X)*J(1,cols(PSt_X),1));
		
		T_minus_t = J(n,1,1)*(T :- range(0,T,1))'
		
		
       
        /*  # deriv_gamma_all = vector("list")
        # version ="new"
        # s=1
        # if(version == "new"){
        # # % Computation of the bounds and Pr(Ihat(m_i)=I(m_i))*/
		out =  Delta_bounds(b_hat, V, S, dimX, PSt_X, f, h, (*mat_C_k_T[T,1]), RK, T_minus_t,Tall0,X)
		boundsall[count,1] = &(*out[1])
		bounds = (*out[1])
		bounds_ind = (*out[2])
		c_hat = (*out[3])
		
		  /*# % Computation of the influence function*/
		Z_EZX = (S*J(1,T+1,1)):==(J(rows(S),1,1)*(0..T)) :-  PSt_X;	


		hderiv=0.001 
		for(k=1;k<=dimX;k++){
			
			deriv_beta =J(dimX,2,0);
			for (i=1;i<=dimX;i++){
				out = Delta_bounds(b_hat:+hderiv*((1..dimX):==i),V, S, dimX, PSt_X, f, h, (*mat_C_k_T[T,1]), RK, T_minus_t,Tall0,X);
				for_deriv_b= (*out[1])
				deriv_beta[i,] = (for_deriv_b[k,] :- bounds[k,]):/hderiv;
			}
		  
			deriv_gamma = J(T+1,2,0);
			
			for (t=0;t<=T;t++){
				out = Delta_bounds(b_hat, V, S, dimX, PSt_X:+hderiv:*(J(n,1,1)*((0..T):==t)), f, h, (*mat_C_k_T[T,1]), RK, T_minus_t,Tall0,X)
				for_deriv_g =(*out[1])
				deriv_gamma[t+1,] = (for_deriv_g[k,] :- bounds[k,]):/hderiv;
			} 
      
		  (*infl[k,1])[selecti ,]  = (bounds_ind :+ phi* deriv_beta :+ Z_EZX * deriv_gamma);
		  /*infl[[k]][selecti ,] =  bounds_ind[,k] + phi %*% deriv_beta + Z_EZX %*% deriv_gamma*/
     
		
		} 
        count=count+1
      }   /*### end of T_i loop*/
    }

    count=1
    Delta_hat= J(nb_var,2,0)
    for(ci=1;ci<=nb_clust;ci++){
      for(ti=1;ti<=length(grid_T1);ti++){
	  	T = grid_T1[ti]
		cival = civals[ci]
        selecti = selectindex(Tinf:==T  :& Call1:==cival :& (Tall:!=.))
        Delta_hat=  Delta_hat :+ (*boundsall[count,1])[selectX,]:*length(selecti):/n_s
        count=count+1
      }
    }

    for_average = J(2,1,NULL)
    count=1
    Delta_hat0= J(nb_var,2,0)
    for(ci=1;ci<=nb_clust;ci++){
      for(ti=1;ti<=length(grid_T1);ti++){
	  	T = grid_T1[ti]
		cival = civals[ci]
        selecti = selectindex(Tinf:==T  :& Call1:==cival :& (Tall:!=.))
        Delta_hat0=  Delta_hat0 :+ (*boundsall[count,1])[selectX,]:*length(selecti):/(n_s*T)
        count=count+1
      }
    }
    for_average[1,1] = &Delta_hat0

    length_CI= J(1, nb_var, .)
    et=J(dimX,2, .)
    for(k=1;k<=length(selectX);k++){
      /*et[k,] =apply(infl[[k]][!is.na(Tall),],2,std)/sqrt(n_s);*/
	  et[k,] = diagonal(sqrt(variance((*infl[k,])[selectindex(Tall:!=.),])))':/sqrt(n_s)
    }
	
	/*et=matrix(et[selectX,], nb_var,2)*/
    bias_sup = J(2,1,0)

    CI = J(nb_var,2,.)
	/*length_CI[,s] = bounds[2] :+et[2,s] :- bounds[1] :+et[1,s]
	Delta_hat[,s]= bounds'
		bias_sup[,s] = J(dimX,1,0)	
	*/
   /* ## compute CI at level alpha.
    # k=1*/
    for(k=1;k<=nb_var;k++){
      quant = quantile_IM(alpha, Delta_hat[k,], et[k,]);
      phi_alpha = sqrt(n_s)*abs(b_hat[k])/sqrt(variance((*infl[k,])))[1,1] > invnormal(1-alpha/2)
      if(phi_alpha){
        CI[k,] = (Delta_hat[k,1] :- quant* et[k,1], Delta_hat[k,2] :+ quant*et[k,2])
      }else{
        CI[k,] = (min(0,Delta_hat[k,1] - quant* et[k,1]), max(0,Delta_hat[k,2] + quant*et[k,2]));
      }

      phi_alpha_m[k,1] = &phi_alpha
      length_CI[k] = CI[k,2] - CI[k,1]

    }

    std_b = diagonal(sqrt(variance(phi_b))):/sqrt(rows(phi_b))
   /*# CI = cbind(bounds[,1] - quant* std_bounds[,1], bounds[,2] + quant*std_bounds[,2]);*/

  }

  out = J(14,1,NULL)
  out[1,1] = &Option
  out[2,1] = &n_s
  out[3,1] = &grid_T1
  out[4,1] = &Delta_hat
  out[5,1] = &length_CI
  out[6,1] = &et
  out[7,1] = &bias_sup
  out[8,1] = &CI
 out[9,1] = &phi_alpha_m
  out[10,1] = &b_hat
  out[11,1] = &std_b
  out[12,1] = &infl
	out[13,1] =  &for_average
	if(Option!="quick"){
	out[14,1] =  &c_hat
	}
  /*names(out) <- c("Option","n","Tmax","Delta_hat","length_CI","et","bias_sup","CI","phi_alpha","b_hat","std_b","influence","for_average","c_hat")*/

  return(out)
}
end 


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// local_lin : /*# % Estimates E(Y|X) at the points X by local linear regression
///// with bandwidth h and the Epanechnikov kernel.
///// Second output f: Kernel estimator of the density
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



cap mata mata drop local_lin()
mata: 
pointer matrix function local_lin(real matrix Y1,pointer matrix  X, real scalar  h1){
  
  n =rows(Y1)
  res=J(n,1,0);
  
  X1 = J(n,1,1)
  for(k=1;k<=rows(X);k++){
      X1 = (X1,(*X[k]))
   }
  Xbb = X1[,2..cols(X1)]

  p = cols(X1)
  
  f = J(n,1,0); 
  denom_f = n*(sqrt(2*pi())*h1)^p; 
  
  for (i=1;i<=n;i++){
    x = Xbb[i,];
    bx = J(rows(Xbb),1,1)*x :- Xbb
    w = myrowproduct(exp(-0.5:*(bx:/h1):^2));
    
	bx = (J(n,1,1),bx)
    f[i]=sum(w):/denom_f;
    
    numer = (X1')*(w:*Y1);
    denom = (X1')* (X1:*(w*J(1,cols(X1),1)));
    b =  svsolve(denom,numer)
    res[i,1] = b[1,1];
  }


out = J(2,1,NULL)
out[1,1] = &res 
out[2,1] = &f
return(out)
}
end 


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////estim_intercept : We estimate the intercept of a Logit model of Y on X_T with the
/////beta estimated by conditional logit
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


cap mata mata drop estim_intercept()
mata: 
real scalar function estim_intercept(real matrix Y,real matrix Xbeta){
  
tol=1e-4
pas = 1
PY = mean(mean(Y)');
res = log(PY/(1-PY)) - mean(mean(Xbeta)')
iter=1;

while ((pas > tol) & (iter < 50)){
  prev = res ;
  res = prev - (mean(mean(Lambda(prev:+Xbeta))') - PY)/mean(mean(Lambda_prime(prev:+Xbeta))');
  pas = abs(res-prev);
  iter=iter+1;
}

return(res)
}
end 



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// pmax: Returning the row maximum between ref and m00
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


cap mata mata drop pmax()
mata: 
/* Returning the row maximum between ref and m00 */
real matrix function pmax (real scalar ref , real matrix m00){
	
	d = rows(m00)
	out = J(d,1,0)
	for (i=1;i<=d;i++){
		out[i,1] = max((ref \ m00[i,1]))
	}
	return(out)
}
end 


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// omega : Evaluate the function Omega in DDL (see Section 4.1), with v the vector of v_t for t less than T0
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


cap mata mata drop omega()
mata: 
real matrix function omega(real matrix u,real matrix v,real scalar T){
  aux = u:*(v[1]-1) :+ 1
  if(T>2){
    for (t=2;t<=(T-1);t++){
      aux = aux:*(u:*(v[t]-1):+1)
    }
  }
  aux = u:*(1:-u):*aux:/(u:*(v[T]-1):+1)
  return(aux)
}
end 


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// principal_rep: Computation of the principal representations corresponding to m0=(E(x).. % E(x^k)) 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

cap mata mata drop principal_rep()
/*# % 
# principal_rep(m0)
# m0= matrix(c( 0.4673575, 0.2852945,0.2042084,0.231))*/
mata: 
real matrix function principal_rep(real matrix m0){

 /* # % res includes first the number of support points of the lower, then the 
  # % support points of the lower principal rep., then the corresponding 
  # % probabilities, then the support points of the upper principal rep. and 
  # % finally the corresponding probabilities.*/
  
  K = rows(m0);
  L= floor((K+1)/2);
  
  if(K==1){

    res = (1,m0,1,0,1,1-m0,m0)'

  }else{
  
    if (L == K/2){
     /* #% Cas pair*/
      m0_1 = m0[1..L];
      m0_2 =  m0[(L+1)..(2*L)];
      Mat_mom_l = hankel(m0_1,m0[L..(2*L-1)]);
      if(K==2){
        Mat_mom_u = 1 :- Mat_mom_l ;
      }else{
        m0_0 = (1,m0[1..(L-1)])'
        Mat_mom_u = hankel(m0_0,m0[(L-1)..(2*L-2)]) :- Mat_mom_l 
      } 
      for_poly_orth_l = lusolve( -Mat_mom_l,m0_2)  ;
      coeff_poly_ort_l = (1, revorder(for_poly_orth_l)'); 
      /*# Points de supports de la représentation principale inférieure*/
      x_lower = sort((0, Re(polyroots(revorder(coeff_poly_ort_l))))',1);

      for_poly_orth_u = lusolve(-Mat_mom_u, (m0[L..(2*L-1)]:-m0_2)) ;
      coeff_poly_ort_u = (1, revorder(for_poly_orth_u'));
      /*#% Points de supports de la représentation principale supérieure*/
      x_upper = sort((Re(polyroots(revorder(coeff_poly_ort_u))),1)',1);
      vandermonde_l =   (J(L+1,1,1)*(x_lower')) :^ (range(0,L,1)*J(1,L+1,1))
	  
      /*#% Probas associées à x_lower*/
      proba_lower =  lusolve( vandermonde_l,(1,m0_1')');

      vandermonde_u = (J(L+1,1,1)*(x_upper')) :^ (range(0,L,1)*J(1,L+1,1)) 
      /*#% Probas associées à x_upper*/
      proba_upper = lusolve( vandermonde_u ,(1,m0_1')');

    }else{
 /* #% Cas impair*/

    m0_1_l = (1,m0[1..L-1])'
    m0_11_u = m0[1..L-1]
    m0_12_u = m0[2..L]
    m0_2_l =  m0[(L-1)..(2*L-2)]
    m0_21_u =  m0[(L-1)..(2*L-3)]
    m0_22_u =  m0[L..(2*L-2)]
    Mat_mom_l = hankel(m0_1_l,m0_2_l)
    Mat_mom_u = hankel(m0_11_u,m0_21_u):- hankel(m0_12_u,m0_22_u)
    
    for_poly_orth_l =lusolve( - Mat_mom_l ,m0[L..(2*L-1)]) 
    coeff_poly_ort_l = (1, revorder(for_poly_orth_l'));
    x_lower = sort(Re(polyroots(revorder(coeff_poly_ort_l)))',1)

    for_poly_orth_u = lusolve( - Mat_mom_u ,m0_22_u-m0[(L+1)..(2*L-1)])
    coeff_poly_ort_u = (1,revorder(for_poly_orth_u)');
    x_upper = sort((0,Re(polyroots(revorder(coeff_poly_ort_u))),1)',1);
    
    vandermonde_l = (J(L,1,1)*(x_lower')) :^ (range(0,(L-1),1)*J(1,L,1))
    proba_lower =  lusolve(vandermonde_l , m0_1_l)
     
    vandermonde_u = (J(L+1,1,1)*(x_upper')) :^ (range(0,L,1)*J(1,L+1,1)) 
    proba_upper =  lusolve(vandermonde_u ,(1,m0[1..L]')')

    }

    res =(rows(x_lower),x_lower',proba_lower',x_upper',proba_upper')'
  }

return(Re(res))  
}
end 






////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// adjoint1: generate the function omega in the theory, with v the vector of v_t for t
/////less than T
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

cap mata mata drop adjoint1()
mata:
real matrix function adjoint1(real matrix A){
	return(det(A):*luinv(A))
} 
end 


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// hankel: 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

cap mata mata drop hankel()
mata: 
real matrix function hankel(real matrix a, real matrix b){
    n = rows(a)
    /*if (missing(b)) 
        b <- c(a[n], rep(0, n - 1))*/
    m = rows(b)
    H = J( n, m,0)
	
    for (i=2;i<=(m+n);i++){
		for (j1=1;j1<=n;j1++){
				for (j2=1;j2<=m;j2++){
					if(j1+j2 ==i){
						if (i <=  n + 1){
							H[j1,j2]= a[i - 1,1]
							}else{ 
							H[j1,j2]= b[i - n,1]
							}
					}
			 }
		}
	}
	return(H)
}
end 

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// hermipol: Function conding the Hermite polynomial of degree n
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

cap mata mata drop hermipol()
/* #Function evaluation on the nodes */
mata:
real matrix function hermipol(real scalar n){
  
  p= J(n+1,n+1,0)
  p[1,1]=1
  p[2,(1,2)]=(2,0)
  
  for(k=2;k<=n;k++){
    p[k+1,range(1,(k+1),1)]=2:*(p[k,range(1,k,1)], 0):-2:*(k-1):*(0,0,p[k-1,range(1,k-1,1)])
  }
  
  return(p)
}
end 

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////gausshermi : Returns weights and nodes of the Gauss-Hermite method*/
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

cap mata mata drop gausshermi()
mata:
pointer matrix function gausshermi(real scalar n, real scalar mu, real scalar sigma){

/*#Hermite polynomial*/
p=hermipol(n);
/*#Roots*/
racine= Re(polyroots(revorder(p[n+1,])))
/*#x=mu+sqrt(2)*sigma*roots(p(n+1,:));*/

w=J(n,1,1)
/*#Weights*/
for(i=1;i<=n;i++){
  w[i,1]=(2^(n-1)*(factorial(n)))/(n^2*(polyeval(revorder(p[n,range(1,n,1)]),racine[i]))^2)
}

x = mu:+sqrt(2):*sigma:*racine;

out = J(2,1,NULL)
out[1,1] = &w
out[2,1] = &x
return(out)
}
end 

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// conv: 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


cap mata mata drop conv()
mata: 
real matrix function conv(real matrix x, real matrix y) 
{
    n0 = cols(x) + cols(y) - 1
    res = invfft(fft(ftpad((x, J(1,n0-cols(x),0)))) :* fft(ftpad((y, J(1,n0-cols(y),0)))))
    res = Re(res)
    return(res[1,range(1,n0,1)])
}
end 


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// coeff_Cheb01: Computes the coefficient of T_k(2u-1), where T_k is the usual Chebyshev
///// polynomial of the 1st kind 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


cap mata mata drop coeff_Cheb01()
mata: 
real matrix function coeff_Cheb01(real scalar k){

  nodes = Re(polyroots(ChebyshevPoly(k)'))
  
  new_nodes = (nodes :+ 1) :/ 2;
  
  temp=J(k+1,1,0);
  
  for(i=0;i<=k;i++){
    if(i==0){
      temp[i+1,1]= 1
    }else{
	  M1 = combnk(new_nodes,i)'
	  temp[i+1,1]=(-1)^i * sum(mycolproduct(M1'));
      /*temp[i+1,1]=(-1)^i * sum(apply(t(combnk(new_nodes,i)), 1,prod));*/
    }
  }

  return(2^k * temp)
}
end 

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// choose: Compute C(n,k) with n and k scalars Allows for negative k or n<k (then returns 0)
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

cap mata mata drop choose()
/* Scalar version of the choose function */
mata: 
real scalar function choose(real scalar n, real scalar k){
	
  real scalar num 
  real scalar denom1
  real scalar denom2
  real scalar res 
  
  num = factorial(n)
  denom1 = factorial(abs(k))
  denom2 = factorial(abs(n-k))
  
  res = (num/(denom1*denom2))*(k<=n & k>=0)
  return(res)
}
end 


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////  chooseM:  Compute C(n,k) with n and k scalars Allows for negative k or n<k (then returns 0)
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


cap mata mata drop chooseM()
/* Matricial version of the choose function */
mata: 
real matrix function chooseM(real matrix A, real matrix B){
	
  real matrix res 
  
  res =J(rows(A),cols(A),0)
  
  for(i=1; i<=rows(A); i++){
      for(j=1; j<=cols(A); j++){
		res[i,j] = choose(A[i,j], B[i,j])
	} 
  }
  
  return(res)
}
end 


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// ChebyshevPoly : Given nonnegative integer n, compute the Chebyshev polynomial T_n.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

cap mata mata drop ChebyshevPoly()
/*# From ChebyshevPoly.m by David Terr, Raytheon, 5-10-04
# Given nonnegative integer n, compute the 
# Chebyshev polynomial T_n. Return the result as a column vector whose mth
# element is the coefficient of x^(n+1-m).
# polyval(ChebyshevPoly(n),x) evaluates T_n(x).*/
mata: 
real matrix function ChebyshevPoly(real scalar n){
   
  real scalar tk

  if( n==0){ 
    tk = 1
  }else if(n==1){
    tk = J(2,1,1) 
	tk[1,1] = 0 
  }else{ 
      
      tkm2 = J(n+1,1,0)
      tkm2[n+1,1] = 1
      tkm1 = J(n+1,1,0)
      tkm1[n,1] = 1
  
    for(k=2; k<=n; k++){
          
        tk = J(n+1,1,0)
  
        for(e= (n-k+1);e<=n;e=e+2){
              tk[e,1] = 2*tkm1[e+1,1] - tkm2[e,1]
        }
          
        if( mod(k,2)==0){
              tk[n+1,1] = (-1)^(k/2)
        }
          
        if(k<n){
            tkm2 = tkm1
            tkm1 = tk
        }
          
    }
      tk =revorder(tk)
  }
    return(tk)  
}
end 

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// Lambda_prime: derivative of Lambda for computation of the AME
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

cap mata mata drop Lambda_prime()
mata: 
real matrix function Lambda_prime( real matrix x){
	return(exp(x):/ (1:+ exp(x)):^2)
}
end 

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// Lambda: Lambda for computation of the AME
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


cap mata mata drop Lambda()
mata: 
real matrix function Lambda(real matrix x){

res = 1 :/ (1:+ exp(-x))
return(res)
}
end 


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// myrowproduct : compute product of the elements in rows
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

cap mata mata drop myrowproduct()
mata: 
real matrix myrowproduct(real matrix x)
{
	prod = x[,1]

	for(j = 2; j<=cols(x); j++) {
		prod = prod :* x[,j]
	}
	
   return(prod)
}
end 


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// mycolproduct : compute product of the elements in columns
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

cap mata mata drop mycolproduct()
mata: 
real matrix mycolproduct(real matrix x)
{
         return(myrowproduct(x')')
}
end 


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// put: 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

cap mata mata drop put()
mata:
function put(val,x,i,j,k)
{
/* Usage: value to put, matrix to put it in, i, j, k to put it at. */
(*(x[i,j]))[k,1]=val
}
end 


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// get: 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

cap mata mata drop get()
mata: 
function get(x,i,j,k)
{
/* Usage: matrix to get from, i, j, k of value to get. */
return((*(x[i,j]))[k,1])
}
end 





////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// combnk: 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

cap mata mata drop combnk()
mata:
real matrix function combnk(real matrix n, real scalar k){
    
		zerobased = 0
		ogte = 0
	
		len = cols(n)
    	lngt1 = len > 1
    	copyn = n
    	if (lngt1) {
       		n0 = len
    	}
        e = 0
        ncols = choose(n0, k)
        h = (k - ncols) == 1
        /* Matrix of pointers
		 out <- vector(mode = "list", length = ncols)*/
        out = J(k,ncols,0)
		/*for (j=1; j<=ncols; j++){
			out[j,1]=&J(k,1,0)
		}*/
	
		comb = range(1,k,1) :- zerobased
        comb[k,1] = comb[k,1] :- 1
        last = (n0 == k)
        i = 1
        while (comb[1,1] != (n0 - k + 1) || last) {
            last = 0 
            if (e < n0 - h) {
                h = 1
                e = comb[k,1] :+ zerobased
                comb[k,1] = comb[k,1] :+ 1
                if (comb[k,1] < ogte) {
                  comb[k,1] = ogte
                  e = ogte - 1
                }
            }
            else {
                e = comb[k - h] + zerobased
                h = h + 1
				under = J(1,h,0)
				for(j=1; j<=h;j++){
					under[1,j] = (e + j - zerobased < ogte)
					comb[k - h + j,1] = e + j - zerobased
				}
                
                /*for (j=1; j<=h;j++) {
                  under[j,1] <- (e + j - zerobased < ogte)
                  comb[k - h + j,1] <- e + j - zerobased
                }*/
				
                if (sum(under)==cols(under)) {
                  comb[k,1] = ogte
                  e = ogte - 1
                  h = 1
                }
            }
			/*(*(out[i,1]))[,1] = comb*/
			out[,i] = comb
            i = i + 1
        }
    

    if (lngt1) {
		resmat = J(k,ncols,0)
		for(j=1; j<=ncols;j++){
					 resmat[,j] = copyn[1,out[,j]]'
		} 
    }
    return(resmat)
}
end







////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// compute_ATE: Function which compute the ATE at different values of T according to the selected values of compute_T
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


cap mata mata drop compute_ATE()

mata: 

  
pointer matrix function compute_ATE(real matrix Yall,pointer matrix Xall, real matrix Call, string scalar Option, real matrix selectX, string matrix compute_T,
										real scalar alpha, string scalar CIOption, real matrix g_labels ,real matrix G_types, real matrix G_indic, 
										real scalar ratio){
  /* compute_T = NULL
   selectX = NULL
   alpha = 0.05
   CIOption = "CI2"
   nbCores = 4
  ## Compute the Tinf = min( Supp(T)) for all individuals*/
  Tinf =  J(rows(Yall),1,.)
  for(i=1;i<=rows(Yall);i++){
    Tinf[i,1] = isnot(Yall[i,])
   } 
  
   /*## Max of the Tinf in dataset*/
  Tmax = max(Tinf)

   /*## Get the dimension of X*/
   dimX=cols((*Xall[1,1]))
 
  /*### find the distibution of Tinf in the population and sample size*/
  count1 = 0
  for(t=1;t<=Tmax;t++){
    if(sum(Tinf:==t)>0){
		count1 = count1 +1
    }
  }
  
  
  grid_T = J(1,count1,.)
  n_dist = J(1,count1,.)
  count10 = 0
  for(t=1;t<=Tmax;t++){
    if(sum(Tinf:==t)>0){
	  count10 =count10 +1
      grid_T[1,count10] = t
      n_dist[1,count10] = sum(Tinf:==t)
    }
  }
  

  prop_T = n_dist/sum(n_dist)

   /*## number of clusters*/
  if(Call==NULL){
    Call1 = J(1, rows(Yall),1)
  }else{
    Call1 =  Call
  }

  /*## compute combinatorial numbers at all possible dates in the dataset.*/  
  mat_C_k_T=  J(Tmax,1,NULL)
  cheb_coeff= J(Tmax,1,NULL)
  for(t= 1; t<=length(grid_T);t++){
  	  T0 = grid_T[t]
	  M1 =  range(0, T0, 1)*J(1,T0+1,1)-J(1,T0+1,1)'*range(0, T0, 1)'
	  M11 = J(1,T0+1,T0) - range(0,T0,1)'
	  mat_C_k_T[T0,1] = &chooseM(J(T0+1,1,1)*M11,M1)
	  cheb_coeff[T0,1]  = &revorder(coeff_Cheb01(T0+1)')
  }

   /*## consider linear regression est. /4 as starting point*/
  Olin = optimize_init()
  optimize_init_evaluator(Olin, &myeval_lin())
  optimize_init_evaluatortype(Olin, "d0") 
  optimize_init_argument(Olin, 1, Yall)
  optimize_init_argument(Olin, 2, Xall)
  optimize_init_params(Olin, J(1,dimX,0)) 
  optimize_init_verbose(Olin, 0)
  optimize_init_tracelevel(Olin, "none")
  b_lin = optimize(Olin)
  start_point = b_lin/4

   /*### estimate loglikelihood.
  # ** insert catching errors ex: delete constant variables, ect..*/
  O = optimize_init()
  optimize_init_evaluator(O, &myeval4())
  optimize_init_evaluatortype(O, "d0") 
  optimize_init_argument(O, 1, Yall)
  optimize_init_argument(O, 2, Xall)
  optimize_init_params(O, start_point) 
  optimize_init_verbose(O, 0)
  optimize_init_tracelevel(O, "none")
  b_hat = optimize(O)

  /*# Compute the influence function of beta_hat. Useful for inference on
  # Delta, at the end*/
  
  phi_b = infl_func_beta(b_hat,Yall, Xall, Call1);
  std_b = sqrt(diagonal(variance(phi_b)))/sqrt(rows(phi_b))

  

   /* append_name <- function(x){return(paste0("T_",x))}*/
   /*### compute only at last period*/
  if(compute_T[1,1] =="" ){
    Tall = Tinf
	output =J(1,1,NULL)
    res =  compute_ATE_t(Yall,Xall, prop_T, grid_T,n_dist,Tmax,Tall,Tinf,Call1,mat_C_k_T,
                                            cheb_coeff,b_hat,alpha, CIOption ,Option,dimX,  selectX, phi_b, std_b) 
   output[1,1] = &res
											
    /*names(  output) <- c("Tinf")*/
  }else if( compute_T[1,1] !="" & compute_T[1,1] !="all"){
     /*## compute for selected periods
    # t0=1
    # compute_T= c(2,3)*/
	
	output =J(length(compute_T),1,NULL)
	
    for(t0 =1; t0<=length(compute_T);t0++){
      t_end = strtoreal(compute_T[t0])
       /*## Tall is the T at which the effect is computed, which is different according to the label g (if T is in the list of observed periods)
      # , g_labels  , G_types, G_indic)

      # find types containing t_end*/
      if(G_types[1,1] !=.){
        sel_g = G_types[,t_end]:==1
       /*  # discard observations if T not in periods.*/
        Tall = J(rows(g_labels),1,.)
        for(g=1;g<=length( sel_g);g++){
          if(sel_g[g]){
		  	indexes = selectindex(g_labels:==g)
            Tall[indexes,1]=J(sum(g_labels:==g),1,t_end)
          }
        }
      }else{
        Tall = - pmax(-t_end,-Tinf)
        /* # discard observations if T < t_end*/
		indexes0 = selectindex(Tall :< t_end)
		if(length(indexes0)>0){
			Tall[indexes0] = J(sum(Tall :< t_end),1,.)
		}
      }
       /*# cbind( Tall,dataX[,,1])*/
      grid_T0 = 0
      n_dist0 = 0
      for(t= 1; t<=Tmax; t++){
	  	indexes1 = selectindex(Tall:!=.)
        if(sum(Tinf[indexes1]:==t)>0){
          grid_T0 = (grid_T0 , t)
          n_dist0 = (n_dist0,sum(Tinf[indexes1]:==t))
        }
      }
	  grid_T0 = grid_T0[2..length(grid_T0)]
	  n_dist0 =  n_dist0[2..length(n_dist0)]
      prop_T0 = n_dist0:/sum(n_dist0)

      /* # Tall = pmin(t_end,Tinf)
      # discard observations if T < t_end
      # Tall[Tall < t_end] <- NA*/

     /*  # grid_T0 = grid_T =3
      # grid_T0[grid_T0>t_end] = t_end*/
      output[t0,1] = &compute_ATE_t(Yall,Xall, prop_T0,grid_T0,n_dist0,Tmax,Tall,Tinf,Call1,mat_C_k_T,
                                              cheb_coeff,b_hat,alpha, CIOption ,Option,dimX,  selectX , phi_b, std_b )
									  
    }
  
    /*names(  output) <- apply(matrix(compute_T,length(compute_T),1),1,append_name )*/
  }else{
    /* ## compute for all periods
	G_types = J(1,1,.)
	*/
    
	output= J(Tmax+1,1,NULL)
    for(t_end=1;t_end<=Tmax;t_end++){
     /*  # find types containing t_end*/
      if(G_types[1,1] !=.){
        sel_g = G_types[,t_end]:==1
       /*  # discard observations if T not in periods.*/
        Tall = J(rows(g_labels),1,.)
        for(g =1; g<=length( sel_g);g++){
          if(sel_g[g]){
            indexes = selectindex(g_labels:==g)
            Tall[indexes,1]=J(sum(g_labels:==g),1,t_end)
          }
        }
      }else{
         Tall = -pmax(-t_end,-Tinf)
        /* # discard observations if T < t_end*/
		indexes0 = selectindex(Tall :< t_end)
		if(length(indexes0)>0){
			Tall[indexes0] = J(sum(Tall :< t_end),1,.)
		}
      }

      
       /*# cbind( Tall,dataX[,,1])*/
      grid_T0 = 0
      n_dist0 = 0
      for(t= 1; t<=Tmax; t++){
	  	indexes1 = selectindex(Tall:!=.)
        if(sum(Tinf[indexes1]:==t)>0){
          grid_T0 = (grid_T0 , t)
          n_dist0 = (n_dist0,sum(Tinf[indexes1]:==t))
        }
      }
	  grid_T0 = grid_T0[2..length(grid_T0)]
	  n_dist0 =  n_dist0[2..length(n_dist0)]
      prop_T0 = n_dist0:/sum(n_dist0)
	  
       output[t_end,1] = &compute_ATE_t(Yall,Xall, prop_T0, grid_T0,n_dist0,Tmax,Tall,Tinf,Call1,mat_C_k_T,
                                                 cheb_coeff,b_hat,alpha, CIOption ,Option,dimX,  selectX, phi_b, std_b)
										

    }

    /* ### add computation of average.*/

	attri = G_types[1,1] !=.
	/*if(attri ==0){
		G_types = J(0,2,2)
		g_labels = J(0,2,2)
	}*/
	output[Tmax+1,1] = &compute_average_ATE(output,Option,Tinf,dimX,selectX,CIOption,alpha, attri , g_labels, G_types)

    /* names(  output) <- c(apply(matrix(1:Tmax,length(1:Tmax),1),1,append_name ),"average")*/
   /*  ## add name average*/
  }

  return( output)
}



end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// Delta_bounds: This function computes what corresponds to the function under(over)lined h in Section 3.2.2 in DDL
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

 cap mata mata drop Delta_bounds()

mata:
pointer matrix function Delta_bounds(real matrix beta1, real matrix V, real matrix S, real scalar dimX, real matrix PSt_X,
	real matrix f, real matrix h, real matrix mat_C_k_T0, real scalar RK, real matrix T_minus_t, 
	real matrix Tall0, pointer matrix X){

/* # ! modif dim(X) > 1  */
n = rows(V)
T = cols(V)

grid0 = sort(uniqrows(Tall0),1)
VT = J(rows(Tall0),1, 1)
for(ti0=1;ti0<=length(grid0);ti0++){
  ti = grid0[ti0]
  VT[selectindex(Tall0:==ti),1] = V[selectindex(Tall0:==ti),ti]
}

Vtilde = V:/(VT*J(1,cols(V),1));
Vtilde_min1 = (Vtilde :- J(rows(Vtilde),cols(Vtilde),1), -J(n,1,1))

Mat_lambda=J(n,T+1,0);

for (t=1;t<=T;t++){
  res = C_S_fun(t-1,Vtilde_min1)
  if(rows(res)==1){
  	Mat_lambda[,t+1]=J(n,1,res);
	}else{
	Mat_lambda[,t+1]=res;
  } 
}

lambda_T_plus1 =- myrowproduct(Vtilde_min1[,1..(cols(Vtilde_min1)-2)])';

C_S_vec = C_S_fun(S,Vtilde);
S_minus_t = S*J(1,T+1,1) -  J(rows(S),1,1)*(0..T);
mat_combin = chooseM(T_minus_t,S_minus_t):/(C_S_vec*J(1,T+1,1));

Mat_fin = Mat_lambda:*mat_combin;
moy_fin = (T+1):* sum(Mat_fin)/(rows(Mat_fin)*cols(Mat_fin));

term1 = beta1 * moy_fin;

C_mat = J(n,T+1,0);
for (t=0;t<=T;t++){
  res =  C_S_fun(t,Vtilde)
  if(rows(res)==1){
  	C_mat[,t+1] =J(n,1,res);
	}else{
  C_mat[,t+1] = res
	}
}

mat_ratio = PSt_X:/ C_mat;

c_hat = mat_ratio* mat_C_k_T0;
c0 = c_hat[,1];
m_hat = c_hat[,2..cols(c_hat)]:/(c0*J(1,cols(c_hat)-1,1))

bounds_ind = J(n,2,0);

for (i= 1;i<=n;i++){
    /*# % Truncation of m_hat. We also set indic=0 if m_hat was truncated,
    # % indic=1 if the last component of m_hat was above the upper bound,
    # % indic=-1 if it was below the lower bound.
    # % First, we estimate the asymptotic variance of mhat(x)=> Sigma_m*/
    mi = m_hat[i,]
    H_x = (-mi', I(T))/c0[i];
    M_x = mat_C_k_T0':/(J(cols(mat_C_k_T0),1,1)*C_mat[i,]);
    bbx = diag(PSt_X[i,])- (PSt_X[i,]')*PSt_X[i,]
    Sigma_x = (RK^(dimX*T):/f[i]):* (bbx  :/ (((n:*h)')*J(1,cols(h),1)));
    
    Sigma_m = H_x*M_x*Sigma_x*(M_x')*(H_x');
    
    out = trunc_m(mi', Sigma_m, n);
    mi = (*out[1])
    indic = (*out[2])

    qinf_sup = bound_mom(mi',T,indic);
    
    term2 = c0[i] :* lambda_T_plus1[i] :*(qinf_sup');
    
    bounds_ind[i,1] = min(term2);
    bounds_ind[i,2] = max(term2);

}

bounds = term1' :+  (beta1') *mean(bounds_ind,2);

out = J(3,1,NULL)
out[1]= &bounds
out[2]= &bounds_ind
out[3]= &c_hat
return(out)
}

end





////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// compute_average_ATE: Compute the average of the average treatment effects over all the periods between 1 and Tinf.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


cap mata mata drop compute_average_ATE()

mata: 

pointer matrix function compute_average_ATE(pointer matrix output,string scalar Option,real matrix Tinf,
											real scalar dimX,real scalar selectX,string scalar CIOption, real scalar alpha, real scalar attri, real matrix g_labels, real matrix G_types){

  /*## find length of output.*/
  Tmax =  rows(output)-1
  n = rows(Tinf)

  nb_var = length(selectX)
  


    Delta_hat = J(1, dimX,0)
    bias_sup  = J(1, dimX,0)
    infl = J(n,dimX,0)

    for(t_end=1;t_end<=Tmax;t_end++){
      if(attri==1){
        
		
	    sel_g = G_types[,t_end]:==1
       /*  # discard observations if T not in periods.*/
        Tall = J(rows(g_labels),1,.)
        for(g =1; g<=length( sel_g);g++){
          if(sel_g[g]){
            indexes = selectindex(g_labels:==g)
            Tall[indexes,1]=J(sum(g_labels:==g),1,t_end)
          }
        }
		
      }else{
     Tall = -pmax(-t_end,-Tinf)
       /* # discard observations if T < t_end*/
	   indexes0=selectindex(Tall :< t_end)
	   if(length(indexes0)>0){
        Tall[ indexes0,] = J(sum(Tall :< t_end),1,.)
	   }
      }
    out_cur = (*output[t_end,1])
    /*for_average = out_cur$for_average
    # Compute average of all estimators at period t
    Delta_hat =  Delta_hat + for_average[[1]]*/
	for_average = (*out_cur[13,1])
	Delta_hat =  Delta_hat :+ (*for_average[1,1])
	
    /*# Compute average of associated biases
    bias_sup   = bias_sup + for_average[[2]] # + out_cur$bias_sup*/
	bias_sup   = bias_sup :+ (*for_average[2,1])
	
    /*# Compute average of influence functions
    # infl[Tinf>=t_end ,] = infl[Tinf>=t_end ,]  + out_cur$influence
    infl[!is.na(Tall),] = infl[!is.na(Tall) ,]  + out_cur$influence*/
		influence=(*out_cur[12,1])
		infl[selectindex(Tall:!=.),] = infl[selectindex(Tall:!=.),]  :+ influence
	   
    }

    infl = infl:/(Tinf*J(1,dimX,1))
    /*### Apply the IC construction method*/

    et = J(1,dimX, 0)
	et =et :+ diagonal(sqrt(variance(infl)))';

    et =et:/sqrt(rows(infl))
    et = et[,selectX]
    eps_n = (2*log(log(n)))^(1/2)/sqrt(rows(infl))

	if( CIOption == "CI3"){
      length_CI = 2 :* et :*  sqrt(invnchi2(1,  ncp = ((bias_sup[selectX] + eps_n):/et):^2,0.95))
    }else{
      length_CI = 2 :* et :*  sqrt(invnchi2(1,  ncp = (bias_sup[selectX] :/et):^2,0.95))
    }
    /*### compute CI*/

	CI = (Delta_hat[selectX])'*J(1,2,1)
    CI[,1] = CI[,1] :- length_CI'/2
    CI[,2] = CI[,2] :+  length_CI'/2



 out = J(13,1,NULL)
  out[1,1] = &Option
  out[2,1] = &n
  out[3,1] = &"average"
  /*out[4,1] = */
  out[4,1] = &Delta_hat
  out[5,1] = &length_CI
  out[6,1] = &et
  out[7,1] = &bias_sup
  out[8,1] = &CI
 /* out[10,1] = NA*/
  out[10,1] = &(*out_cur[10,1])
  out[11,1] = &(*out_cur[11,1])
  out[12,1] = &infl

  /*names(out) <- c("Option","n","Tmax","Time","Delta_hat","length_CI","et","bias_sup","CI","phi_alpha","b_hat","std_b", "influence")*/

 return(out)
}

end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////  compute_ATE_t : Function which compute the ATE at a specified value of T contained in Tall.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


cap mata mata drop compute_ATE_t()

mata:
pointer matrix function compute_ATE_t(real matrix Yall, pointer matrix Xall,real matrix prop_T, real matrix grid_T,real matrix n_dist,
									real scalar Tmax,real matrix Tall,real matrix Tinf, real matrix Call1, pointer matrix mat_C_k_T, 
									pointer matrix cheb_coeff,real matrix b_hat,real scalar alpha , string scalar CIOption , string scalar Option,real scalar dimX, real matrix selectX, real matrix phi_b,
									real matrix std_b){

  /*### parameters for the sharp method.
  # ratio=10*/
  RK = 1/(2*sqrt(pi()));  /* #% int K^2(u)du*/
  kappa2 = 1; /* #% int u^2 K(u)du */

  /*c_hat = vector("list")*/

  /*### number of variables to compute the AME/ATE*/
  if(selectX[1,1]==.){
    nb_var = 1
    selectX = 1
  }else{
    nb_var = 1
  }

  /*### to stock the phi_alpha stat.*/
  phi_alpha_m= J(nb_var,1,NULL)
  grid_T0 = sort(uniqrows(Tall),1)
  grid_T0 = grid_T0[selectindex(grid_T0:!=.),]
  /*# dim(Xall)
  ## Estimation, either "quick" or "sharp"*/

	n_1 = sum(Tall:!=.)
	X = J(Tmax,1,NULL)
	for (j=1; j<=Tmax; j++){
	 	lab = (*Xall[j,]) 
		X[j,1]=&lab[selectindex(Tall:!=.),]
	}

	Y = Yall[selectindex(Tall:!=.),]
   
    Tall0 = Tall[selectindex(Tall:!=.),]
    Tinf0 = Tinf[selectindex(Tall:!=.),]
    Call10 = Call1[selectindex(Tall:!=.),]
    grid_T1 = grid_T[selectindex(grid_T :>=min( Tall0 ))]

	civals = uniqrows(Call10)
    /*# Tmax = max(grid_T1)
    # X = Xall
    # Y = Yall*/
    n = n_1
   /* # T <- dim(X)[2]
    ## stock the sample size*/
    n_s = n

	/*lab = (*X[1,]) 
    dimX = cols(&lab[selectindex(Tall:!=.),])*/
    
    S = rowsum(Y)
	
    XT =  J(n,dimX,.) 
    for (ti0=1; ti0<=length(grid_T0); ti0++){ 
		ti = grid_T0[ti0]
        if(sum(Tall0:==ti)>0){
		  lab = (*X[ti,]) 
          XT[selectindex(Tall0:==ti),] =  lab[selectindex(Tall0:==ti),]
        }
    }

	 	  
	Xtilde = J(dimX,1,NULL)
	for (j=1; j<=dimX; j++){
		Xtilde[j,1]=&J(n,Tmax,.)
	}
	
    for(j=1; j<=dimX; j++){
		Xtemp = J(n,Tmax,0)
		for(t=1;t<=Tmax;t++){
			Xtemp[,t] = (*(X[t,1]))[,j]
		}
		(*(Xtilde[j,1])) = Xtemp :- XT[,j]*J(1,Tmax,1)
     }  
	 
    index = J(n,Tmax,.)

    for (ti0=1; ti0<=length(grid_T1); ti0++){ 
		ti = grid_T1[ti0]
		for (t=1;t<=ti;t++){
		  lab = *(X[t,1])
          index[selectindex(Tinf0:==ti),t] = (lab[selectindex(Tinf0:==ti),])*b_hat'
        }
     }
    V = exp(index);

	
	YT =  J(n,1,.) 
    for (ti0=1; ti0<=length(grid_T0); ti0++){ 
		ti = grid_T0[ti0]
        YT[selectindex(Tall0:==ti),] =  Y[selectindex(Tall0:==ti),ti]
    }

	/*### first term in ATE*/
    term1=sum(YT:*(2:*XT[,selectX]:-1)):/n

    /*# % Coefficients of the Chebyshev polynomial
    # temp = coeff_Cheb01(T+1)/2^(T+1);
    # b = -rev(temp[2:length(temp)]);*/
    b = J(n, Tmax+1,.)
    for(ti0=1;ti0<=length(grid_T);ti0++){
	  ti = 	grid_T[ti0]
      temp = -(*cheb_coeff[ti,1])[1..(ti+1)]:/(2^(ti+1))
      b[selectindex(Tinf0:==ti),1..(ti+1)] = J(sum(Tinf0:==ti),1,1)*temp
     /* # deriv_a[Tall==ti,1:(ti+1)] = deriv_lambda[Tall==ti,1:(ti+1)] - matrix(deriv_lambda[Tall==ti,(ti+2)])%*%;*/
    }

	
	XT0 = XT 
    XT0[selectindex(XT[,selectX]:==0),selectX ] = J(sum(XT[,selectX]:==0),1,1)
    XT0[selectindex(XT[,selectX]:==1),selectX ] =  J(sum(XT[,selectX]:==1),1,0)

    Vtilde =  V:/(exp(XT0*b_hat' )*J(1,cols(V),1))
    Vtilde_T =  V:/(exp(XT*b_hat')*J(1,cols(V),1))
	
	mat_binom = J(n,Tmax+1,.);
    lambda = J(n,Tmax+2,.);
    lambda[,1] = J(n,1,0)
    Vmodif = Vtilde  :- 1

     for(ti0 =1; ti0<= length(grid_T);ti0++){
	 	ti = grid_T[ti0]
		  for(t=0;t<=ti;t++){
			mat_binom[selectindex(Tinf0:==ti),t+1] = chooseM((ti-t):*J(sum(Tinf0:==ti),1,1),S[selectindex(Tinf0:==ti)]:-t)
			temp = C_S_fun(t,Vmodif[selectindex(Tinf0:==ti),1..ti])
			if(rows(temp)!=sum(Tinf0:==ti)){
				lambda[selectindex(Tinf0:==ti),t+2] = J(sum(Tinf0:==ti),1,temp)
			}else{
				lambda[selectindex(Tinf0:==ti),t+2] = temp
			}
			
		}
    }


    /*#### change for dimX >1*/
    f1 = J(n,Tmax+1,.);
    f2 = J(n,1,.);
    for(ti0 =1; ti0<= length(grid_T);ti0++){
	 ti = grid_T[ti0]
      f1[selectindex(Tinf0:==ti),1..(ti+1)] = lambda[selectindex(Tinf0:==ti),1..(ti+1)]:*(exp( b_hat[selectX]:*S[selectindex(Tinf0:==ti)]):*(1:-XT[selectindex(Tinf0:==ti),selectX]))*J(1,(ti+1),1)  :-
        exp(- b_hat[selectX]:*S[selectindex(Tinf0:==ti)]):*lambda[selectindex(Tinf0:==ti),1..(ti+1)]:*(XT[selectindex(Tinf0:==ti),selectX]*J(1,(ti+1),1))
      f2[selectindex(Tinf0:==ti),1] = exp( b_hat[selectX]:*S[selectindex(Tinf0:==ti)]):* lambda[selectindex(Tinf0:==ti),(ti+2)]:*(1:-XT[selectindex(Tinf0:==ti),selectX]) :-
        exp(- b_hat[selectX]:*S[selectindex(Tinf0:==ti)]):*lambda[selectindex(Tinf0:==ti),ti+2]:*XT[selectindex(Tinf0:==ti),selectX]
    }

    /*### matrix of coefficients d(x,s, b_hat)*/
    mat_a =  f1 :+ (f2*J(1,Tmax+1,1)) :* b;

	vect_C_S= J(n,1,.)
    for(ti0 =1; ti0<= length(grid_T1);ti0++){
	  ti = grid_T1[ti0]
      vect_C_S[selectindex(Tinf0:==ti),] = C_S_fun(S[selectindex(Tinf0:==ti),1],Vtilde_T[selectindex(Tinf0:==ti),1..ti]);
    }
	
   /* ### change for dimX > 1.*/
    Mat_fin = mat_a:*mat_binom:/(vect_C_S*J(1,cols(mat_a),1))
   /* # Mat_fin = mat_a*mat_binom*(exp(XT%*% b_hat*S)%*%rep(1,dim(mat_binom)[2]))/(vect_C_S%*%rep(1,dim(mat_a)[2]))*/
    term2 =sum(Mat_fin):/n;
    Delta_hat = term1:+term2;

	for_average = J(3,1,NULL)
	lab = sum(YT:*(2:*XT[,selectX]:-1):/Tinf0):/n:+ sum(Mat_fin:/(Tinf0*J(1,cols(mat_binom),1))):/n;
    for_average[1,1] = &lab

   /* # true_param
    ### for the computation of the bias of  ATE_tilde*/
    for_bias = exp(- b_hat[selectX]:*S):*abs(lambda[,Tall0]):*XT[,selectX]:+ exp( b_hat[selectX]:*S) :* abs(lambda[,Tall0]):* (1:-XT[,selectX])
    bias_sup = sum(mat_binom[,1]:*for_bias:/vect_C_S:/(2:*4:^Tinf0))/(cols(for_bias)*rows(for_bias))

	lab =sum(mat_binom[,1]:*for_bias:/vect_C_S:/(2:*(4:^Tinf0):*Tinf0))/(cols(for_bias)*rows(for_bias))
    for_average[2,1] =&lab
	term1 =  rowsum(Mat_fin) :+ YT:*(2:*XT:-1)
     
    mat_combin = J(n,max(grid_T1)+1,.)
    for(ti0 =1; ti0<= length(grid_T1);ti0++){
	  ti = grid_T1[ti0]
	  T_minus_t = J(sum(Tinf0:==ti),1,1)*(ti :- range(0,ti,1))'
	  S_minus_t =  S[selectindex(Tinf0:==ti),]*J(1,ti+1,1) :- J(sum(Tinf0:==ti),1,1)*range(0,ti,1)'  
      mat_combin[selectindex(Tinf0:==ti),1..(ti+1)]  = chooseM(T_minus_t,S_minus_t):/(vect_C_S[selectindex(Tinf0:==ti),]*J(1,ti+1,1))
    }
	
	term2 = J(n,1,0);
	
	Xtilde0 = J(dimX,1,NULL)
	for (j=1; j<=dimX; j++){
		Xtilde0[j,1]=&J(n,Tmax,.)
	}
			
	for(j=1; j<=dimX; j++){
		Xtemp = J(n,Tmax,0)
		for(t=1;t<=Tmax;t++){
			Xtemp[,t] = (*(X[t,1]))[,j]
		}
		(*(Xtilde0[j,1])) = Xtemp :- XT0[,j]*J(1,Tmax,1)
	}  
				
      
     for (k=1;k<=dimX;k++){
            deriv_C_S = J(n,1,0)
			Xtilde00 = (*Xtilde[k,1])
			
			for(ti0=1;ti0<=length(grid_T1);ti0++){
				ti = grid_T1[ti0]
				
				index = selectindex(Tinf0:==ti)
				Vtilde_T0 = Vtilde_T[index,(1..ti)]
				for(t=1;t<=ti;t++){
					Mt = Vtilde_T0[,selectindex((1..ti):!=t)] 
					deriv_C_S[index,] = deriv_C_S[index,]:+ Xtilde00[index,t]:*Vtilde_T[index,t]:*C_S_fun(S[index]:-1, Mt );				 
				 }
			
			  }
			
              
            deriv_e = J(n,Tmax+1,0)
			for(ti0=1;ti0<=length(grid_T1);ti0++){
				ti = grid_T1[ti0]
				if((ti+2) <= (Tmax+1)){
					deriv_e[selectindex(Tinf0:==ti),(ti+2)..(Tmax+1)] = J(sum(Tinf0:==ti),length((ti+2)..(Tmax+1)),.)
				}
			}
			

			Xtilde01= (*Xtilde0[k,1]) 
		
			for(ti0=1;ti0<=length(grid_T1);ti0++){
				ti = grid_T1[ti0]
				 Vmodif0 = Vmodif[,1..ti]
				index = selectindex(Tinf0:==ti)
				for(t=1;t<=ti;t++){
						for(u=1;u<=ti;u++){   
						
						  Vmodif00 =Vmodif0[index,1..ti ]
						  Mt = Vmodif00[,selectindex((1..ti):!=u)]
						  deriv_e[index,t+1] = deriv_e[index,t+1] :+ Xtilde01[index,u]:*Vtilde[index,u]:* C_S_fun(t-1, Mt);
						}		 
				}
			}
           
		   
	  
			deriv_lambda = J(n,Tmax+2,0);
			for(ti0=1;ti0<=length(grid_T1);ti0++){
				ti = grid_T1[ti0]
				index = selectindex(Tinf0:==ti)
				deriv_lambda[index,1] = J(sum(Tinf0:==ti),1,0)
				deriv_lambda[index,2..(ti+2)] = deriv_e[index,1..(ti+1)]
            }
			
			
		  if(k== selectX){

			f1 = J(n,Tmax+1,.)
			f2 = J(n,1,.)
			for(ti0=1;ti0<=length(grid_T);ti0++){
				ti = grid_T[ti0]
				index = selectindex(Tall0:==ti)	
			  /*# Derivative of the coeff a_t wrt beta*/
			  f1[index,1..(ti+1)]= ((exp( b_hat[selectX]:*S[index,]):*(1:-XT[index,selectX]))*J(1,(ti+1),1)):*(deriv_lambda[index,1..(ti+1)] :+
													(S[index,]*J(1,(ti+1),1)):*lambda[index,1..(ti+1)]) :-
				((exp(- b_hat[selectX]:*S[index,]):*XT[index,selectX])*J(1,(ti+1),1)):*(deriv_lambda[index,1..(ti+1)] :-
												(S[index,]*J(1,(ti+1),1)):*lambda[index,1..(ti+1)])
			 /* # f1p = lambda[,1:(T+1)]*(S*(exp( b_hat*S)*(1-XT))%*%rep(1,(T+1)))
			  # f2 = deriv_lambda1[,1:(T+1)]*(XT%*%rep(1,(T+1)))*/
			  f2[index,1] = exp( b_hat[selectX]:*S[index,]):* (deriv_lambda[index,(ti+2)] :+ S[index,]:*lambda[index,(ti+2)]):*(1:-XT[index,selectX]) :-
				exp(- b_hat[selectX]:*S[index,]):*XT[index,selectX]:*(deriv_lambda[index,ti+2]:- S[index,]:*lambda[index,ti+2])
			}


		  }else{
		  	
			
			f1 = J(n,Tmax+1,.)
			f2 = J(n,1,.)
			for(ti0=1;ti0<=length(grid_T);ti0++){
				ti = grid_T[ti0]
				index = selectindex(Tall0:==ti)	
			  /*# Derivative of the coeff a_t wrt beta*/
			  f1[index,1..(ti+1)]= ((exp( b_hat[selectX]:*S[index,]):*(1:-XT[index,selectX]))*J(1,(ti+1),1)):*deriv_lambda[index,1..(ti+1)]  :-
				((exp(- b_hat[selectX]:*S[index]):*XT[index,selectX])*J(1,(ti+1),1)):*deriv_lambda[index,1..(ti+1)]

			  f2[index,1] = exp( b_hat[selectX]:*S[index,]):* (deriv_lambda[index,(ti+2)]):*(1:-XT[index,selectX]) :-
				exp(- b_hat[selectX]:*S[index]):*XT[index,selectX]:*(deriv_lambda[index,ti+2])
			}


		  }
		  
		  
		  
		  /*### matrix of coefficients d(x,s, b_hat)*/
		  deriv_a =  f1  :+ (f2*J(1,cols(b),1)) :* b;
		  /*# deriv_a = deriv_lambda[,1:(T+1)] - matrix(deriv_lambda[,(T+2)])%*%cheb_coeff[1:(T+1)]/(2^(T+1));*/

		  moy_deriv = sum(mat_combin:*(deriv_a :-  mat_a:* ((deriv_C_S:/vect_C_S)*J(1,cols(mat_a),1)))):/n;
		  term2 = term2 :+ moy_deriv:*phi_b[selectindex(Tall:!=.),k];
		  
    } /*## end of the for k loop*/


    infl =  Re(term1 :+ term2);


    nb_clust =length(uniqrows(Call10))
    et = J(1,1,0)
    for(ci=1;ci<=nb_clust;ci++){
      /*if(dimX==1){
        et =et + var(infl[Call10==ci ,])
      }else{*/
	    cival = civals[ci]
        et =et :+ diagonal(variance(infl[selectindex(Call10:==ci),selectX]))
    }

    et =sqrt(et):/sqrt(rows(infl))

	if(CIOption==""){
		CIOption0 = "CI2"
	}else{
		eps_n = strtoreal(CIOption)
		CIOption0 = "CI3"
		if(eps_n==0){
		 eps_n = (2*log(log(n)))^(1/2)/sqrt(rows(infl))
		}
	}
   

    if( CIOption0 == "CI3"){
      length_CI = 2 :* et :*  sqrt(invnchi2(1,  ncp = ((bias_sup :+ eps_n):/et):^2,0.95))
    }else{
      length_CI = 2 :* et :*  sqrt(invnchi2(1,  ncp = (bias_sup:/et):^2,0.95))
    }
    /*### compute CI*/

    CI =  Delta_hat*J(1,2,1)
    CI[,1] = CI[,1] :- length_CI/2
    CI[,2] = CI[,2] :+  length_CI/2


  out = J(14,1,NULL)
  out[1,1] = &Option
  out[2,1] = &n_s
  out[3,1] = &grid_T1
  out[4,1] = &Delta_hat
  out[5,1] = &length_CI
  out[6,1] = &et
  out[7,1] = &bias_sup
  out[8,1] = &CI
 out[9,1] = &phi_alpha_m
  out[10,1] = &b_hat
  out[11,1] = &std_b
  out[12,1] = &infl
 out[13,1] =  &for_average
 /* out[1,14] =  c_hat*/

  /*names(out) <- c("Option","n","Tmax","Delta_hat","length_CI","et","bias_sup","CI","phi_alpha","b_hat","std_b","influence","for_average","c_hat")*/

  return(out)
}

end




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///// mata_mfelogit: master function which launches the computations in mata, treating the input of the stata command mfelogit. 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


capture mata mata drop mata_mfelogit()
mata:

pointer matrix function mata_mfelogit(string scalar listY, string matrix listX, string matrix tall0, string matrix Option1, string matrix alpha01, string matrix eps1, string matrix cluster,string matrix computeT, string matrix computeX, string matrix ratio1, real matrix valid){

/*Tmax = st_data(.,"=Tmax")
dataY = st_data(.,"`deplist'")
dataX = J(Tmax,1,NULL)
for(j=1;j<=Tmax;j++){
	dataX[1,1] = &st_data(.,"age70")		
}*/

/*
alpha01 = alpha0
ratio1 = ratio
eps1 = eps
Option1 = Option
*/
	ratio = strtoreal(ratio1[1,1])
	Option = Option1[1,1]
	alpha0 = strtoreal(alpha01[1,1])
	CIOption = eps1[1,1]


	
    listX = listX[,selectindex(valid:==1)]
	dimX =  cols(listX)
	Tmax =  cols(tall0)

	
	if(computeX[1,1]==""){
		selectX = 1..dimX
	}else{
	   selectX = J(1,length(computeX),.)
       for(i=1;i<=length(computeX);i++){
		selectX[1,i]= strtoreal(computeX[i,1])
	   }
	}
	
	
	
	namesY = J(1,Tmax,"")
	for(j=1;j<=Tmax;j++){
		 namesY[1,j] =    listY + tall0[1,j]
	}
	dataY = st_data(., namesY)
	
	dataX = J(Tmax,1,NULL)
	for(j=1;j<=Tmax;j++){
		names = J(1,dimX,"")
		for(k=1;k<=dimX;k++){
		 names[1,k] =    listX[1,k] + tall0[1,j]
		}
		dataX[j,] = &st_data(.,names)		
	}

	
	/*Keep only if two periods observed  */
	/*nbmax =  Tmax*/
	  /*   ss <- as.data.frame(s0 %>% group_by("idcode") %>% sum("sumNA"))*/
	s0 = (dataY:!=.)
	for(j=1;j<=Tmax;j++){
		temp = J(rows(s0),1,1)
		for(k=1;k<=dimX;k++){
			temp = temp:*((*dataX[j,1])[,k]:!=.)
		}
		s0[,j] =  s0[,j]:*temp
	  }
	
	ss = rowsum(s0)


	/* ## nb of unobserved period  <= nbmax-2 => nb of observed periods >=2*/
	if(min(ss)>=2){
	   /*## no attrition*/
		sub_select = s0
		ndiscard = 0
	}else{
	   indic = ss:<2
	   sub_select =selectindex(indic:==0)
	   /*sub_discard = selectindex(indic:==1)*/
	   /*# report number of discarded individuals*/
	   ndiscard = length(ss[selectindex(indic)])
	}

	dataY = st_data( sub_select,namesY)

	dataX = J(Tmax,1,NULL)
	for(j=1;j<=Tmax;j++){
		names = J(1,dimX,"")
		for(k=1;k<=dimX;k++){
		 names[1,k] =    listX[1,k] + tall0[1,j]
		}
		dataX[j,] = &st_data(sub_select,names)		
	}
		
	/* pattern of attrition */  
	G_all = (dataY:!=.)
	for(j=1;j<=Tmax;j++){
		for(k=1;k<=dimX;k++){
			G_all[,j] =  G_all[,j]:*((*dataX[j,1])[,k]:!=.)
		}
	}

	G_types = uniqrows(G_all)
	g_labels = J(rows(G_all),1,.)

	for(g=1;g<=rows(G_types);g++){
		index = rowsum(G_all:==(J(rows(G_all),1,1)*G_types[g,])) :== cols(G_all)
		g_labels [selectindex(index),] = J(sum(index),1,g)
	}


	Tmax = max(rowsum(G_types))

	/*### transform data according to the type of attrition.*/
	Xall = J(Tmax,1,NULL)
	for(j=1;j<=rows(Xall);j++){
			Xall[j,1]= &J(rows(*dataX[j,1]),dimX,.)  
	}
	Yall = J(rows(dataY),Tmax,.)

	for(g=1;g<=rows(G_types);g++){
		  tinf= sum( G_types[g,]:==1)
		  for(j=1;j<=tinf;j++){
			(*Xall[j,1])[selectindex(g_labels:==g),] = (*dataX[selectindex(G_types[g,]:==1)[j],1])[selectindex(g_labels:==g), ]      
		  }
	  
		  Yall [selectindex(g_labels:==g),1..tinf]   = dataY[selectindex(g_labels:==g), selectindex(G_types[g,]:==1)]
	}
	
	/* Cluster option */
	if(cluster[1,1]==""){
	   Call = J(rows(Yall),1,1)
	}else{ 
	   Call = st_data(sub_select, cluster[1,1] + tall0[1,1]) 
	   Call[selectindex(Call:==.),1] = J(sum(Call:==.),1,10000)
	}
	G_indic = G_types:*(J(rows(G_types),1,1)*(1..Tmax))

/*# G_types*(matrix(1,dim(G_types),1,1)%*%(1:Tmax))
  ## get the types of the variables*/
  Tinf =  J(rows(Yall),1,.)
  for(i=1;i<=rows(Yall);i++){
    Tinf[i,1] = isnot(Yall[i,])
   } 

  Tmax = max(Tinf)
  dimX = cols(*(Xall[1,1]))

  /*## default is continuous*/
  type_cont= J(1,dimX,1)
  for (i=1;i<=dimX;i++){
    if(length(uniqrows((*Xall[1,1])[,i]))==2){
      type_cont[i] = 0
    }
  }

  ref_c =  (1..dimX)[selectindex(type_cont:==1)]
  ref_b =  (1..dimX)[selectindex(type_cont:==0)]


   var_x_c = listX[ref_c]
   var_x_b = listX[ref_b]

  

 /* #### force to use quick method if at least one binary variable.*/

  if(sum(type_cont:==0)>0){
    Option = "quick"
    /*#### add warning message*/
  }


  
  if(sum(type_cont)>0){
    out_c = compute_AME(Yall,Xall, Call,  Option ,  ref_c, computeT, alpha0 , CIOption,  g_labels  , G_types, G_indic, ratio)
  }
 
  if(sum(type_cont:==0)>0){
	out_b = J(max(ref_b),1,NULL)
	for(i0=1;i0<=length(ref_b);i0++){
	  i = ref_b[i0]	
	  out_b[i,1] = &compute_ATE(Yall,Xall,Call, Option , i, computeT , alpha0 , CIOption,  g_labels  , G_types, G_indic , ratio)
    }
  }
  
  /* output */
  
  mat_results_CMLE = J(dimX,3,.);
  mat_results_CMLE_rows = J(dimX,1,"");
  
  
  
  
  
  
  
  
  
  if(Option=="quick"){
	/*  ### compute at T_inf*/
	  if( computeT[1,1]=="" ){
		mat_results = J(dimX,3,.)
		mat_results_rows = J(dimX,1,"")
		/*for(j=1;j<=dimX;j++){
			mat_results_rows[j,1] = "Tinf,"
		}*/
	  }else if(computeT[1,1]!="" & computeT[1,1]!="all"){
		/*### compute at specified dates*/
		mat_results = J(dimX*length(computeT),4,.);
		mat_results_rows = J(dimX*length(computeT),1,"")
		/*for(i=1; i<=length(computeT);i++){
		  for(j=1;j<=dimX;j++){
			mat_results_rows[dimX*(i-1)+j,1] = "T=" + computeT[1,i] + ","
		  }
		}*/
	  }else{
		/*### compute at all dates plus average*/
		/*ta = 1..Tmax*/
		t0 = length(1..Tmax) +1
		mat_results = J(dimX*t0  ,4,.);
		mat_results_rows = J(dimX*t0  ,1,"");
	/*	for(i=1;i<=t0;i++){
		  if(i!=t0){
			for(j=1;j<=dimX;j++){
				mat_results_rows[dimX*(i-1)+j,1] = "T=" + strofreal(ta[i]) + ","
			}
		  }else{
			for(j=1;j<=dimX;j++){
				mat_results_rows[dimX*(i-1)+j,1] = "Average" + ","
			}
		  }
		}*/
	  }
  
  }else{
  
  	/*  ### compute at T_inf*/
	  if( computeT[1,1]=="" ){
		mat_results = J(dimX,4,.)
		mat_results_rows = J(dimX,1,"")
		/*for(j=1;j<=dimX;j++){
			mat_results_rows[j,1] = "Tinf,"
		}*/
	  }else if(computeT[1,1]!="" & computeT[1,1]!="all"){
		/*### compute at specified dates*/
		mat_results = J(dimX*length(computeT),5,.);
		mat_results_rows = J(dimX*length(computeT),1,"")
		/*for(i=1; i<=length(computeT);i++){
		  for(j=1;j<=dimX;j++){
			mat_results_rows[dimX*(i-1)+j,1] = "T=" + computeT[1,i] + ","
		  }
		}*/
	  }else{
		/*### compute at all dates plus average*/
		ta = 1..Tmax
		t0 = length(1..Tmax) +1
		mat_results = J(dimX*t0  ,5,.);
		mat_results_rows = J(dimX*t0  ,1,"");
		/*for(i=1;i<=t0;i++){
		  if(i!=t0){
			for(j=1;j<=dimX;j++){
				mat_results_rows[dimX*(i-1)+j,1] = "T=" + strofreal(ta[i]) + ","
			}
		  }else{
			for(j=1;j<=dimX;j++){
				mat_results_rows[dimX*(i-1)+j,1] = "Average" + ","
			}
		  }
		}*/
	  }
	  
  }

  
  
  
  if(Option=="quick"){
 
    count_c=1
    count_b=1
   /* ## for all the variables
    #i=1*/
    ind=1
    /*rnd= "%7.0g"*/
    for(i= 1; i<=dimX; i++){
      /*# if continuous*/
      if(type_cont[i]==1){
       /* # out_c*/
        if(computeT[1,1]==""){
          /*# names(  output) <- c("Tinf")
          ## insert est beta.*/
         
		  curr= *out_c[1,1]
		
          /*#### insert CMLE estimates*/
          mat_results_CMLE_rows[i,1] = var_x_c[count_c]
		  
          mat_results_CMLE[i,1] =  (*curr[10,1])[i]
          mat_results_CMLE[i,2] =  (*curr[11,1])[i]
          pval = 2*(1- normal(abs((*curr[10,1])[i] )/(*curr[11,1])[i] ))
          mat_results_CMLE[i,3] = pval

		  mat_results_rows[ind,1] =   var_x_c[count_c]  + "(Tinf)"
          /*# ind=  ind +1
          ## insert est Delta
          # mat_results[ind,2] = "\\underline{T}"*/
          mat_results[ind,1] =  (*curr[4,1])[count_c]
          mat_results[ind,2] =  (*curr[8,1])[count_c,1]
		  mat_results[ind,3] =  (*curr[8,1])[count_c,2]

          ind=  ind +1
          count_c = count_c+1
        }else if( computeT[1,1]!="" &  computeT[1,1]!="all"){
         /*## compute for selected periods
          # names(  output) <- apply(matrix(compute_T,length(compute_T),1),1,append_name )*/

         /* ind0 = ind*/
        /*  # j=1*/
		
          curr = *out_c[1,1]
          mat_results_CMLE_rows[i,1] = var_x_c[count_c]
          mat_results_CMLE[i,1] = (*curr[10,1])[i]
          mat_results_CMLE[i,2] =  (*curr[11,1])[i] 
          pval = 2*(1- normal(abs((*curr[10,1])[i] )/(*curr[11,1])[i] ))
          mat_results_CMLE[i,3] = pval

          for(j=1; j<=length(computeT); j++){
		  	if(j ==1){
				mat_results_rows[ind+dimX*(j-1),1] =  var_x_c[count_c]	
			}else{
				mat_results_rows[ind+dimX*(j-1),1] =  var_x_c[count_c]	
			}
           
           /* mat_results[ind+dimX*(j-1),3] = "AME"*/
            curr = (*out_c[j,1])
            /*## insert est Delta*/
			mat_results[ind+dimX*(j-1),1] =  strtoreal(computeT[1,j])
            mat_results[ind+dimX*(j-1),2] =  (*curr[4,1])[count_c]
            mat_results[ind+dimX*(j-1),3] =  (*curr[8,1])[count_c,1]
			mat_results[ind+dimX*(j-1),4] =  (*curr[8,1])[count_c,2]
          }
		  
          ind=  ind +1
          count_c= count_c+1
        }else{
         /* ## compute for all periods.
          # for(t_end in 1:Tmax){
          # names(  output) <- apply(matrix(1:Tmax,length(1:Tmax),1),1,append_name )*/

          curr = *out_c[1,1]
          mat_results_CMLE_rows[i,1] = var_x_c[count_c]
          mat_results_CMLE[i,1] =  (*curr[10,1])[i]
          mat_results_CMLE[i,2] = (*curr[11,1])[i]
          pval = 2*(1- normal(abs((*curr[10,1])[i] )/(*curr[11,1])[i] ))
          mat_results_CMLE[i,3] = pval
		  
         /* ind0 = ind*/
          for(j=1;j<=rows(out_c);j++){
		  	if(j <=Tmax){
				mat_results_rows[ind+dimX*(j-1),1] =  var_x_c[count_c] 
			}else{
				mat_results_rows[ind+dimX*(j-1),1] = var_x_c[count_c] + "(Average)"
			}
            curr = (*out_c[j,1])
           /* ## insert est Delta*/
		   if(j<=Tmax){
			mat_results[ind+dimX*(j-1),1] =  j
		   }else{
		   	mat_results[ind+dimX*(j-1),1] =  .
		   }
            mat_results[ind+dimX*(j-1),2] =  (*curr[4,1])[count_c]
            mat_results[ind+dimX*(j-1),3] =   (*curr[8,1])[count_c,1]
			mat_results[ind+dimX*(j-1),4] =  (*curr[8,1])[count_c,2]
        }
          ind=  ind +1
          count_c= count_c+1

        }

      }else{ /*# end type continous variable*/


        curr =  (*out_b[i,1])

        if( computeT[1,1]=="" ){
			
		  curr = *(curr[1,1])	
          /*# names(  output) <- c("Tinf")
          ## insert est beta.*/
          mat_results_rows[ind,1] =  var_x_b[count_b] + "(Tinf)"

         /* ### insert results CMLE*/
          mat_results_CMLE_rows[i,1] =  var_x_b[count_b] 
          mat_results_CMLE[i,1] =  (*curr[10,1])[i]
          mat_results_CMLE[i,2] =  (*curr[11,1])[i]
          pval = 2*(1- normal(abs((*curr[10,1])[i] )/(*curr[11,1])[i] ))
          mat_results_CMLE[i,3] = pval

        
          /*## insert est Delta*/
          mat_results[ind,1] = (*curr[4,1])
          mat_results[ind,2] =  (*curr[8,1])[1,1] 
		  mat_results[ind,3] =  (*curr[8,1])[1,2]
		  ind=  ind +1
          count_b= count_b+1

        }else if( computeT[1,1]!="" & computeT[1,1]!="all"){
          /*## compute for selected periods
          # names(  output) <- apply(matrix(compute_T,length(compute_T),1),1,append_name )*/
   
		  curr0 =  *curr[1,1]
          mat_results_CMLE_rows[i,1] = var_x_b[count_b]
          mat_results_CMLE[i,1] =  (*curr0[10,1])[i]
          mat_results_CMLE[i,2] =  (*curr0[11,1])[i]
          pval = 2*(1- normal(abs((*curr0[10,1])[i] )/(*curr0[11,1])[i] ))
          mat_results_CMLE[i,3] = pval
        

         /* ind0 = ind*/
          for(j =1;j<=length(computeT);j++){
		  	if(j==1){
				mat_results_rows[ind+dimX*(j-1),1] =  var_x_b[count_b]
            }else{
				mat_results_rows[ind+dimX*(j-1),1] =  var_x_b[count_b]
			}
            curr0 =  *curr[j,1]
          /*  ## insert est Delta*/
			mat_results[ind+dimX*(j-1),1] = strtoreal(computeT[1,j])
            mat_results[ind+dimX*(j-1),2] =  (*curr0[4,1])
            mat_results[ind+dimX*(j-1),3] =  (*curr0[8,1])[1,1] 
			mat_results[ind+dimX*(j-1),4] = (*curr0[8,1])[1,2]
          }
		  
          ind=  ind +1
          count_b= count_b+1
        }else{
          /*## compute for all periods.
          # for(t_end in 1:Tmax){
          # names(  output) <- apply(matrix(1:Tmax,length(1:Tmax),1),1,append_name )*/
		  curr0 =  *curr[1,1]
          mat_results_CMLE_rows[i,1] =  var_x_b[count_b]
          mat_results_CMLE[i,1] = (*curr0[10,1])[i]
          mat_results_CMLE[i,2] =  (*curr0[11,1])[i]
          pval = 2*(1- normal(abs((*curr0[10,1])[i] )/(*curr0[11,1])[i] ))
          mat_results_CMLE[i,3] = pval

          /*ind0 = ind*/
          for(j=1;j<=rows(curr);j++){
		  	if(j<=Tmax){
				mat_results_rows[ind+dimX*(j-1),1] = var_x_b[count_b]
			}else{
			    mat_results_rows[ind+dimX*(j-1),1] =  var_x_b[count_b] + "(Average)"
			}
            curr0 =  *curr[j,1]
            /*## insert est Delta*/
			if(j<=Tmax){
			mat_results[ind+dimX*(j-1),1] =  j
		   }else{
		   	mat_results[ind+dimX*(j-1),1] =  .
		   }
			mat_results[ind+dimX*(j-1),2] =  (*curr0[4,1])[1,1]
            mat_results[ind+dimX*(j-1),3] =  (*curr0[8,1])[1,1]
			mat_results[ind+dimX*(j-1),4] =  (*curr0[8,1])[1,2]
   
          }
          ind=  ind +1
          count_b= count_b+1


        }
      }
    } /*# end dimX*/

  }else{
  	
	count_c=1
    count_b=1
   /* ## for all the variables
    #i=1*/
    ind=1
    /*rnd= "%7.0g"*/
    for(i= 1; i<=dimX; i++){
      /*# if continuous*/
      if(type_cont[i]==1){
       /* # out_c*/
        if(computeT[1,1]==""){
          /*# names(  output) <- c("Tinf")
          ## insert est beta.*/
         
		  curr= *out_c[1,1]
		
          /*#### insert CMLE estimates*/
          mat_results_CMLE_rows[i,1] = var_x_c[count_c]
          mat_results_CMLE[i,1] =  (*curr[10,1])[i]
          mat_results_CMLE[i,2] =  (*curr[11,1])[i]
          pval = 2*(1- normal(abs((*curr[10,1])[i] )/(*curr[11,1])[i] ))
          mat_results_CMLE[i,3] = pval

		  mat_results_rows[ind,1] =  var_x_c[count_c] + "(Tinf)"
          /*# ind=  ind +1
          ## insert est Delta
          # mat_results[ind,2] = "\\underline{T}"*/
       
		  mat_results[ind,1] =  (*curr[4,1])[count_c,1]
		  mat_results[ind,2] =  (*curr[4,1])[count_c,2]
          mat_results[ind,3] =  (*curr[8,1])[count_c,1]
		  mat_results[ind,4] =  (*curr[8,1])[count_c,2]

          ind=  ind +1
          count_c = count_c+1
        }else if( computeT[1,1]!="" &  computeT[1,1]!="all"){
         /*## compute for selected periods
          # names(  output) <- apply(matrix(compute_T,length(compute_T),1),1,append_name )*/

          /*ind0 = ind*/
        /*  # j=1*/
		
          curr = *out_c[1,1]
          mat_results_CMLE_rows[i,1] = var_x_c[count_c]
          mat_results_CMLE[i,1] = (*curr[10,1])[i]
          mat_results_CMLE[i,2] =  (*curr[11,1])[i] 
          pval = 2*(1- normal(abs((*curr[10,1])[i] )/(*curr[11,1])[i] ))
          mat_results_CMLE[i,3] = pval

          for(j=1; j<=length(computeT); j++){
		
			mat_results_rows[ind+dimX*(j-1),1] = var_x_c[count_c]
           
           /* mat_results[ind+dimX*(j-1),3] = "AME"*/
            curr = (*out_c[j,1])
            /*## insert est Delta*/         
			mat_results[ind+dimX*(j-1),1] = strtoreal(computeT[1,j])
            mat_results[ind+dimX*(j-1),2] = (*curr[4,1])[count_c,1]
			mat_results[ind+dimX*(j-1),3] = (*curr[4,1])[count_c,2]
            mat_results[ind+dimX*(j-1),4] = (*curr[8,1])[count_c,1]
			mat_results[ind+dimX*(j-1),5] = (*curr[8,1])[count_c,2]
          }
		  
          ind=  ind +1
          count_c= count_c+1
        }else{
         /* ## compute for all periods.
          # for(t_end in 1:Tmax){
          # names(  output) <- apply(matrix(1:Tmax,length(1:Tmax),1),1,append_name )*/

          curr = *out_c[1,1]
          mat_results_CMLE_rows[i,1] = var_x_c[count_c]
          mat_results_CMLE[i,1] =  (*curr[10,1])[i]
          mat_results_CMLE[i,2] = (*curr[11,1])[i]
          pval = 2*(1- normal(abs((*curr[10,1])[i] )/(*curr[11,1])[i] ))
          mat_results_CMLE[i,3] = pval
		  
          /*ind0 = ind*/
          for(j=1;j<=rows(out_c);j++){
		  	if(j<=Tmax){
				mat_results_rows[ind+dimX*(j-1),1] = mat_results_rows[ind+dimX*(j-1),1]  + var_x_c[count_c]
			}else{
				mat_results_rows[ind+dimX*(j-1),1] =  mat_results_rows[ind+dimX*(j-1),1] + var_x_c[count_c] + "(Average)"
			}
            curr = (*out_c[j,1])
           /* ## insert est Delta*/
			if(j<=Tmax){
				mat_results[ind+dimX*(j-1),1] =  j
			}else{
				mat_results[ind+dimX*(j-1),1] =  .
			}
            mat_results[ind+dimX*(j-1),2] =  (*curr[4,1])[count_c,1]
			mat_results[ind+dimX*(j-1),3] =  (*curr[4,1])[count_c,2]
            mat_results[ind+dimX*(j-1),4] =  (*curr[8,1])[count_c,1]
			mat_results[ind+dimX*(j-1),5] =  (*curr[8,1])[count_c,2]
        }
          ind=  ind +1
          count_c= count_c+1

        }

      }else{ /*# end type continous variable*/


        curr =  (*out_b[i,1])

        if( computeT[1,1]=="" ){
			
		  curr = *(curr[1,1])	
          /*# names(  output) <- c("Tinf")
          ## insert est beta.*/
          mat_results_rows[ind,1] = var_x_b[count_b] + "(Tinf)"

         /* ### insert results CMLE*/
          mat_results_CMLE_rows[i,1] =  var_x_b[count_b]
          mat_results_CMLE[i,1] =  (*curr[10,1])[i]
          mat_results_CMLE[i,2] =  (*curr[11,1])[i]
          pval = 2*(1- normal(abs((*curr[10,1])[i] )/(*curr[11,1])[i] ))
          mat_results_CMLE[i,3] = pval

        
          /*## insert est Delta*/
          mat_results[ind,1] = (*curr[4,1])[1,1] 
		  mat_results[ind,2] = (*curr[4,1])[1,2]
          mat_results[ind,3] =  (*curr[8,1])[1,1] 
		  mat_results[ind,4] =  (*curr[8,1])[1,2]
		  ind=  ind +1
          count_b= count_b+1

        }else if( computeT[1,1]!="" & computeT[1,1]!="all"){
          /*## compute for selected periods
          # names(  output) <- apply(matrix(compute_T,length(compute_T),1),1,append_name )*/
   
		  curr0 =  *curr[1,1]
          mat_results_CMLE_rows[i,1] = var_x_b[count_b]
          mat_results_CMLE[i,1] =  (*curr0[10,1])[i]
          mat_results_CMLE[i,2] =  (*curr0[11,1])[i]
          pval = 2*(1- normal(abs((*curr0[10,1])[i] )/(*curr0[11,1])[i] ))
          mat_results_CMLE[i,3] = pval
        

         /* ind0 = ind*/
          for(j =1;j<=length(computeT);j++){
		  	if(j==1){
				mat_results_rows[ind+dimX*(j-1),1] =  var_x_b[count_b]
            }else{
				mat_results_rows[ind+dimX*(j-1),1] =   var_x_b[count_b]
			}
            curr0 =  *curr[j,1]
          /*  ## insert est Delta*/
		    mat_results[ind+dimX*(j-1),1] =  strtoreal(computeT[1,j])
            mat_results[ind+dimX*(j-1),2] =  (*curr0[4,1])[1,1] 
			mat_results[ind+dimX*(j-1),3] =  (*curr0[4,2])[1,2]
            mat_results[ind+dimX*(j-1),4] =  (*curr0[8,1])[1,1] 
			mat_results[ind+dimX*(j-1),5] = (*curr0[8,1])[1,2]
          }
		  
          ind=  ind +1
          count_b= count_b+1
        }else{
          /*## compute for all periods.
          # for(t_end in 1:Tmax){
          # names(  output) <- apply(matrix(1:Tmax,length(1:Tmax),1),1,append_name )*/
		  curr0 =  *curr[1,1]
          mat_results_CMLE_rows[i,1] = var_x_b[count_b]
          mat_results_CMLE[i,1] = (*curr0[10,1])[i]
          mat_results_CMLE[i,2] =  (*curr0[11,1])[i]
          pval = 2*(1- normal(abs((*curr0[10,1])[i] )/(*curr0[11,1])[i] ))
          mat_results_CMLE[i,3] = pval

        /*  ind0 = ind*/
          for(j=1;j<=rows(curr);j++){
		  	if(j<=Tmax){
				mat_results_rows[ind+dimX*(j-1),1] =  var_x_b[count_b]
			}else{
			    mat_results_rows[ind+dimX*(j-1),1] =  var_x_b[count_b] + "(Average)"
			}
            curr0 =  *curr[j,1]
            /*## insert est Delta*/

			if(j<=Tmax){
				mat_results[ind+dimX*(j-1),1] =  j
			}else{
				mat_results[ind+dimX*(j-1),1] =  .
			}
			mat_results[ind+dimX*(j-1),2] =  (*curr0[4,1])[1,1]
			mat_results[ind+dimX*(j-1),3] =  (*curr0[4,2])[1,2]
            mat_results[ind+dimX*(j-1),4] =  (*curr0[8,1])[1,1]
			mat_results[ind+dimX*(j-1),5] =  (*curr0[8,1])[1,2]
   
          }
          ind=  ind +1
          count_b= count_b+1


        }
      }
    } /*# end dimX*/
		
  }   

  /*
  ### format the output for the print function.*/

  output = J(10,1,NULL)
  output[1,1] = &mat_results
  output[2,1] = &mat_results_CMLE
  output[3,1] = &mat_results_rows
  output[4,1] = &mat_results_CMLE_rows
  output[5,1] = &rows(dataY)
  output[6,1] = &ndiscard
  output[7,1] = &Tmax
  output[8,1] = &alpha0
  output[9,1] = &Option

 /* output[5,1] = &vardiscard*/
  /*names(output) <- c("summary", "n", "ndiscard", "Tmax", "vardiscard", "formul", "alpha", "Option","summary_CMLE", "compute_T")*/
  
  st_eclear() 
  st_matrix("r(mat_results)", mat_results)
  st_matrix("r(mat_results_CMLE)", mat_results_CMLE)
  
  st_numscalar("r(rows_results_CMLE)", rows(mat_results_CMLE))
  st_numscalar("r(rows_results)", rows(mat_results))
  st_global("r(ndiscard)", strofreal(ndiscard) )
  st_global("r(maxT)", strofreal(Tmax))
  st_global("r(n)", strofreal(rows(dataY)) )
  st_global("r(alpha0)", strofreal((1-alpha0)*100) )
  Optionval = (Option=="quick")
  st_numscalar("r(Optionval)", Optionval )
  OptionTinf = (computeT[1,1]=="")
  st_numscalar("r(OptionTinf)", OptionTinf)
  
   for(j=1;j<=rows(mat_results);j++){
  	 /*all_CMLE =  all_CMLE + " " + mat_results_CMLE_rows[j,1]*/
  	st_global("r(res" + strofreal(j) + ")", mat_results_rows[j,1] )
  }

 
  for(j=1;j<=rows(mat_results_CMLE);j++){
  	 /*all_CMLE =  all_CMLE + " " + mat_results_CMLE_rows[j,1]*/
  	st_global("r(CMLE" + strofreal(j) + ")", mat_results_CMLE_rows[j,1] )
  }

  
  
  
  return(output)
}
end


