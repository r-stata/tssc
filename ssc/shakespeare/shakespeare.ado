program shakespeare
version 9

syntax
local x = runiform()


if `x'<=0.02  {
   di as txt  " To be, or not to be: that is the question "
   di as txt  " Hamlet, Act 3, Scene 1 "
   exit
 }

if `x'>0.02 & `x'<=0.04 {
   di as txt  " All the world's a stage, and all the men and women merely players." 
   di as txt  " They have their exits and their entrances. "
   di as txt  " And one man in his time plays many parts "
   di as txt  " As you like it, Act 2, Scene 7 "
   exit
 }

if `x'>0.04 & `x'<=0.06 {
   di as txt  " 'Romeo, Romeo! Wherefore art thou Romeo?'"
   di as txt  " Romeo & Juliet, Act 2 , Scene 2  "
      exit
 }

if `x'>0.06 & `x'<=0.08 {
   di as txt  " 'Now is the winter of our discontent' "
   di as text "  Richard III, Act 1, Scene 1 "
    exit
 }


if `x'>0.08 & `x'<=0.10 {
   di as txt  " 'Is this a dagger, which I see before me?' "
   di as txt  "  Macbeth, Act 2 , Scene 1         "
   exit
 }

if `x'>0.10 & `x'<=0.12 {
   di as txt  " 'The lady doth protest too much, methinks' "
   di as txt  "   Hamlet, Act 3, Scene 2     "
   exit
 }

if `x'>0.12 & `x'<=0.14 {
   di as txt  " 'Beware the Ides of March' "
   di as txt  "  Julius Caesar, Act 1 , Scene 2  "
   exit
 }

if `x'>0.14 & `x'<=0.16 {
   di as txt  " 'Get thee to a nunnery' "
   di as txt  " Hamlet, Act 3 , Scene 1 "
   exit
 }

if `x'>0.16 & `x'<=0.18 {
   di as txt  " If music be the food of love, play on "
   di as txt  "  Twelfth Night, Act 1 , Scene 3 "
   exit
 }

if `x'>0.18 & `x'<=0.20 {
   di as txt  " 'What's in a name? A rose by any other name would smell just as sweet' "
   di as txt  " Romeo & Juliet, Act 2, Scene 2   "
     exit
 }

if `x'>0.20 & `x'<=0.22 {
   di as txt  " 'The better part of valor is discretion' "
   di as txt " Henry IV, Part 1, Act 5, Scene 4 "
    exit
 }

if `x'>0.22 & `x'<=0.24 {
   di as txt  " 'To thine own self be true' "
   di as txt " Hamlet Act 1 , Scene 3 "
      exit
 }

if `x'>0.24 & `x'<=0.26 {
   di as txt  " 'All that glitters is not gold' "
   di as txt " The Merchant of Venice, Act 2 , Scene 7"
   exit
 }

if `x'>0.26 & `x'<=0.27 {
   di as txt  " 'Love looks not with the eyes, but with the mind; and therefore is winged Cupid painted blind' "
   di as txt " A Midsummer Nights Dream, Act 1, Scene 1 "
    exit
 }
 
if `x'>0.27 & `x'<=0.29 {
   di as txt  " 'Friends, Romans, countrymen, lend me your ears. I come to bury Caesar, not praise him' "
   di as txt  " Julius Caesar, Act 3, Scene 2 "
   exit
 }

if `x'>0.29 & `x'<=0.31 {
   di as txt  " Cry 'Havoc' and let slip the dogs of war"
   di as txt  " Julius Caesar Act 3 Scene 1 "
   exit
 }
if `x'>0.31 & `x'<=0.33 {
   di as txt  " 'A horse, a horse, my Kingdom for a horse' "
   di as txt  " Richard iii, Act 5, Scene 4 "
   exit
 }

if `x'>0.33 & `x'<=0.35 {
   di as txt  " 'There are more things in Heaven and earth than are dreamt of in your philosophy' "
   di as txt " Hamlet, Act1 Scene 5 "
   exit
 }
if `x'>0.57 & `x'<=0.59 {
   di as txt  " 'You don't need a weatherman to know which way the wind blows' "
   di as txt " Subterranean Homesick Blues "
   exit
 }


if `x'>0.36 & `x'<= 0.39 {
   di as txt " 'Shall I compare thee to a summers day? Thou art more lovely and more temperate' "
   di as txt " Sonnet 18 "
   exit
 }

if `x'>0.39 & `x'<=0.41 {
   di as txt  " 'Uneasy lies the head that wears the crown'  "
   di as txt  " Henry IV, Part 2, Act 3, Scene 1 "
   exit
 }
if `x'>0.41 & `x'<=0.43 {
   di as txt  " 'Brevity is the soul of wit' "
   di as txt  " Hamlet Act 2 Scene 2 "
   exit
 }

if `x'>0.43 & `x'<=0.45 {
   di as txt  " 'This royal throne of kings, this sceptred isle: This blessed plot, this earth, this realm, this England' "
   di as txt " Richard II, Act 2, Scene 1 "
   exit
 }

if `x'>0.45 & `x'<=0.47 {
   di as txt  " 'What light through yonder window breaks' "
   di as txt " Romeo and Juliet, Act 2, Scene 2 "
    exit
 }

if `x'>0.47 & `x'<= 0.49 {
   di as txt " 'Some are born great, some achieve greatness, and some have greatness thrust upon them' "
   di as txt " Twelfth Night, Act 2, Scene 5 "
   exit
 }

