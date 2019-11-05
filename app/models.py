from datetime import datetime
from app import db
from werkzeug.security import generate_password_hash, check_password_hash


# Donor's information is stored with blood because of the scope of the subsystem.
# Marking blood for disposal should be derived from suitablity and use-by-date.
# Requestable blood is all blood that is not marked for disposal or attached to an order.
class Blood(db.Model):
    __tablename__ = 'blood'

    id = db.Column(db.Integer, primary_key=True)
    blood_type = db.Column(db.String(3), nullable=False)
    volume = db.Column(db.Integer, nullable=False)
    suitablity = db.Column(db.Boolean, nullable=False)
    use_by_date = db.Column(db.Date, nullable=False)
    location_donated = db.Column(db.Text, nullable=False)
    blood_donor_name = db.Column(db.Text, nullable=False)
    blood_donor_email = db.Column(db.Text, nullable=False)

    __table_args__ = (
        db.CheckConstraint("volume > 0", name='check_volume'),
    )

    def __repr__(self):
        return '<Blood [ID : {0}], [Blood Type : {1}], [Blood Donor : {2}]>'\
            .format(self.id, self.blood_type, self.blood_donor_name)


# Each blood request has one or more blood types they request
class RequestedBlood(db.Model):
    __tablename__ = 'requested_blood'

    blood_type = db.Column(db.String(3), primary_key=True)
    volume = db.Column(db.Integer, nullable=False)
    blood_request_id = db.Column(db.Integer, db.ForeignKey('blood_request.id'))

    __table_args__ = (
        db.CheckConstraint("volume > 0", name='check_requested_volume'),
    )

    def __repr__(self):
        return '<Requested Blood [Blood Request ID : {1}], [Blood Type : {2}], [Volume : {3}]>'\
            .format(self.blood_request_id, self.blood_type, self.volume)


# Request for blood by medical facilities. Remove request if order is made.
class BloodRequest(db.Model):
    __tablename__ = 'blood_request'

    id = db.Column(db.Integer, primary_key=True)
    created = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    date_required = db.Column(db.Date, nullable=False)

    def __repr__(self):
        return '<Blood Request [ID : {1}], [Date : {2}]>'\
            .format(self.id, self.created, self.date_required)


# When displaying order group orders heading to the same medical facility on the same date.
class BloodOrder(db.Model):
    __tablename__ = 'blood_order'

    medical_id = db.Column(db.Integer, db.ForeignKey('medical_facility.id'), primary_key=True)
    blood_id = db.Column(db.Integer, db.ForeignKey('blood.id'), unique=True, primary_key=True)
    created = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    date_required = db.Column(db.Date, nullable=False)

    def __repr__(self):
        return '<Blood Order [Medical ID : {1}], [Blood ID : {2}] [Date : {3}]>'\
            .format(self.id, self.blood_id, self.date_required)
    

# Medical facility has a id and password they are given to verify them when
# making requests for blood but they don't login.
class MedicalFacility(db.Model):
    __tablename__ = 'medical_facility'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.Text, nullable=False)
    address = db.Column(db.Text, nullable=False)
    password_hash = db.Column(db.String(128), nullable=False)

    def __repr__(self):
        return '<Medical Facility [Name : {0}], [ID : {1}]>'.format(self.name, self.id)

    def set_password(self, password):
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

#sorts blood donations by expiry date
def sort_expiry(blood):
    #bubble sort
    for i in range(len(blood)):
        for j in range(0, len(blood)-i-1):
            if blood[j].use_by_date > blood[j+1].use_by_date :
                blood[j], blood[j+1] = blood[j+1], blood[j]
    return blood
#for displaying the total volume for each blood type
class BloodTypeVolume:
    def __init__(self, blood_type, volume):
        self.blood_type = blood_type
        self.volume = volume
#returns list of BloodTypeVolume sorted by volume
#only counts volume of blood donation if not expired
def sort_type_volume(blood):
    a_plus,a_minus,b_plus,b_minus,ab_plus,o_plus,o_minus = 0,0,0,0,0,0,0
    for i in range(len(blood)):
        #skip expired blood
        if blood[i].use_by_date <= datetime.today().date():
            continue
        if blood[i].blood_type == 'A+':
            a_plus+=blood[i].volume
        elif blood[i].blood_type == 'A-': 
            a_minus+=blood[i].volume
        elif blood[i].blood_type == 'AB+': 
            ab_plus+=blood[i].volume
        elif blood[i].blood_type == 'B+': 
            b_plus+=blood[i].volume
        elif blood[i].blood_type == 'B-': 
            b_minus+=blood[i].volume
        elif blood[i].blood_type == 'O+': 
            o_plus+=blood[i].volume
        elif blood[i].blood_type == 'O-': 
            o_minus+=blood[i].volume
    #list of BloodTypeVolume objects
    type_volumes = [BloodTypeVolume("A+",a_plus),BloodTypeVolume("A-",a_minus),BloodTypeVolume("B+",b_plus),BloodTypeVolume("B-",b_minus),BloodTypeVolume("AB+",ab_plus),BloodTypeVolume("O+",o_plus),BloodTypeVolume("O-",o_minus)]
    #bubble sort type_volume by volume
    for i in range(len(type_volumes)):
        for j in range(0, len(type_volumes)-i-1):
            if type_volumes[j].volume > type_volumes[j+1].volume :
                type_volumes[j], type_volumes[j+1] = type_volumes[j+1], type_volumes[j]
    return type_volumes
   
