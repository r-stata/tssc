* 1.0.1 TC 16 november 2006
program meoprobit
version 9
#delimit;

syntax [if] [in], [NODiscrete stats(name) VARiance exp];
if (e(cmd)!="oprobit") error 301;
if ("`stats'"!="sd" & "`stats'" !="z" & "`stats'"!="p" & "`stats'"!="") error 198;
marksample touse;
tempvar group;
tempname V V2 VALL B DER DERALL C CUT D SE S ME XB XBAR XBx XBAR0 XBAR1 E PE SEE Y;
matrix `V'=e(V);
matrix `B'=e(b);
matrix `B'=`B'';
matrix `DER'=`B'*`B'';
local xeq: roweq `B';
local xeq=word("`xeq'",1);
matrix `C'=`B'["`xeq':",1];
mat `DER'=`DER'[1..rowsof(`C'),1..colsof(`DER')];
matrix `CUT'=`B'[rowsof(`C')+1..rowsof(`B'),1..1];
matrix `B'=`C';
matrix `D'=`C'; /* `D' saves whether a variable is a dummy or not.*/

local names: rownames `C';

local xvar: rownames `C';
mat accum `XBAR'=`xvar'  if e(sample) & `touse', means(`XBAR');
mat `XBAR'=`XBAR'[1..1,1..colsof(`XBAR')-1];

qui egen `group'=group(`e(depvar)') if e(sample) & `touse';
qui sum `group', meanonly;
local n=r(N);
qui sum `e(depvar)' if `group'==1, meanonly;
mat `Y'=r(mean);
mat PS=r(N)/`n';
qui su `group', meanonly;
foreach X of numlist 2 / `r(max)'{;
qui sum `e(depvar)' if `group'==`X';
mat `Y'=`Y',r(mean);
mat PS=PS,r(N)/`n';
};
mat `Y'=`Y'';


foreach i of any `xvar'{;         /*Matrix `D' zeigt an ob Dummies (1) oder nicht (0)*/
cap assert `i'==0 | `i'==1 if e(sample);
local j=0;
if  _rc==0 {;
	 local j=1;
	 };
mat `D'[rownumb(matrix(`DER'),"`xeq':`i'"),1]=`j';
};

matrix `XB'= `XBAR'*`B';
local xb=`XB'[1,1];


/* geschätzte Wahrscheinlichkeiten am Mittelwert berechnen:*/
matrix P=J(1,rowsof(`CUT')+1,0);
matrix rownames P="Prob at means";
matrix P[1,1]=norm(`CUT'[1,1]-`xb');

local bis=rowsof(`CUT');
foreach c of numlist 2/`bis' {;
matrix P[1,`c']=norm(`CUT'[`c',1]-`xb')-norm(`CUT'[`c'-1,1]-`xb');
};
matrix P[1,rowsof(`CUT')+1]=1-norm(`CUT'[rowsof(`CUT'),1]-`xb');


/*Marginalen Effekt einfügen*/

/* Hier probehalber Berechnungen für Kategorie 2*/

	/* Marginaler Effekt für Kategorie Nummer 1: */
	local to=rowsof(`C');

		foreach i of numlist 1/`to'{;                         /*Dummies als kontinuierliche Variablen*/
		matrix `C'[`i',1]=-normden(`CUT'[1,1]-`xb')*`B'[`i',1];
		};
	mat `ME'=`C';


   /* Marginaler Effekt für Zwischenkategorien : */
	local bis=rowsof(`CUT');
foreach c of numlist 2/`bis' {;
		foreach i of numlist 1/`to'{;                         /*Dummies als kontinuierliche Variablen*/
		matrix `C'[`i',1]=( normden(`CUT'[`c'-1,1]-`xb')-normden(`CUT'[`c',1]-`xb') )*`B'[`i',1];
		};
mat `ME'=`ME',`C';
};

   /* Marginaler Effekt für letzte Kategorie : */
		foreach i of numlist 1/`to'{;                         /*Dummies als kontinuierliche Variablen*/
		matrix `C'[`i',1]=( normden(`CUT'[`bis',1]-`xb'))*`B'[`i',1];
		local name=`bis'+1;
		};

mat `ME'=`ME',`C';


		if "`nodiscrete'"!="nodiscrete" {;                    /*Wenn Dummies als diskrete, dann überschreiben*/

			foreach n of any `names'{;

			local i=rownumb(matrix(`C'),"`xeq':`n'");

			if (`D'[`i',1]==1 ){;

			local xold=`XBAR'[1,`i'];     /* xb0,xb1,zg0 und zg1 berechnen durch ersetzen des MW mit 0 und 1*/
			mat `XBAR'[1,`i']=0;
			matrix `XBx'= `XBAR'*`B';
			local xb0=`XBx'[1,1];

			mat `XBAR'[1,`i']=1;
			matrix `XBx'= `XBAR'*`B';
			local xb1=`XBx'[1,1];

			/* Für erste Kategorie*/

			matrix `ME'[rownumb(matrix(`C'),"`xeq':`n'"),1]=norm(`CUT'[1,1]-`xb1')-norm(`CUT'[1,1]-`xb0');


			/* Für Mittelkategorien*/
			local bis=rowsof(`CUT');
			foreach c of numlist 2/`bis' {;
			matrix `ME'[rownumb(matrix(`C'),"`xeq':`n'"),`c']=norm(`CUT'[`c',1]-`xb1')-norm(`CUT'[`c'-1,1]-`xb1')
			 -(norm(`CUT'[`c',1]-`xb0')-norm(`CUT'[`c'-1,1]-`xb0'));
			};
			/* Für letzte Kategorie*/
			matrix `ME'[rownumb(matrix(`C'),"`xeq':`n'"),`bis'+1]=1-norm(`CUT'[`bis',1]-`xb1')
			 -(1-norm(`CUT'[`bis',1]-`xb0'));


			mat `XBAR'[1,`i']=`xold';    /* Wieder alte Mittelwerte in `XBAR' und ZBAR*/
			};
			};
		};


