
****************************
* Mata funcitons: SSNIP-test
****************************

mata:

mata clear

// SSNIP-test: simple logit model
void ssnip_logit(
	string scalar market0,
	string scalar firm0,
	string scalar segment0,
	string scalar msize0,
	string scalar p0,
	string scalar share0,
	string scalar xb0,
	string scalar ksi0,
	string scalar alpha0,
	string scalar obs0,
	string scalar mc0,
	string scalar vat0,
	string scalar nodisplay0,
	string scalar touse)
{

	// declarations
	real colvector market,firm,segment,msize,p,s,xb,ksi,alpha,obs,vat/*
		*/,marketm,productm,firmm,segmentm,msizem,pm,sm,xbm,ksim,alpham,obsm,mcm,vatm/*
		*/,deltam,shatm/*
		*/,pm_ssnip,prm,prm_ssnip
	real rowvector ssnips
	real matrix ssnip,ssnipm
	real scalar m,ss,sss,dprsm,weight

	// load data
	st_view(market, .,tokens(market0),touse)
	st_view(firm, .,tokens(firm0),touse)
	st_view(segment, .,tokens(segment0),touse)
	st_view(msize, .,tokens(msize0),touse)
	st_view(p, .,tokens(p0),touse)
	st_view(s, .,tokens(share0),touse)
	st_view(xb, .,tokens(xb0),touse)
	st_view(ksi, .,tokens(ksi0),touse)
	st_view(alpha, .,tokens(alpha0),touse)
	st_view(obs, .,tokens(obs0),touse)
	st_view(mc, .,tokens(mc0),touse)
	st_view(vat, .,tokens(vat0),touse)

	// reindexing group variables (categorical variables should start from 1 and increment by 1; reindexig doesn't change the sort order of the data)
	market=reindex(market)
	segment=reindex(segment)
	
	// initializing matrices
	ssnips=(1,5,10)
	ssnipm=J(colmax(segment),cols(ssnips),0)
	ssnip=J(colmax(segment),cols(ssnips),0)
	weight=0

	for (m=colmin(market); m<=colmax(market); m++) {								// calcualtions by markets

		// variables for market m
		marketm=select(market,market:==m)
		firmm=select(firm,market:==m)
		segmentm=select(segment,market:==m)
		msizem=select(msize,market:==m)
		pm=select(p,market:==m)
		sm=select(s,market:==m)
		xbm=select(xb,market:==m)
		ksim=select(ksi,market:==m)
		alpham=select(alpha,market:==m)
		obsm=select(obs,market:==m)
		mcm=select(mc,market:==m)
		vatm=select(vat,market:==m)
		productm=runningsum(J(rows(marketm),1,1))

		// pre-SSNIP profits
		prm=((pm:/(1:+vatm)):-mcm):*sm:*msizem

		// calculating post-SSNIP profits
		for (ss=colmin(segmentm); ss<=colmax(segmentm); ss++) {		// loop over the canditate relevant markets

			for (sss=1; sss<=cols(ssnips); sss++) {					// loop over different SSNIPs (1%, 5%, 10%)
				// SSNIP prices
				pm_ssnip=pm:*J(rows(marketm),1,1+ssnips[1,sss]/100):*(segmentm:==ss):+pm:*(segmentm:!=ss)
				// predicted market shares
				shatm=shatm_logit(pm_ssnip,xbm,ksim,alpham)
				// post-SSNIP profits & change in profits for segment tested
				prm_ssnip=((pm_ssnip:/(1:+vatm)):-mcm):*shatm:*msizem
				dprsm=100*colsum(prm_ssnip:*(segmentm:==ss)):/colsum(prm:*(segmentm:==ss)):-100
				ssnipm[ss,sss]=dprsm
			}

		}	// end of ss (candidate relevant markets) loop
		
		// average SSNIPs over markets
		ssnip=ssnip :+ ssnipm*colsum((sm:*msizem))
		weight=weight+colsum((sm:*msizem))

	}	// end of m (markets) loop 

	// normalization
	ssnip=ssnip/weight

	// saving Stata matrix
	st_matrix("ssnip", ssnip)

}	// end of ssnip_logit function
mata mlib add lrcl ssnip_logit()


