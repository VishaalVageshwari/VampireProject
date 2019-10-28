# VampireProject

SENG2011 Blood Management System for the group 'The Boys'


Instructions for setup

1. Create a virtual environement for python3, there are a few ways to do this. I choose to do this by doing (note I only had python3 and am working on a windows machine you may have to specify the version):

```mkvirtualenv vampire```

2. Activate your virtual env
For me I did: 

```workon vampire```

With vampire being the name of my virtual environment but it'll 

3. Install dependencies
Change directory to vampireproject where requriements.txt is and do:

```pip install -r requirements.txt```

4. Create a dot-env file
In the same directory create a file called .env.
Put the folloing things in that file:

```FLASK_APP=vampire.py```

```FLASK_ENV=development```

Optionally you can also put a secret key in there:
    
```SECRET_KEY=WhateverYouWant```

5. Intialize the database. I'm using flask-SQLAlchemy and a flask-migrate for database stuff so you might (probally will) want to have a look into those. Have a look at the db models they're in models.py and when your fine with those use these commands (you only need to run the last command cause I've included a migration file):

```flask db init ```

```flask db migrate 'blood table'```

```flask db upgrade```

6. Run flask app

```flask run```


There are quite a few packages I'm using to make the project easier that you should look into. These are flask-sqlalchemy, flask-migrate, flask-boostrap, wtforms (for forms) with flask-wtf and then standard things flask comes with Jinja (templates), Werkzeug (security) and Click (custom commands). Blueprints in flask are important to but I don't think you'll need to add anything over what I've already done with regards to that at least till putting in login.

