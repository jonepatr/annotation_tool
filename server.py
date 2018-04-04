from flask import Flask, render_template, request
import csv
import json
import numpy as np
import math
#not really necessary import, good for debugging:
import matplotlib.pyplot as plt
import pandas as pd

app = Flask(__name__)

#output_list = []

output_list = [None] * 10000


#Read file once:
#read file that might have inconsistent column numbers between rows. Fill with nans:
df=pd.read_csv('RPCLAP_20160921_080404_710_to_patrik2.csv', sep=',',header=None,engine='python')

#Windows hardcoded path
#df=pd.read_csv('/Users/Fredrik/Dropbox (IRFU)/Sweepslave/RPCLAP_20160921_080404_710_to_patrik2.csv', sep=',',header=None,engine='python')


#function that returns IV sweep (two arrays) for a row that may have some extra nan values
def getIV(df,row):
    #remove nan values in df.values[row,:], save in row_array
    row_array=df.values[row,~np.isnan(df.values[row,:])]

    #print ( df.values[row,:].size - row_array.size)
    #some index calculations
    len=row_array.size;
    #print(len)
    header_lines=3;

    i_start= header_lines;
    i_end=int((len-header_lines)/2 +header_lines )
    v_start= i_end #something wierd here with python. calling e.g. X(1:4),X(4:5) I don't care
    v_end= len
   # print(row_array[0],row_array[1],row_array[2],row_array[3])
   # print(i_start)
   # print(i_end)
   # print(v_start)
   # print(v_end)
    #return [I, V]
    return [row_array[i_start:i_end],row_array[v_start:v_end]]

#read file that might have inconsistent column numbers between rows. Fill with nans:
#import pandas as pd
#df=pd.read_csv('/Users/frejon/Downloads/RPCLAP_20160921_080404_710_to_patrik2.csv', sep=',',header=None,engine='python')





@app.route("/")
def hello():
    return render_template('index.html', row_id=0)






@app.route('/next_row/<int:current_row>')
def next_row(current_row):


    I,V = getIV(df,current_row) #Currents & potentials from file. Need to have some max row >= current_row condition here.
    # reading from csv...
    x = sorted(np.random.rand(10)*10)
    y = np.random.rand(10)*10

    data = [{'x': a, 'y': b} for a, b in zip(V, I*1e9)]
    return json.dumps({'data': data})

@app.route('/save_values/<int:row>', methods=['POST'])
def save_values(row):
    print('Adding to csv...', row, request.form.get('Vph'), request.form.get('Vbar'), request.form.get('checker1'), request.form.get('checker2'))

    ind=(row-1)*5
    col1=request.form.get('Vph')
    col2=request.form.get('Vbar')
    col3=request.form.get('checker1')
    col4=request.form.get('checker2')

    output_list[ind]=row
    output_list[ind+1]=col1
    output_list[ind+2]=col2
    output_list[ind+3]=col3
    output_list[ind+4]=col4

    df_out = pd.DataFrame(output_list)
    df_out.to_csv('output.csv', index=False)



    #np.savetxt('data.csv', (row, request.form.get('Vph'), request.form.get('Vbar'),request.form.get('checker')), delimiter=',')

   # np.savetxt('data.csv', (col1_array, col2_array, col3_array), delimiter=',')
    #  with open('filnamn.csv', 'w') as f:
  #      spamwriter = csv.writer(f,delimiter=',')
  #      spamwriter.writerow(row + request.form.get('Vph') + request.form.get('Vbar') + request.form.get('checker'))
    #spamwriter.writerow(['Spam'] * 5 + ['Baked Beans'])

    return 'ok'


if __name__ == "__main__":
    app.run(debug=True)
