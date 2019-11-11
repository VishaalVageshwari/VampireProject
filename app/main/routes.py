from flask import render_template, flash, redirect, url_for, request
from app import db
from app.main.forms import AddBloodForm, RequestBloodForm
from app.models import Blood, sort_type_volume, sort_expiry, BloodRequest
from app.main import bp
from datetime import date


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
        print('You added a blood donation to the system')
        flash('You added a blood donation to the system.')
        return redirect(url_for('main.add_blood'))
    return render_template('add_blood.html', title='Add Blood', form=form)


@bp.route('/request_blood', methods=['GET'])
def request_blood():
    form = RequestBloodForm()
    return render_template('request_blood.html', title='Request Blood', form=form)

@bp.route('/view', methods=['GET', 'POST'])
def view_blood():
    today = date.today()
    blood = Blood.query.all()
    blood_sorted = blood
    display_format = 'donation'
    if request.method == 'POST':
        if request.form['sort'] == 'expiry':
             blood_sorted = sort_expiry(blood)
        elif  request.form['sort'] == 'volume':
            blood_sorted = sort_type_volume(blood)
            display_format = 'type'
    return render_template('view_blood.html', blood = blood_sorted, date = today, display_format = display_format)
