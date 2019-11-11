predicate VerifyCheckBlood(id: int, b: string, v: int, s: bool, 
  u: int, l: string, dn: string, de: string, o: bool) 
{
  (b == "A+" || b == "A-"  || b == "B+" || b == "B-" || 
   b == "AB+" || b == "AB-" || b == "O+" || b == "O-") &&
  id > 0 && v > 0 && u > 0 && l != "" && dn != "" && de != "" &&
  (s == true || s == false) && o == false
}


// Method corrseponds to the validators(required, date, and custom validators) 
// on new blood and ordered being set to false before being added.
// Here strings are used as for blood type as they are in implementation
// but after we make the checks here we make the assumption that verifying
// with the datatype BloodType is reasonable since these strings aren't changed.
// id => id, b => blood type, v => volume, s => suitablity, u => use-by-date
// l => location donated, dn => donor name, de => donor email, o => ordered
method CheckBlood(id: int, b: string, v: int, s: bool, 
  u: int, l: string, dn: string, de: string) returns (o: bool, valid_blood: bool)
ensures valid_blood == VerifyCheckBlood(id, b, v, s, u, l, dn, de, o)
{
  o := false;
  valid_blood := true;

  // split over two parts for clarity
  if b != "A+" && b != "A-"  && b != "B+" && b != "B-" &&
     b != "AB+" && b != "AB-" && b != "O+" && b != "O-" 
  {
    valid_blood := false;
  } else if id <= 0 || v <= 0 || u <= 0 || 
    l == "" || dn == "" || de == "" 
  {
    valid_blood := false;
  }

  assert o == false;
}