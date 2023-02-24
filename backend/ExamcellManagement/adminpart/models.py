from django.db import models
from django.contrib.auth.models import AbstractUser
# Create your models here.


class login_table(models.Model):
    username = models.CharField(max_length=90)
    password = models.CharField(max_length=90)
    usertype = models.CharField(max_length=20,default='staff')
    def __str__(self):
        return self.username
    
class department(models.Model):
    d_name = models.CharField(max_length=50)
    def __str__(self):
        return self.d_name

class staff(models.Model):
    name = models.CharField(max_length=50)
    dept = models.ForeignKey(department,on_delete=models.CASCADE)
    stafftype = models.CharField(max_length=20)
    l_id = models.ForeignKey(login_table,on_delete=models.CASCADE)
    status = models.CharField(max_length=10,default='active')

class hall(models.Model):
    hall_name = models.CharField(max_length=10)
    capacity = models.IntegerField()


class staff_allocation(models.Model):
     staff_id = models.ForeignKey(staff,on_delete=models.CASCADE)
     hall_id = models.ForeignKey(hall,on_delete=models.CASCADE)
     date = models.DateField()


class schedule(models.Model):
    date = models.DateField()
    slot = models.CharField(max_length=25)
    exam_name = models.CharField(max_length=150)


class subject(models.Model):
    code = models.CharField(max_length=20)
    branch = models.CharField(max_length=20)
    sub_name = models.CharField(max_length=100)



class schedule_details(models.Model):
    shedule_id = models.ForeignKey(schedule,on_delete=models.CASCADE)
    hall_id = models.ForeignKey(hall,on_delete=models.CASCADE)
    reg_no = models.CharField(max_length=25)
    student = models.CharField(max_length=100)
    subject_id = models.ForeignKey(subject,on_delete=models.CASCADE)

class staff_Attendance(models.Model):
    staff_id = models.ForeignKey(staff,on_delete=models.CASCADE)
    date = models.DateField()
    exam_name = models.CharField(max_length=150)
    status = models.IntegerField()

class malpractice(models.Model):
    hall_id = models.ForeignKey(hall,on_delete=models.CASCADE)
    datetime = models.DateTimeField()
    image = models.ImageField()
    status = models.BooleanField()

class report_malpractice(models.Model):
    image = models.ImageField()
    message = models.CharField(max_length=250)
    staff_id = models.ForeignKey(staff,on_delete=models.CASCADE)
    


