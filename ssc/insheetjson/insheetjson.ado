program insheetjson
version 11.0
mata: if (findexternal("libjson()")) {} else printf("{err: Error: The required JSON library (libjson) seems to be missing so this command will fail. Read the help file for more information.}\n");
mata: if (libjson::checkVersion((1,0,2))) {} else printf("{err: The JSON library version is not compatible with this command and so will likely fail. Please update libjson.}\n");
syntax [varlist] using/ , [COLumns(string)] [TABLEselector(string)] [LIMIT(integer 0)] [OFFSET(integer 0)] [PRINTonly] [REPlace] [DEBUG] [SAVECONtents(string)] [SHOWresponse] [FOLLOWurl(string)] [FLATTEN] [TOPscalars] [aoa(integer 0)]
if ( "`showresponse'" != "" ) {
mata: 	dummy=injson_sheet("`using'", "", "","", 0, 0, 0, 0,strlen( "`debug'"), "`savecontents'" ,"",1,strlen( "`flatten'"),strlen( "`topscalars'" ),0);	
}
else {
mata: 	dummy=injson_sheet("`using'", "`columns'", "`varlist'","`tableselector'", strtoreal("`limit'"), strtoreal("`offset'"), strlen("`printonly'"), strlen( "`replace'"),strlen( "`debug'"), "`savecontents'" ,st_local("followurl"), 0,0,strlen("`topscalars'"),strtoreal("`aoa'"));
}
end

mata

string matrix getTable(pointer (class libjson scalar) scalar root, string rowvector cn, string rowvector selector, real scalar debugf, real scalar aoaf, real scalar aoa) {	
	pointer (class libjson scalar) scalar tableroot
	pointer (class libjson scalar) scalar rownod
	pointer (class libjson scalar) scalar cell
	string matrix res
	if (root) {} else return(J(0,0,""));
	if (cols(selector)==0) tableroot = root->getNode("");
	else tableroot = root->getNode(selector);
	if (tableroot) {} else {
		printf("{err: Unable to find data. Bad result selector '%s'?}\n", selector);
		return(J(0,0,""));	
	}	
	pointer (string rowvector) scalar colsel 
	NC = cols(cn)
	colsel=J(1,NC,NULL)
	for (k=1; k<=NC; k++) colsel[k] = & (libjson::parseSelector(cn[k]));
	if ((tableroot) && (tableroot->isObject())) {
		if (debugf) printf("DEBUG: Single object found\n");
		NR= 1;
		res = J(NR,NC,"") 
		rownod = tableroot;
				for(c=1; c<=NC; c++) {
					cell = rownod->getNode(*colsel[c]);
					if (cell) {} else cell = rownod->getNode((*colsel[c])[1]);
					if (cell) {
						if (cell->isString()) res[1,c] = cell->getString("","");
						else if (cell->isArray()) res[1,c] = cell->bracketArrayScalarValues();
					} else {
						printf("{err: Invalid column name/selector '%s'. (Possible name candidates are: %s)}\n", cn[c], rownod->listAttributeNames(1));
						return(J(0,0,""))
					}
				}
		return(res);			
	} else if ((tableroot) && (tableroot->isArray())) {
		NR= tableroot->arrayLength();
		res = J(NR,NC,"") 
		if (debugf) printf("DEBUG: [%f,%f] Array found\n",NR,NC);
		if (NR<1) return(J(0,0,""));
		rownod = tableroot->getArrayValue(1)
		if ( rownod->isObject() || (aoaf && rownod->isArray()) ) {
			if (debugf) {
					if (rownod->isArray()) printf("DEBUG: Array of Arrays found\n");
					else printf("DEBUG: Array of objects found\n");
			}
			/* assume array of objects */			
			for (r=1; r<=NR; r++) {
				rownod = tableroot->getArrayValue(r);
				if (debugf) rownod->prettyPrint();
				for(c=1; c<=NC; c++) {
					cell = rownod->getNode(*colsel[c]);
					if (cell) {} else cell = rownod->getNode((*colsel[c])[1]);
					if (cell) {
						if (cell->isString()) res[r,c] = cell->getString("","");
						else if (cell->isArray()) res[r,c] = cell->bracketArrayScalarValues();
					} else {
						printf("{err: Invalid column name/selector '%s'. (Possible name candidates are: %s)}\n", cn[c], rownod->listAttributeNames(1));
						return(J(0,0,""))
					}
				}
			}
		} else {
				if (!aoaf) printf("{err: Warning: Sheet appears to be an Array-of-Arrays, but option aoa() was not specified. This will cause your column selectors to silently fail.}\n");			
		}
	if (aoa>0) {
		if ((aoa+1)<=rows(res) ) {
		res=res[(aoa+1)..rows(res),.];
		} else {
			printf ("{err: Warning: Too many aoa() header rows specified for the number of results returned, causing all rows to be skipped.!?!}\n"); 
			return(J(0,0,""));  /* bad format */
		}
	}
	return(res);		
	} else {
		if((tableroot) && (tableroot->isString() || tableroot->isScalar()) ) {
			if (debugf) printf("DEBUG: Single scalar found\n");
			return(J(1,1,root->getString(selector,""))); /*single scalar result*/
			} 
		return(J(0,0,""));  /* bad format */
	}
}