// SSNIP-test: one-level nested logit model
void ssnip_nlogit(
	string scalar market0,
	string scalar firm0,
	string scalar segment0,
	string scalar msize0,
	string scalar p0,
	string scalar share0,
	string scalar xb0,
	string scalar ksi0,
	string scalar g0,
	string scalar alpha0,
	string scalar sigmag0,
	string scalar obs0,
	string scalar mc0,
	string scalar vat0,
	string scalar nodisplay0,
	string scalar touse)
{

	// declarations
	real colvector market,firm,segment,msize,p,s,xb,ksi,g,alpha,sigmag,obs,vat/*
		*/,marketm,productm,firmm,segmentm,msizem,pm,sm,xbm,ksim,gm,alpham,sigmagm,obsm,mcm,vatm/*
		*/,deltam,shatm/*
		*/,pm_ssnip,prm,prm_ssnip
	real rowvector ssnips
	real matrix msumg,ssnip,ssnipm
	real scalar m,ss,sss,dprsm,weight

	// load data
	st_view(market, .,tokens(market0),touse)
	st_view(firm, .,tokens(firm0),touse)
	st_view(segment, .,tokens(segment0),touse)
	st_view(msize, .,tokens(msize0),touse)
	st_view(p, .,tokens(p0),touse)
	st_view(s, .,tokens(share0),touse)
	st_view(xb, .,tokens(xb0),touse)
	st_view(ksi, .,tokens(ksi0),touse)
	st_view(g, .,tokens(g0),touse)
	st_view(alpha, .,tokens(alpha0),touse)
	st_view(sigmag, .,tokens(sigmag0),touse)
	st_view(obs, .,tokens(obs0),touse)
	st_view(mc, .,tokens(mc0),touse)
	st_view(vat, .,tokens(vat0),touse)

	// reindexing group variables (categorical variables should start from 1 and increment by 1; reindexig doesn't change the sort order of the data)
	market=reindex(market)
	segment=reindex(segment)
	g=reindex(g)
	
	// initializing matrices
	ssnips=(1,5,10)
	ssnipm=J(colmax(segment),cols(ssnips),0)
	ssnip=J(colmax(segment),cols(ssnips),0)
	weight=0

	for (m=colmin(market); m<=colmax(market); m++) {								// calcualtions by markets

		// variables for market m
		marketm=select(market,market:==m)
		firmm=select(firm,market:==m)
		segmentm=select(segment,market:==m)
		msizem=select(msize,market:==m)
		pm=select(p,market:==m)
		sm=select(s,market:==m)
		xbm=select(xb,market:==m)
		ksim=select(ksi,market:==m)
		gm=select(g,market:==m)
		alpham=select(alpha,market:==m)
		sigmagm=select(sigmag,market:==m)
		obsm=select(obs,market:==m)
		mcm=select(mc,market:==m)
		vatm=select(vat,market:==m)
		productm=runningsum(J(rows(marketm),1,1))

		// matrices for summations
		msumg=amsumf(productm,gm)															// nest summation matrix

		// pre-SSNIP profits
		prm=((pm:/(1:+vatm)):-mcm):*sm:*msizem

		// calculating post-SSNIP profits
		for (ss=colmin(segmentm); ss<=colmax(segmentm); ss++) {		// loop over the canditate relevant markets

			for (sss=1; sss<=cols(ssnips); sss++) {					// loop over different SSNIPs (1%, 5%, 10%)
				// SSNIP prices
				pm_ssnip=pm:*J(rows(marketm),1,1+ssnips[1,sss]/100):*(segmentm:==ss):+pm:*(segmentm:!=ss)
				// predicted market shares
				shatm=shatm_nlogit(pm_ssnip,xbm,ksim,alpham,sigmagm,msumg)
				// post-SSNIP profits & change in profits for segment tested
				prm_ssnip=((pm_ssnip:/(1:+vatm)):-mcm):*shatm:*msizem
				dprsm=100*colsum(prm_ssnip:*(segmentm:==ss)):/colsum(prm:*(segmentm:==ss)):-100
				ssnipm[ss,sss]=dprsm
			}

		}	// end of ss (candidate relevant markets) loop
		
		// average SSNIPs over markets
		ssnip=ssnip :+ ssnipm*colsum((sm:*msizem))
		weight=weight+colsum((sm:*msizem))

	}	// end of m (markets) loop 

	// normalization
	ssnip=ssnip/weight

	// saving Stata matrix
	st_matrix("ssnip", ssnip)

}	// end of ssnip_nlogit function
mata mlib add lrcl ssnip_nlogit()


