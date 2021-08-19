cap program drop motivatedolly 
program define motivatedolly 
version 14.0 


syntax [,  debug persevere pers regroup angry girlpower girlp mrt gohome advanced adv]

if "`debug'" == "debug" {
  local opt "debug"
}
if "`persevere'" == "persevere" | "`pers'" == "pers" {
  local opt "persevere"
}
if "`regroup'" == "regroup" {
  local opt "regroup"
}
if "`angry'" == "angry" {
  local opt "angry"
}
if "`gohome'" == "gohome" {
  local opt "gohome"
}
if "`mrt'" == "mrt" | "`girlpower'" == "girlpower" |"`girlp'" == "girlp" {
  local opt "mrt"
}
if "`advanced'" == "advanced" | "`adv'" == "adv" {
  local opt "advanced"
}

local x = runiform()

if "`opt'" == "" {

  local count = 16

  forv n = 1/`count'{
     local m = `n' - 1 
     local n`n'_a = 0 + ((`m'*(100/`count'))/100)
  
     local n`n'_b = 0 + ((`n'*(100/`count'))/100)
  }

   if `x'>`n1_a' & `x'<=`n1_b'  {
      di as txt  "{c 39}Storms make trees take deeper roots.{c 39}"
      di as txt  " "            
      di as txt  "                                            Dolly Parton"
      exit
    }
   
   if `x'>`n2_a' & `x'<=`n2_b'  {
      di as txt  "{c 39}If you don't like the road you're walking, start paving another one.{c 39}"
      di as txt  " "            
      di as txt  "                                            Dolly Parton"
      exit
    }
   
   if `x'>`n3_a' & `x'<=`n3_b'  {
      di as txt  "{c 39}We cannot direct the wind, but we can adjust the sails.{c 39}"
      di as txt  " "            
      di as txt  "                                            Dolly Parton"
      exit
    }
   
   if `x'>`n4_a' & `x'<=`n4_b'  {
      di as txt  "{c 39}You'll never do a whole lot unless you're brave enough to try.{c 39}"
      di as txt  " "            
      di as txt  "                                            Dolly Parton"
      exit
    }
   
   
   if `x'>`n5_a' & `x'<=`n5_b'  {
      di as txt  "{c 39}I’ve had heartaches, headaches, toothaches, earaches, and I’ve had a few pains in the ass,"
      di as txt  "but I’ve survived to tell about it.{c 39}"
      di as txt  " "            
      di as txt  "                                            Dolly Parton"
      exit
    }
   
   if `x'>`n6_a' & `x'<=`n6_b'  {
      di as txt  "{c 39}I wasted my tears went I cried over you{c 39}"
      di as txt  " "
      di as smcl "{ralign 56:{browse  "`"www.youtube.com/watch?v=b6Z8AJ7Ud5o:Dolly Parton, 1967}}"'
      exit
    }
   
   if `x'>`n7_a' & `x'<=`n7_b'  {
      di as txt  "{c 39}I think there's something fishy goin' on.{c 39}"
      di as txt  " "      
      di as smcl "{ralign 56:{browse  "`"www.youtube.com/watch?v=G2KcKFBTKl4:Dolly Parton, 1967}}"'
      exit
    }
   if `x'>`n8_a' & `x'<=`n8_b'  {
      di as txt  "{c 39}It ain't fair that is ain't right.{c 39}"
      di as txt  " "
      di as smcl "{ralign 56:{browse  "`"www.youtube.com/watch?v=ouybfd4GBZM:Dolly Parton, 1971}}"'
      exit
    }    
   if `x'>`n9_a' & `x'<=`n9_b'  {
      di as txt  "{c 39}If you don't mind the fact that all the merchandise is used"
      di as txt  "...with a little mendin' it could be as good as new{c 39}"
      di as txt  " "      
      di as smcl "{ralign 56:{browse  "`"www.youtube.com/watch?v=WtTnJ9GuVEM:Dolly Parton, 1975}}"'
      exit
    }    
   if `x'>`n10_a' & `x'<=`n10_b'  {
      di as txt  "{c 39}I'm a little bit slow to catch on, but when I do I'm caught on.{c 39}"
      di as txt  " "      
      di as smcl "{ralign 56:{browse  "`"www.youtube.com/watch?v=6dPEOrsryoQ:Dolly Parton, 1968}}"'
      exit
    }    
   if `x'>`n11_a' & `x'<=`n11_b'  {
      di as txt  "{c 39}Each new love I find"
      di as txt  "Turns out to be the wrong kind"
      di as txt  "And it looks like I'll"
      di as txt  "Just have to love and learn{c 39}"
      di as smcl "{ralign 56:{browse  "`"www.youtube.com/watch?v=hlPfIk1p0es:Dolly Parton, 1968}}"'
      exit
    } 
   if `x'>`n12_a' & `x'<=`n12_b'  {
      di as txt  "{c 39}I'm not going to limit myself just because people won't accept the fact that I can do something else.{c 39}"
      di as txt  " "            
      di as txt  "                                            Dolly Parton"
      exit
    }     
   if `x'>`n13_a' & `x'<=`n13_b'  {
      di as txt  "{c 39}Yes, I've made my mistakes"
      di as txt  "But listen and understand"
      di as txt  "My mistakes are no worse than yours"
      di as txt  "Just because I'm a woman{c 39}"
      di as txt  "  "
      di as smcl "{ralign 56:{browse  "`"www.youtube.com/watch?v=CjKaoM4zmMg:Dolly Parton, 1968}}"'
      exit
    }        
   if `x'>`n14_a' & `x'<=`n14_b'  {
      di as txt  "{c 39}I think I'll dry these useless tears"
      di as txt  "And get myself together"
      di as txt  "I think I'll wander down the hall"
      di as txt  "And have a look around"
      di as txt  "'Cause I can't stay inside"
      di as txt  "This lonely room and cry forever"
      di as txt  "I think I really rather join 'em"           
      di as txt  "Two doors down{c 39}"
      di as txt  " "
      di as smcl "{ralign 56:{browse "`"www.youtube.com/watch?v=oodPqrjwNQc:Dolly Parton, 1977}}"'
      exit
    }    
   if `x'>`n15_a' & `x'<=`n15_b'  {
      di as txt  "{c 39}Well, I'm not the Dalai Lama, but I'll try to offer up a few words of advice"
      di as txt  "You better stop whining, pining"
      di as txt  "Get your dreams in line"
      di as txt  "And then just shine, design, refine"
      di as txt  "Until they come true{c 39}"
      di as smcl "{ralign 56:{browse  "`"www.youtube.com/watch?v=MKeulwZ3sGE:Dolly Parton, 2008}}"'
      exit
    }  
   if `x'>`n16_a' & `x'<=`n16_b'  {       
      di as txt  "{c 39}Find out who you are and do it on purpose.{c 39}"
      di as txt  " "      
      di as smcl "{ralign 56:Referenced in: {browse  "`"www.youtube.com/watch?v=UdNg_EBF1cM:Jolene Remix from Dumplin'}}"'
      exit   
    }
}

