/***
_v. 1.1_

ssczip
======

creates and downloads a Zip file from SSC and names it based on the package release date

Syntax
------

> __ssczip__ _packagename_ 

Description
-----------

__ssczip__ downloads a package from SSC. t will also analyze the last release 
date of the package and creates a Zip file with the release date, to imply the 
version of the package. packages hosted on SSC do not have a version specified 
within the package description and instead, the release date is used to show 
package versions. 

Examples
--------

download adoedit package from SSC, along with its version

        . ssczip adoedit

Author
------

E. F. Haghish   
Department of Mathematics and Computer Science (IMADA)    
University of Southern Denmark    

- - -

This help file was dynamically produced by 
[MarkDoc Literate Programming package](http://www.haghish.com/markdoc/) 
***/


*cap prog drop ssczip
prog ssczip

	syntax [anything]
	ssclastupdate `anything', download remove 	

end


