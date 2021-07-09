* 1.0.1 TC 10 november 2006
program mehetprob
version 8
#delimit;

syntax, [NODiscrete];

if (e(cmd)!="hetprob") error 301;

local zeq lnsigma2;
matrix V=e(V);
matrix C=e(b);
matrix C=C';
matrix D=C; /* D saves whether a variable is a dummy or not.*/
local xeq: roweq C;
local xeq=word("`xeq'",1);
local names: rownames C;
matrix DER=C*C';
matrix DER=DER , J(rowsof(DER),2,0);

matrix B=C["`xeq':",1];
matrix B=B[1..rowsof(B)-1,1..colsof(B)]; /*Konstante löschen damit sie nicht in Definition von xvar dazukommt*/
matrix G=C["lnsigma2:",1];

local xvar: rownames B;
local zvar: rownames G;
mat accum XBAR=`xvar'  if e(sample), means(XBAR);
mat accum ZBAR=`zvar'  if e(sample), means(ZBAR) nocons;


foreach i of any `xvar'{;         /*Matrix D zeigt an ob Dummies (1) oder nicht (0)*/
cap assert `i'==0 | `i'==1 if e(sample);
local j=0;
if  _rc==0 {;
	 local j=1;
	 };
mat D[rownumb(matrix(DER),"`xeq':`i'"),1]=`j';
};

foreach i of any `zvar'{;
local j=inlist(`i',0,1);
mat D[rownumb(matrix(DER),"`zeq':`i'"),1]=`j';
};
mat D[rownumb(matrix(DER),"`xeq':_cons"),1]=0;

matrix B=C["`xeq':",1]; /*B-Vektor wieder mit Konstante definieren, damit x'b gebildet werden kann*/

/*Anzeigen der "Kreuzpunkte" im Beta- und Gamma-Teil der Ableitungsmatrix Matrix durch Spaltenindikatoren in den letzten Spalten*/
foreach i of any `names'{;
capture matrix DER[rownumb(matrix(DER),"`xeq':`i'"),colsof(DER)-1]=colnumb(matrix(DER),"`xeq':`i'");
capture matrix DER[rownumb(matrix(DER),"`zeq':`i'"),colsof(DER)-1]=colnumb(matrix(DER),"`xeq':`i'");

capture matrix DER[rownumb(matrix(DER),"`xeq':`i'"),colsof(DER)]=colnumb(matrix(DER),"`zeq':`i'");
capture matrix DER[rownumb(matrix(DER),"`zeq':`i'"),colsof(DER)]=colnumb(matrix(DER),"`zeq':`i'");
};

