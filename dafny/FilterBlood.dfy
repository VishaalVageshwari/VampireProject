datatype BloodType = AP | AN | BP | BN | ABP | ABN | OP | ON


class Blood {
  var blood_id: int;
  var blood_type: BloodType;
  var volume: int;
  var suitablity: bool;
  var use_by_date: int;
  var location: string;
  var donor_name: string;
  var donor_email: string;
  var ordered: bool;

  predicate Valid()
  reads this;
  {
    volume > 0 && use_by_date > 0 &&
    location != "" && donor_name != "" && donor_email != ""
  }

  constructor (id: int, b: BloodType, v: int, s: bool, u: int, 
    l: string, dn: string, de: string, o: bool) 
  requires v > 0 && u > 0;
  requires l != "" && dn != "" && de != ""
  ensures Valid();
  {
    blood_id := id;
    blood_type := b;
    volume := v;
    suitablity := s;
    use_by_date := u;
    location := l;
    donor_name := dn;
    donor_email := de;
    ordered := o;
  }
}


predicate FilteredBloodType(a: array?<Blood>, bt: BloodType)
requires a != null
reads a
reads set x | x in a[..]
{
  forall j :: 0 <= j < a.Length ==> a[j].blood_type == bt
}



method FilterBloodType(a: array?<Blood>, bt: BloodType) returns (b: array?<Blood>, n: int)
requires a != null
{
  var i := 0;

  n := 0;

  while i < a.Length
  invariant 0 <= n <= i <= a.Length
  decreases a.Length - i;
  {
    if a[i].blood_type == bt {
      n := n + 1; 
    }
    i := i + 1;
  }
}