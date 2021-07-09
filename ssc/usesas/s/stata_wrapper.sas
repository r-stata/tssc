/**************************************************************
 * STATA_WRAPPER should work for you as is, but you may need 
 *  to edit this file to set the values for the macro variables:
 *  ustata  -- if you are using STATA_WRAPPER in a UNIX or Linux environment
 *  wstata  -- if you are using STATA_WRAPPER in a Windows environment
 *
 * There are instructions further down in this file explaining where 
 *  and how to edit the settings of these macro variables.
 * Do a find for "let ustata" or "let wstata".
 **************************************************************/

run;   ** Because the world needs more run statements. **;


%MACRO stata_wrapper(swoptions,out_dir);  
run;   %** Because the world needs more run statements. **;
%** If an error has occurred before call to STATA_WRAPPER then fail immediately. **;
%if &syserr.^=0 %then %goto nevrmind;  
               
/*********************************************************************************************
** Macro: STATA_WRAPPER
** Input: Most recently created SAS WORK dataset and some Stata code to process.
**         
** Output: by default will be included in the SAS output window/.lst file.
**        
** Dependency:  You need to have the Stata installed on your computer and have the 
**               Stata command -usesas- installed for STATA_WRAPPER to load your
**               SAS dataset into Stata.  It would also be a good idea to have the
**               Stata command -savasas- installed as well if you want to pass data
**               back to your SAS session.
**         
** 
** Programmer: Dan Blanchette   dan_blanchette@unc.edu
**             The Carolina Population Center at The University of North Carolina at Chapel Hill
** Developed at:
**             Research Computing, UNC-CH  and
**             Center for Entrepreneurship and Innovation Duke University's Fuqua School of Business
** Date: 20March2008
** Modified: 16Apr2012  - Made it so that Stata executables in the "Program Files (x86)" directory will be found.
** Modified: 28Mar2011  - Made it so that Stata 11 Windows executables can be found since Stata
**                         changed the names of them in Stata 11. Also made it so that
**                         if SAS on Linux is not allowed to CD to the work directory it CDs to /tmp/
**                         to invoke Stata so that the file: _&swtfns._stata_wrapper.log
**                         in /tmp/ and can be safely deleted.
** Modified: 02Dec2010 - Fixed it so that scanning for options is only done when there are options 
**                         specified by the user.
** Modified: 24Apr2008 - Added Stata command -sas_work- that changes directory (cd's) to
**                        the SAS WORK library/directory.  It also returns the local macro
**                        r(sas_work) so that it can be used if needed.
**         
** Modified: 27Jun2008 - Fixed problem with NOTES being shut off after running:
**                        %stata_wrapper(code) datalines;
**         
** Disclaimer:  This program is free to use and to distribute as long as credit is given to
**               Dan Blanchette
**               The Carolina Population Center 
**               University of North Carolina at Chapel Hill
**
**               There is no warranty on this software either expressed or implied.  This program
**                is released under the terms and conditions of GNU General Public License.
**
** Comments: 
**   STATA_WRAPPER SAS macro when invoked by the SAS System passes the most recently created SAS dataset
**    in the WORK library to Stata and runs the Stata code written after the %stata_wrapper(code) datalines; 
**    line.  The log of the Stata code will be included in the SAS output window or .lst file unless an 
**    output directory name is specified.
**
** REQUIRED INPUT TO STATA_WRAPPER:
**  -- STATA_WRAPPER needs to have the most recently created dataset by SAS to be in the WORK library 
**      and a Stata do-file to process. 
**             
** LIST OF OPTIONS:
** NOTE:  Options can be used in any order.  You can specify as many as you want
**         or none at all. 
**             
** -code     -- Used when only using writing Stata code to be submitted by STATA_WRAPPER.  You must
**               use it like so (You have to have "datalines;" after the call to STATA_WAPPER) :
**               %stata_wrapper(code) datalines;
**                  svyset myPSUvar [pweight=myWeightVar], strata(MyStratumVar) 
**                  svy:mean income weight height, over(agegroup race)
**                ;;  ** You should put at least one semi-colon after all your Stata code **;
**                 ** Your Stata code cannot contain any semi-colons.  Do not use #delimit; **;
**                 ** If you really want to use semi-colons in your Stata code, use "datalines4;" **;
**                  *  and end your Stata code with 4 semi-colons starting at the very  **;
**                  *  beginning of the line (column 1 through column 4) **;
**               %stata_wrapper(code) datalines4;
**                  svyset myPSUvar [pweight=myWeightVar], strata(MyStratumVar) 
**                  svy:mean income weight height, over(agegroup race)
**               ;;;;  ** You need 4 semi-colons starting at the beginning of the line. **;
**             
** -replace  -- If an output directory is specified and the output files you want to output already exist, 
**               -replace will then overwrite them with the files generated by STATA_WRAPPER
**             
** -nodata   -- Indicates not to load the most recent SAS dataset in the WORK library into Stata.
**               This should be used when your Stata code does not require that dataset. 
**             
** -noformats -- Specifies not to create value labels (which is the default) from SAS user-defined formats 
**               that are stored in a SAS formats catalog file that has the same name as the dataset and is 
**               in the WORK directory.  For example: MySasData.sas7bcat .  If this file doesn't exist, 
**               -usesas- will look for the file formats.sas7bcat in the WORK directory.
**               
** -int      -- (Windows only option, not for Linux/UNIX) Keep interactive Stata running.  You have to 
**               exit/close Stata before you can return to SAS or exit/close SAS since SAS is waiting 
**               for Stata to stop running.
**             
** -log      -- Includes the Stata log in your SAS log rather than your SAS output window/.lst file.
**             
** =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
**   Since STATA_WRAPPER uses the Stata command -usesas- to load the most recently created SAS dataset in
**    the WORK library the following are options to be used by -usesas- when called by STATA_WRAPPER:
** =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
**            
** -char2lab -- Specifies to encode long SAS character variables like the Stata command -encode-.  Character 
**               variables that are too long for a Stata string variable are maintained in value labels.
**            
** -float    -- Specifies that numeric variables that would otherwise be stored as numeric type double be 
**               stored with numeric type float.  This option should only be used if you are certain you 
**               have no integer variables that have more than 7 digits (like an id variable).
**            
** -quotes   -- Specifies that double quotes that exist in string variables are to be replaced with single 
**               quotes.  Since the data are written out to an ASCII file and then read into Stata, double 
**               quotes are not allowed.
** =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
**             
** -messy    -- Puts the files generated by STATA_WRAPPER used to create the Stata log file in the directory
**               named in the pathname provided in the call to the STATA_WRAPPER macro.
**             
**             
** SETTING UP STATA_WRAPPER 
**  These are instructions to edit the stata_wrapper.sas file.
**             
** NOTE:  If you are setting up this macro on your computer for the first time,
**         please choose which version of Stata you are going to have STATA_WRAPPER use.
**         If you do not choose to set one of the following switches, STATA_WRAPPER will
**         figure out what version of Stata you are running for you.  This may 
**         add a noticeable amount of time to processing so you may want to set these 
**         switches to the correct version of Stata.  You can easily figure out what 
**         version of Stata you are using by looking at the top of your results window 
**         in Stata or by typing in the command -about- at the Stata command line.
**         One advantage of leaving STATA_WRAPPER to figure out what version of Stata is 
**         being used is that when you upgrade your version of Stata you will not have to
**         update stata_wrapper.
**  
**  NOTE:
**  --  If you are running STATA_WRAPPER on UNIX or Linux then
**       you need to be able to start a Stata batch job by:
**       stata -b do mydofile.do
**       If not, then change the setting of the ustata macro variable.
**********************************************************************************************/
 %local ustata;
