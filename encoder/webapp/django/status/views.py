from collections import OrderedDict
from django.shortcuts import render, render_to_response, get_object_or_404
from django.http import HttpResponseRedirect, HttpResponse
from django.shortcuts import render, redirect
from django.contrib import messages
from django.template import RequestContext
from django.core.urlresolvers import reverse
from converter.models import EncodingJob
import sys
#-------------------------------------------------------------------------------
def status_index(request):

    jobs = list(EncodingJob.objects.all().order_by('-created_at'))

    # remove snet urls
    for index, job in enumerate(jobs):
        scrubbed_urls = {}
        for name, url in job.urls.iteritems():
            if "snet" not in name:
                scrubbed_urls[name] = url
        sorted_scrubbed = sorted(scrubbed_urls.items(), key=lambda t: t[0])
        jobs[index].urls = OrderedDict(sorted_scrubbed)

    data = {
            'jobs': jobs
            }
    template = "status/index.html"

    if request.method == "GET":
        context_instance = RequestContext(request)
        rendered_response = render_to_response(\
                template, data, context_instance = context_instance)
        return rendered_response
#-------------------------------------------------------------------------------
