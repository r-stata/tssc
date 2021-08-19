*! flexpaneldid_preprocessing v1.3.0	2020-12-04


capture program drop flexpaneldid_preprocessing
program flexpaneldid_preprocessing, rclass
	version 13
	syntax , 																	///
						id(varname)												/// 
						treatment(varname numeric) 								/// 
						time(varname numeric)									/// 
						matchvars(varlist min = 1)								///  	
						[matchvarsexact(varlist min = 1)]						/// 
						[matchtimerel(integer 0)]								/// 
						[prepdataset(string)]									/// 
						[replace]												/// 

	
	
	* check if at least one obs. is defined as treatment
	quietly count if `treatment' == 1
	if `r(N)' == 0 {
		di as text
		di as error "There is no treatment information defined in `treatment' variable."
		exit 198
	}

	
	* check if prepdataset already exists when no replace option is defined
	capture confirm file `prepdataset'
	if _rc == 0 & "`replace'" == "" {
		di as text ""
		di as error "File `prepdataset' already exists, please rename file or set replace option."
		exit 198
	}
	
	di as text ""
	di as text ""
	di as text "{bf:********************************************************************************}"
	di as text "{bf:************************* flexpaneldid - preprocessing *************************}"
	di as text "{bf:********************************************************************************}"
	di as text ""
	
	di as text "{hline 80}"
	di as text "id:" _col(25) as result "`id'"
	di as text "treatment:" _col(25) as result "`treatment'"
	di as text "time:" _col(25) as result "`time'"
	di as text "matchvars:" _col(25) as result "`matchvars'"
	di as text "matchvarsexact:" _col(25) as result "`matchvarsexact'"
	di as text "match_time:" _col(25) as result "`matchtimerel'"
	di as text "prepdataset:" _col(25) as result "`prepdataset'"
	di as text "{hline 80}"

	local outtimerel = 0
	local group = 0
	local matched_0 = 0
	local matched_1 = 0
	local is_string_id = 0
	
	tempfile tmp		
	tempfile bak
	tempfile matching_result
	tempfile string_id_merge
	
	quietly keep `varlist' `id' `treatment' `time' `matchvarsexact' `matchvars'
	
	* gen var for treated
	quietly bysort `id': egen treated = max(`treatment')
	
	* gen stats for preprocessing summary
	quietly egen _treated_before_prep = group(`id') if treated == 1
	quietly sum _treated_before_prep
	local treated_before_prep = "`r(max)'"
	quietly drop _treated_before_prep

	quietly compress
	quietly save `bak'
	
	* `id' and `matchvarsexact' could be strings -> convert to numerical vars
	capture confirm string variable `id'
	if !_rc {
        local is_string_id = 1
		
		rename `id' `id'_tmp
		egen `id' = group(`id'_tmp)
		
		preserve
		keep `id' `id'_tmp
		quietly duplicates drop

		quietly save `string_id_merge'
		restore
    }
    
	* matchvarsexact
	foreach v of local matchvarsexact {
        capture confirm string variable `v'
        if !_rc {
            rename `v' `v'_tmp
			quietly egen `v' = group(`v'_tmp)
			drop `v'_tmp
        }
    }

	
	* drop obs. with missing information
	quietly drop if `id' == .
	quietly drop if `time' == .

	foreach v of local matchvarsexact {
		quietly drop if `v' == .
	}

	* check for duplicates in `id' `time'
	quietly duplicates report `id' `time'
	if r(N) != r(unique_value) {
		di as text
		di as error "There are duplicates in `id' `time''"
		exit 198
	}
	
	di as text ""
	di as text ""
	di as text "{bf:********************************************************************************}"
	di as text "{bf:************************* Preprocessing ****************************************}"
	di as text "{bf:********************************************************************************}"
	di as text ""
	
	mata: preProcessing("`id'", "`time'", "`treatment'", "`matchvarsexact'", "`matchvars'")
	
	* label matching vars + outcome_dev
	foreach m of local matchvars {
		label variable `m' "`m' (at treatment time `matchtimerel')"
	}

	* keep only selection_groups containing at least one treated
	quietly count
	if r(N) == 0 {
		di as text ""
		di as error "After preprocessing, no observations remaining for matching"
		exit 198
	}
	else {
		quietly bysort selection_group: egen h1 = sum(treated)
		quietly keep if h1 > 0
		quietly drop h1
	}
	
	* keep only selection_groups containing beside treated at least one non treated 
	quietly count
	if r(N) == 0 {
		di as text ""
		di as error "After preprocessing, no observations remaining for matching"
		exit 198
	}
	else {		
		quietly bysort selection_group: egen h2 = min(treated)
		quietly keep if h2 == 0
		quietly drop h2
	}

	* check if there are still observations in dataset
	quietly count
	if r(N) == 0 {
		di as text ""
		di as error "After preprocessing, no observations remaining for matching"
		exit 198
	}
	else {
		* remerge, if string ids in original data set
		if `is_string_id' == 1 {
			quietly merge m:1 `id' using `string_id_merge', keep(3)
			quietly drop `id' _merge
			rename `id'_tmp `id'
			order `id'
			sort selection_group treated
		}

		if "`prepdataset'" != "" {
			quietly save "`prepdataset'", `replace'
		}
	}


	* Preprocessing summary
	quietly egen _treated_after_prep = group(`id') if treated == 1
	quietly sum _treated_after_prep
	local treated_after_prep = "`r(max)'"
	quietly drop _treated_after_prep

	local treated_dropped = `treated_before_prep' - `treated_after_prep'
		
	preserve
	quietly bysort selection_group: gen h_size = _N
	quietly keep selection_group h_size
	quietly duplicates drop
	quietly sum h_size

	local selection_group = `r(N)'
	local group_size_mean = `r(mean)'
	restore
	

	di as text ""
	di as text ""
	di as text "{bf:********************************************************************************}"
	di as text "{bf:************************* Preprocessing - Summary ******************************}"
	di as text "{bf:********************************************************************************}"
	di as text ""
	di as text "Number of treated: " _col(49) as result %8.0g `treated_before_prep'
	di as text "Number of treated dropped during preprocessing: " _col(49) as result %8.0g `treated_dropped'
	di as text "Number of treated after preprocessing: " _col(49) as result %8.0g `treated_after_prep'
	di as text "Mean size of selection groups: " _col(49) as result %8.0g `group_size_mean'
	
	return scalar treated = `treated_before_prep'
	return scalar treated_dropped = `treated_dropped'
	return scalar treated_kept = `treated_after_prep'
	return scalar group_size_mean = `group_size_mean'

	gsort selection_group -treated

end 



*** mata functions for preprocessing ***
mata:
mata clear
mata set matastrict on

void preProcessing(string scalar id,
				   string scalar time,
				   string scalar treatment,
				   string scalar mvars_exact,
				   string scalar mvars)
{
	real matrix V_id, V_time, V_treatment, V_mvars, V_mvars_exact
	real scalar match_time_rel,  i, c, obs, no_of_treated, bar_length
	real matrix treated_id_time, treated_id_mvars_exact, sel_group, preselection
	real matrix S
	real colvector exact_matched_nontreated, all_treated_ids
	string rowvector colnames
			
	// put all stata variables in mata matrices
	st_view(V_id, ., id)
	st_view(V_time, ., time)
	st_view(V_treatment, ., treatment)
	st_view(V_mvars_exact, ., mvars_exact)
	st_view(V_mvars, ., mvars)

	// if no exact matching vars are defined -> create dummy exact matching var containing 1 for every obs
	if (length(V_mvars_exact) == 0) {
		V_mvars_exact = J(length(V_id), 1, 1)
	}
	
	// matchtimerel from flexpaneldid option
	match_time_rel = strtoreal(st_local("matchtimerel"))
	
	treated_id_time = getTreatedTimeFirstLast(V_id, V_time, V_treatment)
	
	treated_id_mvars_exact = getExactMatchVars(treated_id_time, V_id, V_time, V_mvars_exact, match_time_rel)
	
	all_treated_ids = uniqrows(treated_id_time[., 1])
		
	// counter for append / rowjoin 
	c = 0
	
	no_of_treated = rows(treated_id_time)
	bar_length = 50
	printf("Preprocessing of %f treated: \n", no_of_treated)

	for (i=1; i<=no_of_treated; i++) {
		exact_matched_nontreated = getExactMatchedNT(treated_id_time[i, .], treated_id_mvars_exact[i, .],
													 all_treated_ids, V_id, V_time, V_mvars_exact, match_time_rel)
		
		// show the progress of preprocessing
		if (mod(i, bar_length) == 0) {
			printf(". %f \n", i)
		}
		else if (i == no_of_treated) {
			printf(". %f", i)
		}
		else {
			printf(".")
		}
		displayflush()

		if (length(exact_matched_nontreated) > 0) {
			sel_group = getSelectionGroup(treated_id_time[i, .], exact_matched_nontreated,
										  V_id, V_time, V_treatment, V_mvars, match_time_rel)
		}
		else {
			continue
		}
		
		// create id for selection group
		if (length(sel_group) > 0) {
			c++
			S = J(rows(sel_group), 1, c)
			sel_group[., 2] = S
			
			if (c == 1) {
				preselection = sel_group
			}
			else {
				preselection = (preselection \ sel_group)
			}	
		}
	}
	
	if (length(preselection) > 0) {
		obs = rows(preselection)
		
		// clear the "old" stata dataset and write back the created preselection matrix
		stata("clear")
		
		colnames = getColnames(id, mvars)
		
		(void) st_addvar("double", colnames)
		st_addobs(obs)
		st_store(., ., preselection)	
	}
	else {
		_error("No observations remaining for matching.")
	}
}


// identify all ids for treated and define earliest and latest treatment time
real matrix getTreatedTimeFirstLast(real matrix id,
									real matrix time,
									real matrix treatment)
{
	real matrix M, M2, info, grpdata, grpdata_treatment_time
	real scalar t, i
	
	M = (id, time)
		
	// select only obs of treated 
	M2 = select(M, treatment :== 1)
		
	// nr of unique treated ids
	t = rows(uniqrows(M2[.,1]))
		
	// gen empty matrix for treatment time information
	grpdata_treatment_time = J(t, 3, .)
	
	// keep the structure of the panel 
	info = panelsetup(M2, 1)
		
	// identify time of first and last treatment 
	for (i=1; i<=t; i++) {
		panelsubview(grpdata = ., M2, i, info)
		
		grpdata_treatment_time[i, 1] = grpdata[1, 1]
		grpdata_treatment_time[i, 2] = min(grpdata[., 2])
		grpdata_treatment_time[i, 3] = max(grpdata[., 2])
	}
	
	return(grpdata_treatment_time)	
}


// define exact matching vars for all treated ids at matching time
real matrix getExactMatchVars(real matrix treated_id_time,
							  real matrix id,
							  real matrix time,
							  real matrix mvars_exact,
							  real scalar match_time_rel)
{
	real scalar r, c, i, j
	real matrix treated_mvars_exact, T
	
	r = rows(treated_id_time)
	c = cols(mvars_exact) + 1 	// additional col for treated id
	
	// gen empty matrix for exact matching vars
	treated_mvars_exact = J(r, c, .)
	
	treated_mvars_exact[., 1] = treated_id_time[., 1]
	
	for (i=1; i<=r; i++) {
					
		for (j=1; j<c; j++) {
			T = select(mvars_exact[., j], id[., 1] :== treated_id_time[i, 1] :& time[., 1] :== treated_id_time[i, 2] + match_time_rel)
						
			// if matching time is not observable -> no exact match vars 
			if (rows(T) == 0) {
				treated_mvars_exact[i, j+1] = .
			}
			else {
				treated_mvars_exact[i, j+1] = T
			}
		}
	}
	
	return(treated_mvars_exact)
}


// get for specific treated all non treated with equal exact match vars at matching time
transmorphic getExactMatchedNT(real rowvector treated_id_time,
								 real rowvector treated_id_mvars_exact,
								 real colvector all_treated_ids,
								 real matrix id,
								 real matrix time,
								 real matrix mvars_exact,
								 real scalar match_time_rel)
{
	pointer matrix M
	real scalar i
	real colvector b, c, exact_ids
	transmorphic nt_exact_ids
	
	// create matrix as a container (pointer) for results for every exact matching var
	M = J(1, cols(mvars_exact), NULL)
		
	for (i=1; i<=cols(M); i++) {
		// create pointers to matrices with the ids match exactly for each exact matching var 
		M[1, i] = &J(0, 1, .)
		
		// keep exact matched ids
		*M[1,i] = select(id, time[., 1] :== (treated_id_time[2] + match_time_rel) :& mvars_exact[., i] :== treated_id_mvars_exact[i + 1])
		
		if (i > 1) {
			
			// if more than one exact matching var intersection of colvectors -> stepwise intersection for all exact matching vars
			exact_ids = select((b = uniqrows(exact_ids)), rowsum(J(rows(b),1,uniqrows(*M[1,i])') :== b))
		}
		else {
			exact_ids = *M[1,i]
		}
	}
	
	// difference of colvectors -> removes all treated ids from exact matches
	nt_exact_ids = select((c = uniqrows(exact_ids)), rowmin(J(rows(c),1,uniqrows(all_treated_ids)') :!= c))

	return(nt_exact_ids)
		
}



real matrix getSelectionGroup(real rowvector treated_id_time,
							  real colvector nt_exact_ids,
							  real matrix id,
							  real matrix time,
							  real matrix treatment,
							  real matrix mvars,
							  real scalar match_time_rel)
{
	real matrix tmp, tmp1, tmp2, tmp_all
	real matrix mvars_at_matching_time
	real matrix selection_group
	real scalar i, c
	real colvector id_list
	real matrix s1, s2, s3, s4
	pointer matrix p_tmp_all
	
	if (length(nt_exact_ids) == 0) {
		return
	}
	
	tmp = (id, time, mvars)
	
	// select all obs of specific treated
	tmp1 = select(tmp, id[., 1] :== treated_id_time[1,1])
	
	// stepwise select all obs of the exact matched non treated ids and append within selection group
	for (i=1; i<=length(nt_exact_ids); i++) {
		
		tmp2 = select(tmp, id[., 1] :== nt_exact_ids[i])
		
		if (i == 1) {
			tmp_all = tmp2
		}
		else {
			tmp_all = (tmp_all \ tmp2)
		}
	}
	
	// append obs of specific treated
	tmp_all = (tmp1 \ tmp_all)
	
	// passing tmp_all as pointer
	p_tmp_all = &tmp_all

	mvars_at_matching_time = getMvarsAtMatchingTime(treated_id_time, *p_tmp_all, match_time_rel)
	
	// merge all mvars and outcome vars at observed times
	// result is selection group with all needed variables which is the input for matching
	id_list = uniqrows(tmp_all[.,1])
	
	// number of cols for selection group result
	// id, selection_group, treated, first_treatment, last_treatment, mvars 1..n
	c = (5 + cols(mvars))
	
	selection_group = J(rows(id_list), c, .)

	// id
	selection_group[., 1] = id_list
	
	for (i=1; i<=rows(id_list); i++) {
		// treated
		if (selection_group[i, 1] == treated_id_time[1]) {
			selection_group[i, 3] = 1
		}
		else {
			selection_group[i, 3] = 0
		}
		
		// first_treatment
		selection_group[i, 4] = treated_id_time[2]
		
		// last treatment
		selection_group[i, 5] = treated_id_time[3]
		
		// mvars
		if (length(mvars_at_matching_time) > 0) {
			s1 = select(mvars_at_matching_time[., 2..cols(mvars_at_matching_time)], mvars_at_matching_time[., 1] :== id_list[i])
			if (length(s1) > 0) {
				selection_group[i, 6..(6 + cols(mvars) - 1)] = s1
			}
		}
	}
	
	return(selection_group)
}


// get matching vars at matching time within selection group
real matrix getMvarsAtMatchingTime(real rowvector treated_id_time,
								   pointer matrix sel_all,
								   real scalar match_time_rel)
{
	real matrix mvars_at_matching_time
	real scalar m
	
	mvars_at_matching_time = select(sel_all, sel_all[., 2] :== (treated_id_time[2] + match_time_rel))
	
	// keep only id and matching vars
	m = cols(sel_all)
	mvars_at_matching_time = mvars_at_matching_time[., (1, 3..m)] 
	
	return(mvars_at_matching_time)
}


// get a vector with colnames for preselection dataset
string rowvector getColnames(string scalar id,
							 string scalar mvars)
{
	string rowvector colnames, mvar_names
		
	mvar_names = tokens(mvars)
	
	colnames = (id, "selection_group", "treated", "first_treatment", "last_treatment", mvar_names)

	return(colnames)
}

end
