from django.contrib import admin

from .models import *

class departmentAdmin(admin.ModelAdmin):
    list_display = ('pk','d_name')
class studentDetailsAdmin(admin.ModelAdmin):
    list_display = ('reg_no','student','subject','schedule')

class subjectAdmin(admin.ModelAdmin):
    list_display = ('code','branch','sub_name')

class scheduleAdmin(admin.ModelAdmin):
    list_display = ('date','slot','exam_name')



# Register your models here.
admin.site.register(staff)
admin.site.register(hall)
admin.site.register(department,departmentAdmin)
admin.site.register(login_table)
admin.site.register(staff_allocation)
admin.site.register(staff_Attendance)
admin.site.register(schedule,scheduleAdmin)
admin.site.register(schedule_details)
admin.site.register(malpractice)
admin.site.register(report_malpractice)
admin.site.register(subject,subjectAdmin)
admin.site.register(upload_excel_sheet)
admin.site.register(studentDetails,studentDetailsAdmin)
admin.site.register(countList)