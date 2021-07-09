
capture program drop pvcalc
program pvcalc

version 14.1

args osser tavola kk

mat numero = `tavola'[1...,1], `tavola'[1...,`kk'+1+1]
local uno = 0
if `osser' <= `tavola'[1,`kk'+2] {
    local pv = 1
	local uno = `uno' + 1
	}
if `osser' >= `tavola'[34,`kk'+2] {
    local pv = 0
	local uno = `uno' + 1
	}
if `uno' == 0 {
    local rigalmax = 0
	while numero[`rigalmax'+1,2] <= `osser' {
	    local rigalmax = `rigalmax' + 1 
		}
    mat riga = `rigalmax' \ `rigalmax'+1
	mat sel = `tavola'[`rigalmax'..`rigalmax'+1, 1], `tavola'[`rigalmax'..`rigalmax'+1, `kk'+1+1]
	local pv=sel[2,1]+(sel[2,2]-`osser')*(sel[1,1]-sel[2,1])/(sel[2,2]-sel[1,2])
	}

scalar pvalue = `pv'
scalar result_pvcalc = `pv'

disp as text "p-values of TVP and Optimal tests is:"
disp pvalue

end

