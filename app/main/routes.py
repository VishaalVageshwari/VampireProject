from flask import render_template, redirect, url_for, request
from app.main import bp

@bp.route('/', methods=['GET'])
@bp.route('/index', methods=['GET'])
def index():
  return render_template('index.html', title='Home')

@bp.route('/requestBlood', methods=['GET'])
def requestBloodPage():
  return render_template('requestBloodPage.html', title='Medical Staff')

@bp.route('/vampireStaff', methods=['GET'])
def vampireStaffPage():
  return render_template('vampireStaffPage.html', title='Vampire Staff')

@bp.route('/bloodBank', methods=['GET'])
def bloodBankPage():
  return render_template('bloodBankPage.html', title='Blood Bank')

@bp.route('/depositeBlood', methods=['GET'])
def depositBloodPage():
  return render_template('depositBloodPage.html', title='Deposit Blood')
