*Revealed comparative advantage (RCA) indices
*Version December 2013

program drop _all
program define rca
version 9
syntax varlist(max=1),j(varlist) m(varlist) index(name) [, by(varlist)]

marksample touse

qui sum `varlist'
        if r(min)<0{
                display as error "Negative values in varlist"
                exit 198
                    }

if "`index'"~="BRCA" & "`index'"~="SRCA" & "`index'"~="WRCA" & "`index'"~="ARCA"{
di as err "Please select appropriate revealed comparative advantage index"
	exit 198
	}

tempvar Xj Xjm Xk Xkm BI avg_BI

*Total exports of country j
qui egen `Xj' = sum(`varlist'), by(`j' `by')

*Total exports of country j (k category level)
egen `Xjm'=sum(`varlist'), by( `m' `j' `by')

*Total world exports
qui egen `Xk' = sum(`varlist'), by(`by')

*Total world exports of product k
qui egen `Xkm'=sum(`varlist'), by( `m' `by')

qui gen `BI'=(`Xjm'/`Xj')/(`Xkm'/`Xk')

*Average BI for country `j'
egen `avg_BI'=mean(`BI'), by(`j' `by')

if "`index'"=="BRCA" {

*Balassa revealed comparative advantage (BRCA) index
qui gen `varlist'_brca=(`Xjm'/`Xj')/(`Xkm'/`Xk')
lab var `varlist'_brca "Balassa Revealed Comparative Advantage"
}

if "`index'"=="SRCA" {

*Normalized RCA index (SRCA)
qui gen `varlist'_srca= (`BI'-1)/(`BI'+1)
lab var `varlist'_srca "Symmetric Revealed Comparative Advantage"
}

if "`index'"=="WRCA" {

*Weighted RCA index (WRCA)
qui gen `varlist'_wrca= `BI'/`avg_BI'
lab var `varlist'_wrca "Weighted Revealed Comparative Advantage"
}

if "`index'"=="ARCA" {

*Additive Revealed comparative advantage (ARCA) index
qui gen `varlist'_arca=(`Xjm'/`Xj')-(`Xkm'/`Xk')
lab var `varlist'_arca "Additive Revealed Comparative Advantage"
}

end