/*Matrix der Ableitungen berechnen.*/

/* Für erste Kategorie:*/
local c=1;
local xc  (`xb'-`CUT'[`c',1]);
local xc1 0;
local cx  (`CUT'[`c',1]-`xb');
local cx1 0;
local fcx  normden(`CUT'[`c',1]-`xb');
local fcx1 0;
local toi=rowsof(`B');
local toj=rowsof(`B')+rowsof(`CUT');

foreach i of numlist 1/`toi'{;
foreach j of numlist 1/`toj'{;

if ("`nodiscrete'"=="nodiscrete" | `D'[`i',1]==0) {;
	if (`j'<=rowsof(`B')) {; /* Ableitung nach beta Koeffizienten*/
	matrix `DER'[`i',`j']=cond(`i'-`j',(-`B'[`i',1]*`XBAR'[1,`j']*((`xc1'*`fcx1')-(`xc'*`fcx'))),((`fcx1'-`fcx')-`B'[`i',1]*`XBAR'[1,`j']*((`xc1'*`fcx1')-(`xc'*`fcx'))));
	};

	if (`j'>rowsof(`B') & `j'-rowsof(`B')==`c'-1) {; /* Ableitung nach Cutpoint cj-1 */
	matrix `DER'[`i',`j']=`xc1'*`fcx1'*`B'[`i',1];
	};
	if (`j'>rowsof(`B') & `j'-rowsof(`B')==`c') {; /* Ableitung nach Cutpoint cj */
	matrix `DER'[`i',`j']=`cx'*`fcx'*`B'[`i',1];
	};
	if (`j'>rowsof(`B') & `j'-rowsof(`B')~=`c' & `j'-rowsof(`B')~=`c'-1 ) {; /* Ableitung nach Cutpoint ck */
	matrix `DER'[`i',`j']=0;
	};
};
else{;
	local xold=`XBAR'[1,`i'];     /* xb0 und xb1 berechnen durch ersetzen des MW mit 0 und 1*/
	mat `XBAR'[1,`i']=0;
	matrix `XBx'= `XBAR'*`B';
	local xb0=`XBx'[1,1];
	mat `XBAR0'=`XBAR';
	mat `XBAR'[1,`i']=1;
	matrix `XBx'= `XBAR'*`B';
	local xb1=`XBx'[1,1];
	mat `XBAR1'=`XBAR';

	local fcx01  normden(`CUT'[`c',1]-`xb1');
	local fcx11  0;
	local fcx10  0;
	local fcx00  normden(`CUT'[`c',1]-`xb0');


	if (`j'<=rowsof(`B')) {; /* Ableitung Diskreter Fall nach beta Koeffizienten*/
	matrix `DER'[`i',`j']=-`XBAR1'[1,`j']*(`fcx01'-`fcx11')+`XBAR0'[1,`j']*(`fcx00'-`fcx10');
	};

	if (`j'>rowsof(`B') & `j'-rowsof(`B')==`c'-1) {; /* Ableitung Diskreter Fall nach Cutpoint cj-1 */
	matrix `DER'[`i',`j']=`fcx10'-`fcx11';
	};
	if (`j'>rowsof(`B') & `j'-rowsof(`B')==`c') {; /* Ableitung Diskreter Fall nach Cutpoint cj */
	matrix `DER'[`i',`j']=`fcx01'-`fcx00';
	};
	if (`j'>rowsof(`B') & `j'-rowsof(`B')~=`c' & `j'-rowsof(`B')~=`c'-1 ) {; /* Ableitung nach Cutpoint ck */
	matrix `DER'[`i',`j']=0;
	};

	mat `XBAR'[1,`i']=`xold';    /* Wieder alte Mittelwerte in `XBAR' und ZBAR*/
};


};
};
mat `DERALL'=`DER';
matrix `S'=vecdiag(`DER'*`V'*`DER'')';
local to=rowsof(`S');
foreach i of numlist 1/`to'{;
matrix `S'[`i',1]=sqrt(`S'[`i',1]); 
};
mat `SE'=`S';

