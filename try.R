library(fs)
library(tidyverse)
dir_ls('ssc') %>% 
  as_tibble() %>% 
  mutate(value = as.character(value)) %>% 
  mutate(value = str_remove(value, "ssc/")) %>% 
  pull(value) -> have

length(have)

# 更新的
haven::read_dta('sschotPPPcur.dta') %>% 
  mutate(value = str_to_lower(package)) %>% 
  distinct(value) %>% 
  pull(value) -> all

# 没有的
library(hotkeys)

all %w/o% have
