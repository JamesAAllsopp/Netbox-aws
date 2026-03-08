import boto3
import botocore
import botocore.session
import psycopg2
import logging

logger = logging.getLogger()
logger.setLevel("INFO")


import os
import json
import urllib.request


def get_rds_address():
    return os.environ.get('RDS_ADDRESS')}

def get_admin_secret_name():
    return 'database_access_creds' #Doesn't need to be hardcoded, but saves a job.

def get_netbox_user_secret_name():
    return 'netbox_access_creds'

def get_secret(secret_name):
    # The extension listens on port 2773 by default
    url = f"http://localhost:2773/secretsmanager/get?secretId={secret_name}"
    
    # The extension requires the AWS_SESSION_TOKEN as a header for security
    headers = {"X-Aws-Parameters-Secrets-Token": os.environ.get('AWS_SESSION_TOKEN')}
    
    req = urllib.request.Request(url, headers=headers)
    
    try:
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode())
            return data.get('SecretString')
    except Exception as e:
        print(f"Error fetching secret: {e}")
        raise e

def get_json():
    """Retrieve JSON from server."""
    # Business Logic Goes Here.
    response = {
        "statusCode": 200,
        "headers": {},
        "body": {
            "message": "This is the message in a JSON object."
        }
    }
    return response

def lambda_handler(event, context):
    logger.info(f'boto3 version: {boto3.__version__}')
    logger.info(f'botocore version: {botocore.__version__}')

    #Try and get a scret 
    admin_pw = json.loads(get_secret('database_access_creds'))
    netbox_pw = json.loads(get_secret('netbox_access_creds'))
    
    conn = None
    ssl_cert_path = os.path.join(os.environ['LAMBDA_TASK_ROOT'], 'global-bundle.pem')
    try:
        conn = psycopg2.connect(
           host='netbox-db.c3qak6qw21ru.eu-west-2.rds.amazonaws.com',
           port=5432,
           database='postgres',
           user=admin_pw['user'],
           password=admin_pw['password'],
           sslmode='verify-full',
           sslrootcert=ssl_cert_path
        )
        cur = conn.cursor()
        cur.execute('SELECT version();')
        print(cur.fetchone()[0])
        cur.close()    
    except Exception as e:
        print(f"Database error: {e}")
        raise
    finally:
        if conn:
            conn.close()

    return get_json()

