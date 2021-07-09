*! version 1.0.0   15Aug2007
program blinding, rclass
	version 10

syntax namelist [,BWEIght(namelist) ANCillary(namelist) ANCWeight(namelist) LEVel(cilevel)] 

confirm matrix `namelist'
mata:Inp=st_matrix("`namelist'")
mata:size=cols(Inp)

if(colsof("`bweight'")==3){
	di in r "input weight is not acceptable for 2x3 case"
	exit(503)
}

if ("`bweight'"!="") {
	mata: W_i=st_matrix("`bweight'")
} 
else{
	if (colsof("`namelist'")==3){
		mata: W_i=(1,1,0\1,1,0)
	}

	else{
		if ( colsof("`namelist'")==5){
		mata: W_i=(1,0.5,0.5,1,0\1,0.5,0.5,1,0)
		}
		else{
			di in r "input data invalid" 
			exit(503)
		}
	}
}

if ("`ancillary'"!="") {
	mata: An=st_matrix("`ancillary'")
} 
else{
	mata: An=J(2,3,0)
}

if("`ancweight'"!="") {
	mata: W_a=st_matrix("`ancweight'")
} 
else{
	mata: W_a=J(2,3,0)
} 

if("`jweight'"!="") {
	mata: W=st_matrix("`jweight'")
} 
else{
	mata: W=J(2,3,0)
}

scalar LL=`level'
if("`level'"!="") {
	mata: Lev=st_numscalar("LL")
}


mata:chinput(Inp,W_i,An,W_a,W,Lev,size)
mata:za=invnormal(1-(1-Lev/100)) 
mata:bitop(Inp,W_i,An,W_a,W,size,za)

