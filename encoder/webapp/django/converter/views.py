from django.contrib import messages
from django.core.urlresolvers import reverse
from django.http import HttpResponseRedirect
from django.shortcuts import render_to_response
from django.template import RequestContext
from encoder_proj import env_settings
from converter.models import EncodingJob
from utils import Utils, JSONGearmanClient
import MySQLdb
import os
import sys
import pyrax
import uuid
#-------------------------------------------------------------------------------
pyrax.set_setting("identity_type", "rackspace")
creds_file = os.path.expanduser("~/pyrax_rc")
region = env_settings.REGION.upper()
pyrax.set_credential_file(creds_file, region)

cf = pyrax.cloudfiles

meta = {"x-account-meta-temp-url-key": "a_bad_key_to_use"}
cf.set_account_metadata(meta)

# Only use service net for cloudfiles if on public cloud, not private
if env_settings.USE_SNET == "true":
    snet_cf = pyrax.connect_to_cloudfiles(region, public=False)
    snet_cf.set_account_metadata(meta)
else:
    snet_cf = cf

uploaded_cont_name = "uploaded"
completed_cont_name = "completed"
#-------------------------------------------------------------------------------
def converter_index(request):
    uploaded_cont = cf.create_container(uploaded_cont_name)
    completed_cont = cf.create_container(completed_cont_name)

    origin = "https://" + request.META['SERVER_NAME']
    if request.META['SERVER_PORT'] != "80":
       origin += ":" + str(request.META['SERVER_PORT'])
    uploaded_cont.set_metadata({'Access-Control-Allow-Origin': origin})

    key = cf.get_account_metadata()['x-account-meta-temp-url-key']

    orig_uuid = str(uuid.uuid4())
    uploaded_url = cf.get_temp_url(uploaded_cont_name, orig_uuid, 60*60, 'PUT',
            key=key)

    redirect_url = "/converter/uploaded/?orig_uuid=" + orig_uuid

    data = {
            'uploaded_url': uploaded_url,
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

        key = cf.get_account_metadata()['x-account-meta-temp-url-key']
        public_dl_url = cf.get_temp_url(uploaded_cont_name, orig_uuid, 60*60*3,
                'GET', key=key) + "&filename=" + filename

        snet_dl_url = snet_cf.get_temp_url(uploaded_cont_name, orig_uuid,
                60*60*3, 'GET', key=key) + "&filename=" + filename

        job_data = {
                'orig_uuid': orig_uuid,
                'filename': filename,
                'status': "submitted",
                'urls': {
                    'original': public_dl_url,
                    'original_snet': snet_dl_url,
                    },
                }
        create_encoding_job(job_data)

        messages.add_message(request, messages.SUCCESS, 'job_submit_success')
        status_path = request.META['HTTP_REFERER'] + "status/"
        return HttpResponseRedirect(status_path)
    except Exception,e:
        messages.add_message(request, messages.ERROR, 'job_submit_error')
        return HttpResponseRedirect('/')
#-------------------------------------------------------------------------------
def submit_job(task_name, job_id):
    server = env_settings.GEARMAN_SERVER + ":4730"
    GM_SERVERS = [server]
    gm_client = JSONGearmanClient(GM_SERVERS)

    data = {
            "job_id": job_id
            }

    try:
        job_request = gm_client.submit_job(\
                task_name,
                data,
                priority=None,
                background=True,
                wait_until_complete = False,
                )
    except Exception,e:
        None
#-------------------------------------------------------------------------------
def create_encoding_job(data):
    j = EncodingJob(
        orig_uuid = data['orig_uuid'],
        filename = data['filename'],
        status = data['status'],
        urls = data['urls'],
        )

    j.save()

    submit_job("encode", j.id)
#-------------------------------------------------------------------------------
