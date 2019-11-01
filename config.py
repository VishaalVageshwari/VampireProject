import os

# Define app directory
baseDir = os.path.abspath(os.path.dirname(__file__))

class Config:
    # General Config
    DEBUG = True
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'that-bat-is-a-vampire'

    # Set up for SQLAlchemy with sqlite
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or \
        'sqlite:///' + os.path.join(baseDir, 'vampire.db')
    SQLALCHEMY_TRACK_MODIFICATIONS = False