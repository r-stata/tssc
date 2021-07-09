*! version 2.3 11Nov2018

// Incorporating RML

program define stpm2cifgq, rclass
	
	version 14.1
	syntax newvarlist (min=1 max=1), /// 	
		MODELnames(string) ///
		[ ///
		AT(string) TIMEvar(string) NODES(int 100) RMLat(numlist >=0 integer)) HAZard CONtrast(string) CONDitional(int 0) /// 
		quadopt(string) CI GRAPHrml CIF ///
		]
	
	if "`rmlat'" == "" & "`graphrml'" !="" {
		di in red "Cannot use graphrml option without specifying a numlist in rmlat()"
		exit 198
	}
			
	local newvarname `varlist'
	
	local cifopt
	if "`cif'" != "" {
		local cifopt "`cif'"
	}
	
	local minT = `conditional'
	
	// parse models
	local models `modelnames'
	local modelN = wordcount("`modelnames'")
	tokenize `modelnames'
	forvalues i = 1/`modelN' {
		local model`i' ``i'' 
	}

	if "`quadopt'" == "" {
		local quadopt "leg"
	}
	
	//some outside mata model storing stuff
	foreach model in `models' {
		qui estimates restore `model'
		
		tempvar touse_`model'
		quietly gen `touse_`model'' = e(sample)
		quietly count if `touse_`model'' == 1
		local Nobs_`model' `r(N)'
		
		if "`e(noconstant)'" == "" {
			local xbcons_`model' = [xb][_cons]
		}
		
		//code to extract (in order of specification in varlist) the covariates to predict at
		tokenize `at'
		local varsList = e(varlist)
		local Nvars wordcount(e(varlist))*2
		local varval_`model'
		foreach var in `varsList' {
			if strpos("`at'" ,"`var' ") != 0 {
				forvalues i = 1(2)`=`Nvars'' {
					local j = `i' + 1
					if "`var'" == "``i''" { 	
						local varval_`model' "`varval_`model'' ``j''"
					}
				}
			}
			else {
				local varval_`model' "`varval_`model'' 0"
			}
		}
	}
	
	tokenize `at'
	local Natvars wordcount("`at'")
	local atList
	forvalues i = 1(2)`=`Natvars'' {
		local atList "`atList' ``i''"
	}
	
	

	// generate time variable
	/*capture noi range `timerange'
	if _rc != 0 {
		di in red "timerange() incorrectly specified. Syntax should be the same as the {help range} command."
		exit 198
	}
	tokenize `timerange'
	local t `1'
	*/
	local t `timevar'
	local lnt = ln(`t')
	tempvar touse_time
	qui gen `touse_time' = 1 if `t' !=.
	qui replace  `touse_time' = 0 if `t' == .

	// get nodes and weights for numerical integration
	qui set matsize `nodes'
	tempname knodes kweights
	gaussquad, n(`nodes') `quadopt'
	matrix `knodes' = r(nodes)'
	matrix `kweights' = r(weights)'
	
	mata stpm2cifgq_mata()
	
	if "`rmlat'" != "" {
		matrix rownames RML = `rmlat'
		matrix roweq RML = time
		local coleqnames
		foreach name in `modelnames' {
			local coleqnames `coleqnames' ll_`name'
			matrix colnames RML = `coleqnames'
		}
		matrix coleq RML = model
		
		if "`ci'" != "" {
			local coleqnames
			foreach name in `modelnames' {
				local coleqnames `coleqnames' ll_`name' ll_`name'_lci ll_`name'_uci
			}
			matrix colnames RML = `coleqnames'
			
		}
		mat li RML
		return matrix RML = RML
		return matrix rml_Nt = RML_Nt
		
	}
	
end

//== Main structure for mata ====================================================================
mata

struct vars_structure {
	
	real scalar				modelN,
							Nt,
							t0,
							Mnodes,
							minT,
							rml,
							ciopt,
							cifopt
	
	string scalar			touse_time,
							newvarname
	
	real matrix				t,
							lnt,
							nodesi,
							weightsi,
							z,
							v,
							xb,
							CIF,
							CIF_lci,
							CIF_uci,
							rmlT,
							LL,
							LL_lci,
							LL_uci,
							test
	
	string matrix			models,
							atList
	
	transmorphic matrix		rcsbaseoff,
							dfbase,
							dftvc,
							orthog,
							hastvc,
							knots,
							tvcknots,
							hascons,
							tvcnames,
							Ntvc,
							Rmatrix,
							Nvarlist,
							hasvarlist,
							Xrcstvc,		
							Xdrcstvc,
							Xrcsbase,
							Xdrcsbase,
							X,
							Xdrcs,
							Nparameters,
							betacov,
							betarcs,
							beta,
							touse_model,
							Nobs_model,
							V,
							varlist,
							varlistval,
							rcsxb,
							drcsxb,
							eta,
							st,
							ht,
							st_all,
							Ft,
							xbcons,
							u,
							logu,
							Ftmat,
							A12_k
}

void function stpm2cifgq_mata() {

	struct vars_structure scalar Q
	
	Q = stata_transfer()
	
	if(Q.cifopt) {
		for(t=1;t<=Q.Nt;t++) {
			tstar = "cif"
			time_index = "time" + strofreal(t)
			asarray(Q.st_all, (time_index, tstar), J(Q.Mnodes,1,1))
			
			for(m=1;m<=Q.modelN;m++) {
				modelstr_index = Q.models[1,m]
				genSplines(Q,ln(Q.z[,t]),modelstr_index,time_index,tstar)
				genDerivSplines(Q,ln(Q.z[,t]),modelstr_index,time_index,tstar)
				genEta(Q, tstar, time_index, m)
				genSurvFuncs(Q, Q.z[,t], tstar, time_index, m)
			}
			genCIF(Q, tstar, time_index, t)
			
			if(Q.ciopt) {
				deltaMethod(Q, tstar, time_index, t)
			}
		}
		if(Q.ciopt) genCI(Q, Q.Nt, "cif")
		exportCIF(Q)
	}
	
	if(Q.rml) {
		for(t=1;t<=cols(Q.rmlT);t++) {
			time_index = "rmltime" + strofreal(Q.rmlT[,t])
			for(i=1;i<=rows(Q.v);i++) {
				tstar = "rml_"+strofreal(i)
				asarray(Q.st_all, (time_index, tstar), J(Q.Mnodes,1,1))
				
				for(m=1;m<=Q.modelN;m++) {
					modelstr_index = Q.models[1,m]
					genSplines(Q,asarray(Q.logu, time_index)[,i],modelstr_index,time_index,tstar)
					genDerivSplines(Q,asarray(Q.logu, time_index)[,i],modelstr_index,time_index,tstar)
					genEta(Q, tstar, time_index, m)
					genSurvFuncs(Q, asarray(Q.u, time_index)[,i], tstar, time_index, m)
				}
				
				genCIF(Q, tstar, time_index, t)
			}
			if(Q.ciopt) {
				deltaMethod(Q, "rml", time_index, t)
			}
		}
		
		for(m=1;m<=Q.modelN;m++) {
			modelstr_index = Q.models[1,m]
			genRML(Q, m)
		}
		if(Q.ciopt) genCI(Q, Q.rmlT, "rml")
		st_matrix("RML_Nt", Q.rmlT')
		exportRML(Q)
	}
	
	
}

//Get what we need from Stata
function stata_transfer() {
	struct vars_structure scalar Q
	
	Q.newvarname = st_local("newvarname")
	
	//store time
	Q.touse_time = st_local("touse_time")
	Q.t = st_data(.,st_local("t"),Q.touse_time)
	
	Q.lnt = ln(Q.t)
	Q.Nt = rows(Q.t)
	
	Q.minT = strtoreal(st_local("minT"))
	
	//calculate new timepoints at nodes for integration
	Q.Mnodes = strtoreal(st_local("nodes"))
	Q.z = J(Q.Mnodes,Q.Nt,.)
	Q.nodesi = st_matrix(st_local("knodes"))
	Q.weightsi = st_matrix(st_local("kweights"))
	Q.t0 = Q.minT
	
	Q.atList = tokens(st_local("atList"))
	
	for(i=1;i<=Q.Nt;i++) {
		Q.z[,i] = (((Q.t[i] :- Q.t0):/2):*Q.nodesi') :+ ((Q.t[i] :+ Q.t0):/2)
	}
	
	Q.rml = st_local("rmlat") != ""
	Q.cifopt = st_local("cifopt") != ""
	Q.rmlT = Q.t' 
	Q.u = asarray_create()
	Q.logu = asarray_create()
	
	Q.ciopt = st_local("ci") != ""	
	
	if(Q.rml) {
	
		Q.v = J(Q.Mnodes,cols(Q.rmlT),.)
		for(i=1;i<=cols(Q.rmlT);i++) {
			for(j=1;j<=Q.Mnodes;j++) {
				Q.v[j,i] = ((Q.rmlT[i] :- Q.t0):/2):*Q.nodesi[j] :+ ((Q.rmlT[i] :+ Q.t0):/2)	
			}
		}
		
		umat = J(Q.Mnodes, rows(Q.v),0)
		for(t=1;t<=cols(Q.rmlT);t++) {
			time_index = "rmltime" + strofreal(Q.rmlT[,t])
			for(i=1;i<=rows(Q.v);i++) {
				for(j=1;j<=Q.Mnodes;j++) {
					umat[j,i] = ((Q.v[i,t] :- Q.minT):/2):*Q.nodesi[j] :+ ((Q.v[i,t] :+ Q.minT):/2)
				}
			}
			asarray(Q.u, time_index, umat)
			asarray(Q.logu, time_index, log(umat))
		}
		
	}
		
	Q.modelN = strtoreal(st_local("modelN"))
	
	Q.models = J(1,Q.modelN,"")
	Q.dfbase = asarray_create()
	Q.dftvc = asarray_create("string", 2)
	Q.rcsbaseoff = asarray_create()
	Q.orthog = asarray_create()
	Q.hastvc = asarray_create()
	Q.knots = asarray_create("string", 2)
	Q.tvcknots = asarray_create()
	Q.hascons = asarray_create()
	Q.tvcnames = asarray_create()
	Q.Ntvc = asarray_create()
	Q.Rmatrix = asarray_create("string", 2)
	Q.Nvarlist = asarray_create()
	Q.hasvarlist = asarray_create()
	Q.touse_model = asarray_create()
	Q.Nobs_model = asarray_create()
	Q.X = asarray_create()
	Q.Xdrcs = asarray_create()
	Q.Nparameters = asarray_create()
	Q.beta = asarray_create()
	Q.betarcs = asarray_create("string", 2)
	Q.betacov = asarray_create()
	Q.V = asarray_create()
	Q.varlist = asarray_create()
	Q.varlistval = asarray_create()
	Q.xbcons = asarray_create()
	
	
	
	//store information for each model
	for(m=1;m<=Q.modelN;m++) {
				
		model_string = st_local("model"+strofreal(m))
		Q.models[1,m] = model_string
		modelstr_index = Q.models[1,m]
		
		stata("qui estimates restore "+modelstr_index)
	
		//store all of these in asarray with modelstr_index	
		
		asarray(Q.touse_model, modelstr_index, st_local("touse_"+modelstr_index))	
		asarray(Q.Nobs_model, modelstr_index, strtoreal(st_local("Nobs_"+modelstr_index)))
		asarray(Q.rcsbaseoff, modelstr_index,st_global("e(rcsbaseoff)") != "")
		asarray(Q.orthog, modelstr_index, st_global("e(orthog)") != "")
		asarray(Q.hascons, modelstr_index, st_global("e(noconstant)") == "")
		
		if(Q.hascons) asarray(Q.xbcons, modelstr_index, strtoreal(st_local("xbcons_"+modelstr_index)))
	
		
		//baseline stuff
		if(!asarray(Q.rcsbaseoff, modelstr_index)) asarray(Q.knots, (modelstr_index,"baseline") , strtoreal(tokens(st_global("e(ln_bhknots)"))))
		
		if(asarray(Q.orthog, modelstr_index) & !asarray(Q.rcsbaseoff, modelstr_index)) asarray(Q.Rmatrix,(modelstr_index,"baseline"),st_matrix("e(R_bh)"))
		else asarray(Q.Rmatrix,(modelstr_index,"baseline"),J(0,0,.))
		
		asarray(Q.Nvarlist, modelstr_index ,cols(tokens(st_global("e(varlist)"))))			
		asarray(Q.hasvarlist, modelstr_index, asarray(Q.Nvarlist, modelstr_index)>0)				
		asarray(Q.dfbase, modelstr_index, st_numscalar("e(dfbase)"))	

		//tvc stuff
		asarray(Q.hastvc, modelstr_index, st_global("e(tvc)") != "")	
		
		if(asarray(Q.hastvc, modelstr_index)) {
			
			asarray(Q.tvcnames, modelstr_index, tokens(st_global("e(tvc)")))
			asarray(Q.Ntvc, modelstr_index, cols(asarray(Q.tvcnames, modelstr_index)))
			
			
			for(j=1;j<=asarray(Q.Ntvc, modelstr_index);j++) {
				tvc_index = asarray(Q.tvcnames, modelstr_index)[j]
				
				asarray(Q.knots, (modelstr_index, tvc_index),strtoreal(tokens(st_global("e(ln_tvcknots_"+tvc_index+")")))) 
				asarray(Q.dftvc, (modelstr_index, tvc_index), st_numscalar("e(df_"+tvc_index+")"))
				
				if(asarray(Q.orthog, modelstr_index)) asarray(Q.Rmatrix, (modelstr_index, tvc_index) ,st_matrix("e(R_"+tvc_index+")"))
				else asarray(Q.Rmatrix,(modelstr_index, tvc_index),J(0,0,.))
				
			}
		}
		
		//get X matrix			
		covariates = J(1,0,"")
		drcsvars = J(1,0,"")
		if(asarray(Q.Nvarlist, modelstr_index)>0) {
			covariates = covariates, tokens(st_global("e(varlist)")) 
			asarray(Q.varlist, modelstr_index, covariates)
			asarray(Q.varlistval, modelstr_index, tokens(st_local("varval_"+modelstr_index)))
		}
		if(!asarray(Q.rcsbaseoff, modelstr_index)) {
			covariates = covariates, tokens(st_global("e(rcsterms_base)"))
			drcsvars = drcsvars, tokens(st_global("e(drcsterms_base)"))
		}
		if(asarray(Q.hastvc, modelstr_index)) {
				for(j=1;j<=asarray(Q.Ntvc, modelstr_index);j++) {
					tvc_index = asarray(Q.tvcnames, modelstr_index)[j]
					covariates = covariates, tokens(st_global("e(rcsterms_"+tvc_index+")"))
					drcsvars = drcsvars, tokens(st_global("e(drcsterms_"+tvc_index+")"))
				}
		}
		asarray(Q.X, modelstr_index, st_data(.,covariates,asarray(Q.touse_model,modelstr_index)))
		
		if(asarray(Q.hascons, modelstr_index)) asarray(Q.X, modelstr_index, (asarray(Q.X, modelstr_index),J(asarray(Q.Nobs_model, modelstr_index),1,1)))
		asarray(Q.Xdrcs, modelstr_index, st_data(.,drcsvars,asarray(Q.touse_model,modelstr_index)))
			
		//get parameter coefficients
		asarray(Q.Nparameters, modelstr_index, cols(asarray(Q.X, modelstr_index)))
		parameterN = asarray(Q.Nparameters, modelstr_index)
		varlistN = asarray(Q.Nvarlist, modelstr_index)
		asarray(Q.beta, modelstr_index, st_matrix("e(b)")'[1..parameterN,1])
		asarray(Q.betacov, modelstr_index, st_matrix("e(b)")'[1..varlistN,1])
		
		if(!asarray(Q.rcsbaseoff, modelstr_index)) {
			put = asarray(Q.beta, modelstr_index)[(varlistN+1)..(varlistN+asarray(Q.dfbase, modelstr_index))]
			asarray(Q.betarcs, (modelstr_index, "baseline"), put) 
		}
		
		if(!asarray(Q.rcsbaseoff, modelstr_index)) df = asarray(Q.dfbase, modelstr_index) + 1
		else df = 1
		if(asarray(Q.hastvc, modelstr_index)) {
			for(j=1;j<=asarray(Q.Ntvc, modelstr_index);j++) {
				tvc_index = asarray(Q.tvcnames, modelstr_index)[j]
				put = asarray(Q.beta, modelstr_index)[(varlistN+df)..(varlistN+asarray(Q.dftvc, (modelstr_index, tvc_index))+df-1)]
				asarray(Q.betarcs, (modelstr_index, tvc_index), put)  
				df = df + asarray(Q.dftvc, (modelstr_index, tvc_index))
			}
		}

		asarray(Q.V, modelstr_index, st_matrix("e(V)")[1..parameterN,1..parameterN])
		
		
		
	
	}
	
	if(!asarray(Q.rcsbaseoff, modelstr_index)) Q.Xrcsbase = asarray_create("string", 4)
	if(asarray(Q.hastvc, modelstr_index)) Q.Xrcstvc = asarray_create("string",4)
	
	if(!asarray(Q.rcsbaseoff, modelstr_index)) Q.Xdrcsbase = asarray_create("string", 4)
	if(asarray(Q.hastvc, modelstr_index)) Q.Xdrcstvc = asarray_create("string",4)
	
	Q.xb = J(Q.Mnodes,Q.modelN,0)
	for(m=1;m<=Q.modelN;m++) {
		modelstr_index = Q.models[1,m]
		var_index = asarray(Q.Nvarlist, modelstr_index)
		for(k=1;k<=var_index;k++) {
			for(j=1;j<=Q.Mnodes;j++) {
				x = strtoreal(asarray(Q.varlistval, modelstr_index)[,k])
				b = (asarray(Q.betacov, modelstr_index)[k,])
				Q.xb[j,m] = Q.xb[j,m] + b*x
			}
		}
		if(asarray(Q.hascons, modelstr_index)) { 
			Q.xb[,m] = Q.xb[,m] :+ asarray(Q.xbcons, modelstr_index) 
		}
	}
	
	Q.eta = asarray_create("string", 3)
	Q.rcsxb = asarray_create("string", 3)
	Q.drcsxb = asarray_create("string", 3)
	
	Q.st = asarray_create("string", 3)
	Q.ht = asarray_create("string", 3)
	Q.Ft = asarray_create("string", 3)
	Q.st_all = asarray_create("string", 2)
	Q.CIF = J(Q.Nt,Q.modelN,0)
	
	Q.LL = J(cols(Q.rmlT),Q.modelN,0)
	Q.Ftmat = asarray_create("string", 2)
	
	Q.A12_k = asarray_create("string", 3)
	
	
	return(Q)

}

void function genSplines(struct vars_structure scalar Q, lnt, modelstr_index, time_index, tstar) 
{	
	
	if(!asarray(Q.rcsbaseoff, modelstr_index)) {
		if(asarray(Q.orthog, modelstr_index)) asarray(Q.Xrcsbase, (modelstr_index,"baseline",time_index,tstar),rcsgen_core(lnt,asarray(Q.knots, (modelstr_index,"baseline")),0,asarray(Q.Rmatrix,(modelstr_index,"baseline"))))
		else asarray(Q.Xrcsbase, (modelstr_index,"baseline",time_index,tstar),rcsgen_core(lnt,asarray(Q.knots, (modelstr_index,"baseline")),0))
	}

	if(asarray(Q.hastvc, modelstr_index)) {
			for(j=1;j<=asarray(Q.Ntvc, modelstr_index);j++) {
				tvc_index = asarray(Q.tvcnames, modelstr_index)[j]
				
				if(asarray(Q.orthog, modelstr_index)) asarray(Q.Xrcstvc,(modelstr_index,tvc_index,time_index,tstar),rcsgen_core(lnt,asarray(Q.knots, (modelstr_index,tvc_index)),0,asarray(Q.Rmatrix,(modelstr_index,tvc_index))))
				else asarray(Q.Xrcstvc,(modelstr_index,tvc_index,time_index,tstar),rcsgen_core(lnt,asarray(Q.knots, (modelstr_index,tvc_index)),0))
			}
	}
	
}


void function genDerivSplines(struct vars_structure scalar Q, lnt, modelstr_index, time_index, tstar) 
{	
		
	if(!asarray(Q.rcsbaseoff, modelstr_index)) {
		if(asarray(Q.orthog, modelstr_index)) asarray(Q.Xdrcsbase, (modelstr_index,"baseline",time_index,tstar),rcsgen_core(lnt,asarray(Q.knots, (modelstr_index,"baseline")),1,asarray(Q.Rmatrix,(modelstr_index,"baseline"))))
		else asarray(Q.Xdrcsbase, (modelstr_index,"baseline",time_index,tstar),rcsgen_core(lnt,asarray(Q.knots, (modelstr_index,"baseline")),1))
	}

	if(asarray(Q.hastvc, modelstr_index)) {
			for(j=1;j<=asarray(Q.Ntvc, modelstr_index);j++) {
				tvc_index = asarray(Q.tvcnames, modelstr_index)[j]
				
				if(asarray(Q.orthog, modelstr_index)) asarray(Q.Xdrcstvc,(modelstr_index,tvc_index,time_index,tstar),rcsgen_core(lnt,asarray(Q.knots, (modelstr_index,tvc_index)),1,asarray(Q.Rmatrix,(modelstr_index,tvc_index))))
				else asarray(Q.Xdrcstvc,(modelstr_index,tvc_index,time_index,tstar),rcsgen_core(lnt,asarray(Q.knots, (modelstr_index,tvc_index)),1))
			}
	}
		
	
}

function genEta(struct vars_structure scalar Q, tstar, time_index, modelindex)
{

				
	m = modelindex
	modelstr_index = Q.models[1,m]
	asarray(Q.rcsxb, (modelstr_index, time_index, tstar), J(Q.Mnodes,1,0))
	asarray(Q.drcsxb, (modelstr_index, time_index, tstar), J(Q.Mnodes,1,0))
	
	if(!asarray(Q.rcsbaseoff, modelstr_index)) {
		el = asarray(Q.rcsxb, (modelstr_index, time_index, tstar)) + asarray(Q.Xrcsbase, (modelstr_index,"baseline",time_index,tstar))*asarray(Q.betarcs, (modelstr_index, "baseline"))
		asarray(Q.rcsxb, (modelstr_index, time_index, tstar), el)
		el2 = asarray(Q.drcsxb, (modelstr_index, time_index, tstar)) + asarray(Q.Xdrcsbase, (modelstr_index,"baseline",time_index,tstar))*asarray(Q.betarcs, (modelstr_index, "baseline"))
		asarray(Q.drcsxb, (modelstr_index, time_index, tstar), el2)
	}

	
	
	if(asarray(Q.hastvc, modelstr_index)) {
		for(j=1;j<=asarray(Q.Ntvc, modelstr_index);j++) {
			tvc_index = asarray(Q.tvcnames, modelstr_index)[j]

			for(k=1;k<=cols(Q.atList);k++) {
				//strtoreal(asarray(Q.varlistval, modelstr_index)[,k])
				if(Q.atList[,k]==tvc_index) {
					el = asarray(Q.rcsxb, (modelstr_index, time_index, tstar)) + asarray(Q.Xrcstvc, (modelstr_index,tvc_index,time_index, tstar))*asarray(Q.betarcs, (modelstr_index, tvc_index))*1
					asarray(Q.rcsxb, (modelstr_index, time_index, tstar), el)
					el2 = asarray(Q.drcsxb, (modelstr_index, time_index, tstar)) + asarray(Q.Xdrcstvc, (modelstr_index,tvc_index,time_index, tstar))*asarray(Q.betarcs, (modelstr_index, tvc_index))*1
					asarray(Q.drcsxb, (modelstr_index, time_index, tstar), el2)
				}
			}
			
			
		}
	}

	asarray(Q.eta, (modelstr_index, time_index, tstar), asarray(Q.rcsxb, (modelstr_index, time_index, tstar)) :+ Q.xb[,m])
	//if(asarray(Q.hascons, modelstr_index)) asarray(Q.eta, (modelstr_index, time_index, tstar), asarray(Q.eta, (modelstr_index, time_index, tstar)) :+ asarray(Q.xbcons, modelstr_index)) 

}

function genSurvFuncs(struct vars_structure scalar Q, time, tstar, time_index, modelindex)
{
	m = modelindex
	modelstr_index = Q.models[1,m]
	asarray(Q.st, (modelstr_index, time_index, tstar), exp(-exp(asarray(Q.eta, (modelstr_index, time_index, tstar)))))
	asarray(Q.ht, (modelstr_index, time_index, tstar), (1:/time):*asarray(Q.drcsxb, (modelstr_index, time_index, tstar)):*(exp(asarray(Q.eta, (modelstr_index, time_index, tstar)))))	
	asarray(Q.st_all, (time_index, tstar), asarray(Q.st_all, (time_index, tstar)):*asarray(Q.st, (modelstr_index, time_index, tstar)))
	
}

function genCIF(struct vars_structure scalar Q, tstar, time_index, t)
{
	
	
	
	for(m=1;m<=Q.modelN;m++) {
		
		model_string = st_local("model"+strofreal(m))
		Q.models[1,m] = model_string
		modelstr_index = Q.models[1,m]
		
		asarray(Q.Ft, (modelstr_index, time_index, tstar), asarray(Q.st_all, (time_index, tstar)):*asarray(Q.ht, (modelstr_index, time_index, tstar)))
		
		if(tstar=="cif") {
			tminus = (Q.t[t]:-Q.minT):/2
			Q.CIF[t,m] = tminus:*(Q.weightsi*(asarray(Q.Ft, (modelstr_index, time_index, tstar)):/1))
		}
		
	}
	
	
}

function genRML(struct vars_structure scalar Q, modelindex)
{
	m = modelindex
	modelstr_index = Q.models[1,m]
	
	tempFt = J(Q.Mnodes, Q.Mnodes, .)
	CB = J(Q.Mnodes,1,.)
	
	A = J(Q.Mnodes,rows(Q.v),.)
	for(t=1;t<=cols(Q.v);t++) {
		A[,t] = ((Q.weightsi' :* (Q.v[,t] :- Q.minT)):/2)
	}
	

	for(t=1;t<=cols(Q.rmlT);t++) {
		time_index = "rmltime" + strofreal(Q.rmlT[,t])
		tminus = (Q.rmlT[t]:-Q.minT):/2
		
		//construct master Ft matrix
		for(c=1;c<=rows(Q.v);c++) {
			tstar = "rml_"+strofreal(c)
			tempFt[,c] = asarray(Q.Ft, (modelstr_index, time_index, tstar))
		}			
		CB = (Q.weightsi*tempFt')
		done = CB*A[,t]
		asarray(Q.Ftmat, (modelstr_index, time_index), done)
		Q.LL[t,m] = tminus:*(asarray(Q.Ftmat, (modelstr_index, time_index)))
	}
	st_matrix("RML", Q.LL)
}

//Delta Method Main
void function deltaMethod(struct vars_structure scalar Q, pred, time_index, t) 
{
	
	for(m=1;m<=Q.modelN;m++) {
		modelstr_index = Q.models[1,m]
		
		//CIF
		if(pred=="cif") {	
			tstar = "cif"
		
			A12 = J(1,asarray(Q.Nparameters, modelstr_index),.)
			St_all = asarray(Q.st_all, (time_index, tstar))
			logSt_k = log(asarray(Q.st, (modelstr_index, time_index, tstar)))
			ht_k = asarray(Q.ht, (modelstr_index, time_index, tstar))	

			rcs_index = 1
			Ntvc_index = 0
			tvcrcs_index = 1
			tminus = (Q.t[t]:-Q.minT):/2	
			
			for(k=1;k<=asarray(Q.Nparameters, modelstr_index);k++) {	
				if(k<=asarray(Q.Nvarlist, modelstr_index) | (k==asarray(Q.Nparameters, modelstr_index) & asarray(Q.hascons, modelstr_index))) {
					if(k==asarray(Q.Nparameters, modelstr_index) & asarray(Q.hascons, modelstr_index)) { 
						x_k = 1
					
					}
					else {
						x_k = strtoreal(asarray(Q.varlistval, modelstr_index)[1,k])
					}
					
					eval = St_all :* ht_k :* x_k :* (logSt_k :+ 1)
					A12[1,k] = tminus:*(Q.weightsi*(eval))
					
				}
				else if (k>asarray(Q.Nvarlist, modelstr_index) & k<=(asarray(Q.Nvarlist, modelstr_index) +  asarray(Q.dfbase, modelstr_index) )){
					eval = St_all :* ht_k :* asarray(Q.Xrcsbase, (modelstr_index,"baseline",time_index,tstar))[,rcs_index] :* (logSt_k :+ 1)
					A12[1,k] = tminus:*(Q.weightsi*(eval))
					rcs_index++
				}
				else {
					
					if(k==(asarray(Q.Nvarlist, modelstr_index) +  asarray(Q.dfbase, modelstr_index))+1) {
						Ntvc_index = 1
					}
					else if (k==(asarray(Q.Nvarlist, modelstr_index) +  asarray(Q.dfbase, modelstr_index) + (asarray(Q.dftvc, (modelstr_index, tvc_index)))*Ntvc_index)+1) {
						//"check if you see this, not sure for more than 1 tvc"
						tvcrcs_index = 1
						Ntvc_index++
					}
					tvc_index = asarray(Q.tvcnames, modelstr_index)[1,Ntvc_index]
					for(j=1;j<=cols(Q.atList);j++) {
						if(Q.atList[,j]==tvc_index & strtoreal(asarray(Q.varlistval, modelstr_index)[1,j]) != 0) {
							eval = St_all :* ht_k :* (asarray(Q.Xrcstvc, (modelstr_index,tvc_index,time_index, tstar))[,tvcrcs_index]) :* (logSt_k :+ 1)
							A12[1,k] = tminus:*(Q.weightsi*(eval))
							tvcrcs_index++
						}
						else if (strtoreal(asarray(Q.varlistval, modelstr_index)[1,j]) == 0 | Q.atList[,j]!=tvc_index ) { // should it be 0 in tvc for derivative..
							x_k = 0
							eval = St_all :* ht_k :* x_k :* (logSt_k :+ 1)
							A12[1,k] = tminus:*(Q.weightsi*(eval))
							tvcrcs_index++
						}
					}
				}
			}
			asarray(Q.A12_k, (modelstr_index, time_index, pred), A12)
		}
		
		
		//RML
		if(pred=="rml") {
			
			mat_eval = asarray_create()			
			
			CB = J(Q.Mnodes,1,.)
			
			A = J(Q.Mnodes,rows(Q.v),.)
			for(c=1;c<=cols(Q.v);c++) {
				A[,c] = ((Q.weightsi' :* (Q.v[,c] :- Q.minT)):/2)
			}
			
			tminus = (Q.rmlT[t]:-Q.minT):/2
			
			rcs_index = 1
			Ntvc_index = 0
			tvcrcs_index = 1
			A12 = J(1,asarray(Q.Nparameters, modelstr_index),.)
			
			//construct master Ft matrix
			for(k=1;k<=asarray(Q.Nparameters, modelstr_index);k++) {
				param_index = "parameter_" + strofreal(k)
				//param_index
				//asarray(Q.Nparameters, modelstr_index)
				tempFt = J(Q.Mnodes, Q.Mnodes, .)
				templogSt_k = J(Q.Mnodes, Q.Mnodes, .)
				tempmat_k = J(Q.Mnodes, Q.Mnodes, .)
				x_k = J(Q.Mnodes, Q.Mnodes, .)
				//covariates
				for(c=1;c<=rows(Q.v);c++) {
					tstar = "rml_"+strofreal(c)
					
					tempFt[,c] = asarray(Q.Ft, (modelstr_index, time_index, tstar))
					templogSt_k[,c] = log(asarray(Q.st, (modelstr_index, time_index, tstar)))
					tempmat_k[,c] = tempFt[,c]:*(1 :+ templogSt_k[,c])
					
					if(k<=asarray(Q.Nvarlist, modelstr_index) | (k==asarray(Q.Nparameters, modelstr_index) & asarray(Q.hascons, modelstr_index))) {
						if(k==asarray(Q.Nparameters, modelstr_index) & asarray(Q.hascons, modelstr_index)) { 
							x_k[,c] = J(Q.Mnodes, 1, 1)
						}
						else {
							x_k[,c] = J(Q.Mnodes, 1, strtoreal(asarray(Q.varlistval, modelstr_index)[1,k]))
						}
						tempmat_k[,c] = tempmat_k[,c]:*x_k[,c]
						
					}
					else if (k>asarray(Q.Nvarlist, modelstr_index) & k<=(asarray(Q.Nvarlist, modelstr_index) +  asarray(Q.dfbase, modelstr_index) )){
						x_k[,c] = asarray(Q.Xrcsbase, (modelstr_index,"baseline",time_index,tstar))[,rcs_index]
						tempmat_k[,c] = tempmat_k[,c]:*x_k[,c]
						if(c==rows(Q.v)) rcs_index++
					}
					else {
						
						if(k==(asarray(Q.Nvarlist, modelstr_index) +  asarray(Q.dfbase, modelstr_index))+1) {
							if(c==1) Ntvc_index = 1
						}
						else if (k==(asarray(Q.Nvarlist, modelstr_index) +  asarray(Q.dfbase, modelstr_index) + (asarray(Q.dftvc, (modelstr_index, tvc_index)))*Ntvc_index)+1) {
							//"check if you see this, not sure for more than 1 tvc"
							if(c==1) tvcrcs_index = 1
							if(c==1) Ntvc_index++
						}
						tvc_index = asarray(Q.tvcnames, modelstr_index)[1,Ntvc_index]
						for(j=1;j<=cols(Q.atList);j++) {
							if(Q.atList[,j]==tvc_index & strtoreal(asarray(Q.varlistval, modelstr_index)[1,j]) != 0) {
								x_k[,c] = (asarray(Q.Xrcstvc, (modelstr_index,tvc_index,time_index, tstar))[,tvcrcs_index])
								tempmat_k[,c] = tempmat_k[,c]:*x_k[,c]
								if(c==rows(Q.v)) tvcrcs_index++
							}
							else if (strtoreal(asarray(Q.varlistval, modelstr_index)[1,j]) == 0 | Q.atList[,j]!=tvc_index ) { // should it be 0 in tvc for derivative..
								x_k[,c] = J(Q.Mnodes, 1, 0)
								tempmat_k[,c] = tempmat_k[,c]:*x_k[,c]
								if(c==rows(Q.v)) tvcrcs_index++
							}
						}
					}
				
				}
				
				asarray(mat_eval, param_index, tempmat_k)
				CB = (Q.weightsi*asarray(mat_eval, param_index))
				A12[1,k] = CB*A[,t]
				
			}		
			asarray(Q.A12_k, (modelstr_index, time_index, pred), tminus:*A12)
	
		}

		
	}

}

void function genCI(struct vars_structure scalar Q, time, pred) {

	if(pred=="cif") {
		Q.CIF_uci = J(time, Q.modelN,.)
		Q.CIF_lci = J(time, Q.modelN,.)
		for(m=1;m<=Q.modelN;m++) {
			modelstr_index = Q.models[1,m]
			for(t=1;t<=time;t++) {
				time_index = "time" + strofreal(t)

				G = asarray(Q.A12_k, (modelstr_index, time_index, "cif"))	
				Var = G*asarray(Q.V, modelstr_index)*G'
				theta = invnormal(1-(1-95/100)/2)*sqrt(diagonal(Var))
				
				Q.CIF_uci[t,m] = Q.CIF[t,m] + theta' 
				Q.CIF_lci[t,m] = Q.CIF[t,m] - theta' 
				
			}
			
		}
	}
	
	if(pred=="rml") {
	
		Q.LL_uci = J(cols(time), Q.modelN,.)
		Q.LL_lci = J(cols(time), Q.modelN,.)
		for(m=1;m<=Q.modelN;m++) {
			modelstr_index = Q.models[1,m]
			for(t=1;t<=cols(time);t++) {
				
				time_index = "rmltime" + strofreal(time[,t])
				
				G = asarray(Q.A12_k, (modelstr_index, time_index, "rml"))	
				
				Var = G*asarray(Q.V, modelstr_index)*G'
				
				theta = invnormal(1-(1-95/100)/2)*sqrt(diagonal(Var))
				
				Q.LL_uci[t,m] = Q.LL[t,m] + theta' 
				Q.LL_lci[t,m] = Q.LL[t,m] - theta' 

				
			}
			
		}
		
		LL_mat = J(cols(time), Q.modelN*3, .)
		for(i=1;i<=(Q.modelN*3);i=i+3) {
			j = ((i-1)/3) + 1
			i_lci = i+1
			i_uci = i+2
			LL_mat[,i] = Q.LL[,j]
			LL_mat[,i_lci] = Q.LL_lci[,j]
			LL_mat[,i_uci] = Q.LL_uci[,j]
		}
		st_matrix("RML", LL_mat)
		st_matrix("RML_Nt", time')
		
	}
	

}

function exportCIF(struct vars_structure scalar Q)
{

	for(m=1;m<=Q.modelN;m++) {

		modelstr_index = Q.models[1,m]
		
		(void) st_addvar("double",Q.newvarname+ "_" + modelstr_index)
		st_store(.,Q.newvarname+ "_" + modelstr_index,Q.touse_time,Q.CIF[,m])
		
		if(Q.ciopt) {
			(void) st_addvar("double",Q.newvarname+ "_" + modelstr_index + "_lci")
			st_store(.,Q.newvarname+ "_" + modelstr_index + "_lci",Q.touse_time,Q.CIF_lci[,m])
			
			(void) st_addvar("double",Q.newvarname+ "_" + modelstr_index + "_uci")
			st_store(.,Q.newvarname+ "_" + modelstr_index + "_uci",Q.touse_time,Q.CIF_uci[,m])
		}
			
	}
	
}

function exportRML(struct vars_structure scalar Q)
{

	for(m=1;m<=Q.modelN;m++) {
		Q.rml
		modelstr_index = Q.models[1,m]
		
		(void) st_addvar("double",Q.newvarname+ "_" + modelstr_index)
		st_store(.,Q.newvarname+ "_" + modelstr_index,Q.touse_time,Q.LL[,m])
		
		if(Q.ciopt) {
			(void) st_addvar("double",Q.newvarname+ "_" + modelstr_index + "_lci")
			st_store(.,Q.newvarname+ "_" + modelstr_index + "_lci",Q.touse_time,Q.LL_lci[,m])
			
			(void) st_addvar("double",Q.newvarname+ "_" + modelstr_index + "_uci")
			st_store(.,Q.newvarname+ "_" + modelstr_index + "_uci",Q.touse_time,Q.LL_uci[,m])
		}
			
	}
	
}


//======================================================================================================================================//
// rcsgen_core function - calculate splines with provided knots

real matrix rcsgen_core(	real colvector variable,	///
							real rowvector knots, 		///
							real scalar deriv,|			///
							real matrix rmatrix			///
						)
{
	real scalar  Nobs, Nknots, kmin, kmax, interior, Nparams
	real matrix splines, knots2

	//======================================================================================================================================//
	// Extract knot locations

	Nobs 	= rows(variable)
	Nknots 	= cols(knots)
	kmin 	= knots[1,1]
	kmax 	= knots[1,Nknots]

	if (Nknots==2) interior = 0
	else interior = Nknots - 2
	Nparams = interior + 1
	
	splines = J(Nobs,Nparams,.)

	//======================================================================================================================================//
	// Calculate splines

	if (Nparams>1) {
		lambda = J(Nobs,1,(kmax:-knots[,2..Nparams]):/(kmax:-kmin))
		knots2 = J(Nobs,1,knots[,2..Nparams])
	}

	if (deriv==0) {
		splines[,1] = variable
		if (Nparams>1) {
			splines[,2..Nparams] = (variable:-knots2):^3 :* (variable:>knots2) :- lambda:*((variable:-kmin):^3):*(variable:>kmin) :- (1:-lambda):*((variable:-kmax):^3):*(variable:>kmax) 
		}
	}
	else if (deriv==1) {
		splines[,1] = J(Nobs,1,1)
		if (Nparams>1) {
			splines[,2..Nparams] = 3:*(variable:-knots2):^2 :* (variable:>knots2) :- lambda:*(3:*(variable:-kmin):^2):*(variable:>kmin) :- (1:-lambda):*(3:*(variable:-kmax):^2):*(variable:>kmax) 	
		}
	}
	else if (deriv==2) {
		splines[,1] = J(Nobs,1,0)
		if (Nparams>1) {
			splines[,2..Nparams] = 6:*(variable:-knots2) :* (variable:>knots2) :- lambda:*(6:*(variable:-kmin)):*(variable:>kmin) :- (1:-lambda):*(6:*(variable:-kmax)):*(variable:>kmax) 	
		}
	}
	else if (deriv==3) {
		splines[,1] = J(Nobs,1,0)
		if (Nparams>1) {
			splines[,2..Nparams] = 6:*(variable:>knots2) :- lambda:*6:*(variable:>kmin) :- (1:-lambda):*6:*(variable:>kmax)
		}
	}

	//orthog
	if (args()==4) {
		real matrix rmat
		rmat = luinv(rmatrix)
		if (deriv==0) splines = (splines,J(Nobs,1,1)) * rmat[,1..Nparams]
		else splines = splines * rmat[1..Nparams,1..Nparams]
	}
	return(splines)
}

end


//=== Gaussian quadrature program borrowed from stgenreg ===============================================================
program define gaussquad, rclass
        syntax [, N(integer -99) LEGendre CHEB1 CHEB2 HERmite JACobi LAGuerre alpha(real 0) beta(real 0)]
        
    if `n' < 0 {
        display as err "need non-negative number of nodes"
                exit 198
        }
        if wordcount(`"`legendre' `cheb1' `cheb2' `hermite' `jacobi' `laguerre'"') > 1 {
                display as error "You have specified more than one integration option"
                exit 198
        }
        local inttype `legendre'`cheb1'`cheb2'`hermite'`jacobi'`laguerre' 
        if "`inttype'" == "" {
                display as error "You must specify one of the integration type options"
                exit 198
        }

        tempname weights nodes
        mata gq("`weights'","`nodes'")
        return matrix weights = `weights'
        return matrix nodes = `nodes'
