from django.shortcuts import redirect


def custom_login_required(view_func):
    def wrapper(request, *args, **kwargs):
        # Check if the user is logged in
        if not request.session.get('is_logged_in'):
            # Redirect to the login page if the user is not logged in
            return redirect('index')

        # Call the view function if the user is logged in
        return view_func(request, *args, **kwargs)

    return wrapper
