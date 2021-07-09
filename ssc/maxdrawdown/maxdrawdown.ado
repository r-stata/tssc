capt program drop _all
mata: mata clear

version 13.1
mata:
mata set matastrict on
void down(string scalar varlist, ///
string scalar touse)
{
real colvector x,maxdrawdown
st_view(x,.,varlist,touse)
N=length(x)
drawdown=J(N,1,0)
for (i=2;i<=N;i++){
c=max(x[(1::i)])
if (c==x[i]){
drawdown[i]=0
}
else{
drawdown[i]=(x[i]-c)/c
}
}
maxdrawdown=min(drawdown);
st_numscalar("r(drawdown)",maxdrawdown[1])
}
end

program maxdrawdown,rclass
*! varextrema1.0.0
version 13.1
syntax varlist(numeric)[if] [in]
marksample touse
mata:down("`varlist'","`touse'")
display as txt "maxdrawdown(`varlist')=" as res r(drawdown)
return scalar maxdrawdown=r(drawdown)
end
