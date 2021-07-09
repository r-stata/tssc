{smcl}
{* März 19, 2009 @ 16:56:09 UK}{...}
{hi:help soepuse}, {hi:help soepadd}
{hline}

{title:Title}

{phang}
 Makes retrievals from GSOEP real easy
{p_end}

{title:Syntax}
{phang2}
   {cmd:soepuse }
   {it:varnames} 
   {cmd: using} {it:dirname}
   {cmd:, }
   {it:mandatory_options}  
   {cmd:[}
   {it:soepuse_options joint_options}  
   {cmd:]}

{phang2}
   {cmd:soepadd }
   {it:varnames} 
   {cmd:, }
   {it:mandatory_options}  
   {cmd:[}
   {it:joint_options}  
   {cmd:]}

{pstd}
{it:dirname} refer to the name of the directory in which the GSOEP
files are stored. The term {it: varnames} refer to variable names of
the GSOEP. Note: You cannot specify varnames in terms of a {help varlist}.


{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Mandatory options}
{synopt:{opt f:typ(fileype)}}type of SOEP file (h, p, pgen, etc.){p_end}
{synopt:{opt w:aves(numlist)}}waves to be used{p_end}

{syntab:Soepuse_options}
{synopt:{opt d:esign(designtype)}} Design; default: {cmd:design(balanced)}{p_end}
{synopt:{opt k:eep(varlist)}} Keep variables from ppfad{p_end}
{synopt:{opt clear}} Replace data in memory{p_end}

{syntab:Joint Options (seldom used)}
{synopt:{opt o:st(g|h)}} Request special files for east{p_end}
{synopt:{opt onlyost}} Use only special files {p_end}
{synopt:{opt oldnetto}} Use old design of netto variables{p_end}
{synopt:{opt uc}} Variable list is upper case{p_end}
{synopt:{opt fast}} Speed up (not much){p_end}
{synoptline}
{p2colreset}{...}

{title:Description}

{pstd} {cmd:soepuse} and {cmd:soepadd} are two little tools for
performing retrievals from the German Socio Economic Panel. The
programs are revisions of two older programs, {cmd:mkdat} and
{cmd:holrein} for the same purpose. Both programs provide the same
function than there predecessors but with a simplified syntax.
{p_end}

{pstd}The programs create SOEP datasets with the variables of the
varlist. {cmd:soepuse} generates a new file and {cmd:soepadd} merges
further variables to a file generated with {cmd:soepuse}.  By default,
the created files will have a balanced panel design, but various
other designs could be specified.{p_end}

{pstd} {cmd:soepuse} and {cmd:soepadd} both require that the variables
to be loaded are specified in the order of the item correspondence
list and that variables all belong to the same file-type. Here is an
example: To combine individual gross and net income variables with
household income using the waves of 1991 and 1992 you would specify
{p_end}

{phang2}{cmd:. soepuse hp5401 ip5401 hp5402 ip5402 using ~/data/gsoep24, f(p) w(1991 1992)}{p_end}
{phang2}{cmd:. soepadd hh49 ih49, f(h) w(1991 1992)}
{p_end}

{pstd} or in a format that highlights better the requested format of
the variable list:
{p_end}

{p 8 8 0}{cmd:. soepuse }{p_end}
{p 12 12 0}{cmd:hp5401 ip5401 }{p_end}
{p 12 12 0}{cmd:hp5402 ip5402 }{p_end}
{p 10 10 0}{cmd:using ~/data/gsoep24, f(p) w(1991 1992) }{p_end}

{pstd}{cmd:soepuse} and {cmd:soepadd} are constructed for using them
in connection with
{browse "http://panel.gsoep.de/soepinfo2007/":SOEPinfo}. Consider you have
been searching the GSOEP database with SOEPinfo for information on
political interest and party identification from 1984 to 1998. After
founding that information you have stored SOEPinfo's item correspondence
list to a file, which looks like this: 
{p_end}

        -----------------------------------------------------------
        1984     |1985     |1986     |1987     |1988     |1989
        -----------------------------------------------------------
        Politik
        Politisches Interesse
        -        |BP75     |CP75     |DP84     |EP73     |FP89
        Politik
        Allgemeine Parteienpraeferenz
        AP5601   |BP7901   |CP7901   |DP8801   |EP7701   |FP9301
        Politik
        Parteienidentifikation
        AP5602   |BP7902   |CP7902   |DP8802   |EP7702   |FP9302

{pstd}After cutting pipes and headings, and changing uppercase to
lowercase you end up with
{p_end}

        -      bp75   cp75   dp84   ep73   fp89
        ap5601 bp7901 cp7901 dp8801 ep7701 fp9301
        ap5602 bp7902 cp7902 dp8802 ep7702 fp9302

