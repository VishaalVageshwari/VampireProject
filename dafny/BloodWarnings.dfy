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


class BloodTypeSum {
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


function volumeSum(s: seq<Blood>, bt: BloodType, i: int): int
requires 0 <= i <= |s|;
requires forall j :: 0 <= j < |s| ==> s[j] != null && s[j].Valid()
decreases s, i;
reads s;
reads set x | x in s[..];
{
  if |s| == 0 || i == 0 then 0
  else if s[0].blood_type != bt then volumeSum(s[1..], bt, i - 1)
  else s[0].volume + volumeSum(s[1..], bt, i - 1)
}


lemma volumeSumLemma(s: seq<Blood>, bt: BloodType, i: int)
requires 0 <= i < |s|;
requires forall j :: 0 <= j < |s| ==> s[j] != null && s[j].Valid();
ensures forall j :: 0 <= j < |s| ==> s[j] != null && s[j].Valid();
ensures s[i].blood_type == bt ==> (volumeSum(s, bt, i) + s[i].volume == volumeSum(s, bt, i + 1)) &&
  s[i].blood_type != bt ==> (volumeSum(s, bt, i) == volumeSum(s, bt, i + 1));
decreases s;
{

}


method BloodTypesTotals(s1: seq<Blood>) returns(s2: seq<BloodTypeSum>)
requires forall j :: 0 <= j < |s1| ==> s1[j] != null && s1[j].Valid();
{
  var aps := new BloodTypeSum(AP);
  var ans := new BloodTypeSum(AN);
  var bps := new BloodTypeSum(BP);
  var bns := new BloodTypeSum(BN);
  var abps := new BloodTypeSum(ABP);
  var abns := new BloodTypeSum(ABN);
  var ops := new BloodTypeSum(OP);
  var ons := new BloodTypeSum(ON);
  var i := 0;
  var total := 0;

  assert aps.total == 0;

  while i < |s1|
  invariant 0 <= i <= |s1|
  invariant forall j :: 0 <= j < |s1| ==> s1[j] != null && s1[j].Valid() && s1[j].volume >= 0;
  invariant aps != null && aps.Valid() && ans != null && ans.Valid() && bps != null && bps.Valid() && 
    bns != null && bns.Valid() && abps != null && abps.Valid() && abns != null && abns.Valid() && 
    ops != null && ops.Valid() && ons != null && ons.Valid();
  invariant aps.blood_type == AP && ans.blood_type == AN && bps.blood_type == BP &&
    bns.blood_type == BN && abps.blood_type == ABP && abns.blood_type == ABN && 
    ops.blood_type == OP && ons.blood_type == ON;
  invariant total == volumeSum(s1, AP, i);
  decreases |s1| - i
  {
    if s1[i].blood_type == AP {
      aps.AddToTotal(s1[i].volume);
      total := total + s1[i].volume;
      volumeSumLemma(s1, AP, i);
    } else if s1[i].blood_type == AN {
      aps.AddToTotal(s1[i].volume);
    } else if s1[i].blood_type == BP {
      aps.AddToTotal(s1[i].volume);
    } else if s1[i].blood_type == BN {
      aps.AddToTotal(s1[i].volume);
    } else if s1[i].blood_type == ABP {
      aps.AddToTotal(s1[i].volume);
    } else if s1[i].blood_type == ABN {
      aps.AddToTotal(s1[i].volume);
    }

    i := i + 1;
  }

  s2 := [aps, ans, bps, bns, abps, abns, ops, ons];
}