program define createtocdlg

syntax, [CINST]

if "`cinst'"!=""{
    
	mata: filewrite =fopen("$file_path_/stata.toc","a")
	mata: fclose(filewrite)
	
	if(`"$file_path_pkgs"'!=""){
		foreach f of global file_path_pkgs{
			local f=regexr(`"`f'"',"(\.pkg)$","")
			net install `f', from($file_path_) $file_path_rnew
		}

	}

}

else{
   di "stata.toc not created, installation exits..."
}



end