if "`opt'" == "debug" {
  local count = 3 

  forv n = 1/`count'{
     local m = `n' - 1 
     local n`n'_a = 0 + ((`m'*(100/`count'))/100)
  
     local n`n'_b = 0 + ((`n'*(100/`count'))/100)
  }
/* SLEUTHING  */
   if `x'>`n1_a' & `x'<=`n1_b'  {
      di as txt  "{c 39}Each new love I find"
      di as txt  "Turns out to be the wrong kind"
      di as txt  "And it looks like I'll"
      di as txt  "Just have to love and learn{c 39}"
      di as smcl "{ralign 56:{browse  "`"www.youtube.com/watch?v=hlPfIk1p0es:Dolly Parton, 1968}}"'
      exit
    } 

   if `x'>`n2_a' & `x'<=`n2_b'  {
      di as txt  "{c 39}I'm a little bit slow to catch on, but when I do I'm caught on.{c 39}"
      di as txt  " "      
      di as smcl "{ralign 56:{browse  "`"www.youtube.com/watch?v=6dPEOrsryoQ:Dolly Parton, 1968}}"'
      exit
      exit
    }   
   if `x'>`n3_a' & `x'<=`n3_b'  {
      di as txt  "{c 39}I think there's something fishy goin' on.{c 39}"
      di as txt  " "      
      di as smcl "{ralign 56:{browse  "`"www.youtube.com/watch?v=G2KcKFBTKl4:Dolly Parton, 1967}}"'
      exit
    }
}

