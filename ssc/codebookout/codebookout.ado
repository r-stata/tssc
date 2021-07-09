*! version 1.0.0  19mar2014
program codebookout
 version 12
 local 0 `"using `0'"'
 syntax using/ [, REPLACE]
 if "`replace'"=="" {
	confirm new file `"`using'"'
}
 quietly local filename "$S_FN"
 mata: A=mata_codebookout()
 clear
 getmata(Vname Vlabel Vtype Acode Alabel)=A
 label variable Vname "Variable Name"
 label variable Vlabel "Variable Label"
 label variable Vtype "Variable Type"
 label variable Acode "Answer Code"
 label variable Alabel "Answer Label" 
 quietly destring Acode, replace
 quietly replace Vtype="Integer" if Vtype=="int"
 quietly replace Vtype="Numeric" if Vtype=="float" | Vtype=="byte" 
 quietly replace Vtype="String"  if regexm(Vtype,"str") 
 order Vname Vlabel Alabel Acode Vtype
 export excel using "`using'",  firstrow(varlabels) `replace'
 quietly use "`filename'",clear
end

// Definition of your mata function
clear mata
mata:
function mata_codebookout(){
nv=st_nvar()
A=J(0,5,"")
for(i=1; i<=nv; i++ ){
 if(st_varvaluelabel(i)!=""){
   a1=st_varname(i),st_varlabel(i),st_vartype(i)   
   st_vlload(st_varvaluelabel(i), values=., text=.)
   a2=(strofreal(values),text)
   a2_2="",""
   a2=a2_2\a2
   dum=length(a2[.,1])-1
   a1_2=J(dum,3,"")
   a1=a1\a1_2
   a=a1,a2
   A=A\a
  }
  else{
   b=st_varname(i),st_varlabel(i),st_vartype(i),"","Open ended"
   A=A\b
  }
 }
 return(A)
}
end
 
