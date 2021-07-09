*! version 0.2.1	2018-12-21 > BUG: Placing pvalue on top not working together with missing
*! version 0.2.1	2018-10-04 > Option for smoothing data when returning median and quartiles
*! version 0.2.1	2018-10-04 > function summarize_by() is now a private method in class basetable
*! version 0.2.1	2018-09-18 > Option for drop p-value in print
*! version 0.2.1	2018-09-18 > Option for drop total in print
*! version 0.2.1 2018-09-17 > Hidesmall for for missings
* version 0.2.0 2018-01-24 > Removed "<" in front of almost p values
* version 0.2.0 2017-12-05 > Do not perform kwallis when colvar is single valued
* version 0.2.0 2017-03-12 > Bug calculating slct in basetable::n_pct_by_value() fixed
* version 0.1.8 2017-03-12 > Code partly based on lmatrixtools
* version 0.1.8 2017-03-12 > Binomial CI added
* version 0.1.5 2016-02-24 > Most Mata code back in mlib
version 12

mata:
	class basetable {
		private: 
			string scalar colvar, nfmt, pctfmt, pvfmt 
			real scalar valuewidth, pv_on_top, no_small, missing, smooth_width
			string matrix n_pct_by_base()
			real matrix summarize_by()
			string scalar missings()
		public:
			string scalar str_if, str_in
			string matrix output
			void setup_tbl(), log_print(), header()
			void n_pct(), n_pct_by(), n_pct_by_value(), n_bin_by_value()
			void mean_sd(), median_iqr(), median_iqi(), mean_ci(), mean_pi()
			real rowvector regex_select_columns()
	}

		string scalar basetable::missings(string scalar varname) 
		{
			real colvector counts
			string scalar txt
			class nhb_mt_labelmatrix scalar lm
		
			lm = nhb_sae_summary_row(varname, "N missing", "", this.str_if, 
												this.str_in, 95, 0, 0, 0, 0, 0, 1)
			counts = lm.values()
			if ( counts[1] < this.no_small & counts[1]  > 0 ) {
				txt = sprintf(". / %1.0f (.)", counts[1] + counts[2]) 
			} else {
				txt = sprintf("%1.0f / %1.0f (%4.2f)", counts[2], 
							counts[1] + counts[2], 
							counts[2] / (counts[1] + counts[2]) * 100)
			}
			return(txt)
		}

		real rowvector basetable::regex_select_columns(	string scalar str_regex, 
														| real scalar drop
														) 
		{
			real colvector col_idx, slct
			
			col_idx = 1::cols(this.output)
			slct = regexm(this.output[1,.]', str_regex)
			if ( str_regex == "" ) slct = !slct
			return( drop ? select(col_idx, !slct)' : select(col_idx, slct)' )
		}

		void basetable::setup_tbl(string scalar colvar, 
									string scalar nfmt, 
									string scalar pctfmt, 
									string scalar pvfmt,
									real scalar pv_on_top,
									real scalar no_small, 
									real scalar smooth_width, 
									real scalar missing,
									| string scalar str_if, 
									string scalar str_in
									)
		{
			string scalar col_by
		
			this.colvar = colvar
			this.nfmt = nfmt
			this.pctfmt = pctfmt
			this.pvfmt = pvfmt
			this.pv_on_top = pv_on_top
			col_by = st_varlabel(this.colvar)
			if ( col_by == "" ) col_by = this.colvar
			col_by = sprintf("Columns by: %s", col_by)
			this.output = col_by, nhb_sae_labelsof(colvar), "Total", "P-value"
			this.valuewidth = cols(this.output) - 2
			this.no_small = no_small
			this.smooth_width = smooth_width
			this.missing = missing
			this.output = (this.missing ? this.output, "Missings / N (Pct)" : this.output)
			this.str_if = str_if
			this.str_in = str_in
		}

		void basetable::log_print(	|string scalar style,
									string scalar filename,
									real scalar replace,
									string scalar caption,
									string vector top,
									string vector undertop,
									string vector bottom,
									real scalar show_pv,
									real scalar show_total)
		{
			real rowvector slct_columns
			string scalar str_regex
			string colvector lines
			
			if ( show_total ) str_regex = "^Total$"
			if ( show_pv ) str_regex = "^P-value$"
			if ( show_total & show_pv ) str_regex = "^Total$|^P-value$"
			
			slct_columns = this.regex_select_columns(str_regex)

			lines = nhb_mt_mata_string_matrix_styled(this.output[., slct_columns], 
				style, ("-", ""), 1, caption, top, undertop, bottom, filename, replace)
		}

		void basetable::n_pct()
		{
			real scalar r, R, c, C
			real rowvector n, prp, n_tmp, prp_tmp
			string rowvector row
			string colvector names
			class nhb_mt_chi2tabulate scalar tbl
			
			tbl.set(this.colvar, "", this.str_if, this.str_in)
			n = tbl.counts_with_totals().values()'
			prp = 100 * tbl.proportions().values()'
			C = cols(n)
			if ( C != this.valuewidth ) {
				n_tmp = n
				prp_tmp = prp
				n = prp = J(1, this.valuewidth, 0)
				names = tbl.counts().row_names() \ "Total"
				for(r=1;r<=this.valuewidth;r++) {
					for(c=1;c<=C;c++) {
						if ( names[c] == this.output[1,r+1] ) {
							n[r] = n_tmp[c]
							prp[r] = prp_tmp[c]
						}
					}
				}
				C = this.valuewidth
			}
			row = ("n (%)", strofreal(n, this.nfmt) + J(1, C, " (") 
					+ strofreal(prp, this.pctfmt) + J(1, C, ")"), "")
			row = this.missing ? row, this.missings(this.colvar) : row
			this.output	=  this.output \ row 
		}

		string matrix basetable::n_pct_by_base(	string scalar variable, 
												real scalar colpct)
		{
			real scalar r, c, R, C
			real matrix has_small
			rowvector n, prp, tmp_n, tmp_p
			string scalar errtxt
			string rowvector header
			string colvector names
			string matrix out
			class nhb_mt_chi2tabulate scalar tbl
		
			if ( (errtxt=nhb_sae_validate_variable(variable, 1)) != "" ) {
				this.header("n_pct_by_base: " + errtxt, "ERROR!!")
				out = J(0,0,"")
			} else {
				tbl.set(variable, this.colvar, this.str_if, this.str_in)
				n = tbl.counts_with_totals().values()
				R = rows(n) - 1	//Ignore bottom total
				n = n[1..R,.]
				C = cols(n)
				if ( colpct ) {
					prp = 100 * tbl.column_proportions().values()[1..R,.]
				} else {
					prp = 100 * tbl.row_proportions().values()[1..R,.]
				}
				if ( C != this.valuewidth ) {
					tmp_n = n
					tmp_p = prp
					names = tbl.counts().column_names() \ "Total"
					n = prp = J(R, this.valuewidth, 0)
					for (c=1;c<=rows(names);c++) {
						for(r=1;r<=cols(n);r++) {
							if ( names[c] == this.output[1,r+1] ) {
								n[.,r] = tmp_n[.,c]
								prp[.,r] = tmp_p[.,c]
							}
						}
					}
					C = this.valuewidth
				}
				if ( this.no_small ) {
					n = n[.,1..C-1]
					has_small = n :> 0 :& n :< this.no_small
					n = n :* !has_small + this.no_small :* has_small
					n = n, rowsum(n)
					has_small = has_small, rowsum(has_small) :> 0
				} else {
					has_small = J(R, this.valuewidth, 0)
				}
				n = ("" :* !has_small + "< " :* has_small) :+ strofreal(n, this.nfmt)
				prp = prp :/ !has_small
				prp = strofreal(prp, this.pctfmt)
				names = "  " :+ tbl.counts().row_names() :+ ", n (%)"
				out = (names, n + J(R, C, " (") + prp + J(R, C, ")"), J(R, 1, ""))
				C = cols(out)
				out[R,C] = strofreal(tbl.tests().values()[1,3], this.pvfmt)
				header = J(1, C, "")
				header[1] = sprintf("%s, n (%%)", st_varlabel(variable))
				out = header \ out
				if ( this.missing ) {
					out = out, (J(R, 1, "") \ this.missings(variable))
				}
			}
			return(out)
		}
		
	real matrix basetable::summarize_by(	string scalar variable, 
											string scalar statistics
											)
	{
		string scalar txt_if, lbl_name
		string vector lbls
		real scalar C, R, c
		real matrix out
		class nhb_mt_labelmatrix scalar lm


		txt_if = (str_if != "" ? sprintf("%s & !missing(%s)", str_if, this.colvar) 
								: sprintf("if !missing(%s)", this.colvar))
		lbl_name = st_varvaluelabel(this.colvar)
		lbls = nhb_sae_labelsof(this.colvar)
		C = cols(lbls)
		lm = nhb_sae_summary_row(variable, statistics, "", txt_if, this.str_in, 
						95, 0, this.smooth_width, 0, 0, 0, 1)
		out = lm.values()'
		for(c=C; c>=1; c--) {
			lm = nhb_sae_summary_row(variable, statistics, "", 
						txt_if + sprintf(`" & %s == "%s":%s"', this.colvar, lbls[c], lbl_name), 
						str_in, 95, 0, this.smooth_width, 0, 0, 0, 1)
			out = lm.values()', out
		}
		return(out)
	}
		
		void basetable::n_pct_by(	string scalar variable, 
									real scalar colpct)
		{
			real scalar R, C
			string matrix n_pct
			
			n_pct = this.n_pct_by_base(variable, colpct)
			if ( this.pv_on_top ) {
				R = rows(n_pct)
				C = (cols(n_pct)-this.missing)..cols(n_pct)				
				n_pct[1,C] = n_pct[R,C]
				n_pct[R,C] = J(1, 1 + this.missing, "")
			}
			if ( n_pct != J(0,0,"") ) this.output = this.output \ n_pct
		}
		
		void basetable::n_pct_by_value(	string scalar variable, 
										string scalar rowvalue, 
										real scalar colpct)
		{
			real scalar R, C
			string matrix n_pct
			real colvector slct
			
			n_pct = this.n_pct_by_base(variable, colpct)
			if ( n_pct != J(0,0,"") ) {
				R = rows(n_pct)
				C = cols(n_pct)
				slct = regexm(n_pct[.,1], sprintf("^  %s, n", rowvalue))
				if ( colsum(slct) ) {
					n_pct = select(n_pct[., 1..(C-1)], slct), n_pct[R, C]
				} else {
					n_pct = "", J(1, C-2, "0 (.)"), "."
				}
				n_pct[1] = sprintf("%s (%s), n (%%)", st_varlabel(variable), rowvalue)
				this.output = this.output \ n_pct
			}
		}
		
		void basetable::n_bin_by_value(string scalar variable, rowvalue)
		{
			real matrix values
			real scalar rc, c, C
			real colvector slct, z
			string scalar tmpvar, errtxt
			string rowvector str_row
			string matrix sv, test
			
			if ( (errtxt=nhb_sae_validate_variable(variable, 1)) != "" ) {
				this.header("n_bin_by_value: " + errtxt, "ERROR!!")
			} else {
				tmpvar = st_tempname()
				rc = nhb_sae_logstatacode(sprintf(`"generate %s = (%s == "%s":%s) if !missing(%s, %s)"', 
					tmpvar, variable, rowvalue, st_varvaluelabel(variable), 
					variable, this.colvar), 1, 0)
				values = this.summarize_by(tmpvar, "sum N mean")
				values = values \ sqrt(values[3,.] :* (1 :- values[3,.]) :/ values[2,.]) // Add SE in row 4
				z = invnormal(0.025) \ invnormal(0.975)
				values = values \ values[3,.] :+ z # values[4,.] // Add CI
				values[3..6, .] = 100 * values[3..6, .]
				sv = strofreal(values[1..2, .], "%6.0f") \ strofreal(values[3..6, .], this.pctfmt)
				C = cols(values)
				str_row = sprintf("%s (%s), %% (95%% ci)", st_varlabel(variable), rowvalue), J(1, C, "")
				for(c = 1;c <= C; c++) {
					str_row[1, c+1] = sprintf("%s (%s; %s)", sv[3,c], sv[5,c], sv[6,c])
				}
				test = this.n_pct_by_base(variable, 1)
				str_row = str_row, test[rows(test), cols(test)]
				str_row = this.missing ? str_row, this.missings(variable) : str_row
				this.output = this.output \ str_row
			}
		}

		void basetable::mean_sd(string scalar variable, fmt)
		{
			real scalar C, rc, df_m, df_r, F
			real matrix data
			string rowvector rows
			string scalar label, p_value, errtxt
			
			if ( (errtxt=nhb_sae_validate_variable(variable, 0)) != "" ) {
				this.header("mean_sd: " + errtxt, "ERROR!!")
			} else {
				data = this.summarize_by(variable, "mean sd")
				C = cols(data)
				label = sprintf("%s, mean (sd)", st_varlabel(variable))
				p_value = ""
				rc = nhb_sae_logstatacode(sprintf("oneway %s %s %s %s", variable, 
									this.colvar, this.str_if, this.str_in), 1, 0)
				if ( !rc ) {
					df_m = st_numscalar("r(df_m)")
					df_r = st_numscalar("r(df_r)")
					F = st_numscalar("r(F)")
					if ( F != . )  p_value = strofreal(Ftail(df_m, df_r, F), this.pvfmt)
				}
				rows = (label, strofreal(data[1,.], fmt)
							+ J(1, C, " (")
							+ strofreal(data[2,.], fmt) 
							+ J(1, C, ")"), 
							p_value)
				rows = this.missing ? rows, this.missings(variable) : rows
				this.output = this.output \ rows
			}
		}

		void basetable::median_iqr(string scalar variable, fmt)
		{
			real scalar C, df, F
			real matrix data
			string rowvector rows
			string scalar statacode, label, p_value, errtxt

			if ( (errtxt=nhb_sae_validate_variable(variable, 0)) != "" ) {
				this.header("median_iqr: " + errtxt, "ERROR!!")
			} else {
				data = this.summarize_by(variable, "p50 p25 p75")
				data = data[1,.] \ (data[3,.] - data[2,.])
				C = cols(data)
				label = sprintf("%s, median (iqr)", st_varlabel(variable))
				p_value = ""
				if ( this.valuewidth > 2 ) {
					statacode = sprintf("kwallis %s %s %s, by(%s)", variable, 
									this.str_if, this.str_in, this.colvar)
					if ( !nhb_sae_logstatacode(statacode, 1, 0) ) {
						df = st_numscalar("r(df)")
						F = st_numscalar("r(chi2)")
						p_value = strofreal(chi2tail(df, F), this.pvfmt)
					}
				}
				rows = (label, strofreal(data[1,.], fmt)
							+ J(1, C, " (")
							+ strofreal(data[2,.], fmt) 
							+ J(1, C, ")"), 
							p_value)
				rows = this.missing ? rows, this.missings(variable) : rows
				this.output = this.output \ rows
			}
		}

		void basetable::median_iqi(string scalar variable, fmt)
		{
			real scalar C, df, F
			real matrix data
			string rowvector rows
			string scalar statacode, label, p_value, errtxt

			if ( (errtxt=nhb_sae_validate_variable(variable, 0)) != "" ) {
				this.header("median_iqi: " + errtxt, "ERROR!!")
			} else {
				data = this.summarize_by(variable, "p50 p25 p75")
				C = cols(data)
				label = sprintf("%s, median (iqi)", st_varlabel(variable))
				p_value = ""
				this.valuewidth
				if ( this.valuewidth > 2 ) {
					statacode = sprintf("kwallis %s %s %s, by(%s)", variable, 
									this.str_if, this.str_in, this.colvar)
					if ( !nhb_sae_logstatacode(statacode, 1, 0) ) {
						df = st_numscalar("r(df)")
						F = st_numscalar("r(chi2)")
						p_value = strofreal(chi2tail(df, F), this.pvfmt)
					}
				}
				rows = (label, strofreal(data[1,.], fmt)
							+ J(1, C, " (")
							+ strofreal(data[2,.], fmt) 
							+ J(1, C, "; ")
							+ strofreal(data[3,.], fmt) 
							+ J(1, C, ")"), 
							p_value)
				rows = this.missing ? rows, this.missings(variable) : rows
				this.output = this.output \ rows
			}
		}

		void basetable::mean_ci(string scalar variable, fmt)
		{
			real scalar C, rc, df_m, df_r, F, z
			real matrix data
			string rowvector rows
			string scalar label, p_value, errtxt

			if ( (errtxt=nhb_sae_validate_variable(variable, 0)) != "" ) {
				this.header("mean_ci: " + errtxt, "ERROR!!")
			} else {
				data = this.summarize_by(variable, "mean sd N")
				data = data[1,.] \ (data[2,.] :/ sqrt(data[3,.]))
				C = cols(data)
				label = sprintf("%s, mean (95%% ci)", st_varlabel(variable))
				p_value = ""
				rc = nhb_sae_logstatacode(sprintf("oneway %s %s %s %s", variable, 
									this.colvar, this.str_if, this.str_in), 1, 0)
				if ( !rc ) {
					df_m = st_numscalar("r(df_m)")
					df_r = st_numscalar("r(df_r)")
					F = st_numscalar("r(F)")
					if ( F != . )  p_value = strofreal(Ftail(df_m, df_r, F), this.pvfmt)
				}
				z = invnormal(0.975)
				rows = (label, strofreal(data[1,.], fmt)
							+ J(1, C, " (")
							+ strofreal(data[1,.] :- z :* data[2,.], fmt) 
							+ J(1, C, "; ")
							+ strofreal(data[1,.] :+ z :* data[2,.], fmt)
							+ J(1, C, ")"), 
							p_value)
				rows = this.missing ? rows, this.missings(variable) : rows
				this.output = this.output \ rows
			}
		}

		void basetable::mean_pi(string scalar variable, fmt)
		{
			real scalar C, rc, df_m, df_r, F, z
			real matrix data
			string rowvector rows
			string scalar label, p_value, errtxt

			if ( (errtxt=nhb_sae_validate_variable(variable, 0)) != "" ) {
				this.header("mean_pi: " + errtxt, "ERROR!!")
			} else {
				data = this.summarize_by(variable, "mean sd")
				C = cols(data)
				label = sprintf("%s, mean (95%% pi)", st_varlabel(variable))
				p_value = ""
				rc = nhb_sae_logstatacode(sprintf("oneway %s %s %s %s", variable, 
									this.colvar, this.str_if, this.str_in), 1, 0)
				if ( !rc ) {
					df_m = st_numscalar("r(df_m)")
					df_r = st_numscalar("r(df_r)")
					F = st_numscalar("r(F)")
					if ( F != . )  p_value = strofreal(Ftail(df_m, df_r, F), this.pvfmt)
				}
				z = invnormal(0.975)
				rows = (label, strofreal(data[1,.], fmt)
							+ J(1, C, " (")
							+ strofreal(data[1,.] :- z :* data[2,.], fmt) 
							+ J(1, C, "; ")
							+ strofreal(data[1,.] :+ z :* data[2,.], fmt)
							+ J(1, C, ")"), 
							p_value)
				rows = this.missing ? rows, this.missings(variable) : rows
				this.output = this.output \ rows
			}
		}

		void basetable::header(string scalar headertext,| separator)
		{
			string rowvector row
			
			row = J(1, cols(this.output), (args() == 2 ? separator : "***"))
			row[1] = headertext
			this.output = this.output \ row
		}


	function tokensplit(string scalar txt, delimiter)
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

	
	class basetable scalar basetable_parser(	string scalar input_lst, 
												string scalar nfmt, 
												string scalar pctfmt, 
												string scalar pvfmt, 
												real scalar pv_on_top, 
												string scalar continousreport, 
												real scalar no_small, 
												real scalar smooth_width, 
												real scalar missing,
												string scalar str_if, 
												string scalar str_in
												)
	{
		class basetable scalar tbl
		transmorphic t
		real scalar r, n_pct
		string scalar e_txt
		string rowvector lst, arguments
		

		t = tokeninit(" ", "", (`"()"', `"[]"'))
		tokenset(t, input_lst)
		lst = tokengetall(t)
		if ( regexm(lst[1], "^\[|^\(") ) _error("Arguments must not start with a [ or a (")
		if ( (e_txt=nhb_sae_validate_variable(lst[1], 1)) != "" ) _error("First argument: " + e_txt)
		
		tbl.setup_tbl(lst[1], nfmt, pctfmt, pvfmt, pv_on_top, no_small, ///
			smooth_width, missing, str_if, str_in)
		tbl.n_pct()

		for(r=2;r<=cols(lst);r++){ 
			if ( regexm(lst[r], "^\[(.*)\]") ) {			// header, handles local if
				arguments = strtrim(tokensplit(regexs(1), ","))
				arguments = length(arguments) == 1 ? arguments, "" : arguments
				if ( regexm(arguments[1], "(.*)# *$") ) {
					arguments[1] = regexs(1)
					n_pct = 1
				} else {
					n_pct = 0
				}				
				if ( regexm(arguments[2], "^ *(.*) *(if *.+) *$") ) {
					tbl.str_if = stritrim(regexs(2))
					tbl.header(arguments[1], stritrim(regexs(1)))
				} else if ( regexm(arguments[2], "^ *(.*) *$") ) {
					tbl.header(arguments[1], stritrim(regexs(1)))
					tbl.str_if = str_if
				} else {
					tbl.header(arguments[1], "")
				}
				if ( n_pct ) tbl.n_pct()
			} else {										// variable
				if ( (e_txt=nhb_sae_validate_variable(lst[r], 0)) != "" ) {
					tbl.header(e_txt, "ERROR!!")
					continue
				}
				if ( !regexm(lst[r+1], "^\((.*)\)") ) {
					tbl.header(sprintf("Arguments in braces () must follow variable %s", lst[r]), "ERROR!!")
					continue
				}
				arguments = strtrim(tokensplit(regexs(1), ","))
				if ( st_isnumfmt(arguments[1]) == 1 ) {		// continous variable
					continousreport = (continousreport == "" ? "sd" : continousreport)
					arguments = length(arguments) == 1 ? arguments, continousreport : arguments
					if ( arguments[2] == "sd" ) {
						tbl.mean_sd(lst[r], arguments[1])
					} else if ( regexm(arguments[2],"^iqr$") ) {
						tbl.median_iqr(lst[r], arguments[1])
					} else if ( regexm(arguments[2],"^iqi$") ) {
						tbl.median_iqi(lst[r], arguments[1])
					} else if ( regexm(arguments[2],"^ci$") ) {
						tbl.mean_ci(lst[r], arguments[1])
					} else if ( regexm(arguments[2],"^pi$") ) {
						tbl.mean_pi(lst[r], arguments[1])
					}					
				} else {									// categorical variable
					if ( (e_txt=nhb_sae_validate_variable(lst[r], 1)) != "" ) {
						tbl.header(e_txt, "ERROR!!")
						continue
					}
					if ( regexm(strlower(arguments[1]), "^[0r1c]$|^ci$") ) {
						// 0 = row pct, 1 = column pct
						tbl.n_pct_by(lst[r], regexm(arguments[1], "^[1cC]$"))
					} else {
						arguments = length(arguments) == 1 ? arguments, "c" : arguments
						if ( regexm(strlower(arguments[2]), "^ci$") ) { 
							tbl.n_bin_by_value(lst[r], arguments[1])
						} else {
							tbl.n_pct_by_value(lst[r], arguments[1], regexm(arguments[2], "[1cC]$"))
						}
					}
				}
				r++
			}
		}
		return(tbl)
	}	
end