if(colsof(`namelist')==3){
	mat b=[Index_Jame,Index_NewBI1,Index_NewBI2]
	matrix colnames b=James Bang_drug2x3 Bang_plabo2x3
	mat vv=[Var_Jame,Var_NewBI1,Var_NewBI2]
	mat V=diag(vv)
	matrix rownames V=James Bang_drug2x3 Bang_plabo2x3
	matrix colnames V=James Bang_drug2x3 Bang_plabo2x3
}
if(colsof(`namelist')==5){
	mat b=[Index_Jame,Index_NewBI1,Index_NewBI2,Index_NewBIL1,Index_NewBIL2]
	matrix colnames b=James Bang_drug2x3 Bang_plabo2x3 Bang_drug2x5 Bang_plabo2x5
	mat vv=[Var_Jame,Var_NewBI1,Var_NewBI2,Var_NewBIL1,Var_NewBIL2]
	mat V=diag(vv)
	matrix rownames V=James Bang_drug2x3 Bang_plabo2x3 Bang_drug2x5 Bang_plabo2x5
	matrix colnames V=James Bang_drug2x3 Bang_plabo2x3 Bang_drug2x5 Bang_plabo2x5
}

*ereturn post b V
return matrix b = b
mat var = vecdiag(V)
return matrix  var = var
//ereturn display, level(`level')

di ""
di as text "Tests Results"
di as text "{hline 79}"
di as text "       Methods{c |}     Index.   Std. Err.     z    P_Value    [`level'% Conf. Interval] " 
di as text "{hline 14}{c +}{hline 64}"
di as text " James' Method{c |}" as result   _col(17)%9.0g Index_Jame   _col(29)%9.0g sqrt(Var_Jame)   _col(41)%5.0g zj  _col(49)%5.0g pj _col(60)%9.0g cj1 _col(71)%9.0g cj2
di as text " Bang_Drug 2x3{c |}" as result   _col(17)%9.0g Index_NewBI1 _col(29)%9.0g sqrt(Var_NewBI1) _col(41)%5.0g z1  _col(49)%5.0g p1 _col(60)%9.0g cd1 _col(71)%9.0g cd2
di as text "Bang_plabo 2x3{c |}" as result   _col(17)%9.0g Index_NewBI2 _col(29)%9.0g sqrt(Var_NewBI2) _col(41)%5.0g z2  _col(49)%5.0g p2 _col(60)%9.0g cp1 _col(71)%9.0g cp2

if (colsof(`namelist')==3){
di as text "{hline 79}"
}
else{
di as text " Bang_Drug 2x5{c |}" as result   _col(17)%9.0g Index_NewBIL1 _col(29)%9.0g sqrt(Var_NewBIL1) _col(41)%5.0g zL1  _col(49)%5.0g pL1 _col(60)%9.0g cdL1 _col(71)%9.0g cdL2
di as text "Bang_plabo 2x5{c |}" as result   _col(17)%9.0g Index_NewBIL2 _col(29)%9.0g sqrt(Var_NewBIL2) _col(41)%5.0g zL2  _col(49)%5.0g pL2 _col(60)%9.0g cpL1 _col(71)%9.0g cpL2
di as text "{hline 79}"
}

end

************************************************************************************************************
mata:

void chinput(Inp,W_i,An,W_a,W,Lev,size){
	
if ( rows(Inp)!=2 | (cols(Inp)!=3 & cols(Inp)!=5) ){
	stata(`" di in r `"input data invalid"' "')
	exit(503)
}

if ( rows(W_i)!=2 | cols(W_i)!=cols(Inp) ){
	stata(`" di in r `"input weight invalid"' "')
	exit(503)
}

if ( cols(W_i)==5 ){
	if (W_i[1,1]!=W_i[1,4] | W_i[1,2]!=W_i[1,3] | W_i[2,1]!=W_i[2,4] | W_i[2,2]!=W_i[2,3] ) {
		stata(`" di in r `"input weight doesn't satisfy the necessary conditions. Type help blinding"' "')
		exit(503)
	}

	if (W_i[1,5]!=0 | W_i[2,5]!=0){
		stata(`" di in r `"input weight element should be 0 in DK response"' "')
		exit(503)
	}

	if (W_i[1,1]<0 | W_i[1,1]>1 | W_i[1,2]<0 | W_i[1,2]>1 |W_i[2,1]<0 | W_i[2,1]>1 | W_i[2,2]<0 | W_i[2,2]>1 ){
		stata(`"di in r `"input weight element should be number between 0 to 1"' "')
		exit(503)
	}

	if (W_i[1,1]<W_i[1,2] | W_i[2,1]<W_i[2,2] ) {
		stata(`" di in r `"weights invalid"' "')
		exit(503)
	}
}


if ( rows(An)!=2 | cols(An)!=3 ){
	stata(`" di in r `"ancillary data invalid"' "')
	exit(503)
}

if ( sum(An)>0 & (Inp[1,size]!=sum(An[1,]) | Inp[2,size]!=sum(An[2,])) ){
	stata(`" di in r `"ancillary data invalid"' "')
	exit(503)
}

if ( rows(W_a)!=2 | cols(W_a)!=3 ){
	stata(`" di in r `"ancillary data weight invalid"' "')
	exit(503)
}

if ( W_a[1,1]!=W_a[1,2] | W_a[2,1]!=W_a[2,2] ){
	stata(`" di in r `"ancillary weight doesn't satisfy the necessary conditions. Type help blinding"' "')
	exit(503)
}

if ( W_a[1,1]>W_i[1,2] | W_a[2,1]>W_i[2,2] | W_a[1,1]<0 | W_a[2,1]<0 | W_a[1,3]!=0 | W_a[2,3]!=0 ){
	stata(`" di in r `"ancillary weight invalid"' "')
	exit(503)
}

if ( W[1,3]<W[1,2] | W[1,2]<W[1,1] | W[2,3]<W[2,1] | W[2,1]<W[2,2] | W[1,3]>1 | W[1,1]<0 | W[2,3]>1 | W[2,2]<0 ){
	stata(`" di in r `"James' weight invalid"' "')
	exit(503)
}

}


/*     James' method      */
real matrix James(NewInp,W,N,za){
	if (W==J(2,3,0)){
	W = (0,0.5,1\0.5,0,1)
	}
	
	P=NewInp:/N

	Pdk=sum(P[,3])
	Pdo=1/(1-Pdk)*sum((W:*P)[(1,2),(1,2)])
	Pde=1/(1-Pdk)^2*sum((W:*(rowsum(P)-P[,3])*colsum(P))[(1,2),(1,2)])
	
	Kd=(Pdo-Pde)/Pde

	BI=(1+Pdk+(1-Pdk)*Kd)/2  

	PPT=J(2,2,.)
	for (i=1;i<=2;i++) {
		for (j=1;j<=2;j++) {
			PPT[i,j]=(1-Pdk)^2*P[i,j]*(W[i,j]*(1-Pdk)-(1+Kd)* ///
					(sum(P[,1])*W[i,1]+(sum(P[1,])-P[1,3])*W[1,j]+sum(P[,2])*W[i,2]+(sum(P[2,])-P[2,3])*W[2,j]))^2

		}
	}
	varBI=(sum(PPT)/(4*Pde^2*(1-Pdk)^4)+Pdk*(1-Pdk)-(1-Pdk)*(1+Kd)*(Pdk+(1-Pdk)*(1+Kd)/4))/N
	stdBI=sqrt(varBI)

	ZJ=(BI-0.5)/stdBI
	PJ=normal(ZJ)
 	CJ1=BI-stdBI*za
	CJ2=BI+stdBI*za

st_numscalar("Index_Jame",BI)
st_numscalar("Var_Jame",varBI)
st_numscalar("zj",ZJ)
st_numscalar("pj",PJ)
st_numscalar("cj1",CJ1)
st_numscalar("cj2",CJ2)
}
 
/*        2x3 matrix         */
real matrix Bi(NewInp,W_i,An,W_a,N,za){
		
		P_i=J(2,3,.)
		P_i[1,]=NewInp[1,]:/sum(NewInp[1,])
		P_i[2,]=NewInp[2,]:/sum(NewInp[2,])
		

		P_a=J(2,3,.)
		P_a[1,]=An[1,]:/sum(NewInp[1,]) 
		P_a[2,]=An[2,]:/sum(NewInp[2,]) 

		PP=((P_i[1,1],P_a[1,1],P_a[1,2],P_i[1,2])',(-P_i[2,1],-P_a[2,1],-P_a[2,2],-P_i[2,2])')

		NewBI=J(1,2,.)
		VarNewBI=J(1,2,.)
		if (An!=J(2,3,0) & W_a==J(2,3,0)){
			W_a=(0.25,0.25,0\0.25,0.25,0)
		}		
		
		W_s=W_i

		if (cols(W_s)==5 | W_s==J(2,3,0)){
			W_s=(1,1,0\1,1,0)
		}


		L=(W_s[,1],W_a[,1],-W_a[,2],-W_s[,2])


		NewBI[1]=L[1,]*PP[,1]
		NewBI[2]=L[2,]*PP[,2]

		VarNewBI[1]=(L[1,]*(diag(PP[,1])-PP[,1]*PP[,1]')*L[1,]')/sum(NewInp[1,])
		VarNewBI[2]=(L[2,]*(diag((-1)*PP[,2])-PP[,2]*PP[,2]')*L[2,]')/sum(NewInp[2,])


		stdNewBI=sqrt(VarNewBI)


		ZN=NewBI:/stdNewBI
      		PN=1:-normal(ZN)
		CN1=NewBI-stdNewBI*za
		CN2=NewBI+stdNewBI*za

		st_numscalar("Index_NewBI1",NewBI[1])
		st_numscalar("Var_NewBI1",VarNewBI[1])
		st_numscalar("Index_NewBI2",NewBI[2])
		st_numscalar("Var_NewBI2",VarNewBI[2])
		st_numscalar("z1",ZN[1])
		st_numscalar("z2",ZN[2])
		st_numscalar("p1",PN[1])
		st_numscalar("p2",PN[2])
		st_numscalar("cd1",CN1[1])
		st_numscalar("cd2",CN2[1])
		st_numscalar("cp1",CN1[2])
		st_numscalar("cp2",CN2[2])
}


/*       2x5 with ancillary data       */
real matrix Bii(Inp,W_i,An,W_a,za){
	
		P_i=J(2,5,.)
		P_i[1,]=Inp[1,]:/sum(Inp[1,])
		P_i[2,]=Inp[2,]:/sum(Inp[2,])
		

		P_a=J(2,3,.)
		P_a[1,]=An[1,]:/sum(Inp[1,]) 
		P_a[2,]=An[2,]:/sum(Inp[2,]) 

		PP=((P_i[1,1],P_i[1,2],P_a[1,1],P_a[1,2],P_i[1,3],P_i[1,4])',(-P_i[2,1],-P_i[2,2],-P_a[2,1],-P_a[2,2],-P_i[2,3],-P_i[2,4])')


		BI_long=J(1,2,.)
		VarBI_long=J(1,2,.)

		if (An!=J(2,3,0) & W_a==J(2,3,0)){
			W_a=(0.25,0.25,0\0.25,0.25,0)
		}		

		if (W_i==J(2,5,0)){
			W_i=(1,0.5,0.5,1,0\1,0.5,0.5,1,0)
		}


		L=(W_i[,1],W_i[,2],W_a[,1],-W_a[,2],-W_i[,3],-W_i[,4])


		BI_long[1]=L[1,]*PP[,1]
		BI_long[2]=L[2,]*PP[,2]

		VarBI_long[1]=(L[1,]*(diag(PP[,1])-PP[,1]*PP[,1]')*L[1,]')/sum(Inp[1,])
		VarBI_long[2]=(L[2,]*(diag((-1)*PP[,2])-PP[,2]*PP[,2]')*L[2,]')/sum(Inp[2,])
		stdBI_long=sqrt(VarBI_long)
	

	ZNL=BI_long:/stdBI_long
      PNL=1:-normal(ZNL)
	CNL1=BI_long-stdBI_long*za
	CNL2=BI_long+stdBI_long*za

st_numscalar("Index_NewBIL1",BI_long[1]) 
st_numscalar("Var_NewBIL1",VarBI_long[1])
st_numscalar("Index_NewBIL2",BI_long[2])
st_numscalar("Var_NewBIL2",VarBI_long[2])
st_numscalar("zL1",ZNL[1])
st_numscalar("zL2",ZNL[2])
st_numscalar("pL1",PNL[1])
st_numscalar("pL2",PNL[2])
st_numscalar("cdL1",CNL1[1])
st_numscalar("cdL2",CNL2[1])
st_numscalar("cpL1",CNL1[2])
st_numscalar("cpL2",CNL2[2])

}


void bitop(real matrix Inp,real matrix W_i,real matrix An,real matrix W_a,real matrix W,real scalar size,real scalar za){
	if (size==3) {
		NewInp=Inp
 		N=sum(NewInp)
 
		James(NewInp,W,N,za)
		Bi(NewInp,W_i,An,W_a,N,za)
      }
      
	if (size==5){
		NewInp=J(2,3,0)
		NewInp[,1]=Inp[,1]+Inp[,2]
		NewInp[,2]=Inp[,3]+Inp[,4]
		NewInp[,3]=Inp[,5]
		N=sum(NewInp)
		
		James(NewInp,W,N,za)
		Bi(NewInp,W_i,An,W_a,N,za)
		Bii(Inp,W_i,An,W_a,za)

	}
} 

end  


   
