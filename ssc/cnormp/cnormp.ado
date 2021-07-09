*! version 1.1 21oct2009 
*! computes mean,sd for censored normal creation
*! austinnichols@gmail.com
prog cnormp, rclass
version 10
syntax [anything] [, Censpoint(real 0) ]
tokenize `anything'
if real(`"`1'"')==. | `"`1'"'=="" error 198
if real(`"`2'"')<0 |real(`"`2'"')==. | `"`2'"'=="" error 198
tempname b
di as txt _n  "To produce a censored normal dist. with"
di "mean `1' and SD `2' and censoring"
di "point `censpoint', generate using an underlying"
di "normal distribution with"
mat `b'=(`1',`2')
qui mata: fobj("`b'")
return scalar s=`b'[1,2]
return scalar m=`b'[1,1]
di "mean " as res `b'[1,1] as txt " and SD " as res `b'[1,2]
end
version 10
mata:
void obj(todo,b,crit,g,H)
{
external x,y,tm,ts,b,c
m=b[1,1]
s=b[1,2]
F=normal((c-m)/s)
f=normalden((c-m)/s)
h=f/(1-F)
x=F*c+(1-F)*(m+h*s)
y=sqrt(F*(x-c)^2+(1-F)*s^2*(1-h*(h+(m-c)/s))+(1-F)*(m+h*s-x)^2)
crit=(tm-x)^2+(ts-y)^2
}
void fobj(string scalar beta)
{
external x,y,tm,ts,b,c
c=strtoreal(st_local("censpoint"))
init=st_matrix(beta)
tm=init[1,1]
ts=init[1,2]
S=optimize_init()
optimize_init_evaluator(S, &obj())
optimize_init_which(S,"min")
optimize_init_evaluatortype(S,"d0")
optimize_init_params(S,init)
p=optimize(S)
st_replacematrix(beta,p)
}
end
exit
