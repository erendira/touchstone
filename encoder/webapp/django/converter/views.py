from django.shortcuts import render, render_to_response, get_object_or_404
from django.http import HttpResponseRedirect, HttpResponse
from django.shortcuts import render, redirect
from django.template import RequestContext
from django.core.urlresolvers import reverse
from encoder_proj import env_settings
import sys
#-------------------------------------------------------------------------------
def converter_index(request):
    page = "converter"
    data = {
            'page': page,
            }
    template = "converter/index.html"

    if request.method == "GET":
        context_instance = RequestContext(request)
        rendered_response = render_to_response(\
                template, data, context_instance = context_instance)
        return rendered_response
    if request.method == "POST":
        for key, file in request.FILES.items():
            path = file.name
            dest = open(path, 'w')
            if file.multiple_chunks:
                for c in file.chunks():
                    dest.write(c)
            else:
                dest.write(file.read())
            dest.close()
            #print >>sys.stderr, env_settings.GEARMAN_SERVER
        return HttpResponseRedirect('/')
#-------------------------------------------------------------------------------
