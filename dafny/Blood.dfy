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
  modifies this;
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

  method OrderBlood()
  requires Valid();
  ensures Valid();
  requires ordered == false;
  ensures ordered == true;
  modifies this;
  {
    ordered := true;
  }
}


predicate isRequestable(s: seq<Blood>, cd: int)
requires forall j :: 0 <= j < |s| ==> s[j] != null && s[j].Valid();
reads s;
reads set x | x in s[..];
{
  forall j :: 0 <= j < |s| ==> !s[j].ordered &&
    s[j].suitablity && cd <= s[j].use_by_date
}


predicate isDisposable(s: seq<Blood>, cd: int)
requires forall j :: 0 <= j < |s| ==> s[j] != null && s[j].Valid();
reads s;
reads set x | x in s[..];
{
  forall j :: 0 <= j < |s| ==> !s[j].ordered &&
    (!s[j].suitablity || cd > s[j].use_by_date)
}


predicate isOrdered(s: seq<Blood>)
requires forall j :: 0 <= j < |s| ==> s[j] != null && s[j].Valid();
reads s;
reads set x | x in s[..];
{
  forall j :: 0 <= j < |s| ==> s[j].ordered
}


method GetRequestableBlood(s1: seq<Blood>, cd: int) returns (s2: seq<Blood>)
requires forall j :: 0 <= j < |s1| ==> s1[j] != null && s1[j].Valid();
ensures forall j :: 0 <= j < |s2| ==> s2[j] != null && s2[j].Valid();
ensures 0 <= |s2| <= |s1|;
ensures isRequestable(s2, cd);
{
  s2 := [];
  var i := 0;
  
  while i < |s1|
  invariant 0 <= |s2| <= i <= |s1|;
  invariant forall j :: 0 <= j < |s1| ==> s1[j] != null && s1[j].Valid();
  invariant forall j :: 0 <= j < |s2| ==> s2[j] != null && s2[j].Valid();
  invariant forall j :: 0 <= j < |s2| ==> !s2[j].ordered &&
    s2[j].suitablity && cd <= s2[j].use_by_date;
  decreases |s1| - i;
  {
    if !s1[i].ordered && s1[i].suitablity 
      && cd <= s1[i].use_by_date {
      var s3 := [s1[i]];
      s2 := s2 + s3;
    }

    i := i + 1;
  }
}


method GetDisposableBlood(s1: seq<Blood>, cd: int) returns (s2: seq<Blood>)
requires forall j :: 0 <= j < |s1| ==> s1[j] != null && s1[j].Valid();
ensures forall j :: 0 <= j < |s2| ==> s2[j] != null && s2[j].Valid();
ensures 0 <= |s2| <= |s1|;
ensures isDisposable(s2, cd);
{
  s2 := [];
  var i := 0;
  
  while i < |s1|
  invariant 0 <= |s2| <= i <= |s1|;
  invariant forall j :: 0 <= j < |s1| ==> s1[j] != null && s1[j].Valid();
  invariant forall j :: 0 <= j < |s2| ==> s2[j] != null && s2[j].Valid();
  invariant forall j :: 0 <= j < |s2| ==> !s2[j].ordered &&
    (!s2[j].suitablity || cd > s2[j].use_by_date);
  decreases |s1| - i;
  {
    if !s1[i].ordered && (!s1[i].suitablity 
      || cd > s1[i].use_by_date) {
      var s3 := [s1[i]];
      s2 := s2 + s3;
    }

    i := i + 1;
  }
}