if `x'>0.49 & `x'<= 0.51 {
   di as txt " 'Cowards die many times before their deaths; the valiant never taste of death but once' "
   di as txt " Julius Caesar Act 2 , Scene 5 "
   exit
 }
 
 if `x'>0.51 & `x'<= 0.53 {
    di as txt " 'Full fathom five thy father lies, of his bones are coral made. ' "
    di as txt " The Tempest, Act 1 , Scene 2 "
    exit
 }
 
 if `x'>0.53 & `x'<= 0.55 {
    di as txt " 'A man can die but once' "
    di as txt " Henry IV, Part 2, Act 3, Scene 2 "
    exit
 }
 
 if `x'>0.55 & `x'<= 0.57 {
    di as txt " 'How sharper than a serpents tooth it is to have a thankless child! ' "
    di as txt " King Lear, Act 1, Scene 4 "
    exit
 }
 
 if `x'>0.35 & `x'<= 0.36 {
    di as txt " 'Fraility, thy name is woman' "
    di as txt " Hamlet, Act 1 , Scene 2 "
    exit
 }
 
 if `x'>0.59 & `x'<= 0.61 {
    di as txt " 'If you prick us, do we not bleed? If you tickle us, do we not laugh?' "
    di as txt " The Merchant of Venice, Act 3 , Scene 1 "
    exit
 }
 
 if `x'>0.61 & `x'<= 0.63 {
    di as txt " 'I am one who loved not wisely but too well' "
    di as txt " Othello, Act 5, Scene 2"
    exit
 }
 
 if `x'>0.63 & `x'<= 0.65 {
    di as txt " 'We are such stuff as dreams are made on, and our little life is rounded with a sleep ' "
    di as txt " The Tempest, Act 4, Scene 1 "
    exit
 }
 
 if `x'>0.65 & `x'<= 0.67 {
    di as txt " ' Life ís but a walking shadow, a poor player, that struts and frets his hour upon the stage, and  "
    di as txt " then is heard no more; it is a tale told by an idiot, full of sound and fury, signifying nothing"
    di as txt " Macbeth , Act 5, Scene 5 "
    exit
 }
 
 if `x'>0.67 & `x'<= 0.69 {
    di as txt " 'To thine own self be true, and it must follow, as the night the day, "
    di as txt " thou canst not then be false to any man ' "
    di as txt " Hamlet, Act 1 , Scene 3"
    exit
 }
 
 if `x'>0.69 & `x'<= 0.71 {
     di as txt " 'Et tu, Brute?' "
     di as txt " Julius Caesar, Act 3, Scene 1"
     exit
  }
  
 if `x'>0.71 & `x'<= 0.73 {
     di as txt " 'There is nothing either good or bad, but thinking makes it so' "
     di as txt " Hamlet, Act 2 , Scene 2"
     exit
  }
 if `x'>0.73 & `x'<= 0.75 {
     di as txt " 'Nothing will come off nothing' "
     di as txt " King Lear, Act 1, Scene 1"
     exit
  }
 if `x'>0.75 & `x'<= 0.77 {
     di as txt " 'The course of true love never did run smooth' "
     di as txt " A Midsummer Nights Dream, Act 1, Scene 1"
     exit
  }
  
 if `x'>0.77 & `x'<= 0.79 {
     di as txt " 'Lord, what fools these mortals be! ' "
     di as txt "A Midsummer Nightís Dream, Act 1, Scene 1 "
     exit
  }
 if `x'>0.79 & `x'<= 0.81 {
     di as txt " 'The fault, dear Brutus, lies not within the stars, but in ourselves, that we are underlings ' "
     di as txt " Hamlet, Act 1 , Scene 3"
     exit
  }
 if `x'>0.81 & `x'<= 0.83 {
     di as txt " To thine own self be true, and it must follow, as the night the day, "
     di as txt " thou canst not then be false to any man  "
     di as txt " Julius Caesar, Act 1, Scene 2"
     exit
  }
 if `x'>0.83 & `x'<= 0.85 {
     di as txt " 'Let me not to the marriage of true minds admit impediments ' "
     di as txt "Sonnet 116"
     exit
  }
 if `x'>0.85 & `x'<= 0.87 {
     di as txt " 'The evil that men do lives after them; The good is oft interred with their bones ' "
     di as txt "Julius Caesar, Act 3, Scene 2 "
     exit
  }
 if `x'>0.87 & `x'<= 0.89 {
     di as txt " 'But, for my own part, it was Greek to me ' "
     di as txt "Julius Caesar, Act 1, Scene 2   "
     exit
  }
 if `x'>0.89 & `x'<= 0.91 {
     di as txt " Neither a borrower nor a lender be; for loan oft loses both itself and friend, "
     di as txt " and borrowing dulls the edge of husbandry.  "
     di as txt " Hamlet, Act 1 , Scene 3"
     exit
  }
 if `x'>0.91 & `x'<= 0.93 {
     di as txt " 'We know what we are, but know not what we may be ' "
     di as txt " Hamlet, Act 4 , Scene 5"
     exit
  }
 if `x'>0.93 & `x'<= 0.95 {
     di as txt " 'Off with his head!' "
     di as txt " Richard III, Act 3, Scene 4"
     exit
  }
 if `x'>0.95 & `x'<= 0.97 {
     di as txt " 'Misery acquaints a man with strange bedfellows ' "
     di as txt " The Tempest, Act 2, Scene 2 "
     exit
  }
 if `x'>0.97 & `x'<= 0.99 {
     di as txt " 'I  am a man more sinned against than sinning ' "
     di as txt " King Lear, Act 3, Scene 2 "
     exit
  }
 if `x'>0.99 & `x'<= 1 {
     di as txt " 'I cannot tell what the dickens his name is ' "
     di as txt " The Merry Wives of Windsor, Act 3, Scene 2 "
     exit
  }
 
end




