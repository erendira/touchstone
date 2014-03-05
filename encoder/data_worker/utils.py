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
import MySQLdb
import urllib
import traceback
#-------------------------------------------------------------------------------
pyrax.set_setting("identity_type", "rackspace")
creds_file = os.path.expanduser("~/pyrax_rc")
pyrax.set_credential_file(creds_file)

c = Converter()
table="converter_encodingjob"
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

    def on_job_execute(self, current_job):
        print "Job started"
        return super(JSONGearmanWorker, self).on_job_execute(current_job)

    def on_job_exception(self, current_job, exc_info):
        print "Job failed"
        ex_type, ex, tb = exc_info
        print ex_type, ex, traceback.print_tb(tb)
        return super(JSONGearmanWorker, self).on_job_exception(\
                current_job, exc_info)

    def on_job_complete(self, current_job, job_result):
        print "Job completed"
        return super(JSONGearmanWorker, self).send_job_complete(\
                current_job, job_result)

    def after_poll(self, any_activity):
        # Return True if you want to continue polling, replaces callback_fxn
        return True
#-------------------------------------------------------------------------------
class Utils:
#-------------------------------------------------------------------------------
    def __init__(self):
        None
#-------------------------------------------------------------------------------
    def mysql_call(self, cmd):
        db = MySQLdb.connect(
                host = env_settings.MYSQL_HOST,
                user = env_settings.MYSQL_USER,
                passwd = env_settings.MYSQL_PASSWORD,
                db = env_settings.MYSQL_DB
                )

        cur = db.cursor(MySQLdb.cursors.DictCursor)
        cur.execute(cmd)
        db.commit()

        results = cur.fetchall()

        cur.close()
        db.close()

        return results
#-------------------------------------------------------------------------------
    def encode_job(self, gearman_worker, gearman_job):
        passed_data = gearman_job.data

        job_id = passed_data['job_id']

        # pull job info
        cmd = "SELECT * FROM %s WHERE id=%s;" % (table, job_id)
        job = self.mysql_call(cmd)[0]

        orig_uuid = job['orig_uuid']
        filename = job['filename']
        status = job['status']
        urls = json.loads(job['urls'])
        created_at = job['created_at']

        output_path = '/tmp/' + orig_uuid
        urllib.urlretrieve(urls['original_snet'], output_path)

        # update status
        cmd = "UPDATE %s SET status='%s' WHERE id=%s;" % \
                (table, "processing", job_id)
        results = self.mysql_call(cmd)
        
        return None
#-------------------------------------------------------------------------------
    def register_job(self, gm_servers, task_name, task_function):
        gm_worker = JSONGearmanWorker(gm_servers)
        gm_worker.register_task(task_name, task_function)
        gm_worker.work()
#-------------------------------------------------------------------------------
#===============================================================================
