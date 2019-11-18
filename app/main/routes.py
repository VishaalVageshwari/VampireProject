from flask import render_template, flash, redirect, url_for, request
from app import db
from app.main.forms import AddBloodForm, ViewBloodForm, RequestBloodForm
from app.models import Blood as dbBlood, RequestedBlood, BloodRequest, BloodOrder
from app.main import bp
from app.main.models.Blood import Blood, BloodTypeLevel, get_requestable_blood, \
    bubblesort_expiration, bubblesort_volume, filter_blood_type, get_blood_levels, \
    get_ordered_blood, get_total_blood_volume, get_disposable_blood
from datetime import date
from app.main.request import allocate_blood

@bp.route('/', methods=['GET'])
@bp.route('/index', methods=['GET'])
def index():
    blood_levels = get_blood_levels()
    return render_template('index.html', title='Home', blood_levels=blood_levels)


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
    blood = get_requestable_blood()
    bloodID = -1
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
                blood = bubblesort_expiration(blood, True)
            elif sort_type == 'Use-By-Date: Latest-Earliest':
                blood = bubblesort_expiration(blood, False)
    return render_template('view_blood.html', title='View Blood', blood=blood, form=form)

@bp.route('/request_blood', methods=['GET', 'POST'])
def request_blood():
    form = RequestBloodForm()
    if form.validate_on_submit():
        blood_type = form.blood_type.data
        volume = form.volume.data
        delivery_date = form.delivery_date.data
        blood = allocate_blood(blood_type=blood_type, volume=volume, delivery_date=delivery_date)
        if blood is None:
            flash('Not enough suitable blood to satisfy the request')
        else:
            for donation in blood:
                order = BloodOrder(medical_id=0, blood_id=donation.blood_id, date_required=delivery_date)
                db.session.add(order)
            db.session.commit()
            flash('Your request has been successfully made')

    return render_template('request_blood.html', title='Request Blood', form=form)


@bp.route('/ordered', methods=['GET', 'POST'])
def ordered_blood():
    form = ViewBloodForm()
    blood = get_ordered_blood()
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
    return render_template('view_ordered.html', title='View Blood', blood=blood, form=form)


@bp.route('/', methods=['GET'])
@bp.route('/blood_levels', methods=['GET'])
def blood_levels():
    blood_levels = get_blood_levels()
    blood_total = get_total_blood_volume()
    return render_template('blood_levels.html', title='Blood Levels', blood_total=blood_total, blood_levels=blood_levels)


@bp.route('/remove_blood', methods=['GET', 'POST'])
def remove_blood():
    form = ViewBloodForm()
    blood = get_disposable_blood()
    bloodID = -1
    if request.method == 'POST':
        if "remove" in request.form:
            bloodId = request.form.get("remove")
            blood_to_remove = dbBlood.query.get(bloodId)
            db.session.delete(blood_to_remove)
            db.session.commit()
            blood = get_disposable_blood()
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
    return render_template('remove_blood.html', title='Remove Blood', blood=blood, form=form)
