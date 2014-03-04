from django.shortcuts import render, render_to_response, get_object_or_404
from django.http import HttpResponseRedirect, HttpResponse
from django.shortcuts import render, redirect
from django.template import RequestContext
from django.core.urlresolvers import reverse
from encoder_proj import env_settings
from hashlib import sha1
from time import time
from urlparse import urlparse
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

meta = {"x-account-meta-temp-url-key": "rackspace_rocks"}
cf.set_account_metadata(meta)
#-------------------------------------------------------------------------------
def converter_index(request):
    upload_container = cf.create_container("upload")
    upload_container.make_public(ttl=1200)
    completed_container = cf.create_container("completed")
    completed_container.make_public(ttl=1200)

    origin = "https://" + request.META['SERVER_NAME']
    upload_container.set_metadata({'Access-Control-Allow-Origin': origin})

    filename = str(uuid.uuid4())
    expires = 60*60*2
    key = cf.get_account_metadata()['x-account-meta-temp-url-key']

    upload_url = cf.get_temp_url(\
            upload_container, filename, expires, method='PUT', key=key)
    download_url = cf.get_temp_url(\
            upload_container, filename, expires, method='GET', key=key)

    redirect_url = origin + "/status/uploaded/" + filename

    data = {
            'upload_url': upload_url,
            'download_url': download_url,
            'redirect_url': redirect_url,
            }
    template = "converter/index.html"

    print >>sys.stderr, download_url

    if request.method == "GET":
        context_instance = RequestContext(request)
        rendered_response = render_to_response(\
                template, data, context_instance = context_instance)
        return rendered_response
#-------------------------------------------------------------------------------
