from flask import Flask, request
from numpy import byte
import ml
import json

app = Flask(__name__)

@app.route('/')
def hello_world():
   return f'Hellos World'

@app.route('/api',methods = ['GET'])
def mlapi():
   d = {}
   inputarr = (request.args['array'])
   arr = json.loads(inputarr)
   bytearr = bytearray(arr)
   gender = ml.call(bytearr)
   d['output'] = gender
   return d

if __name__ == '__main__':
   app.run()