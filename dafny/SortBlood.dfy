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


predicate SortedExpiration(a: array?<Blood>, asc: bool)
requires a != null;
reads a;
reads set x | x in a[..];
{
  asc ==> (forall j, k :: 0 <= j <= k < a.Length 
    ==> a[j].use_by_date <= a[k].use_by_date) &&
  !asc ==> (forall j, k :: 0 <= j <= k < a.Length 
    ==> a[k].use_by_date <= a[j].use_by_date)
}


predicate SortedBetweenExpiration(a: array?<Blood>, asc: bool, lower: int, upper: int)
requires a != null;
requires lower <= upper < a.Length;
reads a;
reads set x | x in a[..];
{
  asc ==> (forall j, k :: 0 <= lower <= j <= k <= upper < a.Length 
    ==> a[j].use_by_date <= a[k].use_by_date) &&
  !asc ==> (forall j, k :: 0 <= lower <= j <= k <= upper < a.Length 
    ==> a[k].use_by_date <= a[j].use_by_date)
}


predicate PartitionExpiration(a: array?<Blood>, asc: bool, i: int)
requires a != null;
reads a;
reads set x | x in a[..];
{
  asc ==> (forall j, k :: 0 <= j <= i < k < a.Length 
    ==> a[j].use_by_date <= a[k].use_by_date) &&
  !asc ==> (forall j, k :: 0 <= j <= i < k < a.Length 
    ==> a[k].use_by_date <= a[j].use_by_date)
}


method BubbleSortExpiration(a: array?<Blood>, asc: bool)
requires a != null;
ensures SortedExpiration(a, asc);
modifies a;
{
  var i := a.Length - 1;

  while i > 0
  invariant i < 0 ==> a.Length == 0;
  invariant -1 <= i < a.Length;
  invariant SortedBetweenExpiration(a, asc, i, a.Length - 1);
  invariant PartitionExpiration(a, asc, i);
  decreases i;
  {
    var j := 0;

    while j < i
    decreases i - j;
    invariant 0 < i < a.Length && 0 <= j <= i;
    invariant asc ==> (forall k :: 0 <= k <= j 
      ==> a[k].use_by_date <= a[j].use_by_date);
    invariant !asc ==> (forall k :: 0 <= k <= j 
      ==> a[j].use_by_date <= a[k].use_by_date);
    invariant SortedBetweenExpiration(a, asc, i, a.Length - 1);
    invariant PartitionExpiration(a, asc, i);
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

method Main() 
{
  var b1 := new Blood(1, AP, 3, true, 100, "UNSW", "John Doe", "Donor01@gmail.com", false);
  var b2 := new Blood(2, AN, 4, true, 90, "UNSW", "Steve Doe", "Donor02@gmail.com", false);
  var b3 := new Blood(3, BN, 8, true, 70, "UNSW", "Kate Doe", "Donor03@gmail.com", false);

  var a := new Blood[][b1, b2, b3];
  BubbleSortExpiration(a, true);

  assert SortedExpiration(a, true);
  print(a[0].blood_id);
  print(" ");
  print(a[1].blood_id);
  print(" ");
  print(a[2].blood_id);
  print("\n");

  var b := new Blood[][b2, b1, b3];
  BubbleSortExpiration(b, false);

  assert SortedExpiration(b, false);
  print(b[0].blood_id);
  print(" ");
  print(b[1].blood_id);
  print(" ");
  print(b[2].blood_id);
  print("\n");
}