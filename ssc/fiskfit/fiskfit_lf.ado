*! version 1.0.0 MLB 29Dec2007
*! Fitting of Fisk distribution by ML
*! Called by fiskfit.ado

program define fiskfit_lf

        version 8.2
        args lnf a b

        quietly replace `lnf' = ln(`a') + ln(1) + `a'*ln(`b') ///
                - (`a'+1)*ln($S_mlinc)  /// 
                - (2)*ln(1+(`b'/$S_mlinc)^(`a'))

end
