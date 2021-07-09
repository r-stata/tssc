cap program drop mrprjlik
program define mrprjlik
version 10
args lnf xbo xbfp xbfn

quietly replace `lnf'=(1-$ML_y2)*($ML_y1*ln(normal(`xbfp'))+(1-$ML_y1)*ln(normal(-`xbfp')))+$ML_y2*($ML_y1*ln(normal(-`xbfn'))+(1-$ML_y1)*ln(normal(`xbfn'))) if $Samp==1
quietly replace `lnf'=(1-$ML_y2)*($ML_y1*ln(normal(`xbfp'))+(1-$ML_y1)*ln(normal(-`xbfp')))+$ML_y2*($ML_y1*ln(normal(-`xbfn'))+(1-$ML_y1)*ln(normal(`xbfn')))+$ML_y2*ln(normal(`xbo'))+(1-$ML_y2)*ln(normal(-`xbo')) if $Samp==2
quietly replace `lnf'=$ML_y1*ln(normal(`xbfp')+(1-normal(`xbfp')-normal(`xbfn'))*normal(`xbo'))+(1-$ML_y1)*ln(normal(`xbfn')+(1-normal(`xbfp')-normal(`xbfn'))*normal(-`xbo')) if $Samp==3
end
