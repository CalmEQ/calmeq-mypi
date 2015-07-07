#!/usr/bin/env python
"""
Given an 'interesting' file push it to S3 and then push the resulting reference to the file to 
calmeq-devices db.
"""



'''
Workflow summary:
- device wants to register
- device is approved, keys are exchanged (amazon key for s3 onto pi, remote login key for pi to server
- device gets its id cached.
- device starts to record (use the keepalive script we saw on the docker for pi page, (supervisor?)
- device continues to record (2/5 min files)
  - recordings are analyzed once complete, stats saved locally
  - if interesting push file to S3, grab file reference
  - post to server the noise data, and if interesting the reference
  - if no internet access, wait to post to s3 and device server until there is internet access

'''

import boto3
import argparse
import os
import logging

CALMEQ_SAMPLE_BUCKET="calmeq.samples"


def syncfile( filename, bucketname ):
    """
    Given an 'interesting' file push it to S3 and then push the resulting reference to the file to 
    calmeq-devices db.
    """
    deviceid = open('/etc/calmeq-device-id').read()
    shortname = os.path.splitext(os.path.basename(filename))[0]
    key = deviceid + "/" + shortname
    s3 = boto3.resource('s3')
    data = open(filename)
    bucket = s3.Bucket(bucketname)
    logging.info("adding {} to bucket {} under key {}" .format(filename, bucketname, key ) )
    obj = bucket.put_object( Key = key, Body = data );
    return key


# make sure aws configure has been run, or that the secrete key for s3 has been loaded into ~/.aws/credentials

def initbucket( bucketname ):
    """
    initialize the bucket
    """
    s3 = boto3.resource('s3')
    bucket = s3.Bucket(bucketname)
    ret = bucket.create()
    return ret


def getdata( key, bucketname ):
    """
    get data from s3
    """
    s3 = boto3.resource('s3')
    bucket = s3.Bucket(bucketname)
    obj = bucket.Object(key)
    response = obj.get()
    data = response['Body'].read()
    return data

def deleteobj( key, bucketname ):
    """
    deletes the specified key from the bucket
    """
    s3 = boto3.resource('s3')
    bucket = s3.Bucket(bucketname)
    obj = bucket.Object(key);
    res = obj.delete()
    return res


if __name__ == "__main__":
    """
    Main function, push the data
    """
    parser = argparse.ArgumentParser();
    parser.add_argument("filename", help="mp3 data to add to s3, prints the result resource name" )
    parser.add_argument("-b", "--bucket", help="name of bucket to use, defaults to $CALMEQ_SAMPLE_BUCKET" )
    args = parser.parse_args();

    main( args.filename, args.bucketname )





