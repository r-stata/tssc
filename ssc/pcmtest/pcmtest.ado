* Needed modules :
* gausshermite (http://www.freeirt.org)
* gllamm version 2.3.14 (ssc describe gllamm)

program define pcmtest, eclass 
version 11.0
syntax [, APproximation NEw Group(string) NFit(string) Power(string) Alpha(string) GRAPHics FILEgraph(string) Sitest]
preserve
qui{
tempfile bddtravail
save `bddtravail', replace

capture local cmdavant=e(cmd)
if _rc!=0 | "`cmdavant'"!="pcmodel"{
	noi di in red "Please use pcmtest only after pcmodel"
	error 100
}
if "`graphics'"!=""{
	if "`filegraph'"!=""{
		local ReplaceGr2=0
		local ReplaceGr=strpos("`filegraph'",",")
		if `ReplaceGr'!=0{
			local ReplaceGr=strpos(reverse("`filegraph'"),",")
			local ReplaceGr2=strpos( substr("`filegraph'", strpos("`filegraph'",","), .), "r")!=0
			local filegraphOld="`filegraph'"
			local filegraph=rtrim(reverse(substr(reverse("`filegraph'"),`=`ReplaceGr'+1',.)))
		}

		if `ReplaceGr2'==0{	
			capture graph use "`filegraph'_LT_Sc", nodraw
			if _rc==0{
				noi di in red "`filegraph'_LT_Sc already exists (use option replace for replacing it)"
				error 100
			}
			capture graph use "`filegraph'_MAP", nodraw
			if _rc==0{
				noi di in red "`filegraph'_MAP already exists (use option replace for replacing it)"
				error 100
			}
			capture graph use "`filegraph'_Score_Distrib", nodraw
			if _rc==0{
				noi di in red "`filegraph'_Score_Distrib already exists (use option replace for replacing it)"
				error 100
			}
			capture graph use "`filegraph'_Contrib", nodraw
			if _rc==0{
				noi di in red "`filegraph'_Contrib already exists (use option replace for replacing it)"
				error 100
			}
		}
		capture save "`filegraph'", replace
		if _rc!=0{
			noi di in red "Invalid path specification"
			error 603
		}
		else{
			erase "`filegraph'.dta"
		}
	}
}

   /***************************/
  /* Récuperation de toutes  */
 /*  les matrices estimées  */
/***************************/
local itest=e(itest)
if `itest'==0{
	noi di in red "No tests of fit if the items difficulties are fixed (i.e. not estimated) "
	error 100
}
local Elll=e(mll)
local Ecn=e(cn)
local EN=e(N)
local ENit=e(Nit)
local datatest=e(datatest)
local dataR1m=e(dataR1m)
local mugauss=e(mugauss)
local sdgauss=e(sdgauss)
local ordre=e(order)
local ENqual=e(Ncat)
local ENquant=e(Ncont)
local convergeance=e(converged)	
local Esigma=e(sigma)
local EVarsigma=e(Varsigma)
local ENumFit=e(NumFit)
local Eitems=e(items)
matrix EglobalFit=e(globalFit)
matrix EitemFit=e(itemFit)
matrix Etheta=e(b)
matrix EVartheta=e(V)
matrix Edelta=e(delta)
matrix EVardelta=e(Vardelta)
qui capture matrix list e(globalFit)
if _rc!=0{
	qui capture matrix list e(globalFitTot)
	if _rc!=0{
		local testafaire=1
	}
	else{
		local testafaire=0
	}
}
else{
	local testafaire=0
}
if "`new'"!=""{
local testafaire=1
}
if "`nfit'"!=""{
	local numFit=`nfit'
}
else{
	local numFit=.
}
use `datatest', replace
tempfile bddini
save `bddini'_b, replace
local varlist=e(items)
local nbit: word count `varlist'
local nbitsuf=1
if `nbit'<2{
	noi di in red "No tests of fit if the number of items is less than 2"
	error 100
}
if `nbit'==2{
	noi di in gr "Only the R1m test is performed if the number of items is equal to 2"
	local nbitsuf=0
}
tokenize `varlist'


  /*************************************/
 /*			  	test R1m			  */
/*************************************/

noi di in gr "Performing R1m test"
qui{
	q memory
	local matsizeini=r(matsize)
	set matsize `matsizeini'
	tempfile matU
	tempname dm cell row
	egen `dm'=rowmiss(`varlist')
	replace `dm'=`dm'>0
	tab `dm',matcell(`cell') matrow(`row')
	local nbmissing=`cell'[2,1]
	local percentmissing=`cell'[2,1]/(`cell'[1,1]+`cell'[2,1])
	if `nbmissing'==.{
		local nbmissing=0
		local percentmissing=0
	}
	keep if `dm'==0
	local NbIdFit=_N
	if `numFit'==.{
		local propFit=1
		local propFitPb=0
	}
	else if `numFit'>`NbIdFit'{
		local propFit=1
		local propFitPb=1
	}
	else{
		local propFit=`numFit'/`NbIdFit'
		local propFitPb=2
	}
	drop `dm'
	keep `varlist'
	forvalues i=1/`nbit'{
		rename ``i'' pre_``i''
	}
	forvalues i=1/`nbit'{
		gen it`i'=pre_``i''
		drop pre_``i''
	}
	local nbscore=1
	forvalues i=1/`nbit'{
		qui tab it`i'
		local nbmoda_`i'=r(r)
		local nbscore=`nbscore'+`nbmoda_`i''-1
	}
	local score "it1"
	forvalues i=2/`nbit'{
		local score "`score'+it`i'"
	}
	gen score=`score'
	save `bddini'_se, replace
	local N=_N