end

mata:
        void gq(string scalar weightsname, string scalar nodesname)
{
        n =  strtoreal(st_local("n"))
        inttype = st_local("inttype")
        i = range(1,n,1)'
        i1 = range(1,n-1,1)'
        alpha = strtoreal(st_local("alpha"))
        beta = strtoreal(st_local("beta"))
                
        if(inttype == "legendre") {
                muzero = 2
                a = J(1,n,0)
                b = i1:/sqrt(4 :* i1:^2 :- 1)
        }
        else if(inttype == "cheb1") {
                muzero = pi()
                a = J(1,n,0)
                b = J(1,n-1,0.5)
                b[1] = sqrt(0.5)
    }
        else if(inttype == "cheb2") {
                muzero = pi()/2
                a = J(1,n,0)
                b = J(1,n-1,0.5)
        }
        else if(inttype == "hermite") {
                muzero = sqrt(pi())
                a = J(1,n,0)
                b = sqrt(i1:/2)
        }
        else if(inttype == "jacobi") {
                ab = alpha + beta
                muzero = 2:^(ab :+ 1) :* gamma(alpha :+ 1) * gamma(beta :+ 1):/gamma(ab :+ 2)
                a = i
                a[1] = (beta - alpha):/(ab :+ 2)
                i2 = range(2,n,1)'
                abi = ab :+ (2 :* i2)
                a[i2] = (beta:^2 :- alpha^2):/(abi :- 2):/abi
                b = i1
        b[1] = sqrt(4 * (alpha + 1) * (beta + 1):/(ab :+ 2):^2:/(ab :+ 3))
        i2 = i1[2..n-1]
        abi = ab :+ 2 :* i2
        b[i2] = sqrt(4 :* i2 :* (i2 :+ alpha) :* (i2 :+ beta) :* (i2 :+ ab):/(abi:^2 :- 1):/abi:^2)
        }
        else if(inttype == "laguerre") {
                a = 2 :* i :- 1 :+ alpha
                b = sqrt(i1 :* (i1 :+ alpha))
                muzero = gamma(alpha :+ 1)
    }

        A= diag(a)
        for(j=1;j<=n-1;j++){
                A[j,j+1] = b[j]
                A[j+1,j] = b[j]
        }
        symeigensystem(A,vec,nodes)
        weights = (vec[1,]:^2:*muzero)'
        weights = weights[order(nodes',1)]
        nodes = nodes'[order(nodes',1)']
        st_matrix(weightsname,weights)
        st_matrix(nodesname,nodes)
}
                
end


