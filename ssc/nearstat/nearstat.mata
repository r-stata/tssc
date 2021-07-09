// Mata code for nearstat
// Copyright by P. wilner Jeanty. But, may be distributed for free with proper credit.
// Updated 12/02/2010
// Updated 11/26/2011 to allow for minmaxd option
version 10.1
mata
mata set matastrict on
	void nearstat_compcoord(string scalar list2, string scalar list3) 
	{
		real matrix comp2, comp3
		st_view(comp2=., ., tokens(list2))
		st_view(comp3=., ., tokens(list3))
		st_numscalar("obsnear", colnonmissing(comp2[,1]))
		st_numscalar("val_obscont", mean(colnonmissing(comp3)'))		
	}
	void nearstat_calcdist(string scalar latlong1, string scalar touseobs, string scalar latlong2)
 	{
		external string scalar nearstat_expto
		external real scalar nearstat_Inc, nearstat_Pop, nearstat_Alfa, nearstat_neigh, nearstat_minmax
		real matrix A, B, C, cvar, stateq, W, _InD, mid, wei, ring_C, ring_mat 
		real scalar usecont1, forid, nearstat_n, rowsofa, rowsofb, k1, k2, towi, tonei, dlat, dlong, fh, 
    		lowb, highb, torad, r, i, j, z, a, c, l,s, nr, L1, Q1, Q2, L2, L3, Q3, rowsof,
			colw, roww, rowcol, ind, minrc, sameAB, neighb, tomin
		real rowvector matr
		real colvector neid, R1, R2, nnc, dist, Qrt, incd, d, d2, neinum, ring_cont, Dii, minmax
		string scalar stn, tozero
		transmorphic colvector D
		A=st_data(., tokens(latlong1), touseobs)
		B=st_data(., tokens(latlong2))
		sameAB=(A==B? 1:0)
		nearstat_n=rowsofa=colnonmissing(A[,1])
		rowsofb=colnonmissing(B[,1])
		if (rowsofb!=colnonmissing(B[,2])) {
			""
			errprintf("Latitude and longitude for the near features must have the same number of non-missing observations\n")
			exit(416)
		}
		if (rowsofa!=colnonmissing(A[,2])) {
			""
			errprintf("Latitude and longitude for the input features must have the same number of non-missing observations\n")
			exit(416)
		}
		usecont1=strtoreal(st_local("stcont1"))
		if (usecont1==1 | usecont1==2) {
			C=st_data(., tokens(st_local("contvar")))
			C=select(C, rowmissing(C):==0) 
			cvar=J(nearstat_n, cols(C), .); stateq=J(nearstat_n, cols(C), .)
		}
		forid=0
		if (st_local("nid")!="") {
			if (strtoreal(st_local("chkid"))==0) {
				D=st_data(., st_local("neid1"))
				neid=J(nearstat_n, 1, .)
			}
			else {
				D=st_sdata(., st_local("neid1"))
				neid=J(nearstat_n, 1, "")
			}
			forid=1
		}
		if ((sameAB | rowsofb!=rowsofa) & st_local("iidist")!="") {
			""
			errprintf("Option iidist() not allowed when input and near features are the same or have different number of non-missing observations\n")
			exit(198)
		}
		if (st_local("statname")!="") {
			stn=st_local("statname")
			if (st_local("dband")!="") {
				lowb=strtoreal(st_local("band1"))
				highb=strtoreal(st_local("band2"))
			}						
			else if (st_local("knn")!="") k2=strtoreal(st_local("knn"))
		}
		if (st_local("knn")!="") {
			if (A==select(B, rowmissing(B):==0) & k2>rowsofb-1)  {  // rowsofb-1 to exclude self as a neighbor
				""
				displayas("err") // Another way to display error message in Mata
				printf("Value provided with knn(#) cannot be larger than N-1, where N is the number of non-missing observations\n")
				exit(416)
			}
		}
		k1=strtoreal(st_local("kth"))
		
		if (st_local("dname")!="" | st_local("ncount")!="") {
			towi=0; tonei=0			
			if (st_local("dname")!="") {
				R1=J(nearstat_n, 1, .); R2=J(nearstat_n, 1, 0); towi=1
			}
			if (st_local("ncount")!="") {
				nnc=J(nearstat_n, 1, 0); tonei=1;
 			}
			lowb=strtoreal(st_local("band1"))
			highb=strtoreal(st_local("band2"))			
		}		
		if (st_local("cart")=="") {
			torad=pi()/180
			A=A:*torad ; B=B:*torad // Convert from degrees to radians
			r=strtoreal(st_local("rad"))			
		}		
		if (nearstat_minmax) {
			minmax=J(nearstat_n, 1, .)
			tomin=0
			if (st_local("minmaxtype")=="min") tomin=1
		}	
		dist=J(nearstat_n, 1, .); W=J(nearstat_n, rowsofb,.); Qrt=.; incd=J(nearstat_n, 1, .)
		for (i=1; i<=nearstat_n; i++) {
			mid=.; wei=.
			d=J(rowsofb, 1, .) 
			for (j=1; j<=rowsofb; j++) {  
				if (st_local("cart")!="") d[j,1] =((B[j,1]==A[i,1] & B[j,2]==A[i,2])? . : sqrt((B[j,1]:-A[i,1]):^2 + (B[j,2]:-A[i,2]):^2))				
				else {
					dlat = B[j,1]:- A[i,1]
					dlong = B[j,2]:- A[i,2]
					if (colmissing(dlong):==0 & dlong:>pi()) dlong=(B[j,2]:- A[i,2]:-360)
					if (dlong:<-pi()) dlong=(B[j,2]:- A[i,2]:+ 360)
					a = (sin(dlat/2)):^2 :+ cos(A[i,1]):*cos(B[j,1]):*(sin(dlong:/2)):^2
					matr=1,sqrt(a)
					c = 2 * asin(rowmin(matr))
					d[j,1]=((B[j,1]==A[i,1] & B[j,2]==A[i,2])? . : r*c) // if input=near then set distance to missing
				}
			}
			W[i,]=d'
			minindex(d, rowsofb, mid, wei) // rows(mid) will not equal k1 if there are more than one min
			// use of rows(B) allows calling minindex just one time.
			// In case there are more than one first-order, second-order,...,k-th order nearest neighbors, the first one encountered will be used
			 
			dist[i]= d[mid[k1]] // Even if rows(mid)>k1, that's ok.
			if (nearstat_minmax) minmax[i]=(tomin==1? rowmin(W[i,]) : rowmax(W[i,]))
				
			if (forid) neid[i]=D[mid[k1]]	// to get id of the kth nearest neighbor			
			
			if (usecont1) { 			
				if (nearstat_Inc==1) { // Request incremental distance
					_InD=d[mid],C[mid]
					// if (i==3) _InD can be used for verification
					if (_InD[1,2]>=nearstat_Pop) incd[i]=0
					else {
						for (l=2; l<=rows(_InD); l++) {
							if (nearstat_Pop<= _InD[l,2]) {
								incd[i]=_InD[l,1]-_InD[1,1]
								l=rows(_InD)
							}						
						}
					}
				}
				else { 
					for (s=1; s<=cols(C); s++) {
						cvar[i,s]=C[,s][mid[k1]]  // For each contvar() variable, record the value associated with the kth order nearest neighbor
					}
				}
			}
			if (usecont1==2) {
				ring_C=J(rowsof=colnonmissing(d), cols(C), 0) 
				ring_mat=J(rowsofb, 2, .); ring_cont=J(rowsofb, 1, 0); d2=J(rowsofb, 1, .) 
				for (s=1; s<=cols(C); s++) {
					ring_mat=d, C[,s]
					if (nearstat_neigh==1 | nearstat_neigh==3 | nearstat_neigh==5) {
						d2=ring_mat[,1][mid]; ring_cont=ring_mat[,2][mid] // sort d2 and each column of C in ascending order
						if (nearstat_neigh==1 | nearstat_neigh==5) { // Stats calculated over all other features (except self if input==near) 
							for (z=1; z<=rows(d2); z++) {
								ring_C[z,s]=ring_cont[z]/(d2[z]^nearstat_Alfa)								
							}
							neighb=z
						}
						else if (nearstat_neigh==3) { // Stats calculated only for those falling in ring (lowb-highb)
							if (tonei==1) {
								neinum=J(rowsof,1,0) // dimensions of d2 and ring_cont become same as that of ring_C after sorting
								for (z=1; z<=rows(d2); z++) {
									if (d2[z]>lowb & d2[z]<=highb) {
										ring_C[z,s]=ring_cont[z]/(d2[z]^nearstat_Alfa)
										neinum[z]=1
									}
									if (d2[z]>highb) {
										z=rows(d2) // stop the loop; this works since d2 is sorted in ascending order
										neighb=z // record the number neighbors falling in the ring for each observation
									}	
								}
								nnc[i]=colsum(neinum) // This also gives the number of neighbors falling in the ring. But, a variable will need to be stored.  
							}
							else {
								for (z=1; z<=rows(d2); z++) {
									if (d2[z]>lowb & d2[z]<=highb) ring_C[z,s]=ring_cont[z]/(d2[z]^nearstat_Alfa)
									if (d2[z]>highb) {
										z=rows(d2)  
										neighb=z  
									}	
								}
							}
						}
					}
					else if (nearstat_neigh==4 | nearstat_neigh==2) { //  Calculated stats over nearest neighbors only
 						d2=ring_mat[,1][mid[|1\k2|]]; ring_cont=ring_mat[,2][mid[|1\k2|]] // rows(d2) becomes k2
						// There could be more than k2 nearest neighbors if there are ties, but I want k2 of them
						for (z=1; z<=rows(d2); z++) { // k2 instead of rows(d2) would do as well 
							ring_C[z,s]=ring_cont[z]/(d2[z]^nearstat_Alfa)							
						}
						neighb=k2
					}
					if (stn=="min")  stateq[i,s]=colmin(ring_C[,s][|1\neighb|])
					if (stn=="max")  stateq[i,s]=colmax(ring_C[,s][|1\neighb|])
					if (stn=="mean") stateq[i,s]=mean(ring_C[,s][|1\neighb|])
					if (stn=="std")  stateq[i,s]=sqrt(variance(ring_C[,s])[|1\neighb|])
					if (stn=="sum")  stateq[i,s]=colsum(ring_C[,s][|1\neighb|])
				}
			}
			if (towi==1) R1[i]=d[mid[k1]] // to get distance to kth nearest neighbor
			if (tonei==1 & nearstat_neigh!=3) { // Calculate number of neighbors that fall within ring (lowb-highb)
				neinum=J(rowsofb,1,0)
				_sort(d,1) // d=d[mid] would do as well except that the missing value for self would get dropped
				for (z=1; z<=rowsofb; z++) {
					if (d[z]>lowb & d[z]<=highb) neinum[z]=1					
					if (d[z]>highb) z=rowsofb // break in lieu of z=rowsofb would do as well - to avoid wasting time continuing the search
				}
				nnc[i]=colsum(neinum)
			}			
		}
		Qrt=colshape(W,1); Qrt=select(Qrt, rowmissing(Qrt):==0) // to get rid of missing values and then sort the non-missing ones in ascending order
		_sort(Qrt, 1)
		
		// When one-to-one distance requested, export diagonal elements of W if A!=B but rows(A)=row(B) 
		if (st_local("iidist")!="") {
			Dii=J(nearstat_n,1,.)
			for (i=1; i<=nearstat_n; ++i) {
				Dii[i]=W[i,i]
			}
			st_store(., st_addvar("double", st_local("iidist")), touseobs, Dii)	
		}	

		// Now export the distance matrix
		// *****************************
		if (st_local("expdist")!="") {
			if (sameAB) {
				for (i=1; i<=rows(W); i++) {
					W[i,i]=0
				}
			}	
			if (valofexternal("nearstat_wform")==1) {
				if (nearstat_expto=="Stata") {
					colw=cols(W); roww=rows(W); rowcol=colw,roww; minrc=rowmin(rowcol); ind=0
       				if (c("flavor")=="Small" & minrc>40) ind=1
        				if (c("flavor")=="Intercooled") {
                				if ((c("SE")==0 & c("MP")==0) & minrc>800) ind=2
                				if ((c("SE")==1 | c("MP")==1) & minrc>11000) ind=3
       				}
					if (ind>0) {
						""
						printf("Matrix size exceeds your Stata flavor matsize limit, Stata matrix not created\nearstat_n")					
					}
					else if (ind==0) st_matrix(st_local("expdist"), W)
					st_numscalar("nearstat_ind", ind)
				}
			}
			else {
				tozero=valofexternal("nearstat_zero")
				if (tozero=="") W=nearstat_MakeGWT(W)
				else W=nearstat_MakeGWT(W, tozero)
			}
			if (nearstat_expto=="tab" | nearstat_expto=="csv") nearstat_MatXport(nearstat_expto, st_local("expdist"), strofreal(W))
			if (nearstat_expto=="Mata")  {
				fh = fopen(st_local("expdist"), "w")
				fputmatrix(fh, W)
				fclose(fh)
			}
		} 		
		// Calculate descriptive statistics for the distance between i and j, where i=1,N and j=1,N
		// *************************************************************
		nr=rows(Qrt)

		// Lower Quartile (Q1)
		L1=0.25*nr
		Q1=((trunc(L1)==L1)? (Qrt[L1]+Qrt[L1+1])/2 : Qrt[round(L1)])

		// Median or Middle Quartile (Q2)
		L2=0.5*nr
		Q2=((trunc(L2)==L2)? (Qrt[L2]+Qrt[L2+1])/2 : Qrt[round(L2)])

		// Upper Quartile (Q3)
		L3=0.75*nr
		Q3=((trunc(L3)==L3)? (Qrt[L3]+Qrt[L3+1])/2 : Qrt[round(L3)])
		
		// Min, Max, and Mean are returned as scalars below

		// *************************************************************	
		// Now pass everything onto Stata

		st_store(., st_addvar("double", st_local("distvar")), touseobs, dist)
		if (forid==1) {
			if (strtoreal(st_local("chkid"))==0) st_store(., st_local("neid2"), touseobs, neid)
			else st_sstore(., st_local("neid2"), touseobs, neid)
		}
		if (usecont1==1) { 
			if (nearstat_Inc==1) st_store(., st_addvar("double", st_local("incdist")), touseobs, incd)
			else {
				for (l=1; l<=cols(C); l++) st_store(., st_addvar("double", tokens(st_local("statvar"))[,l]), touseobs, cvar[,l])
			}
		}
		else if (usecont1==2) {
			for (l=1; l<=cols(C); l++) st_store(., st_addvar("double", tokens(st_local("statvar"))[,l]), touseobs, stateq[,l]) 
		}
		if (towi==1) {
			for (i=1; i<=rows(R1); i++) {
				if (R1[i]>lowb & R1[i]<=highb) R2[i]=1  // Create a dummy variable equal to 1 if the kth-nearest neighbor falls in ring lowb-highb
			}
			st_store(., st_addvar("byte", st_local("dname")), touseobs, R2)
		}
		if (tonei==1) st_store(., st_addvar("double", st_local("ncount")), touseobs, nnc)
		if (nearstat_minmax) st_store(., st_addvar("double", st_local("mmname")), touseobs, minmax)
		
		st_numscalar("nfeat", nearstat_n); st_numscalar("nnear", rowsofb);

		//  return mean, min, and max distance from kth nearest neighbor
		st_numscalar("kn_mean", mean(dist)); st_numscalar("kn_max", colmax(dist)); st_numscalar("kn_min", colmin(dist))

		// return descriptive statistics for distance between i and j
		st_numscalar("Q1_d", Q1); st_numscalar("Q2_d", Q2); st_numscalar("Q3_d", Q3)
		st_numscalar("std_d", sqrt(variance(Qrt,1)))
		st_numscalar("obs_d", rows(Qrt)); st_numscalar("min_d", colmin(Qrt))
		st_numscalar("mean_d", mean(Qrt,1)); st_numscalar("max_d", colmax(Qrt))
}
void nearstat_MatXport(string scalar delimit, string scalar fname, string matrix g)
{
      string scalar line, wtod, delim
      real scalar i, j, fho
	wtod= "w"
	if (delimit=="tab") delim = char(9)
	else delim = char(44)
      fho = fopen(fname, wtod)
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
real matrix nearstat_MakeGWT(transmorphic matrix wght, | string scalar noz) 
	{
	pragma unused noz
 	real scalar n, N, j, g, i
	transmorphic matrix distm	
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
	mata mlib create lnearstat, dir(PLUS) replace
	mata mlib add lnearstat nearstat_*(), dir(PLUS)
	mata mlib index
end


