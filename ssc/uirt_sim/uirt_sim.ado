*uirt_sim.ado 
*ver 1.0
*compatible with item parameters provided by uirt.ado ver 1.0 and higher
*2020.03.25
*everythingthatcounts@gmail.com


capture prog drop uirt_sim
program define uirt_sim
version 10
	syntax [namelist], /// a list of items to select from ipar() matrix if one wants to generate a dataset for just some of the items listed in ipar(); not a varlist - exact list needed; optional
		IPar(namelist max=1) /// item parameters; a stata matrix specified as in uirt.ado output; obligatory
		[Mean(real 0) /// mean of normal distribution of theta; used if theta() or grpar() are not provided; default - 0
		sd(real 1) /// sd of normal distribution of theta; used if theta() or grpar() are not provided; default - 1
		Obs(integer 1000) /// total number of generated observations; used if theta() or grn() are not provided; default - 1000; does not handle expotentials like 10^4
		THeta(varname numeric) /// name of stata variable with theta values provided by the user; if specified mean() and sd() and obs() and grpar() and grn() options are ignored
		GRoup(varname numeric) /// name of stata variable with grouping variable provided by the user; requires theta() or properly specified grpar();
		ADDtheta /// if specified additional "theta" variable is added at the end of the dataset; the variable contains theta values used in generating responses for eah observtion; ignored if theta() is provided by the user
		GRPar(namelist max=1) /// parameters of normal distribution of theta in each group; for single group can be replaced by setting mean() and sd(); a stata matrix specified as in uirt.ado output
		grn(namelist max=1) /// total number of observations in each group; for single group can be replaced by setting obs(); a stata matrix specified as in uirt.ado output
		igrn(namelist max=1) /// number of observations for each item in each group; if an item has less observations in a group that specified in obs() or grn(), the missing responses will be generated at random; a stata matrix specified as in uirt.ado output
		ICats(namelist max=1)] // list of item categories, if not specified the responses are generated as consequtive integers 0,1,...,max_cat where max_cat is inferred from ipar() matrix; a stata matrix specified as in uirt.ado output

		if(strlen("`addtheta'")==0){
			m: addtheta=0
		}
		else{
			if(strlen("`theta'")==0){
				m: addtheta=1
			}
			else{
				m: addtheta=0
				display  "Note: you asked to use `theta' variable so addtheta option will be ignored"
			}
		}
		
		if(strlen("`grpar'")>0){
			local grpar_cols=colsof("`grpar'")
			if(`grpar_cols'==0){
				m: _error("`grpar' matrix has 0 columns")
			}
			if(`grpar_cols'==.){
				mat l `grpar'
			}
			
			local distring="Note: you asked to use `grpar' matrix so options"
			if(`mean'!=0){
				local distring="`distring' mean(`mean')"
				local mean=0
			}
			if(`sd'!=1){
				local distring="`distring' sd(`sd')"
				local sd=1
			}			
			if("`distring'"!="Note: you asked to use `grpar' matrix so options"){
				local distring="`distring' will be ignored"
				display "`distring'"
			}
			
		}
		else{
			local grpar_cols=0
		}
		
		if(strlen("`grn'")>0){
			local grn_cols=colsof("`grn'")
			if(`grn_cols'==0){
				m: _error("`grn' matrix has 0 columns")
			}
			if(`grn_cols'==.){
				mat l `grn'
			}
		}
		else{
			local grn_cols=0
		}
		
		if(strlen("`igrn'")>0){
			local igrn_cols=colsof("`igrn'")
			if(`igrn_cols'==0){
				m: _error("`igrn' matrix has 0 columns")
			}
			if(`igrn_cols'==.){
				mat l `igrn'
			}
		}
		else{
			local igrn_cols=0
		}
		
		
		if(strlen("`theta'")==0){
			m: theta=J(0,0,.)
		}
		else{
			
			m: st_local("theta_missing",strofreal(missing(st_data(.,"`theta'"))))
			if(`theta_missing'>0){
				m: _error("`theta' variable has `theta_missing' missing values, this is not allowed for theta() in uirt_sim")
			}
			else{
				m: theta=st_data(.,"`theta'")
			}
			macro drop _theta_missing
			
			
			
			local distring="Note: you asked to use `theta' variable so options"
			local multigroupcommands=""
			if(`mean'!=0){
				local distring="`distring' mean(`mean')"
			}
			if(`sd'!=1){
				local distring="`distring' sd(`sd')"
			}			
			if(`obs'!=1000){
				local distring="`distring' obs(`obs')"
			}
			if(strlen("`grpar'")>0){
				local distring="`distring' grpar(`grpar')"
				if(`grpar_cols'>1){
					local multigroupcommands="`multigroupcommands' grpar(`grpar') "
				}
				local grpar_cols=0
			}
			if(strlen("`grn'")>0){
				local distring="`distring' grn(`grn')"
				if(`grn_cols'>1){
					local multigroupcommands="`multigroupcommands' grn(`grn') "
				}
				local grn_cols=0
			}
			
			
			if("`distring'"!="Note: you asked to use `theta' variable so options"){
				local distring="`distring' will be ignored"
				display "`distring'"
			}
			if("`multigroupcommands'"!="" & strlen("`group'")==0){
					display "Note:... furthermore, the size of `multigroupcommands' indicate an intention to generate multigroup data, if so please define group() if you want to use the theta() option"
					display "Note:... the dataset will be generated as in a single group setting"
					local multigroup=0
			}	
		}
		
		
		
		
		if(strlen("`group'")==0){
			m: group=J(0,0,.)
			if(`grpar_cols'>1){
				local multigroup=1
			}
			else{
				local multigroup=0
				if(`grn_cols'>1){
					m: _error("grn() matrix has `grn_cols' columns, more information needed to generate multigroup dataset")
				}
			}
		}
		else{
			m: st_local("group_missing",strofreal(missing(st_data(.,"`group'"))))
			if(`group_missing'>0){
				m: _error("`group' variable has `group_missing' missing values, this is not allowed for group() in uirt_sim")
			}
			else{
				m: group=st_data(.,"`group'")
			}
			macro drop _group_missing
			
			if(strlen("`grpar'")==0 & strlen("`theta'")==0){
				m: _error("you asked to use `group' variable for grouping so you have to provide either theta() or grpar()")
			}
			
			if(strlen("`theta'")==0){
				local distring="Note: you asked to use `group' variable for grouping so options"
				if(`mean'!=0){
					local distring="`distring' mean(`mean')"
				}
				if(`sd'!=1){
					local distring="`distring' sd(`sd')"
				}			
				if(`obs'!=1000){
					local distring="`distring' obs(`obs')"
				}
				if(strlen("`grn'")>0){
					local distring="`distring' grn(`grn')"
					local grn_cols=0
				}
				if("`distring'"!="Note: you asked to use `group' variable for grouping so options"){
					local distring="`distring' will be ignored"
					display "`distring'"
				}
			}
			
			m:  st_local("N_gr",strofreal(rows(uniqrows(st_data(.,"`group'")))))
			if(`N_gr'==1){
				m: group=J(0,0,.)
				local multigroup=0
				display  "Note: you asked to use `group' variable for grouping but it has only one-value"
			}
			else{
				local multigroup=2
				m: group=st_data(.,"`group'")
			}
		}
	
		m: group_par=st_tempname()
		m: group_N=st_tempname()
		m: item_group_N=st_tempname()
		m: icats=st_tempname()

							
		if(`multigroup'==0){
			
			if(`igrn_cols'>1){
				m: _error("igrn() matrix has `igrn_cols' colums, this is not interpretable in single group setting")
			}
			else{
				if(`igrn_cols'==1){
					m: stata("matrix "+item_group_N+"=`igrn'")
				}
			}
			
			if(strlen("`theta'")==0){
				if(`grn_cols'==0){
					m: st_matrix(group_N,`obs')
					m: st_matrixrowstripe(group_N,("","N"))
					m: st_matrixcolstripe(group_N,("","group_1"))
				}
				if(`grn_cols'==1){
					m: stata("matrix "+group_N+"=`grn'")
				}
	
				if(`grpar_cols'==0){
					m: st_matrix(group_par,(`mean' \ `sd'))
					m: st_matrixrowstripe(group_par,(J(2,1,""),("mean"\"sd")))
					m: st_matrixcolstripe(group_par,("","group_1"))
				}
				if(`grpar_cols'==1){
					m: stata("matrix "+group_par+"=`grpar'")
				}
			}
			
		}
		
		
		if(`multigroup'==1){
			if(`igrn_cols'!=0 & `igrn_cols'!=`grpar_cols'){
				m: _error("igrn() matrix has `igrn_cols' colums and grpar() matrix has `grpar_cols' colums")
			}
			if(`igrn_cols'!=0){
				m: stata("matrix "+item_group_N+"=`igrn'")
			}

			if(`grn_cols'!=0 & `grn_cols'!=`grpar_cols'){
				m: _error("grn() matrix has `grn_cols' colums and grpar() matrix has `grpar_cols' colums")
			}
			if(`grn_cols'==0){
				m: st_matrix(group_N,J(1,`grpar_cols',`obs'))
				m: st_matrixrowstripe(group_N,("","N"))
				m: st_matrixcolstripe(group_N,st_matrixcolstripe("`grpar'"))
			}
			else{
				m: stata("matrix "+group_N+"=`grn'")
			}
			m: stata("matrix "+group_par+"=`grpar'")
		}
		
		if(`multigroup'==2){
			if(`igrn_cols'!=0 & `igrn_cols'!=`N_gr'){
				m: _error("igrn() matrix has `igrn_cols' colums and group() variable has `N_gr' unique values")
			}
			if(`igrn_cols'!=0){
				m: stata("matrix "+item_group_N+"=`igrn'")
			}
			
			if(strlen("`theta'")==0){
				if(`grpar_cols'!=`N_gr'){
					m: _error("grpar() matrix has `grpar_cols' colums and group() variable has `N_gr' unique values")
				}
				m: stata("matrix "+group_par+"=`grpar'")
			}
			
			m: uniqgrvals=uniqrows(group)
			m: gr_n=colsum(J(1,rows(uniqgrvals),group):==uniqgrvals')
			m: st_matrix(group_N,gr_n)
			m: st_matrixrowstripe(group_N,("","N"))
			m: st_matrixcolstripe(group_N,(J(rows(uniqgrvals),1,""),("group":+strtoname(strofreal(uniqgrvals)))))			
			
		}		
		
		if(strlen("`icats'")){
			local icats_cols=colsof("`igrn'")
			if(`icats_cols'==0){
				m: _error("`icats' matrix has 0 columns")
			}
			if(`icats_cols'==.){
				mat l `icats'
			}
			m: stata("matrix "+icats+"=`icats'")
		}
		
			
		m: irt_simulate("`namelist'","`ipar'",group_par, group_N, item_group_N, theta, group, `multigroup', addtheta,icats)
		
		m: stata("cap matrix drop "+group_par)
		m: stata("cap matrix drop "+group_N)
		m: stata("cap matrix drop "+item_group_N)
		m: stata("cap matrix drop "+icats)
end




mata
	void irt_simulate(string scalar namelist, string scalar parameters, string scalar group_par, string scalar group_N, string scalar item_group_N, real matrix theta, real matrix group, real scalar multigroup, real scalar addtheta, string matrix icats){
	
		grn=st_matrix(group_N)
		grpar=st_matrix(group_par)
	
		item_names_matrix0=st_matrixrowstripe(parameters)[.,1]
		item_models_matrix0=st_matrixrowstripe(parameters)[.,2]
		item_param_matrix0=st_matrix(parameters)		
	
		if(tokens(namelist)==J(1,0,"")){
			item_names_matrix=item_names_matrix0
			item_models_matrix=item_models_matrix0
			item_param_matrix=item_param_matrix0
		}
		else{
			item_names_matrix=J(0,1,"")
			item_models_matrix=J(0,1,"")
			item_param_matrix=J(0,cols(item_param_matrix0),.)
			requested_item_names=tokens(namelist)'
			common_sum=0
			for(i=1;i<=rows(requested_item_names);i++){
				for(j=1;j<=rows(item_names_matrix0);j++){
					if(requested_item_names[i,1]==item_names_matrix0[j]){
						common_sum++
						item_names_matrix=item_names_matrix\item_names_matrix0[j]
						item_models_matrix=item_models_matrix\item_models_matrix0[j]
						item_param_matrix=item_param_matrix\item_param_matrix0[j,.]
					}
				}
			}
			display(strofreal(rows(requested_item_names))+" item names requested, "+strofreal(rows(item_names_matrix0))+" item names found in matrix "+parameters+", "+strofreal(common_sum)+" common item names")
		}
		
		

		
		if (rows(item_names_matrix)==0){
			_error("There are no common item names in requested list and "+parameters+" matrix")
		}
		
		item_n=rows(item_names_matrix)
		
		item_group_N_user=st_matrix(item_group_N)
		igrn=J(item_n,1,grn)
		if(rows(item_group_N_user)){
		
			if(sum(st_matrixcolstripe(item_group_N):!=st_matrixcolstripe(group_N))){
				if(rows(group)==0){
					_error("colum names of igrn() matrix differ from column names of grn() matrix")
				}
				else{
					_error("colum names of igrn() matrix does not match the unique values of group() variable")
				}
			}
			
			common_sum=0
			uncommon_sum=0
			itemlist_igrn=st_matrixrowstripe(item_group_N)[.,2]
			for(i=1;i<=item_n;i++){
				ind=select((1::rows(itemlist_igrn)),itemlist_igrn:==item_names_matrix[i])
				if(rows(ind)==1){
					igrn[i,.]=item_group_N_user[ind,.]
					common_sum=common_sum+1
				}
				else{
					uncommon_sum=uncommon_sum+1
				}
			}
			display(strofreal(common_sum)+" items found in igrn() matrix")
			if(uncommon_sum){
				display(strofreal(uncommon_sum)+" items not found in igrn() matrix, their frequency will be defaulted by contents of grn() matrix")
			}
		}
		
		for(g=1;g<=cols(grn);g++){
			if(max(igrn[.,g])>grn[g]){
				_error("number of observations in igrn() matrix is larger than number of observations in group(s)")
			}
		}
		
		if(multigroup==0){
			if(rows(theta)==0){
				if(sum(st_matrixcolstripe(group_par):!=st_matrixcolstripe(group_N))){
					_error("colum names of grpar() matrix differ from column names of grn() matrix")
				}
				theta=rnormal(grn,1,grpar[1],grpar[2])
			}
		}
		if(multigroup==1){
			if(sum(st_matrixcolstripe(group_par):!=st_matrixcolstripe(group_N))){
				_error("colum names of grpar() matrix differ from column names of grn() matrix")
			}
			theta=J(0,1,.)
			group=J(0,1,.)
			for(g=1;g<=cols(grn);g++){
				theta=theta\rnormal(grn[g],1,grpar[1,g],grpar[2,g])
				group=group\J(grn[g],1,strtoreal(subinstr((st_matrixcolstripe(group_N)[g,2]),"group_","")))
			}
		}
		if(multigroup==2){
			if(rows(theta)==0){
				if(sum(st_matrixcolstripe(group_par):!=st_matrixcolstripe(group_N))){
					_error("colum names of grpar() matrix does not match the unique values of group() variable")
				}
				theta=J(0,1,.)
				for(g=1;g<=cols(grn);g++){
					theta=theta\rnormal(grn[g],1,grpar[1,g],grpar[2,g])
				}
			}
		}
		

		
		icats_user=st_matrix(icats)
		icats_dummy=J(item_n,cols(item_param_matrix),.)
		if(rows(icats_user)){
		
			if(cols(icats_user)>cols(icats_dummy)){
				icats_dummy=icats_dummy,J(rows(icats_dummy),cols(icats_user)-cols(icats_dummy),.)
			}
			if(cols(icats_dummy)>cols(icats_user)){
				icats_user=icats_user,J(rows(icats_user),cols(icats_dummy)-cols(icats_user),.)
			}

			common_sum=0
			uncommon_sum=0
			itemlist_icats=st_matrixrowstripe(icats)[.,2]
			for(i=1;i<=item_n;i++){
				ind=select((1::rows(itemlist_icats)),itemlist_icats:==item_names_matrix[i])
				if(rows(ind)==1){
					icats_dummy[i,.]=icats_user[ind,.]
					common_sum=common_sum+1
				}
				else{
					uncommon_sum=uncommon_sum+1
				}
			}
			display(strofreal(common_sum)+" items found in icats() matrix, these will be used if are not in conflict with number of categories defined in ipar() matrix")
			if(uncommon_sum){
				display(strofreal(uncommon_sum)+" items not found in icats() matrix, their categories will be defaulted")
			}
		}
		
		
		sample_size=rows(theta)
		
		X=J(sample_size,item_n,.)
		
		for(itemrow=1;itemrow<=item_n;itemrow++){
			p=runiform(sample_size,1)
			
			if (item_models_matrix[itemrow]=="2plm" | (nonmissing(item_param_matrix[itemrow,.])==2 & item_models_matrix[itemrow]=="pcm")){
				xp=invlogit(item_param_matrix[itemrow,1]*(theta-J(sample_size,1,item_param_matrix[itemrow,2])))
				x=0.5*(sign(xp-p)+J(sample_size,1,1))
				
				max_c=1
				if(nonmissing(icats_dummy[itemrow,.])){
					if(nonmissing(icats_dummy[itemrow,.])==(max_c+1) & nonmissing(icats_dummy[itemrow,1..(max_c+1)])==(max_c+1)){
						ind=J(0,1,.)
						newcats=J(0,1,.)
						for(c=0;c<=max_c;c++){
							indcat=select(1::rows(x),x:==c)
							ind=ind\indcat
							newcats=newcats\J(rows(indcat),1,icats_dummy[itemrow,c+1])
						}
						x[ind]=newcats
					}
					else{
						display("Note: icats() matrix entry for item "+item_names_matrix[itemrow]+" do not agree with the number of categories in ipar() matrix, item categories will be defaulted")
					}
				}
				
			}
			
			if (item_models_matrix[itemrow]=="3plm"){
				xp=J(sample_size,1,item_param_matrix[itemrow,3])+(1-item_param_matrix[itemrow,3])*invlogit(item_param_matrix[itemrow,1]*(theta-J(sample_size,1,item_param_matrix[itemrow,2])))
				x=0.5*(sign(xp-p)+J(sample_size,1,1))
				
				max_c=1
				if(nonmissing(icats_dummy[itemrow,.])){
					if(nonmissing(icats_dummy[itemrow,.])==(max_c+1) & nonmissing(icats_dummy[itemrow,1..(max_c+1)])==(max_c+1)){
						ind=J(0,1,.)
						newcats=J(0,1,.)
						for(c=0;c<=max_c;c++){
							indcat=select(1::rows(x),x:==c)
							ind=ind\indcat
							newcats=newcats\J(rows(indcat),1,icats_dummy[itemrow,c+1])
						}
						x[ind]=newcats
					}
					else{
						display("Note: icats() matrix entry for item "+item_names_matrix[itemrow]+" do not agree with the number of categories in ipar() matrix, item categories will be defaulted")
					}
				}
			}
			
			if (item_models_matrix[itemrow]=="grm"){
				if(sum(item_models_matrix0:=="3plm")>0){
					start_grm=4
				}
				else{
					if(sum(item_models_matrix0:=="2plm")>0){
						start_grm=3
					}
					else{
						start_grm=2
					}
					
				}
				x=J(sample_size,1,0)
				for (i=start_grm;i<=start_grm+nonmissing(item_param_matrix[itemrow,.])-2;i++){
					xp=invlogit(item_param_matrix[itemrow,1]*(theta:-item_param_matrix[itemrow,i]))
					x=x+0.5*(sign(xp-p)+J(sample_size,1,1))
				}

				max_c=nonmissing(item_param_matrix[itemrow,.])-1
				if(nonmissing(icats_dummy[itemrow,.])){
					if(nonmissing(icats_dummy[itemrow,.])==(max_c+1) & nonmissing(icats_dummy[itemrow,1..(max_c+1)])==(max_c+1)){
						ind=J(0,1,.)
						newcats=J(0,1,.)
						for(c=0;c<=max_c;c++){
							indcat=select(1::rows(x),x:==c)
							ind=ind\indcat
							newcats=newcats\J(rows(indcat),1,icats_dummy[itemrow,c+1])
						}
						x[ind]=newcats
					}
					else{
						display("Note: icats() matrix entry for item "+item_names_matrix[itemrow]+" do not agree with the number of categories in ipar() matrix, item categories will be defaulted")
					}
				}
			}
			
			if ((item_models_matrix[itemrow]=="pcm" & nonmissing(item_param_matrix[itemrow,.])>2)|item_models_matrix[itemrow]=="gpcm"){
			
				if(sum(item_models_matrix0:=="3plm")){
					start_pcm=4
				}
				else{
					if(sum(item_models_matrix0:=="2plm")>0){
						start_pcm=3
					}
					else{
						start_pcm=2
					}
					
				}
				
				n_par=nonmissing(item_param_matrix[itemrow,.])-1
				
				a_theta_b=J(sample_size,n_par,1)
				for(i=1;i<=n_par;i++){
					a_theta_b[.,i]=item_param_matrix[itemrow,1]:*(theta:-item_param_matrix[itemrow,start_pcm+i-1])
				}
				
				e_sum_a_theta_b=J(sample_size,n_par,1)
				for(i=1;i<=n_par;i++){
					e_sum_a_theta_b[.,i]=exp(rowsum(a_theta_b[.,1..i]))
				}
				
				a_theta_b=J(0,0,.)
				denominator=(1:+rowsum(e_sum_a_theta_b))
				
				cat_p=e_sum_a_theta_b:/denominator
				e_sum_a_theta_b=J(0,0,.)
				denominator=J(0,0,.)
				xp=J(sample_size,n_par,1)
				xp[.,1]=(1:-rowsum(cat_p))
				for(i=2;i<=n_par;i++){
					xp[.,i]=xp[.,i-1]:+cat_p[.,i-1]
				}
				
				x=rowsum(xp:<p)
				
				max_c=nonmissing(item_param_matrix[itemrow,.])-1
				if(nonmissing(icats_dummy[itemrow,.])){
					if(nonmissing(icats_dummy[itemrow,.])==(max_c+1) & nonmissing(icats_dummy[itemrow,1..(max_c+1)])==(max_c+1)){
						ind=J(0,1,.)
						newcats=J(0,1,.)
						for(c=0;c<=max_c;c++){
							indcat=select(1::rows(x),x:==c)
							ind=ind\indcat
							newcats=newcats\J(rows(indcat),1,icats_dummy[itemrow,c+1])
						}
						x[ind]=newcats
					}
					else{
						display("Note: icats() matrix entry for item "+item_names_matrix[itemrow]+" do not agree with the number of categories in ipar() matrix, item categories will be defaulted")
					}
				}
				
			}
			
			X[.,itemrow]=x
		}

		if( rows(group) & sum(igrn:!=grn) ){
			uniqgrvals=uniqrows(group)
			for(g=1;g<=rows(uniqgrvals);g++){
				ind_gr=select((1::sample_size),group:==uniqgrvals[g])
				for(i=1;i<=item_n;i++){
					if(igrn[i,g]==0){
						X[ind_gr,i]=J(grn[g],1,.)
					}
					else{
						if(igrn[i,g]<grn[g]){
							sampl_ind_gr=jumble(ind_gr)[1::(grn[g]-igrn[i,g])]
							X[sampl_ind_gr,i]=J(rows(sampl_ind_gr),1,.)
						}
					}
				}
			}
		}
		
		obs_in_dataset=st_nobs()
		if(sample_size>obs_in_dataset){
			st_addobs(sample_size-obs_in_dataset)
		}
		
		varindex=st_addvar("byte",item_names_matrix')
		st_store(.,item_names_matrix',X)

		displaytheta=""
		if(addtheta){
			varindex=st_addvar("double","theta")
			st_store(.,"theta",theta)
			displaytheta="+ theta variable"
		}
		
		displaygroup=""
		if(multigroup==1){
			varindex=st_addvar("double","group")
			st_store(.,"group",group)
			displaygroup="+ group variable"
		}
		
		display("Hurrey! A "+strofreal(sample_size)+"x"+strofreal(item_n)+" item response matrix is added to the dataset "+displaytheta+displaygroup+" :)")

	}
end

