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
predicate SortedExpiration(a: seq<Blood>, asc: bool)
requires forall j :: 0 <= j < |a| ==> a[j] != null && a[j].Valid();
reads a;
reads set x | x in a[..];
{
  asc ==> (forall j, k :: 0 <= j <= k < |a| 
    ==> a[j].use_by_date <= a[k].use_by_date) &&
  !asc ==> (forall j, k :: 0 <= j <= k < |a| 
    ==> a[k].use_by_date <= a[j].use_by_date)
}


method hasEnoughVolume(blood: seq<Blood>, volume: int) returns (b: bool)
requires forall x :: 0 <= x < |blood| ==> blood[x] != null
{   
    b := false;
    var i : int;
    i := 0;
    var totalVolume: int;
    totalVolume := 0;

    while i < |blood|
    decreases |blood| - i
    invariant 0 <= i <= |blood|
    {
        totalVolume := totalVolume + blood[i].volume;
        i := i + 1;
    }

    if totalVolume > volume {
        b:= true;
    }
}

method requestBlood(allBlood: seq<Blood>, bt: BloodType, amount: int, deliverByDate: int) returns (order: seq<Blood>)
requires forall i :: 0 <= i < |allBlood| ==> allBlood[i] != null && allBlood[i].Valid()
requires SortedExpiration(allBlood, true)
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
    i := 0;
    order := [];
    while i < |suitable|
    decreases |suitable| - i
    invariant forall j :: 0 <= j < |suitable| ==> suitable[j] != null && suitable[j].suitablity == true && suitable[j].use_by_date <= deliverByDate && suitable[j].blood_type == bt && suitable[j].Valid()
    invariant forall j :: 0 <= j < |order| ==> order[j] != null && order[j].suitablity == true && order[j].use_by_date <= deliverByDate && order[j].blood_type == bt && order[j].Valid()
    {
        check := hasEnoughVolume(order, amount);
        if !check{
            order := order + [suitable[i]];
        }
        i := i + 1;
    }
}
