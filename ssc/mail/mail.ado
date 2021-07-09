*! version 0.2 23april2007
#delim ;

/*
 This little program is supposed to mail you status reports
 in case your program runs over several hours. You may use
 an sms-to-email gateway of your local cell phone provider
 to turn them into sms.
 If the target address is a blackberry or similar then you
 are up-to-date on the go. Matlab has a similar functionality.
 Author: Nikos Askitas
*/;

program def mail;
version 6.0;

syntax anything(name=envelop) [using/] [,lines(integer 50)];

local mprog sendmail;
local mytail tail;

* Run program *;
if("$S_OS"=="Windows"){;
 display "Sorry we do not do windows yet...";
 exit;
};
else{;
 tokenize `"`envelop'"', parse(";");
 local from = `"`1'"';
 local to = `"`3'"';
 local subject =`"`5'"';
 local body = `"`7'"';
 local fname = `"`using'"';
 local tail = `"`lines'"';
 local from = regexr(`"`from'"',"From:","");
 local to = regexr(`"`to'"',"To:","");
 local subject = regexr(`"`subject'"',"Subject:","");
 /*
  We write out a spool mail file. It will contain the entire 
  message so that by  the time we are up to it we are ready
  to "cat pipe" it into sendmail.
 */;
  local spoolf = string(uniform());
  local spoolf = reverse("`spoolf'");
  local spoolf = regexr("`spoolf'","\.",".spool");
  capture shell echo "From: 'Ado Mail'<`from'>" > `spoolf';
  capture shell echo "Subject: `subject'" >> `spoolf';
  capture shell echo " " >> `spoolf';
  capture shell echo "`body'" >> `spoolf';
 /*
  If we get a file to use check whether the file exists.
  If not throw error and exit. If yes. Check whether ashell is installed.
  if not exist suggesting installing ashell.
 */;
 if regexm(`"`fname'"', ".+")==1{;
  capture confirm file `"`fname'"';
  if _rc ~= 0 {;
    noisily error _rc;
  };
  else{;
   capture which ashell;
   if _rc == 111 {;
     display as error "You need to install ashell in order to say using";
     exit;
   };
   else{;
    /*
      All "ashell"-ing will be done in the scope of this else.
      Do not violate the logic will break.
    */;
    capture ashell  `mytail' -`tail' "`fname'";
    local got = r(no);
    capture shell echo "---file snippet below--- " >> `spoolf';
    forval x =1/`got'{;
     local tmp = r(o`x');
     capture shell echo "`tmp'" >> "`spoolf'";
    };
   };
  };
 };

 /* 
  some rudimentary plausibility checks before we attempt mailing. 
 */;
 
 if regexm("`from'","@") == 0{;
  display as error "You need to supply a properly formatted From: address";
  exit;
 };
 if regexm("`to'","@") == 0{;
  display as error "You need to supply a properly formatted To: address";
  exit;
 };
 if regexm("`subject'",".") == 0{;
  display as error "You need to supply a non empty Subject:";
  exit;
 };
 if regexm("`body'",".") == 0{;
  display as error "You need to supply a non empty message body";
  exit;
 };
 display "-----------------------------------------";
 display "Ado mail send out a report to `to'.";
 display "-----------------------------------------";
 capture shell cat `spoolf' | `mprog' -t `to';
 capture shell rm `spoolf';
};

end;
