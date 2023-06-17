from django.shortcuts import render ,redirect
# from rest_framework import status
from django.http import HttpResponse ,JsonResponse
import datetime
import time

from adminpart.decorators import custom_login_required
# from django.contrib.auth import authenticate, login
from .models import *
from django.contrib.auth.hashers import make_password,check_password
from django.views.decorators.csrf import csrf_exempt
from django.core.files.storage import FileSystemStorage
# from openpyxl import load_workbook
# import xlrd
import pandas as pd
from django.db import connection
# from django.db import connection
# Create your views here.
from reportlab.lib.styles import getSampleStyleSheet,ParagraphStyle
from reportlab.lib.pagesizes import letter, landscape
from reportlab.lib import colors,pagesizes
from reportlab.lib.units import inch
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle,Paragraph
from reportlab.platypus.flowables import KeepTogether, Spacer
from reportlab.lib.enums import TA_CENTER,TA_LEFT,TA_RIGHT

def index(request):
    if 'user_type' in request.session:
        return redirect('home')
    else:
        # login_err = None
        try:
            login_err = request.session['login_err']
            request.session['login_err'] = None
        except:
            login_err = None

        return render(request,'index.html',{'err':login_err})




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
                request.session['is_logged_in'] = True
                request.session['user_type'] = 'admin'
                # print(check_user.values()[0]['usertype'])
                return redirect('home')
            else:
                request.session['login_err'] = 'Incorrect Username or Password'
                return redirect('index')
        else:
            request.session['login_err'] = 'Incorrect Username or Password'
            return redirect('index')

@custom_login_required
def home(request):

    if 'user_type' in request.session:
        return render(request,'admin_dashboard.html')
    else:
        return redirect('index')

def staff_list(request):
    if 'user_type' in request.session:
        try:
            add_success = request.session['add_success']
            request.session['add_success'] = None
        except:
            add_success = None
        list_staff = staff.objects.all()
        
        # print(list_staff.values())
        return render(request,'stafflist.html',{'staffs':list_staff,'message':add_success})
    else:
        return redirect('index')

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
        try:
            user_login = login_table(username = username,password = hashed_password)
            user_login.save()
        except:
            request.session['staff_err'] = 'Username already exist'
            return redirect('add_staff')
        

        last_inserted_id = user_login.pk

        l_id = login_table.objects.get(id = last_inserted_id)

        # print(last_inserted_id,'****************************')
        staff_user = staff(name = name,dept = dept_id,stafftype = staff_type,l_id = l_id)
        staff_user.save()
        request.session['add_success'] = name
        return redirect("staff_list")

    else:
        if 'user_type' in request.session:
            try:
                deptmnts = department.objects.all().values()
                staff_err = request.session['staff_err']
                request.session['staff_err'] = None
            except:
                staff_err = None
            # print(deptmnts,'*******************')
            return render(request,'add_staff.html',{'depts':deptmnts,'err':staff_err})
        else:
            return redirect('index')



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
        print(staff_object.l_id.id,'*****************')
        login_object = login_table.objects.get(id = staff_object.l_id.id)
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

@custom_login_required
def room_list(request):
    rooms = hall.objects.all()
    return render(request,'view-rooms.html',{'rooms':rooms})
    

@custom_login_required
def add_room(request):
    if request.POST:
        hall_name = request.POST.get('hall_name')
        capacity = request.POST.get('capacity')
        try:
            hall_obj = hall.objects.get(hall_name = hall_name)
        except:
            hall_obj = None
        if hall_obj is not None:
            return HttpResponse('''<script>alert("Hall already exist");window.location='add_room'</script>''')

        room = hall(hall_name = hall_name,capacity = capacity)
        room.save()
        print(capacity)
        return redirect('room_list')
    else:
        return render(request,'add-room.html')
    
@custom_login_required
def edit_room(request,id):
    room = hall.objects.get(pk = id)
    print(id,'****************')
    return render(request,'edit_room.html',{'room':room})

@custom_login_required
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


@custom_login_required
def delete_room(request,id):

    room = hall.objects.get(pk = id)
    if room.status == 'active':
        room.status = 'inactive'
    else:
        room.status = 'active'
        
    room.save()
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

@custom_login_required
def select_halls1(request):
    if request.POST:
        halls=request.POST.getlist('hall_id')
        ob=studentDetails.objects.filter(schedule__date=request.session['date'],schedule__slot=request.session['session']).order_by('reg_no')
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
        # for i in range(0,len(countlist)):
        #     print(countlist[i],sublist[i])
        # return HttpResponse('File uploaded')                
          
        alocation=[]
        max_ob=countList.objects.filter(count__gte=1).order_by('-count')
        max_index_id=0
        min_index_id=1
        for i in halls:
            hob=hall.objects.get(id=i)
            
            if max_index_id>=len(max_ob) and min_index_id>len(max_ob):
                break
            if max_index_id<len(max_ob):             
                maxindex=max_ob[max_index_id]
            # print(maxindex,'*************************')
            # minindex=max_ob[len(max_ob)-1]
            if min_index_id<len(max_ob):
                minindex=max_ob[min_index_id]
            
            
            halldetails=[]
            # counter = 0
            for ii in range(0,int(hob.capacity/2)):
                
                if maxindex.count!=0:
                    index=sublist.index(maxindex.subject_id.id)
                    students=studentlist[index]
                    
                    ob_c_stud=students[countlist[index]-maxindex.count]
                    
                    row=[ob_c_stud,(2*ii)+1]
                    halldetails.append(row)
                    maxindex.count=maxindex.count-1;
                    maxindex.save()
                else:
                    print("======================================")
                    print(max_index_id,min_index_id)
                    if min_index_id>max_index_id:
                        max_index_id=min_index_id+1
                    else:
                        max_index_id=max_index_id+1
                    if max_index_id>=len(max_ob):
                        pass
                    else:
                        
                        maxindex=max_ob[max_index_id]
                        print(maxindex.subject_id.sub_name,maxindex.count,max_index_id,min_index_id)
                        
                        index=sublist.index(maxindex.subject_id.id)
                        students=studentlist[index]
                        print(len(students),"====",countlist[index],"=====",maxindex.count)
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
                else:
                        print("**********************************")
                        print(max_index_id,min_index_id,len(max_ob))
                        if min_index_id>max_index_id:
                            min_index_id=min_index_id+1
                        else:
                            min_index_id=max_index_id+1
                    
                       
                        if min_index_id>=len(max_ob):
                            print("=====================")
                        else:
                            minindex=max_ob[min_index_id]
                            print(minindex.subject_id.sub_name,minindex.count,max_index_id,min_index_id)
                            index=sublist.index(minindex.subject_id.id)
                            students=studentlist[index]
                            print(minindex.subject_id.id)
                            print(len(students),"==",countlist[index],"=====",minindex.count)
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
                schedule_details_object =schedule_details()
                schedule_details_object.hall_id = hall.objects.get(id = hid)
                schedule_details_object.seat_no = ii[1]
                schedule_details_object.student = ii[0].student
                schedule_details_object.reg_no = ii[0].reg_no
                schedule_details_object.shedule_id = ii[0].schedule
                schedule_details_object.subject_id = ii[0].subject
                schedule_details_object.save()
                


                # scheduleDetails = schedule_details(shedule_id = sid)
        students = studentDetails.objects.all()
        counts = countList.objects.all()
        for i in students:
            i.delete()
        for i in counts:
            i.delete()
        return redirect('halls_and_reports')                
                


    else:
        try:
            ob=studentDetails.objects.filter(schedule__date=request.session['date'],schedule__slot=request.session['session'])
            count=len(ob)   
            halls = hall.objects.filter(status = 'active')
            if count == 0:
                return HttpResponse('''<script>alert("There is no students to allocate");window.location='seating'</script>''')
            
            return render(request,'hall-allocation.html',{'halls':halls,"count":count})
        except:
            return HttpResponse('''<script>alert("There is no students to allocate");window.location='seating'</script>''')