/* persevere  */
if "`opt'" == "persevere" {

  local count = 9 

  forv n = 1/`count'{
     local m = `n' - 1 
     local n`n'_a = 0 + ((`m'*(100/`count'))/100)
  
     local n`n'_b = 0 + ((`n'*(100/`count'))/100)
  }

   if `x'>`n1_a' & `x'<=`n1_b'  {
      di as txt  "{c 39}Storms make trees take deeper roots.{c 39}"
      di as txt  " "            
      di as txt  "                                            Dolly Parton"
      exit
    }
   if `x'>`n2_a' & `x'<=`n2_b'  {
      di as txt  "{c 39}You'll never do a whole lot unless you're brave enough to try.{c 39}"
      di as txt  " "            
      di as txt  "                                            Dolly Parton"
      exit
    }
   if `x'>`n3_a' & `x'<=`n3_b'  {
      di as txt  "{c 39}I’ve had heartaches, headaches, toothaches, earaches, and I’ve had a few pains in the ass,"
      di as txt "but I’ve survived to tell about it.{c 39}"
      di as txt  " "            
      di as txt  "                                            Dolly Parton"
      exit
    }
   
   if `x'>`n4_a' & `x'<=`n4_b'  {
      di as txt  "{c 39}I wasted my tears went I cried over you{c 39}"
      di as txt  " "      
      di as smcl "{ralign 56:{browse  "`"www.youtube.com/watch?v=SpKY7RyEG_Y:Dolly Parton, 1967}}"'
      exit
    }
   if `x'>`n5_a' & `x'<=`n5_b'  {
      di as txt  "{c 39}If you don't mind the fact that all the merchandise is used"
      di as txt  "...with a little mendin' it could be as good as new{c 39}"
      di as txt  " "      
      di as smcl "{ralign 56:{browse  "`"www.youtube.com/watch?v=WtTnJ9GuVEM:Dolly Parton, 1975}}"'
      exit
    } 
   if `x'>`n6_a' & `x'<=`n6_b'  {
      di as txt  "{c 39}I'm a little bit slow to catch on, but when I do I'm caught on.{c 39}"
      di as txt  " "      
      di as smcl "{ralign 56:{browse  "`"www.youtube.com/watch?v=6dPEOrsryoQ:Dolly Parton, 1968}}"'
      exit
    }  
   if `x'>`n7_a' & `x'<=`n7_b'  {
      di as txt  "{c 39}Each new love I find"
      di as txt  "Turns out to be the wrong kind"
      di as txt  "And it looks like I'll"
      di as txt  "Just have to love and learn{c 39}"
      di as smcl "{ralign 56:{browse  "`"www.youtube.com/watch?v=hlPfIk1p0es:Dolly Parton, 1968}}"'
      exit
    } 
   if `x'>`n8_a' & `x'<=`n8_b'  {
      di as txt  "{c 39}I'm not going to limit myself just because people won't accept the fact that I can do something else.{c 39}"
      di as txt  " "            
      di as txt  "                                            Dolly Parton"
      exit
    }  
   if `x'>`n9_a' & `x'<=`n9_b'  {
      di as txt  "{c 39}Well, I'm not the Dalai Lama, but I'll try to offer up a few words of advice"
      di as txt  "You better stop whining, pining"
      di as txt  "Get your dreams in line"
      di as txt  "And then just shine, design, refine"
      di as txt  "Until they come true{c 39}"
      di as smcl "{ralign 56:{browse  "`"www.youtube.com/watch?v=MKeulwZ3sGE:Dolly Parton, 2008}}"'
      exit
    }     

}



