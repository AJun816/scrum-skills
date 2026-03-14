import pytest
from app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_hello(client):
    response = client.get('/hello')
    assert response.status_code == 200
    data = response.get_json()
    assert data['code'] == 200
    assert data['message'] == 'success'
    assert 'greeting' in data['data']

def test_ping(client):
    response = client.get('/ping')
    assert response.status_code == 200
    data = response.get_json()
    assert data['code'] == 200
    assert data['message'] == 'success'
    assert data['data']['status'] == 'ok'
