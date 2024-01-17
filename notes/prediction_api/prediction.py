import pickle
import pandas as pd
import json

def predict_turnover(config):
    ##loading the model from the saved file
    xgb_model = load('xgboost_model.joblib')
    if type(config) == dict:
        df = pd.DataFrame(config)
    else:
        df = config
    
    y_pred = xgb_model.predict(df)
    
    if y_pred == 0:
        return 'Will not quit'
    elif y_pred == 1:
        return 'Will quit'
