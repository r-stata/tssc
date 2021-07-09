*! version 1.0  2019-10-31 Mark Chatfield

program ciwidth_cmd_proportions_mc_init, sclass
version 16
sreturn clear
sreturn local prss_allcolnames    "level N N1 N2 nratio p1 p2 true_ES halfwidth width Pr_width ES_type lbgt ublt power Pr_noCI"
sreturn local prss_alltabcolnames "level N N1 N2        p1 p2 true_ES halfwidth width Pr_width ES_type"
*above - what is stored
sreturn local prss_numopts "p1 p2 trueeffectsize effecttype halfwidth lbgt ubgt"
*above - options
*above helpful for graphs
sreturn local prss_title " for a two-sided CI for the difference (RD, RR* or OR*) between two proportions"
sreturn local prss_subtitle "Effect Size type (CI):  1 RD (observed_ES +- halfwidth), 2 RR & 3 OR (observed_ES ×/ halfwidth) -> *width = CI_ub/CI_lb = halfwidth^2"
sreturn local prss_samples "twosample"
end

