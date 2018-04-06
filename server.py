from flask import Flask, render_template, request
import json
import numpy as np
import math
import pandas as pd
#not really necessary import, good for debugging:
import matplotlib.pyplot as plt
import csv

app = Flask(__name__)

#output_list = []
#initialise output_list. This is ugly.. Enough for 2000 sweeps though.
#output_list = [None] * 10000
output_list = [None] * 2000


#Read file once:
#read file that might have inconsistent column numbers between rows. Fill with nans:
#df=pd.read_csv('RPCLAP_20160921_080404_710_to_patrik2.csv', sep=',',header=None,engine='python')
df=pd.read_csv('generatedsweeps_3.csv', sep=',',header=None,engine='python')
global identifier

#Windows hardcoded path
#df=pd.read_csv('/Users/Fredrik/Dropbox (IRFU)/Sweepslave/RPCLAP_20160921_080404_710_to_patrik2.csv', sep=',',header=None,engine='python')


#function that returns IV sweep (two arrays) for a row that may have some extra nan values
def getIV(df,row):
    #remove nan values in df.values[row,:], save in row_array
    global identifier
    identifier=df.loc[row,0]

    #remove nan values in df.values[row,:], save in row_array
    #row_array=df.values[row,pd.notnull(df.values[row,:])]
    row_array=df.values[row,:]

    row_array = np.delete(row_array, [0,1], 0); #delete column 0 & 1
    #row_array2=row_array[row_array!=-1000]
    row_array=row_array.astype('float')
#    indb=np.absolute(row_array+1000)>1e-10
    ind_end=max(np.where(np.absolute(row_array+1000)>1e-10)[0])#find last non-nan (actually not -1000) value
    #print(ind_end)
    row_array=row_array[0:ind_end-1];



#    row_array=row_array[indb]

    #print ( df.values[row,:].size - row_array.size)
    #some index calculations
    leng=row_array.size;
    #print(len)
    header_lines=0;

    i_start= header_lines;
    i_end=int((leng-header_lines)/2 +header_lines )
    v_start= i_end #something wierd here with python. calling e.g. X(1:4),X(4:5) I don't care
    v_end= leng


    I=row_array[i_start:i_end]
    V=row_array[v_start:v_end]
    mask = np.ones(len(I), dtype=bool)
    mask[I==-1000] = False
    V=V[mask]
    I=I[mask]
    #I=I.astype('float')
    #V=V.astype('float')

   # print(row_array[0],row_array[1],row_array[2],row_array[3])
   # print(i_start)
   # print(i_end)
   # print(v_start)
    #print(identifier)
    #return [I, V]
    return [I,V]

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

    #I=1e9*I
    #indb=np.absolute(I+1000)>1e-10#remove any remaining NaN (-1000)
    #V=V[indb+1]
    #I=I[indb+1]

#    V(np.isnan(I))=[]
#    I(np.isnan(I))=[]



    I=np.round(1e9*I*1e5)/1e5
    V=np.round(V*1e5)/1e5
    dI =np.gradient(I)
    #dI =I
    x = sorted(np.random.rand(10)*10)
    y = np.random.rand(10)*10

    data = [{'x': a, 'y': b} for a, b in zip(V, I)]
    #data2 = [{'x': a, 'y': b} for a, b in zip(V, dI)]
    return json.dumps({'data': data})

    #return json.dumps({'data': data,'data2': data2})

@app.route('/save_values/<int:row>', methods=['POST'])
def save_values(row):
    print('Adding to csv...', row, request.form.get('Vph'), request.form.get('Vbar'), request.form.get('checker1'), request.form.get('checker2'))

    global identifier
    #prepare ouput, send to python list
    ind=(row-1)*5
    col1=request.form.get('Vph')
    col2=request.form.get('Vbar')
    col3=request.form.get('checker1')
    col4=request.form.get('checker2')

    output_list[ind]=identifier
    output_list[ind+1]=col1
    output_list[ind+2]=col2
    output_list[ind+3]=col3
    output_list[ind+4]=col4
    #output_list is kept up to date even if you go back and forwards in the tool

    #convert output to dataframe, output all of it.
    df_out = pd.DataFrame(output_list)
    df_out.to_csv('output.csv', index=False)

    return 'ok'


if __name__ == "__main__":
    app.run(debug=True)
