*! netreg 1.0.0 01Aug2018
*! author: Dayou Luo 
*! version: 1.0.0	01Aug2018
program define netreg2, sortpreserve eclass
version 12.0
/* syntax Y X1 X2 Node1 Node2*/
/*suppose that data are saved in colums*/
/*undirected for undirected net*/
/*withnode indicates node is contained in varlist*/
/*tol and maxit are used for reweighted iteration
tol is tolerance, maxit is the maximum times of iteration accepeted*/
/*n_total is the size of item in the net table*/
/*cilevel is the confidence level. The confidence interval depends on a degrees of freedom which is kind of suspicious*/
syntax varlist(min=1 numeric) [if] [in]  [, undirect withnode reweight tol(real 0.001) maxit(integer 50) n_total(integer 0) cilevel(integer 95)]
marksample touse
tokenize "`varlist'"
quietly foreach v in `varlist' {
	confirm numeric variable `v'
}
if "`withnode'" == "" {
	mata: node = 0
	local node = 0
}
else{
	mata: node = 1
	local node = 1
}
if "`reweight'" == ""{
	mata: simple = 1
}
else{
	mata: simple = 0
}
if "`undirect'" == ""{
	mata: directed = 1
}
else{
	mata: directed = 0
}
mata: netreg("`varlist'",node,simple,directed,"`touse'")
/*change names of b and V*/
if `node' == 1 {
	local WC: word count `varlist'
	local name "cons"
	local WC =`WC'-2
	forvalues i=2/`WC'{
		local wd: word `i' of `B'
		local name "`name' ``i''"
	}
}
else{
	local WC: word count `varlist'
	local name "cons"
	forvalues i=2/`WC'{
		local wd: word `i' of `B'
		local name "`name' ``i''"
	}
}
matrix colnames b=`name'
matrix colnames V=`name'
matrix rownames V=`name'
local df=df
local N=N
ereturn post b V, depname('1') obs(`N') esample(`touse')
ereturn local depvar "`1'"
ereturn local cmd "netreg"
if `cilevel'<10 | `cilevel'>99 {
	display as error "level() must be between 10 and 99 inclusive."
	exit 198
}
ereturn display, level(`cilevel')
end

mata:
mata clear

struct node{
	/*
	This is a structure for nodes.
	Ni is a matrix with 4 rows, saving the nodes for
	residuals of type i.
	There are N different type of residuals.
	For undirected table, N=2
	else N=5.Assume Phi[6]=0
	*/
	real matrix N1,N2,N3,N4,N5
	real scalar N,n_tot
}

struct row_list{
	/*
	 Row_list is similar to the structure node. The only
	 difference is that, row_list uses dyad to save node.
	 Mi is a matrix with 2 rows.
	 */
	 real matrix M1,M2,M3,M4,M5
	 real scalar N,L,Dyad_size,n_tot
}
function lower_tri(A){
/*lower_tri is used to obtain the lower triangle of matrix A*/
	temp1=(A[2,]:<A[1,]):*(A[3,]:>A[4,])
	A=select(A,temp1)
	return(A)
}		

struct node function node_set(n_tot,directed){
	/* function node.set will provide the coordinate
		of different types of residuals (overlapping
		 dyads pairs)when there is no missing data.
		 n_tot is the total number of interactive items.
		 directed is 0 or 1
	*/
	struct node scalar N
	N.n_tot=n_tot
	if(directed == 1){
		temp1=J(1,n_tot,(1::n_tot))
		temp2=rowshape(temp1,1)
		temp3=J(1,n_tot,(1..n_tot))  
		N.N1=(temp2\temp3\temp2\temp3)
		temp4=mod(((1..n_tot^2):-1),(n_tot+1))
		/*eliminate (i,i)*/
		N.N1=select(N.N1,temp4)
		N.N2=J(4,1,.)
		N.N3=J(4,1,.)
		N.N4=J(4,1,.)
		N.N5=J(4,1,.)/*make interation convenient*/
		for(i=1;i<=n_tot;i++){
			if(i<n_tot){
				temp1=J(1,n_tot-i,i)
				temp2=(i+1)..n_tot
				N.N2=(N.N2,(temp1\temp2\temp2\temp1))
			}
			c1=J(1,(n_tot-1)*(n_tot-2)/2,i)
			c2=J(1,1,.)
			c3=J(1,1,.)
			temp=n_tot-2
			for(j=1;j<n_tot;j++){
				if(i!=j){
					if(i==n_tot&j==n_tot-1) break
					c2=(c2,J(1,temp,j))
					temp1=(j+1)..n_tot
					temp3=select(temp1,temp1:-i)
					c3=(c3,temp3)
					temp=temp-1
				}
			}
			c2=select(c2,colnonmissing(c2))
			c3=select(c3,colnonmissing(c3))
			N.N3=(N.N3,(c1\c2\c1\c3))
			N.N4=(N.N4,(c2\c1\c3\c1))
			N.N5=(N.N5,(c1\c2\c3\c1),(c2\c1\c1\c3))
		}
		N.N2=select(N.N2,colnonmissing(N.N2))
		N.N3=select(N.N3,colnonmissing(N.N3))
		N.N4=select(N.N4,colnonmissing(N.N4))
		N.N5=select(N.N5,colnonmissing(N.N5))
		N.N=5
		return(N)
	}
				



	else{
		N=node_set(n_tot,1)
		N.N1=lower_tri(N.N1)
		N.N2=lower_tri(N.N2)
		N.N3=lower_tri(N.N3)
		N.N4=lower_tri(N.N4)
		N.N5=lower_tri(N.N5)
		temp=(N.N2,N.N3,N.N4,N.N5)'
		N.N2=temp'
		N.N3=J(4,1,.)
		N.N4=J(4,1,.)
		N.N5=J(4,1,.)
		N.N=2
		return(N)
	}
}
function dyad(i_in,j_in,n_tot,directed){
/* this function gives a integer coordinate to a node (i,j)*/
/*i_in j_in should be a col matrix*/
	if(directed ==1) {
		dyad_result= ((i_in:-1)+(j_in:-1):*(n_tot-1)+ (j_in:>i_in)):*(i_in!=j_in)
	}
	else{
		if(cols(i_in)==1){
			All_node=(i_in,j_in)
			i_in=rowmax(All_node)
			j_in=rowmin(All_node)
		}
		else{
			All_node=(i_in\j_in)
			i_in=colmax(All_node)
			j_in=colmin(All_node)
		}
		dyad_result=((i_in-(j_in:*j_in:*0.5)+j_in:*(n_tot-0.5)):-n_tot):*(i_in!=j_in)
	}
	return(dyad_result)
}

function nodetocoordinate(N,Map,n_tot,directed){
	L=cols(N)
	M=J(2,1,.)
	Dyad_N=(dyad(N[1,],N[2,],n_tot,directed)\dyad(N[3,],N[4,],n_tot,directed))
	for(i=1;i<=L;i++){
		M=(M,(asarray(Map,Dyad_N[1,i])\asarray(Map,Dyad_N[2,i])))
	}
	M=select(M,colnonmissing(M))
	return(M)
}
struct row_list scalar function nonmissing_list(struct node scalar N){
/*no missing data, data is ranged according to dyads*/
/*i.e. sort by colums first and then by rows*/
	struct row_list scalar M
	M.N=N.N
	n_tot=N.n_tot
	M.n_tot=n_tot
	if(N.N<4){
		Sizeofdyad=(n_tot-1)*n_tot/2
		directed=0
	}
	else{
		Sizeofdyad=(n_tot-1)*n_tot
		directed=1
	}
	M.L=Sizeofdyad
	M.Dyad_size=Sizeofdyad
	M.M1=(dyad(N.N1[1,],N.N1[2,],n_tot,directed)\dyad(N.N1[3,],N.N1[4,],n_tot,directed))
	M.M2=(dyad(N.N2[1,],N.N2[2,],n_tot,directed)\dyad(N.N2[3,],N.N2[4,],n_tot,directed))
	if(directed==0) return(M)
	M.M3=(dyad(N.N3[1,],N.N3[2,],n_tot,directed)\dyad(N.N3[3,],N.N3[4,],n_tot,directed))
	M.M4=(dyad(N.N4[1,],N.N4[2,],n_tot,directed)\dyad(N.N4[3,],N.N4[4,],n_tot,directed))
	M.M5=(dyad(N.N5[1,],N.N5[2,],n_tot,directed)\dyad(N.N5[3,],N.N5[4,],n_tot,directed))
	return(M)
}






struct row_list scalar function missing_list( struct node scalar N,Dyad_data){
/* In this function, we produce the subscripts version of scalar N with which
	we can get data i from Residual[i] directly*/
/* the substract method isn't included */
/* For inputs, N is the scalar containing subscripts for each type of overlap,
	subscripts is corresponding to row subscripts each data*/
/* Information of missing value should be used to construct the missed corner 
   of matrix Omega*/
/* Map is map between dyads and subscripts*/
	L=length(Dyad_data)
	n_tot=N.n_tot
	if(N.N<4){
		Sizeofdyad=(n_tot-1)*n_tot/2
		directed=0
	}
	else{
		Sizeofdyad=(n_tot-1)*n_tot
		directed=1
	}
	Map=asarray_create("real",1)
	for(i=1;i<=L;i++){
		asarray(Map,Dyad_data[i],i)
	}
	asarray_notfound(Map,.)
	temp=L+1
	for(i=1;i<=Sizeofdyad;i++){
		if(missing(asarray(Map,i))){
			asarray(Map,i,temp)
			temp=temp+1
		}
	}
	struct row_list scalar M
	M.n_tot=n_tot
	M.N=N.N
	M.L=L
	M.Dyad_size=Sizeofdyad
	M.M1=nodetocoordinate(N.N1,Map,n_tot,directed)
	M.M2=nodetocoordinate(N.N2,Map,n_tot,directed)
	if(directed==0) return(M)
	M.M3=nodetocoordinate(N.N3,Map,n_tot,directed)
	M.M4=nodetocoordinate(N.N4,Map,n_tot,directed)
	M.M5=nodetocoordinate(N.N5,Map,n_tot,directed)
	return(M)
}
function param_est_base(M,E){
	if(length(M)==0) exit(_error("Need more data to evaluate variance: there are too many missing data"))
	temp1=E[M[1,]]
	temp2=E[M[2,]]
	temp3=mean(temp1:*temp2)
	/*automatically eliminate the missing value*/
	return(temp3)
}
   
function param_est(struct row_list scalar M, E){
	phi=param_est_base(M.M1,E)
	phi=(phi,param_est_base(M.M2,E))
	if(M.N<4) return((phi,J(1,3,0)))
	phi=(phi,param_est_base(M.M3,E))
	phi=(phi,param_est_base(M.M4,E))
	phi=(phi,param_est_base(M.M5,E))
	return(phi)
}
function inverse_exchangable_matrix(n_tot,phi,directed){
/*we assume phi[6]=0*/
	if(directed==1){
		phi=(phi,0)
		A=J(6,6,1)
		A[1,]=(phi[1], phi[2], (n_tot-2)*phi[3], (n_tot-2)*phi[4], 2*(n_tot-2)*phi[5], (n_tot-3)*(n_tot-2)*phi[6])
		A[2,]=(phi[2], phi[1], (n_tot-2)*phi[5], (n_tot-2)*phi[5], (n_tot-2)*phi[3] + (n_tot-2)*phi[4], (n_tot-3)*(n_tot-2)*phi[6])
		A[3,]=(phi[3], phi[5], phi[1] + (n_tot-3)*phi[3], phi[5] + (n_tot-3)*phi[6], phi[2] + phi[4] + (n_tot-3)*phi[5] + (n_tot-3)*phi[6], (n_tot-3)*(phi[4] + phi[5] + (n_tot-4)*phi[6]))
		A[4,]=(phi[4], phi[5], phi[5] + (n_tot-3)*phi[6], phi[1] + (n_tot-3)*phi[4], phi[2] + phi[3] + (n_tot-3)*phi[5] + (n_tot-3)*phi[6], (n_tot-3)*(phi[3] + phi[5] + (n_tot-4)*phi[6]))
		A[5,]=(phi[5], phi[4], phi[2] + (n_tot-3)*phi[5], phi[3] + (n_tot-3)*phi[6], phi[1] + phi[5] + (n_tot-3)*phi[4] + (n_tot-3)*phi[6], (n_tot-3)*(phi[3] + phi[5] + (n_tot-4)*phi[6]))
		A[6,]=(phi[6], phi[6], phi[4] + phi[5] + (n_tot-4)*phi[6], phi[3] + phi[5] + (n_tot-4)*phi[6], phi[3] + phi[4] + 2*phi[5] + 2*(n_tot-4)*phi[6], phi[1] + phi[2] + (n_tot-4)*(phi[3] + phi[4] + 2*phi[5] + (n_tot-5)*phi[6]))
	}
	else{
		A=J(3,3,0)
		phi=(phi,0)
		A[1,]=(phi[1],  2*(n_tot-2)*phi[2],  .5*(n_tot-2)*(n_tot-3)*phi[3])
		A[2,]=(phi[2],  phi[1] + (n_tot-2)*phi[2] + (n_tot-3)*phi[3], (n_tot-3)*phi[2] + (.5*(n_tot-2)*(n_tot-3) - (n_tot-3))*phi[3] )
		A[3,]=(phi[3],  4*phi[2] + (2*n_tot - 8)*phi[3],  phi[1] + (2*n_tot - 8)*phi[2] + (.5*(n_tot-2)*(n_tot-3) - ( 2*(n_tot-2) - 4) - 1)*phi[3])

	}
	L=cols(A)
	B=J(L,1,0)
	B[1,1]=1
	output=lusolve(A,B)
	return(output)
}
function sparse_times_base(X1,M,X2){
	/*Mata can only contain a matrix with elements less than sizemax^5*/
	/*M is a sparse matrix that is the same type in row_list*/
	/*return X1*M*X2*/
	if(cols(M)==0) return(J(rows(X1),cols(X2),0))
	sizemax=40^3
	L=cols(M)
	R=mod(L,sizemax)
	temp=X1[,M[1,1..R]]*X2[M[2,1..R],]
	for(i=1;i<=floor(L/sizemax);i++){
	/*untested*/
		low=(i-1)*sizemax+1+R
		up=i*sizemax+R
		temp=temp+X1[,M[1,low..up]]*X2[M[2,low..up],]
	}
	return(temp)
}



function sparse_sep_base(M,L,index,index2){
/*seperate a matrix into small matrixs*/
/* index==1 stands for up left,index==2 for up right,
  index==3 down left,index=4,down right*/
/*index2 for symmetry*/
   if(index==1){
	temp1=M[1,]:<=L
	temp2=M[2,]:<=L
  	temp3=temp1:*temp2
	output=select(M,temp3)
	if(index2==1){
		temp=(M[2,]\M[1,])
		temp=select(temp,temp3)
		output=(output,temp)
	}
	return(output)
  }
  if(index==2){
	temp1=M[1,]:<=L
	temp2=M[2,]:>L
	temp3=temp1:*temp2
	output=select(M,temp3)
	if(index2==1){
		temp=(M[2,]\M[1,])
		temp1=temp[1,]:<=L
		temp2=temp[2,]:>L
		temp3=temp1:*temp2
		temp=select(temp,temp3)
		output=(output,temp)
	}
	output[2,]=output[2,]:-L
	return(output)
  }
  if(index==3){
	temp1=M[1,]:>L
	temp2=M[2,]:<=L
	temp3=temp1:*temp2
	output=select(M,temp3)
	if(index2==1){
		temp=(M[2,]\M[1,])
		temp1=temp[1,]:>L
		temp2=temp[2,]:<=L
		temp3=temp1:*temp2
		temp=select(temp,temp3)
		output=(output,temp)
	}
	output[1,]=output[1,]:-L
	return(output)
  }
  if(index==4){
	temp1=M[1,]:>L
	temp2=M[2,]:>L
	temp3=temp1:*temp2
	output=select(M,temp3)
	if(index2==1){
		temp=(M[2,]\M[1,])
		temp1=temp[1,]:>L
		temp2=temp[2,]:>L
		temp3=temp1:*temp2
		temp=select(temp,temp3)
		output=(output,temp)
	}
	output[1,]=output[1,]:-L
	output[2,]=output[2,]:-L
	return(output)
  }
}




struct row_list scalar function sparse_sep(struct row_list scalar M,index,Est){
/*do it for both missing and non-missing*/
/*est=0 is the symmetric matrix*/
/*matrix of estimating phi should set est=0, else est=0*/
	L=M.L
	struct row_list scalar M_out
	M_out.L=L
	M_out.N=M.N
	M_out.Dyad_size=M.Dyad_size
	M_out.n_tot=M.n_tot
	if(Est==0){
		M_out.M1=sparse_sep_base(M.M1,L,index,0)
		M_out.M2=sparse_sep_base(M.M2,L,index,1)
		if(M.N<4) return(M_out)
		M_out.M3=sparse_sep_base(M.M3,L,index,1)
		M_out.M4=sparse_sep_base(M.M4,L,index,1)
		M_out.M5=sparse_sep_base(M.M5,L,index,1)
		return(M_out)
	}
	else{
		M_out.M1=sparse_sep_base(M.M1,L,index,0)
		M_out.M2=sparse_sep_base(M.M2,L,index,0)
		if(M.N<4) return(M_out)
		M_out.M3=sparse_sep_base(M.M3,L,index,0)
		M_out.M4=sparse_sep_base(M.M4,L,index,0)
		M_out.M5=sparse_sep_base(M.M5,L,index,0)
		return(M_out)
	}
		
}

function row_list_to_matrix(struct row_list scalar M,R,C,phi){
/*this transforms a struct row_list to a R*C matrixs with phi for each data*/
/*M is symmtry,i.e.sparse_sep(M,1,0)*/
/*used only for inverse*/
	if(M.N<4) directed=0
	else directed=1
	L=2+3*directed
	A=J(R,C,phi[L+1])

	if(M.N<4){
		L1=cols(M.M1)
		L2=cols(M.M2)
		for(i=1;i<=max((L1,L2));i++){
			if(i<=L1) A[M.M1[1,i],M.M1[2,i]]=phi[1]
			if(i<=L2) A[M.M2[1,i],M.M2[2,i]]=phi[2]
		}
	}
	if(M.N>4){
		L1=cols(M.M1)
		L2=cols(M.M2)
		L3=cols(M.M3)
		L4=cols(M.M4)
		L5=cols(M.M5)
		Max_L=max((L1,L2,L3,L4,L5))
		for(i=1;i<=Max_L;i++){
			if(i<=L1) A[M.M1[1,i],M.M1[2,i]]=phi[1]
			if(i<=L2) A[M.M2[1,i],M.M2[2,i]]=phi[2]
			if(i<=L3) A[M.M3[1,i],M.M3[2,i]]=phi[3]
			if(i<=L4) A[M.M4[1,i],M.M4[2,i]]=phi[4]
			if(i<=L5) A[M.M5[1,i],M.M5[2,i]]=phi[5]
		}
	}
	return(A)
} 	

function W_times(X1,struct row_list scalar W,X2,phi){
/*to calculate XWX,W=Omega^-1 and Omega is the covariance matrix with missing data
	Phi is the inversed phi*/
/*This row_list is the original row_list*/
/*error when phi has 0 itsself*/
	if((W.Dyad_size-W.L)<0.5){
		/*No missing data*/
		W_E=sparse_sep(W,1,0)
		temp=sparse_times(X1,W_E,X2,phi)
		return(temp)
	}
	struct row_list scalar A,B,C,D
	/*Should do the following out side of the function*/
	A=sparse_sep(W,1,0)
	B=sparse_sep(W,2,0)
	C=sparse_sep(W,3,0)
	D=sparse_sep(W,4,0)
	D_M=row_list_to_matrix(D,(W.Dyad_size-W.L),(W.Dyad_size-W.L),phi)
	D_inv=luinv(D_M)
	temp1=sparse_times(X1,A,X2,phi)
	temp2=sparse_times(X1,B,D_inv,phi)
	temp3=sparse_times(temp2,C,X2,phi)
	return(temp1-temp3)
}



function positive_variance(V){
/*V is a matrix, this function eliminate all V's non-positive eigen value*/
	X=.
	L=.
	symeigensystem(V,X,L)
	for(i=1;i<=length(L);i++){
		if(L[i]<0) L[i]=0
	}
	output=X*diag(L)*X'
	return(output)
}

function GEE_est(Y,X,struct row_list scalar W,tol,Max_it){
/*Y is a col vector, X is a matrix with same number of rows as Y
  W is a row_list scalar, the one used for matrix operation(missing_list or nonmissing_list)
  tol is a number between 0~1, it stops the iteration,
  the Maximum iteration is Max_it,Max_it>0,integer*/
/*this function is the GEE estimation function. In this function,
 the beta from ordinary linear regression serves as the start of interation*/
	beta_old=cholsolve((X'*X),(X'*Y))
	E=Y-X*beta_old
	beta_new=beta_old
	delta_loop=1
	temp=0
	W_E=sparse_sep(W,1,1)
	if(W.N<4) directed=0
	else directed=1
	while(delta_loop>=tol&temp<=Max_it){
		phi=param_est(W_E,E)
		phi_inv=inverse_exchangable_matrix(W.n_tot,phi,directed)	
		temp1=W_times(X',W,X,phi_inv)
		temp2=W_times(X',W,Y,phi_inv)
		beta_old=beta_new
 		beta_new=luinv(temp1)*temp2
		E=Y-X*beta_new
		delta_loop=beta_new:-beta_old
		delta_loop=sum(delta_loop:*delta_loop)/sum(beta_old:*beta_old)
		temp=temp+1
	}
	if(temp>Max_it) printf("Iteration doesn't converge\n")
	V=luinv(temp1)
	V=positive_variance(V)
	/*Not sure whether df is appropriate here*/
	df=1e8
	st_matrix("b",beta_new')
	st_matrix("V",V)
	st_numscalar("df",df)
	st_numscalar("N",rows(X))
}

function simple_est(Y,X,struct row_list scalar W){
/*beta is the same as linear regression*/
	beta=cholsolve((X'*X),(X'*Y))
	E=Y-X*beta
	W_E=sparse_sep(W,1,1)/*used for estimation*/
	W_T=sparse_sep(W,1,0)/*used for sparse matrix multiply*/
	if(W.N<4) directed=0
	else directed=1
	phi=param_est(W_E,E)
	V=sparse_times(X',W_T,X,phi)
	V=cholsolve(X'*X,V)*cholinv(X'*X)
	df=rows(X)-length(beta)
	st_matrix("b",beta')
	st_matrix("V",V)
	st_numscalar("df",df)
	st_numscalar("N",rows(X))
}
	
	
function sparse_times(X1,struct row_list scalar M,X2,phi){
/*return X1*M8*X2*/
	if(M.N<4) directed=0
	else directed=1
	L=2+3*directed
	if(length(phi)==L){
	/*direct multiply*/
		temp=phi[1]:*sparse_times_base(X1,M.M1,X2)
		temp=temp+phi[2]:*sparse_times_base(X1,M.M2,X2)
		if(M.N<4) return(temp)
		temp=temp+phi[3]:*sparse_times_base(X1,M.M3,X2)
		temp=temp+phi[4]:*sparse_times_base(X1,M.M4,X2)
		temp=temp+phi[5]:*sparse_times_base(X1,M.M5,X2)
		return(temp)
	}
	else{
		temp1=sparse_times_base(X1,M.M1,X2)
		temp=phi[1]:*temp1
		temp2=sparse_times_base(X1,M.M2,X2)
		temp1=temp1+temp2
		temp=temp+phi[2]:*temp2
		if(directed==1){
			temp2=sparse_times_base(X1,M.M3,X2)
			temp1=temp1+temp2
			temp=temp+phi[3]:*temp2
			temp2=sparse_times_base(X1,M.M4,X2)
			temp1=temp1+temp2
			temp=temp+phi[4]:*temp2
			temp2=sparse_times_base(X1,M.M5,X2)
			temp1=temp1+temp2
			temp=temp+phi[5]:*temp2
		
		}
		X_1_row=rowsum(X1)
		X_2_col=colsum(X2)
		temp3=X_1_row*X_2_col
		temp=temp+(temp3-temp1):*phi[L+1]
		return(temp)
	}
	
} 
	
	
	
	

function full_node(n_tot,directed){
/*n_tot is an integer greater than 1. directed shows whether the net is directed or not
	if it is directed, the directed =1, else directed = 0*/
	if(directed==1){
		N=J(2,1,.)
		for(i=1;i<=n_tot;i++){
			if(i==1){
				temp1=J(1,n_tot-1,i)
				temp2=((i+1)..n_tot)
				N=(N,(temp2\temp1))
			}
			if(i==n_tot){
				temp1=J(1,n_tot-1,i)
				temp2=(1..(i-1))
				N=(N,(temp2\temp1))
			}
			if(i<n_tot&i>1){
				temp1=J(1,n_tot-1,i)
				temp2=(1..(i-1),(i+1)..n_tot)
				N=(N,(temp2\temp1))

			}
		}
		N=select(N,colnonmissing(N))
	}
	else{
		N=J(2,1,.)
		for(i=1;i<=n_tot;i++){
			if(i<n_tot){
				temp1=J(1,n_tot-i,i)
				temp2=(i+1)..n_tot

				N=(N,(temp2\temp1))
			}
		}
		N=select(N,colnonmissing(N))
	}
	return(N')
}




function netreg(varlist,node,simple,directed,|touse){
	YX=st_data(.,varlist,touse)
	n_tot=strtoreal(st_local("n_total"))
	tol=strtoreal(st_local("tol"))
	Maxit=strtoreal(st_local("maxit"))
	if(tol<=0) exit(_error("tol should be positive"))
	if(n_tot == 0 & node == 0){
		exit(_error("At least one of n_total or node should be clarified"))
	}
	else if(n_tot == 0){
		n_tot=max(YX[,(cols(YX)-1)..cols(YX)])
	}
	
	if(directed == 1) dyad_size = n_tot*(n_tot-1)
	else dyad_size = n_tot*(n_tot-1)/2
	if(node == 0){
	/*there is no missing data and we need to generate node*/
		R=rows(YX)
		if(R>dyad_size) exit(_error("n_total is too small"))
		if(R<dyad_size) exit(_error("There are missing data. Node coordinates are needed"))
		else{
			node=full_node(n_tot,directed)
			/*wrong*/
			YX=(YX,node)
		}	
	}
	else{	
			node=YX[,(cols(YX)-1)..cols(YX)]
			if(directed==0){
				node=(rowmax(node),rowmin(node))
				YX[,(cols(YX)-1)..cols(YX)]=node
			}
			if(max(node)>n_tot) exit(_error("n_total is too small"))
	}
	/*only consider rows will no missingdata*/
	YX=select(YX,rownonmissing(YX):==cols(YX))
	/*cosider unique rows*/
	YX=uniqrows(YX)
	node=YX[,(cols(YX)-1)..cols(YX)]
	R=rows(uniqrows(node))
	if(R < dyad_size) missing_element=1
	else if(R==dyad_size) missing_element=0
	if(R < rows(YX)) printf("warning: Some nodes are duplicated. Automatically pick the data with lower row subscirpt\n")

	N=node_set(n_tot,directed)
	/*sort data and delete duplicated data*/
	Order_YX=order((YX[,cols(YX)],YX[,cols(YX)-1]),(1,2))
	YX=YX[Order_YX,]/*sort the data*/
	temp=J(rows(YX),1,1)
	for(i=1;i<rows(YX);i++){	
		if(YX[i,cols(YX)]==YX[i+1,cols(YX)]& YX[i,cols(YX)-1]==YX[i+1,cols(YX)-1]) temp[i+1]=0
	}
	YX= select(YX,temp)
	node=YX[,(cols(YX)-1)..cols(YX)]
	dyad_data=dyad(node[,1],node[,2],n_tot,directed)
	Y=YX[,1]
	if(cols(YX)>3){
		X=YX[,2..(cols(YX)-2)]
		X=(J(rows(YX),1,1),X)
	}
	else X=J(rows(YX),1,1)
	if(missing_element==1){
		M=missing_list(N,dyad_data)
	}
	else{
		M=nonmissing_list(N)
	}
	if(simple==1){
		simple_est(Y,X,M)
	}
	else GEE_est(Y,X,M,tol,Maxit)
}
end
	


	
