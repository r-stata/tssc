*! version 0.6 30/04/2019
program define msaj, rclass sortpreserve
	version 14.2
	syntax [if][in],[	TRANSMatrix(name) 	///
						BY(varname) 		///
						GEN(string) 		///
						CI					///
						ENTER(real 0)		///
						EXIT(real -99)		///
						FROM(integer -99)	///
						CR					///
						ID(varname)			///
					]
	marksample touse
	if "`by'" != "" {
		qui replace `touse' = 0 if `by' == . 
		qui levelsof `by' if `touse', local(bylevels)
	}
	
	cap confirm variable _t, exact
	if _rc {
		di as error "data must be stset"
		exit 198
	}
	if "`id'" == "" {
		di as error "You must specify an ID variable using the id() option"
		exit 198
	}
	
	if "`transmatrix'" == "" & "`cr'" == "" {
		di as error "You must specify either the transmatrix() or cr option"
		exit 198
	}
	
	summ _t if `touse' & _d, meanonly
	if `exit' == -99 local exit `r(max)'
	
	if "`cr'" != "" {
		if "`transmatrix'" != "" {
			di "do not specify both the transmatrix and cr option"
			exit 198
		}
		summ _to if `touse', meanonly
		local tmpNstates `r(max)'
		tempname transmatrix
		matrix `transmatrix' = J(`tmpNstates',`tmpNstates',.)
		forvalues i = 2/`tmpNstates' {
			local tmptrans = `i' - 1
			matrix `transmatrix'[1,`i'] = `tmptrans'
		}
	}

	
	local Nstates = colsof(`transmatrix')
	if `Nstates'<2 {
		di as error "Must be at least 2 possible states, including starting state"
		exit 198
	}
