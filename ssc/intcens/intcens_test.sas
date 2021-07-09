
proc import datafile="....txt" out=test;
run;

proc lifereg data=test;
model (t0, t1)=drug age/dist=exp;
run;
proc lifereg data=test;
model (t0, t1)=drug age/dist=weibull;
run;
proc lifereg data=test;
model (t0, t1)=drug age/dist=llogistic;
run;
proc lifereg data=test;
model (t0, t1)=drug age/dist=lnormal;
run;
proc lifereg data=test;
model (t0, t1)=drug age/dist=gamma;
run;

/* get interval-censored 2-parameter gamma estimates 
	using the shape parameter estimated in Stata */
/* standard errors won't be the same, since the shape parameter is fixed */
%let a=4.193206;
%let b=%sysevalf(1/%sysfunc(sqrt(&a))); 
proc lifereg data=test;
model (t0, t1)=drug age/dist=gamma noscale noshape1 scale=&b shape1=&b;
run;

