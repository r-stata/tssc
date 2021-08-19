{smcl}
{right:version 1.0}
{title:Title}

{phang}
{cmd:gitee} {hline 2} install, and uninstall Stata packages from 
{browse "http://www.gitee.com":Gitee} website
 

{title:Syntax}

{p 8 16 2}
{cmd: gitee} {help gitee##subcommand:{it:subcommand}}  {it:username/repository[/subfolder]}  [{cmd:,} replace force]
{p_end}


{p 8 16 2}
{cmd: gitee} {help gitee##subcommand:{it:subcommand}}  [{it:packagename}]{cmd:,} from({it:directory_or_url}) [replace force]
{p_end}

{p 4 4 2}
The {bf:gitee} command takes two subcommands:

{marker subcommand}{...}
{synoptset 20 tabbed}{...}
{synopthdr:subcommand}
{synoptline}
{synopt:{opt install}}installs the specified repository. The command should be 
followed by the {bf:username/repository}{p_end}
{synopt:{opt uninstall}}uninstalls a package{p_end}

{synoptline}
{p2colreset}{...}


{title:Options}

{p 4 4 2}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}

{synopt:{opt replace}}specifies that the downloaded files replace existing 
files if any of the files already exists.{p_end}

{synopt:{opt force}}specifies that the downloaded files replace existing 
files if any of the files already exists, even if Stata thinks all the files 
are the same.  force implies replace.{p_end}

{synopt:{opt from(directory_or_url)}}specifies the directory or URL where installable packages 
may be found.{p_end} 

{synoptline}
{p2colreset}{...}



{title:Example(s)}

{p 4 4 2}

    install the gtfpch package from Gitee
        . gitee install arlionn/gtfpch
		
	or
	
        . gitee install gtfpch, from(https://gitee.com/arlionn/gtfpch?_from=gitee_search)	
                
    Uninstall gtfpch repository
        . gitee uninstall gtfpch
                


{title:Author}

{p 4 4 2}
Kerry Du     {break}
Xiamen University      {break}
Email:kerrydu@xmu.edu.cn     {break}