/*	
	tempname fromuse
	if `from' !=-99 {
		forvalues i=1/`Nstates' {
					local finished 0
		while !`finished' {

				forvalues j=1/`Nstates' {
					if (`transmatrix'[`i',`j']!=.) {
					local state`i'_to `state`i'_to' `=`transmatrix'[`i',`j']'


		}
		forvalues i=1/`Nstates' {
			forvalues j=1/`Nstates' {
				if (`transmatrix'[`i',`j']!=.) {
					local row`i'trans `row`i'trans' `=`transmatrix'[`i',`j']'
					local row`i'next `row`i'next' `j'
				}
			}
			di "`row`i'next'"

		}
		
		//check somewhere to go
		if "`row`from'next'"=="" {
			di as error "No possible next states from(`frm')"
			exit 198
		}
		
		forvalue i = 1/`Nstates' {
			local fromposs`i' "`row`i'trans'"
			while `endstate'==0 {
				local ended 0
				foreach j in `fromposs`i'' {
					if row`j'trans == "" {
						local fromposs`i' `fromposs`i' j
						local added 1
					}
				}
					
				if "`row`i'trans`j''" == "" {
						local endstate 1
					}
					local fromposs`i' `fromposs`i'' `row`j'trans'
				}
			}
		}
		
	}
	else qui gen `fromuse' = 1
	*/
	
	if "`gen'" == "" {
		forvalues i = 1/`Nstates' {
			local newvars `newvars' P_AJ_`i'
			if "`ci'" != "" local newvars `newvars' P_AJ_`i'_lci P_AJ_`i'_uci
		}		
	}
	else {
		capture _stubstar2names double `gen', nvars(`Nstates') 
		local newvarslist `s(varlist)'
		if _rc>0 {
			di as error "gen() option should either give `Nstates' new variable names " ///
                                "or use the {it:stub*} option. The specified variable(s) probably exists."
			exit 198
		}
		if "`ci'" != "" {
			foreach nn in `newvarslist' {
				local newvars `newvars' `nn' `nn'_lci `nn'_uci
			}
		}
	}
	local Nnewvars = wordcount("`newvars'")
	forvalues i = 1/`Nnewvars' {
		local tmp = word("`newvars'",`i')
		qui gen double `tmp' = .
	}
			
	// Nrisk = N at risk for each transition
	// Nevents = number of events for each transition.

	tempname Nrisk Nevents Nevents_tot Nrisk_tot alpha_gh alpha_gg t_rank touse_t touse_all hasevent
	qui sts gen `Nrisk' = n if `touse', by(_trans `by')
	qui sts gen `Nevents' = d if `touse', by(_trans `by')

	qui levelsof _trans	
	foreach t in `r(levels)' {
		tempvar Nevents`t'
		qui sts gen `Nevents`t'' = d if _trans == `t' & `touse'
	}
	
// which individuals have events
	bysort `id' (_trans): egen `hasevent' = max(_d) if `touse'

// get data in right structure
	qui bysort  `touse' `hasevent' _t _from _trans `by' (`id'): gen `touse_t' = (_n==1)*(`hasevent') if `touse' 
	qui bysort `touse' `by' _t _from (_to): egen `Nevents_tot' = total(`Nevents') if `touse' & `touse_t'
	qui replace `touse_t' = 0 if `Nevents_tot' == 0 & `touse'
	qui gen `touse_all' = `touse'*`touse_t'
	
	
	qui bysort `touse_all' `by' _t _from (_trans): egen `Nrisk_tot' = max(`Nrisk') if `touse_all'
	qui gen double `alpha_gh' = `Nevents'/`Nrisk' if `touse_all' 
	qui gen double `alpha_gg' = -`Nevents_tot'/`Nrisk_tot'  if `touse_all'
	qui replace `alpha_gh' = 0 if missing(`alpha_gh') & `touse_all'

	qui replace `Nevents' = 0 if `Nevents' == . & `touse_all'
	//list _t _from _trans `Nevents_tot' `Nrisk_tot' `alpha_gh' `alpha_gg' `touse_t' `touse_all' if `touse_t'

//	rank of t (within by group)	
	if "`by'" == ""  qui egen `t_rank' = group(_t) if `touse_all'
	else {
		qui gen `t_rank' = .
		tempvar tmpt_rank
		foreach l of local bylevels {
			qui egen `tmpt_rank' = group(_t) if `by' == `l' & `touse_all'
			qui replace `t_rank' = `tmpt_rank'  if `by' == `l' & `touse_all'
			drop `tmpt_rank'
		}
	}
// now call mata to apply AJ equations	
	mata AJ()
	foreach newv in `newvars' {
		quietly bysort `by' _d _t (`id'):  replace `newv' = `newv'[1] if _d==1 & `touse'
	}
end

mata
void function AJ() 
{
	ci = st_local("ci") != ""		// indictator to calculate CIs
	touse = st_local("touse_all")
	t = st_data(.,"_t",touse)	
	d = st_data(.,"_d",touse)	
	
	if(st_local("by") != "") {
		by = st_data(.,st_local("by"),touse)
		bylevels = strtoreal(tokens(st_local("bylevels")))
	}
	else {
		bylevels = 1
		by = J(rows(t),1,1)
	}
	t_rank = st_data(.,st_local("t_rank"),touse)
	t_unique = uniqrows((by,t))
	Nt = rows(t_unique)
	Nt_return = rows(t)
	trans = st_data(.,"_trans",touse)
	from = st_data(.,"_from",touse)
	to = st_data(.,"_to",touse)
	transmat = st_matrix(st_local("transmatrix"))
	Ntrans = check_transmatrix(transmat)
	transmat_index = transRowCol(transmat)
	newvars = tokens(st_local("newvars"))
	alpha_gh = st_data(.,st_local("alpha_gh"),touse)
	alpha_gg = st_data(.,st_local("alpha_gg"),touse)
	Nstates = rows(transmat)
	Imat = I(Nstates)
	entertime = strtoreal(st_local("enter"))
	exittime = strtoreal(st_local("exit"))
	Nrisk = st_data(.,st_local("Nrisk_tot"),touse)
	Nevents = st_data(.,st_local("Nevents"),touse)

	if (ci) P_state = J(Nt_return,Nstates:*3,.)
	else P_state = J(Nt_return,Nstates,.)
// loop over by groups	
	for(k=1;k<=cols(bylevels);k++) {
		P = I(Nstates)
	
		if(ci)  {
			varP = J(Nstates:^2,Nstates:^2,0)
			VarAold = J(Nstates:^2,Nstates:^2,0)
		}
// loop over unique time points
		t_unique_by = select(t_unique[,2],t_unique[,1]:==bylevels[1,k])
		Ntby = rows(t_unique_by)
		for(i=1;i<=Ntby;i++) {
			current_t = t_unique_by[i,1]
			//if(current_t<entertime | current_t>exittime) continue
			// alpha
			alpha = J(Nstates,Nstates,0)
			diag_alpha = J(1,Nstates,0)
			tmp = select((from,alpha_gg),t_rank:==i :& by:==bylevels[1,k])
			diag_alpha[1,tmp[,1]'] = tmp[,2]'
			_diag(alpha,diag_alpha)
			for(j=1;j<=Ntrans;j++) {
				if(max(select(trans,t_rank :==i :& by:==bylevels[,k]) :== j)) {
					alpha[transmat_index[j,1],transmat_index[j,2]] = select(alpha_gh,t_rank:==i :& by:==bylevels[,k] :& trans:==j)
				}
			}
			if(ci) {
				// 1 = from, 2 = to, 3 = Nrisk, 4= Nevents, 
				RiskEvents = select((from,to,Nrisk,Nevents),t_rank:==i :& by:==bylevels[1,k])
				VarHaz = RiskEvents
				VarBlock = asarray_create("real",2) // l,m
				zeros = J(Nstates,Nstates,0)
				// This is inefficient, but simple
				// should try and reprogram
				// (l,n) blocks
				// (k,m) rows & cols within blocks
				for(vl = 1;vl<=Nstates;vl++) {
					for(vn = vl;vn<=Nstates;vn++) {
						tempBlock = zeros
						for(vk = 1;vk<=Nstates;vk++) {
							for(vm = vk;vm<=Nstates;vm++) {
								if(vk==vl & vk==vm & vk==vn) {
									if(sum(VarHaz[,1] :== vk)>0) {
										total_events =  sum(select(RiskEvents[,4],RiskEvents[,1]:==vk))
										atrisk = (select(RiskEvents[,3],RiskEvents[,1]:==vk))[1]
										tempBlock[vk,vm] = (atrisk - total_events)*total_events*atrisk^(-3)
									}						
								}
								if(vk==vl & vk==vm & vk!=vn) {
									if(sum(RiskEvents[,1] :== vk :& RiskEvents[,2]:==vn)>0) {
										total_events =  sum(select(RiskEvents[,4],RiskEvents[,1]:==vk))
										atrisk = (select(RiskEvents[,3],RiskEvents[,1]:==vk))[1]
										events_kn = (select(RiskEvents[,4],RiskEvents[,1]:==vk :& RiskEvents[,2]:==vn)) 
										tempBlock[vk,vm] = -(atrisk - total_events)*events_kn*atrisk^(-3)
									}
								}
								if(vk==vm & vk!=vl & vk!=vn) {
									if(sum(VarHaz[,1] :== vk :& VarHaz[,2]:==vl)>0) {
										atrisk = (select(RiskEvents[,3],RiskEvents[,1]:==vk))[1]
										events_kl = (select(RiskEvents[,4],RiskEvents[,1]:==vk :& RiskEvents[,2]:==vl)) 
										events_kn = (select(RiskEvents[,4],RiskEvents[,1]:==vk :& RiskEvents[,2]:==vn)) 
										delta_ln = (sum(RiskEvents[,1]:==vl :& RiskEvents[,2]:==vn):>0) :| (vl :== vn)
										tempBlock[vk,vm] = (delta_ln*atrisk - events_kl)*events_kn*atrisk^(-3)
									}
								}
							}
						}
						asarray(VarBlock,(vl,vn),tempBlock)
					}
				}
				VarAd = J(Nstates:^2,Nstates:^2,0)
				for(vl = 1;vl<=Nstates;vl++) {
					for(vn = vl;vn<=Nstates;vn++) {
						trows = ((vl-1)*Nstates+1)..((vl-1)*Nstates+Nstates)
						tcols = ((vn-1)*Nstates+1)..((vn-1)*Nstates+Nstates)
						VarAd[trows,tcols] = asarray(VarBlock,(vl,vn))
					}
				}
				VarAd = makesymmetric((VarAd'))
				
				tmp1 = ((Imat + alpha)' # Imat) * varP * ((Imat + alpha) # Imat)
				tmp2 = (Imat # P) * VarAd * (Imat # P')
				varP = tmp1 + tmp2	
			}
			P = P*(Imat + alpha)
			res_index = selectindex(t_rank:==i :& d:==1 :& by:==bylevels[1,k])
			if(ci) {
				seP = (rowshape(sqrt(diagonal(varP)),Nstates)[,1])'
				for(j=1;j<=Nstates;j++) {
					P_colindex = (3*(j-1)+1)
					P_state[res_index,P_colindex..P_colindex+2] = J(rows(res_index),1,(P[1,j], P[1,j] :-1.96:*seP[1,j], P[1,j] :+1.96:*seP[1,j]))
				}
	
			}
			else P_state[res_index,] = J(rows(res_index),1,P[1,])
		}
	}
	P_state = 0:*(P_state:<0) :+ 1:*(P_state:>1) :+ P_state:*(P_state:>0 :& P_state:<1)
	st_store(.,newvars,touse,P_state)
}

// adapted from Michael Crowther's code. 
// Does checks and returns No. of transitions
function check_transmatrix(tmat)
{
        tmat_ind = tmat:!=.                                                     //indicator matrix
 
		//Error checks
        if (max(diagonal(tmat_ind))>0) {
                errprintf("All elements on the diagonal of transmatrix() must be coded missing = .\n")
                exit(198)
        }
        if (max(lowertriangle(tmat_ind))>0) {
                errprintf("All elements of the lower triangle of transmatrix() must be coded missing = .\n")
                exit(198)
        }
        row = 1
        rtmat = rows(tmat)
        trans = 1
        while (row<rtmat) {
                for (i=row+1;i<=rtmat;i++) {
                        if (sum(tmat:==tmat[row,i])>1 & tmat[row,i]!=.) {
                                errprintf("Elements in the upper triangle of transmatrix() are not unique\n")
                                exit(198)
                        }
                        if (tmat[row,i]!=. & tmat[row,i]!=trans){
                                errprintf("Elements in the upper triangle of transmatrix() must be sequentially numbered from 1,...,K, where K = number of transitions\n")
                                exit(198)
                        }               
                        if (tmat[row,i]!=.) trans++
                }
                row++
        }
        return(trans-1)
}

// creates to/from states for each transition
function transRowCol(tmat)
{
	tmat_index = J(max(tmat),2,.)
	row = 1
	rtmat = rows(tmat)
	trans = 1

	while (row<rtmat) {
		for (i=row+1;i<=rtmat;i++) {
			if(tmat[row,i] == trans) {
				tmat_index[trans,] = (row,i)
				trans++
			}
		}
		row++
	}
	return(tmat_index)
}
end
