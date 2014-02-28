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
#-------------------------------------------------------------------------------
pyrax.set_setting("identity_type", "rackspace")
creds_file = os.path.expanduser("~/pyrax_rc")
region = "ORD"
pyrax.set_credential_file(creds_file, region)
cf = pyrax.cloudfiles
container = "submitted"
cont = cf.create_container(container)
cont.make_public(ttl=1200)
meta = {"x-account-meta-temp-url-key": "rackspace_rocks"}
cf.set_account_metadata(meta)
#-------------------------------------------------------------------------------
def get_form_post_sig(cf_path, redirect_url, max_file_size, 
        max_file_count, expires):

    key = cf.get_account_metadata()['x-account-meta-temp-url-key']

    hmac_body = '%s\n%s\n%s\n%s\n%s' % (cf_path, redirect_url,
        max_file_size, max_file_count, expires)

    sig = hmac.new(key, hmac_body, sha1).hexdigest()
    return sig
#-------------------------------------------------------------------------------
def converter_index(request):
    sc = pyrax.identity.services
    cf_public_endpoint = sc['object_store']['endpoints'][region]['public_url']
    cf_url = cf_public_endpoint + "/" + container

    parsed_uri = urlparse(cf_public_endpoint)
    path = '{uri.path}/'.format(uri=parsed_uri)

    cf_path = path + container
    redirect_url = 'http://23.253.219.5'
    max_file_size = 104857600
    max_file_count = 10
    expires = int(time() + 600)
    sig = get_form_post_sig(cf_path, redirect_url, max_file_size, max_file_count,
            expires)

    data = {
            'cf_url': cf_url,
            'redirect_url': redirect_url,
            'max_file_size': max_file_size,
            'max_file_count': max_file_count,
            'expires': expires,
            'sig': sig
            }
    template = "converter/index.html"

    if request.method == "GET":
        context_instance = RequestContext(request)
        rendered_response = render_to_response(\
                template, data, context_instance = context_instance)
        return rendered_response
#-------------------------------------------------------------------------------
