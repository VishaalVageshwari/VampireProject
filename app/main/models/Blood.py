from datetime import datetime
from app.models import Blood as dbBlood, BloodOrder as dbBloodOrder

class Blood:

    def __init__(self, blood_id, blood_type, volume, suitablity,
        use_by_date, location, donor_name, donor_email, ordered=False):
        self._blood_id = blood_id
        self._blood_type = blood_type
        self._volume = volume
        self._suitablity = suitablity
        self._use_by_date = use_by_date
        self._location = location
        self._donor_name = donor_name
        self._donor_email = donor_email
        self._ordered = ordered

    @property
    def blood_id(self):
        return self._blood_id

    @property
    def blood_type(self):
        return self._blood_type

    @property
    def volume(self):
        return self._volume

    @volume.setter
    def volume(self, value):
        self._volume = value

    @property
    def suitablity(self):
        return self._suitablity

    @property
    def use_by_date(self):
        return self._use_by_date

    @property
    def location(self):
        return self._location

    @property
    def donor_name(self):
        return self._donor_name

    @property
    def donor_email(self):
        return self._donor_email

    @property
    def ordered(self):
        return self._ordered

    def __repr__(self):
        return '<Blood [ID : {0}], [Blood Type : {1}], [Blood Donor : {2}]>'\
            .format(self.blood_id, self.blood_type, self.donor_name)


class BloodTypeLevel:

    def __init__(self, blood_type):
        self._blood_type = blood_type
        self._total = 0

    @property
    def blood_type(self):
        return self._blood_type

    @property
    def total(self):
        return self._total

    @total.setter
    def total(self, total):
        self._total = total

    def add_to_total(self, volume):
        self.total += volume


def get_all_blood():
    blood_list = []
    db_blood = dbBlood.query.all()
    db_ordered_ids = dbBloodOrder.query.with_entities(dbBloodOrder.blood_id)
    ordered_ids = {oi[0] for oi in db_ordered_ids}

    for b in db_blood:
        blood_id = b.id
        blood_type = b.blood_type
        volume = b.volume
        suitablity = b.suitablity
        use_by_date = b.use_by_date
        location = b.location_donated
        donor_name = b.blood_donor_name
        donor_email = b.blood_donor_email
        ordered = False

        if b.id in ordered_ids:
            ordered = True

        blood = Blood(blood_id, blood_type, volume, suitablity,
            use_by_date, location, donor_name, donor_email, ordered)

        blood_list.append(blood)

    return blood_list


def get_requestable_blood():
    blood = get_all_blood()
    current_date = datetime.today().date()
    requestable_blood = []

    for b in blood:
        if not b.ordered and b.suitablity and current_date <= b.use_by_date:
            requestable_blood.append(b)
    requestable_blood = bubblesort_expiration(requestable_blood, True)
    return requestable_blood


def get_disposable_blood():
    blood = get_all_blood()
    current_date = datetime.today().date()
    disposable_blood = []

    for b in blood:
        if not b.ordered and (not b.suitablity or current_date > b.use_by_date):
            disposable_blood.append(b)

    return disposable_blood


def get_ordered_blood():
    blood = get_all_blood()
    ordered_blood = []

    for b in blood:
        if b.ordered:
            ordered_blood.append(b)

    return ordered_blood


def get_remove_blood():
    blood = get_all_blood()
    current_date = datetime.today().date()
    remove_blood = []

    for b in blood:
        if b.ordered or not b.suitablity or current_date > b.use_by_date:
            remove_blood.append(b)

    return remove_blood


def get_total_blood_volume():
    blood = get_requestable_blood()
    total = 0

    for b in blood:
        total += b.volume

    return total

def get_blood_levels():
    blood = get_requestable_blood()
    ap_blood = BloodTypeLevel("A+")
    an_blood = BloodTypeLevel("A-")
    bp_blood = BloodTypeLevel("B+")
    bn_blood = BloodTypeLevel("B-")
    abp_blood = BloodTypeLevel("AB+")
    abn_blood = BloodTypeLevel("AB-")
    op_blood = BloodTypeLevel("O+")
    on_blood = BloodTypeLevel("O-")

    for b in blood:
        if b.blood_type == "A+":
            ap_blood.add_to_total(b.volume)
        elif b.blood_type == "A-":
            an_blood.add_to_total(b.volume)
        elif b.blood_type == "B+":
            bp_blood.add_to_total(b.volume)
        elif b.blood_type == "B-":
            bn_blood.add_to_total(b.volume)
        elif b.blood_type == "AB+":
            abp_blood.add_to_total(b.volume)
        elif b.blood_type == "AB-":
            abn_blood.add_to_total(b.volume)
        elif b.blood_type == "O+":
            op_blood.add_to_total(b.volume)
        elif b.blood_type == "O-":
            on_blood.add_to_total(b.volume)

    blood_levels = [ap_blood, an_blood, bp_blood, bn_blood, 
        abp_blood, abn_blood, op_blood, on_blood]

    return blood_levels            


def bubblesort_expiration(blood, asc):
    n = len(blood)
    i = n - 1

    while i > 0:
        j = 0

        while j < i:
            if asc and (blood[j].use_by_date > blood[j + 1].use_by_date):
                blood[j], blood[j + 1] = blood[j + 1], blood[j]
            elif not asc and (blood[j].use_by_date < blood[j + 1].use_by_date):
                blood[j], blood[j + 1] = blood[j + 1], blood[j]

            j += 1

        i -= 1

    return blood


def bubblesort_volume(blood, asc):
    n = len(blood)
    i = n - 1

    while i > 0:
        j = 0

        while j < i:
            if asc and (blood[j].volume > blood[j + 1].volume):
                blood[j], blood[j + 1] = blood[j + 1], blood[j]
            elif not asc and (blood[j].volume < blood[j + 1].volume):
                blood[j], blood[j + 1] = blood[j + 1], blood[j]

            j += 1

        i -= 1

    return blood


def filter_blood_type(blood, blood_type):
    filtered_blood = []

    for b in blood:
        if b.blood_type == blood_type:
            filtered_blood.append(b)

    return filtered_blood