/* autogroup */
	if "`group'"==""{
		su score, d
		local list `=r(p25)'
		if `=r(p25)'!=`=r(p50)'{
		local list "`list' `=r(p50)'"
		}
		if `=r(p50)'!=`=r(p75)'{
		local list "`list' `=r(p75)'"
		}
		if `=r(p75)'!=`=`nbscore'-1'{
		local list "`list' `=`nbscore'-1'"
		}
		if wordcount("`list'")==1{
			noi di in red "Problem with Autogroup option: creating groups from the score quartiles is not possible"
		}
		tab score, matcell(freq) matrow(val)
		local nbgroup=wordcount("`list'")
	}
	else{
		tab score, matcell(freq) matrow(val)
		local list "`group'"
		local nbgroup=wordcount("`list'")
		if real(word("`list'",`nbgroup'))<`=`nbscore'-1'{
			local list "`group' `=`nbscore'-1'"
			local nbgroup=wordcount("`list'")
		}
	}
	local nbmodagpe=0
	forvalues i=1/`nbit'{
		local nbmodagpe=`nbmodagpe'+`nbmoda_`i''
	}
	gen g=.
	local liminf1=-1
	forvalues i=1/`nbgroup'{
		local limsup`i'=real("`=word("`list'",`i')'")
		if `i'>1{
			local liminf`i'=real("`=word("`list'",`=`i'-1')'")
		}
		replace g=`i' if score<=`limsup`i'' & score>`liminf`i''
	} 
	forvalues i=1/`nbgroup'{
		su score if g==`i'
		local N`i'=r(N)
	}
	save `bddini'_se, replace
	save `bddini'_se_g, replace
	use `bddini'_se, replace
	local count=0
	if `testafaire'==1{
		forvalues i=1/`nbit'{
			forvalues j=1/`nbmoda_`i''{
				if `j'==1{
					local diffest`i'_`j'=0
				}
				else{
					local count=`count'+1
					local diffest`i'_`j'=round(Edelta[1,`count'],0.001)+`diffest`i'_`=`j'-1''
				}
				local num`i'_`j' "exp(`=`j'-1'*x-`diffest`i'_`j'')"
				if `j'==1{
					local denom`i' "1"
				}
				else{
					local denom`i' "`denom`i''+`num`i'_`j''"
				}
			}
			forvalues j=1/`nbmoda_`i''{
				local PCM`i'_`j' "(`num`i'_`j'')/(`denom`i'')"
			}
		}
		local nbcomb=1
		forvalues i=1/`nbit'{
			local nbcomb=`nbcomb'*`nbmoda_`i''
		}
		clear
		set obs `=int(`nbcomb'+0.1)'
		local facteur=1
		gen score=0
		local order "score"
		forvalues i=1/`nbit'{
			gen it`i'=floor(mod(_n/`facteur',`nbmoda_`i''))
			local facteur=`facteur'*`nbmoda_`i''
			replace score=score+it`i'
			tab it`i', gen(i`i'c)
			local order "`order' it`i'"
		}
		order `order', first
		sort score
	/* Probabilité des paterns de réponse */
		tab score, gen(score)
		local nbscore=r(r)
		gen P=1
		local gdN=_N
	
     /*************************************/
    /*                                   */
   /*    Calcul de la probabilité de    */
  /*      chaque patern de réponses    */
 /*                                   */    
/*************************************/

		if "`approximation'"==""{
		local percentcount=0
		noi di ""
		noi di in ye "`gdN'" in gr " response pattern probabilities to compute"
		noi di in gr "Percentage of completion"
		noi di in gr "----|---10%---|---20%---|---30%---|---40%---|---50%"
		_dots 0, title(Loop computation of theorical probabilities of each response pattern) reps(100)
		forvalues l=1/`gdN'{
			local exp ""
			forvalues i=1/`nbit'{
				forvalues m=1/`nbmoda_`i''{
					if i`i'c`m'[`l']==1{
						if "`exp'"==""{
							local exp "`PCM`i'_`m''"
						}
						else{
							local exp "`exp'*`PCM`i'_`m''"
						}
					}
				}
			}
			gausshermite `exp' , sigma(`sdgauss') mu(`mugauss') display
			replace P=round(r(int),0.000001) if _n==`l'
			local percentcountplus=floor(`l'*100/`gdN')
			forvalues percen=`=`percentcount'+1'/`percentcountplus'{
				nois _dots `percen' 0
			}
			local percentcount=`percentcountplus'
		}
/*save BDDProba, replace		*/
		}
		else{
			noi di in gr "Response pattern probabilities computation"
			replace P=0
			sort score it*
			save `bddini'_proba, replace
			local NbCol=1
			local compteur=1
			forvalues i=1/`nbit'{
				matrix Dit`i'=Edelta[1,`compteur'..`=`compteur'+`nbmoda_`i''-2']
				if colsof(Dit`i')>`NbCol'{
					local NbCol=colsof(Dit`i')
				}
				local compteur=`compteur'+`nbmoda_`i''-1
			}
			clear
			noi di in gr "----|---25%---|---50%---|---75%---|---100%
			qui _dots 0, title(Title) reps(40)
			set obs 1000000
			gen id=_n
			gen theta=`mugauss'+invnormal(uniform())*`sdgauss'
			forvalues i=1/`nbit'{
				gen denom`i'=1
				gen num`i'_0=1
				forvalues j=1/`=`nbmoda_`i''-1'{
					gen num`i'_`j'=exp(ln(num`i'_`=`j'-1') + theta-Dit`i'[1,`j'])
					replace denom`i'=denom`i'+num`i'_`j'
				}
				forvalues j=0/`=`nbmoda_`i''-1'{
					gen p`i'_`j'=num`i'_`j'/denom`i'
				}
				drop denom`i'
				drop num`i'_*
				forvalues j=1/`=`nbmoda_`i''-1'{
					replace p`i'_`j'=p`i'_`j'+p`i'_`=`j'-1'
				}
				gen it`i'=0
				gen random`i'=runiform()
				forvalues j=1/`=`nbmoda_`i''-1'{
					replace it`i'=`j' if random`i'>=p`i'_`=`j'-1' & random`i'<p`i'_`j'
				}
				drop random* p`i'_*
				forvalues j=1/`=round(`=40/`nbit'')'{
					nois _dots `j' 0
				}
			}
			egen score=rowtotal(it*)
			keep it* score
			contract score it*, f(P)
			replace P=round(P/1000000,0.000001)
			sort score it*
			merge score it* using `bddini'_proba
			drop _merge
			order `order', first
			order P, last
		}
		noi di in gr ""
		save `bddini'_R1m, replace
		local dataR1m "`bddini'_R1m"
	}
	else{
		use "`dataR1m'", replace
	}
	tab score
	local Pscoresl=r(r)
	matrix Pscores=J(`Pscoresl',2,.)
	forvalues i=1/`Pscoresl'{
		su P if score==`=`i'-1'
		matrix Pscores[`i',2]=r(sum)
		matrix Pscores[`i',1]=`i'-1
	}
	save `matU'_2, replace
	local sort "score"
	forvalues i=1/`nbit'{
		local sort "`sort' it`i'"
		forvalues j=1/`nbmoda_`i''{
			replace i`i'c`j'=i`i'c`j'*P
		}
	}
	forvalues i=1/`nbscore'{
		replace score`i'=score`i'*P
	}
	save `matU'_1, replace
/* Matrices U */
noi di "U matrix computation"
	local order ""
	forvalues i=1/`=wordcount("`list'")'{
		local nbscoreg`i'= `nbscore'
		forvalues j=0/`=`nbscore'-1'{
			if `j'>`limsup`i'' | `j'<=`liminf`i''{
				local nbscoreg`i'=`nbscoreg`i''-1
				capture drop s`=`j'+1'g`i'
			}
		}
		local order "`order' *g`i'"
		use `matU'_1, replace
		keep if score<=`limsup`i'' & score>`liminf`i''
		gen g=`i'
		forvalues a=1/`nbit'{
			forvalues b=1/`nbmoda_`a''{
				capture rename i`a'c`b' i`a'c`b'g`i'
			}
		}
		forvalues a=1/`nbscore'{
			capture rename score`a' s`a'g`i'
			forvalues j=1/`=wordcount("`list'")'{
				if `=`a'-1'>`limsup`i'' | `=`a'-1' <= `liminf`i''{
					capture drop s`a'g`j'
				}
			}
		}
		tempfile bloc`i'
		sort `sort'
		save `bloc`i''_1, replace
	}
	local order ""
	forvalues i=1/`=wordcount("`list'")'{
		local order "`order' *g`i'"
		use `matU'_2, replace
		keep if score<=`limsup`i'' & score>`liminf`i''
		gen g=`i'
		forvalues a=1/`nbit'{
			forvalues b=1/`nbmoda_`a''{
				capture rename i`a'c`b' i`a'c`b'g`i'b
			}
		}
		forvalues a=1/`nbscore'{
			capture rename score`a' s`a'g`i'b
			forvalues j=1/`=wordcount("`list'")'{

				if `=`a'-1'>`limsup`i'' | `=`a'-1' <= `liminf`i''{
					capture drop s`a'g`j'
				}
			}
		}
		sort `sort'
		save `bloc`i''_2, replace
		describe
		local mat_`i'=r(k)-3-`nbit'
	}