/*  regroup  */
 if "`opt'" == "regroup" {
  local count = 8 

  forv n = 1/`count'{
     local m = `n' - 1 
     local n`n'_a = 0 + ((`m'*(100/`count'))/100)
  
     local n`n'_b = 0 + ((`n'*(100/`count'))/100)
  }

   if `x'>`n1_a' & `x'<=`n1_b'  {
      di as txt  "{c 39}If you don't like the road you're walking, start paving another one.{c 39}"
      di as txt  " "            
      di as txt  "                                            Dolly Parton"
      exit
    }
   
   if `x'>`n2_a' & `x'<=`n2_b'  {
      di as txt  "{c 39}We cannot direct the wind, but we can adjust the sails.{c 39}"
      di as txt  " "            
      di as txt  "                                            Dolly Parton"
      exit
    }
   if `x'>`n3_a' & `x'<=`n3_b'  {
      di as txt  "{c 39}I’ve had heartaches, headaches, toothaches, earaches, "
      di as txt  "and I’ve had a few pains in the ass, but I’ve survived to tell about it.{c 39}"
      di as txt  " "            
      di as txt  "                                            Dolly Parton"
      exit
    }
   if `x'>`n4_a' & `x'<=`n4_b'  {
      di as txt  "{c 39}I wasted my tears went I cried over you{c 39}"
      di as txt  " "      
      di as smcl "{ralign 56:{browse  "`"www.youtube.com/watch?v=SpKY7RyEG_Y:Dolly Parton, 1967}}"'
      exit
    }
   
   if `x'>`n5_a' & `x'<=`n5_b'  {
      di as txt  "{c 39}I think there's something fishy goin' on.{c 39}"
      di as txt  " "      
      di as smcl "{ralign 56:{browse  "`"www.youtube.com/watch?v=G2KcKFBTKl4:Dolly Parton, 1967}}"'
      exit
    }
   if `x'>`n6_a' & `x'<=`n6_b'  {
      di as txt  "{c 39}If you don't mind the fact that all the merchandise is used"
      di as txt  "...with a little mendin' it could be as good as new{c 39}"
      di as txt  " "      
      di as smcl "{ralign 56:{browse  "`"www.youtube.com/watch?v=WtTnJ9GuVEM:Dolly Parton, 1975}}"'
      exit
    }    
   if `x'>`n7_a' & `x'<=`n7_b'  {
      di as txt  "{c 39}I'm a little bit slow to catch on, but when I do I'm caught on.{c 39}"
      di as txt  " "      
      di as smcl "{ralign 56:{browse  "`"www.youtube.com/watch?v=6dPEOrsryoQ:Dolly Parton, 1968}}"'
      exit
    }  
   if `x'>`n8_a' & `x'<=`n8_b'  {
      di as txt  "{c 39}Find out who you are and do it on purpose.{c 39}"
      di as txt  " "      
      di as smcl "{ralign 56:Referenced in: {browse  "`"www.youtube.com/watch?v=UdNg_EBF1cM:Jolene Remix from Dumplin'}}"'
      exit
    }      
} 
/* angry  */

 if "`opt'" == "angry" {
  local count = 3

  forv n = 1/`count'{
     local m = `n' - 1 
     local n`n'_a = 0 + ((`m'*(100/`count'))/100)
  
     local n`n'_b = 0 + ((`n'*(100/`count'))/100)
  }
 if `x'>`n1_a' & `x'<=`n1_b'  {
      di as txt  "{c 39}I wasted my tears went I cried over you{c 39}"
      di as txt  " "
      di as smcl "{ralign 56:{browse  "`"www.youtube.com/watch?v=b6Z8AJ7Ud5o:Dolly Parton, 1967}}"'
      exit
    }
 if `x'>`n2_a' & `x'<=`n2_b'  {
      di as txt  "{c 39}It ain't fair that is ain't right.{c 39}"
      di as txt  " "
      di as smcl "{ralign 56:{browse  "`"www.youtube.com/watch?v=ouybfd4GBZM:Dolly Parton, 1971}}"'
      exit
    }  
 if `x'>`n3_a' & `x'<=`n3_b'  {
      di as txt  "{c 39}They just use your mind and they never give you credit"
      di as txt  "It's enough to drive you crazy if you let it{c 39}"
      di as txt  " "
      di as smcl "{ralign 56:{browse  "`"www.youtube.com/watch?v=UbxUSsFXYo4:Dolly Parton, 1980}}"'
      exit
    }    
}

 if "`opt'" == "gohome" {
  local count = 2

  forv n = 1/`count'{
     local m = `n' - 1 
     local n`n'_a = 0 + ((`m'*(100/`count'))/100)
  
     local n`n'_b = 0 + ((`n'*(100/`count'))/100)
  } 
 if `x'>`n1_a' & `x'<=`n1_b'  {
      di as txt  "{c 39}Put it off until tomorrow..."
      di as text "You've hurt me enough today{c 39}"
      di as txt  " "
      di as smcl "{ralign 56:{browse  "`"www.youtube.com/watch?v=ouybfd4GBZM:Dolly Parton, 1967}}"' 
    }   
   if `x'>`n2_a' & `x'<=`n2_b'  {
      di as txt  "{c 39}I think I'll dry these useless tears"
      di as txt  "And get myself together"
      di as txt  "I think I'll wander down the hall"
      di as txt  "And have a look around"
      di as txt  "'Cause I can't stay inside"
      di as txt  "This lonely room and cry forever"
      di as txt  "I think I really rather join 'em"           
      di as txt  "Two doors down{c 39}"
      di as txt  " "
      di as smcl "{ralign 56:{browse  "`"www.youtube.com/watch?v=oodPqrjwNQc:Dolly Parton, 1977}}"'
      exit
    }            
} 
 
 if "`opt'" == "advanced" {
  local count = 1

  forv n = 1/`count'{
     local m = `n' - 1 
     local n`n'_a = 0 + ((`m'*(100/`count'))/100)
  
     local n`n'_b = 0 + ((`n'*(100/`count'))/100)
  } 
 if `x'>`n1_a' & `x'<=`n1_b'  {
      di as txt  "Watch Dolly read {it:The Little Engine That Could} and tell yourself that you think you can!"
      di as txt  " "
      di as smcl "{ralign 56:{browse  "`"www.youtube.com/watch?v=tT9fv_ELbnE:Goodnight with Dolly | Episode 1}}"' 
    }         
}  

