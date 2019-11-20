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

predicate SortedExpiration(a: array<Blood>, asc: bool)
requires a != null;
requires forall j :: 0 <= j < a.Length ==> a[j] != null && a[j].Valid();
reads a;
reads set x | x in a[..];
{
  asc ==> (forall j, k :: 0 <= j <= k < a.Length 
    ==> a[j].use_by_date <= a[k].use_by_date) &&
  !asc ==> (forall j, k :: 0 <= j <= k < a.Length 
    ==> a[k].use_by_date <= a[j].use_by_date)
}


predicate SortedBetweenExpiration(a: array<Blood>, asc: bool, lower: int, upper: int)
requires a != null;
requires forall j :: 0 <= j < a.Length ==> a[j] != null && a[j].Valid();
requires lower <= upper < a.Length;
reads a;
reads set x | x in a[..];
{
  asc ==> (forall j, k :: 0 <= lower <= j <= k <= upper < a.Length 
    ==> a[j].use_by_date <= a[k].use_by_date) &&
  !asc ==> (forall j, k :: 0 <= lower <= j <= k <= upper < a.Length 
    ==> a[k].use_by_date <= a[j].use_by_date)
}


predicate PartitionExpiration(a: array<Blood>, asc: bool, i: int)
requires a != null;
requires forall j :: 0 <= j < a.Length ==> a[j] != null && a[j].Valid();
reads a;
reads set x | x in a[..];
{
  asc ==> (forall j, k :: 0 <= j <= i < k < a.Length 
    ==> a[j].use_by_date <= a[k].use_by_date) &&
  !asc ==> (forall j, k :: 0 <= j <= i < k < a.Length 
    ==> a[k].use_by_date <= a[j].use_by_date)
}


method BubbleSortExpiration(a: array<Blood>, asc: bool)
requires a != null;
requires forall j :: 0 <= j < a.Length ==> a[j] != null && a[j].Valid();
ensures forall j :: 0 <= j < a.Length ==> a[j] != null && a[j].Valid();
ensures SortedExpiration(a, asc);
modifies a;
{
  var i := a.Length - 1;

  while i > 0
  invariant i < 0 ==> a.Length == 0;
  invariant -1 <= i < a.Length;
  invariant forall j :: 0 <= j < a.Length ==> a[j] != null && a[j].Valid();
  invariant SortedBetweenExpiration(a, asc, i, a.Length - 1);
  invariant PartitionExpiration(a, asc, i);
  decreases i;
  {
    var j := 0;

    while j < i
    invariant 0 < i < a.Length && 0 <= j <= i;
    invariant forall j :: 0 <= j < a.Length ==> a[j] != null && a[j].Valid();
    invariant asc ==> (forall k :: 0 <= k <= j 
      ==> a[k].use_by_date <= a[j].use_by_date);
    invariant !asc ==> (forall k :: 0 <= k <= j 
      ==> a[j].use_by_date <= a[k].use_by_date);
    invariant SortedBetweenExpiration(a, asc, i, a.Length - 1);
    invariant PartitionExpiration(a, asc, i);
    decreases i - j;
    {  
      if asc && (a[j].use_by_date > a[j + 1].use_by_date)
      {
        a[j], a[j + 1] := a[j + 1], a[j];
      } 
      else if !asc && (a[j].use_by_date < a[j + 1].use_by_date)
      {
        a[j], a[j + 1] := a[j + 1], a[j];
      }

      j := j + 1;
    }

    i := i - 1;
  }
}

predicate satisfiable(
        all_blood: seq<Blood>,
        blood_type: BloodType,
        volume_required: int,
        delivery_date: int)
    requires forall j :: 0 <= j < |all_blood| ==> all_blood[j] != null;
    reads all_blood;
{
    if |all_blood| > 0 then
        if all_blood[0].blood_type == blood_type &&
            all_blood[0].use_by_date >= delivery_date
        then
            satisfiable(all_blood[1..], blood_type, volume_required - all_blood[0].volume, delivery_date)
        else
            satisfiable(all_blood[1..], blood_type, volume_required, delivery_date)
    else
        volume_required <= 0
}

