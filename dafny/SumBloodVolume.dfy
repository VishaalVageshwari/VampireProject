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

  constructor(id: int, b: BloodType, v: int, s: bool, u: int, 
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
}


function volumeSum(s: seq<Blood>, i: int): int
requires 0 <= i <= |s|;
requires forall j :: 0 <= j < |s| ==> s[j] != null && s[j].Valid()
decreases s, i;
reads s;
reads set x | x in s[..];
{
  if |s| == 0 || i == 0 then 0
  else s[0].volume + volumeSum(s[1..], i -1)
}


lemma volumeSumLemma(s: seq<Blood>, i: int)
requires 0 <= i < |s|;
requires forall j :: 0 <= j < |s| ==> s[j] != null && s[j].Valid();
decreases s;
ensures forall j :: 0 <= j < |s| ==> s[j] != null && s[j].Valid();
ensures (volumeSum(s, i) + s[i].volume) == volumeSum(s, i + 1);
{

}


method SumBloodVolume(s: seq<Blood>) returns(total: int)
requires forall j :: 0 <= j < |s| ==> s[j] != null && s[j].Valid();
ensures total == volumeSum(s, |s|);
{
  total := 0;
  var i := 0;

  while i < |s|
  invariant 0 <= i <= |s|;
  invariant forall j :: 0 <= j < |s| ==> s[j] != null && s[j].Valid();
  invariant total == volumeSum(s, i);
  decreases |s| - i;
  {
    total := total + s[i].volume;
    volumeSumLemma(s, i);
    i := i + 1;
  }
}


method Main() 
{
  var b1 := new Blood(1, AP, 3, true, 100, "UNSW", "John Doe", "Donor01@gmail.com", false);
  var b2 := new Blood(2, AN, 4, true, 90, "UNSW", "Steve Doe", "Donor02@gmail.com", false);
  var b3 := new Blood(3, BN, 8, true, 70, "UNSW", "Kate Doe", "Donor03@gmail.com", false);

  assert b1 != null && b1.Valid();
  assert b2 != null && b2.Valid();
  assert b3 != null && b3.Valid();

  var s1: seq<Blood> := [b1, b2, b3];

  assert s1[0] == b1 && s1[0] != null && s1[0].Valid();
  assert s1[1] == b2 && s1[1] != null && s1[1].Valid();
  assert s1[2] == b3 && s1[2] != null && s1[2].Valid();
  assert forall j :: 0 <= j < |s1| ==> s1[j] != null && s1[j].Valid();
  
  var s1Total := SumBloodVolume(s1);
  assert s1Total == volumeSum(s1, |s1|);

  print s1Total, "\n";
}