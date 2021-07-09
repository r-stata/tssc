*uirt.ado 
*ver 2.0.1
*2020.03.28
*everythingthatcounts@gmail.com

capture prog drop uirt
program define uirt, eclass
version 10
syntax [varlist] [if] [in] [,GRoupvar(varname numeric) REFerence(numlist max=1) dist NOUPD_quad_betw_em ERRors(str) pcm(varlist) gpcm(varlist) GUEssing(varlist)  guessing_attempts(integer 5) guessing_lrcrit(numlist max=1 >0 <=1) dif(varlist) THeta THName(namelist max=1) theta_nip(numlist integer max=1 >=2 <=195) SAVingname(namelist max=1) FIXIMatrix(namelist max=1) INITIMatrix(namelist max=1) INITDMatrix(namelist max=1) TRace(numlist integer max=1 >=0 <=2) NOTable nip(numlist integer max=1 >=2 <=195) nit(numlist integer max=1 >=0) NINrf(numlist integer max=1 >=0) pv(numlist integer max=1 >=0) pvreg(str) crit_ll(numlist max=1 >0 <1) crit_par(numlist max=1 >0 <1) fit fit_vars(varlist) fit_sx2 fit_sx2_vars(varlist) icc icc_vars(varlist) icc_noobs icc_pv icc_bins(numlist integer max=1 >=1) icc_pvbin(numlist max=1 >100 <100000) icc_format(str)]
	

	if replay() {
			if("`e(cmd)'" != "uirt"){
				error 301
			}
			else{
				di "/estimates replay/"
				di "Unidimensional item response theory model         Number of obs     =        `e(N)'"
				di "                                                  Number of items   =        `e(N_items)'"
				di "                                                  Number of groups  =        `e(N_gr)'"
				di "Log likelihood = "  %15.4f `e(ll)'
				di ""
				ereturn display
			}
	}
	else{

		marksample touse ,novarlist 
		
		m: eret_cmdline="uirt `0'"
		
		unab items: `varlist'
	
		m: st_local("items_isnumvar",verify_isnumvar("`items'"))
		if(strlen("`items_isnumvar'")){
			di as err "string variables not allowed in item varlist;"
			di as err "the following item variables are strings: `items_isnumvar'"
			exit 109
		}
		
		m: st_local("items_duplicates",verify_dupvars("`items'"))
		if(strlen("`items_duplicates'")){
			di as err "the following item variables are entered multiple times:"
			di as err "`items_duplicates'"
			exit 198
		}
		
		if(strlen("`thname'")==0){
			local theta_name="."
		}
		else{
			local theta_name="`thname'"
		}
		
		if("`theta'"==""){
			local add_theta=0
		}
		else{
			m: st_local("thexistlist",verify_thetaexist("`theta_name'"))
			if(strlen("`thexistlist'")){
				di as err "the following variables you asked to create are already defined: `thexistlist'"
				exit 110
			}
			local add_theta=1
		}
		
		
		if("`pv'"==""){
			local pv=0
		}
		else{
			m: st_local("pvexistlist",verify_pvexist(`pv',"`theta_name'"))
			if(strlen("`pvexistlist'")){
				di as err "the following variables you asked to create are already defined: `pvexistlist'"
				exit 110
			}
		}


		if(strlen("`pvreg'")==0){
			local pvreg="."
		}
		else{
			if(`pv'==0){
				di as err "you have to provide a positive number of PVs in pv() option in order to use pvreg() option"
				exit 198
			}
			if(strpos("`pvreg'",",")){
				di as err char(34)+","+char(34)+" is not allowed in the pvreg() option"
				exit 198
			}
			tempvar verify_xtmixed
			qui gen `verify_xtmixed'=rnormal() if `touse'
			if(`c(stata_version)'>=12){
				version `c(stata_version)'
			}
			cap xtmixed `verify_xtmixed' `pvreg',iter(0)
			if(_rc){
				di as err "there seem to be something wrong with the pvreg() option;"
				di as err char(34)+"xtmixed depvar `pvreg'"+char(34)+" returns the following error:"
				qui xtmixed `verify_xtmixed' `pvreg',iter(0)
			}
			else{
				qui drop `verify_xtmixed'
			}
			if((`c(stata_version)'<12)&(`e(k_r)')>1){
				if(strpos("`pvreg'","||")){
					di as err "Multilevel syntax is not allowed in the pvreg() option if Stata version is lower than 12.0"
					exit 198
				}
			}
			version 10
		}
		
		if(strlen("`errors'")==0){
			local errors="cdm"
		}
		else{
			if(lower("`errors'")=="cdm" | lower("`errors'")=="rem" | lower("`errors'")=="sem"| lower("`errors'")=="cp"){
				local errors=lower("`errors'")
			}
			else{
				di as err "`errors' is not a valid errors() value;"
				di as err "allowed values are: cdm | rem | sem | cp"
				exit 198
			}
		}
		
			
		if(strlen("`icc_format'")==0){
			local icc_format="png"
		}
		else{
			if("`icc_format'"=="png" | "`icc_format'"=="gph" | "`icc_format'"=="eps"){
				local icc_format="`icc_format'"
			}
			else{
				di as err "`icc_format' is not a valid icc_format() value;"
				di as err "only: png | gph | eps entries are allowed"
				exit 198
			}
		}
		
		if(strlen("`savingname'")==0){
			local savingname="."
		}
		
		if(strlen("`fiximatrix'")==0){
			local fiximatrix="."
		}
		else{
			cap mat l `fiximatrix'
			if(_rc){
				qui mat l `fiximatrix'
			}
		}
		
			
		if("`dist'"!=""){
			if("`fiximatrix'"=="."){
				di as err "dist option requires fixing parameters of at least one item"
				exit 198
			}
			else{
				local estimate_dist=1
			}
		}
		else{
			local estimate_dist=0
		}
		
		if(strlen("`initimatrix'")==0){
			local initimatrix="."
		}
		else{
			cap mat l `initimatrix'
			if(_rc){
				qui mat l `initimatrix'
			}
		}
		
		if(strlen("`initdmatrix'")==0){
			local initdmatrix="."
		}
		else{
			cap mat l `initdmatrix'
			if(_rc){
				qui mat l `initdmatrix'
			}
		}
		
		if(strlen("`groupvar'")>0){
	        unab group:`groupvar'
	        if("`reference'"==""){
		        local reference=.
	        }
	        else{
	        	qui tab `group' if `group'==`reference' & `touse'
		        if(r(N)==0){
		        	di as err "grouping variable `group' has no valid observations for ref(`reference');"
		        	error(2000)
		        }
	        }
		}
		else{
			local group="."
			local reference=.
		}
		
		
		if("`noupd_quad_betw_em'"!=""){
			if("`group'"=="."){
				di  "Note: noupd_quad_betw_em does not change anything if group() is not specified"
			}
			local upd_quad_betw_em=0
		}
		else{
			local upd_quad_betw_em=1
		}
		

		if strlen("`pcm'")>0{
			unab pcm_list: `pcm'
			
			m: st_local("pcm_missinall",*compare_varlist("`items'","`pcm_list'")[4])
			if(`pcm_missinall'>0){
				di as err "`pcm_missinall' items in pcm() are not declared in the main list of items:"
				m: st_local("pcm_misslist",*compare_varlist("`items'","`pcm_list'")[3])
				di as err "`pcm_misslist'"
				exit 198
			}
			m: st_local("pcm_duplicates",verify_dupvars("`pcm_list'"))
			if(strlen("`pcm_duplicates'")){
				di as err "the following item variables are entered multiple times in pcm():"
				di as err "`pcm_duplicates'"
				exit 198
			}
			
			m: pcmlist=tokens("`pcm_list'")'
		}
		else{
			m: pcmlist=J(0,1,"")
		}
		
		
		if strlen("`gpcm'")>0{
			unab gpcm_list: `gpcm'
			
			m: st_local("gpcm_missinall",*compare_varlist("`items'","`gpcm_list'")[4])
			if(`gpcm_missinall'>0){
				di as err "`gpcm_missinall' items in gpcm() are not declared in the main list of items:"
				m: st_local("gpcm_misslist",*compare_varlist("`items'","`gpcm_list'")[3])
				di as err "`gpcm_misslist'"
				exit 198
			}
			m: st_local("gpcm_duplicates",verify_dupvars("`gpcm_list'"))
			if(strlen("`gpcm_duplicates'")){
				di as err "the following item variables are entered multiple times in gpcm():"
				di as err "`gpcm_duplicates'"
				exit 198
			}
			
			m: gpcmlist=tokens("`gpcm_list'")'
		}
		else{
			m: gpcmlist=J(0,1,"")
		}
			
		if strlen("`guessing'")>0{
			unab guess_list: `guessing'
	
			m: st_local("guess_missinall",*compare_varlist("`items'","`guess_list'")[4])
			if(`guess_missinall'>0){
				di as err "`guess_missinall' items in guessing() are not declared in the main list of items:"
				m: st_local("guess_misslist",*compare_varlist("`items'","`guess_list'")[3])
				di as err "`guess_misslist'"
				exit 198
			}
			m: st_local("guess_duplicates",verify_dupvars("`guess_list'"))
			if(strlen("`guess_duplicates'")){
				di as err "the following item variables are entered multiple times in guessing():"
				di as err "`guess_duplicates'"
				exit 198
			}
			
			local okguess=0
			local notokguess=0
			m: guesslist=J(0,1,"")
			m: noguess_list=""
			foreach item of varlist `guess_list'{
				qui tab `item' if `touse'
				if(r(r)==2){
					local okguess=`okguess'+1
					m: guesslist=guesslist\"`item'"
				}
				else{
					local ++notokguess					
					m: noguess_list=noguess_list+" `item'"					
				}
			}
			if(`notokguess'>0){
				di "Note: `notokguess' items specified for fitting 3PLM have more than 2 response categories; `okguess' items left for 3PLM"			
			}
			if(`okguess'==0){
				m: guesslist=J(0,1,"")
			}
		}
		else{
			m: guesslist=J(0,1,"")
		}
		
		m: st_local("comp_pcm_gpcm",strofreal(rows(pcmlist)*rows(gpcmlist)>0))
		if(`comp_pcm_gpcm'){
			m: st_local("common_n",*compare_varlist("`pcm_list'","`gpcm_list'")[2])
			if(`common_n'){
				di as err "`common_n' items are listed both in pcm() and gpcm():"
				m: st_local("common_list",*compare_varlist("`pcm_list'","`gpcm_list'")[1])
				di as err "`common_list'"
				exit 198
			}
		}
	
		m: st_local("comp_pcm_guess",strofreal(rows(pcmlist)+rows(guesslist)>0))
		if(`comp_pcm_guess'){
			m: st_local("common_n",*compare_varlist("`pcm_list'","`guess_list'")[2])
			if(`common_n'){
				di as err "`common_n' items are listed both in pcm() and guessing():"
				m: st_local("common_list",*compare_varlist("`pcm_list'","`guess_list'")[1])
				di as err "`common_list'"
				exit 198
			}
		}
		
		m: st_local("comp_gpcm_guess",strofreal(rows(gpcmlist)*rows(guesslist)>0))
		if(`comp_gpcm_guess'){
			m: st_local("common_n",*compare_varlist("`gpcm_list'","`guess_list'")[2])
			if(`common_n'){
				di as err "`common_n' items are listed both in gpcm() and guessing():"
				m: st_local("common_list",*compare_varlist("`gpcm_list'","`guess_list'")[1])
				di as err "`common_list'"
				exit 198
			}
		}
		
		
		if(strlen("`icc'")>0){
			m: icclist=tokens("`items'")'
		}
		else{
			if(strlen("`icc_vars'")>0){
				unab icc_list: `icc_vars'
				
				m: st_local("icc_missinall",*compare_varlist("`items'","`icc_list'")[4])
				if(`icc_missinall'>0){
					di as err "`icc_missinall' items in icc() are not declared in the main list of items:"
					m: st_local("icc_misslist",*compare_varlist("`items'","`icc_list'")[3])
					di as err "`icc_misslist'"
					exit 198
				}
				
				m: icclist=tokens("`icc_list'")'
			}
			else{
				m: icclist=J(0,1,"")
			}
		}
		
		if("`icc_noobs'"==""){
			local icc_obs=1
		}
		else{
			local icc_obs=0
		}
		
		if(strlen("`fit'")>0){
			m: fitlist=tokens("`items'")'
		}
		else{
			if(strlen("`fit_vars'")>0){
				unab fit_list: `fit_vars'
				
				m: st_local("fit_missinall",*compare_varlist("`items'","`fit_list'")[4])
				if(`fit_missinall'>0){
					di as err "`fit_missinall' items in fit_vars() are not declared in the main list of items:"
					m: st_local("fit_misslist",*compare_varlist("`items'","`fit_list'")[3])
					di as err "`fit_misslist'"
					exit 198
				}
				
				m: fitlist=tokens("`fit_list'")'
			}
			else{
				m: fitlist=J(0,1,"")
			}
		}
		
		if(strlen("`fit_sx2'")>0){
			m: sx2_fitlist=tokens("`items'")'
		}
		else{
			if(strlen("`fit_sx2_vars'")>0){
				unab sx2_fit_list: `fit_sx2_vars'
				
				m: st_local("fit_missinall",*compare_varlist("`items'","`sx2_fit_list'")[4])
				if(`fit_missinall'>0){
					di as err "`fit_missinall' items in fit_sx2_vars() are not declared in the main list of items:"
					m: st_local("fit_misslist",*compare_varlist("`items'","`sx2_fit_list'")[3])
					di as err "`fit_misslist'"
					exit 198
				}
				
				m: sx2_fitlist=tokens("`sx2_fit_list'")'
			}
			else{
				m: sx2_fitlist=J(0,1,"")
			}
		}		
		
		
		
		if (strlen("`dif'")>0){
			if("`group'"=="."){
				di as err "you must specify groupvar() in order to analyze for DIF"
				exit 198
			}
			else{
				qui tab `group' if `touse'
				if(r(r)!=2){
					di as err "variable in groupvar() need to have two values in order to analyze for DIF"
					exit 198
				}
				else{
					unab dif_list: `dif'
					
					m: st_local("dif_missinall",*compare_varlist("`items'","`dif_list'")[4])
					if(`dif_missinall'>0){
						di as err "`dif_missinall' items in dif() are not declared in the main list of items:"
						m: st_local("dif_misslist",*compare_varlist("`items'","`dif_list'")[3])
						di as err "`dif_misslist'"
						exit 198
					}
							
					local okdif=0
					local notokdif=0
					m: diflist=J(0,1,"")
					m: nodif_list=""
					foreach item of varlist `dif_list'{
						qui tab `group' `item' if `touse'
						if(r(r)==2){
							local okdif=`okdif'+1
							m: diflist=diflist\"`item'"
						}
						else{
							local ++notokdif					
							m: nodif_list=nodif_list+" `item'"					
						}
					}
					if(`notokdif'>0){
						di "Note: `notokdif' items for DIF analysis not responded in both groups; `okdif' items left for DIF analysis"			
					}
					if(`okdif'==0){
						m: diflist=J(0,1,"")
					}
				}
			}
		}
		else{
			m: diflist=J(0,1,"")
		}
	
		if("`icc_pv'"==""){
			if("`icc_pvbin'"!=""){
				di "Note: icc_pvbin(`icc_pvbin') will not take effect unless you add icc_pv option; observed proportions will be computed by numerical itegration"	
			}
			local icc_pvbin=0
		}
		else{
			if("`icc_pvbin'"==""){
				local icc_pvbin=10000
			}
		}
		
		if("`guessing_lrcrit'"==""){
			local guessing_lrcrit=0.05
		}	
		if("`nip'"==""){
			local nip=51
		}
		if("`theta_nip'"==""){
			local theta_nip=195
		}
	 
		if("`crit_ll'"==""){
			local crit_ll=10^-9
		}
		if("`crit_par'"==""){
			local crit_par=10^-4
		}
		if("`icc_bins'"==""){
			local icc_bins=100
		}
		if("`nit'"==""){
			local nit=100
		}	
		if("`ninrf'"==""){
			local ninrf=20
		}			
		if("`trace'"==""){
			local trace=1
		}
		
				
		m: uirt("`touse'","`items'","`group'",`reference',`estimate_dist',`upd_quad_betw_em',"`errors'",pcmlist,gpcmlist,guesslist,`guessing_attempts',`guessing_lrcrit', diflist,`add_theta',"`theta_name'",`theta_nip',"`savingname'","`fiximatrix'","`initimatrix'","`initdmatrix'",`icc_obs',icclist,fitlist,sx2_fitlist,`trace',`nip',`nit',`ninrf',`pv',"`pvreg'",`crit_ll',`crit_par',`icc_bins',`icc_pvbin',"`icc_format'")
		
		m: stata("ereturn local cmdline "+char(34)+eret_cmdline+char(34))
	
*display results
		di ""
		di "Unidimensional item response theory model         Number of obs     =        `e(N)'"
		di "                                                  Number of items   =        `e(N_items)'"
		di "                                                  Number of groups  =        `e(N_gr)'"
		di "Log likelihood = "  %15.4f `e(ll)'
		di ""
		if("`notable'"==""){
			ereturn display
		}
}

end

