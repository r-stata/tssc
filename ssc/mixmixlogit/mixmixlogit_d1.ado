*! ML program that acts as the middle man between the stata ado lcmixlogit and the mata command lcmixl_ll.
program define mixmixlogit_d1
	version 12
	args todo b lnf g
 
	mata: mixmix_ll("`b'")
	scalar `lnf' = r(ll)

	if (`todo'==0 | `lnf'>=.) exit
	matrix `g' = r(gradient)
end

*! The mata command lcmixl_ll has the main function of calculating the log likelihood and gradient vector at each iteration.
version 12
mata: 
void mixmix_ll(string scalar B_s)
{
	/* Import Variables from the Stata .ado and assign them internal names */
	external data_X
	external data_Y
	external data_ccov
	external data_CSID
	external macro_nrep
	external macro_np
	external macro_k
	external macro_burn
	external macro_class
	external macro_kclass
	external lognormal
	external macro_corr
	external macro_T
	external macro_ccovnum
	external macro_cutnum
	external gradpick
	
	nrep = macro_nrep
	np = macro_np
	k = macro_k
	burn = macro_burn
	ccovnum = macro_ccovnum
	cutnum = macro_cutnum
	classes = macro_class
	kclass = macro_kclass
	classesp = classes - 1
	B = st_matrix(B_s)'
	corr = macro_corr
	
	/* Split up the passed B matrix into the mean coefficients, standard errors, and class probabilities */

	MRND = B[|1,1\kclass,1|]

	if (corr == 1) {
		external macro_cho
		cho = macro_cho 
		SRND = J(kclass,kclass,0)
		for(j=1; j<=classes; j++) {
			SRND[|(((j-1)*k)+1),(((j-1)*k)+1)\(j*k),(j*k)|] = invvech(B[|(kclass+(((j-1)*(cho/classes))+1)),1\(kclass+(j*(cho/classes))),1|]) :* lowertriangle(J(k,k,1))
		}
		if (ccovnum > 0) gammas = B[|(kclass+cho+1),1\(kclass+cho+ccovnum),1|]
		cuts = B[|(kclass+cho+ccovnum+1),1\(kclass+cho+ccovnum+cutnum),1|]
	}
	else {
		SRND = diag(B[|kclass+1,1\(kclass*2),1|])
		if (ccovnum > 0) gammas = B[|(kclass*2)+1,1\(kclass*2)+ccovnum,1|]
		cuts =   B[|(kclass*2)+ccovnum+1,1\(kclass*2)+ccovnum+cutnum,1|]
	}
		
	/* Set up empty matrices for the LL and gradient vector */
	p = J(np,classes,0)
	P = J(np,1,0)
	
	if (corr == 1) {
		G = J(np,(kclass+cho),0)
	}
	else {
		G = J(np,(kclass*2),0)
	}
	
	Gp = J(np,ccovnum+cutnum,0)
	Gpre = J(1,classes,0)	
	COMP = J(k,nrep,0)

	/* Initial Halton sequence for later shuffling */
	rseed(1234567)
	firstrow = invnormal(halton(nrep,1,(1+burn)))
	ERR = firstrow'
	for (z=2; z<=kclass; z++) {
		if (MRND[z,1] == MRND[z-1,1] & SRND[z,1] == SRND[z-1,1]) {
			addz = ERR[|z-1,1\z-1,nrep|]
			ERR = ERR \ addz
		}
		else {
			addz = jumble(firstrow)
			ERR = ERR \ addz'
		}
	}

	i = 1
	/* Calculate choice probabilities and gradients for each individual */
	for (n=1; n<=np; n++) { 
		
		/* Shuffle the Halton sequence */ 
		ERR[|1,1\1,nrep|] = jumble(ERR[|1,1\1,nrep|]')'
		for (z=2; z<=kclass; z++) {
			if (MRND[z,1] == MRND[z-1,1] & SRND[z,1] == SRND[z-1,1]) {
				ERR[|z,1\z,nrep|] = ERR[|z-1,1\z-1,nrep|]
			}
			else {
				ERR[|z,1\z,nrep|] = jumble(ERR[|z,1\z,nrep|]')'
			}
		}

		/* Calculate the simulated beta vector using the halton series, the means, and the standard errors of the coefficients. */
		BETA = MRND :+ (SRND*ERR)
		
		/* If some beta distributions are specified by the user to be positive or negative log-normal, transform them here. */
		for (j=1; j<=kclass; j++) {
			if (lognormal[1,j] != 0) {
				BETA[j,.] = lognormal[1,j]:*exp(BETA[j,.])
			}
		}
		
		/* Calculate some more stuff */
		if (corr == 1) {
			M = J((kclass+cho),nrep,0)
		}
		else {
			M = J((kclass*2),nrep,0) 
		}
		R = J(1,nrep,0)
		nc = macro_T[i,1]
		istart = i

		/* Loop for each class */ 
		for(j=1; j<=classes; j++) {
			RJ = J(1,nrep,1)
			i = istart

			for (t=1; t<=nc; t++) {	
				/* Grab the data */
				YMAT = data_Y[|i,1\(i+data_CSID[i,1]-1),cols(data_Y)|]
				XMAT = data_X[|i,1\(i+data_CSID[i,1]-1),cols(data_X)|]

				/* Choice probability for that class, time period, and individual */
				EV = exp(XMAT*BETA[|(((j-1)*k)+1),1\(j*k),nrep|])
				EV = (EV :/ colsum(EV))
				
				/* Multiply with other time periods for that specific class and individual */
				RJ = RJ :* colsum(YMAT :* EV) 

				/* Calc M for gradient vector */
				PMAT = YMAT :- EV
				for (s=1; s<=k; s++) {
					COMP[s,.] = colsum(PMAT :* XMAT[.,s])
				}

				for(s=1; s<=k; s++) {
					if (lognormal[1,(((j-1)*k)+s)] != 0) {
						M[(((j-1)*k)+s),.] = M[(((j-1)*k)+s),.] :+ (COMP[s,.] :* BETA[(((j-1)*k)+s),.])
					}
					else {
						M[(((j-1)*k)+s),.] = M[(((j-1)*k)+s),.] :+ COMP[s,.]
					}
				}
				if (corr == 1) {
					num = 1
					for (l=1; l<=k; l++) {
						for (s=l; s<=k; s++) {
							if (lognormal[1,(((j-1)*k)+s)] != 0) {
								M[(((j-1)*(cho/classes))+num+kclass),.] = M[(((j-1)*(cho/classes))+num+kclass),.] :+ (COMP[s,.] :* BETA[(((j-1)*k)+s),.] :* ERR[(((j-1)*k)+l),.])	
							}
							else {
								M[(((j-1)*(cho/classes))+num+kclass),.] = M[(((j-1)*(cho/classes))+num+kclass),.] :+ (COMP[s,.] :* ERR[(((j-1)*k)+l),.])
							}	
							num = num + 1
						}
					}
				}
				else {
					for(s=1; s<=k; s++) {
						if (lognormal[1,(((j-1)*k)+s)] != 0) {
							M[(((j-1)*k)+s+kclass),.] = M[(((j-1)*k)+s+kclass),.] :+ (COMP[s,.] :* BETA[(((j-1)*k)+s),.] :* ERR[(((j-1)*k)+s),.])	
						}
						else {
							M[(((j-1)*k)+s+kclass),.] = M[(((j-1)*k)+s+kclass),.] :+ (COMP[s,.] :* ERR[(((j-1)*k)+s),.])
						}
					}
				}
				
				i = i + data_CSID[i,1]
			}

			/* Calculate class probability denominator for this specific individual */
			if (ccovnum > 0) {
				CCOVMAT = mean(data_ccov[|istart,1\(i-1),cols(data_ccov)|],1)
				if (j == 1) {
					COMP4 = exp(cuts[1,1] - CCOVMAT*gammas)
					p[n,j] = COMP4 / (1 + COMP4)
				}
				else if (j == classes) {
					COMP5 = exp(cuts[classesp,1] - CCOVMAT*gammas)
					p[n,j] = 1 - COMP5 / (1 +COMP5)
				}	
				else {
					COMP4 = exp(cuts[j-1,1] - CCOVMAT*gammas)
					COMP5 = exp(cuts[j,1] - CCOVMAT*gammas)
					p[n,j] = COMP5 / (1 + COMP5) - COMP4 / (1 + COMP4)		
				}

			}
			else {
				if (j == 1) {
					COMP4 = exp(cuts[1,1])
					p[n,j] = COMP4 / (1 + COMP4)
				}
				else if (j == classes) {
					COMP5 = exp(cuts[classesp,1])
					p[n,j] = 1 - COMP5 / (1 +COMP5)
				}	
				else {
					COMP4 = exp(cuts[j-1,1])
					COMP5 = exp(cuts[j,1])
					p[n,j] = COMP5 / (1 + COMP5) - COMP4 / (1 + COMP4)		
				}
			}

			/* Aggregate over classes to obtain the choice probability for that individual (average over simulation) */
			P[n,1] = P[n,1] :+ (p[n,j] :* mean(RJ',1))

			/* Start calc for gradient vector for this specific class */
			if (corr == 1) {
				num = 1
				for (l=1; l<=k; l++) {
					G[n,(((j-1)*k)+l)] = p[n,j] :* mean((RJ :* M[(((j-1)*k)+l),.])',1)
					for (s=l; s<=k; s++) {
						G[n,(((j-1)*(cho/classes))+num+kclass)] = p[n,j] :* mean((RJ :* M[(((j-1)*(cho/classes))+num+kclass),.])',1) 
						num = num + 1
					}
				}
			}
			else {
				for(s=1; s<=k; s++) {
					G[n,(((j-1)*k)+s)] = p[n,j] :* mean((RJ :* M[(((j-1)*k)+s),.])',1)
					G[n,(((j-1)*k)+s+kclass)] = p[n,j] :* mean((RJ :* M[(((j-1)*k)+s+kclass),.])',1) 
				}
			
			}
			Gpre[1,j] = mean(colsum(RJ)',1)
		}

		/* Finish G calc now that statistics for all classes have been obtained */
		COMP6 = (1 :/ P[n,1])
		G[n,.] = COMP6 :* G[n,.]
		for (c=1; c<= (ccovnum+cutnum); c++) {
			if (c <= ccovnum) {
				for (j=1; j<=classesp; j++) {
					if (ccovnum > 0) COMPZ = exp(cuts[j,1] - CCOVMAT*gammas)
					else COMPZ = exp(cuts[j,1])
					Gp[n,c] = Gp[n,c] + ((CCOVMAT[1,c] * COMPZ) / (1 + COMPZ)^2) :* COMP6 :* Gpre[1,j+1] - ((CCOVMAT[1,c] * COMPZ) / (1 + COMPZ)^2) :* COMP6 :* Gpre[1,j]
				}
			}
			else {
				if (ccovnum > 0) COMPZ = exp(cuts[c-ccovnum,1] - CCOVMAT*gammas)
				else COMPZ = exp(cuts[c-ccovnum,1])
				Gp[n,c] = ((COMPZ)/(1 + COMPZ)^2) :* COMP6 :* Gpre[1,c-ccovnum] - ((COMPZ)/(1 + COMPZ)^2) :* COMP6 :* Gpre[1,c-ccovnum+1]
			}
		}
	}
	
	G = G , Gp
	
	for(j=1; j<=classes; j++) {
		if (colsum(p[.,j]) < 0.015) {
			ll_penalty = -99999999
		}
	}
	
	/* Output the log-likelihood and gradient vector. */
	st_numscalar("r(ll)", colsum(ln(P))) 
	st_matrix("r(gradient)", colsum(G))	
}

end
