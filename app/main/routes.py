from flask import render_template, flash, redirect, url_for, request
from app import db
from app.main.forms import AddBloodForm, ViewBloodForm
from app.models import Blood as dbBlood
from app.main import bp
from app.main.models.Blood import Blood, get_requestable_blood, bubblesort_expiration, bubblesort_volume, filter_blood_type
from datetime import date

@bp.route('/', methods=['GET'])
@bp.route('/index', methods=['GET'])
def index():
  return render_template('index.html', title='Home')


@bp.route('/add_blood', methods=['GET', 'POST'])
def add_blood():
    form = AddBloodForm()
    if form.validate_on_submit():
        blood = dbBlood(blood_type=form.blood_type.data, volume=form.volume.data,
                suitablity=form.suitablity.data, use_by_date=form.use_by_date.data,
                location_donated=form.location_donated.data, blood_donor_name=form.donor_name.data,
                blood_donor_email=form.donor_email.data)
        db.session.add(blood)
        db.session.commit()
        print('You added a blood donation to the system')
        flash('You added a blood donation to the system.')
        return redirect(url_for('main.add_blood'))
    return render_template('add_blood.html', title='Add Blood', form=form)


@bp.route('/view', methods=['GET', 'POST'])
def view_blood():
    form = ViewBloodForm()
    today = date.today()
    blood = get_requestable_blood()
    display_format = 'donation'
    bloodID = -1
    if request.method == 'POST':
        if "remove" in request.form:
            flash(request.form.get("remove"))
            bloodId = request.form.get("remove")
            blood_to_remove = dbBlood.query.get(bloodId)
            db.session.delete(blood_to_remove)
            db.session.commit()
            blood = get_requestable_blood()
        elif form.validate_on_submit():
            filter_type = form.filter_type.data
            sort_type = form.sort_blood.data
            if filter_type != 'No Filter':
                blood = filter_blood_type(blood, filter_type)

            if sort_type == 'Volume: Low-High':
                blood = bubblesort_volume(blood, True)
            elif sort_type == 'Volume: High-Low':
                blood = bubblesort_volume(blood, False)
            elif sort_type == 'Use-By-Date: Earliest-Latest':
                blood = bubblesort_expiration(blood, True)
            elif sort_type == 'Use-By-Date: Latest-Earliest':
                blood = bubblesort_expiration(blood, False)
    return render_template('view_blood.html', title='View Blood', blood=blood, form=form)

@bp.route('/request_blood', methods=['GET'])
def request_blood():
    return render_template('request_blood.html', title='Request Blood')
