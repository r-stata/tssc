cap prog drop gprefscode
program define gprefscode 
version 7.0
	gprefs query `1'
	local parlist "symmag_p symmag_T symmag_d symmag_S symmag_o symmag_O symmag_x symmag_all pen9_thick pen9_color pen8_thick pen8_color pen7_thick pen7_color pen6_thick pen6_color pen5_thick pen5_color pen4_thick pen4_color pen3_thick pen3_color pen2_thick pen2_color pen1_thick pen1_color background_color "
	foreach par in `parlist' {
		di "gprefs set `1' `par'  `r(`par')' "
	}
end
*gprefscode custom1
