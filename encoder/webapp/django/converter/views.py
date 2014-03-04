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
upload_cont_name = "upload"
completed_cont_name = "completed"
#-------------------------------------------------------------------------------
def converter_index(request):
    upload_cont = cf.create_container(upload_cont_name)
    upload_cont.make_public(ttl=1200)
    completed_cont = cf.create_container(completed_cont_name)
    completed_cont.make_public(ttl=1200)

    origin = "https://" + request.META['SERVER_NAME']
    upload_cont.set_metadata({'Access-Control-Allow-Origin': origin})

    orig_uuid = str(uuid.uuid4())
    upload_url = cf.get_temp_url(upload_cont_name, orig_uuid, 60*60*3, 'PUT')

    redirect_url = "/converter/uploaded/?orig_uuid=" + orig_uuid

    data = {
            'upload_url': upload_url,
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
    try:
        orig_uuid = request.GET['orig_uuid']
        filename = request.GET['filename']

        download_url = cf.get_temp_url(upload_cont_name, orig_uuid, 60*60*3,
                'GET') + "&filename=" + filename

        messages.add_message(request, messages.SUCCESS, 'job_created_success')
        return HttpResponseRedirect(reverse('status_index'))
    except Exception,e:
        return HttpResponseRedirect('/')
#-------------------------------------------------------------------------------
