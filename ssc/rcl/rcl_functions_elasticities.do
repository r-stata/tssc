
*******************************
* Mata funcitons: elasticities
*******************************

mata:

mata clear

// simple logit elasticities and diversion ratios
void elasticities_logit(
	string scalar market0,
	string scalar brand0,
	string scalar p0,
	string scalar q0,
	string scalar share0,
	string scalar alpha0,
	string scalar touse)
{

	// declarations
	real colvector market,brand,p,q,s,marketm,pm,qm,sm,brandm,alpha,alpham,sbm,pbm,missing_index
	real matrix amsumb,el,dr,weight,msumb,elm,qbm,weightm,elm0
	real scalar b,bb,m,elmij,j,i,_alpha

	// load data
	st_view(market, .,tokens(market0),touse)
	st_view(brand, .,tokens(brand0),touse)
	st_view(p, .,tokens(p0),touse)
	st_view(q, .,tokens(q0),touse)
	st_view(s, .,tokens(share0),touse)
	st_view(alpha, .,tokens(alpha0),touse)
	
	// reindexing group variable (categorical variables should start from 1 and increment by 1)
	market=reindex(market)
	brand=reindex(brand)

	// matrix for summations
	amsumb=J(rows(market),colmax(brand)-colmin(brand)+1,0)
	b=0
	for (bb=colmin(brand); bb<=colmax(brand); bb++) {
		b=b+1
		amsumb[.,b]=(brand:==bb)
	}

	el=J(colmax(brand),colmax(brand),0)												// brand level elasticity matrix
	dr=J(colmax(brand),colmax(brand),0)												// brand level diversion ratio matrix
	weight=J(colmax(brand),colmax(brand),0)											// weight matrix

	for (m=colmin(market); m<=colmax(market); m++) {								// calcualtions by markets

		// variables
		marketm=select(market,market:==m)
		pm=select(p,market:==m)
		qm=select(q,market:==m)
		sm=select(s,market:==m)
		brandm=select(brand,market:==m)
		alpham=select(alpha,market:==m)
		_alpha=mean(alpham)
	
		// brand matrix for summations
		msumb=select(amsumb,market:==m)

		// calculation of brand level elasticity matrix
		sbm=msumb'*sm																// brand level market shares
		pbm=((msumb:*qm)'*pm):/(colsum((msumb:*qm))')								// brand level weighted average prices
		qbm=msumb'*qm																// brand level quantities
		elm=J(colmax(brandm),colmax(brandm),1):*sbm'								// brand level elasticity matrix of market m
		elm=elm :- diag( J(rows(elm),1,1) )
		elm=_alpha*elm
		elm=elm:*pbm'															// transforming into elasticities: multiplying by derivating prices
		// changing missing values to zero (in unbalanced panels elasticities involving product(s) not present at the given market are missing)
		if (rows(elm)>1) {
			missing_index=(elm[.,1]:==.):*runningsum(J(rows(elm),1,1))
			missing_index=select(missing_index,missing_index:>0)
			elm[missing_index,.]=J(rows(elm[missing_index,.]),cols(elm[missing_index,.]),0)
			elm[.,missing_index]=J(rows(elm[.,missing_index]),cols(elm[.,missing_index]),0)
			missing_index=(elm[1,.]':==.):*runningsum(J(rows(elm),1,1))
			missing_index=select(missing_index,missing_index:>0)
			elm[missing_index,.]=J(rows(elm[missing_index,.]),cols(elm[missing_index,.]),0)
			elm[.,missing_index]=J(rows(elm[.,missing_index]),cols(elm[.,missing_index]),0)
		}

		// weigth matrix for market m
		weightm=qbm#J(1,rows(qbm),1)

		// adding up weights and weighted elasticities
		weight=weight:+weightm
		el=el:+(elm:*weightm)

	}	// end of m (markets) loop 

	el=el:/weight																	// normalizing: final, weighted average (across markets) elasticity matrix

	// calculation of loss diversations for average elasticites
	for (j=1; j<=colmax(brand); j++) {
		if (sum(brand:==j)!=0) {		// only if brand j is present
			for (i=1; i<=colmax(brand); i++) {
				if (sum(brand:==i)!=0) {		// only if brand i is present
					dr[i,j]=100*sum(q:*(brand:==i))*el[i,j]/abs(sum(q:*(brand:==j))*el[j,j])
				}
			}
		}
	}
	
	// storing in Stata
	st_matrix("el", el)
	st_matrix("dr", dr)
	
}	// end of elasticities_logit function
mata mlib add lrcl elasticities_logit()


// one-level nested logit elasticities and diversion ratios
void elasticities_nlogit(
	string scalar market0,
	string scalar brand0,
	string scalar g0,
	string scalar p0,
	string scalar q0,
	string scalar share0,
	string scalar sjg0,
	string scalar alpha0,
	string scalar sigmag0,
	string scalar touse)
{

	// declarations
	real colvector market,brand,g,p,q,s,sjg,marketm,pm,qm,sm,brandm,alpha,sigmag,alpham,sigmagm,gm,sjgm,sbm,pbm,scg,sjscg,missing_index,im
	real matrix amsumb,el,dr,weight,msumb,msumg,elm,qbm,weightm,elm0
	real scalar b,bb,m,elmij,j,i,gg,_alpha,_sigmag

	// load data
	st_view(market, .,tokens(market0),touse)
	st_view(brand, .,tokens(brand0),touse)
	st_view(g, .,tokens(g0),touse)
	st_view(p, .,tokens(p0),touse)
	st_view(q, .,tokens(q0),touse)
	st_view(s, .,tokens(share0),touse)
	st_view(sjg, .,tokens(sjg0),touse)
	st_view(alpha, .,tokens(alpha0),touse)
	st_view(sigmag, .,tokens(sigmag0),touse)
	
	// reindexing group variable (categorical variables should start from 1 and increment by 1)
	market=reindex(market)
	brand=reindex(brand)
	g=reindex(g)

	// matrix for summations
	amsumb=J(rows(market),colmax(brand)-colmin(brand)+1,0)
	b=0
	for (bb=colmin(brand); bb<=colmax(brand); bb++) {
		b=b+1
		amsumb[.,b]=(brand:==bb)
	}

	el=J(colmax(brand),colmax(brand),0)												// brand level elasticity matrix
	dr=J(colmax(brand),colmax(brand),0)												// brand level diversion ratio matrix
	weight=J(colmax(brand),colmax(brand),0)											// weight matrix

	for (m=colmin(market); m<=colmax(market); m++) {								// calcualtions by markets

		// variables
		marketm=select(market,market:==m)
		pm=select(p,market:==m)
		qm=select(q,market:==m)
		sm=select(s,market:==m)
		brandm=select(brand,market:==m)
		alpham=select(alpha,market:==m)
		sigmagm=select(sigmag,market:==m)
		gm=select(g,market:==m)
		sjgm=select(sjg,market:==m)
		_alpha=mean(alpham)
		_sigmag=mean(sigmagm)
	
		// matrices for summations
		msumb=select(amsumb,market:==m)
		im=runningsum(J(rows(gm),1,1))
		msumg=amsumf(im,gm)

		// calculation of brand level elasticity matrix
		qbm=msumb'*qm																// brand level quantities
		if (rows(uniqrows(brandm))==rows(brandm)) {									// if no grouping (no aggregation needed)
			elm0=J(rows(brandm),rows(brandm),1):*sm'
			elm0=elm0 :+ (_sigmag/(1-_sigmag))*(msumg):*(sjgm')
			elm0=elm0 :- diag( J(rows(elm0),1,(1/(1-_sigmag))) )
			elm0=_alpha*elm0
			elm0=elm0:*pm'															// transforming into elasticities: multiplying by derivating prices
			elm=J(rows(el),cols(el),0)
			elm[brandm,brandm]=elm0													// elasticity matrix of market m
		}
		if (rows(uniqrows(brandm))!=rows(brandm) & rows(uniqrows(brandm))!=1) {		// if grouping (aggregation needed)
			pbm=((msumb:*qm)'*pm):/(colsum((msumb:*qm))')							// brand level weighted average prices
			sbm=msumb'*sm															// brand level market shares
			elm=J(rows(brandm),1,1)*(sbm')											// brand level elasticity matrix of market m
			elm=elm :+ (_sigmag/(1-_sigmag))*(msumg:*(sjgm'))*msumb
			elm=elm :- msumb*(1/(1-_sigmag))
			elm=_alpha*elm:*sm
			elm=msumb'*elm
			elm=elm:/sbm															// transforming into semi elasticities: dividing by shares to be derivated
			elm=elm:*pbm'															// transforming into elasticities: multiplying by derivating prices 
			// changing missing values to zero (in unbalanced panels elasticities involving product(s) not present at the given market are missing)
			if (rows(elm)>1) {
				missing_index=(elm[.,1]:==.):*runningsum(J(rows(elm),1,1))
				missing_index=select(missing_index,missing_index:>0)
				elm[missing_index,.]=J(rows(elm[missing_index,.]),cols(elm[missing_index,.]),0)
				elm[.,missing_index]=J(rows(elm[.,missing_index]),cols(elm[.,missing_index]),0)
				missing_index=(elm[1,.]':==.):*runningsum(J(rows(elm),1,1))
				missing_index=select(missing_index,missing_index:>0)
				elm[missing_index,.]=J(rows(elm[missing_index,.]),cols(elm[missing_index,.]),0)
				elm[.,missing_index]=J(rows(elm[.,missing_index]),cols(elm[.,missing_index]),0)
			}
		}
		if (rows(uniqrows(brandm))!=rows(brandm) & rows(uniqrows(brandm))==1) {		// if market level elasticity
			pbm=((msumb:*qm)'*pm):/(colsum((msumb:*qm))')							// market level weighted average price
			elm=-_alpha*(1-sum(sm))*pbm
		}

		// weigth matrix for market m
		weightm=qbm#J(1,rows(qbm),1)

		// adding up weights and weighted elasticities
		weight=weight:+weightm
		el=el:+(elm:*weightm)

	}	// end of m (markets) loop 

	el=el:/weight																	// normalizing: final, weighted average (across markets) elasticity matrix

	// calculation of loss diversations for average elasticites
	for (j=1; j<=colmax(brand); j++) {
		if (sum(brand:==j)!=0) {		// only if brand j is present
			for (i=1; i<=colmax(brand); i++) {
				if (sum(brand:==i)!=0) {		// only if brand i is present
					dr[i,j]=100*sum(q:*(brand:==i))*el[i,j]/abs(sum(q:*(brand:==j))*el[j,j])
				}
			}
		}
	}

	// storing in Stata
	st_matrix("el", el)
	st_matrix("dr", dr)
	
}	// end of elasticities_nlogit function
mata mlib add lrcl elasticities_nlogit()


// two-level nested logit elasticities and diversion ratios
void elasticities_nlogit2(
	string scalar market0,
	string scalar brand0,
	string scalar g0,
	string scalar h0,
	string scalar p0,
	string scalar q0,
	string scalar share0,
	string scalar sjg0,
	string scalar sjh0,
	string scalar alpha0,
	string scalar sigmag0,
	string scalar sigmah0,
	string scalar touse)
{

	// declarations
	real colvector market,brand,g,h,p,q,s,sjg,sjh,alpha,sigmag,sigmah,marketm,pm,qm,sm,brandm,alpham,sigmagm,sigmahm,gm,hm,sjgm,sjhm,sbm,pbm,scg,sjscg,schg,sjschg,missing_index,im
	real matrix amsumb,el,dr,weight,msumb,msumg,msumhg,elm,qbm,weightm,elm0
	real scalar b,bb,m,elmij,j,i,gg,hh,_alpha,_sigmag,_sigmah

	// load data
	st_view(market, .,tokens(market0),touse)
	st_view(brand, .,tokens(brand0),touse)
	st_view(g, .,tokens(g0),touse)
	st_view(h, .,tokens(h0),touse)
	st_view(p, .,tokens(p0),touse)
	st_view(q, .,tokens(q0),touse)
	st_view(s, .,tokens(share0),touse)
	st_view(sjg, .,tokens(sjg0),touse)
	st_view(sjh, .,tokens(sjh0),touse)
	st_view(alpha, .,tokens(alpha0),touse)
	st_view(sigmag, .,tokens(sigmag0),touse)
	st_view(sigmah, .,tokens(sigmah0),touse)
	
	// reindexing group variable (categorical variables should start from 1 and increment by 1)
	market=reindex(market)
	brand=reindex(brand)
	g=reindex(g)
	h=reindex(h)

	// matrix for summations
	amsumb=J(rows(market),colmax(brand)-colmin(brand)+1,0)
	b=0
	for (bb=colmin(brand); bb<=colmax(brand); bb++) {
		b=b+1
		amsumb[.,b]=(brand:==bb)
	}

	el=J(colmax(brand),colmax(brand),0)												// brand level elasticity matrix
	dr=J(colmax(brand),colmax(brand),0)												// brand level diversion ratio matrix
	weight=J(colmax(brand),colmax(brand),0)											// weight matrix
	for (m=colmin(market); m<=colmax(market); m++) {								// calcualtions by markets

		// variables
		marketm=select(market,market:==m)
		pm=select(p,market:==m)
		qm=select(q,market:==m)
		sm=select(s,market:==m)
		brandm=select(brand,market:==m)
		alpham=select(alpha,market:==m)
		sigmagm=select(sigmag,market:==m)
		sigmahm=select(sigmah,market:==m)
		gm=select(g,market:==m)
		hm=select(h,market:==m)
		sjgm=select(sjg,market:==m)
		sjhm=select(sjh,market:==m)
		_alpha=mean(alpham)
		_sigmag=mean(sigmagm)
		_sigmah=mean(sigmahm)
	
		// matrices for summations
		msumb=select(amsumb,market:==m)
		im=runningsum(J(rows(gm),1,1))
		msumg=amsumf(im,gm)
		msumhg=amsumf(im,hm):*msumg

		// calculation of brand level elasticity matrix
		qbm=msumb'*qm																// brand level quantities
		elm=J(colmax(brand),colmax(brand),0)										// brand level elasticity matrix of market m
		if (rows(uniqrows(brandm))==rows(brandm)) {									// if no grouping (no aggregation needed)
			elm0=J(rows(brandm),rows(brandm),1):*sm'
			elm0=elm0 :+ (_sigmag/(1-_sigmag))*(msumg):*(sjgm')
			elm0=elm0 :+ ( (1/(1-_sigmah)) - (1/(1-_sigmag)) )*(msumhg):*(sjhm')
			elm0=elm0 :- diag( J(rows(elm0),1,(1/(1-_sigmah))) )
			elm0=_alpha*elm0
			elm0=elm0:*pm'															// transforming into elasticities: multiplying by derivating prices
			elm=J(rows(el),cols(el),0)
			elm[brandm,brandm]=elm0													// elasticity matrix of market m 
		}
		if (rows(uniqrows(brandm))!=rows(brandm) & rows(uniqrows(brandm))!=1) {		// if grouping (aggregation needed)
			pbm=((msumb:*qm)'*pm):/(colsum((msumb:*qm))')							// brand level weighted average prices
			sbm=msumb'*sm															// brand level market shares
			elm=J(rows(brandm),1,1)*(sbm')											// brand level elasticity matrix of market m
			elm=elm :+ (_sigmag/(1-_sigmag))*(msumg:*(sjgm'))*msumb
			elm=elm :+ ( (1/(1-_sigmah)) - (1/(1-_sigmag)) )*(msumhg:*(sjhm'))*msumb
			elm=elm :- msumb*(1/(1-_sigmah))
			elm=_alpha*elm:*sm
			elm=msumb'*elm
			elm=elm:/sbm															// transforming into semi elasticities: dividing by shares to be derivated
			elm=elm:*pbm'															// transforming into elasticities: multiplying by derivating prices
			// changing missing values to zero (in unbalanced panels elasticities involving product(s) not present at the given market are missing)
			if (rows(elm)>1) {
				missing_index=(elm[.,1]:==.):*runningsum(J(rows(elm),1,1))
				missing_index=select(missing_index,missing_index:>0)
				elm[missing_index,.]=J(rows(elm[missing_index,.]),cols(elm[missing_index,.]),0)
				elm[.,missing_index]=J(rows(elm[.,missing_index]),cols(elm[.,missing_index]),0)
				missing_index=(elm[1,.]':==.):*runningsum(J(rows(elm),1,1))
				missing_index=select(missing_index,missing_index:>0)
				elm[missing_index,.]=J(rows(elm[missing_index,.]),cols(elm[missing_index,.]),0)
				elm[.,missing_index]=J(rows(elm[.,missing_index]),cols(elm[.,missing_index]),0)
			}
		}
		if (rows(uniqrows(brandm))!=rows(brandm) & rows(uniqrows(brandm))==1) {		// if market level elasticity
			pbm=((msumb:*qm)'*pm):/(colsum((msumb:*qm))')							// market level weighted average price
			elm=-_alpha*(1-sum(sm))*pbm
		}

		// weigth matrix for market m
		weightm=qbm#J(1,rows(qbm),1)

		// adding up weights and weighted elasticities
		weight=weight:+weightm
		el=el:+(elm:*weightm)
	
	}	// end of m (markets) loop 

	el=el:/weight																	// normalizing: final, weighted average (across markets) elasticity matrix

	// calculation of loss diversations for average elasticites
	for (j=1; j<=colmax(brand); j++) {
		if (sum(brand:==j)!=0) {		// only if brand j is present
			for (i=1; i<=colmax(brand); i++) {
				if (sum(brand:==i)!=0) {		// only if brand i is present
					dr[i,j]=100*sum(q:*(brand:==i))*el[i,j]/abs(sum(q:*(brand:==j))*el[j,j])
				}
			}
		}
	}

	// storing in Stata
	st_matrix("el", el)
	st_matrix("dr", dr)
	
}	// end of elasticities_nlogit2 function
mata mlib add lrcl elasticities_nlogit2()


// three-level nested logit elasticities and diversion ratios
void elasticities_nlogit3(
	string scalar market0,
	string scalar brand0,
	string scalar g0,
	string scalar h0,
	string scalar k0,
	string scalar p0,
	string scalar q0,
	string scalar share0,
	string scalar sjg0,
	string scalar sjh0,
	string scalar sjk0,
	string scalar alpha0,
	string scalar sigmag0,
	string scalar sigmah0,
	string scalar sigmak0,
	string scalar touse)
{

	// declarations
	real colvector market,brand,g,h,k,p,q,s,sjg,sjh,sjk,alpha,sigmag,sigmah,sigmak,marketm,pm,qm,sm,brandm,alpham,sigmagm,sigmahm,sigmakm,gm,hm,km,sjgm,sjhm,sjkm,sbm,pbm,scg,sjscg,schg,sjschg,sckhg,sjsckhg,missing_index,im
	real matrix amsumb,el,dr,weight,msumb,msumg,msumhg,msumkhg,elm,qbm,weightm,elm0
	real scalar b,bb,m,elmij,j,i,gg,hh,kk,_alpha,_sigmag,_sigmah,_sigmak

	// load data
	st_view(market, .,tokens(market0),touse)
	st_view(brand, .,tokens(brand0),touse)
	st_view(g, .,tokens(g0),touse)
	st_view(h, .,tokens(h0),touse)
	st_view(k, .,tokens(k0),touse)
	st_view(p, .,tokens(p0),touse)
	st_view(q, .,tokens(q0),touse)
	st_view(s, .,tokens(share0),touse)
	st_view(sjg, .,tokens(sjg0),touse)
	st_view(sjh, .,tokens(sjh0),touse)
	st_view(sjk, .,tokens(sjk0),touse)
	st_view(alpha, .,tokens(alpha0),touse)
	st_view(sigmag, .,tokens(sigmag0),touse)
	st_view(sigmah, .,tokens(sigmah0),touse)
	st_view(sigmak, .,tokens(sigmak0),touse)

	// reindexing group variable (categorical variables should start from 1 and increment by 1)
	market=reindex(market)
	brand=reindex(brand)
	g=reindex(g)
	h=reindex(h)
	k=reindex(k)

	// matrix for summations
	amsumb=J(rows(market),colmax(brand)-colmin(brand)+1,0)
	b=0
	for (bb=colmin(brand); bb<=colmax(brand); bb++) {
		b=b+1
		amsumb[.,b]=(brand:==bb)
	}

	el=J(colmax(brand),colmax(brand),0)												// brand level elasticity matrix
	dr=J(colmax(brand),colmax(brand),0)												// brand level diversion ratio matrix
	weight=J(colmax(brand),colmax(brand),0)											// weight matrix

	for (m=colmin(market); m<=colmax(market); m++) {								// calcualtions by markets

		// variables
		marketm=select(market,market:==m)
		pm=select(p,market:==m)
		qm=select(q,market:==m)
		sm=select(s,market:==m)
		brandm=select(brand,market:==m)
		alpham=select(alpha,market:==m)
		sigmagm=select(sigmag,market:==m)
		sigmahm=select(sigmah,market:==m)
		sigmakm=select(sigmak,market:==m)
		gm=select(g,market:==m)
		hm=select(h,market:==m)
		km=select(k,market:==m)
		sjgm=select(sjg,market:==m)
		sjhm=select(sjh,market:==m)
		sjkm=select(sjk,market:==m)
		_alpha=mean(alpham)
		_sigmag=mean(sigmagm)
		_sigmah=mean(sigmahm)
		_sigmak=mean(sigmakm)

		// matrices for summations
		msumb=select(amsumb,market:==m)
		im=runningsum(J(rows(gm),1,1))
		msumg=amsumf(im,gm)
		msumhg=amsumf(im,hm):*msumg
		msumkhg=amsumf(im,km):*msumhg

		// calculation of brand level elasticity matrix
		qbm=msumb'*qm																// brand level quantities
		if (rows(uniqrows(brandm))==rows(brandm)) {									// if no grouping (no aggregation needed)
			elm0=J(rows(brandm),rows(brandm),1):*sm'
			elm0=elm0 :+ (_sigmag/(1-_sigmag))*(msumg):*(sjgm')
			elm0=elm0 :+ ( (1/(1-_sigmah)) - (1/(1-_sigmag)) )*(msumhg):*(sjhm')
			elm0=elm0 :+ ( (1/(1-_sigmak)) - (1/(1-_sigmah)) )*(msumkhg):*(sjkm')
			elm0=elm0 :- diag( J(rows(elm0),1,(1/(1-_sigmak))) )
			elm0=_alpha*elm0
			elm0=elm0:*pm'															// transforming into elasticities: multiplying by derivating prices
			elm=J(rows(el),cols(el),0)
			elm[brandm,brandm]=elm0													// elasticity matrix of market m 
		}
		if (rows(uniqrows(brandm))!=rows(brandm) & rows(uniqrows(brandm))!=1) {		// if grouping (aggregation needed)
			pbm=((msumb:*qm)'*pm):/(colsum((msumb:*qm))')							// brand level weighted average prices
			sbm=msumb'*sm															// brand level market shares
			elm=J(rows(brandm),1,1)*(sbm')											// brand level elasticity matrix of market m
			elm=elm :+ (_sigmag/(1-_sigmag))*(msumg:*(sjgm'))*msumb
			elm=elm :+ ( (1/(1-_sigmah)) - (1/(1-_sigmag)) )*(msumhg:*(sjhm'))*msumb
			elm=elm :+ ( (1/(1-_sigmak)) - (1/(1-_sigmah)) )*(msumkhg:*(sjkm'))*msumb
			elm=elm :- msumb*(1/(1-_sigmak))
			elm=_alpha*elm:*sm
			elm=msumb'*elm
			elm=elm:/sbm															// transforming into semi elasticities: dividing by shares to be derivated
			elm=elm:*pbm'															// transforming into elasticities: multiplying by derivating prices
			// changing missing values to zero (in unbalanced panels elasticities involving product(s) not present at the given market are missing)
			if (rows(elm)>1) {
				missing_index=(elm[.,1]:==.):*runningsum(J(rows(elm),1,1))
				missing_index=select(missing_index,missing_index:>0)
				elm[missing_index,.]=J(rows(elm[missing_index,.]),cols(elm[missing_index,.]),0)
				elm[.,missing_index]=J(rows(elm[.,missing_index]),cols(elm[.,missing_index]),0)
				missing_index=(elm[1,.]':==.):*runningsum(J(rows(elm),1,1))
				missing_index=select(missing_index,missing_index:>0)
				elm[missing_index,.]=J(rows(elm[missing_index,.]),cols(elm[missing_index,.]),0)
				elm[.,missing_index]=J(rows(elm[.,missing_index]),cols(elm[.,missing_index]),0)
			}
		}
		if (rows(uniqrows(brandm))!=rows(brandm) & rows(uniqrows(brandm))==1) {		// if market level elasticity
			pbm=((msumb:*qm)'*pm):/(colsum((msumb:*qm))')							// market level weighted average price
			elm=-_alpha*(1-sum(sm))*pbm
		}

		// weigth matrix for market m
		weightm=qbm#J(1,rows(qbm),1)

		// adding up weights and weighted elasticities
		weight=weight:+weightm
		el=el:+(elm:*weightm)
	
	}	// end of m (markets) loop 

	el=el:/weight																	// normalizing: final, weighted average (across markets) elasticity matrix

	// calculation of loss diversations for average elasticites
	for (j=1; j<=colmax(brand); j++) {
		if (sum(brand:==j)!=0) {		// only if brand j is present
			for (i=1; i<=colmax(brand); i++) {
				if (sum(brand:==i)!=0) {		// only if brand i is present
					dr[i,j]=100*sum(q:*(brand:==i))*el[i,j]/abs(sum(q:*(brand:==j))*el[j,j])
				}
			}
		}
	}
	
	// storing in Stata
	st_matrix("el", el)
	st_matrix("dr", dr)
	
}	// end of elasticities_nlogit3 function
mata mlib add lrcl elasticities_nlogit3()


// BLP elasticity and diversion ratio matrices (averages over markets)
// elvar: variable specifying the groups to which the aggregation is to be done (product, brand, firm, etc.)
void elasticities_rcl(
	real colvector theta1,
	real rowvector theta2,
	real colvector delta,
	real colvector elvar)
{

	// declarations
	external real colvector market,p,s,msize
	external real matrix rc,simdraws,msumm,prices,rc_prices
	external real scalar _is_rc_on_p
	real colvector brand,q,sigmas,pm,qm,sm,sbm,qbm,pbm,missing_index
	real matrix amsumb,alphai,mu,shati,el,dr,weight,shatim,msumb,shatimb,elm,weightm
	real scalar b,bb,alpha,m,j,i
	
	// reindexed group variable (henceforth, it is called "brand")
	brand=reindex(elvar)

	// quantities
	q=s:*msize

	// matrix for summations
	amsumb=J(rows(market),colmax(brand)-colmin(brand)+1,0)
	b=0
	for (bb=colmin(brand); bb<=colmax(brand); bb++) {
		b=b+1
		amsumb[.,b]=(brand:==bb)
	}

	// parameters
	sigmas=theta2'																	// vector of random coefficient parameters
	alpha=-theta1[1,1]																// mean price coefficient
	if (_is_rc_on_p==1) {
		alphai=alpha:-(sigmas[1,1]*simdraws[1,.])									// individual price coefficients (if there is random coefficient on price)
	}
	if (_is_rc_on_p==0) {
		alphai=alpha:*J(1,cols(simdraws),1)											// individual price coefficients (if there is no random coefficient on price)
	}
	mu=rc*(sigmas:*simdraws[1..rows(simdraws)-1,.])									// matrix of observed consumer heterogeneity (separate column for each consumer)

	// predicted market shares
	shati=exp(delta:+mu)															// predicted individual choice probabilities
	shati=shati:/(1:+msumm*((shati'*msumm)'))

	el=J(colmax(brand),colmax(brand),0)												// brand level elasticity matrix
	dr=J(colmax(brand),colmax(brand),0)												// brand level diversion ratio matrix
	weight=J(colmax(brand),colmax(brand),0)											// weight matrix

	for (m=colmin(market); m<=colmax(market); m++) {								// calcualtions by markets

		// variables
		pm=select(p,market:==m)
		qm=select(q,market:==m)
		sm=select(s,market:==m)
		brandm=select(brand,market:==m)
		shatim=select(shati,market:==m)

		// brand matrix for summations
		msumb=select(amsumb,market:==m)

		/* calculation of brand level elasticity matrix */

		// auxiliary objects
		shatimb=msumb'*shatim														// individual choice probabilities of brands (sums of product level probabilities for a given consumer)
		sbm=msumb'*sm																// brand level market shares
		qbm=msumb'*qm																// brand level quantities
		pbm=((msumb:*qm)'*pm):/(colsum((msumb:*qm))')								// brand level weighted average prices

		// brand level elasticity matrix
		// rows: brands whose shares respond (derivated shares)
		// columns: brands whose prices increase (derivating prices)
		elm=((alphai:*shatimb):*(simdraws[rows(simdraws),.]))*shatimb'				// general (to all elasticities) cross terms
		elm=elm:-diag((alphai:*shatimb)*simdraws[rows(simdraws),.]')				// terms specific to own-price elasticites
		elm=elm:/sbm																// transforming into semi elasticities: dividing by shares to be derivated
		elm=elm:*pbm'																// transforming into elasticities: multiplying by derivating prices

		// changing missing values to zero (in unbalanced panels elasticities involving product(s) not present at the given market are missing)
		if (rows(elm)>1) {
			missing_index=(elm[.,1]:==.):*runningsum(J(rows(elm),1,1))
			missing_index=select(missing_index,missing_index:>0)
			elm[missing_index,.]=J(rows(elm[missing_index,.]),cols(elm[missing_index,.]),0)
			elm[.,missing_index]=J(rows(elm[.,missing_index]),cols(elm[.,missing_index]),0)
			missing_index=(elm[1,.]':==.):*runningsum(J(rows(elm),1,1))
			missing_index=select(missing_index,missing_index:>0)
			elm[missing_index,.]=J(rows(elm[missing_index,.]),cols(elm[missing_index,.]),0)
			elm[.,missing_index]=J(rows(elm[.,missing_index]),cols(elm[.,missing_index]),0)
		}

		// weigth matrix for market m
		weightm=qbm#J(1,rows(sbm),1)

		// adding up weights and weighted elasticities
		weight=weight:+weightm
		el=el:+(elm:*weightm)

	}	// end of m (markets) loop 

	el=el:/weight																	// normalizing: final, weighted average (across markets) elasticity matrix

	// calculation of loss diversations for average elasticites
	for (j=1; j<=colmax(brand); j++) {
		if (sum(brand:==j)!=0) {		// only if brand j is present
			for (i=1; i<=colmax(brand); i++) {
				if (sum(brand:==i)!=0) {		// only if brand i is present
					dr[i,j]=100*sum(q:*(brand:==i))*el[i,j]/abs(sum(q:*(brand:==j))*el[j,j])
				}
			}
		}
	}

	
	// storing in Stata
	st_matrix("el", el)
	st_matrix("dr", dr)
	
}	// end of elasticities_rcl function
mata mlib add lrcl elasticities_rcl()

end
