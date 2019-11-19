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


predicate SortedVolume(a: array<Blood>, asc: bool)
requires a != null;
requires forall j :: 0 <= j < a.Length ==> a[j] != null && a[j].Valid();
reads a;
reads set x | x in a[..];
{
  asc ==> (forall j, k :: 0 <= j <= k < a.Length 
    ==> a[j].volume <= a[k].volume) &&
  !asc ==> (forall j, k :: 0 <= j <= k < a.Length 
    ==> a[k].volume <= a[j].volume)
}


predicate SortedBetweenVolume(a: array<Blood>, asc: bool, lower: int, upper: int)
requires a != null;
requires forall j :: 0 <= j < a.Length ==> a[j] != null && a[j].Valid();
requires lower <= upper < a.Length;
reads a;
reads set x | x in a[..];
{
  asc ==> (forall j, k :: 0 <= lower <= j <= k <= upper < a.Length 
    ==> a[j].volume <= a[k].volume) &&
  !asc ==> (forall j, k :: 0 <= lower <= j <= k <= upper < a.Length 
    ==> a[k].volume <= a[j].volume)
}


predicate PartitionVolume(a: array<Blood>, asc: bool, i: int)
requires a != null;
requires forall j :: 0 <= j < a.Length ==> a[j] != null && a[j].Valid();
reads a;
reads set x | x in a[..];
{
  asc ==> (forall j, k :: 0 <= j <= i < k < a.Length 
    ==> a[j].volume <= a[k].volume) &&
  !asc ==> (forall j, k :: 0 <= j <= i < k < a.Length 
    ==> a[k].volume <= a[j].volume)
}


method BubbleSortVolume(a: array<Blood>, asc: bool)
requires a != null;
requires forall j :: 0 <= j < a.Length ==> a[j] != null && a[j].Valid();
ensures forall j :: 0 <= j < a.Length ==> a[j] != null && a[j].Valid();
ensures SortedVolume(a, asc);
modifies a;
{
  var i := a.Length - 1;

  while i > 0
  invariant i < 0 ==> a.Length == 0;
  invariant -1 <= i < a.Length;
  invariant forall j :: 0 <= j < a.Length ==> a[j] != null && a[j].Valid();
  invariant SortedBetweenVolume(a, asc, i, a.Length - 1);
  invariant PartitionVolume(a, asc, i);
  decreases i;
  {
    var j := 0;

    while j < i
    invariant 0 < i < a.Length && 0 <= j <= i;
    invariant forall j :: 0 <= j < a.Length ==> a[j] != null && a[j].Valid();
    invariant asc ==> (forall k :: 0 <= k <= j 
      ==> a[k].volume <= a[j].volume);
    invariant !asc ==> (forall k :: 0 <= k <= j 
      ==> a[j].volume <= a[k].volume);
    invariant SortedBetweenVolume(a, asc, i, a.Length - 1);
    invariant PartitionVolume(a, asc, i);
    decreases i - j;
    {  
      if asc && (a[j].volume > a[j + 1].volume)
      {
        a[j], a[j + 1] := a[j + 1], a[j];
      } 
      else if !asc && (a[j].volume < a[j + 1].volume)
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

  assert b1 != null && b1.Valid();
  assert b2 != null && b2.Valid();
  assert b3 != null && b3.Valid();

  var a := new Blood[3];
  a[0], a[1], a[2] := b2, b1, b3;

  assert a[0] == b2 && a[0] != null && a[0].Valid();
  assert a[1] == b1 && a[1] != null && a[1].Valid();
  assert a[2] == b3 && a[2] != null && a[2].Valid();
  assert forall j :: 0 <= j < a.Length ==> a[j] != null && a[j].Valid();
  
  BubbleSortVolume(a, true);
  assert SortedVolume(a, true);

  print a[0].blood_id, " ", a[1].blood_id, " ", a[2].blood_id, "\n";

  BubbleSortVolume(a, false);
  assert SortedVolume(a, false);

  print a[0].blood_id, " ", a[1].blood_id, " ", a[2].blood_id, "\n";
}