// SSNIP-test: two-level nested logit model
void ssnip_nlogit2(
	string scalar market0,
	string scalar firm0,
	string scalar segment0,
	string scalar msize0,
	string scalar p0,
	string scalar share0,
	string scalar xb0,
	string scalar ksi0,
	string scalar g0,
	string scalar h0,
	string scalar alpha0,
	string scalar sigmag0,
	string scalar sigmah0,
	string scalar obs0,
	string scalar mc0,
	string scalar vat0,
	string scalar nodisplay0,
	string scalar touse)
{

	// declarations
	real colvector market,firm,segment,msize,p,s,xb,ksi,g,h,alpha,sigmag,sigmah,obs,vat/*
		*/,marketm,productm,firmm,segmentm,msizem,pm,sm,xbm,ksim,gm,hm,alpham,sigmagm,sigmahm,obsm,mcm,vatm/*
		*/,deltam,shatm/*
		*/,pm_ssnip,prm,prm_ssnip
	real rowvector ssnips
	real matrix msumg,msumhg,ssnip,ssnipm
	real scalar m,ss,sss,dprsm,weight

	// load data
	st_view(market, .,tokens(market0),touse)
	st_view(firm, .,tokens(firm0),touse)
	st_view(segment, .,tokens(segment0),touse)
	st_view(msize, .,tokens(msize0),touse)
	st_view(p, .,tokens(p0),touse)
	st_view(s, .,tokens(share0),touse)
	st_view(xb, .,tokens(xb0),touse)
	st_view(ksi, .,tokens(ksi0),touse)
	st_view(g, .,tokens(g0),touse)
	st_view(h, .,tokens(h0),touse)
	st_view(alpha, .,tokens(alpha0),touse)
	st_view(sigmag, .,tokens(sigmag0),touse)
	st_view(sigmah, .,tokens(sigmah0),touse)
	st_view(obs, .,tokens(obs0),touse)
	st_view(mc, .,tokens(mc0),touse)
	st_view(vat, .,tokens(vat0),touse)

	// reindexing group variables (categorical variables should start from 1 and increment by 1; reindexig doesn't change the sort order of the data)
	market=reindex(market)
	segment=reindex(segment)
	g=reindex(g)
	h=reindex(h)
	
	// initializing matrices
	ssnips=(1,5,10)
	ssnipm=J(colmax(segment),cols(ssnips),0)
	ssnip=J(colmax(segment),cols(ssnips),0)
	weight=0

	for (m=colmin(market); m<=colmax(market); m++) {								// calcualtions by markets

		// variables for market m
		marketm=select(market,market:==m)
		firmm=select(firm,market:==m)
		segmentm=select(segment,market:==m)
		msizem=select(msize,market:==m)
		pm=select(p,market:==m)
		sm=select(s,market:==m)
		xbm=select(xb,market:==m)
		ksim=select(ksi,market:==m)
		gm=select(g,market:==m)
		hm=select(h,market:==m)
		alpham=select(alpha,market:==m)
		sigmagm=select(sigmag,market:==m)
		sigmahm=select(sigmah,market:==m)
		obsm=select(obs,market:==m)
		mcm=select(mc,market:==m)
		vatm=select(vat,market:==m)
		productm=runningsum(J(rows(marketm),1,1))

		// matrices for summations
		msumg=amsumf(productm,gm)															// nest summation matrix
		msumhg=amsumf(productm,hm):*msumg													// subnest summation matrix

		// pre-SSNIP profits
		prm=((pm:/(1:+vatm)):-mcm):*sm:*msizem

		// calculating post-SSNIP profits
		for (ss=colmin(segmentm); ss<=colmax(segmentm); ss++) {		// loop over the canditate relevant markets

			for (sss=1; sss<=cols(ssnips); sss++) {					// loop over different SSNIPs (1%, 5%, 10%)
				// SSNIP prices
				pm_ssnip=pm:*J(rows(marketm),1,1+ssnips[1,sss]/100):*(segmentm:==ss):+pm:*(segmentm:!=ss)
				// predicted market shares
				shatm=shatm_nlogit2(pm_ssnip,xbm,ksim,alpham,sigmagm,sigmahm,msumg,msumhg)
				// post-SSNIP profits & change in profits for segment tested
				prm_ssnip=((pm_ssnip:/(1:+vatm)):-mcm):*shatm:*msizem
				dprsm=100*colsum(prm_ssnip:*(segmentm:==ss)):/colsum(prm:*(segmentm:==ss)):-100
				ssnipm[ss,sss]=dprsm
			}

		}	// end of ss (candidate relevant markets) loop
		
		// average SSNIPs over markets
		ssnip=ssnip :+ ssnipm*colsum((sm:*msizem))
		weight=weight+colsum((sm:*msizem))

	}	// end of m (markets) loop 

	// normalization
	ssnip=ssnip/weight

	// saving Stata matrix
	st_matrix("ssnip", ssnip)

}	// end of ssnip_nlogit2 function
mata mlib add lrcl ssnip_nlogit2()