/* FOR THE LADIES */    

 if "`opt'" == "mrt" {
  local count = 3

  forv n = 1/`count'{
     local m = `n' - 1 
     local n`n'_a = 0 + ((`m'*(100/`count'))/100)
  
     local n`n'_b = 0 + ((`n'*(100/`count'))/100)
  } 
 if `x'>`n1_a' & `x'<=`n1_b'  {
      di as txt  "{c 39}Yes, I've made my mistakes"
      di as txt  "But listen and understand"
      di as txt  "My mistakes are no worse than yours"
      di as txt  "Just because I'm a woman{c 39}"
      di as txt  "  "
      di as smcl "{ralign 56:{browse  "`"www.youtube.com/watch?v=CjKaoM4zmMg:Dolly Parton, 1968}}"'
      exit 
    }   
 if `x'>`n2_a' & `x'<=`n2_b'  {    
    di as txt  "{c 39}Your woman's gettin' tired of being your ole handy man"
    di as txt  "Now I know you got ten fingers"
    di as txt  "But where's that helpin' hand"
    di as txt  "I've just made a decision"
    di as txt  "I've stood all I'm gonna stand"
    di as txt  "Your woman's gettin' tired of being your ole handy man.{c 39}"
    di as txt  "  "
    di as smcl "{ralign 56:{browse  "`"www.youtube.com/watch?v=BpehKYTa4Tw:Dolly Parton, 1967}}"'
    exit     
  }
 if `x'>`n3_a' & `x'<=`n3_b'  {    
    di as txt  "{c 39}They said a woman’s place"
    di as txt  "Was staying in her hut"
    di as txt  "Washin’, cookin’ cleanin’"
    di as txt  "Wipin’ babies butts."
    di as txt  "They said she’d never see the day"
    di as txt  "We’d equal up to them"
    di as txt  "But here we are; we’ve come so far"
    di as txt  "I guess we sure showed them.{c 39}"
    di as txt  " "    
    di as smcl "{ralign 56:{browse  "`"www.youtube.com/watch?v=ASx-s0fPzK4:Dolly Parton, 2018}}"'
    exit     
  }
}  

end