/* Für Zwischenkategorien*/
local bis=rowsof(`CUT');
foreach c of numlist 2/`bis' {;
local xc  (`xb'-`CUT'[`c',1]);
local xc1 (`xb'-`CUT'[`c'-1,1]);
local cx  (`CUT'[`c',1]-`xb');
local cx1 (`CUT'[`c'-1,1]-`xb');
local fcx  normden(`CUT'[`c',1]-`xb');
local fcx1 normden(`CUT'[`c'-1,1]-`xb');

local toi=rowsof(`B');
local toj=rowsof(`B')+rowsof(`CUT');
foreach i of numlist 1/`toi'{;
foreach j of numlist 1/`toj'{;

if ("`nodiscrete'"=="nodiscrete" | `D'[`i',1]==0) {;

	if (`j'<=rowsof(`B')) {; /* Ableitung nach beta Koeffizienten*/
	matrix `DER'[`i',`j']=cond(`i'-`j',(-`B'[`i',1]*`XBAR'[1,`j']*((`xc1'*`fcx1')-(`xc'*`fcx'))),((`fcx1'-`fcx')-`B'[`i',1]*`XBAR'[1,`j']*((`xc1'*`fcx1')-(`xc'*`fcx'))));
	};

	if (`j'>rowsof(`B') & `j'-rowsof(`B')==`c'-1) {; /* Ableitung nach Cutpoint cj-1 */
	matrix `DER'[`i',`j']=`xc1'*`fcx1'*`B'[`i',1];
	};
	if (`j'>rowsof(`B') & `j'-rowsof(`B')==`c') {; /* Ableitung nach Cutpoint cj */
	matrix `DER'[`i',`j']=`cx'*`fcx'*`B'[`i',1];
	};
	if (`j'>rowsof(`B') & `j'-rowsof(`B')~=`c' & `j'-rowsof(`B')~=`c'-1 ) {; /* Ableitung nach Cutpoint ck */
	matrix `DER'[`i',`j']=0;
	};
};
else{;
	local xold=`XBAR'[1,`i'];     /* xb0 und xb1 berechnen durch ersetzen des MW mit 0 und 1*/
	mat `XBAR'[1,`i']=0;
	matrix `XBx'= `XBAR'*`B';
	local xb0=`XBx'[1,1];
	mat `XBAR0'=`XBAR';
	mat `XBAR'[1,`i']=1;
	matrix `XBx'= `XBAR'*`B';
	local xb1=`XBx'[1,1];
	mat `XBAR1'=`XBAR';

	local fcx01  normden(`CUT'[`c',1]-`xb1');
	local fcx11  normden(`CUT'[`c'-1,1]-`xb1');
	local fcx10  normden(`CUT'[`c'-1,1]-`xb0');
	local fcx00  normden(`CUT'[`c',1]-`xb0');


	if (`j'<=rowsof(`B')) {; /* Ableitung Diskreter Fall nach beta Koeffizienten*/
	matrix `DER'[`i',`j']=-`XBAR1'[1,`j']*(`fcx01'-`fcx11')+`XBAR0'[1,`j']*(`fcx00'-`fcx10');
	};

	if (`j'>rowsof(`B') & `j'-rowsof(`B')==`c'-1) {; /* Ableitung Diskreter Fall nach Cutpoint cj-1 */
	matrix `DER'[`i',`j']=`fcx10'-`fcx11';
	};
	if (`j'>rowsof(`B') & `j'-rowsof(`B')==`c') {; /* Ableitung Diskreter Fall nach Cutpoint cj */
	matrix `DER'[`i',`j']=`fcx01'-`fcx00';
	};
	if (`j'>rowsof(`B') & `j'-rowsof(`B')~=`c' & `j'-rowsof(`B')~=`c'-1 ) {; /* Ableitung nach Cutpoint ck */
	matrix `DER'[`i',`j']=0;
	};

	mat `XBAR'[1,`i']=`xold';    /* Wieder alte Mittelwerte in `XBAR' und ZBAR*/
};




};
};
mat `DERALL'=`DERALL' \ `DER';
matrix `S'=vecdiag(`DER'*`V'*`DER'')';
local to=rowsof(`S');
foreach i of numlist 1/`to'{;
matrix `S'[`i',1]=sqrt(`S'[`i',1]); 
};
mat `SE'=`SE',`S';

};