// SSNIP-test: three-level nested logit model
void ssnip_nlogit3(
	string scalar market0,
	string scalar firm0,
	string scalar segment0,
	string scalar msize0,
	string scalar p0,
	string scalar share0,
	string scalar xb0,
	string scalar ksi0,
	string scalar g0,
	string scalar h0,
	string scalar k0,
	string scalar alpha0,
	string scalar sigmag0,
	string scalar sigmah0,
	string scalar sigmak0,
	string scalar obs0,
	string scalar mc0,
	string scalar vat0,
	string scalar nodisplay0,
	string scalar touse)
{

	// declarations
	real colvector market,firm,segment,msize,p,s,xb,ksi,g,h,k,alpha,sigmag,sigmah,sigmak,obs,vat/*
		*/,marketm,productm,firmm,segmentm,msizem,pm,sm,xbm,ksim,gm,hm,km,alpham,sigmagm,sigmahm,sigmakm,obsm,mcm,vatm/*
		*/,deltam,shatm/*
		*/,pm_ssnip,prm,prm_ssnip
	real rowvector ssnips
	real matrix msumg,msumhg,msumkhg,ssnip,ssnipm
	real scalar m,ss,sss,dprsm,weight

	// load data
	st_view(market, .,tokens(market0),touse)
	st_view(firm, .,tokens(firm0),touse)
	st_view(segment, .,tokens(segment0),touse)
	st_view(msize, .,tokens(msize0),touse)
	st_view(p, .,tokens(p0),touse)
	st_view(s, .,tokens(share0),touse)
	st_view(xb, .,tokens(xb0),touse)
	st_view(ksi, .,tokens(ksi0),touse)
	st_view(g, .,tokens(g0),touse)
	st_view(h, .,tokens(h0),touse)
	st_view(k, .,tokens(k0),touse)
	st_view(alpha, .,tokens(alpha0),touse)
	st_view(sigmag, .,tokens(sigmag0),touse)
	st_view(sigmah, .,tokens(sigmah0),touse)
	st_view(sigmak, .,tokens(sigmak0),touse)
	st_view(obs, .,tokens(obs0),touse)
	st_view(mc, .,tokens(mc0),touse)
	st_view(vat, .,tokens(vat0),touse)

	// reindexing group variables (categorical variables should start from 1 and increment by 1; reindexig doesn't change the sort order of the data)
	market=reindex(market)
	segment=reindex(segment)
	g=reindex(g)
	h=reindex(h)
	k=reindex(k)
	
	// initializing matrices
	ssnips=(1,5,10)
	ssnipm=J(colmax(segment),cols(ssnips),0)
	ssnip=J(colmax(segment),cols(ssnips),0)
	weight=0

	for (m=colmin(market); m<=colmax(market); m++) {								// calcualtions by markets

		// variables for market m
		marketm=select(market,market:==m)
		firmm=select(firm,market:==m)
		segmentm=select(segment,market:==m)
		msizem=select(msize,market:==m)
		pm=select(p,market:==m)
		sm=select(s,market:==m)
		xbm=select(xb,market:==m)
		ksim=select(ksi,market:==m)
		gm=select(g,market:==m)
		hm=select(h,market:==m)
		km=select(k,market:==m)
		alpham=select(alpha,market:==m)
		sigmagm=select(sigmag,market:==m)
		sigmahm=select(sigmah,market:==m)
		sigmakm=select(sigmak,market:==m)
		obsm=select(obs,market:==m)
		mcm=select(mc,market:==m)
		vatm=select(vat,market:==m)
		productm=runningsum(J(rows(marketm),1,1))

		// matrices for summations
		msumg=amsumf(productm,gm)															// nest summation matrix
		msumhg=amsumf(productm,hm):*msumg													// subnest summation matrix
		msumkhg=amsumf(productm,km):*msumhg													// sub-subnest summation matrix

		// pre-SSNIP profits
		prm=((pm:/(1:+vatm)):-mcm):*sm:*msizem

		// calculating post-SSNIP profits
		for (ss=colmin(segmentm); ss<=colmax(segmentm); ss++) {		// loop over the canditate relevant markets

			for (sss=1; sss<=cols(ssnips); sss++) {					// loop over different SSNIPs (1%, 5%, 10%)
				// SSNIP prices
				pm_ssnip=pm:*J(rows(marketm),1,1+ssnips[1,sss]/100):*(segmentm:==ss):+pm:*(segmentm:!=ss)
				// predicted market shares
				shatm=shatm_nlogit3(pm_ssnip,xbm,ksim,alpham,sigmagm,sigmahm,sigmakm,msumg,msumhg,msumkhg)
				// post-SSNIP profits & change in profits for segment tested
				prm_ssnip=((pm_ssnip:/(1:+vatm)):-mcm):*shatm:*msizem
				dprsm=100*colsum(prm_ssnip:*(segmentm:==ss)):/colsum(prm:*(segmentm:==ss)):-100
				ssnipm[ss,sss]=dprsm
			}

		}	// end of ss (candidate relevant markets) loop
		
		// average SSNIPs over markets
		ssnip=ssnip :+ ssnipm*colsum((sm:*msizem))
		weight=weight+colsum((sm:*msizem))

	}	// end of m (markets) loop 

	// normalization
	ssnip=ssnip/weight

	// saving Stata matrix
	st_matrix("ssnip", ssnip)

}	// end of ssnip_nlogit3 function
mata mlib add lrcl ssnip_nlogit3()


