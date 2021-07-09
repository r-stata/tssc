*!  excel2latex 1.0   15April2018 by gc_zhao@foxmail.com

prog define excel2latex,rclass
   
   version 13
   
   syntax, [saving(string)   ///
     using(string)         ///
     tabpos(string)         ///
     CAPtion(string)        ///
     LABel(string)          ///
     FONTSize(string)       ///
     makebox(numlist max=1) ///
     Landscape              ///
     as(string)             ///
	 BASELine(real 1)       ///
	 ARRAYstretch(real 1.2) ///
	 hline(numlist >0 integer sort) ///
	 DROPRow(numlist>0 integer sort) ///
	 TITLECell(numlist max=3 min=2 integer) ///
	 MULTIColumn(string)    ///
	 COLAlignment(string)   ///
	 noNote                 ///
	 NOTECell(string)       ///
	 NOTEScontent(string)   ///
	 NOTEFONTSize(string)   ///
	 DISPlay ]

****** import the table from a file *****   
   if "`using'"!="" {
      tokenize "`using'", parse(",")
      local usename="`1'"
      local uopt="`3'"
      if "`uopt'"~="excel" & "`uopt'"~="txt" & "`uopt'"~="csv" & "`uopt'"~="dta" {
	       dis as error "error: excel2latex does not support .`uopt' files."
	       exit
      }
      if "`uopt'"=="excel" {
         tokenize "`usename'",parse(":")
         local tablename=trim("`1'")
	       if substr("`usename'",-4,4)~=".xls" | substr("`usename'",-5,5)~=".xlsx" {
		      import excel "`tablename'",sheet("`3'") clear
		   }
		   else {
		   cap import excel "`tablename'.xls",sheet("`3'") clear 
		   if _rc~=0 cap import excel "`tablename'.xlsx",sheet("`3'") clear
		   }
      }
      else if "`uopt'"=="txt" {
      	 local usename=trim("`usename'")
         if substr("`usename'",-4,4)~=".txt" qui insheet using "`usename'.txt",clear nonames t
      	 else qui insheet using "`usename'",clear nonames t
      }
      else if "`uopt'"=="csv" {
      	 local usename=trim("`usename'")
      	 if substr("`usename'",-4,4)~=".csv" qui insheet using "`usename'.csv",clear nonames c
      	 else qui insheet using "`usename'",clear nonames c
      }
      else if "`uopt'"=="dta" {
         local usename=trim("`usename'")
         use "`usename'",clear
      }
      local v=1
	    foreach i of varlist _all {
	       capture confirm string variable `i'
		     qui if _rc!=0 tostring `i',replace
		     qui replace `i'=trim(`i')
	       cap assert `i'=="." | `i'==""
		     if _rc==0 drop `i'
		     else qui rename `i' var`v'
		     local v=`v'+1
	    }
      
   }
   else {
      qui des _all
      local tmpk=r(k)
      local tmpn=r(N)
      if `tmpk'==0 | `tmpn'==0 {
         dis as error "error: no table to convert!"
         exit
      }
      else{
      	 local v=1 
      	 foreach i of varlist _all {
      	 	  capture confirm string variable `i'
		        qui if _rc!=0 tostring `i',replace
		        qui replace `i'=trim(`i')
	          cap assert `i'=="." | `i'==""
		        if _rc==0 drop `i'
		        else qui rename `i' var`v'
		        local v=`v'+1
      	 }
      }
   }
   
   preserve 

***** hanld the signs ans marks *****
   foreach i of varlist _all {
      qui replace `i'=subinstr(`i',"_","\_",.)
      qui replace `i'=subinstr(`i',"#","\#",.)
      qui replace `i'=subinstr(`i',"$","\$",.)
      qui replace `i'=subinstr(`i',"<","$<$",.)
      qui replace `i'=subinstr(`i',">","$>$",.)
   }

***** title of the table *****   
   if "`titlecell'"!="" {
      local j=1
	    local tr=word("`titlecell'",1)
      local tc=word("`titlecell'",2)
	    local tp=word("`titlecell'",3)
      local title=var`tc' in `tr'
	    if "`tp'"~="" local title=substr("`title'",`tp',.)
   }  

***** notes of the table *****
   if "`notecell'"!="" {
      tokenize "`notecell'",parse(",")
	    local j=1 
	    while "`1'"!="" {
	       local nr`j'=word("`1'",1)
		     local nc`j'=word("`1'",2)
		     if `nr`j''>_N {
		        dis as error "Warning: The row number of the Note is larger than the number of rows of the table. Check the option notecell()"	
		        exit
		     }
		     local nt`j'=var`nc`j'' in `nr`j''
		     macro shift 2
		     local j=`j'+1
	    }
	    local numnotes=`j'-1
	    forvalues i=1/`numnotes' {
	       if `i'==1 local NR="`nr`i''"
		     else local NR="`NR' `nr`i''"
	    }
   }  
   
  local N=_N 
	gen tmpobs1=_n
 
***** drop some rows *****	
	if "`droprow'"=="" local droprow=.
	if "`titlecell'"=="" local tr=.
	if "`notecell'"=="" local NR=.
	
	if "`titlecell'"!="" | "`droprow'"!="" | "`notecell'"!="" {   
	   qui mata: dropr("`droprow'","`tr'","`NR'")
	   mat dropr=r(dropr)
	   local rowdropr=rowsof(dropr)
	   forval i=1/`rowdropr' {
		    qui drop if tmpobs1==dropr[`i',1] 
	   }
	}
	
	gen tmpobs2=_n
***** hanld the multicolumn cells ******
  if "`multicolumn'"!="" {
     mata: mct=multic("`multicolumn'")
	   mat mc=r(mc)
	   mat colname mc=row col length
	
	   local mcn=rowsof(mc)
	   forva i=1/`mcn' {
	      local mcr=mc[`i',1]
	      local mcc=mc[`i',2]
	      qui replace var`mcc'=" " if tmpobs2==`mcr'
	   }
	}
	else {
	   mat mc=`N'*10,.,.	
	}
	qui compress
	
***** add "&" into the table *****	
	cap drop tmp?
	local j=1
	foreach i of varlist var* {
	   qui {
	   gen tmp1=length(`i')
	   sum tmp1
	   local maxlength=r(max)
	   gen tmp2=" "*(`maxlength'-tmp1)
	   replace `i'=`i'+tmp2
	   if "`j'"~="1" replace `i'="&"+`i'
	   drop tmp1 tmp2 
	   }
	   local j=`j'+1
	   global lvar "`i'"
	}
	qui replace ${lvar}=${lvar}+" \\"
	
****** write the table in a text file *****

   if "`as'"=="" local as="tex"

   if "`caption'"=="" & "`titlecell'"=="" & "`label'"~="" {
      dis as error "error: label() is only be used when caption() or titlecell() is specified!"
	  exit
   }
   
   qui des var*,varlist
   local varlist=r(varlist)
   local K=wordcount("`varlist'")
   local N=r(N)   
   
   if "`saving'"=="" & "`display'"=="" {
   	 dis as error "error: at least one of saving() or display should be specified!"
   	 exit
   }
   
   cap file close tabname
   if "`saving'"~="" {
      tokenize "`saving'",parse(",")
      local savname=rtrim("`1'")
      local sopt="`3'"
      local nspot: word count "`sopt'"
      if `nspot'>1 | ("`sopt'"~="replace" & "`sopt'"~="append") {
         dis as error `"error: only one of "replace" and "append" should be specified"'
	     exit
      }
	  nois file open tabname using "`savname'.`as'",`sopt' write text
	 }
	 else {
	    tempfile temptable
	    local savname="`temptable'"
	    nois file open tabname using "`savname'.`as'",replace write text 	
	 }

******** head of the table ********
// table position
if "`tabpos'"=="" local tabpos="h"

// font size
if "`fontsize'"=="" local fontsize="\small"
else local fontsize="\"+"`fontsize'"

if "`notefontsize'"=="" local notefontsize="`fontsize'"
else local notefontsize="\"+"`notefontsize'"

// column alignment
if "`colalignment'"=="" {
   local K2=`K'-2
   local c="c"
   forva i=1/`K2'{
      local c="`c'"+"c"
   }
   local colalignment="l"+"`c'"
}
else {
   tokenize "`colalignment'",parse(",")
   if "`3'"~="force" { 
      local colanovl=subinstr("`colalignment'","|","",.)
      if length("`colanovl'")<`K' {
         dis as error "At least the alignment for one column is not specified by the option colalignment()"
	     exit
      }
      else if length("`colanovl'")>`K' {
         dis as error "The alignment of additional column(s) is/are specified by the option colalignment()"
	     exit
      }	  
   }
   else local colalignment="`1'"
}


