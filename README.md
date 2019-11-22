# VampireProject

SENG2011 Blood Management System for the group 'The Boys'


Instructions for setup

1. Create a virtual environement for python3, there are a few ways to do this. I choose to do this by doing (note I only had python3 and am working on a windows machine you may have to specify the version):

```virtualenv venv```

2. Activate your virtual env

```.\venv\Scripts\activate```

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

5. Intialize the database. I'm using flask-SQLAlchemy and a flask-migrate for database stuff. Run this command to set it up:


```flask db upgrade```

6. Run flask app

```flask run```
