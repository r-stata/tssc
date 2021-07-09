*****************************
**** Configuracion inicial
*****************************

clear
set mem 2m
set matsize 500
set more off

************************************************
**** inicializando las bases de datos
************************************************

local path "c:\"

use "`path'es04.dta", clear
gen ano=2004
append using "`path'es01.dta"
replace ano=2001 if ano==.

****************************************************************************
*** simulação de mudancas na renda média e na desigualdade de renda
****************************************************************************


changemean rdpc [fw=int(pesopes)], by(ano)
changemean rdpc [fw=int(pesopes)], by(ano) h
changemean rdpc [fw=int(pesopes)], by(ano) h2
changemean rdpc [fw=int(pesopes)], by(ano) pgr
changemean rdpc [fw=int(pesopes)], by(ano) igr
changemean rdpc [fw=int(pesopes)], by(ano) w
changemean rdpc [fw=int(pesopes)], by(ano) fgt1
changemean rdpc [fw=int(pesopes)], by(ano) fgt2
changemean rdpc [fw=int(pesopes)], by(ano) fgt3
changemean rdpc [fw=int(pesopes)], by(ano) fgt4
changemean rdpc [fw=int(pesopes)], by(ano) fgt5
changemean rdpc [fw=int(pesopes)], by(ano) fgt6
changemean rdpc [fw=int(pesopes)], by(ano) fgt7
changemean rdpc [fw=int(pesopes)], by(ano) fgt8
changemean rdpc [fw=int(pesopes)], by(ano) fgt9
changemean rdpc [fw=int(pesopes)], by(ano) chu1
changemean rdpc [fw=int(pesopes)], by(ano) chu2
changemean rdpc [fw=int(pesopes)], by(ano) chu3
changemean rdpc [fw=int(pesopes)], by(ano) chu4
changemean rdpc [fw=int(pesopes)], by(ano) chu5
changemean rdpc [fw=int(pesopes)], by(ano) s
changemean rdpc [fw=int(pesopes)], by(ano) thon
changemean rdpc [fw=int(pesopes)], by(ano) tak
