from django.shortcuts import render ,redirect
from django.http import HttpResponse
# from django.contrib.auth import authenticate, login
from .models import *
from django.contrib.auth.hashers import make_password,check_password

from django.core.files.storage import FileSystemStorage
from openpyxl import load_workbook
import xlrd
import pandas as pd

# from django.db import connection
# Create your views here.


def index(request):
    if 'user_type' in request.session:
        return redirect('home')
    else:
        return render(request,'index.html')




def login_user(request):
     if request.POST:
        username = request.POST.get('username')
        password = request.POST.get('password')
        # hashed_password = make_password(password)
        # print(hashed_password)
        try:
                
            check_user = login_table.objects.filter(username=username)
            is_user_correct = check_user.values()[0]['username'] == username
            is_correct = check_password(password, check_user.values()[0]['password'])
            # print(is_user_correct,"************************")
        except:
            return redirect('index')


        if is_correct and is_user_correct:
            if check_user.values()[0]['usertype'] == 'admin':
                request.session['user_type'] = 'admin'
                # print(check_user.values()[0]['usertype'])
                return redirect('home')
            else:
                return redirect('index')
        else:
            return redirect('index')


def home(request):

    if 'user_type' in request.session:
        return render(request,'admin_dashboard.html')
    else:
        return redirect('index')

def staff_list(request):

    list_staff = staff.objects.all()
    
    
    # print(list_staff.values())
    return render(request,'stafflist.html',{'staffs':list_staff})

def admin_logout(request):
    if 'user_type' in request.session:
        request.session.flush()
    return redirect('index')


def add_staff(request):

    if request.POST:
        username = request.POST.get('username')
        name = request.POST.get('name')
        staff_type = request.POST.get('staff_type')
        dept = request.POST.get('dept')
        dept_id = department.objects.get(id=dept)
        password = request.POST.get('password')
        hashed_password = make_password(password)
        # print(username,name,staff_type,dept,password)
        user_login = login_table(username = username,password = hashed_password)
        user_login.save()
        

        last_inserted_id = user_login.pk

        l_id = login_table.objects.get(id = last_inserted_id)

        # print(last_inserted_id,'****************************')
        staff_user = staff(name = name,dept = dept_id,stafftype = staff_type,l_id = l_id)
        staff_user.save()
        return redirect("staff_list")

    else:
        try:
            deptmnts = department.objects.all().values()
        except:
            return redirect('staff_list')
        # print(deptmnts,'*******************')
        return render(request,'add_staff.html',{'depts':deptmnts})



def edit_staff(request,id):

    try:
        user = staff.objects.get(pk = id)
    except:
        return HttpResponse('erorr')
    
    # print(user.name,"22222222222222222222")
    return render(request,'edit_staff.html',{'user':user})


def alter_staff(request):
    if request.POST:
        username = request.POST.get('username')
        name = request.POST.get('name')
        key = request.POST.get('id')
        # print(key,'*********************************')
        staff_object = staff.objects.get(id = key )
        
        staff_object.name = name
        staff_object.save()
        login_object = login_table.objects.get(username = staff_object.l_id)
        login_object.username = username
        print(staff_object.l_id,'*****************')
        if request.POST.get('password'):
            password = request.POST.get('password')
            hashed_password = make_password(password)
            login_object.password = hashed_password
        login_object.save()

        
        return redirect('staff_list')
    

def change_status_to_inactive(request,id):
    print(id)
    user = staff.objects.get(pk = id)
    print(user.status)
    if user.status == 'active':
        user.status = 'inactive'
    else:
        user.status = 'active'
    user.save()
    return redirect('staff_list')


def room_list(request):
    
    rooms = hall.objects.all()
    
    return render(request,'view-rooms.html',{'rooms':rooms})


def add_room(request):
    if request.POST:
        hall_name = request.POST.get('hall_name')
        capacity = request.POST.get('capacity')
        room = hall(hall_name = hall_name,capacity = capacity)
        room.save()
        print(capacity)
        return redirect('room_list')
    else:
        return render(request,'add-room.html')

def edit_room(request,id):
    room = hall.objects.get(pk = id)
    print(id,'****************')
    return render(request,'edit_room.html',{'room':room})


def room_edit(request):
    hall_name = request.POST.get('hall_name')
    capacity = request.POST.get('capacity')
    key = request.POST.get('key')

    room = hall.objects.get(pk = key)
    room.hall_name = hall_name
    room.capacity = capacity
    room.save()
    print(hall_name,key)
    return redirect('room_list')



def delete_room(request,id):

    room = hall.objects.get(pk = id)
    room.delete()
    return redirect('room_list')


#seating arrangement

# def seating(request):
    
#     if request.POST:


#         excel_file = request.FILES['appearing_list']
#         if not excel_file.name.endswith('.xls'):
#             return HttpResponse("Your file must be a xls type")
#         fs = FileSystemStorage()
#         filename = fs.save(excel_file.name, excel_file)
#         filepath = fs.path(filename)
#         with open(filepath, 'rb') as file:
#             wb = xlrd.open_workbook(file_contents=file.read())


       
#         sheet = wb.sheet_by_index(0)
#         print(sheet.nrows,"0000000000000000000000000000000000000")
#         print(sheet.ncols)
#         column_names = [cell.value for cell in sheet.row(1)]

