from django.contrib import messages
from django.core.urlresolvers import reverse
from django.http import HttpResponseRedirect
from django.shortcuts import render_to_response
from django.template import RequestContext
from encoder_proj import env_settings
from converter.models import EncodingJob
import MySQLdb
import os
import sys
import pyrax
import uuid
#-------------------------------------------------------------------------------
pyrax.set_setting("identity_type", "rackspace")
creds_file = os.path.expanduser("~/pyrax_rc")
pyrax.set_credential_file(creds_file, "ORD")

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
    except Exception,e:
        return HttpResponseRedirect('/')

    try:
        download_url = cf.get_temp_url(upload_cont_name, orig_uuid, 60*60*3,
                'GET') + "&filename=" + filename

        job_data = {
                'orig_uuid': orig_uuid,
                'filename': filename,
                'status': "submitted",
                'urls': {
                    'orig': download_url,
                    },
                }
        create_encoding_job(job_data)

        messages.add_message(request, messages.SUCCESS, 'job_submit_success')
        return HttpResponseRedirect(reverse('status_index'))
    except Exception,e:
        messages.add_message(request, messages.ERROR, 'job_submit_error')
        return HttpResponseRedirect('/')
#-------------------------------------------------------------------------------
def create_encoding_job(data):
    j = EncodingJob(
        orig_uuid = data['orig_uuid'],
        filename = data['filename'],
        status = data['status'],
        urls = data['urls'],
        )

    j.save()
#-------------------------------------------------------------------------------
