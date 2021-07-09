/**************************************************************
 * SAVASTATA should work for you as is, but you may need 
 *  to edit this file to set the values for the macro variables:
 *  ustata  -- if you are using SAVASTATA in a UNIX or Linux environment
 *  wstata  -- if you are using SAVASTATA in a Windows environment
 *
 * There are instructions further down in this file explaining where 
 *  and how to edit the settings of these macro variables.
 * Do a find for "let ustata" or "let wstata".
 **************************************************************/

run;   ** Because the world needs more run statements. **;


%MACRO savastata(out_dir,options,sortedby,tfns,nosave,u_dir,U_SE,version=0);  
run;   %** Because the world needs more run statements. **;
%** If an error has occurred before call to SAVASTATA then fail immediately. **;
%if &syserr. ^= 0 %then %goto nevrmind;  
               
/*********************************************************************************************
** Macro: SAVASTATA
** Input: Most recently created SAS work dataset, directory path of where to save the output
**         Stata dataset file, and any options.
** Output: A Stata 6, 7, 7-SE, 8, or 8-SE dataset, or an ASCII data file with
**          other files created by SAVASTATA to input the data into Stata.
**         
** 
** Programmer: Dan Blanchette   dan_blanchette@unc.edu
**             The Carolina Population Center at The University of North Carolina at Chapel Hill
** Developed at:
**             The Carolina Population Center at The University of North Carolina at Chapel Hill,
**             Research Computing, UNC-CH, and
**             Center for Entrepreneurship and Innovation Duke University's Fuqua School of Business
** Date: 20October2003
** Modified: 16Apr2012  - Made it so that Stata executables in the "Program Files (x86)" directory will be found.
** Modified: 28Mar2011  - Made it so that Stata 11 Windows executables can be found since Stata
**                         changed the names of them in Stata 11. Also made sure that the MISSING
**                         system option is set to a period during SAVASTATA. Also made it so that
**                         if SAS on Linux is not allowed to CD to the work directory it CDs to /tmp/
**                         to invoke Stata so that the files: log _tfns_version.log and _tfns_infile.log 
**                         are in /tmp/ and can be safely deleted.
** Modified: 02Dec2010  - Now all temporary files are deleted when savastata successfully runs 
**                         with ascii and messy options turned off when not run by script.
**                      - Fixed it so that scanning for options is only done when there are options 
**                         specified by the user.
** Modified: 27Oct2010  - Made it so that formats specified in the fmtsearch SAS System Option will
**                         that are assigned to variables in the dataset being processed will be 
**                         converted to value labels if Stata will accept them as value labels.
** Modified: 20Aug2010  - Made it so that if a dataset has a lot of string variables maxvar will be
**                         set to more than the number of variables if they are running Stata SE or MP.
** Modified: 15Jul2010  - Made it so that if user has work.formats and library.formats and the length
**                         of formats in work.formats are shorter than in library.formats the maximum
**                         length will be chosen instead of truncated.  Also stopped using -saveold-
**                         when it was not specified since date formats are not truly perserved when
**                         -saveold- is used.
** Modified: 06Nov2009  - Added search for up to Stata 14 and made Stata 11 also use -saveold-
**                         Now use %sysfunc(lowcase()) instead of %lowcase since that is what %lowcase is.
** Modified: 16Apr2009  - Fixed situations where long variable labels were attempting to be made into
**                         Stata variable notes and the macro variable &llabvars. messing things up.
** Modified: 13Mar2009  - Now variable labels that are longer than 80 characters are stored as 
**                         variable notes (the truncated label is still the variable label)
**                      - renamed file to savastata.sas
**                      - fixed issue when -ascii option specified with no version number.
**                      - fixed issue when new dataset name submitted and it's name also existed in
**                         the directory path, like a dataset named with a single letter: d.dta
** Modified: 01Apr2008  - Made it Stata 10 and Stata MP compatible. 
**                      - Made it so that double quotes in string variables can be transferred
**                         to Stata by replacing them with the cent symbol and having Stata replace
**                         the cent signs back to double quotes.  This only happens if no string
**                         variables contain a cent symbol and if saving to Stata 7+.  If that is the case, 
**                         the -quotes option still works to replace double quotes with single quotes.
**                      - Only saves to Stata 9 when using Stata 10 since no benefit to a Stata 10 file. 
**                      - Fixed situation when -usesas- calls SAVASTATA with char2lab option
**                         and no other vars have user-defined formats converted vars did not
**                         get value labels assigned.
**                      - Added the version of Stata to be used in the -ascii option.
**                      - Fixed it so when a variable has formats for special missing values and
**                         use OTHER, LOW or HIGH also, SAVASTATA handles that.
**                      - Made it so that if a SAS dataset has more than 32,767 vars savastata
**                         fails with that message rather than dataset is too wide message.
**                      - Fixed situations where really long user-defined formats (32,000+ 
**                         characters) were being processed.
**                      - Made help url dynamic so that it is the savastata page when run by 
**                         savastata, or it's the savas or usesas page when run by them.
**                      - set local macro vars to be local.
**                      - stopped having Stata sort data after read into Stata since DESCENDING sorts
**                         and missing values in sorts mess up sorts between SAS and Stata
** Modified: 17Apr2007  - Fixed ability to handle ranges in formats like:  1-3 "first 3"
**                      - Added restraint of min and max value a format can have since Stata
**                         cannot make value labels for numbers less than -2,147,483,200 or
**                         greater than 2,147,483,200
**                      - Added check that one format does not exceed 65,536 values which is 
**                         the max for Stata
**                      - Fixed it so that the there is not added space added to value labels.
** Modified: 07Aug2006  - Added ability to handle non-alphanumeric characters in directory names.
**                      - Added ability for batch invocation of SAS to set location of ustata
**                         with the sysparm macro variable.
**                      - Added checking HOSTNAME when discerning where to log usage.
** Modified: 29May2006  - Fixed char2lab option problem with -usesas- & savas when
**                         formats were stored in formats.sas7bcat
** Modified: 04Apr2006  - Fixed it so that locations of the Stata executable file 
**                         that have spaces in the directory name no longer crash
**                         savastata.  The %sysexec macro is not supposed to require
**                         double quotes in such situations but adding double quotes
**                         fixed the problem.
** Modified: 14Mar2006  - no longer searches for stata.exe when run by -usesas-
** Modified: 13Feb2006  - fixed formatting of special missings issues.
** Modified: 10Nov2005  - fixed when usagelog not set issues.
** Modified: 29Sep2005  - fixed situation where -usesas- calls savastata and savastata closed user's log
**                      - added max str var length to 244 if Stata version is >= 9.1
**                         since Stata 9.1 does not allow you to save as Stata 8 or 9.0 any special missing
**                         will be lost since -saveold- saves as Stata 7.
** Modified: 09Aug2005  - If using/saving to Stata 9 and using SAS 9, then SAS user-defined formats
**                         that have a max length of 32,767 characters can have up to the first
**                         32,000 (Stata 9's limit) saved as Stata value labels. 
**                      - new option char2lab which runs the SAS macro char2fmt is only helpful 
**                         if using Stata 9 and only allowed if savastata is being run by savas 
**                         or -usesas- since it changes data dramatically
**                      - check users path for Stata executable, For *nix, "stata" or "stata-se" 
**                         seem to just work so no need to go hunting.
**                      - does not save data if Stata does not report same number of obs and vars
**                      - no longer searches for stata.exe when run by -usesas-
**                      - spaces in directory names (where intermediary files put) in *nix seems to be fixed.
**                      - for when -usesas- runs savastata, the maxvar setting is not changed if
**                         savastata suggests a number lower than the user has already specified.
**                         otherwise savastata sets maxvar to about 10% of the difference of 
**                          (32,766 - (all variables))  
**                         savastata has successfully worked with 32,766 variables!
** Modified: 24Jun2005  - made sure that if unix/linux directory names had spaces all is still fine
** Modified: 14Jun2005  - fixed it so that directory names with commas in them are okay and problem
**                         with changing back to pwd that was introduced in 15May2005 version.
** Modified: 15May2005  - fixed it so that directory names with commas in them or 
**                         start with forward slashes (universal file naming convention)
**                         are okay.
**                      - if user has a profile.do that cd's to another directory
**                         that that is okay.
** Modified: 10May2005 - updated search for Windows Stata executable file to find up to 
**                        version 12 Stata (if directory naming conventions stay predictable)
**                     - made work when user does not have Stata and wants to save to ascii file
**                     - made work when user has profile.do changing directories on savastata
**                       This introduces problems when Unix/Linux directory contains a double quote...
**                       but what good Unix/Linux user would name a directory containing a double quote?!
** Modified: 22Mar2005  - fixed problems related to when a new dataset name provided
** Modified: 08Dec2004  - The new name of the Stata datafile can be uppercase or mix case.
** Modified: 09Nov2004  - User can now specify the name of the Stata datafile they want.
**                         %savastata("C:\MyProject\My{98}Stata!Data.dta", replace );
**                        This is helpful if they want to use an invalid SAS filename but valid Stata file name.
**                        !The Stata dataset name must end in ".dta"!
**                      - Thanks to West, bug fixed that was related formats using the "Other" category. 
** Modified: 26Oct2004  - Stopped allowing user to set what version of Stata they are using.  SAVASTATA will always figure it out.
**                      - also changed note in log to report Stata version as integer instead of 8.2 since the version of  
**                        a dataset is not that specific.
** Modified: 22Jul2004  - fixed bug with numeric variables that had both positive and negative
**                         formatted values, and made a few tweaks, one of which is that the raw 
**                         ascii data file in the work
**                        directory is deleted when savastata successfully completes.
** Modified: 27Apr2004  - fixed macro so that setting use8SE=1 does not generate error messages
**                         about macro variable VER.
**                      - fixed warning message about script macro var when usagelog not used.
**                      - added more locations to find the windows Stata executable.
** Modified: 26Feb2004 - memory setting fix for -usesas-
** Modified: 03Feb2004  1) when -usesas- calls macro memory will not be reset if not needed.
**                      2) no longer closes existing logs when called by -usesas- .
**
** Disclaimer:  This program is free to use and to distribute as long as credit is given to 
**                Dan Blanchette 
**                The Carolina Population Center 
**                University of North Carolina at Chapel Hill
** 
**               There is no warranty on this software either expressed or implied.  This program 
**                is released under the terms and conditions of GNU General Public License.
**
** Comments: 
**   SAVASTATA SAS macro when implemented by the SAS System saves the most recently created 
**    SAS dataset in the WORK library to a Stata dataset.  SAVASTATA requires that you have a 
**    working copy of SAS and a working copy of Stata Intercooled or SE on your computer to run 
**    successfully.  If your SAS dataset is small enough SAVASTATA may work on Stata Small 
**    (Student Version).
**    If your SAS dataset is using formats that are in a formats catalog (work.formats or 
**    library.formats), SAVASTATA will make an attempt to preserve them as value labels in 
**    Stata.  Stata does not allow all the variations of user-defined formats that SAS offers.
** 
**   SAVASTATA may take a few minutes to save your dataset.
** 
**   SAVASTATA will work in SAS interactive mode or in SAS batch mode.
**   SAVASTATA will run on various operating systems including: Windows, Red Hat Linux, AIX.
**   It may work fine on others as well.
**
**   SAVASTATA uses the most recently created dataset in the work directory,
**    figures out how best to store the data as a Stata dataset, keeps most date
**    formats and other basic formats for numeric variables, checks for invalid
**    Stata variable names, if using or outputting to Stata6: checks to see if long variable 
**    names need to be shortened, prints them to the SAS log and shortens them, writes out 
**    the SAS dataset to an ASCII data file, attempts to preserve all user-defined formats for 
**    numeric variables, writes out Stata do-files, and submits them to Stata in batch mode 
**    in order to have Stata read the data in and save it as a Stata dataset. 
**
** Restrictions of each version of Stata:
**  1. Variable names can be no more than 8 characters long: Stata 6
**  2. Variable names can be up to 32 characters long: Stata 7 and 8
**  3. String variables can contain a maximum of 80 characters: Stata 6, 7 and 8 Intercooled.
**  4. String variables can contain a maximum of 244 characters: Stata 7 and 8 SE.
**  5. The maximum number of variables is 2,047:  Stata 6, 7, and 8 Intercooled
**  6. The maximum number of variables is 32,766:  Stata 7 
**  7. The maximum number of variables is 32,767:  Stata 8 and 9 SE 
**  8. Special missings (.a through .z) for numeric data are allowed: Stata 8
**
**
** -- SAVASTATA can run on SAS ver 7, 8 or 9 
** -- SAVASTATA can run in the following environments: Windows, RS6000, SUN , LINUX
**       and maybe on many others.
**
** REQUIRED INPUT TO SAVASTATA:
**  -- SAVASTATA needs to have the most recently created dataset by SAS to be in the 
**      work directory.
**  -- SAVASTATA needs to know what directory to put the Stata dataset and possibly 
**      the files used to input the data to Stata that are written by savastata.
**      These are the only required input, but you may choose to make use of the
**      following options.
**             
** LIST OF OPTIONS:
** NOTE:  Options can be used in any order.  You can specify as many as you want
**         or none at all. 
**  The following three options work as they do in Stata:
** -replace -- If the Stata dataset you want to output already exists, then overwrite it with
**              the dataset generated by savastata.
**
** -old     -- Outputs a Stata 6 dataset if using Stata 7 or Stata 7-SE,
**              or a Stata 7 Intercooled dataset if using Stata 8 Intercooled 
**              or a Stata 7-SE dataset if you are using Stata 8-SE.
**
** -intercooled -- Outputs a Stata Intercooled dataset if using Stata SE or Stata MP.
**             
** NOTE:  If you do not specify what version of Stata to save in, Stata will save the
**         dataset in the current version. 
** 
** -float   -- Numeric variables that contain decimals will be stored as float instead of the 
**              default of double.  This may result in a loss of precision, but float is the
**              default storage type that Stata uses.  This will help decrease your filesize.
**
** -quotes  -- Replace double quotes ( " ) occurring in character variables with single quotes ( ' )
**              and replace compound quotes ( `" or "' ) occurring in variable labels or formats 
**              with single quotes ( ' ).
**              SAVASTATA cannot process character variables with double quotes or variable
**              labels or formats with compound quotes.
** 
** -messy   -- Puts the files generated by SAVASTATA used to create the Stata dataset in the directory 
**              named in the pathname provided in the call to the SAVASTATA macro.
**             
** -check   -- Creates two check files for the user to compare the SAS input dataset with
**              the Stata output dataset to make sure SAVASTATA created the files correctly.
**              This is a comparison that should be done after any data file is converted
**              to any other type of data file by any software.  The files are
**              created in the same directory as the output Stata data file and are named
**              starting with the name of the data file followed by either "_SAScheck.lst" 
**              or "_STATAcheck.log",  e.g. "mydata_SAScheck.lst" and "mydata_STATAcheck.log".
**              The SAS check file contains output from proc means,
**              proc contents (by position), and a proc print of the first 5 observations. 
**              The Stata check file contains the equivalent output by the commands summarize,
**              describe, and a list of the first 5 observations.
**             
** -ascii   -- Outputs only the ASCII data file and does not save your dataset in Stata format.
**              It also turns on "-messy" switch so that the Stata input files are 
**              not deleted after your program has run.  Use this switch to make your own 
**              edits to the input of these data into Stata.   Use this option if you do not 
**              have Stata on the same computer that you have SAS.  The files generated by 
**              SAVASTATA can be moved to another computer that does have Stata and run there to
**              create the Stata dataset. 
**
**              The default version of Stata that your ascii file will be set to be used for 
**               will be Stata 6 (only allow up to 2,047 variables).
**
**              If you want to specify what version of Stata will be used to read the ascii
**               data you can do so like so:
**                -ascii9SE  (for Stata 9 SE/MP) 
**                -ascii9  (for Stata 9 Intercooled) 
**                -ascii10MP  (for Stata 10 SE/MP) 
**                -ascii8  (for Stata 8 Intercooled) 
**
**                Stata versions with decimal values are invalid:
**                -ascii9.2SE   IS INVALID VERSION, just specify: -ascii9SE
**                -ascii 9.2 SE  IT IS INVALID TO USE SPACES, just specify: -ascii9SE
**             
**              You can also use options -old and -intercooled to changed what version the data set 
**               will be saved as.
**             
**             
** -char2lab - Runs the CHAR2FMT macro but only if SAVASTATA invoked by savas script or -usesas-
**              because CHAR2FMT changes the user's dataset in a dramatic way.
**              CHAR2FMT converts long character variables to numeric vars and stores character data
**              in user-defined formats which get translated into Stata value labels which have 
**              a maximum length of 32,000 characters (new feature in Stata 9).             
**             
** SETTING UP SAVASTATA 
**  These are instructions to edit the savastata.sas file.
**             
** NOTE:  If you are setting up this macro on your computer for the first time,
**         please choose which version of Stata you are going to have SAVASTATA use.
**         If you do not choose to set one of the following switches, SAVASTATA will
**         figure out what version of Stata you are running for you.  This may 
**         add a noticeable amount of time to processing so you may want to set these 
**         switches to the correct version of Stata.  You can easily figure out what 
**         version of Stata you are using by looking at the top of your results window 
**         in Stata or by typing in the command -about- at the Stata command line.
**         One advantage of leaving SAVASTATA to figure out what version of Stata is 
**         being used is that when you upgrade your version of Stata you will not have to
**         update savastata.
**  
**  NOTE:
**  --  If you are running SAVASTATA on UNIX or Linux then
**       you need to be able to start a Stata batch job by:
**       stata -b do mydofile.do
**       If not, then change the setting of the ustata macro variable.
**********************************************************************************************/
 %local ustata;