@custom_login_required
def select_halls(request):
    if request.POST:
        halls=request.POST.getlist('hall_id')
        ob=studentDetails.objects.filter(schedule__date=request.session['date'],schedule__slot=request.session['session']).order_by('reg_no')
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
        # for i in range(0,len(countlist)):
        #     print(countlist[i],sublist[i])
        # return HttpResponse('File uploaded')                
          
        alocation=[]
        max_ob=countList.objects.filter(count__gte=1).order_by('-count')
        max_index_id=0
        min_index_id=1
        for i in halls:
            hob=hall.objects.get(id=i)
            
            if max_index_id>=len(max_ob) and min_index_id>len(max_ob):
                break
            if max_index_id<len(max_ob):             
                maxindex=max_ob[max_index_id]
            # print(maxindex,'*************************')
            minindex=max_ob[len(max_ob)-1]
            if min_index_id<len(max_ob):
                minindex=max_ob[min_index_id]
            
            
            halldetails=[]
            # counter = 0
            for ii in range(0,int(hob.capacity/2)):
                
                if maxindex.count!=0:
                    index=sublist.index(maxindex.subject_id.id)
                    students=studentlist[index]
                    
                    ob_c_stud=students[countlist[index]-maxindex.count]
                    
                    row=[ob_c_stud,(2*ii)+1]
                    halldetails.append(row)
                    maxindex.count=maxindex.count-1;
                    maxindex.save()
                else:
                    print("======================================")
                    print(max_index_id,min_index_id)
                    if min_index_id>max_index_id:
                        max_index_id=min_index_id+1
                    else:
                        max_index_id=max_index_id+1
                    if max_index_id>=len(max_ob):
                        try:
                            index=sublist.index(minindex.subject_id.id)
                            students=studentlist[index]
                        
                            ob_c_stud=students[countlist[index]-minindex.count]
                            row=[ob_c_stud,(2*ii)+1]
                            halldetails.append(row)
                            minindex.count=minindex.count-1;
                            minindex.save()
                        except:
                            pass
                    else:
                        
                        maxindex=max_ob[max_index_id]
                        print(maxindex.subject_id.sub_name,maxindex.count,max_index_id,min_index_id)
                        
                        index=sublist.index(maxindex.subject_id.id)
                        students=studentlist[index]
                        print(len(students),"====",countlist[index],"=====",maxindex.count)
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
                else:
                        print("**********************************")
                        print(max_index_id,min_index_id,len(max_ob))
                        if min_index_id>max_index_id:
                            min_index_id=min_index_id+1
                        else:
                            min_index_id=max_index_id+1
                    
                       
                        if min_index_id>=len(max_ob):
                            print("=====================")
                            try:
                                index=sublist.index(maxindex.subject_id.id)
                                students=studentlist[index]
                                
                                ob_c_stud=students[countlist[index]-maxindex.count]
                                
                                row=[ob_c_stud,(2*ii)+2]
                                halldetails.append(row)
                                maxindex.count=maxindex.count-1;
                                maxindex.save()
                            except:
                                pass
                        else:
                            minindex=max_ob[min_index_id]
                            print(minindex.subject_id.sub_name,minindex.count,max_index_id,min_index_id)
                            index=sublist.index(minindex.subject_id.id)
                            students=studentlist[index]
                            print(minindex.subject_id.id)
                            print(len(students),"==",countlist[index],"=====",minindex.count)
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
                schedule_details_object =schedule_details()
                schedule_details_object.hall_id = hall.objects.get(id = hid)
                schedule_details_object.seat_no = ii[1]
                schedule_details_object.student = ii[0].student
                schedule_details_object.reg_no = ii[0].reg_no
                schedule_details_object.shedule_id = ii[0].schedule
                schedule_details_object.subject_id = ii[0].subject
                schedule_details_object.save()
                


                # scheduleDetails = schedule_details(shedule_id = sid)
        students = studentDetails.objects.all()
        counts = countList.objects.all()
        for i in students:
            i.delete()
        for i in counts:
            i.delete()
        return redirect('halls_and_reports')                
                


    else:
        try:
            # request.session['date']='2023-05-13'
            # request.session['session']='Afternoon'
            ob=studentDetails.objects.filter(schedule__date=request.session['date'],schedule__slot=request.session['session'])
            count=len(ob)   
            halls = hall.objects.filter(status = 'active')
            if count == 0:
                return HttpResponse('''<script>alert("There is no students to allocate");window.location='seating'</script>''')
            
            return render(request,'hall-allocation.html',{'halls':halls,"count":count})
        except:
            return HttpResponse('''<script>alert("There is no students to allocate");window.location='seating'</script>''')


# available halls and reports
@custom_login_required
def halls_and_reports(request):
    with connection.cursor() as cursor:
      
        cursor.execute("select * from adminpart_hall where id in(select hall_id_id from adminpart_schedule_details where shedule_id_id="+str(request.session['schedule'])+")")
        row = cursor.fetchall()
  
    return render(request,'halls_and_reports.html',{'row':row})


@custom_login_required
def display_report(request):
    with connection.cursor() as cursor:
      
        cursor.execute("select * from adminpart_hall where id in(select hall_id_id from adminpart_schedule_details where shedule_id_id="+str(request.session['schedule'])+")")
        row = cursor.fetchall()
    

    
        result=[]
        count = 0
        for i in row:
            cr={"hname":i[1],"det":[]}
            qry="select distinct subject_id_id from adminpart_schedule_details where shedule_id_id="+str(request.session['schedule'])+" and hall_id_id="+str(i[0])
            cursor.execute(qry)
            subrow=cursor.fetchall()
            for sid in subrow:
                ob=subject.objects.get(id=sid[0])
                sr={"branch":ob.branch,"regno":[],"count":0}
                ob1=schedule_details.objects.filter(hall_id__id=i[0],shedule_id__id=request.session['schedule'],subject_id__id=sid[0]).order_by()
                sr['count']=len(ob1)
                count = count + len(ob1)

                for reg in ob1:
                    sr['regno'].append(reg.reg_no)
                cr['det'].append(sr)
            result.append(cr)
        print(result)
        examname = schedule.objects.get(id = request.session['schedule'])
        return render(request,'display.html',{'result':result,'exam':examname,'count':count})

        



@custom_login_required
def reports_in_hall(request,id):
    hall_name = hall.objects.get(pk = id)
    print(hall_name.hall_name)
    return render(request,'reports_in_hall.html',{'hall_id':id,'hall':hall_name})

def download_seating(request,id):
    # print(id,"==========================\n=================\n=====================")
    # Query the database to get the student data
    students = schedule_details.objects.filter(shedule_id__date = request.session['date'],shedule_id__slot = request.session['session'],hall_id = id)
    hall_name = students[0].hall_id.hall_name
    schedule_name = schedule.objects.get(slot = request.session['session'],date = request.session['date'])
    date_obj = datetime.datetime.strptime(request.session['date'], "%Y-%m-%d").date()

    # Format the date object as a string in the desired format
    formatted_date_str = date_obj.strftime("%d-%m-%Y")


    # Build the table data
    table_data = [['Seat', 'Reg_no', 'Name', 'Code', 'Remark']]
    head_data = [['Room :',hall_name,request.session['session'],formatted_date_str]]
    for student in students:
        table_data.append([student.seat_no, student.reg_no, student.student,student.subject_id.code,])
        
        
    # Set up the PDF document
    response = HttpResponse(content_type='application/pdf')
    response['Content-Disposition'] = 'attachment; filename="seating_"'+hall_name+'".pdf"'
    doc = SimpleDocTemplate(response, pagesize=letter)

    # Define styles
    # styles = getSampleStyleSheet()
    # heading_style = styles['Heading1']
    # heading_style.alignment = 1 # center alignment
    # date_style = styles['Normal']
    # date_style.fontSize = 12
    heading_style = ParagraphStyle(
            
        name='heading',
        fontName='Helvetica-Bold',
        fontSize=18,
        leading=16,
        alignment=TA_CENTER
        )
    


    # Create heading and date
    heading = Paragraph("KMCT College of Engineering", heading_style)
    heading1 =Paragraph(schedule_name.exam_name, heading_style)
    heading2 = Paragraph("SEATING ARRANGEMENT", heading_style)
    # date = Paragraph("Date: {}".format(request.session['date']), date_style)

    # Create the table and apply styles
    head_data_table = Table(head_data,colWidths=[1.0*inch, 2.0*inch, 3.0*inch, 1.8*inch])
    table = Table(table_data, colWidths=[1.0*inch, 1.7*inch, 2.8*inch,1*inch, 1.5*inch])
    style = TableStyle([
        # ('BACKGROUND', (0,0), (-1,0), colors.grey),
        ('TEXTCOLOR', (0,0), (-1,0), colors.black),
        ('ALIGN', (0,0), (-1,0), 'CENTER'),
        ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
        ('FONTSIZE', (0,0), (-1,0), 14),
        ('BOTTOMPADDING', (0,0), (-1,0), 12),
        # ('BACKGROUND', (0,1), (-1,-1), colors.beige),
        ('TEXTCOLOR', (0,1), (-1,-1), colors.black),
        ('ALIGN', (0,1), (-1,-1), 'CENTER'),
        ('FONTNAME', (0,1), (-1,-1), 'Helvetica'),
        ('FONTSIZE', (0,1), (-1,-1), 10),
        ('BOTTOMPADDING', (0,1), (-1,-1), 6),
        ('GRID', (0,0), (-1,-1), 1, colors.black)
    ])
    head_style = TableStyle([
        # ('BACKGROUND', (0,0), (-1,0), colors.grey),
        ('TEXTCOLOR', (0,0), (-1,0), colors.black),
        ('ALIGN', (0,0), (-1,0), 'CENTER'),
        ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
        ('FONTSIZE', (0,0), (-1,0), 14),
        ('BOTTOMPADDING', (0,0), (-1,0), 12),
        # ('BACKGROUND', (0,1), (-1,-1), colors.beige),
        # ('TEXTCOLOR', (0,1), (-1,-1), colors.black),
        # ('ALIGN', (0,1), (-1,-1), 'CENTER'),
        # ('FONTNAME', (0,1), (-1,-1), 'Helvetica'),
        # ('FONTSIZE', (0,1), (-1,-1), 10),
        # ('BOTTOMPADDING', (0,1), (-1,-1), 6),
        # ('GRID', (0,0), (-1,-1), 1, colors.black)
    ])


    table.setStyle(style)
    head_data_table.setStyle(head_style)
    # hall_name_para = Paragraph(hall_name, hall_style)
    # hall_name_spacer = Spacer(1, 0.2*inch)
    heading_spacer = Spacer(1, 0.25*inch)
    # date_spacer = Spacer(1, 0.25*inch)

    count = [[" ","Total Number of Students : ",str(len(students))]]
    countdata = Table(count,colWidths=[1.3*inch,2.0*inch, 1.0*inch])

    
      
    # Add the heading, date, and table to the PDF document and save it
    # elements = [heading,heading1,heading2, date, table]
    elements = [
    heading,
    heading_spacer,
    heading1,
    heading_spacer,
    heading2,
    heading_spacer,
    head_data_table,
    table,
    heading_spacer,
    countdata
    ]

    doc.build(elements)

    return response

