import record_and_push
import pytest
import os


CALMEQ_DEVICE_SERVER_QA="http://calmeq-devices-qa.herokuapp.com"

def test_register_device():
    siteaddress=CALMEQ_DEVICE_SERVER_QA
    id = record_and_push.register_device( siteaddress, True )
    assert id >= 0

def test_A_weighting():
    #TODO: @cprohan add a unit test here
    assert True

def test_push_data():
    db = 42.42
    id = 11
    siteaddress = CALMEQ_DEVICE_SERVER_QA
    statuscode = record_and_push.push_data(db, id, siteaddress)
    assert statuscode == 200

@pytest.mark.skipif(os.environ.get('CIRCLECI') == 'true', reason="requires audio card")
def test_main():
    isgood = record_and_push.main( "QA", True )
    assert isgood