void saveToFile(string scalar outputname, string scalar contents) {
	fh_out = fopen(outputname, "w")
	fput(fh_out, contents)
	fclose(fh_out)
}

string scalar followonurl(string scalar original_url, string scalar next_url) {
	if (strlower(substr(next_url, 1,5))=="http://") return("") /* safety feature. should be a relative url */
	question_mark = strpos(next_url,"?");
	if (question_mark==1) {
		/* some quick splicing */
		qm = strpos(original_url,"?")
		new_url = substr(original_url,1,qm-1)+next_url
	} else {
		new_url = next_url;
	}
	printf("{txt: Following url '%s' for more table rows.}\n",new_url); 
	displayflush();
	return(new_url)	
}

real scalar injson_sheet(string scalar url, string scalar  colnames, string scalar varnames, string scalar selector, real scalar limit, real scalar offset, real scalar printonlyf,  real scalar overwritef, real scalar debugf, string scalar savetofile, string scalar followurl,  real scalar showresf, real scalar flattenf, real scalar topscalarsf, real scalar aoa) {
	class libjson scalar w
	pointer (class libjson scalar) scalar root
	string matrix tbl
	sel = tokens(selector);
	c=libjson::getrawcontents(url ,J(0,0,""));

	if (debugf>0) {	
		printf ("DEBUG: Version 1.2\n");	
		printf("{phang}URL returned:\n %s {p_end}\n", c);
	}
	if (strlen(savetofile)>0) {
			saveToFile(savetofile,c); 
			printf("{res: URL contents saved to '%s'}\n", savetofile);
			}
	root = w.parse(c);
	if (root==NULL) {
		printf("{err: Warning: No response from source?!?}\n");
		return(-1);
	}
	if (showresf>0) {
		printf("Response from server:\n");
		if (flattenf) {
			fv=root->flattenToKV()
			for (k=1; k<=rows(fv); k++) {
				printf("\t%s = %s\n",fv[k,1],fv[k,2]);
			}
		} else {
			root->prettyPrint();
		}
		return(0);
	}

	aoaf=aoa!=0;
	aoa_orig = aoa;
	if (aoa<=0) aoa=0;

	if (topscalarsf>0 && !aoaf) {
		pointer (class libjson scalar) scalar cell
		st_rclear();
		root_attr = root->listAttributeNames(0);			
		for (k=1; k<=cols(root_attr); k++) {
			kk= root_attr[k];
			cell=root->getAttribute(kk);
			if (cell->isArray()) {
				if (cell->arrayLength()>0) {
					v=cell->getArrayValue(1)->getAttributeScalar(kk,"") 
				} else v="";
			} else v=root->getAttributeScalar(kk,"")			
			if (v!=.) {				
				if (strpos(kk," ")==0) {
				if (debugf>0) printf("TOPSCALARS: %s = '%s'\n",kk,v);
				st_global("r("+kk+")",v); 
				}
			}
		}
	}
	
	fu = tokens(followurl)
	if (cols(fu)>0) {
		followurl =fu[1]
		pagelimit=10
		if (cols(fu)>1) {
				pagelimit=strtoreal(fu[2]); /* max number of follows */
				if (pagelimit>1) pagelimit++; /* Max number of pages */
		}				 
	}
	cn=tokens(colnames)
	
	tbl = getTable(root, cn, sel,debugf,aoaf,aoa);
	
	if (topscalarsf>0 && aoa_orig==-1) {
				if (rows(tbl)>=2)  for (k=1; k<= cols(tbl); k++) {
				kk = tbl[1,k];
				v = tbl[2,k];
				if (v!=.) {				
					if (strpos(kk," ")==0) {
					if (debugf>0) printf("TOPSCALARS: %s = '%s'\n",kk,v);
					st_global("r("+kk+")",v); 
					}
				}
		}
		return(0);
	} else {
		if (topscalarsf>0 && aoa>0) {
			printf("{err: Warning: Sheet appears to be an Array-of-Arrays, and the topscalars option only works with aoa(-1). Topscalars option ignored.}\n");
		} 
	}
	
	page_count=1
	if ((rows(tbl)>0) && (strlen(followurl)>0)) {
		printf("Received page 1 with %f rows and %f columns\n", rows(tbl), cols(tbl));
		fsel = libjson::parseSelector(followurl)
		url2=followonurl(url, root->getString(fsel,""));
		if ( (strlen(url2)>0) &&  ((page_count <=pagelimit) || (pagelimit<=0)) ) {
			root = libjson::webcall(url2,"")
			page_count++
			while ((root)&&(strlen(url2)>0) && ((rows(tbl)<=limit) || (limit<=0)) && ((page_count <=pagelimit) || (pagelimit<=0)) ){
				tbl2 = getTable(root, cn, sel, 0)
				if (rows(tbl2)<=0) break;
				else printf("Received page %f with %f rows and %f columns\n", page_count, rows(tbl2), cols(tbl2)); 
				tbl = tbl \ tbl2
				url2=followonurl(url, root->getString(fsel,""));
				page_count++
				root = libjson::webcall(url2,"")
			}
		}
		printf("Total received: %f rows and %f columns\n", rows(tbl), cols(tbl));		
	}
	vnam = tokens(varnames);
	if (rows(tbl)<=0) {
		printf("{res: Empty result returned; Nothing to do.}\n");
		return(0);
	}
	
	if (limit>0 && (rows(tbl)>=limit)) {
		tbl=tbl[1..limit,.]
		printf("{txt: Results were trimmed to %f observations.}\n",limit);
	}
	
	if (printonlyf>0) {
		cn
		tbl
		return(0);
	}
	
	current_obs = st_nobs();
	start_index = 1+offset;
	end_index = start_index+rows(tbl)-1;	
	end_window = 	end_index
	if (end_window>	current_obs) end_window= current_obs
	real colvector rvec
		
	if (end_window<start_index) {
			/* no check needed */
	} else {
		st_sview(TV, (start_index..end_window)', vnam);
		if ( (overwritef<=0) && sum(strlen(TV[.,.])) ) {
				printf("{err: Fatal Error, data would be lost}\n");
				return(0)
		}
			
	}
	if (current_obs< end_index) {
		st_addobs(end_index-current_obs);
	}
	current_obs = st_nobs();
	st_sview(V, (start_index..end_index)', vnam);
	V[.,.]=tbl[.,.]; 
	printf("{res: %f observations updated/written.}\n", rows(tbl));
	if (end_index<current_obs) {
		st_sview(V, ((end_index+1).. current_obs)', vnam);
		V[.,.]=J(current_obs-end_index, cols(tbl),"");
	}
	return(1)
}

end
