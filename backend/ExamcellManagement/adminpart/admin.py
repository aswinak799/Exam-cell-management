from django.contrib import admin

from .models import department,hall,staff,login_table,staff_allocation,staff_Attendance,schedule,schedule_details,malpractice,report_malpractice,subject

class departmentAdmin(admin.ModelAdmin):
    list_display = ('pk','d_name')



# Register your models here.
admin.site.register(staff)
admin.site.register(hall)
admin.site.register(department,departmentAdmin)
admin.site.register(login_table)
admin.site.register(staff_allocation)
admin.site.register(staff_Attendance)
admin.site.register(schedule)
admin.site.register(schedule_details)
admin.site.register(malpractice)
admin.site.register(report_malpractice)
admin.site.register(subject)