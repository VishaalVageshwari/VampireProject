from flask import render_template, redirect, url_for, request
from app.main import bp

@bp.route('/', methods=['GET'])
@bp.route('/index', methods=['GET'])
def index():
  return render_template('index.html', title='Home')

@bp.route('/request_blood', methods=['GET'])
def requestBloodPage():
  return render_template('request_blood.html', title='Request Blood')