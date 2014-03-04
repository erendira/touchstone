from django.contrib import messages
from django.core.urlresolvers import reverse
from django.http import HttpResponseRedirect, HttpResponse
from django.shortcuts import render, render_to_response, redirect
from django.template import RequestContext
from encoder_proj import env_settings
from hashlib import sha1
from time import time
from urlparse import urlparse
import base64
import hmac
import MySQLdb
import os
import pyrax
import pyrax.exceptions as exc
import pyrax.utils as utils
import sys
import uuid
#-------------------------------------------------------------------------------
pyrax.set_setting("identity_type", "rackspace")
creds_file = os.path.expanduser("~/pyrax_rc")
region = "ORD"
pyrax.set_credential_file(creds_file, region)

cf = pyrax.cloudfiles

#meta = {"x-account-meta-temp-url-key": "rackspace_rocks"}
#cf.set_account_metadata(meta)
#-------------------------------------------------------------------------------
def converter_index(request):
    upload_container = cf.create_container("upload")
    upload_container.make_public(ttl=1200)
    completed_container = cf.create_container("completed")
    completed_container.make_public(ttl=1200)

    origin = "https://" + request.META['SERVER_NAME']
    #origin = "http://" + request.META['SERVER_NAME'] + ":" + request.META['SERVER_PORT']
    upload_container.set_metadata({'Access-Control-Allow-Origin': origin})

    unique_id = str(uuid.uuid4())
    expires = 60*60*3

    upload_url = cf.get_temp_url(\
            upload_container, unique_id, expires, method='PUT')
    download_url = cf.get_temp_url(\
            upload_container, unique_id, expires, method='GET')

    redirect_url = "/converter/uploaded/?unique_id=" + unique_id

    data = {
            'upload_url': upload_url,
            'b64_download_url': base64.b64encode(download_url),
            'redirect_url': redirect_url,
            }
    template = "converter/index.html"


    if request.method == "GET":
        context_instance = RequestContext(request)
        rendered_response = render_to_response(\
                template, data, context_instance = context_instance)
        return rendered_response
#-------------------------------------------------------------------------------
def uploaded(request):
    unique_id = request.GET['unique_id']
    filename = request.GET['filename']
    download_url = base64.b64decode(request.GET['b64_download_url']) +\
            "&filename=" + filename

    print >>sys.stderr, unique_id, download_url

    if unique_id and download_url:
        messages.add_message(request, messages.SUCCESS, 'job_created_success')
        return HttpResponseRedirect(reverse('status_index'))
    else:
        return HttpResponseRedirect(reverse('converter_index'))
#-------------------------------------------------------------------------------
