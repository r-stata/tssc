program define zoib_lf
	version 8.2
	args lnf proportion oneinflate zeroinflate ln_phi
	tempvar mu muprime phi

	quietly gen double `mu' = invlogit(`proportion')
	quietly gen double `muprime' = invlogit(-`proportion')
	quietly gen double `phi' = exp(`ln_phi')

	quietly replace `lnf' =  ///
	        lngamma(`phi') - lngamma(`mu'*`phi')-lngamma(`muprime'*`phi')       ///
                + (`mu'*`phi'-1)*ln($ML_y1) +(`muprime'*`phi'-1)*ln(1-$ML_y1)   ///
				+ ln(invlogit(- `oneinflate')) + ln(invlogit( - `zeroinflate')) ///
                                 if ($ML_y1 < 1 & $ML_y1 > 0)
	quietly replace `lnf' =  ln(invlogit(`oneinflate'))         ///
                                 if ($ML_y1 == 1) 
    quietly replace `lnf' =  ln(invlogit(`zeroinflate'))        ///
                                 if ($ML_y1 == 0) 
end