/** One of these may work: ** 
 %let ustata=/usr/local/stata/stata;  
 %let ustata=/usr/local/stata/stata-mp;  
 %let ustata=/usr/local/stata/stata-se;  */
 %let ustata=stata;


 %** tfns is only submitted by savas and -usesas- and savas may set the location of Stata **;
  %*  savas may invoke SAS like so:  sas -sysparm /alt_location/stata  my_sas.sas **;
 %if "&tfns."^="" and "&sysparm."^="" and %sysfunc(fileexist("&sysparm.")) %then %do;
     %let ustata=%nrbquote(&sysparm.);
 %end;



/**********************************************************************************************
**
**  --  If you are running SAVASTATA on Windows, you may need to tell SAVASTATA where 
**       the Stata executable file is located if SAVASTATA cannot find it.
**       If you do not know where your Stata executable file is located, find your Stata
**       short-cut icon, right click on it, choose "properties", and look in the "target" field.
**       This will show you where the Stata executable file is located on your hard drive.
**
***********************************************************************************************/
 %local wstata;
%** Change what is inside the parentheses to the location of your Stata executable file **; 
/** One of these may work: **;
 %let wstata= %nrstr(C:\Stata11\statase.exe);
 %let wstata= %nrstr(C:\Stata11\statamp.exe);
 %let wstata= %nrstr(C:\Stata11\stata.exe); 
 **  Pre-Stata 11 versions: *;
 %let wstata= %nrstr(C:\Stata\wsestata.exe);
 %let wstata= %nrstr(C:\Stata\wmpstata.exe); 
 %let wstata= %nrstr(C:\Stata\wstata.exe); */
 %let wstata= %nrstr(C:\Stata\stata.exe);

 

/*********************************************************************************************
** 
** HOW TO USE THE SAVASTATA MACRO: 
** Using the SAVASTATA macro requires that you understand how to use the "%include" statement
**  and that you know how to call a SAS macro.
**
**  %include'LOCATION AND NAME OF A FILE THAT CONTAINS SAS CODE';
**
** For example, if you have copied this file to "C:\SASmacros", then you tell SAS 
**  about this macro by adding the following line to your SAS program:
**
**  %include 'C:\SASmacros\savastata.sas'; 
**
** This statement makes SAS aware of the SAVASTATA macro which is in the file savastata.sas.
** To use the macro you have to make a call to it.  To do that you add a line like the 
**  following to your SAS program:
**
**  %savastata(C:\mySASdir\,-old);
**
** The information inside the parentheses is passed on to the SAVASTATA macro.  The first
** string of information is the location you want to save your SAS dataset as a Stata dataset.
** This is somewhat like a libname statement.  The second string of information is the options
** you wish to pass on to the SAVASTATA macro.  You can use as many options as you like or none at all.
**
**
** EXAMPLE USE OF THE SAVASTATA MACRO:
**  %include 'C:\SASmacros\savastata.sas'; ** Include macro once in a SAS session and call it **;
**                                         *  as many times as you like in that session.     **;
**
**  data work.ToBeStata;   ** This makes a copy of the SAS dataset in the in the WORK library. **;
**   set in.mySASfile;
**  run;
** 
** 
** %savastata(C:\mydata\,);  ** Saves the dataset in the C:\mydata\ directory if it does not  **;
**                            *  already exist in that directory.                             **;
** 
** OTHER EXAMPLE CALLS:
**                
** %savastata(C:\mydata\,-replace);  ** Saves the dataset C:\mydata\, overwriting it if   **;
**                                    *  it already exists.                               **; 
**                
** %savastata(C:\data\,-old);      ** Saves the dataset as the previous version of Stata  **;
**                                  *  in C:\data\  directory                             **;
** 
** %savastata(C:\data\,-old -replace);  ** Saves the dataset as the previous version of Stata  **;
**                                       *  in C:\data\  directory, overwriting it if it       **;
**                                       *  already exists.                                    **;
** 
** The -intercooled option starting with Stata 10 only checks for more than 2,047 vars.  It does not
**       save the dataset as an intercooled dataset since starting with Stata 10 that is no longer 
**       an option.
** %savastata(C:\data\,-intercooled);  ** Saves the dataset as the Intercooled version of Stata  **;
**                                      * in C:\data\  directory.  This is only possible if      **;
**                                      * your version of Stata is an SE edition.                **;
** 
** %savastata(/project/data/,-old -intercooled);  ** Saves the dataset as previous version of   **;
**                                                 * Stata Intercooled in the /project/data/    **;
**                                                 * directory **;
** 
** 
***********************************************************************************************/

%local usagelog;
%** SET LOCATION OF USAGE LOG FILE **;
%let usagelog="specify what file name and location you want here";
%if "&sysscp."="WIN" %then %do;
 %let usagelog="x:\software\temp\savas_usage.log";  %* windoze *;
%end;
%else %if "&sysscp."="RS6000" %then %do;
 %let usagelog="/afs/isis.unc.edu/home/d/a/danb/usage/savas_usage.log";  %* AIX nodes *;
%end;
%else %if "&sysscp."="AIX 64" %then %do;
 %let usagelog="/afs/isis.unc.edu/home/d/a/danb/usage/savas_usage.log";  %* AIX nodes *;
%end;
%else %if "&sysscp."="LINUX" %then %do;   %* linux boxes *;
  %if %index(%qlowcase(%qcmpres(%sysget(HOSTNAME))),"gromit") = 1 
   or %index(%qlowcase(%qcmpres(%sysget(HOSTNAME))),"sig") = 1 
   or %index(%qlowcase(%qcmpres(%sysget(HOSTNAME))),".cpc.") ^= 0 %then
     %let usagelog="/afs/isis.unc.edu/home/d/a/danb/usage/savas_usage.log";  
  %else %let usagelog="/afs/isis.unc.edu/home/d/a/danb/usage/savas_usage.log";  
%end;
%else %if %index(%qupcase(&sysscp.),SUN) %then %do;
    %let usagelog="/afs/isis.unc.edu/home/d/a/danb/usage/savas_usage.log";  
%end;
%else %do;
    %let usagelog="/afs/isis.unc.edu/home/d/a/danb/usage/savas_usage.log";  
%end;


/***************************************************************************/
/****** !NO MORE EDITS TO THE MACRO SHOULD BE MADE BEYOND THIS POINT! ******/
/***************************************************************************/

%** local macro vars used in savastata (SAS 9.2 automatically sets macros to local) **;
%local ascii avars bign bign1 bstatavs bvar bytemax bytemin 
       c_len ch char2fmthttp char2lab check cnobs3 cq crdate cv 
       decpos diffhour diffmin diffsec dq dq1 dq_fail dq_fix dyc dy dy_and_dq_fail drive dset dta_exists 
       exe10 exe11
       fail fail11 fail20 fail23 fb fe fdset flavor flibr float fmlabel_len fmt_order formats 
       http 
       i ii intmax intmin intrcool isysver 
       j jj k kk 
       label_lens labtrunc ldset lib librfmts llabvars ln lo longname longmax longmin max_clen_count 
       maxobs maxreclen maxstrvarlen maxvallablen maxvar messy missing MP
       n_fmts name newname nobs nocd noisily notes nv 
       ob obs old pwdir 
       pwdrive 
       quietly quotes 
       reclen replace 
       s_dsn s_last s_SEver s_ver script SE slash sm sprog startdat success 
       tdir temp_dir tempfiles
       u_SEver u_sysrc u_ver udset unix uspace 
       var_c var_n versions vlabels 
       w_sysrc work_dir workfmts wrk
      ;;;

%** make sure sas version is an integer so it can be properly evaluated **;
%let isysver = %sysevalf(&sysver.,integer);  

 %** Save option settings so they can be restored at the end of this macro. **;
%let notes= %sysfunc(getoption(notes)); 

%let obs= %sysfunc(getoption(obs)); 

%let missing= %nrbquote(%sysfunc(getoption(missing)));

options obs= MAX;   %*** Reason for maximizing it is because user could have        **;
                     %*  set it lower than the number of variables in the dataset. **;
options nonotes;   %** Shut off notes while program is running in order to reduce log size. **;

options missing= '.'; %** Make sure missing values are really a period. **;

%** Time how long SAVASTATA takes to run **;
%let startdat= %sysfunc(datetime());

%** initialize macro vars **;
%let diffhour= 0;
%let diffmin= 0;
%let diffsec= 0;
%let fail= 0;
%let success= 0;  

