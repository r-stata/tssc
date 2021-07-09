program complogitml
	version 8
	args lnf theta delta
	quietly replace `lnf'= 				///
	$ML_y1 * `theta' * (1+`delta')- 		///
	ln(1+exp(`theta' * (1+`delta')))
end


