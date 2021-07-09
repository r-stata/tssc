cap prog drop mycolor
prog def mycolor
	cuse colormap, c w
	cap mkdir "`c(sysdir_plus)'/style"
	cd "`c(sysdir_plus)'/style"
	forval i = 1/`=_N'{
		if ustrregexm(v[`i'], "[\u4e00-\u9fa5]+"){
			file open myfile using "color-`=v1[`i']'.style", write replace
		}
		if !ustrregexm(v[`i'], "[\u4e00-\u9fa5]+") {
			file open myfile using "color-谷歌`=v1[`i']'.style", write replace
		}
		file write myfile `"set rgb "`=rgb[`i']'""'
		file close myfile
	}
end 