mata:
	void uirt(string scalar touse, string scalar items, string scalar group, real scalar ref, real scalar estimate_dist, real scalar upd_quad_betw_em, string scalar errors, string matrix pcmlist,string matrix gpcmlist, string matrix guesslist, real scalar guessing_attempts, real scalar guessing_lrcrit, string matrix diflist, real scalar add_theta, string scalar theta_name, real scalar theta_nip, string scalar savingname , string scalar fiximatrix, string scalar initimatrix, string scalar initdmatrix, real scalar icc_obs, string matrix icclist, string matrix fitlist,string matrix sx2_fitlist, real scalar trace, real scalar nip,real scalar nit,real scalar nnirf,real scalar pv,string scalar pvreg, real scalar crit_ll, real scalar crit_par, real scalar icc_bins, real scalar icc_pvbin,string scalar icc_format){

		itemlist	= tokens(items)'
		I 			= rows(itemlist)	
		N_iter		=nit
		N_iter_NRF	=nnirf
		K			=nip
		J_all		=st_nobs()

		
		iflogist_del=1 //if there is a fail in initiating item starting values and the item is discarded all this is repeated. A waste, will be fixed some day.
		while(iflogist_del==1){
		
			if(initimatrix!="." | fiximatrix!="."){
				starting_values_fixORinit_res	= starting_values_fixORinit(itemlist,fiximatrix,initimatrix)
				parameters							=*starting_values_fixORinit_res[1]
				item_fix_init_indicator				=*starting_values_fixORinit_res[2]
				model_curr_asked					=*starting_values_fixORinit_res[3]	
			}
			else{
				parameters				= J(I,32,.)
				item_fix_init_indicator	= J(I,2,0)
				model_curr_asked		= J(I,2,"")
			}
			
	
			grouping_data 	= return_group_item_info(touse,items,group,ref)
			group_rec_data	= *grouping_data[1]
			group_vals		= *grouping_data[2]
			group_labels 	= *grouping_data[3]
			item_n_cat		= *grouping_data[4]
			point_item_cats = *grouping_data[5]
			item_group_totalobs 	= *grouping_data[6]		
			grouping_data[1]= NULL
			
			
			N_gr = rows(group_vals)
			

// model_curr_asked - current, asked model and number of item categories
// fixing overrides asking (initating does not); you cannot initiate 2plm with 3plm etc			
			for(i=1;i<=I;i++){
				if(sum(item_fix_init_indicator[i,.])==0){
					if(item_n_cat[i]==2 & sum(guesslist:==itemlist[i])){
							model_curr_asked[i,.]=("2plm","3plm")
					}
					if(item_n_cat[i]==2 & model_curr_asked[i,1]==""){
							model_curr_asked[i,.]=("2plm","2plm")	
					}
					if(sum(pcmlist:==itemlist[i])){
						model_curr_asked[i,.]=("pcm","pcm")
					}
					if(item_n_cat[i]>2 & sum(gpcmlist:==itemlist[i])){
						model_curr_asked[i,.]=("pcm","gpcm")
					}
					if(item_n_cat[i]>2 & model_curr_asked[i,1]==""){
						model_curr_asked[i,.]=("grm","grm")	
					}
				}
				if(sum(item_fix_init_indicator[i,2])==1){
					if(item_n_cat[i]==2 & sum(guesslist:==itemlist[i])){
							model_curr_asked[i,2]="3plm"
					}
					if(item_n_cat[i]==2 & (model_curr_asked[i,2]=="")){
							model_curr_asked[i,.]=("2plm","2plm")	
					}
					if(sum(pcmlist:==itemlist[i])){
						model_curr_asked[i,2]="pcm"
					}
					if(item_n_cat[i]>2 & sum(gpcmlist:==itemlist[i])){
						model_curr_asked[i,2]="gpcm"
					}
					if(item_n_cat[i]>2 & model_curr_asked[i,2]==""){
							model_curr_asked[i,2]="grm"
					}
				}							
			}
					
			// if item is fixed 0-max_cat is assumed; 
			// in future an option to provide original categories should be introduced
			if(sum(item_fix_init_indicator[.,1])){
				for(i=1;i<=I;i++){
					if(item_fix_init_indicator[i,1]==1){
						if(parameters[i,2]!=.){
							item_n_cat[i] = 2
						}
						else{
							item_n_cat[i] = nonmissing(parameters[i,1..cols(parameters)-2])
						}
						point_item_cats[i] = return_pointer( (0::item_n_cat[i]-1) )
					}
				}
			}
					
			model_curr_asked=model_curr_asked,strofreal(item_n_cat)				
			
			dropped_items_range=select((1::I),   (item_n_cat:==0)  :+  ((item_n_cat:==1):*(item_fix_init_indicator[.,1]:==0))   )
			if(rows(dropped_items_range)){
				dropped_items		= itemlist[dropped_items_range]
				dropped_item_n_cat	= item_n_cat[dropped_items_range]
	
				display("Note: "+strofreal(rows(dropped_items))+" items are dropped from analysis:")
				for(i=1;i<=rows(dropped_items);i++){
					if(dropped_item_n_cat[i]==0){
						display("      item has all values missing: "+dropped_items[i])	
					}
					if(dropped_item_n_cat[i]==1){
						display("      item has zero variance     : "+dropped_items[i])
					}
				}
				
				kept_items_range		= select((1::I),  ( (item_n_cat:==0)  :+  ((item_n_cat:==1):*(item_fix_init_indicator[.,1]:==0)) ):==0 )
				itemlist 				= itemlist[kept_items_range]
				item_n_cat 				= item_n_cat[kept_items_range]
				point_item_cats 		= point_item_cats[kept_items_range]
				item_group_totalobs		= item_group_totalobs[kept_items_range,.]
				parameters				= parameters[kept_items_range,.]
				item_fix_init_indicator	= item_fix_init_indicator[kept_items_range,.]
				model_curr_asked		= model_curr_asked[kept_items_range,.]
				I 						= rows(itemlist)
			}
			
	
			
			if(sum(item_fix_init_indicator[.,1])==0 & estimate_dist){
				estimate_dist=0
				stata("di in red "+char(34)+"Warning: parameters of reference group will remain fixed; dist requires fixing parameters of at least one item"+char(34))
			}
		
			Theta_id = select((1::J_all),group_rec_data:!=.)
			N_Theta_id=rows(Theta_id)
			Theta_id_sorted=J(N_Theta_id,1,.)
			Theta_dup = J(N_Theta_id,1,.)
			
	
	//	establishing pointers and sorting stuff
			point_Uigc=J(I,N_gr,NULL)
			point_Fg=J(N_gr,1,NULL)
			row_Theta_dup=1
			for(g=1;g<=N_gr;g++){
				
				Theta_id_g = select(Theta_id,group_rec_data[Theta_id]:==g)
				N_Theta_id_g=rows(Theta_id_g)			
				
				
				itemselectrange_g = select((1::I),item_group_totalobs[.,g]:>0)
				itemlist_g =  itemlist[itemselectrange_g]
				point_item_cats_g = point_item_cats[itemselectrange_g]
				I_g = rows(itemlist_g)
				
				U_g=sort((Theta_id_g,st_data(Theta_id_g,itemlist_g')),(2..I_g+1))
				
				Theta_id_sorted[ (nonmissing(Theta_id_sorted)+1) :: (nonmissing(Theta_id_sorted)+N_Theta_id_g)]=U_g[.,1]
				U_g=U_g[.,(2..I_g+1)]
				
				Fg=J(N_Theta_id_g,1,.)
				unique_pattern_rows=J(N_Theta_id_g,1,0)
				pattern=U_g[1,.]
				counter=0
				rowFg=1
				for(j=1;j<=N_Theta_id_g;j++){
					if(rowsum(U_g[j,.]:==pattern)==I_g){
						counter++
						if(j>1){
							Theta_dup[row_Theta_dup]=Theta_dup[row_Theta_dup-1]
						}
						else{
							if(g==1){
								Theta_dup[row_Theta_dup]=1
							}
							else{
								Theta_dup[row_Theta_dup]=max(Theta_dup)+1
							}
						}
					}
					else{
						unique_pattern_rows[j-1]=1
						Fg[rowFg]=counter
						Theta_dup[row_Theta_dup]=Theta_dup[row_Theta_dup-1]+1
						pattern=U_g[j,.]
						counter=1
						rowFg++
					}
					row_Theta_dup++
				}
				Fg[rowFg]=counter
				unique_pattern_rows[j-1]=1		
				U_g=select(U_g,unique_pattern_rows)
	
	//	establishing pointer to fweights	
				point_Fg[g]=return_pointer(Fg[1::nonmissing(Fg)])
				
	//	establishing pointers to category ranges
				for(i=1;i<=I_g;i++){
					point_Uigc[i,g]=&return_category_range_pointers(*point_item_cats_g[i],U_g[.,i])
				}
			}
	
		
			
	// getting rid of these huge matrices
			Theta_id=Theta_id_sorted
			Theta_id_sorted=J(0,0,.)
			Theta_id_g=J(0,0,.)
			Fg=J(0,0,.)
			U_g=J(0,0,.)
			group_rec_data=J(0,0,.)
	
				
			group_uniq_total_obs=J(N_gr,2,0)
			for(g=1;g<=N_gr;g++){
				group_uniq_total_obs[g,1] = rows(*point_Fg[g]) 
				group_uniq_total_obs[g,2] = sum(*point_Fg[g])
			}		
			
	
			if( missing(parameters[.,1]) ){
				starting_values_logistic_results 	= starting_values_logistic( itemlist,model_curr_asked, item_fix_init_indicator ,point_item_cats, Theta_id, Theta_dup  , item_n_cat, item_group_totalobs, group_uniq_total_obs , point_Uigc, point_Fg, "" )
				remaining_parameters				=*starting_values_logistic_results[1]
				remaining_parameters_failed			=*starting_values_logistic_results[2]
		
				
				remaining_items_range = select((1::I), rowsum(item_fix_init_indicator):==0)
				if(rows(remaining_items_range)){
					parameters[remaining_items_range,.] = remaining_parameters
				}
				
				dropped_items_range		= select(remaining_items_range, remaining_parameters_failed )
				if(rows(dropped_items_range)){
					dropped_items		= itemlist[dropped_items_range]
					dropped_item_whyfail= select(remaining_parameters_failed,remaining_parameters_failed)
		
					display("Note: "+strofreal(rows(dropped_items))+" items are dropped from analysis:")
					for(i=1;i<=rows(dropped_items);i++){
						if(dropped_item_whyfail[i]==1){
							display("      failed generating starting values (convergence): "+dropped_items[i])
						}
						if(dropped_item_whyfail[i]==2){
							display("      failed generating starting values (a<0)        : "+dropped_items[i])
						}
					}
					
					kept_items_range		= select((1::I),  parameters[.,1]:!=.)
					itemlist 				= itemlist[kept_items_range]
					item_n_cat 				= item_n_cat[kept_items_range]
					point_Uigc				= restrict_point_Uigc(kept_items_range, item_group_totalobs,point_Uigc)	
					point_item_cats 		= point_item_cats[kept_items_range]
					item_group_totalobs		= item_group_totalobs[kept_items_range,.]
					parameters				= parameters[kept_items_range,.]
					item_fix_init_indicator	= item_fix_init_indicator[kept_items_range,.]
					model_curr_asked		= model_curr_asked[kept_items_range,.]
					I 						= rows(itemlist)
					
					items=""
					for(i=1;i<=I;i++){
						items=items+" "+itemlist[i]
					}	
				}
				else{
					iflogist_del=0
				}
			}
			else{
				iflogist_del=0
			}
		
		}			
			
					
		X_k_A_k	= gauss_hermite(K)
		X_k 	= J(1,N_gr,X_k_A_k[.,1])
		A_k 	= J(1,N_gr,X_k_A_k[.,2])
		if(initdmatrix=="."){
			DIST=J(1,N_gr,(0\1))
		}
		else{
			
			DIST=st_matrix(initdmatrix)
			
			saved_group_vals=st_matrixcolstripe(initdmatrix)
			saved_group_vals=strtoreal(subinstr(st_matrixcolstripe(initdmatrix)[.,2],"group_",""))
			
			if(rows(saved_group_vals)!=rows(group_vals)){
				_error("number of groups in matrix "+initdmatrix+" is not " +strofreal(rows(group_vals)))
			}
			else{
				if(sum(abs(saved_group_vals-group_vals))){
					_error("group values in matrix "+initdmatrix+" differ from those specified in current run")			
				}
			}	
			for(g=1;g<=N_gr;g++){
				X_k[.,g]=X_k[.,g]:*DIST[2,g]:+DIST[1,g]	
			}
		}

		Cns_parameters			= (parameters :*0) :+ item_fix_init_indicator[.,1]
		Cns_parameters[.,1] 	= ((model_curr_asked[.,2]:=="pcm") :+ (Cns_parameters[.,1]):==1) :> 0
		Cns_DIST				= DIST :* 0
		if(estimate_dist==0){
			Cns_DIST[.,1]=(1\1)
		}
		if(estimate_dist==0 & sum(model_curr_asked[.,2]:=="pcm")>0 ){
			Cns_DIST[.,1]=(1\0)
		}
		


		//checking if sx2 can be computed
		if(rows(sx2_fitlist)){
		
			if(N_gr==1){
			
				viable_for_sx2=J(rows(itemlist),N_gr,1)
				for(g=1;g<=N_gr;g++){
					viable_for_sx2[.,g] = ( item_group_totalobs[.,g]:==group_uniq_total_obs[g,2] )
				}
				for(g=1;g<=N_gr;g++){
					viable_for_sx2[.,g] =  viable_for_sx2[.,g]:*( item_n_cat:==2)
				}
				viable_for_sx2=(rowsum(viable_for_sx2):==cols(viable_for_sx2))
				
				if_fit_sx2=J(rows(itemlist),1,0)
				items_missing_or_ncat="     "
				N_missing_or_ncat=0
				for(i=1;i<=rows(sx2_fitlist);i++){
					if(sum( (itemlist:==sx2_fitlist[i]):*viable_for_sx2 )){
						if_fit_sx2=if_fit_sx2:+(itemlist:==sx2_fitlist[i])
					}
					else{
						items_missing_or_ncat=items_missing_or_ncat+" "+sx2_fitlist[i]
						N_missing_or_ncat=N_missing_or_ncat+1
					}
				}
							
				N_for_sx2_required=3
				viable_for_sx2_models=select(model_curr_asked[.,1],viable_for_sx2)
				if(sum(viable_for_sx2_models:=="3plm")){
					N_for_sx2_required=N_for_sx2_required+3
				}
				else{
					if(sum(viable_for_sx2_models:=="2plm")){
						N_for_sx2_required=N_for_sx2_required+2
					}
					else{
						if(sum(viable_for_sx2_models:=="1plm")){
							N_for_sx2_required=N_for_sx2_required+1
						}
					}
				}
				
				if(N_missing_or_ncat){
					display("Note: "+strofreal(N_missing_or_ncat)+" items specified for SX2 fit statistic have either missing responses or are polytomous:")
					display(items_missing_or_ncat)
					if(sum(if_fit_sx2)){
						display( "      "+ strofreal(sum(if_fit_sx2)) + " items left for SX2")
					}
					else{
						display( "      no valid items left for SX2")
					}
				}
	
				if(sum(if_fit_sx2)){			
					if(N_for_sx2_required>sum(viable_for_sx2)){
						display("Note: To compute SX2 fit statistic there need to be at least "+strofreal(N_for_sx2_required)+" dichotomously scored items with no missing values in your test,")
						display("      there is only "+strofreal(sum(viable_for_sx2))+" such items, SX2 will not be computed")
					}
				}
			}
			else{
				if_fit_sx2=J(rows(itemlist),1,0)
				display("Note: SX2 is implemented only for a single group setting, you defined "+strofreal(N_gr)+" groups, SX2 will not be computed")
			}
			
		}
		
		
// THE EM
			em_results				= em(N_iter, trace, errors, crit_ll, model_curr_asked, guessing_attempts, guessing_lrcrit, add_theta, theta_name, theta_nip, Theta_id, Theta_dup, savingname, group_vals                   ,                       Cns_parameters, Cns_DIST, itemlist, item_n_cat, item_fix_init_indicator, point_item_cats, item_group_totalobs, group_uniq_total_obs, parameters, X_k , A_k, point_Uigc, point_Fg                 ,                 DIST, upd_quad_betw_em, N_iter_NRF, crit_par)
	
			DIST					= *em_results[1]
			parameters				= *em_results[2]
			logL					= *em_results[3]
			X_k						= *em_results[4]
			long_EMhistory_matrix	= *em_results[5]
			model_curr_asked		= *em_results[6]
			Cns_parameters			= *em_results[7]
			if_em_converged			= *em_results[8]

						
			
			
// ERRORS 
		if(errors!="."){
			if(errors=="sem" | errors=="rem" |  errors=="cdm" ){		
				perturbation = crit_par*10
				
				errors_DM_results		= errors_DM(errors,  perturbation, long_EMhistory_matrix,        group_vals ,  Cns_parameters, Cns_DIST,  itemlist, item_fix_init_indicator, model_curr_asked,  item_group_totalobs,  group_uniq_total_obs,  parameters,  X_k ,  A_k, point_Uigc, point_Fg ,   DIST,  N_iter_NRF,  crit_par)	
				
				DIST_err				= *errors_DM_results[1]
				parameters_err			= *errors_DM_results[2]
				V						= *errors_DM_results[3]
				eret_Cns				= *errors_DM_results[4]
				parameters				= *errors_DM_results[5]
				DIST					= *errors_DM_results[6]
			}
			if(errors=="cp"){
			
				errors_CP_results		=	errors_CP(group_vals ,Cns_parameters, Cns_DIST, item_group_totalobs,model_curr_asked, group_uniq_total_obs, parameters,  point_Uigc,  point_Fg ,  DIST)

				DIST_err				= *errors_CP_results[1]
				parameters_err			= *errors_CP_results[2]
				V						= *errors_CP_results[3]
				eret_Cns				= *errors_CP_results[4]
				parameters				= *errors_CP_results[5]
				DIST					= *errors_CP_results[6]
			}
		
		}	
		else{
			parameters_err=J(rows(parameters),cols(parameters),.)
			DIST_err=J(rows(DIST),cols(DIST),.)
		}
		
		
		// not documented in help, for testing purposes only
		 	 store_matrices(model_curr_asked,"",itemlist,parameters,DIST,parameters_err,DIST_err,logL,group_vals, item_group_totalobs, item_n_cat, point_item_cats, group_uniq_total_obs)


		
		
// ADDING PVs
		if(pv>0){
			// giving small burn, because we have a proposition distribution fixed at the unconditioned a posteriori
			burn					= 40
			draw_from_chain			= 10
			max_independent_chains	=	20
			if(group!="."){
				if(pvreg!="."){
					pvreg= "i."+group+" "+pvreg
				}
			}
			PV 				= generate_pv(pv,draw_from_chain,max_independent_chains, burn    ,   Theta_dup, point_Uigc, point_Fg    ,  parameters, item_n_cat, item_group_totalobs,model_curr_asked  ,  group_uniq_total_obs, A_k, X_k, DIST   ,  pvreg, Theta_id,1,V)
			
			if(theta_name!="."){
				index_temp=st_addvar("double",J(1,pv,"pv_")+strofreal((1..pv))+J(1,pv,"_"+theta_name))
				if(pv>1){
					mess = "Added variables: pv_1_"+theta_name+" - pv_"+strofreal(pv)+"_"+theta_name
				}
				else{
					mess = "Added variable: pv_1_"+theta_name
				}
			}
			else{
				index_temp=st_addvar("double",J(1,pv,"pv_")+strofreal((1..pv)))
				if(pv>1){
					mess = "Added variables: pv_1 - pv_"+strofreal(pv)
				}
				else{
					mess = "Added variable: pv_1"
				}		
			}
			st_store(Theta_id,index_temp,PV)
			display(mess)
			PV = J(0,0,.)
		}


// GRAPHS
		if(rows(icclist)){
		
			if_makeicc=J(I,1,0)
			for(i=1;i<=rows(icclist);i++){
				if_makeicc=if_makeicc+(itemlist:==icclist[i])
			}
			
			if(icc_obs){
				if(icc_pvbin){
					Pj_centile = Pj_centile_pv(if_makeicc, Theta_dup, point_Uigc, point_Fg , parameters, item_group_totalobs,model_curr_asked, group_uniq_total_obs  ,  A_k, X_k, DIST ,  icc_pvbin, icc_bins,V)
				}
				else{
					Pj_centile = Pj_centile_integrated(item_n_cat, point_Uigc,  point_Fg,  parameters, item_group_totalobs, model_curr_asked, group_uniq_total_obs , DIST, icc_bins)
				}
			}
			else{
				Pj_centile=J(0,0,.)
			}
			
			icc_graph(Pj_centile,if_makeicc,icc_format,itemlist,parameters,model_curr_asked, item_group_totalobs ,point_Uigc,point_Fg,group_labels,theta_name,point_item_cats,J(0,0,.))
		}
		
// FIT		
		if(rows(fitlist)){

			fit_N_intervals=10
			fit_npq_crit=20
			report_min_npq=0
			
			if_fit=J(rows(itemlist),1,0)
			for(i=1;i<=rows(fitlist);i++){
				if_fit=if_fit+(itemlist:==fitlist[i])
			}
			fitlist=select(itemlist,if_fit)
			
			if_df_loss=J(sum(if_fit),1,1)
			
			chi2W_results=chi2W(if_fit, fit_N_intervals, fit_npq_crit, if_df_loss,  item_n_cat, item_group_totalobs , model_curr_asked,  group_uniq_total_obs, parameters , point_Uigc, point_Fg, DIST)
			
			if(report_min_npq){
				st_matrix("item_fit_chi2W",chi2W_results)
				st_matrixcolstripe("item_fit_chi2W", (J(5,1,""),("chi2W","p-val","df","n_par","min_npq")'))
				st_matrixrowstripe("item_fit_chi2W", (J(rows(fitlist),1,""),fitlist))
			}
			else{
				st_matrix("item_fit_chi2W",chi2W_results[.,1..4])
				st_matrixcolstripe("item_fit_chi2W", (J(4,1,""),("chi2W","p-val","df","n_par")'))
				st_matrixrowstripe("item_fit_chi2W", (J(rows(fitlist),1,""),fitlist))
			}
		}
		
		if(sum(if_fit_sx2)){
		
			sx2_fitlist=select(itemlist,if_fit_sx2)
			
			sx2_min_freq=1
			if_df_loss=J(sum(if_fit_sx2),1,1)
					
			SX2_results=SX2(if_fit_sx2, viable_for_sx2, if_df_loss, sx2_min_freq,  item_n_cat , model_curr_asked, parameters , point_Uigc, point_Fg, DIST)
			
			st_matrix("item_fit_SX2",SX2_results)
			st_matrixcolstripe("item_fit_SX2", (J(4,1,""),("SX2","p-val","df","n_par")'))
			st_matrixrowstripe("item_fit_SX2", (J(rows(sx2_fitlist),1,""),sx2_fitlist))
			
		}
		
// DIF
		if(rows(diflist)>0){	
		
			
			dif_results = dif(diflist, logL, group_labels, icc_format       ,    N_iter, crit_ll, model_curr_asked, theta_nip, Theta_id, Theta_dup, group_vals                   ,                       Cns_parameters, Cns_DIST, itemlist, item_group_totalobs, group_uniq_total_obs, item_fix_init_indicator, parameters, X_k , A_k, point_Uigc, point_Fg                 ,                 DIST, upd_quad_betw_em, N_iter_NRF, crit_par, point_item_cats,     theta_name)
			
			st_matrix("dif_results",dif_results)
			st_matrixcolstripe("dif_results", (J(8,1,""),("LR","p-value","P-DIF|GR","P-DIF|GF","E(parR,GR)","E(parF,GR)","E(parR,GF)","E(parF,GF)")'))
			st_matrixrowstripe("dif_results", (J(rows(diflist),1,""),diflist))
			
		}
		
		
		
// ereturn posting 


	stata("ereturn clear")
	
//MATRICES
	eret_b			= create_long_vector(DIST,parameters)'
	eret_b_colnames	= J(2,cols(eret_b),"")
	range_start=1
	for(g=1;g<=N_gr;g++){
			range_stop=range_start+2-1
			eret_b_colnames[1,range_start..range_stop]=J(1,2,"group_"+strofreal(group_vals[g]))
			eret_b_colnames[2,range_start..range_stop]=("mean_theta","sd_theta")
			range_start=range_stop+1
	}
	for(i=1;i<=I;i++){
		inpar=nonmissing(parameters[i,1..cols(parameters)-2])
		range_stop=range_start+inpar-1
		eret_b_colnames[1,range_start..range_stop]=J(1,inpar,itemlist[i])
		if(model_curr_asked[i,1]=="1plm"){
			eret_b_colnames[2,range_start..range_stop]=model_curr_asked[i,1]:+("_b")
		}		
		if(model_curr_asked[i,1]=="2plm"){
			eret_b_colnames[2,range_start..range_stop]=model_curr_asked[i,1]:+("_a","_b")
		}
		if(model_curr_asked[i,1]=="3plm"){
			eret_b_colnames[2,range_start..range_stop]=model_curr_asked[i,1]:+("_a","_b","_c")
		}
		if(model_curr_asked[i,1]=="pcm"){
			eret_b_colnames[2,range_start..range_stop]=model_curr_asked[i,1]:+("_a",("_b":+strofreal(1..inpar-1)))
		}
		if(model_curr_asked[i,1]=="gpcm"){
			eret_b_colnames[2,range_start..range_stop]=model_curr_asked[i,1]:+("_a",("_b":+strofreal(1..inpar-1)))
		}		
		if(model_curr_asked[i,1]=="grm"){
			eret_b_colnames[2,range_start..range_stop]=model_curr_asked[i,1]:+("_a",("_b":+strofreal(1..inpar-1)))
		}
		range_start=range_stop+1
	}
	
// parameter matrix
	st_matrix("b",eret_b)
	st_matrixcolstripe("b",eret_b_colnames')
	st_matrixrowstripe("b", ("","y1"))

//covariance matrix		
	st_matrix("V",V)
	st_matrixcolstripe("V", eret_b_colnames')
	st_matrixrowstripe("V", eret_b_colnames')
	
// constraints matrix
	st_matrix("Cns",eret_Cns)
	st_matrixcolstripe("Cns",(eret_b_colnames'\("_Cns","_r")))

	
// eret post
	stata("ereturn post b V Cns, esample("+touse+") obs("+strofreal(sum(group_uniq_total_obs[.,2]))+")")
	
// additional matrices
	if(rows(diflist)>0){	
		stata("ereturn matrix dif_results dif_results")
	}
	if(rows(fitlist)>0){	
		stata("ereturn matrix item_fit_chi2W item_fit_chi2W")
	}

	if(sum(if_fit_sx2)>0){	
		stata("ereturn matrix item_fit_SX2 item_fit_SX2")
	}
	
	stata("ereturn matrix item_cats item_cats")
	stata("ereturn matrix item_group_N item_group_N")
	stata("ereturn matrix group_N group_N")
	stata("ereturn matrix group_ll ll")
	stata("ereturn matrix group_par_se dist_se")
	stata("ereturn matrix group_par dist")
	stata("ereturn matrix item_par_se items_se")
	stata("ereturn matrix item_par items")			
		
//MACROS
	stata("ereturn local cmd "+char(34)+"uirt"+char(34))
	stata("ereturn local title "+char(34)+"Unidimensional item response theory model"+char(34))
	eret_depvar=""
	for(i=1;i<=I;i++){
		eret_depvar=eret_depvar+" "+itemlist[i]
	}	
	stata("ereturn local depvar "+char(34)+eret_depvar+char(34))

// SCALARS	
	stata("ereturn scalar ll="+strofreal(sum(logL),"%15.4f"))
	stata("ereturn scalar df_m="+strofreal(cols(eret_b)))
	stata("ereturn scalar N_items="+strofreal(I))
	stata("ereturn scalar N_gr="+strofreal(N_gr))
	stata("ereturn scalar converged="+strofreal(if_em_converged))
	

	}
	
	
	
// FUNCTIONS BELOW
	pointer colvector errors_CP( real colvector group_vals , real matrix Cns_parameters, real matrix Cns_DIST, real matrix item_group_totalobs,string matrix model_curr_asked , real matrix group_uniq_total_obs, real matrix parameters, pointer matrix point_Uigc, pointer matrix point_Fg ,  real matrix DIST){
		
		N_gr	= rows(group_vals)
		I		= rows(parameters)
		item_n_cat = strtoreal(model_curr_asked[.,3])
		
		long_final_estimates	= create_long_vector(DIST,parameters)
		N_par					= rows(long_final_estimates)
		Cns_matrix=create_long_Cns_matrix(DIST,parameters,Cns_parameters, Cns_DIST)
		
		long_obsdata_Score_crosspr	= J(N_par,N_par,0)
		

		for(g=1;g<=N_gr;g++){
		
			par_range_g=J(0,1,.)

			N_par_g			=	2
			range_start		=	(g-1)*2+1
			range_stop		=	range_start+2-1
			par_range_g		=	par_range_g\(range_start::range_stop)
				
			range_start		= N_gr*2+1
			for(i=1;i<=I;i++){
				n_cat = item_n_cat[i]
				model = model_curr_asked[i,1]
				if(model=="2plm"){
					range_stop=range_start+2-1
				}
				if(model=="3plm"){
					range_stop=range_start+3-1
				}
				if(model=="grm" | model=="gpcm" | model=="pcm" ){
					range_stop=range_start+n_cat-1
				}
				if(item_group_totalobs[i,g]:>0){
					par_range_g	=	par_range_g\(range_start::range_stop)
					N_par_g=N_par_g+(range_stop-range_start+1)
				}
				range_start=range_stop+1
			}
			
			Fg = *point_Fg[g]
			itemselectrange_g = select((1::I),item_group_totalobs[.,g]:>0)
			
			parameters_g 		= parameters[itemselectrange_g,.]
			item_n_cat_g 		= item_n_cat[itemselectrange_g]
			model_curr_asked_g	= model_curr_asked[itemselectrange_g,.]
			I_g = rows(itemselectrange_g)
			
			theta_nip=195
			X_k_A_k=gauss_hermite(theta_nip)
			X_k_theta = X_k_A_k[.,1]:*DIST[2,g]:+DIST[1,g]
			A_k_theta = X_k_A_k[.,2]
			
			PXk_Uj = eE_step(X_k_theta,A_k_theta,point_Uigc[.,g],parameters_g,item_n_cat_g,model_curr_asked_g, group_uniq_total_obs[g,1])
			PXk_Uj = PXk_Uj :/ rowsum(PXk_Uj)
			theta =  rowsum(PXk_Uj :* X_k_theta')
							
			crossme_g	= J(rows(theta),N_par_g,0)
			
			range_start		=	1
			range_stop		=	range_start+2-1
			X1				=	(1-Cns_DIST[1,g]):*(theta:-DIST[1,g]):/DIST[2,g]^2
			X2				=	(1-Cns_DIST[2,g]):*( (theta:-DIST[1,g]):*(theta:-DIST[1,g]):-DIST[2,g]^2 ):/DIST[2,g]^3
			crossme_g[.,range_start..range_stop] 	= X1,X2
			
			range_start			= range_stop+1
							
			for(i=1;i<=I_g;i++){
				
				n_cat = item_n_cat_g[i]
				model = model_curr_asked_g[i,1]
				if(model=="2plm"){
					range_stop=range_start+2-1		
				}
				if(model=="3plm"){
					range_stop=range_start+3-1		
				}
				if(model=="grm" | model=="gpcm" | model=="pcm" ){
					range_stop=range_start+n_cat-1								
				}
				
				if(sum(Cns_parameters[i,.])<=1){
				
					//2plm
					if(model=="2plm"){
	
						a = parameters_g[i,1]
						b = parameters_g[i,2]
						X_b =(theta :-b)
						Pij = f_Pitem_theta_01(parameters_g[i,.],model_curr_asked_g[i,.],theta)
						
						X1=J(rows(theta),1,0)
						X2=J(rows(theta),1,0)								
						for(c=1;c<=n_cat;c++){
							ord_c			=		*(*point_Uigc[i,g])[c]
							X1[ord_c]		=		( ( (c-1) :- Pij[ord_c] ) :* X_b[ord_c] )  	
							X2[ord_c]		=		( ( (c-1) :- Pij[ord_c] ) :* (-a) ) 													
						}
						
						crossme_g[.,range_start..range_stop] 	= X1,X2	
					}
					
					//3plm
					if(model=="3plm"){
	
						a = parameters_g[i,1]
						b = parameters_g[i,2]
						ccc = parameters_g[i,3]
						
						X_b =(theta :- b)
						Pij = f_Pitem_theta_01(parameters_g[i,.],model_curr_asked_g[i,.], theta)
						V = (Pij:-ccc) :/ (Pij :* (1-ccc))
						
						X1=J(rows(theta),1,0)
						X2=J(rows(theta),1,0)
						X3=J(rows(theta),1,0)								
						for(c=1;c<=n_cat;c++){
							ord_c			=		*(*point_Uigc[i,g])[c]
							X1[ord_c]		=		( ( (c-1) :- Pij[ord_c] ) :* X_b[ord_c]  :* V[ord_c] )	
							X2[ord_c]		=		( ( (c-1) :- Pij[ord_c] ) :* (-a) :* V[ord_c] ) 
							X3[ord_c]		=		( ( (c-1) :- Pij[ord_c] ) :* (1/(1-ccc))) :/ Pij[ord_c] 													
						}	
						
						crossme_g[.,range_start..range_stop] 	= X1,X2,X3				
					}
					
					//grm
					if(model=="grm"){
					
						Pij_0c						=	f_Pitem_theta_0c(parameters_g[i,.],model_curr_asked_g[i,.],theta)
					
						Pij_0c_star					=	J(rows(theta),n_cat+1,.)
						Pij_0c_star[.,1]			=	J(rows(theta),1,1)
						Pij_0c_star[.,n_cat+1]		=	J(rows(theta),1,0)
						grm_parameters				=	J(n_cat-1,1,parameters_g[i,1]),parameters_g[i,(4..4+n_cat-2)]',J(n_cat-1,cols(parameters_g)-4,.),J(n_cat-1,1,1)
						dummy_2plm_model=("2plm","2plm","2")
						for(c=2;c<=n_cat;c++){
							Pij_0c_star[.,c]		=	f_Pitem_theta_01(grm_parameters[c-1,.],dummy_2plm_model,theta)
						}
						
						P_starxQ_star				=	Pij_0c_star :* (1 :- Pij_0c_star)
						
						X_b_star					=	J(rows(theta),n_cat+1,.)
						X_b_star[.,1]					=	J(rows(theta),1,0)
						X_b_star[.,n_cat+1]			=	J(rows(theta),1,0)
						for(c=2;c<=n_cat;c++){
							X_b_star[.,c]			=	theta :- grm_parameters[c-1,2]
						}								
						
						X_b_starxP_starxQ_star		=	X_b_star :* P_starxQ_star
						
						a							=	parameters_g[i,1]								
						
						Score_ij	= J(rows(theta),n_cat,0)
						for(c=1;c<=n_cat;c++){
							ord_c								=	*(*point_Uigc[i,g])[c]
							if(c<n_cat){
								Score_ij[ord_c,1+c] 			=	(a) :* ( P_starxQ_star[ord_c,c+1] :* ( 1 :/Pij_0c[ord_c,c]) )
							}
							if(c>1){
								Score_ij[ord_c,1+c-1] 			=	(-a) :* ( P_starxQ_star[ord_c,c] :* ( 1 :/Pij_0c[ord_c,c]) )
							}
							Score_ij[ord_c,1]					=	( 1 :/ Pij_0c[ord_c,c] ) :* (X_b_starxP_starxQ_star[ord_c,c] :- X_b_starxP_starxQ_star[ord_c,c+1])
						}
						
						crossme_g[.,range_start..range_stop] 	= Score_ij		
					}
					
					
					if(model=="gpcm" | model=="pcm" ){
					
						Pij_0c	=	f_Pitem_theta_0c(parameters_g[i,.],model_curr_asked_g[i,.],theta)
						
						a=parameters_g[i,1]		
						b_1tomax=parameters_g[i,4..4+n_cat-2]		
						
						Zc_1toc=J(rows(theta),n_cat-1,.)
						for(c=1;c<=n_cat-1;c++){
							Zc_1toc[.,c] = a :* ( c :* theta :- sum(b_1tomax[1..c]) )
						}
						Sum_Pc_ctomax=J(rows(theta),n_cat-1,0)
						for(c=1;c<=n_cat-1;c++){
							for(cc=c+1;cc<=n_cat;cc++){
								Sum_Pc_ctomax[.,c]=Sum_Pc_ctomax[.,c] :+ Pij_0c[.,cc]
							}
						}	
						Sum_PcZc_1tomax=J(rows(theta),1,0)
						for(c=1;c<=n_cat-1;c++){
							Sum_PcZc_1tomax=Sum_PcZc_1tomax :+ ( Pij_0c[.,c+1] :* Zc_1toc[.,c])
						}				
						
						Score_ij	= J(rows(theta),n_cat,0)
						for(c=1;c<=n_cat-1;c++){
							for(cat=1;cat<=c;cat++){
								ord_cat				=	*(*point_Uigc[i,g])[cat]							
								Score_ij[ord_cat,c+1] =	Score_ij[ord_cat,c+1] :+ Sum_Pc_ctomax[ord_cat,c]
							}
							for(cat=c+1;cat<=n_cat;cat++){
								ord_cat				=	*(*point_Uigc[i,g])[cat]							
								Score_ij[ord_cat,c+1] =	Score_ij[ord_cat,c+1] :- ( 1 :- Sum_Pc_ctomax[ord_cat,c] )
							}
							Score_ij[.,c+1]			= 	a :* Score_ij[.,c+1]
						}
						if(model=="gpcm"){
							ord_1						=	*(*point_Uigc[i,g])[1]
							Score_ij[ord_1,1]			= 	Score_ij[ord_1,1] :- Sum_PcZc_1tomax[ord_1]
							for(cat=2;cat<=n_cat;cat++){
								ord_cat					=	*(*point_Uigc[i,g])[cat]
								Score_ij[ord_cat,1]		= 	Score_ij[ord_cat,1] :+ (Zc_1toc[ord_cat,cat-1] :- Sum_PcZc_1tomax[ord_cat])
							}
							Score_ij[.,1]				= 	(1/a) :* Score_ij[.,1]
						}
		
						crossme_g[.,range_start..range_stop] 	= Score_ij
					
					}
				
				}
				
				range_start=range_stop+1
			}

			
			for(j=1;j<=rows(Fg);j++){				
				long_obsdata_Score_crosspr[par_range_g,par_range_g']=long_obsdata_Score_crosspr[par_range_g,par_range_g'] :+ (cross(crossme_g[j,.],crossme_g[j,.]):*  Fg[j])
			}	
		}
			
		
		V= invsym(long_obsdata_Score_crosspr)	
		
		// rescaling if pcm
		if(sum(model_curr_asked[.,1]:=="pcm")>0 & Cns_DIST[1,1]==1){
			indexoffirstpcm=sum((colsum(select(Cns_matrix,rowsum(Cns_matrix):==0))':>0):*(1::cols(Cns_matrix)))
			sdthetag1=DIST[2,1]
			parameters[.,4..30]=parameters[.,4..30]/sdthetag1
			parameters[.,2]=parameters[.,2]/sdthetag1
			parameters[.,1]=parameters[.,1]*sdthetag1
			DIST=DIST/sdthetag1
			
			Vtemp=V
			Vtemp[.,2]=V[.,indexoffirstpcm]
			Vtemp[.,indexoffirstpcm]=V[.,2]*sdthetag1
			V=Vtemp
			V[2,.]=Vtemp[indexoffirstpcm,.]
			V[indexoffirstpcm,.]=Vtemp[2,.]*sdthetag1
			Vtemp=J(0,0,.)
			V=V/sdthetag1^2
			
			Cns_DIST[2,1]=1
			Cns_matrix=create_long_Cns_matrix(DIST,parameters,Cns_parameters, Cns_DIST)
		}
		
		
		se=sqrt(rowsum(diag(V)))
		
		parameters_err=uncreate_long_vector(se,parameters,DIST,0)
		
		DIST_err=uncreate_long_vector(se,parameters,DIST,1)		
		
		results = J(6,1,NULL)
		results[1] = &DIST_err
		results[2] = &parameters_err
		results[3] = &V
		results[4] = &Cns_matrix
		results[5] = &parameters
		results[6] = &DIST
		return(results)
		
	}
	


	pointer colvector errors_DM(string scalar errors, real scalar perturbation, real matrix long_EMhistory_matrix,       real colvector group_vals , real matrix Cns_parameters, real matrix Cns_DIST, string colvector itemlist, real matrix item_fix_init_indicator, string matrix model_curr_asked, real matrix item_group_totalobs, real matrix group_uniq_total_obs, real matrix parameters, real matrix X_k , real matrix A_k, pointer matrix point_Uigc, pointer matrix point_Fg ,  real matrix DIST, real scalar N_iter_NRF, real scalar crit_par){
		
		
		N_gr	= rows(group_vals)
		I		= rows(parameters)
		
		item_n_cat=strtoreal(model_curr_asked[.,3])
		

		long_final_estimates=create_long_vector(DIST,parameters)
		N_par=rows(long_final_estimates)
		Cns_matrix=create_long_Cns_matrix(DIST,parameters,Cns_parameters, Cns_DIST)
		
	// compute Fisher information
		long_completedata_Fisher=J(N_par,N_par,0)
		range_start=1
		for(g=1;g<=N_gr;g++){
			range_stop		= range_start+2-1
			total_obs_g		= group_uniq_total_obs[g,2]
			variance_g		= DIST[2,g]^2
			long_completedata_Fisher[range_start::range_stop,range_start..range_stop] = ( (total_obs_g/variance_g)*(1-Cns_DIST[1,g]) , 0 \ 0 , 2*total_obs_g/variance_g*(1-Cns_DIST[2,g]) )
			range_start		= range_stop+1
		}
					
		e_step_results	= e_step(Cns_parameters, Cns_DIST,itemlist,item_n_cat,item_group_totalobs,model_curr_asked,group_uniq_total_obs,parameters,X_k ,A_k,point_Uigc,point_Fg)
		p_ik			= *e_step_results[3]
		p_ck			= *e_step_results[4]
		f_ik			= *e_step_results[5]		
		
		for(i=1;i<=I;i++){
			n_cat = item_n_cat[i]
			model = model_curr_asked[i,.]
			if(n_cat>2){
				row_p_ck = sum(select(item_n_cat[1::i],item_n_cat[1::i]:>2))-n_cat+1		
				pi_ck=p_ck[(row_p_ck::row_p_ck+n_cat-1),.]
				Fisher_i=m_step(X_k, model,item_fix_init_indicator[i,.] ,parameters[i,.] ,f_ik[i,.],p_ik[i,.],pi_ck,1)
			}
			else{
				Fisher_i=m_step(X_k, model, item_fix_init_indicator[i,.], parameters[i,.] ,f_ik[i,.],p_ik[i,.],p_ck,1)
			}
			range_stop=range_start+cols(Fisher_i)-1
			long_completedata_Fisher[range_start::range_stop,range_start..range_stop]=Fisher_i
			range_start=range_stop+1
		}
		
		
		
		
		
	// REM | CDM
		if(errors=="rem" |  errors=="cdm" ){
			if(errors=="rem"){
				max_rem_iter = 4
			}
			if(errors=="cdm"){
				max_rem_iter = 2
			}
			
			long_DM_marix=J(N_par,N_par,0)
			perturbation_rem_vector=(perturbation,-perturbation,2*perturbation,-2*perturbation)
			multiplyby_rem_vector=(8,-8,-1,1)
			
			stata("display "+char(34)+"Calculating errors ("+strupper(errors)+"): 0%"+char(34)+" _c")
			previous_progress=0
			
			for(rem_iter=1;rem_iter<=max_rem_iter;rem_iter++){
				for(par=1;par<=N_par;par++){
				
					current_progress	= 100 * ( N_par*(rem_iter-1) + par ) / (max_rem_iter*N_par)
					previous_progress	= progress(current_progress,previous_progress)
					
					if(sum(abs(Cns_matrix[.,par]))==0){
		
						long_final_estimates_par			= long_final_estimates
						long_final_estimates_par[par]		= long_final_estimates_par[par]+perturbation_rem_vector[rem_iter]
						
						parameters_par						= uncreate_long_vector(long_final_estimates_par ,parameters,DIST,0)
						DIST_par							= uncreate_long_vector(long_final_estimates_par ,parameters,DIST,1)
									
						X_k_upd_quad = X_k
						for(g=1;g<=N_gr;g++){				
							if(g>1-sum(Cns_DIST[.,1]:==0)){
								X_k_upd_quad[.,g] 	=(((X_k[.,g] :- DIST[1,g])/DIST[2,g]):*DIST_par[2,g]):+DIST_par[1,g]
							}
						}
						
						em_step_results			= em_step(Cns_parameters, Cns_DIST,itemlist,item_n_cat,item_fix_init_indicator,item_group_totalobs,model_curr_asked,group_uniq_total_obs,parameters_par[.,.],X_k_upd_quad ,A_k,point_Uigc,point_Fg  ,  DIST_par[.,.],       0     ,N_iter_NRF,crit_par)								
		
						DIST_par_plus1			= *em_step_results[1]
						parameters_par_plus1	= *em_step_results[2]					
						
						long_final_estimates_par_plus1		= create_long_vector(DIST_par_plus1, parameters_par_plus1)
						long_DM_marix[par,.]				= long_DM_marix[par,.]:+(long_final_estimates_par_plus1':*multiplyby_rem_vector[rem_iter])
									
					}	
				}
			}
			if(errors=="rem"){
				long_DM_marix		= long_DM_marix :/ (12*perturbation)
			}
			if(errors=="cdm"){
				long_DM_marix		= long_DM_marix :/ (16*perturbation)
			}
		}
		
	// SEM
		if(errors=="sem"){
		
			crit_sem			= crit_par^0.5
			long_starti_vector	= J(N_par,1,2)
			shift_stop			= min(long_starti_vector)+1
		
			long_DM_marix		= J(N_par,N_par,0)
			long_DM_marix_less1	= J(N_par,N_par,1)
			long_DM_marix_fix	= (J(N_par,1,colsum(abs(Cns_matrix[.,1..N_par]))) + J(N_par,1,colsum(abs(Cns_matrix[.,1..N_par])))') :!= 0
			DM_tocoverge        = sum(long_DM_marix_fix:==0)
		
			for(sem_iter=0;sem_iter<=cols(long_EMhistory_matrix)-shift_stop;sem_iter++){
			
				N_converged = sum(long_DM_marix_fix)
				if(N_converged!=N_par^2){
				stata("display "+char(34)+"Calculating errors ("+strupper(errors)+";it="+strofreal(sem_iter)+";conv="+strofreal(floor(100*(DM_tocoverge-sum(long_DM_marix_fix:==0))/DM_tocoverge))+"%): 0%"+char(34)+" _c")
				previous_progress=0
				}
				
				for(par=1;par<=N_par;par++){
				
					if(N_converged!=N_par^2){
						current_progress	= 100 * par / N_par
						previous_progress	= progress(current_progress,previous_progress)
					}
					
					if(sum(abs(Cns_matrix[.,par]))==0){
						if(sum(long_DM_marix_fix[par,.])<N_par ){		
		
							long_starti_vector[par]=long_starti_vector[par]+1
							
							long_final_estimates_par			= long_final_estimates
							long_final_estimates_par[par]		= long_EMhistory_matrix[par,long_starti_vector[par]]
											
							parameters_par						= uncreate_long_vector(long_final_estimates_par ,parameters,DIST,0)
							DIST_par							= uncreate_long_vector(long_final_estimates_par ,parameters,DIST,1)
							
							X_k_upd_quad = X_k
							for(g=1;g<=N_gr;g++){				
								if(g>1-sum(Cns_DIST[.,1]:==0)){
									X_k_upd_quad[.,g] 	=(((X_k[.,g] :- DIST[1,g])/DIST[2,g]):*DIST_par[2,g]):+DIST_par[1,g]
								}
							}
												
							em_step_results			= em_step(Cns_parameters, Cns_DIST,itemlist,item_n_cat,item_fix_init_indicator,item_group_totalobs,model_curr_asked,group_uniq_total_obs,parameters_par[.,.],X_k_upd_quad ,A_k,point_Uigc,point_Fg  ,  DIST_par[.,.],       0     ,N_iter_NRF,crit_par)								
			
							DIST_par_plus1			= *em_step_results[1]
							parameters_par_plus1	= *em_step_results[2]					
							
							long_final_estimates_par_plus1		= create_long_vector(DIST_par_plus1, parameters_par_plus1)
									
							for(j=1;j<=N_par;j++){
								if(long_DM_marix_fix[par,j]==0 & sum(abs(Cns_matrix[.,j]))==0  ){
									long_DM_marix[par,j]=(long_final_estimates_par_plus1[j]-long_final_estimates[j])/(long_final_estimates_par[par]-long_final_estimates[par])
								}
							}
						}
					}		
				}
	// checking for convergence of [par1,par2] element of long_DM_marix			
				if(sem_iter==0){
					long_DM_marix_less1=long_DM_marix		
				}
				if(sem_iter>=1){
				
					for(par1=1;par1<=N_par;par1++){
						for(par2=1;par2<=N_par;par2++){
						
							if(long_DM_marix_fix[par1,par2]==0){
								abs1	= abs(long_DM_marix_less1[par1,par2]-long_DM_marix[par1,par2])
								if(abs1<crit_sem){
									long_DM_marix_fix[par1,par2]=1
								}
							}						
						}
					}
					
					long_DM_marix_less1=long_DM_marix
					
				}
				
			}
			N_converged = sum(long_DM_marix_fix)
			if(N_converged!=N_par^2){
				display("Calculating errors: Warning; "+strofreal(N_par^2-N_converged)+" of "+strofreal(N_par^2)+"elements of DM matrix did not reach convergence; errors may be inadequate")
			}
			else{
				display("Calculating errors: SEM converged")
			}
		}

		
		V= invsym(long_completedata_Fisher) * luinv(I(N_par) - long_DM_marix)
		V=(makesymmetric(V):+makesymmetric(V')):/2
		
		// rescaling if pcm
		if(sum(model_curr_asked[.,1]:=="pcm")>0 & Cns_DIST[1,1]==1){
			indexoffirstpcm=sum((colsum(select(Cns_matrix,rowsum(Cns_matrix):==0))':>0):*(1::cols(Cns_matrix)))
			sdthetag1=DIST[2,1]
			parameters[.,4..30]=parameters[.,4..30]/sdthetag1
			parameters[.,2]=parameters[.,2]/sdthetag1
			parameters[.,1]=parameters[.,1]*sdthetag1
			DIST=DIST/sdthetag1
			
			Vtemp=V
			Vtemp[.,2]=V[.,indexoffirstpcm]
			Vtemp[.,indexoffirstpcm]=V[.,2]*sdthetag1
			V=Vtemp
			V[2,.]=Vtemp[indexoffirstpcm,.]
			V[indexoffirstpcm,.]=Vtemp[2,.]*sdthetag1
			Vtemp=J(0,0,.)
			V=V/sdthetag1^2
			
			Cns_DIST[2,1]=1
			Cns_matrix=create_long_Cns_matrix(DIST,parameters,Cns_parameters, Cns_DIST)
		}
		
		se=sqrt(rowsum(diag(V)))
		
		parameters_err=uncreate_long_vector(se,parameters,DIST,0)
		
		DIST_err=uncreate_long_vector(se,parameters,DIST,1)
		
		results = J(6,1,NULL)
		results[1] = &DIST_err
		results[2] = &parameters_err
		results[3] = &V
		results[4] = &Cns_matrix
		results[5] = &parameters
		results[6] = &DIST
		return(results)
		
	}
	

	real matrix dif(string colvector diflist, real colvector logL , string colvector group_labels, string scalar icc_format     ,    real scalar N_iter, real scalar crit_ll, string matrix model_curr_asked, real scalar theta_nip, real colvector Theta_id, real colvector Theta_dup, real colvector group_vals                   ,                       real matrix Cns_parameters, real matrix Cns_DIST, string colvector itemlist, real matrix item_group_totalobs, real matrix group_uniq_total_obs, real matrix item_fix_init_indicator, real matrix parameters, real matrix X_k , real matrix A_k, pointer matrix point_Uigc, pointer matrix point_Fg                 ,                real matrix DIST, real scalar upd_quad_betw_em, real scalar N_iter_NRF, real scalar crit_par,pointer matrix point_item_cats, string scalar theta_name){
	
		item_n_cat = strtoreal(model_curr_asked[.,3])
	
		dif_results=J(rows(diflist),8,.)
		
		LL0=sum(logL)
		
		I_dif	= rows(diflist)
		I		= rows(itemlist)
		
		for(i=1;i<=I_dif;i++){
			
			point_Uigc_dif=J(I,2,NULL)
			for(g=1;g<=2;g++){

				itemselectrange_g	= select((1::I),item_group_totalobs[.,g]:>0)
				itemlist_g 			= itemlist[itemselectrange_g]
				I_g					= rows(itemlist_g)
				
				no_dif_range_g		= select((1::I_g),itemlist_g:!=diflist[i])
				dif_range_g			= select((1::I_g),itemlist_g:==diflist[i])
				
				point_Uigc_dif[1::I_g,g]	= point_Uigc[no_dif_range_g,g] \ point_Uigc[dif_range_g,g]
			}

			
			no_dif_range			= select((1::I),itemlist:!=diflist[i])
			dif_range				= select((1::I),itemlist:==diflist[i])		
			dif_reindex				= no_dif_range\dif_range\dif_range
						
			n_cat					= item_n_cat[dif_range]
			item_n_cat_dif			= item_n_cat[dif_reindex]
			item_fix_init_indicator_dif	= item_fix_init_indicator[dif_reindex,.]
			point_item_cats_dif		= point_item_cats[dif_reindex]
			parameters_dif			= parameters[dif_reindex,.]	
			item_group_totalobs_dif	= item_group_totalobs[no_dif_range,.] 	\ ( item_group_totalobs[dif_range,.] :* (1,0\0,1) )		
			itemlist_dif			= itemlist[no_dif_range] \ (diflist[i]+"_GR") \ (diflist[i]+"_GF")
			model_curr_asked_dif	= model_curr_asked[dif_reindex,.]
			Cns_parameters_dif		= Cns_parameters[dif_reindex,.]
			
			em_results				= em(N_iter, 0, ".", crit_ll, model_curr_asked_dif, 0 , 1 ,0, ".", theta_nip, Theta_id, Theta_dup, ".", group_vals                  ,                       Cns_parameters_dif, Cns_DIST, itemlist_dif, item_n_cat_dif, item_fix_init_indicator_dif, point_item_cats_dif, item_group_totalobs_dif, group_uniq_total_obs, parameters_dif, X_k[.,.] , A_k, point_Uigc_dif, point_Fg                 ,                 DIST[.,.], upd_quad_betw_em, N_iter_NRF, crit_par)
			
			DIST_resdif				= *em_results[1]
			parameters_resdif		= (*em_results[2])[(I::I+1),.]
			logL_resdif				= *em_results[3]
			X_k_resdif				= *em_results[4]
			model_resdif			= (*em_results[6])[(I::I+1),.]
			Cns_parameters_resdif	= (*em_results[7])[(I::I+1),.]

			LL1			= sum(logL_resdif)
			LR			= 2*(LL1-LL0)
			if(model_resdif[1,1]==model_resdif[2,1]){
				df			= (nonmissing(parameters_resdif)-sum(Cns_parameters_resdif))/2
				pvalue		= 1-chi2(df,LR)
				print_notnested=0
			}
			else{
				pvalue		= .
				print_notnested=1
			}
	
			
			if(n_cat == 2 & model_resdif[1,1]!="pcm"){
				mean1GR = sum(f_PiXk_01(parameters_resdif[1,.],model_resdif[1,.],X_k_resdif[.,1])*A_k[.,1])
				mean2GR = sum(f_PiXk_01(parameters_resdif[2,.],model_resdif[2,.],X_k_resdif[.,1])*A_k[.,1])
				mean1GF = sum(f_PiXk_01(parameters_resdif[1,.],model_resdif[1,.],X_k_resdif[.,2])*A_k[.,2])
				mean2GF = sum(f_PiXk_01(parameters_resdif[2,.],model_resdif[2,.],X_k_resdif[.,2])*A_k[.,2])
			}
			else{
				mean1GR = 0
				mean2GR = 0
				mean1GF = 0
				mean2GF = 0
				PiXk_11 = f_PiXk_0c(parameters_resdif[1,.],model_resdif[1,.],X_k_resdif[.,1])
				PiXk_21 = f_PiXk_0c(parameters_resdif[2,.],model_resdif[2,.],X_k_resdif[.,1])
				PiXk_12 = f_PiXk_0c(parameters_resdif[1,.],model_resdif[1,.],X_k_resdif[.,2])
				PiXk_22 = f_PiXk_0c(parameters_resdif[2,.],model_resdif[2,.],X_k_resdif[.,2])
				for(c=2;c<=n_cat;c++){
					mean1GR = mean1GR + (c-1)*sum(PiXk_11[c,.]*A_k[.,1])
					mean2GR = mean2GR + (c-1)*sum(PiXk_21[c,.]*A_k[.,1])
					mean1GF = mean1GF + (c-1)*sum(PiXk_12[c,.]*A_k[.,2])
					mean2GF = mean2GF + (c-1)*sum(PiXk_22[c,.]*A_k[.,2])		
				}
			}
			
			
			display("")
			display("_____________________________________________________________________")
			display("DIF analysis of item "+diflist[i]+" (GR: gr()="+strofreal(group_vals[1])+" , GF: gr()="+strofreal(group_vals[2])+")")
							
			display("")
			stata("display _col(10) %10s "+char(34)+"GR"+char(34)+" _col(20)  %10s "+char(34)+"GF"+char(34))	
			stata("display %10s "+char(34)+"a"+char(34)+" _col(10) %10.4f "+strofreal(parameters_resdif[1,1])+" _col(20) %10.4f "+strofreal(parameters_resdif[2,1]))
			if(nonmissing(parameters_resdif[.,2])){
				stata("display %10s "+char(34)+"b"+char(34)+" _col(10) %10.4f "+strofreal(parameters_resdif[1,2])+" _col(20) %10.4f "+strofreal(parameters_resdif[2,2]))
			}
			if(nonmissing(parameters_resdif[.,3])){
				stata("display %10s "+char(34)+"c"+char(34)+" _col(10) %10.4f "+strofreal(parameters_resdif[1,3])+" _col(20) %10.4f "+strofreal(parameters_resdif[2,3]))
			}
			if(n_cat>2 | model_resdif[1,1]=="pcm"){
				for(c=1;c<=n_cat-1;c++){
					stata("display %10s "+char(34)+"b"+strofreal(c)+char(34)+" _col(10) %10.4f "+strofreal(parameters_resdif[1,3+c])+" _col(20) %10.4f "+strofreal(parameters_resdif[2,3+c]))
				}
			}		
			
			display("")
			stata("display %15s "+char(34)+"E(parR,GR)"+char(34)+" _col(15)  %15s "+char(34)+"E(parF,GR)"+char(34)+" _col(30)  %15s "+char(34)+"E(parR,GF)"+char(34)+" _col(45)  %15s "+char(34)+"E(parF,GF)"+char(34))
			stata("display %15.4f "+strofreal(mean1GR)+" _col(15) %15.4f "+strofreal(mean2GR)+" _col(30) %15.4f "+strofreal(mean1GF)+" _col(45) %15.4f "+strofreal(mean2GF))

			display("")			
			if(print_notnested){
				display("Note: DIF model is not nested because item has different IRF between groups, p-value not computed")
				display("")		
			}
			stata("display %10s "+char(34)+"LR"+char(34)+" _col(10)  %10s "+char(34)+"p-value"+char(34)+" _col(20)  %10s "+char(34)+"P-DIF|GR"+char(34)+" _col(30)  %10s "+char(34)+"P-DIF|GF"+char(34))
			stata("display %10.4f "+strofreal(LR)+" _col(10) %10.4f "+strofreal(pvalue)+" _col(20) %10.4f "+strofreal(mean2GR-mean1GR)+" _col(30) %10.4f "+strofreal(mean1GF-mean2GF))
			
				
			dif_results[i,.]=(LR,pvalue,mean2GR-mean1GR, mean1GF-mean2GF, mean1GR,mean2GR,mean1GF,mean2GF)
			
			point_item_cats_resdif=point_item_cats_dif[(I::I+1),.]
			icc_graph(J(0,0,.),(1\1),icc_format,(diflist[i]\diflist[i]),parameters_resdif ,model_resdif, item_group_totalobs,point_Uigc_dif , point_Fg,group_labels,theta_name,point_item_cats_resdif,DIST_resdif)
		
		}
		
		return(dif_results)
	}



	function create_long_vector(real matrix DIST, real matrix parameters){
		N_gr=cols(DIST)
		long_vector=J(2*N_gr + nonmissing(parameters[.,1..cols(parameters)-2]),1,. )
		range_start=1
		for(g=1;g<=N_gr;g++){
			range_stop=range_start+2-1
			long_vector[range_start::range_stop]=DIST[.,g]
			range_start=range_stop+1
		}
		for(i=1;i<=rows(parameters);i++){
			parameters_extract=select(parameters[i,1..cols(parameters)-2]',parameters[i,1..cols(parameters)-2]':!=.)
			range_stop=range_start+rows(parameters_extract)-1
			long_vector[range_start::range_stop]=parameters_extract
			range_start=range_stop+1
		}
		return(long_vector)
	}
	
	function  create_long_Cns_matrix(real matrix DIST, real matrix parameters, real matrix Cns_parameters, real matrix Cns_DIST){
		
		Cns_long_vector=create_long_vector(Cns_DIST, Cns_parameters)
		long_final_estimates=create_long_vector(DIST,parameters)
		N_par=rows(long_final_estimates)
		N_gr=cols(DIST)
		
		Cns_matrix_C=J(0,N_par,.)
		Cns_matrix_R=J(0,1,.)
		range_start=1
		for(g=1;g<=N_gr;g++){
			range_stop=range_start+2-1
			for(par=range_start;par<=range_stop;par++){
				if(Cns_long_vector[par]){
					Cns_matrix_C_par=J(1,N_par,0)
					Cns_matrix_C_par[par]=1
					Cns_matrix_C=Cns_matrix_C\Cns_matrix_C_par
					Cns_matrix_R=Cns_matrix_R\long_final_estimates[par]
				}
			}
			range_start=range_stop+1
		}
		indexoffirstpcm=0
		for(i=1;i<=rows(parameters);i++){
			Cns_parameters_extract=select(Cns_parameters[i,1..cols(Cns_parameters)-2]',Cns_parameters[i,1..cols(Cns_parameters)-2]':!=.)
			range_stop=range_start+rows(Cns_parameters_extract)-1
			if(rows(Cns_parameters_extract)==sum(Cns_parameters_extract)){
				for(par=range_start;par<=range_stop;par++){
					Cns_matrix_C_par=J(1,N_par,0)
					Cns_matrix_C_par[par]=1
					Cns_matrix_C=Cns_matrix_C\Cns_matrix_C_par
					Cns_matrix_R=Cns_matrix_R\long_final_estimates[par]
				}
			}
			//the following assumed to be only the case of pcm
			if(sum(Cns_parameters_extract)==1){
				if(indexoffirstpcm==0){
					indexoffirstpcm=range_start
				}
				else{
					Cns_matrix_C_par=J(1,N_par,0)
					Cns_matrix_C_par[indexoffirstpcm]=1
					Cns_matrix_C_par[range_start]=-1
					Cns_matrix_C=Cns_matrix_C\Cns_matrix_C_par
					Cns_matrix_R=Cns_matrix_R\0
				}
			}
			range_start=range_stop+1
		}
		
		long_Cns_matrix=Cns_matrix_C,Cns_matrix_R
		return(long_Cns_matrix)
	}

// seems Cns_matrices not necessary at all here		
	function uncreate_long_vector(real matrix long_vector,real matrix parameters, real matrix DIST, real scalar ifdist){
		toreturn=DIST
		N_gr=cols(DIST)
		range_start=1
		for(g=1;g<=N_gr;g++){
			range_stop=range_start+2-1
			toreturn[.,g]=long_vector[range_start::range_stop]
			range_start=range_stop+1
		}
		if(ifdist==0){
			toreturn=parameters
			for(i=1;i<=rows(parameters);i++){
				for(c=1;c<=cols(parameters)-2;c++){
					if(parameters[i,c]!=.){
						toreturn[i,c]=long_vector[range_start]
						range_start=range_start+1
					}
				}
			}
		}
		return(toreturn)
	}

	
	
	
// draws icc line for a single item parameter matrix
	string scalar icc_graph_function(real matrix parameters, string matrix model, string matrix colours_vector){
		n_cat=strtoreal(model[3])
		stata_command=""
		if (n_cat==2 & model[1]=="2plm"){
			stata_command=stata_command+"(function invlogit("+strofreal(parameters[1])+"*(x-"+strofreal(parameters[2])+")), range(-4 4) clcolor("+colours_vector[2]+"))"
		}
		if (n_cat==2 & model[1]=="pcm"){
			stata_command=stata_command+"(function invlogit("+strofreal(parameters[1])+"*(x-"+strofreal(parameters[4])+")), range(-4 4) clcolor("+colours_vector[2]+"))"
		}
		if (n_cat==2 & model[1]=="3plm" ){
			stata_command=stata_command+"(function "+strofreal(parameters[3])+" +(1-"+strofreal(parameters[3])+")*invlogit("+strofreal(parameters[1])+"*(x-"+strofreal(parameters[2])+")), range(-4 4) clcolor("+colours_vector[2,1]+")) || (function "+strofreal(parameters[3])+", range(-4 4) clcolor("+colours_vector[1]+") clpattern(dash))"
		}
		if (n_cat>2 & model[1]=="grm"){
			start_cat = 1+missing(parameters[1..3])+1
			stata_command=stata_command+"(function 1-invlogit("+strofreal(parameters[1])+"*(x-"+strofreal(parameters[start_cat])+")), range(-4 4) clcolor("+colours_vector[1]+")) || "
			for(c=1;c<=n_cat-2;c++){
				stata_command=stata_command+"(function (invlogit("+strofreal(parameters[1])+"*(x-"+strofreal(parameters[start_cat+c-1])+"))-invlogit("+strofreal(parameters[1])+"*(x-"+strofreal(parameters[start_cat+c])+"))), range(-4 4) clcolor("+colours_vector[c+1]+")) || "
			}
			stata_command=stata_command+"(function invlogit("+strofreal(parameters[1])+"*(x-"+strofreal(parameters[start_cat+c-1])+")), range(-4 4) clcolor("+colours_vector[c+1]+")) || "
		}
		if (n_cat>2 & model[1]!="grm"){
			start_cat = 1+missing(parameters[1..3])+1
			expsum_all_function="(1+"
			for(c=2;c<=n_cat;c++){
				expsum_all_function=expsum_all_function+"exp("+strofreal(parameters[1,1])+"*("+strofreal(c-1)+"*x-("+strofreal(sum(parameters[1,(start_cat..(start_cat+c-2))]))+")))+"
			}
			expsum_all_function=expsum_all_function+")"
			expsum_all_function=subinstr(expsum_all_function,"+)",")")
			stata_command=stata_command+"(function 1/"+expsum_all_function+", range(-4 4) clcolor(red)) || "
			for(c=2;c<=n_cat;c++){
				expsum_cat_function="exp("+strofreal(parameters[1,1])+"*("+strofreal(c-1)+"*x-("+strofreal(sum(parameters[1,(start_cat..(start_cat+c-2))]))+")))"				
				stata_command=stata_command+"(function "+expsum_cat_function+"/"+expsum_all_function+", range(-4 4) clcolor("+colours_vector[c+1,1]+")) || "
			}
		}
		
		return(stata_command)
	}

	
	
	pointer colvector icc_graph_emppoints(real matrix Pj_centile, pointer matrix point_Uixx, pointer matrix point_Fg, real scalar n_cat,real matrix item_group_totalobs_i, string matrix colours_vector){
		
		// discard ploting frequency in a quantile of less than min_icc_pvbin is observed
		min_icc_pvbin=10
		
		icc_intervals=cols(Pj_centile)
		
		N_gr=rows(point_Fg)
		
		stata_command=""
		
		X_k_icc = J(icc_intervals,1,.)
		for(interval=1;interval<=icc_intervals;interval++){
			X_k_icc[interval,1]=invnormal(interval/icc_intervals-0.5/icc_intervals)
		}

		if(n_cat == 2){
			P_item=J(icc_intervals,1,0)
		}
		else{
			P_item=J(icc_intervals,n_cat,0)
		}
		
		
		weight_g=sum(item_group_totalobs_i)
		
		min_icc_pvbin_matrix=J(1,icc_intervals,0)
		group_range_stop=0		
		for(g=1;g<=N_gr;g++){
		
			Fg	= *point_Fg[g]
			
			group_range_start=group_range_stop+1
			group_range_stop=group_range_stop+rows(Fg)
			
			if(item_group_totalobs_i[g]){
				
				nonmiss_U_ig_vector=J(0,1,.)
				for(c=1;c<=n_cat;c++){
					nonmiss_U_ig_vector=nonmiss_U_ig_vector\(*(*point_Uixx[g])[c])
				}
				min_icc_pvbin_matrix	=	min_icc_pvbin_matrix :+ colsum( (*point_Fg[g])[nonmiss_U_ig_vector] :* (Pj_centile[nonmiss_U_ig_vector,.]:>0) )
	
				weight_ig = item_group_totalobs_i[g]/weight_g

				Pj_centile_g = Pj_centile[group_range_start::group_range_stop,.]
				
				denominator=colsum( Fg[nonmiss_U_ig_vector] :* Pj_centile_g[nonmiss_U_ig_vector,.] )
				
				if(n_cat==2){
					P_item_ig_weight= ( colsum( Fg[*(*point_Uixx[g])[2]] :* Pj_centile_g[*(*point_Uixx[g])[2],.] ) :/ denominator  )'
					P_item[(1::icc_intervals)]=rowsum( (P_item[(1::icc_intervals)] , P_item_ig_weight * weight_ig) )
				}
				else{			
					for(c=1;c<=n_cat;c++){
					P_item_ig_weight= ( colsum( Fg[*(*point_Uixx[g])[c]] :* Pj_centile_g[*(*point_Uixx[g])[c],.] ) :/ denominator )'
					P_item[(1::icc_intervals),c]=rowsum( (P_item[(1::icc_intervals),c] , P_item_ig_weight * weight_ig) )
					}
				}
			}
		}
		
		min_icc_pvbin_matrix=(min_icc_pvbin_matrix' :< min_icc_pvbin)
		if(sum(min_icc_pvbin_matrix)){
			miss_index=select((1::icc_intervals),min_icc_pvbin_matrix)
			P_item[miss_index,.]=J(rows(miss_index),cols(P_item),.)
		}

		tempvarlist=""
		ThetaMode_var=st_tempname()
		tempvarlist=tempvarlist+" "+ThetaMode_var
		index_temp=st_addvar("double",ThetaMode_var)
		st_store((1::icc_intervals),ThetaMode_var,X_k_icc)
		
		
		if(n_cat==2){
			ItemMean_var=st_tempname()
			tempvarlist=tempvarlist+" "+ItemMean_var
			index_temp=st_addvar("double",ItemMean_var)
			st_store((1::icc_intervals),ItemMean_var,P_item[(1::icc_intervals)])
			stata_command=stata_command+"(scatter  "+ItemMean_var+" "+ThetaMode_var+", mcolor("+substr(colours_vector[2],1,strlen(colours_vector[2])-1)+"*0.5"+char(34)+") msize(vsmall)) || "	
		}
		else{
			for(c=1;c<=n_cat;c++){
				ItemMean_var=st_tempname()
				tempvarlist=tempvarlist+" "+ItemMean_var
				index_temp=st_addvar("double",ItemMean_var)
				st_store((1::icc_intervals),ItemMean_var,P_item[(1::icc_intervals),c])
				stata_command=stata_command+"(scatter  "+ItemMean_var+" "+ThetaMode_var+", mcolor("+substr(colours_vector[c,1],1,strlen(colours_vector[c,1])-1)+"*0.5"+char(34)+") msize(vsmall)) || "
			}
		}
		
		
		results = J(2,1,NULL)
		results[1] = &stata_command
		results[2] = &tempvarlist
		return(results)
	}

	
	void icc_graph(real matrix Pj_centile, real matrix if_makeicc, string scalar icc_format, string matrix itemlist,real matrix parameters, string matrix model_curr_asked, real matrix item_group_totalobs, pointer matrix point_Uigc, pointer matrix point_Fg, string matrix group_labels, string scalar theta_name, pointer matrix point_item_cats,real matrix DIST_for_dif){
		
		if(sum(if_makeicc)){
		
			I=rows(itemlist)
			N_gr=rows(point_Fg)
	
			if(theta_name!="."){
				thetan="_"+theta_name
			}
			else{
				thetan=""
			}
	
			if(rows(Pj_centile)>0){
				icc_obs=1
			}
			else{
				icc_obs=0
			}
			
	// DIF graph
			if(I==2 & rows(DIST_for_dif)>0){
				groupvarname="Group"
			
				colours_vector=J(30,1,("red","blue"))
				itemname=itemlist[1,1]			
				stata_command="qui twoway "

				n_cat = strtoreal(model_curr_asked[1,3])
				shift_legend=(0\0)
				if(n_cat == 2){
					shift_legend=shift_legend:+(model_curr_asked[1::2,1]:=="3plm")
					title_cat=strofreal((*point_item_cats[1])[2])
				}
				else{
					shift_legend=shift_legend:+(n_cat-1)
					title_cat="cat"
				}
				for(g=1;g<=N_gr;g++){
					stata_command=stata_command+icc_graph_function(parameters[g,.],model_curr_asked[g,.], colours_vector[.,g])
					stata_command=stata_command+ " (function normalden(x,"+strofreal(DIST_for_dif[1,g])+","+strofreal(DIST_for_dif[2,g])+"), range(-4 4) lcolor("+colours_vector[1,g]+"*0.5) lpattern(dash)) "
				}
				
				lab_1=group_labels[1]
				lab_2=group_labels[2]
				stata_command=stata_command+",  legend(cols(2) order(1 "+char(34)+"P(item="+title_cat+"|{&theta};GR)"+char(34)+" "+strofreal(2+shift_legend[1])+" "+char(34)+"{&psi}({&theta};GR)"+char(34)+" "+strofreal(3+shift_legend[1])+" "+char(34)+"P(item="+title_cat+"|{&theta};GF)"+char(34)+" "+strofreal(4+sum(shift_legend))+" "+char(34)+"{&psi}({&theta};GF)"+char(34)+" )) xtitle("+char(34)+"theta"+thetan+char(34)+") xscale(range(-4 4)) ytitle("+char(34)+"P("+itemname+"="+title_cat+")"+char(34)+") yscale(range(0 1)) ylabel(0(0.2)1) graphregion(color(white)) bgcolor(white)"
				stata(stata_command)
				if(icc_format=="gph"){
					stata("qui graph save DIF_"+itemname+", replace")
				}
				if(icc_format=="eps"){
						stata("qui graph export DIF_"+itemname+".eps,  mag(200)  replace")
				}
				if(icc_format=="png"){
					if("`c(os)'"=="Windows"){
						stata("qui graph export DIF_"+itemname+".png, width(1244) replace")
					}
					if("`c(os)'"=="Unix"){
						stata("qui graph export DIF_"+itemname+".eps,  mag(200)  replace")
						if(fileexists("DIF_"+itemname+".png")){
							unlink("DIF_"+itemname+".png")
						}
						stata("! convert -size 1244 DIF_"+itemname+".eps DIF_"+itemname+".png")
						if(fileexists("DIF_"+itemname+".png")){
							unlink("DIF_"+itemname+".eps")
						}
						else{
							display("unable to perform ! convert -size 1244 DIF_"+itemname+".eps DIF_"+itemname+".png")
						}
					}
				}
				
			}
			else{
				colours_vector=(char(34)+"242 0 60"+char(34) , char(34)+"248 89 0"+char(34) , char(34)+"242 136 0"+char(34) , char(34)+"242 171 0"+char(34) , char(34)+"239 204 0"+char(34) , char(34)+"240 234 0"+char(34) , char(34)+"177 215 0"+char(34) , char(34)+"0 202 36"+char(34) , char(34)+"0 168 119"+char(34) , char(34)+"0 167 138"+char(34) , char(34)+"0 165 156"+char(34) , char(34)+"0 163 172"+char(34) , char(34)+"0 147 175"+char(34) , char(34)+"0 130 178"+char(34) , char(34)+"0 110 191"+char(34) , char(34)+"125 0 248"+char(34) , char(34)+"159 0 197"+char(34) , char(34)+"185 0 166"+char(34) , char(34)+"208 0 129"+char(34) , char(34)+"226 0 100" + char(34), char(34)+"161 0 40" + char(34) , char(34)+"165 59 0" + char(34) , char(34)+"161 91 0" + char(34) , char(34)+"161 114 0" + char(34) , char(34)+"159 136 0" + char(34) , char(34)+"160 156 0" + char(34) , char(34)+"118 143 0" + char(34) , char(34)+"0 135 24" + char(34) , char(34)+"0 112 79" + char(34) , char(34)+"0 111 92" + char(34))'
								
				for(i=1;i<=I;i++){
					if(if_makeicc[i]){
						itemname		= itemlist[i,1]
						stata_command	= "qui twoway "
						n_cat 			= strtoreal(model_curr_asked[i,3])
						
						catcaption=" "
						catcaption_pos=1
						marginsize=strofreal(7+2*max(strlen(strofreal(*point_item_cats[i]))))
						if(n_cat == 2){
							title_cat=strofreal((*point_item_cats[i])[2])
							for(c=2;c<=rows(*point_item_cats[i]);c++){
								catcaption=catcaption+" text("+strofreal(catcaption_pos)+" 4.15 "+char(34)+"cat="+strofreal((*point_item_cats[i])[c])+char(34)+",color("+colours_vector[c]+") place(e)) "
								catcaption_pos=catcaption_pos-0.04
							}
						}
						else{
							title_cat="cat"
							for(c=1;c<=rows(*point_item_cats[i]);c++){
								catcaption=catcaption+" text("+strofreal(catcaption_pos)+" 4.15 "+char(34)+"cat="+strofreal((*point_item_cats[i])[c])+char(34)+",color("+colours_vector[c]+") place(e)) "
								catcaption_pos=catcaption_pos-0.04
							}
						}
						if(icc_obs==1){
							 point_Uixx = J(1,N_gr,NULL)
							for(g=1;g<=N_gr;g++){
								if(item_group_totalobs[i,g]>0){
									i_g = sum(item_group_totalobs[1::i,g]:>0)
									point_Uixx[g]	= point_Uigc[i_g,g]
								}
								else{
									point_Uixx[g]	= &J(0,0,.)
								}
							}
						
							icc_graph_emppoints_res		= icc_graph_emppoints(Pj_centile, point_Uixx,point_Fg, n_cat,item_group_totalobs[i,.], colours_vector)
							stata_command				= stata_command+(*icc_graph_emppoints_res[1])
						}
						stata_command = stata_command+icc_graph_function(parameters[i,.],model_curr_asked[i,.], colours_vector)
						
						stata_command=stata_command+", legend(off) xtitle("+char(34)+"theta"+thetan+char(34)+") xscale(range(-4 4)) ytitle("+char(34)+"P("+itemname+"="+title_cat+")"+char(34)+") yscale(range(0 1)) ylabel(0(0.2)1) graphregion(color(white)) bgcolor(white) graphregion(margin(r="+marginsize+"))"+ catcaption		
		
						stata(stata_command)
						if(icc_format=="gph"){
							stata("qui graph save ICC_"+itemname+", replace")
						}
						if(icc_format=="eps"){
								stata("qui graph export ICC_"+itemname+".eps,  mag(200)  replace")
						}
						if(icc_format=="png"){
							if("`c(os)'"=="Windows"){
								stata("qui graph export ICC_"+itemname+".png, width(1244) replace")
							}
							if("`c(os)'"=="Unix"){
								stata("qui graph export ICC_"+itemname+".eps, mag(200) replace")
								if(fileexists("ICC_"+itemname+".png")){
									unlink("ICC_"+itemname+".png")
								}
								stata("! convert -size 1244 ICC_"+itemname+".eps ICC_"+itemname+".png")
								if(fileexists("ICC_"+itemname+".png")){
									unlink("ICC_"+itemname+".eps")
								}
								else{
									display("unable to perform ! convert -size 1244 ICC_"+itemname+".eps ICC_"+itemname+".png")
								}
							}
						}
						if(icc_obs==1){
							stata( "qui drop "+(*icc_graph_emppoints_res[2]) )
						}
					}
				}
			}	
		}
	}
	
		
	
	pointer colvector em(real scalar N_iter, real scalar trace, string scalar errors, real scalar crit_ll, string matrix model_curr_asked, real scalar guessing_attempts, real scalar guessing_lrcrit,real scalar add_theta, string scalar theta_name, real scalar theta_nip, real colvector Theta_id, real colvector Theta_dup, string scalar savingname,real colvector group_vals                   ,                       real matrix Cns_parameters, real matrix Cns_DIST, string colvector itemlist, real colvector item_n_cat, real matrix item_fix_init_indicator, pointer matrix point_item_cats, real matrix item_group_totalobs, real matrix group_uniq_total_obs, real matrix parameters, real matrix X_k , real matrix A_k, pointer matrix point_Uigc, pointer matrix point_Fg                 ,                real matrix DIST, real scalar upd_quad_betw_em, real scalar N_iter_NRF, real scalar crit_par){


		I=rows(itemlist)
		N_gr=cols(A_k)
		
		if(sum((model_curr_asked[.,1]:=="2plm"):*(model_curr_asked[.,2]:=="3plm"))){
			guesslist = select(itemlist,(model_curr_asked[.,1]:=="2plm"):*(model_curr_asked[.,2]:=="3plm"))
			I_guess = rows(guesslist)
			guessing_attempts_count=1
		}
		else{
			I_guess = 0
		}
		
		delta = J(I,32,1)
		delta_DIST = J(2,N_gr,1)
		delta_ll=1
		display_logLdecrese=0
		
		
		if(errors=="sem"){
			long_EMhistory_matrix=J(rows(create_long_vector(DIST,parameters)),N_iter,.)
		}
		else{
			long_EMhistory_matrix=J(0,0,.)
		}

		
		haywire_list=""
		haywire_guess_list=""
		if_em_converged=1
		for(iter=1;iter<=N_iter;iter++){
			if(( (max(abs(delta))>crit_par) | (max(abs(delta_DIST))>crit_par) ) & delta_ll>crit_ll){
			
				previous_DIST=DIST
				if(iter==1 | haywire_list!="" | haywire_guess_list!=""){
					previous_ll=-10^20	
				}
				else{
					previous_ll=sum(logL)
				}				
									
				em_step_results	= em_step(Cns_parameters, Cns_DIST,itemlist,item_n_cat,item_fix_init_indicator, item_group_totalobs,model_curr_asked,group_uniq_total_obs,parameters,X_k ,A_k,point_Uigc,point_Fg  ,  DIST[.,.],upd_quad_betw_em,N_iter_NRF,crit_par)								
				DIST			= *em_step_results[1]
				parameters		= *em_step_results[2]
				logL			= *em_step_results[3]
				X_k				= *em_step_results[4]
				delta			= *em_step_results[5]
				f_ik			= *em_step_results[6]
				p_ik			= *em_step_results[7]
//				p_ck			= *em_step_results[8]

				delta_DIST=previous_DIST-DIST
				delta_ll=(previous_ll-sum(logL))/sum(logL)

				print_iter(iter,DIST,delta,logL,group_vals,trace,Cns_parameters, Cns_DIST,model_curr_asked)
				
// adding 3plm items that have guessing<0 to haywire_list (	delta[i,.]==delta[i,.]*0)
				haywire_guess_ind=select((1::I),(model_curr_asked[.,1]:=="3plm") :* (parameters[.,3]:<0) )
				if(rows(haywire_guess_ind)){
					delta[haywire_guess_ind,.]=delta[haywire_guess_ind,.]:*0
				}
				
				haywire_list=""
				haywire_guess_list=""
				haywire_indexes=J(0,1,.)
				ok_indexes=J(0,1,.)
				for(i=1;i<=rows(delta);i++){
					if(max(abs(delta[i,.]))==0 & item_fix_init_indicator[i,1]==0){
						if(sum(haywire_guess_ind:==i)){
							haywire_guess_list=haywire_guess_list+" "+itemlist[i]
						}
						else{
							haywire_list=haywire_list+" "+itemlist[i]
						}
						haywire_indexes=haywire_indexes\i
					}
					else{
						ok_indexes=ok_indexes\i
					}
				}	
				if(rows(haywire_indexes)){
				
					if(strlen(haywire_list)){
						display("estimates of folowing items went haywire (|delta_par|>5), their starting values will be refined, logL may increase:")
						display(haywire_list)
					}
					if(strlen(haywire_guess_list)){
						display("guessing parameter turned negative (c<0) for the following items, their starting values will be refined, logL may increase:")
						display(haywire_guess_list)
					}
					
					ll_theta_se = return_ll_theta_se(1 ,195, item_n_cat[ok_indexes,.], item_group_totalobs[ok_indexes,.], model_curr_asked[ok_indexes,.], group_uniq_total_obs, X_k , A_k, parameters[ok_indexes,.], DIST, point_Uigc[ok_indexes,.], point_Fg)
					
					X_var=st_tempname()
					index_temp=st_addvar("double",X_var)
					//  drawing pseudoplausible values, errors in estimating parameters are not accounted for but better solution that EAP
					st_store(Theta_id,index_temp,rnormal(1,1,(*ll_theta_se[2])[Theta_dup],(*ll_theta_se[3])[Theta_dup]))
					
					// if a 3pl item went haywire the model is changed to 2pl
					model_curr_asked[haywire_indexes,1]=subinstr(model_curr_asked[haywire_indexes,1],"3plm","2plm")
					Cns_parameters[haywire_indexes,3]=J(rows(haywire_indexes),1,.)
					guesslist = select(itemlist,(model_curr_asked[.,1]:=="2plm"):*(model_curr_asked[.,2]:=="3plm"))
					I_guess = rows(guesslist)
					
					starting_values_logistic_results 	= starting_values_logistic(itemlist[haywire_indexes,.],model_curr_asked[haywire_indexes,.], J(rows(haywire_indexes),2,0) ,point_item_cats[haywire_indexes], Theta_id, Theta_dup  , item_n_cat[haywire_indexes,.], item_group_totalobs[haywire_indexes,.], group_uniq_total_obs , restrict_point_Uigc(haywire_indexes, item_group_totalobs,point_Uigc), point_Fg, X_var )
				
					remaining_parameters				=*starting_values_logistic_results[1]
					remaining_parameters_failed			=*starting_values_logistic_results[2]
					
					for(i=1;i<=rows(haywire_indexes);i++){
						if(remaining_parameters_failed[i]==0){
							parameters[haywire_indexes[i],.] = remaining_parameters[i,.]
						}
					}
				}
				
													
				if(errors=="sem"){
					// and so we have a problem with this guessing generation in the context of sem, all previous history becomes discarded :/	
					long_EMhistory_vector=create_long_vector(DIST,parameters)
					if(rows(long_EMhistory_vector)!=rows(long_EMhistory_matrix)){
						long_EMhistory_matrix=J(rows(long_EMhistory_vector),N_iter,.)
					}
					long_EMhistory_matrix[.,iter]=create_long_vector(DIST,parameters)
				}							
				
				
				
				if(savingname!="."){
					save_iteration_matrices(itemlist,parameters,savingname,DIST,group_vals)
				}
				
				if(sum((model_curr_asked[.,1]:=="pcm"):*(model_curr_asked[.,2]:=="gpcm")) & (max(delta)<(10^(log10(crit_par)/2)))){
					for(m=1;m<=rows(model_curr_asked);m++){
						if(model_curr_asked[m,1]=="pcm" & model_curr_asked[m,2]=="gpcm"){
							model_curr_asked[m,1]="gpcm"
						}
					}

					if(sum(model_curr_asked[.,1]:=="pcm")==0 & estimate_dist==0){
						parameters[.,4..30]=parameters[.,4..30]/DIST[2,1]
						parameters[.,2]=parameters[.,4]/DIST[2,1]
						parameters[.,1]=parameters[.,1]*DIST[2,1]
						X_k= X_k/DIST[2,1]
						DIST=DIST/DIST[2,1]
					}	
				}
				
				if(I_guess>0){
					if( (max(delta)<(10^(log10(crit_par)/((1-guessing_attempts_count)/guessing_attempts+2)))) & (guessing_attempts_count<=guessing_attempts) ){
						display("generating starting values for guessing parameters for "+strofreal(I_guess)+" item(s); attempt="+strofreal(guessing_attempts_count))
						starting_values_guess_results = starting_values_guess(itemlist ,model_curr_asked, guesslist , guessing_lrcrit, item_group_totalobs, parameters[.,.], X_k[.,.], A_k, f_ik, p_ik, point_Uigc, point_Fg)
						parameters[.,1..3] = *starting_values_guess_results[1]
						Cns_parameters[.,3]			= (parameters[.,3] :*0) :+ item_fix_init_indicator[.,1]
						model_curr_asked = *starting_values_guess_results[2]
						guesslist = select(itemlist,(model_curr_asked[.,1]:=="2plm"):*(model_curr_asked[.,2]:=="3plm"))
						I_guess = rows(guesslist)
						guessing_attempts_count++
					}
				}
								
			}
			else{
				if(delta_ll<0){
					display_logLdecrese=1
				}
			}		
		}

		if((iter>N_iter)& (( (max(abs(delta))>crit_par) | (max(abs(delta_DIST))>crit_par) ) & delta_ll>crit_ll)){
			if_em_converged=0
		}

		if(display_logLdecrese){
			display("Warning: logL started to decrease, this should not happen in EM algorithm, try increasing nip() or use noupd_quad_betw_em if multigroup")
			if_em_converged=0
		}
		

		
		if(if_em_converged==0){
			display("Warning: the EM algorithm did not reach convergence criteria")
		}
			
		if(errors=="sem"){
			if(nonmissing(long_EMhistory_matrix)){
				long_EMhistory_matrix=select(long_EMhistory_matrix',rownonmissing(long_EMhistory_matrix'):>0)'
			}
		}


// recalculate ll, obtain theta and theta_se estimates if requested			
		ll_theta_se = return_ll_theta_se( add_theta,theta_nip, item_n_cat, item_group_totalobs, model_curr_asked, group_uniq_total_obs, X_k , A_k, parameters, DIST, point_Uigc, point_Fg)
		
		if(add_theta==1){
			if(theta_name!="."){
				index_temp=st_addvar("double",("theta_"+theta_name,"se_theta_"+theta_name))
				st_store(Theta_id,index_temp,(*ll_theta_se[2],*ll_theta_se[3])[Theta_dup,.])
				display("Added variables: theta_"+theta_name+", se_theta_"+theta_name)
			}
			else{
				index_temp=st_addvar("double",("theta","se_theta"))
				st_store(Theta_id,index_temp,(*ll_theta_se[2],*ll_theta_se[3])[Theta_dup,.])
				display("Added variables: theta, se_theta")
			}
		}
				
		results = J(8,1,NULL)
		results[1] = &DIST
		results[2] = &parameters
		results[3] = &(*ll_theta_se[1])
		results[4] = &X_k
		results[5] = &long_EMhistory_matrix
		results[6] = &model_curr_asked
		results[7] = &Cns_parameters
		results[8] = &if_em_converged
		return(results)
		
	}

										
	pointer colvector em_step(real matrix Cns_parameters, real matrix Cns_DIST, string colvector itemlist, real colvector item_n_cat,real matrix item_fix_init_indicator, real matrix item_group_totalobs,string matrix model_curr_asked, real matrix group_uniq_total_obs, real matrix parameters, real matrix X_k , real matrix A_k, pointer matrix point_Uigc, pointer matrix point_Fg                 ,                real matrix DIST, real scalar upd_quad_betw_em, real scalar N_iter_NRF, real scalar crit_par){
		
	
		e_step_results	= e_step(Cns_parameters, Cns_DIST,itemlist,item_n_cat,item_group_totalobs,model_curr_asked, group_uniq_total_obs,parameters,X_k ,A_k,point_Uigc,point_Fg)
		
		logL			= *e_step_results[1]
		A_k_estimated	= *e_step_results[2]
		p_ik			= *e_step_results[3]
		p_ck			= *e_step_results[4]
		f_ik			= *e_step_results[5]
		
		N_gr=cols(A_k)
		K=rows(A_k)
		
		X_k_upd_quad = X_k
		for(g=1;g<=N_gr;g++){				
			if(Cns_DIST[1,g]==0){
				X_mean_g 		= sum(X_k[.,g] :* A_k_estimated[.,g])
			}
			else{
				X_mean_g 		= DIST[1,g]
			}
			
			if(Cns_DIST[2,g]==0){
				X_sd_g 			= ((sum(X_k[.,g] :* X_k[.,g] :* A_k_estimated[.,g]) - sum(X_k[.,g] :* A_k_estimated[.,g])^2)^0.5)
			}
			else{
				X_sd_g			= DIST[2,g]
			}
			
			X_k_upd_quad[.,g] 	=((X_k[.,g] - J(K,1,DIST[1,g]))/DIST[2,g])*X_sd_g+J(K,1,X_mean_g)
			
			DIST[1,g] 			= X_mean_g
			DIST[2,g] 			= X_sd_g
		}
					
		if(upd_quad_betw_em==1 & sum(model_curr_asked[.,2]:=="pcm")==0){
			X_k = X_k_upd_quad
		}

		
		delta_NRF=m_step(X_k,model_curr_asked,item_fix_init_indicator,parameters,f_ik,p_ik,p_ck,0)
		delta=delta_NRF
		for(iter_NRF=2;iter_NRF<=N_iter_NRF;iter_NRF++){
// just to make sure - divide precission by 10 for one iteration
			if((max(abs(delta_NRF))>crit_par/10)){
				delta_NRF=m_step(X_k,model_curr_asked,item_fix_init_indicator,parameters+delta,f_ik,p_ik,p_ck,0)
				delta=delta+delta_NRF
			}
		}
		
// arbitrary but works most of the time	
		for(i=1;i<=rows(delta);i++){
			if(max(abs(delta[i,.]))>5){
				delta[i,.]=delta[i,.]*0
			}
		}
			
		parameters=parameters+delta

		X_k = X_k_upd_quad
		
		results = J(8,1,NULL)
		results[1] = &DIST
		results[2] = &parameters
		results[3] = &logL
		results[4] = &X_k
		results[5] = &delta
		results[6] = &f_ik
		results[7] = &p_ik
		results[8] = &p_ck
		return(results)
				
	}


	pointer colvector e_step(real matrix Cns_parameters, real matrix Cns_DIST, string colvector itemlist, real colvector item_n_cat, real matrix item_group_totalobs,string matrix model_curr_asked, real matrix group_uniq_total_obs, real matrix parameters, real matrix X_k , real matrix A_k, pointer matrix point_Uigc, pointer matrix point_Fg){
	
		I=rows(itemlist)
		I_c = sum(select(item_n_cat,item_n_cat:>2))
		K=rows(A_k)
		N_gr=cols(A_k)
		
		A_k_estimated = J(K,N_gr,.) 
		f_ik = J(I,0,.)
		p_ik = J(I,0,.)
		p_ck = J(I_c,0,.)
		logL = J(N_gr,1,0)
		
		for(g=1;g<=N_gr;g++){
			
			itemselectrange_g = select((1::I),item_group_totalobs[.,g]:>0)
			Fg = *point_Fg[g]
			
			itemlist_g			= itemlist[itemselectrange_g]
			parameters_g		= parameters[itemselectrange_g,.]
			item_n_cat_g		= item_n_cat[itemselectrange_g]
			model_curr_asked_g	= model_curr_asked[itemselectrange_g,.]
			I_g = rows(itemlist_g)
			I_c_g =sum(select(item_n_cat_g,item_n_cat_g:>2))
			
			PXk_Uj = eE_step(X_k[.,g],A_k[.,g],point_Uigc[.,g],parameters_g,item_n_cat_g, model_curr_asked_g, group_uniq_total_obs[g,1])
			logL[g] = sum( Fg :* ln(rowsum(PXk_Uj)) )
			PXk_Uj = PXk_Uj :/ rowsum(PXk_Uj)
			
			f_ik_g = J(I_g,K,0)
			p_ik_g = J(I_g,K,0)
			p_ck_g = J(I_c_g,K,0)
			for(i=1;i<=I_g;i++){
				n_cat = item_n_cat_g[i]
				cat_freqs = J(n_cat,K,.)
				for(c=1;c<=n_cat;c++){
					ord_ic = *(*point_Uigc[i,g])[c]
					if(rows(ord_ic)){ // in case of fixing and missing
						cat_freqs[c,.] = colsum( Fg[ord_ic] :* PXk_Uj[ord_ic,.] )
					}
					f_ik_g[i,.]=f_ik_g[i,.]+cat_freqs[c,.]
				}
				if(n_cat==2){
					p_ik_g[i,.] = cat_freqs[2,.] :/ f_ik_g[i,.]
				}
				else{
					row_p_ck_g = sum(select(item_n_cat_g[1::i],item_n_cat_g[1::i]:>2))-n_cat+1
					for(c=1;c<=n_cat;c++){
						p_ck_g[row_p_ck_g,.] = cat_freqs[c,.]:/ f_ik_g[i,.]
						row_p_ck_g++
					}
				}
			}					
			temp=J(I,K,0)
			temp[itemselectrange_g,.]=f_ik_g
			f_ik=f_ik,temp
			temp = J(I,K,0)
			temp[itemselectrange_g,.]=p_ik_g
			p_ik=p_ik,temp	
			temp = J(I_c,K,.)
			if(I_c_g){
				okrange=J(0,1,.)
				range_start=1
				for(i=1;i<=I;i++){
					if(item_n_cat[i]>2){
						range_stop=range_start+item_n_cat[i]-1
						if(item_group_totalobs[i,g]){
							okrange=okrange\(range_start::range_stop)
						}
						range_start=range_stop+1
					}
				}
			temp[okrange,.]=p_ck_g
			}
			p_ck=p_ck,temp
			
			if(g>1-sum(Cns_DIST[.,1]:==0)){
				A_k_estimated[.,g] =(colsum(Fg :* PXk_Uj)/group_uniq_total_obs[g,2])'
			}
					
		}
		
		results = J(5,1,NULL)
		results[1] = &logL
		results[2] = &A_k_estimated
		results[3] = &p_ik
		results[4] = &p_ck
		results[5] = &f_ik
		return(results)
		
	}


	pointer colvector return_ll_theta_se(real scalar add_theta,real scalar theta_nip, real colvector item_n_cat, real matrix item_group_totalobs ,string matrix model_curr_asked,  real matrix group_uniq_total_obs, real matrix X_k , real matrix A_k, real matrix parameters , real matrix DIST , pointer matrix point_Uigc, pointer matrix point_Fg){
	
		N_gr=cols(A_k)
		K=rows(A_k)	
		I=rows(parameters)
		logL = J(N_gr,1,0)
		
		if(add_theta==1){
			theta_rangestart = 1
			theta = J(sum(group_uniq_total_obs[.,1]),1,.)
			se = theta
		}
		else{
			theta = J(0,0,.)
			se = J(0,0,.)
		}
		
		for(g=1;g<=N_gr;g++){
			
			itemselectrange_g 	= select((1::I),item_group_totalobs[.,g]:>0)
			parameters_g 		= parameters[itemselectrange_g,.]
			item_n_cat_g 		= item_n_cat[itemselectrange_g]
			model_curr_asked_g	= model_curr_asked[itemselectrange_g,.]
			
			PXk_Uj = eE_step(X_k[.,g],A_k[.,g],point_Uigc[.,g],parameters_g,item_n_cat_g, model_curr_asked_g,group_uniq_total_obs[g,1])
			logL[g] = sum( (*point_Fg[g]) :* ln(rowsum(PXk_Uj)) )			
			
			if(add_theta==1){
				
				theta_rangestop=theta_rangestart+group_uniq_total_obs[g,1]-1
				
				if(theta_nip!=K){
					X_k_A_k=gauss_hermite(theta_nip)
					X_k_theta = X_k_A_k[.,1]:*DIST[2,g]:+DIST[1,g]
					A_k_theta = X_k_A_k[.,2]
					PXk_Uj = eE_step(X_k_theta,A_k_theta,point_Uigc[.,g],parameters_g,item_n_cat_g,model_curr_asked_g,group_uniq_total_obs[g,1])
					PXk_Uj = PXk_Uj :/ rowsum(PXk_Uj)
				}
				else{
					X_k_theta = X_k[.,g]
					PXk_Uj = PXk_Uj :/ rowsum(PXk_Uj)
				}
				
				
				theta[theta_rangestart::theta_rangestop]	= rowsum(PXk_Uj :* X_k_theta')
				se[theta_rangestart::theta_rangestop]		= sqrt(rowsum(PXk_Uj :* (X_k_theta' :* X_k_theta')) :- (theta[theta_rangestart::theta_rangestop] :* theta[theta_rangestart::theta_rangestop]))
				
				theta_rangestart=theta_rangestop+1
				
			}
		}
		
		results = J(3,1,NULL)
		results[1] = &logL
		results[2] = &theta
		results[3] = &se

		return(results)
		
	}		
	

	void save_iteration_matrices(string matrix itemlist, real matrix parameters, string scalar savingname, real matrix DIST, real matrix group_vals){
		
		unlink("_inms_"+savingname+".matrix")
		inmsf = fopen("_inms_"+savingname+".matrix", "w")
			fputmatrix(inmsf,itemlist)
		fclose(inmsf)

		unlink("_iprs_"+savingname+".matrix")				
		iprsf = fopen("_iprs_"+savingname+".matrix", "w")
			fputmatrix(iprsf,parameters)
		fclose(iprsf)
		
		unlink("_dprs_"+savingname+".matrix")				
		dprsf = fopen("_dprs_"+savingname+".matrix", "w")
			fputmatrix(dprsf,DIST)
		fclose(dprsf)
			
		unlink("_gvls_"+savingname+".matrix")				
		gvlsf = fopen("_gvls_"+savingname+".matrix", "w")
			fputmatrix(gvlsf,group_vals)
		fclose(gvlsf)
	
	}
	

	real matrix eE_step(real matrix X_k,real matrix A_k, pointer matrix point_Uxgx, real matrix parameters, real colvector item_n_cat,string matrix model_curr_asked, real scalar Obs_g){
		I=rows(parameters)
		K=rows(X_k)
		
		LXk_Uj=J(Obs_g,K,1)
		for(i=1;i<=I;i++){
			n_cat	= item_n_cat[i]
			model	= model_curr_asked[i,.]
			if(n_cat==2  & model[1]!="pcm"){
				PiXk_0c=(1 :- f_PiXk_01(parameters[i,.],model,X_k)) \ f_PiXk_01(parameters[i,.],model,X_k)
			}
			else{
				PiXk_0c=f_PiXk_0c(parameters[i,.],model,X_k)
			}
	
			for(c=1;c<=n_cat;c++){
				ord_ic = *(*point_Uxgx[i])[c]
				if(rows(ord_ic)){ // in case of fixing and missing
					LXk_Uj[ord_ic,.] = LXk_Uj[ord_ic,.] :* PiXk_0c[c,.]
				}
			}
		}
	
		PXk_Uj=A_k' :* LXk_Uj

		return(PXk_Uj)
	}
	
		
	real matrix m_step(real matrix X_k,string matrix model, real matrix item_fix_init_indicator, real matrix parameters,real matrix f_ik,real matrix p_ik,real matrix p_ck,real scalar delta_fisher_score){
		
		I=rows(parameters)
		K=rows(X_k)
		N_gr=cols(X_k)
		item_n_cat=strtoreal(model[.,3])
		
		PiXk=J(I,0,.)
		for(g=1;g<=N_gr;g++){
			PiXk_g=f_PiXk_01(parameters,model,X_k[.,g])
			PiXk=PiXk,PiXk_g
		}
		
		delta=J(I,32,.)
		
		for(i=1;i<=I;i++){
			n_cat = item_n_cat[i]

			if(item_fix_init_indicator[i,1]==0){
				
				if(model[i,1]=="2plm"){
					
					a = parameters[i,1]
					b = parameters[i,2]
					
					Fxp_P = f_ik[i,.] :* (p_ik[i,.]-PiXk[i,.])
					X_b=J(1,0,.)
					for(g=1;g<=N_gr;g++){
						X_b =X_b , (X_k[.,g]'-J(1,K,b))
					}
					FxPxQ = f_ik[i,.] :* (PiXk[i,.] :* (J(1,N_gr*K,1)-PiXk[i,.]))
					
					
					L1_gk		= (Fxp_P :* X_b)
					L2_gk		= -a :* (Fxp_P)
					Score_gk	= (L1_gk \ L2_gk)
					Score 		= rowsum(Score_gk)
					
					L11 		= -sum(FxPxQ :* (X_b :* X_b))
					L22 		= -a^2*sum(FxPxQ)
					L12 		= a*sum(FxPxQ :* X_b)
					Fisher 		= -1*(L11,L12\L12,L22)
					
					if(delta_fisher_score==0){
						delta[i,(1,2)] = (invsym(Fisher)*Score)'
					}						
					if(delta_fisher_score==1){
						return(Fisher)
					}
					if(delta_fisher_score==2){
						return(Score_gk)
					}
					
				}
					
				if(model[i,1]=="3plm"){
	
					a = parameters[i,1]
					b = parameters[i,2]
					c = parameters[i,3]
					
					V = (PiXk[i,.]-J(1,N_gr*K,c)) :/ (PiXk[i,.] :* J(1,N_gr*K,1-c))
					VV = V :* V
					
					Fxp_P = f_ik[i,.] :* (p_ik[i,.]-PiXk[i,.])
					X_b=J(1,0,.)
					for(g=1;g<=N_gr;g++){
						X_b =X_b , (X_k[.,g]'-J(1,K,b))
					}
					FxPxQ = f_ik[i,.] :* (PiXk[i,.] :* (J(1,N_gr*K,1)-PiXk[i,.]))
					FxQ=(f_ik[i,.] :* (J(1,N_gr*K,1)-PiXk[i,.])) 
					
					L1_gk		= (Fxp_P :* X_b :* V)
					L2_gk		= -a :* (Fxp_P :* V)
					L3_gk		= (1/(1-c)) :* (Fxp_P :/ PiXk[i,.])
					Score_gk	= (L1_gk \ L2_gk \ L3_gk)
					Score 		= rowsum(Score_gk)
					
					L11 = -sum(FxPxQ :* (X_b :* X_b) :* VV)
					L22 = -a^2*sum(FxPxQ :* VV)
					L33 = -(1/(1-c))^2*sum(FxQ :/ PiXk[i,.])
					L12 = a*sum(FxPxQ :* X_b :* VV)
					L13 = -(1/(1-c))*sum(FxQ :* X_b :* V)
					L23 = (a/(1-c))*sum(FxQ :* V)

					
					Fisher = -1*(L11,L12,L13\L12,L22,L23\L13,L23,L33)

					if(delta_fisher_score==0){
						delta[i,(1..3)] = (invsym(Fisher)*Score)'
					}												
					if(delta_fisher_score==1){
						return(Fisher)
					}
					if(delta_fisher_score==2){
						return(Score_gk)
					}
		
				}
				
				if(model[i,1]=="grm"){
					
		// 	PiXk_0c[1,.] -->cat=0
		// 	PiXk_0c[n_cat,.] -->cat=n_cat-1
					PiXk_0c=J(n_cat,0,.)
					for(g=1;g<=N_gr;g++){
						PiXk_0c_g=f_PiXk_0c(parameters[i,.],model[i,.],X_k[.,g])
						PiXk_0c=PiXk_0c,PiXk_0c_g
					}
					
		// 	pi_ck[1,.] -->cat=0
		// 	pi_ck[n_cat,.] -->cat=n_cat-1	
					row_p_ck = sum(select(item_n_cat[1::i],item_n_cat[1::i]:>2))-n_cat+1		
					pi_ck=p_ck[(row_p_ck::row_p_ck+n_cat-1),.]
	
		// 	PiXk_0c_star[1,.] -->cat>-1, i.e. dummy constant=1 function
		// 	PiXk_0c_star[2,.] -->cat>0, 
		// 	PiXk_0c_star[n_cat,.] -->cat>n_cat-2,
		// 	PiXk_0c_star[n_cat+1,.] -->cat>n_cat-1, i.e. dummy constant=0 function
					PiXk_0c_star=J(n_cat+1,N_gr*K,.)
					PiXk_0c_star[1,.]=J(1,N_gr*K,1)
					PiXk_0c_star[n_cat+1,.]=J(1,N_gr*K,0)
					grm_parameters=J(n_cat-1,1,parameters[i,1]),parameters[i,(4..4+n_cat-2)]',J(n_cat-1,cols(parameters)-4,.),J(n_cat-1,1,1)
					dummy_2plm_model=J(n_cat-1,1,("2plm","2plm","2"))
					for(g=1;g<=N_gr;g++){
						PiXk_0c_star[(2::n_cat),((g-1)*K+1..g*K)]=f_PiXk_01(grm_parameters,dummy_2plm_model,X_k[.,g])
					}
							
					P_starxQ_star=PiXk_0c_star :* (1 :- PiXk_0c_star)
	
		// 	X_b_star[1,.] --> dummy 0, because always multiplied by 0
		// 	X_b_star[2,.] --> X_x - b of P(cat>0) 
		// 	X_b_star[n_cat,.] --> X_x - b of P(cat>n_cat-2)
		// 	X_b_star[n_cat+1,.] --> dummy 0, because always multiplied by 0
					X_b_star=J(n_cat+1,N_gr*K,.)
					X_b_star[1,.]=J(1,N_gr*K,0)
					X_b_star[n_cat+1,.]=J(1,N_gr*K,0)
					for(g=1;g<=N_gr;g++){
						X_b_star[(2::n_cat),((g-1)*K+1..g*K)] =(J(n_cat-1,1,X_k[.,g]') :- grm_parameters[.,2])
					}
					
					X_b_starxP_starxQ_star = X_b_star :* P_starxQ_star
	
					a=parameters[i,1]
					
					Score_gk	= J(n_cat,N_gr*K,.)					
					Score		= J(n_cat,1,.)
					Fisher 		= J(n_cat,n_cat,0)
					
		// summation over categories cat\in{0...n_cat-2}
					for(c=1;c<=n_cat-1;c++){
						Score_gk[c,.] 		= a :* (f_ik[i,.] :* P_starxQ_star[c+1,.] :* ((pi_ck[c,.]:/PiXk_0c[c,.])-(pi_ck[c+1,.]:/PiXk_0c[c+1,.])))
					}
					Score_gk[n_cat,.]		= ( f_ik[i,.] :* colsum( (pi_ck[(1::n_cat),.] :/ PiXk_0c[(1::n_cat),.]) :* (X_b_starxP_starxQ_star[(1::n_cat),.] - X_b_starxP_starxQ_star[(2::n_cat+1),.]) ) )

					Score 					= rowsum(Score_gk)
					
											
					for(c=1;c<=n_cat-1;c++){
						Fisher[c,c] = -a^2 * sum(f_ik[i,.] :* P_starxQ_star[c+1,.] :* P_starxQ_star[c+1,.] :* ((1 :/ PiXk_0c[c,.])+(1 :/ PiXk_0c[c+1,.])))
						if(c<n_cat-1){
							Fisher[c,c+1] = a^2 * sum(f_ik[i,.] :* P_starxQ_star[c+1,.] :* P_starxQ_star[c+2,.] :* (1 :/ PiXk_0c[c+1,.]))
							Fisher[c+1,c] = Fisher[c,c+1]
						}
					}
					for(c=1;c<=n_cat-1;c++){
						Fisher[c,n_cat] = -a * sum(f_ik[i,.] :* P_starxQ_star[c+1,.] :* (( (X_b_starxP_starxQ_star[c,.] - X_b_starxP_starxQ_star[c+1,.]) :/ PiXk_0c[c,.])-( (X_b_starxP_starxQ_star[c+1,.] - X_b_starxP_starxQ_star[c+2,.]) :/ PiXk_0c[c+1,.])))
						Fisher[n_cat,c] = Fisher[c,n_cat]
					}
					Fisher[n_cat,n_cat] = - sum( f_ik[i,.] :* colsum( ((X_b_starxP_starxQ_star[(1::n_cat),.] - X_b_starxP_starxQ_star[(2::n_cat+1),.]) :* (X_b_starxP_starxQ_star[(1::n_cat),.] - X_b_starxP_starxQ_star[(2::n_cat+1),.])) :/ PiXk_0c[(1::n_cat),.] ) )
	
					
					Fisher = -1*Fisher

					if(delta_fisher_score==0){
						delta_temp = (invsym(Fisher)*Score)'
						delta[i,1] = delta_temp[n_cat]
						delta[i,(4..4+n_cat-2)] = delta_temp[1.. n_cat-1]
					}										
					if(delta_fisher_score==1){
						Fishertemp=Fisher[.,n_cat],Fisher[.,1..n_cat-1]
						Fisher=Fishertemp[n_cat,.]\Fishertemp[1::n_cat-1,.]
						return(Fisher)
					}
					if(delta_fisher_score==2){
						Score_gk=Score_gk[n_cat,.]\Score_gk[1::n_cat-1,.]
						return(Score_gk)
					}

					
				}
				
				//GPCM
				if(model[i,1]=="gpcm" | model[i,1]=="pcm"){
						
					PiXk_0c=J(n_cat,0,.)
					for(g=1;g<=N_gr;g++){
						PiXk_0c_g=f_PiXk_0c(parameters[i,.],model[i,.],X_k[.,g])
						PiXk_0c=PiXk_0c,PiXk_0c_g
					}
							
					if(n_cat>2){		
						row_p_ck = sum(select(item_n_cat[1::i],item_n_cat[1::i]:>2))-n_cat+1		
						pi_ck=p_ck[(row_p_ck::row_p_ck+n_cat-1),.]
					}
					else{
						pi_ck=(1:-p_ik[i,.])\p_ik[i,.]
					}
					
					a=parameters[i,1]		
					b_1tomax=parameters[i,4..4+n_cat-2]		
					
					Zc_1toc=J(n_cat-1,cols(pi_ck),.)
					for(c=1;c<=n_cat-1;c++){
						for(g=1;g<=N_gr;g++){
							Zc_1toc[c,((g-1)*K+1..g*K)] = a :* ( c :* X_k[.,g]' :- sum(b_1tomax[1..c]) )
						}
					}
				
					Sum_Pc_ctomax=J(n_cat-1,cols(pi_ck),0)
					for(c=1;c<=n_cat-1;c++){
						for(cc=c+1;cc<=n_cat;cc++){
							Sum_Pc_ctomax[c,.]=Sum_Pc_ctomax[c,.] :+ PiXk_0c[cc,.]
						}
					}
					
					Sum_PcZc_1tomax=J(1,cols(pi_ck),0)
					for(c=1;c<=n_cat-1;c++){
						Sum_PcZc_1tomax=Sum_PcZc_1tomax :+ (PiXk_0c[c+1,.] :* Zc_1toc[c,.])
					}
					
					fik			= 			f_ik[i,.]
					afik		= a 	:*	fik
					asqfik		= a^2 	:* 	fik
					ainvfik		= 1/a 	:*	fik
					ainvsqfik	= 1/a^2 :*	fik
					
					Score_gk					= J(n_cat,N_gr*K,0)
					for(c=1;c<=n_cat-1;c++){
						for(cat=1;cat<=c;cat++){
							Score_gk[c,.]		= Score_gk[c,.] :+ (pi_ck[cat,.] :* Sum_Pc_ctomax[c,.] )
						}
						for(cat=c+1;cat<=n_cat;cat++){
							Score_gk[c,.]		= Score_gk[c,.] :- (pi_ck[cat,.] :* ( 1 :- Sum_Pc_ctomax[c,.] ) )
						}
						Score_gk[c,.]			= afik :* Score_gk[c,.]
					}
					Score_gk[n_cat,.]			= Score_gk[n_cat,.] :- (pi_ck[1,.] :* Sum_PcZc_1tomax )
					for(cat=2;cat<=n_cat;cat++){
						Score_gk[n_cat,.]		= Score_gk[n_cat,.] :+ (pi_ck[cat,.] :* (Zc_1toc[cat-1,.] :- Sum_PcZc_1tomax) )
					}
					Score_gk[n_cat,.]			= ainvfik :* Score_gk[n_cat,.]
					Score 						= rowsum(Score_gk)	
				
					Fisher 						= J(n_cat,n_cat,0)
					for(c=1;c<=n_cat-1;c++){
						for(cc=c;cc<=n_cat-1;cc++){
							Fisher_ccc			= J(1,N_gr*K,0)
							for(cat=1;cat<=n_cat;cat++){
								Fisher_ccc		= Fisher_ccc :+ (pi_ck[cat,.] :* ( (Sum_Pc_ctomax[c,.] :* Sum_Pc_ctomax[cc,.]) :- Sum_Pc_ctomax[max((c,cc)),.]))
							}
							Fisher_ccc			= sum(asqfik :* Fisher_ccc)
							Fisher[c,cc]		= Fisher_ccc
							Fisher[cc,c]		= Fisher_ccc
						}
					}
					derb_dera_wrr_ctomax=J(n_cat-1,cols(pi_ck),0)
					for(c=1;c<=n_cat-1;c++){
						for(cc=c;cc<=n_cat-1;cc++){
							derb_dera_wrr_ctomax[c,.]=derb_dera_wrr_ctomax[c,.] :+ (PiXk_0c[cc+1,.] :* (Zc_1toc[cc,.] :- Sum_PcZc_1tomax) )
						}
					}
					for(c=1;c<=n_cat-1;c++){
						Fisher_cncat			= J(1,N_gr*K,0)
						for(cat=1;cat<=n_cat;cat++){
							Fisher_cncat		= Fisher_cncat :+ (pi_ck[cat,.] :* derb_dera_wrr_ctomax[c,.])
						}
						Fisher_cncat			= sum(fik :* Fisher_cncat)
						Fisher[c,n_cat]			= Fisher_cncat
						Fisher[n_cat,c]			= Fisher_cncat					
					}
					dera_dera_wrr_ctomax=J(1,cols(pi_ck),0)
					for(c=1;c<=n_cat-1;c++){
						dera_dera_wrr_ctomax=dera_dera_wrr_ctomax :+ (PiXk_0c[c+1,.] :* Zc_1toc[c,.] :* (Sum_PcZc_1tomax :- Zc_1toc[c,.] ) )
					}
					Fisher_ncatncat				= J(1,N_gr*K,0)
					for(cat=1;cat<=n_cat;cat++){
						Fisher_ncatncat			= Fisher_ncatncat :+ (pi_ck[cat,.] :* dera_dera_wrr_ctomax)
					}
					Fisher[n_cat,n_cat]			= sum(ainvsqfik :* Fisher_ncatncat)	
					
								
					Fisher = -1*Fisher
	
					
					if(model[i,1]=="pcm"){
						Score[n_cat]=0
						Fisher[n_cat,.]=J(1,n_cat,0)
						Fisher[.,n_cat]=J(n_cat,1,0)
					}
					
					if(delta_fisher_score==0){
						delta_temp = (invsym(Fisher)*Score)'
						delta[i,1] = delta_temp[n_cat]
						delta[i,(4..4+n_cat-2)] = delta_temp[1.. n_cat-1]
					}										
					if(delta_fisher_score==1){
						Fishertemp=Fisher[.,n_cat],Fisher[.,1..n_cat-1]
						Fisher=Fishertemp[n_cat,.]\Fishertemp[1::n_cat-1,.]
						return(Fisher)
					}
					if(delta_fisher_score==2){
						Score_gk=Score_gk[n_cat,.]\Score_gk[1::n_cat-1,.]
						return(Score_gk)
					}
	
				}
			
			}
			else{
				if(delta_fisher_score==1){
					//return(Fisher)
					return(J(nonmissing(parameters[i,.]),nonmissing(parameters[i,.]),0))
				}
				if(delta_fisher_score==2){
					//return(Score_gk)
					return(J(nonmissing(parameters[i,.]),N_gr*K,0))
				}
				delta[i,.] = parameters[i,.]*0
			}
				
		}
		
		if(delta_fisher_score==0){
			return(delta)
		}
	}	
	
	
	function f_PiXk_01(real matrix parameters,string matrix model, real matrix X_k){
		K=rows(X_k)
		I=rows(parameters)		

		PiXk=J(I,K,.)
		for(i=1;i<=I;i++){
			if(model[i,3]=="2"){
				if(model[i,1]=="3plm"){
					PiXk[i,.]=invlogit(parameters[i,1]:*(X_k':-parameters[i,2])):*(1-parameters[i,3]):+parameters[i,3]
				}
				else{
					PiXk[i,.]=invlogit(parameters[i,1]*(X_k':-parameters[i,2]))
				}
			}
		}
		return(PiXk)	
	}

	
	function f_Pitem_theta_01(real matrix parameters,string matrix model, real matrix theta){
		K=rows(theta)
		Pitem_theta=J(K,1,.)
		if(model[3]=="2"){
			if(model[1]=="3plm"){
				Pitem_theta=invlogit(parameters[1]:*(theta:-parameters[2])):*(1-parameters[3]):+parameters[3]
			}
			else{
				Pitem_theta=invlogit(parameters[1]*(theta:-parameters[2]))
			}
		}
		return(Pitem_theta)	
	}
	
			
	function f_PiXk_0c(real matrix parameters,string matrix model, real matrix X_k){
		K		= rows(X_k)
		n_cat	= strtoreal(model[3])
		PiXk	= J(n_cat,K,.)
		
		if(model[1]=="grm"){	
			PiXk[1,.] 	= 1 :- invlogit(parameters[1] :* (X_k' :- parameters[4]))
			PiXk[n_cat,.] = invlogit(parameters[1] :* (X_k' :- parameters[2+n_cat]))
			for(c=2;c<=n_cat-1;c++){
				PiXk[c,.] = invlogit(parameters[1] :* (X_k' :- parameters[2+c]))  :- invlogit(parameters[1] :* (X_k' :- parameters[3+c]))
			}
		}
		
		if(model[1]=="gpcm" | model[1]=="pcm"){
			expsum_all = 1
			for(c=2;c<=n_cat;c++){
				expsum_all = expsum_all :+ exp( parameters[1] :* ( (c-1) :* X_k' :- sum(parameters[4..2+c]) ) )
			}
			PiXk[1,.]	= 1 :/ expsum_all
			for(c=2;c<=n_cat;c++){
				PiXk[c,.] = exp( parameters[1] :* ( (c-1) :* X_k' :- sum(parameters[4..2+c]) ) ) :/ expsum_all
			}	
		}
		
		return(PiXk)	
	}


	function f_Pitem_theta_0c(real matrix parameters,string matrix model, real matrix theta){
		K		= rows(theta)
		n_cat	= strtoreal(model[3])	
		Pitem_theta=J(K,n_cat,.)
		
		if(model[1]=="grm"){
			Pitem_theta[.,1] = 1 :- invlogit(parameters[1] :* (theta :- parameters[4]))
			Pitem_theta[.,n_cat] = invlogit(parameters[1] :* (theta :- parameters[2+n_cat]))	
			for(c=2;c<=n_cat-1;c++){
				Pitem_theta[.,c] = invlogit(parameters[1] :* (theta :- parameters[2+c]))  :- invlogit(parameters[1] :* (theta :- parameters[3+c]))
			}
		}
		
		if(model[1]=="gpcm" | model[1]=="pcm"){
			expsum_all = 1
			for(c=2;c<=n_cat;c++){
				expsum_all = expsum_all :+ exp( parameters[1] :* ( (c-1) :* theta :- sum(parameters[4..2+c]) ) )
			}
			Pitem_theta[.,1]	= 1 :/ expsum_all
			for(c=2;c<=n_cat;c++){
				Pitem_theta[.,c] = exp( parameters[1] :* ( (c-1) :* theta :- sum(parameters[4..2+c]) ) ) :/ expsum_all
			}	
		}
		
		return(Pitem_theta)	
	}


void store_matrices(string matrix model_curr_asked, string scalar temporary_suffix, string matrix itemlist, real matrix parameters, real matrix DIST, real matrix parameters_err, real matrix DIST_err, real matrix logL, real matrix group_vals, real matrix item_group_totalobs, real matrix item_n_cat, pointer matrix point_item_cats, real matrix group_uniq_total_obs){
		
		I=rows(itemlist)
		N_gr=cols(DIST)
		N_item_parameters=sum(colsum(parameters:!=. ) :> 0)
		max_cat=max(strtoreal(model_curr_asked[.,3]))-1
		

		item_parameter_labels=J(N_item_parameters,1,"")
		item_parameters=J(I,N_item_parameters,.)
		item_parameters_err=J(I,N_item_parameters,.)
		
		count_par=1
		item_parameter_labels[count_par]="a"
		item_parameters[.,count_par]=parameters[.,1]
		item_parameters_err[.,count_par]=parameters_err[.,1]
		if(nonmissing(parameters[.,2])){
			count_par++
			item_parameter_labels[count_par]="b"
			item_parameters[.,count_par]=parameters[.,2]
			item_parameters_err[.,count_par]=parameters_err[.,2]
		}
		if(nonmissing(parameters[.,3])){
			count_par++
			item_parameter_labels[count_par]="c"
			item_parameters[.,count_par]=parameters[.,3]
			item_parameters_err[.,count_par]=parameters_err[.,3]
		}
		if(max_cat>1 | sum(model_curr_asked[.,1]:=="pcm")){
			for(c=0;c<=max_cat-1;c++){
				count_par++
				item_parameter_labels[count_par]="b" + strofreal(c+1)
				item_parameters[.,count_par]=parameters[.,4+c]
				item_parameters_err[.,count_par]=parameters_err[.,4+c]
			}
		}
		item_parameter_labels_err="se_":+item_parameter_labels
		
		st_matrix("items"+temporary_suffix, item_parameters)
		st_matrixrowstripe("items"+temporary_suffix, (itemlist,model_curr_asked[.,1]))
		st_matrixcolstripe("items"+temporary_suffix, (J(N_item_parameters,1,""),item_parameter_labels))
				
		st_matrix("dist"+temporary_suffix, DIST)
		st_matrixrowstripe("dist"+temporary_suffix, (J(2,1,""),("mean"\"sd")))
		st_matrixcolstripe("dist"+temporary_suffix, (J(N_gr,1,""),("group" :+ "_":+strofreal(group_vals))))

		st_matrix("items_se"+temporary_suffix, item_parameters_err)
		st_matrixrowstripe("items_se"+temporary_suffix, (itemlist,model_curr_asked[.,1]))
		st_matrixcolstripe("items_se"+temporary_suffix, (J(N_item_parameters,1,""),item_parameter_labels_err))
				
		st_matrix("dist_se"+temporary_suffix, DIST_err)
		st_matrixrowstripe("dist_se"+temporary_suffix, (J(2,1,""),("se_mean"\"se_sd")))
		st_matrixcolstripe("dist_se"+temporary_suffix, (J(N_gr,1,""),("group" :+ "_":+strofreal(group_vals))))
		
		st_matrix("ll"+temporary_suffix, logL')
		st_matrixrowstripe("ll"+temporary_suffix, ("","logL"))
		st_matrixcolstripe("ll"+temporary_suffix, (J(N_gr,1,""),("group" :+ "_":+strofreal(group_vals))))
		
		st_matrix("item_group_N",item_group_totalobs)
		st_matrixrowstripe("item_group_N",(J(I,1,""),itemlist))
		st_matrixcolstripe("item_group_N",(J(N_gr,1,""),("group":+"_":+strofreal(group_vals))) )
		
		item_cats=J(I,max(item_n_cat),.)
		for(i=1;i<=I;i++){
			item_cats[i,1..rows(*point_item_cats[i])]=*point_item_cats[i]'
		}
		st_matrix("item_cats",item_cats)
		st_matrixrowstripe("item_cats",(J(I,1,""),itemlist))
		st_matrixcolstripe("item_cats",(J(cols(item_cats),1,""),("cat_":+strofreal((1::cols(item_cats))))) )
		
		group_N=group_uniq_total_obs[.,2]'
		st_matrix("group_N",group_N)
		st_matrixrowstripe("group_N",("","N"))
		st_matrixcolstripe("group_N",(J(N_gr,1,""),("group":+"_":+strofreal(group_vals))))

	}
	
			
	pointer colvector starting_values_logistic(string matrix itemlist,string matrix model_curr_asked, real matrix item_fix_init_indicator,  pointer matrix point_item_cats    ,   real colvector Theta_id, real colvector Theta_dup    ,   real colvector item_n_cat, real matrix item_group_totalobs, real matrix group_uniq_total_obs  ,    pointer matrix point_Uigc, pointer matrix point_Fg, string scalar X_var ){
		
		I = rows(itemlist)
		N_gr = cols(item_group_totalobs)
		
		if(strlen(X_var)==0){
			X_sum		= J(sum(group_uniq_total_obs[.,1]),1,0)
			X_max		= J(sum(group_uniq_total_obs[.,1]),1,0)
			X_rangestart	= 1		
			for(g=1;g<=N_gr;g++){
				X_rangestop=X_rangestart+group_uniq_total_obs[g,1]-1
				
				itemselectrange_g = select((1::I),item_group_totalobs[.,g]:>0)
				itemlist_g = itemlist[itemselectrange_g]
				item_n_cat_g = item_n_cat[itemselectrange_g]
				I_g = rows(itemlist_g)
				
				
				for(i=1;i<=I_g;i++){
					n_cat = item_n_cat_g[i]
					for(c=1;c<=n_cat;c++){
						category_range = (X_rangestart::X_rangestop)[*(*point_Uigc[i,g])[c]]
						X_max[category_range] = X_max[category_range] :+ (n_cat-1)
						if(c>1){
							X_sum[category_range] = X_sum[category_range] :+ (c-1)
						}
					}
				}
				
				X_rangestart=X_rangestop+1
			}
			
			X	= X_sum :/ X_max
			X	= X[Theta_dup]
			X	= (X:-mean(X)):/sqrt(variance(X))
			
			X_var=st_tempname()
			index_temp=st_addvar("double",X_var)
			st_store(Theta_id,index_temp,X)
			
			X_sum=J(0,0,.)
			X_max=J(0,0,.)		
			X=J(0,0,.)
		}
			
		remaining_itemlist 			= select(itemlist , rowsum(item_fix_init_indicator):==0)
		remaining_model_curr_asked	= select(model_curr_asked , rowsum(item_fix_init_indicator):==0)
		remaining_item_n_cat		= select(item_n_cat , rowsum(item_fix_init_indicator):==0)
		remaining_point_item_cats	= select(point_item_cats , rowsum(item_fix_init_indicator):==0)
		I_remaining=rows(remaining_itemlist)
		
		remaining_parameters = J(I_remaining,32,.)
		remaining_parameters_failed=J(I_remaining,1,0)
		
		
		for(i=1;i<=I_remaining;i++){
			
		// a remedy for DIF items which are not present in the dataset
			if(_st_varindex(remaining_itemlist[i])==.){
				remaining_itemlist[i]=substr(remaining_itemlist[i],1,strlen(remaining_itemlist[i])-3)
			}
			
			if(remaining_model_curr_asked[i,1]=="2plm" | remaining_model_curr_asked[i,1]=="grm"){
				stata("cap ologit " + remaining_itemlist[i] + " " + X_var)
				if(sum(st_matrix("e(V)"))){
					ologit_coefs = st_matrix("e(b)")
					if(ologit_coefs[1]>0){
						n_cat = cols(ologit_coefs)
						remaining_parameters[i,1] = ologit_coefs[1]
						if(n_cat==2){
							remaining_parameters[i,2] = ologit_coefs[2] / ologit_coefs[1]
						}
						else{
							remaining_parameters[i,4..2+n_cat] = ologit_coefs[2..n_cat] :/ ologit_coefs[1]
						}
					}
					else{
						remaining_parameters_failed[i] = 2
					}
				}
				else{
					remaining_parameters_failed[i] = 1
				}
			}
			if(remaining_model_curr_asked[i,1]=="gpcm" | remaining_model_curr_asked[i,1]=="pcm"){
				n_cat		= remaining_item_n_cat[i]
				item_cats	= *remaining_point_item_cats[i]
						
				constraints = ""
				if(remaining_model_curr_asked[i,1]=="pcm"){
					stata("constraint define 1000 ["+strofreal(item_cats[2])+"]" + X_var + "=1")
					constraints = constraints + "1000,"
				}
				if(n_cat>2){
					for(c=3;c<=n_cat;c++){
						stata("constraint define "+strofreal(1000+c)+" ["+strofreal(item_cats[2])+"]" + X_var + "=["+strofreal(item_cats[c])+"]" + X_var)
						constraints = constraints + strofreal(1000+c) + ","				
					}
				}
				
				stata("cap mlogit " + remaining_itemlist[i] + " " + X_var + ", baseoutcome("+strofreal(item_cats[1])+") constraints("+constraints+")")
				if(sum(st_matrix("e(V)"))){
					mlogit_coefs = st_matrix("e(b)")
					// remedy for problem whem working under lower versions of Stata
					shift=0
					if(rows(st_matrix("e(Cns)"))==0){
						shift=2
					}					
					if(mlogit_coefs[3-shift]>0){
						remaining_parameters[i,1] = mlogit_coefs[3-shift]
						for(c=2;c<=n_cat;c++){
							remaining_parameters[i,2+c]= - mlogit_coefs[2*c-shift]:/mlogit_coefs[3-shift]
						}
					}
					else{
						remaining_parameters_failed[i] = 2
					}
				}
				else{
					remaining_parameters_failed[i] = 1
				}
				if(strlen(constraints)){
					// mlogit adds two additional constraints
					stata("constraint drop "+constraints+"1998,1999")
				}
			}
	
			
		}
		
		stata("qui drop " + X_var)
		
		results = J(2,1,NULL)
		results[1] = &remaining_parameters
		results[2] = &remaining_parameters_failed
		return(results)
	}
	
	
	
	function grm_dummy(real matrix Ui , real scalar max_cat){
		Ui_dummy = J(rows(Ui),max_cat,.)
		for(c=1;c<=max_cat;c++){
			Ui_dummy[.,c] = (Ui :> (c-1))
		}
		return(Ui_dummy)
	}

	
	pointer colvector starting_values_guess(string matrix itemlist ,string matrix model_curr_asked, string matrix guesslist , real scalar guessing_lrcrit, real matrix item_group_totalobs, real matrix parameters, real matrix X_k, real matrix A_k, real matrix f_ik, real matrix p_ik, pointer matrix point_Uigc, pointer matrix point_Fg){

		I=rows(itemlist)
		N_gr=cols(X_k)
		
		item_n_cat = strtoreal(model_curr_asked[.,3])
		model_curr_asked_return=model_curr_asked
// when guessing_lrcrit==1 no LR testing is performed, only lack of convergence can suppress fitting the c parameter	
		if(guessing_lrcrit<1){
			logL_0 = J(N_gr,1,0)
			for(g=1;g<=N_gr;g++){			
				Fg = *point_Fg[g]
				itemselectrange_g 	= select((1::I),item_group_totalobs[.,g]:>0)
				parameters_g 		= parameters[itemselectrange_g,.]
				model_curr_asked_g	= model_curr_asked[itemselectrange_g,.]
				item_n_cat_g 		= item_n_cat[itemselectrange_g]

				PXk_Uj = eE_step(X_k[.,g],A_k[.,g],point_Uigc[.,g],parameters_g,item_n_cat_g,model_curr_asked_g,rows(Fg))
				logL_0[g] = sum( Fg :* ln(rowsum(PXk_Uj)) )
			}
			logL_0=sum(logL_0)
		}
		
// absolute difference in easiness based on 2plm and 3plm curve	criterion	
		means_difference_crit=0.01

		parameters_guess=parameters[.,1..3]
		dummy_2plm=("2plm","2plm","2")
		dummy_3plm=("3plm","3plm","2")
		dummy_fix_init=(0,0)
		failed_list=""		

		for(i=1;i<=I;i++){
			if(sum(guesslist :== itemlist[i])){
			
				mean_item_2plm = f_PiXk_01(parameters[i,.],dummy_2plm, X_k[.,1])* A_k[.,1]
				if_item_found = 0
				grid=20
				for(i_c=0 ; i_c<grid ; i_c++){
					if(if_item_found == 0){
						
	// first guess at abc parameter starting values, starting_c - variant, starting_b <- logit(a,b,starting_b)=starting_c+(1-starting_c)/2, starting_a- bisection
						starting_c = (i_c/grid)*mean_item_2plm
						starting_b = parameters[i,2] + logit(starting_c+(1-starting_c)/2)/parameters[i,1]
				
						delta_a_low = 0
						delta_a_up = 8
						delta_a_mean = (delta_a_up+delta_a_low)/2
						count_border = 0
						borders = (delta_a_low \ delta_a_up)
						p_mean=2
						for(i_bisect=1;i_bisect<=100;i_bisect++){
							if(abs(p_mean-mean_item_2plm)>10^-6){
								p_low = f_PiXk_01(((parameters[i,1]+delta_a_low,starting_b,starting_c),parameters[i,4..32]),dummy_3plm, X_k[.,1])* A_k[.,1]
								p_mean = f_PiXk_01(((parameters[i,1]+delta_a_mean,starting_b,starting_c),parameters[i,4..32]),dummy_3plm, X_k[.,1])* A_k[.,1]
								p_up = f_PiXk_01(((parameters[i,1]+delta_a_up,starting_b,starting_c),parameters[i,4..32]),dummy_3plm, X_k[.,1])* A_k[.,1]
								
								sort_three = abs((p_low\p_mean\p_up):-mean_item_2plm),(delta_a_low\delta_a_mean\delta_a_up)
								delta_a_low = sort(sort(sort_three,1)[1::2,.],2)[1,2]
								delta_a_up = sort(sort(sort_three,1)[1::2,.],2)[2,2]
								
								if( sum((borders:==delta_a_low) + (borders:==delta_a_low))){
									count_border++
								}
								else{
									count_border = 0
									borders = (delta_a_low \ delta_a_up)
								}
								
								if(count_border==20){
									if(borders[1]==delta_a_low){
										delta_a_up = delta_a_low
										delta_a_low = 0
									}
									if(borders[2]==delta_a_up){
										delta_a_low = delta_a_up
										delta_a_up = 8
									}
									count_border = 0
									borders = (delta_a_low \ delta_a_up)
								}
								
								delta_a_mean = (delta_a_up+delta_a_low)/2
							}
						}
						if(abs(p_mean-mean_item_2plm)>10^-6){
							starting_a=parameters[i,1]+delta_a_mean
						}
						else{
							starting_a=parameters[i,1]
						}
					
					parameters_guess[i,.] = (starting_a, starting_b, starting_c)
					dummy_parameters=parameters_guess[i,.],parameters[i,4..cols(parameters)]
					
	// reafining ab parameters for given starting_c by ML with ab fixed
						KK=rows(X_k)
						delta=J(1,32,.)
						delta[3]=0
						for(iter=1;iter<=100;iter++){
							PiXk=J(1,0,.)
							for(g=1;g<=N_gr;g++){
								PiXk_g=f_PiXk_01(dummy_parameters,dummy_3plm,X_k[.,g])
								PiXk=PiXk,PiXk_g
							}
													
							a = dummy_parameters[1]
							b = dummy_parameters[2]
							c = dummy_parameters[3]
					
							V = (PiXk-J(1,N_gr*KK,c)) :/ (PiXk :* J(1,N_gr*KK,1-c))
							VV = V :* V
					
							Fxp_P = f_ik[i,.] :* (p_ik[i,.]-PiXk)
							X_b=J(1,0,.)
							for(g=1;g<=N_gr;g++){
								X_b =X_b , (X_k[.,g]'-J(1,KK,b))
							}
							FxPxQ = f_ik[i,.] :* (PiXk :* (J(1,N_gr*KK,1)-PiXk))
							FxQ=(f_ik[i,.] :* (J(1,N_gr*KK,1)-PiXk)) 
					
							L1 = sum(Fxp_P :* X_b :* V)
							L2 = -a*sum(Fxp_P :* V)
							L11 = -sum(FxPxQ :* (X_b :* X_b) :* VV)
							L22 = -a^2*sum(FxPxQ :* VV)
							L12 = a*sum(FxPxQ :* X_b :* VV)
													
							Jacob = (L1,L2)'
							Fisher = -1*(L11,L12\L12,L22)
							
							delta[1..2] = (invsym(Fisher)*Jacob)'
							
							dummy_parameters=dummy_parameters+delta
						}	
	
	// testing whether maximisation converges	
						for(iter=1;iter<=100;iter++){
								dummy_parameters=dummy_parameters+m_step(X_k,  dummy_3plm  ,dummy_fix_init ,dummy_parameters,f_ik[i,.],p_ik[i,.],p_ik[i,.],0)
						}
	// this is quite arbitrary; specificity and sensitivity need to be checked
						if( (abs(sum(f_PiXk_01(dummy_parameters,dummy_3plm,X_k[.,1])*A_k[.,1]) - sum(f_PiXk_01(parameters[i,.],dummy_2plm,X_k[.,1])*A_k[.,1]) ) < means_difference_crit) & dummy_parameters[1]>0 & dummy_parameters[3]>0 & abs(dummy_parameters[2]-parameters[i,2])<20 & dummy_parameters[1]<20 ){
							if_item_found=1						
							parameters_guess[i,.]=dummy_parameters[1..3]
						}
					}
				}
				
				if( if_item_found==0 ){
					parameters_guess[i,.]=parameters[i,1..3]
					failed_list=failed_list + " " + itemlist[i]+"[conv]"
				}

				if( if_item_found==1){
					if(guessing_lrcrit<1){
						parameters_for_ll=parameters
						parameters_for_ll[i,.]=dummy_parameters
						model_for_ll=model_curr_asked
						model_for_ll[i,.]=dummy_3plm
						logL = J(N_gr,1,0)
						for(g=1;g<=N_gr;g++){
							Fg = *point_Fg[g]
							itemselectrange_g 		= select((1::I),item_group_totalobs[.,g]:>0)
							parameters_for_ll_g 	= parameters_for_ll[itemselectrange_g,.]
							model_for_ll_g		= model_for_ll[itemselectrange_g,.]
							item_n_cat_g 			= item_n_cat[itemselectrange_g]
			
							PXk_Uj = eE_step(X_k[.,g],A_k[.,g],point_Uigc[.,g],parameters_for_ll_g,item_n_cat_g,model_for_ll_g,rows(Fg))
							logL[g] = sum( Fg :* ln(rowsum(PXk_Uj)) )
						}
						logL=sum(logL)
						pvalue=1-chi2(1,2*(logL-logL_0))
					}
					else{
						pvalue=0
					}
					
					if(pvalue<guessing_lrcrit){
						parameters_guess[i,.]=dummy_parameters[1..3]
						model_curr_asked_return[i,1]="3plm"
					}
					else{
						parameters_guess[i,.]=parameters[i,1..3]
						failed_list=failed_list + " " + itemlist[i]+"[LR]"
					}	
				}
			}
		}
		
		if(failed_list!=""){
			display("Note: did not generate starting values for "+strofreal(rows(tokens(failed_list)'))+ " items: "+failed_list)
		}
		
		results = J(2,1,NULL)
		results[1] = &parameters_guess
		results[2] = &model_curr_asked_return
		return(results)
	}
	
	
	
	void print_iter(real scalar iter, real matrix DIST, real matrix delta, real matrix logL, real matrix group_vals, real scalar trace,real matrix Cns_parameters, real matrix Cns_DIST, string matrix model_curr_asked){
		if(trace==1){
			printf("ITERATION=%3.0f;logL=%15.4f\n",iter,sum(logL))
		}
		
		if(trace==2){
			I=rows(delta)
			N_item_parameters=sum(colsum(delta[.,(1..30)] :!=. ) :> 0)
			max_cat=sum(colsum(delta[.,(4..30)] :!=. ) :> 0)
			
			item_parameter_labels=J(1,N_item_parameters,"")
			parmaxs=J(1,N_item_parameters,.)
			
			count_par=1
			parmaxs[count_par]=max(abs(delta[.,1]))
			item_no=max((abs(delta[.,1]):==parmaxs[count_par]):*(1::I))
												
			item_parameter_labels[count_par]="a["+strofreal(item_no)+"]"
			parmaxs[count_par]=delta[item_no,1]
			
			if(nonmissing(delta[.,2])){
				count_par++
				parmaxs[count_par]=max(abs(delta[.,2]))
				item_no=max((abs(delta[.,2]):==parmaxs[count_par]):*(1::I))
				item_parameter_labels[count_par]="b[" + strofreal(item_no) + "]"
				parmaxs[count_par]=delta[item_no,2]
			}
			if(nonmissing(delta[.,3])){
				count_par++				
				parmaxs[count_par]=max(abs(delta[.,3]))
				item_no=max((abs(delta[.,3]):==parmaxs[count_par]):*(1::I))
				item_parameter_labels[count_par]="c[" + strofreal(item_no) + "]"
				parmaxs[count_par]=delta[item_no,3]

			}
			if(max_cat>1){
				for(c=0;c<=max_cat-1;c++){	
					count_par++				
					parmaxs[count_par]=max(abs(delta[.,4+c]))
					item_no=max((abs(delta[.,4+c]):==parmaxs[count_par]):*(1::I))
					item_parameter_labels[count_par]="b" + strofreal(c) + "[" + strofreal(item_no) + "]"
					parmaxs[count_par]=delta[item_no,4+c]
				}
			}
			
			display("______________________________________")
			printf("ITERATION=%3.0f;logL=%15.2f\n",iter,sum(logL))
			display("")
			display("Largest par change")
			stataline1="_col(10) "
			stataline2=char(34)+"Delta"+char(34)+" _col(10) "
			for(i=1;i<=N_item_parameters;i++){
				stataline1=stataline1+"%10s "+char(34)+item_parameter_labels[i]+char(34)+" _col("+strofreal(10+10*i)+") "
				stataline2=stataline2+"%10.4f "+strofreal(parmaxs[i])+" _col("+strofreal(10+10*i)+") "
			}
			stata("di "+stataline1)
			stata("di "+stataline2)
			display("")
			if(cols(DIST)>1-sum(Cns_DIST[.,1]) & trace){
				display("Parameters by group:")
				stataline3=char(34)+"Parameter"+char(34)+" _col(15) "	
				stataline4=char(34)+"logL"+char(34)+" _col(15) "	
				stataline5=char(34)+"mean"+char(34)+" _col(15) "	
				stataline6=char(34)+"sd"+char(34)+" _col(15) "	
				for(i=1;i<=cols(DIST);i++){
					stataline3=stataline3+"%10s "+char(34)+"Group="+strofreal(group_vals[i])+char(34)+" _col("+strofreal(15+12*i)+") "
					stataline4=stataline4+"%12.2f "+strofreal(logL[i])+" _col("+strofreal(15+12*i)+") "
					stataline5=stataline5+"%10.4f "+strofreal(DIST[1,i])+" _col("+strofreal(15+12*i)+") "
					stataline6=stataline6+"%10.4f "+strofreal(DIST[2,i])+" _col("+strofreal(15+12*i)+") "
				}
				stata("di "+stataline3)
				stata("di "+stataline4)
				stata("di "+stataline5)
				stata("di "+stataline6)
			}
		}
	}
	
 
 
 
	real matrix generate_pv(real scalar pv, real scalar draw_from_chain, real scalar max_independent_chains, real scalar burn, real matrix Theta_dup, pointer matrix  point_Uigc, pointer matrix point_Fg, real matrix parameters, real colvector item_n_cat, real matrix item_group_totalobs,string matrix model_curr_asked, real matrix group_uniq_total_obs, real matrix A_k, real matrix X_k, real matrix DIST, string scalar pvreg, real matrix Theta_id, real scalar if_progress, real matrix V){
	
		N_gr=cols(A_k)
		I=rows(parameters)

// and, unfortunatelly, now we have to uncontract the point_Uigc
		point_Uigc_dup			= J(I,N_gr,NULL)
		total_obs_rangestart	= 1
		group_previousuniqueobs	= 0
		point_uncontracted_group_range	=J(N_gr,1,NULL)
		for(g=1;g<=N_gr;g++){
				
			itemselectrange_g	= select((1::I),item_group_totalobs[.,g]:>0)
			item_n_cat_g 		= item_n_cat[itemselectrange_g]
			I_g 				= rows(itemselectrange_g)
			
			total_obs_rangestop					= total_obs_rangestart+group_uniq_total_obs[g,2]-1
			point_uncontracted_group_range[g]	= &(total_obs_rangestart::total_obs_rangestop)
			uncontracted_group_range			= Theta_dup[*point_uncontracted_group_range[g]] :-group_previousuniqueobs
			for(i=1;i<=I_g;i++){
				n_cat	= item_n_cat_g[i]
				U_ig	= J(group_uniq_total_obs[g,1],1,.)
				for(c=1;c<=n_cat;c++){
					ord_ic 		= *(*point_Uigc[i,g])[c]
					if(rows(ord_ic)){ // in case of fixing and missing
						U_ig[ord_ic]= J(rows( ord_ic ),1,c)
					}
				}
				point_Uigc_dup[i,g] = &return_category_range_pointers2((1::n_cat) , U_ig[uncontracted_group_range],total_obs_rangestart-1)
			}
			total_obs_rangestart	= total_obs_rangestart    + group_uniq_total_obs[g,2]
			group_previousuniqueobs	= group_previousuniqueobs + group_uniq_total_obs[g,1]
		}

		PV = J(sum(group_uniq_total_obs[.,2]),pv,.)

		long_final_estimates			= create_long_vector(DIST,parameters)
		estim_range						= select((1::rows(long_final_estimates)),rowsum(V):!=0)
		long_final_estimates_perturbed  = long_final_estimates

		count_pv=0
		if(if_progress){
			if(if_progress==1){
				stata("display "+char(34)+"Generating PVs: 0%"+char(34)+" _c")
			}
			if(if_progress==2){
				stata("display "+char(34)+"Generating PVs for item fit: 0%"+char(34)+" _c")
			}
			previous_progress=0
			progress_counter=0
		}

// if there is more PVs that the maximum number of independent chains, some pvs will be drawn from the same chain, governed by the draw_from_chain parameter
		if(pv>max_independent_chains){
			max_chain			=	max_independent_chains
			draw_at_chain_ceil	=	ceil(pv/max_independent_chains)
			draw_at_chain_floor	=	floor(pv/max_independent_chains)
			chain_ceilfloor_cut	=	max_chain-mod(pv,max_independent_chains)
		}
		else{
			max_chain=pv
			draw_at_chain_ceil	=	1
			draw_at_chain_floor	=	1
			chain_ceilfloor_cut	=	max_chain
		}
		
		
		for(chain=1;chain<=max_chain;chain++){
			
			if(chain>chain_ceilfloor_cut){
				max_i=1+draw_from_chain*(draw_at_chain_ceil-1)
			}
			else{
				max_i=1+draw_from_chain*(draw_at_chain_floor-1)
			}
			
			if_draw_from_chain=0
			
			for(i=1-burn;i<=max_i;i++){
			
				if(if_progress){
					progress_counter=progress_counter+1
					current_progress=100 * progress_counter / ( (chain_ceilfloor_cut)*(burn+1+draw_from_chain*(draw_at_chain_floor-1)) + (max_chain-chain_ceilfloor_cut)*(burn+1+draw_from_chain*(draw_at_chain_ceil-1)) )
					previous_progress=progress(current_progress,previous_progress)
				}
				
				// this perturbs model parameters so they would involve noise due error of estimation
				// only once a chain
				if(i==(1-burn)){
					// probably need to be adjusted for ordering in grm (is not)
					if(rows(estim_range)>0){
						long_final_estimates_perturbed[estim_range]	= multinormal(long_final_estimates[estim_range]',V[estim_range,estim_range'],1)'
					}
					parameters_perturbed	= uncreate_long_vector(long_final_estimates_perturbed ,parameters,DIST,0)
					aminus_range			= select(1::rows(parameters_perturbed),parameters_perturbed[.,1]:<0)
					if(rows(aminus_range)>0){
						parameters_perturbed[aminus_range,1]=J(rows(aminus_range),1,0.1)
					}
					cminus_range			= select(1::rows(parameters_perturbed),(parameters_perturbed[.,3]:<0) :* rownonmissing(parameters_perturbed[.,3]))
					if(rows(cminus_range)>0){
						parameters_perturbed[cminus_range,3]=J(rows(cminus_range),1,0.01)
					}
					cabove_range			= select(1::rows(parameters_perturbed),(parameters_perturbed[.,3]:>1) :* rownonmissing(parameters_perturbed[.,3]))
					if(rows(cabove_range)>0){
						parameters_perturbed[cabove_range,3]=J(rows(cabove_range),1,0.99)
					}
					DIST_perturbed			= uncreate_long_vector(long_final_estimates_perturbed ,parameters,DIST,1)
					
					ll_theta_se	= return_ll_theta_se( 1, 195 , item_n_cat, item_group_totalobs, model_curr_asked ,group_uniq_total_obs, X_k , A_k, parameters_perturbed, DIST_perturbed, point_Uigc, point_Fg)
					theta_tt 	= (*ll_theta_se[2])[Theta_dup]	
					sd_prop		= (*ll_theta_se[3])[Theta_dup]
					
					prior_mean	=  J(sum(group_uniq_total_obs[.,1]),1,.)
					prior_sd 	=  prior_mean
					unique_obs_rangestart = 1
					for(g=1;g<=N_gr;g++){
						unique_obs_rangestop									= unique_obs_rangestart+group_uniq_total_obs[g,1]-1
						prior_mean[unique_obs_rangestart::unique_obs_rangestop]	= J(group_uniq_total_obs[g,1],1,DIST_perturbed[1,g])
						prior_sd[unique_obs_rangestart::unique_obs_rangestop]	= J(group_uniq_total_obs[g,1],1,DIST_perturbed[2,g])
						unique_obs_rangestart									= unique_obs_rangestop+1
					}
					prior_mean = prior_mean[Theta_dup]
					prior_sd = prior_sd[Theta_dup]	
				}
				
				if(pvreg=="." | (i+burn)>ceil(burn/2)){
					theta_tt = mcmc_step(theta_tt, sd_prop , prior_mean, prior_sd, parameters_perturbed, model_curr_asked, item_group_totalobs, point_Uigc_dup)
				}
				else{  // MUST be repeated several times, otherwise estimates are biased downwards!!
					
				
					current_pv_name			= st_tempname()
					current_pv_index		= st_addvar("double",current_pv_name)
					st_store(Theta_id,current_pv_index,theta_tt)

	//xtmixed in Stata 10 does not handle factor notation					
					if(stataversion()>=1200){
						statasetversion(stataversion())
					}
					stata("qui xtmixed "+current_pv_name+" "+pvreg+",iter(50)")
					k_random_effects		= st_numscalar("e(k_r)")
					
					current_prior_name		= st_tempname()
					stata("qui predict "+current_prior_name+",fit")
					current_prior_E			= st_data(Theta_id,current_prior_name)
	//				without error of estimation of predictions we would have simply				
	//				prior_mean				= current_prior_E
					stata("qui predict "+current_prior_name+"e0,stdp")
					current_prior_S			= st_data(Theta_id,current_prior_name+"e0")
					if(k_random_effects>1){
						current_prior_S		= current_prior_S:*current_prior_S
						stata("qui predict "+current_prior_name+"e*,reses")
						for(k=1;k<=k_random_effects-1;k++){
							current_prior_S	= current_prior_S :+ st_data(Theta_id,current_prior_name+"e"+strofreal(k)):* st_data(Theta_id,current_prior_name+"e"+strofreal(k))
						}
						current_prior_S		= sqrt(current_prior_S)
					}
					
					statasetversion(1000) // resetting to Stata 1000
					
					prior_nonmiss			= select((1::rows(current_prior_E)),current_prior_E:!=.)
					
					prior_mean[prior_nonmiss]= rnormal(1,1,current_prior_E[prior_nonmiss],current_prior_S[prior_nonmiss])
					
					residuals = theta_tt-prior_mean
										
					stata("qui drop " + current_prior_name+"*")
					
					stata("qui drop " + current_pv_name)
					
					//computing prior_sd from residuals and rescaling the priors to sync with DIST_perturbed
					for(g=1;g<=N_gr;g++){
					
						mean_prior_mean=mean(prior_mean[*point_uncontracted_group_range[g]])
						variance_prior_mean=variance(prior_mean[*point_uncontracted_group_range[g]])
						mean_prior_sd = sqrt(variance(residuals[*point_uncontracted_group_range[g]]))
						
						rescaling_factor=((DIST_perturbed[2,g]^2)/(mean_prior_sd^2+variance_prior_mean))
						prior_mean[*point_uncontracted_group_range[g]]	= (prior_mean[*point_uncontracted_group_range[g]] :- mean_prior_mean):*rescaling_factor :+ DIST_perturbed[1,g]
						prior_sd[*point_uncontracted_group_range[g]] = J(group_uniq_total_obs[g,2],1, mean_prior_sd * rescaling_factor )

					}
					
					theta_tt = mcmc_step(theta_tt, sd_prop , prior_mean, prior_sd, parameters, model_curr_asked, item_group_totalobs, point_Uigc_dup)
					
				}
				
				
				if(i>0){
					if_draw_from_chain=if_draw_from_chain+1
					if(if_draw_from_chain==draw_from_chain | i==1){
						count_pv=count_pv+1
						PV[.,count_pv] = theta_tt
						if_draw_from_chain=0
					}
				}	
			}
		}
		return(PV)
	}
		
	real colvector mcmc_step(real matrix theta_t, real matrix sd_prop , real matrix prior_mean, real matrix prior_sd ,real matrix parameters, string matrix model_curr_asked, real matrix item_group_totalobs, pointer matrix point_Uigc_dup){
		
		J=rows(theta_t)
		
		theta_tt = rnormal(1,1,theta_t,sd_prop)
		L_tt = likelihood(theta_tt, parameters, model_curr_asked, item_group_totalobs, point_Uigc_dup) :* normalden(theta_tt,prior_mean,prior_sd)
		L_t = likelihood(theta_t, parameters, model_curr_asked, item_group_totalobs, point_Uigc_dup) :* normalden(theta_t,prior_mean,prior_sd)
		
		alpha = rowmin( ( J(J,1,1) , (L_tt :/ L_t) ) )
		Uni=runiform(J,1)
		theta_tt_select=select((1::J), Uni :> alpha )
		if(rows(theta_tt_select)){
			theta_tt[theta_tt_select]=theta_t[theta_tt_select]
		}
				
		return(theta_tt)

	}
	
	real colvector likelihood(real colvector theta, real matrix parameters,string matrix model_curr_asked, real matrix item_group_totalobs, pointer matrix point_Uigc_dup){
	
		I=rows(parameters)		
		N_gr=cols(point_Uigc_dup)
		item_n_cat=strtoreal(model_curr_asked[.,3])
		
		L=J(rows(theta),1,1)
		
		for(g=1;g<=N_gr;g++){
			
			itemselectrange_g	= select((1::I),item_group_totalobs[.,g]:>0)			
			parameters_g		= parameters[itemselectrange_g,.]
			item_n_cat_g		= item_n_cat[itemselectrange_g]
			model_curr_asked_g	= model_curr_asked[itemselectrange_g,.]
			I_g					= rows(itemselectrange_g)		
		
			for(i=1;i<=I_g;i++){
				n_cat = item_n_cat_g[i]
				model = model_curr_asked_g[i,1]
				if(n_cat==2){
					ord_i0		= (*(*point_Uigc_dup[i,g])[1])
					ord_i1		= (*(*point_Uigc_dup[i,g])[2])
					if(model=="2plm"){
						if(rows(ord_i0)){ // in case of fixing and missing
							L_i0	= 1 :- (invlogit(parameters_g[i,1] :* (theta[ord_i0] :- parameters_g[i,2])))
						}
						if(rows(ord_i1)){ // in case of fixing and missing
							L_i1	= invlogit(parameters_g[i,1] :* (theta[ord_i1] :- parameters_g[i,2]))				
						}
					}
					if(model=="pcm"){
						if(rows(ord_i0)){ // in case of fixing and missing
							L_i0	= 1 :- (invlogit(parameters_g[i,1] :* (theta[ord_i0] :- parameters_g[i,4])))
						}
						if(rows(ord_i1)){ // in case of fixing and missing
							L_i1	= invlogit(parameters_g[i,1] :* (theta[ord_i1] :- parameters_g[i,4]))				
						}
					}
					if(model=="3plm"){
						if(rows(ord_i0)){ // in case of fixing and missing
							L_i0	= 1 :- (invlogit(parameters_g[i,1] :* (theta[ord_i0] :- parameters_g[i,2])) :* (1-parameters_g[i,3]) :+ parameters_g[i,3])
						}
						if(rows(ord_i1)){ // in case of fixing and missing
							L_i1	= invlogit(parameters_g[i,1] :* (theta[ord_i1] :- parameters_g[i,2])) :* (1-parameters_g[i,3]) :+ parameters_g[i,3]
						}
					}
					if(rows(ord_i0)){ // in case of fixing and missing
						L[ord_i0]	= L[ord_i0] :* L_i0
					}
					if(rows(ord_i1)){ // in case of fixing and missing
						L[ord_i1]	= L[ord_i1] :* L_i1
					}

				}
				else{				
					if(model=="grm"){
						for(c=1;c<=n_cat;c++){
							ord_ic = (*(*point_Uigc_dup[i,g])[c])
							if(rows(ord_ic)){ // in case of fixing and missing
								if(c == 1){
									L_ic = 1 :- invlogit(parameters_g[i,1] :* (theta[ord_ic] :- parameters_g[i,3+1]))
								}
								if(c == n_cat){
									L_ic = invlogit(parameters_g[i,1] :* (theta[ord_ic] :- parameters_g[i,2+n_cat]))
								}
								if(c>1 & c<n_cat){
									L_ic = invlogit(parameters_g[i,1] :* (theta[ord_ic] :- parameters_g[i,4+c-2]))  :- invlogit(parameters_g[i,1] :* (theta[ord_ic] :- parameters_g[i,3+c]))
								}
								L[ord_ic]=L[ord_ic] :* L_ic
							}
						}
					}
					if(model=="gpcm" | model=="pcm"){
						for(c=1;c<=n_cat;c++){
							ord_ic = (*(*point_Uigc_dup[i,g])[c])
							if(rows(ord_ic)){ // in case of fixing and missing
								expsum_all = 1
								for(cc=2;cc<=n_cat;cc++){
									expsum_all = expsum_all :+ exp(parameters_g[i,1] :* ( (cc-1) :* theta[ord_ic] :- sum(parameters_g[i,4..2+cc]) ) )
								}
								if(c == 1){
									L_ic = 1 :/ expsum_all
								}
								else{
									L_ic = exp( parameters_g[i,1] :* ( (c-1) :* theta[ord_ic] :- sum(parameters_g[i,4..2+c]) ) ) :/ expsum_all
								}
								L[ord_ic]=L[ord_ic] :* L_ic
							}
						}					
					}
				}
			}
		}
			
		return(L)	
	}
	
	
	function Pj_centile_pv(real matrix if_makeicc, real matrix Theta_dup, pointer matrix point_Uigc, pointer matrix point_Fg, real matrix parameters, real matrix item_group_totalobs,string matrix model_curr_asked, real matrix group_uniq_total_obs  , real matrix A_k, real matrix X_k, real matrix DIST, real scalar icc_pvbin, real scalar icc_bins, real matrix V){
	
		item_n_cat=strtoreal(model_curr_asked[.,3])
		N_pv_max	= 10000
		min_ig_obs	= min(rowsum(select(item_group_totalobs,if_makeicc)))
		N_pv		= ceil( (icc_pvbin * icc_bins) / min_ig_obs )
		if(N_pv>N_pv_max){
			N_pv	=  N_pv_max
			icc_pvbin_reduced=round( (N_pv * min_ig_obs) / icc_bins ,0.1)
			display("Note: minimum number of observations for an item is "+strofreal(min(rowsum(select(item_group_totalobs,if_makeicc))))+" so icc_pvbin() was reduced to " +strofreal(icc_pvbin_reduced))
		}
	
		// very small burn assuming that stationary distribution is obtained right away, due to starting point at eap,se_eap
		burn=10		
		draw_from_chain=1			
		max_independent_chains=20
		
		PV = generate_pv(N_pv ,draw_from_chain, max_independent_chains, burn    ,   Theta_dup, point_Uigc, point_Fg    ,  parameters, item_n_cat, item_group_totalobs, model_curr_asked, group_uniq_total_obs, A_k, X_k, DIST, ".", J(0,0,.),2,V)

		J_all=rows(PV)
		
		X_low = J(icc_bins,1,.)
		X_up = J(icc_bins,1,.)
		X_low[1,1] = -1000
		X_up[icc_bins,1] = 1000 
		for(i=1;i<=icc_bins-1;i++){
			X_low[i+1,1]=invnormal(i/icc_bins)
			X_up[i,1]=X_low[i+1,1]
		}

		Pj_centile_all=J(J_all,icc_bins,0)
		
		for(i=1;i<=icc_bins;i++){
			Pj_centile_all[.,i] = rowsum((X_low[i,1] :< PV ) :* (PV :<= X_up[i,1])) :/ N_pv
		}
		
		N_gr=rows(point_Fg)
		F=J(0,1,.)
		for(g=1;g<=N_gr;g++){
			F=F\(*point_Fg[g])
		}
		
		
		Pj_centile=J(rows(F),icc_bins,0)
		up=0
		for(j=1;j<=rows(F);j++){		
			low=up+1
			up=up+F[j]
					
			if((up-low)){
				Pj_centile[j,.]=mean(Pj_centile_all[(low::up),.])
			}
			else{
				Pj_centile[j,.]=Pj_centile_all[low,.]			
			}
		}
		
		return(Pj_centile)
	}

	
	pointer PXk_Uj_all(real colvector item_n_cat, real matrix item_group_totalobs ,string matrix model_curr_asked,  real matrix group_uniq_total_obs, real matrix X_k , real matrix A_k, real matrix parameters , pointer matrix point_Uigc, pointer matrix point_Fg){
		
		N_gr=rows(group_uniq_total_obs)
		K=rows(A_k)	
		I=rows(parameters)
				
		PXk_Uj_all	=J(sum(group_uniq_total_obs[.,1]),K,1)
				
		range_start=1
		range_stop=0
		for(g=1;g<=N_gr;g++){
				
				range_stop=range_stop+group_uniq_total_obs[g,1]
				
				itemselectrange_g 	= select((1::I),item_group_totalobs[.,g]:>0)
				parameters_g 		= parameters[itemselectrange_g,.]
				item_n_cat_g 		= item_n_cat[itemselectrange_g]
				model_curr_asked_g	= model_curr_asked[itemselectrange_g,.]
				
				PXk_Uj_all[range_start::range_stop,.]= *( PXk_Uj_fit_g(X_k[.,g],A_k[.,g],point_Uigc[.,g],parameters_g,item_n_cat_g, model_curr_asked_g,group_uniq_total_obs[g,1],0)[1] )
				
				range_start=range_stop+1
		}
		
		results=J(1,1,NULL)
		results[1]=return_pointer(PXk_Uj_all)
		return(results)
		
	}		
	

	function Pj_centile_integrated(real colvector item_n_cat, pointer matrix point_Uigc, pointer matrix point_Fg, real matrix parameters, real matrix item_group_totalobs,string matrix model_curr_asked, real matrix group_uniq_total_obs , real matrix DIST, real scalar icc_bins){
	
		N_gr=cols(DIST)	
	
		K=151
		X_k_A_k	= gauss_hermite(K)
		quadpts 	= J(1,N_gr,X_k_A_k[.,1])
		P_quadpts 	= J(1,N_gr,X_k_A_k[.,2])
		for(g=1;g<=N_gr;g++){
			quadpts[.,g]=quadpts[.,g]:*DIST[2,g]:+DIST[1,g]	
		}
		
		P_all=	rowsum( *( PXk_Uj_all( item_n_cat,  item_group_totalobs , model_curr_asked,   group_uniq_total_obs, quadpts , P_quadpts,  parameters , point_Uigc,  point_Fg)[1] ) )
		
		
		borders_icc=-100,invnormal((1..icc_bins-1):/icc_bins),100
		
		K=15
		legendreRW = return_legendreRW(K)'
		Pj_centile=J(rows(P_all),icc_bins,.)
		for(d=1;d<=icc_bins;d++){		
			
			U=borders_icc[d+1]
			L=borders_icc[d]	
			quadpts		= J(K,N_gr,.)
			P_quadpts	= J(K,N_gr,.)
			for(g=1;g<=N_gr;g++){				
				quadpts[.,g]= ( (U-L) :* legendreRW[.,1] :+ (U+L) ) :/2  
				P_quadpts[.,g]= (U-L) :* legendreRW[.,2] :* normalden( quadpts[.,g],DIST[1,g],DIST[2,g]  )/2
			}
			
			Pj_centile[.,d]= rowsum( *( PXk_Uj_all( item_n_cat,  item_group_totalobs , model_curr_asked,   group_uniq_total_obs, quadpts , P_quadpts,  parameters , point_Uigc,  point_Fg,)[1] ) )
			
		}
	
		Pj_centile=Pj_centile:/P_all
		
		return(Pj_centile)
	}
	
	
	
	
	pointer colvector starting_values_fixORinit(string matrix itemlist, string scalar fiximatrix, string scalar initimatrix){
		
		I			 			= rows(itemlist)
		parameters				= J(I,32,.)
		item_fix_init_indicator	= J(I,2,0)
		model_curr_asked		= J(I,2,"")
		item_fix_init_left_strlist	= J(3,1,"")
		
		if(fiximatrix!="."){
			saved_fix_rown=st_matrixrowstripe(fiximatrix)
			saved_fix_iprs=st_matrix(fiximatrix)
			
			if(sum(saved_fix_rown:=="3plm")){
				saved_fix_iprs=saved_fix_iprs,J(rows(saved_fix_iprs),32-cols(saved_fix_iprs),.)
			}
			else{
				if(sum(saved_fix_rown:=="2plm")){
					if(cols(saved_fix_iprs)>2){
						saved_fix_iprs=saved_fix_iprs[.,(1,2)],J(rows(saved_fix_iprs),1,.),saved_fix_iprs[.,(3..cols(saved_fix_iprs))],J(rows(saved_fix_iprs),32-cols(saved_fix_iprs)-1,.)
					}
					else{
						saved_fix_iprs=saved_fix_iprs,J(rows(saved_fix_iprs),32-cols(saved_fix_iprs),.)
					}
				}
				else{
					saved_fix_iprs=saved_fix_iprs[.,1],J(rows(saved_fix_iprs),2,.),saved_fix_iprs[.,(2..cols(saved_fix_iprs))],J(rows(saved_fix_iprs),32-cols(saved_fix_iprs)-2,.)
				}
			}
			
			for(i=1;i<=I;i++){
				find_row = select( (1::rows(saved_fix_rown)) ,saved_fix_rown[.,1]:==itemlist[i])
				if(rows(find_row)){
					item_fix_init_indicator[i,1]	= find_row
					item_fix_init_left_strlist[1]	= item_fix_init_left_strlist[1]+" "+itemlist[i]				
				}
			}
			
		}
		
					
		if(initimatrix!="."){
			saved_init_rown=st_matrixrowstripe(initimatrix)
			saved_init_iprs=st_matrix(initimatrix)
			if(sum(saved_init_rown:=="3plm")){
				saved_init_iprs=saved_init_iprs,J(rows(saved_init_iprs),32-cols(saved_init_iprs),.)
			}
			else{
				if(sum(saved_init_rown:=="2plm")){
					if(cols(saved_init_iprs)>2){
						saved_init_iprs=saved_init_iprs[.,(1,2)],J(rows(saved_init_iprs),1,.),saved_init_iprs[.,(3..cols(saved_init_iprs))],J(rows(saved_init_iprs),32-cols(saved_init_iprs)-1,.)
					}
					else{
						saved_init_iprs=saved_init_iprs,J(rows(saved_init_iprs),32-cols(saved_init_iprs),.)
					}
				}
				else{
					saved_init_iprs=saved_init_iprs[.,1],J(rows(saved_init_iprs),2,.),saved_init_iprs[.,(2..cols(saved_init_iprs))],J(rows(saved_init_iprs),32-cols(saved_init_iprs)-2,.)
				}
			}	
			// fixing overrides initiating
			for(i=1;i<=I;i++){
				if(item_fix_init_indicator[i,1]==0){
					find_row = select( (1::rows(saved_init_rown)) ,saved_init_rown[.,1]:==itemlist[i])
					if(rows(find_row)){
						item_fix_init_indicator[i,2]	= find_row
						item_fix_init_left_strlist[2]	= item_fix_init_left_strlist[2]+" "+itemlist[i]				
					}
				}
			}
		}
		
		for(i=1;i<=I;i++){
			if(item_fix_init_indicator[i,1]){
				parameters[i,.] = saved_fix_iprs[item_fix_init_indicator[i,1],.]
				model_curr_asked[i,1]=saved_fix_rown[item_fix_init_indicator[i,1],2]
				model_curr_asked[i,2]=model_curr_asked[i,1]
				item_fix_init_indicator[i,1] = 1
			}
			else if(item_fix_init_indicator[i,2]){
				parameters[i,.] = saved_init_iprs[item_fix_init_indicator[i,2],.]
				model_curr_asked[i,1]=saved_init_rown[item_fix_init_indicator[i,2],2]
				model_curr_asked[i,2]=model_curr_asked[i,1]
				item_fix_init_indicator[i,2] = 1				
			}
			if(sum(item_fix_init_indicator[i,.]):==0){
				item_fix_init_left_strlist[3] = item_fix_init_left_strlist[3]+" "+itemlist[i]	
			}
		}		
		
		fix_sum = sum(item_fix_init_indicator[.,1])
		init_sum = sum(item_fix_init_indicator[.,2])
		
		if((fix_sum + init_sum)<I){
		
			if(fiximatrix!="."){
				if(fix_sum){
					display("parameters of "+strofreal(fix_sum)+" requested items were found in "+fiximatrix+" matrix; uirt.ado will set them fixed:")
					display(item_fix_init_left_strlist[1])
				}
				else{
					display("Note: no parameters for requested items found in "+fiximatrix+" matrix")
				}
			}
			if(initimatrix!="."){
				if(init_sum){
					if(fix_sum){
						display("initial parameters of additional "+strofreal(init_sum)+" requested items were found in "+initimatrix+" matrix:")
					}
					else{
						display("initial parameters of "+strofreal(init_sum)+" requested items were found in "+initimatrix+" matrix:")
					}
					display(item_fix_init_left_strlist[2])			
				}
				else{
					if(fix_sum){
						display("Note: no additional parameters found for requested items in "+initimatrix+" matrix")
					}
					else{
						display("Note: no parameters for requested items found in "+initimatrix+" matrix")
					}
				}
			}
			
			if(fix_sum + init_sum){
				display("parameters of remaining "+strofreal(I-(fix_sum + init_sum))+" requested items were not found:")
				display(item_fix_init_left_strlist[3])
			}
			else{
				display("Note: uirt.ado will try to initiate all remaining item parameters by defaults")
			}
						
		}
		else{
			if(fix_sum==I){
				display("parameters of all "+strofreal(I)+" requested items were found in "+fiximatrix+" matrix")
			}	
			if(init_sum==I){
				display("initial parameters of all "+strofreal(I)+" requested items were found in "+initimatrix+" matrix")
			}
			if(fix_sum*init_sum){
				display("parameters of "+strofreal(fix_sum)+" requested items were found in "+fiximatrix+" matrix; uirt.ado will set them fixed:")
				display(item_fix_init_left_strlist[1])				
				display("initial parameters of additional "+strofreal(init_sum)+" requested items were found in "+initimatrix+" matrix:")
				display(item_fix_init_left_strlist[2])
			}				
		}
		
						
	
		results = J(3,1,NULL)
		results[1] = &parameters
		results[2] = &item_fix_init_indicator
		results[3] = &model_curr_asked
		return(results)
	
	}

	
	
	function gauss_hermite(real scalar nip){
		N=st_nobs()
		if(nip>N){
			st_addobs(nip-N)
		}
		x_name=st_tempname()
		a_name=st_tempname()
		index=st_addvar("double",(x_name,a_name))
		stata("_GetQuad, avar("+x_name+") wvar("+a_name+") quad("+strofreal(nip)+")")
		XGH_k = st_data((nip..1)',x_name)
		AGH_k = st_data((nip..1)',a_name)
		stata("qui drop "+x_name+" "+a_name)
		X_k = (XGH_k*2^0.5)
		A_k = (AGH_k/pi()^0.5)
		if(nip>N){
			stata("qui drop in "+strofreal(N+1)+"/"+strofreal(nip))
		}
		
		return(X_k,A_k)
	}
	

	function return_pointer(real matrix input_matrix){
		return(	&input_matrix )
	}
		
	function return_range_pointer( real scalar range_end, real matrix logical_vector){
		return(	&select(1::range_end,logical_vector)	)
	}	

	
	pointer colvector return_category_range_pointers(real colvector item_cats, real colvector item_obs){
		range_end 		= rows(item_obs)
		pointer_vector	= J(rows(item_cats),1,NULL)
		for(i=1;i<=rows(item_cats);i++){
			pointer_vector[i] = return_range_pointer(range_end , item_obs :== item_cats[i] )
		}
		return(pointer_vector)
	}
	
	
	function return_range_pointer2(real scalar range_end, real matrix logical_vector,real scalar shift){
		return(	&(select(1::range_end,logical_vector):+shift)	)
	}
	
	
	pointer colvector return_category_range_pointers2(real colvector item_cats, real colvector item_obs, real scalar shift){
		range_end		= rows(item_obs)
		pointer_vector	= J(rows(item_cats),1,NULL)
		for(i=1;i<=rows(item_cats);i++){
			pointer_vector[i] = return_range_pointer2(range_end , item_obs :== item_cats[i] ,shift)
		}
		return(pointer_vector)
	}

	
	function restrict_point_Uigc(real matrix item_range, real matrix item_group_totalobs,  pointer matrix point_Uigc){
	 
	 	point_Uigc_restricted=J(rows(point_Uigc),cols(point_Uigc),NULL)
	 	N_gr=cols(item_group_totalobs)
	 	I=rows(item_group_totalobs)
	 	for(g=1;g<=N_gr;g++){
	 		point_Uigc_G=J(0,1,NULL)
	 		for(i=1;i<=I;i++){
		 		if(item_group_totalobs[i,g]>0 & sum(item_range:==i)>0){
		 			i_g = sum(item_group_totalobs[1::i,g]:>0)
		 			point_Uigc_G=point_Uigc_G\point_Uigc[i_g,g]
		 		}
		 	}
		 	if(rows(point_Uigc_G)){
		 		point_Uigc_restricted[1::rows(point_Uigc_G),g]=point_Uigc_G
		 	}
	 	}
	 	return(point_Uigc_restricted)
	 }
	
	
	pointer colvector return_group_item_info(string scalar touse, string scalar items, string scalar group, real scalar ref){
		
		itemlist = tokens(items)'
		N_itms = rows(itemlist)
		N_obs = st_nobs()
		range1_N_obs = (1::N_obs)
				
		if(group=="."){

			group_vals = J(1,1,1)
			group_labels = J(1,1,"0")
			N_gr = 1
			group_rec_data = J(N_obs,1,1)
			group_missingallitems_tempvar=st_tempname()
			stata("qui egen "+group_missingallitems_tempvar+"=rownonmiss("+items+")")
			select_missingallitems_group = select(range1_N_obs , (st_data(.,group_missingallitems_tempvar):== 0) + (st_data(.,touse):== 0))		
			stata("qui drop " + group_missingallitems_tempvar)
			if(rows(select_missingallitems_group)){
				group_rec_data[select_missingallitems_group] = J(rows(select_missingallitems_group),1,.)
				st_store(select_missingallitems_group,touse,J(rows(select_missingallitems_group),1,0))
			}
			select_missingallitems_group = J(0,0,.)
			
		}
		else{
			group_org_data = st_data(.,group)
			group_vals = uniqrows(select(group_org_data,st_data(.,touse):== 1))
			group_vals = select(group_vals,group_vals :< .)
			N_gr = rows(group_vals)	

// constructing group_vals and group_labels, according to information in group variable		
			if(ref != . & N_gr>1){
				group_vals = ref \ sort( select(group_vals , group_vals :!= ref) , 1 )
			}
			else{
				group_vals = sort(group_vals,1)
			}
			
			stata("local gr_labelname: val l "+group)
			if(strlen(st_local("gr_labelname"))){
				group_labels=st_vlmap(st_local("gr_labelname"),group_vals)
				for(g=1;g<=N_gr;g++){
					if(strlen(group_labels[g])==0){
						group_labels[g]=strofreal(group_vals[g])
					}
				}
			}
			else{
				group_labels="_":+strofreal(group_vals)
			}
			group_labels[1]="[ref] "+group_labels[1]
			
// creating group_rec_data according to valid obs count and ref() information	
			group_rec_data = J(N_obs,1,.)
			for(g=1;g<=N_gr;g++){
				index_g = select( range1_N_obs ,  group_org_data :== group_vals[g])
				group_rec_data[index_g] = J(rows(index_g),1,g)
			}
			group_org_data = J(0,0,.)
			index_g = J(0,0,.)
			
			group_missingallitems_tempvar=st_tempname()
			stata("qui egen "+group_missingallitems_tempvar+"=rownonmiss("+items+")")
			select_missingallitems_group = select(range1_N_obs , (st_data(.,group_missingallitems_tempvar):== 0) + (st_data(.,touse):== 0))		
			stata("qui drop " + group_missingallitems_tempvar)
			if(rows(select_missingallitems_group)){
				group_rec_data[select_missingallitems_group] = J(rows(select_missingallitems_group),1,.)
				st_store(select_missingallitems_group,touse,J(rows(select_missingallitems_group),1,0))
			}
			select_missingallitems_group = J(0,0,.)
					
		}
				
// creating item_* information
		point_obs_g=J(N_gr,1,NULL)
		for(g=1;g<=N_gr;g++){
			point_obs_g[g] = return_pointer(select(range1_N_obs,group_rec_data:==g))
		}
		range_groupnonmissing = select(range1_N_obs,group_rec_data:!=.)
		
		item_n_cat = J(N_itms,1,0)
		point_item_cats = J(N_itms,1,NULL)
		item_group_totalobs = J(N_itms, N_gr, 0)
		
		for(i=1;i<=N_itms;i++){
			U_i_all = st_data(.,itemlist[i])	
			item_cats = uniqrows(U_i_all[range_groupnonmissing])
			item_cats = select(item_cats,item_cats:<.)
			item_n_cat[i] = rows(item_cats)
			if(rows(item_cats)>0){
				point_item_cats[i] = return_pointer(item_cats[.])
			}
			else{
				point_item_cats[i] = return_pointer(.)
			}
			for(g=1;g<=N_gr;g++){
				item_group_totalobs[i,g] = colnonmissing(U_i_all[(*point_obs_g[g])]) 
			}
		}
		
		results = J(6,1,NULL)
		results[1] = &group_rec_data
		results[2] = &group_vals
		results[3] = &group_labels
		results[4] = &item_n_cat
		results[5] = &point_item_cats
		results[6] = &item_group_totalobs
		return(results)
	}
	
// display progress	
	function progress(real scalar current_progress,real scalar previous_progress){
		current_progress=floor(current_progress)
		while(current_progress>=previous_progress+2){
			previous_progress=previous_progress+2
			if(previous_progress/10==floor(previous_progress/10)){
				if(previous_progress<100){
					stata("display "+char(34)+strofreal(previous_progress)+"%"+char(34)+" _c")
				}
				else{
					stata("display "+char(34)+strofreal(previous_progress)+"%"+char(34))
				}
			}
			else{
				stata("display "+char(34)+"."+char(34)+" _c")
			}
		}
		return(previous_progress)
	}

	real matrix multinormal(real rowvector mu, real matrix sigma, real scalar obs){
		return(mu:+ (cholesky(sigma)*rnormal(rows(sigma),obs,0,1))')
	}	
	
	
	function verify_isnumvar(string scalar items){
		itemlist	= tokens(items)'
		notoklist		=""
		for(i=1;i<=rows(itemlist);i++){
			if(st_isnumvar(itemlist[i])==0){
				notoklist	= notoklist+" "+itemlist[i]
			}
		}
		return(notoklist)
	}

	function verify_dupvars(string scalar items){
		itemlist		= tokens(items)'
		uniq_itemlist	= uniqrows(itemlist)
		duplist			= ""
		for(i=1;i<=rows(uniq_itemlist);i++){
			s=sum(itemlist:==uniq_itemlist[i])
			if(s>1){
				duplist=duplist+" "+uniq_itemlist[i]+"(x"+strofreal(s)+")"
			}
		}
		return(duplist)
	}

	function verify_thetaexist(string scalar theta_name){
		existlist=""
		if(theta_name=="."){
			if(_st_varindex("theta")<.){
				existlist=existlist+" theta"
			}
			if(_st_varindex("se_theta")<.){
				existlist=existlist+" se_theta"
			}
		}
		else{
			if(_st_varindex("theta_"+theta_name)<.){
				existlist=existlist+"theta_"+theta_name
			}
			if(_st_varindex("se_theta_"+theta_name)<.){
				existlist=existlist+" se_theta_"+theta_name
			}
		}
		return(existlist)
	}
	
	
	function verify_pvexist(real scalar pv, string scalar theta_name){
		existlist=""
		if(theta_name=="."){
			s=sum(_st_varindex( ("pv_":+strofreal((1..pv))) ):<.)
			if(s){
				existlist=existlist+"pv_.. (x"+strofreal(s)+")"
			}
		}
		else{
			s=sum(_st_varindex( ("pv_":+strofreal((1..pv)):+"_":+theta_name) ):<.)
			if(s){
				existlist=existlist+"pv_.._"+theta_name+" (x"+strofreal(s)+")"
			}
		}
		return(existlist)
	}
	
	
	function compare_varlist(string scalar items1, string scalar items2){
		itemlist1		= tokens(items1)'
		itemlist2		= tokens(items2)'
		common_list		=""
		common_n		=0
		missin1_list	=""
		missin1_n		=0
		for(i=1;i<=rows(itemlist2);i++){
			s=sum(itemlist1:==itemlist2[i])
			if(s==0){
				missin1_list	= missin1_list+" "+itemlist2[i]
				missin1_n		= missin1_n+1		
			}
			else{
				common_list		= common_list+" "+itemlist2[i]
				common_n		= common_n+1
			}
		}
		results = J(4,1,NULL)
		results[1] = &common_list
		results[2] = &strofreal(common_n)
		results[3] = &missin1_list
		results[4] = &strofreal(missin1_n)
		return(results)
	}
	
// FIT functions
		
	real matrix SX2(real colvector if_fit_sx2, real colvector viable_for_sx2, real colvector if_df_loss, real scalar sx2_min_freq, real colvector item_n_cat ,string matrix model_curr_asked, real matrix parameters , pointer matrix point_Uigc, pointer matrix point_Fg, real matrix DIST){
	
		I=rows(parameters)
		item_indx=select((1::I),if_fit_sx2)
		I_fit=rows(item_indx)
		
		S=sx2_S(viable_for_sx2, point_Uigc, point_Fg)
		
		SX2_results=J(I_fit,4,.)	
		for(i=1;i<=I_fit;i++){
		
			LW_results=sx2_lord_wingersky(item_indx[i],viable_for_sx2, parameters, model_curr_asked, DIST)
			Eik_i=*LW_results[1]
			Sk_all_i=*LW_results[2]
			
			collapse_cats_results=sx2_collapse_cats(Eik_i,Sk_all_i,sx2_min_freq, sum(*point_Fg[1]))
			Eik=*collapse_cats_results[1]
			score_range=*collapse_cats_results[2]
			
			if(if_df_loss[i]){
				if(model_curr_asked[item_indx[i],1]=="2plm"){
					n_est_par=2
				}
				if(model_curr_asked[item_indx[i],1]=="3plm"){
					n_est_par=3
				}
				if(model_curr_asked[item_indx[i],1]=="pcm"){
					n_est_par=item_n_cat[item_indx[i]]-1
				}
				if(model_curr_asked[item_indx[i],1]=="gpcm"){
					n_est_par=item_n_cat[item_indx[i]]
				}
				if(model_curr_asked[item_indx[i],1]=="grm"){
					n_est_par=item_n_cat[item_indx[i]]
				}
			}
			else{
				n_est_par=0
			}
			
			SX2_item_results	=	sx2_orlando_thissen(item_indx[i], Eik, score_range, S, n_est_par, point_Uigc, point_Fg)
			SX2_results[i,]=(*SX2_item_results[1],*SX2_item_results[2],*SX2_item_results[3],n_est_par)
						
		}
	
		return(SX2_results)
		
	}
	

	pointer sx2_orlando_thissen(real scalar item_for_fit, real matrix Eik, real matrix score_range, real matrix S, real scalar n_est_par, pointer matrix point_Uigc, pointer matrix point_Fg ){
	
		obs_i=J(rows(*point_Fg[1]),1,0)
		ord_ic = (*(*point_Uigc[item_for_fit,1])[2])
		if(rows(ord_ic)){
			obs_i[ord_ic]=J(rows(ord_ic),1,1)
		}
		
		Oik=J(rows(Eik),1,0)
		Nik=J(rows(Eik),1,0)
		for(i=1;i<=rows(Eik);i++){
			sel_i=select((1::rows(obs_i)), (S:>=score_range[i,1] ):* (S:<=score_range[i,2] ))
			if(rows(sel_i)){
				Nik[i]=sum((*point_Fg[1])[sel_i])
				Oik[i]=cross( (*point_Fg[1])[sel_i] , obs_i[sel_i])/ Nik[i]
			}
		}
		
		SX2=sum(( Nik:*(Oik:-Eik):*(Oik:-Eik)):/(Eik:*(1:-Eik)))
		
		df=rows(Eik)-n_est_par
		
		pvalue=(1:-chi2(df,SX2))
		
		results=J(5,1,NULL)
		results[1]=return_pointer(SX2)
		results[2]=return_pointer(pvalue)
		results[3]=return_pointer(df)
		results[4]=return_pointer(Oik)
		results[5]=return_pointer(Nik)
		
		return(results)
	
	}	
	
	pointer sx2_collapse_cats(real matrix Eik_in, real matrix Sk_all_in, real scalar sx2_min_freq, real scalar N_obs){
	
		Eik=Eik_in
		Sk_all=Sk_all_in
		N=N_obs
		
		warning=""

		N=N-N*(Sk_all[1]+Sk_all[rows(Sk_all)])
		Sk_all=Sk_all[2::rows(Sk_all)-1]
		
		n_sc=rows(Sk_all)
		score_range=(1::n_sc),(1::n_sc)
		exp_freq_1=N:*Sk_all:*Eik
		for(i=1;i<=n_sc;i++){
			if(exp_freq_1[i]<sx2_min_freq){
				if(rows(score_range)>2){
					if(i==1){
						Eik = ( (Eik[i::i+1]'*Sk_all[i::i+1])/sum(Sk_all[i::i+1]) ) \ Eik[i+2::n_sc]
						Sk_all = sum(Sk_all[i::i+1])\ Sk_all[i+2::n_sc]
						score_range = (score_range[i,1],score_range[i+1,2]) \ score_range[i+2::n_sc,]
					}
					if(i>1 & i<=n_sc-2){
						Eik = Eik[1::i-1] \ ( (Eik[i::i+1]'*Sk_all[i::i+1])/sum(Sk_all[i::i+1]) ) \ Eik[i+2::n_sc]
						Sk_all = Sk_all[1::i-1] \ sum(Sk_all[i::i+1]) \ Sk_all[i+2::n_sc]
						score_range = score_range[1::i-1,] \ (score_range[i,1],score_range[i+1,2]) \ score_range[i+2::n_sc,]
					}
					if(i==n_sc-1){
						Eik = Eik[1::i-1] \ ( (Eik[i::i+1]'*Sk_all[i::i+1])/sum(Sk_all[i::i+1]) )
						Sk_all = Sk_all[1::i-1] \ sum(Sk_all[i::i+1])
						score_range = score_range[1::i-1,] \ (score_range[i,1],score_range[i+1,2])
					}
					if(i==n_sc){
						Eik = Eik[1::i-2] \ ( (Eik[i-1::i]'*Sk_all[i-1::i])/sum(Sk_all[i-1::i]) )  
						Sk_all = Sk_all[1::i-2] \ sum(Sk_all[i-1::i])
						score_range = score_range[1::i-2,] \ (score_range[i-1,1],score_range[i,2])
					}
					exp_freq_1=N:*Sk_all:*Eik
					n_sc=n_sc-1
					i=i-1
				}
				else{
					warning="could not collapse cats with sx2_min_freq="+strofreal(sx2_min_freq)
				}
			}
		}
		
		exp_freq_0=N:*Sk_all:*(1:-Eik)
		i=n_sc
		while(n_sc>1 & i>2){
			if(exp_freq_0[i]<sx2_min_freq){
				if(rows(score_range)>2){
					if(i==n_sc){
						Eik = Eik[1::i-2] \ ( (Eik[i-1::i]'*Sk_all[i-1::i])/sum(Sk_all[i-1::i]) )  
						Sk_all = Sk_all[1::i-2] \ sum(Sk_all[i-1::i])
						score_range = score_range[1::i-2,] \ (score_range[i-1,1],score_range[i,2])
					}
					else{
						Eik= Eik[1::i-2] \ ( (Eik[i-1::i]'*Sk_all[i-1::i])/sum(Sk_all[i-1::i]) ) \ Eik[i+1::n_sc]
						Sk_all= Sk_all[1::i-2] \ sum(Sk_all[i-1::i]) \ Sk_all[i+1::n_sc]
						score_range= score_range[1::i-2,] \ (score_range[i-1,1],score_range[i,2]) \ score_range[i+1::n_sc,]
					}
					exp_freq_0=N:*Sk_all:*(1:-Eik)
					n_sc=n_sc-1
				}
				else{
					warning="could not collapse cats with sx2_min_freq="+strofreal(sx2_min_freq)
				}
			}
			i=i-1
		}
		exp_freq_1=N:*Sk_all:*Eik
		
		results=J(6,1,NULL)
		results[1]=return_pointer(Eik)
		results[2]=return_pointer(score_range)
		results[3]=return_pointer(Sk_all)
		results[4]=return_pointer(exp_freq_1)
		results[5]=return_pointer(exp_freq_0)
		results[6]=&warning
		
		return(results)
	
	}
	
		
	pointer sx2_lord_wingersky(real scalar item_for_fit, real colvector viable_for_sx2, real matrix parameters, string matrix model_curr_asked, real matrix DIST_g){
	
		I=rows(parameters)
		itemselectrange_g 	= select((1::I),viable_for_sx2)
		itemselectrange_g	= select(itemselectrange_g,itemselectrange_g:!=item_for_fit)\item_for_fit
		parameters_g 		= parameters[itemselectrange_g,.]
		model_curr_asked_g	= model_curr_asked[itemselectrange_g,.]
		I=rows(parameters_g)
		
		
		K=151
		P_kX_k=gauss_hermite(K)
		P_quadpts	= P_kX_k[.,2]'
		quadpts 	= P_kX_k[.,1]':*DIST_g[2,1]:+DIST_g[1,1]
		
		f_PiXk_matrix=J(I,K,.)
		for(i=1;i<=I;i++){
			if(model_curr_asked_g[i,1]!="pcm"){
				f_PiXk_matrix[i,.]=f_PiXk_01(parameters_g[i,.],model_curr_asked_g[i,.],quadpts')
			}
			else{
				f_PiXk_matrix[i,.]=f_PiXk_0c(parameters_g[i,.],model_curr_asked_g[i,.],quadpts')[2,.]
			}
		}
		
		Sk_less=J(I+1,K,1)
		
		Sk_less[1,]=(1:-f_PiXk_matrix[1,]) 
		Sk_less[2,]=f_PiXk_matrix[1,] 
		
		for(i=2;i<=I-1;i++){
			current=Sk_less[1,]
			Sk_less[1,]=current :*(1:-f_PiXk_matrix[i,]) 
			for(s=2;s<=i;s++){
				previous=current
				current=Sk_less[s,]
				Sk_less[s,]=  ( previous :*f_PiXk_matrix[i,] ) :+ ( current :*(1:-f_PiXk_matrix[i,]) ) 
			}
			previous=current
			Sk_less[i+1,]= ( previous :*f_PiXk_matrix[i,] )
		}
		
		Sk_all=Sk_less
		
		for(i=I;i<=I;i++){
			current=Sk_all[1,]
			Sk_all[1,]= current :*(1:-f_PiXk_matrix[i,]) 
			for(s=2;s<=i;s++){
				previous=current
				current=Sk_all[s,]
				Sk_all[s,]= ( previous :*f_PiXk_matrix[i,] ) :+ ( current :*(1:-f_PiXk_matrix[i,]) )
			}
			previous=current
			Sk_all[i+1,]=  ( previous :*f_PiXk_matrix[i,] ) 
		}
		
		Eik=J(I-1,1,.)
		for(i=1;i<=I-1;i++){
			Eik[i] =	rowsum(P_quadpts :* (f_PiXk_matrix[I,] :* Sk_less[i,]) ):/ rowsum(P_quadpts :* Sk_all[i+1,])
		}	
		
		results=J(2,1,NULL)
		results[1]=return_pointer(Eik)
		results[2]=return_pointer(rowsum(P_quadpts :* Sk_all))
		return(results)
	
	}
	
	function sx2_S(real colvector viable_for_sx2,pointer matrix point_Uigc, pointer matrix point_Fg){
		S=J(rows(*point_Fg[1]),1,0)
		for(i=1;i<=rows(viable_for_sx2);i++){
			if( viable_for_sx2[i]){
				ord_ic = (*(*point_Uigc[i,1])[2])
				if(rows(ord_ic)){
					S[ord_ic]=S[ord_ic]:+1
				}
			}
		}
		return(S)
	}
	
	
	real matrix chi2W(real colvector if_fit, real scalar fit_N_intervals, real scalar fit_npq_crit, real colvector if_df_loss, real colvector item_n_cat, real matrix item_group_totalobs ,string matrix model_curr_asked,  real matrix group_uniq_total_obs, real matrix parameters , pointer matrix point_Uigc, pointer matrix point_Fg, real matrix DIST){
	
		I=rows(parameters)
		item_indx=select((1::I),if_fit)
		I_fit=rows(item_indx)
		
		chi2W_results=J(I_fit,5,.)	
		for(i=1;i<=I_fit;i++){
			
			if(if_df_loss[i]){
				if(model_curr_asked[item_indx[i],1]=="2plm"){
					n_est_par=2
				}
				if(model_curr_asked[item_indx[i],1]=="3plm"){
					n_est_par=3
				}
				if(model_curr_asked[item_indx[i],1]=="pcm"){
					n_est_par=item_n_cat[item_indx[i]]-1
				}
				if(model_curr_asked[item_indx[i],1]=="gpcm"){
					n_est_par=item_n_cat[item_indx[i]]
				}
				if(model_curr_asked[item_indx[i],1]=="grm"){
					n_est_par=item_n_cat[item_indx[i]]
				}
			}
			else{
				n_est_par=0
			}

			
			chi2W_item_results	=	chi2W_item(item_indx[i], n_est_par, fit_N_intervals , fit_npq_crit, item_n_cat, item_group_totalobs , model_curr_asked, group_uniq_total_obs, parameters ,  point_Uigc, point_Fg,  DIST)
			
			
			chi2W_results[i,]=(*chi2W_item_results[1],*chi2W_item_results[2],*chi2W_item_results[3],n_est_par,min(*chi2W_item_results[8]))
						
		}
	
		return(chi2W_results)
		
	}

	pointer chi2W_item(real scalar item_for_fit, real scalar n_est_par, real scalar N_Intervals, real scalar npq_crit, real colvector item_n_cat, real matrix item_group_totalobs ,string matrix model_curr_asked,  real matrix group_uniq_total_obs, real matrix parameters , pointer matrix point_Uigc, pointer matrix point_Fg, real matrix DIST){
	
		N_gr=cols(DIST)	
	
		K=151
		X_k_A_k	= gauss_hermite(K)
		quadpts 	= J(1,N_gr,X_k_A_k[.,1])
		P_quadpts 	= J(1,N_gr,X_k_A_k[.,2])
		for(g=1;g<=N_gr;g++){
			quadpts[.,g]=quadpts[.,g]:*DIST[2,g]:+DIST[1,g]	
		}

		PXk_Uj_fit_results=	PXk_Uj_fit( item_n_cat,  item_group_totalobs , model_curr_asked,   group_uniq_total_obs, quadpts , P_quadpts,  parameters , point_Uigc,  point_Fg, item_for_fit, 1)
		
		borders=*chi2W_collapse_intervals(item_for_fit, N_Intervals, npq_crit,  n_est_par , model_curr_asked, parameters ,  PXk_Uj_fit_results)[1]
		N_interv=cols(borders)-1

		P_all	=	*PXk_Uj_fit_results[1]
		P_all	=	rowsum(P_all)
		
		Fg_i=*PXk_Uj_fit_results[3]
		Y_i=*PXk_Uj_fit_results[5]
		nonmiss_U_ig_count=*PXk_Uj_fit_results[6]

		n_cat_i=strtoreal(model_curr_asked[item_for_fit,3])
		model_i=model_curr_asked[item_for_fit,.]
		
		K=30
		legendreRW = return_legendreRW(K)'
		Pkq=J(rows(P_all),N_interv,.)
		Ekq=J(rows(P_all),N_interv,.)
		Pkq_less_i=J(rows(P_all),N_interv,.)
		for(d=1;d<=N_interv;d++){		
			
			U=borders[d+1]
			L=borders[d]	
			quadpts		= J(K,N_gr,.)
			P_quadpts	= J(K,N_gr,.)
			for(g=1;g<=N_gr;g++){				
				quadpts[.,g]= ( (U-L) :* legendreRW[.,1] :+ (U+L) ) :/2  
				P_quadpts[.,g]= (U-L) :* legendreRW[.,2] :* normalden( quadpts[.,g],DIST[1,g],DIST[2,g]  )/2
			}
			
			PXk_Uj_fit_results=PXk_Uj_fit( item_n_cat,  item_group_totalobs , model_curr_asked,   group_uniq_total_obs, quadpts , P_quadpts,  parameters , point_Uigc,  point_Fg, item_for_fit,0)
			Pkq[.,d]=rowsum( (*PXk_Uj_fit_results[1]) )
			Pkq_less_i[.,d]=rowsum( (*PXk_Uj_fit_results[2]) )
			
			E_quadpts=J(rows(P_all),K,.)
			range_start=1
			range_stop=0
			for(g=1;g<=N_gr;g++){
				if(nonmiss_U_ig_count[g]){
					range_stop=range_stop+nonmiss_U_ig_count[g]
					
						if(n_cat_i==2  & model_i[1]!="pcm"){
							PiXk_0c=(1 :- f_PiXk_01(parameters[item_for_fit,.],model_i,quadpts[.,g])) \ f_PiXk_01(parameters[item_for_fit,.],model_i,quadpts[.,g])
						}
						else{
							PiXk_0c=f_PiXk_0c(parameters[item_for_fit,.],model_i,quadpts[.,g])
						}
						
						E_temp=J(1,K,0)
						for(c=2;c<=n_cat_i;c++){
								E_temp = E_temp :+ ((c-1) :* PiXk_0c[c,.])
						}
					
						E_quadpts[range_start::range_stop,.]=J(nonmiss_U_ig_count[g],1,E_temp)
					
					range_start=range_stop+1
				}
			}
			Ekq[.,d]=rowsum( (*PXk_Uj_fit_results[2]) :* E_quadpts)
		}
	
		Pkq_simplex=Pkq:/P_all
		
		exp_N=colsum(Fg_i:*Pkq_simplex)
		
		E=colsum(Fg_i:*(Ekq:/Pkq_less_i):*Pkq_simplex):/exp_N
		
		O=colsum(Fg_i:*Pkq_simplex:*Y_i):/exp_N
		
		inv_COV_D=invsym(quadcross((sqrt(Fg_i):*Pkq_simplex:*(Y_i:-J(rows(Y_i),1,O) ):/exp_N),(sqrt(Fg_i):*Pkq_simplex:*(Y_i:-J(rows(Y_i),1,O) ):/exp_N)))
		
		d=(O-E)
		
		NPQ=exp_N:*E:*((n_cat_i-1):-E)
		
		W			=	d*inv_COV_D*d'
		df_W		=	rank(inv_COV_D)-n_est_par
		pvalue		=	1:-chi2(df_W,W)
		sign_W		=	(pvalue< 0.05)
		
		
		results = J(9,1,NULL)
		results[1] = return_pointer(W)
		results[2] = return_pointer(pvalue)
		results[3] = return_pointer(df_W)
		results[4] = return_pointer(sign_W)
		results[5] = return_pointer(E)
		results[6] = return_pointer(O)
		results[7] = return_pointer(exp_N)		
		results[8] = return_pointer(NPQ)
		results[9] = return_pointer(borders)
		
		return(results)
	}		



	pointer chi2W_collapse_intervals(real scalar item_for_fit, real scalar N_Intervals, real scalar npq_crit, real scalar n_est_par ,string matrix model_curr_asked, real matrix parameters , pointer matrix PXk_Uj_fit_results){
	
		warning=""
		
		if(N_Intervals-n_est_par<1){
			N_interv=n_est_par+5
		}
		else{
			N_interv=N_Intervals
		}
		
		P_all=*PXk_Uj_fit_results[1]
		Fg_i=*PXk_Uj_fit_results[3]
		quadpts=*PXk_Uj_fit_results[4]
		nonmiss_U_ig_count=*PXk_Uj_fit_results[6]
		
		N_gr=cols(quadpts)		

		n_cat_i=strtoreal(model_curr_asked[item_for_fit,3])
		model_i=model_curr_asked[item_for_fit,.]
		
		K=cols(P_all)
		E_quadpts=J(rows(P_all),K,.)
		range_start=1
		range_stop=0
		for(g=1;g<=N_gr;g++){
			if(nonmiss_U_ig_count[g]){
			
				range_stop=range_stop+nonmiss_U_ig_count[g]
				
					if(n_cat_i==2  & model_i[1]!="pcm"){
						PiXk_0c=(1 :- f_PiXk_01(parameters[item_for_fit,.],model_i,quadpts[.,g])) \ f_PiXk_01(parameters[item_for_fit,.],model_i,quadpts[.,g])
					}
					else{
						PiXk_0c=f_PiXk_0c(parameters[item_for_fit,.],model_i,quadpts[.,g])
					}
					
					E_temp=J(1,K,0)
					for(c=2;c<=n_cat_i;c++){
							E_temp = E_temp :+ ((c-1) :* PiXk_0c[c,.])
					}
				
					E_quadpts[range_start::range_stop,.]=J(nonmiss_U_ig_count[g],1,E_temp)
				
				range_start=range_stop+1
				
			}
		}
		
		PQ_quadpts=E_quadpts:*((n_cat_i-1):-E_quadpts)
		
		
		
		NPQ_all=sum( Fg_i :* P_all :* PQ_quadpts :/ rowsum(P_all) )
		P_all=	rowsum(Fg_i :* P_all)
		
		if( (NPQ_all/N_interv) < npq_crit ){
			N_interv = floor(NPQ_all/npq_crit)
		}
		
		if(N_interv-n_est_par<1){
			N_interv=n_est_par+1
			warning="N*p*q~"+substr(strofreal(NPQ_all/N_interv),1,4)+"<10, chi2 approximation may be unreliable"
		}
		
		NPQ_d_crit=NPQ_all/N_interv
		
		
		K=9
		legendreRW = return_legendreRW(K)'
		N_int=10000
		bord=-10,invnormal((1..N_int-1):/N_int),10
		E_d=J(1,N_int,.)	
		for(d=1;d<=N_int;d++){
			U=bord[d+1]
			L=bord[d]
			quadpts= ( (U-L) :* legendreRW[.,1] :+ (U+L) ) :/2  
			P_N01_quadpts= (U-L) :* legendreRW[.,2] :* normalden( quadpts  )/2
			
			if(n_cat_i==2  & model_i[1]!="pcm"){
				PiXk_0c=(1 :- f_PiXk_01(parameters[item_for_fit,.],model_i,quadpts)) \ f_PiXk_01(parameters[item_for_fit,.],model_i,quadpts)
			}
			else{
				PiXk_0c=f_PiXk_0c(parameters[item_for_fit,.],model_i,quadpts)
			}
			
			E_temp=J(1,K,0)
			for(c=2;c<=n_cat_i;c++){
					E_temp = E_temp :+ ((c-1) :* PiXk_0c[c,.])
			}
			
			E_d[d]=E_temp*P_N01_quadpts/sum(P_N01_quadpts)
			
		}
		
		NPQ=(sum(Fg_i)/N_int):*E_d:*((n_cat_i-1):-E_d)
	
		NPQ_crit=NPQ_d_crit*0.99*(sum(NPQ)/NPQ_all)
		borders=-10,J(1,N_interv-1,.),10
		up=1
		b_up=2
		b_down=N_interv
		int_up=1
		int_down=N_int
		proceed=1
		for(k=1;k<=N_interv-1;k++){
			if(proceed){
				if(up){
					S=0
					int_start=int_up
					while(S<NPQ_crit){
						S=sum(NPQ[int_start..int_up])
						int_up++
					}
					borders[b_up]=bord[int_up]
					b_up++
					up=0
				}
				else{
					S=0
					int_start=int_down
					while(S<NPQ_crit){
						S=sum(NPQ[int_down..int_start])
						int_down--
					}
					borders[b_down]=bord[int_down]
					b_down--
					up=1
				}
				
				proceed=-1
				r_int_span=(int_down-int_up)/(N_interv-k)
				for(r=1;r<=N_interv-k;r++){
					if( sum(NPQ[int_up+floor((r-1)*r_int_span)+1..int_up+floor(r*r_int_span)]) < NPQ_crit ){
						proceed=1
					}
				}
				
			}

			if(proceed==-1){
				r=1
				for(b=b_up;b<=b_down;b++){
					borders[b]=bord[int_up+floor(r*r_int_span)+1]
					r++
				}
				proceed=0
			}
		}	
		
					
		results = J(2,1,NULL)
		results[1] = return_pointer(borders)
		results[2] = &warning
		
		return(results)

	}
	
	
	
	pointer PXk_Uj_fit(real colvector item_n_cat, real matrix item_group_totalobs ,string matrix model_curr_asked,  real matrix group_uniq_total_obs, real matrix X_k , real matrix A_k, real matrix parameters , pointer matrix point_Uigc, pointer matrix point_Fg, real scalar item_for_fit, real scalar if_FY){
	
		item_group_totalobs_i=item_group_totalobs[item_for_fit,.]
		n_cat_i=strtoreal(model_curr_asked[item_for_fit,3])
		
		N_gr=rows(group_uniq_total_obs)
		K=rows(A_k)	
		I=rows(parameters)
		
		point_Uixx = J(1,N_gr,NULL)
		for(g=1;g<=N_gr;g++){
			if(item_group_totalobs_i[g]){
				i_g = sum(item_group_totalobs[1::item_for_fit,g]:>0)
				point_Uixx[g]	= point_Uigc[i_g,g]
			}
			else{
				point_Uixx[g]	= &J(0,0,.)
			}
		}
		
		
		PXk_Uj_i	=J(sum(group_uniq_total_obs[.,1]),K,1)
		PXk_Uj_less_i=J(sum(group_uniq_total_obs[.,1]),K,1)
		if(if_FY){
			Fg_i	=	J(sum(group_uniq_total_obs[.,1]),1,1)
			Y_i		=	J(sum(group_uniq_total_obs[.,1]),1,1)
		}
		else{
			Fg_i	=	J(0,0,.)
			Y_i		=	J(0,0,.)		
		}
				
		range_start=1
		range_stop=0
		nonmiss_U_ig_count=J(N_gr,1,0)
		for(g=1;g<=N_gr;g++){
			if(item_group_totalobs_i[g]){
				
				nonmiss_U_ig_vector	=J(0,1,.)
				Y_ig				= J(0,1,.)
				for(c=1;c<=n_cat_i;c++){
					ord_ic 		= (*(*point_Uixx[g])[c])
					nonmiss_U_ig_vector=nonmiss_U_ig_vector\ord_ic
					if(if_FY){
						Y_ig= Y_ig\J(rows(ord_ic),1,c-1)
					}
				}
				nonmiss_U_ig_count[g]=rows(nonmiss_U_ig_vector)
				
				range_stop=range_stop+nonmiss_U_ig_count[g]
				
				itemselectrange_g 	= select((1::I),item_group_totalobs[.,g]:>0)
				parameters_g 		= parameters[itemselectrange_g,.]
				item_n_cat_g 		= item_n_cat[itemselectrange_g]
				model_curr_asked_g	= model_curr_asked[itemselectrange_g,.]
				item_for_fit_g=select((1::rows(itemselectrange_g)),itemselectrange_g:==item_for_fit)
				
				PXk_Uj_fit_g_results= PXk_Uj_fit_g(X_k[.,g],A_k[.,g],point_Uigc[.,g],parameters_g,item_n_cat_g, model_curr_asked_g,group_uniq_total_obs[g,1],item_for_fit_g)
				
				PXk_Uj_i[range_start::range_stop,.]			=	(*PXk_Uj_fit_g_results[1])[nonmiss_U_ig_vector,.]
				PXk_Uj_less_i[range_start::range_stop,.]	=	(*PXk_Uj_fit_g_results[2])[nonmiss_U_ig_vector,.]
				if(if_FY){
					Fg_i[range_start::range_stop,.]				=	(*point_Fg[g])[nonmiss_U_ig_vector]
					Y_i[range_start::range_stop,.]				=	Y_ig
				}
			
				range_start=range_stop+1
				
			}
		}
		
		PXk_Uj_i=PXk_Uj_i[1::range_stop,.]
		PXk_Uj_less_i=PXk_Uj_less_i[1::range_stop,.]
		if(if_FY){
			Fg_i	=	Fg_i[1::range_stop]
			Y_i		=	Y_i[1::range_stop]
		}	
		
		results=J(6,1,NULL)
		results[1]=return_pointer(PXk_Uj_i)
		results[2]=return_pointer(PXk_Uj_less_i)
		results[3]=return_pointer(Fg_i)
		results[4]=return_pointer(X_k)
		results[5]=return_pointer(Y_i)
		results[6]=return_pointer(nonmiss_U_ig_count)
		return(results)
		
	}		
	

	pointer PXk_Uj_fit_g(real matrix X_k,real matrix A_k, pointer matrix point_Uxgx, real matrix parameters, real colvector item_n_cat,string matrix model_curr_asked, real scalar Obs_g, real scalar item_for_fit){
		I=rows(parameters)
		K=rows(X_k)
		
		LXk_Uj=J(Obs_g,K,1)
		for(i=1;i<=item_for_fit-1;i++){
			n_cat	= item_n_cat[i]
			model	= model_curr_asked[i,.]
			if(n_cat==2  & model[1]!="pcm"){
				PiXk_0c=(1 :- f_PiXk_01(parameters[i,.],model,X_k)) \ f_PiXk_01(parameters[i,.],model,X_k)
			}
			else{
				PiXk_0c=f_PiXk_0c(parameters[i,.],model,X_k)
			}
	
			for(c=1;c<=n_cat;c++){
				ord_ic = *(*point_Uxgx[i])[c]
				if(rows(ord_ic)){ // in case of fixing and missing
					LXk_Uj[ord_ic,.] = LXk_Uj[ord_ic,.] :* PiXk_0c[c,.]
				}
			}
		}
		for(i=item_for_fit+1;i<=I;i++){
			n_cat	= item_n_cat[i]
			model	= model_curr_asked[i,.]
			if(n_cat==2  & model[1]!="pcm"){
				PiXk_0c=(1 :- f_PiXk_01(parameters[i,.],model,X_k)) \ f_PiXk_01(parameters[i,.],model,X_k)
			}
			else{
				PiXk_0c=f_PiXk_0c(parameters[i,.],model,X_k)
			}
	
			for(c=1;c<=n_cat;c++){
				ord_ic = *(*point_Uxgx[i])[c]
				if(rows(ord_ic)){ // in case of fixing and missing
					LXk_Uj[ord_ic,.] = LXk_Uj[ord_ic,.] :* PiXk_0c[c,.]
				}
			}
		}
	
		if(item_for_fit){
			PXk_Uj_less_i=A_k' :* LXk_Uj
			
			i=item_for_fit
			n_cat	= item_n_cat[i]
			model	= model_curr_asked[i,.]
			if(n_cat==2  & model[1]!="pcm"){
				PiXk_0c=(1 :- f_PiXk_01(parameters[i,.],model,X_k)) \ f_PiXk_01(parameters[i,.],model,X_k)
			}
			else{
				PiXk_0c=f_PiXk_0c(parameters[i,.],model,X_k)
			}
	
			for(c=1;c<=n_cat;c++){
				ord_ic = *(*point_Uxgx[i])[c]
				if(rows(ord_ic)){ // in case of fixing and missing
					LXk_Uj[ord_ic,.] = LXk_Uj[ord_ic,.] :* PiXk_0c[c,.]
				}
			}
		}
		else{
			PXk_Uj_less_i=J(0,0,.)
		}
		PXk_Uj=A_k' :* LXk_Uj
		
		results=J(2,1,NULL)
		results[1]=return_pointer(PXk_Uj)
		results[2]=return_pointer(PXk_Uj_less_i)
		return(results)
	}
	
	// return_legendreRW() function below adapts a code from:
	// Adrian Mander, 2012. "INTEGRATE: Stata module to perform one-dimensional integration," 
	// Statistical Software Components S457429, Boston College Department of Economics, revised 10 Aug 2018.
	function return_legendreRW(real scalar nip){
	  i = (1..nip-1)
	  b = i:/sqrt(4:*i:^2:-1) 
	  z1 = J(1,nip,0)
	  z2 = J(1,nip-1,0)
	  CM = ((z2',diag(b))\z1) + (z1\(diag(b),z2'))
	  V=.
	  L=.
	  symeigensystem(CM, V, L)
	  w = (2:* V':^2)[,1]
	  return( L \ w') 
	}	
	
end
