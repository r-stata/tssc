program define PCM010402_lf 
version 8.2
args lnf tht1 tht2 tht3
tempvar etht1 etht2 etht3 tt tt0 pi k k0 dk dk0
local  t "$ML_y1"
local  d "$ML_y2"
local t0 "$ML_y3"
local lc "$ML_y4"
quietly {
gen double `etht1' = exp(`tht1')
gen double `etht2' = exp(`tht2')
gen double `etht3' = exp(`tht3')
gen double `tt' = (`t')/`etht2'
gen double `tt0' = (`t0')/`etht2'
gen double `pi' = exp(-1*`etht1')
gen double `k'  = gammap(`etht3',`tt')
gen double `k0' = gammap(`etht3',`tt0')
replace    `k0' = 0 if `tt0'==0
gen double `dk' = gammaden(`etht3',`etht2',0,`t')
replace `lnf' = (ln(-1*ln(`pi'))+`k'*ln(`pi')+ln(`dk'))-(`k0'*ln(`pi')) if `d'==1 & `lc'==0
replace `lnf' = (`k'*ln(`pi'))-(`k0'*ln(`pi')) if `d'==0 & `lc'==0
replace `lnf' = (ln((`pi'^`k0')-(`pi'^`k')))-(`k0'*ln(`pi')) if `d'==1 & `lc'==1
}
end
