
from django.urls import path,include
from . import views
urlpatterns = [
    
    path('', views.index,name='index'),
    path('home',views.home,name='home'),
    path('staff_list',views.staff_list,name='staff_list'),
    path('login_user',views.login_user,name='login_user'),
    path('admin_logout',views.admin_logout,name='admin_logout'),
    path('add_staff',views.add_staff,name='add_staff'),
    path('edit_staff/<int:id>',views.edit_staff,name='edit_staff'),
    path('alter_staff',views.alter_staff,name='alter_staff'),
    path('room_list',views.room_list,name='room_list'),
    path('add_room',views.add_room,name='add_room'),
    path('edit_room/<int:id>',views.edit_room,name='edit_room'),
    path('room_edit',views.room_edit,name='room_edit'),

    path('delete_room/<int:id>',views.delete_room,name='delete_room'),
    path('change_status_inactive/<int:id>',views.change_status_to_inactive,name='change_status_inactive'),
    path('seating',views.seating,name='seating'),
    path('select_halls',views.select_halls,name='select_halls'),


    path('duties',views.duties,name='duties'),   
    path('allocate_duties',views.allocate_duties,name='allocate_duties'),
    path('selectDuties',views.selectDuties,name='selectDuties'),

    path('generate_reports',views.generate_reports,name='generate_reports'),
    path('halls_and_reports',views.halls_and_reports,name='halls_and_reports'),
    path('reports_in_hall/<int:id>',views.reports_in_hall,name='reports_in_hall'),
    path('download_seating/<int:id>',views.download_seating,name='download_seating'),
    path('download_attendance/<int:id>',views.download_attendance,name='download_attendance'),
    path('display_report',views.display_report,name='display_report'),
    path('allocate_duties_post',views.allocate_duties_post,name='allocate_duties_post'),
    path('edit_allocation/<int:id>',views.edit_allocation,name='edit_allocation'),

    path('edit_allocated_staff/',views.edit_allocated_staff,name='edit_allocated_staff'),
    path('remove_allocated_staff/',views.remove_allocated_staff,name='remove_allocated_staff'),

    path('seating_history',views.seating_history,name='seating_history'),
    path('report_in_halls_history/<int:id>',views.report_in_halls_history,name='report_in_halls_history'),
    path('download_seating_history/<int:id>',views.download_seating_history,name='download_seating_history'),
    path('download_attendance_history/<int:id>',views.download_attendance_history,name='download_attendance_history'),
    path('display_report_history',views.display_report_history,name='display_report_history'),


    path('attendance_marking',views.attendance_marking,name='attendance_marking'),
    path('mark_absenties/',views.mark_absenties,name='mark_absenties'),
    path('view_attendance/',views.view_attendance,name='view_attendance'),
















    # staff----app---------

    path('staff_login',views.staff_login,name='staff_login'),
    path('get_staff',views.get_staff,name='get_staff'),
    path('edit_staff_app',views.edit_staff_app,name='edit_staff_app'),






]