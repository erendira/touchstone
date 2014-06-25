from django.shortcuts import render, render_to_response, get_object_or_404
from django.http import HttpResponseRedirect, HttpResponse
from django.shortcuts import render, redirect
from django.template import RequestContext
from helloworld_proj import env_settings
#-------------------------------------------------------------------------------
def home_index(request):
    page = "home"
    referrer_http_host = request.META['HTTP_HOST']
    referrer_remote_addr = request.META['REMOTE_ADDR']
    data = {
            'page': page,
            'referrer_http_host': referrer_http_host,
            'referrer_remote_addr': referrer_remote_addr,
            'hostname': env_settings.HOSTNAME,
            }
    template = "home/index.html"

    if request.method == "GET":
        context_instance = RequestContext(request)
        rendered_response = render_to_response(\
                template, data, context_instance = context_instance)
        return rendered_response
#-------------------------------------------------------------------------------
