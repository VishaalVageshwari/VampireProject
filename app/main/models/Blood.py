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
            .format(self.id, self.blood_type, self.donor_name)


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

    for index, b in enumerate(blood):
        if b.ordered or not b.suitablity or current_date > b.use_by_date:
            del blood[index]

    return blood


def bubblesort_expiration(blood, asc):
    n = len(blood)
    i = n - 1

    while i > 0:
        j = 0

        while j < i:
            if asc and (a[j].use_by_date > a[j + 1].use_by_date):
                a[j], a[j + 1] = a[j + 1], a[j]
            elif not asc and (a[j].use_by_date < a[j + 1].use_by_date)
                a[j], a[j + 1] = a[j + 1], a[j]

            j += 1
    
    i -= 1