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

method hasEnoughVolume(blood: seq<Blood>, volume: int) returns (b: bool)
{   
    b := false;
    var i : int;
    i := 0;
    var totalVolume: int;
    totalVolume := 0;

    while i < |blood|
    {
        totalVolume := totalVolume + blood[i].volume;
    }

    if totalVolume > volume {
        b:= true;
    }
}

method requestBlood(allBlood: seq<Blood>, bt: BloodType, amount: int, deliverByDate: int) returns (order: seq<Blood>)
{
    var i: int;
    i := 0;
    var suitable : seq<Blood>;
    suitable := [];
    while i < |allBlood|
    {
        if allBlood[i].suitablity == true && allBlood[i].use_by_date < deliverByDate && allBlood[i].blood_type == bt
        {
            suitable := suitable + allBlood[i..i+1];
        }
    }
    var check : bool;
    check := hasEnoughVolume(suitable, amount);
    if !check{
        order := [];
        return;
    }
    var True: bool;
    True := true;
    suitable := BubbleSortExpiration(suitable);
    order := [];
    i := 0;
    while i < |suitable|
    {
        check := hasEnoughVolume(order, amount);
        if !check{
            order := order + suitable[i..i+1];
        }
    }
}