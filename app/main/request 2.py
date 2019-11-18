from app.models import Blood, sort_expiry

def is_suitable_type(blood, blood_type):
    # TODO: can account for compatible blood types
    return blood.blood_type == blood_type

def not_expired(blood, delivery_date):
    return blood.use_by_date >= delivery_date

def has_volume(suitable_blood, volume):
    has_volume = 0
    for blood in suitable_blood:
        has_volume += blood.volume
    return has_volume >= volume

def allocate_blood(blood_type, volume, delivery_date):
    # get all the blood in the system
    blood_entries = Blood.query.all()

    # get all the suitable blood for the request
    suitable_blood = []
    for blood in blood_entries:
        suitable_type = is_suitable_type(blood, blood_type)
        suitable_date = not_expired(blood, delivery_date)
        if blood.suitablity and suitable_type and suitable_date:
            suitable_blood.append(blood)

    # check there is enough suitable blood
    if not has_volume(suitable_blood, volume):
        return None

    # allocate blood, prioritising blood that expires soonest
    suitable_blood = sort_expiry(suitable_blood)

    allocation = []
    for blood in suitable_blood:
        if not has_volume(allocation, volume):
            allocation.append(blood)

    return allocation