def download_attendance(request,id):
    students = schedule_details.objects.filter(shedule_id__date = request.session['date'],shedule_id__slot = request.session['session'],hall_id = id)
    hall_name = students[0].hall_id.hall_name
    schedule_name = schedule.objects.get(slot = request.session['session'],date = request.session['date'])
    date_obj = datetime.datetime.strptime(request.session['date'], "%Y-%m-%d").date()

    # Format the date object as a string in the desired format
    formatted_date_str = date_obj.strftime("%d-%m-%Y")
    # Build the table data
    table_data = [['slno', 'Name and Reg_no', 'Course Code', 'Barcode', 'Signature']]
    head_data = [['Room :',hall_name,request.session['session'],formatted_date_str]]
    for student in students:
        table_data.append(["\n\n"+str(student.seat_no)+"\n\n", "\n\n"+str(student.student+"-"+student.reg_no)+"\n\n","\n\n"+str(student.subject_id.code)+'\n\n',])
        
        
    # Set up the PDF document
    response = HttpResponse(content_type='application/pdf')
    response['Content-Disposition'] = 'attachment; filename="Attendance_"'+hall_name+'".pdf"'
    doc = SimpleDocTemplate(response, pagesize=pagesizes.A4)

    # Define styles
    # styles = getSampleStyleSheet()
    # heading_style = styles['Heading1']
    # heading_style.alignment = 1 # center alignment
    # date_style = styles['Normal']
    # date_style.fontSize = 12
    heading_style = ParagraphStyle(
            
        name='heading',
        fontName='Helvetica-Bold',
        fontSize=18,
        leading=16,
        alignment=TA_CENTER
        )
    


    # Create heading and date
    heading = Paragraph("KMCT College of Engineering", heading_style)
    heading1 =Paragraph(schedule_name.exam_name, heading_style)
    
    # date = Paragraph("Date: {}".format(request.session['date']), date_style)

    # Create the table and apply styles
    head_data_table = Table(head_data,colWidths=[1.0*inch, 2.0*inch, 3.0*inch, 1.8*inch])
    table = Table(table_data, colWidths=[0.5*inch, 2.7*inch, 1.1*inch,2.4*inch, 1.3*inch])
    
    style = TableStyle([
        # ('BACKGROUND', (0,0), (-1,0), colors.grey),
        ('TEXTCOLOR', (0,0), (-1,0), colors.black),
        ('ALIGN', (0,0), (-1,0), 'CENTER'),
        ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
        ('FONTSIZE', (0,0), (-1,0), 11),
        ('BOTTOMPADDING', (0,0), (-1,0), 12),
        # ('BACKGROUND', (0,1), (-1,-1), colors.beige),
        ('TEXTCOLOR', (0,1), (-1,-1), colors.black),
        ('ALIGN', (0,1), (-1,-1), 'CENTER'),
        ('FONTNAME', (0,1), (-1,-1), 'Helvetica'),
        ('FONTSIZE', (0,1), (-1,-1), 9),
        ('BOTTOMPADDING', (0,1), (-1,-1), 6),
        ('GRID', (0,0), (-1,-1), 1, colors.black),
        ('ROWHEIGHT', (0,1), (-1,1), 0.9*inch),

    ])
    head_style = TableStyle([
        # ('BACKGROUND', (0,0), (-1,0), colors.grey),
        ('TEXTCOLOR', (0,0), (-1,0), colors.black),
        ('ALIGN', (0,0), (-1,0), 'CENTER'),
        ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
        ('FONTSIZE', (0,0), (-1,0), 14),
        ('BOTTOMPADDING', (0,0), (-1,0), 12),
        
    ])
   

    table.setStyle(style)

    head_data_table.setStyle(head_style)
    # hall_name_para = Paragraph(hall_name, hall_style)
    # hall_name_spacer = Spacer(1, 0.2*inch)
    heading_spacer = Spacer(1, 0.25*inch)
    # date_spacer = Spacer(1, 0.25*inch)

    additional_text = '''I do hereby certify that I have examined the answer books of all the students in this exam hall and found all the entries in the facing page are correct. Also the barcodes pasted on this attendance sheet against a student and on his/her answer book are same and are corresponding to the concerned student.'''
    additional_text_style = ParagraphStyle(
        name='additional_text',
        fontName='Helvetica',
        fontSize=11,
        leading=13,

    )
    additional_text_paragraph = Paragraph(additional_text, additional_text_style)

    signature_text = '''Name and Signature of Invigilator 1:'''
    signature_text_style = ParagraphStyle(
        name='signature_text',
        fontName='Helvetica',
        fontSize=11,
        leading=13,
        alingnment=TA_LEFT

    )
    signature_text_para = Paragraph(signature_text, signature_text_style)

    signature_text2 = '''Name and Signature of Invigilator 2:'''
    signature_text_style2 = ParagraphStyle(
        name='signature_text',
        fontName='Helvetica',
        fontSize=11,
        leading=13,
        alingnment=TA_RIGHT

    )
    signature_text_para2 = Paragraph(signature_text2, signature_text_style2)


      
    # Add the heading, date, and table to the PDF document and save it
    # elements = [heading,heading1,heading2, date, table]
    elements = [
    heading,
    heading_spacer,
    heading1,
    heading_spacer,
    heading_spacer,
    head_data_table,
    table,
    heading_spacer,
    additional_text_paragraph,
    heading_spacer,
    signature_text_para,
    heading_spacer,
    signature_text_para2
    ]

    doc.build(elements)
    return response


