predicate Sorted(a: array<Blood>, low:int, high:int)
requires a != null
requires 0<=low<=high<=a.Length
reads a;
{ forall j,k:: low<=j<k<high ==> a[j].getAge()<=a[k].getAge() }

class Blood{
    var id: int
    var blood_type: array<char>
    var volume: int
    var use_by_date: array<char>
    var age: int
    constructor (aa: int, bb: array<char>, cc: int, dd:array<char>, ee:int)
    { id := aa; blood_type := bb; volume := cc; use_by_date := dd; age := ee; }

    method getAge() returns (age: int)
    modifies this
    {age := age;}

    predicate isExpired()
    reads this;
    {age > 40}

}

method DateSort(blood: array<Blood>)
requires blood != null
requires blood.Length > 1
ensures Sorted(blood, 0, blood.Length);
ensures multiset(blood[..]) == multiset(old(blood[..]));
modifies blood;
{
    var up:=1;
    while (up < blood.Length)
    decreases blood.Length - up
    invariant 1 <= up <= blood.Length;
    invariant Sorted(blood, 0, up);
    invariant multiset(blood[..]) == multiset(old(blood[..]));
    {
    var down := up;
    while (down >= 1 && blood[down-1] > blood[down])
    decreases down - 1
    invariant 0 <= down <= up;
    invariant forall i,j:: (0<=i<j<=up && j!=down) ==> blood[i]<=blood[j];
    invariant multiset(blood[..]) == multiset(old(blood[..]));
    {
    blood[down-1], blood[down] := blood[down], blood[down-1];
    down:=down-1;
    }
    up:=up+1;
    }
}
