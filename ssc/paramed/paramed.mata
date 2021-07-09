*!TITLE: PARAMED - causal mediation analysis using parametric regression models	
*!AUTHORS: Hanhua Liu and Richard Emsley, Centre for Biostatistics, The University of Manchester
*!
*!	verson 1.5 HL/RAE 24 April 2013
*!		bug fix - stata's standard calculation of p and confidence interval based on e(b) and e(V)
*!				  (e.g. at 95%, [b-1.96*se, b+1.96*se]) does not work for non-linear cases
*!				  (e.g. loglinear at 95%, [exp(log(b)-1.96*se), exp(log(b)+1.96*se)]), so revert
*!				  back to manual calculation as already done in paramed.mata
*!		affected files - paramed.ado, paramedbs.ado; other files only updated with new version info
*!	
*!	version 1.4 HL/RAE 14 March 2013
*!		replay feature - after running paramed, issuing just paramed reprint/replay the results;
*!		affected files - paramed.ado, paramed.sthlp; other files only updated with new version info
*!
*!	version 1.3 HL/RAE 17 February 2013
*!		return values - instead of returning e(effects), now returns standard e(b) and e(V),
*!						and display the results in standard Stata format;
*!		affected files - paramed.ado, paramedbs.ado, paramed.sthlp
*!
*!	version 1.2 HL/RAE 11 February 2013
*!		syntax change - interaction is now default behaviour, 'nointer' is required syntax for no interaction;
*!		results - now use indicative name for the interaction variable rather than _000001;
*!		bootstrap - changed default number of repetitions from 200 to 1000;
*!		affected files - paramed.ado, paramedbs.ado, paramed.sthlp
*!	
*!	version 1.1 HL/RAE  28 November 2012
*!		updated to save and install files to Stata's PLUS folder
*!
*!	version 1.0 HL/RAE  1 October 2012
*!		final version for submitting to SSC
*! corresponding to paramed.ado 1.0 28 November 2012

*/

version 10.0	
mata: mata clear
mata: mata set matastrict off
mata:

void paramed(
		string scalar cvar, 
		real scalar a0, 
		real scalar a1, 
		real scalar m, 
		scalar nc, 
		string scalar yreg, 
		string scalar mreg, 
		string scalar interaction, 
		string scalar output, 
		string scalar c) 