/** One of these may work: **
 %let ustata=stata;
 %let ustata=/usr/local/stata/stata;
 %let ustata=/usr/local/stata/stata-mp;
 %let ustata=/usr/local/stata/stata-se;  */
 %let ustata=stata;


/**********************************************************************************************
**
**  --  If you are running STATA_WRAPPER on Windows, you may need to tell STATA_WRAPPER where 
**       the Stata executable file is located if STATA_WRAPPER cannot find it.
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
** HOW TO USE THE STATA_WRAPPER MACRO: 
** Using the STATA_WRAPPER macro requires that you understand how to use the "%include" statement
**  and that you know how to call a SAS macro.
**
**  %include'LOCATION AND NAME OF A FILE THAT CONTAINS SAS CODE';
**
** For example, if you have copied this file to "C:\SASmacros", then you tell SAS 
**  about this macro by adding the following line to your SAS program:
**
**  %include 'C:\SASmacros\stata_wrapper.sas'; 
**
** This statement makes SAS aware of the STATA_WRAPPER macro which is in the file stata_wrapper.sas.
** To use the macro you have to make a call to it.  To do that you add a line like the 
**  following to your SAS program:
**
**  %stata_wrapper([options], "[folder to save Stata output]");
**  But you don't really have to specify anything if you want to use the defaults:
**  %stata_wrapper;
**
**
**  ** create data set that contains only the observations and variable(s) needed for the Stata command 
**   *  to be run:  **;
**  data test;
**   set my_data (keep=math cses one school
**                where=(gender=1));
**  run;
**
**  ** write some Stata code to be submitted by STATA_WRAPPER: **;
**  %stata_wrapper(code) datalines;
**   eq cses: cses
**   eq one: one
**   gllamm math cses, i(school) eqs(one cses)  diff adapt nrf(2) 
**  ;;;; ** end Stata code with at least one semi-colon **;
**
**  ** Have STATA_WRAPPER submit the above Stata code to Stata  **;
**  %stata_wrapper;
**
**
**  Or you can submit a Stata do-file saved in some other directory:
**  %stata_wrapper(code) datalines;
**    do  "C:\my_project\my_stata_code.do"
**  ;;;;
**
**  ** Have STATA_WRAPPER submit the above Stata code to Stata  **;
**  %stata_wrapper;
**
**
** The information inside the parentheses is passed on to the STATA_WRAPPER macro.  The first
** string of information is any/all STATA_WRAPPER options.  The second string 
** of information is the location you want to save your Stata log file if you do not want it
** included in the SAS output window/.lst file.  This is somewhat like a LIBNAME statement.  
**
**
** EXAMPLE USE OF THE STATA_WRAPPER MACRO:
**  %include "C:\SASmacros\stata_wrapper.sas"; ** Include macro once in a SAS session and call it **;
**                                              *  as many times as you like in that session.     **;
**
**  data work.ToBeStata;   ** This makes a copy of the SAS dataset in the in the work library. **;
**   set in.mySASfile (keep= math school
**                     where=(gender=2));
**  run;
** 
**  ** write some Stata code to be submitted to Stata by STATA_WRAPPER **;
**  %stata_wrapper(code) datalines;
**   matrix b1 = [12, 2, 8]
**   gllamm math , i(school) from(b1) copy
**  ;;;;
**
**  ** now submit the above code to Stata **;
**  %stata_wrapper;  
** 
** 
**  OTHER EXAMPLE CALLS:
**                
**  ** Save the Stata log file "_[some_big_number]_stata_code.log  **; 
**  ** in C:\MyData\, overwriting it if  it already exists.    **; 
**  %stata_wrapper(-replace,"C:\MyData\");  
**                
**  ** Run the Stata do-file "my_stata_code.do in C:\MyProject\ and **; 
**   * save the Stata log file "_[some_big_number]_stata_code.log  **; 
**   * in C:\MyData\, overwriting the log file if it already exists.    **; 
**  %stata_wrapper(code);  
**    do "C:\MyProject\my_stata_code.do"
**  ;;;;
**  %stata_wrapper(-replace,"C:\MyData\");  
**                
**                
**  This example is like a USESTATA SAS macro.
**
**  %stata_wrapper(code) datalines; 
**    use "C:\My Project\Data\some_data.dta"
**    savasas using "some_data.sas7bdat"
**  ;;;;
**
**  * specify not to use the most recently created SAS dataset in WORK **;
**  *  since your Stata code does not need it. **;
**  %stata_wrapper(-nodata);
**
**  ** now you can access this data set from your WORK library/directory because  **;
**   *  no directory name was specified in the call to -savasas- above. **;
**  proc contents work.some_data;
**  run;
**                
** The above example assumes that Stata is not set up to cd to some other directory when 
**  Stata is started up.  If you are not in the SAS WORK library/directory at the moment
**  when -savasas- is invoked you can use the Stata command -sas_work- to cd you to that
**  directory.  This command is only available while running STATA_WRAPPER.
**  Here is an example using -sas_work-
**                
**  %stata_wrapper(code) datalines; 
**    use "C:\My Project\Data\some_data.dta"
**    sas_work
**    return list  // this is optional but shows that the local macro r(sas_work) exists now
**    savasas using "some_data.sas7bdat"
**  ;;;;
**
**  %stata_wrapper(-nodata);
**
**  proc contents work.some_data;
**  run;
** 
***********************************************************************************************/


 %local usagelog;
