#===============================================================================
#-------------------------------------------------------------------------------
from gearman import GearmanClient, DataEncoder
import json
#-------------------------------------------------------------------------------
class Utils:
#-------------------------------------------------------------------------------
    def __init__(self):
        None
#-------------------------------------------------------------------------------
class JSONDataEncoder(DataEncoder):
    @classmethod
    def encode(cls, encodable_object):
        return json.dumps(encodable_object)

    @classmethod
    def decode(cls, decodable_string):
        return json.loads(decodable_string)

class JSONGearmanClient(GearmanClient):
    data_encoder = JSONDataEncoder
#-------------------------------------------------------------------------------
#===============================================================================
