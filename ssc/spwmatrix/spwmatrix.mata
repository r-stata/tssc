*! Mata code for spwmatrix
*! Copyright by P. wilner Jeanty. But, may be distributed for free with proper credit.
*! February 10, 2010
*! Note: Very large datasets may be challenging depending on memory availability
version 9.2
mata: 
mata drop *()
mata set matastrict on	
void CalcSPweightM(string scalar xxs, | string scalar ftouse)  {
	external real scalar spwmatrix_clow, spwmatrix_chigh,  spwmatrix_Alfa,
	spwmatrix_rep0, spwmatrix_rep1, spwmatrix_rep2, spwmatrix_rep3, spwmatrix_beta, spwmatrix_soc
	external real matrix w
	real scalar i, j, k, toeig, alp, N, torad, matr, dist, rowsw, 
	  ind, zero_rows, dlat, dlong, tok, r, a, c, fh
	string scalar disttype, Towrite1, Towrite2, noz, forrownumb
	real colvector Eij, mid, d, idvar, spwmatrix_eigw
 	real matrix A, B, wgt
 
	pointer(real scalar) rowvector p1
	pointer(string scalar) rowvector p2
	pointer(real vector) scalar p3

	p1=(&spwmatrix_clow, &spwmatrix_chigh, &spwmatrix_Alfa, &spwmatrix_rep0, &spwmatrix_rep1, 
	&spwmatrix_rep2, &spwmatrix_rep3, &spwmatrix_beta, &spwmatrix_soc)
	p2=(&disttype, &Towrite1, &Towrite2)
	p3=(&spwmatrix_eigw)

	if (args()==1) {
		A=st_data(., tokens(xxs)) 
		N=colmax(A[,1]); w=J(N,N,0)
		i=1
		j=i+1 
		while (i<=rows(A) & j<=rows(A)) {
			k=1; 	a=A[i,1]
			if (A[i,2]!=0) {
				while (k<=A[i,2]) {
					c=A[j,k]; w[a,c]=1
					k++
				}
			}
			if (A[i,2]==0) {
				i++; j++
			}
			else{  
			 	i=i+2; j=j+2
			}
		}
	}
	if (args()==2)  { 
	   A=st_data(., tokens(xxs), ftouse)
	   w=J(N=rows(A), N, 0)
	   if (*p1[9]==0) { 
			if (st_local("wtype")!="") {
				*p2[1]=st_local("wtype")
				if (*p2[1]=="inv") alp=*p1[3]
				else if (*p2[1]=="econ" | *p2[1]=="invecon") Eij=st_data(., st_local("econvar"), ftouse)
			}
		tok=0
		if (st_local("knn")!="") {
			k=strtoreal(st_local("knn"))
			if (k<=0 | k>=rows(A)) {
				""
				displayas("err")
				printf("Value supplied for option knn(#) invalid.\n")
				exit(198)
			}
			else tok=1
		}
		c=J(N, N, 0)
		if (st_local("cart")!="") {		
			for (i=1; i<=rows(A); i++) {
				d = sqrt((A[,1]:-A[i,1]):^2 + (A[,2]:-A[i,2]):^2)				
				c[i,]=d'		
			}
		}
		else { // can be improved
		// Convert degrees into radians
			torad=pi()/180
			A=A:*torad ; B=A; r=strtoreal(st_local("rad"))
			for (i=1; i<=rows(A); i++) {
				for (j=1; j<=rows(B); j++) {
				   if (i!=j) {		
					dlat = B[j,1]:- A[i,1]
					dlong = B[j,2]:- A[i,2]
					if (colmissing(dlong):==0 & dlong:>pi()) dlong=(B[j,2]:- A[i,2]:-360)
					if (dlong:<-pi()) dlong=(B[j,2]:- A[i,2]:+ 360)
					a = (sin(dlat/2)):^2 :+ cos(A[i,1]):*cos(B[j,1]):*(sin(dlong:/2)):^2
					matr=1,sqrt(a)
					dist = 2 * asin(rowmin(matr))
					c[i,j]=r*dist 
				  }		
				}				
			}
		}
		for (i=1; i<=rows(w); i++) {
			if (tok==1) {
				c[i,i]=. // so that the zeros on the diagonal are not taken for mins
				mid=.; wgt=.
				minindex(c[i,], k, mid, wgt)
				w[i,mid[|1\k|]]=J(1, k, 1) // minindex is good at handling missing values, so no bother for the diagonal elements of c			
			}
			else {
				for (j=1; j<=cols(w); j++) {
					if (i!=j) {
						if (*p2[1]=="bin") {
							if (c[i,j]>*p1[1] & c[i,j]<=*p1[2]) w[i,j]=1
						}				
						else if (*p2[1]=="inv") {
							if (st_local("dband")!="") {
								if (c[i,j]>*p1[1] & c[i,j]<=*p1[2]) w[i,j]=1/(c[i,j]^alp)	
							}
							else w[i,j]=1/(c[i,j]^alp) // distance-based spatial weights matrix without a cutoff not recommended but provided									 					
						}
						else if (*p2[1]=="econ") w[i,j]=Eij[i]*Eij[j]*exp(-*p1[8]*c[i,j])
						else if (*p2[1]=="invecon") w[i,j]=(1/abs(Eij[i]-Eij[j]))*exp(-*p1[8]*c[i,j])
					}
				}
			}
		}
	    } // end of spwmatrix_soc==0
	    else { 
		if (st_local("wtype")=="socnet") {	
			idvar=st_data(., st_local("idvar"), ftouse)
			A=A,idvar
			for (i=1; i<=rows(A); i++) {
				for (j=i+1; j<=rows(A); j++) {
					if (A[j,1]==A[i,1]) {
						w[A[i,2],A[j,2]]=1
						w[A[j,2],A[i,2]]=1
					}
				}
			}
		}
		else if (st_local("wtype")=="socecon") {
			for (i=1; i<=rows(A); i++) {
				w[i,]=(1:/abs(A:-A[i]))'
				w[i,i]=0				
			}
		}
	  }		
	} // end of if args()==2
	toeig=0  
	if (anyof(rowsum(w), 0)) {
		toeig=1  // will never happen for knn weights matrix, e.i tok==1
		zero_rows=sum(rowsum(w):==0) // Count how many rows whose elements sum up to zero
		if (zero_rows==N) {
			""
                  errprintf("You have attempted to create or import a spatial weights matrix with zero-entries; no further action was taken.\n")
			""
                  errprintf("You may need to revise you weights structure criteria.\n")
			""
			displayas("err")
                  printf("If this is a distance-based weights matrix, use {help nearstat} for distance information.\n")
                  _error(0)			
           }
	}
	if (st_local("rowstand")!="") {
		if (toeig) {
			forrownumb=strofreal(zero_rows)
                  display("")
                  display("N.B.: " + (zero_rows==1? "Elements of one row sum up to zero, " : "Elements of " + forrownumb + " rows sum up to zero, ") +
				  "weighting matrix was not row-standardized")             
                  display("")
                  display((zero_rows==1? " This row is:" : " These rows are:"))
			j=0
                  for (i=1; i<=rows(rowsum(w)); i++) {
                  	if (rowsum(w)[i]==0) {
					i; j=j+1
				}
				if (j==zero_rows) i=rows(rowsum(w)) // break would do as well, to avoid continuing searching
                  }
			if (st_local("using")=="") {
				stata(`"di " You might want to rethink your weights structure criteria.""')
				if (st_local("dband")!="") {
					stata(`"di " Use {help nearstat} to obtain distance information and a neighbor count""')
					stata(`"di " for your distance-cutoff or distance band.""')
				}
			}
			else { 
				stata(`"di " You might want to use {help spwmatfill} to assign to observations with no contiguous neighbors""')
				stata(`"di " their first nearest neighbors as their sole neighbors""')
			}
		}
        else w=w:/rowsum(w) // Perform row-standardization, but note that matrix operation more efficient than loop     
    }
	else if (st_local("rowstand")=="") {
		if (toeig) {
			""
			if (*p2[1]=="econ" | *p2[1]=="invecon") {
				forrownumb=strofreal(zero_rows)
                display("")
				display("N.B.: " + (zero_rows==1? "Elements of one row sum to zero, " : "Elements of " + forrownumb + " sum to zero, ") +
				"weight matrix was not row-standardized")             
				display("")
				display((zero_rows==1? " This row is:" : " These rows are:"))
			}
			else {
				display(" N.B.: " + (zero_rows==1? "One observation has no neighbors" : " There are " + 
				strofreal(zero_rows) +  " observations with no neighbors."))
				""
                display((zero_rows==1? " This obseravtion is:" : " These observations are:"))
			}
			j=0
			for (i=1; i<=rows(rowsum(w)); i++) {
				if (rowsum(w)[i]==0) {
					i; j=j+1
				}
				if (j==zero_rows) i=rows(rowsum(w))
            }
			""
			if (st_local("using")=="") {
				stata(`"di " You might want to rethink your weights structure criteria.""')
				if (st_local("dband")!="") {
					stata(`"di " Use {help nearstat} to obtain distance information and a neighbor count""')
					stata(`"di " for your distance cut-off.""')
					stata(`"di " Weights matrix may not be useful.""')
				}
			}
			else { 
				stata(`"di " You might want to use {help spwmatfill} to assign to observations with no contiguous neighbors""')
				stata(`"di " their nearest neighbors as their sole neighbors""')
			}
		}
	}
	rowsw=rows(w); ind=0
	if (c("flavor")=="Small" & rowsw>40) ind=1
	if (c("flavor")=="Intercooled") {
		if (c("SE")==0 & c("MP")==0 & rowsw>800) ind=2
		if ((c("SE")==1 | c("MP")==1) & rowsw>11000) ind=3
	}
	if (ind==0) {
		if (st_local("mataf")=="") st_matrix(st_local("wname"), w)
		else {
			*p2[2]=(*p1[5]==1? "rw" : "w")	
			fh = fopen(st_local("wname"), *p2[2])
			fputmatrix(fh, w)
			fclose(fh)
		}
	}
	if (ind!=0) {
		if (st_local("mataf")!="") {
			*p2[2]=(*p1[5]==1? "rw" : "w")	
			fh = fopen(st_local("wname"), *p2[2])
			fputmatrix(fh, w)
			fclose(fh)
		}
		else {		
	  		fh = fopen(st_local("wname") + "_n", "rw")
			fputmatrix(fh, w)
			fclose(fh)
		}		
	}
	if (st_local("matlab")!="") spwmatrix_xport(st_global("outname"), strofreal(w), *p1[4])

	if (st_local("eignval")!="" | st_local("eignvar")!="") {
		if (toeig==1) {
			""
			"  Also, because one or more locations do not have any neighbors, eigenvalues were not calculated"
			""  
			"  Most importantly, weights matrix may not be useful"
		}	
		else {
	  	   if (st_local("eignval")!="")  {
			if (issymmetric(w)) {
				*p3=_symeigenvalues(w) // row-standardized w may or may not be symmetric
				*p3=*p3'
			}
			else	{
				*p3=eigenvalues(w)  
				*p3=Re(*p3); *p3=*p3'
			}
			if (ind==0) {
				if (st_local("mataf")=="") st_matrix(st_local("eignval"), *p3)
				else {
					*p2[3]=(*p1[6]==1? "rw" : "w")
					fh = fopen(st_local("eignval"), *p2[3])
					fputmatrix(fh, *p3)
					fclose(fh)
				}				
			}
			if (ind!=0) {
				if (st_local("mataf")!="") {
					*p2[3]=(*p1[6]==1? "rw" : "w")
					fh = fopen(st_local("eignval"), *p2[3])
					fputmatrix(fh, *p3)
					fclose(fh)
				}				
				else {
	  				fh = fopen(st_local("eignval") + "_n", "rw")
					fputmatrix(fh, *p3)
					fclose(fh)
				}
			}		
	   	 }
		 if (st_local("eignvar")!="") {
			if (st_local("eignval")!="") {
				if (args()!=1) st_store(., st_addvar("double", st_local("eignvar")), ftouse, *p3)
				else if (args()==1 & st_local("mataf")=="") {
					fh = fopen("spwmatrix_tempf", "w")
					fputmatrix(fh, *p3)
					fclose(fh)
				}
			}		
			else if (st_local("eignval")=="") { 
				if (issymmetric(w)) {
					*p3=symeigenvalues(w) 
					*p3=*p3'
				}		
				else	{
					*p3=eigenvalues(w)
					*p3=Re(*p3); *p3=*p3'
				}				
				if (args()!=1) st_store(., st_addvar("double", st_local("eignvar")), ftouse, *p3)
				else {
					fh = fopen("spwmatrix_tempf", "w")
					fputmatrix(fh, *p3)
					fclose(fh)
				}
			}
	 	}
	   } // for else
	}
	st_numscalar("spwmatrix_rowst", toeig)               
	st_numscalar("spwmatrix_forst", ind)
	if (args()==2 & st_local("gwt")!="") {
		noz="nozero"
		w=MakeGWT(w,noz)
		spwmatrix_xport(st_global("outgwt"), strofreal(w), *p1[7])
	} 
}
void spwmatrix_xport(string scalar jnct, string matrix g, real scalar torep) {  
    string scalar line, wtod, delim
    real scalar i, j, fho
	wtod=(torep==1? "rw" : "w")
	delim = char(9)
    fho = fopen(jnct, wtod)
    for (i=1; i<=rows(g); i++) {
		line = J(1,1,"")
        for (j=1; j<=cols(g); j++) {
			line = line + g[i,j]
			if (j<cols(g)) line = line + delim
		}
		fput(fho, line)
	}
    fclose(fho)
} 
void spwmatrix_Connect() {	
	real scalar spa, n
	real vector neighb
	string scalar neighbr
	pragma unused neighbr
	external real matrix w
	n=rows(w)
	spa=(sum(w:!=0)/(n*n))*100
	neighb=rowsum(w:!=0)
	st_numscalar("spwmatrix_spa", spa)
	st_store(., st_addvar("double", neighbr=st_tempname()), neighb)
}	
void spwmatrix_getfile() {
	real vector spwmatrix_feignv
	real scalar fh
	if (st_local("eignval")!="" & st_local("mataf")!="") fh = fopen(st_local("eignval"), "r")	
	else fh = fopen("spwmatrix_tempf", "r")
      spwmatrix_feignv=fgetmatrix(fh)
      fclose(fh)
	st_store(., st_addvar("double", st_local("eignvar")), spwmatrix_feignv)	
}
real matrix MakeGWT(real matrix wght, | string scalar noz) {	
	pragma unused noz
 	real scalar n, N, j, g, i
	real matrix distm	
	n=rows(wght)
	distm=J(n*n, 3, 0)
	N=rows(distm)
	j=1
	g=0
	for (i=1; i<=N; i++) {
		g++
		distm[i,2]=g
		if (i<=j*n) distm[i,1]=j
		if (mod(i,n)==0) {
			j++; g=0
		}
	}
	distm[.,3]=colshape(wght,1)
	for (i=1; i<=N; i++) {
		if (distm[i,1]==distm[i,2]) distm[i,3]=0
	}
	if (args()==2)distm=select(distm, distm[.,3]:>0) // remove the zeros
	return(distm)
}
  mata mlib create lspwmatrix, dir(PLUS) replace
  mata mlib add lspwmatrix *(), dir(PLUS)
  mata mlib index
end