{pstd} which is the structure requested by {cmd:soepuse} and
{cmd:soepadd}. Take care not to erase the {hilite:-} sign for the
missing variable name in the first row.  {cmd:soepuse} and
{cmd:soepadd} needs this as a placeholder whenever a variable is
missing in the item correspondence.{p_end}

{pstd}The entire {cmd:soepuse} command to load all variables of
the example will become{p_end}

{p 8 8 0}{cmd:. soepuse }{p_end}
{p 12 12 0}{cmd:- bp75 cp75 dp84 ep73 fp89}{p_end}
{p 12 12 0}{cmd:ap5601 bp7901 cp7901 dp8801 ep7701 fp9301}{p_end}
{p 12 12 0}{cmd:ap5602 bp7902 cp7902 dp8802 ep7702 fp9302}{p_end}
{p 10 10 0}{cmd:using ~/data/gsoep24, f(p) w(1991/1998) }{p_end}

{title:Options}

{phang}{cmdab:f:typ(}{it:string}{cmd:)} is used to specify the type of
the GSOEP data sets in which the variables to be loaded are stored. As
it stands this can be any of the following types. Note that you can
only specify one filetype add a time. Use {cmd:soepadd} to add
variables of further filetypes.{p_end}

{p2colset 8 20 8 20} {p2line}
{p2col:{cmd:h}} Household data{p_end}
{p2col:{cmd:hbrutto}} Gross information on household{p_end}
{p2col:{cmd:hgen}} Household data, generated variables{p_end}
{p2col:{cmd:kind}} child information{p_end}
{p2col:{cmd:p}} Person data{p_end}
{p2col:{cmd:pausl}} Person files for foreigners {p_end}
{p2col:{cmd:pbrutto}} Gross information on persons{p_end}
{p2col:{cmd:pequiv}} PSID equivalence files{p_end}
{p2col:{cmd:pgen}}Person data, generated variables{p_end}
{p2col:{cmd:pkal}} Person calendar files{p_end}
{p2col:{cmd:pluecke}} Retrospective question to fill gaps{p_end}
{p2line}

{phang}{cmdab:w:aves(}{help numlist}{cmd:)} is used to specify the
waves from which the variables out to be taken. {cmd:waves(1984/2002)}
is used if the variable names correspond to files for all waves from
1984 to 2002. Likewise {cmd:waves(1985(5)2005)} is used if variable
names correspond to waves of 1985, 1990, ... 2005. See
 help {help numlist} for various ways to specify the list of waves. 

