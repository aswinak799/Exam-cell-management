
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


]