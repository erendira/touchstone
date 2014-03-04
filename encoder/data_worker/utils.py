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
        print "In encode job" 
        
        return None
#-------------------------------------------------------------------------------
    def register_job(self, gm_servers, task_name, task_function):
        gm_worker = JSONGearmanWorker(gm_servers)
        gm_worker.register_task(task_name, task_function)
        gm_worker.work()
#-------------------------------------------------------------------------------
#===============================================================================