//if "`saving'"~="" { 
	if "`savname'"~="" {
  file write tabname "%%%%%%%%%%%%Table: `caption' (beginning)%%%%%%%%%%%%%" _n
	if "`landscape'"~="" file write tabname "\begin{landscape}" _n
	file write tabname "\renewcommand{\arraystretch}{`arraystretch'}" _n
	file write tabname "\begin{table}[`tabpos']" _n
	if "`landscape'"~="" file write tabname "\centering" _n
	if "`makebox'"~="" file write tabname "\noindent \makebox[\textwidth][c]{\begin{minipage}[c]{`makebox'\textwidth}" _n
	if "`caption'"~="" file write tabname "\caption{`caption'}" _n
	if "`caption'"=="" & "`titlecell'"~="" file write tabname "\caption{`title'}" _n
	if "`label'"~="" file write tabname "\label{`label'}" _n
	if "`makebox'"~="" file write tabname "\end{minipage}}" _n 
	file write tabname "{\renewcommand\baselinestretch{`baseline'}\selectfont" _n
	file write tabname "{`fontsize'" _n
	if "`makebox'"=="" {
	   file write tabname "\begin{tabularx}{\textwidth}{@{\extracolsep{\fill}} `colalignment'}" _skip(1) 
	}
	else {
	   file write tabname "\noindent\makebox[\textwidth][c]{" _n
	   file write tabname "\begin{tabularx}{`makebox'\textwidth}{@{\extracolsep{\fill}} `colalignment'}" _skip(1) 
	}   
	file write tabname "\hline \hline" _n

	// content of the table 
  mata: hliner("`hline'")
	mat hlvec=r(hliner)

  local x=1
	local hliner=hlvec[`x',1]
  
  local m=1
	local mcr=mc[1,1]
	local mcc=mc[1,2]
	local mcl=mc[1,3]
	local rowmc=rowsof(mc)
	
	** i: row; j: column
	forva i=1/`N' {
	   local j=1
	   while `j'<=`K' {
	      local tmp=var`j' in `i'
	      if `i'~=`mcr' {
		       if `j'<`K' file write tabname "`tmp'" _skip(1) 
	            else { 
	            if "`i'"=="`hliner'" {
			           file write tabname "`tmp' \hline" _n 
				         local x=`x'+1
				         local hliner=hlvec[`x',1]
		          }
			     else file write tabname "`tmp'" _n
		       }
		       local j=`j'+1 
		    }
		    else {
		       if `j'<`K' & `j'<`mcc' {
			     file write tabname "`tmp'" _skip(1) 
				   local j=`j'+1
			     }	
			     else if `j'<`K' & `j'==`mcc' & `mcc'+`mcl'-1<=`K'  {
				      mata: mcalign=mct[strtoreal(st_local("m")),1]
				      mata: mctext=mct[strtoreal(st_local("m")),2]
				      mata: st_strscalar("mctext",mctext)
				      mata: st_strscalar("mcalign",mcalign)
				      local mctext=mctext
				      local mcalign=mcalign
			        if (`mcc'+`mcl'-1<`K') {
				         if (`j'==1) file write tabname "\multicolumn{`mcl'}{@{\extracolsep{\fill}} `mcalign'}{`mctext'}" _skip(1)
				         else file write tabname "&\multicolumn{`mcl'}{@{\extracolsep{\fill}} `mcalign'}{`mctext'}" _skip(1)
				         local j=`j'+`mcl'
				      }
				      else {
				         if (`j'==1) {
				            if ("`i'"=="`hliner'") {
					             file write tabname "\multicolumn{`mcl'}{@{\extracolsep{\fill}} `mcalign'}{`mctext'} \\ \hline" _n
						           local x=`x'+1
				               local hliner=hlvec[`x',1] 
					          }	 
					          else file write tabname "\multicolumn{`mcl'}{@{\extracolsep{\fill}} `mcalign'}{`mctext'} \\" _n
				         }  
				         else {
				            if ("`i'"=="`hliner'") {
					             file write tabname "&\multicolumn{`mcl'}{@{\extracolsep{\fill}} `mcalign'}{`mctext'}  \\ \hline" _n
						           local x=`x'+1
						           local hliner=hlvec[`x',1]
				            }
					          else file write tabname "&\multicolumn{`mcl'}{@{\extracolsep{\fill}} `mcalign'}{`mctext'}  \\" _n
				         }	  
				         local j=`K'+1
				      }
				      if `m'<`rowmc' local m=`m'+1
				      local mcr=mc[`m',1]
	            local mcc=mc[`m',2]
	            local mcl=mc[`m',3]
		       }
			     else {
				      if `j'==`K' & `i'==`hliner' {
				      	 file write tabname "`tmp' \hline" _n 
				      	 local x=`x'+1
				      	 local hliner=hlvec[`x',1]
				      }
				      else if `j'==`K' & `i'~=`hliner' file write tabname "`tmp'" _n 
				      local j=`j'+1
			     }
		    }
	   }
	}

	// end of the table 

	file write tabname "\hline \hline" _n
	file write tabname "\end{tabularx}" _skip(1)
	if "`makebox'"~="" file write tabname "}" _skip(1)
	file write tabname "}" _n
	file write tabname "\par}" _n

	if "`note'"~="nonote" {
	   file write tabname "{\renewcommand\baselinestretch{`baseline'}\selectfont" _n
	   file write tabname "{`notefontsize' " _n
	   if "`makebox'"~="" file write tabname "\noindent \makebox[\textwidth][c]{\begin{minipage}[c]{`makebox'\textwidth}" _n
	   if "`notecell'"=="" & "`notescontent'"=="" file write tabname "Notes: ...." _n
	   else if "`notescontent'"~="" file write tabname "Notes: `notescontent'" _n
	   else if "`notescontent'"=="" & "`notecell'"~="" {
	      forvalues i=1/`numnotes' {
		       if `i'==1 & `numnotes'>1 file write tabname "`nt`i'' \\" _n
			     else file write tabname "`nt`i'' " _n
		    }
	   }
	   if "`makebox'"~="" file write tabname "\end{minipage}}" _n
	   file write tabname "}" _n
	   file write tabname "\par }" _n
	}
	file write tabname "\end{table}" _n
	if "`landscape'"~="" file write tabname "\end{landscape}" _n
	file write tabname "%%%%%%%%%%%%Table: `caption'(end)%%%%%%%%%%%%%" _n(4)
	file close tabname
}

if "`display'"=="display" {
   file open latextable using "`savname'.`as'",read
   file read latextable line
   while r(eof)==0 {
   	  dis as result "`line'"
   	  file read latextable line
   }
   file close latextable
}	

restore 

end

********************************************************************************
cap mata: mata drop multic()
mata:
string matrix multic(string scalar multicolumn)
{
   string matrix table
   real matrix obs
   
   table=st_sdata(.,.)
   table=st_sdata(.,1..(cols(table)-2))
   obs=st_data(.,("tmpobs1 tmpobs2"))
   
   tokenmultic=tokens(multicolumn,",")
   tokenmultic=select(tokenmultic,tokenmultic[1,.]:~=",")
   
   for (i=1; i<=cols(tokenmultic); i++) {
	  mc=tokens(tokenmultic[1,i])
	  if (i==1) {
		 mcr=select(obs[.,2],obs[.,1]:==strtoreal(mc[1]))
		 mcc=strtoreal(mc[2])
		 mcl=strtoreal(mc[3])
		 mca=mc[4]
		 mct=table[mcr,mcc]
	  }
	  else {
		 mcr=mcr\select(obs[.,2],obs[.,1]:==strtoreal(mc[1]))
		 mcc=mcc\strtoreal(mc[2])
		 mcl=mcl\strtoreal(mc[3])
		 mca=mca\mc[4]
		 mct=mct\table[select(obs[.,2],obs[.,1]:==strtoreal(mc[1])),strtoreal(mc[2])]
	  }
   }
   mc=mcr,mcc,mcl
   mct=mca,mct
   st_matrix("r(mc)",mc)   
   return(mct) 
}
end

*******************************************************************************

cap mata: mata drop hliner()
mata:
void hliner(string scalar hline)
{
   real matrix obs
   
   obs=st_data(.,("tmpobs1 tmpobs2"))
   
   tokenhline=tokens(hline)
   
   for (i=1; i<=cols(tokenhline); i++) {
	  if (i==1) {
		 hliner=select(obs[.,2],obs[.,1]:==strtoreal(tokenhline[i]))
	  }
	  else {
		 hliner=hliner\select(obs[.,2],obs[.,1]:==strtoreal(tokenhline[i]))
	  }
   }
   st_matrix("r(hliner)",hliner)   
}
end


********************************************************************************

cap mata: mata drop dropr()
mata:

void dropr(string scalar droprow,string scalar tr,string scalar NR)

{
   droprow=tokens(droprow)
   droprow=strtoreal(droprow)
   tr=strtoreal(tr)
   NR=tokens(NR)
   NR=strtoreal(NR)   
   
   if (anyof(droprow,tr)==0) {
      droprow=droprow,tr
   }
   i=1   
   do {
      nr=NR[1,i]
      if (anyof(droprow,nr)==0) {
	     droprow=droprow,nr
	  }
	  i=i+1
   } while (i<=cols(NR))

   droprow=sort(droprow',1)
   st_matrix("r(dropr)",droprow)
}

end



