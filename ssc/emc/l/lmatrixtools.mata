*! Part of package matrixtools v. 0.24
*! Support: Niels Henrik Bruun, nhbr@ph.au.dk
*! 2019-01-30 > BUG \resizebox{\textwidth}{!}{" removed from nhb_mt_mata_string_matrix_styled()

*TODO nhb_mt_labelmatrix.as_stringmatrix()

*2018-10-09 > BUG nhb_mc_percentiles(): When "data = select(values, values :< .)" returns J(0,0,.) code were run
*2018-10-09 > nhb_sae_summary_row() now returns a class nhb_mt_labelmatrix object
*2018-10-09 > nhb_mt_labelmatrix::add_sideways() added
*2018-09-24 > nhb_sae_summary_row() added optionally smoothed data
*2018-09-24 > nhb_sae_summary_row() now calculates centiles based on formulas from -centiles- instead of -summarize-
*2018-09-21 > nhb_mc_smoothed_minmax()
*2018-09-20 > nhb_mc_smoothed_data() added
*2018-09-20 > nhb_mc_percentiles() added optionally smoothed data
*2018-09-20 > Argument smooth (smothing ordered values for calculations) added to nhb_sae_summary_row(). 
*2018-08-20 > nhb_sae_subselect() added
*2018-08-06 > nhb_mt_labelmatrix::hide_small() do nothing when limit is zero or negative
*2018-06-26 > nhb_muf_tokensplit() added
*2018-06-03 > nhb_List() extended
*2018-06-03 > nhb_mt_labelmatrix::clear() added
*2018-06-03 > nhb_mt_labelmatrix::empty() added 
*2018-06-03 > nhb_mt_labelmatrix::append() added
*2018-06-03 > nhb_mt_labelmatrix::regex_select() added
*2018-05-16 > nhb_mc_post_ci_table() added
*2018-01-09 > nhb_sae_markrows() modified
*2017-12-07 > Added class nhb_List()
*2017-12-07 > Added nhb_fp_map() and nhb_fp_reduce()
*2017-12-07 > Option to return created varnames in nhb_sae_addvars()
*2017-12-03 > modified nhb_sae_stored_scalars()
*2017-11-07 > Added nhb_msa_unab()
*2017-10-21 > Added nhb_mc_predictions()
*2017-10-21 > Added class nhb_mc_splines()
*2017-10-21 > Added nhb_mc_percentiles()
*2017-09-29 > nhb_sae_labelsof() handling non labelled values and missing values
*2017-09-29 > nhb_sae_unique_values() strictly mata and handling missing values
*2017-09-26 > nhb_sae_summary_row() returns number of nonmissing rows for string values. Consistency with numbers
*2017-09-26 > nhb_sae_summary_row() returns .m when no value is found
*2017-09-26 > nhb_sae_num_scalar() returns .m when no value is found
*2017-09-21 > nhb_sae_unique_values() modified to handle non existing variables
*2017-09-21 > nhb_mt_mata_string_matrix_styled(): default html table print split into thead og tbody
*2017-09-19 > Hide missings in nhb_mt_labelmatrix::print()
*2017-07-26 > Problem with . and : in nhb_sae_summary_row() in variable labels solved for version 14 and up
*2017-07-17 Bug in nhb_msa_variable_description() and nhb_mt_matrix_v_sep() regarding value labels fixed
*2017-06-09 bugfix when repeating basetable after style md
*2017-06-09 latex tablefit in nhb_mt_mata_string_matrix_styled
*2017-01-06 class nhb_mt_chi2tabulate added
*2017-01-06 class nhb_mt_labelmatrix added
*2016-12-27 created, revised from previous code

version 12.1

********************************************************************************
*** Matrix utility classes *****************************************************
********************************************************************************
mata:
	class nhb_mt_labelmatrix
	{
		private:
			string colvector coleq, colnm, roweq, rownm
			real matrix mat
			void new()
			string colvector duplicate_strip()
			real matrix hide_small()
		public:
			column_equations()
			column_names()
			row_equations()
			row_names()
			values()
			void from_matrix()
			void to_matrix()
			void from_labelmatrix()
			void print()
			class nhb_mt_labelmatrix scalar regex_select()
			void append()
			void add_sideways()
			real scalar empty()
			void clear()
		//TODO: sort, sorted
	}

		void nhb_mt_labelmatrix::new()
		{
			this.clear()
		}
		
		string colvector nhb_mt_labelmatrix::duplicate_strip(colvector x)
		{
			real scalar R
			real colvector slct
			string colvector strx
			
			strx = isreal(x) ? strofreal(x) : x
			R = rows(strx)
			if ( R > 1 ) {
				strx = strx :* (slct = 1 \ strx[2::R] :!= strx[1::(R-1)]) + "" :* slct
			}
			return(strx) 
		}
		
		real matrix nhb_mt_labelmatrix::hide_small(real matrix mat, real scalar limit)
			return(limit > 0 ? mat :/ (mat :>= limit) : mat)
		
		function nhb_mt_labelmatrix::column_equations(|colvector strvec)
		{
			real scalar R

			strvec = isreal(strvec) ? strofreal(strvec) : strvec
			if ( this.mat != J(0,0,.) ) {
				R = cols(this.mat)
				if ( strvec != J(0, 1, "") ) {
					if ( R <= rows(strvec) ) this.coleq = strvec[1..R]
					else this.coleq = nhb_mt_resize_matrix(strvec, R, 1)
				} else {
					if ( this.coleq == J(0,0,"") ) {
						this.coleq = J(R, 1, "")
					} else {
						if ( R <= rows(this.coleq) ) {
							this.coleq = this.coleq[1..R]
						} else {
							this.coleq = nhb_mt_resize_matrix(this.coleq, R, 1)
						}
					}
					return(this.coleq) 
				}
			}
		}
		
		function nhb_mt_labelmatrix::column_names(|colvector strvec)
		{
			real scalar R
			
			strvec = isreal(strvec) ? strofreal(strvec) : strvec
			if ( this.mat != J(0,0,.) ) {
				R = cols(this.mat)
				if ( strvec != J(0, 1, "") ) {
					if ( R <= rows(strvec) ) this.colnm = strvec[1..R]
					else this.colnm = nhb_mt_resize_matrix(strvec, R, 1)
				} else {
					if ( this.colnm == J(0,0,"") ) {
						this.colnm = J(R, 1, "")
					} else {
						if ( R <= rows(this.colnm) ) {
							this.colnm = this.colnm[1..R]
						} else {
							this.colnm = nhb_mt_resize_matrix(this.colnm, R, 1)
						}
					}
					return(this.colnm) 
				}
			}
		}
		
		function nhb_mt_labelmatrix::row_equations(|colvector strvec)
		{
			real scalar R
			
			strvec = isreal(strvec) ? strofreal(strvec) : strvec
			if ( this.mat != J(0,0,.) ) {
				R = rows(this.mat)
				if ( strvec != J(0, 1, "") ) {
					if ( R <= rows(strvec) ) this.roweq = strvec[1..R]
					else this.roweq = nhb_mt_resize_matrix(strvec, R, 1)
				} else {
					if ( this.roweq == J(0,0,"") ) {
						this.roweq = J(R, 1, "")
					} else {
						if ( R <= rows(this.roweq) ) {
							this.roweq = this.roweq[1..R]
						} else {
							this.roweq = nhb_mt_resize_matrix(this.roweq, R, 1)
						}
					}
					return(this.roweq) 
				}
			}
		}
		
		function nhb_mt_labelmatrix::row_names(|colvector strvec)
		{
			real scalar R
			
			strvec = isreal(strvec) ? strofreal(strvec) : strvec
			if ( this.mat != J(0,0,.) ) {
				R = rows(this.mat)
				if ( strvec != J(0, 1, "") ) {
					if ( R <= rows(strvec) ) this.rownm = strvec[1..R]
					else this.rownm = nhb_mt_resize_matrix(strvec, R, 1)
				} else {
					if ( this.rownm == J(0,0,"") ) {
						this.rownm = J(R, 1, "")
					} else {
						if ( R <= rows(this.rownm) ) {
							this.rownm = this.rownm[1..R]
						} else {
							this.rownm = nhb_mt_resize_matrix(this.rownm, R, 1)
						}
					}
					return(this.rownm) 
				}
			}
		}
		
		function nhb_mt_labelmatrix::values(|real matrix mat)
		{
			if ( mat != J(0, 0, .) ) this.mat = mat
			else return(this.mat)
		}
		
		void nhb_mt_labelmatrix::from_matrix(string scalar matrixname)
		{
			if ( st_matrix(matrixname) != J(0,0,.) ) {
				this.values(st_matrix(matrixname))
				this.column_equations(st_matrixcolstripe(matrixname)[.,1])
				this.column_names(st_matrixcolstripe(matrixname)[.,2])
				this.row_equations(st_matrixrowstripe(matrixname)[.,1])
				this.row_names(st_matrixrowstripe(matrixname)[.,2])
			}
		}
		
		void nhb_mt_labelmatrix::to_matrix(string scalar matrixname,| real scalar replace)
		{
			if ( this.mat != J(0,0,.) ) {
				if ( replace == 0 | replace == . ) replace = (st_matrix(matrixname) == J(0,0,.))
				if ( replace ) {
					st_matrix(matrixname, this.values())
					st_matrixcolstripe(matrixname,  abbrev((this.column_equations(), this.column_names()), 32))
					st_matrixrowstripe(matrixname,  abbrev((this.row_equations(), this.row_names()), 32))
				}
			}
		}
		
		void nhb_mt_labelmatrix::from_labelmatrix(class nhb_mt_labelmatrix scalar m)
		{
			if ( m.values() != J(0,0,.) ) {
				this.mat = m.values()
				this.coleq = m.column_equations()
				this.colnm = m.column_names()
				this.roweq = m.row_equations()
				this.rownm = m.row_names()
			}
		}
		
		void nhb_mt_labelmatrix::print(|string scalar style,
								real matrix decimalwidth,
								real scalar duplicate_strip,
								real scalar hidesmall,
								string scalar caption,
								string scalar top, 
								string scalar undertop, 
								string scalar bottom,
								string scalar savefile, 
								real scalar overwrite
								)
		{
			real scalar R, C, hh
			string colvector roweq, rownm, coleq, colnm, lines
			string matrix m, justify
			
			if ( this.mat != J(0,0,.) ) {
				R = rows(this.mat)
				C = cols(this.mat)
				decimalwidth = (decimalwidth == J(0,0,.) ? 2 :decimalwidth)
				if ( hidesmall < . ) {
					m = nhb_mt_format_real_matrix(hide_small(this.mat, hidesmall), decimalwidth)
				} else {
					m = nhb_mt_format_real_matrix(this.mat, decimalwidth)
				}
				m = m :* (this.mat :< .)
				justify = ""
				roweq = this.row_equations()
				rownm = this.row_names()
				coleq = this.column_equations()
				colnm = this.column_names()
				if ( duplicate_strip ) {
					if ( roweq != J(R, 1, "") ) roweq = duplicate_strip(roweq)
					if ( coleq != J(C, 1, "") ) coleq = duplicate_strip(coleq)
				}
				if ( rownm != J(R, 1, "") ) {
					m = rownm, m
					justify = "-", justify
					coleq = "" \ coleq
					colnm = "" \ colnm
				}
				if ( roweq != J(R, 1, "") ) {
					m = roweq, m
					justify = "-", justify
					coleq = "" \ coleq
					colnm = "" \ colnm
				}
				R = rows(coleq)
				if ( coleq != J(R, 1, "") ) {
					m = coleq' \ colnm' \ m
					hh = 2
				} else {
					m = colnm' \ m
					hh = 1
				}
				lines = nhb_mt_mata_string_matrix_styled(	m, 
															style, 
															justify,


															hh,
															caption, 
															top, 
															undertop,
															bottom, 
															savefile, 
															overwrite
															) // Assignment just to prevent list of lines being printed
			} else {
				printf("{error:Nothing to print}")
			}
		}
		
		class nhb_mt_labelmatrix scalar nhb_mt_labelmatrix::regex_select(
			string scalar str_regex,
			| real scalar keep,	// default keep
			real scalar names,	// default names
			real scalar row		// default row
			)
		{
			real vector slct, slct_values
			class nhb_mt_labelmatrix scalar out
			
			if ( !names & row ) slct_values = this.row_equations()
			else if ( names & row ) slct_values = this.row_names()
			else if ( !names & !row ) slct_values = this.column_equations()
			else if ( names & !row ) slct_values = this.column_names()

			slct = regexm(slct_values, str_regex)
			if ( !keep ) slct = !slct
			if ( row ) {
				out.values(select(this.values(), slct))
				out.row_equations(select(this.row_equations(), slct))
				out.row_names(select(this.row_names(), slct))
				out.column_equations(this.column_equations())
				out.column_names(this.column_names())
			} else {
				out.values(select(this.values()', slct)')
				out.row_equations(this.row_equations())
				out.row_names(this.row_names())
				out.column_equations(select(this.column_equations(), slct))
				out.column_names(select(this.column_names(), slct))
			}
			return(out)
		}
		
		real scalar nhb_mt_labelmatrix::empty() return(this.mat == J(0,0,.))

		void nhb_mt_labelmatrix::append(class nhb_mt_labelmatrix scalar m)
		{
			colvector eq, nm
		
			eq = this.row_equations()
			nm = this.row_names()
			this.values(this.values() \ m.values())
			this.row_equations(eq \ m.row_equations())
			this.row_names(nm \ m.row_names())
		}

		void nhb_mt_labelmatrix::add_sideways(class nhb_mt_labelmatrix scalar m)
		{
			colvector eq, nm
		
			eq = this.column_equations()
			nm = this.column_names()
			this.values( (this.values(), m.values()) )
			this.column_equations(eq \ m.column_equations())
			this.column_names(nm \ m.column_names())
		}
		
		void nhb_mt_labelmatrix::clear()
		{
			this.mat = J(0,0,.)
			this.coleq = this.colnm = J(0,0,"")
			this.roweq = this.rownm = J(0,0,"")
		}
		
	class nhb_mt_chi2tabulate
	{
		private:
			real scalar isset
			real scalar showcode, addquietly
			void new()
			class nhb_mt_labelmatrix scalar counts, tests, greeks
		public:
			void set()
			void verbose()
			class nhb_mt_labelmatrix scalar tests()
			class nhb_mt_labelmatrix scalar counts()
			class nhb_mt_labelmatrix scalar greeks()
			class nhb_mt_labelmatrix scalar counts_with_totals()
			class nhb_mt_labelmatrix scalar expected()
			class nhb_mt_labelmatrix scalar proportions()
			class nhb_mt_labelmatrix scalar row_proportions()
			class nhb_mt_labelmatrix scalar column_proportions()
			class nhb_mt_labelmatrix scalar pearson_chisquare_parts()
			class nhb_mt_labelmatrix scalar likelihood_ratio_chisquare_parts()
	}
	
		void nhb_mt_chi2tabulate::new()
		{
			this.isset = 0
			this.showcode = 0
			this.addquietly = 1
			this.counts = nhb_mt_labelmatrix()
			this.tests = nhb_mt_labelmatrix()
			this.greeks = nhb_mt_labelmatrix()
		}
		
		void nhb_mt_chi2tabulate::set(	string scalar var1, 
										| string scalar var2,
										string scalar str_if, 
										string scalar str_in, 
										string scalar str_weight,
										real scalar exactno,
										real scalar missing,
										real scalar no_vlbl
										)	
		{
			string scalar strmiss, statacode, exact, vlbl, lbl
			real scalar rc, f, chi2, p, chi2_lr, p_lr, CramersV, gamma, ase_gam, taub, ase_taub, p_exact
			
			strmiss = any(missing :== (0, .)) ? "" : "missing"
			if ( var2 == "" ) {
				statacode = sprintf("tabulate %s %s %s %s, matcell(__mc) matrow(__lblr) %s", 
								var1, str_if, str_in, str_weight, strmiss)
			} else {
				exact = ( exactno == 0 | exactno == . ? "" : sprintf("exact(%f)", exactno)) 
				statacode = sprintf("tabulate %s %s %s %s %s, %s all matcell(__mc) matrow(__lblr) matcol(__lblc) %s", 
								var1, var2, str_if, str_in, str_weight, exact, strmiss)
			}
			rc = nhb_sae_logstatacode(statacode, this.showcode, this.addquietly)
			this.isset = 0
			if ( !rc & st_matrix("__mc") != J(0,0,.) ) {
				this.isset = 1
				this.counts.values(st_matrix("__mc"))
				if ( no_vlbl != 0 & no_vlbl != . ) {
					this.counts.row_equations(var1)
					this.counts.row_names(st_matrix("__lblr"))
					if (var2 != "") {
						this.counts.column_equations(var2)
						this.counts.column_names(st_matrix("__lblc")')
					} else {
						this.counts.column_names("Frequency")
					}
				} else {
					lbl = (lbl=st_varlabel(var1)) == "" ? var1 : lbl
					this.counts.row_equations(lbl)
					this.counts.row_names(nhb_sae_labelsof(var1, st_matrix("__lblr")')')
					if (var2 != "") {
						lbl = (lbl=st_varlabel(var2)) == "" ? var2 : lbl
						this.counts.column_equations(lbl)
						this.counts.column_names(nhb_sae_labelsof(var2, st_matrix("__lblc"))')
					} else {
						this.counts.column_names("Frequency")
					}
				}
				if ( var2 != "" ) {
					this.isset = 2
					//tests
					f = (nhb_sae_num_scalar("r(r)") - 1) * (nhb_sae_num_scalar("r(c)") - 1)
					chi2 = nhb_sae_num_scalar("r(chi2)")
					p = nhb_sae_num_scalar("r(p)")
					chi2_lr = nhb_sae_num_scalar("r(chi2_lr)")
					p_lr = nhb_sae_num_scalar("r(p_lr)")
					if ( exact == "" ) {
						this.tests.values((chi2, f, p \ chi2_lr, f, p_lr))
						this.tests.row_names(("Pearson", "LR")')
					} else {
						p_exact = nhb_sae_num_scalar("r(p_exact)")
						this.tests.values((chi2, f, p \ chi2_lr, f, p_lr \ ., ., p_exact))
						this.tests.row_names(("Pearson", "LR", "Fisher's exact")')
					}
					this.tests.column_names(("Test", "f", "P")')
					//greeks
					CramersV = nhb_sae_num_scalar("r(CramersV)")
					gamma = nhb_sae_num_scalar("r(gamma)")
					ase_gam = nhb_sae_num_scalar("r(ase_gam)")
					taub = nhb_sae_num_scalar("r(taub)")
					ase_taub = nhb_sae_num_scalar("r(ase_taub)")
					this.greeks.values((CramersV, . \ gamma, ase_gam \ taub, ase_taub))
					this.greeks.column_names(("Estimate", "ASE")')
					this.greeks.row_names(("Cramers V", "Gamma", "Kendalls tau b")')
				}
			} 
		}
		
		void nhb_mt_chi2tabulate::verbose(real scalar showcode, real scalar addquietly)
		{
			this.showcode = showcode
			this.addquietly = addquietly
		}
		
		class nhb_mt_labelmatrix scalar nhb_mt_chi2tabulate::tests()
		{
			return(this.tests)
		}

		class nhb_mt_labelmatrix scalar nhb_mt_chi2tabulate::counts()
		{
			return(this.counts)
		}

		class nhb_mt_labelmatrix scalar nhb_mt_chi2tabulate::greeks()
		{
			return(this.greeks)
		}

		class nhb_mt_labelmatrix scalar nhb_mt_chi2tabulate::counts_with_totals()
		{
			class nhb_mt_labelmatrix scalar m
			
			if ( this.isset ) {
				m = this.counts
				if ( this.isset == 2 ) {
					m.values( (m.values(), rowsum(m.values())) )
					m.column_equations( (this.counts.column_equations() \ "") )
					m.column_names( (this.counts.column_names() \ "Total") )
				}
				m.values( (m.values() \ colsum(m.values())) )
				m.row_equations( this.counts.row_equations() \ "" )
				m.row_names( this.counts.row_names() \ "Total" )
			}
			return(m)
		}

		class nhb_mt_labelmatrix scalar nhb_mt_chi2tabulate::expected()
		{
			real matrix vm
			class nhb_mt_labelmatrix scalar lm
		
			if ( this.isset == 2 ) {
				lm = this.counts_with_totals()
				vm = lm.values()
				lm.values(vm[., cols(vm)] # vm[rows(vm), .] :/ vm[rows(vm), cols(vm)])
			}
			return(lm)
		}

		class nhb_mt_labelmatrix scalar nhb_mt_chi2tabulate::proportions()
		{
			real matrix vm
			class nhb_mt_labelmatrix scalar lm
		
			if ( this.isset ) {
				lm = this.counts_with_totals()
				vm = lm.values()
				lm.values(vm :/ vm[rows(vm), cols(vm)])
				if ( this.isset == 1 ) lm.column_names("%")
			}
			return(lm)
		}

		class nhb_mt_labelmatrix scalar nhb_mt_chi2tabulate::row_proportions()
		{
			real matrix vm
			class nhb_mt_labelmatrix scalar lm
		
			if ( this.isset == 2 ) {
				lm = this.counts_with_totals()
				vm = lm.values()
				lm.values(vm :/ vm[., cols(vm)])
			}
			return(lm)
		}

		class nhb_mt_labelmatrix scalar nhb_mt_chi2tabulate::column_proportions()
		{
			real matrix vm
			class nhb_mt_labelmatrix scalar lm
		
			if ( this.isset == 2 ) {
				lm = this.counts_with_totals()
				vm = lm.values()
				lm.values(vm :/ vm[rows(vm), .])
			}
			return(lm)
		}

		class nhb_mt_labelmatrix scalar nhb_mt_chi2tabulate::pearson_chisquare_parts()
		{
			real scalar R, C
			real matrix vm, em
			class nhb_mt_labelmatrix scalar lm
		
			if ( this.isset == 2 ) {
				lm = this.counts_with_totals()
				vm = lm.values()
				R = rows(vm) - 1
				C = cols(vm) - 1
				vm = vm[1..R, 1..C]
				em = this.expected().values()[1..R, 1..C]
				vm = (vm - em) :^2 :/ em
				vm = vm, rowsum(vm)
				vm = vm \ colsum(vm)
				lm.values(vm)
				return(lm)
			}
			return(lm)
		}

		class nhb_mt_labelmatrix scalar nhb_mt_chi2tabulate::likelihood_ratio_chisquare_parts()
		{
			real scalar R, C
			real matrix vm, em
			class nhb_mt_labelmatrix scalar lm
		
			if ( this.isset == 2 ) {
				lm = this.counts_with_totals()
				vm = lm.values()
				R = rows(vm) - 1
				C = cols(vm) - 1
				vm = vm[1..R, 1..C]
				em = this.expected().values()[1..R, 1..C]
				vm =  2 :* vm :* ln(vm :/ em)
				vm = vm, rowsum(vm)
				vm = vm \ colsum(vm)
				lm.values(vm)
				return(lm)
			}
			return(lm)
		}
		
		
	real matrix nhb_sae_collapse(real matrix keys, 
								|real colvector marker,
								 real colvector values)
	{
		real scalar r, R, C, uR, uc
		real matrix uniq 
		real colvector summary
		real rowvector uval

		if ( marker != J(0,1,.) ) keys = keys, marker
		R = rows(keys)
		C = cols(keys)
		
		uniq = sort(uniqrows(keys), 1..C)
		uR = rows(uniq)
		summary = J(uR, 1, 0)
		uc = 1
		uval = uniq[uc, .]

		if ( values == J(0,1,.) ) values = J(R, 1, 1)
		keys = keys, values
		keys = sort(keys, 1..C)
		
		for(r=1;r<=R;r++){
			if ( uval != keys[r, 1..C] ) {
				uc++
				uval = uniq[uc, .]
			}
			summary[uc] = summary[uc] + keys[r, C+1]
		}
		if ( marker != J(0,1,.) ) {
			summary = summary :* (uniq[.,C] :!= 0)
			uniq = uniq[., 1..C-1]
			return(nhb_sae_collapse(uniq, J(0,1,.), summary))
		}
		return((uniq, summary))
	}

	
	class nhb_mt_tabulate
	{
		private:
			real scalar isset
			void new()
			real colvector validate_varname()
			class nhb_mt_labelmatrix scalar counts
		public:
			void set()
			class nhb_mt_labelmatrix scalar counts()
			class nhb_mt_labelmatrix scalar counts_with_totals()
			class nhb_mt_labelmatrix scalar expected()
			class nhb_mt_labelmatrix scalar proportions()
			class nhb_mt_labelmatrix scalar row_proportions()
			class nhb_mt_labelmatrix scalar column_proportions()
			class nhb_mt_labelmatrix scalar pearson_chisquare_parts()
			class nhb_mt_labelmatrix scalar likelihood_ratio_chisquare_parts()
			class nhb_mt_labelmatrix scalar tests()
	}

		void nhb_mt_tabulate::new()
			{
				this.isset = 0
				this.counts = nhb_mt_labelmatrix()
			}
		
		real colvector nhb_mt_tabulate::validate_varname(string scalar varname)
		{
			real colvector values
		
			if ( varname == "" ) values = J(0, 1, .)
			else if ( & _st_varindex(varname) == . ) values = J(0, 1, .) 
			else if ( !st_isnumvar(varname) ) values = J(0, 1, .)
			else values = st_data(., varname)
			return( values )
		}
		
		void nhb_mt_tabulate::set(	string scalar row_vname, 
									| string scalar col_vname,
									string scalar str_if, 
									string scalar str_in, 
									string scalar var_weight,
									real scalar drop_missings/*,
									real scalar no_vlbl,
									real scalar hidesmall*/
									)	
		{
			real scalar r, c, v, R, C, V
			real colvector rvalues, cvalues, marker, weights
			string scalar var_ifin
			string colvector lbls
			real matrix keys, m, values
			
			keys = this.validate_varname(row_vname)
			cvalues = this.validate_varname(col_vname)
			if ( cvalues != J(0, 1, .) ) keys = keys, cvalues
			if ( str_if != "" | str_in != "" ) {
				var_ifin = nhb_sae_markrows(str_if, str_in)
				marker = this.validate_varname(var_ifin)
				//keys = keys, marker
				st_dropvar(var_ifin)
			} else marker = J(0, 1, .)
			weights = this.validate_varname(var_weight)
			m = nhb_sae_collapse(keys, marker, weights)
			rvalues = uniqrows(m[.,1])
			if ( drop_missings ) rvalues = select(rvalues, rvalues :< .)
			if ( col_vname != "" ) {
				cvalues = uniqrows(m[.,2])
				if ( drop_missings ) cvalues = select(cvalues, cvalues :< .) 
				V = rows(m)
				r = 1
				c = 1
				R = rows(rvalues)
				C = rows(cvalues)
				values = J(R, C, 0)
				for(v=1;v<=V;v++){
					if ( m[v,1] != rvalues[r] ) r++
					if ( r > R ) break
					for(c=1;c<=C;c++) {
						if ( m[v,2] == cvalues[c] ) {
							values[r,c] = m[v,3]
							break
						}
					}
				}
				this.counts.values(values)
				this.counts.row_names(nhb_sae_labelsof(row_vname)')
				this.counts.column_names(nhb_sae_labelsof(col_vname)')
				this.isset = 2
			} else {
				this.counts.values(m[., 2])
				this.counts.row_names(nhb_sae_labelsof(row_vname)')
				this.counts.column_names("n")
				this.isset = 1
			}
		}

		class nhb_mt_labelmatrix scalar nhb_mt_tabulate::counts()
		{
			return(this.counts)
		}

		class nhb_mt_labelmatrix scalar nhb_mt_tabulate::counts_with_totals()
		{
			class nhb_mt_labelmatrix scalar m
			
			if ( this.isset ) {
				m = this.counts
				if ( this.isset == 2 ) {
					m.values( (m.values(), rowsum(m.values())) )
					m.column_equations( (this.counts.column_equations() \ "") )
					m.column_names( (this.counts.column_names() \ "Total") )
				}
				m.values( (m.values() \ colsum(m.values())) )
				m.row_equations( this.counts.row_equations() \ "" )
				m.row_names( this.counts.row_names() \ "Total" )
			}
			return(m)
		}

		class nhb_mt_labelmatrix scalar nhb_mt_tabulate::expected()
		{
			real matrix vm
			class nhb_mt_labelmatrix scalar lm
		
			if ( this.isset == 2 ) {
				lm = this.counts_with_totals()
				vm = lm.values()
				lm.values(vm[., cols(vm)] # vm[rows(vm), .] :/ vm[rows(vm), cols(vm)])
			}
			return(lm)
		}

		class nhb_mt_labelmatrix scalar nhb_mt_tabulate::proportions()
		{
			real matrix vm
			class nhb_mt_labelmatrix scalar lm
		
			if ( this.isset ) {
				lm = this.counts_with_totals()
				vm = lm.values()
				lm.values(vm :/ vm[rows(vm), cols(vm)])
				if ( this.isset == 1 ) lm.column_names("%")
			}
			return(lm)
		}

		class nhb_mt_labelmatrix scalar nhb_mt_tabulate::row_proportions()
		{
			real matrix vm
			class nhb_mt_labelmatrix scalar lm
		
			if ( this.isset == 2 ) {
				lm = this.counts_with_totals()
				vm = lm.values()
				lm.values(vm :/ vm[., cols(vm)])
			}
			return(lm)
		}

		class nhb_mt_labelmatrix scalar nhb_mt_tabulate::column_proportions()
		{
			real matrix vm
			class nhb_mt_labelmatrix scalar lm
		
			if ( this.isset == 2 ) {
				lm = this.counts_with_totals()
				vm = lm.values()
				lm.values(vm :/ vm[rows(vm), .])
			}
			return(lm)
		}

		class nhb_mt_labelmatrix scalar nhb_mt_tabulate::pearson_chisquare_parts()
		{
			real scalar R, C
			real matrix vm, em
			class nhb_mt_labelmatrix scalar lm
		
			if ( this.isset == 2 ) {
				lm = this.counts_with_totals()
				vm = lm.values()
				R = rows(vm) - 1
				C = cols(vm) - 1
				vm = vm[1..R, 1..C]
				em = this.expected().values()[1..R, 1..C]
				vm = (vm - em) :^2 :/ em
				vm = vm, rowsum(vm)
				vm = vm \ colsum(vm)
				lm.values(vm)
				return(lm)
			}
			return(lm)
		}

		class nhb_mt_labelmatrix scalar nhb_mt_tabulate::likelihood_ratio_chisquare_parts()
		{
			real scalar R, C
			real matrix vm, em
			class nhb_mt_labelmatrix scalar lm
		
			if ( this.isset == 2 ) {
				lm = this.counts_with_totals()
				vm = lm.values()
				R = rows(vm) - 1
				C = cols(vm) - 1
				vm = vm[1..R, 1..C]
				em = this.expected().values()[1..R, 1..C]
				vm =  2 :* vm :* ln(vm :/ em)
				vm = vm, rowsum(vm)
				vm = vm \ colsum(vm)
				lm.values(vm)
				return(lm)
			}
			return(lm)
		}
		
		class nhb_mt_labelmatrix scalar nhb_mt_tabulate::tests()
		{
			real scalar R, C, pchi2, lrchi2, f
			real matrix vm
			class nhb_mt_labelmatrix scalar lm
			
			if ( this.isset == 2 ) {
				lm.values(J(2,3,.))
				lm.row_names(("Pearson", "LR")')
				lm.column_names(("Test", "f", "P")')
				vm = this.counts().values()
				R = rows(vm) + 1
				C = cols(vm) + 1
				pchi2 = this.pearson_chisquare_parts().values()[R,C]
				lrchi2 = this.likelihood_ratio_chisquare_parts().values()[R,C]
				if ( (R = sum(rowsum(vm) :> 0)) & (C = sum(colsum(vm) :> 0)) ) {
					f = (R - 1) * (C - 1)
					if ( f > 0 ) {
						(lm.values())[1,1] = pchi2
						(lm.values())[2,1] = lrchi2
						(lm.values())[1,2] = f
						(lm.values())[2,2] = f
						(lm.values())[1,3] = chi2tail(f, pchi2)
						(lm.values())[2,3] = chi2tail(f, lrchi2)
					}
				}
			}
			return(lm)
		}
end


/*******************************************************************************
*** Styling mata string matrices ***********************************************
*******************************************************************************/
mata:
	function nhb_mt_mata_string_matrix_styled(	string matrix M,
												string scalar style,
												string matrix justify,
												real scalar headerheight,	// must be 1 or 2
												string scalar caption,
												string scalar top, 
												string scalar undertop, 
												string scalar bottom,
												string scalar savefile,
												real scalar overwrite
												)
	{		
		real scalar rc, r, c, R, C, fh
		real rowvector cw
		string vector lines
		string matrix tmp, special_chars

		if ( ! any(style :== ("", "smcl", "csv", "html", "htm", "latex", "tex", "md")) ) {
			printf(`"{error:The value of "style" must be one of smcl, csv, html, latex or tex, or md. Not %s}\n"', style)
			printf(`"{error:"style" is set to smcl}\n"')
			style = "smcl"
		}
		if ( ! any(headerheight :== (1,2)) ) {
			printf(`"{error: The value of "headerheight" must be 1 or 2, not %f}\n"', headerheight)
			printf(`"{error:"headerheight" is set to 1}\n"')
			headerheight = 1
		}
		M = nhb_mt_justify_string_matrix(M, 0, justify)
		special_chars = J(0, 2, "")
		R = rows(M)
		C = cols(M)
		cw = strlen(M[1,.])
		
		/** smcl **************************************************************/
		if ( style == "" | style == "smcl" ) {
			if ( top == "" ) top = (sum(cw[1..C] :+ 2) - 2) * "{c -}"
			if ( caption != "" ) top = sprintf("{bf:%s}:", caption) \ top
			if ( undertop == "" ) undertop = (sum(cw[1..C] :+ 2) - 2) * "{c -}"
			if ( bottom == "" ) bottom = (sum(cw[1..C] :+ 2) - 2) * "{c -}"
			lines = nhb_mt_matrix_v_sep(M, "", "  ", "")
		/** csv ***************************************************************/
		} else if ( style == "csv" ) {
			top = ""
			undertop = ""
			bottom = ""
			lines = nhb_mt_matrix_v_sep(M, "", ";", "")
		/** html **************************************************************/
		} else if ( style == "html" | style == "htm" ) {
			if ( top == "" ) top = `"<table width="95%">"' \ `"<thead>"'
			if (caption != "" ) top = top \ sprintf("<caption>%s</caption>", caption)
			undertop = `"</thead>"' \ `"<tbody>"'
			if ( bottom == "" ) bottom = `"</tbody>"' \ "</table>"
			tmp = editvalue(justify, "", `"<td style="text-align:right">"')
			tmp = editvalue(tmp, "-", `"<td style="text-align:left">"')
			tmp = editvalue(tmp, "~", `"<td style="text-align:center">"')

			lines = nhb_mt_matrix_v_sep(M, 
										"<tr>" :+ tmp[1,1], 
										"</td>" :+ tmp[., 2..cols(tmp)], 
										"</td></tr>")
			lines[1..headerheight] = subinstr(lines[1..headerheight], "td", "th")
		/** latex/tex *********************************************************/
		} else if ( style == "latex" | style == "tex" ) {
			// http://texblog.net/latex-archive/uncategorized/symbols/
			// backslash \ and ampersand & not included due to tables
			special_chars = "#", "$", "%", "_", "{", "}", "^"
			special_chars = special_chars', "\" :+ special_chars'
			if ( top == "" ) {
				top = "\begin{table}[h]" \ "\centering"
				if ( caption != "" ) {
					top = top \ sprintf("\caption{%s}", caption)
				}
				tmp = editvalue(justify, "", "r")
				tmp = editvalue(tmp, "-", "l")
				tmp = editvalue(tmp, "~", "c")
				tmp = nhb_mt_matrix_v_sep(tmp, "", "", "")
				top = top \ sprintf("\begin{tabular}{%s}", tmp[1,1]) \ "\hline" \ "\hline"
			}
			if ( undertop == "" ) undertop = "\hline"
			if ( bottom == "" ) bottom = "\hline" \ "\hline" \ "\end{tabular}" \ "\end{table}"
			lines = nhb_mt_matrix_v_sep(M, "", " & ", " \\")
		/** md ****************************************************************/
		} else if ( style == "md" ) {
			if ( headerheight == 2 ) {	// Q&D: md do not show/handle coleq
				headerheight = 1
				M = M[2..R, .]
				R = R - 1
			}
			// Left align strip columns
			M = nhb_mt_resize_matrix(nhb_sae_str_mult_matrix("  ", justify :== ""), R, C) :+ M
			M = M :+ nhb_mt_resize_matrix(nhb_sae_str_mult_matrix("  ", justify :== "-"), R, C)

			lines = nhb_mt_matrix_v_sep(M, "", 4*" ", "")
			//lines[headerheight+2..R] = lines[headerheight+2..R] :+ "\n"
			R = rows(lines)
			tmp = lines[1]
			for(r=2;r<=R;r++) {
				tmp = tmp \ lines[r] 
				if ( r < R ) tmp = tmp \ ""
			}
			lines = tmp
			R = rows(lines)
			top = "" \ strlen(lines[1]) * "-"
			if ( undertop == "" ) undertop = nhb_mt_matrix_v_sep((cw :+ 2) :* "-", "", 4*" ", "")
			if ( caption == "" ) {
				bottom = top
			} else {
				bottom = top \ sprintf("Table: %s", caption)
			}
		}
		/** Adding top undertop and bottom and print **************************/
		for(r=1;r<=rows(special_chars);r++) {
			lines = subinstr(lines, special_chars[r,1], special_chars[r,2])
		}
		if ( undertop != "" ) {
			lines = lines[1..headerheight] \ undertop \ lines[headerheight+1..R]
		}
		if ( top != "" ) lines = top \ lines
		if ( bottom != "" ) lines = lines \ bottom
		for(r=1;r<=rows(lines);r++){
			printf("%s\n", lines[r])
		}
		/** save to file ******************************************************/
		if ( savefile != "" ) {
			if ( overwrite ) rc = _unlink(savefile)
			fh = _fopen(savefile, fileexists(savefile) ? "a" : "w")
			if ( fh >= 0 ) {
				for(r=1;r<=rows(lines);r++) fput(fh, lines[r])
				fclose(fh)
			} else {
				printf("{error:fopen error %f}", fh)
			}
		}
		return(lines)
	}
	
	function nhb_mt_resize_matrix(matrix mat, real scalar R, C)
	{
		real scalar tmp
		matrix M
		
		M = mat
		if ( (tmp=cols(M)) < C ) {
			M = M, J(1,C-tmp,M[.,tmp])
		} else {
			M = M[.,1..C]
		}
		if ( (tmp=rows(M)) < R ) {
			M = M \ J(R-tmp,1,M[tmp,.])
		} else {
			M = M[1..R,.]
		}
		M = M[1..R, 1..C]
		return(M)
	}
	
	function nhb_mt_format_real_matrix(	real matrix M, 
										|real matrix decimalwidth
										)
	{
		real scalar R, C
		real matrix integerwidth
		string matrix fmt
		
		R = rows(M)
		C = cols(M)
		
		integerwidth = J(R, C, max(strlen(strofreal(round(M)))))
		decimalwidth = nhb_mt_resize_matrix(decimalwidth, R, C)
		fmt = ("%" :+ strofreal(integerwidth + decimalwidth :+ 1) 
				:+ "." :+ strofreal(decimalwidth) :+ "f")
		return( strofreal(M, fmt) )
	}

	function nhb_mt_justify_string_matrix(	string matrix values, 
											|real rowvector columnwidth, 
											string matrix justify
											)
	{
		real scalar C, R, r, c
		string matrix fmt, justified
		
		if ( args() <= 1 ) columnwidth = colmax(strlen(values))
		if ( args() <= 2 ) justify = ""
		
		R = rows(values)
		C = cols(values)
		
		if ( columnwidth <= 0 ) columnwidth = colmax(strlen(values))
		columnwidth = nhb_mt_resize_matrix(columnwidth, R, C)
		justify = nhb_mt_resize_matrix(justify, R, C)
		fmt = "%" :+ justify :+ strofreal(columnwidth) :+ (stataversion() > 1400 ? "us" : "s")
		justified = J(R, C, "")
		for(c=1; c <= C; c++){
			for(r=1; r <= R; r++){
				justified[r,c] = sprintf(fmt[r,c], values[r,c])
			}
		}
		return(justified) 
	}

	function nhb_mt_matrix_v_sep(	string matrix values, 
									|string scalar first,
									string matrix strseparator, 
									string scalar last
									)
	{
		real scalar c, C
		string rowvector separated
		
		C = cols(values)
		strseparator = nhb_mt_resize_matrix(strseparator, 1, max((C-1, 1)))
		if ( C ) {
			separated = values[., 1]
			for(c=2; c <= C; c++) {
				separated = separated :+ strseparator[c-1] :+ values[., c]
			}
			return(first :+ separated :+ last)
		} else {
			return( J(1,1,"") )
		}
	}
	
	function nhb_mt_matrix_stripe(	string scalar matrixname, 
								real scalar col,
								|real scalar collapse
								)
	{
		real scalar r
		string scalar eq_duplicate_value
		string matrix stripe
	
		if ( args() == 2 ) collapse = 1
		if ( col ) {
			stripe = st_matrixcolstripe(matrixname)
		} else {
			stripe = st_matrixrowstripe(matrixname)
		}
		if ( collapse ) {
			eq_duplicate_value = stripe[1,1]
			for (r=2; r<=rows(stripe); r++) {
				if ( eq_duplicate_value != "" ) {
					if ( eq_duplicate_value == stripe[r,1] ) {
						stripe[r,1] = ""
					} else {
						eq_duplicate_value = stripe[r,1]
					}
				}
			}
		}
		return( col ? stripe' : stripe)
	}
end


/*******************************************************************************
*** Stata api extension ********************************************************
*******************************************************************************/
mata:
	function nhb_sae_logstatacode(	string scalar statacode,
									| real scalar showcode, 
									real scalar addquietly)
	{
		if ( addquietly != 0 | addquietly == . ) statacode = "quietly " + statacode
		if ( !any(showcode :== (0, .)) ) printf("{cmd:. %s}\n", statacode)
		return(_stata(statacode))
	}

	function nhb_sae_num_scalar(string scalar scalarname)
	{
		real scalar value
		value = st_numscalar(scalarname)
		return( value != J(0, 0, .) ? value : . )
	} 
	
	function nhb_sae_stored_scalars(
			string scalar matrixname, 
			|real scalar escalars,
			string scalar filter
			)
	{
		real scalar r, R
		real colvector values
		string scalar r_or_e
		string colvector names
		
		r_or_e = ( escalars == 0 | escalars == . ) ? "r" : "e"
		if ( filter == "" ) filter = "*"
		names = st_dir(r_or_e + "()", "numscalar", filter)
		R = rows(names)
		for(r=1; r<=R; r++) {
			if ( regexm(st_numscalar_hcat(sprintf("%s(%s)", "r", names[r])), "^h") ) {
				names[r] = ""
			}
		}
		names = select(names, names :!= "")
		R = rows(names)		
		values = J(R,1,.)
		for(r=1; r<=R;r++) values[r] = nhb_sae_num_scalar(sprintf("%s(%s)", r_or_e, names[r]))
		if ( !R ) {
			R = 1
			names = "No scalars found"
			values = .
		}
		st_matrix(matrixname, values)
		st_matrixrowstripe(matrixname, (J(R,1,""), names))
		st_matrixcolstripe(matrixname, ("", sprintf("%s scalars", r_or_e)))
	}
	
	class nhb_mt_labelmatrix scalar nhb_sae_summary_row(string scalar variable, 
														string scalar statistics, 
														string scalar matrixname,
														string scalar str_if, 
														string scalar str_in, 
														real scalar ppct,
														real scalar N,
														real scalar smooth_width,
														real scalar hide,
														real scalar nolabel,
														real scalar showcode,
														real scalar addquietly
														)
	{
		string scalar stata_code, varlbl
		string vector stats
		real scalar rc, n, c, C, z, mean, se
		real vector values, tmp, sminmax
		real colvector svalues, pct_tiles
		class nhb_mt_labelmatrix scalar lm

		stats = tokens(subinstr(statistics, ",", " "))
		C = cols(stats)
		values = J(1,C,.)
		stata_code = sprintf("count %s %s", str_if, str_in)
		if ( !(rc=nhb_sae_logstatacode(stata_code, showcode, addquietly)) 
				& hide <= (n=nhb_sae_num_scalar("r(N)")) | !n ) {
			if ( st_isnumvar(variable) ) {
				z = invnormal((100 + ppct) / 200)
				stata_code = sprintf("summarize %s %s %s, detail", variable, str_if, str_in)
				if ( !(rc=nhb_sae_logstatacode(stata_code, showcode, addquietly)) ) {
					if ( smooth_width >= . ) smooth_width = 0
					svalues = st_data(., variable, nhb_sae_markrows(str_if, str_in))
					pct_tiles = nhb_mc_percentiles(svalues, 1::99, smooth_width)[.,2]
					sminmax = nhb_mc_smoothed_minmax(svalues, smooth_width)
					for(c=1;c<=C;c++) {
						if ( regexm(strtrim(strlower(stats[c])), "^[n|count]$") ) {
							values[c] = nhb_sae_num_scalar("r(N)")
						} else if ( regexm(strtrim(strlower(stats[c])), "^range$") ) {
							values[c] = sminmax[2] - sminmax[1]
						} else if ( regexm(strtrim(strlower(stats[c])), "^[var|variance]$") ) {
							values[c] = nhb_sae_num_scalar("r(Var)")
						} else if ( regexm(strtrim(strlower(stats[c])), "^cv$") ) {
							values[c] = nhb_sae_num_scalar("r(sd)") / nhb_sae_num_scalar("r(mean)")
						} else if ( regexm(strtrim(strlower(stats[c])), "^semean$") ) {
							values[c] = nhb_sae_num_scalar("r(sd)") / sqrt(nhb_sae_num_scalar("r(N)"))
						} else if ( regexm(strtrim(strlower(stats[c])), "^median$") ) {
							values[c] = pct_tiles[50]
						} else if ( regexm(strtrim(strlower(stats[c])), "^iqr$") ) {
							values[c] = pct_tiles[75] - pct_tiles[25]
						} else if ( regexm(strtrim(strlower(stats[c])), "^iqi$") ) {
							stats[c] = "iq 25%"
							values[c] = pct_tiles[25]
							if ( c == C ) {
								stats = stats, "iq 75%"
								values = values, pct_tiles[75]
							} else {
								stats = stats[1..c], "iq 75%", stats[c+1..C]
								values = values[1..c], pct_tiles[75], values[c+1..C]
								c++
								C++
							}
						} else if ( regexm(strtrim(strlower(stats[c])), "^idi$") ) {
							stats[c] = "id 10%"
							values[c] = pct_tiles[90] - pct_tiles[10]
							if ( c == C ) {
								stats = stats, "id 90%"
								values[c] = values, pct_tiles[90]
							} else {
								stats = stats[1..c], "id 90%", stats[c+1..C]
								values = values[1..c], pct_tiles[90], values[c+1..C]
								c++
								C++
							}
						} else if ( regexm(strtrim(strlower(stats[c])), "^ci$|^ci\((.*)\)$") ) {
							stats[c] = sprintf("ci%2.0f%% lb", ppct)
							if ( regexs(0) != "ci" ) {
							} else {
								mean = nhb_sae_num_scalar("r(mean)")
								se = nhb_sae_num_scalar("r(sd)") / sqrt(nhb_sae_num_scalar("r(N)"))
							}
							values[c] = mean - z * se
							if ( c == C ) {
								stats = stats, sprintf("ci%2.0f%% ub", ppct)	
								values = values, nhb_sae_num_scalar("r(mean)") + z * se
							} else {
								stats = stats[1..c], sprintf("ci%2.0f%% ub", ppct), stats[c+1..C]
								values = values[1..c], nhb_sae_num_scalar("r(mean)") + z * se, values[c+1..C]
								c++
								C++
							}
						} else if ( regexm(strtrim(strlower(stats[c])), "^pi$") ) {
							stats[c] = sprintf("pi%2.0f%% lb", ppct)
							values[c] = nhb_sae_num_scalar("r(mean)") - z * nhb_sae_num_scalar("r(sd)")
							if ( c == C ) {
								stats = stats, sprintf("pi%2.0f%% ub", ppct)
								values = values, nhb_sae_num_scalar("r(mean)") + z * nhb_sae_num_scalar("r(sd)")
							} else {
								stats = stats[1..c], sprintf("pi%2.0f%% ub", ppct), stats[c+1..C]
								values = values[1..c], nhb_sae_num_scalar("r(mean)") + z * nhb_sae_num_scalar("r(sd)"), values[c+1..C]
								c++
								C++
							}
						} else if ( regexm(strtrim(strlower(stats[c])), "^missing$") ) {
							tmp = nhb_sae_variable_data(variable, str_if, str_in)
							values[c] = colsum(tmp :>= .)
						} else if ( regexm(strtrim(strlower(stats[c])), "^unique$") ) {
							tmp = nhb_sae_variable_data(variable, str_if, str_in)
							tmp = select(tmp, tmp :< .)
							values[c] = rows(uniqrows(tmp))
						} else if ( regexm(strtrim(strlower(stats[c])), "^fraction$") ) {
							if ( N > 0 ) {
								values[c] = nhb_sae_num_scalar("r(N)") / N * 100
							} else {
								values[c] = 100
							}
						} else if ( regexm(strtrim(strlower(stats[c])), "^min$") ) {
							values[c] = sminmax[1]
						} else if ( regexm(strtrim(strlower(stats[c])), "^max$") ) {
							values[c] = sminmax[2]
						} else if ( regexm(strtrim(strlower(stats[c])), "^p([1-9][0-9]?)$") ) {
							values[c] = pct_tiles[strtoreal(regexs(1))]
						} else {
							values[c] = nhb_sae_num_scalar(sprintf("r(%s)", stats[c]))
						}
					}
				}
			} else { // Is string variable
				for(c=1;c<=C;c++) {
					values[c] = .
					if ( regexm(strtrim(strlower(stats[c])), "^[n|count]$") ) {
						tmp = nhb_sae_variable_data(variable, str_if, str_in)
						values[c] = rows(tmp) - colsum(tmp :== "")
					} else if ( regexm(strtrim(strlower(stats[c])), "^i[qd]i$") ) {
						stats[c] = sprintf("%s %f%%", 
											substr(stats[c],1,3), 
											substr(stats[c],1,3) == "iqi" ? 25 : 10)
						if ( c == C ) {
							stats = stats, sprintf("%s %f%%", 
													substr(stats[c],1,3), 
													substr(stats[c],1,3) == "iqi" ? 75 : 90)
							values = values, .
						} else {
							stats = stats[1..c], 
									sprintf("%s %f%%", substr(stats[c],1,3), 
									substr(stats[c],1,3) == "iqi" ? 75 : 90), 
									stats[c+1..C]
							values = values[1..c], ., values[c+1..C]
							c++
							C++
						}
					} else if ( regexm(strtrim(strlower(stats[c])), "^[pc]i$") ) {
						stats[c] = sprintf("%s%2.0f%% lb", substr(stats[c],1,2), ppct)
						if ( c == C ) {
							stats = stats, sprintf("%s%2.0f%% ub", substr(stats[c],1,2), ppct)
							values = values, .
						} else {
							stats = stats[1..c], sprintf("%s%2.0f%% ub", substr(stats[c],1,2), ppct), stats[c+1..C]
							values = values[1..c], ., values[c+1..C]
							c++
							C++
						}
					} else if ( regexm(strtrim(strlower(stats[c])), "^missing$") ) {
						tmp = nhb_sae_variable_data(variable, str_if, str_in)
						values[c] = colsum(tmp :== "")
					} else if ( regexm(strtrim(strlower(stats[c])), "^unique$") ) {
						tmp = nhb_sae_variable_data(variable, str_if, str_in)
						tmp = select(tmp, tmp :!= "")
						values[c] = rows(uniqrows(tmp))
					}
				}
			}
		} else {
			values = J(1,C,.h)
		}
		
		lm.values(values)
		if ( !nolabel ) {
			varlbl = abbrev(st_varlabel(variable), 32)
			varlbl = subinstr(varlbl, ".", "")
			varlbl = subinstr(varlbl, ":", "")
			if ( varlbl == "" ) varlbl = variable
		} else {
			varlbl = variable
		}
		lm.row_names(varlbl)
		lm.column_names(stats')
		if ( matrixname != "" ) lm.to_matrix(matrixname)
		return(lm)
	}
	
	function nhb_sae_markrows(string scalar str_if, string scalar str_in)
	{
		real scalar rc
		string scalar statacode, markname
	
		statacode = sprintf("generate %s = 1 %s %s", markname = st_tempname(), str_if, str_in)
		if ( rc=nhb_sae_logstatacode(statacode) ) _error(sprintf("nhb_sae_markrows: %s", statacode))
		statacode = sprintf("replace %s = 0 if missing(%s)", markname, markname)
		if ( rc=nhb_sae_logstatacode(statacode) ) _error(sprintf("nhb_sae_markrows: %s", statacode))
		return(markname)
	}
	
	function nhb_sae_variable_data(	string scalar variable, 
									string scalar str_if,
									|string scalar str_in)
	{
		colvector data
		string scalar slct
	
		slct = nhb_sae_markrows(str_if, str_in)
		if ( st_isnumvar(variable) ) {
			data = st_data(., variable, slct)
		} else if ( st_isstrvar(variable) ) {
			data = st_sdata(., variable, slct)
		} else {
			data = J(0,1,.)
		}
		st_dropvar(slct)
		return(data)
	}
	
	function nhb_sae_addvars(
			string rowvector names, 
			matrix values, 
			| real scalar returnnames)
	{
		real scalar rc, obs
		real rowvector vars
		
		names = strtoname(strtrim(names))
		if ( (obs=rows(values) - st_nobs()) > 0 ) st_addobs(obs)
		if ( isreal(values) ) {
			rc = _st_addvar("double", names)[1]
			if ( rc < 0 ) exit(_error(-rc))
				st_store(1::rows(values), names, values)
		} else {
			if ( stataversion() > 1300 ) {
				rc = _st_addvar("strL", names)[1]
			} else {
				rc = _st_addvar("str244", names)[1]
			}
			if ( rc < 0 ) exit(_error(-rc))
				st_sstore(1::rows(values), names, values)
		}
		rc = nhb_sae_logstatacode("compress")
		if ( returnnames != 0 & returnnames != . ) return(names)
	}
	
	function nhb_sae_appendvars(string rowvector names, matrix values)
	{
		real scalar rc, c, R, C
		real rowvector vars
		real colvector slct, append
		
		if ( cols(names) == cols(values) ) {
			names = strtoname(strtrim(names))
			R = rows(values)
			C = cols(names)
			slct = _st_varindex(names) :< .
			append = st_nobs() :+ (1::R)
			st_addobs(R)
			if ( isreal(values) ) {
				for(c=1;c<=C;c++) {
					if ( !slct[c] ) vars = _st_addvar("double", (names[c]))
					if ( st_isnumvar(names[c]) ) st_store(append, (names[c]), values[.,c])
				}
			} else if ( isstring(values) ) {
				for(c=1;c<=C;c++) {
					if ( !slct[c] ) {
						if ( stataversion() > 1300 ) {
							rc = _st_addvar("strL", names)[1]
						} else {
							rc = _st_addvar("str244", names)[1]
						}
					}
					if ( st_isstrvar(names[c]) ) {
						st_sstore(append, (names[c]), values[.,c])
					} else {
						st_store(append, (names[c]), strofreal(values[.,c]))
					}
				}
			}
		}
	//return(names)
	}
	
	function nhb_sae_validate_variable(string scalar varname, real scalar is_categorical)
	{
		string scalar lblname
		
		if ( _st_varindex(varname) == . ) {
			return(sprintf("Argument |%s| must be variable name", varname))
		}
		if ( !st_isnumvar(varname) ) {
			return(sprintf("Variable |%s| must be numerical", varname))
		}
		if ( st_varlabel(varname) == "" ) {
			return(sprintf("Variable |%s| must have a variable label", varname))
		}
		if ( is_categorical ) {
			if ( (lblname=st_varvaluelabel(varname)) == "") {
				return(sprintf("Variable |%s| must have a value label assigned!", varname))
			}
			if ( !st_vlexists(lblname) ) {
				return(sprintf("The assigned value label |%s| do not exist!", lblname))
			}
		}
		return("")
	}

	real rowvector nhb_sae_unique_values(string scalar variable,
										| string scalar str_if, 
										string scalar str_in,
										real scalar drop_missings
										)
	{
		real rowvector levels
		string scalar statacode, if_in
		real scalar rc
		
		levels = J(1, 0, .)
		if ( _st_varindex(variable) < . ) {
			if ( st_isnumvar(variable) ) {
				if_in = nhb_sae_markrows(str_if, str_in)
				levels = uniqrows(st_data(., variable, if_in))'
			}
			if ( drop_missings ) levels = select(levels, levels :< .)
		}
		return(levels == J(0,0,.) ? J(1, 0, .) : levels)
	}

	string rowvector nhb_sae_labelsof(	string scalar variable, 
										| real rowvector levels, 
										string scalar str_if, 
										string scalar str_in,
										real scalar drop_missings
										)
	{
		string scalar vallblname
		string rowvector lbls 
		
		variable = strtrim(variable)
		if ( levels == J(1, 0, .) ) {	//No levels as argument
			levels = nhb_sae_unique_values(variable, str_if, str_in, drop_missings)
		}
		if ( levels == J(1, 0, .) ) {	//No non missing levels for variable
			lbls = J(1, 0, "")
		} else {						//levels non empty
			if ( (vallblname=st_varvaluelabel(variable)) != "" ) {
				lbls = st_vlmap(vallblname, levels)
				lbls = lbls + strofreal(levels) :* (lbls :=="")
			} else {
				lbls = strofreal(levels)
			}
		}
		return(lbls)
	}

	function nhb_sae_str_mult_matrix(string scalar str, real matrix factors)
	{
		real scalar r, c, R, C
		string vector out
		
		R = rows(factors)
		C = cols(factors)
		out = J(R, C, "")
		for(r=1; r <=R; r++) {
			for(c=1; c <=C; c++) {
				out[r,c] = factors[r,c] * str
			}
		}
		return(out)
	}
	
	function nhb_sae_subselect(slctvar, slctname, str_if, str_in)
	{
		string scalar mrk
		rowvector uniq
		colvector dta
		real scalar R
		real rowvector include
	
		mrk = nhb_sae_markrows(str_if, str_in)
		if ( st_isnumvar(slctvar) ) {
			uniq = uniqrows(st_data(., slctvar, mrk))'
			dta = st_data(.,slctvar)
		} else {
			uniq = uniqrows(st_sdata(., slctvar, mrk))'
			dta = st_sdata(.,slctvar)
		}
		st_dropvar(mrk)
		R = rows(dta)
		include = rowsum(dta :== J(R,1,uniq))
		nhb_sae_addvars(slctname, include)
	}
end


/*******************************************************************************
*** mata system api ************************************************************
*******************************************************************************/
mata:
	function nhb_msa_variable_description(|string scalar names)
	{
		real scalar r
		string vector nms, uval, ulbl
		string matrix vd
		class nhb_mt_labelmatrix scalar lm
		
		nms = ( names != "" ? tokens(names)' : st_varname(1..st_nvar())' )
		vd = J(rows(nms), 9, "")
		vd[.,1] = nms
		for(r=1; r<=rows(nms); r++){
			if ( _st_varindex(vd[r, 1]) < . ) {
				vd[r, 2] = strofreal(st_varindex(vd[r, 1]))
				vd[r, 3] = st_varlabel(vd[r, 1])
				vd[r, 4] = st_varvaluelabel(vd[r, 1])
				vd[r, 5] = st_varformat(vd[r, 1])
				if ( vd[r, 4] != "" & st_nobs() > 0 ) {		// Stata 12 do handle empty datasets here
					uval = strofreal(nhb_sae_unique_values(vd[r, 1]))
					ulbl = nhb_sae_labelsof(vd[r, 1])
					if ( uval != J(1,0,"") & ulbl != "" ) {
						vd[r, 6] = nhb_mt_matrix_v_sep(
										uval :+ `" ""' :+ ulbl :+ `"""', ""	// Must be matrix, hence "" added in the end
										, " "
										)
					} else {
						vd[r, 6] = ""
					}

				}
				lm = nhb_sae_summary_row(vd[r, 1], "n unique missing", "", "", "", 95, 0, 0, 0, 0, 0, 1)
				vd[r, 7..9] = strofreal(lm.values())
			}
		}
		vd = ("Name", "Index", "Label", "Value Label Name", "Format", "Value Label Values", "n", "unique", "missing") \ vd
		return(vd)
	}

	function nhb_msa_oswalk(string scalar root, dirfilter, filefilter)
	{
		real scalar r, R
		string colvector files, dirs
		string matrix osw
		
		osw = J(0,2,"")
		dirs = dir(root, "dirs", dirfilter)
		R = rows(dirs)
		if ( R > 0 ) {
			for(r=1;r<=R;r++) {
				osw = osw \ nhb_msa_oswalk(	sprintf(`"%s/%s"', root, dirs[r]), 
									dirfilter, 
									filefilter)
			}
		}
		files = dir(root, "files", filefilter)
		if ( rows(files) > 0 ) osw = osw \ (J(rows(files), 1, root), files)
		for(r=1;r<=rows(osw);r++) {
			osw[r,1] = subinstr(osw[r,1], "\", "/")
			osw[r,1] = subinstr(osw[r,1], "//", "/")
		}
		return(osw)
	}
	
	function nhb_msa_file_size_kb(string scalar fname)
	// From filelist by Robert Picard
	// Also see: http://www.statalist.org/forums/forum/general-stata-discussion/general/1305580-creating-variable-to-record-filesize-of-dataset
	{
		real scalar fh, fsize, filepos
		
		fh = fopen(fname, "r")
		// go to the end of the file; returns negative error codes
		filepos = _fseek(fh, 0, 1)
		if (filepos >= 0) fsize = ftell(fh)
		fclose(fh)
		return(strofreal(fsize/1024, "%21.3f"))
	}

	string scalar nhb_msa_unab(string scalar varlist_fltr)
	{
		string scalar tmp0, out
		real scalar rc
		
		tmp0 = st_local("0")
		st_local("0", varlist_fltr)
		out = !_stata("syntax varlist") ? st_local("varlist") : ""
		st_local("0", tmp0)
		return(out)
	}
end


********************************************************************************
*** Mata calculations **********************************************************
********************************************************************************
mata:
	real colvector nhb_mc_smoothed_data(real colvector values,
										real scalar smooth_width)
	/***
	Order the values, smooth the values with an average of with smooth_width.
	Endpoints are set to missing.
	Returns the reordered smoothed values.
	***/
	{
		real scalar half
		real colvector r, R, idx, data, out
		
		if ( smooth_width == 0 ) return ( values )

		R = rows(values)
		smooth_width = (smooth_width=trunc(abs(smooth_width))) + !mod(smooth_width, 2)
		if ( smooth_width > R) return( J(R, 1, .) )

		half = trunc(smooth_width / 2)
		out = J(R, 1, .)
		idx = order(values, 1)
		data = values[idx]	//sorted
		for(r=half+1;r<=R-half;r++) out[r] = sum(data[(r-half)..(r+half)]) / smooth_width
		out[1..half] = J(half, 1, out[half+1])
		out[(R-half+1)..R] = J(half, 1, out[R-half])
		return( out[invorder(idx)] )
	}

	real rowvector nhb_mc_smoothed_minmax(	real colvector values,
											real scalar smooth_width)
	{
		real colvector smoothdata
		
		if ( smooth_width >= . ) smooth_width = 0
		smoothdata = nhb_mc_smoothed_data(values, smooth_width)
		return( (min(smoothdata), max(smoothdata)) )
	}
		
	real matrix nhb_mc_percentiles(	real colvector values, 
									real colvector pct,
									| real scalar smooth_width)
	/***
	source:	Stata [R] manual p. 287 (same method as as Stata command centile)

			Mood, A. M., and F. A. Graybill. 1963. 
			Introduction to the Theory of Statistics. 
			2nd ed. New York: McGraw–Hill p. 408
			
	If smooth_width is set, ie not missing or zero the dataset is smoothed 
	before percentiles are calculated.
	***/
	{
		real scalar r, R
		real colvector data

		if ( !all( (pct :> 0 :& pct :< 100)' ) ) return ( J(0, 0, .) )
		if ( smooth_width >= . ) smooth_width = 0
		
		data = select(values, values :< .)
		if ( data != J(0, 1, .) & data != J(0, 0, .) ) {
			r = trunc(R=(rows(data) + 1) / 100 :* pct)
			r = (r :== 0) :+ r
			R = (r :!= 0) :* R :+ (r :== 0) :* r
			data = nhb_mc_smoothed_data(data, smooth_width)		
			data = sort(data, 1)
			data = (data) \ data[rows(data)]
			return(pct, data[r :+ 1] :* (R - r) + data[r] :* (1 :- R + r))
		} else {
			return(pct, J(rows(pct), 1, .))
		}
	}
	
	class nhb_mc_splines
	{
		private:
			real rowvector knots
			void new()
			real vector positive()
		public:
			void add_knots()
			real matrix marginal_linear()
			real matrix restricted_cubic()
	}

		real vector nhb_mc_splines::positive(real vector v) 
		{
			return((abs(v) + v) :* 0.5)
		}
		
		void nhb_mc_splines::new()
		{
			this.knots = J(0,1,.)
		}

		void nhb_mc_splines::add_knots(real rowvector knots)
		{
			this.knots = sort(knots', 1)'	// knots are always ordered
		}

		real matrix nhb_mc_splines::marginal_linear(real colvector values)
		//linear before the first knot and/or after the final knot
		{
			real scalar c, R, C
			real matrix x

			R = rows(values)
			C = cols(this.knots)
			x = values
			for (c=1;c<=C;c++) x = x, positive(values :- this.knots[c])
			return(x)
		}

		real matrix nhb_mc_splines::restricted_cubic(real colvector values)
		//linear before the first knot and/or after the final knot
		{
			real scalar c, R, C
			real vector lambda
			real matrix u, x

			R = rows(values)
			C = cols(this.knots)
			u = J(R, 0, .)
			x = values
			for (c=1;c<=C;c++) u = u, positive(x :- this.knots[c]) :^ 3
			lambda = (this.knots[C] :- this.knots[1..C-2]) :/ (this.knots[C] - this.knots[C-1])
			for(c=1;c<=C-2; c++) {
				x = x, 	((u[.,c] - u[.,C-1] :* lambda[c] + u[.,C] :* (lambda[c] - 1)) 
							:/ (this.knots[C] - this.knots[1]) :^ 2)
			}
			return(x)
		}

		
	real matrix nhb_mc_predictions(	real matrix values, 
									real colvector betas, 
									real matrix variance, 
									|real scalar ci_p
									)
	{
		real scalar z
		real colvector pr, pr_sd, pr_lb, pr_ub
		
		ci_p = ci_p < . ? ci_p : 0.975
		z = invnormal(ci_p)
		pr = values * betas
		//https://www.statalist.org/forums/forum/general-stata-discussion/mata/1407049-how-can-i-calculate-only-the-diagonal-elements-of-a-matrix
		pr_sd = sqrt(rowsum(values :* (values * variance)))
		pr_lb = pr - z :* pr_sd
		pr_ub = pr + z :* pr_sd
		return(pr, pr_lb, pr_ub)
	}
	
	class nhb_mt_labelmatrix scalar nhb_mc_post_ci_table(
		| real scalar eform, 
		real scalar cip
		)
		/*
		Inspired by parmest. However results are saved in mata labelmatrix
		
		*/
	{
		real scalar df, zt
		real vector b, se_b, test, lb, ub, pv
		class nhb_mt_labelmatrix scalar out
	
		cip = cip == . ? 0.025 : (100 - cip) / 200
	
		b = st_matrix("e(b)")'
		se_b = sqrt(diagonal(st_matrix("e(V)")))
		test = b :/ se_b
		if ( (df = nhb_sae_num_scalar("e(df_r)")) != . ) 
		zt = invttail(df, cip)
		else zt = invnormal(1-cip)
		lb = b - zt :* se_b
		ub = b + zt :* se_b
		pv = 2 :* normal(-abs(b :/ se_b))
		if ( eform ) out.values( (exp((b, se_b, lb, ub)), pv) )
		else out.values( (b, se_b, lb, ub, pv) )
		out.row_equations(st_global("e(depvar)"))
		out.column_names((	"b", 
							"se(b)", 
							sprintf("Lower %f%% CI", 100-200*cip), 
							sprintf("Upper %f%% CI", 100-200*cip),
							"P value"
							)')
		out.row_names(st_matrixcolstripe("e(b)")[.,2])
		return( out )
	}
end


********************************************************************************
*** Mata Utility functions *****************************************************
********************************************************************************
mata:
    string rowvector nhb_muf_tokensplit(string scalar txt, string scalar delimiter)
    {
        string vector  row
        string scalar filter
        row = J(1,0,"")
        filter = sprintf("(.*)%s(.*)", delimiter)
        while (regexm(txt, filter)) {
            txt = regexs(1)
            row = regexs(2), row
        }
        row = txt, row
        return(row)
    }
end


********************************************************************************
*** Functional programming *****************************************************
********************************************************************************
mata:
	transmorphic vector nhb_fp_map(
		pointer(transmorphic scalar function) f, 
		transmorphic vector vec) 
	{
		real scalar r, R
		transmorphic vector out
	
		R = length(vec)
		if (isstring((*f)(vec[1]))) out = J(R,1,"")
		else if (isreal((*f)(vec[1]))) out = J(R,1,.)
		else return(J(0,0,.))
		for(r=1;r<=R;r++) out[r] = (*f)(vec[r])
		return(out)
	}

	transmorphic vector nhb_fp_reduce(
		pointer(transmorphic scalar function) f, 
		transmorphic vector vec)
		{
		real scalar R
	
		R = length(vec)
		if (R == 1){
			return(vec[1])
		} else {
			return( (*f)(vec[1], nhb_fp_reduce(&(*f), vec[2::R])) )
		}
	}
end


********************************************************************************
*** Containers *****************************************************************
********************************************************************************
mata:
    class nhb_List {
        private:
			real scalar cursor
			transmorphic colvector lst
		public:
			void reset()
			string scalar type()
			transmorphic colvector content()
			void next_init()
			transmorphic scalar next()
			real scalar has_next()
			real scalar len()
			real find()
			transmorphic colvector apply()
			void append()
			void remove()
			real scalar is_empty()
			transmorphic colvector unique_values()
			real colvector frequency()
			transmorphic colvector union_unique()
			transmorphic colvector intersection_unique()
			transmorphic colvector less_unique()
    }
        
        void nhb_List::reset() {
			this.cursor = 0
			this.lst = J(0,1,.)
        }

		string scalar nhb_List::type() return(eltype(this.content())) 
	
        transmorphic colvector nhb_List::content() 
			return( !this.is_empty() ? this.lst : J(0,1,.) )

        void nhb_List::next_init()
        {
            this.cursor = 0
        }
        
        transmorphic scalar nhb_List::next()
			return( this.has_next() ? this.lst[++this.cursor] : . )
        
        real scalar nhb_List::has_next() 
			return( !this.is_empty() ? this.cursor < this.len() : 0 )
        
        real scalar nhb_List::len()
			return( rows(this.lst) )
        
        real nhb_List::find(value)
			return(  !this.is_empty() ? select((1::rows(this.lst)), this.lst :== value) : J(0,1,.) )
        
        transmorphic colvector nhb_List::apply(f)
			return( !this.is_empty() ? nhb_fp_map(&(*f), this.lst) : J(1,0,.))
        
        void nhb_List::append(transmorphic colvector value)
        {
            this.lst = this.is_empty() ? value : this.lst \ value
        }
        
        void nhb_List::remove(scalar value) {
            this.lst = select(this.lst, this.lst :!= value)
        }
        
        real scalar nhb_List::is_empty() return( !this.len() )

        transmorphic colvector nhb_List::unique_values() return( sort(uniqrows(this.lst), 1) )
        
        real colvector nhb_List::frequency(|colvector vals)
        {
			transmorphic colvector values
		
            values = args() ? vals : this.unique_values()
            return(rowsum(J(rows(values), 1, this.lst') :== values))
        }

        transmorphic colvector nhb_List::union_unique(colvector set_b) {
			transmorphic colvector a_unique, b_unique
			
            a_unique = sort(uniqrows(this.lst), 1)
            b_unique = sort(uniqrows(set_b), 1)
            return( sort(uniqrows(a_unique \ b_unique), 1) )
        }
        
        transmorphic colvector nhb_List::intersection_unique(colvector set_b) {
			real scalar a, A
			real colvector slct
			transmorphic colvector a_unique, b_unique
			
            a_unique = sort(uniqrows(this.lst), 1)
            b_unique = sort(uniqrows(set_b), 1)
            A = rows(a_unique)
            slct = J(A,1,.)
            for(a=1;a<=A;a++) slct[a] = anyof(b_unique, a_unique[a])
            return( select(a_unique, slct) )
        }
        
        transmorphic colvector nhb_List::less_unique(colvector set_b) {
			real scalar a, A
			real colvector slct
			transmorphic colvector a_unique, b_unique
			
            a_unique = sort(uniqrows(this.lst), 1)
            b_unique = sort(uniqrows(set_b), 1)
            A = rows(a_unique)
            slct = J(A,1,.)
            for(a=1;a<=A;a++) slct[a] = !anyof(b_unique, a_unique[a])
            return( select(a_unique, slct) )
        }
end
