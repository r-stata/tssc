*! version 1.0.0 TJS 9jun2000
program define ncf
  version 6.0

di _n in bl "ncf is not an executable program."
di _n in bl "Available non-central F programs are:"
di _n in wh "   ncfprob F' lambda v1 v2" in bl "     /* yields p"
di _n in wh "   ncfinv  p lambda v1 v2" in bl "      /* yields F'"
di _n in wh "   ncfncp  F' p v1 v2" in bl "          /* yields lambda"
di _n in wh "   ncfn    F' lambda p v1" in bl "      /* yields v2"
di
exit 119
end
