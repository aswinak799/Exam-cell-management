from django.shortcuts import render ,redirect
from django.http import HttpResponse
# from django.contrib.auth import authenticate, login
from .models import *
from django.contrib.auth.hashers import make_password,check_password
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

def seating(request):
    # file1 = request.FILES['appearing_list']
    # file_name = FileSystemStorage()
    # fs = file_name.save(file1.name,file1)

    return render(request,'upload-list.html')



