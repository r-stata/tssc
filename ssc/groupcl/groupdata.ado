*! version 1.0.3 05Oct2006
* Author: Paulo Guimaraes
* syntax: groupdata varlist, dep(var1) groupid(var2) choiceid(var3)
* descrition: Prepares clogit type data for grouped clogit estimation
program define groupdata
    version 9
    syntax varlist(numeric), Dep(varname) GRoupid(varname) CHoiceid(varname)
    di "Varlist  --> " "`varlist'"
    di "Dep Var  --> " "`dep'"
    di "Groupid  --> " "`groupid'"
    di "Choiceid  --> " "`choiceid'"
    local test1: list dep & varlist    
    if "`test1'"!="" {
      di in red "Dependent variable may not belong to varlist!"
      exit 8
    }
    local test2: list groupid & varlist    
    if "`test2'"!="" {
      di in red "Groupid may not belong to varlist!"
      exit 8
    }
    local test3: list choiceid & varlist    
    if "`test3'"!="" {
      di in red "Choiceid variable may not belong to varlist!"
      exit 8
    }
    keep `varlist' `dep' `groupid' `choiceid' 
    tempvar var0 var1 var2
    bys `groupid': gen `var2'=_N
    local vars : list choiceid | varlist
    local vars : list var2 | vars
    egen `var0'=group(`vars')
    bys `groupid': egen `var1'=sum(`var0')
    gsort `var2' -`var1' `groupid' `choiceid'
    di "Getting there..."
    mata: group_cl("`var0'","`var1'","`groupid'","`dep'")
    keep if _newmark==1
    drop _newmark `dep'
    rename _ysum `dep'
    sort `groupid' `choiceid'
end

mata:
void function group_cl(string scalar var0, string scalar var1, string scalar groupid, string scalar dep)
{
mata:
st_view(id=.,.,groupid)
st_view(y=.,.,dep)
st_view(x=.,.,var0)
st_view(control=.,.,var1)
info1=panelsetup(id,1)
info2=panelsetup(control,1)
mark=J(rows(info1),1,1)
ysum=y
m=1
for (i=1; i<rows(info1); i++) {
       if (mark[i,1]==1) {
       s=rows(panelsubmatrix(x,m,info2))/rows(panelsubmatrix(x,i,info1))
       if (s>1) {
       xi=panelsubmatrix(x,i,info1)
       for (j=i+1; j<i+s; j++) {
            if (j<=rows(info1)) {
            xii=panelsubmatrix(x,j,info1)
                if (mreldif(xi,xii)<1e-8) {
                    for (k=0; k<=info1[i,2]-info1[i,1]; k++ ) {
                    ysum[info1[i,1]+k,1]=ysum[info1[i,1]+k,1]+y[info1[j,1]+k,1]
                    }   
            mark[j,1]=0
        }      
        }
        }       
        }
        if (m<rows(info2)) {
        m++
        }   
        }
}
newmark=J(rows(y),1,0)
for (i=1; i<=rows(info1); i++) {
for (j=info1[i,1];j<=info1[i,2]; j++) {
newmark[j,1]=mark[i,1]
}
}
index1 = st_addvar("float","_ysum")
st_store((1,rows(y)),index1,ysum)
index2 = st_addvar("float","_newmark")
st_store((1,rows(y)),index2,newmark)
}
end

/*

*/
