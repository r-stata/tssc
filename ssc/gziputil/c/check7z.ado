*capture program drop check7z
*! version 0.3.0 25sep2019
program define check7z, rclass
	version 11
	
	* BBk-specific: Define global for 7zip path -> removes the need to change 
	* the PATH system variable.
	capture confirm file "C:\Program Files\PeaZip\res\7z\7z.exe"
	
	if _rc == 0 {
		global gziputil_path_7z = `""& 'C:\Program Files\PeaZip\res\7z\7z.exe'""'
		return scalar sevenz_available = 1
	}
	 else {
		global gziputil_path_7z = `""""'
	}
	
	
	* General: Check if 7-Zip is available in PATH environment variable.	
	if $gziputil_path_7z != `"& 'C:\Program Files\PeaZip\res\7z\7z.exe'"' {
		tempfile shell_output
		
		if c(os) == "Windows" {
			local orig_shell = "${S_SHELL}"
			global S_SHELL "powershell.exe -WindowStyle Hidden -noninteractive"
			shell 7z.exe | Out-File -FilePath '`shell_output'' -Encoding UTF8 -Force
			global S_SHELL "`orig_shell'"
		} 
		else {
			shell 7z >> "`shell_output'"
		}
		
		
		tempname file_handle
		file open `file_handle' using "`shell_output'", read
		// skip one line since 7-Zip inserts a blank line
		file read `file_handle' line
		file read `file_handle' line
		file close `file_handle'
		
		if substr("`line'", 1, 5) == "7-Zip" {
			global gziputil_path_7z = `""7z""'
			return scalar sevenz_available = 1
		} 
		else {
			return scalar sevenz_available = 0
		}
	}
end


