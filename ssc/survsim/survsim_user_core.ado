
local RS real scalar
local RM real matrix

program define survsim_user_core
	version 14.2
	syntax , 	stime(varname)				///
				maxtime(string) 			///
				logu(varname) 				///
				expxb(varlist) 				///
				tdexb(varlist)				///
			[								///
				ltruncated(varname) 		///
				CHazard						///
			]								//
			
	mata: survsim_user($overallsyntax2)
end

mata:

void survsim_user($overallsyntax1)
{
	N = st_nobs()
	st_view(time = .,.,st_local("stime"))
	st_view(maxt = .,.,st_local("maxtime"))

	st_view(expxb = .,.,st_local("expxb"))
	st_view(tdexb = .,.,st_local("tdexb"))
	st_view(rc = .,.,"_survsim_rc")
	st_view(logu = .,.,st_local("logu"))

	if (st_local("ltruncated")!="") {
		st_view(lt=.,.,st_local("ltruncated"))
	}
	else lt = J(N,1,smallestdouble())
	
	hazard 	= st_local("chazard")==""
	if (hazard) {
		nodes 	= st_matrix("r(nodes)")'
		weights = st_matrix("r(weights)")
	}
	maxit 	= 1000
	tol 	= 0
	
	if (hazard) {
		for (i=1;i<=N;i++){
			rc[i] 	= mm_root(															///
								t=.,&survsim_user_hazard(),lt[i],maxt[i],tol,maxit,		///
								logu[i],nodes,weights,i,expxb[i,],lt[i],tdexb[i,] 		///
								${mmrootsyntax1}										///
								)														//
			time[i] = t
		}
	}
	else {
		for (i=1;i<=N;i++){
			rc[i] 	= mm_root(															///
								t=.,&survsim_user_chazard(),lt[i],maxt[i],tol,maxit,	///
								logu[i],i,expxb[i,],lt[i],tdexb[i,] 					///
								${mmrootsyntax1}										///
								)														//
			time[i] = t
		}		
	}
}

function survsim_user_hazard(	`RS' t, 			///
								`RS' logu, 			///
								`RM' nodes, 		///
								`RM' weights, 		///
								`RS' i, 			///
								`RM' expxb, 		///
								`RS' lt,	 		///
								`RM' tdexb 			///
								${mmrootsyntax2}	///
								)					//
{
	tnodes 		= (t :- lt) :* 0.5 :* nodes :+ (t :+ lt) :/ 2
	tweights 	= (t :- lt) :* weights :/ 2
	chq 		= $chaz
	return(chq * tweights :+ logu)
}

function survsim_user_chazard(	`RS' t,				///
								`RS' logu, 			///
								`RS' i, 			///
								`RM' expxb, 		///
								`RS' lt,	 		///
								`RM' tdexb 			///
								${mmrootsyntax2}	///
								)					//
{
	return((${chaz}) :+ logu)
}

end
