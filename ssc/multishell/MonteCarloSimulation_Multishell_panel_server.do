**Please change paths

clear all
adopath ++ "YOUR PATH\multishell\ado\"
multishell path "YOUR PATH\output" 
multishell exepath "YOUR PATH\Stata14\StataSE-64.exe" 
multishell adopath "YOUR PATH\multishell\ado\"
multishell alttext "PATH1 @ W:\YOUR PATH" 
multishell add "YOUR PATH\multishell\MonteCarloSimulation.do" 
multishell add "YOUR PATH\MonteCarloSimulation_panel.do" 
multishell run, threads(2) sleep(2000)
