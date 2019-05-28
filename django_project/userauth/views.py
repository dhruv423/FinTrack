from django.http import HttpResponse
from django.contrib.auth.models import User
from django.contrib.auth import authenticate, login, logout
from django.http import JsonResponse
import json
from .models import UserInfo, ExpenseInfo, LoanInfo
from django.db import IntegrityError

# Function for adding user to the database
def add_user(request):
    """recieves a json request containing username and password, saves it to the database
        and logs them in """
    
    try:
        json_req = json.loads(request.body)
        uname = json_req.get('username','')
        passw = json_req.get('password','')
        
        if uname != '':
            
            newUser = UserInfo.objects.create_user_info(username=uname,password=passw)
            user = authenticate(request, username=uname, password=passw)
            newUser.save()
            return HttpResponse('Created')
        else:
            return HttpResponse('Failed')
    # catch the unique username error
    except IntegrityError:
        return HttpResponse('Exists')
        pass


# Function for checking authentication
def is_auth(request):
    if request.user.is_authenticated:
        return HttpResponse("IsAuth")
    else:
        return HttpResponse("NotAuth")

# Function to logging user
def login_user(request):
    """recieves a json request { 'username' : 'val0' : 'password' : 'val1' } and
        authenticates and loggs in the user upon success """
    
    json_req = json.loads(request.body)
    uname = json_req.get('username','')
    passw = json_req.get('password','')
    
    user = authenticate(request,username=uname,password=passw)
    if user is not None:
        login(request,user)
        return HttpResponse('LoggedIn')
    else:
        return HttpResponse('LoginFailed')

# Logout User -- Built-in Django
def logout_user(request):
    logout(request)
    return HttpResponse("LoggedOut")

# Send an JSON Response with the current values in database
def get_user_info(request):
    user = UserInfo.objects.get(user=request.user)
    uInfo = {}
    uInfo["income"] = float(user.income)

    sumG = 0
    sumE = 0
    sumO = 0
    # Get all the expense info objects associated with the user logged in
    for i in ExpenseInfo.objects.filter(e1 = user):
        if i.expenseType == 'Groceries':
            sumG += float(i.expenseVal)
        elif i.expenseType == 'Entertainment':
            sumE += float(i.expenseVal)
        elif i.expenseType == 'Other':
            sumO += float(i.expenseVal)

    uInfo["groceries"] = sumG
    uInfo["entertainment"] = sumE
    uInfo["otherE"] = sumO

    sumRVal = 0
    sumRI = 0
    sumOVal = 0
    sumOI = 0
    # Get all the loan info objects associated with the user logged in
    for i in LoanInfo.objects.filter(l1 = user):
        if i.loanType == 'Residential':
            sumRVal += float(i.loanVal)
            sumRI += (float(i.loanVal) * (1 + ((float(i.loanInterest)/100) * float(i.loanPeriod))) - float(i.loanVal)) # Finding Simple Interest on amount
        elif i.loanType == 'Other':
            sumOVal += float(i.loanVal)
            sumOI += (float(i.loanVal) * (1 + ((float(i.loanInterest)/100) * float(i.loanPeriod))) - float(i.loanVal)) # Finding Simple Interest on amount

    uInfo["resL"] = sumRVal
    uInfo["resLI"] = sumRI
    uInfo["otL"] = sumOVal
    uInfo["otLI"] = sumOI
    
    print(uInfo)
    return JsonResponse(uInfo)


# Save the information from the front end
def save_user_info(request):
    json_req = json.loads(request.body)
    income = json_req.get('Income', '')
    expenseval = json_req.get('ExpenseVal', '')
    expensetype = json_req.get('ExpenseType', '')
    loanval = json_req.get('LoanVal', '')
    loanperiod = json_req.get('LoanPeriod', '')
    loaninterest = json_req.get('LoanInterest', '')
    loantype = json_req.get('LoanType', '')
    

    user = UserInfo.objects.get(user = request.user)

    user.income = income
    user.save()
    
    tmp = UserInfo.objects.get(user=request.user)
    exp = ExpenseInfo(id = None,expenseVal = expenseval, expenseType = expensetype, e1 = tmp ) # Create new expense object with that users account
    loan = LoanInfo(id = None, loanVal = loanval, loanPeriod = loanperiod, loanInterest = loaninterest, loanType = loantype, l1 = tmp) # Create new loan object with that users account
    exp.save()
    loan.save()
    return HttpResponse("InformationUpdated")

