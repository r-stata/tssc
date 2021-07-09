*! version 1.0.0 TJS 9jun2000
program define nct
  version 6.0

di _n in bl "nct is not an executable program."
di _n in bl "Available non-central t programs are:"
di _n in wh "   nctprob t' delta df" in bl "     /* yields p"
di _n in wh "   nctinv  p delta df" in bl "      /* yields t'"
di _n in wh "   nctncp  t' p df" in bl "         /* yields delta"
di _n in wh "   nctn    t' delta p" in bl "      /* yields v2"
di _n in wh "   nct2    t' delta df" in bl "     /* yields two-sided p"
di _n in wh "   nct2inv p delta df" in bl "      /* yields two-sided t'"
di
exit 119
end
 