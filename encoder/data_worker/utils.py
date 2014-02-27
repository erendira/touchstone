#===============================================================================
from gearman import GearmanWorker, DataEncoder
from converter import Converter
import json
import env_settings
import sys, os
import os
import pyrax
import pyrax.exceptions as exc
import pyrax.utils as utils
import uuid
import MySQLdb
#-------------------------------------------------------------------------------
pyrax.set_setting("identity_type", "rackspace")
creds_file = os.path.expanduser("~/pyrax_rc")
pyrax.set_credential_file(creds_file)

c = Converter()
#-------------------------------------------------------------------------------
class JSONDataEncoder(DataEncoder):
    @classmethod
    def encode(cls, encodable_object):
        return json.dumps(encodable_object)
    
    @classmethod
    def decode(cls, decodable_string):
        return json.loads(decodable_string)
#-------------------------------------------------------------------------------
class JSONGearmanWorker(GearmanWorker):
    data_encoder = JSONDataEncoder
#-------------------------------------------------------------------------------
class Utils:
#-------------------------------------------------------------------------------
    def __init__(self):
        None
#-------------------------------------------------------------------------------
    def encode_job(self, gearman_worker, gearman_job):
        formats = { 
                'mkv': ('aac', 'h264'),
                #'ogg': ('vorbis', 'theora'),
                #'avi': ('aac', 'mpeg2'),
                'webm': ('vorbis', 'vp8')
                }

        for format,codecs in formats.items():
            conv = c.convert(video, 'output.' + format, {
                'format': format,
                'audio': { 'codec': codecs[0] },
                'video': { 'codec': codecs[1] }
                })

            for timecode in conv:
                print "Converting (%f) ...\r" % timecode
        
        return None
#-------------------------------------------------------------------------------
    def register_job(self, gm_servers, task_name, task_function):
        gm_worker = JSONGearmanWorker(gm_servers)
        gm_worker.register_task(task_name, task_function)
        gm_worker.work()
#-------------------------------------------------------------------------------
#===============================================================================
