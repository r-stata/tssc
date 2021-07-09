program motivate
version 10

syntax
local x = runiform()


if `x'<=0.05  {
   di as txt  "{c 39}I find that the harder I work, the more luck I seem to have{c 39}"
   di as txt  "                                            Thomas Jefferson"
   exit
 }

if `x'>0.05 & `x'<=0.10 {
   di as txt  "{c 39}Success is not final, failure is not fatal. It is the courage to continue that counts.{c 39}"
   di as txt  "                                            Winston Churchill"
   exit
 }

if `x'>0.10 & `x'<=0.15 {
   di as txt  "{c 39}If you are going through hell, keep going.{c 39}"
   di as txt  "                                            Winston Churchill"
   exit
 }

if `x'>0.15 & `x'<=0.20 {
   di as txt  "{c 39}Patience and deep breaths are key, but so is Statalist.{c 39}"
   di as txt  "                                            Sara Ansari"
   exit
 }


if `x'>0.20 & `x'<=0.25 {
   di as txt  "{c 39}Maybe Nick Cox has written something about this error?{c 39}"
   di as txt  "                                            Kabira Namit"
   exit
 }

if `x'>0.25 & `x'<=0.30 {
   di as txt  "{c 39}Nothing in the world is worth having or worth doing unless it means effort, pain, difficulty. I have never in my life envied a human being who led an easy life. I have envied a great many people who led difficult lives and led them well.{c 39}"
   di as txt  "                                            Theodore Roosevelt"
   exit
 }

if `x'>0.30 & `x'<=0.35 {
   di as txt  "{c 39}I did not mess up the syntax. I just found 100 ways to specify it incorrectly.{c 39}"
   di as txt  "                                            Kabira Namit"
   exit
 }

if `x'>0.35 & `x'<=0.40 {
   di as txt  "{c 39}It always seems impossible till it is done.{c 39}"
   di as txt  "                                            Nelson Mandela"
   exit
 }

if `x'>0.40 & `x'<=0.45 {
   di as txt  "{c 39}If you were able to believe in Santa Claus for 8 years, you can believe in yourself for 5 minutes.{c 39}"
   di as txt  "                                            Unknown"
   exit
 }

if `x'>0.45 & `x'<=0.50 {
   di as txt  "{c 39}I have failed over and over and over again in my life. And that is why I succeed.{c 39}"
   di as txt  "                                            Michael Jordan"
   exit
 }

if `x'>0.50 & `x'<=0.55 {
   di as txt  "{c 39}Every Stata expert has had their fair share of errors. Keep at it!{c 39}"
   di as txt  "                                            Kabira Namit"
   exit
 }

if `x'>0.55 & `x'<=0.60 {
   di as txt  "{c 39}Does ', force' still work? Asking for a friend.{c 39}"
   di as txt  "                                            Paul Atherton"
   exit
 }

if `x'>0.60 & `x'<=0.65 {
   di as txt  "{c 39}There are two kinds of people in this world: those who want to get things done and those who do not want to make mistakes.{c 39}"
   di as txt  "                                            John Maxwell"
   exit
 }

if `x'>0.65 & `x'<=0.70 {
   di as txt  "{c 39}If we knew what we were doing, it would not be called research, would it?{c 39}"
   di as txt  "                                            Albert Einstein"
   exit
 }

if `x'>0.70 & `x'<=0.75 {
   di as txt  "{c 39}We must accept finite disappointment but never lose infinite hope.{c 39}"
   di as txt  "                                            Martin Luther King"
   exit
 }

if `x'>0.75 & `x'<=0.80 {
   di as txt  "{c 39}The only real mistake is the one from which we learn nothing.{c 39}"
   di as txt  "                                            Henry Ford"
   exit
 }

if `x'>0.80 & `x'<=0.85 {
   di as txt  "{c 39}Try to live everyday like Elle Woods after Warner told her she was not smart enough for law school.{c 39}"
   di as txt  "                                            Marissa Kathryn"
   exit
 }

if `x'>0.85 & `x'<=0.90 {
   di as txt  "{c 39}Failure is so important. We speak about success all the time. It is the ability to resist failure or use failure that often leads to greater success. I have met people who do not want to try for fear of failing.{c 39}"
   di as txt  "                                            Joanne K. Rowling"
   exit
 }

if `x'>0.90 & `x'<=0.95 {
   di as txt  "{c 39}A person who never made a mistake never tried anything new.{c 39}"
   di as txt  "                                            Albert Einstein"
   exit
 }

if `x'>0.95 & `x'<=0.975 {
   di as txt  "{c 39}Success consists of going from failure to failure without loss of enthusiasm.{c 39}"
   di as txt  "                                            Winston Churchill"
   exit
 }

if `x'>0.975 & `x'<=0.100 {
   di as txt  "{c 39}There is beauty in every struggle that is your own.{c 39}"
   di as txt  "                                            Salvia Zeeshan"
   exit
 }

end