{

	if ((strlower(yreg)=="linear") & (strlower(mreg)=="linear")) {	
		/*Part 1 yreg=linear mreg=linear: #1
			effects, standard errors, confidence intervals and p-value 
			no interaction w/ c
		*/
		if ((strlower(interaction)=="false") & (cvar!="")) {
				
			V1 = st_matrix("out1")
			theta = st_matrix("beta1")
			theta1 = theta[1,1]		
			theta2 = theta[1,2]
			
			V2 = st_matrix("out2")
			beta = st_matrix("beta2")
			beta1 = beta[1,1]		
			beta2 = beta[1,2::nc+1]		
			
			zero1 = J(rows(V1),rows(V2),0)
			zero2 = J(rows(V2),rows(V1),0)
			A = (V2, zero2)
			B = (zero1, V1)
			sigma = A \ B	
			
			zero = 0
			one1 = 1
			
			z1 = J(1, nc, 0)		//Note if nc==0, z1 is null
			z = (zero, z1, zero, one1, zero, zero)
			
			
			/*cde and nde*/
			noint1 = theta1 * (a1-a0)
			/*nie*/
			noint2 = (theta2 * beta1) * (a1-a0)
			/*te*/
			te = (theta1 + theta2 * beta1) * (a1 - a0)
			/*pm*/
			pm = (theta2 * beta1) / (theta1 + theta2 * beta1)
			
			nointgammacde = (zero, z1, zero,  one1, zero, z1, zero)	
			nointgammanie = (theta2, z1, zero,  zero, beta1, z1, zero)
			tegamma = (theta2, z1, zero,  one1, beta1, z1, zero)		
			
			/*se cde and nde*/
			nointse1 = sqrt(nointgammacde * sigma * nointgammacde') * abs(a1-a0)
			/*se nie*/
			nointse2 = sqrt(nointgammanie * sigma * nointgammanie') * abs(a1-a0)
			/*se te*/
			tese = sqrt(tegamma * sigma * tegamma') * abs(a1-a0)
			
		
			min = (1-abs(normal(te/tese))) < abs(normal(te/tese)) ? (1-abs(normal(te/tese))) : abs(normal(te/tese))
			ptwosidete = 2 * min
			citel = te - 1.96*tese
			citeu = te + 1.96*tese
			

			min = (1-abs(normal(noint1/nointse1))) < abs(normal(noint1/nointse1)) ? (1-abs(normal(noint1/nointse1))) : abs(normal(noint1/nointse1))	
			ptwoside1 = 2 * min
			min = (1-abs(normal(noint2/nointse2))) < abs(normal(noint2/nointse2)) ? (1-abs(normal(noint2/nointse2))) : abs(normal(noint2/nointse2))	
			ptwoside2 = 2 * min
			ci1l = noint1 - 1.96*nointse1
			ci1u = noint1 + 1.96*nointse1
			ci2l = noint2 - 1.96*nointse2
			ci2u = noint2 + 1.96*nointse2
			
			value1 = (noint1, noint2)
			se1 = (nointse1, nointse2)
			pvalue1 = (ptwoside1, ptwoside2)
			cil1 = (ci1l, ci2l)
			ciu1 = (ci1u, ci2u)
			x1 = (value1', se1', pvalue1', cil1', ciu1')
		
			value2 = (te, pm)
			se2 = (tese, 0)
			pvalue2 = (ptwosidete, 0)
			cil2 = (citel, 0)
			ciu2 = (citeu, 0)
			x2 = (value2', se2', pvalue2', cil2', ciu2')
			
			x = x1 \ x2
		
			st_matrix("results", x)
			st_local("rspec", "rspec(&-&&&&)")		//with r rows, r+2 characters if column headers are displayed
			st_local("rownames", `""cde=nde" nie "total effect" "proportion mediated""')				
			st_local("cspec", "cspec(& b %24s | %8.5f & %8.5f & %8.5f & %12.5f & %12.5f &)")
			st_local("colnames", `"Estimate s_e p-value "95% CI lower" "95% CI upper""')
		}
	
	
		/*Part 1 yreg=linear mreg=linear: #2
			effects, standard errors, confidence intervals and p-value 
			no interaction w/o c
		*/
		if ((strlower(interaction)=="false") & (cvar=="")) {
				
			V1 = st_matrix("out1")
			theta = st_matrix("beta1")
			theta1 = theta[1,1]	
			theta2 = theta[1,2]
			
			V2 = st_matrix("out2")
			beta = st_matrix("beta2")
			beta1 = beta[1,1]
		//	beta2 = beta[1,2:nc+2]
			
			zero1 = J(rows(V1),rows(V2),0)
			zero2 = J(rows(V2),rows(V1),0)
			A = (V2, zero2)
			B = (zero1, V1)
			sigma = A \ B	
		//	sigma
			
			zero = 0
			one1 = 1
			
			
			
			/*cde and nde*/
			noint1 = theta1 * (a1-a0)
			/*nie*/
			noint2 = (theta2 * beta1) * (a1-a0)
			/*te*/
			te = (theta1 + theta2 * beta1) * (a1 - a0)
			/*pm*/
			pm = (theta2 * beta1) / (theta1 + theta2 * beta1)
			
			nointgammacde = (zero, zero, one1, zero, zero)	
			nointgammanie = (theta2, zero, zero, beta1, zero)
			tegamma = (theta2, zero, one1, beta1, zero)
			
			/*se cde and nde*/
			nointse1 = sqrt(nointgammacde * sigma * nointgammacde') * abs(a1-a0)
			/*se nie*/
			nointse2 = sqrt(nointgammanie * sigma * nointgammanie') * abs(a1-a0)
			/*se te*/
			tese = sqrt(tegamma * sigma * tegamma') * abs(a1-a0)
			
		//	pgreaterte = 1 - normal(te/tese)	//variable not used
		//	plesste = normal(te/tese)
			
			
			ptwosidete = 2 * min((1-abs(normal(te/tese)), abs(normal(te/tese))))
			citel = te - 1.96*tese
			citeu = te + 1.96*tese
			
		//	pgreater1 = 1 - normal(noint1/nointse1)
		//	pless1 = normal(noint1/nointse1)
			min = (1-abs(normal(noint1/nointse1))) < abs(normal(noint1/nointse1)) ? (1-abs(normal(noint1/nointse1))) : abs(normal(noint1/nointse1))	
			ptwoside1 = 2 * min
		//	pgreater2 = 1 - normal(noint2/nointse2)
		//	pless2 = normal(noint2/nointse2)
			min = (1-abs(normal(noint2/nointse2))) < abs(normal(noint2/nointse2)) ? (1-abs(normal(noint2/nointse2))) : abs(normal(noint2/nointse2))	
			ptwoside2 = 2 * min
			ci1l = noint1 - 1.96*nointse1
			ci1u = noint1 + 1.96*nointse1
			ci2l = noint2 - 1.96*nointse2
			ci2u = noint2 + 1.96*nointse2
			
			value1 = (noint1, noint2)
			se1 = (nointse1, nointse2)
			pvalue1 = (ptwoside1, ptwoside2)
			cil1 = (ci1l, ci2l)
			ciu1 = (ci1u, ci2u)
			x1 = (value1', se1', pvalue1', cil1', ciu1')
		
			value2 = (te, pm)
			se2 = (tese, 0)
			pvalue2 = (ptwosidete, 0)
			cil2 = (citel, 0)
			ciu2 = (citeu, 0)
			x2 = (value2', se2', pvalue2', cil2', ciu2')
			
			x = x1 \ x2
		//	x
			
			st_matrix("results", x)
			st_local("rspec", "rspec(&-&&&&)")		//with r rows, r+2 characters if column headers are displayed
			st_local("rownames", `""cde=nde" nie "total effect" "proportion mediated""')				
			st_local("cspec", "cspec(& b %24s | %8.5f & %8.5f & %8.5f & %12.5f & %12.5f &)")
			st_local("colnames", `"Estimate s_e p-value "95% CI lower" "95% CI upper""')
		}
	
	
		/*Part 1 yreg=linear mreg=linear: #3
			effects, standard errors, confidence intervals and p-value interaction w/ c
		*/	
		//%if &interaction=true & &cvar^= %then %do
		if ((strlower(interaction)=="true") & (cvar!="")) {
			vars = st_data(., tokens(cvar))
			vb1 = mean(vars)
			cmean = vb1[1, cols(vb1)-nc+1::cols(vb1)]
		//	cmean = mean(vars)
			
			//%if &c^= %then %do
			if (c!="") {
				cvals = tokens(c)
				cc=strtoreal(cvals)		
				
				cmean = vb1
			}
			//%end
			
			V1 = st_matrix("out1")
			theta = st_matrix("beta1")
			theta1 = theta[1,1]	
			theta2 = theta[1,2]
			theta3 = theta[1,3]
			
			V2 = st_matrix("out2")
			beta = st_matrix("beta2")
			beta0 = beta[1,cols(beta)]
			beta1 = beta[1,1]
			beta2 = beta[1,2::nc+1]		
			
			zero1=J(rows(V1),rows(V2),0)
			zero2=J(rows(V2),rows(V1),0)
			A= (V2, zero2)
			B= (zero1, V1)
			sigma= A \ B
			zero=0
			one1=1
			z1=J(1,nc,0)
			z=zero, z1, zero,  one1, zero		
	
			//%if &c^= %then %do
			if (c!="") {
				/*CONDITIONAL CDE*/
				int1=(theta1)*(a1-a0)+(theta3*(m))*(a1-a0)
				/*CONDITIONAL NDE*/
				int2=(theta1+theta3*beta0+theta3*beta1*a0+(theta3*beta2*cc'))*(a1-a0)
				/*CONDITIONAL NIE*/
				int3=(theta2*beta1+theta3*beta1*a0)*(a1-a0)
				/*CONDITIONAL TNDE*/
				int4=(theta1+theta3*beta0+theta3*beta1*a1+(theta3*beta2*cc'))*(a1-a0)
				/*CONDITIONAL TNIE*/
				int5=(theta2*beta1+theta3*beta1*a1)*(a1-a0)
			}
			//%end
		
			/*MARGINAL CDE*/
			int6=(theta1+theta3*m)*(a1-a0)
			/*MARGINAL NDE*/
			int7=(theta1+theta3*beta0+theta3*beta1*a0+(theta3*beta2*cmean'))*(a1-a0)
			/*MARGINAL NIE*/
			int8=(theta2*beta1+theta3*beta1*a0)*(a1-a0)
			/*MARGINAL TNDE*/
			int9=(theta1+theta3*beta0+theta3*beta1*a1+(theta3*beta2*cmean'))*(a1-a0)
			/*MARGINAL TNIE*/
			int10=(theta2*beta1+theta3*beta1*a1)*(a1-a0)
			
			/*te conditional*/
			//%if c^= %then %do
			if (c!="") {
				tecond=(theta1+theta3*beta0+theta3*beta1*a0+(theta3*beta2*cc')+theta2*beta1+theta3*beta1*a1)*(a1-a0)
			}
			//%end

			/*te marginal*/
			temarg=(theta1+theta3*beta0+theta3*beta1*a0+(theta3*beta2*cmean')+theta2*beta1+theta3*beta1*a1)*(a1-a0)
			/*pm*/
			pm=(theta2*beta1+theta3*beta1*a1)/(theta1+theta3*beta0+theta3*beta1*a0+(theta3*beta2*cmean')+theta2*beta1+theta3*beta1*a1)
			
			//%if c^= %then %do
			if (c!="") {
				condgammacde=zero, z1, zero,  one1, zero, m, z1, zero
				
				x1=theta3*a0
				w=theta3*cc'
				h1=beta0+beta1*a0+(beta2)*cc'
				condgammapnde= x1, w', theta3,  one1, zero, h1', z1, zero
				x0=theta3*a1
				h0=beta0+beta1*a1+(beta2)*cc'
				condgammatnde=x0, w', theta3,  one1, zero, h0', z1, zero
				w0=beta1*a1
				condgammatnie=x0, z1, zero,  zero, beta1, w0, z1, zero
				x1=theta2+theta3*a0
				w1=beta1*a0
				condgammapnie=x1, z1, zero,  zero, beta1, w1, z1, zero
				/*cond se cde*/
				intse1=sqrt(condgammacde*sigma*condgammacde')* abs(a1-a0)
				/*cond se pnde*/
				intse2=sqrt(condgammapnde*sigma*condgammapnde')* abs(a1-a0)
				/*cond se pnie*/
				intse3=sqrt(condgammapnie*sigma*condgammapnie')* abs(a1-a0)
				/*cond se tnde*/
				intse4=sqrt(condgammatnde*sigma*condgammatnde')* abs(a1-a0)
				/*cond se tnie*/
				intse5=sqrt(condgammatnie*sigma*condgammatnie')* abs(a1-a0)
			}
			//%end
			
			marggammacde=zero, z1, zero,  one1, zero, m, z1, zero

			x1=theta3*a0
			w=theta3*cmean'
			h1=beta0+beta1*a0+(beta2)*cmean'
			marggammapnde= x1, w', theta3,  one1, zero, h1' ,z1, zero
			x0=theta3*a1
			w=theta3*cmean'
			h0=beta0+beta1*a1+(beta2)*cmean'
			marggammatnde=x0, w', theta3,  one1, zero, h0' ,z1, zero
			x0=theta2+theta3*a1
			w0=beta1*a1
			marggammatnie=x0, z1, zero,  zero, beta1, w0, z1, zero
			x1=theta2+theta3*a0
			w1=beta1*a0
			marggammapnie=x1, z1, zero,  zero, beta1, w1, z1, zero
			/*marg se cde*/
			intse6=sqrt(marggammacde*sigma*marggammacde')* abs(a1-a0)
			/*marg se pnde*/
			intse7=sqrt(marggammapnde*sigma*marggammapnde')* abs(a1-a0)
			/*marg se pnie*/
			intse8=sqrt(marggammapnie*sigma*marggammapnie')* abs(a1-a0)
			/*marg se tnde*/
			intse9=sqrt(marggammatnde*sigma*marggammatnde')* abs(a1-a0)
			/*marg se tnie*/
			intse10=sqrt(marggammatnie*sigma*marggammatnie')* abs(a1-a0)
			/*se te cond*/
			
			//%if c^= %then %do
			if (c!="") {
				D=theta3*(cc)
				A=(theta3*a1+theta3*a0+theta2)
				B=beta0+beta1*(a1+a0)+beta2*cc'
			//	tegammacond=theta3, A, (D),  zero, one1, beta1, B, z1
				tegammacond=A, (D), theta3,  one1, beta1, B, z1, zero
				tesecond=sqrt(tegammacond*sigma*tegammacond')* abs(a1-a0)
			}
			//%end
	
			D=theta3*(cmean)
			A=(theta3*a1+theta3*a0+theta2)
			B=beta0+beta1*(a1+a0)+beta2*cmean'
			tegammamarg=A,(D),theta3,  one1,beta1,B,z1,zero
			tesemarg=sqrt(tegammamarg*sigma*tegammamarg')* abs(a1-a0)
			
			//%if c^= %then %do
			if (c!="") {
			//	pgreater1 = 1 - normal((int1)/(intse1))
			//	pless1 = normal((int1)/(intse1))
				min = (1- abs(normal((int1)/(intse1)))) < abs(normal((int1)/(intse1))) ? (1- abs(normal((int1)/(intse1)))) : abs(normal((int1)/(intse1)))	
				ptwoside1 = 2*min
				
			//	pgreater2 = 1 - normal((int2)/(intse2))
			//	pless2 = normal((int2)/(intse2))
				min = (1- abs(normal((int2)/(intse2)))) < abs(normal((int2)/(intse2))) ? (1- abs(normal((int2)/(intse2)))) : abs(normal((int2)/(intse2)))	
				ptwoside2 = 2*min
				
			//	pgreater3 = 1 - normal((int3)/(intse3))
			//	pless3 = normal((int3)/(intse3))
				min = (1- abs(normal((int3)/(intse3)))) < abs(normal((int3)/(intse3))) ? (1- abs(normal((int3)/(intse3)))) : abs(normal((int3)/(intse3)))	
				ptwoside3 = 2*min
				
			//	pgreater4 = 1 - normal((int4)/(intse4))
			//	pless4 = normal((int4)/(intse4))
				min = (1- abs(normal((int4)/(intse4)))) < abs(normal((int4)/(intse4))) ? (1- abs(normal((int4)/(intse4)))) : abs(normal((int4)/(intse4)))	
				ptwoside4 = 2*min
				
			//	pgreater5 = 1 - normal((int5)/(intse5))
			//	pless5 = normal((int5)/(intse5))
				min = (1- abs(normal((int5)/(intse5)))) < abs(normal((int5)/(intse5))) ? (1- abs(normal((int5)/(intse5)))) : abs(normal((int5)/(intse5)))	
				ptwoside5 = 2*min
			}
			//%end
	
		//	pgreater6 = 1 - normal((int6)/(intse6))
		//	pless6 = normal((int6)/(intse6))
			min = (1- abs(normal((int6)/(intse6)))) < abs(normal((int6)/(intse6))) ? (1- abs(normal((int6)/(intse6)))) : abs(normal((int6)/(intse6)))	
			ptwoside6 = 2*min
	
		//	pgreater7 = 1 - normal((int7)/(intse7))
		//	pless7 = normal((int7)/(intse7))
			min = (1- abs(normal((int7)/(intse7)))) < abs(normal((int7)/(intse7))) ? (1- abs(normal((int7)/(intse7)))) : abs(normal((int7)/(intse7)))	
			ptwoside7 = 2*min
	
		//	pgreater8 = 1 - normal((int8)/(intse8))
		//	pless8 = normal((int8)/(intse8))
			min = (1- abs(normal((int8)/(intse8)))) < abs(normal((int8)/(intse8))) ? (1- abs(normal((int8)/(intse8)))) : abs(normal((int8)/(intse8)))	
			ptwoside8 = 2*min
	
		//	pgreater9= 1 - normal((int9)/(intse9))
		//	pless9 = normal((int9)/(intse9))
			min = (1- abs(normal((int9)/(intse9)))) < abs(normal((int9)/(intse9))) ? (1- abs(normal((int9)/(intse9)))) : abs(normal((int9)/(intse9)))	
			ptwoside9 = 2*min
	
		//	pgreater10 = 1 - normal((int10)/(intse10))
		//	pless10 = normal((int10)/(intse10))
			min = (1- abs(normal((int10)/(intse10)))) < abs(normal((int10)/(intse10))) ? (1- abs(normal((int10)/(intse10)))) : abs(normal((int10)/(intse10)))	
			ptwoside10 = 2*min
	
			//%if c^= %then %do
			if (c!="") {
				ci1l=int1-1.96*intse1
				ci1u=int1+1.96*intse1
				ci2l=int2-1.96*intse2
				ci2u=int2+1.96*intse2
				ci3l=int3-1.96*intse3
				ci3u=int3+1.96*intse3
				ci4l=int4-1.96*intse4
				ci4u=int4+1.96*intse4
				ci5l=int5-1.96*intse5
				ci5u=int5+1.96*intse5
			}
			//%end
			
			ci6l=int6-1.96*intse6
			ci6u=int6+1.96*intse6
			ci7l=int7-1.96*intse7
			ci7u=int7+1.96*intse7
			ci8l=int8-1.96*intse8
			ci8u=int8+1.96*intse8
			ci9l=int9-1.96*intse9
			ci9u=int9+1.96*intse9
			ci10l=int10-1.96*intse10
			ci10u=int10+1.96*intse10
	
			ptwosidetemarg = (1-normal(abs((temarg)/(tesemarg))))*2
			citelmarg=temarg-1.96*tesemarg
			citeumarg=temarg+1.96*tesemarg
			
			//%if c^= %then %do
			if (c!="") {
				ptwosidetecond = (1-normal(abs((tecond)/(tesecond))))*2
				citelcond=tecond-1.96*tesecond
				citeucond=tecond+1.96*tesecond
			}
			//%end
			
			//%if output=full %then %do 
			if (strlower(output)=="full") {
				value1= int6, int7, int8, int9, int10, temarg, int1 , int2, int3, int4, int5, tecond, pm
				se1= intse6, intse7, intse8, intse9, intse10, tesemarg, intse1 , intse2, intse3, intse4, intse5, tesecond, 0
				pvalue1=  ptwoside6, ptwoside7, ptwoside8, ptwoside9, ptwoside10, ptwosidetemarg, ptwoside1 , ptwoside2, ptwoside3, ptwoside4, ptwoside5, ptwosidetecond, 0
				cil1=ci6l,ci7l,ci8l,ci9l,ci10l, citelmarg, ci1l,ci2l,ci3l,ci4l,ci5l, citelcond, 0
				ciu1=ci6u,ci7u,ci8u,ci9u,ci10u, citeumarg, ci1u,ci2u,ci3u,ci4u,ci5u, citeucond, 0
				x= value1' ,se1',pvalue1',cil1',ciu1' 
				
				st_matrix("results", x)
				st_local("rspec", "rspec(&-&&&&&&&&&&&&&)")		//with r rows, r+2 characters if column headers are displayed
				st_local("rownames", `""marginal cde"	"marginal pnde" "marginal pnie" "marginal tnde" "marginal tnie" "marginal total effect" "conditional cde" "conditional pnde" "conditional pnie" "conditional tnde" "conditional tnie" "conditional total effect" "proportion mediated""')	//v0.3g	
				st_local("cspec", "cspec(& b %24s | %8.5f & %8.5f & %8.5f & %12.5f & %12.5f &)")
				st_local("colnames", `"Estimate s_e p-value "95% CI lower" "95% CI upper""')
			}
			//%end
	
			//%if output^=full %then %do 
			if (strlower(output)!="full") {
				value1= int6 , int7, int10 
				se1= intse6,intse7,intse10
				pvalue1=ptwoside6 , ptwoside7, ptwoside10
				cil1=ci6l,ci7l,ci10l
				ciu1=ci6u,ci7u,ci10u
				x1= value1' ,se1',pvalue1',cil1',ciu1' 
				value2=  temarg , pm
				se2= tesemarg ,0
				pvalue2=  ptwosidetemarg , 0
				cil2=citelmarg,0
				ciu2=citeumarg,0
				x2= value2' ,se2',pvalue2',cil2',ciu2' 
				x=x1 \ x2
								
				st_matrix("results", x)	
				st_local("rspec", "rspec(&-&&&&&)")		//with r rows, r+2 characters if column headers are displayed
				st_local("rownames", `"cde nde nie "marginal total effect" "proportion mediated""')
				st_local("cspec", "cspec(& b %24s | %8.5f & %8.5f & %8.5f & %12.5f & %12.5f &)")
				st_local("colnames", `"Estimate s_e p-value "95% CI lower" "95% CI upper""')			
			}
			//%end
		}
	
	
		/*Part 1 yreg=linear mreg=linear: #4
			effects, standard errors, confidence intervals and p-value
			interaction w/o c
		*/
		if ((strlower(interaction)=="true") & (cvar=="")) {
						
			V1 = st_matrix("out1")
			theta = st_matrix("beta1")
		//	theta0 = theta[1,4]		//_b[_cons], variable not used
			theta1 = theta[1,1]	
			theta2 = theta[1,2]
			theta3 = theta[1,3]
			
			V2 = st_matrix("out2")
			beta = st_matrix("beta2")
			beta0 = beta[1,2]		//_b[_cons]
			beta1 = beta[1,1]
			
			zero1 = J(rows(V1),rows(V2),0)
			zero2 = J(rows(V2),rows(V1),0)
			A = (V2, zero2)
			B = (zero1, V1)
			sigma = A \ B	
			
			zero = 0
			one1 = 1
				
			/*CONDITIONAL=MARGINAL CDE*/
			int1=theta1*(a1-a0) + (theta3*m)*(a1-a0)
			/*CONDITIONAL=MARGINAL NDE*/
			int2=(theta1 + theta3*beta0 + theta3*beta1*a0)*(a1-a0)
			/*CONDITIONAL=MARGINAL NIE*/
			int3=(theta2*beta1 + theta3*beta1*a0)*(a1-a0)
			/*CONDITIONAL=MARGINAL TNDE*/
			int4=(theta1 + theta3*beta0 + theta3*beta1*a1)*(a1-a0)
			/*CONDITIONAL=MARGINAL TNIE*/
			int5=(theta2*beta1 + theta3*beta1*a1)*(a1-a0)
			/*te*/
			te=(theta1 + theta3*beta0 + theta3*beta1*a0 + theta2*beta1 + theta3*beta1*a1)*(a1-a0)
			/*pm*/
			pm=(theta2*beta1 + theta3*beta1*a1) / (theta1 + theta3*beta0 + theta3*beta1*a0 + theta2*beta1 + theta3*beta1*a1)
		
			condgammacde=(zero,zero, one1,zero,m,zero)
		
			x1=theta3*a0
			h1=beta0 + beta1*a0
			condgammapnde= (x1, theta3,  one1, zero, h1', zero)
			x0=theta3*a1
			h0=beta0 + beta1*a1
			condgammatnde=(x0, theta3,  one1, zero, h0', zero)
			w0=beta1*a1
			condgammatnie=(x0, zero,  zero, beta1, w0, zero)
			w1=beta1*a0
			condgammapnie=(x1, zero,  zero, beta1, w1, zero) 
		
			A=theta3*a1 + theta3*a0 + theta2
			B=beta0 + beta1*(a0+a1)		
			tegamma=(A,theta3, one1,beta1,B,zero)
		
			/*cond=marg se cde*/
			intse1=sqrt(condgammacde*sigma*condgammacde')*abs(a1-a0)
			/*cond=marg se pnde*/
			intse2=sqrt(condgammapnde*sigma*condgammapnde')*abs(a1-a0)
			/*cond=marg se pnie*/
			intse3=sqrt(condgammapnie*sigma*condgammapnie')*abs(a1-a0)
			/*cond=marg se tnde*/
			intse4=sqrt(condgammatnde*sigma*condgammatnde')*abs(a1-a0)
			/*cond=marg se tnie*/
			intse5=sqrt(condgammatnie*sigma*condgammatnie')*abs(a1-a0)
			/*se te*/
			tese=sqrt(tegamma*sigma*tegamma')*abs(a1-a0)
		//	pgreater1 = 1 - normal(int1/intse1)
		//	pless1 = normal(int1/intse1)
			min = (1-abs(normal(int1/intse1))) < abs(normal(int1/intse1)) ? (1-abs(normal(int1/intse1))) : abs(normal(int1/intse1))
			ptwoside1 = 2*min
		//	pgreater2 = 1 - normal((int2)/(intse2))
		//	pless2 = normal((int2)/(intse2))
			min = (1-abs(normal((int2)/(intse2)))) < abs(normal((int2)/(intse2))) ? (1-abs(normal((int2)/(intse2)))) : abs(normal((int2)/(intse2)))
			ptwoside2 = 2*min
		//	pgreater3 = 1 - normal((int3)/(intse3))
		//	pless3 = normal((int3)/(intse3))
			min = (1-abs(normal((int3)/(intse3)))) < abs(normal((int3)/(intse3))) ? (1-abs(normal((int3)/(intse3)))) : abs(normal((int3)/(intse3)))
			ptwoside3 = 2*min
		//	pgreater4 = 1 - normal((int4)/(intse4))
		//	pless4 = normal((int4)/(intse4))
			min = (1-abs(normal((int4)/(intse4)))) < abs(normal((int4)/(intse4))) ? (1-abs(normal((int4)/(intse4)))) : abs(normal((int4)/(intse4)))
			ptwoside4 = 2*min
		//	pgreater5 = 1 - normal((int5)/(intse5))
		//	pless5 = normal((int5)/(intse5))
			min = (1-abs(normal((int5)/(intse5)))) < abs(normal((int5)/(intse5))) ? (1-abs(normal((int5)/(intse5)))) : abs(normal((int5)/(intse5)))
			ptwoside5 = 2*min
			ci1l=int1-1.96*intse1
			ci1u=int1+1.96*intse1
			ci2l=int2-1.96*intse2
			ci2u=int2+1.96*intse2
			ci3l=int3-1.96*intse3
			ci3u=int3+1.96*intse3
			ci4l=int4-1.96*intse4
			ci4u=int4+1.96*intse4
			ci5l=int5-1.96*intse5
			ci5u=int5+1.96*intse5
		//	pgreaterte = 1 - normal((te)/(tese))	//variable not used
		//	plesste = normal((te)/(tese))
			ptwosidete = (1-normal(abs(te)/tese))*2
			citel=te-1.96*tese
			citeu=te+1.96*tese
			if (strlower(output)=="full") {	//full output
				value1= (int1, int2, int3, int4, int5)
				se1= (intse1, intse2, intse3, intse4, intse5)
				pvalue1= (ptwoside1, ptwoside2, ptwoside3, ptwoside4, ptwoside5)
				cil1=(ci1l, ci2l, ci3l, ci4l, ci5l)
				ciu1=(ci1u, ci2u, ci3u, ci4u, ci5u)
				x1= (value1', se1', pvalue1', cil1', ciu1')
				value2= (te, pm)
				se2= (tese, 0)
				pvalue2=  (ptwosidete, 0)
				cil2=(citel, 0)
				ciu2=(citeu, 0)
				x2= (value2', se2', pvalue2', cil2', ciu2') 
				x=x1 \ x2		
				
				st_matrix("results", x)
				st_local("rspec", "rspec(&-&&&&&&&)")		//with r rows, r+2 characters if column headers are displayed
				st_local("rownames", `"cde pnde pnie tnde tnie "total effect" "proportion mediated""')			
				st_local("cspec", "cspec(& b %24s | %8.5f & %8.5f & %8.5f & %12.5f & %12.5f &)")
				st_local("colnames", `"Estimate s_e p-value "95% CI lower" "95% CI upper""')
			}
				
			if (strlower(output)!="full") {
				value1= (int1, int2, int5)
				se1= (intse1, intse2, intse5)
				pvalue1= (ptwoside1, ptwoside2, ptwoside5)
				cil1=(ci1l, ci2l, ci5l)
				ciu1=(ci1u, ci2u, ci5u)
				
				x1= (value1', se1', pvalue1', cil1', ciu1')
				value2= (te, pm)
				se2= (tese, 0)
				pvalue2=  (ptwosidete, 0)
				cil2=(citel, 0)
				ciu2=(citeu, 0)
				x2= (value2', se2', pvalue2', cil2', ciu2') 
				x=x1 \ x2		
				
				st_matrix("results", x)
				st_local("rspec", "rspec(&-&&&&&)")		//with r rows, r+2 characters if column headers are displayed
				st_local("rownames", `"cde nde nie "marginal total effect" "proportion mediated""')	
				st_local("cspec", "cspec(& b %24s | %8.5f & %8.5f & %8.5f & %12.5f & %12.5f &)")
				st_local("colnames", `"Estimate s_e p-value "95% CI lower" "95% CI upper""')				
			}
		
		}
	}	
	
	
	if ((strlower(yreg)=="linear") & (strlower(mreg)=="logistic")) {
		/**********************************************************************************/
		/*Part 2 yreg=linear mreg=logistic: #1
			effects, standard errors, confidence intervals and p-value no interaction w/ c
		*/	
		//%if &interaction=false & &cvar^= %then %do
		if ((strlower(interaction)=="false") & (cvar!="")) {
			vars = st_data(., tokens(cvar))
			vb1 = mean(vars)
			cmean = vb1
			
			//%if &c^= %then %do
			if (c!="") {
				cvals = tokens(c)
				cc=strtoreal(cvals)		
			}
			//%end
			
			V1 = st_matrix("out1")
			theta = st_matrix("beta1")
			theta1 = theta[1,1]	
			theta2 = theta[1,2]
			theta3 = theta[1,3]
			
			V2 = st_matrix("out2")
			beta = st_matrix("beta2")
			beta0 = beta[1,cols(beta)]
			beta1 = beta[1,1]
			beta2 = beta[1,2::cols(beta)-1]		
	
			zero1=J(rows(V1),rows(V2),0)
			zero2=J(rows(V2),rows(V1),0)
			A= V2, zero2
			B= zero1, V1
			sigma= A \ B
			zero=0
			one1=1
			z1=J(1,nc,0)
			z=zero,z1,zero, one1,zero		
	
			//%if &c^= %then %do
			if (c!="") {
				condgammacde=z,z1,zero
				A=exp(beta0+beta1*a0+beta2*cc')
				B=(1+A)
				x=0
				w=0
				condgammapnde= w , z1, x,  one1, zero, z1, zero
				
				A=exp(beta0+beta1*a1+beta2*cc')		
				B=(1+A)
				x=0
				w=0
				condgammatnde=w , z1, x,  one1, zero, z1, zero
				D=exp(beta0+beta1*a1+beta2*cc')
				E=(1+D)
				A=exp(beta0+beta1*a0+beta2*cc')
				B=(1+A)
				x=(theta2)*((D*E-D^2)/E^2-(A*B-A^2)/B^2)
				w=(theta2)*(a1*(D*E-D^2)/E^2-a0*(A*B-A^2)/B^2)
				y=cc*(theta2)*((D*E-D^2)/E^2-(A*B-A^2)/B^2)
				h=(D/E-A/B)'
				condgammatnie=w, y, x,  zero, h, z1, zero
				x=(theta2)*((D*E-D^2)/E^2-(A*B-A^2)/B^2)
				w=(theta2)*(a1*(D*E-D^2)/E^2-a0*(A*B-A^2)/B^2)
				y=cc*(theta2)*((D*E-D^2)/E^2-(A*B-A^2)/B^2)
				h=(D/E-A/B)'
				condgammapnie=w, y, x,  zero, h, z1, zero
				/*cond se cde*/
				intse1=sqrt(condgammacde*sigma*condgammacde')* abs(a1-a0)
				/*cond se pnde*/
				intse2=sqrt(condgammapnde*sigma*condgammapnde')* abs(a1-a0)
				/*cond se pnie*/
				intse3=sqrt(condgammapnie*sigma*condgammapnie')
				/*cond se tnde*/
				intse4=sqrt(condgammatnde*sigma*condgammatnde')* abs(a1-a0)
				/*cond se tnie*/
				intse5=sqrt(condgammatnie*sigma*condgammatnie')
			}
			//%end
	
			marggammacde=z, z1, zero		
			A=exp(beta0+beta1*a0+beta2*cmean')
			B=(1+A)
			x=0
			w=0
			marggammapnde=  w , z1, x,  one1, zero,  z1, zero
			A=exp(beta0+beta1*a1+beta2*cmean')
			B=(1+A)
			marggammatnde=w , z1, x,  one1, zero,  z1, zero
			D=exp(beta0+beta1*a1+beta2*cmean')
			E=(1+D)
			A=exp(beta0+beta1*a0+beta2*cmean')
			B=(1+A)
			x=(theta2)*((D*E-D^2)/E^2-(A*B-A^2)/B^2)
			w=(theta2)*(a1*(D*E-D^2)/E^2-a0*(A*B-A^2)/B^2)
			y=cmean*(theta2)*((D*E-D^2)/E^2-(A*B-A^2)/B^2)
			h=(D/E-A/B)'
			marggammatnie=w, y, x,  zero, h,  z1, zero
			marggammapnie=w, y, x,  zero, h,  z1, zero
			/*marg se cde*/
			intse6=sqrt(marggammacde*sigma*marggammacde')* abs(a1-a0)
			/*marg se pnde*/
			intse7=sqrt(marggammapnde*sigma*marggammapnde')* abs(a1-a0)
			/*marg se pnie*/
			intse8=sqrt(marggammapnie*sigma*marggammapnie')
			/*marg se tnde*/
			intse9=sqrt(marggammatnde*sigma*marggammatnde')* abs(a1-a0)
			/*marg se tnie*/
			intse10=sqrt(marggammatnie*sigma*marggammatnie')
			
			//%if &c^= %then %do
			if (c!="") {
				A=exp(beta0+beta1*a0+beta2*cc')
				B=(1+A)
				D=exp(beta0+beta1*a1+beta2*cc')
				E=(1+D)
				x=(theta2)*((D*E-E^2)/(E^2)-(A*B-B^2)/(B^2))
				w=((theta2)*(a1*(D*E-E^2)/(E^2)-a0*(A*B-B^2)/(B^2)))
				y=(theta2)*cc*((D*E-E^2)/(E^2)-(A*B-B^2)/(B^2))
				t=(D/E-A/B)'
				s=(a1-a0)
				tegammacond=w,y,x, s,t,z1,zero
				tesecond=sqrt(tegammacond*sigma*tegammacond')
			}
			//%end
	
			A=exp(beta0+beta1*a0+beta2*cmean')
			B=(1+A)
			D=exp(beta0+beta1*a1+beta2*cmean')
			E=(1+D)
			x=(theta2)*((D*E-E^2)/(E^2)-(A*B-B^2)/(B^2))
			w=((theta2)*(a1*(D*E-E^2)/(E^2)-a0*(A*B-B^2)/(B^2)))
			y=(theta2)*cmean*((D*E-E^2)/(E^2)-(A*B-B^2)/(B^2))
			t=(D/E-A/B)'
			s=(a1-a0)
			tegammamarg=w,y,x, s,t,z1,zero
			tesemarg=sqrt(tegammamarg*sigma*tegammamarg')
			
			//%if &c^= %then %do
			if (c!="") {	
				/*CONDITIONAL CDE*/
				int1=(theta1)*(a1-a0)
				/*CONDITIONAL PNDE*/
				int2=(theta1)*(a1-a0)
				/*CONDITIONAL PNIE*/
				int3=(theta2)*(exp(beta0+beta1*a1+sum(beta2*cc'))/(1+exp(beta0+beta1*a1+sum(beta2*cc')))-exp(beta0+beta1*a0+sum(beta2*cc'))/(1+exp(beta0+beta1*a0+sum(beta2*cc'))))
				/*CONDITIONAL TNDE*/
				int4=(theta1)*(a1-a0)
				/* CONDITIONAL TNIE*/
				int5=(theta2)*(exp(beta0+beta1*a1+sum(beta2*cc'))/(1+exp(beta0+beta1*a1+sum(beta2*cc')))-exp(beta0+beta1*a0+sum(beta2*cc'))/(1+exp(beta0+beta1*a0+sum(beta2*cc'))))
			}
			//%end
			
			/*MARGINAL CDE*/
			int6=(theta1)*(a1-a0)
			/*MARGINAL NDE*/
			int7=(theta1)*(a1-a0)
			/*MARGINAL NIE*/
			int8=(theta2)*(exp(beta0+beta1*a1+sum(beta2*cmean'))/(1+exp(beta0+beta1*a1+sum(beta2*cmean')))-exp(beta0+beta1*a0+sum(beta2*cmean'))/(1+exp(beta0+beta1*a0+sum(beta2*cmean'))))
			/* MARGINAL TNDE*/
			int9=(theta1)*(a1-a0)
			/* MARGINAL TNIE*/
			int10=(theta2)*(exp(beta0+beta1*a1+sum(beta2*cmean'))/(1+exp(beta0+beta1*a1+sum(beta2*cmean')))-exp(beta0+beta1*a0+sum(beta2*cmean'))/(1+exp(beta0+beta1*a0+sum(beta2*cmean'))))
	
			//%if &c^= %then %do
			if (c!="") {
				tecond = int2 + int5	
			}
			//%end
	
			temarg = int7 + int10		
			pm=(int10)/(temarg)
			//%if &c^= %then %do
			if (c!="") {
			//	pgreater1 = 1 - normal((int1)/(intse1))
			//	pless1 = normal((int1)/(intse1))
				ptwoside1 = 2*min((1-abs(normal((int1)/(intse1))), abs(normal((int1)/(intse1)))))
			//	pgreater2 = 1 - normal((int2)/(intse2))
			//	pless2 = normal((int2)/(intse2))
				ptwoside2 = 2*min((1- abs(normal((int2)/(intse2))), abs(normal((int2)/(intse2)))))
			//	pgreater3 = 1 - normal((int3)/(intse3))
			//	pless3 = normal((int3)/(intse3))
				ptwoside3 = 2*min((1- abs(normal((int3)/(intse3))), abs(normal((int3)/(intse3)))))
			//	pgreater4 = 1 - normal((int4)/(intse4))
			//	pless4 = normal((int4)/(intse4))
				ptwoside4 = 2*min((1- abs(normal((int4)/(intse4))), abs(normal((int4)/(intse4)))))
			//	pgreater5 = 1 - normal((int5)/(intse5))
			//	pless5 = normal((int5)/(intse5))
				ptwoside5 = 2*min((1- abs(normal((int5)/(intse5))), abs(normal((int5)/(intse5)))))
			}
			//%end
	
		//	pgreater6 = 1 - normal((int6)/(intse6))
		//	pless6 = normal((int6)/(intse6))
			ptwoside6 = 2*min((1- abs(normal((int6)/(intse6))), abs(normal((int6)/(intse6)))))
		//	pgreater7 = 1 - normal((int7)/(intse7))
		//	pless7 = normal((int7)/(intse7))
			ptwoside7 = 2*min((1- abs(normal((int7)/(intse7))), abs(normal((int7)/(intse7)))))
		//	pgreater8 = 1 - normal((int8)/(intse8))
		//	pless8 = normal((int8)/(intse8))
			ptwoside8 = 2*min((1- abs(normal((int8)/(intse8))), abs(normal((int8)/(intse8)))))
		//	pgreater9= 1 - normal((int9)/(intse9))
		//	pless9 = normal((int9)/(intse9))
			ptwoside9 = 2*min((1- abs(normal((int9)/(intse9))), abs(normal((int9)/(intse9)))))
		//	pgreater10 = 1 - normal((int10)/(intse10))
		//	pless10 = normal((int10)/(intse10))
			ptwoside10 = 2*min((1-abs(normal((int10)/(intse10))),abs(normal((int10)/(intse10)))))
			
			//%if &c^= %then %do
			if (c!="") {
				ci1l=int1-1.96*intse1
				ci1u=int1+1.96*intse1
				ci2l=int2-1.96*intse2
				ci2u=int2+1.96*intse2
				ci3l=int3-1.96*intse3
				ci3u=int3+1.96*intse3
				ci4l=int4-1.96*intse4
				ci4u=int4+1.96*intse4
				ci5l=int5-1.96*intse5
				ci5u=int5+1.96*intse5
			}
			//%end
			
			ci6l=int6-1.96*intse6
			ci6u=int6+1.96*intse6
			ci7l=int7-1.96*intse7
			ci7u=int7+1.96*intse7
			ci8l=int8-1.96*intse8
			ci8u=int8+1.96*intse8
			ci9l=int9-1.96*intse9
			ci9u=int9+1.96*intse9
			ci10l=int10-1.96*intse10
			ci10u=int10+1.96*intse10
	
			//%if &c^= %then %do
			if (c!="") {
				ptwosidetecond = (1-normal(abs((tecond)/(tesecond))))*2
				citelcond=tecond-1.96*(tesecond)
				citeucond=tecond+1.96*(tesecond)
			}

			ptwosidetemarg = (1-normal(abs((temarg)/(tesemarg))))*2
			citelmarg=temarg-1.96*(tesemarg)
			citeumarg=temarg+1.96*(tesemarg)
			
			//%if &output=full %then %do 
			if (strlower(output)=="full") {
				value1= int6, int7, int8, int9, int10, temarg, int1 , int2, int3, int4, int5, tecond, pm
				se1= intse6, intse7, intse8, intse9, intse10, tesemarg, intse1 , intse2, intse3, intse4, intse5, tesecond, 0
				pvalue1=  ptwoside6, ptwoside7, ptwoside8, ptwoside9, ptwoside10, ptwosidetemarg, ptwoside1 , ptwoside2, ptwoside3, ptwoside4, ptwoside5, ptwosidetecond, 0
				cil1=ci6l,ci7l,ci8l,ci9l,ci10l, citelmarg, ci1l,ci2l,ci3l,ci4l,ci5l, citelcond, 0
				ciu1=ci6u,ci7u,ci8u,ci9u,ci10u, citeumarg, ci1u,ci2u,ci3u,ci4u,ci5u, citeucond, 0
				x= value1' ,se1',pvalue1',cil1',ciu1' 
				
				st_matrix("results", x)
				st_local("rspec", "rspec(&-&&&&&&&&&&&&&)")		//with r rows, r+2 characters if column headers are displayed
				st_local("rownames", `""marginal cde"	"marginal pnde" "marginal pnie" "marginal tnde" "marginal tnie" "marginal total effect" "conditional cde" "conditional pnde" "conditional pnie" "conditional tnde" "conditional tnie" "conditional total effect" "proportion mediated""')	//v0.3g	
				st_local("cspec", "cspec(& b %24s | %8.5f & %8.5f & %8.5f & %12.5f & %12.5f &)")
				st_local("colnames", `"Estimate s_e p-value "95% CI lower" "95% CI upper""')	
			}
			//%end
	
			//%if &output^=full %then %do 
			if (strlower(output)!="full") {
				value1= int6 , int7, int10 
				se1= intse6,intse7,intse10
				pvalue1=ptwoside6 , ptwoside7, ptwoside10
				cil1=ci6l,ci7l,ci10l
				ciu1=ci6u,ci7u,ci10u
				x1= value1',se1',pvalue1',cil1',ciu1' 
				value2=  temarg,pm
				se2= tesemarg,0
				pvalue2=  ptwosidetemarg, 0
				cil2=citelmarg,0
				ciu2=citeumarg,0
				x2= value2',se2',pvalue2',cil2',ciu2' 
				x=x1 \ x2

				st_matrix("results", x)	
				st_local("rspec", "rspec(&-&&&&&)")		//with r rows, r+2 characters if column headers are displayed
				st_local("rownames", `"cde nde nie "marginal total effect" "proportion mediated""')							
				st_local("cspec", "cspec(& b %24s | %8.5f & %8.5f & %8.5f & %12.5f & %12.5f &)")
				st_local("colnames", `"Estimate s_e p-value "95% CI lower" "95% CI upper""')
			}
			//%end
			
		}
	
		/**********************************************************************************/
		/*Part 2 yreg=linear mreg=logistic: #2
			effects, standard errors, confidence intervals and p-value no interaction w/o c
		*/	
		//%if &interaction=false & &cvar= %then %do
		if ((strlower(interaction)=="false") & (cvar=="")) {
	
			V1 = st_matrix("out1")
			theta = st_matrix("beta1")
			theta1 = theta[1,1]
			theta2 = theta[1,2]
			
			V2 = st_matrix("out2")
			beta = st_matrix("beta2")
			beta0 = beta[1,cols(beta)]
			beta1 = beta[1,1]
	
			zero1=J(rows(V1),rows(V2),0)
			zero2=J(rows(V2),rows(V1),0)
			A= V2, zero2
			B= zero1, V1
			sigma= A \ B
			zero=0
			one1=1
			z1=J(1,nc,0)
	
			z=zero,zero, one1,zero,zero
			nointgammacde=z
			D=exp(beta0+beta1*a1)
			E=(1+D)
			A=exp(beta0+beta1*a0)
			B=(1+A)
			x=(theta2)*((D*E-D^2)/E^2-(A*B-A^2)/B^2)
			w=(theta2)*(a1*(D*E-D^2)/E^2-a0*(A*B-A^2)/B^2)
			h=(D/E-A/B)'
			nointgammanie=w,x,  zero,h,zero
			A=exp(beta0+beta1*a0)
			B=(1+A)
			D=exp(beta0+beta1*a1)
			E=(1+D)
			x=(theta2)*((D*E-D^2)/(E^2)-(A*B-B^2)/(B^2))
			w=((theta2)*(a1*(D*E-D^2)/(E^2)-a0*(A*B-B^2)/(B^2)))
			t=(D/E-A/B)'
			s=(a1-a0)
			tegamma=w,x, s,t,zero
			nointse1=sqrt(nointgammacde*sigma*nointgammacde')* abs(a1-a0)
			/*nie*/
			nointse2=sqrt(nointgammanie*sigma*nointgammanie')* abs(a1-a0)
			tese=sqrt(tegamma*sigma*tegamma')
			noint1=(theta1)*(a1-a0)
			noint2=(theta2)*(exp(beta0+beta1*a1)/(1+exp(beta0+beta1*a1))-exp(beta0+beta1*a0)/(1+exp(beta0+beta1*a0)))
			/*te*/
			te=((theta1)*(a1-a0)+(theta2)*(exp(beta0+beta1*a1)/(1+exp(beta0+beta1*a1))-exp(beta0+beta1*a0)/(1+exp(beta0+beta1*a0))))
			te = noint2 + noint1	
			pm=(noint2)/te

		//	pgreater1 = 1 - normal((noint1)/(nointse1))
		//	pless1 = normal((noint1)/(nointse1))
			ptwoside1 = 2*min((1- abs(normal((noint1)/(nointse1))), abs(normal((noint1)/(nointse1)))))
		//	pgreater2 = 1 - normal((noint2)/(nointse2))
		//	pless2 = normal((noint2)/(nointse2))
			ptwoside2 = 2*min((1- abs(normal((noint2)/(nointse2))), abs(normal((noint2)/(nointse2)))))
			ci1l=noint1-1.96*((nointse1))
			ci1u=noint1+1.96*((nointse1))
			ci2l=noint2-1.96*((nointse2))
			ci2u=noint2+1.96*((nointse2))
		//	pgreaterte = 1 - normal((te)/(tese))	//variable not used
		//	plesste = normal((te)/(tese))
			ptwosidete = (1-normal(abs((te)/(tese))))*2
			citel=te-1.96*(tese)
			citeu=te+1.96*(tese)
			value1=  noint1 , noint2
			se1= nointse1 ,nointse2
			pvalue1=  ptwoside1 , ptwoside2
			cil1=ci1l,ci2l
			ciu1=ci1u,ci2u
			x1= value1',se1',pvalue1',cil1',ciu1'
			value2=  te , pm
			se2= tese ,0
			pvalue2=  ptwosidete ,0
			cil2=citel,0
			ciu2=citeu,0
			x2= value2',se2',pvalue2',cil2',ciu2'
			x=x1 \ x2
			
		//	x
			
			st_matrix("results", x)
			st_local("rspec", "rspec(&-&&&&)")		//with r rows, r+2 characters if column headers are displayed
			st_local("rownames", `""cde=nde" nie "total effect" "proportion mediated""')										
			st_local("cspec", "cspec(& b %24s | %8.5f & %8.5f & %8.5f & %12.5f & %12.5f &)")
			st_local("colnames", `"Estimate s_e p-value "95% CI lower" "95% CI upper""')
		}	
	
	
		/**********************************************************************************/
		/*Part 2 yreg=linear mreg=logistic: #3
			effects, standard errors, confidence intervals and p-value interaction w/ c
		*/	
		//%if &interaction=true & &cvar^= %then %do
		if ((strlower(interaction)=="true") & (cvar!="")) {
			vars = st_data(., tokens(cvar))
			vb1 = mean(vars)
			cmean = vb1[1, cols(vb1)-nc+1::cols(vb1)]
			
			//%if &c^= %then %do
			if (c!="") {
				cvals = tokens(c)
				cc=strtoreal(cvals)		
			}
			//%end
			
			V1 = st_matrix("out1")
			theta = st_matrix("beta1")
			theta1 = theta[1,1]	
			theta2 = theta[1,2]
			theta3 = theta[1,3]
			
			V2 = st_matrix("out2")
			beta = st_matrix("beta2")
			beta0 = beta[1,cols(beta)]
			beta1 = beta[1,1]
			beta2 = beta[1,2::cols(beta)-1]		
	
			zero1=J(rows(V1),rows(V2),0)
			zero2=J(rows(V2),rows(V1),0)
			A= V2, zero2
			B= zero1, V1
			sigma= A \ B
			zero=0
			one1=1
	
			//%if &c^= %then %do
			if (c!="") {
				/*CONDITIONAL CDE*/
				int1=(theta1+theta3*m)*(a1-a0)
				/*CONDITIONAL NDE*/
				int2=(theta1+theta3*exp(beta0+beta1*a0+sum(beta2*cc'))/(1+exp(beta0+beta1*a0+sum(beta2*cc'))))*(a1-a0)
				/*CONDITIONAL NIE*/
				int3=(theta2+theta3*a0)*(	///
					exp(beta0+beta1*a1+sum(beta2*cc'))/(1+exp(beta0+beta1*a1+sum(beta2*cc')))-	///
					exp(beta0+beta1*a0+sum(beta2*cc'))/(1+exp(beta0+beta1*a0+sum(beta2*cc'))))
				/*CONDITIONAL TNDE*/
				int4=(theta1+theta3*exp(beta0+beta1*a1+sum(beta2*cc'))/(1+exp(beta0+beta1*a1+sum(beta2*cc'))))*(a1-a0)
				/*CONDITIONAL TNIE*/
				int5=(theta2+theta3*a1)*(	///
					exp(beta0+beta1*a1+sum(beta2*cc'))/(1+exp(beta0+beta1*a1+sum(beta2*cc')))-	///
					exp(beta0+beta1*a0+sum(beta2*cc'))/(1+exp(beta0+beta1*a0+sum(beta2*cc'))))
			}
			//%end
	
			/*MARGINAL CDE*/
			int6=(theta1+theta3*m)*(a1-a0)
			/*MARGINAL NDE*/
			int7=(theta1+theta3*exp(beta0+beta1*a0+sum(beta2*cmean'))/(1+exp(beta0+beta1*a0+sum(beta2*cmean'))))*(a1-a0)
			/*MARGINAL NIE*/
			int8=(theta2+theta3*a0)*(	///
				exp(beta0+beta1*a1+sum(beta2*cmean'))/(1+exp(beta0+beta1*a1+sum(beta2*cmean')))-	///
				exp(beta0+beta1*a0+sum(beta2*cmean'))/(1+exp(beta0+beta1*a0+sum(beta2*cmean'))))
			/*MARGINAL TNDE*/
			int9=(theta1+theta3*exp(beta0+beta1*a1+sum(beta2*cmean'))/(1+exp(beta0+beta1*a1+sum(beta2*cmean'))))*(a1-a0)
			/*MARGINAL TNIE*/
			int10=(theta2+theta3*a1)*(exp(beta0+beta1*a1+sum(beta2*cmean'))/(1+exp(beta0+beta1*a1+sum(beta2*cmean')))-	///
				exp(beta0+beta1*a0+sum(beta2*cmean'))/(1+exp(beta0+beta1*a0+sum(beta2*cmean'))))
			
			/*te*/
			//%if &c^= %then %do
			if (c!="") {
				tecond=(theta1+theta3*(exp(beta0+beta1*a0+sum(beta2*cc'))/(1+exp(beta0+beta1*a0+sum(beta2*cc')))))*	///
					(a1-a0)+(theta2+theta3*a1)*(exp(beta0+beta1*a1+sum(beta2*cc'))/(1+exp(beta0+beta1*a1+sum(beta2*cc')))-	///
					exp(beta0+beta1*a0+sum(beta2*cc'))/(1+exp(beta0+beta1*a0+sum(beta2*cc'))))
				tecond = int2 + int5	
			}
			//%end
			
			temarg=(theta1+theta3*(exp(beta0+beta1*a0+sum(beta2*cmean'))/(1+exp(beta0+beta1*a0+sum(beta2*cmean')))))*	///
				(a1-a0)+(theta2+theta3*a1)*(exp(beta0+beta1*a1+sum(beta2*cmean'))/(1+exp(beta0+beta1*a1+sum(beta2*cmean')))-	///
				exp(beta0+beta1*a0+sum(beta2*cmean'))/(1+exp(beta0+beta1*a0+sum(beta2*cmean'))))
			temarg = int7 + int10	
			/*pm*/
			pm=(int10)/(temarg)
	
			z1=J(1,nc,0)
			z=zero,z1,zero, one1,zero
	
			//%if &c^= %then %do
			if (c!="") {
				condgammacde=z,m , z1, zero
				B=exp(beta0+beta1*a0+beta2*cc')		
				A=(1+B)
				d1=theta3*(A*B-B^2)/A^2
				d2=theta3*a0*(A*B-B^2)/A^2
				d3=theta3*cc*(A*B-B^2)/A^2
				d4=0
				d5=1
				d6=0
				d7=B/A
				d8=z1
				condgammapnde= d2 , d3, d1 ,  d5, d6, d7' , d8, d4
				B=exp(beta0+beta1*a1+beta2*cc')
				A=(1+B)
				d1=theta3*(A*B-B^2)/A^2
				d2=theta3*a1*(A*B-B^2)/A^2
				d3=theta3*cc*(A*B-B^2)/A^2
				d4=0
				d5=1
				d6=0
				d7=(B/A)'
				d8=z1
				condgammatnde=d2 , d3, d1 ,  d5, d6, d7 , d8, d4
			
				D=exp(beta0+beta1*a1+beta2*cc')
				X=(1+D)
				B=exp(beta0+beta1*a0+beta2*cc')		
				A=(1+B)								
				d1=(theta2+theta3*a1)*(((D*X-D^2)/X^2)-((A*B-B^2)/A^2))			
				d2=(theta2+theta3*a1)*((a1*(D*X-D^2)/X^2)-a0*((A*B-B^2)/A^2))	
				d3=cc*(theta2+theta3*a1)*(((D*X-D^2)/X^2)-((A*B-B^2)/A^2))		
				d4=0
				d5=0
				d6=(D/X-B/A)'
				d7=a1*d6
				d8=z1
				condgammatnie=d2 , d3 , d1,  d5, d6, d7 , d8, d4
				d1=(theta2+theta3*a0)*(((D*X-D^2)/X^2)-((A*B-B^2)/A^2))			
				d2=(theta2+theta3*a0)*((a1*(D*X-D^2)/X^2)-a0*((A*B-B^2)/A^2))	
				d3=cc*(theta2+theta3*a0)*(((D*X-D^2)/X^2)-((A*B-B^2)/A^2))		
				d4=0
				d5=0
				d6=(D/X-B/A)'
				d7=a0*d6
				d8=z1
				
				condgammapnie=d2 , d3 , d1, d5, d6, d7 , d8, d4
				/*cond se cde*/
				intse1=sqrt(condgammacde*sigma*condgammacde')* abs(a1-a0)
				/*cond se pnde*/
				intse2=sqrt(condgammapnde*sigma*condgammapnde')* abs(a1-a0)
				/*cond se pnie*/
				intse3=sqrt(condgammapnie*sigma*condgammapnie')
				/*cond se tnde*/
				intse4=sqrt(condgammatnde*sigma*condgammatnde')* abs(a1-a0)
				/*cond se tnie*/
				intse5=sqrt(condgammatnie*sigma*condgammatnie')
			}
			//%end
	
			marggammacde=z,m , z1, zero
			A=exp(beta0+beta1*a0+beta2*cmean')
			B=(1+A)
			x=theta3*(A*B-A^2)/B^2
			w=theta3*a0*(A*B-A^2)/B^2
			y=theta3*cmean*(A*B-A^2)/B^2
			h=A/B
			marggammapnde=  w , y , x, one1, zero, h' , z1, zero
			A=exp(beta0+beta1*a1+beta2*cmean')
			B=(1+A)
			x=theta3*(A*B-A^2)/B^2
			w=theta3*a1*(A*B-A^2)/B^2
			y=theta3*cmean*(A*B-A^2)/B^2
			h=A/B
		
			marggammatnde=w , y, x , one1, zero, h' , z1, zero

			D=exp(beta0+beta1*a1+beta2*cmean')
			E=(1+A)									
			E=(1+D)
			A=exp(beta0+beta1*a0+beta2*cmean')		
			B=(1+A)									
			x=(theta2+theta3*a1)*(((D*E-D^2)/E^2)-((A*B-A^2)/B^2))		
			w=(theta2+theta3*a1)*((a1*(D*E-D^2)/E^2)-a0*((A*B-A^2)/B^2))	
			y=(theta2+theta3*a1):*cmean:*(((D*E-D^2)/E^2):-((A*B-A^2)/B^2))	
			h=(D/E-A/B)'
			j=a1*h		
			marggammatnie=w, y, x, zero, h, j , z1, zero
			x=(theta2+theta3*a0)*(((D*E-D^2)/E^2)-((A*B-A^2)/B^2))			
			w=(theta2+theta3*a0)*((a1*(D*E-D^2)/E^2)-a0*((A*B-A^2)/B^2))	
			y=cmean*(theta2+theta3*a0)*(((D*E-D^2)/E^2):-((A*B-A^2)/B^2))	
			h=(D/E-A/B)'
			j=a0*h
			marggammapnie=w, y, x,  zero, h, j, z1, zero
			/*marg se cde*/
			intse6=sqrt(marggammacde*sigma*marggammacde')* abs(a1-a0)
			/*marg se pnde*/
			intse7=sqrt(marggammapnde*sigma*marggammapnde')* abs(a1-a0)
			/*marg se pnie*/
			intse8=sqrt(marggammapnie*sigma*marggammapnie')
			/*marg se tnde*/
			intse9=sqrt(marggammatnde*sigma*marggammatnde')* abs(a1-a0)
			/*marg se tnie*/
			intse10=sqrt(marggammatnie*sigma*marggammatnie')
	
			//%if c^= %then %do
			if (c!="") {
				A=exp(beta0+beta1*a0+beta2*cc')
				B=(1+A)
				D=exp(beta0+beta1*a1+beta2*cc')
				E=(1+D)
				x=theta3*(a1-a0)*(A*B-B^2)/(B^2)+(theta2+theta3*a1)*(((D*E-D^2)/(E^2))-((A*B-B^2)/(B^2)))
				w=a0*theta3*(a1-a0)*(A*B-B^2)/(B^2)+(theta2+theta3*a1)*(a1*((D*E-D^2)/(E^2))-a0*((A*B-B^2)/(B^2)))	
				y=theta3*cc*(a1-a0)*((A*B-B^2)/(B^2)):+(theta2+theta3*a1)*(((D*E-D^2)/(E^2))-((A*B-B^2)/(B^2)))		
				s=(a1-a0)
				t=(D/E-A/B)'
				r=(a1-a0)*(A/B)'+a1*t
				tegammacond=w,y,x, s,t,r,z1,zero
				/*se te*/
				tesecond=sqrt(tegammacond*sigma*tegammacond')
			}
			//%end
			
			A=exp(beta0+beta1*a0+beta2*cmean')
			B=(1+A)
			D=exp(beta0+beta1*a1+beta2*cmean')
			E=(1+D)
			x=theta3*(a1-a0)*(A*B-B^2)/(B^2)+(theta2+theta3*a1)*(((D*E-D^2)/(E^2))-((A*B-B^2)/(B^2)))
			w=a0*theta3*(a1-a0)*(A*B-B^2)/(B^2)+(theta2+theta3*a1)*(a1*((D*E-D^2)/(E^2))-a0*((A*B-B^2)/(B^2)))	
			y=theta3*cmean*(a1-a0)*((A*B-B^2)/(B^2)):+(theta2+theta3*a1)*(((D*E-D^2)/(E^2))-((A*B-B^2)/(B^2)))	
			s=(a1-a0)
			t=(D/E-A/B)'
			r=(a1-a0)*(A/B)'+a1*t
			tegammamarg=w,y,x, s,t,r,z1,zero
			/*se te*/
			tesemarg=sqrt(tegammamarg*sigma*tegammamarg')
	
			//%if c^= %then %do
			if (c!="") {
			//	pgreater1 = 1 - normal((int1)/(intse1))
			//	pless1 = normal((int1)/(intse1))
				ptwoside1 = 2*min((1- abs(normal((int1)/(intse1))), abs(normal((int1)/(intse1)))))
			//	pgreater2 = 1 - normal((int2)/(intse2))
			//	pless2 = normal((int2)/(intse2))
				ptwoside2 = 2*min((1- abs(normal((int2)/(intse2))), abs(normal((int2)/(intse2)))))
			//	pgreater3 = 1 - normal((int3)/(intse3))
			//	pless3 = normal((int3)/(intse3))
				ptwoside3 = 2*min((1- abs(normal((int3)/(intse3))), abs(normal((int3)/(intse3)))))
			//	pgreater4 = 1 - normal((int4)/(intse4))
			//	pless4 = normal((int4)/(intse4))
				ptwoside4 = 2*min((1- abs(normal((int4)/(intse4))), abs(normal((int4)/(intse4)))))
			//	pgreater5 = 1 - normal((int5)/(intse5))
			//	pless5 = normal((int5)/(intse5))
				ptwoside5 = 2*min((1- abs(normal((int5)/(intse5))), abs(normal((int5)/(intse5)))))
			}
			//%end
			
		//	pgreater6 = 1 - normal((int6)/(intse6))
		//	pless6 = normal((int6)/(intse6))
			ptwoside6 = 2*min((1- abs(normal((int6)/(intse6))), abs(normal((int6)/(intse6)))))
		//	pgreater7 = 1 - normal((int7)/(intse7))
		//	pless7 = normal((int7)/(intse7))
			ptwoside7 = 2*min((1- abs(normal((int7)/(intse7))), abs(normal((int7)/(intse7)))))
		//	pgreater8 = 1 - normal((int8)/(intse8))
		//	pless8 = normal((int8)/(intse8))
			ptwoside8 = 2*min((1- abs(normal((int8)/(intse8))), abs(normal((int8)/(intse8)))))
		//	pgreater9= 1 - normal((int9)/(intse9))
		//	pless9 = normal((int9)/(intse9))
			ptwoside9 = 2*min((1- abs(normal((int9)/(intse9))), abs(normal((int9)/(intse9)))))
		//	pgreater10 = 1 - normal((int10)/(intse10))
		//	pless10 = normal((int10)/(intse10))
			ptwoside10 = 2*min((1- abs(normal((int10)/(intse10))), abs(normal((int10)/(intse10)))))
	
			//%if &c^= %then %do
			if (c!="") {
				ci1l=int1-1.96*intse1
				ci1u=int1+1.96*intse1
				ci2l=int2-1.96*intse2
				ci2u=int2+1.96*intse2
				ci3l=int3-1.96*intse3
				ci3u=int3+1.96*intse3
				ci4l=int4-1.96*intse4
				ci4u=int4+1.96*intse4
				ci5l=int5-1.96*intse5
				ci5u=int5+1.96*intse5
			}
			//%end
			
			ci6l=int6-1.96*intse6
			ci6u=int6+1.96*intse6
			ci7l=int7-1.96*intse7
			ci7u=int7+1.96*intse7
			ci8l=int8-1.96*intse8
			ci8u=int8+1.96*intse8
			ci9l=int9-1.96*intse9
			ci9u=int9+1.96*intse9
			ci10l=int10-1.96*intse10
			ci10u=int10+1.96*intse10 
		//	pgreatertemarg = 1 - normal((temarg)/(tesemarg))
		//	plesstemarg = normal((temarg)/(tesemarg))
			ptwosidetemarg = (1-normal(abs((temarg)/(tesemarg))))*2
			citelmarg=temarg-1.96*tesemarg
			citeumarg=temarg+1.96*tesemarg
			
			//%if &c^= %then %do
			if (c!="") {
			//	pgreatertecond = 1 - normal((tecond)/(tesecond))
			//	plesstecond = normal((tecond)/(tesecond))
				ptwosidetecond = (1-normal( abs((tecond)/(tesecond))))*2
				citelcond=tecond-1.96*tesecond
				citeucond=tecond+1.96*tesecond
			}
			//%end
	
			//%if &output=full %then %do 
			if (strlower(output)=="full") {
				value1= int6, int7, int8, int9, int10, temarg, int1 , int2, int3, int4, int5, tecond, pm
				se1= intse6, intse7, intse8, intse9, intse10, tesemarg, intse1 , intse2, intse3, intse4, intse5, tesecond, 0
				pvalue1=  ptwoside6, ptwoside7, ptwoside8, ptwoside9, ptwoside10, ptwosidetemarg, ptwoside1 , ptwoside2, ptwoside3, ptwoside4, ptwoside5, ptwosidetecond, 0
				cil1=ci6l,ci7l,ci8l,ci9l,ci10l, citelmarg, ci1l,ci2l,ci3l,ci4l,ci5l, citelcond, 0
				ciu1=ci6u,ci7u,ci8u,ci9u,ci10u, citeumarg, ci1u,ci2u,ci3u,ci4u,ci5u, citeucond, 0
				x= value1' ,se1',pvalue1',cil1',ciu1' 
				
				st_matrix("results", x)
				st_local("rspec", "rspec(&-&&&&&&&&&&&&&)")		//with r rows, r+2 characters if column headers are displayed
				st_local("rownames", `""marginal cde"	"marginal pnde" "marginal pnie" "marginal tnde" "marginal tnie" "marginal total effect" "conditional cde" "conditional pnde" "conditional pnie" "conditional tnde" "conditional tnie" "conditional total effect" "proportion mediated""')	//v0.3g	
				st_local("cspec", "cspec(& b %24s | %8.5f & %8.5f & %8.5f & %12.5f & %12.5f &)")
				st_local("colnames", `"Estimate s_e p-value "95% CI lower" "95% CI upper""')					
			
			}
			//%end
	
			//%if &output^=full %then %do 
			if (strlower(output)!="full") {
				value1= int6 , int7, int10 
				se1= intse6,intse7,intse10
				pvalue1=ptwoside6 , ptwoside7, ptwoside10
				cil1=ci6l,ci7l,ci10l
				ciu1=ci6u,ci7u,ci10u
				x1= value1',se1',pvalue1',cil1',ciu1' 
				value2=  temarg , pm
				se2= tesemarg ,0
				pvalue2=  ptwosidetemarg , 0
				cil2=citelmarg,0
				ciu2=citeumarg,0
				x2= value2',se2',pvalue2',cil2',ciu2'
				x=x1 \ x2
	
				st_matrix("results", x)	
				st_local("rspec", "rspec(&-&&&&&)")		//with r rows, r+2 characters if column headers are displayed
				st_local("rownames", `"cde nde nie "marginal total effect" "proportion mediated""')
				st_local("cspec", "cspec(& b %24s | %8.5f & %8.5f & %8.5f & %12.5f & %12.5f &)")
				st_local("colnames", `"Estimate s_e p-value "95% CI lower" "95% CI upper""')				
			}
			
	
		}
		
		/**********************************************************************************/
		/*Part 2 yreg=linear mreg=logistic: #4
			effects, standard errors, confidence intervals and p-value interaction w/o c
		*/	
		//%if &interaction=true & &cvar= %then %do
		
		if ((strlower(interaction)=="true") & (cvar=="")) {
	
			V1 = st_matrix("out1")
			theta = st_matrix("beta1")
			theta1 = theta[1,1]	
			theta2 = theta[1,2]
			theta3 = theta[1,3]
			
			V2 = st_matrix("out2")
			beta = st_matrix("beta2")
			beta0 = beta[1,cols(beta)]
			beta1 = beta[1,1]
	
			zero1=J(rows(V1),rows(V2),0)
			zero2=J(rows(V2),rows(V1),0)
			A= V2, zero2
			B= zero1, V1
			sigma= A \ B
			zero=0
			one1=1
	
			/*CONDITIONAL=MARGINAL CDE*/
			int1=(theta1+theta3*m)*(a1-a0)
			/*CONDITIONAL=MARGINAL  NDE*/
			int2=(theta1+theta3*exp(beta0+beta1*a0)/(1+exp(beta0+beta1*a0)))*(a1-a0)
			/*CONDITIONAL=MARGINAL  NIE*/
			int3=(theta2+theta3*a0)*((exp(beta0+beta1*a1))/(1+exp(beta0+beta1*a1))-exp(beta0+beta1*a0)/(1+exp(beta0+beta1*a0)))	
			/*CONDITIONAL=MARGINAL  TNDE*/
			int4=(theta1+theta3*exp(beta0+beta1*a1)/(1+exp(beta0+beta1*a1)))*(a1-a0)
			/*CONDITIONAL=MARGINAL  TNIE*/
			int5=(theta2+theta3*a1)*(exp(beta0+beta1*a1)/(1+exp(beta0+beta1*a1))-exp(beta0+beta1*a0)/(1+exp(beta0+beta1*a0)))
			/*te*/
			te = int5 + int2	
			/*pm*/
			pm=(int5)/(te)
			z=zero,zero, one1,zero
			condgammacde=z,m,zero
			A=exp(beta0+beta1*a0)
			B=(1+A)
			x=theta3*(A*B-A^2)/B^2
			w=theta3*a0*(A*B-A^2)/B^2
			h=A/B
			condgammapnde= w, x,  one1, zero, h', zero
			A=exp(beta0+beta1*a1)
			B=(1+A)
			x=theta3*(A*B-A^2)/B^2
			w=theta3*a1*(A*B-A^2)/B^2
			h=A/B
			condgammatnde=w, x,  one1, zero, h', zero
			D=exp(beta0+beta1*a1)
			E=(1+D)					
			A=exp(beta0+beta1*a0)	
			B=(1+A)					
			x=(theta2+theta3*a1)*(((D*E-D^2)/E^2)-((A*B-A^2)/B^2))			
			w=(theta2+theta3*a1)*((a1*(D*E-D^2)/E^2)-a0*((A*B-A^2)/B^2))	
			h=(D/E-A/B)'
			j=a1*h
			condgammatnie=w, x,  zero, h, j, zero 
			x=(theta2+theta3*a0)*(((D*E-D^2)/E^2)-((A*B-A^2)/B^2))			
			w=(theta2+theta3*a0)*((a1*(D*E-D^2)/E^2)-a0*((A*B-A^2)/B^2))	
			h=(D/E-A/B)'
			j=a0*h
			condgammapnie=w, x,  zero, h, j, zero
			/*cond se cde*/
			intse1=sqrt(condgammacde*sigma*condgammacde')* abs(a1-a0)
			/*cond se pnde*/
			intse2=sqrt(condgammapnde*sigma*condgammapnde')* abs(a1-a0)
			/*cond se pnie*/
			intse3=sqrt(condgammapnie*sigma*condgammapnie')
			/*cond se tnde*/
			intse4=sqrt(condgammatnde*sigma*condgammatnde')* abs(a1-a0)
			/*cond se tnie*/
			intse5=sqrt(condgammatnie*sigma*condgammatnie')
			A=exp(beta0+beta1*a0)
			B=(1+A)
			D=exp(beta0+beta1*a1)
			E=(1+D)
			x=theta3*(a1-a0)*(A*B-B^2)/(B^2)+(theta2+theta3*a1)*(((D*E-D^2)/(E^2))-((A*B-B^2)/(B^2)))
			w=a0*theta3*(a1-a0)*(A*B-B^2)/(B^2)+(theta2+theta3*a1)*(a1*((D*E-D^2)/(E^2))-a0*((A*B-B^2)/(B^2)))	
			s=(a1-a0)
			t=(D/E-A/B)'
			r=(a1-a0)*(A/B)'+a1*t
			tegamma=w,x, s,t,r,zero
			/*se te*/
			tese=sqrt(tegamma*sigma*tegamma')
		//	pgreater1 = 1 - normal((int1)/(intse1))
		//	pless1 = normal((int1)/(intse1))
			ptwoside1 = 2*min((1- abs(normal((int1)/(intse1))), abs(normal((int1)/(intse1)))))
		//	pgreater2 = 1 - normal((int2)/(intse2))
		//	pless2 = normal((int2)/(intse2))
			ptwoside2 = 2*min((1- abs(normal((int2)/(intse2))), abs(normal((int2)/(intse2)))))
		//	pgreater3 = 1 - normal((int3)/(intse3))
		//	pless3 = normal((int3)/(intse3))
			ptwoside3 = 2*min((1- abs(normal((int3)/(intse3))), abs(normal((int3)/(intse3)))))
		//	pgreater4 = 1 - normal((int4)/(intse4))
		//	pless4 = normal((int4)/(intse4))
			ptwoside4 = 2*min((1- abs(normal((int4)/(intse4))), abs(normal((int4)/(intse4)))))
		//	pgreater5 = 1 - normal((int5)/(intse5))
		//	pless5 = normal((int5)/(intse5))
			ptwoside5 = 2*min((1- abs(normal((int5)/(intse5))), abs(normal((int5)/(intse5)))))
			ci1l=int1-1.96*intse1
			ci1u=int1+1.96*intse1
			ci2l=int2-1.96*intse2
			ci2u=int2+1.96*intse2
			ci3l=int3-1.96*intse3
			ci3u=int3+1.96*intse3
			ci4l=int4-1.96*intse4
			ci4u=int4+1.96*intse4
			ci5l=int5-1.96*intse5
			ci5u=int5+1.96*intse5
		//	pgreaterte = 1 - normal((te)/(tese))	//variable not used
		//	plesste = normal((te)/(tese))
			ptwosidete = (1-normal(abs((te)/(tese))))*2
			citel=te-1.96*tese
			citeu=te+1.96*tese
	
			//%if &output=full %then %do 
			if (strlower(output) == "full") {
				value1= int1 , int2, int3, int4, int5
				se1= intse1 , intse2, intse3, intse4, intse5
				pvalue1=  ptwoside1 , ptwoside2, ptwoside3, ptwoside4, ptwoside5
				cil1=ci1l,ci2l,ci3l,ci4l,ci5l
				ciu1=ci1u,ci2u,ci3u,ci4u,ci5u
				x1= value1',se1',pvalue1',cil1',ciu1'
				value2=  te , pm
				se2= tese ,0
				pvalue2=  ptwosidete , 0
				cil2=citel,0
				ciu2=citeu,0
				x2= value2',se2',pvalue2',cil2',ciu2' 
				x=x1 \ x2
				
				st_matrix("results", x)	
				st_local("rspec", "rspec(&-&&&&&&&)")		//with r rows, r+2 characters if column headers are displayed
				st_local("rownames", `"cde pnde pnie tnde tnie "total effect" "proportion mediated""')								
				st_local("cspec", "cspec(& b %24s | %8.5f & %8.5f & %8.5f & %12.5f & %12.5f &)")
				st_local("colnames", `"Estimate s_e p-value "95% CI lower" "95% CI upper""')
			}
	
			//%if &output^=full %then %do 
			if (strlower(output)!="full") {
				value1= int1 , int2, int5 
				se1= intse1,intse2,intse5
				pvalue1=ptwoside1 , ptwoside2, ptwoside5
				cil1=ci1l,ci2l,ci5l
				ciu1=ci1u,ci2u,ci5u
				x1= value1',se1',pvalue1',cil1',ciu1' 
				value2=  te , pm
				se2= tese ,0
				pvalue2=  ptwosidete , 0
				cil2=citel,0
				ciu2=citeu,0
				x2= value2',se2',pvalue2',cil2',ciu2' 
				x=x1 \ x2

				st_matrix("results", x)	
				st_local("rspec", "rspec(&-&&&&&)")		//with r rows, r+2 characters if column headers are displayed
				st_local("rownames", `"cde nde nie "marginal total effect" "proportion mediated""')			
				st_local("cspec", "cspec(& b %24s | %8.5f & %8.5f & %8.5f & %12.5f & %12.5f &)")
				st_local("colnames", `"Estimate s_e p-value "95% CI lower" "95% CI upper""')
			}	
			//%end	
			
		//	x
		}
	}	
	
	
	if (((strlower(yreg)=="logistic") | (strlower(yreg)=="loglinear") | (strlower(yreg)=="poisson") | (strlower(yreg)=="negbin")) & (strlower(mreg)=="logistic")) {
		/**********************************************************************************/
		/*Part 3 yreg=logistic/loglinear/poisson/negbin mreg=logistic: #1
			effects, standard errors, confidence intervals and p-value no interaction w/ c
		*/	
		//%if &interaction=false & &cvar^= %then %do
		if ((strlower(interaction)=="false") & (strlower(cvar)!="")) {
			vars = st_data(., tokens(cvar))
			vb1 = mean(vars)
			cmean = vb1[1, cols(vb1)-nc+1::cols(vb1)]
			
			//%if &c^= %then %do
			if (c!="") {
				cvals = tokens(c)
				cc=strtoreal(cvals)		
			}
			//%end
			
			V1 = st_matrix("out1")
			theta = st_matrix("beta1")
			theta1 = theta[1,1]	
			theta2 = theta[1,2]
			
			V2 = st_matrix("out2")
			beta = st_matrix("beta2")
			beta0 = beta[1,cols(beta)]
			beta1 = beta[1,1]
			beta2 = beta[1,2::cols(beta)-1]		
	
			zero1=J(rows(V1),rows(V2),0)
			zero2=J(rows(V2),rows(V1),0)
			A= V2, zero2
			B= zero1, V1
			sigma= A \ B
			zero=0
			one1=1

			z1=J(1,nc,0)
			
			z=zero,z1,zero, one1,zero
			
			//%if &c^= %then %do
			if (c!="") {
				condgammacde=z,z1,zero
				
				A=exp(theta2+beta0+beta1*a0+beta2*cc')
				B=(1+exp(theta2+beta0+beta1*a0+beta2*cc'))
				D=exp(theta2+beta0+beta1*a0+beta2*cc')
				E=(1+exp(theta2+beta0+beta1*a0+beta2*cc'))
				d1cnde=A/B-D/E
				d2cnde=a0*(d1cnde)
				d3cnde=(d1cnde)*(cc)
				d4cnde=0
				d5cnde=(a1-a0)
				d6cnde=d1cnde
				d7cnde=z1
				condgammapnde= d2cnde,d3cnde,d1cnde,  d5cnde,d6cnde,d7cnde,d4cnde
				A=exp(theta2+beta0+beta1*a1+beta2*cc')
				B=(1+exp(theta2+beta0+beta1*a1+beta2*cc'))
				D=exp(theta2+beta0+beta1*a1+beta2*cc')
				E=(1+exp(theta2+beta0+beta1*a1+beta2*cc'))
				s=A/B-D/E
				x=a1*(s)
				w=(s)*(cc)
				t=(a1-a0)
				condgammatnde=x, w, s,  t,s,z1,zero
				A=exp(theta2+beta0+beta1*a1+beta2*cc')
				B=(1+exp(theta2+beta0+beta1*a1+beta2*cc'))
				D=exp(theta2+beta0+beta1*a0+beta2*cc')
				E=(1+exp(theta2+beta0+beta1*a0+beta2*cc'))
				F=exp(beta0+beta1*a0+beta2*cc')
				G=(1+exp(beta0+beta1*a0+beta2*cc'))
				H=exp(beta0+beta1*a1+beta2*cc')
				I=(1+exp(beta0+beta1*a1+beta2*cc'))
				d1cnie=F/G-H/I+A/B-D/E
				d2cnie=a0*F/G-a1*H/I+a1*A/B-a1*D/E
				d3cnie=cc*(d1cnie)
				d4cnie=0
				d5cnie=0
				d6cnie=(A/B-D/E)
				d7cnie=z1
				condgammatnie=d2cnie,d3cnie,d1cnie,  d5cnie,d6cnie,d7cnie,d4cnie
				A=exp(theta2+beta0+beta1*a1+beta2*cc')
				B=(1+exp(theta2+beta0+beta1*a1+beta2*cc'))
				D=exp(theta2+beta0+beta1*a0+beta2*cc')
				E=(1+exp(theta2+beta0+beta1*a0+beta2*cc'))
				F=exp(beta0+beta1*a0+beta2*cc')
				G=(1+exp(beta0+beta1*a0+beta2*cc'))
				H=exp(beta0+beta1*a1+beta2*cc')
				I=(1+exp(beta0+beta1*a1+beta2*cc'))
				s=F/G-H/I+A/B-D/E
				x=a0*F/G-a1*H/I+a1*A/B-a1*D/E
				w=cc*(s)
				k=(A/B-D/E)
				condgammapnie=x, w, s,  zero,k,z1,zero
				/*cond se cde*/
				intse1=sqrt(condgammacde*sigma*condgammacde')
				/*cond se pnde*/
				intse2=sqrt(condgammapnde*sigma*condgammapnde')
				/*cond se pnie*/
				intse3=sqrt(condgammapnie*sigma*condgammapnie')
				/*cond se tnde*/
				intse4=sqrt(condgammatnde*sigma*condgammatnde')
				/*cond se tnie*/
				intse5=sqrt(condgammatnie*sigma*condgammatnie')
			}
			//%end

			z=zero,z1,zero, one1,zero
			marggammacde=z, z1, zero
			A=exp(theta2+beta0+beta1*a0+beta2*cmean')
			B=(1+exp(theta2+beta0+beta1*a0+beta2*cmean'))
			D=exp(theta2+beta0+beta1*a0+beta2*cmean')
			E=(1+exp(theta2+beta0+beta1*a0+beta2*cmean'))
			d1nde=A/B-D/E
			d2nde=a0*(d1nde)
			d3nde=(d1nde)*(cmean)
			d4nde=0
			d5nde=(a1-a0)
			d6nde=d1nde
			d7nde=z1
			marggammapnde= d2nde, d3nde, d1nde,  d5nde,d6nde,d7nde,d4nde
			A=exp(theta2+beta0+beta1*a1+beta2*cmean')
			B=(1+exp(theta2+beta0+beta1*a1+beta2*cmean'))
			D=exp(theta2+beta0+beta1*a1+beta2*cmean')
			E=(1+exp(theta2+beta0+beta1*a1+beta2*cmean'))
			s=A/B-D/E
			x=a1*(s)
			w=(s)*(cmean)
			t=(a1-a0)
			marggammatnde=x, w, s,  t,s,z1,zero

			A=exp(theta2+beta0+beta1*a1+beta2*cmean')
			B=(1+exp(theta2+beta0+beta1*a1+beta2*cmean'))
			
			D=exp(theta2+beta0+beta1*a0+beta2*cmean')
			E=(1+exp(theta2+beta0+beta1*a0+beta2*cmean'))
			
			F=exp(beta0+beta1*a0+beta2*cmean')
			G=(1+exp(beta0+beta1*a0+beta2*cmean'))
			
			H=exp(beta0+beta1*a1+beta2*cmean')
			I=(1+exp(beta0+beta1*a1+beta2*cmean'))
			
			d1nie=F/G-H/I+A/B-D/E
			
			d2nie=a0*F/G-a1*H/I+a1*A/B-a1*D/E
			
			d3nie=cmean*(d1nie)
			
			d4nie=0
			d5nie=0
			d6nie=(A/B-D/E)
			d7nie=z1
			
			marggammatnie=d2nie, d3nie, d1nie,  d5nie,d6nie,d7nie,d4nie

			A=exp(theta2+beta0+beta1*a1+beta2*cmean')
			B=(1+exp(theta2+beta0+beta1*a1+beta2*cmean'))
			D=exp(theta2+beta0+beta1*a0+beta2*cmean')
			E=(1+exp(theta2+beta0+beta1*a0+beta2*cmean'))
			F=exp(beta0+beta1*a0+beta2*cmean')
			G=(1+exp(beta0+beta1*a0+beta2*cmean'))
			H=exp(beta0+beta1*a1+beta2*cmean')
			I=(1+exp(beta0+beta1*a1+beta2*cmean'))
			s=F/G-H/I+A/B-D/E
			x=a0*F/G-a1*H/I+a1*A/B-a1*D/E
			w=cmean*(s)
			k=(A/B-D/E)
			marggammapnie=x, w, s,  zero,k,z1,zero
			/*marg se cde*/
			intse6=sqrt(marggammacde*sigma*marggammacde')
			/*marg se pnde*/
			intse7=sqrt(marggammapnde*sigma*marggammapnde')
			/*marg se pnie*/
			intse8=sqrt(marggammapnie*sigma*marggammapnie')
			/*marg se tnde*/
			intse9=sqrt(marggammatnde*sigma*marggammatnde')
			/*marg se tnie*/
			intse10=sqrt(marggammatnie*sigma*marggammatnie')

			//%if &c^= %then %do
			if (c!="") {
				d1=(d1cnie+d1cnde)
				d2=(d2cnie+d2cnde)
				d3=(d3cnie+d3cnde)
				d4=zero
				d5=(d5cnie+d5cnde)
				d6=(d6cnie+d6cnde)
				tegammacond=d2,d3,d1, d5,d6,z1,zero
				tesecond=sqrt(tegammacond*sigma*tegammacond')* abs(a1-a0)
			}
			//%end
						
			d1=(d1nie+d1nde)
			d2=(d2nie+d2nde)
			d3=(d3nie+d3nde)
			d4=zero
			d5=(d5nie+d5nde)
			d6=(d6nie+d6nde)
			tegammamarg=d2,d3,d1, d5,d6,z1,zero
			tesemarg=sqrt(tegammamarg*sigma*tegammamarg')


			//%if &c^= %then %do
			if (c!="") {
				/*CONDITIONAL CDE*/
				x1=exp(theta1*(a1-a0))
				int1=x1
				/*CONDITIONAL NDE*/
				int2=exp((theta1)*(a1-a0))*(1+exp(theta2+beta0+beta1*a0+sum(beta2*cc')))/(1+exp(theta2+beta0+beta1*a0+sum(beta2*cc')))
				/*CONDITIONAL NIE*/
				int3=((1+exp(beta0+beta1*a0+beta2*cc'))*(1+exp(theta2+beta0+beta1*a1+sum(beta2*cc'))))/(	///
					(1+exp(beta0+beta1*a1+sum(beta2*cc')))*(1+exp(theta2+beta0+beta1*a0+sum(beta2*cc'))))
				/*CONDITIONAL TNDE*/
				int4=exp((theta1)*(a1-a0))*(1+exp(theta2+beta0+beta1*a1+sum(beta2*cc')))/(1+exp(theta2+beta0+beta1*a1+sum(beta2*cc')))
				/*CONDITIONAL TNIE*/
				int5=((1+exp(beta0+beta1*a0+sum(beta2*cc')))*(1+exp(theta2+beta0+beta1*a1+sum(beta2*cc'))))/(	///
					(1+exp(beta0+beta1*a1+sum(beta2*cc')))*(1+exp(theta2+beta0+beta1*a0+sum(beta2*cc'))))
			}
			//%end

			/*MARGINAL CDE*/
			x6=(theta1)*(a1-a0)
			int6=exp(x6)
			/*MARGINAL NDE*/
			int7=exp((theta1)*(a1-a0))*(1+exp(theta2+beta0+beta1*a0+sum(beta2*cmean')))/(1+exp(theta2+beta0+beta1*a0+sum(beta2*cmean')))
			/*MARGINAL NIE*/
			int8=((1+exp(beta0+beta1*a0+sum(beta2*cmean')))*(1+exp(theta2+beta0+beta1*a1+sum(beta2*cmean'))))/(	///
				(1+exp(beta0+beta1*a1+sum(beta2*cmean')))*(1+exp(theta2+beta0+beta1*a0+sum(beta2*cmean'))))
			/*MARGINAL TNDE*/
			int9=exp((theta1)*(a1-a0))*(1+exp(theta2+beta0+beta1*a1+sum(beta2*cmean')))/(1+exp(theta2+beta0+beta1*a1+sum(beta2*cmean')))
			/*MARGINAL TNIE*/
			int10=((1+exp(beta0+beta1*a0+sum(beta2*cmean')))*(1+exp(theta2+beta0+beta1*a1+sum(beta2*cmean'))))/(	///
				(1+exp(beta0+beta1*a1+sum(beta2*cmean')))*(1+exp(theta2+beta0+beta1*a0+sum(beta2*cmean'))))
			
			//%if &c^= %then %do
			if (c!="") {
				tecond=(int2)*(int5)
				logtecond=log(tecond)
			}
			//%end

			temarg=(int7)*(int10)
			logtemarg=log(temarg)
			
			pm=(int7)*((int10)-1)/((int7)*(int10)-1)
			//%if &c^= %then %do
			if (c!="") {
				log1=log(int1)
				log2=log(int2)
				log3=log(int3)
				log4=log(int4)
				log5=log(int5)
			}
			//%end
			
			log6=log(int6)
			log7=log(int7)
			log8=log(int8)
			log9=log(int9)
			log10=log(int10)
			
			//%if &c^= %then %do
			if (c!="") {
				cl1=log1-1.96*intse1
				cu1=log1+1.96*intse1
				cl2=log2-1.96*intse2
				cu2=log2+1.96*intse2
				cl3=log3-1.96*intse3
				cu3=log3+1.96*intse3
				cl4=log4-1.96*intse4
				cu4=log4+1.96*intse4
				cl5=log5-1.96*intse5
				cu5=log5+1.96*intse5
			}
			//%end
			
			cl6=log6-1.96*intse6
			cu6=log6+1.96*intse6
			cl7=log7-1.96*intse7
			cu7=log7+1.96*intse7
			cl8=log8-1.96*intse8
			cu8=log8+1.96*intse8
			cl9=log9-1.96*intse9
			cu9=log9+1.96*intse9
			cl10=log10-1.96*intse10
			cu10=log10+1.96*intse10
			
			//%if &c^= %then %do
			if (c!="") {
			//	pgreater1 = 1 - normal((log1)/(intse1))
			//	pless1 = normal((log1)/(intse1))
				ptwoside1 = 2*min((1- abs(normal((log1)/(intse1))), abs(normal((log1)/(intse1)))))
			//	pgreater2 = 1 - normal((log2)/(intse2))
			//	pless2 = normal((log2)/(intse2))
				ptwoside2 = 2*min((1- abs(normal((log2)/(intse2))), abs(normal((log2)/(intse2)))))
			//	pgreater3 = 1 - normal((int3)/(intse3))
			//	pless3 = normal((log3)/(intse3))
				ptwoside3 = 2*min((1- abs(normal((log3)/(intse3))), abs(normal((log3)/(intse3)))))
			//	pgreater4 = 1 - normal((log4)/(intse4))
			//	pless4 = normal((log4)/(intse4))
				ptwoside4 = 2*min((1- abs(normal((log4)/(intse4))), abs(normal((log4)/(intse4)))))
			//	pgreater5 = 1 - normal((log5)/(intse5))
			//	pless5 = normal((log5)/(intse5))
				ptwoside5 = 2*min((1- abs(normal((log5)/(intse5))), abs(normal((log5)/(intse5)))))
			}
			//%end
			
		//	pgreater6 = 1 - normal((log6)/(intse6))
		//	pless6 = normal((log6)/(intse6))
			ptwoside6 = 2*min((1- abs(normal((log6)/(intse6))), abs(normal((log6)/(intse6)))))
		//	pgreater7 = 1 - normal((log7)/(intse7))
		//	pless7 = normal((log7)/(intse7))
			ptwoside7 = 2*min((1- abs(normal((log7)/(intse7))), abs(normal((log7)/(intse7)))))
		//	pgreater8 = 1 - normal((log8)/(intse8))
		//	pless8 = normal((log8)/(intse8))
			ptwoside8 = 2*min((1- abs(normal((log8)/(intse8))), abs(normal((log8)/(intse8)))))
		//	pgreater9= 1 - normal((log9)/(intse9))
		//	pless9 = normal((log9)/(intse9))
			ptwoside9 = 2*min((1- abs(normal((log9)/(intse9))), abs(normal((log9)/(intse9)))))
		//	pgreater10 = 1 - normal((log10)/(intse10))
		//	pless10 = normal((log10)/(intse10))
			ptwoside10 = 2*min((1- abs(normal((log10)/(intse10))), abs(normal((log10)/(intse10)))))

			//%if &c^= %then %do
			if (c!="") {
				ci1l=exp(cl1)
				ci1u=exp(cu1)
				ci2l=exp(cl2)
				ci2u=exp(cu2)
				ci3l=exp(cl3)
				ci3u=exp(cu3)
				ci4l=exp(cl4)
				ci4u=exp(cu4)
				ci5l=exp(cl5)
				ci5u=exp(cu5)
			}
			//%end
			
			ci6l=exp(cl6)
			ci6u=exp(cu6)
			ci7l=exp(cl7)
			ci7u=exp(cu7)
			ci8l=exp(cl8)
			ci8u=exp(cu8)
			ci9l=exp(cl9)
			ci9u=exp(cu9)
			ci10l=exp(cl10)
			ci10u=exp(cu10)
		//	pgreatertemarg = 1 - normal((logtemarg)/(tesemarg))
		//	plesstemarg = normal((logtemarg)/(tesemarg))
			ptwosidetemarg = 2*min((1- abs(normal((logtemarg)/(tesemarg))), abs(normal((logtemarg)/(tesemarg)))))
			citelmarg=exp(logtemarg-1.96*tesemarg)
			citeumarg=exp(logtemarg+1.96*tesemarg)


			//%if &c^= %then %do
			if (c!="") {
			//	pgreatertecond = 1 - normal((logtecond)/(tesecond))
			//	plesstecond = normal((logtecond)/(tesecond))
				ptwosidetecond = 2*min((1- abs(normal((logtecond)/(tesecond))), abs(normal((logtecond)/(tesecond)))))
				citelcond=exp(logtecond-1.96*tesecond)
				citeucond=exp(logtecond+1.96*tesecond)
			}
			//%end
			
			//%if &output=full %then %do 
			if (strlower(output)=="full") {
				value1= int6, int7, int8, int9, int10, temarg, int1 , int2, int3, int4, int5, tecond, pm
				se1= intse6, intse7, intse8, intse9, intse10, tesemarg, intse1 , intse2, intse3, intse4, intse5, tesecond, 0
				pvalue1=  ptwoside6, ptwoside7, ptwoside8, ptwoside9, ptwoside10, ptwosidetemarg, ptwoside1 , ptwoside2, ptwoside3, ptwoside4, ptwoside5, ptwosidetecond, 0
				cil1=ci6l,ci7l,ci8l,ci9l,ci10l, citelmarg, ci1l,ci2l,ci3l,ci4l,ci5l, citelcond, 0
				ciu1=ci6u,ci7u,ci8u,ci9u,ci10u, citeumarg, ci1u,ci2u,ci3u,ci4u,ci5u, citeucond, 0
				x= value1' ,se1',pvalue1',cil1',ciu1' 
				
					st_matrix("results", x)
					st_local("rspec", "rspec(&-&&&&&&&&&&&&&)")		//with r rows, r+2 characters if column headers are displayed
					st_local("rownames", `""marginal cde"	"marginal pnde" "marginal pnie" "marginal tnde" "marginal tnie" "marginal total effect" "conditional cde" "conditional pnde" "conditional pnie" "conditional tnde" "conditional tnie" "conditional total effect" "proportion mediated""')	//v0.3g	
				st_local("cspec", "cspec(& b %24s | %8.5f & %8.5f & %8.5f & %12.5f & %12.5f &)")	//v0.3c Oct 2011
				st_local("colnames", `"Estimate s_e p-value "95% CI lower" "95% CI upper""')	//v0.3c Oct 2011		

			}
			//%end
			
			//%if &output^=full %then %do 
			if (strlower(output)!="full") {
				value1= int6 , int7, int10 
				se1= intse6,intse7,intse10
				pvalue1=ptwoside6 , ptwoside7, ptwoside10
				cil1=ci6l,ci7l,ci10l
				ciu1=ci6u,ci7u,ci10u
				x1= value1',se1',pvalue1',cil1',ciu1'	
				value2=  temarg , pm
				se2= tesemarg ,0
				pvalue2=  ptwosidetemarg , 0
				cil2=citelmarg,0
				ciu2=citeumarg,0
				x2= value2',se2',pvalue2',cil2',ciu2'	
				x=x1 \ x2
				
				st_matrix("results", x)	
				st_local("rspec", "rspec(&-&&&&&)")		//with r rows, r+2 characters if column headers are displayed
				st_local("rownames", `"cde nde nie "marginal total effect" "proportion mediated""')
				st_local("cspec", "cspec(& b %24s | %8.5f & %8.5f & %8.5f & %12.5f & %12.5f &)")	
				st_local("colnames", `"Estimate s_e p-value "95% CI lower" "95% CI upper""')			
			}
			//%end
			
		
		}
	
	
		/**********************************************************************************/
		/*Part 3 yreg=logistic/loglinear/poisson/negbin mreg=logistic: #2
			effects, standard errors, confidence intervals and p-value no interaction w/o c
		*/	
		//%if &interaction=false & &cvar^= %then %do
		if ((strlower(interaction)=="false") & (strlower(cvar)=="")) {
			
			V1 = st_matrix("out1")
			theta = st_matrix("beta1")
			theta1 = theta[1,1]	
			theta2 = theta[1,2]
			
			V2 = st_matrix("out2")
			beta = st_matrix("beta2")
			beta0 = beta[1,cols(beta)]
			beta1 = beta[1,1]
	
			zero1=J(rows(V1),rows(V2),0)
			zero2=J(rows(V2),rows(V1),0)
			A= V2, zero2
			B= zero1, V1
			sigma= A \ B
			zero=0
			one1=1

			z=zero,zero, one1,zero,zero
			condgammacde=z
			A=exp(theta2+beta0+beta1*a0)
			B=(1+exp(theta2+beta0+beta1*a0))
			D=exp(theta2+beta0+beta1*a0)
			E=(1+exp(theta2+beta0+beta1*a0))
			d1nde=A/B-D/E
			d2nde=a0*(d1nde)
			d3nde=0
			d4nde=(a1-a0)
			d5nde=d1nde
			condgammapnde=d2nde,d1nde, d4nde,d5nde,d3nde
			A=exp(theta2+beta0+beta1*a1)
			B=(1+exp(theta2+beta0+beta1*a1))
			D=exp(theta2+beta0+beta1*a1)
			E=(1+exp(theta2+beta0+beta1*a1))
			s=A/B-D/E
			x=a1*(s)
			t=(a1-a0)
			condgammatnde=x,s, t,s,zero
			A=exp(theta2+beta0+beta1*a1)
			B=(1+exp(theta2+beta0+beta1*a1))
			D=exp(theta2+beta0+beta1*a0)
			E=(1+exp(theta2+beta0+beta1*a0))
			F=exp(beta0+beta1*a0)
			G=(1+exp(beta0+beta1*a0))
			H=exp(beta0+beta1*a1)
			I=(1+exp(beta0+beta1*a1))
			d1nie=F/G-H/I+A/B-D/E
			d2nie=a0*F/G-a1*H/I+a1*A/B-a0*D/E	
			d3nie=0
			d4nie=0
			d5nie=(A/B-D/E)
			condgammatnie=d2nie,d1nie, d4nie,d5nie,d3nie
			A=exp(theta2+beta0+beta1*a1)
			B=(1+exp(theta2+beta0+beta1*a1))
			D=exp(theta2+beta0+beta1*a0)
			E=(1+exp(theta2+beta0+beta1*a0))
			F=exp(beta0+beta1*a0)
			G=(1+exp(beta0+beta1*a0))
			H=exp(beta0+beta1*a1)
			I=(1+exp(beta0+beta1*a1))
			s=F/G-H/I+A/B-D/E
			x=a1*F/G-a0*H/I+a0*A/B-a1*D/E	
			k=(A/B-D/E)
			condgammapnie=x,s, zero,k,zero
			/*cond se cde*/
			intse1=sqrt(condgammacde*sigma*condgammacde')
			/*cond se pnde*/
			intse2=sqrt(condgammapnde*sigma*condgammapnde')
			/*cond se pnie*/
			intse3=sqrt(condgammapnie*sigma*condgammapnie')
			/*cond se tnde*/
			intse4=sqrt(condgammatnde*sigma*condgammatnde')
			/*cond se tnie*/
			intse5=sqrt(condgammatnie*sigma*condgammatnie')
			d1=((d1nie)+(d1nde))
			d2=((d2nie)+(d2nde))
			d3=((d3nie)+(d3nde))
			d4=((d4nie)+(d4nde))
			d5=((d5nie)+(d5nde))
			tegamma=d2,d1, d4,d5,d3
			tese=sqrt(tegamma*sigma*tegamma')
			/*CONDITIONAL CDE*/
			x1=exp(theta1*(a1-a0))
			int1=x1
			/*CONDITIONAL NDE*/
			int2=exp((theta1)*(a1-a0))*(1+exp(theta2+beta0+beta1*a0))/(1+exp(theta2+beta0+beta1*a0))
			/*CONDITIONAL NIE*/
			int3=((1+exp(beta0+beta1*a0))*(1+exp(theta2+beta0+beta1*a1)))/(	///
				(1+exp(beta0+beta1*a1))*(1+exp(theta2+beta0+beta1*a0)))
			/*CONDITIONAL TNDE*/
			int4=exp((theta1)*(a1-a0))*(1+exp(theta2+beta0+beta1*a1))/(1+exp(theta2+beta0+beta1*a1))
			/*CONDITIONAL TNIE*/
			int5=((1+exp(beta0+beta1*a0))*(1+exp(theta2+beta0+beta1*a1)))/(	///
				(1+exp(beta0+beta1*a1))*(1+exp(theta2+beta0+beta1*a0)))
			
			te=(int2)*(int5)
			logte=log((int2)*(int5))
			pm=(int2)*((int5)-1)/((int2)*(int5)-1)
			log1=log(int1)
			log2=log(int2)
			log3=log(int3)
			log4=log(int4)
			log5=log(int5)
			cl1=log1-1.96*intse1
			cu1=log1+1.96*intse1
			cl2=log2-1.96*intse2
			cu2=log2+1.96*intse2
			cl3=log3-1.96*intse3
			cu3=log3+1.96*intse3
			cl4=log4-1.96*intse4
			cu4=log4+1.96*intse4
			cl5=log5-1.96*intse5
			cu5=log5+1.96*intse5
		//	pgreater1 = 1 - normal((log1)/(intse1))
		//	pless1 = normal((log1)/(intse1))
			ptwoside1 = 2*min((1- abs(normal((log1)/(intse1))), abs(normal((log1)/(intse1)))))
		//	pgreater2 = 1 - normal((log2)/(intse2))
		//	pless2 = normal((log2)/(intse2))
			ptwoside2 = 2*min((1- abs(normal((log2)/(intse2))), abs(normal((log2)/(intse2)))))
		//	pgreater3 = 1 - normal((int3)/(intse3))
		//	pless3 = normal((log3)/(intse3))
			ptwoside3 = 2*min((1- abs(normal((log3)/(intse3))), abs(normal((log3)/(intse3)))))
		//	pgreater4 = 1 - normal((log4)/(intse4))
		//	pless4 = normal((log4)/(intse4))
			ptwoside4 = 2*min((1- abs(normal((log4)/(intse4))), abs(normal((log4)/(intse4)))))
		//	pgreater5 = 1 - normal((log5)/(intse5))
		//	pless5 = normal((log5)/(intse5))
			ptwoside5 = 2*min((1- abs(normal((log5)/(intse5))), abs(normal((log5)/(intse5)))))
			ci1l=exp(cl1)
			ci1u=exp(cu1)
			ci2l=exp(cl2)
			ci2u=exp(cu2)
			ci3l=exp(cl3)
			ci3u=exp(cu3)
			ci4l=exp(cl4)
			ci4u=exp(cu4)
			ci5l=exp(cl5)
			ci5u=exp(cu5)
		//	pgreaterte = 1 - normal((logte)/(tese))	//variable not used
		//	plesste = normal((logte)/(tese))
			ptwosidete = 2*min((1- abs(normal((logte)/(tese))), abs(normal((logte)/(tese)))))
			citel=exp((logte)-1.96*(tese))
			citeu=exp((logte)+1.96*(tese))
			
			//%if &output=full %then %do 
			if (strlower(output)=="full") {
				value1= int1 , int2, int3, int4, int5
				se1= intse1 , intse2, intse3, intse4, intse5
				pvalue1=  ptwoside1 , ptwoside2, ptwoside3, ptwoside4, ptwoside5
				cil1=ci1l,ci2l,ci3l,ci4l,ci5l
				ciu1=ci1u,ci2u,ci3u,ci4u,ci5u
				x1= value1',se1',pvalue1',cil1',ciu1'	
				value2=  te , pm
				se2= tese ,0
				pvalue2=  ptwosidete , 0
				cil2=citel,0
				ciu2=citeu,0
				x2= value2',se2',pvalue2',cil2',ciu2'	
				x=x1 \ x2
				
				st_matrix("results", x)	
				st_local("rspec", "rspec(&-&&&&&&&)")		//with r rows, r+2 characters if column headers are displayed
				st_local("rownames", `"cde pnde pnie tnde tnie "total effect" "proportion mediated""')				
				st_local("cspec", "cspec(& b %24s | %8.5f & %8.5f & %8.5f & %12.5f & %12.5f &)")	
				st_local("colnames", `"Estimate s_e p-value "95% CI lower" "95% CI upper""')		
			}
			//%end
			
			//%if &output^=full %then %do 
			if (strlower(output)!="full") {
				value1= int1 , int2, int5 
				se1= intse1,intse2,intse5
				pvalue1=ptwoside1 , ptwoside2, ptwoside5
				cil1=ci1l,ci2l,ci5l
				ciu1=ci1u,ci2u,ci5u
				x1= value1',se1',pvalue1',cil1',ciu1'	
				value2=  te , pm
				se2= tese ,0
				pvalue2=  ptwosidete , 0
				cil2=citel,0
				ciu2=citeu,0
				x2= value2',se2',pvalue2',cil2',ciu2'	
				x=x1 \ x2

				st_matrix("results", x)	
				st_local("rspec", "rspec(&-&&&&&)")		//with r rows, r+2 characters if column headers are displayed
				st_local("rownames", `"cde nde nie "marginal total effect" "proportion mediated""')				
				st_local("cspec", "cspec(& b %24s | %8.5f & %8.5f & %8.5f & %12.5f & %12.5f &)")	
				st_local("colnames", `"Estimate s_e p-value "95% CI lower" "95% CI upper""')			
			}
			
		}

		/**********************************************************************************/
		/*Part 3 yreg=logistic/loglinear/poisson/negbin mreg=logistic: #3
			effects, standard errors, confidence intervals and p-value interaction w/ c
		*/	
		//%if &interaction=true & &cvar^= %then %do
		if ((strlower(interaction)=="true") & (strlower(cvar)!="")) {
			vars = st_data(., tokens(cvar))
			vb1 = mean(vars)
			cmean = vb1[1, cols(vb1)-nc+1::cols(vb1)]
			
			//%if &c^= %then %do
			if (c!="") {
				cvals = tokens(c)
				cc=strtoreal(cvals)		
			}
			//%end
			
			V1 = st_matrix("out1")
			theta = st_matrix("beta1")
			theta1 = theta[1,1]	
			theta2 = theta[1,2]
			theta3 = theta[1,3]
			
			V2 = st_matrix("out2")
			beta = st_matrix("beta2")
			beta0 = beta[1,cols(beta)]
			beta1 = beta[1,1]
			beta2 = beta[1,2::cols(beta)-1]	
	
			zero1=J(rows(V1),rows(V2),0)
			zero2=J(rows(V2),rows(V1),0)
			zeros=J(1,rows(V1)+rows(V2),0)
			A= V2, zero2
			B= zero1, V1
			sigma= A \ B
			zero=0
			one1=1

			z1=J(1,nc,0)
			z=zero,z1,zero, one1,zero
			
			//%if &c^= %then %do
			if (c!="") {
				condgammacde=z,m , z1, zero
				A=exp(theta2+theta3*a1+beta0+beta1*a0+beta2*cc')
				B=(1+exp(theta2+theta3*a1+beta0+beta1*a0+beta2*cc'))
				D=exp(theta2+theta3*a0+beta0+beta1*a0+beta2*cc')
				E=(1+exp(theta2+theta3*a0+beta0+beta1*a0+beta2*cc'))
				d1cnde=A/B-D/E
				d2cnde=a0*(d1cnde)
				d3cnde=(d1cnde)*(cc)
				d4cnde=0
				d5cnde=(a1-a0)
				d6cnde=A/B-D/E
				d7cnde=a1*A/B-a0*D/E
				d8cnde=z1
				condgammapnde= d2cnde, d3cnde, d1cnde,  d5cnde,d6cnde, d7cnde ,d8cnde,d4cnde
				A=exp(theta2+theta3*a1+beta0+beta1*a1+beta2*cc')
				B=(1+exp(theta2+theta3*a1+beta0+beta1*a1+beta2*cc'))
				D=exp(theta2+theta3*a0+beta0+beta1*a1+beta2*cc')
				E=(1+exp(theta2+theta3*a0+beta0+beta1*a1+beta2*cc'))
				d1=A/B-D/E
				d2=a1*(d1)
				d3=(d1)*(cc)
				d4=0
				d5=(a1-a0)
				d6=A/B-D/E
				d7=a1*A/B-a0*D/E
				d8=z1
				condgammatnde=d2, d3, d1,  d5,d6, d7 ,d8,d4
				A=exp(theta2+theta3*a1+beta0+beta1*a1+beta2*cc')
				B=(1+exp(theta2+theta3*a1+beta0+beta1*a1+beta2*cc'))
				D=exp(theta2+theta3*a1+beta0+beta1*a0+beta2*cc')
				E=(1+exp(theta2+theta3*a1+beta0+beta1*a0+beta2*cc'))
				F=exp(beta0+beta1*a0+beta2*cc')
				G=(1+exp(beta0+beta1*a0+beta2*cc'))
				H=exp(beta0+beta1*a1+beta2*cc')
				I=(1+exp(beta0+beta1*a1+beta2*cc'))
				d1cnie=F/G-H/I+A/B-D/E
				d2cnie=a0*F/G-a1*H/I+a1*A/B-a0*D/E
				d3cnie=cc*(d1cnie)
				d4cnie=0
				d5cnie=0
				d6cnie=A/B-D/E
				d7cnie=a1*(A/B-D/E)
				d8cnie=z1
				condgammatnie=d2cnie, d3cnie, d1cnie,  d5cnie,d6cnie, d7cnie ,d8cnie,d4cnie
				A=exp(theta2+theta3*a0+beta0+beta1*a1+beta2*cc')
				B=(1+exp(theta2+theta3*a0+beta0+beta1*a1+beta2*cc'))
				D=exp(theta2+theta3*a0+beta0+beta1*a0+beta2*cc')
				E=(1+exp(theta2+theta3*a0+beta0+beta1*a0+beta2*cc'))
				F=exp(beta0+beta1*a0+beta2*cc')
				G=(1+exp(beta0+beta1*a0+beta2*cc'))
				H=exp(beta0+beta1*a1+beta2*cc')
				I=(1+exp(beta0+beta1*a1+beta2*cc'))
				d1=F/G-H/I+A/B-D/E
				d2=a0*F/G-a1*H/I+a1*A/B-a0*D/E
				d3=cc*(d1)
				d4=0
				d5=0
				d6=A/B-D/E
				d7=a0*(A/B-D/E)
				d8=z1
				condgammapnie=d2, d3, d1,  d5,d6, d7 ,d8,d4
				/*cond se cde*/
				intse1=sqrt(condgammacde*sigma*condgammacde')
				/*cond se pnde*/
				intse2=sqrt(condgammapnde*sigma*condgammapnde')
				/*cond se pnie*/
				intse3=sqrt(condgammapnie*sigma*condgammapnie')
				/*cond se tnde*/
				intse4=sqrt(condgammatnde*sigma*condgammatnde')
				/*cond se tnie*/
				intse5=sqrt(condgammatnie*sigma*condgammatnie')
			}
			//%end
			
			z=zero,z1,zero, one1,zero
			marggammacde=z,m , z1, zero
			
			A=exp(theta2+theta3*a1+beta0+beta1*a0+beta2*cmean')
			B=(1+exp(theta2+theta3*a1+beta0+beta1*a0+beta2*cmean'))
			D=exp(theta2+theta3*a0+beta0+beta1*a0+beta2*cmean')
			E=(1+exp(theta2+theta3*a0+beta0+beta1*a0+beta2*cmean'))
			d1nde=A/B-D/E
			d2nde=a0*(d1nde)
			d3nde=(d1nde)*(cmean)
			d4nde=0
			d5nde=(a1-a0)
			d6nde=d1nde
			d7nde=a1*A/B-a0*D/E
			d8nde=z1
			marggammapnde= d2nde, d3nde, d1nde,  d5nde,d6nde, d7nde ,d8nde,d4nde

			A=exp(theta2+theta3*a1+beta0+beta1*a1+beta2*cmean')
			B=(1+exp(theta2+theta3*a1+beta0+beta1*a1+beta2*cmean'))
			D=exp(theta2+theta3*a0+beta0+beta1*a1+beta2*cmean')
			E=(1+exp(theta2+theta3*a0+beta0+beta1*a1+beta2*cmean'))
			s=A/B-D/E
			x=a1*(s)
			w=(s)*(cmean)
			t=(a1-a0)
			h=a1*A/B-a0*D/E
			marggammatnde=x, w, s,  t,s, h ,z1,zero
			
			A=exp(theta2+theta3*a1+beta0+beta1*a1+beta2*cmean')
			B=(1+exp(theta2+theta3*a1+beta0+beta1*a1+beta2*cmean'))
			D=exp(theta2+theta3*a1+beta0+beta1*a0+beta2*cmean')
			E=(1+exp(theta2+theta3*a1+beta0+beta1*a0+beta2*cmean'))
			F=exp(beta0+beta1*a0+beta2*cmean')
			G=(1+exp(beta0+beta1*a0+beta2*cmean'))
			H=exp(beta0+beta1*a1+beta2*cmean')
			I=(1+exp(beta0+beta1*a1+beta2*cmean'))
			d1nie=F/G-H/I+A/B-D/E
			d2nie=a0*F/G-a1*H/I+a1*A/B-a0*D/E
			d3nie=cmean*(d1nie)
			d4nie=0
			d5nie=0
			d6nie=A/B-D/E
			d7nie=a1*(A/B-D/E)
			d8nie=z1
			marggammatnie=d2nie, d3nie, d1nie,  d5nie,d6nie, d7nie ,d8nie,d4nie			
			
			A=exp(theta2+theta3*a0+beta0+beta1*a1+beta2*cmean')
			B=(1+exp(theta2+theta3*a0+beta0+beta1*a1+beta2*cmean'))
			D=exp(theta2+theta3*a0+beta0+beta1*a0+beta2*cmean')
			E=(1+exp(theta2+theta3*a0+beta0+beta1*a0+beta2*cmean'))
			F=exp(beta0+beta1*a0+beta2*cmean')
			G=(1+exp(beta0+beta1*a0+beta2*cmean'))
			H=exp(beta0+beta1*a1+beta2*cmean')
			I=(1+exp(beta0+beta1*a1+beta2*cmean'))
			s=F/G-H/I+A/B-D/E
			x=a0*F/G-a1*H/I+a1*A/B-a0*D/E
			w=cmean*(s)
			l=A/B-D/E
			k=a0*(A/B-D/E)
			marggammapnie=x, w, s,  zero,l, k ,z1,zero

			/*marg se cde*/
			intse6=sqrt(marggammacde*sigma*marggammacde')
			/*marg se pnde*/
			intse7=sqrt(marggammapnde*sigma*marggammapnde')
			/*marg se pnie*/
			intse8=sqrt(marggammapnie*sigma*marggammapnie')
			/*marg se tnde*/
			intse9=sqrt(marggammatnde*sigma*marggammatnde')
			/*marg se tnie*/
			intse10=sqrt(marggammatnie*sigma*marggammatnie')

			//%if &c^= %then %do
			if (c!="") {
				d1=((d1cnie)+(d1cnde))
				d2=((d2cnie)+(d2cnde))
				d3=((d3cnie)+(d3cnde))
				d4=((d4cnie)+(d4cnde))
				d5=((d5cnie)+(d5cnde))
				d6=((d6cnie)+(d6cnde))
				d7=((d7cnie)+(d7cnde))
				tegammacond=d2,d3,d1, d5,d6,d7,z1,d4
				tesecond=sqrt(tegammacond*sigma*tegammacond')
			}
			//%end
			
			d1=((d1nie)+(d1nde))
			d2=((d2nie)+(d2nde))
			d3=((d3nie)+(d3nde))
			d4=((d4nie)+(d4nde))
			d5=((d5nie)+(d5nde))
			d6=((d6nie)+(d6nde))
			d7=((d7nie)+(d7nde))
			tegammamarg=d2,d3,d1, d5,d6,d7,z1,d4
			tesemarg=sqrt(tegammamarg*sigma*tegammamarg')

			//%if &c^= %then %do
			if (c!="") {
				/*CONDITIONAL CDE*/
				x1=exp((theta1+theta3*m)*(a1-a0))
				int1=x1
				/*CONDITIONAL NDE*/
				int2=exp(theta1*(a1-a0))*(1+exp(theta2+theta3*a1+beta0+beta1*a0+sum(beta2*cc')))/(1+exp(theta2+theta3*a0+beta0+beta1*a0+sum(beta2*cc')))
				/*CONDITIONAL NIE*/
				int3=((1+exp(beta0+beta1*a0+sum(beta2*cc')))*(1+exp(theta2+theta3*a0+beta0+beta1*a1+sum(beta2*cc'))))/(	///
					(1+exp(beta0+beta1*a1+sum(beta2*cc')))*(1+exp(theta2+theta3*a0+beta0+beta1*a0+sum(beta2*cc'))))
				/*CONDITIONAL TNDE*/
				int4=exp(theta1*(a1-a0))*(1+exp(theta2+theta3*a1+beta0+beta1*a1+sum(beta2*cc')))/(1+exp(theta2+theta3*a0+beta0+beta1*a1+sum(beta2*cc')))
				/*CONDITIONAL TNIE*/
				int5=((1+exp(beta0+beta1*a0+sum(beta2*cc')))*(1+exp(theta2+theta3*a1+beta0+beta1*a1+sum(beta2*cc'))))/(	///
					(1+exp(beta0+beta1*a1+sum(beta2*cc')))*(1+exp(theta2+theta3*a1+beta0+beta1*a0+sum(beta2*cc'))))
			}
			//%end

			/*MARGINAL CDE*/
			x6=(theta1+theta3*m)*(a1-a0)
			int6=exp(x6)
			/*MARGINAL NDE*/
			int7=exp(theta1*(a1-a0))*(1+exp(theta2+theta3*a1+beta0+beta1*a0+sum(beta2*cmean')))/(1+exp(theta2+theta3*a0+beta0+beta1*a0+sum(beta2*cmean')))
			/*MARGINAL NIE*/
			int8=((1+exp(beta0+beta1*a0+sum(beta2*cmean')))*(1+exp(theta2+theta3*a0+beta0+beta1*a1+sum(beta2*cmean'))))/(	///
				(1+exp(beta0+beta1*a1+sum(beta2*cmean')))*(1+exp(theta2+theta3*a0+beta0+beta1*a0+sum(beta2*cmean'))))
			/*MARGINAL TNDE*/
			int9=exp(theta1*(a1-a0))*(1+exp(theta2+theta3*a1+beta0+beta1*a1+sum(beta2*cmean')))/(1+exp(theta2+theta3*a0+beta0+beta1*a1+sum(beta2*cmean')))
			/*MARGINAL TNIE*/
			int10=((1+exp(beta0+beta1*a0+sum(beta2*cmean')))*(1+exp(theta2+theta3*a1+beta0+beta1*a1+sum(beta2*cmean'))))/(	///
				(1+exp(beta0+beta1*a1+sum(beta2*cmean')))*(1+exp(theta2+theta3*a1+beta0+beta1*a0+sum(beta2*cmean'))))

			//%if &c^= %then %do
			if (c!="") {
				tecond=(int2)*(int5)
				logtecond=log((int2)*(int5))
			}
			//%end
			
			temarg=(int7)*(int10)
			logtemarg=log((int7)*(int10))
			pm=(int7)*((int10)-1)/((int7)*(int10)-1)
			
			//%if &c^= %then %do
			if (c!="") {
				log1=log(int1)
				log2=log(int2)
				log3=log(int3)
				log4=log(int4)
				log5=log(int5)
			}
			//%end
			
			log6=log(int6)
			log7=log(int7)
			log8=log(int8)
			log9=log(int9)
			log10=log(int10)
			
			//%if &c^= %then %do
			if (c!="") {
				cl1=log1-1.96*intse1
				cu1=log1+1.96*intse1
				cl2=log2-1.96*intse2
				cu2=log2+1.96*intse2
				cl3=log3-1.96*intse3
				cu3=log3+1.96*intse3
				cl4=log4-1.96*intse4
				cu4=log4+1.96*intse4
				cl5=log5-1.96*intse5
				cu5=log5+1.96*intse5
			}
			//%end

			cl6=log6-1.96*intse6
			cu6=log6+1.96*intse6
			cl7=log7-1.96*intse7
			cu7=log7+1.96*intse7
			cl8=log8-1.96*intse8
			cu8=log8+1.96*intse8
			cl9=log9-1.96*intse9
			cu9=log9+1.96*intse9
			cl10=log10-1.96*intse10
			cu10=log10+1.96*intse10
		//	pgreatertemarg = 1 - normal((logtemarg)/(tesemarg))
		//	plesstemarg = normal((logtemarg)/(tesemarg))
			ptwosidetemarg = 2*min((1- abs(normal((logtemarg)/(tesemarg))), abs(normal((logtemarg)/(tesemarg)))))
			citelmarg=exp(logtemarg-1.96*tesemarg)
			citeumarg=exp(logtemarg+1.96*tesemarg)
			
			//%if &c^= %then %do
			if (c!="") {
			//	pgreatertecond = 1 - normal((logtecond)/(tesecond))
			//	plesstecond = normal((logtecond)/(tesecond))
				ptwosidetecond = 2*min((1- abs(normal((logtecond)/(tesecond))), abs(normal((logtecond)/(tesecond)))))
				citelcond=exp(logtecond-1.96*tesecond)
				citeucond=exp(logtecond+1.96*tesecond)
			//	pgreater1 = 1 - normal((log1)/(intse1))
			//	pless1 = normal((log1)/(intse1))
				ptwoside1 = 2*min((1- abs(normal((log1)/(intse1))), abs(normal((log1)/(intse1)))))
			//	pgreater2 = 1 - normal((log2)/(intse2))
			//	pless2 = normal((log2)/(intse2))
				ptwoside2 = 2*min((1- abs(normal((log2)/(intse2))), abs(normal((log2)/(intse2)))))
			//	pgreater3 = 1 - normal((int3)/(intse3))
			//	pless3 = normal((log3)/(intse3))
				ptwoside3 = 2*min((1- abs(normal((log3)/(intse3))), abs(normal((log3)/(intse3)))))
			//	pgreater4 = 1 - normal((log4)/(intse4))
			//	pless4 = normal((log4)/(intse4))
				ptwoside4 = 2*min((1- abs(normal((log4)/(intse4))), abs(normal((log4)/(intse4)))))
			//	pgreater5 = 1 - normal((log5)/(intse5))
			//	pless5 = normal((log5)/(intse5))
				ptwoside5 = 2*min((1- abs(normal((log5)/(intse5))), abs(normal((log5)/(intse5)))))
			}
			//%end

		//	pgreater6 = 1 - normal((log6)/(intse6))
		//	pless6 = normal((log6)/(intse6))
			ptwoside6 = 2*min((1- abs(normal((log6)/(intse6))), abs(normal((log6)/(intse6)))))
		//	pgreater7 = 1 - normal((log7)/(intse7))
		//	pless7 = normal((log7)/(intse7))
			ptwoside7 = 2*min((1- abs(normal((log7)/(intse7))), abs(normal((log7)/(intse7)))))
		//	pgreater8 = 1 - normal((log8)/(intse8))
		//	pless8 = normal((log8)/(intse8))
			ptwoside8 = 2*min((1- abs(normal((log8)/(intse8))), abs(normal((log8)/(intse8)))))
		//	pgreater9= 1 - normal((log9)/(intse9))
		//	pless9 = normal((log9)/(intse9))
			ptwoside9 = 2*min((1- abs(normal((log9)/(intse9))), abs(normal((log9)/(intse9)))))
		//	pgreater10 = 1 - normal((log10)/(intse10))
		//	pless10 = normal((log10)/(intse10))
			ptwoside10 = 2*min((1- abs(normal((log10)/(intse10))), abs(normal((log10)/(intse10)))))

			//%if &c^= %then %do
			if (c!="") {
				ci1l=exp(cl1)
				ci1u=exp(cu1)
				ci2l=exp(cl2)
				ci2u=exp(cu2)
				ci3l=exp(cl3)
				ci3u=exp(cu3)
				ci4l=exp(cl4)
				ci4u=exp(cu4)
				ci5l=exp(cl5)
				ci5u=exp(cu5)
			}
			//%end
			
			ci6l=exp(cl6)
			ci6u=exp(cu6)
			ci7l=exp(cl7)
			ci7u=exp(cu7)
			ci8l=exp(cl8)
			ci8u=exp(cu8)
			ci9l=exp(cl9)
			ci9u=exp(cu9)
			ci10l=exp(cl10)
			ci10u=exp(cu10)

			//%if &output=full %then %do 
			if (strlower(output)=="full") {
				value1= int6, int7, int8, int9, int10, temarg, int1 , int2, int3, int4, int5, tecond, pm
				se1= intse6, intse7, intse8, intse9, intse10, tesemarg, intse1 , intse2, intse3, intse4, intse5, tesecond, 0
				pvalue1=  ptwoside6, ptwoside7, ptwoside8, ptwoside9, ptwoside10, ptwosidetemarg, ptwoside1 , ptwoside2, ptwoside3, ptwoside4, ptwoside5, ptwosidetecond, 0
				cil1=ci6l,ci7l,ci8l,ci9l,ci10l, citelmarg, ci1l,ci2l,ci3l,ci4l,ci5l, citelcond, 0
				ciu1=ci6u,ci7u,ci8u,ci9u,ci10u, citeumarg, ci1u,ci2u,ci3u,ci4u,ci5u, citeucond, 0
				x= value1' ,se1',pvalue1',cil1',ciu1' 
				
				st_matrix("results", x)
				st_local("rspec", "rspec(&-&&&&&&&&&&&&&)")		//with r rows, r+2 characters if column headers are displayed
				st_local("rownames", `""marginal cde"	"marginal pnde" "marginal pnie" "marginal tnde" "marginal tnie" "marginal total effect" "conditional cde" "conditional pnde" "conditional pnie" "conditional tnde" "conditional tnie" "conditional total effect" "proportion mediated""')	//v0.3g	
				st_local("cspec", "cspec(& b %24s | %8.5f & %8.5f & %8.5f & %12.5f & %12.5f &)")	//v0.3c Oct 2011
				st_local("colnames", `"Estimate s_e p-value "95% CI lower" "95% CI upper""')	//v0.3c Oct 2011		
			}
			//%end
			
			//%if &output^=full %then %do 
			if (strlower(output)!="full") {
				value1= int6 , int7, int10 
				se1= intse6,intse7,intse10
				pvalue1=ptwoside6 , ptwoside7, ptwoside10
				cil1=ci6l,ci7l,ci10l
				ciu1=ci6u,ci7u,ci10u
				x1= value1',se1',pvalue1',cil1',ciu1'	
				value2=  temarg , pm
				se2= tesemarg ,0
				pvalue2=  ptwosidetemarg , 0
				cil2=citelmarg,0
				ciu2=citeumarg,0
				x2= value2',se2',pvalue2',cil2',ciu2'	
				x=x1 \ x2

				st_matrix("results", x)	
				st_local("rspec", "rspec(&-&&&&&)")		//with r rows, r+2 characters if column headers are displayed
				st_local("rownames", `"cde nde nie "marginal total effect" "proportion mediated""')				
				st_local("cspec", "cspec(& b %24s | %8.5f & %8.5f & %8.5f & %12.5f & %12.5f &)")	
				st_local("colnames", `"Estimate s_e p-value "95% CI lower" "95% CI upper""')			
			}

			
		}
		//%end


		/**********************************************************************************/
		/*Part 3 yreg=logistic/loglinear/poisson/negbin mreg=logistic: #4
			effects, standard errors, confidence intervals and p-value interaction w/o c
		*/	
		//%if &interaction=true & &cvar= %then %do
		if ((strlower(interaction)=="true") & (strlower(cvar)=="")) {			
			V1 = st_matrix("out1")
			theta = st_matrix("beta1")
			theta1 = theta[1,1]	
			theta2 = theta[1,2]
			theta3 = theta[1,3]
			
			V2 = st_matrix("out2")
			beta = st_matrix("beta2")
			beta0 = beta[1,cols(beta)]
			beta1 = beta[1,1]
	
			zero1=J(rows(V1),rows(V2),0)
			zero2=J(rows(V2),rows(V1),0)
			A= V2, zero2
			B= zero1, V1
			zeros=J(1,rows(V1)+rows(V2),0)
			sigma= A \ B
			zero=0
			one1=1

			z=zero,zero, one1,zero
			condgammacde=z,m,zero
			A=exp(theta2+theta3*a1+beta0+beta1*a0)
			B=(1+exp(theta2+theta3*a1+beta0+beta1*a0))
			D=exp(theta2+theta3*a0+beta0+beta1*a0)
			E=(1+exp(theta2+theta3*a0+beta0+beta1*a0))
			d1nde=A/B-D/E
			d2nde=a0*(d1nde)
			d3nde=0
			d4nde=(a1-a0)
			d5nde=d1nde
			d6nde=a1*A/B-a0*D/E
			condgammapnde= d2nde, d1nde,  d4nde,d5nde,d6nde,d3nde
			A=exp(theta2+theta3*a1+beta0+beta1*a1)
			B=(1+exp(theta2+theta3*a1+beta0+beta1*a1))
			D=exp(theta2+theta3*a0+beta0+beta1*a1)
			E=(1+exp(theta2+theta3*a0+beta0+beta1*a1))
			s=A/B-D/E
			x=a1*(s)
			t=(a1-a0)
			h=a1*A/B-a0*D/E
			condgammatnde=x, s,  t,s, h,zero
			A=exp(theta2+theta3*a1+beta0+beta1*a1)
			B=(1+exp(theta2+theta3*a1+beta0+beta1*a1))
			D=exp(theta2+theta3*a1+beta0+beta1*a0)
			E=(1+exp(theta2+theta3*a1+beta0+beta1*a0))
			F=exp(beta0+beta1*a0)
			G=(1+exp(beta0+beta1*a0))
			H=exp(beta0+beta1*a1)
			I=(1+exp(beta0+beta1*a1))
			d1nie=F/G-H/I+A/B-D/E
			d2nie=a0*F/G-a1*H/I+a1*A/B-a0*D/E
			d3nie=0
			d4nie=0
			d5nie=A/B-D/E
			d6nie=a1*(A/B-D/E)
			condgammatnie=d2nie, d1nie,  d4nie,d5nie,d6nie,d3nie
			A=exp(theta2+theta3*a0+beta0+beta1*a1)
			B=(1+exp(theta2+theta3*a0+beta0+beta1*a1))
			D=exp(theta2+theta3*a0+beta0+beta1*a0)
			E=(1+exp(theta2+theta3*a0+beta0+beta1*a0))
			F=exp(beta0+beta1*a0)
			G=(1+exp(beta0+beta1*a0))
			H=exp(beta0+beta1*a1)
			I=(1+exp(beta0+beta1*a1))
			s=F/G-H/I+A/B-D/E
			x=a1*F/G-a0*H/I+a0*A/B-a1*D/E	
			l=A/B-D/E
			k=a0*(A/B-D/E)
			condgammapnie=x,s, zero,l, k,zero
			/*cond se cde*/
			intse1=sqrt(condgammacde*sigma*condgammacde')
			/*cond se pnde*/
			intse2=sqrt(condgammapnde*sigma*condgammapnde')
			/*cond se pnie*/
			intse3=sqrt(condgammapnie*sigma*condgammapnie')
			/*cond se tnde*/
			intse4=sqrt(condgammatnde*sigma*condgammatnde')
			/*cond se tnie*/
			intse5=sqrt(condgammatnie*sigma*condgammatnie')
			d1=(d1nie+d1nde)
			d2=(d2nie+d2nde)
			d3=(d3nie+d3nde)
			d4=(d4nie+d4nde)
			d5=(d5nie+d5nde)
			d6=(d6nie+d6nde)
			tegamma=d2,d1, d4,d5,d6,d3
			tese=sqrt(tegamma*sigma*tegamma')

			/*CONDITIONAL CDE*/
			x1=exp((theta1+theta3*m)*(a1-a0))
			int1=x1
			/*CONDITIONAL NDE*/
			int2=exp(theta1*(a1-a0))*(1+exp(theta2+theta3*a1+beta0+beta1*a0))/(1+exp(theta2+theta3*a0+beta0+beta1*a0))
			/*CONDITIONAL NIE*/
			int3=((1+exp(beta0+beta1*a0))*(1+exp(theta2+theta3*a0+beta0+beta1*a1)))/(	///
				(1+exp(beta0+beta1*a1))*(1+exp(theta2+theta3*a0+beta0+beta1*a0)))
			/*CONDITIONAL TNDE*/
			int4=exp(theta1*(a1-a0))*(1+exp(theta2+theta3*a1+beta0+beta1*a1))/(1+exp(theta2+theta3*a0+beta0+beta1*a1))
			/*CONDITIONAL TNIE*/
			int5=((1+exp(beta0+beta1*a0))*(1+exp(theta2+theta3*a1+beta0+beta1*a1)))/(	///
				(1+exp(beta0+beta1*a1))*(1+exp(theta2+theta3*a1+beta0+beta1*a0)))
			te=(int2)*(int5)
			logte=log(te)
			pm=(int2)*((int5)-1)/((int2)*(int5)-1)
			log1=log(int1)
			log2=log(int2)
			log3=log(int3)
			log4=log(int4)
			log5=log(int5)
			cl1=log1-1.96*intse1
			cu1=log1+1.96*intse1
			cl2=log2-1.96*intse2
			cu2=log2+1.96*intse2
			cl3=log3-1.96*intse3
			cu3=log3+1.96*intse3
			cl4=log4-1.96*intse4
			cu4=log4+1.96*intse4
			cl5=log5-1.96*intse5
			cu5=log5+1.96*intse5
		//	pgreaterte = 1 - normal((logte)/(tese))	//variable not used
		//	plesste = normal((logte)/(tese))
			ptwosidete = 2*min((1- abs(normal((logte)/(tese))), abs(normal((logte)/(tese)))))
			citel=exp(logte-1.96*tese)
			citeu=exp(logte+1.96*tese)
		//	pgreater1 = 1 - normal((log1)/(intse1))
		//	pless1 = normal((log1)/(intse1))
			ptwoside1 = 2*min((1- abs(normal((log1)/(intse1))), abs(normal((log1)/(intse1)))))
		//	pgreater2 = 1 - normal((log2)/(intse2))
		//	pless2 = normal((log2)/(intse2))
			ptwoside2 = 2*min((1- abs(normal((log2)/(intse2))), abs(normal((log2)/(intse2)))))
		//	pgreater3 = 1 - normal((int3)/(intse3))
		//	pless3 = normal((log3)/(intse3))
			ptwoside3 = 2*min((1- abs(normal((log3)/(intse3))), abs(normal((log3)/(intse3)))))
		//	pgreater4 = 1 - normal((log4)/(intse4))
		//	pless4 = normal((log4)/(intse4))
			ptwoside4 = 2*min((1- abs(normal((log4)/(intse4))), abs(normal((log4)/(intse4)))))
		//	pgreater5 = 1 - normal((log5)/(intse5))
		//	pless5 = normal((log5)/(intse5))
			ptwoside5 = 2*min((1- abs(normal((log5)/(intse5))), abs(normal((log5)/(intse5)))))
			ci1l=exp(cl1)
			ci1u=exp(cu1)
			ci2l=exp(cl2)
			ci2u=exp(cu2)
			ci3l=exp(cl3)
			ci3u=exp(cu3)
			ci4l=exp(cl4)
			ci4u=exp(cu4)
			ci5l=exp(cl5)
			ci5u=exp(cu5)
			
			//%if &output=full %then %do 
			if (strlower(output)=="full") {
				value1= int1 , int2, int3, int4, int5
				se1= intse1 , intse2, intse3, intse4, intse5
				pvalue1=  ptwoside1 , ptwoside2, ptwoside3, ptwoside4, ptwoside5
				cil1=ci1l,ci2l,ci3l,ci4l,ci5l
				ciu1=ci1u,ci2u,ci3u,ci4u,ci5u
				x1= value1',se1',pvalue1',cil1',ciu1'	
				value2=  te , pm
				se2= tese ,0
				pvalue2=  ptwosidete , 0
				cil2=citel,0
				ciu2=citeu,0
				x2= value2',se2',pvalue2',cil2',ciu2'	
				x=x1 \ x2

				st_matrix("results", x)	
				st_local("rspec", "rspec(&-&&&&&&&)")		//with r rows, r+2 characters if column headers are displayed
				st_local("rownames", `"cde pnde pnie tnde tnie "total effect" "proportion mediated""')				
				st_local("cspec", "cspec(& b %24s | %8.5f & %8.5f & %8.5f & %12.5f & %12.5f &)")	
				st_local("colnames", `"Estimate s_e p-value "95% CI lower" "95% CI upper""')			
			}
			//%end

			//%if &output^=full %then %do 
			if (strlower(output)!="full") {
				value1= int1 , int2, int5 
				se1= intse1,intse2,intse5
				pvalue1=ptwoside1 , ptwoside2, ptwoside5
				cil1=ci1l,ci2l,ci5l
				ciu1=ci1u,ci2u,ci5u
				x1= value1',se1',pvalue1',cil1',ciu1'	
				value2=  te , pm
				se2= tese ,0
				pvalue2=  ptwosidete , 0
				cil2=citel,0
				ciu2=citeu,0
				x2= value2',se2',pvalue2',cil2',ciu2'	
				x=x1 \ x2

				st_matrix("results", x)	
				st_local("rspec", "rspec(&-&&&&&)")		//with r rows, r+2 characters if column headers are displayed
				st_local("rownames", `"cde nde nie "marginal total effect" "proportion mediated""')			
				st_local("cspec", "cspec(& b %24s | %8.5f & %8.5f & %8.5f & %12.5f & %12.5f &)")	
				st_local("colnames", `"Estimate s_e p-value "95% CI lower" "95% CI upper""')			
			}
			
		}
		
	}
	/*******************end of Part 3*********************/
	

	if (((strlower(yreg)=="logistic") | (strlower(yreg)=="loglinear") | (strlower(yreg)=="poisson") | (strlower(yreg)=="negbin")) & (strlower(mreg)=="linear")) {	
		/**********************************************************************************/
		/*Part 4 yreg=logistic/loglinear/poisson/negbin mreg=linear: #1 & #2
			effects, standard errors, confidence intervals and p-value no interaction w/ and w/o c
		*/	
		//%if &interaction=false %then %do
		if (strlower(interaction)=="false") {
			
			if (strlower(cvar)!="") {
				vars = st_data(., tokens(cvar))
				vb1 = mean(vars)
				cmean = vb1[1, cols(vb1)-nc+1::cols(vb1)]
				
				//%if &c^= %then %do
				if (c!="") {
					cvals = tokens(c)
					cc=strtoreal(cvals)	
				}
				//%end
			}
			
			V1 = st_matrix("out1")
			theta = st_matrix("beta1")	
			theta1 = theta[1,1]	
			theta2 = theta[1,2]
			
			V2 = st_matrix("out2")
			beta = st_matrix("beta2")
			beta1 = beta[1,1]
	
			zero1=J(rows(V1),rows(V2),0)
			zero2=J(rows(V2),rows(V1),0)
			A= V2, zero2
			B= zero1, V1
			sigma= A \ B
	
			zero=J(1,1,0)
			one1=J(1,1,1)
			z1=J(1,nc,0)
			//%if &cvar^= %then %do
			if (cvar!="") {
				z=zero,z1,zero, one1,zero
				nointgammacde=z,z1,zero
				nointgammanie=theta2,z1,zero,  zero,beta1,z1,zero
				tegamma=theta2,z1,zero, one1,beta1,z1,zero
			}
			//%end
			
			//%if &cvar= %then %do
			if (cvar=="") {
				z=zero,zero, one1,zero,zero
				nointgammacde=z
				nointgammanie=theta2,zero,  zero,beta1,zero
				tegamma=theta2,zero, one1,beta1,zero
			}
			//%end
	
			/*se for log odds ratio cde and nde*/
			nointse1=sqrt(nointgammacde*sigma*nointgammacde')*abs(a1-a0)
			/*se for log odds ratio nie*/
			nointse2=sqrt(nointgammanie*sigma*nointgammanie')*abs(a1-a0)
			tese=sqrt(tegamma*sigma*tegamma')*abs(a1-a0)
	
			/*create the effects*/
			/*cde and nde*/
			noint1=exp((theta1)*(a1-a0))
			/*nied*/
			noint2=exp((theta2*beta1)*(a1-a0))
			logte=(theta1+theta2*beta1)*(a1-a0)
			te=exp(logte)
			pm=(noint1)*((noint2)-1)/((noint1)*(noint2)-1)
			log1=log(noint1)
			log2=log(noint2)
		//	pgreater1 = 1 - normal((log1)/(nointse1))
		//	pless1 = normal((log1)/(nointse1))
			ptwoside1 = 2*min((1- abs(normal((log1)/(nointse1))), abs(normal((log1)/(nointse1)))))		
		//	pgreater2 = 1 - normal((log2)/(nointse2))
		//	pless2 = normal((log2)/(nointse2))
			ptwoside2 = 2*min((1- abs(normal((log2)/(nointse2))), abs(normal((log2)/(nointse2)))))
			ci1l=exp(log1-1.96*nointse1)
			ci1u=exp(log1+1.96*nointse1)
			ci2l=exp(log2-1.96*nointse2)
			ci2u=exp(log2+1.96*nointse2)
		//	pgreaterte = 1 - normal((logte)/(tese))	//variale not used
		//	plesste = normal((logte)/(tese))
			ptwosidete = (1-normal(abs((logte)/(tese))))*2
			citel=exp(logte-1.96*tese)
			citeu=exp(logte+1.96*tese)
			value1=  noint1 , noint2
			se1= nointse1 ,nointse2
			pvalue1=  ptwoside1 , ptwoside2
			cil1=ci1l,ci2l
			ciu1=ci1u,ci2u
			
			x1= value1',se1',pvalue1',cil1',ciu1'
			value2=  te , pm
			se2= tese ,0
			pvalue2=  ptwosidete , 0
			cil2=citel,0
			ciu2=citeu,0
			x2= value2',se2',pvalue2',cil2',ciu2'
			x=x1 \ x2
			
			st_matrix("results", x)	
			st_local("rspec", "rspec(&-&&&&)")		//with r rows, r+2 characters if column headers are displayed
			st_local("rownames", `""cde=nde" nie "total effect" "proportion mediated""')				
			st_local("cspec", "cspec(& b %24s | %8.5f & %8.5f & %8.5f & %12.5f & %12.5f &)")
			st_local("colnames", `"Estimate s_e p-value "95% CI lower" "95% CI upper""')
		//	x
		} /**********end of part 4: #1 & #2*******************/


		/**********************************************************************************/
		/*Part 4 yreg=logistic/loglinear/poisson/negbin mreg=linear: #3
			effects, standard errors, confidence intervals and p-value interaction w/ c
		*/	
		//%if &interaction=true & &cvar^= %then %do
		if ((strlower(interaction)=="true") & (strlower(cvar)!="")) {
			vars = st_data(., tokens(cvar))
			vb1 = mean(vars)
			cmean = vb1[1, cols(vb1)-nc+1::cols(vb1)]
			
			//%if &c^= %then %do
			if (c!="") {
				cvals = tokens(c)
				cc=strtoreal(cvals)		
			}
			//%end
			
			V1 = st_matrix("out1")
			theta = st_matrix("beta1")
			theta1 = theta[1,1]	
			theta2 = theta[1,2]
			theta3 = theta[1,3]
			
			V2 = st_matrix("out2")
			beta = st_matrix("beta2")
			s2tmp = st_numscalar("rmse")
			s2 = s2tmp^2
			beta0 = beta[1,cols(beta)]
			beta1 = beta[1,1]
			beta2 = beta[1,2::cols(beta)-1]		
	
			zero1=J(rows(V1),rows(V2),0)
			zero2=J(rows(V2),rows(V1),0)
			z2=J(rows(V1),1,0)
			z3=J(rows(V2),1,0)
			A= V2, zero2, z3
			B= zero1, V1, z2
			zeros=J(1, rows(V1)+rows(V2),0)
			D= zeros, s2
			sigma= A \ B \ D
			zero=0
			one1=1
			z1=J(1, nc, 0)
		
			z=zero,z1,zero, one1,zero
			
			//%if &c^= %then %do
			if (c!="") {
				condgammacde=z,m , z1,zero,zero
				x=theta3*a0
				w=theta3*cc'
				h=beta0+beta1*a0+(beta2)*cc'+theta2*s2+theta3*s2*(a1+a0)
				ts=s2*theta3
				f=theta3*theta2+0.5*(theta3^2)*(a1+a0)
				condgammapnde= x, w', theta3,  one1,ts, h ,z1,zero, f
				x=theta3*a1
				w=theta3*cc'
				h=beta0+beta1*a1+(beta2)*cc'+theta2*s2+theta3*s2*(a1+a0)
				ts=s2*theta3
				f=theta3*theta2+0.5*theta3^2*(a1+a0)
				condgammatnde=x, w', theta3,  one1, ts, h,z1, zero,  f
				x=theta2+theta3*a1
				w=beta1*a1
				condgammatnie=x, z1, zero,  zero, beta1, w , z1 ,zero,   zero
				x=theta2+theta3*a0
				w=beta1*a0
				condgammapnie=x, z1, zero,  zero, beta1, w , z1 ,zero,  zero
				/*cond se cde*/
				intse1=sqrt(condgammacde*sigma*condgammacde')
				/*cond se pnde*/
				intse2=sqrt(condgammapnde*sigma*condgammapnde')
				/*cond se pnie*/
				intse3=sqrt(condgammapnie*sigma*condgammapnie')
				/*cond se tnde*/
				intse4=sqrt(condgammatnde*sigma*condgammatnde')
				/*cond se tnie*/
				intse5=sqrt(condgammatnie*sigma*condgammatnie')
			}
			//%end
			
			marggammacde=z,m , z1,zero, zero 
			
			x=theta3*a0
			w=theta3*cmean'
			h=beta0+beta1*a0+(beta2)*cmean'+theta2*s2+theta3*s2*(a1+a0)
			ts=s2*theta3
			f=theta3*theta2+0.5*(theta3^2)*(a1+a0)
			marggammapnde= x, w', theta3,  one1, ts, h, z1, zero,  f
			
			x=theta3*a1
			w=theta3*cmean'
			h=beta0+beta1*a1+(beta2)*cmean'+theta2*s2+theta3*s2*(a1+a0)
			ts=s2*theta3
			f=theta3*theta2+0.5*theta3^2*(a1+a0)
			marggammatnde=x, w', theta3,  one1, ts, h,z1, zero,  f
			
			x=theta2+theta3*a1
			w=beta1*a1
			marggammatnie=x, z1, zero,  zero, beta1, w , z1 ,zero,  zero
			
			x=theta2+theta3*a0
			w=beta1*a0
			marggammapnie=x, z1, zero,  zero, beta1, w , z1 ,zero,  zero
			
			/*marg se cde*/
			intse6=sqrt(marggammacde*sigma*marggammacde')
			/*marg se pnde*/
			intse7=sqrt(marggammapnde*sigma*marggammapnde')
			/*marg se pnie*/
			intse8=sqrt(marggammapnie*sigma*marggammapnie')
			/*marg se tnde*/
			intse9=sqrt(marggammatnde*sigma*marggammatnde')
			/*marg se tnie*/
			intse10=sqrt(marggammatnie*sigma*marggammatnie')
			
			//%if &c^= %then %do
			if (c!="") {
				d2pnde=theta3*a0
				d3pnde=theta3*(cc)
				d7pnde=beta0+beta1*a0+(beta2)*cc'+theta2*s2+theta3*s2*(a1+a0)
				d6pnde=s2*theta3
				d9pnde=theta3*theta2+0.5*(theta3^2)*(a1+a0)
				d2tnie=theta2+theta3*a1
				d7tnie=beta1*a1
				d2=d2pnde+d2tnie
				d3=d3pnde
				d6=d6pnde+beta1
				d7=d7pnde+d7tnie
				d9=d9pnde
				tegammacond=d2,d3,theta3, one1,d6,d7,z1,zero, d9
				tesecond=sqrt(tegammacond*sigma*tegammacond')
			}
			//%end
			
			d2pnde=theta3*a0
			d3pnde=theta3*(cmean)
			d7pnde=beta0+beta1*a0+(beta2)*cmean'+theta2*s2+theta3*s2*(a1+a0)
			d6pnde=s2*theta3
			d9pnde=theta3*theta2+0.5*(theta3^2)*(a1+a0)
			d2tnie=theta2+theta3*a1
			d7tnie=beta1*a1
			d2=d2pnde+d2tnie
			d3=d3pnde
			d6=d6pnde+beta1
			d7=d7pnde+d7tnie
			d9=d9pnde
			tegammamarg=d2,d3,theta3, one1,d6,d7,z1,zero, d9

			tesemarg=sqrt(tegammamarg*sigma*tegammamarg')
			tsq=(theta3^2)
			rm=s2
			asq=(a1^2)
			a1sq=(a0^2)
			
			//%if &c^= %then %do
			if (c!="") {
				  /*CONDITIONAL CDE*/
				  x1=(theta1+theta3*m)*(a1-a0)
			      int1=exp(x1)
			      /*CONDITIONAL NDE*/	  
				  x2=(theta1+theta3*beta0+theta3*beta1*a0+sum(theta3*beta2*cc')+theta3*theta2*rm)*(a1-a0)+(1/2)*tsq*rm*(asq-a1sq)
				  int2=exp(x2)
			      /*CONDITIONAL NIE*/
				  x3=(theta2*beta1+theta3*beta1*a0)*(a1-a0)
			      int3=exp(x3)
			      /*CONDITIONAL TNDE*/
				  x4=(theta1+theta3*beta0+theta3*beta1*a1+sum(theta3*beta2*cc')+theta3*theta2*rm)*(a1-a0)+(1/2)*tsq*rm*(asq-a1sq)
			      int4=exp(x4)
			      /*CONDITIONAL TNIE*/
				  x5=(theta2*beta1+theta3*beta1*a1)*(a1-a0)
			      int5=exp(x5)
			}	 
			//%end
				  
				  /*MARGINAL CDE*/
				  x6=(theta1+theta3*m)*(a1-a0)
				  int6=exp(x6)
				  /*MARGINAL NDE*/
				  x7=(theta1+theta3*beta0+theta3*beta1*a0+sum(theta3*beta2*cmean')+theta3*theta2*rm)*(a1-a0)+1/2*tsq*rm*(asq-a1sq)
			      int7=exp(x7)
				  /*MARGINAL NIE*/
				  x8=(theta2*beta1+theta3*beta1*a0)*(a1-a0)
				  int8=exp(x8)
				  /*MARGINAL TNDE*/
				  x9=(theta1+theta3*beta0+theta3*beta1*a1+sum(theta3*beta2*cmean')+theta3*theta2*rm)*(a1-a0)+1/2*tsq*rm*(asq-a1sq)
				  int9=exp(x9)
				  /*MARGINAL TNIE*/
				  x10=(theta2*beta1+theta3*beta1*a1)*(a1-a0)
				  int10=exp(x10)
			
			//%if &c^= %then %do
			if (c!="") {
				logtecond=(theta1+theta3*beta0+theta3*beta1*a0+sum(theta3*beta2*cc')+theta2*beta1+theta3*beta1*a1+theta3*(rm)*theta2)*(a1-a0)+0.5*(theta3^2)*(rm)*(a1^2-a0^2)
				tecond=exp(logtecond)
			}
			//%end
			
			logtemarg=(theta1+theta3*beta0+theta3*beta1*a0+sum(theta3*beta2*cmean')+theta2*beta1+theta3*beta1*a1+theta3*(rm)*theta2)*(a1-a0)+0.5*(theta3^2)*(rm)*(a1^2-a0^2)
			temarg=exp(logtemarg)
			pm=(int7)*((int10)-1)/((int7)*(int10)-1)
			
			//%if &c^= %then %do
			if (c!="") {
				log1=log(int1)
				log2=log(int2)
				log3=log(int3)
				log4=log(int4)
				log5=log(int5)
			}
			//%end
			
			log6=log(int6)
			log7=log(int7)
			log8=log(int8)
			log9=log(int9)
			log10=log(int10)
			
			//%if &c^= %then %do
			if (c!="") {
				cl1=log1-1.96*intse1
				cu1=log1+1.96*intse1
				cl2=log2-1.96*intse2
				cu2=log2+1.96*intse2
				cl3=log3-1.96*intse3
				cu3=log3+1.96*intse3
				cl4=log4-1.96*intse4
				cu4=log4+1.96*intse4
				cl5=log5-1.96*intse5
				cu5=log5+1.96*intse5
			}
			//%end
			
			cl6=log6-1.96*intse6
			cu6=log6+1.96*intse6
			cl7=log7-1.96*intse7
			cu7=log7+1.96*intse7
			cl8=log8-1.96*intse8
			cu8=log8+1.96*intse8
			cl9=log9-1.96*intse9
			cu9=log9+1.96*intse9
			cl10=log10-1.96*intse10
			cu10=log10+1.96*intse10
			
			//%if &c^= %then %do
			if (c!="") {
			//	pgreater1 = 1 - normal((log1)/(intse1))
			//	pless1 = normal((log1)/(intse1))
				ptwoside1 = 2*min((1- abs(normal((log1)/(intse1))), abs(normal((log1)/(intse1)))))
			//	pgreater2 = 1 - normal((log2)/(intse2))
			//	pless2 = normal((log2)/(intse2))
				ptwoside2 = 2*min((1- abs(normal((log2)/(intse2))), abs(normal((log2)/(intse2)))))
			//	pgreater3 = 1 - normal((int3)/(intse3))
			//	pless3 = normal((log3)/(intse3))
				ptwoside3 = 2*min((1- abs(normal((log3)/(intse3))), abs(normal((log3)/(intse3)))))
			//	pgreater4 = 1 - normal((log4)/(intse4))
			//	pless4 = normal((log4)/(intse4))
				ptwoside4 = 2*min((1- abs(normal((log4)/(intse4))), abs(normal((log4)/(intse4)))))
			//	pgreater5 = 1 - normal((log5)/(intse5))
			//	pless5 = normal((log5)/(intse5))
				ptwoside5 = 2*min((1- abs(normal((log5)/(intse5))), abs(normal((log5)/(intse5)))))
			}
			//%end
			
		//	pgreater6 = 1 - normal((log6)/(intse6))
		//	pless6 = normal((log6)/(intse6))
			ptwoside6 = 2*min((1- abs(normal((log6)/(intse6))), abs(normal((log6)/(intse6)))))
		//	pgreater7 = 1 - normal((log7)/(intse7))
		//	pless7 = normal((log7)/(intse7))
			ptwoside7 = 2*min((1- abs(normal((log7)/(intse7))), abs(normal((log7)/(intse7)))))
		//	pgreater8 = 1 - normal((log8)/(intse8))
		//	pless8 = normal((log8)/(intse8))
			ptwoside8 = 2*min((1- abs(normal((log8)/(intse8))), abs(normal((log8)/(intse8)))))
		//	pgreater9= 1 - normal((log9)/(intse9))
		//	pless9 = normal((log9)/(intse9))
			ptwoside9 = 2*min((1- abs(normal((log9)/(intse9))), abs(normal((log9)/(intse9)))))
		//	pgreater10 = 1 - normal((log10)/(intse10))
		//	pless10 = normal((log10)/(intse10))
			ptwoside10 = 2*min((1- abs(normal((log10)/(intse10))), abs(normal((log10)/(intse10)))))
			
			//%if &c^= %then %do
			if (c!="") {
				ci1l=exp(cl1)
				ci1u=exp(cu1)
				ci2l=exp(cl2)
				ci2u=exp(cu2)
				ci3l=exp(cl3)
				ci3u=exp(cu3)
				ci4l=exp(cl4)
				ci4u=exp(cu4)
				ci5l=exp(cl5)
				ci5u=exp(cu5)
			}
			//%end
			
			ci6l=exp(cl6)
			ci6u=exp(cu6)
			ci7l=exp(cl7)
			ci7u=exp(cu7)
			ci8l=exp(cl8)
			ci8u=exp(cu8)
			ci9l=exp(cl9)
			ci9u=exp(cu9)
			ci10l=exp(cl10)
			ci10u=exp(cu10)
		//	pgreatertemarg = 1 - normal((logtemarg)/(tesemarg))
		//	plesstemarg = normal((logtemarg)/(tesemarg))
			ptwosidetemarg = 2*min((1- abs(normal((logtemarg)/(tesemarg))), abs(normal((logtemarg)/(tesemarg)))))
			citelmarg=exp(logtemarg-1.96*tesemarg)
			citeumarg=exp(logtemarg+1.96*tesemarg)
			
			//%if &c^= %then %do
			if (c!="") {
			//	pgreatertecond = 1 - normal((logtecond)/(tesecond))
			//	plesstecond = normal((logtecond)/(tesecond))
				ptwosidetecond = 2*min((1- abs(normal((logtecond)/(tesecond))), abs(normal((logtecond)/(tesecond)))))
				citelcond=exp(logtecond-1.96*tesecond)
				citeucond=exp(logtecond+1.96*tesecond)
			}
			//%end
			
			//%if &output=full %then %do 
			if (strlower(output)=="full") {
				value1= int6, int7, int8, int9, int10, temarg, int1 , int2, int3, int4, int5, tecond, pm
				se1= intse6, intse7, intse8, intse9, intse10, tesemarg, intse1 , intse2, intse3, intse4, intse5, tesecond, 0
				pvalue1=  ptwoside6, ptwoside7, ptwoside8, ptwoside9, ptwoside10, ptwosidetemarg, ptwoside1 , ptwoside2, ptwoside3, ptwoside4, ptwoside5, ptwosidetecond, 0
				cil1=ci6l,ci7l,ci8l,ci9l,ci10l, citelmarg, ci1l,ci2l,ci3l,ci4l,ci5l, citelcond, 0
				ciu1=ci6u,ci7u,ci8u,ci9u,ci10u, citeumarg, ci1u,ci2u,ci3u,ci4u,ci5u, citeucond, 0
				x= value1' ,se1',pvalue1',cil1',ciu1' 
				
				st_matrix("results", x)
				st_local("rspec", "rspec(&-&&&&&&&&&&&&&)")		//with r rows, r+2 characters if column headers are displayed
				st_local("rownames", `""marginal cde"	"marginal pnde" "marginal pnie" "marginal tnde" "marginal tnie" "marginal total effect" "conditional cde" "conditional pnde" "conditional pnie" "conditional tnde" "conditional tnie" "conditional total effect" "proportion mediated""')	//v0.3g	
				st_local("cspec", "cspec(& b %24s | %8.5f & %8.5f & %8.5f & %12.5f & %12.5f &)")	
				st_local("colnames", `"Estimate s_e p-value "95% CI lower" "95% CI upper""')	
			}
			//%end
			
			//%if &output^=full  %then %do 
			if (strlower(output)!="full") {
				value1= int6 , int7, int10 
				se1= intse6,intse7,intse10
				pvalue1=ptwoside6 , ptwoside7, ptwoside10
				cil1=ci6l,ci7l,ci10l
				ciu1=ci6u,ci7u,ci10u
				x1= value1',se1',pvalue1',cil1',ciu1'	
				value2= temarg , pm
				se2=tesemarg ,0
				pvalue2= ptwosidetemarg , 0
				cil2=citelmarg,0
				ciu2=citeumarg,0
				x2= value2',se2',pvalue2',cil2',ciu2'	
				x=x1 \ x2

				st_matrix("results", x)	
				st_local("rspec", "rspec(&-&&&&&)")		//with r rows, r+2 characters if column headers are displayed
				st_local("rownames", `"cde nde nie "marginal total effect" "proportion mediated""')				
				st_local("cspec", "cspec(& b %24s | %8.5f & %8.5f & %8.5f & %12.5f & %12.5f &)")	
				st_local("colnames", `"Estimate s_e p-value "95% CI lower" "95% CI upper""')			
			}
			
		} /**********end of part 4: #3*******************/
		

		/**********************************************************************************/
		/*Part 4 yreg=logistic/loglinear/poisson/negbin mreg=linear: #4
			effects, standard errors, confidence intervals and p-value interaction w/o c
		*/				
		//%if &interaction=true & &cvar= %then %do
		if ((strlower(interaction)=="true") & (strlower(cvar)=="")) {
			
			V1 = st_matrix("out1")
			theta = st_matrix("beta1")
			theta1 = theta[1,1]	
			theta2 = theta[1,2]
			theta3 = theta[1,3]
			
			V2 = st_matrix("out2")
			
			beta = st_matrix("beta2")
			s1 = st_numscalar("rmse")
			s2 = s1^2
			beta0 = beta[1,2]		//intercept
			beta1 = beta[1,1]
	
			zero1=J(rows(V1),rows(V2),0)
			zero2=J(rows(V2),rows(V1),0)
			z2 = J(rows(V1),1,0)
			z3 = J(rows(V2),1,0)
			A= V2, zero2, z3
			B= zero1, V1, z2
			zeros=J(1,rows(V1)+rows(V2),0)
			D= zeros, s2
			sigma= A \ B \ D
			
			zero=0
			one1=1
			z=zero,zero, one1,zero
			condgammacde=z,m, zero, zero
			
			x=theta3*a0
			h=beta0+beta1*a0+theta2*s2+theta3*s2*(a1+a0)
			ts=s2*theta3
			f=theta3*theta2+0.5*(theta3^2)*(a1+a0)
			condgammapnde= x, theta3,  one1,ts,h,zero, f
			
			x=theta3*a1
			h=beta0+beta1*a1+theta2*s2+theta3*s2*(a1+a0)
			ts=s2*theta3
			f=theta3*theta2+0.5*theta3^2*(a1+a0)
			condgammatnde=x, theta3,  one1, ts, h, zero,  f
			
			x=theta2+theta3*a1
			w=beta1*a1
			condgammatnie=x,zero,  zero,beta1,w,zero,  zero
			
			x=theta2+theta3*a0
			w=beta1*a0
			condgammapnie=x,zero,  zero,beta1,w,zero,  zero
			
			/*cond se cde*/
			intse1=sqrt(condgammacde*sigma*condgammacde')
			/*cond se pnde*/
			intse2=sqrt(condgammapnde*sigma*condgammapnde')
			/*cond se pnie*/
			intse3=sqrt(condgammapnie*sigma*condgammapnie')
			/*cond se tnde*/
			intse4=sqrt(condgammatnde*sigma*condgammatnde')
			/*cond se tnie*/
			intse5=sqrt(condgammatnie*sigma*condgammatnie')
			
			d2pnde=theta3*a0
			d7pnde=beta0+beta1*a0+theta2*s2+theta3*s2*(a1+a0)
			d6pnde=s2*theta3
			d9pnde=theta3*theta2+0.5*(theta3^2)*(a1+a0)
			d2tnie=theta2+theta3*a1
			d7tnie=beta1*a1
			d2=d2pnde+d2tnie
			d6=d6pnde+beta1
			d7=d7pnde+d7tnie
			d9=d9pnde
			tegamma=d2,theta3,  one1,d6,d7,zero,  d9
			
			tese=sqrt(tegamma*sigma*tegamma')		
			/*CONDITIONAL CDE*/
			x1=(theta1+theta3*m)*(a1-a0)
			int1=exp(x1)
			/*CONDITIONAL NDE*/
			
			tsq=(theta3^2)
			rm=s2
			asq=(a1^2)
			a1sq=(a0^2)
			x2=(theta1+theta3*beta0+theta3*beta1*a0+theta3*theta2*rm)*(a1-a0)+(1/2)*tsq*rm*(asq-a1sq)
			int2=exp(x2)
			/*CONDITIONAL NIE*/
			x3=(theta2*beta1+theta3*beta1*a0)*(a1-a0)
			int3=exp(x3)
			/*CONDITIONAL TNDE*/
			x4=(theta1+theta3*beta0+theta3*beta1*a1+theta3*theta2*rm)*(a1-a0)+(1/2)*tsq*rm*(asq-a1sq)
			int4=exp(x4)
			/*CONDITIONAL TNIE*/
			x5=(theta2*beta1+theta3*beta1*a1)*(a1-a0)
			int5=exp(x5)
			logte=(theta1+theta3*beta0+theta3*beta1*a0+theta2*beta1+theta3*beta1*a1+theta3*(rm)*theta2)*(a1-a0)+0.5*(theta3^2)*(rm)*(a1^2-a0^2)
			te=exp(logte)
			te=int2*int5		
			pm=(int2)*((int5)-1)/((int2)*(int5)-1)
			log1=log(int1)
			log2=log(int2)
			log3=log(int3)
			log4=log(int4)
			log5=log(int5)
			cl1=log1-1.96*intse1
			cu1=log1+1.96*intse1
			cl2=log2-1.96*intse2
			cu2=log2+1.96*intse2
			cl3=log3-1.96*intse3
			cu3=log3+1.96*intse3
			cl4=log4-1.96*intse4
			cu4=log4+1.96*intse4
			cl5=log5-1.96*intse5
			cu5=log5+1.96*intse5
		//	pgreater1 = 1 - normal((log1)/(intse1))
		//	pless1 = normal((log1)/(intse1))
			ptwoside1 = 2*min((1- abs(normal((log1)/(intse1))), abs(normal((log1)/(intse1)))))
		//	pgreater2 = 1 - normal((log2)/(intse2))
		//	pless2 = normal((log2)/(intse2))
			ptwoside2 = 2*min((1- abs(normal((log2)/(intse2))), abs(normal((log2)/(intse2)))))
		//	pgreater3 = 1 - normal((int3)/(intse3))
		//	pless3 = normal((log3)/(intse3))
			ptwoside3 = 2*min((1- abs(normal((log3)/(intse3))), abs(normal((log3)/(intse3)))))
		//	pgreater4 = 1 - normal((log4)/(intse4))
		//	pless4 = normal((log4)/(intse4))
			ptwoside4 = 2*min((1- abs(normal((log4)/(intse4))), abs(normal((log4)/(intse4)))))
		//	pgreater5 = 1 - normal((log5)/(intse5))
		//	pless5 = normal((log5)/(intse5))
			ptwoside5 = 2*min((1- abs(normal((log5)/(intse5))), abs(normal((log5)/(intse5)))))
			ci1l=exp(cl1)
			ci1u=exp(cu1)
			ci2l=exp(cl2)
			ci2u=exp(cu2)
			ci3l=exp(cl3)
			ci3u=exp(cu3)
			ci4l=exp(cl4)
			ci4u=exp(cu4)
			ci5l=exp(cl5)
			ci5u=exp(cu5)
		//	pgreaterte = 1 - normal((logte)/(tese))	//variable not used
		//	plesste = normal((logte)/(tese))
			ptwosidete = 2*min((1- abs(normal((logte)/(tese))), abs(normal((logte)/(tese)))))
			citel=exp(logte-1.96*tese)
			citeu=exp(logte+1.96*tese)
			
			//%if &output=full %then %do 
			if (strlower(output)=="full") {
				value1= int1 , int2, int3, int4, int5
				se1= intse1 , intse2, intse3, intse4, intse5
				pvalue1=  ptwoside1 , ptwoside2, ptwoside3, ptwoside4, ptwoside5
				cil1=ci1l,ci2l,ci3l,ci4l,ci5l
				ciu1=ci1u,ci2u,ci3u,ci4u,ci5u
				x1= value1',se1',pvalue1',cil1',ciu1'	
				value2=  te , pm
				se2= tese ,0
				pvalue2=  ptwosidete , 0
				cil2=citel,0
				ciu2=citeu,0
				x2= value2',se2',pvalue2',cil2',ciu2'	
				x=x1 \ x2

				st_matrix("results", x)	
				st_local("rspec", "rspec(&-&&&&&&&)")		//with r rows, r+2 characters if column headers are displayed
				st_local("rownames", `"cde pnde pnie tnde tnie "total effect" "proportion mediated""')				
				st_local("cspec", "cspec(& b %24s | %8.5f & %8.5f & %8.5f & %12.5f & %12.5f &)")	
				st_local("colnames", `"Estimate s_e p-value "95% CI lower" "95% CI upper""')			
			}
			//%end
			
			//%if &output^=full %then %do 
			if (strlower(output)!="full") {
				value1= int1 , int2, int5 
				se1= intse1,intse2,intse5
				pvalue1=ptwoside1 , ptwoside2, ptwoside5
				cil1=ci1l,ci2l,ci5l
				ciu1=ci1u,ci2u,ci5u
				x1= value1',se1',pvalue1',cil1',ciu1'	
				value2=  te , pm
				se2= tese ,0
				pvalue2=  ptwosidete , 0
				cil2=citel,0
				ciu2=citeu,0
				x2= value2',se2',pvalue2',cil2',ciu2'	
				x=x1 \ x2

				st_matrix("results", x)	
				st_local("rspec", "rspec(&-&&&&&)")		//with r rows, r+2 characters if column headers are displayed
				st_local("rownames", `"cde nde nie "marginal total effect" "proportion mediated""')				
				st_local("cspec", "cspec(& b %24s | %8.5f & %8.5f & %8.5f & %12.5f & %12.5f &)")	
				st_local("colnames", `"Estimate s_e p-value "95% CI lower" "95% CI upper""')			
			}
			
				
			
		} /**********end of part 4: #4*******************/


	}
	/*******************end of Part 4*********************/
	
	st_local("cspec", "cspec(& b %24s | %9.0g & %9.0g & %9.0g & %12.0g & %12.0g &)")
	st_local("colnames", `"Estimate s_e p-value "95% CI lower" "95% CI upper""')
}

end

mata: mata mosave paramed(), dir(PLUS) replace