method GetOrderedBlood(s1: seq<Blood>) returns (s2: seq<Blood>)
requires forall j :: 0 <= j < |s1| ==> s1[j] != null && s1[j].Valid();
ensures forall j :: 0 <= j < |s2| ==> s2[j] != null && s2[j].Valid();
ensures 0 <= |s2| <= |s1|;
ensures isOrdered(s2);
{
  s2 := [];
  var i := 0;
  
  while i < |s1|
  invariant 0 <= |s2| <= i <= |s1|;
  invariant forall j :: 0 <= j < |s1| ==> s1[j] != null && s1[j].Valid();
  invariant forall j :: 0 <= j < |s2| ==> s2[j] != null && s2[j].Valid();
  invariant forall j :: 0 <= j < |s2| ==> s2[j].ordered;
  decreases |s1| - i;
  {
    if s1[i].ordered {
      var s3 := [s1[i]];
      s2 := s2 + s3;
    }

    i := i + 1;
  }
}


method Main() 
{
  var b1 := new Blood(1, AP, 3, true, 100, "UNSW", "John Doe", "Donor01@gmail.com", false);
  var b2 := new Blood(2, AN, 4, true, 90, "UNSW", "Steve Doe", "Donor02@gmail.com", true);
  var b3 := new Blood(3, BN, 8, true, 70, "UNSW", "Kate Doe", "Donor03@gmail.com", false);
  var b4 := new Blood(4, AP, 8, false, 60, "UNSW", "Kale Doe", "Donor04@gmail.com", true);
  var b5 := new Blood(5, OP, 4, true, 70, "UNSW", "Peter Doe", "Donor05@gmail.com", false);
  var b6 := new Blood(6, AP, 10, true, 40, "UNSW", "Parker Doe", "Donor06@gmail.com", false);

  assert b1 != null && b1.Valid();
  assert b2 != null && b2.Valid();
  assert b3 != null && b3.Valid();
  assert b4 != null && b4.Valid();
  assert b5 != null && b5.Valid();
  assert b6 != null && b6.Valid();

  var s1: seq<Blood> := [b1, b2, b3, b4, b5, b6];

  assert s1[0] == b1 && s1[0] != null && s1[0].Valid();
  assert s1[1] == b2 && s1[1] != null && s1[1].Valid();
  assert s1[2] == b3 && s1[2] != null && s1[2].Valid();
  assert s1[3] == b4 && s1[3] != null && s1[3].Valid();
  assert s1[4] == b5 && s1[4] != null && s1[4].Valid();
  assert s1[5] == b6 && s1[5] != null && s1[5].Valid();
  assert forall j :: 0 <= j < |s1| ==> s1[j] != null && s1[j].Valid();

  var s2 := GetRequestableBlood(s1, 50);
  assert isRequestable(s2, 50);

  var i := 0;
  print "Requestable Blood", "\n";

  while i < |s2|
  invariant 0 <= i <= |s2|
  invariant forall j :: 0 <= j < |s2| ==> s2[j] != null && s2[j].Valid();
  decreases |s2| - i;
  {
    print s2[i].blood_id, " suitablity: ", s2[i].suitablity, " use_by_date: ", 
      s2[i].use_by_date, " ordered status: ", s2[i].ordered, "\n";
    i := i + 1;
  }

  s2 := GetDisposableBlood(s1, 50);
  assert isDisposable(s2, 50);

  i := 0;
  print "Disposable Blood", "\n";

  while i < |s2|
  invariant 0 <= i <= |s2|
  invariant forall j :: 0 <= j < |s2| ==> s2[j] != null && s2[j].Valid();
  decreases |s2| - i;
  {
    print s2[i].blood_id, " suitablity: ", s2[i].suitablity, " use_by_date: ", 
      s2[i].use_by_date, " ordered status: ", s2[i].ordered, "\n";
    i := i + 1;
  }

  s2 := GetOrderedBlood(s1);
  assert isOrdered(s2);

  i := 0;
  print "Ordered Blood", "\n";

  while i < |s2|
  invariant 0 <= i <= |s2|
  invariant forall j :: 0 <= j < |s2| ==> s2[j] != null && s2[j].Valid();
  decreases |s2| - i;
  {
    print s2[i].blood_id, " suitablity: ", s2[i].suitablity, " use_by_date: ", 
      s2[i].use_by_date, " ordered status: ", s2[i].ordered, "\n";
    i := i + 1;
  }
}