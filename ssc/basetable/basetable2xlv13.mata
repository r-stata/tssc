version 13
capture mata mata drop xlsetup()
capture mata mata drop __basetable_to_xl()
mata:
	class xlsetup
	{
		private:
			void reset(), set_xl()
		public:
			string scalar filename, fileext, sheetname
			real scalar rowpos, colpos, replacesheet, xl_is_set
			class xl scalar xl
		
			void new(), destroy(), set(), show(), insert_matrix()
	}
	
		void xlsetup::new()
		{
			this.reset()
		}
		
		void xlsetup::destroy()
		{
			this.xl.close_book()
		}
		
		void xlsetup::reset()
		{
			this.filename = ""
			this.fileext = "xlsx"
			this.sheetname = ""
			this.rowpos = 1
			this.colpos = 1
			this.replacesheet = 0
		}

		void xlsetup::set(string scalar rgxtxt)
		{
			real scalar r
		
			this.reset()
			rgxf =	"^(.+)\.(xls) *, *(.+) *, *([0-9]+) *, *([0-9]+) *, *(r|replace) *, *\(([0-9 ,]+)\)$",
					"^(.+)\.(xls) *, *(.+) *, *([0-9]+) *, *([0-9]+) *, *(r|replace)$",
					"^(.+)\.(xls) *, *(.+) *, *([0-9]+) *, *([0-9]+)$",
					"^(.+)\.(xls) *, *(.+) *, *(r|replace) *, *\(([0-9 ,]+)\)$",
					"^(.+)\.(xls) *, *(.+) *, *\(([0-9 ,]+)\)$",
					"^(.+)\.(xls) *, *(.+) *, *(r|replace)$",
					"^(.+)\.(xls) *, *(.+)$",
					""
			for(r=1;r<=cols(rgxf);r++) if ( regexm(rgxtxt, rgxf[r]) ) break
			if ( r == 1 ) {
				this.filename = regexs(1)
				this.fileext = regexs(2)
				this.sheetname = regexs(3)
				this.rowpos = strtoreal(regexs(4))
				this.colpos = strtoreal(regexs(5))
				this.replacesheet = 1
				printf(`"{error: Warning!! Coulumn widths can not be set in Stata version 13!}"')
			} else if ( r == 2 ) {
				this.filename = regexs(1)
				this.fileext = regexs(2)
				this.sheetname = regexs(3)
				this.rowpos = strtoreal(regexs(4))
				this.colpos = strtoreal(regexs(5))
				this.replacesheet = 1
			} else if ( r == 3 ) {
				this.filename = regexs(1)
				this.fileext = regexs(2)
				this.sheetname = regexs(3)
				this.rowpos = strtoreal(regexs(4))
				this.colpos = strtoreal(regexs(5))
			} else if ( r == 4 ) {
				this.filename = regexs(1)
				this.fileext = regexs(2)
				this.sheetname = regexs(3)
				this.replacesheet = 1
				printf(`"{error: Warning!! Coulumn widths can not be set in Stata version 13!}"')
			} else if ( r == 5 ) {
				this.filename = regexs(1)
				this.fileext = regexs(2)
				this.sheetname = regexs(3)
				printf(`"{error: Warning!! Coulumn widths can not be set in Stata version 13!}"')
			} else if ( r == 6 ) {
				this.filename = regexs(1)
				this.fileext = regexs(2)
				this.sheetname = regexs(3)
				this.replacesheet = 1
			} else if ( r == 7 ) {
				this.filename = regexs(1)
				this.fileext = regexs(2)
				this.sheetname = regexs(3)
			} else {
				printf(`"\nxlsetup Error help:\n"')
				printf(`"Mandatory are an XL file name (Extension xls), a sheetname (no commas).\n"')
				printf(`"Optional are row and column number for placement on sheet. Defaults are (1,1).\n"')
				printf(`"Optional is "r" or "replace" for replace sheet. Default is no.\n"')
				printf(`"All comma separated.\n\n"')
				_error(sprintf(`"ERROR: "%s" can not be parsed!"', rgxtxt))
			}
		}

		void xlsetup::show()
		{
			printf(`"\nSaved in "%s.%s" at sheet "%s" in position (row, col) = (%f, %f).\n"', 
				this.filename, this.fileext, this.sheetname, this.rowpos, this.colpos)
			printf(`"The sheet is %sreplaced.\n\n"', this.replacesheet ? "" : "not ")
		}
		
		void xlsetup::set_xl()
		{
			string scalar xlbookname, path
		
			if ( this.filename == "" ) _error("Class xlsetup is not set.")
			xlbookname = invtokens((this.filename, this.fileext), ".")
			if ( fileexists(xlbookname) ) {
				this.xl.load_book(xlbookname)
				if ( all(xl.get_sheets() :!= this.sheetname) ) {
					this.xl.add_sheet(this.sheetname)
				} else {
					if ( this.replacesheet ) {
						//xl.set_sheet(this.sheetname)
						this.xl.clear_sheet(this.sheetname)
					} else {
						_error(sprintf("Excel sheet |%s| is already in |%s|", 
										this.sheetname, xlbookname))
					}
				}
			} else {
				pathsplit(xlbookname, path, fn)
				if ( direxists(path) ) {
					this.xl.create_book(xlbookname, this.sheetname)
				} else {
					_error(sprintf("Path |%s| do not exist", path))
				}
			}
		}

		void xlsetup::insert_matrix(string matrix strmat)
		{
			real scalar c, col
			real vector colwidth
		
			this.set_xl()
			this.xl.put_string(this.rowpos, this.colpos, strmat)
		}


	void __basetable_to_xl(	class basetable scalar tbl, 
							string scalar xl_txt,
							| real scalar show_pv,
							real scalar show_total)
	{
		class xlsetup scalar xlz
		real rowvector slct_columns
		string scalar str_regex
		string matrix M

		if ( show_total ) str_regex = "Total"
		if ( show_pv ) str_regex = "P-value"
		if ( show_total & show_pv ) str_regex = "Total|P-value"
		slct_columns = tbl.regex_select_columns(str_regex)

		xlz.set(xl_txt)
		//xlz.show()
		M = tbl.output[., slct_columns]
		xlz.insert_matrix(M)
	}
end