def generate_reports(request):
    
    # Query the database to get the student data
    students = schedule_details.objects.filter(shedule_id__date = request.session['date'],shedule_id__slot = request.session['session'])
    schedule_name = schedule.objects.get(slot = request.session['session'],date = request.session['date'])
    # Build the table data
    table_data = [['Seat', 'Reg_no', 'Name', 'Code', 'Remark']]
    
    for student in students:
        table_data.append([student.seat_no, student.reg_no, student.student,student.subject_id.code,])
        
        
    # Set up the PDF document
    response = HttpResponse(content_type='application/pdf')
    response['Content-Disposition'] = 'attachment; filename="students.pdf"'
    doc = SimpleDocTemplate(response, pagesize=letter)

    # Define styles
    styles = getSampleStyleSheet()
    heading_style = styles['Heading1']
    heading_style.alignment = 1 # center alignment
    date_style = styles['Normal']
    date_style.fontSize = 12

    # Create heading and date
    heading = Paragraph("KMCT College of Engineering", heading_style)
    heading1 =Paragraph(schedule_name.exam_name, heading_style)
    heading2 = Paragraph("SEATING ARRANGEMENT", heading_style)
    date = Paragraph("Date: {}".format(request.session['date']), date_style)

    # Create the table and apply styles
    table = Table(table_data, colWidths=[1.0*inch, 1.7*inch, 2.8*inch,1*inch, 1.5*inch])
    style = TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.grey),
        ('TEXTCOLOR', (0,0), (-1,0), colors.whitesmoke),
        ('ALIGN', (0,0), (-1,0), 'CENTER'),
        ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
        ('FONTSIZE', (0,0), (-1,0), 14),
        ('BOTTOMPADDING', (0,0), (-1,0), 12),
        ('BACKGROUND', (0,1), (-1,-1), colors.beige),
        ('TEXTCOLOR', (0,1), (-1,-1), colors.black),
        ('ALIGN', (0,1), (-1,-1), 'CENTER'),
        ('FONTNAME', (0,1), (-1,-1), 'Helvetica'),
        ('FONTSIZE', (0,1), (-1,-1), 12),
        ('BOTTOMPADDING', (0,1), (-1,-1), 6),
        ('GRID', (0,0), (-1,-1), 1, colors.black)
    ])
    table.setStyle(style)

    # Add the heading, date, and table to the PDF document and save it
    elements = [heading,heading1,heading2, date, table]
    doc.build(elements)

    return response




@custom_login_required
def seating(request):
    
    if request.POST:
        time.sleep(3)

    # btn=request.POST['btn']
    # if btn == 'upload':
        date = request.POST.get('date')
        session = request.POST.get('session')
        request.session['date']=date
        request.session['session']=session
        excel_file = request.FILES['appearing_list']
        try:
            schedule_obj_exist = schedule.objects.get(date = date,slot = session)
        except:
            schedule_obj_exist = None
    
        # fs = FileSystemStorage()
        # filename = fs.save(excel_file.name, excel_file)
        # filepath = fs.path(filename)
        df = pd.read_excel(excel_file)
        for index, row in df.iterrows():
            if index == 1:
                if schedule_obj_exist is not None:
                    print(schedule_obj_exist.exam_name+","+row[4],"888****8888888*999999999966666665/////*****")
                    schedule_obj_exist.exam_name = schedule_obj_exist.exam_name+","+row[4]
                    schedule_obj_exist.save()
                    schedule_instance = schedule.objects.get(id = request.session['schedule'])
                else:

                    make_schedule = schedule(date = date,slot = session,exam_name = row[4])
                    make_schedule.save()
                    schedule_id = make_schedule.pk
                    request.session['schedule'] = schedule_id
                    schedule_instance = schedule.objects.get(id = schedule_id)


            if index > 0:
                if row[11]=='Yes':

                    print(row[11])
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
                        
                    print(name,"  ",req_no,"  ",course," ",course_code,"  ",row[4],"  ",row[3])
                    
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
        return redirect('seating')
        # else:
        #     if request.session['date'] and request.session['session']:
        #         ob=studentDetails.objects.filter(schedule__date=request.session['date'],schedule__slot=request.session['session'])
        #         count=len(ob)
        #         request.session['count']=count
        #         return redirect('select_halls')
    else:

        return render(request,'upload-list.html')

@custom_login_required
def duties(request):
    with connection.cursor() as cursor:
            cursor.execute("SELECT * FROM exam_cell.adminpart_schedule where  id in (SELECT schedule_id from adminpart_staff_allocation) ORDER BY adminpart_schedule.date DESC;")
            row = cursor.fetchall()
            print(row)
    return render(request,'view-duties.html',{'allocation':row})

@custom_login_required
def selectDuties(request):
    if request.POST:
        request.session['duty_schedule_id'] = request.POST.get('schedule')
        return redirect('allocate_duties')
    else:
        with connection.cursor() as cursor:
        
            cursor.execute("SELECT * FROM exam_cell.adminpart_schedule where date >=curdate() and id not in (SELECT schedule_id from adminpart_staff_allocation);")
            row = cursor.fetchall()
            print(row)
        return render(request,'select_duties_form.html',{'rows':row})




@custom_login_required
def allocate_duties(request):
    aloclist=[]
    with connection.cursor() as cursor:
      
        cursor.execute("select * from adminpart_hall where id in(select hall_id_id from adminpart_schedule_details where shedule_id_id="+str(request.session['duty_schedule_id'])+")")
        row = cursor.fetchall()
        

        examcell_staff = staff.objects.exclude(stafftype='invigilator')
        cursor.execute("SELECT * FROM adminpart_staff where stafftype='Invigilator' and id not in (select staff_id_id from adminpart_staff_allocation) limit "+str(len(row))+";")
        no_work_done = cursor.fetchall()
        # print(no_work_done,len(row))

        if len(no_work_done) == 0:
            cursor.execute("SELECT adminpart_staff.*,count(*) as c from adminpart_staff join adminpart_staff_allocation on adminpart_staff_allocation.staff_id_id=adminpart_staff.id where stafftype='Invigilator' group by adminpart_staff.id order by c limit "+str(len(row))+";")
            work =cursor.fetchall()
            for i in range(len(row)):
                aloclist.append(work[i])

        else:
            for i in no_work_done:
                aloclist.append(i)

            if len(aloclist)<len(row):
                cursor.execute("SELECT adminpart_staff.*,count(*) as c from adminpart_staff join adminpart_staff_allocation on adminpart_staff_allocation.staff_id_id=adminpart_staff.id where stafftype='Invigilator' group by adminpart_staff.id order by c limit "+str(len(row)-len(aloclist))+";")
                work =cursor.fetchall()
                for i in work:
                    aloclist.append(i)
    print("=====================")
    # print(aloclist)
    invigilators =[]
    for i in range(len(row)):
        cr = {}
        cr['hall'] = row[i]
        cr['invigilator'] = aloclist[i]
        invigilators.append(cr)


    print(invigilators)
    print("=====================")
    print(len(invigilators))

    print("=====================")


        

    return render(request,'Allocate-Duties.html',{'rows':row,'examcell':examcell_staff,'invigilators':invigilators})



@custom_login_required
def allocate_duties_post(request):
    if request.POST:
        schedule_id = request.session['duty_schedule_id']
        halls = request.POST.getlist('hall_id')
        staff_id_s = request.POST.getlist('staff_id')
        exam_cell_staff = request.POST.getlist('examcell')

        for i in range(len(halls)):
            # user_login = login_table(username = username,password = hashed_password)
            alloction_obj = staff_allocation(staff_id = staff.objects.get(id = staff_id_s[i]),hall_id = hall.objects.get(id = halls[i]),schedule = schedule.objects.get(id = schedule_id))
            alloction_obj.save()
        
        for i in exam_cell_staff:
            exam_alloction_obj = staff_allocation(staff_id = staff.objects.get(id = i),schedule = schedule.objects.get(id = schedule_id))
            exam_alloction_obj.save()



        print(schedule_id)
        print("Hall id ==>",halls,"\n Staff_id ==>",staff_id_s,"\n Exam cell id ==>",exam_cell_staff)

        return HttpResponse('''<script>alert("Successfully allocated");window.location='duties'</script>''')

@custom_login_required
def edit_allocation(request,id):
    print(id)
    request.session['sch_id'] = id
    allocated_staffs = staff_allocation.objects.filter(schedule__id = id)
    print(len(allocated_staffs))
   
    with connection.cursor() as cursor:
        cursor.execute("SELECT * from adminpart_staff where stafftype='Invigilator' and id not in (select staff_id_id from adminpart_staff_allocation where schedule_id = "+str(id)+");")
        row = cursor.fetchall()
    print(row)
    return render(request,'edit_allocation.html',{'allocation':allocated_staffs,'exam':allocated_staffs[0].schedule.exam_name,'staffs':row})

#edit allocated staff
#================================
@custom_login_required
def edit_allocated_staff(request):
    if request.method == 'GET':
        alloc_id = request.GET.get('alloc_id',None)
        staff_id = request.GET.get('staff_id',None)
        try:
            alloc_obj = staff_allocation.objects.get(id=alloc_id)
        except:
            alloc_obj = None
        
        if alloc_obj is not None:
            alloc_obj.staff_id = staff.objects.get(id = staff_id)
            alloc_obj.status = 'pending'
            alloc_obj.save()
            return JsonResponse({'message': 'Successfully Edited'})
        else:
             return JsonResponse({'message': 'Something wrong !!!'},status=401)
        