%** SET LOCATION OF USAGE LOG FILE **;
%let usagelog="specify what file name and location you want here";
%if "&sysscp."="WIN" %then %do;
 %let usagelog="x:\software\temp\stata_wrapper_usage.log";  %* windoze *;
%end;
%else %if "&sysscp."="RS6000" %then %do;
 %let usagelog="/afs/isis.unc.edu/home/d/a/danb/usage/stata_wrapper_usage.log";  %* AIX nodes *;
%end;
%else %if "&sysscp."="AIX 64" %then %do;
 %let usagelog="/afs/isis.unc.edu/home/d/a/danb/usage/stata_wrapper_usage.log";  %* AIX nodes *;
%end;
%else %if "&sysscp."="LINUX" %then %do;   %* linux boxes *;
  %let usagelog="/afs/isis.unc.edu/home/d/a/danb/usage/stata_wrapper_usage.log";  
%end;


/***************************************************************************/
/****** !NO MORE EDITS TO THE MACRO SHOULD BE MADE BEYOND THIS POINT! ******/
/***************************************************************************/

 %** local macro vars used in stata_wrapper: **;
 %local char2lab code 
        decpos diffhour diffmin diffsec drive dset 
        fail fail7 fdset float formats 
        exe10 exe11 
        http 
        i ii int isysver 
        j jj 
        k kk 
        ldset lst_name 
        messy newname 
        no_out_dir nocd notes 
        obs 
        pwdir pwdrive 
        quotes 
        replace 
        slash 
        sw_dsn sw_last swtartdat swtfns swlog 
        temp_dir unix u_sysrc w_sysrc work_dir
       ;;;


%** make sure sas version is an integer so it can be properly evaluated **;
%let isysver = %sysevalf(&sysver.,integer);  

 %** Save option settings so they can be restored at the end of this macro. **;
%let notes=%sysfunc(getoption(notes)); 
%let obs=%sysfunc(getoption(obs)); 

options obs=MAX;   %*** Reason for maximizing it is because user could have        **;
                     %*  set it lower than the number of variables in the dataset. **;
options nonotes;   %** Shut off notes while program is running in order to reduce log size. **;

%** Time how long STATA_WRAPPER takes to run **;
%let swtartdat=%sysfunc(datetime());

