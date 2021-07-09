program def alphlist, rclass
*! NJC 1.1.1 28 June 2001 
* NJC 1.1.0 6 June 2000 
* NJC 1.0.0 27 Jan 2000 
	version 6.0 
	syntax , [ Capitals Underscore Global(str) Noisily ]
	
	if length("`global'") > 8 { 
		di in r "global name must be <=8 characters" 
		exit 198 
	} 	

	if "`capitals'" != "" { 
		local newlist "A B C D E F G H I J K L M N O P Q R S T U V W X Y Z" 
	} 	
	else local newlist "a b c d e f g h i j k l m n o p q r s t u v w x y z" 

	if "`underscore'" != "" { local newlist "`newlist' _" } 
		
	if "`noisily'" != "" { di "`newlist'" } 	
	if "`global'" != "" { global `global' "`newlist'" } 
	return local list `newlist' 
end 	