@custom_login_required
def remove_allocated_staff(req):
    if req.method == 'GET':

        alloc_id = req.GET.get('alloc_id',None)
        try:
            alloc_obj = staff_allocation.objects.get(id = alloc_id)
        except:
            alloc_obj = None
        if alloc_obj is not None:
            alloc_obj.delete()
            return JsonResponse({'message': 'Successfully Deleted '})
        else:
            return JsonResponse({'message': ' Deletion Faild '})



#seating history
#================
@custom_login_required
def seating_history(request):
    if request.POST:
        schedule_id = request.POST.get('schedule')
        request.session['schedule_id_history'] = schedule_id
        with connection.cursor() as cursor:
            cursor.execute("select * from adminpart_hall where id in(select hall_id_id from adminpart_schedule_details where shedule_id_id="+str(schedule_id)+")")
            row = cursor.fetchall()
        return render(request,'halls_and_reports_history.html',{'row':row})

    with connection.cursor() as cursor:
            # cursor.execute("SELECT * FROM exam_cell.adminpart_schedule where date >=curdate() and id not in (SELECT schedule_id from adminpart_staff_allocation);")
            cursor.execute("SELECT * FROM exam_cell.adminpart_schedule;")
            row = cursor.fetchall()
            print(row)

    return render(request,'select_schedule_to_seating.html',{'rows':row})

@custom_login_required
def report_in_halls_history(request,id):
    hall_name = hall.objects.get(pk = id)
    print(hall_name.hall_name)
    return render(request,'reports_in_hall_history.html',{'hall_id':id,'hall':hall_name})


def download_seating_history(request,id):
    # print(id,"==========================\n=================\n=====================")
    # Query the database to get the student data
    students = schedule_details.objects.filter(shedule_id__id = request.session['schedule_id_history'],hall_id = id)
    hall_name = students[0].hall_id.hall_name
    schedule_name = schedule.objects.get(id = request.session['schedule_id_history'])

    date_obj = datetime.datetime.strptime(str(schedule_name.date), "%Y-%m-%d").date()

    # Format the date object as a string in the desired format
    formatted_date_str = date_obj.strftime("%d-%m-%Y")
    # Build the table data
    table_data = [['Seat', 'Reg_no', 'Name', 'Code', 'Remark']]
    head_data = [['Room :',hall_name,schedule_name.slot,formatted_date_str]]
    for student in students:
        table_data.append([student.seat_no, student.reg_no, student.student,student.subject_id.code,])
        
        
    # Set up the PDF document
    response = HttpResponse(content_type='application/pdf')
    response['Content-Disposition'] = 'attachment; filename="seating_"'+hall_name+'".pdf"'
    doc = SimpleDocTemplate(response, pagesize=letter)

    # Define styles
    # styles = getSampleStyleSheet()
    # heading_style = styles['Heading1']
    # heading_style.alignment = 1 # center alignment
    # date_style = styles['Normal']
    # date_style.fontSize = 12
    heading_style = ParagraphStyle(
            
        name='heading',
        fontName='Helvetica-Bold',
        fontSize=18,
        leading=16,
        alignment=TA_CENTER
        )
    


    # Create heading and date
    heading = Paragraph("KMCT College of Engineering", heading_style)
    heading1 =Paragraph(schedule_name.exam_name, heading_style)
    heading2 = Paragraph("SEATING ARRANGEMENT", heading_style)
    # date = Paragraph("Date: {}".format(request.session['date']), date_style)

    # Create the table and apply styles
    head_data_table = Table(head_data,colWidths=[1.0*inch, 2.0*inch, 3.0*inch, 1.8*inch])
    table = Table(table_data, colWidths=[1.0*inch, 1.7*inch, 2.8*inch,1*inch, 1.5*inch])
    style = TableStyle([
        # ('BACKGROUND', (0,0), (-1,0), colors.grey),
        ('TEXTCOLOR', (0,0), (-1,0), colors.black),
        ('ALIGN', (0,0), (-1,0), 'CENTER'),
        ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
        ('FONTSIZE', (0,0), (-1,0), 14),
        ('BOTTOMPADDING', (0,0), (-1,0), 12),
        # ('BACKGROUND', (0,1), (-1,-1), colors.beige),
        ('TEXTCOLOR', (0,1), (-1,-1), colors.black),
        ('ALIGN', (0,1), (-1,-1), 'CENTER'),
        ('FONTNAME', (0,1), (-1,-1), 'Helvetica'),
        ('FONTSIZE', (0,1), (-1,-1), 10),
        ('BOTTOMPADDING', (0,1), (-1,-1), 6),
        ('GRID', (0,0), (-1,-1), 1, colors.black)
    ])
    head_style = TableStyle([
        # ('BACKGROUND', (0,0), (-1,0), colors.grey),
        ('TEXTCOLOR', (0,0), (-1,0), colors.black),
        ('ALIGN', (0,0), (-1,0), 'CENTER'),
        ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
        ('FONTSIZE', (0,0), (-1,0), 14),
        ('BOTTOMPADDING', (0,0), (-1,0), 12),
        # ('BACKGROUND', (0,1), (-1,-1), colors.beige),
        # ('TEXTCOLOR', (0,1), (-1,-1), colors.black),
        # ('ALIGN', (0,1), (-1,-1), 'CENTER'),
        # ('FONTNAME', (0,1), (-1,-1), 'Helvetica'),
        # ('FONTSIZE', (0,1), (-1,-1), 10),
        # ('BOTTOMPADDING', (0,1), (-1,-1), 6),
        # ('GRID', (0,0), (-1,-1), 1, colors.black)
    ])


    table.setStyle(style)
    head_data_table.setStyle(head_style)
    # hall_name_para = Paragraph(hall_name, hall_style)
    # hall_name_spacer = Spacer(1, 0.2*inch)
    heading_spacer = Spacer(1, 0.25*inch)
    # date_spacer = Spacer(1, 0.25*inch)
    count = [[" ","Total Number of Students : ",str(len(students))]]
    countdata = Table(count,colWidths=[1.3*inch,2.0*inch, 1.0*inch])

    
      
    # Add the heading, date, and table to the PDF document and save it
    # elements = [heading,heading1,heading2, date, table]
    elements = [
    heading,
    heading_spacer,
    heading1,
    heading_spacer,
    heading2,
    heading_spacer,
    head_data_table,
    table,
    heading_spacer,
    countdata
    ]

    doc.build(elements)

    return response