function sumVolume(blood: seq<Blood>): int
    requires forall j :: 0 <= j < |blood| ==> blood[j] != null;
    reads blood;
{
    if |blood| > 0 then
        blood[0].volume + sumVolume(blood[1..])
    else
        0
}

method AllocateBlood(
         all_blood: seq<Blood>,
         blood_type: BloodType,
         volume_required: int,
         delivery_date: int)
    returns (allocation: seq<Blood>)
    requires forall j :: 0 <= j < |all_blood| ==> all_blood[j] != null && all_blood[j].Valid();
    requires volume_required > 0;
    requires delivery_date > 0;
    
    ensures forall j :: 0 <= j < |allocation| ==> allocation[j] != null;
    // ensures
    //     if satisfiable(all_blood, blood_type, volume_required, delivery_date) then
    //         forall j :: 0 <= j < |allocation| ==> allocation[j].blood_type == blood_type
    //     else
    //         allocation == [];
  
    ensures satisfiable(all_blood, blood_type, volume_required, delivery_date) ==> (
        forall j :: 0 <= j < |allocation| ==> (
            allocation[j].blood_type == blood_type &&
            allocation[j].use_by_date >= delivery_date
        ) &&
        sumVolume(allocation) >= volume_required
    );
        
{
    var blood_entries: seq<Blood>;
    var suitable_blood: seq<Blood>;    
    var suitable_type: bool;
    var suitable_date: bool;
    var blood_arr: array<Blood>;
    var volume: int;
    var i: int;

    // Get all of the requestable blood
    blood_entries := GetRequestableBlood(all_blood, delivery_date);

    // Get all of the suitable blood
    i := 0;
    suitable_blood := [];
    while (i < |blood_entries|)
        invariant 0 <= i <= |blood_entries|;
        invariant forall j :: 0 <= j < |suitable_blood| ==> suitable_blood[j] != null && suitable_blood[j].Valid();
    {
        suitable_type := blood_entries[i].blood_type == blood_type;
        suitable_date := blood_entries[i].use_by_date >= delivery_date;
        if (suitable_type && suitable_date) {
            suitable_blood := suitable_blood + [blood_entries[i]];
        }

        i := i + 1;
    }

    // Check if there is enough suitable blood
    volume := SumBloodVolume(suitable_blood[..]);
    if (volume < volume_required) {
        return [];
    }

    assert forall j :: 0 <= j < |suitable_blood| ==> suitable_blood[j] != null && suitable_blood[j].Valid();

    // Allocate the blood prioritising blood that expires the soonest
    blood_arr := new Blood[|suitable_blood|];
    i := 0;
    while (i < |suitable_blood|)
        invariant 0 <= i <= |suitable_blood|;
        invariant forall j :: 0 <= j < |suitable_blood| ==> suitable_blood[j] != null && suitable_blood[j].Valid();
        invariant forall j :: 0 <= j < i ==> blood_arr[j] != null && blood_arr[j].Valid();
    {
        blood_arr[i] := suitable_blood[i];
        i := i + 1;
        assert blood_arr[i - 1] != null && blood_arr[i - 1].Valid();
    }
    BubbleSortExpiration(blood_arr, true);

    allocation := [];
    i := 0;
    while (i < blood_arr.Length)
        invariant 0 <= i <= blood_arr.Length;
        invariant forall j :: 0 <= j < blood_arr.Length ==> blood_arr[j] != null && blood_arr[j].Valid();
        invariant forall j :: 0 <= j < |allocation| ==> allocation[j] != null;
        invariant forall j :: 0 <= j < |allocation| ==> allocation[j].blood_type == blood_type;
        invariant forall j :: 0 <= j < |allocation| ==> allocation[j].use_by_date >= delivery_date;
    {
        volume := SumBloodVolume(blood_arr[..]);
        if (volume < volume_required && blood_arr[i].blood_type == blood_type && blood_arr[i].use_by_date >= delivery_date) {
            allocation := allocation + [blood_arr[i]];
        }
        i := i + 1;
    }

    return allocation;
}