{phang}{cmd:design(designtype)} specifies the design of the dataset to
be created. {cmd:design(balanced)} is used to create a balanced panel
design, i.e. the data will contain only observations interviewed in
all requested waves. {cmd:design(any)} will keep all available
observations in the dataset. {cmd:design(#)} with # being an integer
positive number creates datasets with respondents interviewed at least
# times. With {cmd:design(any)} and {cmd:design(#)} the netto
variables from ppfad will be retained in the data set for further fine
tuning of the design.  {p_end}

{phang}{cmd:clear} specifies that it is okay to replace the data in
memory, even though the current data have not been saved to disk.
{p_end}

{phang}{cmd:ost(g|h)} must be specified, if your list of variable
names contains names from specialized files for East Germany of years
1990 and 1991. Specify {cmd:ost(g)} if you have used either names from
gpost or gpkalost, {cmd:ost(h)} if you have used either names from
hpost or hpkalost and {cmd:ost(g h)} if you have used some specialized
East-files of both waves.{p_end}

{phang}{cmd: onlyost} must be specified if you variable names
contains only names from the specialized files for East Germany. 
{p_end}

{phang}{cmd: oldnetto} must be used if you are working with an old
version of the GSOEP database, i.e. with an version where the
variables anetto, bnetto ... znetto in the dataset ppfad have the
value 1 for interviews. {p_end}

{phang}{cmd: uc} must be used if the variable list is upper
cased. This is helpful if you don't have a decent text editor that is
capable to lower-case the upper-cased variable names from SOEPinfo.
{p_end}

{phang}{cmd: fast} speeds up the retrieval. By default, {soepuse} and
{soepadd} do some extra work to check whether the variable names make
sense. This helps debugging lengthy list, but takes some time,
especially if the GSOEP data is stored on a slow network drive. Option
fast bypasses the additional check of variable names. {p_end}

{title:Example(s)}

{pstd}Constructing Longitudinal Individual Records{p_end}
{phang2}{cmd:. soepuse gp109 zp6401 hp10901 ip10901 jp10901 using ., ost(g) w(1990/1993) f(p)}{p_end}

{pstd}Linking Household Data to Individuals{p_end}
{phang2}{cmd:. soepuse hp5401 hp5402 using ., w(1991) f(p)}{p_end}
{phang2}{cmd:. soepadd hh48, w(1991) f(h)}{p_end}

{pstd}Linking Houshold Data to Individuals Across Waves{p_end}
{phang2}{cmd:. soepuse hp5401 ip5401 hp5402 ip5402 using ., w(1991/1992) f(p)}{p_end}
{phang2}{cmd:. soepadd hh48 ih49, w(1991/1992) f(h)}{p_end}

{pstd}Houshold Level Variables from Individual Data{p_end}
{phang2}{cmd:. soepuse hp07 hp15 using ., f(p) w(1991)}{p_end}
{phang2}{cmd:. gen ft=1 if hp15==1}{p_end}
{phang2}{cmd:. gen pt=1 if hp15==2}{p_end}
{phang2}{cmd:. gen unemp=1 if hp07==1}{p_end}
{phang2}{cmd:. gen noinf=1 if hp15==9}{p_end}
{phang2}{cmd:. collapse (count) n_ft=ft n_pt=pt n_unemp=unemp n_noinf=noinf (mean) hhnr=hhnr, by(hhnr)}{p_end}
{phang2}{cmd:. soepadd htyphh1 htyphh2, w(1991) f(hgen)}{p_end}

{pstd}Creating longitudinal data from waves 1984-2006 with vars from different sources{p_end}
{p 4 4 0}{cmd:. soepuse}{p_end}
{p 8 4 0}{cmd:afamstd bfamstd cfamstd dfamstd efamstd ffamstd gfamstd hfamstd}{p_end}
{p 8 4 0}{cmd:ifamstd jfamstd kfamstd lfamstd mfamstd nfamstd ofamstd pfamstd}{p_end}
{p 8 4 0}{cmd:qfamstd rfamstd sfamstd tfamstd ufamstd vfamstd}{p_end}
{p 8 4 0}{cmd:egp84 egp85 egp86 egp87 egp88 egp89 egp90 egp91 egp92 egp93 egp94}{p_end}
{p 8 4 0}{cmd:egp95 egp96 egp97 egp98 egp99 egp00 egp01 egp02 egp03 egp04 egp05}{p_end}
{p 8 4 0}{cmd:using . ,}{p_end}
{p 8 4 0}{cmd:ftyp(pgen) waves(1984/2005)}{p_end}
{p 8 4 0}{cmd:design(3) keep(sex gebjahr) clear}{p_end}

{p 4 4 0}{cmd:. soepadd}{p_end}
{p 8 4 0}{cmd:ap6801 bp9301 cp9601 dp9801 ep89 fp108 gp109 hp10901}{p_end}
{p 8 4 0}{cmd:ip10901 jp10901 kp10401 lp10401 mp11001 np11701 op12301}{p_end}
{p 8 4 0}{cmd:pp13501 qp14301 rp13501 sp13501 tp14201 up14501 vp154}{p_end}
{p 8 4 0}{cmd:, ftyp(p) waves(1984/2005)}{p_end}

{p 4 4 0}{cmd:. soepadd}{p_end}
{p 8 4 0}{cmd:i1110284 i1110285 i1110286 i1110287 i1110288 i1110289 i1110290}{p_end}
{p 8 4 0}{cmd:i1110291 i1110292 i1110293 i1110294 i1110295 i1110296 i1110297}{p_end}
{p 8 4 0}{cmd:i1110298 i1110299 i1110200 i1110201 i1110202 i1110203 i1110204}{p_end}
{p 8 4 0}{cmd:i1110205}{p_end}
{p 8 4 0}{cmd:e1110184 e1110185 e1110186 e1110187 e1110188 e1110189 e1110190}{p_end}
{p 8 4 0}{cmd:e1110191 e1110192 e1110193 e1110194 e1110195 e1110196 e1110197}{p_end}
{p 8 4 0}{cmd:e1110198 e1110199 e1110100 e1110101 e1110102 e1110103 e1110104}{p_end}
{p 8 4 0}{cmd:e1110105}{p_end}
{p 8 4 0}{cmd:,  ftyp(pequiv) waves(1984/2005)}{p_end}

{title:Note}

{pstd}{cmd:soepuse} and {cmd:soepadd} are two little unambitious
helper programs. A far more advanced Stata program for working with
the GSOEP and many other panel data sets is
{browse "http://www.panelwhiz.eu":PanelWhiz} by John Haisken DeNew.  {p_end}


{title:Author}

{pstd}Ulrich Kohler, WZB, kohler@wzb.eu{p_end}

{title:Also see}

{psee} Online: {help soepren} (if installed), {help rgroup} (if
installed), {help soepdo} (if installed) {p_end}

