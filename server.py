from flask import Flask, render_template, request
import csv
import json
import numpy as np


app = Flask(__name__)

@app.route("/")
def hello():
    return render_template('index.html', row_id=0)


@app.route('/next_row/<int:current_row>')
def next_row(current_row):
    # reading from csv...
    x = sorted(np.random.rand(10)*10)
    y = np.random.rand(10)*10
    data = [{'x': a, 'y': b} for a, b in zip(x, y)]
    return json.dumps({'data': data})

@app.route('/save_values/<int:row>', methods=['POST'])
def save_values(row):
    print('Adding to csv...', row, request.form.get('first_text'), request.form.get('second_text'), request.form.get('checker'))
    return 'ok'


if __name__ == "__main__":
    app.run(debug=True)
