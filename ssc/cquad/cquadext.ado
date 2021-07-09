
capture mata: mata drop sq()
capture mata: mata drop cquadext()
capture program drop cquadext

// --------------------------------------------------------------------
program cquadext, eclass 

  version 11

  display ""
  display "Fit quadratic exponential model by Conditional Maximum Likelihood"
  display "see Bartolucci & Nigro (2010), Econometrica
  display ""
  
  syntax varlist

  
  ereturn clear
  mata: cquadext("`varlist'")
  
end


// --------------------------------------------------------------------
mata: 
void cquadext(varnames){

// preliminaries
  st_view(data1,.,varnames)
  yv = data1[,1]
  id = data1[,2]
  label = uniqrows(id)
  n = length(label)
  k = cols(data1)-2
  nt = rows(id)
  if(k==0){
    X = J(nt,1,0)
    ind = 0
    for(i=1;i<=n;i++){
      il = label[i]
      Ti = sum(id:==label[i])
      ind = max(ind)+1..max(ind)+Ti
      X[ind] = (J(Ti-1,1,0) \ 1) 
	}
  	varlist = ("diff-int","y-lag")
  }
  if(k>0){
    X0 = data1[,3..(k+2)]
    X = J(nt,2*k+1,0)
    ind = 0
    for(i=1;i<=n;i++){
      il = label[i]
      Ti = sum(id:==il)
      Xi = select(X0,id:==il)
      Tmp = (J(Ti - 1, k + 1, 0) \ (1, Xi[Ti, ]))
      ind = max(ind)+1..max(ind)+Ti
      X[ind,] = (Xi, Tmp)
    }
    varlist = (tokens(varnames)[3..(k+2)])
    varlist = (varlist,"diff-int")
	for(j=1;j<=k;j++) varlist = (varlist,"diff-"+varlist[j]) 
    varlist = (varlist,"y-lag")
    ind = J(0,1,0)
    for(j=1;j<=2*k+1;j++){
      if(max(X[,j])>min(X[,j])){
        ind = (ind \ j)
      }
    }
    X = X[,ind]
    ind = (ind \ 2*k+2)
    varlist = varlist[ind]
  }
// starting values
  nx = cols(X)+1
  be = J(nx,1,0)
// check for balanced data
  Tv = J(n,1,0)
  for(i=1;i<=n;i++) Tv[i] = sum(id:==label[i])
  TT = max(Tv)
  Tv = Tv:-1
// iterate until convergence    
  it = 0
  lk = -10^10
  lk0 = -10^10
  zero1 = (J(1,nx-1,0),1)
  printf("{txt}{space 6}{c |}      lk       lk-lk0\n")  
  printf("{hline 6}{c +}{hline 50}\n")  
  while(abs(lk-lk0)>10^-6 | it==0){
    it = it+1; lk0 = lk 
    scv = J(n,nx,0)
    lk = 0; J = J(nx,nx,0)
    for(i=1;i<=n;i++){
      if(Tv[i]>1){
        il = label[i]
        y_i = select(yv,id:==il)
        y_i0 = y_i[1]
        y_i = y_i[2..(Tv[i]+1)]
        sui = sum(y_i)
        if(sui>0 & sui<Tv[i]){
          Z = sq(Tv[i],sui)
          x_i = select(X,id:==il)
          x_i = ((x_i[2..(Tv[i]+1),],J(Tv[i],1,0)) \ zero1)
          Z = (Z,Z[,1]*y_i0+rowsum(Z[,1..(Tv[i]-1)]:*Z[,2..Tv[i]]))
          xb = x_i*be              
          den = exp(Z*xb)
          sden = sum(den)
          y_i = (y_i \ y_i0*y_i[1]+sum(y_i[1..(Tv[i]-1)]:*y_i[2..Tv[i]]))
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
  if(rank(iJ)<nx) display("Warning: the information matrix is rank deficient: check covariate structure")
  display("")  
// output  
  Va = iJ*(scv'scv)*iJ 
  se = sqrt(diagonal(-iJ))
  ser = sqrt(diagonal(Va))
  tstat = be:/se
  pv = 2:*(1:-normal(abs(tstat)))
  display("")
  printf("{txt}{space 15}{c |}      est.      s.e.      t-stat.    p-value\n")  
  printf("{hline 15}{c +}{hline 50}\n")
  for(j=1;j<=nx;j++) printf("{txt}%14s {c |} {res}%10.0g %10.0g %10.0g %10.0g\n", varlist[j], be[j], se[j], tstat[j], pv[j])
  display("")
// store arguments  
  st_global("e(cmd)", "cquadext")
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

