from app.models import Blood

def is_suitable_type(blood, blood_type):
    return blood.blood_type == blood_type

def not_expired(blood, delivery_date):
    return blood.use_by_date >= delivery_date

def has_volume(suitable_blood, volume):
    has_volume = 0
    for blood in suitable_blood:
        has_volume += blood.volume
    return has_volume >= volume

def allocate_blood(blood_type, volume, delivery_date):
    blood_entries = Blood.query.all()

    suitable_blood = []

    for blood in blood_entries:
        suitable_type = is_suitable_type(blood, blood_type)
        suitable_date = not_expired(blood, delivery_date)
        if suitable_type and suitable_date:
            suitable_blood.append(blood)

    if not has_volume(suitable_blood, volume):
        return None

    # TODO: remove unneeded blood
