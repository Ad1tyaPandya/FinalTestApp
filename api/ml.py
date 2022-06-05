import numpy as np
import tensorflow as tf
import pandas as pd
from tqdm import tqdm
import librosa
from pydub import AudioSegment
from os.path import splitext
from ffmpy import FFmpeg
import sys
import os
# from aubio import source,pitch
import scipy.io.wavfile
from keras.models import load_model
# from tensorflow.keras.models import Sequential
# from tensorflow.keras.layers import Dense, LSTM, Dropout,Activation
# from tensorflow.keras.callbacks import ModelCheckpoint, TensorBoard, EarlyStopping
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
def run_model():
    
    model = load_model(r"C:\Users\adity.DESKTOP-DIU3TF0\api\male_vs_female_ml\saved_models\audio_classification.hdf5")
    le = LabelEncoder()
    filename = r"C:\Users\adity.DESKTOP-DIU3TF0\api\file2.wav"
    audio,sample_rate = librosa.load(filename,res_type='kaiser_fast')
    mfccs_features=librosa.feature.mfcc(y=audio,sr=sample_rate,n_mfcc=40)
    mfccs_scaled_features = np.mean(mfccs_features.T,axis=0)
    mfccs_scaled_features = mfccs_scaled_features.reshape(1,-1)
    x_predict=model.predict(mfccs_scaled_features)
    predicted_label = np.argmax(x_predict,axis=1)
    print(predicted_label)
    # prediction_class = le.inverse_transform(predicted_label)
    # print(prediction_class)
    if predicted_label == [1]:
        return 'male'
    else:
        return 'female'
def call(bytes:bytearray):
    print("entered call")
    with open("file2.wav", mode='wb') as f:
       f.write(bytes)
    return run_model()
    # return 'hi'
# print(run_model())
# run_model()