def download_attendance_history(request,id):
    students = schedule_details.objects.filter(shedule_id__id = request.session['schedule_id_history'],hall_id = id)
    hall_name = students[0].hall_id.hall_name
    schedule_name = schedule.objects.get(id = request.session['schedule_id_history'])
    # Build the table data
    print(schedule_name.date)
    date_obj = datetime.datetime.strptime(str(schedule_name.date), "%Y-%m-%d").date()

    # Format the date object as a string in the desired format
    formatted_date_str = date_obj.strftime("%d-%m-%Y")
    table_data = [['slno', 'Name and Reg_no', 'Course Code', 'Barcode', 'Signature']]
    head_data = [['Room :',hall_name,schedule_name.slot,formatted_date_str]]
    for student in students:
        table_data.append(["\n\n"+str(student.seat_no)+"\n\n", "\n\n"+str(student.student+"-"+student.reg_no)+"\n\n","\n\n"+str(student.subject_id.code)+'\n\n',])
        
        
    # Set up the PDF document
    response = HttpResponse(content_type='application/pdf')
    response['Content-Disposition'] = 'attachment; filename="Attendance_"'+hall_name+'".pdf"'
    doc = SimpleDocTemplate(response, pagesize=pagesizes.A4)

    # Define styles
    # styles = getSampleStyleSheet()
    # heading_style = styles['Heading1']
    # heading_style.alignment = 1 # center alignment
    # date_style = styles['Normal']
    # date_style.fontSize = 12
    heading_style = ParagraphStyle(
            
        name='heading',
        fontName='Helvetica-Bold',
        fontSize=18,
        leading=16,
        alignment=TA_CENTER
        )
    


    # Create heading and date
    heading = Paragraph("KMCT College of Engineering", heading_style)
    heading1 =Paragraph(schedule_name.exam_name, heading_style)
    
    # date = Paragraph("Date: {}".format(request.session['date']), date_style)

    # Create the table and apply styles
    head_data_table = Table(head_data,colWidths=[1.0*inch, 2.0*inch, 3.0*inch, 1.8*inch])
    table = Table(table_data, colWidths=[0.5*inch, 2.7*inch, 1.1*inch,2.4*inch, 1.3*inch])
    
    style = TableStyle([
        # ('BACKGROUND', (0,0), (-1,0), colors.grey),
        ('TEXTCOLOR', (0,0), (-1,0), colors.black),
        ('ALIGN', (0,0), (-1,0), 'CENTER'),
        ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
        ('FONTSIZE', (0,0), (-1,0), 11),
        ('BOTTOMPADDING', (0,0), (-1,0), 12),
        # ('BACKGROUND', (0,1), (-1,-1), colors.beige),
        ('TEXTCOLOR', (0,1), (-1,-1), colors.black),
        ('ALIGN', (0,1), (-1,-1), 'CENTER'),
        ('FONTNAME', (0,1), (-1,-1), 'Helvetica'),
        ('FONTSIZE', (0,1), (-1,-1), 9),
        ('BOTTOMPADDING', (0,1), (-1,-1), 6),
        ('GRID', (0,0), (-1,-1), 1, colors.black),
        ('ROWHEIGHT', (0,1), (-1,1), 0.9*inch),

    ])
    head_style = TableStyle([
        # ('BACKGROUND', (0,0), (-1,0), colors.grey),
        ('TEXTCOLOR', (0,0), (-1,0), colors.black),
        ('ALIGN', (0,0), (-1,0), 'CENTER'),
        ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
        ('FONTSIZE', (0,0), (-1,0), 14),
        ('BOTTOMPADDING', (0,0), (-1,0), 12),
        
    ])
   

    table.setStyle(style)

    head_data_table.setStyle(head_style)
    # hall_name_para = Paragraph(hall_name, hall_style)
    # hall_name_spacer = Spacer(1, 0.2*inch)
    heading_spacer = Spacer(1, 0.25*inch)
    additional_text = '''I do hereby certify that I have examined the answer books of all the students in this exam hall and found all the entries in the facing page are correct. Also the barcodes pasted on this attendance sheet against a student and on his/her answer book are same and are corresponding to the concerned student.'''
    additional_text_style = ParagraphStyle(
        name='additional_text',
        fontName='Helvetica',
        fontSize=11,
        leading=13,

    )
    additional_text_paragraph = Paragraph(additional_text, additional_text_style)

    signature_text = '''Name and Signature of Invigilator 1:'''
    signature_text_style = ParagraphStyle(
        name='signature_text',
        fontName='Helvetica',
        fontSize=11,
        leading=13,
        alingnment=TA_LEFT

    )
    signature_text_para = Paragraph(signature_text, signature_text_style)

    signature_text2 = '''Name and Signature of Invigilator 2:'''
    signature_text_style2 = ParagraphStyle(
        name='signature_text',
        fontName='Helvetica',
        fontSize=11,
        leading=13,
        alingnment=TA_RIGHT

    )
    signature_text_para2 = Paragraph(signature_text2, signature_text_style2)


      
    # Add the heading, date, and table to the PDF document and save it
    # elements = [heading,heading1,heading2, date, table]
    elements = [
    heading,
    heading_spacer,
    heading1,
    heading_spacer,
    heading_spacer,
    head_data_table,
    table,
    heading_spacer,
    additional_text_paragraph,
    heading_spacer,
    signature_text_para,
    heading_spacer,
    signature_text_para2
    ]

    doc.build(elements)
    return response

@custom_login_required
def display_report_history(request):
    with connection.cursor() as cursor:
      
        cursor.execute("select * from adminpart_hall where id in(select hall_id_id from adminpart_schedule_details where shedule_id_id="+str(request.session['schedule_id_history'])+")")
        row = cursor.fetchall()
    

    
        result=[]
        count=0
        for i in row:
            cr={"hname":i[1],"det":[]}
            qry="select distinct subject_id_id from adminpart_schedule_details where shedule_id_id="+str(request.session['schedule_id_history'])+" and hall_id_id="+str(i[0])
            cursor.execute(qry)
            subrow=cursor.fetchall()
            for sid in subrow:
                ob=subject.objects.get(id=sid[0])
                sr={"branch":ob.branch,"regno":[],"count":0}
                ob1=schedule_details.objects.filter(hall_id__id=i[0],shedule_id__id=request.session['schedule_id_history'],subject_id__id=sid[0]).order_by()
                sr['count']=len(ob1)
                count = count + len(ob1)
                for reg in ob1:
                    sr['regno'].append(reg.reg_no)
                cr['det'].append(sr)
            result.append(cr)
        print(result)
        examname = schedule.objects.get(id = request.session['schedule_id_history'])
        return render(request,'display.html',{'result':result,'exam':examname,'count':count})
    
@custom_login_required
def attendance_marking(request):
    if request.POST:
        schedule_id = request.POST.get('schedule')
        schedule_students = schedule_details.objects.filter(shedule_id = schedule_id)
        studList = []


        print(len(studList))
        return render(request,'student_list.html',{'students':schedule_students})
    with connection.cursor() as cursor:
            # cursor.execute("SELECT * FROM exam_cell.adminpart_schedule where date >=curdate() and id not in (SELECT schedule_id from adminpart_staff_allocation);")
            cursor.execute("SELECT * FROM exam_cell.adminpart_schedule where date <= curdate();")
            row = cursor.fetchall()
            print(row)

    return render(request,'select_exam_to_attendance.html',{'rows':row})


@custom_login_required
def mark_absenties(request):
    print('its mark absent ********************')
    sd_id = request.GET.get('sd_id')
    try:
        student = schedule_details.objects.get(id = sd_id)
    except:

        student = None
    if student is not None:
        student.attendance_status = 0
        student.save()
        return JsonResponse({"message":"Absent Marked Successfull"})



    return HttpResponse(id)

#view attendance based on exam
@custom_login_required
def view_attendance(request):

    if request.POST:
        schedule_id = request.POST.get('schedule')
        schedule_students = schedule_details.objects.filter(shedule_id = schedule_id)
        return render(request,'view_stud_attandance.html',{'students':schedule_students})
    with connection.cursor() as cursor:
            # cursor.execute("SELECT * FROM exam_cell.adminpart_schedule where date >=curdate() and id not in (SELECT schedule_id from adminpart_staff_allocation);")
            cursor.execute("SELECT * FROM exam_cell.adminpart_schedule where date <= curdate();")
            row = cursor.fetchall()
            # print(row)

    return render(request,'attendance_form_stud.html',{'rows':row})


@custom_login_required
def view_reported_malpractice(request):
    reports = report_malpractice.objects.all().order_by('-created_at')
    return render(request,'view_reported_malpractice.html',{'reports':reports})


def get_info(request):
    # print('get_infoooooooooooooooooooooooooooos')
    nums = report_malpractice.objects.filter(admin_view = False)
    return JsonResponse({'message':True,'count':len(nums)})

@custom_login_required
def view_image(request,img,id):
    print(id,img)
    make_view = report_malpractice.objects.get(id = id)
    # print(make_view.admin_view,'***************************')
   
    # print('0000000000000003333333333333333333333#########################3')
    make_view.admin_view = True
    make_view.save()
    return render(request,'viewimg.html',{'image':img})


@custom_login_required
def view_staff_attendance(request):
    with connection.cursor() as cursor:

        # cursor.execute("SELECT * FROM exam_cell.adminpart_schedule where date >=curdate() and id not in (SELECT schedule_id from adminpart_staff_allocation);")
        cursor.execute("SELECT * FROM exam_cell.adminpart_schedule where date <= curdate() order by date ;")
        row = cursor.fetchall()
        rows = []
        dates = []
        for i in row:
            dates.append(i[1])
            if i[3] in rows:
                continue
            rows.append(i[3])
        
        

    return render(request,'view_staff_attendance.html',{'rows':rows,'dates':dates})


def get_attendanceBy_scheme(request):

    scheme = request.GET.get('scheme')
    print(scheme)

    schedule_cnt = schedule.objects.filter(exam_name = scheme)
    # print(len(schedule_cnt))

    detail = staff_allocation.objects.filter(schedule__exam_name = scheme)

    data = []
    for i in schedule_cnt:
        cr = {'date':i.date,'staff':[]}
        for ii in detail:
            if ii.schedule.date == i.date:
                try:
                    st_row = {'name':ii.staff_id.name+"   ---   "+str(ii.staff_id.dept)+"---"+str(ii.hall_id.hall_name)}
                except:
                    st_row = {'name':ii.staff_id.name+"   ---   "+str(ii.staff_id.dept)+"   ---   Examcell"}


                cr['staff'].append(st_row)
        data.append(cr)
    print(data)
    print(len(data))
    print("========================")

    new_data = [i for i in data if len(i['staff']) != 0]

    print("========================")

    # print(detail.values())
    return JsonResponse({"message":"successfull",'data':new_data,'scheme':scheme})


