import random
import syncfile
import pytest
import botocore

CALMEQ_TEST_BUCKET="calmeq.testing"

def test_syncfile():
    """                                                                                                                            post random data to s3, then pull down and assert the same                                                                     """
    # load it in                                                                                                                
    testfile = 'test/intest.mp3'
    bucketname = CALMEQ_TEST_BUCKET
    ret = syncfile.initbucket(bucketname)
    key = syncfile.syncfile(testfile, bucketname)

    # test it                                                                                                                   
    outdata = syncfile.getdata(key, bucketname)
    indata = open(testfile).read()
    assert(indata == outdata )

    # delete the temp object                                                                                                   
    resp = syncfile.deleteobj(key, bucketname)
    assert( resp['ResponseMetadata']['HTTPStatusCode'] == 204 )