#         for row_idx in range(2, sheet.nrows):
#             row = sheet.row_values(row_idx)
            
#             start_index = row[0].find('(')
#             end_index = row[0].find(')')

#             start_index_7 = row[7].find('(')
#             end_index_7 = row[7].find(')')

#             if start_index != -1 and end_index != -1:
#                 name = row[0][0:start_index]
#                 req_no = row[0][start_index+1:end_index]



#             if start_index_7 != -1 and end_index_7 != -1:
#                 course = row[7][0:start_index_7]
#                 course_code = row[7][start_index_7+1:end_index_7]
                
#             print(name,"  ",req_no,"  ",course," ",course_code,"  ",row[4],"  ",row[3])
           

#         return redirect('select_halls')
#     else:

#         return render(request,'upload-list.html')


def select_halls(request):
    if request.POST:
        halls=request.POST.getlist('hall_id')
        ob=studentDetails.objects.filter(schedule__date=request.session['date'],schedule__slot=request.session['session'])
        count=len(ob)
        sublist=[]
        for i in ob:
            if i.subject.id not in sublist:
                sublist.append(i.subject.id)
        studentlist=[]
        for i in sublist:
            obs=studentDetails.objects.filter(subject__id=i)
            studentlist.append(obs)

        countlist=[]
        for i in studentlist:
            obcount=countList()
            obcount.count=len(i)
            # print(i)
            obcount.subject_id=i[0].subject
            obcount.save()
            countlist.append(len(i))

        alocation=[]
        for i in halls:
            hob=hall.objects.get(id=i)
            max_ob=countList.objects.all().order_by('-count')
            print(max_ob)
            maxindex=max_ob[0]
            # print(maxindex,'*************************')
            minindex=max_ob[len(max_ob)-1]
            # print(minindex,'*************************')

            # print(hob.capacity,'****************************')
            
            halldetails=[]
            for ii in range(0,int(hob.capacity/2)):
                if maxindex.count!=0:
                    index=sublist.index(maxindex.subject_id.id)
                    students=studentlist[index]
                    ob_c_stud=students[countlist[index]-maxindex.count]
                    row=[ob_c_stud,(2*ii)+1]
                    halldetails.append(row)
                    maxindex.count=maxindex.count-1;
                    maxindex.save()

                if minindex.count!=0:
                    index=sublist.index(minindex.subject_id.id)
                    students=studentlist[index]
                    ob_c_stud=students[countlist[index]-minindex.count]
                    row=[ob_c_stud,(2*ii)+2]
                    halldetails.append(row)
                    minindex.count=minindex.count-1;
                    minindex.save()

            alocation.append(halldetails)  
        for i in range(0,len(alocation)):
            hid=halls[i]
            # print(i)
            for ii in alocation[i]:
                sid=ii[0]
                sno=ii[1]
                # print(ii,'********/////////')
                
                print(hid,"-",ii[1],"=",ii[0].student,ii[0].subject)
                # scheduleDetails = schedule_details(shedule_id = sid)
                    
                



        
    halls = hall.objects.all()
    return render(request,'hall-allocation.html',{'halls':halls,"count":request.session['count']})







def seating(request):
    
    if request.POST:
        btn=request.POST['btn']
        if btn == 'upload':
            date = request.POST.get('date')
            session = request.POST.get('session')
            request.session['date']=date
            request.session['session']=session
            excel_file = request.FILES['appearing_list']
        
            fs = FileSystemStorage()
            filename = fs.save(excel_file.name, excel_file)
            filepath = fs.path(filename)
            df = pd.read_excel(excel_file)
            for index, row in df.iterrows():
                if index == 1:
                    make_schedule = schedule(date = date,slot = session,exam_name = row[4])
                    make_schedule.save()
                    schedule_id = make_schedule.pk
                    schedule_instance = schedule.objects.get(id = schedule_id)


                if index > 0:

                    
                    start_index = row[0].find('(')
                    end_index = row[0].find(')')

                    start_index_7 = row[7].find('(')
                    end_index_7 = row[7].find(')')

                    if start_index != -1 and end_index != -1:
                        name = row[0][0:start_index]
                        req_no = row[0][start_index+1:end_index]



                    if start_index_7 != -1 and end_index_7 != -1:
                        course = row[7][0:start_index_7]
                        course_code = row[7][start_index_7+1:end_index_7]
                        
                    # print(name,"  ",req_no,"  ",course," ",course_code,"  ",row[4],"  ",row[3])
                    
                    try:
                        sub_obj = subject.objects.get(code = course_code)
                    except:
                        sub_obj = None
                    if sub_obj is not None:
                        sub_instance = sub_obj
                    else:
                        sub_details = subject(code = course_code,branch = row[3],sub_name = course)
                        sub_details.save()
                        sub_id = sub_details.pk
                        sub_instance = subject.objects.get(id = sub_id)

                    student_details = studentDetails(reg_no = req_no,student = name,subject = sub_instance,schedule = schedule_instance)
                    student_details.save()
            return render(request,'upload-list.html')
        else:
            ob=studentDetails.objects.filter(schedule__date=request.session['date'],schedule__slot=request.session['session'])
            count=len(ob)
            request.session['count']=count
            return redirect('select_halls')
    else:

        return render(request,'upload-list.html')


def duties(request):
    return render(request,'view-duties.html')


def allocate_duties(request):
    return render(request,'Allocate-Duties.html')