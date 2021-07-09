*! MLB 1.0.2 29 Okt 2009
*! MLB 1.0.1 05 Sep 2006
*! MLB 1.0.0 13 Nov 2005
  program betareg_lf
	version 8.2
	args lnf mu ln_phi
  qui replace `lnf' = ///
  lngamma(exp(`ln_phi')) - lngamma(invlogit(`mu')*exp(`ln_phi'))-lngamma(invlogit(-1*`mu')*exp(`ln_phi')) ///
  + (invlogit(`mu')*exp(`ln_phi')-1)*ln($S_MLy) +(invlogit(-1*`mu')*exp(`ln_phi')-1)*ln(1-$S_MLy)

end