%** if out_dir is surrounded by double or single quotes, remove them. **;
%if %nrbquote(%index(%nrbquote(&out_dir.),%str(%")))=1 /*"*/
  or %nrbquote(%index(%nrbquote(&out_dir.),%str(%')))=1  /*'*/
      %then %let out_dir=%nrbquote(%substr(%nrbquote(&out_dir.),2,%length(%nrbquote(&out_dir.))-2));

%if %nrbquote(%index(%nrbquote(&u_dir.),%str(%")))=1 /*"*/
  or %nrbquote(%index(%nrbquote(&u_dir.),%str(%')))=1 /*'*/
       %then %let u_dir=%nrbquote(%substr(%nrbquote(&u_dir.),2,%length(%nrbquote(&u_dir.))-2));


%** initialize vars **;
%let newname=;
%let tempfiles=;
 
%** check to see if new dataset name provided in %nrbquote(&out_dir.) **;
%if %nrbquote(%length(&out_dir.)) > 0  %then %do;  
 %if %nrbquote(%index(%qlowcase(&out_dir.),.dta)) %then %do;
  %** if Stata dataset name provided with directory info **;
  %if "%qlowcase(%substr(%nrbquote(&out_dir.),%length(%nrbquote(&out_dir.))-3,4))"=".dta" %then %do;  
    %** if no backslash provided:  savstata(d:mydata.dta) then add in the backslash **;
   %if "&sysscp."="WIN" 
     and %nrbquote(%index(%nrbquote(&out_dir.),:)) = 2 and %nrbquote(%index(%nrbquote(&out_dir.),\)) ^= 3 %then 
    %let out_dir = %nrbquote(%substr(%nrbquote(&out_dir.),1,2)\%substr(%nrbquote(&out_dir.),3,%length(%nrbquote(&out_dir.))-2));  
   %let newname=%nrbquote(%substr(%nrbquote(&out_dir.),1,%length(%nrbquote(&out_dir.))-4));
   %if %index(%nrbquote(&newname.),\) %then %do;
    %do %while(%nrbquote(%index(%nrbquote(&newname.),\)));
     %let newname=%nrbquote(%substr(%nrbquote(&newname.),%index(%nrbquote(&newname.),\)+1,%length(&newname.)-(%index(%nrbquote(&newname.),\))));
    %end;
    %let out_dir=%nrbquote(%substr(%nrbquote(&out_dir.),1,%index(%nrbquote(&out_dir.),%nrbquote(&newname.))-1));
   %end;
   %else %if %index(%nrbquote(&newname.),/) %then %do;
    %do %while(%nrbquote(%index(%nrbquote(&newname.),/)));
     %let newname=%nrbquote(%substr(%nrbquote(&newname.),%index(%nrbquote(&newname.),/)+1,%length(&newname.)-(%index(%nrbquote(&newname.),/))));
    %end;
    %let out_dir=%nrbquote(%substr(%nrbquote(&out_dir.),1,%eval(%length(%nrbquote(&out_dir.))-%length(%nrbquote(&newname..dta)))));
   %end;
   %else %let out_dir=;  %** only new name provided **;
  %end;
 %end; %** end of if %index(%nrbquote(&out_dir.),.dta) do loop **;
%end; %** end of if length(%nrbquote(&out_dir.)) = 0 do loop **;
 
 
%let s_dsn=&sysdsn.;  %** preserve these to restore after setting up usagelog **;

%** script var is definitive way to determine how savastata was called,  **;
 %* if empty then not called by either -usesas- or savas **;
%let script=; 
%if "&tfns." ^= "" and "&nosave."="nosave" %then %do;
 %let script=usesas;
%end;
%else %if "&tfns."^="" and "&nosave."="" %then %do;
 %let script=savas;
%end;

%** log usage of savastata if usage log file exists **;
%if %sysfunc(fileexist(&usagelog.)) %then %do;
 data _null_;
  file &usagelog. mod;
  %if "&script."="" %then %do;
   put " ";
   date=datetime() ;
   put " savastata macro " date dateampm.  ;
  %end;
  put "  &sysuserid. savastata( &out_dir.,&options.,&sortedby.,&tfns.,&nosave.,&u_dir.,&U_SE.)";
%end;

%let sysdsn=&s_dsn.; %** restore after setting up usagelog **; 

%let noisily = ;
%let quietly = ;
%if "&script." = "usesas" %then %do;
 options nonotes nodate ;
 %let noisily =noisily;
 %let quietly =quietly;
 %** proc printto prints any weird error messages that SAS has to this log file in a nice, *;
  %* readable format because -usesas- looks for this file and prints it to the results window **;
 proc printto log="&out_dir._&tfns._report.log"; run;  
%end;   


%** current website address for savastata, usesas, or savas help: **;
 %* used in fail messages at end of macro **;
%let sprog=savastata;
%if "&script." ^="" %then %let sprog=&script.;
%let http=%nrstr(http://www.cpc.unc.edu/research/tools/data_analysis/sas_to_stata/)&sprog..html;
%let char2fmthttp=%nrstr(http://www.cpc.unc.edu/research/tools/data_analysis/sas_to_stata/char2fmt.html);

%** Find out what directory SAS currently is using as the present working directory **;
 %*  so that it can be restored at end of macro. **;
libname ________ " ";  %** ________ is a very unlikely libname **;
%let pwdir=%nrbquote(%sysfunc(pathname(________)));
%let pwdrive= ;
%if %index(%nrbquote(&pwdir.),\) %THEN %do;
   %let pwdrive= %qsubstr(%nrbquote(&pwdir.),1,2);   %** get drive info eg. "d:"  **;
%end;


%** if no temporary filenames are supplied then use sysjobid macro var **;  
%if %length(&tfns.)=0 %then %let tfns=&sysjobid.&sysindex.;
                  %** Have macro var that will increase each time macro run for **;
                   %* times when one SAS session runs savastata macro multiple **;
                   %* times and -messy option specified. ***; 


%*** Use the most recently created SAS work dataset.  ***;
%let s_last=&syslast.;
%let ldset=%length(&syslast.);
%let decpos=%index(&syslast.,.);
%let dset=%substr(&syslast.,&decpos.+1,&ldset.-&decpos.);

%**  use the work directory to store the temporary SAS files that this program creates ***;
%let temp_dir= %nrbquote(%sysfunc(pathname(work)));
%let work_dir= %nrbquote(%sysfunc(pathname(work)));

%** this is first time program goes to a fail label **;
%** Work directory cannot start with a back slash because savastata needs to cd to it. **;
%if %index(%nrbquote(&work_dir.),\)=1 %then %goto fail18; 

%** Figure out whether the operating system uses forward slashes or back slashes in   **;
 %*  directory paths and make sure that out_dir has the appropriate slash at the end. **;
%let unix=0;
%let drive= ;
%IF %index(%nrbquote(&temp_dir.),\) %THEN %do;
   %let unix=0;   %** unix=0 implies windows platform **;
   %let drive= %qsubstr("&work_dir.",2,2);   %** get drive info eg. "d:"  **;
   %let temp_dir = %nrbquote(&temp_dir.)\;   %** tack on a back slash **;
   %if "&out_dir."=""  %then %goto fail4;  
   %else %if "&out_dir."=" " %then %goto fail4;
   %else %if "&out_dir."="." %then %goto fail4;
   %let slash= %qsubstr("&out_dir.",%length("&out_dir.")-1,1);   %** check if back slash at end **;
   %if "&slash." ^= "\" %THEN %do;   /*"*/
     %let out_dir= %nrbquote(&out_dir.)\;   %** add a back slash at end if it is not there already **;
   %end;
%END;
%ELSE %IF %index(%nrbquote(&temp_dir.),/) %THEN %do;
  %let unix=1;  %** unix or unix-like platform **;
  %let temp_dir = %nrbquote(&temp_dir.)/;  %** tack on a forward slash **;
    %** make sure that out_dir is not a relative directory name like: ../mydata/ **;
  libname ________ "&out_dir.";  %** ________ is a very unlikely libname **;
  %let out_dir=%nrbquote(%sysfunc(pathname(________)));
  %let slash= %qsubstr("&out_dir.",%length("&out_dir.")-1,1);  %** check if back slash at end **;
  %if "&slash."^="/" %THEN %do;
    %let out_dir= %nrbquote(&out_dir.)/;  %** add a forward slash at end if it is not there already **;
  %end;
%END; %** ELSE IF index("temp_dir",/) THEN do loop **;

 

%** Make sure the dataset name and any option passed to savastata is in lowercase. **;
%let dset=%sysfunc(lowcase(%nrbquote(&dset.)));
%if %length(&newname.)>0 %then %let fdset=%nrbquote(&newname.);
%else %let fdset=%sysfunc(lowcase(%nrbquote(&dset.)));
%let options=%sysfunc(lowcase(%nrbquote(&options.)));

%let udset= %qupcase(&fdset.);

%if %index(&syslast.,WORK)^=1 %then %goto fail1;

%** if obs are set to zero, error in program previous to savastata **;
%if &obs.=0 %then %goto fail13;  


%if &udset. = _CONTEN 
 or &udset. = _CONTEN1 
 or &udset. = _CONTEN2
 or &udset. = _CONTEN3 %then %goto fail3;


%** initialize macro vars **;
%let workfmts= 0;  
%let librfmts= 0;
%let vlabels= 0;


%** Initialize macro vars for savastata options **;
%let ascii= 0;
%let float= 0;
%let quotes= 0;
%let messy= 0;
%let intrcool= ;
%let old= ;
%let replace= ;
%let check= 0;
%let char2lab= 0;   

%** need to remove dashes from options as SAS thinks they are minus signs and wants to evaluate stuff **;
 %*  need to do this in a data step so that the double quotes around options do not get added to the *;
 %*  options macro variable *;
data _null_;
 call symput('options',translate("&options."," ","-"));
run;

%if %str(&options.) ^= %str() %then %do;
 %** Find out what options were specified **;
 %if %index(&options.,ascii) %then %let ascii= 1; %** set ascii option  **;
 %if %index(&options.,fl)   %then %let float= 1;  %** set float option  **;
 %if %index(&options.,qu)   %then %let quotes= 1; %** set quote option  **;
 %if %index(&options.,mes)  %then %let messy= 1;  %** set messy option  **;
 %if %index(&options.,old)  %then %let old= old;  %** set old option    **;
 %if %index(&options.,int)  %then %let intrcool= intercooled;  %** set intrcool option **;
 %if %index(&options.,rep)  %then %let replace= replace;       %** set replace option  **;
 %if %index(&options.,rpl)  %then %let replace= replace;       %** set replace option  **;
 %if %index(&options.,che)  %then %let check= 1;  %** set check option  **;
 %if %index(&options.,cha)  %then %let char2lab= 1;  %** set char2lab option  **;
%end; 

%** initialize vars to default setting of Stata if you know you what version of Stata you have **;
%**  Need to set all if you set any. **;
%let u_ver=0.0; %** version of Stata that is being used. decimal values are okay. *; 
                 %* set this if you do not want Stata to be run just figure out what *;
                 %*  version of Stata you are using. *;
%let s_ver=0.0; %** version of Stata that data will be saved as. *; 
                 %* set this only if you set the u_ver variable. *;
                 %* old option will change this if used **;
%let u_SEver=0; %** 1 if SE/MP version of Stata that is being used. *; 
%let s_SEver=0; %** 1 if SE/MP version of Stata that data will be saved as. *; 
                 %* intercooled option will change this if used **;

%* make sure these macro vars are numbers. **;
 %** Stata versions are multiplied by 10 so that no decimal places exist **;
%let u_ver=%sysevalf(&u_ver.*10,integer);
%let s_ver=%sysevalf(&s_ver.*10,integer);

%* test that save version is not higher than the using version *;
%if &s_ver. > &u_ver. %then %goto fail2; 
%if not (&u_SEver.=0 or &u_SEver.=1) %then %goto fail2; 
%if not (&s_SEver.=0 or &s_SEver.=1) %then %goto fail2; 
%** cannot use Intercooled and save to SE **;
%if (&u_SEver.=0 and &s_SEver.=1) %then %goto fail2; 

%if &ascii. = 1 %then %do;
 %** Need to save all the files if ascii specified. **;
 %if &messy. = 0 %then %let messy= 1;

 %let ascii_ver= %qsubstr(&options.,%index(&options.,ascii),%eval(%length(&options.)-%index(&options.,ascii)+1) );  
 %let ascii_ver= %scan(&ascii_ver.,1,%nrstr( ));
 %if &ascii_ver. = ascii %then %do;
   %let ascii_ver= ; %** use default settings **;
 %end;
 %else %do;
   %let ascii_ver=%qsubstr(&ascii_ver.,6,%eval(%length(&ascii_ver.)-5));  
 %end;
 %if &ascii_ver. =  %then %do;
   %* use defaults settings. **;
 %end;
 %else %do;
   %* figure out what version user specified: *;
   %let blen=%length(&ascii_ver.);
   %** replace "se" with a blank **;
   %let ascii_ver=%cmpres(%sysfunc(translate(&ascii_ver.,%nrstr( ), se)));
   %let alen=%length(&ascii_ver.);
   %if &alen. < &blen. %then %do;
     %let u_SEver=1;
     %if &intrcool.^=intercooled %then %let s_SEver=1;
   %end;
   %else %do;
     %let blen=%length(&ascii_ver.);
     %** replace "mp" with a blank **;
     %let ascii_ver=%cmpres(%sysfunc(translate(&ascii_ver.,%nrstr( ), mp)));
     %let alen=%length(&ascii_ver.);
     %if &alen. < &blen. %then %do;
       %let u_SEver=1; 
       %if &intrcool.^=intercooled %then %let s_SEver=1;
     %end;
   %end; %** end of if either SE or MP was specified **;
     %**  < 2000 is just an extremely high version of Stata **;
   %if 0 < &ascii_ver. and &ascii_ver. < 2000 %then %do;
     %* ascii_ver is a number *;
       %let u_ver=&ascii_ver.;
       %let u_ver=%sysevalf(&u_ver.*10,integer);
       %if &old.=old %then %do;
         %if &ascii_ver.=9 %then %do;
            %let s_ver=%eval(&ascii_ver. - 2);
            %let s_SEver=0;              %** Stata 9 saves old only to Stata 7 IC **;
            %let intrcool=intercooled;   %** setting intrcool to intercooled makes this work  **;
                                          %*  as s_SEver gets set to u_SEver later **;
         %end;
         %else %let s_ver=%eval(&ascii_ver. - 1);
       %end;
       %else %let s_ver=&u_ver.;
       %let s_ver=%sysevalf(&s_ver.*10,integer);
   %end;
 %end;
 %* change of default settings based on old and intercooled will be changed later **;
%end; %** end of if ascii=1;


%** check to see if user has set up Windows Stata correctly. **;
%** if not then check other likely places the Stata executable would be. **;
%let fail20= 0;
  %** do not need the stata.exe when ascii or -usesas- running it *;
%if not (&ascii. = 1 or "&script." = "usesas") %then %do;  
 %if &unix. = 0 and %sysfunc(fileexist("&wstata.")) = 0 %then %do %while(&fail20. = 0);
   %let drives= C D Y;
   %let exe10= wsestata wmpstata wstata wsmstata;
   %let exe11= statase statamp stata smstata; %** in version 11 Stata changed the names **;
   %if %sysfunc(substr(&SYSSCPL.,1,3)) = X64 %then %do;
     %** Windows X64 has different names starting in Stata 11 **;
      %*  and it can run normal Stata executables *;
     %let exe11= statase-64 statamp-64 stata-64 statase statamp stata; 
   %end;
   %else %if %sysfunc(substr(&SYSSCPL.,1,3)) = W64 %then %do;
     %** Windows Itanium has different names starting in Stata 11 **;
      %*  and it can run normal Stata executables *;
     %let exe11= statase-ia statamp-ia stata-ia statase statamp stata; 
   %end;
   %let versions= 14 13 12 11 10 9 8 7 6;
   %do i= 1 %to %sysfunc(countw(&drives.));  %** one for each drive **;
    %let ii=%scan(&drives.,&i.,%nrstr( ));
    %do j= 1 %to %sysfunc(countw(&exe11.));  %** one for each exe of Stata **;
     %do k= 1 %to %sysfunc(countw(&versions.));  %** one for each version of Stata **;
      %let kk= %scan(&versions.,&k.,%nrstr( ));
      %if %eval(&kk. < 11 ) %then %do;
        %let jj= %scan(&exe10.,&j.,%nrstr( ));
      %end;
      %else %do;
        %let jj= %scan(&exe11.,&j.,%nrstr( ));
      %end;
      %let wstata= %str(&ii.:\Stata&kk.\&jj..exe);
      %if %sysfunc(fileexist("&wstata.")) = 0 %then %do;
        %let wstata= %str(&ii.:\Program Files\Stata-&kk.\&jj..exe);  %** Stata-9 **;
      %end;
      %else %goto exist;  %** file exists **;
      %if %sysfunc(fileexist("&wstata.")) = 0 %then %do;
        %let wstata= %str(&ii.:\Program Files (x86)\Stata-&kk.\&jj..exe);  %** Stata-9 **;
      %end;
      %else %goto exist;  %** file exists **;
      %if %sysfunc(fileexist("&wstata.")) = 0 %then %do;
        %let wstata= %str(&ii.:\Program Files\Stata&kk.\&jj..exe);   %** Stata9 **;
      %end;
      %else %goto exist;  %** file exists **;
      %if %sysfunc(fileexist("&wstata.")) = 0 %then %do;
        %let wstata= %str(&ii.:\Program Files (x86)\Stata&kk.\&jj..exe);   %** Stata9 **;
      %end;
      %else %goto exist;  %** file exists **;
      %if %sysfunc(fileexist("&wstata.")) = 0 %then %do;
        %let wstata= %str(&ii.:\Stata-&kk.\&jj..exe);  %** Stata-9 **;
      %end;
      %else %goto exist;  %** file exists **;
      %if %sysfunc(fileexist("&wstata.")) = 0 %then %do;  
        %let wstata= %str(&ii.:\Stata&kk.\&jj..exe);   %** Stata9 **;
      %end;
      %else %goto exist;  %** file exists **;
      %if %sysfunc(fileexist("&wstata.")) = 0 %then %do;
        %let wstata= %str(&ii.:\Stata\&jj..exe);
      %end;
      %else %goto exist;  %** file exists **;
      %if %sysfunc(fileexist("&wstata.")) = 0 %then %do;
       %** nothing **;
      %end;
      %else %goto exist;  %** file exists **;
     %end;  %** of k loop **;
    %end;  %** of j loop **;
   %end;  %** of i loop **;
   %do;  %** now check path for Stata executable **;
     %let i=1;
     %let delim=%str(;);
     %do %until (%qscan(%sysget(PATH),&i.,%str(&delim.)) = );
      %do j= 1 %to %sysfunc(countw(&exe11.)); %** one for each exe of Stata **;
       %let jj= %scan(&exe11.,&j.,%nrstr( ));
       %let wstata= "%qscan(%sysget(PATH),&i.,%str(&delim.))\&jj..exe";
       %if %sysfunc(fileexist("&wstata.")) %then %do; 
         %let fail20= 2; 
         %let i= 200000;  %** break loop if found it **;
       %end;
      %end; %** of j loop **;
      %let i= %eval(&i.+1);
     %end; %** of until loop **;
     %if fail20= 2 %then %goto exist;  %** file exists **;
   %end; %** of checking path for Stata executable **;
   %if %sysfunc(fileexist("&wstata.")) = 0 %then %do;
     %let wstata=NO STATA EXECUTABLE FOUND;
     %let fail20= 1;  %** give up **;
   %end;
  %exist: ;
  %if &fail20. = 0 %then  %let fail20= 2;  %** found file so break while loop **;
 %end;  %** end of if unix=0 then do while loop **;

%end; %** end of if &ascii. = 0  and &script. = "usesas" **;
  
%if &fail20. = 1 %then %goto fail20;

%if not (&ascii. = 1 or "&script." = "usesas") %then %do;  
  %put SAVASTATA is going to use this Stata executable:;
  %if &unix. = 0 %then %do;
    %put "     %nrbquote(&wstata.)";
    %put ;
  %end;
  %else %do;
    %put "     %nrbquote(&ustata.)";
    %put ;
  %end;
%end;

libname ________ "&out_dir.";  %** ________ is a very unlikely libname **;
%if &syslibrc.^=0 %then %do;
 libname ________ clear;  %** do away with it now **;
 %goto fail5;  %** exit if not a valid pathname **;
%end;

libname ________ clear;  %** do away with it now **;

%* -usesas- sets messy to on so it can control where the files are put **;
%if &messy. = 1 %then %do;
  %**  Use the output directory to store the SAS program files that this macro creates. ***;
 %let temp_dir= %nrbquote(&out_dir.); 
 %let work_dir= %nrbquote(&out_dir.); 
 %if &unix. = 0 %then %do;
  %let windrive= %qsubstr("&out_dir.",2,2);   %** get drive info eg. "d:"  **;
  %sysexec &windrive.;  ** change to whatever drive files are going **;
 %end;
 %** sysexec requires no quotes even when changing to dirs with spaces in windows or unix **;
 %sysexec cd %nrbquote(&out_dir.) ;   %** change to the drive and directory where the Stata do-files are. **;
%end;

%if "&u_dir." ^= "" %then %do;  %** this happens when -usesas- or savas script call savastata **;
 %let out_dir= %nrbquote(&u_dir.);
%end;

%** run Stata to find out what version of Stata is being used. **;
 %*  -usesas- passes &version. to savastata but savas needs to figure it out here **;
 %*   Stata versions are multiplied by 10 so that no decimal places exist **;
%if &script. = usesas %then %do;
  %** force this since a -usesas- user could have incorrectly preset this **;
  %let u_ver= %sysevalf(&version.*10,integer);
  %** force this since a -usesas- user could have incorrectly preset this **;
   %*  and -usesas- needs to have s_ver = u_ver since it does not save data. **;
  %let s_ver= &u_ver.;   
  /** U_SE should only equal either 1 or 0: `= ("`c(SE)'" == "1") + ("`c(MP)'" == "1")' **/
  %if &U_SE. >= 1  %then %let u_SEver= 1;
%end;
%else %if &u_ver. = 0 and &ascii.=0 %then %do; 
 %let tempfiles= &tempfiles. _&tfns._version.do _&tfns._version.log _&tfns._ver.log;
 data _null_;
  file "&temp_dir._&tfns._version.do"; 
  put " capture program drop stata_v";
  put " program define stata_v, nclass";
  put " capture log close ";
  put " quietly log using ""&temp_dir._&tfns._ver.log"" ";
  %** macro var version can have decimal places **;
  put ' display "%let version= " _caller() " ; " '; 
  put ' display "%let SE= $S_StataSE ;" ';
  put ' display "%let MP= $S_StataMP ;" ';  
  put " quietly capture log close " ;
  put " end ";
  put " stata_v";
 run;

 %let uspace= 0;  %** flag if in non-Windows and directory name has a space in it **;
 %let nocd= no;
 %if "&nosave." = "" %then %do;  %** if not run by -usesas- **; 
  %if &unix. = 1 %then %do;
   %** sysexec requires no quotes even when changing to dirs with spaces in windows or unix **;
    %* change to the drive and directory where the Stata do-files are. **;
    %sysexec cd %nrbquote(&work_dir.) ;

    %** test if able to cd to the work directory **;
    %sysexec echo $PWD > %nrbquote(&work_dir./_&tfns._tdir.txt);
    data _null_;
     infile "%nrbquote(&work_dir./_&tfns._tdir.txt)" lrecl= 32767 truncover;
     input test $200.;
     call symput('tdir',_infile_);
    run;
    %if %nrbquote(&tdir.) ne %nrbquote(&work_dir.) %then %do; 
      %let nocd= cd;
      %sysexec cd /tmp/ ;
    %end;
 
     %** Run Stata in batch from within the directory where the temp files are. **;  
    %if &nocd. = cd %then %do;
      %sysexec %nrbquote(&ustata.) -b do "&temp_dir._&tfns._version.do";  
    %end;
    %else %do;
      %sysexec %nrbquote(&ustata.) -b do "_&tfns._version.do";  
    %end;
    %if &sysrc. ^= 0 %then %do;
      %goto fail21;
    %end;
  %end;  %** if unix=1 do loop **;
  
  %if &unix. = 0 %then %do;
   %sysexec &drive.;
   %** sysexec requires no quotes even when changing to dirs with spaces in windows or unix **;
   %sysexec cd %nrbquote(&work_dir.) ;
       %** Run Stata in batch. **;
   %sysexec "&wstata." /e do "&temp_dir._&tfns._version.do";   
  %end;  %** if unix = 0 then do loop **;

  %if %sysfunc(fileexist("&temp_dir._&tfns._ver.log")) %then %do;
    %include "&temp_dir._&tfns._ver.log";
  %end;
  %else %goto fail22;
  
  %let u_ver= %sysevalf(&version.*10,integer);

  %** stata 6 cannot handle $S_StataSE or $S_StataMP *;
  %if &SE. = E %then %let SE=;
  %if &MP. = P %then %let MP=;

  %** no difference between MP and SE to savastata **;
  %if &SE. = SE or &MP. = MP %then %let u_SEver= 1;
   
 %end; %** end of "&nosave." ^= "" (not being run by -usesas-) **;
%end; %** if script = usesas, else if &u_ver. = 0 and &ascii. = 0 then do loop **; 

%if &old. = old %then %do;
  %if 90 <= &u_ver. and &u_ver. < 100 %then %do;
    %let s_ver= 70;  %** Stata 9 -saveold- saves to version 7 IC only **;
    %let s_SEver= 0;  %** Stata 9 -saveold- saves to version 7 IC only **;
    %let intrcool= intercooled;   %** setting intrcool to intercooled makes this work  **;
                                  %*  as s_SEver gets set to u_SEver later **;
  %end;
  %else %let s_ver= %eval(&u_ver. - 10);  %** otherwise subtract 1 (by subtracting 10) **;
  %if &u_ver. >= 100 and &u_ver. < 110 %then %let s_ver= 91; %** Stata 10 saves like Stata 9.1 not 9.0 **;
%end;
%else %let s_ver= &u_ver.;

%if &s_SEver. = 0 %then %let s_SEver= &u_SEver.;
%if &s_SEver. = 1 and &intrcool. = intercooled  %then %let s_SEver= 0;

%if &s_ver. > &u_ver. %then %goto fail2; 
%if not (&u_SEver. = 0 or &u_SEver. = 1) %then %goto fail2; 
%if not (&s_SEver. = 0 or &s_SEver. = 1) %then %goto fail2; 
%** cannot use Intercooled and save to SE **;
%if (&u_SEver. = 0 and &s_SEver. = 1) %then %goto fail2; 

 
%** Have to be using Stata SE to specify that you are saving a Stata Intercooled dataset. **;
%if &u_SEver. = 0 %then %let intrcool= ; 


%* char2lab can only be run by savas or -usesas- **;
%if &char2lab. = 1 %then %do;
 %** s_ver is multiplied by 10 to make sure no decimal exists **;
 %if &s_ver. < 90 %then %do;
  %** Stata 9 started allowing value labels to be up to 32,000 characters long.**;
  %** Stata 8 will ignore such value labels if dataset is read into Stata 8 **;
  %put %upcase(warning): The option char2lab is not beneficial prior to Stata 9.   *;
  %let char2lab=0;
 %end; 
 %if ("&script." = "" ) %then %do;
  %** The option char2lab is not allowed when SAVASTATA is not run by the savas script **;
   %*  or the Stata command -usesas-.   **;
  %put %upcase(warning): The option char2lab is not allowed.                                         *;
  %if &s_ver. >= 90 %then %do;
    %put Consider running the SAS macro CHAR2FMT before running SAVASTATA.                    *;
    %put For more help check here: &char2fmthttp.        ;
  %end;
  %let char2lab=0;
 %end; 
 %if &char2lab.=0 %then %do;
  %put %upcase(warning): char2lab option will be ignored.           * ; 
 %end; 
%end; 


%* set max limits for Stata dataset  **;
%* For SE or Intercooled the max number of obs is: 2,147,483,647 **;
%let maxobs=2147483647;
%* set max string variable length and max value label length **;
%if &s_ver.<70 %then %do;  %** Stata 7 was first version with SE **;
 %let maxstrvarlen=80;  
 %let maxvallablen=80; 
%end;
%else %if &s_SEver.=0 and &s_ver.<=90 %then %do;  %** intercooled versions 7, 8 and 9.0 **;
 %let maxstrvarlen=80;
 %let maxvallablen=80;  
%end;
%else %if &s_SEver.=1 and &s_ver.<=90 %then %do;  %** Stata 7 SE, 8 SE, and 9.0 SE **;
 %let maxstrvarlen=244; 
 %let maxvallablen=244; 
%end;
%else %if &s_ver.>=91 %then %do;                %** 9.1+ SE and Intercooled are the same **;
 %let maxstrvarlen=244; 
 %let maxvallablen=32000; 
%end;


%let dta_exists=0;
%if "&script." ^= "usesas" %then %do;
  %if %sysfunc(fileexist("&out_dir.&fdset..dta")) %then %do;
    %let dta_exists= 1;
    %if &replace. ^= replace and &ascii. = 0 %then %do;
      %goto fail7;
    %end;
  %end;
%end;


%** check for long character variables only if using Stata 9 or higher **;
%if &u_ver. >= 90 %then %do;
 proc contents data= &dset. out= _conten noprint;
 run;
 
 proc sort data= _conten;
  by type;
 run;

 %let max_clen_count=0; 
 data _null_;
  set _conten (where=(type=2)) end=lastobs ;
  retain max_clen_count 0;  
  by type;
  if length > &maxstrvarlen. then do;
    max_clen_count = max_clen_count + 1;
   %if &char2lab. = 1  %then %do; 
    if max_clen_count=1 then do;
     %** if a var has a length longer than needed then it may be needlessly converted     **;
      %*  if the trailing blanks were removed first...which savastata does after char2fmt **;
      %*  is run.  not worth moving length optimization to be before here as it has to    **;
      %*  be done after char2fmt as well **;
      put " This is a list of character variables that are going to be made into        *";
      put " numeric variables but have value labels containing their character contents *";
      put " because they contain more than &maxstrvarlen. characters.                   *";
    end;
    put "  " name  "         *";
   %end;
  end;
  if last.type and type=2 then do;
   call symput( 'max_clen_count', compress(left( put( max_clen_count, 10. ) ) ) ) ;  
  end;
 run;
 
 %** only do char2fmt if user asked for it and have long character vars that need  **;
  %*  to be made into labels **;
  %* char2fmt creates and deletes temporary dataset _conten2 **;
 %if (&char2lab.=1) and (&max_clen_count. > 0 ) %then %do;  
   %char2fmt(dset=&dset. , maxlen=&maxstrvarlen. , temp_dir=%nrbquote(&temp_dir.) , tfns=&tfns. );
   %let workfmts=%sysfunc(cexist(WORK.FORMATS));
   %if &workfmts. = 1 %then %let vlabels= 1;
 %end;
 %** end begin char2lab process **;
%end; %** of if s_ver>=90  **;

 %** run proc means to check data after potential change in data by char2fmt **;
%if &check.=1 %then %do;
 proc printto print="&out_dir.&fdset._SAScheck.lst" new ; run;
 proc means data=&dset.;
 proc contents data=&dset. position;
 proc print data=&dset. (obs=5);
 run;
 proc printto;  %** ends printing to means.lst and returns printing to normal **;
 run;
%end;

%** Here starts the processing of the dataset. **;
%** Create a dataset of the dataset info of the input dataset. **;
proc contents data=&dset. out=_conten noprint;
run;

%** Initialize macro vars **;
%let nv=0;
%let cv=0;
%let ch=0;
%let ln=0;
%let ob=0;
%let lo=0;
%let dq=0;
%let dq1=0;
%let dy=0;
%let dyc=0;  %** initialize to 0 for now **;
%let bign=0; 
%let bign1=0; 
%let name=0; 
%** Check for vars with names that are used in savastata like: _N and _______N. **;
data _null_;
 set _conten(keep=name ) end=lastobs;
 retain bign bign1 0;
 name=lowcase(name);
 if name="_n" then bign=1;
 if name="_______N" then bign1=1;
 if name="___nv___" then call symput("nv","1");
 if name="___cv___" then call symput("cv","1");
 if name="___ch___" then call symput("ch","1");
 if name="___ln___" then call symput("ln","1");
 if name="___ob___" then call symput("ob","1");
 if name="___lo___" then call symput("lo","1");
 if name="___dq___" then call symput("dq","1");
 if name="___dq1__" then call symput("dq1","1");
 if name="___dy___" then call symput("dy","1");
 if name="___dyc__" then call symput("dyc","1");
 if name="_name_" then call symput("name","1");

 if lastobs then do;
   call symput("bign",bign);
   call symput("bign1",bign1);
 end;
run;

/** DR's little fix **/
%let crdate=SAVASTATA created this dataset on %sysfunc(date(),date9.);

%** An attempt to rename _N to _______N will fail
 %*  because both vars exist in the dataset. **;
%if &bign.=1 and &bign1.=1 %then %goto fail8;  

 %let bvar=________;
 %if &nv.=1 %then %do; %let bvar=___nv___; %goto fail9; %end;
 %if &cv.=1 %then %do; %let bvar=___cv___; %goto fail9; %end;
 %if &ch.=1 %then %do; %let bvar=___ch___; %goto fail9; %end;
 %if &ln.=1 %then %do; %let bvar=___ln___; %goto fail9; %end;
 %if &ob.=1 %then %do; %let bvar=___ob___; %goto fail9; %end;
 %if &lo.=1 %then %do; %let bvar=___lo___; %goto fail9; %end;
 %if &dq.=1 %then %do; %let bvar=___dq___; %goto fail9; %end;
 %if &dq1.=1 %then %do; %let bvar=___dq1__; %goto fail9; %end;
 %if &dy.=1 %then %do; %let bvar=___dy___; %goto fail9; %end;
 %if &dyc.=1 %then %do; %let bvar=___dyc__; %goto fail9; %end;
 %if &name.=1 %then %do; %let bvar=_name_; %goto fail9; %end;



%* invalid Stata vars *;
%let bstatavs='_ALL','_B','BYTE','_COEF','_CONS','DOUBLE','FLOAT','IF','IN','INT','LONG','_N','_PI','_PRED','_RC','_SE','_SKIP','_UNIFORM','USING','WITH';

%let cq=0;
data _conten;
 length __strvar 8 llabvars $32000; 
 set _conten end=lastobs;
 %** count how many variable labels need to be truncated **;
  %*  and create a list of variables that need variable labels saved as notes **;
 retain llabcnt 0 llabvars ""; 
 name=upcase(name);  %** make sure all variable names are uppercase **;
  if (substr(name,1,3)='STR') then do;  %** Look for variables named like "str14" which is **;
                                         %* an invalid variable name in Stata if it was in **;
                                         %* lowercase.  Leave them in uppercase.           **;
    __strvar=substr(name,4,length(name)); 
     _error_=0;  %** SAS creates _error_=15 if _strvar evaluates to ., so clear it. **;
    if (__strvar in(.,0)) then name=lowcase(name); 
    else call symput("bstatavs","&bstatavs.,'"||trim(name)||"'");  %** add str var to list **;
  end; 
  %** Check for variable names that are invalid variable names in Stata if they were in  **;
   %*  lowercase and leave them in uppercase. **;
  else if name ~in(&bstatavs.) then name=lowcase(name);

 %if &bign.=1 and &bign1.=0 %then %do;
  if (name='_N') then do;
   put "%upcase(warning): SAVASTATA has renamed Stata invalid variable _N to _______N   * ";
   name='_______N';
    call symput("bstatavs","&bstatavs.,'"||trim(name)||"'");  %** add _______N var to list **;
  end;
 %end;
  if label^=""  then do;
   %** this does not need to be version controlled as Stata has only ever allowed 80 characters *;
    %* for variable labels: *;
   llabel = label;  ** store long labels in notes in Stata **;
   if length(label)>80 then do;
     llabcnt=llabcnt+1;
     label=substr(label,1,80);   %** need to test length before escaping $ and \ etc. **;
     if llabcnt = 1 then do;
      put "%upcase(warning): This is a list of variables that have had their label truncated to 80 characters    * ";
      put "          and had their original label stored as a note in Stata.                            * ";
      llabvars = '"' || trim(lowcase(name)) || '"';
     end;
     else llabvars = trim(llabvars) || ',"' || trim(name) || '"';
     put @10 name "  * ";
   end;

    %** prepare label to be written to _labels.do **;
   %if &u_ver. < 90 or "&script." = "usesas" %then %do;
     %** replace two back slashes with four, tranwrd is like subinstr **;
     if index(label,"\\") then label = tranwrd(label,"\\","\\\\");
     %* if index(llabel,"\\") then llabel = tranwrd(llabel,"\\","\\\\"); %** this does not matter to Stata, all will reduced to one **;
   %end;


   %** replace all left quotes with right quotes since they mess things up **;
   if index(label,"`") then label = tranwrd(label,"`","'"); 
   if index(llabel,"`") then llabel = tranwrd(llabel,"`","'"); 
   %** the above can create a right compound quote **;

   %** escape all dollar signs **;
   if index(llabel,"$") then llabel = tranwrd(llabel,"$","\$");
   %** if variable label contains a compound quote. **;
   if index(label,"`"||'"') or index(label,'"'||"'") then do;  
     call symput("cq","1"); 
        %if &quotes.=1 %then %do;
          label = tranwrd(label,"`"||'"',"''");  %* replace left compound quote with two single quotes *;
          label = tranwrd(label,'"'||"'","''");  %* replace right compound quote with two single quotes *;
        %end;
   end;
   %** if variable llabel contains a compound quote. **;
   if index(llabel,"`"||'"') or index(llabel,'"'||"'") then do;  
     call symput("cq","1"); 
        %if &quotes.=1 %then %do;
          llabel = tranwrd(llabel,"`"||'"',"''");  %* replace left compound quote with two single quotes *;
          llabel = tranwrd(llabel,'"'||"'","''");  %* replace right compound quote with two single quotes *;
        %end;
   end;
  end; %** if var has a label **;
  if lastobs then call symput("llabvars",trim(llabvars));  


   length w d $5; 
   w=formatl; 
   d=formatd; 
   format=upcase(format);
   orig_fmt=format;
   if (format='' & formatl>0) then format = compress('%'||w||'.'||d||'f',' ');
   else if (format='F') then format = compress('%'||w||'.'||d||'f',' ');
   else if (format='BEST') then format = compress('%'||formatl||'.0g');
   else if (format='DATE' & formatl<9) then format = '%d';
   else if (format='DATE' & formatl>=9) then format = '%dDlCY';
   else if (format='DDMMYY' & formatl<10) then format = '%dD/N/Y';
   else if (format='DDMMYY' & formatl>=10) then format = '%dD/N/CY';
   else if (format='MMDDYY' & formatl<10) then format = '%dN/D/Y';
   else if (format='MMDDYY' & formatl>=10) then format = '%dN/D/CY';
   else if (format='YYMMDD' & formatl<8) then format = '%dYND';
   else if (format='YYMMDD' & 8<=formatl<10) then format = '%dY-N-D';
   else if (format='YYMMDD' & formatl>=10) then format = '%dCY-N-D';
   else if (format='DAY') then format = '%dd';
   else if (format='MONTH') then format = '%dl';
   else if (format='YEAR' & formatl<4) then format = '%dY';
   else if (format='YEAR' & formatl>=4) then format = '%dCY';
   else if (format='MONNAME') then format = '%dM';
   else if (format='MONYY' & formatl<7) then format = '%dlY';
   else if (format='MONYY' & formatl>=7) then format = '%dlCY';
   else if (format='WEEKDAY') then format = '%dD';
   else if (format='WORDDATE') then format = '%d';
   else if (format='WORDDATX') then format = '%d';
   else if (format='YYMM') then format = '%d';
   else if (format='YYMON' & formatl<7) then format = '%dYl';
   else if (format='YYMON' & formatl>=7) then format = '%dCYl';
   else if (format='YYQR') then format = '%dCY-q';
   else format='default';

   if type=2 then format='default';  %** make all string vars be default format **;
run;

%if &cq.=1 and &quotes.=0 %then %goto fail10;  %** Variable label contains a compound quote **;


 %** initialize macro vars **;
%let VAR_N  = 0 ;   %* number of numeric variables *;
%let VAR_C  = 0 ;   %* number of character variables *;
%let longname=0;

%** check for varnames longer than 8 characters and rename them **;
%if &isysver.<7 %then %goto skip6;
%if &s_ver.< 70 %then %do;   
 data _conten;     
  length longname $32;
  set _conten;
  longname = name;
  if (length(name)>8) then do; 
   s_name=right(substr(name,1,4)); %** renaming vars after proc means (check) done! oh, well*;
   call symput("longname","1"); 
  end; 
 run;
 
 
 %if &longname.=1 %then %do;   %** only do if there is at least one varname > 8 **;
 %** Check that variables have not been renamed to names that already exist in the dataset. **;
  proc sort data=_conten; 
   by s_name name;
  run;
  
  data _conten;  
   set _conten; 
   by s_name;
   retain count start 0; 
   if first.s_name then count=0;
   if (length(name)>8) then do; 
    start=start+1; 
    count=count+1;
    name=compress(s_name||count);
    if start=1  then do; 
     %** print to log **;
     put " ";
     put "%upcase(warning): Stata 6 does not allow variable names longer than 8 characters.   * ";
     put " ";
     put "%upcase(warning): List of long variable names that SAVASTATA has renamed:   *  ";
     put " "; 
     put " Original long name"  @35 " New short name    *  "; 
     put " "; 
    end; 
    put " " longname @33 " = " @36 name "    *  ";
   end; %** end of if (length(name)>8) do loop **;
  run;
 
  proc sort data=_conten; by name;
  run;

  %let fail11=0;  %** initialize fail11 macro var **;
  data _null_;
   set _conten;
   by name;
   if not (first.name and last.name) then do; %** means there is a repeat in varnames **;
     call symput("fail11","1"); 
   end;
 
  run;
  %if &fail11.=1 %then %goto fail11;  

 %end;   %** end of if long=1 the do loop **; 
%end;   %** end of if &s_ver.< 70 do loop **; 
%skip6: ;  %** Skip fixing stuff for Stata 6 if using SAS 6 **;

proc sort data=_conten; by type;
run;

%let var_n=0;
%let var_c=0;
%let avars=0;
%** Count up number of numeric and number of character variables. **;
data _null_ ;
 set _conten end=lastobs;
 by type;
 if first.type then do;
  var_non=0;
  var_noc=0;
 end;
 if type=1 then do;   %* numeric vars **;
  var_non + 1 ;
 end;
 if type=2 then do;   %* character vars **;
  var_noc + 1 ;
 end;

 %** Create macro vars containing final number of vars. **;
 if last.type and type=1 then call symput( 'VAR_N', left( put( var_non , 5. ) ) ) ;
 if last.type and type=2 then do;
  call symput( 'VAR_C', left( put( var_noc, 5. ) ) ) ;
 end;

  %** AVARS is total number of variables **;
 if lastobs then call symput( 'AVARS', compress(left( put( _n_, 5. ) ) ) ) ;  

run ;

 %if &AVARS.=0 %then %do ;
   %goto fail12 ;
  %end ;


 %*** Figure out minimum safe storage type for each variable. ***;
 %if &s_ver. < 80 %then %do;
   %let bytemin  = -127; 
   %let bytemax  =  126;
   %let intmin   = -32767;
   %let intmax   =  32766;
   %let longmin  = -2147483647;
   %let longmax  =  2147483646;
 %end; %** of if s_ver < 80 then do loop **;
 %else %do;  %** Starting with Stata 8 there is a smaller range due to storage of special missings **;
   %let bytemin  = -127; 
   %let bytemax  =  100;
   %let intmin   = -32767;
   %let intmax   =  32740;
   %let longmin  = -2147483647;
   %let longmax  =  2147483620;
 %end; %** of if s_ver < 80 then do loop **;


 %** Initialize macro vars **;
 %let nobs=0;  
 %let dq_fail=0;
 %let dy_and_dq_fail=0;
 %let dq_fix=;
 %let dyc=%sysfunc(byte(162)); %** this makes cents **;
 %let sm=0;

  data _conten1;
   set work.&dset. end=___lo___;
    format _all_;   %** remove all formats and informats **;
    informat _all_;

    %** Count up observations since using _n_ to step through arrays. **;
    array ___ob___[1] _temporary_ (1*0);
   
    ___ob___[1]=___ob___[1]+1;


    %if &VAR_N.>0 %then %do;  %** process numeric vars *;
       array ___nv___ [&VAR_N.] _numeric_;  %** all numeric variables in dataset **;
       array ___ln___ [&VAR_N.] _temporary_ (&VAR_N.*3);

       %** use the temporary variable _n_ to step through the arrays so as **;
        %*  not to create another var (i).  _n_ resets itself at next obs. **;
       do _n_ = 1 to &VAR_N.;
          %** check to see if any numeric var has special missing values **;
         if .a<=___nv___[_n_]<=.z then call symput("sm","1");

         if ___ln___[_n_] ne 8 and ___nv___[_n_] ne .  then do ;
           if ___nv___[_n_] ne int(___nv___[_n_]) then ___ln___(_n_)=8; %** all decimal vars length 8 *;
           else  %* check numeric variables that are integers *;
            if &BYTEMIN.<=___nv___[_n_]<=&BYTEMAX. then ___ln___(_n_)= max( ___ln___(_n_), 3 ) ;
           else
            if &INTMIN.<=___nv___[_n_]<=&INTMAX. then ___ln___(_n_)= max( ___ln___(_n_), 4 ) ;
           else
            if &LONGMIN.<=___nv___[_n_]<=&LONGMAX. then ___ln___(_n_)= max( ___ln___(_n_), 6 ) ;
           else
            ___ln___(_n_)=8;
         end ;
       end ;   %*** end of _n_=1 to &VAR_N. ***;
    %end;  %** end of processing numeric vars **;
   


     %if &VAR_C.>0 %then %do;  %* now process the character variables *;
       array ___cv___( &VAR_C. ) _character_ ;  %** all character variables in dataset **;
       %** temp array vars are retained variables **;
       array ___ch___( &VAR_C. ) _temporary_ (&VAR_C.*1); %** var length **;
       array ___dq___( &VAR_C. ) _temporary_ (&VAR_C.*0); %** var has dq **;
       array ___dy___( &VAR_C. ) _temporary_ (&VAR_C.*0); %** var has dyc **;
       array ___dq1__( 1 ) _temporary_ (1*0); %** any var has dq **;
       array ___dyc__(1) $32766 _temporary_ ;  %** all vars that have dqs and dycs **;

         do _n_ = 1 to &VAR_C. ;
           %** check for double quotes in character variables **;
           if ___dq___[_n_]=0 then do;  %** once a var is known to have a double quote **;
                                       %*  stop checking it for a double quote       **;
             if index(___cv___[_n_],compress(' " ')) then do;
               ___dq___[_n_]=1; 
               %** temp array vars are retained variables **;
               ___dq1__[1]=1; 
             end;
           end;
           %** also check for &dyc. char in character variables **;
           if ___dy___[_n_]=0 then do;  %** once a var is known to have a dyc  **;
                                         %*  stop checking it for a dyc        **;
             if index(___cv___[_n_],"&dyc.") then ___dy___[_n_]=1;  
              %** temp array vars are retained variables **;
           end;

           %* increase character length until the maximum needed *;
           if ___ch___[_n_] < length(___cv___[_n_]) then ___ch___[_n_]=length(___cv___[_n_]);
         end; %** of do _n_ = 1 to &VAR_C. **;
     %end;   %* end of processing character vars *;

        if ___lo___ then do ;
          call symput("nobs",compress(___ob___[1]));
          %if &VAR_N.>0 %then %do;
             do  _n_ = 1 to &VAR_N. ;
               ___nv___[_n_]=___ln___[_n_]; %** replace values of variables with their length **;
             end;
          %end;

          %if &VAR_C.>0 %then %do;
            %if &u_ver.>=70 %then %do; %** since long varnames could be renamed for Stata 6   **;
                                         %*  and -foreach- does not work in 6, do not do this. *;
              do _n_ = 1 to &VAR_C.;
               if ___dy___[_n_]=0 and ___dq___[_n_]=1 then do;
                 %** create a list of char vars that need fixing **;
                  %* do same upcasing/lowcasing as before **;
                  if upcase(trim(vname(___cv___[_n_]))) in(&bstatavs.) then
                    ___dyc__[1]= trim(upcase(vname(___cv___[_n_])))||trim(" ")||trim(___dyc__[1]); 
                  else 
                   ___dyc__[1]= trim(lowcase(vname(___cv___[_n_])))||trim(" ")||trim(___dyc__[1]); 
                  if upcase(trim(vname(___cv___[_n_]))) = "_N" then
                   ___dyc__[1]= trim("_______N")||trim(" ")||trim(___dyc__[1]); 
               end; %** of if var had dq but not dyc **;
               if ___dy___[_n_]=1 and ___dq___[_n_]=1 then call symput("dy_and_dq_fail","1");  
              end;  %** of do _n_ to var_c **;
            %end;  %** if u_ver>=70 loop **;
            %else %do;
              %** if previous to version 7 then force replacing  **;
               %*  double quotes with single quotes **;
              if ___dq1__[1]=1 then call symput("dy_and_dq_fail","1");  
            %end;
              %** create a macro var that has char vars that have double quotes **;
               %*  and can be fixed. **;
              if ___dq1__[1]=1 then call symput("dq_fix",trim(___dyc__[1]));
              if ___dq1__[1]=1 then call symput("dq_fail","1");  

              do _n_ = 1 to &VAR_C.;
              %** this converts the character data to numeric data *;
               ___cv___[_n_]=___ch___[_n_]; %** replace values of variables with their length **;
              end;
          %end; %* of if &VAR_C.>0 then do **;
          output;
        end;
  run;

 %if %sysfunc(fileexist(&usagelog.)) %then %do;
  data _null_;
   file &usagelog. mod;
   put "   Input SAS dataset has &nobs. obs and &AVARS. vars" ;
 %end;

%if &nobs.=0 %then %goto fail13;
%if &nobs.>&maxobs. %then %goto fail25; 

%if &u_ver.>=70 %then %do; %** since varnames could be renamed for Stata 6   **;
                             %*  then do not do this. *;
  %if &dy_and_dq_fail.=1 and &quotes.=0 %then %goto fail14;
%end;
%else %do;
  %if &dq_fail.=1 and &quotes.=0 %then %goto fail14;
%end;

%** Stata 7 and earlier cannot save special missing values **;
%if &sm.=1 and &s_ver. < 80 %then %do;
 %put %upcase(warning): The dataset WORK.&dset. contains special missing data that will be converted to missing (.)   *  ; 
%end;

%** Since _conten1 is one obs in the dataset transpose to create variable _name_. **;
proc transpose data =_conten1 out=_conten1;
  var _all_;
run;


%** Put _conten dataset in the variable order of the original dataset. **;
proc sort data=_conten;
  by varnum;
run;

%** Figure out the minimum required length for accurate storage of the col1 variable. **;
data _conten1;
 set _conten1; 
 varnum= _n_;  %** make the variable order be the order they are in dataset **;
run;

data _conten;
 merge _conten(keep=name varnum type label llabel orig_fmt format)
       _conten1(keep=_name_ varnum col1);
 by varnum;
run;


data _conten;
  length c_len $10 stype $10 oformat $10; 
  set _conten;
  retain lcvarcnt 0; %** count how many variables need to be truncated  **;
   c_len=compress(col1);
   n_len=input(c_len,8.);

   %** name has been fixed if too long or left uppercase **;
    %*  and _name_ is untouched **;

  if type=1 /***  and format="default" ***/ then do;  %** numeric variables **;
   if c_len="3" then do; stype="byte"; oformat="best4."; end;
   else if c_len="4" then do; stype="int"; oformat="best6."; end;
   else if c_len="6" then do; stype="long"; oformat="best11."; end;
   else if c_len="8" and &float.=1 then do; stype="float"; oformat="best18."; end;
   else if c_len="8" and &float.=0 then do; stype="double"; oformat="best18."; end;  
  end;
  /******************
  if type=1 and format^="default" then do;  %** numeric variables with formats **;
   stype="double"; oformat="best17.";
  end;
  ******************/


  if type=2 then do;  %** character variables **;
   if n_len>&maxstrvarlen. then do;
    c_len="&maxstrvarlen."; 
    if &char2lab. = 0 then do;
      lcvarcnt = lcvarcnt + 1;
      if lcvarcnt = 1 then do;
       put "%upcase(warning): This is a list of variables that have been truncated to &maxstrvarlen. characters.   * ";
       if (&s_ver. >= 90) then do; 
        if ("&script." = "") then do; 
         put "Consider using the SAS macro CHAR2FMT to convert them to numeric variables with   *";
         put " SAS formats containing their character data.  SAVASTATA saves formats as value labels in Stata.  *";
        end;
        else do;
         put "Consider using the char2lab option to encode them to numeric with value labels in Stata.  *";
        end;
       end; %* end of if saving to Stata version 9 or higher **;
      end;
      put @10 name '  * ';
    end; 
   end; 
   period='.';
   oformat=compress("$char"||c_len); 
   oformat=compress(oformat||period); 
   stype=compress("str"||c_len); 
   stype=left(stype);
  end; %** end of if type=2 do loop **;
run;


  %** Figure out the record length. **;
data _null_;
  set _conten end=lastobs;
  retain bpos lepos 0;
   if type=1 then do;
    if stype="byte" then len=1; 
    if stype="int" then len=2; 
    if stype="long" then len=4;
    if stype="float" then len=4;
    if stype="double" then len=8;
   end;
   if type=2 then len=input(c_len,8.); 

   bpos=lepos+1;
   lepos=bpos+len-1;

   if lastobs then do;
    call symput("reclen",compress(lepos));
   end;
run;

    
%if &s_ver.>=80 %then %do;
proc format;
   value ___mi___ 
    .a=".a"
    .b=".b"
    .c=".c"
    .d=".d"
    .e=".e"
    .f=".f"
    .g=".g"
    .h=".h"
    .i=".i"
    .j=".j"
    .k=".k"
    .l=".l"
    .m=".m"
    .n=".n"
    .o=".o"
    .p=".p"
    .q=".q"
    .r=".r"
    .s=".s"
    .t=".t"
    .u=".u"
    .v=".v"
    .w=".w"
    .x=".x"
    .y=".y"
    .z=".z"
 ;;;
run;
%end;  %** end of if &s_ver.>=80 do loop **;


%let tempfiles= &tempfiles. _&tfns._ascii.sas _&tfns._.raw;
%** Write a SAS program to output the data to an ascii file. **;
data _null_;
 set _conten end=lastobs;
 %** Write to a SAS program to be inserted in this program later. **;
 file "&temp_dir._&tfns._ascii.sas";  
  retain lvar ivar 0;
 if _n_=1 then do;
  %*** this fileref is used after success to delete this raw file **;
  put "filename ________ ""&temp_dir._&tfns._.raw""; ";  %** write out to an ascii file **;
  put "data _null_; ";
  put " set work.&dset. end=___lo___; ";
  put "  file ________ ls=2000; ";  %** write out to an ascii file **;
 end;
  lvar=lvar+1;
  ivar=ivar+1;

   %* only here if NOT (&dy_and_dq_fail.=1 and &quotes.=0) **;  
   %if &dq_fail.=1 %then %do;
     %** check for double quotes in only the character variables that need fixing **;
     %** tranwrd makes the list of space separated char vars like: in("cvar1","cvar2")**;
    if type=2 and _name_ in(%sysfunc(tranwrd("&dq_fix.",%nrstr( ),","))) 
       then put " if index(" _name_ ",compress(' "" ')) then ";
     %if &dy_and_dq_fail.=0 and &u_ver.>=70 %then %do;
       %** Make Maria happy. **;
       %**   and replace with &dyc. character which is a very unlikely character **;
      if type=2 then put  _name_ "=translate(" _name_ ",compress("" &dyc. ""),compress(' "" '));" ;
     %end;
     %else %if &quotes.=1 %then %do;
       %**   and replace with single quotes **;
      if type=2 then put  _name_ "=translate(" _name_ ",compress("" ' ""),compress(' "" '));" ;
     %end;
   %end; %** if dq_fail=1 then do loop **;

    %if &s_ver.<80 %then %do;   %** make all special missings equal to missing since pre-Stata 8 cannot handle them **;
       if type=1 then put " if .< " _name_ "<=.z then " _name_ "=. ; ";
    %end;   %** if s_ver<80 or sm=0 then do loop  **;

    %if &s_ver.>=80 and &sm.=1 %then %do;   %** make invalid special missings equal to missing **;
     %** Stata can only handle special missing between .a and .z, **;
      %*  SAS also has " ._ " ***;
     if type=1 then put " if " _name_ "<.a then " _name_ "=. ; ";
    %end;   %** if s_ver>=80 and sm=1 then do loop  **;

  if (lvar < 5 and ivar < &avars.) then do;
   %** put the variable with the output format and put a space after each variable **;
  %if &s_ver.>=80 and &sm.=1 %then %do;   %** keep special missings special **;
   if type=1 then put ' if .a<= ' _name_ '<=.z then put ' _name_ ' ___mi___. " " @;';
  %end;   
   if type=1 then put ' if ' _name_ '<.a or ' _name_ '>.z then put ' _name_  oformat ' " " @;';
  /** would work if Stata could infile compound quotes:
       if type=2 then put ' put " `""" ' _name_ oformat ' """''  " " "  @  ; ';
   ******/
   if type=2 then put ' put " """ ' _name_ oformat ' """  " " "  @  ; ';
  end; %** of if (lvar < 5 and ivar < avars.) then do loop **;
  else do;
   %if &s_ver.>=80 and &sm.=1 %then %do;  %** keep special missings special **;
    if type=1 then put ' if .a<= ' _name_ '<=.z then put ' _name_ ' ___mi___. ;';
   %end;   
    if type=1 then put ' if ' _name_ '<.a or ' _name_ '>.z then put ' _name_  oformat ' ;';
    /** would work if Stata could infile compound quotes:
         if type=2 then put ' put " `""" ' _name_ oformat ' """''  "  ; ';
     **/
    if type=2 then put ' put "  """ ' _name_ oformat ' """   " ; ';
    lvar=0;
  end;  %** of if else (the 5th var) do loop **;
  put " ";
 if lastobs then do;
   put "run; ";
 end;
run;

%include "&temp_dir._&tfns._ascii.sas";
filename ________ clear;  %** clear filename ref used in _tfns_ascii.sas **;

%** initialize maxvar **;
%let maxvar =0;
%let reclen=%eval(&reclen.);
%if (&s_ver. < 80 or &s_SEver. = 0) %then %do;
 %if &avars. > 2047 %then %goto fail15;     %** &avars. is number of all variables **;
 %else %if (&s_ver. < 70) and &reclen. > 8192  %then %goto fail16;
 %else %if &reclen. > 24564 %then %goto fail16;
 %end;
%else %do;  %** saving SE **;
  %** The maximum width of a dataset in Stata SE is 12*maxvar. **;
  %** The maximum number of variables for Stata SE is 32,767.  **;
  %** The maximum number of variables savastata can handle varies based on type of variables **;
  %if &avars. > 32767 %then %goto fail24;   %** Starting with SAS 9, SAS now allows more than 32,767 vars **;
  %let maxreclen = %eval(&avars. * 12 );  
  %** The real max width for Stata is 393204 (=32767 * 12) not 393192 (= 32766 * 12) **;
  %if &maxreclen. > 393204 %then %goto fail16;
  %if &reclen. > 393204  %then %goto fail16;
  %if &avars. < 32756 %then %do;
     %** allow for more vars (10 percent of the difference of total amount of vars you can have) **; 
    %let maxvar = %eval(&avars. + %sysfunc(int((32766-&avars.) / 10)));  
  %end;
  %else %if &avars. >= 32756 %then %do;
    %let maxvar = %eval(&avars. + 1);  
  %end;
  %if &avars.>32767 %then %goto fail24;   %** This should not happen, but check it again **;
  %if &maxvar.<=5000 %then %let maxvar=5000;
  %** maxvar should really be set to the width of the dataset divided by 12 *;
  %*  but Stata seems to need a bit more room so 11.7 does that **;
  %if %sysfunc(int(%sysevalf(&reclen. / 11.7 ))) > &maxvar. %then %do;  
    %let maxvar = %sysfunc(int(%sysevalf(&reclen. / 11.7 )));  
  %end;
  %if %sysfunc(int(%sysevalf(&reclen. / 11.7 ))) > 32767  %then %do; %** try making maxvar a bit smaller **; 
    %let maxvar = %sysfunc(int(%sysevalf(&reclen. / 11.8 )));  
  %end;
  %if &maxvar.>32767 %then %goto fail16;   %** This really means the dataset is too wide. **;
%end;


%let flavor= ; %** Initialize macro var **;


%* intrcool now only used for the Stata intercooled saving option which stopped being an option with Stata 10 **;
%if &u_ver. >= 100 %then %let intrcool= ; %** make sure it is blank if Stata 10 or higher **;

** see if value labels exist: **;
%let fmt_order= %sysfunc(getoption(fmtsearch));
%let fmt_order= %qsysfunc(translate(&fmt_order.," ","("," ",")"));
%let n_fmts= %sysfunc(countw(&fmt_order.));
%let flibr= %scan(&fmt_order.,1,%str( ));
%let wrk= 0;
%let lib= 0;
%let i= 1;
%do %while( &flibr. ne  );

  %let flibr= %scan(&fmt_order.,&i.,%str( ));
  %if %upcase(&flibr.) = WORK or %upcase(&flibr.) = WORK.FORMATS and %sysfunc(cexist(WORK.FORMATS)) %then %do;
    %if &lib. = 0 %then %let wrk= 1;
    %else %if &lib. = 1 %then %let wrk= 2;
  %end;
  %else %if %upcase(&flibr.) = LIBRARY or %upcase(&flibr.) = LIBRARY.FORMATS and %sysfunc(cexist(LIBRARY.FORMATS)) %then %do;
    %if &wrk. = 0 %then %let lib= 1;
    %else %if &wrk. = 1 %then %let lib= 2;
  %end;

  %let i= %eval(&i. + 1);
%end;

** work always wins unless it is in &fmt_order. *;
** library wins if work is in &fmt_order. and library is not in &fmt_order.  *;
%if &wrk. = 0 and &lib. = 0 %then %do;
  options fmtsearch= ( work.formats library.formats &fmt_order. );
%end;
%if &wrk. = 0 and &lib. = 1 %then %do;
  options fmtsearch= ( work.formats &fmt_order. );
%end;
%if &wrk. = 1 and &lib. = 0 %then %do;
  options fmtsearch= ( library.formats &fmt_order. );
%end;

%let fmt_order= %sysfunc(getoption(fmtsearch));
%let fmt_order= %qsysfunc(translate(&fmt_order.," ","("," ",")"));

** _conten3 is only a formats datasets **;
data _conten3;
run;

** the above data step creates 1 obs so reset to 0 obs **;
data _conten3;
 set _conten3 (obs= 0);
run;

%let c_len=;
%let label_lens= 10;
%let fmlabel_len= 10;
%let flibr= %scan(&fmt_order.,1,%str( ));
%let i= 1;
%do %while( &flibr. ne  );

  %let flibr= %scan(&fmt_order.,&i.,%str( ));
  %if &flibr. ne %then %do;
    %if %index(&flibr.,.) = 0 %then %let flibr= &flibr..FORMATS;
    %if %sysfunc(cexist(&flibr.)) %then %do;
      proc format library= &flibr. cntlout= _conten1(keep= type fmtname start end label);
      run;

      proc sort data= _conten1(rename= (fmtname=format label=fmtlabel));
        by format start;
       %* sm is a test earlier on if special missings are in the dataset: *;
       %if &sm. = 0 %then %do;
                %** Stata can only handle formats of integers. **; 
        where not index(start,".") and not index(end,".") 
                %** Stata can not handle formats of **OTHER**. **; 
              and upcase(start) ^= '**OTHER**' 
              and upcase(start) not in('LOW','HIGH') 
              and upcase(end) not in('LOW','HIGH') 
              %*********************************************************;
              %**  formats with ranges using LOW, HIGH and OTHER      **;
              %**   could apply to multiple variables                 **;
              %*********************************************************;
                %** Stata can only handle formats of numeric vars. **;
              and upcase(type) = "N";   
      run;  ** proc sort run statement;
       %end;  %** if sm = 0 then do loop **;
      
       %else %if &sm. = 1 %then %do;
         where upcase(type) = "N";       %** Stata can only handle formats of numeric vars. **; 
      run;  ** proc sort run statement  **;

        data _conten1;
         set _conten1;
         fine= 0;                                                  
          %** If both start and end are special missing that is okay, ranges now okay. **;
         if  (upcase(compress(start)) >= ".A" and upcase(compress(start)) <= ".Z")
          and (upcase(compress(end)) >= ".A" and upcase(compress(end)) <= ".Z") then do;
           start= lowcase(start);
           end= lowcase(end);
           fine= 1;
         end;
         else %** Stata can only handle formats of integers. **; 
              if not index(start,".") and not index(end,".") 
              and upcase(start) ^= '**OTHER**' 
              and upcase(start) not in('LOW','HIGH') 
              and upcase(end) not in('LOW','HIGH') 
              %*********************************************************;
              %**  formats with ranges using LOW, HIGH and OTHER      **;
              %**   could apply to multiple variables                 **;
              %*********************************************************;
              then fine= 1;
         if fine= 1;
        run;
       %end;  %** if sm = 1 then do loop **;
    
      data _null_;
       set _conten1 (obs= 1); 
        %** this is still the label length when also character labels existed which is fine:  **;
       if _n_ = 1 then call symputx("c_len",put(vlength(fmtlabel),best32.));
      run;

      %if &c_len. ne  %then %do;
        %let label_lens= &label_lens., &c_len.;
        %let fmlabel_len= %sysfunc(max( &label_lens. ));
      %end;

      %** need to exclude formats from appending dataset if they already exist in _conten3 *;
      data _null_;
       dsid= open("_conten3","i");
       cnobs3= attrn(dsid,"nobs");
       call symput("cnobs3",compress(cnobs3));
      run;
      
      %if &cnobs3. > 0 %then %do; 
        proc sql noprint;
          select distinct format 
           into :formats separated by "' , '" 
            from work._conten3;
        quit;
      %end; 

      %if &formats. ne  %then %do;
        data _null_;
          length formats $32767;
          formats= trim(upcase("&formats.")); 
          if substr(formats,1,1) ^= "'" then formats= trim("'" ||  trim(formats) );
          if substr(formats,length(formats),1) ^= "'" then formats= trim( trim(formats) || "'" );
          call symput('formats', trim(formats) );
        run;
      %end;

      data _conten1;
       set _conten1;
        %if &cnobs3. > 0 %then %do; 
          where upcase(format) not in( &formats. );  ** formats has already been made uppercase **;
        %end;
      run;

      %** this happens when there are no formats in the dataset: **;
      %if &fmlabel_len. =  %then %do;
        %let fmlabel_len= 10;
      %end;
      data _conten3;
       length fmtlabel $&fmlabel_len.;
       set _conten3
           _conten1;
      run;

    %end;
  %end;
  
  %let i= %eval(&i. + 1);

%end;

data _null_;
  dsid= open("_conten3","i");
  cnobs3= attrn(dsid,"nobs");
  call symput("cnobs3",compress(cnobs3));
run;

%if &cnobs3. ne 0 %then %do;
  %let vlabels= 1;
%end;

%let tempfiles= &tempfiles. _&tfns._infile.do _&tfns._infile.log _&tfns._labels.do _&tfns._fix.do _&tfns._formats.do;
%if &vlabels. = 1 %then %do;
  %let tempfiles= &tempfiles. _&tfns._dlabels.do _&tfns._vlabels.do;
%end;
%let tempfiles= &tempfiles. _&tfns._done.log;

%** Write do-file to read in data. **;
data _null_;
 set _conten end=lastobs;
 %** Write to a Stata do-file. **;
 file "&temp_dir._&tfns._infile.do"  ls=2000;  %* ls=256 is default *;
 if _n_=1 then do; 
  /****************************************************************
   # Figure out memory requirements. 
   # Use a slightly modified version of the formula Stata suggests to figure
   #  out how much memory is needed.
   #  STATA_s formula:         N*V*W + 4*N
   #                    M  =  --------------
   #                           1024 * 1024
   #        N  =  number observations
   #        V  =  number of variables
   #        W  =  average width in bytes of a variable
   #        M  =  number of megabytes   
   # savastata_s formula:
   ****************************************************************/
   %** record length is number of variables times average variable width **;
    statamem= &nobs.*(&reclen. + (&reclen./4)) + (4*&nobs.) ;  %** "+ (&reclen./4)" adds about 25 percent for good measure **;
  %if &u_ver.>=80 %then %do;
    put " if `c(memory)' < " statamem  " { ";  %** c(memory) is in bytes and statamem is also at this point **;
  %end;
   %**  Convert STATAMEM bytes to megabytes  **;
    statamem=int(statamem / 1024**2);
   %** Make sure memory is set to at least 20 megabytes **;
    if (statamem< 20) then statamem=20;
  mem=compress(statamem||"m");
  put " set memory " mem;
  %if &u_ver.>=80 %then %do;
    put " } ";  %** end of if memory setting is less than needed **;
  %end;
  %if &maxvar.>5000 %then %do;  %** but only reset if not high enough (for -usesas- or user_s default setting) **;
    put " if `c(max_k_current)' < &maxvar.   set maxvar &maxvar. ";
  %end;
  put " #delimit ; "; 
  put " infile  "; 
 end; %** end of if _n_=1 do loop **;
 put '    ' stype name ;
 if lastobs then do;
  put " using   ""&temp_dir._&tfns._.raw"" ";
  put ';;;';
  put ' ';
  put ' #delimit cr ';
  %** replace dyc char with double quote only in char vars that need fixing **;
  %if &dq_fail. = 1 and &dy_and_dq_fail. = 0 and &u_ver. >= 70 %then %do; 
   put "foreach svar of varlist &dq_fix. { ";
   put "  replace `svar' = subinstr(`svar',""&dyc."",`""""""',.) ";
   put '} ';
  %end;
  put " do ""&temp_dir._&tfns._labels.do""";  %** This will call the next do-file. **;
  put " do ""&temp_dir._&tfns._fix.do""";     %** This will call the next do-file. **;
  put " do ""&temp_dir._&tfns._formats.do"""; %** This will call the next do-file. **;
  %if &vlabels. = 1 %then %do;
   put " do ""&temp_dir._&tfns._dlabels.do"""; %** This will call the next do-file. **;
   put " do ""&temp_dir._&tfns._vlabels.do"""; %** This will call the next do-file. **;
  %end;

  put "  ";
  %if "&sysscp." = "WIN" %then %do;
    put "  global S_FN ""\&fdset..dta"" ";
  %end;
  %else %do;
    put "  global S_FN ""/&fdset..dta"" ";
  %end;
  put "  label data ""&crdate."" ";

 %******* save Stata dataset *********************************;
 %*----------------------------------------------------------*; 
 %if "&script." ^= "usesas" %then %do;
  put 'if _caller()<8 { ';
  put ' quietly describe ';
  put ' local obs=`r(N)'' ';
  put ' local vars=`r(k)'' ';
  put " } ";
  put " else { ";
  put '  local obs=`c(N)'' ';
  put '  local vars=`c(k)'' ';
  put " } ";

  put " if `obs' == &nobs. & `vars' == &AVARS.  { ";  %** only save if successful **; 
       %** not saving will still allow checking data **;
   %** add another back slash to directories that start with a back slash, as Stata **;
    %*  drops the first back slash because it sees it as an escape character. **;
  %if %index(%nrbquote(&out_dir.),\)=1 %then %do;
   if &u_ver.<80  then put " save ""\&out_dir.&fdset..dta"", &old. &intrcool. &replace. "; 
   else if &u_ver.>=80 then put " save&old. ""\&out_dir.&fdset..dta"", &intrcool. &replace. "; 
  %end;
  %else %do;
   if &u_ver.<80  then put " save ""&out_dir.&fdset..dta"", &old. &intrcool. &replace. "; 
   else if &u_ver.>=80 then put " save&old. ""&out_dir.&fdset..dta"", &intrcool. &replace. "; 
  %end;
  put " } " ;  %** end of if obs and vars match SAS dataset **;
  %if &ascii.=0 and &u_ver.>=70 %then %do; 
   put " set linesize 100 "; %** -usesas- should not reset linesize **; 
  %end;
 %end;  %** of script ^= "usesas" do loop **;
 %*** end save Stata dataset *********************************;
 %*----------------------------------------------------------*; 

 %if "&script." = "usesas" %then %do;
  put "capture program drop savastata_report    ";
  put "program savastata_report    ";
  put " if `c(N)' != &nobs | `c(k)' != &AVARS.  { ";
  put "   noisily { ";
  put "     di _n ""{txt}SAS reports that the input dataset has {res}&nobs. {txt}observations "" /* "; /*"*/
  put "         */ ""and {res}&AVARS. {txt}variables "" ";
  put '     di "{txt}but Stata reports that the dataset has {res}`c(N)'' {txt}observations " /* ';
  put '         */ "and {res}`c(k)'' {txt}variables " ';
  put '     di as err "{help usesas:usesas} was unable to read in your SAS data correctly." ';
  put '     di as err "Does your data contain non-roman characters?" ';
  put '     di as err "SAVASTATA writes the data to ascii and non-roman characters mess that up." ';
  put '     di as err "If you want to check out the intermediary files generated " ';
  put '     di as err "by -usesas- in order to check out why -usesas- failed, " ';
  put '     di as err "try -usesas- again using the {text}messy {error}option. " ';
  put "   } ";
  put "   drop _all  // clear data from memory  ";
  put " } ";
  put ' else noi di _n "{txt}Stata reports that the dataset has {res}`c(N)'' {txt}observations " /* ';
  put '         */ "and {res}`c(k)'' {txt}variables. " ';
  put "end";
 %end;  %** of script = "usesas" do loop **;

 %if &ascii.=0 %then %do;  %** -usesas- runs checks the Stata data inside the usesas.ado file **;
  %if "&script." ^= "usesas" %then %do;  %** -usesas- already knows if it loaded data correctly or not **;
   put "  capture program drop __save__ ";
   put "  program define __save__, nclass ";
   put " args obs vars ";
   put " capture log close ";
   %if &check.=1 %then %do;
    %** If a directory starts with a back slash, Stata likes to remove it. **;
    %if %index(%nrbquote(&out_dir.),\)=1 %then %do;
      put "&quietly. log using ""\&out_dir.&fdset._STATAcheck.log"", replace ";
    %end;
    %else %do;
     put "&quietly. log using ""&out_dir.&fdset._STATAcheck.log"", replace ";
    %end;
    put " &noisily. display "" "" ";
    put " &noisily. display as res ""** Compare these results with the results provided by SAS **"" ";
    put " &noisily. display ""**  in the file &out_dir.&fdset._SAScheck.lst.             **"" ";
    put " &noisily. display "" "" ";
    put " &noisily. summarize ";
    put " &noisily. describe ";
    put " &noisily. list in 1/5";
    put " capture log close ";
   %end; %** of if check=1 do loop **;
   put " ** If this file exists then Stata successfully saved &fdset..dta  ** ";
   put " quietly log using ""&temp_dir._&tfns._done.log"" ";
   put " ** If this file exists then Stata successfully saved &fdset..dta  ** ";
   put ' display "%macro _______v;" ';
   put ' display " %let SE=$S_StataSE ; " ';
   put ' display " %let MP=$S_StataMP ; " ';
   put ' display " %if &MP.=MP %then %let SE=SE ; " '; 
   put ' display " %let flavor=$S_FLAVOR; " ';
   put ' display " %let version=%sysfunc(int(" _caller() ")); " '; 
   put ' display " %if &SE.=SE and &s_SEver=0 %then %let flavor=Intercooled; " '; 
   put ' display " %if &SE.=SE and &s_SEver.=1 and &s_ver.>=70 %then %let flavor=SE; " ';
   %********* Stata version 9 is only version that saved to 2 versions previous  **;
   put ' display " %if &old.=old and &version.=9 %then %let version=%eval(&version.-2);" ';   
   put ' display " %else %if &old.=old %then %let version=%eval(&version.-1);" ';   
   put ' display " options notes; " ';
   put " if `obs' != &nobs. | `vars' != &AVARS.  { ";   %** failed possibly due to non-roman characters **;
   put '  di "%put %upcase(error): SAVASTATA was unable to save your SAS data correctly. *;" ';
   put '  di "%put Does your data contain non-roman characters?  *;" ';
   put "  di ""%nrstr(%put) SAS reports that the input dataset has &nobs. observations and &AVARS. variables. *; "" ";
   put '  di "%put but Stata reports that the dataset has `obs'' observations and `vars'' variables. *; " ';
   put '  di "%let fail23=1;" ';
   put ' } ';
   put ' else { '; %** success! **;
   put '  di "%put NOTE: SAVASTATA has successfully saved the               *; " '; 
   put '  di "%put Stata &version. &flavor data file &out_dir.&fdset..dta.    *; "  ';
   put '  di "%put Stata reports that the dataset has `obs'' observations and `vars'' variables. *; " ';
   put '  if c(SE) == 1 & c(maxvar) > 5000 {  ';
   put '    di "%put You need to set maxvar to " c(maxvar) " or higher to load this dataset into Stata *; " '; 
   put '  } ';
   put ' } ';
   put ' if _caller() >= 8 { ';  %** usagelog only works in version 8+ **;
   put "  capture which usagelog";
   put "  if _rc==0 {";
   put "    usagelog , type(savas) message(Output Stata dataset has `obs' obs and `vars' vars)";
   put "  }";
   put " }";
 
 
   %if &check.=1 %then %do;
    put ' di "%put *; " ';
    put ' di "%put You have requested to have SAVASTATA provide 2 check files: *; " ';
    put ' di "%put ""&out_dir.&fdset._SAScheck.lst"" and *; " ';
    put ' di "%put ""&out_dir.&fdset._STATAcheck.log""  *; " ';
    put ' di "%put *; " ';
   %end; %** if check=1 then do loop **;
   put ' display " %mend _______v; " ';
   put ' display " %_______v; " ';
   put "quietly capture log close";
   put "end "; %** end of defining program __save__ **;
   put "&noisily. __save__ `obs' `vars'";
  %end;  %** of script ^= "usesas" do loop **;
 %end; %** of if &ascii.=0 do loop **;
 end; %** if last_obs do loop **;
run;

%** Write the Stata label do-file  ***;
data _null_;
 set _conten;
 %** start a new Stata do-file **;
 file "&temp_dir._&tfns._labels.do";  %* this is just max 32 char varname and 32 char label name *;
 if _n_=1 then do;
  put " ** This do-file assigns variable labels ** ";
 end;
 if label^="" then put ' label var ' name ' `"' label '"'' ';
 %if %length(%qcmpres(%nrbquote(&llabvars.))) > 0 %then %do;
   if lowcase(name) in(&llabvars.) then 
     put ' notes ' name ': ' llabel ;  %** enclosing in compound double quotes does not help **;
 %end;
run;
 
 
%** Write the Stata fix do-file.  ***;
data _null_;
 set _conten end=lastobs;
 file "&temp_dir._&tfns._fix.do";  %** start a new Stata do-file **;
 if _n_=1 then do;
  %** If a directory starts with a back slash, Stata likes to remove it. **;
  put " ** This do-file replaces empty strings with null values. ** ";
 end;
  if type=2 then put ' replace ' name '="" if  ltrim(' name ')=="" ';
run;

%** SAS defined format do-file  ***;
data _null_;
 set _conten end=lastobs;
 %** start a new Stata do-file **;
 file "&temp_dir._&tfns._formats.do"; %* This is just 32 max varname and 32 max format name *;
 if _n_=1 then do;
  put " ** This do-file assigns variables formats. ** ";
 end;
 if format^="default" then put ' format ' name format;
 if lastobs then do;
  put ' ';
 end;
run; 


%if &vlabels. = 1 %then %do;

  %** rename _conten3 to _conten1 **;
  proc datasets library= work nodetails nolist nowarn;
    delete _conten1 / memtype= data;
   run;
    change _conten3= _conten1 / memtype= data;
   run; 
  quit;
  
  proc sort data= _conten1;
    by format;
  run;
  
  proc sort data= _conten(keep= type varnum format name orig_fmt 
                           where= (format = "default")) 
             out= _conten(drop= format rename= (orig_fmt=format));
   by orig_fmt;
  run;
  
  data _conten3;
   merge _conten(in= a keep= format)
         _conten1(in= b keep= format); 
   by format;
      %** Only keep the formats used in the dataset. **;
    if a and b;  
  run;
  
  data _conten3;
   set _conten3;
    by format;
      %** Reduce to one obs per format. **;
    if first.format;  
  run;
  
  data _conten1;
   merge _conten3(in= a keep= format)
         _conten1(in= b); 
   by format;
   if a and b;  %** Only keep the numeric formats used in the dataset. **;
  run;

  %** Make an attempt to save some of the other formats. **;
  %** first check to see if any will be truncated **;
  %let labtrunc= 0;
  data _null_;
   set _conten1;  %** _conten1 contains only numeric formats for numeric vars **;
    %** Stata can only handle value labels up to &maxvallablen. characters. **;
    if length(fmtlabel) > &maxvallablen. then call symput('labtrunc',"1");  
  run;
  
  %if &labtrunc. = 1 %then %do;  
   %put %upcase(warning): SAVASTATA truncated at least one format label because it contained more than &maxvallablen. characters.   *; 
  %end;
  
  data _null_;
     %** Increase length to allow for compound quotes to be attached later. **;
    length fmtlabel $%eval(&maxvallablen.+500); 
   set _conten1 (where= (fmtlabel ^= "")) end= lastobs ;  
   %** stata cannot handle empty value labels **;

   by format;
   file "&temp_dir._&tfns._dlabels.do" ls= 32200;  %** start a new Stata do-file **;
   if _n_ = 1 then do;
    put " ** This do-file defines value labels. ** ";
   end;
    %** nstart and nend have to be numeric. they are only used in ranges **;
   nstart= start * 1; 
   nend= end * 1; 
   %** format byte is okay but not as nice as the same as the var name BYTE **;
   if upcase(format) not in(&bstatavs.) then format= lowcase(format);
   %** make sure fmtlabel not longer than max **;
   fmtlabel= substr(fmtlabel,1,&maxvallablen.);  %** need to test length before escaping $ and \  **;
   %** prepare fmtlabel to be written to _dlabels.do **;

   %** value labels cannot end in a left quote even if it is escaped **;
   if length(fmtlabel) = 1 and 
       substr(fmtlabel,length(fmtlabel),length(fmtlabel)) = "`" then
     fmtlabel= "'";  %** replace with right quote **;
   else if substr(fmtlabel,length(fmtlabel),length(fmtlabel)) = "`" then
     fmtlabel= substr(fmtlabel,1,length(fmtlabel)-1)||"'";  %** replace with right quote **;
   %** the above can create right compound quotes **;

   %** value labels cannot contain either a left or right compound quote **;
   if index(fmtlabel,compress("`"||' " ')) or
      index(fmtlabel,compress('"'||" ' ")) then do;
     call symput("cq","1");  %** Format contains a compound quote. **;
        %if &quotes. = 1 %then %do;
          fmtlabel= tranwrd(fmtlabel,"`"||'"',"''");  %* replace left compound quote with two single quotes *;
          fmtlabel= tranwrd(fmtlabel,'"'||"'","''");  %* replace right compound quote with two single quotes *;
        %end;
   end;

   %if &u_ver. < 90 or "&script." = "usesas" %then %do;
     %** replace two back slashes with four **;
     if index(fmtlabel,"\\") then fmtlabel= tranwrd(fmtlabel,"\\","\\\\");
   %end;

   %** escape all left quotes (already know they are not left compound quotes) **;
   if index(fmtlabel,"`") then fmtlabel= tranwrd(fmtlabel,"`","\`");
   %** escape all dollar signs **;
   if index(fmtlabel,"$") then fmtlabel= tranwrd(fmtlabel,"$","\$");
    /** replace \\` with \\' since stata hates \\` **/
   if index(fmtlabel,"\\`") then fmtlabel= tranwrd(fmtlabel,"\\`","\\'");
   %** the above cannot create a right compound quote **;
  
   %** One format can be assigned to many variables.  **;
   %** new way  of defining each value and adding if more than 1                **;
    %*  because long value labels can make Stata unable to find end quote.      **;
    %*  the added bonus is that a semicolon in a label will not throw off Stata **;
    %*****;
  
   %* add compound quotes at beginning and end of fmtlabel *;
   fmtlabel= " `"""|| trim(fmtlabel) ||"""' " ; 

   %** value labels are stored as datatype long. **;
   if .z < nstart < &longmin. then nstart= &longmin. ;  
   if nend > &longmax. then do;
     nend= &longmax.;
   end;
   
   if start = end then do;  
     %** start and end could equal "**OTHER**" and will only be assigned to **;
      %*  the first "other" value.  Not able to replicate OTHER in Stata.   **;
     if first.format then do;
       j= 1; %** for counting inside ranges. one format can only have 65,536 values **;
       put " label define " format  start  fmtlabel ;   
     end;
     else do;
       j= j + 1;
       if j <= 65536 then 
         put " label define " format  start  fmtlabel " , add  " ;   
     end;
   end;
   else if ( nstart > .z and nend > .z ) then do i= nstart to nend;
     if first.format and i = nstart then do;    
       j= 1; %** for counting inside ranges. one format can only have 65,536 values **;
       put " label define " format  i fmtlabel ;   
     end;
     else do;                              
       j= j + 1;
       if j <= 65536 then 
         put " label define " format  i fmtlabel " , add  " ;   
     end;
   end;
   else if  (compress(start) >= ".a" and compress(start) <= ".z")
        and (compress(end)> = ".a" and compress(end) <= ".z") then do;
      cstart= substr(lowcase(compress(start)),2,1);
         %** Stata does not allow special missing ._ **;
      nstart= index("abcdefghijklmnopqrstuvwxyz",compress(cstart));
      cend= substr(lowcase(compress(end)),2,1);
      nend=   index("abcdefghijklmnopqrstuvwxyz",compress(cend));
      do i= nstart to nend;
        _sm_= compress("." || substr("abcdefghijklmnopqrstuvwxyz",i,1));
        if first.format and i = nstart then do;    
          j= 1; %** for counting inside ranges. one format can only have 65,536 values **;
          put " label define " format  _sm_ fmtlabel ;   
        end;
        else do;                              
          j= j + 1;
          if j <= 65536 then 
            put " label define " format  _sm_ fmtlabel " , add  " ;   
        end;
      end;
   end;
  run;
  
  %if &cq. = 1 and &quotes. = 0 %then %goto fail17;  %** at least one format contains a compound quote. **;
  
  data _conten;
   merge _conten(in= a keep= type varnum name format)
         _conten3(in= b keep= format);
   by format;
   if a and b;  %** Keep only the variables assigned to these formats. **;
  run;
  
  data _null_;
   set _conten (where= (type = 1)) end= lastobs;  %** can only format numeric variables **;
   %** start a new Stata do-file **;
   file "&temp_dir._&tfns._vlabels.do";  %** this is just a max 32 char varname and *;
                                          %*  32 char user-defined label name *;
   if _n_ = 1 then do;
     put " ** This do-file assigns value labels. ** ";
   end;
   if upcase(format) not in(&bstatavs.) then format= lowcase(format);
      put 'label value ' name format;
  run;
  
%end; %** end of if vlabels = 1 then do loop **;

  

%if "&script." ^= "usesas" %then %do;
 %let u_sysrc= 0;  %** initialize macro var **;
 %let w_sysrc= 0;  %** initialize macro var **;
 %if &ascii. = 0 %then %do;
  %if &unix. = 1 %then %do;
   %** This submits the Stata do-file that reads in the ascii dataset that becomes the Stata dataset. ***;
   %** sysexec requires no quotes even when changing to dirs with spaces in windows or unix **;
    %sysexec cd %nrbquote(&work_dir.) ;   %** change to the drive and directory where the Stata do-files are. **;

    %** Run Stata in batch. from within the directory where the temp files are. **;
    %if &nocd. = cd %then %do;
      %sysexec %nrbquote(&ustata.) -b do "&temp_dir._&tfns._infile.do";
    %end;
    %else %do;
      %sysexec %nrbquote(&ustata.) -b do "_&tfns._infile.do";
    %end;
    %let u_sysrc= &sysrc.;  %** store value of sysrc until after if ascii=0 do loop **;
    %if &nocd. = cd and &messy. = 0 %then %do;    
      %if %sysfunc(fileexist("_&tfns._version.log")) %then %do;
         %sysexec rm _&tfns._version.log ;
      %end;
      %if %sysfunc(fileexist("_&tfns._infile.log")) %then %do;
         %sysexec rm _&tfns._infile.log ;
      %end;
    %end;
  %end; %** if unix = 1 then do loop **;

  %if &unix. = 0 %then %do;
   %sysexec &drive.;
   %** sysexec requires no quotes even when changing to dirs with spaces in windows or unix **;
   %sysexec cd %nrbquote(&work_dir.) ;
      %** Run Stata in batch. **;
   %sysexec "&wstata." /e do "&temp_dir._&tfns._infile.do";  
   %let w_sysrc=&sysrc.;  %** store value of sysrc until after if ascii=0 do loop **;
  %end;  %** if unix=0 then do loop **;
 %end; %** if ascii=0 then do loop. Do not run Stata if only want ascii dataset **;
 %if &u_sysrc. ^= 0 %then %goto fail21;
 %if &w_sysrc. ^= 0 %then %do;
   %if &u_ver. < 80 and &w_sysrc. = 17 %then  %let w_sysrc= 0;
   %else %if &u_ver. < 90 and &w_sysrc. = 2180 %then  %let w_sysrc= 0;
   %if &w_sysrc. ^= 0 %then %goto fail20; 
 %end;
%end;  %** of script ^= "usesas" do loop **;

%let fail23=0;
%if (&isysver. < 7 and &ascii. = 0) or (&ascii. = 0 and %sysfunc(fileexist("&temp_dir._&tfns._done.log"))) %then %do; 
 %include"&temp_dir._&tfns._done.log";  %** Run report program written by Stata. **;
 %if &fail23. = 1 %then %goto fail23;
 %let success= 1;
%end;
%if &ascii. = 1 and %sysfunc(fileexist("&out_dir._&tfns._.raw")) %then %do; 
 %let success= 1;
%end;

%if &success. = 0 and "&nosave." = "" %then %goto fail19;



 %*********  delete intermediary files when successful *********************;
 %if &success. = 1 and &ascii. = 0 and &messy. = 0 and "&script." = ""  %then %do;
    options nonotes;
    %sysexec cd &temp_dir.;
    %let i= 1;
    %let j= 1;
    %** make sure tempfiles ends with a space: **;
    %let tempfiles= &tempfiles. ;
    %do %while (&j. = 1); 
       %let name= %qscan(&tempfiles.,&i.,%str( ));
       %let name= %qtrim(&name.);
       %if &name. = %str( ) or &name. =  %then %goto deldone;
       filename ________ "&name."; 
       data _null_;
         fname= "________";
         if fexist(fname) then rc= fdelete(fname);
       run;
       %deldone: ;
       %let i= %eval(&i + 1);
       %if &name =  %then %let j= 0;
    %end;
    %sysexec cd &pwdir.;
    filename ________ clear;
    options notes;
 %end; %** if success = 1 and ascii = 0 and messy = 0 do loop **;
 %********* (end of) delete intermediary files when successful **************;

%goto okay;


 %** The following are all the failure messages returned to the user when the macro **;
  %*  is unable to process the input SAS dataset.                                   **;
%fail1: 
        %put  * ;  
        %put %upcase(error): SAVASTATA did not save your dataset.                     *  ;
        %if "%sysfunc(lowcase(&dset.))"="_null_" %then %do;
          %put You do not have a SAS dataset in the WORK library for          *  ;
          %put  SAVASTATA to convert to Stata.                                *  ;
        %end;
        %else 
          %put The input dataset &dset. has to be in the WORK library.         *  ;
        %put For more help check here: &http.   * ;
         %** SAS 8 will put a note at the end of the log stating what page errors           **;
          %* occurred but earlier versions do not. So insert bad code to generate an error. **;
        %if &isysver.<8 %then 
              SAVASTATA did not save your dataset
        %put  *  ;
        %let fail=1;
%goto okay;

%fail2: %put  *  ; 
        %put %upcase(error): SAVASTATA did not save your dataset.                     *  ;
        %put You have set u_ver=&u_ver., s_ver=&s_ver., u_SEver=&u_SEver. and s_SEver=&s_SEver.            *  ;
        %put  which is invalid.  Perhaps edit savastata.sas to set all these vars to 0 (zero)?  *  ;
        %put For more help check here: &http.   * ;
        %if &isysver.<8 %then 
              SAVASTATA did not save your dataset
        %put  *  ;
        %let fail=2;
%goto okay;

%fail3: %put  *  ;
        %put %upcase(error): SAVASTATA did not save your dataset.                     *  ;
        %put The dataset cannot be named &fdset.                             *  ;
        %put SAVASTATA uses this dataset name.                               *  ;
        %put Consider renaming the dataset.                                  *  ;
        %put For more help check here: &http.   * ;
        %if &isysver.<8 %then 
              SAVASTATA did not save your dataset
        %put  *  ;
        %let fail=3;
%goto okay;

%fail4: %put  *  ;  
        %put %upcase(error): SAVASTATA did not save your dataset.                                      *  ;
        %put You did not tell SAVASTATA what directory you want to save the Stata dataset.    *  ;
        %put Your call to SAVASTATA should look something like this:                          *  ;
        %put %nrstr(%%)savastata(C:\mydata\,-replace)                                         *  ;
        %put For more help check here: &http.   * ;
        %if &isysver.<8 %then 
              SAVASTATA did not save your dataset
        %put  *  ;
        %let fail=4;
%goto okay;

%fail5: %put  *  ;  
        %put %upcase(error): SAVASTATA did not save your dataset.                      *  ;
        %put The directory %nrbquote(&out_dir.) does not exist.                 *  ;
        %put For more help check here: &http.   *  ;
        %if &isysver.<8 %then 
              SAVASTATA did not save your dataset
        %put  *  ;
        %let fail=5;
%goto okay;

%fail6: %put  *  ;
        %put %upcase(error): SAVASTATA did not save your dataset.                      *  ;
        %put You can only choose to save one type of dataset.                 *  ;
        %put For more help check here: &http.   * ;
        %if &isysver.<8 %then 
              SAVASTATA did not save your dataset
        %put   *  ;
        %let fail=6;
%goto okay;

%fail7: %put  *  ;  
        %put %upcase(error): SAVASTATA did not save your dataset.                                      *  ;
        %put The dataset %nrbquote(&out_dir.)&fdset..dta already exists.                     *  ;
        %put If you want to overwrite this file, then use the SAVASTATA option "-replace".    *  ;
        %put Like:  %nrstr(%%)savastata(%nrbquote(&out_dir.),-replace &options.)%nrstr(;)     ;
        %put For more help check here: &http.   * ;
        %if &isysver.<8 %then 
              SAVASTATA did not save your dataset
        %put  *  ;
        %let fail=7;
%goto okay;

%fail8: %put   *  ;
        %put %upcase(error): SAVASTATA did not save your dataset.                             *  ;
        %put Your dataset &dset. contains a variable named _N which is not a valid    *  ;
        %put variable name in Stata.  Consider renaming it to a valid Stata          *  ;
        %put variable name or dropping the variable from the SAS dataset.            *  ; 
        %put For more help check here: &http.   * ;
        %if &isysver.<8 %then 
              SAVASTATA did not save your dataset
        %put ;
        %let fail=8;
%goto okay;

%fail9: %put   *  ;
        %put %upcase(error): SAVASTATA did not save your dataset.                             *  ;
        %put The input dataset &dset. cannot contain a variable named &bvar.    *  ;
        %put because SAVASTATA uses this name.                                       *  ;
        %put Either rename the variable or drop it.                                  *  ;
        %put For more help check here: &http.   * ;
        %if &isysver.<8 %then
              SAVASTATA did not save your dataset
        %put  *  ;
        %let fail=9;
%goto okay;

%fail10: %put  *  ;
        %put %upcase(error): SAVASTATA did not save your dataset.                               *  ;
         %put At least one variable label in input dataset &dset. contains a compound quote ( %nrquote(%str(`%") or %str(%")%nrstr(%')) ).    *  ;  /*'*/
        %put This is not allowed by SAVASTATA.                                           *  ; 
        %put Consider replacing any compound quotes with two single quotes ( %nrquote(%str(%'%')) ) using    *  ;
        %put the "quotes" option.                                             *  ;
        %if "&script." = "" %then %do;
          %put Like:  %nrstr(%%)savastata(%nrbquote(&out_dir.),-quotes &options.)%nrstr(;)  ;
        %end;
        %put For more help check here: &http.   * ;
        %if &isysver.<8 %then 
              SAVASTATA did not save your dataset
        %put   *  ;
        %let fail=10;
%goto okay;


%fail11: %put   *  ;
        %put %upcase(error): SAVASTATA did not save your dataset.                                       *  ;
        %put SAVASTATA tried to rename the variable names that are 9 or more characters        *  ;
        %put to valid Stata 6 variable names (8 or less characters).  SAVASTATA was            *  ;
        %put unable to come up with unique variables names.                                    *  ;
        %put Rename the long variable names to 8 characters or less and try SAVASTATA again.   *  ;
        %put For more help check here: &http.   * ;
        %if &isysver.<8 %then 
              SAVASTATA did not save your dataset
        %put   *   ;
        %let fail=11;
%goto okay;

%fail12: %put  *  ;
        %put %upcase(error): SAVASTATA did not save your dataset.                           *  ;
        %put The input dataset &dset. has no variables.                             *  ;
        %put For more help check here: &http.   * ;
        %if &isysver.<8 %then 
              SAVASTATA did not save your dataset
        %put   *  ;
        %let fail=12;
%goto okay;

%fail13: %put   *   ;
        %put %upcase(error): SAVASTATA did not save your dataset.                           *  ;
        %put The input dataset &dset. has no observations.               *  ;
        %put For more help check here: &http.   * ;
        %if &isysver.<8 %then 
              SAVASTATA did not save your dataset
        %put   *  ;
        %let fail=13;
%goto okay;

%fail14: %put  *  ;
        %put %upcase(error): SAVASTATA did not save your dataset.                                  *  ;
        %put At least one character variable in the input dataset &dset. contains a double quote ( %nrquote(%str(%")) ).     *  ; /*"*/
        %put This is not allowed by SAVASTATA.                                           *  ; 
        %put Consider replacing any double quotes with a single quote ( %nrquote(%str(%')) ) by using     *  ;  /*'*/
        %put the "quotes" option.                                             *  ;  
        %if "&script." = "" %then %do;
          %put Like:  %nrstr(%%)savastata(%nrbquote(&out_dir.),-quotes &options.)%nrstr(;)  ;
        %end;
        %put The following is a list of all character variables in your dataset that     *  ;
        %put contain double quotes:                                                      *  ; 
      data _conten1;
      set &dset. end=___lo___;
      keep _character_; %** keep only character variables **;
      array ___ch___ ( &VAR_C. ) _temporary_;
      array ___cv___( &VAR_C. ) _character_ ;  %** all character variables in dataset **;
      do _n_=1 to &VAR_C.;
         if index(___cv___[_n_],compress(' " ')) then
          ___ch___[_n_]=1;
         end;
      if ___lo___;
       do _n_=1 to &VAR_C.;
         ___cv___[_n_]=___ch___[_n_];
       end;
      run;
      proc transpose data =_conten1 out=_conten1;
       var _all_;
      run;
      data _null_;
       set _conten1;
        if compress(col1)="1";
      _name_=lowcase(_name_);
       put "     " _name_  "           *   "; 
      run;
        %put                                                                        *;
        %put For more help check here: &http.   * ;
        %if &isysver.<8 %then 
              SAVASTATA did not save your dataset
        %put   *  ;
        %let fail=14;
%goto okay;

%fail15: %put   *  ;
        %put %upcase(error): SAVASTATA did not save your dataset.                          *   ;
        %put Only Stata SE can handle more than 2,047 variables.                   *   ;
        %let avars=%sysfunc(putn(&avars.,comma32.));    
        %put You have &avars. variables in dataset &dset..                   *   ;
        %put For more help check here: &http.   * ;
        %if &isysver. < 8 %then 
              SAVASTATA did not save your dataset
        %put   *   ;
        %let fail=15;
%goto okay;

%fail16: %put   *  ;
        %put %upcase(error): SAVASTATA did not save your dataset.                                       *  ;
        %put The input dataset &dset. exceeds the width limit of the version of Stata you       *  ;
        %put are using or saving to.                                                           *  ;
        %if &float.=0 %then %do;
         %put Consider using the "float" option to save space.  The "float" option saves numeric  *  ;
         %put variables that contain decimal values as storage type float instead of the default  *  ;
         %put of double.  Storage type float is %nrquote(Stata%str(%'s)) default for numeric variables.  *  ;   /*'*/
        %end;
        %else %if &float. = 1 %then %do;
         %put Consider dropping some variables.                                                *  ;
        %end;
        %put For more help check here: &http.   * ;
        %if &isysver. < 8 %then 
              SAVASTATA did not save your dataset
        %put  *   ;
        %let fail=16;
%goto okay;

%fail17: %put  *   ;
       %put %upcase(error): SAVASTATA did not save your dataset.                                    *   ;
       %put At least one of the formats for a numeric variable contains a compound quote ( %nrquote(%str(`%") or %str(%")%nrstr(%')) ).    *   ;  /*'*/
       %put This is not allowed by SAVASTATA.                                              *   ; 
       %put Consider replacing any compound quotes with two single quotes ( %nrquote(%str(%'%')) ) using    *  ;
       %put the "quotes" option.                                                *   ;
       %if "&script." = "" %then %do;
        %put Like:  %nrstr(%%)savastata(%nrbquote(&out_dir.),-quotes &options.)%nrstr(;)  ;
       %end;
       %put For more help check here: &http.   * ;
       %if &isysver.<8 %then 
              SAVASTATA did not save your dataset
       %put   *  ;
       %let fail=17;
%goto okay;

%fail18: %put   *   ;
        %put %upcase(error): SAVASTATA did not save your dataset.                                     *  ;
        %put The work directory cannot start with a forward slash ( \ ) because              *  ;
        %put SAVASTATA needs to cd to it.                                                   *  ;
        %put Is it possible to reassign your work directory to a drive like C: or D: ?      *  ;  
        %put For more help check here: &http.   * ;
        %if &isysver.<8 %then 
              SAVASTATA did not save your dataset
        %put   *  ;
        %let fail=18;
%goto okay;

%fail19: %put  *   ;
       %put %upcase(error): SAVASTATA did not save your dataset.                                     *  ;
       %put Stata had an error when attempting to infile the data.   *  ;
       %* tfns = &sysjobid.&sysindex. when not run by -usesas- or savas **;
       %if "&script." ^= "" %then %do;
        %*if &messy. = 0 %then %do; %** messy is always equal 1 for usesas and savas **;
         %put Run &script. again using the "messy" option                                   *  ;
         %put and then check the files "&out_dir._SomeNumber_infile.log" and                     *  ;
         %put "&out_dir._SomeNumber_con.log" for errors.                                         *  ;
        %*end;
       %end;
       %else %do;
        %if &messy. = 0 %then %do;
         %put Run SAVASTATA again using the "messy" option                                   *  ;
           %put Like:  %nrstr(%%)savastata(%nrbquote(&out_dir.),-messy &options.)%nrstr(;)   *  ;
         %put and then check the file "&out_dir._SomeNumber_infile.log" for errors.              *  ;
        %end;
       %end;
       %put For more help check here: &http.   * ;
       %if &isysver. < 8 %then 
              SAVASTATA did not save your dataset
       %put   *  ;
       %let fail=19;
%goto okay;

%fail20: %put  *  ;
       %put %upcase(error): SAVASTATA did not save your dataset.                                    *   ;
       %put Either Stata ran with an error (use -messy option to see) or *   ;
       %put SAVASTATA was not able to get Stata to execute and                             *   ;
       %put this is not where your Stata executable file is located:                       *   ;
       %put &wstata.                                                          *   ;
       %put There are instructions in the top section of the savastata.sas file             *  ;
       %put that explain how to edit the savastata.sas file to set the                      *  ;
       %put macro variable wstata to the correct location of your Stata executable file.    *  ;
       %put For more help check here: &http.   * ;
       %if &isysver.<8 %then 
              SAVASTATA did not save your dataset
       %put  *  ;
       %let fail=20;
%goto okay;

%fail21: %put   *  ;
       %put %upcase(error): SAVASTATA did not save your dataset.                            *   ;
       %put Either Stata ran with an error (use -messy option to see) or *   ;
       %put SAVASTATA was not able to get Stata to execute and                     *   ;
       %put this is not how to call Stata:                                         *   ;
       %put &ustata.                                                           *;
       %put There are instructions in the top section of the savastata.sas file    *   ;
       %put that explain how to edit the savastata.sas file to set the             *   ;
       %put macro variable ustata to the correct way to call Stata.                *   ;
       %put For more help check here: &http.   * ;
       %if &isysver.<8 %then 
              SAVASTATA did not save your dataset
       %put   *   ;
       %let fail=21;
%goto okay;

%fail22: %put   *  ;
       %put %upcase(error): SAVASTATA did not save your dataset.                            *   ;
       %put For reasons unknown SAVASTATA was not able to get Stata to execute.    *   ;
       %put This is the Stata executable SAVASTATA found:                          *   ;
       %if &unix. = 0 %then %do;
         %put "     %nrbquote(&wstata.)"                                           *   ;
       %end;
       %else %do;
         %put "     %nrbquote(&ustata.)"                                           *   ;
       %end;
       %put For more help check here: &http.   * ;
       %if &isysver.<8 %then 
              SAVASTATA did not save your dataset
       %put   *   ;
       %let fail=22;
%goto okay;

%fail23: %put   *  ;
       %put %upcase(error): SAVASTATA did not save your dataset.                            *   ;
       %put     *   ;
       %put For more help check here: &http.   * ;
       %if &isysver.<8 %then 
              SAVASTATA did not save your dataset
       %put   *   ;
       %let fail=23;
%goto okay;

%fail24: %put   *  ;
       %put %upcase(error): SAVASTATA did not save your dataset.                            *   ;
       %put The input dataset &dset. has &avars. variables which exceeds the 32,767 limit of Stata SE  *   ;
       %put Consider dropping at least %eval(&avars. - 32766) variables.                       *   ;
       %put For more help check here: &http.   * ;
       %if &isysver.<8 %then
              SAVASTATA did not save your dataset
       %put   *   ;
       %let fail=24;
%goto okay;

%fail25: %put   *  ;
       %put   *   ;
       %put %upcase(error): SAVASTATA did not save your dataset.                            *   ;
       %let nobs=%sysfunc(putn(&nobs.,comma32.));
       %let maxobs=%sysfunc(putn(&maxobs.,comma32.));
       %put The input dataset &dset. has &nobs. observations.               *   ;
       %put  which exceeds %nrquote(Stata%str(%'s)) limit of &maxobs. observations.       *   ; /*'*/
       %put For more help check here: &http.   * ;
       %if &isysver.<8 %then
              SAVASTATA did not save your dataset
       %put   *   ;
       %let fail=25;
%goto okay;



%okay: %put ;
%if &success.=0 and "&nosave."="" %then %goto done;

%if &fail. > 0 and  "&script." = "usesas" %then %do;
  %** used to just delete the _infile.do file but now also creating a text file that usesas *;
   %* looks for to see if savastata failed with a known error **;
  %* fail22 and fail23 are unknown reasons  and fail13 could be an unknown reason *;
  %if (&fail. < 22 or &fail. > 23) and &fail. ^= 13  %then %do;
    data _null_;
     file "&temp_dir._&tfns._knerror.txt";
     put "fail==&fail.";
    run;
  %end;
  %** erase _infile.do so that -usesas- will not attempt to run it **;
  %if %sysfunc(fileexist(%nrbquote("&temp_dir._&tfns._infile.do"))) %then %do;
    data _null_;
        fname= "tempfile";
        rc= filename(fname,"&temp_dir._&tfns._infile.do");
        if fexist(fname) then rc= fdelete(fname);
    run;
  %end;
  %* since only run by usesas, no need to clean up or figure out how long savastata took to run.  *;
  %goto nevrmind;
%end;
 
%if &ascii. = 1 %then %do;
       options notes; 
       %put   *   ;
       %put NOTE: SAVASTATA has successfully created the ascii data file %nrbquote(&out_dir.)_&tfns._.raw.     *  ;
       %put   *   ;
%end;
%else %if &ascii. = 0 and &messy. = 1 and "&script." = "" %then %do;
       options notes; 
       %put   *   ;
       %put NOTE: SAVASTATA has created its intermediary files _&tfns._* in:   *  ;
       %put          %nrbquote(&out_dir.)      *  ;
       %put   *   ;
%end;


options nonotes;  %** Make sure notes are shut off while deleting temp files and figuring out run time. **;
%****** clean up ***************;
%if "&script." ^= "usesas" %then %do;
 proc datasets library=work nodetails nolist nowarn;
  %** if a dataset does not exist, SAS does not give error message **;
   %*  so delete all of them. **;
  delete _conten _conten1 _conten2 _conten3;
 run;
 quit;
%end; %** if script ^= usesas **; 

%** Figure out how much time savastata took to process the dataset. **;
%** initialize macro vars **;
%let diffhour= %sysfunc(compress(%sysfunc(hour(%sysfunc(datetime())-&startdat.))));
%let diffmin= %sysfunc(compress(%sysfunc(minute(%sysfunc(datetime())-&startdat.))));
%let diffsec= %sysfunc(compress(%sysfunc(second(%sysfunc(datetime())-&startdat.))));

 options notes;
 %if &diffhour. > 0 %then %put NOTE:  SAVASTATA took about &diffhour. hours and &dffmin. minutes to run.     *   ;
 %else %if &diffmin.=0 %then %put NOTE:  SAVASTATA took less than a minute to run.    *  ;
 %else %put NOTE:  SAVASTATA took about &diffmin. mins to run.                      *  ;
 %if &sysindex. = 10 and &check. = 1 %then %do;
   %put ;
   %put Michael says, %str(%"Checking data is cool!%") ; 
   %put ;
 %end;
%done: ;

%if "&script." = "usesas" %then %do;
   proc printto;
   run;
%end;

options nonotes;
%if %sysfunc(fileexist(&usagelog.)) %then %do;
 data _null_;
  difftime= compress("&diffhour."||":"||"&diffmin."||":"||round(&diffsec.,0.1));
  file &usagelog. mod;
  put "   SAS dataset name: &dset.  pwd= &pwdir. ";
  put "   Elapsed time for SAVASTATA macro is " difftime;
  put "   fail= &fail. ";
 run;
%end;

options obs= &obs. &notes. missing= "%nrbquote(&missing.)";  %** Restore options. **;
 %** Make sure that the last dataset created in work is the users dataset. **;
%let sysdsn= &s_dsn.;
%let syslast= &s_last.;

%if &unix. = 0 %then %do;
  %sysexec &pwdrive. ;   %** change to the drive that SAS started out in. **;
%end;  %** end of if unix=0 do loop **;
%** sysexec requires no quotes even when changing to dirs with spaces in windows or unix **;
%sysexec cd &pwdir. ;   %** change to the directory that SAS started out in. **;
%nevrmind: ;  %** Go to here if an error occurred before savastata started **;

%MEND savastata;