noi di "W matrix computation"
/* Matrice W */
	local nbscoreg0=0
	forvalues g=1/`nbgroup'{
		qui q memory
		if `mat_`g''>r(matsize) & `mat_`g''<=r(m_matsize){
			set matsize `mat_`g''
		}
		if `mat_`g''>r(m_matsize){
			noi di in red "Error, not enough memory to allocate to the W matrix computation"
		}
		matrix W_`g'=J(`mat_`g'',`mat_`g'',.)
		use `bloc`g''_2, replace
		local count=1
		forvalues i=1/`nbit'{
			forvalues j=1/`nbmoda_`i''{
				rename i`i'c`j'g`g'b v`count'b
				local count=`count'+1
			}
		}
		forvalues s=1/`=`nbscore'+1'{
			capture rename s`s'g`g'b v`count'b
			if _rc ==0{
				local count=`count'+1
			}
		}
		local Ncol_`g'_=`count'-1
		save `bloc`g''_2b, replace
		use `bloc`g''_1, replace
		local count=1
		forvalues i=1/`nbit'{
			forvalues j=1/`nbmoda_`i''{
				rename i`i'c`j'g`g' v`count'
				local count=`count'+1
			}
		}
		forvalues s=1/`=`nbscore'+1'{
			capture rename s`s'g`g' v`count'
			if _rc ==0{
				local count=`count'+1
			}
		}
		local Ncol_`g'__=`count'-1
		forvalues i=1/`=`count'-1'{
			replace v`i'=P if round(v`i',0.000001)!=round(0,0.000001)
		}
		local countW_`g'=`count'-1
		save `bloc`g''_1b, replace
		merge `sort' using `bloc`g''_2b
		drop _merge
		forvalues i=1/`mat_`g''{
			forvalues j=1/`mat_`g''{
				gen prod=v`i'*v`j'b
				qui su prod
				matrix W_`g'[`i',`j']=r(sum)
				drop prod
			}
		}
		capture matrix W_`g'i=invsym(W_`g')
		if _rc!=0{
			capture matrix W_`g'i=inv(W_`g')
		}
		if _rc!=0{
			noi di in red "Error while computing the Wg matrix"
		}
		mata: A=J(1,1,.)
		mata: A[1,1]=rank(st_matrix("W_`g'"))
		mata: st_matrix("rank_",A)
		local rank`g'=rank_[1,1]
	}
/* Matrice poid */
	forvalues g=1/`nbgroup'{
		use `bddini'_se_g, replace
		keep if g==`g'
		gen Pd=1
		contract `sort', f(nb)
		sort `sort'
		save `bddini'_se_`g'obs, replace
		use `bloc`g''_2b, replace
		sort `sort'
		merge `sort' using `bddini'_se_`g'obs
		drop _merge
		replace nb=0 if nb==.
		gen nbth=P*`N'
		gen Di=(nb-nbth)/sqrt(`N')
		sort `sort'
		save `bloc`g''_2bgi, replace
		if `countW_`g''>10{
			set matsize `countW_`g''
		}
		else{
			set matsize 10
		}
		matrix deviation_`g'=J(`countW_`g'',1,.)
		use `bloc`g''_2bgi, replace
		gen Pobs=nb/`N'
		gen Diff=Pobs-P
		forvalues j=1/`countW_`g''{
			replace v`j'b=v`j'b*Diff
			su v`j'b
			matrix deviation_`g'[`j', 1]=r(sum)*sqrt(`N')
		}
	}
	local sum=0
	local ddl=0
	local rank ""
	qui q memory
	if `matsizeini'>r(matsize) & 10000 > r(m_matsize){
		set matsize `matsizeini'
	}
	else{
		set matsize 10000
	}
	matrix graphContribPond=J(`nbgroup',2,.)
	forvalues g=1/`nbgroup'{
		capture matrix G_`g'=deviation_`g''*W_`g'i*deviation_`g'
		if _rc!=0{
			noi di in red "Error, not enought memory to allocate to the W matrix computation
		}
		local sum=`sum'+G_`g'[1,1]
		local ddl=`ddl'+`rank`g''
		local rank "`rank'`rank`g''  "
		matrix graphContribPond[`g',1]=`g'
		matrix graphContribPond[`g',2]=G_`g'[1,1]
	}
	local ddl=`ddl'-`ordre'-1
	set matsize `matsizeini'
}
local R1m_group "`list'"
local R1m_Rank `rank'
local R1M_ddl=`ddl'
local R1M_stat=`sum'*`propFit'
local R1M_p=`=1-chi2(`ddl', `R1M_stat')'

/*************************************/
/*			  tests Si			 */
/*************************************/
if `nbitsuf'==1 & "`sitest'"!=""{
	qui{
		local countbase=0
		forvalues ii=1/`nbit'{
			forvalues j=1/`nbmoda_`ii''{
				local countbase=`countbase'+1
			}
		}
		forvalues s=1/`nbscore'{
			local countbase=`countbase'+1
		}
		matrix DGibase=J(6,`countbase',.)
		use `bddini'_se_g, replace
		local countbase=0
		forvalues ii=1/`nbit'{
			tab it`ii', gen(i`ii'c)
			forvalues j=1/`nbmoda_`ii''{
				local countbase=`countbase'+1
				matrix DGibase[2,`countbase']=`ii'
				matrix DGibase[3,`countbase']=`j'
				su i`ii'c`j'
				matrix DGibase[4,`countbase']=r(sum)
			}
			drop i`ii'c*
		}
		tab score, gen(s)
		forvalues s=1/`nbscore'{
			capture su s`s'
			if _rc!=0{
				gen s`s'=0
			}
		}
		forvalues s=1/`nbscore'{
			local countbase=`countbase'+1
			matrix DGibase[2,`countbase']=`s'
			su s`s'
			matrix DGibase[4,`countbase']=r(sum)
		}
		use `matU'_2, replace
		local countbase=0
		forvalues ii=1/`nbit'{
			forvalues j=1/`nbmoda_`ii''{
				local countbase=`countbase'+1
				su P if i`ii'c`j'==1
				matrix DGibase[5,`countbase']=r(sum)*`N'
				matrix DGibase[6,`countbase']=(DGibase[4,`countbase']-DGibase[5,`countbase'])/sqrt(`N')
			}
		}
		forvalues s=1/`nbscore'{
			local countbase=`countbase'+1
				su P if score`s'==1
				matrix DGibase[5,`countbase']=r(sum)*`N'
				matrix DGibase[6,`countbase']=(DGibase[4,`countbase']-DGibase[5,`countbase'])/sqrt(`N')
		}
		local colbase=`countbase'
	}
	forvalues i=1/`nbit'{
		noi di in gr "Performing Si test for the `i'th item"
		qui{
			use `matU'_2, replace
			gen g=.
			local liminf1=-1
			forvalues g=1/`nbgroup'{
				replace g=`g' if score<=`limsup`g'' & score>`liminf`g''
			}
			forvalues g=1/`nbgroup'{
				forvalues j=1/`nbmoda_`i''{
					gen testi`i'c`j'g`g'=0
					replace testi`i'c`j'g`g'=i`i'c`j' if g==`g'
				}
			}
			local count=1
			forvalues ii=1/`nbit'{
				forvalues j=1/`nbmoda_`ii''{
					rename i`ii'c`j' v`count'b
					local count=`count'+1
				}
			}
			forvalues s=1/`=`nbscore'+1'{
				capture rename score`s' v`count'b
				if _rc ==0{
					local count=`count'+1
				}
			}
			forvalues g=1/`nbgroup'{
				forvalues j=1/`nbmoda_`i''{
					rename testi`i'c`j'g`g' v`count'b
					local count=`count'+1
				}
			}
			local nbarrive`i'=`count'-1
			sort `sort'
			save `matU'_2i`i', replace
			use `matU'_1, replace
			gen g=.
			local liminf1=-1
			forvalues g=1/`nbgroup'{
				replace g=`g' if score<=`limsup`g'' & score>`liminf`g''
			}
			forvalues g=1/`nbgroup'{
				forvalues j=1/`nbmoda_`i''{
					gen testi`i'c`j'g`g'=0
					replace testi`i'c`j'g`g'=i`i'c`j' if g==`g'
				}
			}
			local count=1
			forvalues ii=1/`nbit'{
				forvalues j=1/`nbmoda_`ii''{
					rename i`ii'c`j' v`count'
					local count=`count'+1
				}
			}
			forvalues s=1/`=`nbscore'+1'{
				capture rename score`s' v`count'
				if _rc ==0{
					local count=`count'+1
				}
			}
			forvalues g=1/`nbgroup'{
				forvalues j=1/`nbmoda_`i''{
					rename testi`i'c`j'g`g' v`count'
					local count=`count'+1
				}
			}
			sort `sort'
			save `matU'_1i`i', replace
			merge `sort' using `matU'_2i`i'
			drop _merge
			if `nbarrive`i''>r(matsize) & `nbarrive`i''<=r(m_matsize){
				set matsize `nbarrive`i''
			}
			if `nbarrive`i''>r(m_matsize){
				noi di in red "Error, not enought memory to allocate to the W matrix computation"
			}
			matrix i`i'W=J(`nbarrive`i'',`nbarrive`i'',0)
			if `=`nbarrive`i''*`nbarrive`i'''>3000{
				noi di in gr "----|---25%---|---50%---|---75%---|---100%
				qui _dots 0, title(Loop computation of theorical probabilities of each response pattern) reps(40)
				local percentcount=0
				local countS=1
			}
			forvalues ii=1/`nbarrive`i''{
				su v`ii'
				if r(max)>=0.000001{
				forvalues j=1/`nbarrive`i''{
					gen prod=v`ii'*v`j'b
					qui su prod
					matrix i`i'W[`ii',`j']=r(sum)
					drop prod
					if `=`nbarrive`i''*`nbarrive`i'''>3000{
						local percentcountplus=floor(`countS'*40/`=`nbarrive`i''*`nbarrive`i''')
						forvalues percen=`=`percentcount'+1'/`percentcountplus'{
							nois _dots `percen' 0
						}
						local percentcount=`percentcountplus'
						local countS=`countS'+1
					}
				}
				}
				else{
					if `=`nbarrive`i''*`nbarrive`i'''>3000{
						local percentcountplus=floor((`countS'+`nbarrive`i''-1)*40/`=`nbarrive`i''*`nbarrive`i''')
						forvalues percen=`=`percentcount'+1'/`percentcountplus'{
							nois _dots `percen' 0
						}
						local percentcount=`percentcountplus'
						local countS=`countS'+`nbarrive`i''
					}
				}
			}
			if `=`nbarrive`i''*`nbarrive`i'''>3000{
				noi di ""
			}
			capture matrix i`i'Wi=invsym(i`i'W)
			if _rc!=0{
				capture matrix i`i'Wi=inv(i`i'W)
			}
			if _rc!=0{
				noi di in red "Error while computing the Wg matrix"
			}
			mata: A=J(1,1,.)
			mata: A[1,1]=rank(st_matrix("i`i'W"))
			mata: st_matrix("rank_",A)
			local i`i'rank=rank_[1,1]
			matrix plus`i'=J(6,`=`nbarrive`i''-`colbase'',.)
			matrix DGi_`i'=DGibase,plus`i'
			matrix DGi`i'_a=J(1,`=colsof(DGibase)',0)
			matrix DGi`i'_b=J(1,`=`nbarrive`i''-`colbase'',.)
			matrix DGi_`i'_v2=DGi`i'_a,DGi`i'_b
			save `matU'_i`i', replace
			local count=`colbase'
			use `bddini'_se_g, replace
			tab it`i', gen(i`i'c)
			forvalues g=1/`nbgroup'{
				forvalues j=1/`nbmoda_`i''{
					local count=`count'+1
					matrix DGi_`i'[2,`count']=`i'
					matrix DGi_`i'[3,`count']=`j'
					matrix DGi_`i'[1,`count']=`g'
					su i`i'c`j' if g==`g'
					matrix DGi_`i'[4,`count']=r(sum)
				}
			}
			use `matU'_i`i', replace
			forvalues t=`=`colbase'+1'/`nbarrive`i''{
				su P if v`t'b==1
				matrix DGi_`i'[5,`t']=r(sum)*`N'
				matrix DGi_`i'[6,`t']=(DGi_`i'[4,`t']-DGi_`i'[5,`t'])/sqrt(`N')
				matrix DGi_`i'_v2[1,`t']=(DGi_`i'[4,`t']-DGi_`i'[5,`t'])/sqrt(`N')
			}
			set matsize `matsizeini'
			matrix tDGi_`i'=DGi_`i'[6,1..`=colsof(DGi_`i')']'
			matrix tDGi_`i'_v2=DGi_`i'_v2'
			matrix G=tDGi_`i''*i`i'Wi*tDGi_`i'
			matrix G_v2=tDGi_`i'_v2'*i`i'Wi*tDGi_`i'_v2
			local sum=G[1,1]
			local sum_v2=G_v2[1,1]
			local rank "`i`i'rank'"
			local ddl=(`nbgroup'-1)*(`nbmoda_`i''-1)
		}
		local S`i'_rank=`rank'
		local S`i'_ddl=`ddl'
		local S`i'_stat=`sum'*`propFit'
		local S`i'_p=`=1-chi2(`S`i'_ddl', `S`i'_stat')'
	}
}

/* Graphs : */

if "`graphics'"!=""{
	noi di ""
	noi di ""
	noi di in gr "Graphics:"
	tempfile graph	
	qui{
		local debut=1
		local fin=1
		forvalues i=1/`nbit'{
			local fin=`fin'+`nbmoda_`i''-2
			matrix it`i'=Edelta[1,`debut'..`fin']
			local fin=`fin'+1
			local debut=`debut'+`nbmoda_`i''-1
		}
		clear
		use `bddini'_se, replace
		local scmin=1
		local scmax=-1
		forvalues i=1/`nbit'{
			local scmax=`scmax'+`nbmoda_`i''-1
		}		
		gen select=score<=`scmin'
		su score if select==1
		local scorereel_scmin=r(mean)
		replace select=score>=`scmax'
		su score if select==1
		local scorereel_scmax=r(mean)
		replace score=`scmin' if score<`scmin'
		replace score=`scmax' if score>`scmax'
		tab score, matcell(matname)  
		local tottab=r(N)
		clear
		set obs 2000
		gen theta=_n/100-10
		gen scoreth=0
		forvalues i=1/`nbit'{
			matrix D`i'=J(1,`nbmoda_`i'',0)
			gen eV`i'_0=1
			gen SeV`i'=1
			forvalues j=1/`=`nbmoda_`i''-1'{
				matrix D`i'[1,`=`j'+1']=it`i'[1,`j']+D`i'[1,`j']
				gen eV`i'_`j'=exp(`j'*theta-D`i'[1,`=`j'+1'])
				replace SeV`i'=SeV`i'+eV`i'_`j'
			}
			gen p`i'_0=eV`i'_0/SeV`i'
			forvalues j=1/`=`nbmoda_`i''-1'{
				gen p`i'_`j'=eV`i'_`j'/SeV`i'
				replace scoreth=scoreth+(eV`i'_`j'/SeV`i')*`j'
			}
		}
		drop e* S* p*
		su scoreth
		local scmin=ceil(r(min))
		local scmax=floor(r(max))
		gen sc=abs(scoreth-`scorereel_scmin')
		sort sc
		local valini_`scmin'=theta[1]
		drop sc
		gen sc=abs(scoreth-`scorereel_scmax')
		sort sc
		local valini_`scmax'=theta[1]
		drop sc
		matrix scoretheta=J(2,`scmax',.)
		forvalues i=`=`scmin'+1'/`=`scmax'-1'{
			matrix scoretheta[1,`i']=`i'
			gen sc=abs(scoreth-`i')
			sort sc
			local valini_`i'=theta[1]
			drop sc
		}
		matrix scoretheta[1,1]=`scorereel_scmin'
		matrix scoretheta[1,`scmax']=`scorereel_scmax'
		forvalues i=1/`scmax'{
			matrix scoretheta[2,`i']=`valini_`i''
		}
		tempfile graphscthscobstheta
		save `graphscthscobstheta', replace
		clear
		use `bddini'_se, replace
		gen select=score<=`scmin'
		su score if select==1
		local scorereel_scmin=r(mean)
		replace select=score>=`scmax'
		su score if select==1
		local scorereel_scmax=r(mean)
		replace score=`scmin' if score<`scmin'
		replace score=`scmax' if score>`scmax'
		drop g
		forvalues i=1/`nbit'{
			gen rep`i' = it`i'
			drop it`i'
		}
		contract rep1-rep`nbit' score, f(wt2)
		gen id=_n
		reshape long rep, i(id) j(it)
		drop if rep==.
		gen obs=_n
		forvalues i=1/`nbit'{
			expand `nbmoda_`i'' if it==`i'
		}
		by obs, sort: gen x=_n-1
		gen choix=rep==x
		rename it item
		tab item, gen(it)
		forvalues i=1/`nbit'{

			forvalues g=1/`=`nbmoda_`i''-1'{
				gen d_i`i'_m`g'=(-1)*it`i'*(x>=`g')
			}
		}
		gen difficulties=0
		forvalues i=1/`nbit'{

			forvalues g=1/`=`nbmoda_`i''-1'{

				replace difficulties=difficulties+it`i'[1,`g']*d_i`i'_m`g'
			}
		}
		tab score, gen(score__) matrow(nom)
		local nbmodscore=r(r)
		forvalues k=1/`nbmodscore'{
			replace score__`k'=x if score__`k'==1
			local ident=nom[`k',1]
			if `k'==1{
				local ident1=`ident'
			}
			rename score__`k' score_`ident'
		}
		eq slope: x
		noi di in gr "Performing graphics"
		use `graphscthscobstheta', replace
		gen sc=abs(scoreth-`scorereel_scmin')
		sort sc
		local limginf=theta[1]-1.5
		drop sc
		gen sc=abs(scoreth-`scorereel_scmax')
		sort sc
		local limgsup=theta[1]+1.5
		drop sc
		drop if theta<`limginf' | theta>`limgsup'
		capture graph drop Obs_vs_Exp_LT 
		capture graph drop MAP 
		capture graph drop Score_Distrib 
		capture graph drop Contrib
		twoway (line theta scoreth, sort) , ytitle(Latent trait) xtitle(Score) title("latent trait values depending on the individual scores", size(medium))  scheme(s2mono) graphregion(fcolor(white) ifcolor(white))  name("LT_Sc", replace)
		graph save `graph'_ScoreEO.gph, replace
		if "`filegraph'"!=""{
			graph save "`filegraph'_LT_Sc", replace
		}
		clear
		set obs `=int(`=rowsof(matname)+colsof(Edelta)'+0.1)'
		gen theta=.
		gen diff=0
		gen freq=.
		forvalues i=1/`=rowsof(matname)'{
			replace theta=scoretheta[2,`i'] if _n==`i'
			replace freq=matname[`i',1]/`tottab' if _n==`i'
		}	
		su freq
		local tadatzouinzou=-r(max)/8
		forvalues i=1/`=colsof(Edelta)'{
			replace theta=Edelta[1,`i'] if _n==`i'+`=rowsof(matname)'
			replace freq=`tadatzouinzou' if _n==`i'+`=rowsof(matname)'
			replace diff=1 if _n==`i'+`=rowsof(matname)'
		}
		sort diff theta
		bysort diff: replace freq=freq-(`tadatzouinzou'/5) if theta<theta[_n-1]+0.08 & diff==1 & _n!=1
		replace theta=round(theta,0.01)
		compress
		sort theta
		save `graph', replace
		su theta
		local mininf=round(`=r(min)-(r(max)-r(min))/4',0.01)
		local maxinf=round(`=r(max)+(r(max)-r(min))/4',0.01)
		clear
		set obs `=int(`=(`maxinf'-`mininf')*100'+0.1)'
		gen theta=round(_n/100+`mininf',0.01)
		compress
		sort theta
		merge theta using `graph'
		drop _merge
		forvalues i=1/`nbit'{
			matrix D`i'=J(1,`nbmoda_`i'',0)
			gen eV`i'_0=1
			gen SeV`i'=1
			forvalues j=1/`=`nbmoda_`i''-1'{
				matrix D`i'[1,`=`j'+1']=it`i'[1,`j']+D`i'[1,`j']
				gen eV`i'_`j'=exp(`j'*theta-D`i'[1,`=`j'+1'])
				replace SeV`i'=SeV`i'+eV`i'_`j'
			}
			gen p`i'_0=eV`i'_0/SeV`i'
			forvalues j=1/`=`nbmoda_`i''-1'{
				gen p`i'_`j'=eV`i'_`j'/SeV`i' + p`i'_`=`j'-1'
			}
			drop eV* SeV*
		}
		gen L=1
		forvalues i=1/`nbit'{
			forvalues j=0/`=`nbmoda_`i''-1'{
				replace L=L*p`i'_`j'
			}
		}
		sort theta
		replace L=ln(L)
		gen d1=.
		replace d1=(L-L[_n-1])/(theta-theta[_n-1]) if _n>1
		gen d2=.
		replace d2=(d1-d1[_n-1])/(theta-theta[_n-1]) if _n>1
		replace d2=-d2
		su freq
		local freqmin=r(min)
		local freqmax=r(max)
		su d2
		local d2max=r(max)
		local d2min=`d2max'*`freqmax'/`freqmin'
		label variable freq "Freq. (%)"
		label variable d2 "Information"
		sort theta
		twoway (spike freq theta if diff==0, lwidth(thick) horizontal xscale(alt  axis(1)) ) (scatter theta freq if diff==1,mcolor(black) msymbol(plus)) (line theta d2, xaxis(2) xscale(alt axis(2))) , yscale(noline) ylabel(#5, angle(horizontal)) xscale(range(`freqmin' `freqmax') axis(1)) xscale(reverse range(`d2min' `d2max') axis(2))  yscale(range(`mininf' `maxinf'))  xline(0) xlabel(0 (0.05) `freqmax') title(, size(medium)) legend(order(1 "Persons" 2 "Thresholds location" 3 "Information curve") cols(1) size(small)) scheme(s2mono) graphregion(fcolor(white) ifcolor(white)) ytitle(Latent trait) title(MAP) name("MAP", replace)		
		graph save `graph'_MAP.gph, replace	
		if "`filegraph'"!=""{
			graph save "`filegraph'_MAP", replace
		}
		clear
		use "`dataR1m'"
		keep score P
		collapse (sum) P, by(score)
		sort score
		save `bddini'_Graph1, replace
		clear
		use "`datatest'"
		keep `varlist'
		tempname dm SumScore
		egen `dm'=rowmiss(`varlist')
		replace `dm'=`dm'>0
		keep if `dm'==0
		tempname SumScore
		egen `SumScore'=rowtotal(`varlist')
		gen Pobs=1
		rename `SumScore' score
		keep Pobs score
		local tot=_N
		collapse (sum) Pobs, by(score)
		replace Pobs=Pobs/`tot'
		sort score
		merge 1:1 score using `bddini'_Graph1
		gen g=.
		drop _merge
		sort g 
		save `bddini'_Graph1, replace
		clear
		svmat graphContribPond
		rename graphContribPond1 g
		rename graphContribPond2 Contrib
		sort g
		merge g using `bddini'_Graph1
		su Contrib
		replace Contrib=Contrib/r(sum)
		capture label drop g
		local liminf1=-1
		forvalues i=1/`nbgroup'{
			local limsup`i'=real("`=word("`list'",`i')'")
			if `i'>1{
				local liminf`i'=real("`=word("`list'",`=`i'-1')'")
			}
			replace g=`i' if score<=`limsup`i'' & score>`liminf`i''
			if `i'==1{
				label define g `i' "[0;`limsup`i'']"
			}
			else if `i' == `nbgroup'{
				label define g `i' "]`liminf`i'';`=`nbscore'-1']", a
			}
			else{
				label define g `i' "]`liminf`i'';`limsup`i'']", a
			}
		} 
		label values g g
		gen nb=P*`EN'
		 su score [iweight=nb]
		local MoyThScore=r(mean)
		local SdThScore=r(sd)
		gen nbObs=Pobs*`EN'
		 su score [iweight=nbObs]
		local MoyObsScore=r(mean)
		local SdObdcore=r(sd)
		drop _merge
		tempfile BDD
		sort score
		save `BDD', replace
		save BDD, replace
		clear
		set obs `=(`=r(max)'+2)*100'
		gen score=(_n/100)-1
		gen p=normalden(score,`MoyThScore',`SdThScore')
		gen pobs=normalden(score,`MoyObsScore',`SdObdcore')
		sort score
		save `BDD'2, replace
		merge score using `BDD'
		gen score1=score if Pobs!=.
		gen scorep=score1-0.15
		gen scorep2=score1+0.15
		twoway (bar  Pobs scorep, horizontal  barwidth(0.3)) (bar  P scorep2, horizontal barwidth(0.3)) (line score p, lpattern(solid)lcolor(black)) (line 			score pobs, lpattern(vshortdash) lcolor(gs12)), yscale(reverse) scheme(s2mono) xtitle(%) xscale(range(0 0.01)) xlabel(#5) legend(order(1 "% observed" 3 "" 2 "% expected" 4 "") cols(2) size(small)) title("Observed and expected" "scores distribution", size(medium)) graphregion(fcolor(white)) name("Score_Distrib", replace)
		graph save `graph'_totscore.gph, replace
		if "`filegraph'"!=""{
			graph save "`filegraph'_totscore", replace
		}
		graph hbar (sum) Pobs P Contrib, over(g)  yvaroptions(relabel(1 "% observed" 2 "% expected" 3 "% R1m contribution") label(labcolor(none) labsize(zero)))  title("Groups contribution to" "the R1m statistic", size(medium)) legend(cols(1) size(small)) ytitle("%") scheme(s2mono) graphregion(fcolor(white)) bar(3, fcolor(black)) bar(1, fcolor(gs8)) bar(2, fcolor(gs13)) name("Contrib", replace)
		graph save `graph'_scoregp.gph, replace
		if "`filegraph'"!=""{
			graph save "`filegraph'_scoregp", replace
		}
	}
}
matrix globalFit=(`R1M_stat',`R1M_ddl',`R1M_p')
if `nbitsuf'==1 & "`sitest'"!=""{
	matrix itemFit=J(`nbit',3,.)
	forvalues i=1/`nbit'{
		matrix itemFit[`i',1]=`S`i'_stat'
		matrix itemFit[`i',2]=`S`i'_ddl'
		matrix itemFit[`i',3]=`S`i'_p'
	}
}
if "`alpha'"==""{
	local alpha=0.05
}
tempname  g it r Power bB cC Discriminant
matrix `g'=globalFit
if `nbitsuf'==1 & "`sitest'"!=""{
	matrix `it'=itemFit
}
if "`nfit'"==""{
	local `r'=1
}
else{
	local `r'=`NbIdFit'/`nfit'
}

local `g'_t=`g'[1,1]*``r''
if `g'[1,2]<=200{
	local `Power'_t_R1m= 1-nchi2(`g'[1,2],``g'_t',invchi2tail(`g'[1,2],`alpha'))
}
else{
	local `Power'_t_R1m=1-(normal((invchi2tail(`g'[1,2],`alpha')-(`g'[1,2]+``g'_t'))/sqrt(2*(`g'[1,2]+2*``g'_t'))))
}
if `nbitsuf'==1 & "`sitest'"!=""{
	forvalues i=1/`nbit'{
		local `it'_`i'_t=`it'[`i',1]*``r''
		if `it'[`i',2]>200 | ``it'_`i'_t'>1000{
			local `Power'_t_S`i'=1-(normal((invchi2tail(`it'[`i',2],`alpha')-(`it'[`i',2]+``it'_`i'_t'))/sqrt(2*(`it'[`i',2]+2*``it'_`i'_t'))))
		}
		else{
			local `Power'_t_S`i'= 1-nchi2(`it'[`i',2],``it'_`i'_t',invchi2tail(`it'[`i',2],`alpha'))
		}
	}
}
if "`nfit'"!=""{
	local `r'_2=``r''*`nfit'/`NbIdFit'
	local `g'_newN=`g'[1,1]*``r'_2'
	if `g'[1,2]<=200{
		local `Power'_newN_R1m= 1-nchi2(`g'[1,2],``g'_newN',invchi2tail(`g'[1,2],`alpha'))
	}
	else{
		local `Power'_newN_R1m=1-(normal((invchi2tail(`g'[1,2],`alpha')-(`g'[1,2]+``g'_newN'))/sqrt(2*(`g'[1,2]+2*``g'_newN'))))
	}
	if `nbitsuf'==1 & "`sitest'"!=""{
		forvalues i=1/`nbit'{
			local `it'_`i'_newN=`it'[`i',1]*``r'_2'
			if `it'[`i',2]>200 | ``it'_`i'_newN'>1000{
				local `Power'_newN_S`i'=1-(normal((invchi2tail(`it'[`i',2],`alpha')-(`it'[`i',2]+``it'_`i'_newN'))/sqrt(2*(`it'[`i',2]+2*``it'_`i'_newN'))))
			}
			else{
				local `Power'_newN_S`i'= 1-nchi2(`it'[`i',2],``it'_`i'_newN',invchi2tail(`it'[`i',2],`alpha'))
			}
		}
	}
}
if "`power'"!=""{
	if `g'[1,2]<=200{
		local `g'_newP=npnchi2(`=`g'[1,2]',`=invchi2tail(`=`g'[1,2]',`alpha')',`=1-`power'')
	}
	else{
		local `bB'=2*`=`g'[1,2]'-2*`=invchi2tail(`=`g'[1,2]',`alpha')'-4*(invnormal(`=1-0.8'))^2
		local `cC'=(`=invchi2tail(`=`g'[1,2]',`alpha')')^2-2*`=`g'[1,2]'*`=invchi2tail(`=`g'[1,2]',`alpha')'+(`=`g'[1,2]')^2-2*`=`g'[1,2]'*(invnormal(`=1-0.8'))^2
		local `Discriminant'=(``bB'')^2-4*``cC''
		local `g'_newP=(sqrt(``Discriminant'')-``bB'')/2
	}
	local `r'_3=``g'_newP'/``g'_t'
	if `nbitsuf'==1 & "`sitest'"!=""{
		forvalues i=1/`nbit'{
			local `it'_`i'_newP=``it'_`i'_t'*``r'_3'
			if `it'[`i',2]>200 | ``it'_`i'_newP'>1000{
				local `Power'_newP_S`i'=1-(normal((invchi2tail(`it'[`i',2],`alpha')-(`it'[`i',2]+``it'_`i'_newP'))/sqrt(2*(`it'[`i',2]+2*``it'_`i'_newP'))))
			}
			else{
				local `Power'_newP_S`i'= 1-nchi2(`it'[`i',2],``it'_`i'_newP',invchi2tail(`it'[`i',2],`alpha'))
			}
		}
	}
}
}

  /*************************************/
 /*               print               */
/*************************************/

di ""
di ""
di in gr "Global tests of the fit : test R1m"
di in gr "			  groups : " in ye "`R1m_group'"
di in gr "			  Number of individuals with missing data : " in ye "`nbmissing' "  in gr "(" in ye "`=round(`=`percentmissing'*100',0.01)'%" in gr ")"
di ""
if "`nfit'"!="" & "`power'"!=""{
	di in gr "{hline 90}"
	di  _col(30) in gr "N = " in ye %6.0f `NbIdFit' _col(53) in gr "N = " in ye %6.0f `nfit'  _col(76) in gr  "N = " in ye %6.0f `=ceil(`NbIdFit'*``r'_3')'
	di _col(16) in gr "df" _col(26) in gr "R1m" _col(32) in gr "p-val" _col(39) in gr "Power" _col(49) in gr "R1m" _col(55) in gr "p-val" _col(62) in gr "Power" _col(72) in gr "R1m" _col(78) in gr "p-val" _col(85) in gr "Power"
	di in gr "{hline 90}"
	di _col(3) in gr "R1m" _col(14) in ye %4.0f `R1M_ddl' _col(23) in ye %6.1f ``g'_t' _col(32) in ye %5.4f `=1-chi2(`=`g'[1,2]', ``g'_t')'  _col(39) in ye %5.4f ``Power'_t_R1m'   _col(46) in ye %6.1f ``g'_newN' _col(55) in ye %5.4f `=1-chi2(`=`g'[1,2]', ``g'_newN')'  _col(62) in ye %5.4f ``Power'_newN_R1m'         _col(69) in ye %6.1f ``g'_newP' _col(78) in ye %5.4f `=1-chi2(`=`g'[1,2]', ``g'_newP')'  _col(85) in ye %5.4f `power'
	di in gr "{hline 90}"
	di in gr ""
	if `nbitsuf'==1 & "`sitest'"!=""{
		di in gr "Items specific tests of the fit : tests Si"
		di in gr ""
		di in gr "{hline 90}"
		di  _col(30) in gr "N = " in ye %6.0f `NbIdFit' _col(53) in gr "N = " in ye %6.0f `nfit'  _col(76) in gr  "N = " in ye %6.0f `=ceil(`NbIdFit'*``r'_3')'
		di _col(1) in gr "Item" _col(16) in gr "df" _col(27) in gr "Si" _col(32) in gr "p-val" _col(39) in gr "Power" _col(50) in gr "Si" _col(55) in gr "p-val" _col(62) in gr "Power" _col(73) in gr "Si" _col(78) in gr "p-val" _col(85) in gr "Power"
		di in gr "{hline 90}"
		forvalues i=1/`nbit'{
			di _col(1) in gr "``i'' :" _col(14) in ye %4.0f `S`i'_ddl' _col(23) in ye %6.1f ``it'_`i'_t' _col(32) in ye %5.4f `=1-chi2(`=`it'[`i',2]', ``it'_`i'_t')'  _col(39) in ye %5.4f ``Power'_t_S`i''   _col(46) in ye %6.1f ``it'_`i'_newN' _col(55) in ye %5.4f `=1-chi2(`=`it'[`i',2]', ``it'_`i'_newN')'  _col(62) in ye %5.4f ``Power'_newN_S`i''         _col(69) in ye %6.1f ``it'_`i'_newP' _col(78) in ye %5.4f `=1-chi2(`=`it'[`i',2]', ``it'_`i'_newP')'  _col(85) in ye %5.4f ``Power'_newP_S`i''
			di in gr "{hline 90}"
		}
	}
}
else if "`nfit'"!=""{
	di in gr "{hline 67}"
	di  _col(30) in gr "N = " in ye %6.0f `NbIdFit' _col(53) in gr "N = " in ye %6.0f `nfit'  
	di _col(16) in gr "df" _col(26) in gr "R1m" _col(32) in gr "p-val" _col(39) in gr "Power" _col(49) in gr "R1m" _col(55) in gr "p-val" _col(62) in gr "Power" 
	di in gr "{hline 67}"
	di _col(3) in gr "R1m" _col(14) in ye %4.0f `R1M_ddl' _col(23) in ye %6.1f ``g'_t' _col(32) in ye %5.4f `=1-chi2(`=`g'[1,2]', ``g'_t')'  _col(39) in ye %5.4f ``Power'_t_R1m'   _col(46) in ye %6.1f ``g'_newN' _col(55) in ye %5.4f `=1-chi2(`=`g'[1,2]', ``g'_newN')'  _col(62) in ye %5.4f ``Power'_newN_R1m'
	di in gr "{hline 67}"
	di in gr ""
	if `nbitsuf'==1 & "`sitest'"!=""{
		di in gr "Items specific tests of the fit : tests Si"
		di in gr ""
		di in gr "{hline 67}"
		di  _col(30) in gr "N = " in ye %6.0f `NbIdFit' _col(53) in gr "N = " in ye %6.0f `nfit'  
		di _col(1) in gr "Item" _col(17) in gr "df" _col(26) in gr "Si" _col(32) in gr "p-val" _col(39) in gr "Power" _col(50) in gr "Si" _col(55) in gr "p-val" _col(62) in gr "Power" 
		di in gr "{hline 67}"
		forvalues i=1/`nbit'{
			di _col(1) in gr "``i'' :" _col(14) in ye %4.0f `S`i'_ddl' _col(23) in ye %6.1f ``it'_`i'_t' _col(32) in ye %5.4f `=1-chi2(`=`it'[`i',2]', ``it'_`i'_t')'  _col(39) in ye %5.4f ``Power'_t_S`i''   _col(46) in ye %6.1f ``it'_`i'_newN' _col(55) in ye %5.4f `=1-chi2(`=`it'[`i',2]', ``it'_`i'_newN')'  _col(62) in ye %5.4f ``Power'_newN_S`i'' 
			di in gr "{hline 90}"
		}
	}
}
else if "`power'"!=""{
	di in gr "{hline 67}"
	di  _col(30) in gr "N = " in ye %6.0f `NbIdFit'   _col(53) in gr  "N = " in ye %6.0f `=ceil(`NbIdFit'*``r'_3')'
	di _col(16) in gr "df" _col(26) in gr "R1m" _col(32) in gr "p-val" _col(39) in gr "Power" _col(49) in gr "R1m" _col(55) in gr "p-val" _col(62) in gr "Power" 
	di in gr "{hline 67}"
	di _col(3) in gr "R1m" _col(14) in ye %4.0f `R1M_ddl' _col(23) in ye %6.1f ``g'_t' _col(32) in ye %5.4f `=1-chi2(`=`g'[1,2]', ``g'_t')'  _col(39) in ye %5.4f ``Power'_t_R1m'   _col(46) in ye %6.1f ``g'_newP' _col(55) in ye %5.4f `=1-chi2(`=`g'[1,2]', ``g'_newP')'  _col(62) in ye %5.4f `power'
	di in gr "{hline 67}"
	di in gr ""
	if `nbitsuf'==1 & "`sitest'"!=""{
		di in gr "Items specific tests of the fit : tests Si"
		di in gr ""
		di in gr "{hline 67}"
		di  _col(30) in gr "N = " in ye %6.0f `NbIdFit' _col(53)  in gr  "N = " in ye %6.0f `=ceil(`NbIdFit'*``r'_3')'
		di _col(1) in gr "Item" _col(16) in gr "df" _col(27) in gr "Si" _col(32) in gr "p-val" _col(39) in gr "Power" _col(50) in gr "Si" _col(55) in gr "p-val" _col(62) in gr "Power"
		di in gr "{hline 67}"
		forvalues i=1/`nbit'{
			di _col(1) in gr "``i'' :" _col(14) in ye %4.0f `S`i'_ddl' _col(23) in ye %6.1f ``it'_`i'_t' _col(32) in ye %5.4f `=1-chi2(`=`it'[`i',2]', ``it'_`i'_t')'  _col(39) in ye %5.4f ``Power'_t_S`i''   _col(46) in ye %6.1f ``it'_`i'_newP' _col(55) in ye %5.4f `=1-chi2(`=`it'[`i',2]', ``it'_`i'_newP')'  _col(62) in ye %5.4f ``Power'_newP_S`i''
			di in gr "{hline 67}"
		}
	}
}
else{
	di in gr "{hline 44}"
	di  _col(30) in gr "N = " in ye %6.0f `NbIdFit' 
	di _col(16) in gr "df" _col(26) in gr "R1m" _col(32) in gr "p-val" _col(39) in gr "Power" 
	di in gr "{hline 44}"
	di _col(3) in gr "R1m" _col(14) in ye %4.0f `R1M_ddl' _col(23) in ye %6.1f ``g'_t' _col(32) in ye %5.4f `=1-chi2(`=`g'[1,2]', ``g'_t')'  _col(39) in ye %5.4f ``Power'_t_R1m'  
	di in gr "{hline 44}"
	di in gr ""
	if `nbitsuf'==1 & "`sitest'"!=""{
		di in gr "Items specific tests of the fit : tests Si"
		di in gr ""
		di in gr "{hline 44}"
		di  _col(30) in gr "N = " in ye %6.0f `NbIdFit' 
		di _col(1) in gr "Item" _col(16) in gr "df" _col(27) in gr "Si" _col(32) in gr "p-val" _col(39) in gr "Power" 
		di in gr "{hline 44}"
		forvalues i=1/`nbit'{
			di _col(1) in gr "``i'' :" _col(14) in ye %4.0f `S`i'_ddl' _col(23) in ye %6.1f ``it'_`i'_t' _col(32) in ye %5.4f `=1-chi2(`=`it'[`i',2]', ``it'_`i'_t')'  _col(39) in ye %5.4f ``Power'_t_S`i'' 
			di in gr "{hline 44}"
		}
	}
}

  /*************************************/
 /*	             ereturn              */
/*************************************/


ereturn clear
ereturn post Etheta EVartheta, depname(theta)
ereturn scalar mll=`Elll'
ereturn scalar cn=`Ecn'
ereturn scalar N=`EN'
ereturn scalar Nit=`ENit'
if `=`ENqual'+`ENquant''!=0{
	ereturn scalar Ncat=`ENqual'
	ereturn scalar Ncont=`ENquant'
}
ereturn scalar sigma=`Esigma'
ereturn scalar Varsigma=`EVarsigma'
ereturn scalar converged=`convergeance'
if "`nfit'"!=""{
	ereturn scalar NumFit=`nfit'
	matrix globalFitNu=(``g'_newN',`R1M_ddl',`=1-chi2(`=`g'[1,2]', ``g'_newN')',``Power'_newN_R1m',`nfit')
	if `nbitsuf'==1 & "`sitest'"!=""{
		matrix itemFitNu=J(`nbit',5,.)
			forvalues i=1/`nbit'{
			matrix itemFitNu[`i',1]=``it'_`i'_newN'
			matrix itemFitNu[`i',2]=`S`i'_ddl'
			matrix itemFitNu[`i',3]=`=1-chi2(`=`it'[`i',2]', ``it'_`i'_newN')'
			matrix itemFitNu[`i',4]=``Power'_newN_S`i''
			matrix itemFitNu[`i',5]=`nfit'
		}
	}
	matrix coln globalFitNu=R1m df alpha power N
	matrix rown globalFitNu=Global
	if `nbitsuf'==1 & "`sitest'"!=""{
		matrix coln itemFitNu=Si df alpha power N
		ereturn matrix itemFitNu=itemFitNu
	}
	ereturn matrix globalFitNu=globalFitNu
}
if "`power'"!=""{
	ereturn scalar PowFit=`power'
	matrix globalFitPo=(``g'_newP',`R1M_ddl',`=1-chi2(`=`g'[1,2]', ``g'_newP')',`power',`=ceil(`NbIdFit'*``r'_3')')
	if `nbitsuf'==1 & "`sitest'"!=""{
		matrix itemFitPo=J(`nbit',5,.)
			forvalues i=1/`nbit'{
			matrix itemFitPo[`i',1]=``it'_`i'_newP'
			matrix itemFitPo[`i',2]=`S`i'_ddl'
			matrix itemFitPo[`i',3]=`=1-chi2(`=`it'[`i',2]', ``it'_`i'_newP')'
			matrix itemFitPo[`i',4]=``Power'_newP_S`i''
			matrix itemFitPo[`i',5]=`=ceil(`NbIdFit'*``r'_3')'
		}
	}
	matrix coln globalFitPo=R1m df alpha power N
	matrix rown globalFitPo=Global
	if `nbitsuf'==1 & "`sitest'"!=""{
		matrix coln itemFitPo=Si df alpha power N
		ereturn matrix itemFitPo=itemFitPo
	}
	ereturn matrix globalFitPo=globalFitPo
}
matrix globalFitTot=(``g'_t',`R1M_ddl',`=1-chi2(`=`g'[1,2]', ``g'_t')',``Power'_t_R1m',`NbIdFit')
if `nbitsuf'==1 & "`sitest'"!=""{
	matrix itemFitTot=J(`nbit',5,.)
		forvalues i=1/`nbit'{
		matrix itemFitTot[`i',1]=``it'_`i'_t'
		matrix itemFitTot[`i',2]=`S`i'_ddl'
		matrix itemFitTot[`i',3]=`=1-chi2(`=`it'[`i',2]', ``it'_`i'_t')'
		matrix itemFitTot[`i',4]=``Power'_t_S`i''
		matrix itemFitTot[`i',5]=`NbIdFit'
	}
}
matrix coln globalFitTot=R1m df alpha power N
matrix rown globalFitTot=Global
if `nbitsuf'==1 & "`sitest'"!=""{
	matrix coln itemFitTot=Si df alpha power N
	ereturn matrix itemFitTot=itemFitTot
}
ereturn matrix globalFitTot=globalFitTot
ereturn local items `varlist'
ereturn local cmd "pcmodel"
ereturn local itest `itest'
ereturn local datatest `datatest'
ereturn local dataR1m `bddini'_R1m
ereturn local mugauss `mugauss'
ereturn local sdgauss `sdgauss'
ereturn local order `ordre'
ereturn matrix delta=Edelta
ereturn matrix Vardelta=EVardelta
use `bddtravail', replace
restore
end
