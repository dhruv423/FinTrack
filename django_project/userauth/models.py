from django.db import models
from django.contrib.auth.models import User

# Creating the user
class UserInfoManager(models.Manager):
    def create_user_info(self, username, password):
        user = User.objects.create_user(username=username,password=password)
        userinfo = self.create(user=user)
                                        
        return userinfo

# Creates the fields associated with the user
class UserInfo(models.Model):
    user = models.OneToOneField(User,
                                on_delete=models.CASCADE,
                                primary_key=True)
        
    # Information about User
    income = models.CharField(default="1000",max_length=60)
    objects = UserInfoManager()

# Foreign Key relationship for ExpenseInfo
class ExpenseInfo(models.Model):
    
    expenseVal = models.CharField(default="50", max_length=60, blank = "True")
    expenseType = models.CharField(max_length=60, default="Other")
    
    
    e1 = models.ForeignKey(UserInfo, on_delete=models.CASCADE)

# Foreign Key relationship for LoanInfo
class LoanInfo(models.Model):
    
    loanVal = models.CharField(default="",max_length=60, blank = "True")
    loanPeriod = models.CharField(default="",max_length=60, blank = "True")
    loanInterest = models.CharField(default="",max_length=60, blank = "True")
    loanType = models.CharField(max_length=60, default="Residential")
    
    l1 = models.ForeignKey(UserInfo, on_delete=models.CASCADE)



