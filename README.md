# FinTrack
This is the final project pertaining to this course. FinTrack is an online financial tracker which tracks expenses and loans and displays them in a graphical view.

## Setting Up

* Clone this repository by either downloading it or `git clone https://github.com/bhavsd1/CS1XA3.git` to your prefered location 
* Create a Python Virtual Environment by `python3 -m venv envirname` in the same location as repo
* Go in the virtual environment `cd envirname` and start it up `source bin/activate` 
* Verify that you have the environment name in the front of the line in terminal 
* Navigate back `cd ..` 
* Install the required packages to run this app `pip install -r requirements.txt` 
* After that is done downloading, go to the `django_project` folder `cd CS1XA3/Project03/django_project`
* Collect the static files for running the server `python3 manage.py collectstatic`
* Run the Django server `python3 manage.py runserver localhost:8000` 
* Open up your browser and go to [http://localhost:8000/static/project03.html](http://localhost:8000/static/project03.html)
* Now create an account and play around with the app!


## Features

**Client Side**

* Use of GraphicSVG and Html.Events
* Created graphs from the shapes in Graphics SVG
* Login Page
* Register Page 
* Adds Expense Info to the database to keep track 
* Adds Loan Info to the database to keep track of principal amount and the interest build up
* Usage of JSON Encode to encode password, username, LoanInfo and ExpenseInfo
* Usage of JSON Decode to decode the information recieved from the database

**Backend (Django)**

* userauth app is used for user authentication related request - Login page for the user to get a custom dashboard, register page to create many users
* Models such as ExpenseInfo, LoanInfo, UserInfo and built-in User
* ExpenseInfo and LoanInfo are Foreign Key Relationships with the UserInfo object



## Resources
The website for FinTrack was made from [SB Admin Free Bootstrap Template](https://startbootstrap.com/templates/sb-admin/) including the CSS.
The login and register page is modelled after [ColorLib Free Login Form](https://colorlib.com/wp/template/login-form-v2/).
Most of the elm view functions are converted from html using a Html to Elm converter. Then it is appropriately adjusted to fit the requirements.
