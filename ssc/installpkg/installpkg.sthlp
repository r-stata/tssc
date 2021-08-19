{smcl}
{right:version 1.1}
{title:Title}

{phang}
{cmd:installpkg} {hline 2} install Stata packages by specifying zipfile/pkgfile or local directory
 

{title:Syntax}

{p 8 16 2}
{cmd: installpkg} {cmd:,}  {it:from(local_directory)}   [{it:options}]{p_end}

{p 8 16 2}
{cmd: installpkg} {cmd:,}  {it:from(directory/zipfile)}  [{it:options}]{p_end}

{p 8 16 2}
{cmd: installpkg} {cmd:,}  {it:from(directory/pkgfile)} [{it:options}]{p_end}



{title:Options}

{p 4 4 2}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}

{synopt:{opt from(string)}}specifies install package(s) from local_directory 
or directory/zipfile or directory/pkgfile.{p_end} 

{synopt:{opt replace}}specifies that the downloaded files replace existing 
files if any of the files already exists.{p_end}

{synopt:{opt force}}specifies that the downloaded files replace existing 
files if any of the files already exists, even if Stata thinks all the files 
are the same.  force implies replace.{p_end}

{synoptline}
{p2colreset}{...}
{p 4 4 2}
Note: If local_driectory is specified, the command searches and installs all installable 
packages in the root of the specified driectory. 
If directory/zipfile is specified, the command searches and installs all installable 
packages in the unzipped folder. 


{title:Example(s)}

{p 4 4 2}
install gtfpch from arlionn-gtfpch-master.zip

    . installpkg, from(C:\arlionn-gtfpch-master.zip)

{p 4 4 2}
install gtfpch by specifying gtfpch.pkg in the local directory.

    . installpkg, from(C:\gtfpch\gtfpch.pkg)

{p 4 4 2}
install gitee by specifying gitee.pkg in website

    . installpkg, from(https://gitee.com/kerrydu/gitee/raw/master/gitee.pkg)

{p 4 4 2}
Search and install packages included in C:\gtfpch.

    . installpkg, from(C:\gtfpch)



{title:Usage in Stata User Menu}
   
{p 4 4 2} 

  Prompt installpkgmenu in Stata command window to add "InstallPackage" submenu into Stata User. 

  Click InstallPackage -> Installpkg to select the Stata files for installation.

  Click InstallPackage -> Createpkg  to create package information and install the package.





{title:Acknowledgment}

I am grateful to E. F. Haghish for providing many useful Stata commands in Github. "make2.ado" in 
this package is a copy of his "make.ado" with some minor modifications. "createpkg.dlg" 
and "createpkgdlg.ado" also originates from his "make.dlg" and "makedlg.ado".

dirlist command in "installpkg.ado" is from the post by Robert Picard in Statalist 
(https://www.stata.com/statalist/archive/2013-10/msg01058.html).
I appreciate Robert Picard for posting this command



{title:Author}

{p 4 4 2}
Kerry Du     {break}
Xiamen University      {break}
Email:kerrydu@xmu.edu.cn     {break}