def get_attendanceBy_date(request):
    date = request.GET.get('date')
    from datetime import datetime

    date_obj = datetime.strptime(date, "%B %d, %Y")
    formatted_date = date_obj.strftime("%Y-%m-%d")

    staff_det = staff_allocation.objects.filter(schedule__date = formatted_date)
    print(staff_det.values())

    data = []
    for i in staff_det:
        try:
            cr = {'name':i.staff_id.name,'dept':i.staff_id.dept.d_name,'exam':i.schedule.exam_name,'hall':i.hall_id.hall_name}
        except:
            cr = {'name':i.staff_id.name,'dept':i.staff_id.dept.d_name,'exam':i.schedule.exam_name,'hall':'Examcell'}

        data.append(cr)
    
    return JsonResponse({"message":"successfull",'data':data,'date':date,})

@custom_login_required
def get_detection_notification(request):
    
    with connection.cursor() as cursor:
        result=[]
        qry="select adminpart_malpractice.*,hour(datetime) as h,adminpart_hall.hall_name from adminpart_malpractice join adminpart_hall ON adminpart_hall.id=adminpart_malpractice.hall_id_id order by adminpart_malpractice.datetime DESC"
        cursor.execute(qry)
        data=cursor.fetchall()
        # cursor.execute("SELECT * FROM exam_cell.adminpart_schedule where date >=curdate() and id not in (SELECT schedule_id from adminpart_staff_allocation);")
        # cursor.execute('''SELECT adminpart_malpractice.*, adminpart_hall.hall_name, adminpart_staff.name
        #                     FROM adminpart_malpractice
        #                     JOIN adminpart_hall ON adminpart_hall.id = adminpart_malpractice.hall_id_id
        #                     JOIN adminpart_staff_allocation ON adminpart_staff_allocation.hall_id_id = adminpart_hall.id
        #                     JOIN adminpart_staff ON adminpart_staff.id = adminpart_staff_allocation.staff_id_id 
        #                     JOIN adminpart_schedule ON adminpart_schedule.id=adminpart_staff_allocation.schedule_id
        #                     WHERE DATE(adminpart_malpractice.datetime) = adminpart_schedule.date
        #                     GROUP BY adminpart_malpractice.id, adminpart_hall.hall_name, adminpart_staff.name 
        #                     order by adminpart_malpractice.datetime DESC;''')
        # row = cursor.fetchall()
       
        for i in data:
            row=list(i)
            sloat="Forenoon"
            if int(i[6])>13:
                sloat="Afternoon"

            qry="select adminpart_staff.name from adminpart_staff join adminpart_staff_allocation on adminpart_staff_allocation.staff_id_id=adminpart_staff.id join adminpart_schedule on adminpart_schedule.id=adminpart_staff_allocation.schedule_id where adminpart_schedule.date='"+str(i[1]).split(' ')[0]+"' and slot='"+sloat+"' and adminpart_staff_allocation.hall_id_id='"+str(i[4])+"'"

            cursor.execute(qry)
            r=cursor.fetchone()
            if r is not None:
                row.append(r[0])
                result.append(row)
                print(row)
    
    malpractice_obcts = malpractice.objects.all()
    for i in malpractice_obcts:
        print('000000000000000000000000000000000000000000')
        i.status=1
        i.save()

    

    return render(request,'mal_noti_detected.html',{"notification":result})



def get_mal_info(request):

    # with connection.cursor() as cursor:

    #     # cursor.execute("SELECT * FROM exam_cell.adminpart_schedule where date >=curdate() and id not in (SELECT schedule_id from adminpart_staff_allocation);")
    #     cursor.execute('''SELECT adminpart_malpractice.*, adminpart_hall.hall_name, adminpart_staff.name
    #                         FROM adminpart_malpractice
    #                         JOIN adminpart_hall ON adminpart_hall.id = adminpart_malpractice.hall_id_id
    #                         JOIN adminpart_staff_allocation ON adminpart_staff_allocation.hall_id_id = adminpart_hall.id
    #                         JOIN adminpart_staff ON adminpart_staff.id = adminpart_staff_allocation.staff_id_id 
    #                         JOIN adminpart_schedule ON adminpart_schedule.id=adminpart_staff_allocation.schedule_id
    #                         WHERE DATE(adminpart_malpractice.datetime) = adminpart_schedule.date and adminpart_malpractice.status=0
    #                         GROUP BY adminpart_malpractice.id, adminpart_hall.hall_name, adminpart_staff.name 
    #                         order by adminpart_malpractice.datetime DESC;''')

    #     row = cursor.fetchall()
    
    row = malpractice.objects.filter(status = 0)
    
    return JsonResponse({'message':True,'count':len(row)})


def get_waiting_students(request):

    students = studentDetails.objects.all()

    return JsonResponse({'message':True,'count':len(students)})








# ---------------------------staff----------app-------------------------------
# ---------------------------staff----------app-------------------------------
# ---------------------------staff----------app-------------------------------



@csrf_exempt
def staff_login(request):
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')
        print(username,password)
        try:
            check_user = login_table.objects.get(username=username)
            is_user_correct = check_user.username == username
            is_correct = check_password(password, check_user.password)
        except:
            check_user = None


        if check_user is not None and is_correct and is_user_correct:
            staff_details = staff.objects.get(l_id = check_user.pk)
            if staff_details.status == 'active':
                return JsonResponse({'status':True,'name':staff_details.name,'id':staff_details.pk,'type':staff_details.stafftype})
            else:
                return JsonResponse({'success': False, 'message': 'user is blocked by admin'},status=401)

        else:
            return JsonResponse({'success': False, 'message': 'Incorrect Username Or Password'},status=401)
    else:
        return JsonResponse({'success': False, 'message': 'Invalid request method'})
    


@csrf_exempt
def get_staff(request):
    if request.method == 'POST':
        staff_id = request.POST.get('id')
        
        
        try:
            staff_obj = staff.objects.get(id = staff_id)
        except:
            staff_obj = None


        if staff_obj is not None :
            print(staff_obj.name,"///////////************////////////*********")
            
            return JsonResponse({'name':staff_obj.name,'id':staff_obj.pk,'type':staff_obj.stafftype,'dept':staff_obj.dept.d_name,'ktu_id':staff_obj.l_id.username})
        else:
            return JsonResponse({'message': 'Invalid credentials'},status=401)
    else:
        return JsonResponse({'message': 'Invalid request method'},status = 401)



@csrf_exempt
def edit_staff_app(request):
    if request.method == 'POST':
        staff_id = request.POST.get('id')
        name = request.POST.get('name')
        
        
        try:
            staff_obj = staff.objects.get(id = staff_id)
            staff_obj.name = name
            staff_obj.save()
        except:
            staff_obj = None


        if staff_obj is not None :
            # print(staff_obj.name,"///////////************////////////*********")
            
            return JsonResponse({'name':staff_obj.name,'id':staff_obj.pk,'type':staff_obj.stafftype,'dept':staff_obj.dept.d_name,'ktu_id':staff_obj.l_id.username})
        else:
            return JsonResponse({'message': 'Invalid credentials'},status=401)
    else:
        return JsonResponse({'message': 'Invalid request method'},status = 401)


@csrf_exempt
def get_allocation(request):
    if request.method == 'POST':
        staff_id = request.POST.get('id')
        try:
            allocobj = staff_allocation.objects.filter(staff_id__id = staff_id).order_by('-schedule__date')
        except:
            allocobj = None
        if allocobj is not None:
            data=[]
            cr={}
            for i in allocobj:
                # print(i.)
                try:
                    cr = {'id':i.pk,'hall':i.hall_id.hall_name,'date':i.schedule.date,'exam':i.schedule.exam_name,'slot':i.schedule.slot}
                except:
                    cr = {'id':i.pk,'hall':'Exam Cell','date':i.schedule.date,'exam':i.schedule.exam_name,'slot':i.schedule.slot}

                data.append(cr)
            # print(data)
            return JsonResponse({'alloc_list': data})
        else:
            return JsonResponse({'message': 'Invalid request method'},status = 401)


@csrf_exempt
def edit_password_app(request):
    if request.method == 'POST':
        staff_id = request.POST.get('id')
        old = request.POST.get('oldpass')
        newpasswd = request.POST.get('newpass')
        try:
            staff_obj = staff.objects.get(id = staff_id)
            login_obj = login_table.objects.get(id = staff_obj.l_id.pk)
            is_correct = check_password(old, login_obj.password)
            hashed_password = make_password(newpasswd)
            
        except:
            is_correct = False
        
        if is_correct:
            login_obj.password = hashed_password
            login_obj.save()

            # print(staff_id,old,newpasswd,"==========================")
            return JsonResponse({'message': 'Successfully changed password'})


        return JsonResponse({'message': 'Invalid Old Password '},status = 401)



