cap program drop mrprlik
program define mrprlik
version 10
args lnf xb alpha0 alpha1

if "$tco"=="tco" quietly replace `lnf'=$ML_y1*ln((1-`alpha1')*normal(`xb')+`alpha1'*normal(-`xb'))+(1-$ML_y1)*ln((1-`alpha0')*normal(-`xb')+`alpha0'*normal(`xb'))
else quietly replace `lnf'=$ML_y1*ln(invlogit(`alpha0')+(1-invlogit(`alpha0')-invlogit(`alpha1'))*normal(`xb'))+(1-$ML_y1)*ln(invlogit(`alpha1')+(1-invlogit(`alpha0')-invlogit(`alpha1'))*normal(-`xb'))
end
