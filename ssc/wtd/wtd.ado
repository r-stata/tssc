*! version 0.1, HS

/* wtd

   Compare with st.
*/

program define wtd
version 7.0

if replay() {
  wtd_is
  if `"`0'"' == "" { 
    wtd_show
    exit
  }
}
end