@csrf_exempt
def report_mal_practice(request):
    if request.method == 'POST' and request.FILES.get('image'):
        image_file = request.FILES['image']
        message = request.POST.get('message')
        alloc_id = request.POST.get('alloc_id')
        staff_id = request.POST.get('staff_id')
        student_id = request.POST.get('student_id')

        try:
            student = schedule_details.objects.get(id = student_id)
        except:
            return JsonResponse({'message': 'Report again'},status = 401)

        # fs = FileSystemStorage()
        # filename = fs.save(image_file.name, image_file)
        # filepath = fs.path(filename)
        report = report_malpractice(image = image_file,message = message,staff_id = staff.objects.get(id = staff_id) ,alloc_id = staff_allocation.objects.get(id = alloc_id),student_id = student)
        report.save()
        # print(report.image.url,"******************************")

        return JsonResponse({'message': 'Reporting Successfull.'})
    else:
        return JsonResponse({'message': 'Invalid request'},status = 401)




@csrf_exempt
def get_reports(request):
    if request.method == 'POST':
        staff_id = request.POST.get('id')
        try:
            reports = report_malpractice.objects.filter(staff_id__id = staff_id).order_by('-created_at')
        except:
            reports = None
        if reports is not None:
            data=[]
            cr={}
            for i in reports:
                # print(i.)
                date = str(i.created_at).split(" ")

                
                dt = datetime.datetime.fromisoformat(str(i.created_at))

                # Convert to local time (optional)
                dt = dt.astimezone()

                # Format as a string in 12-hour format with AM/PM indication
                formatted_time = dt.strftime("%I:%M %p")

                print(formatted_time,"00000000000000000")


                # print(date)
                cr = {'id':i.pk,'hall':i.alloc_id.hall_id.hall_name,'date':date[0],'time':formatted_time,'exam':i.alloc_id.schedule.exam_name,'slot':i.alloc_id.schedule.slot,'message':i.message,'image':i.image.url}
               

                data.append(cr)

            print(data)
            return JsonResponse({'report': data})
        else:
            return JsonResponse({'message': 'Invalid request method'},status = 401)

@csrf_exempt
def get_students(request):
    if request.POST:
        alloc_id = request.POST.get('alloc_id')
        staff_id = request.POST.get('staff_id')
        alloc_det = staff_allocation.objects.get(id = alloc_id)        
        print(alloc_det.hall_id,alloc_det.schedule,)
        students = schedule_details.objects.filter(shedule_id = alloc_det.schedule, hall_id  = alloc_det.hall_id)

        print(len(students))
        print("===============================")

        data = []
        
        for i in students:
            row ={"id":i.pk,'student':i.student+ " - " +i.reg_no}
            data.append(row)

        print("===============================")
        print(data)
        return JsonResponse({'students': data})
    

@csrf_exempt
def get_report(request):
    if request.POST:
        mal_id = request.POST.get('id')
        print(mal_id)
        report_mal = report_malpractice.objects.get(id = mal_id)
        date = str(report_mal.created_at).split(" ")

                
        dt = datetime.datetime.fromisoformat(str(report_mal.created_at))

                # Convert to local time (optional)
        dt = dt.astimezone()

                # Format as a string in 12-hour format with AM/PM indication
        formatted_time = dt.strftime("%I:%M %p")
        try:
            row = {'student':report_mal.student_id.student,'reg_no':report_mal.student_id.reg_no,'hall':report_mal.alloc_id.hall_id.hall_name,'exam':report_mal.alloc_id.schedule.exam_name,'slot':report_mal.alloc_id.schedule.slot,'date':date[0],'time':formatted_time,'message':report_mal.message,'image':report_mal.image.url}
        except:
            return JsonResponse({'message':'somthing wrong'},status = 401)
        print(report_mal.student_id.student,"=====================")
        return JsonResponse(row)



@csrf_exempt
def get_notification(request):
    if request.POST:
        uid = request.POST.get('uid')
        print(uid,"******************************")

        noti = staff_allocation.objects.filter(staff_id__id = uid,status = 'pending')
        if len(noti) == 0:
            return JsonResponse({'count':len(noti)},status = 401)


        for i in noti:
            i.status = 'viewed'
            i.save()
        print(len(noti))
        return JsonResponse({'count':len(noti)})

@csrf_exempt
def get_mal_notification(request):
    if request.POST:
        staff_id = request.POST.get('id')
        print(staff_id)

        with connection.cursor() as cursor:
            result=[]
            qry="select adminpart_malpractice.*,hour(datetime) as h,adminpart_hall.hall_name from adminpart_malpractice join adminpart_hall ON adminpart_hall.id=adminpart_malpractice.hall_id_id order by adminpart_malpractice.datetime DESC"
            cursor.execute(qry)
            data=cursor.fetchall()
           
        
            for i in data:
                row=list(i)
                sloat="Forenoon"
                if int(i[6])>13:
                    sloat="Afternoon"

                qry="select adminpart_staff.* from adminpart_staff join adminpart_staff_allocation on adminpart_staff_allocation.staff_id_id=adminpart_staff.id join adminpart_schedule on adminpart_schedule.id=adminpart_staff_allocation.schedule_id where adminpart_schedule.date='"+str(i[1]).split(' ')[0]+"' and slot='"+sloat+"' and adminpart_staff_allocation.hall_id_id='"+str(i[4])+"' and adminpart_staff.id='"+str(staff_id)+"' "

                cursor.execute(qry)
                r=cursor.fetchone()
                if r is not None:
                    row.append(r[0])
                    result.append(row)
    # print(result,"99999999999999999999999999999999999999999")
    
    return JsonResponse({'result':result})

@csrf_exempt
def get_mal_notification_back(request):
    if request.POST:
        staff_id = request.POST.get('uid')
        print(staff_id)

        with connection.cursor() as cursor:
            mal_id=[]
            result=[]
            qry="select adminpart_malpractice.*,hour(datetime) as h,adminpart_hall.hall_name from adminpart_malpractice join adminpart_hall ON adminpart_hall.id=adminpart_malpractice.hall_id_id where adminpart_malpractice.staff_status=0 order by adminpart_malpractice.datetime DESC"
            cursor.execute(qry)
            data=cursor.fetchall()
            # print(data[0])
            
           
        
            for i in data:
                row=list(i)
                sloat="Forenoon"
                if int(i[6])>13:
                    sloat="Afternoon"
                    print("##########################")


                qry="select adminpart_staff.* from adminpart_staff join adminpart_staff_allocation on adminpart_staff_allocation.staff_id_id=adminpart_staff.id join adminpart_schedule on adminpart_schedule.id=adminpart_staff_allocation.schedule_id where adminpart_schedule.date='"+str(i[1]).split(' ')[0]+"' and slot='"+sloat+"' and adminpart_staff_allocation.hall_id_id='"+str(i[4])+"' and adminpart_staff.id='"+str(staff_id)+"' "

                cursor.execute(qry)
                r=cursor.fetchone()
                if r is not None:
                    row.append(r[0])
                    result.append(row)
                    mal_id.append(row[0])
                    # print(row)


            if len(result)==0:
                return JsonResponse({"msg":False},status=401)

        

        print(mal_id)
        for i in mal_id:
            mal_obj = malpractice.objects.get(id=i)
            mal_obj.staff_status=1
            mal_obj.save()
        
        

        return JsonResponse({'count':len(result)})




#########################----------REACT JS---------##############################
# import json
# @csrf_exempt
# def login_view(request):
#     if request.method == 'POST':
#         data = request.body.decode('utf-8') # Decode the request body
#         data_dict = json.loads(data) # Parse the JSON string to a dictionary
#         username = data_dict.get('username')
#         password = data_dict.get('password')
#         print(username, password) #
#         try:
#             check_user = login_table.objects.get(username=username)
#             is_user_correct = check_user.username == username
#             is_correct = check_password(password, check_user.password)
#         except:
#             check_user = None


#         if check_user is not None and is_correct and is_user_correct:
#             staff_details = staff.objects.get(l_id = check_user.pk)
#             return JsonResponse({'status':True,'name':staff_details.name,'id':staff_details.pk,'type':staff_details.stafftype})
#         else:
#             return JsonResponse({'success': False, 'message': 'Invalid credentials'},status=500)
#     else:
#         return JsonResponse({'success': False, 'message': 'Invalid request method'})

#########################----------REACT JS---------##############################
