*! version 1.0  2019-03-14 Mark Chatfield

program power_cmd_tworates_zhu_init, sclass
version 15
sreturn clear
sreturn local pss_numopts "r1 DISPersion irr DURation VARMethod"
sreturn local pss_allcolnames "alpha power N N1 N2 nratio r1 r2 IRR dispersion duration varmethod delta"
sreturn local pss_alltabcolnames "alpha power N N1 N2 IRR r1 r2 duration dispersion"
sreturn local pss_delta "IRR"
*above helpful for graphs
sreturn local pss_titletest " for the comparison of rates using negative binomial regression"
sreturn local pss_samples "twosample"
end
