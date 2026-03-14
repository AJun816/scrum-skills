from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/hello', methods=['GET'])
def hello():
    return jsonify({
        'code': 200,
        'message': 'success',
        'data': {
            'greeting': 'Hello, World!'
        }
    })

@app.route('/ping', methods=['GET'])
def ping():
    return jsonify({
        'code': 200,
        'message': 'success',
        'data': {
            'status': 'ok'
        }
    })

if __name__ == '__main__':
    app.run(debug=True)
