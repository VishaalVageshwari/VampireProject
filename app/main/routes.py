from flask import render_template, flash, redirect, url_for, request
from app import db
from app.main.forms import AddBloodForm, ViewBloodForm, RequestBloodForm
from app.models import Blood as dbBlood
from app.main import bp
from app.main.models.Blood import Blood, get_requestable_blood, bubblesort_expiration, \
    bubblesort_volume, filter_blood_type
from datetime import date
from app.main.request import allocate_blood


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
    if request.method == 'POST':
        if form.validate_on_submit():
            filter_type = form.filter_type.data
            sort_type = form.sort_blood.data

            if filter_type != 'No Filter':
                blood = filter_blood_type(blood, filter_type)

            if sort_type == 'Volume: Low-High':
                blood = bubblesort_volume(blood, True)
            elif sort_type == 'Volume: High-Low':
                blood = bubblesort_volume(blood, False)
            elif sort_type == 'Use-By-Date: Earliest-Latest':
                blood = bubblesort_volume(blood, True)
            elif sort_type == 'Use-By-Date: Latest-Earliest':
                blood = bubblesort_volume(blood, False)
    return render_template('view_blood.html', title='View Blood', blood=blood, form=form)

# @bp.route('/request_blood', methods=['GET'])
# def request_blood():
#     return render_template('request_blood.html', title='Request Blood')

@bp.route('/request_blood', methods=['GET', 'POST'])
def request_blood():
    form = RequestBloodForm()
    if form.validate_on_submit():
        blood_type = form.blood_type.data
        volume = form.volume.data
        delivery_date = form.delivery_date.data

        # TODO: make a BloodRequest and put it in the db
        blood = allocate_blood(blood_type=blood_type, volume=volume, delivery_date=delivery_date)
        if blood is None:
            flash('Not enough suitable blood to satisfy the request')
        else:
            blood = get_requestable_blood()
            blood = bubblesort_volume(blood, True)
            volumeReceived = 0
            for i in blood:
                if i.blood_type == blood_type and volumeReceived < volume:
                    volumeReceived = volumeReceived + 1
                    i.volume = i.volume - 1
                    if i.volume == 0 :
                        blood.remove(i)

            flash('Your request has been successfully made')

    return render_template('request_blood.html', title='Request Blood', form=form)
