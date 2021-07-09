*! htmltab2stata version 1.0
*! Jan Ditzen - www.jan.ditzen.net
*! January 2019

program define htmltab2stata 
syntax [anything] , url(string) [tablenumber(string) firstrow href]
	version 14
	clear
	tempfile tmpfile1 tmpfile2
	
	if "`tablenumber'" == "" {
		local tablenumber = 1
	}
	
	qui {
		copy "`url'" "`tmpfile1'" , replace
		
		** filefilter to extent file so stata loads in all with new columns
		filefilter "`tmpfile1'" "`tmpfile2'", from(">") to(">\n") replace
		
		mata Output=ReadFileIn("`tmpfile2'",`tablenumber',"`href'")
		
		getmata myvar* = Output, replace
		if "`firstrow'" != "" {
			foreach var of varlist myvar* {
				if "`=`var'[1]'" != "" {
					local varnamei = strtoname(strtrim("`=`var'[1]'"))
					rename `var' `varnamei'
				}			
			}
			drop in 1
		}
	}
end

mata:
	function ReadFileIn(string scalar path,real scalar tablenumber,string scalar href)
	{
		string matrix FirstRow
		
		FirstRow = J(1,0,"")
		
		file = fopen(path,"r")		
		
		TableNum = 0
		RowInTable = 0
		
		/// Number of Cols and Rows Table has
		RowsOfTable = 0
		ColsOfTable = 0
		
		// Initalise in cell index
		CurrentElementWritten = 0
		CurrentElementExist = 0
		
		while ((line=fget(file))!=J(0,0,"")) {
			/// remove leading blanks in line
			line = ustrltrim(line)
			
			/// counter for number of tabke
			if (strmatch(line,"<table*") == 1) {
				TableNum = TableNum + 1	
				RowInTable = 1
			}
			else if (strmatch(line,"</table*") == 1) {
				RowInTable = 0
			}
 			/// only carry on if row is in table
			if (RowInTable == 1) {
				if (TableNum == tablenumber) {					
					/// Header, find number of columns.
					if (RowsOfTable == 0) {
						if ((strmatch(line,"<th*") == 1) | (strmatch(line,"<td*") == 1)) {
							ColsOfTable = ColsOfTable + 1
							CurrentElementWritten = 0
							CurrentElementExist = 1
						}
						else if ((strmatch(line,"<*") == 0) & (CurrentElementExist == 1)) {
							if (line != "") {
								if (CurrentElementWritten == 0) {
									FirstRow = (FirstRow , tokens(line,"<")[1])
									CurrentElementWritten = 1									
								}
								else {
									if (cols(FirstRow) == 1) {
										FirstRow = (FirstRow + " "+(tokens(line,"<")[1]))
									}
									else {
										FirstRow = (FirstRow[1..cols(FirstRow)-1],FirstRow[cols(FirstRow)]+" "+(tokens(line,"<")[1]))
									}
								}
								if ((strmatch(line,"</th*") == 1) | (strmatch(line,"</td*") == 1)) {
									CurrentElementExist = 0
								}
							}							
						}
						else if ((strmatch(line,"*</th*") == 1) | (strmatch(line,"*</td*") == 1)) {
							CurrentElementExist = 0
							if (CurrentElementWritten == 0) {
								FirstRow = (FirstRow,"")
								CurrentElementWritten = 1
							}
						}						
						else if (strmatch(line,"</tr*") == 1) {
							/// end of row
							RowsOfTable = RowsOfTable + 1							
							
							Output = FirstRow							
							CurrentLine = J(1,0,"")
							
							CurrentElementExist = 0
							CurrentElementWritten = 0
						}
						
					}
					else if (RowsOfTable > 0) {
						if ((strmatch(line,"<th*") == 1) | (strmatch(line,"<td*") == 1)) {
							CurrentElementWritten = 0
							CurrentElementExist = 1
						}
						else if ((strmatch(line,"<*") == 0) & (CurrentElementExist == 1)) {
							if (line != "") {
								if (CurrentElementWritten == 0) {
									CurrentLine = (CurrentLine , tokens(line,"<")[1])
									CurrentElementWritten = 1									
								}
								else {
									if (cols(CurrentLine) == 1) {
										CurrentLine = (CurrentLine + " "+(tokens(line,"<")[1]))
									}
									else {
										CurrentLine = (CurrentLine[1..cols(CurrentLine)-1],CurrentLine[cols(CurrentLine)]+" "+(tokens(line,"<")[1]))
									}
								}
								if ((strmatch(line,"</th*") == 1) | (strmatch(line,"</td*") == 1)) {
									CurrentElementExist = 0
								}								
							}
						}	
						else if ((strmatch(line,"<a*") == 1) & (href == "href") & (CurrentElementExist == 1)) {
							///first get only href part from line
							lineToken = tokens(line)
							for (i=1;i<=cols(lineToken);i++) {
								lineToken[i]
								if (strmatch(lineToken[i],"href*") == 1 ) {
									URL = tokens(lineToken[i],`"""')
									URL = URL[2]
								}
							}
							if (URL != "") {
								if (CurrentElementWritten == 0) {
									CurrentLine = (CurrentLine , URL)
									CurrentElementWritten = 1									
								}
								else {
									if (cols(CurrentLine) == 1) {
										CurrentLine = (CurrentLine + " "+URL)
									}
									else {
										CurrentLine = (CurrentLine[1..cols(CurrentLine)-1],CurrentLine[cols(CurrentLine)]+" "+URL)
									}
								}
								if ((strmatch(line,"</th*") == 1) | (strmatch(line,"</td*") == 1)) {
									CurrentElementExist = 0
								}								
							}
						}
						else if ((strmatch(line,"</th*") == 1) | (strmatch(line,"</td*") == 1)) {
							CurrentElementExist = 0
							if (CurrentElementWritten == 0) {
								CurrentLine = (CurrentLine,"")
								CurrentElementWritten = 1
							}
						}
						else if (strmatch(line,"</tr*") == 1) {
							if (cols(Output) != cols(CurrentLine)) {
								"Error in adding line. Current Table is"
								Output
								"Line to Add"
								CurrentLine
								fclose(file)
								exit()
							}
							Output = (Output \ CurrentLine)
							CurrentLine = J(1,0,"")
							CurrentElementWritten = 0
						}
					}
				}
			}			
		}
		fclose(file)
		return(Output)
	}
end

