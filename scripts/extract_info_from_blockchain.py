##################################################
## Description: This script is the function for Flipside Crypto interview
## Author: Xiuyang Guan
## Version: 0.0.1
## Email: xiuyangguan@gmail.com
## Status: Done
##################################################

# Import packages for the function 
import pandas as pd 
import json
import requests
import pytz
from datetime import datetime

# function 
def extract_info_from_blockchain(url):
    # this function takes only one input, which is the JSON url and then converted the output to the following array structure:
    #-----------------------------
    ## block_id: for the entire block, the unique id
    ## block_timestamp: for the entire block, the timestep, format is iso time format and the timezone is Eastern
    ## tx_hash: for each transactions unique hash
    ## address_from: for each transaction, the address from 
    #-----------------------------

    # Set the timezone transform format
    tz = pytz.timezone('US/Eastern')

    r = requests.get(url=url).json()
    block_timestamp = datetime.fromtimestamp(r['data'][0]['timestamp'], tz).isoformat()

    transactions = r['data'][0]['transactions']
    out = [{
            "block_id": x['block_number'],
            "block_timestamp": block_timestamp,
            "tx_hash": x['hash'],
            "address_from": x['from']
        } for x in transactions]
    return out

# Test the url: https://gist.githubusercontent.com/jfmyers/16f784e4add6410aff8f2e3c54d4a12a/raw/4f0a906cf9b496c749ad32d95be2d6a6fe70cee3/json
url_1 = "https://gist.githubusercontent.com/jfmyers/16f784e4add6410aff8f2e3c54d4a12a/raw/4f0a906cf9b496c749ad32d95be2d6a6fe70cee3/json"
print(extract_info_from_blockchain(url_1))
