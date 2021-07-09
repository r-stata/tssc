*! Mata code for splagvar
*! By P. Wilner Jeanty
*! Date: March 2009
version 10.1
mata:
	mata set matastrict on
	void splagvar_lagmyvar(string scalar xvars1, string scalar xvars2 , string scalar ftouse) 
	{
	transmorphic fh, wyindxes, nwy, stubwy, wy, wxindxes, stubwx, w2xindxes, 
	stubw2x, w3xindxes, stubw3x, nwx, nw2x, nw3x
	real scalar n1, n2, m1, m2, i, j
	real matrix ytolag, xtolag, wx, w2x, w3x
	external real scalar splagvar_Ord
	external string scalar splagvar_TOMAT1
	external real matrix splagvar_w  // To make the weights matrix global
	st_view(ytolag, ., tokens(xvars1), ftouse)
	st_view(xtolag, ., tokens(xvars2), ftouse)
	if (splagvar_TOMAT1=="Mata") {
		if (!fileexists(st_local("wname"))) {
			""
			errprintf("File %s not found\n", st_local("wname"))
			exit(601)
		}
		else { 
			fh = fopen(st_local("wname"), "r")
			splagvar_w=fgetmatrix(fh)
			fclose(fh)
		}
	}
	else {
		splagvar_w=st_matrix(st_local("wname"))
		if (cols(splagvar_w)==0 | rows(splagvar_w)==0) {
			""
			errprintf("Matrix %s not found\n", st_local("wname"))
			exit(601)
		}
	}
	n1=cols(ytolag); m1=rows(ytolag)
	n2=cols(xtolag); m2=rows(xtolag)
	if (n1!=0) {
		if (rows(splagvar_w)!=m1) {
			""
			errprintf("Number of observations (%f) not conformable with weights matrix size (%f by %f)\n", m1, rows(splagvar_w), rows(splagvar_w))
			exit(3200)
		}
		wyindxes=J(1,n1,.)
		stubwy="weird_wy"
		for (i=1; i<=n1; i++) {
			nwy=stubwy+strofreal(i)
			wy=splagvar_w*ytolag[.,i]
			wyindxes[i]=st_addvar("double", nwy)
			st_store(., nwy, wy)
		}
	}
	if (n2!=0) {
		if (rows(splagvar_w)!=m2) {
			""
			errprintf("Number of observations (%f) not conformable with weights matrix size (%f by %f)\n", m2, rows(splagvar_w), rows(splagvar_w))
			exit(3200)
		}
		wxindxes=J(1,n2,.)
		stubwx="weird_wx"
		if (splagvar_Ord==2 | splagvar_Ord==3) {
			w2xindxes=J(1,n2,.)
			stubw2x="weird_w2x"
			if (splagvar_Ord==3) {
				w3xindxes=J(1,n2,.)
				stubw3x="weird_w3x"
			}
		}
		for (j=1; j<=n2; j++) {
			nwx=stubwx+strofreal(j)
			wx=splagvar_w*xtolag[.,j]
			wxindxes[j]=st_addvar("double", nwx)
			st_store(., nwx, wx)
			if (splagvar_Ord==2 | splagvar_Ord==3) {
				nw2x=stubw2x+strofreal(j)
				w2x=splagvar_w*wx
				w2xindxes[j]=st_addvar("double", nw2x)
				st_store(., nw2x, w2x)
				if (splagvar_Ord==3) {
					nw3x=stubw3x+strofreal(j)
					w3x=splagvar_w*w2x
					w3xindxes[j]=st_addvar("double", nw3x)
					st_store(., nw3x, w3x)
				}		
			}	
		}
	}	
} 

void splagvar_CalcMoran(string scalar zvar, string scalar ztouse) {
	real scalar vz2, I, n, C, C2, swyy, ei_n, ei_r, A,
			B, D1, D2, vn, vr, ZI_n, ZI_r, p_n, p_r, E, i, MI
	real colvector z, zd, zd2, zd4, B1
	real matrix sww 
	external real matrix splagvar_w  // To use the weights matrix retrieved by the previous function
	st_view(z=., ., zvar, ztouse)
	zd=z:-mean(z,1)
	zd2=zd:^2
	vz2=sum(zd2) // vz=crossdev(z,meanz, z,meanz) would do as well

	swyy=sum(zd'*splagvar_w*zd)
	C=sum(splagvar_w) 
	C2=C^2
	n=rows(z)
	
	I=(n/C)*(swyy/vz2) // Moran's I
	st_numscalar("r(I)", I)
	ei_n=ei_r=-1/(n-1) // Mean

// Calculating the variances
	zd4=zd2:^2
	sww=(splagvar_w+splagvar_w'):^2
	A=0.5*sum(sww) // A
	B1=J(n,1,.)
	for (i=1; i<=n; i++) {
		B1[i]=(rowsum(splagvar_w[i,.])+ colsum(splagvar_w[.,i]))^2
	}
	B=sum(B1)
	D1=((n^2)-3*n+3)*A - n*B + 3*C2
	D2=((n^2)-n)*A - 2*n*B + 6*C2
	E=mean(zd4,1)/(mean(zd2,1))^2

	// Variance under normal approximation assumption
	vn=(((n^2)*A - n*B + 3*C2)/(((n^2)-1)*C2))-(ei_n)^2

	ZI_n=(I-ei_n)/sqrt(vn)
	p_n=(1-normal(abs(ZI_n)))*2
	
	// Variance under randomization assumption
	vr=((n*D1-E*D2)/((n-1)*(n-2)*(n-3)*C2))-(ei_r)^2
	ZI_r=(I-ei_r)/sqrt(vr)
	p_r=(1-normal(abs(ZI_r)))*2

	MI=(I,I\ei_n,ei_r\sqrt(vn),sqrt(vr)\ZI_n,ZI_r\p_n,p_r)
	st_matrix("morstat", MI) 
}
	mata mlib create lsplagvar, dir(PLUS) replace
    mata mlib add lsplagvar splagvar_*(), dir(PLUS)
    mata mlib index

end