/* Für letzte Kategorie */
local c=`bis'+1;
local xc  0;
local xc1 (`xb'-`CUT'[`c'-1,1]);
local cx  0;
local cx1 (`CUT'[`c'-1,1]-`xb');
local fcx  0;
local fcx1 normden(`CUT'[`c'-1,1]-`xb');

local toi=rowsof(`B');
local toj=rowsof(`B')+rowsof(`CUT');
foreach i of numlist 1/`toi'{;
foreach j of numlist 1/`toj'{;

if ("`nodiscrete'"=="nodiscrete" | `D'[`i',1]==0) {;
	if (`j'<=rowsof(`B')) {; /* Ableitung nach beta Koeffizienten*/
	matrix `DER'[`i',`j']=cond(`i'-`j',(-`B'[`i',1]*`XBAR'[1,`j']*((`xc1'*`fcx1')-(`xc'*`fcx'))),((`fcx1'-`fcx')-`B'[`i',1]*`XBAR'[1,`j']*((`xc1'*`fcx1')-(`xc'*`fcx'))));
	};

	if (`j'>rowsof(`B') & `j'-rowsof(`B')==`c'-1) {; /* Ableitung nach Cutpoint cj-1 */
	matrix `DER'[`i',`j']=`xc1'*`fcx1'*`B'[`i',1];
	};
	if (`j'>rowsof(`B') & `j'-rowsof(`B')==`c') {; /* Ableitung nach Cutpoint cj */
	matrix `DER'[`i',`j']=`cx'*`fcx'*`B'[`i',1];
	};
	if (`j'>rowsof(`B') & `j'-rowsof(`B')~=`c' & `j'-rowsof(`B')~=`c'-1 ) {; /* Ableitung nach Cutpoint ck */
	matrix `DER'[`i',`j']=0;
	};
};
else{;
	local xold=`XBAR'[1,`i'];     /* xb0 und xb1 berechnen durch ersetzen des MW mit 0 und 1*/
	mat `XBAR'[1,`i']=0;
	matrix `XBx'= `XBAR'*`B';
	local xb0=`XBx'[1,1];
	mat `XBAR0'=`XBAR';
	mat `XBAR'[1,`i']=1;
	matrix `XBx'= `XBAR'*`B';
	local xb1=`XBx'[1,1];
	mat `XBAR1'=`XBAR';

	local fcx01  0;
	local fcx11  normden(`CUT'[`c'-1,1]-`xb1');
	local fcx10  normden(`CUT'[`c'-1,1]-`xb0');
	local fcx00  0;


	if (`j'<=rowsof(`B')) {; /* Ableitung Diskreter Fall nach beta Koeffizienten*/
	matrix `DER'[`i',`j']=-`XBAR1'[1,`j']*(`fcx01'-`fcx11')+`XBAR0'[1,`j']*(`fcx00'-`fcx10');
	};

	if (`j'>rowsof(`B') & `j'-rowsof(`B')==`c'-1) {; /* Ableitung Diskreter Fall nach Cutpoint cj-1 */
	matrix `DER'[`i',`j']=`fcx10'-`fcx11';
	};
	if (`j'>rowsof(`B') & `j'-rowsof(`B')==`c') {; /* Ableitung Diskreter Fall nach Cutpoint cj */
	matrix `DER'[`i',`j']=`fcx01'-`fcx00';
	};
	if (`j'>rowsof(`B') & `j'-rowsof(`B')~=`c' & `j'-rowsof(`B')~=`c'-1 ) {; /* Ableitung nach Cutpoint ck */
	matrix `DER'[`i',`j']=0;
	};

	mat `XBAR'[1,`i']=`xold';    /* Wieder alte Mittelwerte in `XBAR' und ZBAR*/
};



};
};
mat `DERALL'=`DERALL' \ `DER';

