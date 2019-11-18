from flask import request
from flask_wtf import FlaskForm
from wtforms import SelectField, IntegerField, DateField, BooleanField, StringField, SubmitField
from wtforms.validators import ValidationError, InputRequired, Email
from app.models import Blood

BLOOD_TYPES = [('A+', 'A+'), ('A-', 'A-'), ('B+', 'B+'), ('B-', 'B-'), 
    ('AB+', 'AB+'), ('AB+', 'AB+'), ('O+', 'O+'), ('O-', 'O-')]

SORT_TYPES = [('Default', 'Default'),('Volume: Low-High', 'Volume: Low-High'),
    ('Volume: High-Low', 'Volume: High-Low'), ('Use-By-Date: Earliest-Latest', 'Use-By-Date: Earliest-Latest'),
    ('Use-By-Date: Latest-Earliest', 'Use-By-Date: Latest-Earliest')]

FILTER_TYPES = [('No Filter', 'No Filter')] + BLOOD_TYPES

class AddBloodForm(FlaskForm):
    blood_type = SelectField('Blood Type', choices=BLOOD_TYPES, validators=[InputRequired()])
    volume = IntegerField('Volume In Liters', validators=[InputRequired()])
    use_by_date = DateField('Use-By-Date', format='%d-%m-%Y', render_kw={"placeholder": "dd-mm-yyyy"}, validators=[InputRequired()])
    location_donated = StringField('Location Donated', validators=[InputRequired()])
    donor_name = StringField('Donor\'s Full Name', validators=[InputRequired()])
    donor_email = StringField('Donor\'s Email', validators=[InputRequired(), Email()])
    suitablity = BooleanField('Suitable For Use')
    submit = SubmitField('Submit')

    def validate_blood_type(self, blood_type):
        if (blood_type.data != 'A+' and blood_type.data != 'A-' and
            blood_type.data != 'B+' and blood_type.data != 'B-' and
            blood_type.data != 'AB+' and blood_type.data != 'AB-' and
            blood_type.data != 'O+' and blood_type.data != 'O-'):
            raise ValidationError('Invalid blood type. Please enter valid blood type')

    def validate_volume(self, volume):
        if volume.data <= 0:
            raise ValidationError('Blood volume must be greater than 0 liters.')

    def validate_suitablity(self, suitablity):
        if suitablity.data != True and suitablity.data != False:
            raise ValidationError('Blood suitablity is neither true or false.')

class ViewBloodForm(FlaskForm):
    filter_type = SelectField('Filter By Blood Type', choices=FILTER_TYPES, validators=[InputRequired()])
    sort_blood = SelectField('Sort Blood', choices=SORT_TYPES, validators=[InputRequired()])
    submit = SubmitField('Confirm')