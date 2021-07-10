# 压缩所有的 Stata 命令
library(tidyverse)
library(fs)
for(i in dir_ls('ssc')){
  j = str_remove(i, "ssc/")
  if(!file_exists(paste0("ssczip/", j, ".zip"))){
    zip(paste0("ssczip/", j, ".zip"), i) 
  }
}

# 获取 Stata 的简介
info <- function(cmd){
  print(cmd)
  readLines(paste0('ssc/', cmd, '/', cmd, '.pkg'))[1]
}

library(purrr)
dir_info('ssc') %>% 
  as_tibble() %>% 
  transmute(path = as.character(path) %>% 
              str_remove("ssc/")) %>% 
  mutate(info = map_chr(path, info)) -> infodf

infodf %>% 
  mutate(info = str_extract(info, ":\\s(.*)"),
         info = str_remove(info, ":\\s")) %>% 
  rename(cmd = path) %>% 
  haven::write_dta("cmdlist.dta")
