
*! flexmat: version 1.5: June 7, 2021 - Author: Attaullah Shah

* flexmat Version 1.5: June 7, 2021 : dropcol and droprow now accepts range row(1-4), col(2-4) or list row(1,3,5)
* flexmat Version 1.4: March 14, 2021 : title, notes, and fmtmat changed
* flexmat verson 1.3 Date: Jan 26, 2021 : getlocinfo moved to option from sub-command
* flexmat verson 1.2 ; Jan 22, 2021 : fixed issue in insertrow
* flexmat version 1.0 Date: March 13, 2020

program define flexmat
	version 13
	syntax anything, 	///
		[				///
		Row(str)  		///
		Col(str) 		///
		LOCation(str)  	///
		NEWLOCation		///
		SAMELOCation	/// will use the highest location number, with the assumption that it is the last location saved
		SWAP			/// will swap a matrix at a given location without chainging the title and notes.
		DATA(str) 		///
		Parse(str)      ///
		MATName(str) 	///
		reset(str) 		///
		Dec(str) 		///
		NONames   		///  To skip the matrix row and column names
		NOColnames 		///	 To skip only the column names
		NORownames		///	 To skip only the row names
		QUIetly		    ///
		locinfo			/// show location of stored items
		getlocinfo		/// writes the highest location number global macro flexmat_current_loc
		HIDEcw			/// Hide control words in display
		below above right left ///
		emptyok 		///
		FILEname(str)   /// File name to which flexmat output is written
		matloc(str)  	/// Used with joing matrices; matloc(1,2) will join matrices at loc 1 and 2
		keep(str)   	/// used with merge to keep existing matrices, eg keep(1) , keep(1,2)
		ABBreviate(int 20) /// abbreviate long sentence for matrix display
		append 			/// To append text to a given location
		writebycells	/// Write  matrix cell by cell
		format(str)		/// Custom format for displaying numbers
		title(str)      /// used with addparts to add table title
		notes(str)      /// used with addparts to add table notes
		mode(str) ///		
		]

	loc stata_version = `c(version)'
	if "`filename'" != ""   loc flexmat_stored_matrix_file_name "`filename'"
	
	else if ("`mode'" == "self") { 
		loc folder `c(pwd)'
		mata: create_asdoc_folder("`folder'")
		loc flexmat_stored_matrix_file_name "`folder'/_asdoc/tempfile.flexmat"
		global flexmat_itself_file "`folder'/_asdoc/tempfile.flexmat"
	}
	
	else loc flexmat_stored_matrix_file_name "$active_flexmat_file"
	
	if "`flexmat_stored_matrix_file_name'" == "" {
		loc folder `c(pwd)'
		mata: create_asdoc_folder("`folder'")
	    loc flexmat_stored_matrix_file_name "_asdoc/MyFile.flexmat"
	}
	
	if ("`mode'" == "asdocx") & ("`anything'" != "reset") {
		global active_flexmat_file "`flexmat_stored_matrix_file_name'"
	}
	
	if !inlist("`anything'", "dropcol", "droprow") {
	    
	    if "`row'" != "" confirm integer number `row'
		if "`col'" != "" confirm integer number `col'
	}
	if inlist("`anything'", "dropcol", "droprow") {
	    
	    if ("`anything'" == "droprow" & "`row'" == ""){
			dis as error "Option row() must be specified with sub-command droprow"
			exit 198
		}
		
		if ("`anything'" == "dropcol" & "`col'" == ""){
			dis as error "Option col() must be specified with sub-command dropcol"
			exit 198
		}
	}
		
		
	
	if ("`anything'" == "droploc") {
	    if "`location'" == "" {
		    dis as error  "Please specify location"
			exit
		}
		else {
			mata: droploc("`flexmat_stored_matrix_file_name'", `location')

			if "`quietly'" == ""  {
				dis ""
				dis ""
				mata: mat_display_all("`flexmat_stored_matrix_file_name'", "`locinfo'", "`hidecw'", `stata_version')
				exit
			}
		}
	}
	if "`location'" == "" loc location 1
	global  ThisPClinesize `c(linesize)'

	if strmatch("`anything'", "*merge*") {
	    merge_matrices, flexmatfile(`flexmat_stored_matrix_file_name') matloc(`matloc') keep(`keep')
		exit
	}
	else if strmatch("`anything'", "*reset*") {

		closemall
		if "`anything'" == "reset" {
			cap  rm "`flexmat_stored_matrix_file_name'"
			if _rc != 0 {
				closemall
				cap  rm "`flexmat_stored_matrix_file_name'"
			}
			exit
		}
		else {
			gettoken a anything : anything, bind
			gettoken c p2: a, parse("(") bind
			loc p2 = subinstr("`p2'", "(", "", .)
			loc p2 = subinstr("`p2'", ")", "", .)
			cap rm "`p2'"
		}
		exit
	}
	else {

		if "`newlocation'"	!= "" {
			mata: find_next_location("`flexmat_stored_matrix_file_name'")
			loc location `newlocation'
		}
		if "`samelocation'"	!= "" {
			mata: find_next_location("`flexmat_stored_matrix_file_name'")
			if `location' > 0 	loc location = `newlocation' - 1
		}
		loc file "`flexmat_stored_matrix_file_name'"


		if "`location'" == "" loc location = 1

 		if "`anything'"         == "addparts" {

			mata: flexmat_fmtmat      = J(2,2,"")
			mata: flexmat_fmtmat[1,1] = "title"
			mata: flexmat_fmtmat[1,2] = "`title'"
			mata: flexmat_fmtmat[2,1] = "notes"
			mata: flexmat_fmtmat[2,2] = "`notes'"	

			loc anything fmtmat

 		}

	
		if "`anything'" == "fmtmat" {
			loc data "`data'"
			loc anything addfmtmat
			mata: r = loc_to_hash("fmtmat`location'")
			loc location `locationhash'
			mata: write_fmtmat("flexmat_fmtmat", "`file'", `location')
			

		}

	}
	if "`anything'" == "addmat" & "`data'" != "" {
		dis as error "addmat and option data cannot be used together"
		exit
	}

	if inlist("`anything'", "addcell", "addcol", "addrow") & "`data'" == "" {
		if "`emptyok'" == "" dis as error "Option data() is required with sub-command `anything'"
		exit
	}


	if (!inlist("`anything'", "addcell", "addtext", "addcol", "addrow", "reset", ///
		"addmat", "showmats", "showmat" "addtitle")) & ///
		(!inlist("`anything'", "merge", "droploc", "insertrow", "insertcol", ///
		"insertmat", "dropcol", "droprow", "addfmtmat"))  {
		dis as error "The sub-command `anything' is unrecognized"
		exit

	}
	if !inlist("`anything'", "addmat", "addcol", "addrow", "insertcol", "insertrow", "insertmat") {
		if "`above'" !="" | "`below'" != "" | "`right'" != "" | "`left'" != "" {
			dis as error "Option `above'`below'`right'`left' cannot be used with the sub-command `anything'"
			exit
		}

	}
	if "`anything'" == "addmat" & "`matname'" == "" {
		dis as error "Option matname() must be used with sub-command addmat"
		exit
	}


	if "`anything'" == "addtext" {
		loc anything addcell
		loc data \addtext `data'
	}

	*--------------------------------------------
	if "`anything'" == "addmat" {
	    if ("`row'" == "" & "`col'" == "" & "`below'`right'`above'`left'" == "" ) {
		    loc below below
		}
		if "`col'" == "" loc col 1
	}
	else {
	    if "`row'" == "" loc row 1
		if "`col'" == "" loc col 1
	}
	if "`format'" != "" loc format format(`format')

			if "`anything'" == "addcell" 	addcell, 	data(`data')   		row(`row') col(`col') dec(`dec') file(`file') loc(`location') `append' `format'
	else 	if "`anything'" == "addrow"  	addrow,  	data("`data'") 		row(`row') col(`col') dec(`dec') parse(`parse') file(`file') loc(`location') `left'`right'`below'`above' `format'
	else 	if "`anything'" == "addcol"  	addcol,  	data("`data'") 		row(`row') col(`col') dec(`dec') parse(`parse') file(`file') loc(`location')  `left'`right'`below'`above' `format'
	else  	if "`anything'" == "addmat" 	addmat , 	matname("`matname'") row(`row') col(`col') dec(`dec') `nonames' `nocolnames' `norownames' `left'`right'`below'`above' file(`file') loc(`location') `swap' `format'
	else  	if "`anything'" == "insertcol" 	insertcol, 	data("`data'") 		row(`row') col(`col') dec(`dec') parse(`parse') file(`file') loc(`location') `left'`right'`below'`above'
	else  	if "`anything'" == "insertrow" 	insertrow, 	data("`data'") 		row(`row') col(`col') dec(`dec') parse(`parse') file(`file') loc(`location') `left'`right'`below'`above'
	else  	if "`anything'" == "dropcol" 	dropcol , 	col(`col') file(`file') loc(`location')
	else  	if "`anything'" == "droprow" 	droprow , 	row(`row') file(`file') loc(`location')
	else 	if "`anything'" == "locinfo"	loc locinfo locinfo


	
	
	
	// display
	global abb `abbreviate'
	if "`getlocinfo'" != "" {
		mata: getlocinfo("`flexmat_stored_matrix_file_name'")
	}
	
	if "`quietly'" == ""  {
		dis ""
		//dis "Current flexmat file name : `flexmat_stored_matrix_file_name'"
		dis ""
		mata: mat_display_all("`flexmat_stored_matrix_file_name'", "`locinfo'", "`hidecw'", `stata_version')
	}
	closemall

end

prog merge_matrices

	syntax, flexmatfile(str) matloc(str) [keep(str) *]

	loc matloc = subinstr("`matloc'", ",", " ", .)
	tokenize `matloc'
	gettoken  first matloc : matloc
	gettoken  second matloc : matloc

	if "`keep'" != "" {
		loc matloc = subinstr("`keep'", ",", " ", .)
		tokenize `keep'
		gettoken  keep1 keep : keep
		gettoken  keep2 keep : keep
	}
loc stata_version = `c(version)'
	mata : merge_matrices("`flexmatfile'", `first', `second', "`keep1'", "`keep2'", `stata_version')
end



*--------------------
* Program	AddCell
*--------------------
prog addcell
	syntax , [data(str)] file(str) [Row(int 1) Col(int 1) Dec(str) loc(str) append format(str)]
	if "`dec'" != "" {
		asdocdec `data', dec(`dec')
		loc data "`value'"
	}
	if "`format'" != "" {
	    cap confirm number `data'
		if _rc {
		    mata : matrixwrite("`data'", "`file'", `loc', `row', `col', "`append'")
		}
		else {
			if "`data'" != "" mata : matrixwrite("`:dis `format' `data''", "`file'", `loc', `row', `col', "`append'")
		}
	}
	else if "`data'" != "" mata : matrixwrite("`data'", "`file'", `loc', `row', `col', "`append'")
	
end


*--------------------
* Program	Addrow
*--------------------

*! Version 1: addrow is a subcommand in asdocmat to add row; Attaullah Shah: Sep 9, 2018
prog addrow
	syntax , DATA(str) file(str) [Row(int 1) Col(int 1) parse(str) loc(str) ///
	         Dec(str) below above right left format(str)]
	if "`parse'" == "" loc parse ","
	else if "`parse'" == "comma" loc parse ","
	else if "`parse'" == "space" loc parse " "
	else if "`parse'" == "pipe"  loc parse |
	if "`dec'" != "" loc dec dec(`dec')

	****************** below above right left **********************************

	if "`above'" !="" | "`below'" != "" | "`right'" != "" | "`left'" != "" {

		mata: flexmat_fileconfirm("`file'", `loc')

		if `fileexists' == 1 {


			if "`left'`right'`below'`above'" == "below" {
				loc col = 1
				loc row = `row' + 1
			}
			if "`left'`right'`below'`above'" == "right" {
				loc col = `col' + 1
				loc row = 1
			}
			if "`left'`above'" == "above" {		
				loc col = 1
				loc row = -1
			}
			if "`left'`above'" == "left" {
				loc col = -1
				loc row = 1
			}
		}

	}

	while "`data'" != "" {
		gettoken myvalue data : data, parse("`parse'")

		if "`myvalue'" != "`parse'" {
			addcell , data("`myvalue'") row(`row') col(`col') file(`file') loc(`loc') `dec' `format'
			if `row' < 0 loc row 1
			if `col' < 0 loc col = 1

			loc `++col'
		}
	}
end




*--------------------
* Program	Addcol
*--------------------

*! addcol: Version 1: addcol is a subcommand in asdocmat to add row; Attaullah Shah: Sep 9, 2018
prog addcol
	syntax , file(str) DATA(str) [Row(int 1) Col(int 1) parse(str) Dec(str) ///
	         loc(str) below above right left format(str)]
	
	if "`format'" != "" loc format format(`format')

	if "`parse'" == "" loc parse ","
	else if "`parse'" == "comma" loc parse ","
	else if "`parse'" == "space" loc parse " "
	else if "`parse'" == "pipe"  loc parse |

	if "`dec'" != "" loc dec dec(`dec')

	****************** below above right left **********************************

	if "`above'" !="" | "`below'" != "" | "`right'" != "" | "`left'" != "" {
	    mata: flexmat_fileconfirm("`file'", `loc')

		if `fileexists' == 1 {

			if "`left'`right'`below'`above'" == "below" {
				loc col = 1
				loc row = `row' + 1
			}
			if "`left'`right'`below'`above'" == "right" {
				loc col = `col' + 1
				loc row = 1
			}
			if "`left'`above'" == "above" {		
				loc col = 1
				loc row = -1
			}
			if "`left'`above'" == "left" {
				loc col = -1
				loc row = 1
			}
		}
	}
	*-----------------------------------------------------------------------------			



	while "`data'" != "" {
		gettoken myvalue data : data, parse("`parse'")

		if "`myvalue'" != "`parse'" {
			addcell , data("`myvalue'") row(`row') col(`col') file(`file') loc(`loc') `dec' `format'
			if `row' < 0 loc row = 1
			loc `++row'
			if `col' <0 loc col 1
		}
	}
end

//*------------------------------------------------------------------------------
//							Insert Col
//=============================================================================*/
prog insertcol
	syntax , file(str) DATA(str) [Row(int 1) Col(int 1) parse(str) Dec(str) loc(str) ]
	if "`parse'" == "" loc parse ","
	else if "`parse'" == "comma" loc parse ","
	else if "`parse'" == "space" loc parse " "
	else if "`parse'" == "pipe"  loc parse |
	
	//if "`dec'" != "" loc dec dec(`dec')

	****************** below above right left **********************************

	mata: insertcol("`file'", `loc', "`dec'", "`data'", "`parse'", `row', `col')


end

prog insertrow
	syntax , file(str) DATA(str) [Row(int 1) Col(int 1) parse(str) Dec(str) ///
	loc(str) below above right left]
	if "`parse'" == "" loc parse ","
	else if "`parse'" == "comma" loc parse ","
	else if "`parse'" == "space" loc parse " "
	else if "`parse'" == "pipe"  loc parse |
	mata: flexmat_fileconfirm("`file'", `loc')
			

	if `fileexists' == 1 {
		if "`above'" !="" | "`below'" != "" | "`right'" != "" | "`left'" != "" {


			if "`left'`right'`below'`above'" == "below" {
				loc col = 1
				loc row = `OldMatRows' + 1
			}
			if "`left'`right'`below'`above'" == "right" {
				loc col = `OldMatcols' + 1
				loc row = 1
			}

		}
	}
	else {
		loc row = 1
		loc col = 1

	}

	mata: insertrow("`file'", `loc', "`dec'", "`data'", "`parse'", `row', `col')


end

prog dropcol
	syntax , [file(str) Col(str)  loc(str)]

	mata: dropcol("`file'", `loc', "`col'")


end

prog droprow
	syntax , [file(str) Row(str)  loc(str)]

	mata: droprow("`file'", `loc', "`row'")


end


*--------------------
* Program	Addmat
*--------------------

prog addmat
	syntax ,      	 	 ///
		matname(str) 	 /// Existing matrix name
		file(str) 		 ///
		[Row(int 1) 	 /// Starting row number
		Col(int 1) 		 /// Staring column number
		Dec(str) 		 ///
		NONames   		 ///  To skip the matrix row and column names
		NOColnames 		 ///  To skip only the column names
		NORownames	 	 ///  To skip only the row names
		below 			 ///
		above			 ///
		right			 ///
		left			 ///
		loc(str)		 ///
		SWAP			 ///
		format(str)       *]

	* Confirm whether master file exists
	if "`dec'" != "" loc dec dec(`dec')
	if "`format'" != "" loc format format(`format')

	* Confirm that the matrix is a mata memory matrix
	if !strmatch("`matname'", "*/*") & !strmatch("`matname'", "*\*")  & !strmatch("`matname'", "*.*") {
		mata : ismata_memory_matrix("`matname'")
		if `mata_memory_matrix' {
			if "`nocolnames'" != "" loc removetitle nocolnames
			if "`norownames'" != "" loc removetitle norownames
			if "`nonames'"    != "" loc removetitle nonames

			//mata: append_mata_memory_matrix("`matname'", "`file'", `loc', "`dec'", "`left'`right'`below'`above'", "`removetitle'")
			cap rm _temporary_file
			mata: convert_mata_matrix_to_file("`matname'", "_temporary_file")
			loc matname _temporary_file
			loc writebycells 1

		}
	}
	mata: flexmat_fileconfirm("`file'", `loc')
	
	if `fileexists' == 1 {
		if "`above'" !="" | "`below'" != "" | "`right'" != "" | "`left'" != "" {

			if "`left'`right'`below'`above'" == "below" {
				loc col = 1
				loc row = `OldMatRows' + 1
			}
			if "`left'`right'`below'`above'" == "right" {
				loc col = `OldMatcols' + 1
				loc row = 1
			}
		}
	}
	else {
		loc row = 1
		loc col = 1

	}

	* confirm that the source matrix is a stored matrix
	cap qui confirm file "`matname'"

	if _rc == 601 { // if not stored
		cap confirm matrix `matname'
		if _rc != 111 {
			if strmatch("`matname'", "*(*") {
				mat matname = `matname'
				loc matname matname
			}
			global nfiles = $nfiles + 1
			loc ThisMatRows = rowsof(`matname')
			loc ThisMatCols = colsof(`matname')

			if "`left'`above'" == "above" {		
				loc col = 1
				loc row = -`ThisMatRows' 
			}
			if "`left'`above'" == "left" {
				loc col = -`ThisMatCols'
				loc row = 1
			}
			if "`norownames'" != "" loc adjusted_col "-1"
			
			// Do not write column names
			if "`nocolnames'" == "" & "`nonames'"=="" {
				loc write_colnames = 1

				loc cnames : colnames `matname'
				loc COL = `ThisMatCols'
				forv i = 1  / `COL' {
					loc mat_col = `i' + `col' `adjusted_col' - 1
					loc myvalue : word `i' of `cnames'
					addcell , data(`myvalue') row(`row') col(`mat_col') `dec' file(`file') loc(`loc') `format'

				}
				loc row = `row' + 1
			}

			// Do not write rownames
			if "`norownames'" == "" & "`nonames'"=="" {
				if `ThisMatCols' != 1 addcell , data(\) row(`=`row'-1') col(`col') file(`file') loc(`loc') `dec' `format'

				loc write_rownames = 1
				loc rnames : rownames `matname'
				loc ROW = `ThisMatRows'
				forv i = 1  / `ROW' {
					loc mat_row = `i' + `row' - 1
					loc myvalue : word `i' of `rnames'
					addcell , data(`myvalue') row(`mat_row') col(`col') `dec' file(`file') loc(`loc') `format'

				}
				//loc col = `col' + 1
			}
			forv r = 1 / `ThisMatRows' {
				forv c = 1  / `ThisMatCols' {
					local myvalue =  `matname'[`r', `c']
					loc mat_row = `r' + `row' - 1
					loc mat_col = `c' + `col' - 1

					if "`myvalue'" != "" addcell , data("`myvalue'") row(`mat_row') col(`mat_col') `dec' file(`file') loc(`loc') `format'
					if `row' < 0 loc row = 1
					if `col' < 0 loc col = 1
				}
			}
		}
		else  dis as error "Matrix `matname' not found"
	}
	else { // if stored mata matrix

		mata: fh = fopen("`matname'", "r")
		mata: Y = fgetmatrix(fh)
		mata: st_local("ThisMatCols", strofreal(cols(Y)))
		mata: st_local("ThisMatRows", strofreal(rows(Y)))
		mata: fclose(fh)

		// If the flexmat file was not previously stored, then add the whole matrix in one go
		if `fileexists' == 0 {
			mata: write_full_matrix("`matname'", "`file'", `loc')

		}
		else if "`writebycells'" == "" {
		    mata: append_full_matrix("`matname'", "`file'", `loc', "`swap'")
		}
		
		
		
		else { // If the flexmat file was previously stored, then go cell by cell

			if "`left'`above'" == "above" {		
				loc col = 1
				loc row = -`ThisMatRows' 
			}
			else if "`left'`above'" == "left" {
				loc col = -`col'
				loc row = 1
			}
			
			if "`nocolnames'" != "" {
				loc adjusted_row = "1"
				//loc rows = `rows' -1
			}
			else loc adjusted_row = 0
			
			if "`norownames'" != "" {
				loc adjusted_col = "1"
				//loc rows = `rows' -1
			}
			else loc adjusted_col = 0
			

			if 	"`matname'" == "`file'" {
				tempname overlap
				mata: fh = fopen("`matname'", "rw")
				mata: fout = fopen("`overlap'", "rw")
				mata: Y = fgetmatrix(fh)
				mata: fputmatrix(fout, Y)
				mata: fclose(fh)
				mata: fclose(fout)
				local matname `overlap'

			}

			forv r = `=`adjusted_row'+1'  / `ThisMatRows' {
				forv c = `=`adjusted_col'+1'  / `ThisMatCols' {

					mata: st_local("myvalue", Y[`r', `c'])
					loc mat_row = `r' + `row' - 1-`adjusted_row'
					loc mat_col = `c' + `col' - 1-`adjusted_col'
					if "`myvalue'" != "" addcell , data("`myvalue'") row(`mat_row') col(`mat_col') `dec'  file(`file') loc(`loc') `format'
					if `mat_row' < 0 loc row = 1
					if `mat_col' < 0 loc col = 1

				}
			}
			cap rm `overlap'
			cap rm _temporary_file
		}
	}		// End of processing stored mata matrix
	
end



prog asdocx_format
	syntax anything, format(str)

	cap confirm number `anything'
	if _rc c_local value `anything'
	
	else {
		c_local value : di `format' =  `anything'
		else c_local value  `anything'
	}
	
end



*! asdocdec: Handle decimal points: Attaullah Shah : Feb20, 2018
prog asdocdec
	syntax anything, dec(str) 

	cap confirm number `anything'
	if _rc c_local value `anything'
	else {

		if strmatch("`anything'", "*.*") {
			if length("`anything'") > `dec' {
				c_local value : di %9.`dec'f =  `anything'
			}
			else c_local value = `anything'

		}
		else c_local value = `anything'
	}
end




cap prog drop closemall
program closemall
	forvalues i = 0 / 50 {
		cap mata: fclose(`i')
	}

end
