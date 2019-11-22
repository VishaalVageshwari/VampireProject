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


class BloodTypeLevel {
  var blood_type: BloodType;
  var total: int;
  ghost var n: int;

  predicate Valid()
  reads this;
  {
    total >= 0 && n >= 0
  }

  constructor (b: BloodType)
  ensures Valid();
  ensures blood_type == b;
  ensures total == 0;
  modifies this;
  {
    blood_type := b;
    total := 0;
    n := 0;
  }

  method AddToTotal(v: int)
  requires Valid();
  requires v >= 0;
  ensures Valid();
  ensures blood_type == old(blood_type);
  ensures total == old(total) + v;
  modifies this`total;
  {
    total := total + v;
  }
}

predicate Critical(btl: BloodTypeLevel)
requires btl != null && btl.Valid();
reads btl
{
  btl.total <= 3
}

function typeVolumeSum(s: seq<Blood>, bt: BloodType, i: int): int
requires 0 <= i <= |s|;
requires forall j :: 0 <= j < |s| ==> s[j] != null && s[j].Valid()
decreases s, i;
reads s;
reads set x | x in s[..];
{
  if |s| == 0 || i == 0 then 0
  else if s[0].blood_type == bt then s[0].volume + typeVolumeSum(s[1..], bt, i - 1)
  else typeVolumeSum(s[1..], bt, i - 1)
}


lemma {:induction s, bt, i} typeVolumeSumLemma(s: seq<Blood>, bt: BloodType, i: int)
requires 0 <= i < |s|;
requires forall j :: 0 <= j < |s| ==> s[j] != null && s[j].Valid();
ensures forall j :: 0 <= j < |s| ==> s[j] != null && s[j].Valid();
ensures (s[i].blood_type == bt ==> (typeVolumeSum(s, bt, i) + s[i].volume == typeVolumeSum(s, bt, i + 1))) &&
  (s[i].blood_type != bt ==> (typeVolumeSum(s, bt, i) == typeVolumeSum(s, bt, i + 1)));
decreases s;
{

}


method GetBloodLevels(s1: seq<Blood>) returns(s2: seq<BloodTypeLevel>)
requires forall j :: 0 <= j < |s1| ==> s1[j] != null && s1[j].Valid();
ensures forall j :: 0 <= j < |s1| ==> s1[j] != null && s1[j].Valid();
ensures |s2| == 8;
ensures s2[0] != null && s2[0].Valid() && s2[0].blood_type == AP && s2[0].total == typeVolumeSum(s1, AP, |s1|);
ensures s2[1] != null && s2[1].Valid() && s2[1].blood_type == AN && s2[1].total == typeVolumeSum(s1, AN, |s1|);
ensures s2[2] != null && s2[2].Valid() && s2[2].blood_type == BP && s2[2].total == typeVolumeSum(s1, BP, |s1|);
ensures s2[3] != null && s2[3].Valid() && s2[3].blood_type == BN && s2[3].total == typeVolumeSum(s1, BN, |s1|);
ensures s2[4] != null && s2[4].Valid() && s2[4].blood_type == ABP && s2[4].total == typeVolumeSum(s1, ABP, |s1|);
ensures s2[5] != null && s2[5].Valid() && s2[5].blood_type == ABN && s2[5].total == typeVolumeSum(s1, ABN, |s1|);
ensures s2[6] != null && s2[6].Valid() && s2[6].blood_type == OP && s2[6].total == typeVolumeSum(s1, OP, |s1|);
ensures s2[7] != null && s2[7].Valid() && s2[7].blood_type == ON && s2[7].total == typeVolumeSum(s1, ON, |s1|);
ensures forall j :: 0 <= j < |s2| ==> s2[j] != null && s2[j].Valid();
{
  var aps := new BloodTypeLevel(AP);
  var ans := new BloodTypeLevel(AN);
  var bps := new BloodTypeLevel(BP);
  var bns := new BloodTypeLevel(BN);
  var abps := new BloodTypeLevel(ABP);
  var abns := new BloodTypeLevel(ABN);
  var ops := new BloodTypeLevel(OP);
  var ons := new BloodTypeLevel(ON);
  var i := 0;

  while i < |s1|
  invariant 0 <= i <= |s1|
  invariant forall j :: 0 <= j < |s1| ==> s1[j] != null && s1[j].Valid() && s1[j].volume >= 0;
  invariant aps != null && aps.Valid() && ans != null && ans.Valid() && bps != null && bps.Valid() && 
    bns != null && bns.Valid() && abps != null && abps.Valid() && abns != null && abns.Valid() && 
    ops != null && ops.Valid() && ons != null && ons.Valid();
  invariant aps.blood_type == AP && ans.blood_type == AN && bps.blood_type == BP &&
    bns.blood_type == BN && abps.blood_type == ABP && abns.blood_type == ABN && 
    ops.blood_type == OP && ons.blood_type == ON;
  invariant aps.total == typeVolumeSum(s1, AP, i) && ans.total == typeVolumeSum(s1, AN, i);
  invariant bps.total == typeVolumeSum(s1, BP, i) && bns.total == typeVolumeSum(s1, BN, i);
  invariant abps.total == typeVolumeSum(s1, ABP, i) && abns.total == typeVolumeSum(s1, ABN, i);
  invariant ops.total == typeVolumeSum(s1, OP, i) && ons.total == typeVolumeSum(s1, ON, i);
  decreases |s1| - i;
  {
    if s1[i].blood_type == AP {
      aps.AddToTotal(s1[i].volume);
    } else if s1[i].blood_type == AN {
      ans.AddToTotal(s1[i].volume);
    } else if s1[i].blood_type == BP {
      bps.AddToTotal(s1[i].volume);
    } else if s1[i].blood_type == BN {
      bns.AddToTotal(s1[i].volume);
    } else if s1[i].blood_type == ABP {
      abps.AddToTotal(s1[i].volume);
    } else if s1[i].blood_type == ABN {
      abns.AddToTotal(s1[i].volume);
    } else if s1[i].blood_type == OP {
      ops.AddToTotal(s1[i].volume);
    } else if s1[i].blood_type == ON {
      ons.AddToTotal(s1[i].volume);
    }

    typeVolumeSumLemma(s1, AP, i);
    typeVolumeSumLemma(s1, AN, i);
    typeVolumeSumLemma(s1, BP, i);
    typeVolumeSumLemma(s1, BN, i);
    typeVolumeSumLemma(s1, ABP, i);
    typeVolumeSumLemma(s1, ABN, i);
    typeVolumeSumLemma(s1, OP, i);
    typeVolumeSumLemma(s1, ON, i);

    i := i + 1;
  }

  s2 := [aps, ans, bps, bns, abps, abns, ops, ons];
}


// This will take some time because of the number of proof obligation but it does mirror implementation
method Main() 
{
  var b1 := new Blood(1, AP, 3, true, 100, "UNSW", "John Doe", "Donor01@gmail.com", false);
  var b2 := new Blood(2, AN, 3, true, 90, "UNSW", "Steve Doe", "Donor02@gmail.com", false);
  var b3 := new Blood(3, BN, 2, true, 70, "UNSW", "Kate Doe", "Donor03@gmail.com", false);
  var b4 := new Blood(4, AP, 8, true, 60, "UNSW", "Kale Doe", "Donor04@gmail.com", false);
  var b5 := new Blood(5, OP, 3, true, 30, "UNSW", "Peter Doe", "Donor05@gmail.com", false);
  var b6 := new Blood(6, AP, 10, true, 40, "UNSW", "Parker Doe", "Donor06@gmail.com", false);
  var b7 := new Blood(7, AN, 5, true, 40, "UNSW", "Paul Doe", "Donor07@gmail.com", false);

  assert b1 != null && b1.Valid();
  assert b2 != null && b2.Valid();
  assert b3 != null && b3.Valid();
  assert b4 != null && b4.Valid();
  assert b5 != null && b5.Valid();
  assert b6 != null && b6.Valid();
  assert b7 != null && b7.Valid();

  var s1: seq<Blood> := [b1, b2, b3, b4, b5, b6, b7];

  assert s1[0] == b1 && s1[0] != null && s1[0].Valid();
  assert s1[1] == b2 && s1[1] != null && s1[1].Valid();
  assert s1[2] == b3 && s1[2] != null && s1[2].Valid();
  assert s1[3] == b4 && s1[3] != null && s1[3].Valid();
  assert s1[4] == b5 && s1[4] != null && s1[4].Valid();
  assert s1[5] == b6 && s1[5] != null && s1[5].Valid();
  assert s1[6] == b7 && s1[6] != null && s1[6].Valid();
  assert forall j :: 0 <= j < |s1| ==> s1[j] != null && s1[j].Valid();

  var s2 := GetBloodLevels(s1);
  assert |s2| == 8;
  assert s2[0] != null && s2[0].Valid() && s2[0].blood_type == AP && s2[0].total == typeVolumeSum(s1, AP, |s1|);
  assert s2[1] != null && s2[1].Valid() && s2[1].blood_type == AN && s2[1].total == typeVolumeSum(s1, AN, |s1|);
  assert s2[2] != null && s2[2].Valid() && s2[2].blood_type == BP && s2[2].total == typeVolumeSum(s1, BP, |s1|);
  assert s2[3] != null && s2[3].Valid() && s2[3].blood_type == BN && s2[3].total == typeVolumeSum(s1, BN, |s1|);
  assert s2[4] != null && s2[4].Valid() && s2[4].blood_type == ABP && s2[4].total == typeVolumeSum(s1, ABP, |s1|);
  assert s2[5] != null && s2[5].Valid() && s2[5].blood_type == ABN && s2[5].total == typeVolumeSum(s1, ABN, |s1|);
  assert s2[6] != null && s2[6].Valid() && s2[6].blood_type == OP && s2[6].total == typeVolumeSum(s1, OP, |s1|);
  assert s2[7] != null && s2[7].Valid() && s2[7].blood_type == ON && s2[7].total == typeVolumeSum(s1, ON, |s1|);
  assert forall j :: 0 <= j < |s2| ==> s2[j] != null && s2[j].Valid();

  var i := 0;
  var critical := false;

  while i < |s2|
  invariant 0 <= i <= |s2|;
  invariant forall j :: 0 <= j < |s2| ==> s2[j] != null && s2[j].Valid();
  decreases |s2| - i;
  {
    critical := false;

    if s2[i].total <= 3 {
      critical := true;
    }

    assert critical == Critical(s2[i]);
    print s2[i].blood_type, " ", s2[i].total, " ", critical, "\n";
     
    i := i + 1;
  }
}