if ("`exp'"=="exp" | "`variance'"=="variance"){;
	mat `VALL'=`DERALL'*`V'*`DERALL'';
	mat V=`VALL';
	};

matrix `S'=vecdiag(`DER'*`V'*`DER'')';
local to=rowsof(`S');
foreach i of numlist 1/`to'{;
matrix `S'[`i',1]=sqrt(`S'[`i',1]); 
};

mat `SE'=`SE',`S';


if "`nodiscrete'"!="nodiscrete" {;
	foreach n of any `names'{;
	local i=rownumb(matrix(`C'),"`xeq':`n'");
	local j=rownumb(matrix(`C'),"`zeq':`n'");
	if (`D'[`i',1]==1 | `D'[`j',1]==1){;
	local names: subinstr local names "`n'" "`n'*", all word;
	};
	};
	matrix rownames `ME'= `names';
	matrix rownames `SE'= `names';
};



mat roweq `ME'="ME";
mat roweq `SE'="SE";


if "`exp'"=="exp" {;
	mat `E'=J(rowsof(`B'),1,0);
	mat `SEE'=J(rowsof(`B'),1,0);
	local toj=rowsof(`B');
	mat `V2'=J(rowsof(`CUT')+1,rowsof(`CUT')+1,0);
	foreach n of numlist 1/`toj'{;
		mat `E'[`n',1]=`Y'' * `ME'[`n'..`n',1..colsof(`ME')]';
		local toi=rowsof(`CUT')+1;
		foreach i of numlist 1/`toi'{;
		foreach j of numlist 1/`toi'{;
		mat `V2'[`i',`j']=`VALL'[(`i'-1)*rowsof(`B')+`n',(`j'-1)*rowsof(`B')+`n'];
		};
		};
		mat `SEE'[`n',1]=`Y'' * `V2' * `Y';
		mat `SEE'[`n',1]=sqrt(`SEE'[`n',1]);
	};

	mat `PE'=`Y'' * P';
	mat colnames `PE'=":E[Y]";
	mat P=P,`PE';
	mat `ME'=`ME',`E';
	mat `SE'=`SE',`SEE';
	mat PS=PS,`Y'' * PS';
};



local toi=rowsof(`ME');
local toj=colsof(`ME');

if ("`stats'"=="z" | "`stats'"=="p" ) {;
	foreach i of numlist 1/`toi'{;
	foreach j of numlist 1/`toj'{;
	mat `SE'[`i',`j']=round(`ME'[`i',`j']/`SE'[`i',`j'],0.01);
	};
	};
	mat roweq `SE'="Z";
	if ("`stats'"=="p" ) {;
	foreach i of numlist 1/`toi'{;
	foreach j of numlist 1/`toj'{;
	mat `SE'[`i',`j']=round((1-norm(abs(`SE'[`i',`j'])))*2,0.001);
	};
	};
	mat roweq `SE'="P";	
	};
};


mat RES=`ME'[1,1..colsof(`ME')];
matrix RES=RES \ `SE'[1..1,1..colsof(`SE')];
foreach i of numlist 2/`toi'{;
mat RES=RES \ `ME'[`i'..`i',1..colsof(`ME')];
mat RES=RES \ `SE'[`i'..`i',1..colsof(`ME')];
};

local names: colnames P;
mat rownames PS="  Sample Freq";
mat colnames RES=`names';
mat colnames PS=`names';

mat list PS;
mat list P;
mat list RES;
if "`nodiscrete'"!="nodiscrete" {;
di _newline "(*) dP/dx is for discrete change of dummy variable from 0 to 1";
};

end;
