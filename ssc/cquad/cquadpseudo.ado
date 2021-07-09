
capture mata: mata drop sq()
capture mata: mata drop cquadpseudo()
capture program drop cquadpseudo

// --------------------------------------------------------------------
program cquadpseudo, eclass 

  version 11

  display ""
  display "Fit Pseudo Conditional Maximum Likelihood estimator for the dynamic logit model"
  display "see Bartolucci & Nigro (2012), J.Econometrics
  display ""
  
  syntax varlist

  
  ereturn clear
  mata: cquadpseudo("`varlist'")
  
end


// --------------------------------------------------------------------
mata: 
void cquadpseudo(varnames){

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
// check for balanced data
  Tv = J(n,1,0)
  for(i=1;i<=n;i++) Tv[i] = sum(id:==label[i])
  Tv0 = Tv
  Tv = Tv:-1
  TT = max(Tv)
// starting values
  if(k==0){
  	be = 0
  	Q = J(length(yv),1,0.5)
  }
  else{
    be0 = J(k,1,0)
    it = 0
    lk = -10^10
    lk0 = -10^10
    display("First step")  
    display("")  
    printf("{txt}{space 6}{c |}      lk       lk-lk0\n")  
    printf("{hline 6}{c +}{hline 50}\n")  
    while(abs(lk-lk0)>10^-6 | it==0){
      it = it+1; lk0 = lk 
	  scv = J(n,k,0)
      lk = 0; J = J(k,k,0)
      for(i=1;i<=n;i++){
        if(Tv0[i]>1){
          il = label[i]
          y_i = select(yv,id:==il)
          sui = sum(y_i)
          if(sui>0 & sui<Tv0[i]){
            Z = sq(Tv0[i],sui)
            x_i = select(Xv,id:==il)
            xb = x_i*be0              
            den = exp(Z*xb)
            sden = sum(den)
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
      dbe = -iJ*sc
      mdbe = max(abs(dbe))
   	  if(mdbe>0.5) dbe = dbe:/mdbe:*0.5
      be0 = be0+dbe
      printf("{res}%5.0f {c |} {res}%10.0g %10.0g\n", it, lk, lk-lk0)
      scv0 = scv
      J0 = J
    }
  	Q = J(length(yv),1,0)
  	j = 0
	for(i=1;i<=n;i++){
      il = label[i]
      y_i = select(yv,id:==il)
      sui = sum(y_i)
      if(sui==0) q_i = J(length(y_i),1,0)
      if(sui==Tv0[i]) q_i = J(length(y_i),1,1)
	  if(sui>0 & sui<Tv0[i]){
        x_i = select(Xv,id:==il)
		int0 = x_i*be0
		al = 0
	    q_i = exp(int0)
	    q_i = q_i:/(1:+q_i)
		lk1 = y_i'log(q_i)+(1:-y_i)'log(1:-q_i)
		lk1o = lk1-10^10
		while(abs(lk1-lk1o)>10^-10){
	      lk1o = lk1
	      dal = sum(y_i-q_i)/sum(q_i:*(1:-q_i))
	      mdal = abs(dal)
	      if(mdal>0.5) dal = dal/mdal*0.5
 	      al = al+dal
          q_i = exp(al:+int0)
          q_i = q_i:/(1:+q_i)
          lk1 = y_i'log(q_i)+(1:-y_i)'log(1:-q_i)
        }
      }
      Q[((j+1)..(j+length(q_i)))] = q_i  	 
      j = j+length(q_i)   
	}
    display("")  
    be = (be0 \ 0)
  }
// iterate until convergence    
  display("Second step")  
  display("")  
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
        q_i = select(Q,id:==il)
        q_i = q_i[2..(Tv[i]+1)]
        sui = sum(y_i)
        if(sui>0 & sui<Tv[i]){
          Z = sq(Tv[i],sui)
          if(k>0) x_i = select(Xv,id:==il)
          if(k>0) x_i = ((x_i[2..(Tv[i]+1),],J(Tv[i],1,0)) \ zero1)
          else x_i = (J(Tv[i],1,0) \ 1)
          Tmp = J(rows(Z),1,1)*q_i[2..(Tv[i])]'
          Z = (Z,y_i0*(Z[,1]:-q_i[1])+
               rowsum(Z[,1..(Tv[i]-1)]:*(Z[,2..Tv[i]]-Tmp)))
          xb = x_i*be              
          den = exp(Z*xb)
          sden = sum(den)
          y_i = (y_i \ y_i0*(y_i[1]-q_i[1])+
                 sum(y_i[1..(Tv[i]-1)]:*(y_i[2..Tv[i]]-q_i[2..Tv[i]])))
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
  se = sqrt(diagonal(-iJ))
  if(k==0) Var = iJ*(scv'scv)*iJ
  else{
  	scv1 = (scv0,scv)
  	J01 = J(k,k+1,0)
// numerical second derivative  	
  	J10 = J(k+1,k,0)
    for(h=1;h<=k;h++){
      be1 = be0; be1[h] = be1[h]+10^-6
  	  Q1 = J(length(yv),1,0)
  	  j = 0
      for(i=1;i<=n;i++){
        il = label[i]
        y_i = select(yv,id:==il)
        sui = sum(y_i)
        if(sui==0) q_i = J(length(y_i),1,0)
        if(sui==Tv0[i]) q_i = J(length(y_i),1,1)
	    if(sui>0 & sui<Tv0[i]){
          x_i = select(Xv,id:==il)
		  int1 = x_i*be1
		  al = 0
	      q_i = exp(int1)
          q_i = q_i:/(1:+q_i)
		  lk1 = y_i'log(q_i)+(1:-y_i)'log(1:-q_i)
		  lk1o = lk1-10^10
		  while(abs(lk1-lk1o)>10^-10){
	        lk1o = lk1
	        dal = sum(y_i-q_i)/sum(q_i:*(1:-q_i))
	        mdal = abs(dal)
	        if(mdal>0.5) dal = dal/mdal*0.5
 	        al = al+dal
            q_i = exp(al:+int1)
            q_i = q_i:/(1:+q_i)
            lk1 = y_i'log(q_i)+(1:-y_i)'log(1:-q_i)
          }
        }
        Q1[((j+1)..(j+length(q_i)))] = q_i  	       
        j = j+length(q_i)  
      }
      sc1 = J(k+1,1,0)
      for(i=1;i<=n;i++){
        if(Tv[i]>1){
          il = label[i]
          y_i = select(yv,id:==il)
          y_i0 = y_i[1]
          y_i = y_i[2..(Tv[i]+1)]
          q_i = select(Q1,id:==il)
          q_i = q_i[2..(Tv[i]+1)]
          sui = sum(y_i)
          if(sui>0 & sui<Tv[i]){
            Z = sq(Tv[i],sui)
            if(k>0) x_i = select(Xv,id:==il)
            if(k>0) x_i = ((x_i[2..(Tv[i]+1),],J(Tv[i],1,0)) \ zero1)
            else x_i = (J(Tv[i],1,0) \ 1)
            Tmp = J(rows(Z),1,1)*q_i[2..(Tv[i])]'
            Z = (Z,y_i0*(Z[,1]:-q_i[1])+
                 rowsum(Z[,1..(Tv[i]-1)]:*(Z[,2..Tv[i]]-Tmp)))
            xb = x_i*be              
            den = exp(Z*xb)
            sden = sum(den)
            y_i = (y_i \ y_i0*(y_i[1]-q_i[1])+
                   sum(y_i[1..(Tv[i]-1)]:*(y_i[2..Tv[i]]-q_i[2..Tv[i]])))
            pc_i = exp(y_i'xb)/sden
            Zt = Z'
            lk = lk+log(pc_i)
            pp_i = den/sden
            e_i = Zt*pp_i
            sc1 = sc1+x_i'(y_i-e_i)
          }
        }
      }
      J10[,h] = (sc1-sc)*10^6       
	}  	
// end numerical second derivative  	
  	J1 = (J0,J01 \ J10,J)
  	iJ1 = pinv(J1)
    Var = iJ1*(scv1'scv1)*iJ1
    Var = Var[k+1..2*k+1,k+1..2*k+1]    
  } 
  ser = sqrt(diagonal(Var))
  tstat = be:/ser
  pv = 2:*(1:-normal(abs(tstat)))
  display("")
  printf("{txt}{space 13}{c |}      est.     s.e.(rob)    t-stat.    p-value\n")  
  printf("{hline 13}{c +}{hline 50}\n")
  for(j=1;j<=k+1;j++) printf("{txt}%12s {c |} {res}%10.0g %10.0g %10.0g %10.0g\n", varlist[j], be[j], ser[j], tstat[j], pv[j])
  display("")
// store arguments  
  st_global("e(cmd)", "cquadpseudo")
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

