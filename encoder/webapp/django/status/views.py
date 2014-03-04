from django.shortcuts import render, render_to_response, get_object_or_404
from django.http import HttpResponseRedirect, HttpResponse
from django.shortcuts import render, redirect
from django.contrib import messages
from django.template import RequestContext
from django.core.urlresolvers import reverse
import sys
#-------------------------------------------------------------------------------
def status_index(request):

    data = {
            }
    template = "status/index.html"

    if request.method == "GET":
        context_instance = RequestContext(request)
        rendered_response = render_to_response(\
                template, data, context_instance = context_instance)
        return rendered_response
#-------------------------------------------------------------------------------
