program define crtrees_p, sortpreserve
syntax newvarlist [if] [in] [,	OPENTREES(string)] 
quietly {
marksample touse, novarlist
tempname DbhGd2DPol coeficientes criterios clases mame
local algoritmo=e(algorithm)
local constant=e(noconstant)
local regvar=e(regvar)
if "`noconstant'"=="." local constant=""
if "`regvar'"=="." local regvar=""
local splvar=e(splvar)
local depvar=e(depvar)
if substr("`algoritmo'", 1, 4)=="CART" {
if wordcount("`varlist'") !=1 {
                noi di as err "Under CART, only one newvarname is allowed"
                error 1
}
}
if substr("`algoritmo'", 1, 4)!="CART" {
if wordcount("`varlist'") !=2 {
                noi di as err "Under Random Forests, two newvarnames are required"
                error 1
}
}
if substr("`algoritmo'", 1, 4)=="CART" {
if "`opentrees'"!="" {
                noi di as err "opentrees can only be used after Random Forests"
                error 1
}
}
if wordcount("`varlist'") ==1 local predicciones="`varlist'"
else {
gettoken predicciones pred_sd : varlist
local predicciones= strltrim("`predicciones'")
local pred_sd= strltrim("`pred_sd'")
}
if wordcount("`typlist'")==2 {
gettoken tipo1 tipo2 : typlist
local tipo1= strltrim("`tipo1'")
local tipo2= strltrim("`tipo2'")
}
if "`algoritmo'"=="Random Forest: Regression" {
if "`opentrees'"=="" {
local opentrees=e(matatrees)
if "`opentrees'"=="" local opentrees="matatrees"
}
noi mata: _WC9cxDDU("`depvar'", "`splvar'","`regvar'","`touse'","`constant'",		///
"`opentrees'","`predicciones'","`pred_sd'","`tipo1'","`tipo2'") 
}
if "`algoritmo'"=="Random Forest: Classification" {
matrix define `clases'=e(classes)
if "`opentrees'"=="" {
local opentrees=e(matatrees)
if "`opentrees'"=="" local opentrees="matatrees"
}
noi mata: _S9chQUZv("`depvar'","`splvar'","`touse'","`opentrees'",	///
"`clases'","`predicciones'","`pred_sd'","`tipo1'","`tipo2'")
}
if substr("`algoritmo'", 1, 16)=="CART: Regression" {
matrix define `DbhGd2DPol'=e(tree)
matrix define `coeficientes'=e(coefficients)
matrix define `criterios'=e(criteria)
noi mata: _FBX9TFq6("`depvar'", "`splvar'","`regvar'", "`touse'","`constant'","`DbhGd2DPol'",	///
"`coeficientes'","`criterios'","`predicciones'","`typlist'")
}
if substr("`algoritmo'", 1, 20)=="CART: Classification" {
matrix define `DbhGd2DPol'=e(tree)
matrix define `coeficientes'=e(coefficients)
matrix define `criterios'=e(criteria)
matrix define `clases'=e(classes)
noi mata: _5HA5zRFB("`depvar'", "`splvar'","`touse'","`DbhGd2DPol'","`coeficientes'","`criterios'", ///
"`clases'","`predicciones'","`typlist'")
}
}	
end

