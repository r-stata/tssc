
use mheart8s0 , clear
cd _output

* Create seperate directories for each imputation
mkdir imp`1'
	cd imp`1'
	
mi set flongsep imp`1'

set rngstream `1'
set seed 1
mi register imputed bmi age
mi impute chained (regress) bmi age = attack smokes hsgrad female, add(1)
					
use _1_imp`1' , clear
	drop _mi_id
		save _1_imp`1' , replace

erase imp`1'.dta
cd ..	
copy  imp`1'\_1_imp`1'.dta _1_imp`1'.dta , replace
erase imp`1'\_1_imp`1'.dta
rmdir imp`1'
cd ..


