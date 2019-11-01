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