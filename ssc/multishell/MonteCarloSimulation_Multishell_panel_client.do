**Please change paths

clear all
adopath ++ "YOUR PATH\multishell\ado\"
multishell path "YOUR PATH\output" 
multishell exepath "YOUR PATH\Stata14\StataSE-64.exe" 
multishell adopath "YOUR PATH\multishell\ado\"
multishell alttext "PATH1 @ W:\YOUR PATH" 

multishell run client, threads(6) sleep(2000)
