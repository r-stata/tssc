
capture mata: mata drop sq()
capture mata: mata drop cquadequ()
capture program drop cquadequ

// --------------------------------------------------------------------
program cquadequ, eclass 

  version 11

  display ""
  display "Fit quadratic exponential model by Conditional Maximum Likelihood"
  display "with modified interaction terms"
  display "see Bartolucci, Nigro & Pigini (2013), MPRA Paper 48233
  display ""
  
  syntax varlist

  
  ereturn clear
  mata: cquadequ("`varlist'")
  
end


// --------------------------------------------------------------------
mata: 
void cquadequ(varnames){

// preliminaries
  st_view(data1,.,varnames)
  yv = data1[,1]
  id = data1[,2]
  k = cols(data1)-2
  nt = rows(id)
  if(k==0) varlist = "y-lag"
  if(k>0) varlist = (tokens(varnames)[3..(k+2)],"y-lag")
  if(k>0) Xv = data1[,3..(k+2)]
  label = uniqrows(id)
  n = length(label)
  c = 2
// starting values
  be = J(k+1,1,0)
// check for balanced data
  Tv = J(n,1,0)
  for(i=1;i<=n;i++) Tv[i] = sum(id:==label[i])
  TT = max(Tv)
  Tv = Tv:-1
// iterate until convergence    
  it = 0
  lk = -10^10
  lk0 = -10^10
  if(k>0) zero1 = (J(1,k,0),1)
  printf("{txt}{space 6}{c |}      lk       lk-lk0\n")  
  printf("{hline 6}{c +}{hline 50}\n")  
  while(abs(lk-lk0)>10^-6 | it==0){
    it = it+1; lk0 = lk 
    scv = J(n,k+1,0)
    lk = 0; J = J(k+1,k+1,0)
    for(i=1;i<=n;i++){
      if(Tv[i]>1){
        il = label[i]
        y_i = select(yv,id:==il)
        y_i0 = y_i[1]
        y_i = y_i[2..(Tv[i]+1)]
        sui = sum(y_i)
        if(sui>0 & sui<Tv[i]){
          Z = sq(Tv[i],sui)
          if(k>0) x_i = select(Xv,id:==il)
          if(k>0) x_i = ((x_i[2..(Tv[i]+1),],J(Tv[i],1,0)) \ zero1)
          else x_i = (J(Tv[i],1,0) \ 1)
          Z = (Z,(Z[,1]:==y_i0)+rowsum(Z[,1..(Tv[i]-1)]:==Z[,2..Tv[i]]))
          xb = x_i*be              
          den = exp(Z*xb)
          sden = sum(den)
          y_i = (y_i \ (y_i0:==y_i[1])+sum(y_i[1..(Tv[i]-1)]:==y_i[2..Tv[i]]))
          pc_i = exp(y_i'xb)/sden
          Zt = Z'
          lk = lk+log(pc_i)
          pp_i = den/sden
          e_i = Zt*pp_i
          scv[i,] = scv[i,]+(y_i-e_i)'*x_i
          V_i = Zt*diag(pp_i)*Z-e_i*e_i'
          J = J-x_i'V_i*x_i
        }
      }
    }
    sc = colsum(scv)'
    iJ = pinv(J)
    be = be-iJ*sc
    printf("{res}%5.0f {c |} {res}%10.0g %10.0g\n", it, lk, lk-lk0)
  }
  display("")
// output  
  Va = iJ*(scv'scv)*iJ 
  se = sqrt(diagonal(-iJ))
  ser = sqrt(diagonal(Va))
  tstat = be:/se
  pv = 2:*(1:-normal(abs(tstat)))
  display("")
  printf("{txt}{space 13}{c |}      est.      s.e.      t-stat.    p-value\n")  
  printf("{hline 13}{c +}{hline 50}\n")
  for(j=1;j<=k+1;j++) printf("{txt}%12s {c |} {res}%10.0g %10.0g %10.0g %10.0g\n", varlist[j], be[j], se[j], tstat[j], pv[j])
  display("")
// store arguments  
  st_global("e(cmd)", "cquadequ")
  st_numscalar("e(lk)", lk)
  st_matrix("e(pv)", pv')  
  st_matrix("e(tstat)", tstat')
  st_matrix("e(ser)", ser')
  st_matrix("e(se)", se')
  st_matrix("e(be)", be')

}

// --------------------------------------------------------------------
mata: 
function sq(T,s){

	if(T==0 | s>T) M = J(0,0,0)
	else{
		if(s==0) M = J(1,T,0)       // no elements equal to 1
		if(s==1){                   // only one element equal to 1
			M = J(T,T,0)
			for(j=1;j<=T;j++) M[j,T-j+1] = 1
		}
		if(s==T) M = J(1,T,1)       // all elements equal to 1
		if(s>1 & s<T){              // all other cases
			M0 = sq(T-1,s)	
			M1 = sq(T-1,s-1)
			M = (J(rows(M0),1,0),M0 \ J(rows(M1),1,1),M1)	
		}
	}
	return(M)
}

end