matrix C=C,J(rowsof(C),6,0);
foreach i of any `names'{;
capture matrix C[rownumb(matrix(C),"`xeq':`i'"),2]=C[rownumb(matrix(C),"`zeq':`i'"),1];
};
foreach i of any `names'{;
capture matrix C[rownumb(matrix(C),"`zeq':`i'"),2]=C[rownumb(matrix(C),"`zeq':`i'"),1];
};
foreach i of any `names'{;
capture matrix C[rownumb(matrix(C),"`zeq':`i'"),1]=C[rownumb(matrix(C),"`xeq':`i'"),1];
};
local torow=rowsof(C);
local tocol=colsof(C);
foreach i of numlist 1/`torow'{;
foreach j of numlist 1/`tocol'{;
if (C[`i',`j']==.) matrix C[`i',`j']=0;
};
};
matrix C[1,3]=XBAR';
matrix C[colsof(XBAR)+1,3]=ZBAR';
matrix colnames C=beta gamma xbar me se(me) z P-Val;

matrix XB= XBAR*B;
matrix ZG= ZBAR*G;
local xb=XB[1,1];
local zg=ZG[1,1];
local exp=exp(`zg');
local f=normden(`xb'/`exp');
local F=norm(`xb'/`exp');


/*Marginalen Effekt einfügen*/
	local to=rowsof(C);

		foreach i of numlist 1/`to'{;                         /*Dummies als kontinuierliche Variablen*/
		matrix C[`i',4]=`f'/`exp'*(C[`i',1]-`xb'*C[`i',2]); 
		};


		if "`nodiscrete'"!="nodiscrete" {;                    /*Wenn Dummies als diskrete, dann überschreiben*/

			foreach n of any `names'{;

			local i=rownumb(matrix(C),"`xeq':`n'");
			local j=rownumb(matrix(C),"`zeq':`n'")-colsof(XBAR);

			if (D[`i',1]==1 | D[colsof(XBAR)+`j',1]==1 ){;
			capture local xold=XBAR[1,`i'];     /* xb0,xb1,zg0 und zg1 berechnen durch ersetzen des MW mit 0 und 1*/
			capture local zold=ZBAR[1,`j'];
			capture mat XBAR[1,`i']=0;
			capture mat ZBAR[1,`j']=0;
			capture matrix XBx= XBAR*B;
			capture matrix ZGx= ZBAR*G;
			capture local xb0=XBx[1,1];
			capture local zg0=ZGx[1,1];

			capture mat XBAR[1,`i']=1;
			capture mat ZBAR[1,`j']=1;
			capture matrix XBx= XBAR*B;
			capture matrix ZGx= ZBAR*G;
			capture local xb1=XBx[1,1];
			capture local zg1=ZGx[1,1];

			capture mat XBAR[1,`i']=`xold';    /* Wieder alte Mittelwerte in XBAR und ZBAR*/
			capture mat ZBAR[1,`j']=`zold';
			capture mat drop XBx ZGx;

			capture matrix C[rownumb(matrix(C),"`xeq':`n'"),4]=norm(`xb1'/exp(`zg1'))-norm(`xb0'/exp(`zg0'));
			capture matrix C[rownumb(matrix(C),"`zeq':`n'"),4]=norm(`xb1'/exp(`zg1'))-norm(`xb0'/exp(`zg0'));
			};
			};
		};




/*Matrix der Ableitungen berechnen.*/
local to=colsof(XBAR);
local torow=rowsof(C);
local tocol=colsof(XBAR);
foreach i of numlist 1/`torow'{;
foreach j of numlist 1/`tocol'{;
/*Block der Ableitungen nach Beta*/
matrix DER[`i',`j']=cond(`j'-DER[`i',colsof(DER)-1],0,1)*`f'/`exp'-C[`i',1]*C[`j',3]*`xb'*`f'/(`exp'^3)-C[`i',2]*C[`j',3]*`f'/`exp'*(1-(`xb')^2/(`exp')^2);
};
};
local to=rowsof(C);
local fromcol=colsof(XBAR)+1;
foreach i of numlist 1/`to'{;
foreach j of numlist `fromcol'/`to'{;
/*Block der Ableitungen nach Gamma*/
matrix DER[`i',`j']=(C[`i',1]-`xb'*C[`i',2])*C[`j',3]*`f'/`exp'*((`xb')^2/(`exp')^2-1)-cond(`j'-DER[`i',colsof(DER)],0,1)*`f'*`xb'/`exp';
};
};

matrix DER=DER[1..rowsof(DER),1..colsof(DER)-2]; /*Indikatorspalten wieder löschen.*/

		if "`nodiscrete'"!="nodiscrete" {;                    /*Wenn Dummies als diskrete, dann überschreiben*/

			foreach n of any `names'{;

			local i=rownumb(matrix(DER),"`xeq':`n'");
			local j=rownumb(matrix(DER),"`zeq':`n'")-colsof(XBAR);

			if (D[`i',1]==1 | D[colsof(XBAR)+`j',1]==1 ){;
			local to=colsof(DER);
			foreach m of numlist 1/`to'{;
			
			capture local xold=XBAR[1,`i'];     /* xb0,xb1,zg0 und zg1 berechnen durch ersetzen des MW mit 0 und 1*/
			capture local zold=ZBAR[1,`j'];
			capture mat XBAR[1,`i']=0;
			capture mat ZBAR[1,`j']=0;
			capture matrix XBx= XBAR*B;
			capture matrix ZGx= ZBAR*G;
			capture local xb0=XBx[1,1];
			capture local zg0=ZGx[1,1];
			mat GBAR0=XBAR,ZBAR;

			capture mat XBAR[1,`i']=1;
			capture mat ZBAR[1,`j']=1;
			capture matrix XBx= XBAR*B;
			capture matrix ZGx= ZBAR*G;
			capture local xb1=XBx[1,1];
			capture local zg1=ZGx[1,1];
			mat GBAR1=XBAR,ZBAR;
			
			if (`m'<=colsof(XBAR)) {;
			capture matrix DER[rownumb(matrix(DER),"`xeq':`n'"),`m']=GBAR1[1,`m']*normden(`xb1'/exp(`zg1'))/exp(`zg1') - GBAR0[1,`m'] *normden(`xb0'/exp(`zg0'))/exp(`zg0');
			capture matrix DER[rownumb(matrix(DER),"`zeq':`n'"),`m']=GBAR1[1,`m']*normden(`xb1'/exp(`zg1'))/exp(`zg1') - GBAR0[1,`m'] *normden(`xb0'/exp(`zg0'))/exp(`zg0');
			};
			else {;
			capture matrix DER[rownumb(matrix(DER),"`xeq':`n'"),`m']=-GBAR1[1,`m']*`xb1'*normden(`xb1'/exp(`zg1'))/exp(`zg1') + GBAR0[1,`m']*`xb0'*normden(`xb0'/exp(`zg0'))/exp(`zg0');
			capture matrix DER[rownumb(matrix(DER),"`zeq':`n'"),`m']=-GBAR1[1,`m']*`xb1'*normden(`xb1'/exp(`zg1'))/exp(`zg1') + GBAR0[1,`m']*`xb0'*normden(`xb0'/exp(`zg0'))/exp(`zg0');
			};

			capture mat XBAR[1,`i']=`xold';    /* Wieder alte Mittelwerte in XBAR und ZBAR*/
			capture mat ZBAR[1,`j']=`zold';
			capture mat drop XBx ZGx GBAR0 GBAR1;
			};
			};
			};
		};


matrix C[1,5]=vecdiag(DER*V*DER')';
local to=rowsof(C);
foreach i of numlist 1/`to'{;
matrix C[`i',5]=sqrt(C[`i',5]); 
};


local to=rowsof(C);
foreach i of numlist 1/`to'{;
matrix C[`i',6]=C[`i',4]/C[`i',5]; 
};
local to=rowsof(C);
foreach i of numlist 1/`to'{;
matrix C[`i',7]=(1-norm(abs(C[`i',6])))*2; 
};

matrix C=C[1..rowsof(C),4..7];

if "`nodiscrete'"!="nodiscrete" {;
	foreach n of any `names'{;
	local i=rownumb(matrix(C),"`xeq':`n'");
	local j=rownumb(matrix(C),"`zeq':`n'");
	if (D[`i',1]==1 | D[`j',1]==1){;
	local names: subinstr local names "`n'" "`n'*", all word;
	};
	};
	matrix rownames C= `names';
};


mat C1=C[1..rownumb(matrix(C),"`xeq':_cons")-1,1..colsof(C)];     /*Zeile der Konstante löschen*/
mat C2=C[rownumb(matrix(C),"`xeq':_cons")+1..rowsof(C),1..colsof(C)];
mat C=C1\C2;
/*mat drop C1 C2 ZG XB B V G D;*/
local names: subinstr local names "_cons" "", all word; /*Name der Konstante löschen*/


quietly sum `xeq' if e(sample);
di _newline "Dependent variable:" _col(35) "`e(depvar)'";
display "P(Y=1) in sample: " _col(35) r(mean);
quietly predict tempvar if e(sample);
quietly sum tempvar if e(sample);
drop tempvar;
display "P(Y=1) mean of model prediction: " _col(35)  r(mean);

display "P(Y=1) predicted at means: " _col(35)   `F';
di "";
di "dP/dX - Marginal effect at means after heteroscedastic probit estimation:";
di "";
di in text  "    Variable {c |}       dP/dX        s.e.          z       P";
di in text "{hline 13}{c +}{hline 44}";
local to=rowsof(C);
foreach i of numlist 1/`to'{;
local n: word `i' of `names';
if (rownumb(matrix(C),"`xeq':`n'")==`i' | rownumb(matrix(C),"`xeq':`n'")==.){; /*Diese Bedingung läßt Doppelte weg*/
di in text %12s abbrev("`n'",12) " {c |}   " as result %9.0g C[`i', 1] "   " %9.0g C[`i', 2] "   " %9.2f C[`i', 3] "   "  %5.3f C[`i', 4] "   " ;
};
};
di in text "{hline 13}{c BT}{hline 44}";

if "`nodiscrete'"!="nodiscrete" {;
di "(*) dP/dx is for discrete change of dummy variable from 0 to 1";
};

end;