mata
mata set matastrict on

                void _6jL7DUnX(numeric matrix DbhGd2DP1, numeric matrix DbhGd2DP3_s, numeric matrix xs,numeric vector nodo) 
        {
        real matrix DbhGd2DP1_s,carac
real scalar ra,j,ra1,rn,i
nodo = J(rows(xs),2,0)
DbhGd2DP1_s=select(DbhGd2DP1,DbhGd2DP1[.,2]:==0)
ra = rows(DbhGd2DP1_s)
for (j=1; j<=ra; j++) {
carac=colshape(DbhGd2DP3_s[j,.],2)'       
nodo[.,1]=nodo[.,1]+DbhGd2DP1_s[j,1]*rowmin((xs:>=carac[1,.]):*(xs:<=carac[2,.]))
}
ra1 = rows(DbhGd2DP1)-1
for (j=1; j<=ra1; j++) {
if ((DbhGd2DP1[j,1]+1)<DbhGd2DP1[j+1,1]) {
DbhGd2DP1=DbhGd2DP1[1..j,.]\((j+1),-1,-1,-1)\DbhGd2DP1[j+1..ra1+1,.]
ra1=ra1+1
}
}
rn=rows(nodo)
for (i=1; i<=rn; i++) {
if (nodo[i,1] == 0) {
j=1
while (j!=0) {	
if (DbhGd2DP1[j,2]==0) {        
nodo[i,1]=DbhGd2DP1[j,1]
nodo[i,2]=1
j=0
}
else {
if (xs[i,DbhGd2DP1[j,3]]<=DbhGd2DP1[j,4]) j=DbhGd2DP1[j,2] 
else j=DbhGd2DP1[j,2]+1	
}
}
}
}
}	

        void _FBX9TFq6(string scalar depvar_s, string scalar splvar_s, string scalar regvar_s, ///
string scalar smpl_s,string scalar constant_s, string scalar DbhGd2DPol_s, 		///
string scalar coeficientes_s,string scalar criterios_s,string scalar predicciones_s, 	///
string scalar typlist_s)
       {
                real matrix splvar,regvar,data,tipo,DbhGd2DP1_h,DbhGd2DP2_h,DbhGd2DP3_h,nodos,DbhGd2DP1_ter,DbhGd2DP2_ter,predicciones
real vector depvar,constante
real scalar no,newvars
depvar=st_data(.,tokens(depvar_s),smpl_s)
no=rows(depvar)
constante=J(no,1,1)
        if (splvar_s=="") splvar=constante
        else splvar = st_data(., tokens(splvar_s),smpl_s)
        if (regvar_s=="") regvar=constante
        if (regvar_s!="" & constant_s=="noconstant") regvar=st_data(.,tokens(regvar_s),smpl_s)
        if (regvar_s!="" & constant_s!="noconstant") regvar=st_data(.,tokens(regvar_s),smpl_s),constante
        data=depvar,splvar,regvar
tipo=	(2\1+cols(splvar)),
(2+cols(splvar)\(1+cols(splvar)+cols(regvar))),
(2+cols(splvar)+cols(regvar)\1+cols(splvar)+cols(regvar)+cols(insvar))
tipo[.,3]=J(2,1,0)
DbhGd2DP1_h=st_matrix(DbhGd2DPol_s)
DbhGd2DP2_h=st_matrix(coeficientes_s)
DbhGd2DP3_h=st_matrix(criterios_s)
_6jL7DUnX(DbhGd2DP1_h,DbhGd2DP3_h[.,2::cols(DbhGd2DP3_h)],		///
(data[.,tipo[1,1]::tipo[2,1]]),nodos=.) 
DbhGd2DP1_ter=select(DbhGd2DP1_h[.,1],DbhGd2DP1_h[.,2]:==0)
DbhGd2DP2_ter=DbhGd2DP2_h[.,7..cols(DbhGd2DP2_h)]
predicciones=rowsum((nodos[.,1]:==DbhGd2DP1_ter[.,1]'#J(rows(nodos),1,1)):*(regvar*DbhGd2DP2_ter'))	
newvars = st_addvar(typlist_s, (predicciones_s))
st_store(.,newvars,smpl_s,predicciones)
}	

        void _WC9cxDDU(string scalar depvar_s, string scalar splvar_s, string scalar regvar_s, 	///
string scalar smpl_s,string scalar constant_s,string scalar matatree,		///
string scalar predicciones_s, string scalar errstd_s,string scalar tipo1_s,	///
string scalar tipo2_s)
       {
                real matrix DbhGd2DPoles,criterios,coeficientes,splvar,regvar,data,tipo,DbhGd2DP1_h,	///
DbhGd2DP2_h,DbhGd2DP3_h,nodos,DbhGd2DP1_ter,DbhGd2DP2_ter
real vector depvar,constante,pred,pred_sd,e,e2,pred_v,e_v
real scalar fh,no_DbhGd2DP,no,num_ts,i0,i,newvars
fh=fopen(matatree, "r")
DbhGd2DPoles=fgetmatrix(fh)
criterios=fgetmatrix(fh)
coeficientes=fgetmatrix(fh)
fclose(fh)
no_DbhGd2DP=rows(DbhGd2DPoles)
depvar=st_data(.,tokens(depvar_s),smpl_s)
no=rows(depvar)
constante=J(no,1,1)
        if (splvar_s=="") splvar=constante
        else splvar = st_data(., tokens(splvar_s),smpl_s)
        if (regvar_s=="") regvar=constante
        if (regvar_s!="" & constant_s=="noconstant") regvar=st_data(.,tokens(regvar_s),smpl_s)
        if (regvar_s!="" & constant_s!="noconstant") regvar=st_data(.,tokens(regvar_s),smpl_s),constante
        data=depvar,splvar,regvar
tipo=	(2\1+cols(splvar)),
(2+cols(splvar)\(1+cols(splvar)+cols(regvar))),J(2,1,0)
pred=J(no,1,0)
pred_sd=pred
e=pred
e2=pred
num_ts=0
i0=1
i=i0
    	while (i<=no_DbhGd2DP-1) {
 if ((i+1==no_DbhGd2DP) | (DbhGd2DPoles[i+1,1]!=DbhGd2DPoles[i,1]+1)) {	
if (i+1==no_DbhGd2DP) i=i+1
DbhGd2DP1_h=DbhGd2DPoles[i0..i,.]
DbhGd2DP2_h=DbhGd2DP1_h[.,1],coeficientes[i0..i,.]
DbhGd2DP2_h=select(DbhGd2DP2_h,DbhGd2DP1_h[.,2]:==0)
DbhGd2DP3_h=DbhGd2DP1_h[.,1],criterios[i0..i,.]
DbhGd2DP3_h=select(DbhGd2DP3_h,DbhGd2DP1_h[.,2]:==0)
_6jL7DUnX(DbhGd2DP1_h,DbhGd2DP3_h[.,2::cols(DbhGd2DP3_h)],(data[.,tipo[1,1]::tipo[2,1]]),nodos=.) 
DbhGd2DP1_ter=select(DbhGd2DP1_h[.,1],DbhGd2DP1_h[.,2]:==0)
DbhGd2DP2_ter=DbhGd2DP2_h[.,2..cols(DbhGd2DP2_h)]
pred_v=rowsum((nodos[.,1]:==DbhGd2DP1_ter[.,1]'#J(rows(nodos),1,1)):*(regvar*DbhGd2DP2_ter'))	
e_v=data[.,1]-pred_v
num_ts=num_ts+1
pred=pred:+pred_v
e=e:+e_v
e2=e2:+(e_v:^2)
i0=i+1
i=i+1
 }							
 else i=i+1
 		}	
pred=pred:/num_ts
e=e:/num_ts
e2=e2:/num_ts
pred_sd=sqrt(e2-e:^2)
newvars = st_addvar(tipo1_s, (predicciones_s))
st_store(.,newvars,smpl_s,pred)
newvars = st_addvar(tipo2_s, (errstd_s))
st_store(.,newvars,smpl_s,pred_sd)
}	
                void _JdErLJSV(numeric matrix DbhGd2DP1, numeric matrix DbhGd2DP3_s, numeric matrix xs,numeric vector nodo) 
        {
        real matrix DbhGd2DP1_s,carac
real scalar ra,j,ra1,rn,i
nodo = J(rows(xs),2,0)
DbhGd2DP1_s=select(DbhGd2DP1,DbhGd2DP1[.,2]:==0)
ra = rows(DbhGd2DP1_s)
for (j=1; j<=ra; j++) {
carac=colshape(DbhGd2DP3_s[j,.],2)'        
nodo[.,1]=nodo[.,1]+DbhGd2DP1_s[j,1]*rowmin((xs:>=carac[1,.]):*(xs:<=carac[2,.]))
}
ra1 = rows(DbhGd2DP1)-1
for (j=1; j<=ra1; j++) {
if ((DbhGd2DP1[j,1]+1)<DbhGd2DP1[j+1,1]) {
DbhGd2DP1=DbhGd2DP1[1..j,.]\((j+1),-1,-1,-1)\DbhGd2DP1[j+1..ra1+1,.]
ra1=ra1+1
}
}
rn=rows(nodo)
for (i=1; i<=rn; i++) {
if (nodo[i,1] == 0) {
j=1
while (j!=0) {	
if (DbhGd2DP1[j,2]==0) {  
nodo[i,1]=DbhGd2DP1[j,1]
nodo[i,2]=1
j=0
}
else {
if (xs[i,DbhGd2DP1[j,3]]<=DbhGd2DP1[j,4]) j=DbhGd2DP1[j,2]    
else j=DbhGd2DP1[j,2]+1			
}
}
}
}
}	
        void _5HA5zRFB(string scalar depvar_s, string scalar splvar_s, string scalar smpl_s,	///
string scalar DbhGd2DPol_s,string scalar coeficientes_s,string scalar criterios_s,	///
string scalar clases_s,string scalar predicciones_s,string scalar typlist_s)
       {
                real matrix splvar,data,DbhGd2DP1_h,DbhGd2DP2_h,DbhGd2DP3_h,nodos,DbhGd2DP1_ter,predicciones
real vector depvar,clases,constante		
real scalar no,newvars
depvar=st_data(.,tokens(depvar_s),smpl_s)
clases=st_matrix(clases_s)
no=rows(depvar)
constante=J(no,1,1)
        if (splvar_s=="") splvar=constante
        else splvar = st_data(., tokens(splvar_s),smpl_s)
        data=depvar,splvar
DbhGd2DP1_h=st_matrix(DbhGd2DPol_s)
DbhGd2DP2_h=st_matrix(coeficientes_s)
DbhGd2DP3_h=st_matrix(criterios_s)
_JdErLJSV(DbhGd2DP1_h,DbhGd2DP3_h[.,2::cols(DbhGd2DP3_h)],(data[.,2::cols(data)]),nodos=.) 
DbhGd2DP1_ter=select(DbhGd2DP1_h[.,1],DbhGd2DP1_h[.,2]:==0)
predicciones=(nodos[.,1]:==DbhGd2DP1_ter[.,1]'#J(rows(nodos),1,1))*DbhGd2DP2_h[.,2]	
newvars = st_addvar(typlist_s, (predicciones_s))
st_store(.,newvars,smpl_s,predicciones)
}	

        void _S9chQUZv(string scalar depvar_s, string scalar splvar_s, string scalar smpl_s,	///
string scalar matatree,	string scalar clases_s,string scalar predicciones_s,	///
string scalar errstd_s,string scalar tipo1_s,string scalar tipo2_s)
       {
                real matrix DbhGd2DPoles,criterios,coeficientes,DbhGd2DP1_h,DbhGd2DP2_h,DbhGd2DP3_h,nodos,DbhGd2DP1_ter,	///
pred_v,splvar,data,pred
real vector depvar,clases,constante,misspr,misspr_v
real scalar fh,q,no,no_DbhGd2DP,num_ts,i0,i,j,newvars
fh=fopen(matatree, "r")
DbhGd2DPoles=fgetmatrix(fh)
criterios=fgetmatrix(fh)
coeficientes=fgetmatrix(fh)
fclose(fh)
no_DbhGd2DP=rows(DbhGd2DPoles)
depvar=st_data(.,tokens(depvar_s),smpl_s)
clases=st_matrix(clases_s)		
q=cols(clases)
no=rows(depvar)
constante=J(no,1,1)
        if (splvar_s=="") splvar=constante
        else splvar = st_data(., tokens(splvar_s),smpl_s)
        data=depvar,splvar
pred=J(no,q,0)
misspr=J(no,1,0)
num_ts=0
i0=1
i=i0
    	while (i<=no_DbhGd2DP-1) {
 if ((i+1==no_DbhGd2DP) | (DbhGd2DPoles[i+1,1]!=DbhGd2DPoles[i,1]+1)) {	
if (i+1==no_DbhGd2DP) i=i+1
DbhGd2DP1_h=DbhGd2DPoles[i0..i,.]
DbhGd2DP2_h=coeficientes[i0..i,.]
DbhGd2DP2_h=select(DbhGd2DP2_h,DbhGd2DP1_h[.,2]:==0)
DbhGd2DP3_h=criterios[i0..i,.]
DbhGd2DP3_h=select(DbhGd2DP3_h,DbhGd2DP1_h[.,2]:==0)
_JdErLJSV(DbhGd2DP1_h,DbhGd2DP3_h[.,2::cols(DbhGd2DP3_h)],(data[.,2::cols(data)]),nodos=.) 	
DbhGd2DP1_ter=select(DbhGd2DP1_h[.,1],DbhGd2DP1_h[.,2]:==0)
pred_v=(nodos[.,1]:==DbhGd2DP1_ter[.,1]'#J(rows(nodos),1,1))*DbhGd2DP2_h[.,2]		
misspr_v=(nodos[.,1]:==DbhGd2DP1_ter[.,1]'#J(rows(nodos),1,1))*DbhGd2DP2_h[.,3]		
num_ts=num_ts+1
pred=pred:+(pred_v:==clases#J(no,1,1))
misspr=misspr:+misspr_v
i0=i+1
i=i+1
 }		
 else i=i+1
 		}	
    	for (i=1; i<=q; i++) {		
j =( i==1 ? J(no,1,clases[1,1]) : ((j:*(pred[.,1]:>=pred[.,i])):+(clases[1,i]:*(pred[.,1]:<pred[.,i]))))
pred[.,1]= ((pred[.,1]:*(pred[.,1]:>=pred[.,i])):+(pred[.,i]:*(pred[.,1]:< pred[.,i])))
}
pred=j
misspr=misspr:/num_ts
newvars = st_addvar(tipo1_s, (predicciones_s))
st_store(.,newvars,smpl_s,pred)
newvars = st_addvar(tipo2_s, (errstd_s))
st_store(.,newvars,smpl_s,misspr)
}	
end	
exit	
