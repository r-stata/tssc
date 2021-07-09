cd "D:\Mijn documenten\projecten\stata\smclpres\3.3.1" 
clear all
version 14.2

mata 
mata clear
mata set matastrict on
end

do smclpres_init.mata
do smclpres_parts.mata
do smclpres_toc.mata
do smclpres_slides.mata
do smclpres_bib.mata

lmbuild lsmclpres, replace
lmbuild lsmclpres, replace dir(.)
