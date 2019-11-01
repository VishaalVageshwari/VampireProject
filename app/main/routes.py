from flask import render_template, flash, redirect, url_for, request
from app import db
from app.main.forms import AddBloodForm
from app.models import Blood
from app.main import bp


@bp.route('/', methods=['GET'])
@bp.route('/index', methods=['GET'])
def index():
    return render_template('index.html', title='Home')

@bp.route('/add_blood', methods=['GET', 'POST'])
def add_blood():
    form = AddBloodForm()
    if form.validate_on_submit():
        blood = Blood(blood_type=form.blood_type.data, volume=form.volume.data,
                suitablity=form.suitablity.data, use_by_date=form.use_by_date.data, 
                location_donated=form.location_donated.data, blood_donor_name=form.donor_name.data, 
                blood_donor_email=form.donor_email.data)
        db.session.add(blood)
        db.session.commit()
        flash('You added a blood donation to the system.')
        return redirect(url_for('main.add_blood'))
    return render_template('add_blood.html', title='Add Blood', form=form)