// SSNIP-test: random coefficient logit models (BLP)
void ssnip_rcl(
	real colvector market,
	real colvector firm,
	real colvector segment,
	real colvector p,
	real colvector s,
	real colvector msize,
	real matrix xd0,
	real colvector ksi,
	real colvector mc,
	real colvector vat,
	real matrix rc,
	real colvector g,
	real colvector h,
	real colvector k,
	real matrix simdraws,
	real rowvector params,
	real colvector beta,
	real scalar _is_rc_on_p)
{

	// declarations
	real colvector marketm,firmm,segmentm,msizem,pm,sm,xd0m,ksim,rcm,gm,hm,km,mcm,vatm/*
		*/,shatm/*
		*/,pm_ssnip,prm,prm_ssnip
	real rowvector ssnips
	real matrix ssnip,ssnipm
	real scalar m,ss,sss,dprsm,weight

	// reindexing group variables (categorical variables should start from 1 and increment by 1; reindexig doesn't change the sort order of the data)
	market=reindex(market)
	segment=reindex(segment)
	g=reindex(g)
	h=reindex(h)
	k=reindex(k)

	// initializing matrices
	ssnips=(1,5,10)
	ssnipm=J(colmax(segment),cols(ssnips),0)
	ssnip=J(colmax(segment),cols(ssnips),0)
	weight=0

	for (m=colmin(market); m<=colmax(market); m++) {								// calcualtions by markets

		// variables for market m
		marketm=select(market,market:==m)
		firmm=select(firm,market:==m)
		segmentm=select(segment,market:==m)
		pm=select(p,market:==m)
		sm=select(s,market:==m)
		msizem=select(msize,market:==m)
		xd0m=select(xd0,market:==m)
		ksim=select(ksi,market:==m)
		rcm=select(rc,market:==m)
		gm=select(g,market:==m)
		hm=select(h,market:==m)
		km=select(k,market:==m)
		vatm=select(vat,market:==m)
		mcm=select(mc,market:==m)

		// pre-SSNIP profits
		prm=((pm:/(1:+vatm)):-mcm):*sm:*msizem

		// calculating post-SSNIP profits
		for (ss=colmin(segmentm); ss<=colmax(segmentm); ss++) {		// loop over the canditate relevant markets


			for (sss=1; sss<=cols(ssnips); sss++) {					// loop over different SSNIPs (1%, 5%, 10%)
				// SSNIP prices
				pm_ssnip=pm:*J(rows(marketm),1,1+ssnips[1,sss]/100):*(segmentm:==ss):+pm:*(segmentm:!=ss)
				// predicted market shares
				shatm=shatm_blp(pm,xd0m,ksim,rcm,simdraws,params,beta,_is_rc_on_p)
				// post-SSNIP profits & change in profits for segment tested
				prm_ssnip=((pm_ssnip:/(1:+vatm)):-mcm):*shatm:*msizem
				dprsm=100*colsum(prm_ssnip:*(segmentm:==ss)):/colsum(prm:*(segmentm:==ss)):-100
				ssnipm[ss,sss]=dprsm
			}

		}	// end of ss (candidate relevant markets) loop

		// average SSNIPs over markets
		ssnip=ssnip :+ ssnipm*colsum((sm:*msizem))
		weight=weight+colsum((sm:*msizem))

	}	// end of m (markets) loop
	
	// normalization
	ssnip=ssnip/weight

	// saving Stata matrix
	st_matrix("ssnip", ssnip)

}	// end of ssnip_rcl function
mata mlib add lrcl ssnip_rcl()


end