%let sprog=stata_wrapper;
%let http=%nrstr(http://www.cpc.unc.edu/research/tools/data_analysis/sas_to_stata/)&sprog..html;


%** initialize macro vars **;
%let diffhour=0;
%let diffmin=0;
%let diffsec=0;
%let fail=0;
%let no_out_dir=0;

%if %length(%nrbquote(&out_dir.)) = 0 %then %let no_out_dir = 1;

%if %nrbquote(%index(%nrbquote(&out_dir.),%str(%")))=1   /** " end quote */
   or %nrbquote(%index(%nrbquote(&out_dir.),%str(%')))=1 /** ' end quote */
      %then %let out_dir=%nrbquote(%substr(%nrbquote(&out_dir.),2,%length(%nrbquote(&out_dir.))-2)); 


%let code=0;
%** create stata_code.do in the WORK library: **;
%if %index(%lowcase(%nrbquote(&swoptions.)),code) %then %do;
  %let code=1;
  
  data _null_;
   file "%nrbquote(%sysfunc(pathname(work)))/stata_code.do";
   infile datalines truncover;
   input @1  sw $2. ;
   put _infile_;

%end;
options obs=&obs. &notes. ;  %** Restore options. **;
%if &code.=1 %then %goto nevrmind;


%** Find out what directory SAS currently is using as the present working directory **;
 %*  so that it can be restored at end of macro. **;
options nonotes; 
libname ________ " ";  %** ________ is a very unlikely libname **;
options &notes. ;  %** Restore notes. **;
%let pwdir=%nrbquote(%sysfunc(pathname(________)))/;
%let pwdrive= ;
%if %index(%nrbquote(&pwdir.),\) %then %do;
   %let pwdrive= %qsubstr(%nrbquote(&pwdir.),1,2);   %** get drive info eg. "D:"  **;
%end;


%**  use the work directory to store the temporary SAS files that this program creates ***;
%let temp_dir = %nrbquote(%sysfunc(pathname(work)));
%let work_dir = %nrbquote(%sysfunc(pathname(work)));

%** this is first time program goes to a fail label **;
%** Work directory cannot start with a back slash because stata_wrapper needs to cd to it. **;
%if %index(%nrbquote(&work_dir.),\)=1 %then %goto fail1; 

%* if out_dir not specified then make it the work_dir **;
%if &no_out_dir. = 1 %then %let out_dir=%nrbquote(&work_dir.);

%** initialize var **;
%let newname=;
 
%** check to see if new log file name provided in %nrbquote(&out_dir.) **;
%if %nrbquote(%length(&out_dir.)) > 0  %then %do;  
 %if %nrbquote(%index(%qlowcase(&out_dir.),.log)) %then %do;
  %** if Stata dataset name provided with directory info **;
  %if "%qlowcase(%substr(%nrbquote(&out_dir.),%length(%nrbquote(&out_dir.))-3,4))"=".log" %then %do;  
    %** if no backslash provided:  savstata(D:mydata.log) then add in the backslash **;
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
    %let out_dir=%nrbquote(%substr(%nrbquote(&out_dir.),1,%index(%nrbquote(&out_dir.),%nrbquote(&newname.))-1));
   %end;
   %else %let out_dir=;  %** only new name provided **;
  %end;
 %end; %** end of if %index(%nrbquote(&out_dir.),.log) do loop **;
%end; %** end of if length(%nrbquote(&out_dir.)) = 0 do loop **;
 
 
%let swoptions=%lowcase(%nrbquote(&swoptions.));
%let sw_dsn=&sysdsn.;  %** preserve these to restore after setting up usagelog **;

%** log usage of stata_wrapper if usage log file exists **;
%if %sysfunc(fileexist(&usagelog.)) %then %do;
 options nonotes;
 data _null_;
  file &usagelog. mod;
   put " ";
   date=datetime() ;
   put " stata_wrapper macro " date dateampm.  ;
   put "  &sysuserid. stata_wrapper(&swoptions., &out_dir.)";
 run;
  options &notes. ;  %** Restore notes. **;
%end;

%let sysdsn=&sw_dsn.; %** restore after setting up usagelog **; 

%** Initialize macro vars for stata_wrapper options **;
%let int=0;
%let nodata=0;
%let replace= ;
%let swlog=0;
%let char2lab= ;
%let formats=formats;
%let float= ;
%let quotes= ;
%let messy=0;

%** need to remove dashes from options as SAS thinks they are minus signs and wants to evaluate stuff **;
 %*  need to do this in a data step so that the double quotes around options do not get added to the *;
 %*  options macro variable *;
data _null_;
 call symput('swoptions',translate("&swoptions."," ","-"));
run;

%if %str(&swoptions.) ^= %str() %then %do;
 %** Find out what options were specified **;
 %if %index(&swoptions.,rep) %then %let replace= replace; %** set replace option  **;
 %if %index(&swoptions.,nod) %then %let nodata= 1; %** set nodata option  **;
 %if %index(&swoptions.,int) %then %let int= 1; %** set int option  **;
 %if %index(&swoptions.,log) %then %let swlog= 1; %** set log option  **;
 %if %index(&swoptions.,fl)   %then %let float= float;  %** set float option  **;
 %if %index(&swoptions.,nofor) %then %let formats=;  %** set noformats option  **;
 %if %index(&swoptions.,qu)   %then %let quotes= quotes; %** set quote option  **;
 %if %index(&swoptions.,cha)  %then %let char2lab= char2lab;  %** set char2lab option  **;
 %if %index(&swoptions.,mes) %then %let messy= 1; %** set messy option  **;
%end;



%if &nodata. = 0 %then %do;
  %*** Use the most recently created SAS work dataset.  ***;
  %let sw_last=&syslast.;
  %let ldset=%length(&syslast.);
  %let decpos=%index(&syslast.,.);
  %let dset=%substr(&syslast.,&decpos.+1,&ldset.-&decpos.);
%end;

%** Figure out whether the operating system uses forward slashes or back slashes in   **;
 %*  directory paths and make sure that out_dir has the appropriate slash at the end. **;
%let unix= 0;
%let drive= ;
%IF %index(%nrbquote(&temp_dir.),\) %THEN %do;
   %let unix=0;   %** unix=0 implies windows platform **;
   %let drive= %qsubstr("&work_dir.",2,2);   %** get drive info eg. "d:"  **;
   %let temp_dir = %nrbquote(&temp_dir.)\;   %** tack on a back slash **;
   %if "&out_dir."=""  %then %goto fail3;  
   %else %if "&out_dir."=" " %then %goto fail3;
   %else %if "&out_dir."="." %then %goto fail3;
   %let slash= %qsubstr("&out_dir.",%length("&out_dir.")-1,1);   %** check if back slash at end **;
   %if "&slash."^="\" %THEN %do; /* " end quote */
     %let out_dir= %nrbquote(&out_dir.)\;   %** add a back slash at end if it is not there already **;
   %end;
   %let slash= %qsubstr("&work_dir.",%length("&work_dir.")-1,1);   %** check if back slash at end **;
   %if "&slash."^="\" %THEN %do;  /* " end quote */
     %let work_dir= %nrbquote(&work_dir.)\;   %** add a back slash at end if it is not there already **;
   %end;
   %end;
%ELSE %IF %index(%nrbquote(&temp_dir.),/) %THEN %do;
  %let unix= 1;  %** unix or unix-like platform **;
  %let temp_dir= %nrbquote(&temp_dir.)/;  %** tack on a forward slash **;
    %** make sure that out_dir is not a relative directory name like: ../mydata/ **;
  options nonotes;
  libname ________ "&out_dir.";  %** ________ is a very unlikely libname **;
  options &notes. ;  %** Restore notes. **;
  %let out_dir=%nrbquote(%sysfunc(pathname(________)));
  %let slash= %qsubstr("&out_dir.",%length("&out_dir.")-1,1);  %** check if back slash at end **;
  %if "&slash."^="/" %THEN %do;
    %let out_dir= %nrbquote(&out_dir.)/;  %** add a forward slash at end if it is not there already **;
  %end;
  %let slash= %qsubstr("&work_dir.",%length("&work_dir.")-1,1);  %** check if back slash at end **;
  %if "&slash."^="/" %THEN %do;
    %let work_dir= %nrbquote(&work_dir.)/;  %** add a forward slash at end if it is not there already **;
  %end;
%END; %** ELSE IF index("temp_dir",/) THEN do loop **;

 
%if &int. = 1 and &unix. = 1 %then %do;
  options notes;
    %put NOTE: The "-int" option is for Windows only.  Stata will be run in batch.;
  options nonotes;
%end;

%** Make sure the dataset name and any option passed to stata_wrapper is in lower case. **;
%let dset=%lowcase(%nrbquote(&dset.));
%if %length(&newname.)>0 %then %let fdset=%nrbquote(&newname.);
%else %let fdset=%lowcase(%nrbquote(&dset.));

%if &nodata.=0 %then %do;
  %if %index(&syslast.,WORK)^=1 %then %goto fail2;
%end;

%** if obs are set to zero, error in program previous to stata_wrapper **;
%if &obs. = 0 %then %goto fail6;  


%** check to see if user has set up Windows Stata correctly. **;
%** if not then check other likely places the Stata executable would be. **;
%let fail7= 0;

%if &unix. = 0 and %sysfunc(fileexist("&wstata.")) = 0 %then %do %while(&fail7. = 0);
   %let drives= C D Y;
   %let exe10= wsestata wmpstata wstata wsmstata;
   %let exe11= statase statamp stata smstata;  %** in version 11 Stata changed the names **;
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
    %let ii =%scan(&drives.,&i.,%nrstr( ));
    %do j= 1 %to %sysfunc(countw(&exe11.));  %** one for each exe of stata **;
     %do k= 1 %to %sysfunc(countw(&versions.));  %** one for each version of stata **;
      %let kk= %scan(&versions.,&k.,%nrstr( ));
      %if %eval(&kk. < 11 ) %then %do;
        %let jj= %scan(&exe10.,&j.,%nrstr( ));
      %end;
      %else %do;
        %let jj= %scan(&exe11.,&j.,%nrstr( ));
      %end;
      %let wstata=%str(&ii.:\Stata&kk.\&jj..exe);
      %if %sysfunc(fileexist("&wstata."))=0 %then %do;
        %let wstata=%str(&ii.:\Program Files\Stata-&kk.\&jj..exe);  %** Stata-9 **;
      %end;
      %else %goto exist;  %** file exists **;
      %if %sysfunc(fileexist("&wstata."))=0 %then %do;
        %let wstata=%str(&ii.:\Program Files (x86)\Stata-&kk.\&jj..exe);  %** Stata-9 **;
      %end;
      %else %goto exist;  %** file exists **;
      %if %sysfunc(fileexist("&wstata"))=0 %then %do;
        %let wstata=%str(&ii.:\Program Files\Stata&kk.\&jj..exe);   %** Stata9 **;
      %end;
      %else %goto exist;  %** file exists **;
      %if %sysfunc(fileexist("&wstata"))=0 %then %do;
        %let wstata=%str(&ii.:\Program Files (x86)\Stata&kk.\&jj..exe);   %** Stata9 **;
      %end;
      %else %goto exist;  %** file exists **;
      %if %sysfunc(fileexist("&wstata."))=0 %then %do;
        %let wstata=%str(&ii.:\Stata-&kk.\&jj..exe);  %** Stata-9 **;
      %end;
      %else %goto exist;  %** file exists **;
      %if %sysfunc(fileexist("&wstata."))=0 %then %do;  
        %let wstata=%str(&ii.:\Stata&kk.\&jj..exe);   %** Stata9 **;
      %end;
      %else %goto exist;  %** file exists **;
      %if %sysfunc(fileexist("&wstata."))=0 %then %do;
        %let wstata=%str(&ii.:\Stata\&jj..exe);
      %end;
      %else %goto exist;  %** file exists **;
      %if %sysfunc(fileexist("&wstata."))=0 %then %do;
       %** nothing **;
      %end;
      %else %goto exist;  %** file exists **;
     %end;  %** of k loop **;
    %end;  %** of j loop **;
   %end;  %** of i loop **;
   %do;  %** check path for Stata executable **;
     %let i= 1;
     %let delim= %str(;);
     %do %until (%qscan(%sysget(PATH),&i.,%str(&delim.)) = );
      %do j= 1 %to %sysfunc(countw(&exe11.)); %** one for each exe of Stata **;
       %let jj= %scan(&exe11.,&j.,%nrstr( ));
       %let wstata= "%qscan(%sysget(PATH),&i.,%str(&delim.))\&jj..exe";
       %if %sysfunc(fileexist("&wstata.")) %then %do;
         %let fail7= 2;
         %let i= 200000;  %** break loop if found it **;
       %end;
      %end; %** of j loop **;
      %let i= %eval(&i.+1);
     %end; %** of until loop **;
     %if &fail7. = 2 %then %goto exist;  %** file exists **;
   %end; %** of checking path for Stata executable **;
  
   %if %sysfunc(fileexist("&wstata.")) = 0 %then %do;
     %let fail7= 1;  %** give up **;
   %end;
  %exist: ;
  %if &fail7. = 0 %then  %let fail7= 2;  %** found file so break while loop **;
%end;  %** end of if unix = 0 then do while loop **;

  
%if &fail7. = 1 %then %goto fail7;

%put STATA_WRAPPER is going to use this Stata executable:;
%if &unix. = 0 %then %do;
  %put "     %nrbquote(&wstata.)";
  %put ;
%end;
%else %do;
  %put "     %nrbquote(&ustata.)";
  %put ;
%end;

options nonotes;  
libname ________ "&out_dir.";  %** ________ is a very unlikely libname **;
options &notes. ;  %** Restore notes. **;
%if &syslibrc.^=0 %then %do;
 libname ________ clear;  %** do away with it now **;
 %goto fail4;  %** exit if not a valid pathname **;
%end;

options nonotes;  
libname ________ clear;  %** do away with it now **;
options &notes. ;  %** Restore notes. **;


%if &messy. = 1 %then %do;
 %if &no_out_dir. = 1 %then %let out_dir=%nrbquote(&pwdir.);
  %**  Use the output directory to store the SAS program files that this macro creates. ***;
 %let temp_dir= %nrbquote(&out_dir.); 
 %if &unix. = 0 %then %do;
  %let windrive= %qsubstr("&out_dir.",2,2);   %** get drive info eg. "d:"  **;
  %sysexec &windrive.;  ** change to whatever drive files are going **;
 %end;
 %** sysexec requires no quotes even when changing to dirs with spaces in windows or unix **;
 %sysexec cd %nrbquote(&out_dir.) ;   %** change to the drive and directory where the Stata do-files are. **;
%end;

%* temporary file name...make it unique *;
%let swtfns = &sysjobid.&sysindex.;

%if %sysfunc(fileexist("&out_dir._&swtfns._stata_code.log")) %then %do;
  %if &replace.^=replace %then %do;
     %goto fail5;
  %end;
%end;


options nonotes;
data _null_;
 file "&temp_dir._&swtfns._stata_wrapper.do" ls=2000;
    put "program define sas_work, rclass";
    put "display as text `""cd `""&work_dir.""'""' ";
    put "quietly  cd `""&work_dir.""' ";
    put "  return local sas_work `""&work_dir.""'";
    put "end ";
  %if &int. = 1 and &unix. = 0 %then %do;
    put "program define swexitnote";
    put "di as res _n _dup(`c(linesize)') ""-"" ";  %** create a horizontal line **;
    put "di as res ""NOTE: You have to exit Stata before you can return to SAS or exit/close SAS. "" ";
    put "di as res _dup(`c(linesize)') ""-"" ";
    put "end ";
  %end;
  %if &nodata.=0 %then %do;
    put "capture program drop swvtest";
    put "program define swvtest";
    put "if _caller() <=8 { ";
    put "  di as text ""You need Stata 8.1 or newer to use -usesas-""" ; 
    put "} ";
    put "end";
  %end;
  put "log using ""&out_dir._&swtfns._stata_code.log"", &replace. ";
  %if &int. = 0 and &unix. = 0 %then %do;
    put "set more off";
  %end;
  %if &nodata.=0 %then %do;
    put "swvtest";
    put "usesas using ""&work_dir.&fdset..sas7bdat"", &formats. &char2lab. &quotes. &float. ";
  %end;
  put "do ""&work_dir.stata_code.do"" ";
  %if &int. = 0 %then %do;
    put "exit, clear STATA";
  %end;
  %else %if &unix. = 0 %then %do;
    put "swexitnote";
  %end;
run;
options &notes. ;  %** Restore notes. **;


%** initialize macro vars for system return codes **;
%let u_sysrc=0; 
%let w_sysrc=0;  
%if &unix. = 1 %then %do;
  %** This submits the Stata do-file stata_code . ***;
  %** sysexec requires no quotes even when changing to dirs with spaces in windows or unix **;
  %sysexec cd %nrbquote(&temp_dir.) ;   %** change to the drive and directory where the Stata do-files are. **;


  %** test if able to cd to the work directory **;
  %sysexec echo $PWD > %nrbquote(&work_dir./_&swtfns._tdir.txt);
  data _null_;
   infile "%nrbquote(&work_dir./_&swtfns._tdir.txt)" lrecl= 32767 truncover;
   input test $200.;
   call symput('tdir',_infile_);
  run;
  %if %nrbquote(&tdir.) ne %nrbquote(&work_dir.) %then %do;
    %let nocd= cd;
    %sysexec cd /tmp/ ;
  %end;

   %** Run Stata in batch from within the directory where the temp files are. **;
  %if &nocd. = cd %then %do;
    %sysexec %nrbquote(&ustata.) -b do "&temp_dir._&swtfns._stata_wrapper.do";  
  %end;
  %else %do;
    %sysexec %nrbquote(&ustata.) -b do "_&swtfns._stata_wrapper.do";  
  %end;
  %let u_sysrc= &sysrc.;  %** store value of sysrc until after loop **;
  %if &nocd. = cd and &messy. = 0 %then %do;
     %if %sysfunc(fileexist("_&swtfns._stata_wrapper_.log")) %then %do;
        %sysexec rm _&swtfns._stata_wrapper.log ;
     %end;
  %end;

%end; %** if unix = 1 then do loop **;

%if &unix. = 0 %then %do;
  %sysexec &drive.;
  %** sysexec requires no quotes even when changing to dirs with spaces in windows or unix **;
  %sysexec cd %nrbquote(&work_dir.) ;
     %** Run Stata interactively. **;
  %sysexec "&wstata."  do "&temp_dir._&swtfns._stata_wrapper.do";  
  %let w_sysrc= &sysrc.;  %** store value of sysrc until after loop **;
%end;  %** if unix = 0 then do loop **;
%if &u_sysrc. ^= 0 %then %goto fail8;
%if &w_sysrc. ^= 0 %then %goto fail7; 


%* only include Stata output to SAS lst if out_dir not specified **;
%if %nrbquote(&out_dir.) = %nrbquote(&work_dir.) %then %do;
  %if %sysfunc(fileexist(%nrbquote(&out_dir._&swtfns._stata_code.log))) %then %do;
     data _null_;
    %if &swlog. = 0 %then %do;
      file print;
    %end;
    %else %do;
      file log;
    %end;
      %* probably only need to set lrecl to 256 since that is the max linesize for Stata *;
      infile "%nrbquote(&out_dir._&swtfns._stata_code.log)"  lrecl= 32767 truncover; 
      input @1 results $char1.;  %** this line is basically irrelevant **;
      put _infile_;  %** this is magic **;
     run;
  %end;
%end;
%else %if %nrbquote(&out_dir.) ^= %nrbquote(&work_dir.) %then %do;
  %* user specified to save results separately *;
  %if %sysfunc(fileexist(%nrbquote(&out_dir._&swtfns._stata_code.log))) %then %do;
    options notes; 
    %put   *   ;
    %put NOTE: STATA_WRAPPER has created the Stata log file:    *  ; 
    %put     %nrbquote(&out_dir._&swtfns._stata_code.log)   *  ;
    %put   *   ;
  %end;
%end;


options nonotes;  %** Make sure notes are shut off while deleting temp files and figuring out run time. **;


%goto okay;

%fail1: %put   *   ;
        %put ERROR: STATA_WRAPPER did not successfully run your Stata do-file              *  ;
        %put The work directory cannot start with a forward slash ( \ ) because              *  ;
        %put STATA_WRAPPER needs to cd to it.                                                   *  ;
        %put Is it possible to reassign your work directory to a drive like C: or D: ?      *  ;  
        %put For more help check here: &http.   * ;
        %if &isysver.<8 %then 
              STATA_WRAPPER did not successfully run your Stata do-file
        %put   *  ;
        %let fail=1;
%goto okay;

 %** The following are all the failure messages returned to the user when the macro **;
  %*  is unable to process the input SAS dataset.                                   **;
%fail2: 
        %put  * ;  
        %put ERROR: STATA_WRAPPER did not successfully run your Stata do-file              *  ;
        %if "%lowcase(&dset.)"="_null_" %then %do;
          %put You do not have a SAS dataset in the WORK library for          *  ;
          %put  STATA_WRAPPER to load into Stata.                                *  ;
        %end;
        %else
         %put The input dataset &dset. has to be in the work library.         *  ;
        %put For more help check here: &http.   * ;
         %** SAS 8 will put a note at the end of the log stating what page errors           **;
          %* occurred but earlier versions do not. So insert bad code to generate an error. **;
        %if &isysver.<8 %then 
              STATA_WRAPPER did not successfully run your Stata do-file
        %put  *  ;
        %let fail=2;
%goto okay;


%fail3: %put  *  ;  
        %put ERROR: STATA_WRAPPER did not successfully run your Stata do-file              *  ;
        %put You did not tell STATA_WRAPPER what directory you want to save the Stata log file.    *  ;
        %put Your call to STATA_WRAPPER should look something like this:                          *  ;
        %put %nrstr(%%)stata_wrapper(,"C:\mydata",-replace)                                         *  ;
        %put For more help check here: &http.   * ;
        %if &isysver.<8 %then 
              STATA_WRAPPER did not successfully run your Stata do-file
        %put  *  ;
        %let fail=3;
%goto okay;

%fail4: %put  *  ;  
        %put ERROR: STATA_WRAPPER did not successfully run your Stata do-file              *  ;
        %put The directory %nrbquote(&out_dir.) does not exist.                 *  ;
        %put For more help check here: &http.   *  ;
        %if &isysver.<8 %then 
              STATA_WRAPPER did not successfully run your Stata do-file
        %put  *  ;
        %let fail=4;
%goto okay;


%fail5: %put  *  ;  
        %put ERROR: STATA_WRAPPER did not successfully run your Stata do-file              *  ;
        %put The log file %nrbquote(&out_dir.)_&swtfns._stata_code.log already exists.                     *  ;
        %put If you want to overwrite this file, then use the STATA_WRAPPER option "-replace".    *  ;
        %put Like:  %nrstr(%%)stata_wrapper(%nrbquote(&out_dir.),-replace &swoptions.)%nrstr(;)     ;
        %put For more help check here: &http.   * ;
        %if &isysver.<8 %then 
              STATA_WRAPPER did not successfully run your Stata do-file
        %put  *  ;
        %let fail=5;
%goto okay;


%fail6: %put   *   ;
        %put ERROR: STATA_WRAPPER did not successfully run your Stata do-file              *  ;
        %put The input dataset &dset. has no observations.               *  ;
        %put For more help check here: &http.   * ;
        %if &isysver.<8 %then 
              STATA_WRAPPER did not successfully run your Stata do-file
        %put   *  ;
        %let fail=6;
%goto okay;



%fail7: %put  *  ;
        %put ERROR: STATA_WRAPPER did not successfully run your Stata do-file              *  ;
        %put STATA_WRAPPER was not able to get Stata to execute.                                *   ;
        %put This is not where your Stata executable file is located:                       *   ;
        %put &wstata.                                                          *   ;
        %put There are instructions in the top section of the stata_wrapper.sas file             *  ;
        %put that explain how to edit the stata_wrapper.sas file to set the                      *  ;
        %put macro variable wstata to the correct location of your Stata executable file.    *  ;
        %put For more help check here: &http.   * ;
        %if &isysver.<8 %then 
              STATA_WRAPPER did not successfully run your Stata do-file
        %put  *  ;
        %let fail=7;
%goto okay;

%fail8: %put   *  ;
        %put ERROR: STATA_WRAPPER did not successfully run your Stata do-file              *  ;
        %put STATA_WRAPPER was not able to get Stata to execute.                        *   ;
        %put This is not how to call Stata:                                         *   ;
        %put &ustata.                                                           *;
        %put There are instructions in the top section of the stata_wrapper.sas file    *   ;
        %put that explain how to edit the stata_wrapper.sas file to set the             *   ;
        %put macro variable ustata to the correct way to call Stata.                *   ;
        %put For more help check here: &http.   * ;
        %if &isysver.<8 %then 
               STATA_WRAPPER did not successfully run your Stata do-file
        %put   *   ;
        %let fail=8;
%goto okay;

%fail9: %put   *  ;
        %put ERROR: STATA_WRAPPER did not successfully run your Stata do-file              *  ;
        %put For reasons unknown STATA_WRAPPER was not able to get Stata to execute.    *   ;
        %put For more help check here: &http.   * ;
        %if &isysver.<8 %then 
               STATA_WRAPPER did not successfully run your Stata do-file
        %put   *   ;
        %let fail=9;
%goto okay;

%fail10: %put   *  ;
        %put ERROR: STATA_WRAPPER did not successfully run your Stata do-file              *  ;
        %put     *   ;
        %put For more help check here: &http.   * ;
        %if &isysver.<8 %then 
               STATA_WRAPPER did not successfully run your Stata do-file
        %put   *   ;
        %let fail=10;
%goto okay;



%okay: %put ;

%if &messy.=1  %then %do;
       options notes; 
       %put   *   ;
       %put NOTE: STATA_WRAPPER has created its intermediary files in:   *  ;
       %put          %nrbquote(&out_dir.)      *  ;
       %put   *   ;
%end;

options nonotes;  %** Make sure notes are shut off while deleting temp files and figuring out run time. **;

%** Figure out how much time stata_wrapper took to process the Stata do-file. **;
%** initialize macro vars **;
%let diffhour=%sysfunc(compress(%sysfunc(hour(%sysfunc(datetime())-&swtartdat.))));
%let diffmin=%sysfunc(compress(%sysfunc(minute(%sysfunc(datetime())-&swtartdat.))));
%let diffsec=%sysfunc(compress(%sysfunc(second(%sysfunc(datetime())-&swtartdat.))));

 options notes;
 %if &diffhour.>0 %then %put NOTE:  STATA_WRAPPER took about &diffhour. hours and &dffmin. minutes to run.     *   ;
 %else %if &diffmin.=0 %then %put NOTE:  STATA_WRAPPER took less than a minute to run.    *  ;
 %else %put NOTE:  STATA_WRAPPER took about &diffmin. mins to run.                      *  ;

 options nonotes;
%if %sysfunc(fileexist(&usagelog.)) %then %do;
 data _null_;
  difftime=compress("&diffhour."||":"||"&diffmin."||":"||round(&diffsec.,0.1));
  file &usagelog. mod;
  put "   SAS dataset name: &dset.  pwd=&pwdir. ";
  put "   Elapsed time for STATA_WRAPPER macro is " difftime;
  put "   fail=&fail. ";
 run;
%end;

options obs=&obs. &notes. ;  %** Restore options. **;
 %** Make sure that the last dataset created in work is the users dataset. **;
%let sysdsn=&sw_dsn.;
%let syslast=&sw_last.;

%if &unix.=0 %then %do;
 %sysexec &pwdrive. ;   %** change to the drive that SAS started out in. **;
%end;  %** end of if unix=0 do loop **;
%** sysexec requires no quotes even when changing to dirs with spaces in windows or unix **;
%sysexec cd &pwdir. ;   %** change to the directory that SAS started out in. **;
%nevrmind: ;  %** Go to here if an error occurred before stata_wrapper started **;

%MEND stata_wrapper;
