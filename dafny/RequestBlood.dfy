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

function count ( a : seq <Blood > , v : int) : nat
reads a
{
    if (| a | > 0) then
        if( a [0].blood_id == v ) then 1 + count ( a [1..] , v )
        else count ( a [1..] , v )
    else 0
}

predicate permutation ( a : seq <Blood > , b : seq <Blood >)
{
    forall v :: count (a , v ) == count (b , v )
}

method BubbleSortExpiration(a: array<Blood>, asc: bool) returns (sorted: array<Blood>)
requires a != null;
requires forall j :: 0 <= j < a.Length ==> a[j] != null && a[j].Valid();
ensures forall j :: 0 <= j < a.Length ==> a[j] != null && a[j].Valid();
ensures SortedExpiration(a, asc);
ensures permutation (a[..],old(a[..]))
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
  sorted := a;
}

method hasEnoughVolume(blood: seq<Blood>, volume: int) returns (b: bool)
{   
    b := false;
    var i : int;
    i := 0;
    var totalVolume: int;
    totalVolume := 0;

    while i < |blood|
    decreases |blood| - i
    {
        totalVolume := totalVolume + blood[i].volume;
        i := i + 1;
    }

    if totalVolume > volume {
        b:= true;
    }
}

method requestBlood(allBlood: seq<Blood>, bt: BloodType, amount: int, deliverByDate: int) returns (order: seq<Blood>)
requires forall i :: 0 <= i < |allBlood| ==> allBlood[i].Valid();
ensures forall j :: 0 <= j < |order| ==> order[j] != null
ensures forall j :: 0 <= j < |order| ==> order[j].blood_type == bt
ensures forall j :: 0 <= j < |order| ==> order[j].use_by_date <= deliverByDate
{
    var i: int;
    i := 0;
    var suitable : seq<Blood>;
    suitable := [];

    while i < |allBlood|
    decreases |allBlood| - i
    invariant 0 <= i <= |allBlood|;
    invariant forall j :: 0 <= j < |suitable| ==> suitable[j] != null && suitable[j].Valid();
    invariant forall j :: 0 <= j < |suitable| ==> suitable[j].suitablity == true && suitable[j].use_by_date <= deliverByDate && suitable[j].blood_type == bt
    {
        if allBlood[i].suitablity == true && allBlood[i].use_by_date <= deliverByDate && allBlood[i].blood_type == bt
        {
            assert allBlood[i].Valid();
            suitable := suitable + [allBlood[i]];
        }
        i := i + 1;
    }
    
    var check : bool;
    check := hasEnoughVolume(suitable, amount);
    if !check{
        order := [];
        return;
    }
    var True: bool;
    True := true;

    var suitableArray: array<Blood>;
    suitableArray := new Blood[|suitable|](i requires 0 <= i < |suitable| reads suitable => suitable[i]);
    i := 0;
    while (i < |suitable|)
        decreases |suitable| - i
        invariant 0 <= i <= |suitable|;
        invariant forall j :: 0 <= j < |suitable| ==> suitable[j] != null && suitable[j].Valid();
        invariant forall j :: 0 <= j < i ==> suitableArray[j] != null && suitableArray[j].Valid();
        invariant forall j :: 0 <= j < suitableArray.Length ==> suitableArray[j].suitablity == true && suitableArray[j].use_by_date <= deliverByDate && suitableArray[j].blood_type == bt
    {
        suitableArray[i] := suitable[i];
        i := i + 1;
        assert suitableArray[i - 1] != null && suitableArray[i - 1].Valid();
    }
    
    //forall i | 0 <= i && i < suitableArray.Length { suitableArray[i] := suitable[i] ; }
    
    suitableArray := BubbleSortExpiration(suitableArray, True);
    assert forall j :: 0 <= j < suitableArray.Length ==> suitableArray[j].suitablity == true && suitableArray[j].use_by_date <= deliverByDate && suitableArray[j].blood_type == bt;
    suitable := suitableArray[0..suitableArray.Length];
    order := [];
    i := 0;
    while i < |suitable|
    decreases |suitable| - i
    invariant forall j :: 0 <= j < |suitable| ==> suitable[j].suitablity == true && suitable[j].use_by_date <= deliverByDate && suitable[j].blood_type == bt
    invariant forall j :: 0 <= j < |order| ==> order[j].suitablity == true && order[j].use_by_date <= deliverByDate && order[j].blood_type == bt
    {
        check := hasEnoughVolume(order, amount);
        if !check{
            order := order + suitable[i..i+1];
        }
        i := i + 1;
    }
}