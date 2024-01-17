from flask import Flask, request, redirect
from flask_restful import Resource, Api
from flask_cors import CORS
import os
import prediction
from joblib import load, dump
from imblearn.combine import SMOTEENN
import numpy as np
import pandas as pd
from sklearn.experimental import enable_iterative_imputer
from sklearn.impute import IterativeImputer
from sklearn.metrics import confusion_matrix
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler

def department_encode(data_name):
  encode_cats = pd.get_dummies(data_name['department'], prefix='department')
  new_data = data_name.drop({'department'}, axis=1)
  encoded_data = new_data.join(encode_cats)
  return encoded_data

def predictor_outcome_split(data_name):
  predictors = data_name.drop('separatedNY', axis=1)
  outcome = data_name['separatedNY']
  return predictors, outcome

def impute_function(predictors_df):
  imp_mean = IterativeImputer(random_state=1001)
  imputed_data = imp_mean.fit_transform(predictors_df)
  return imputed_data

def smote_balance_function(imputed_data_name, outcome_name):
  smote_enn = SMOTEENN(random_state=1001)
  balanced_data, balanced_outcome = smote_enn.fit_resample(
    imputed_data_name, outcome_name
    )
  return balanced_data, balanced_outcome

app = Flask(__name__)
cors = CORS(app, resources={r"*": {"origins": "*"}})
api = Api(app)

class Test(Resource):
    def get(self):
        return 'Here is phase 1 of production!'

    def post(self):
        try:
            value = request.get_json()
            if(value):
                return {'Post Values': value}, 201

            return {"error":"Invalid format."}

        except Exception as error:
            return {'error': error}

class GetPredictionOutput(Resource):
    def get(self):
        return {"error":"Invalid Method."}

    def post(self):
        try:
            data = request.get_json()
            predictors, outcome = data.pipe(department_encode).pipe(predictor_outcome_split)
            imputed_predictors = impute_function(predictors)
            balanced_data, balanced_outcome = smote_balance_function(imputed_predictors, outcome)
            X_test_scaler = StandardScaler().fit(balanced_data)
            X_test_scaled = X_test_scaler.transform(balanced_data)

            predict = prediction.predict_turnover(X_test_scaled)
            predictOutput = predict
            return {'predict':predictOutput}

        except Exception as error:
            return {'error': error}

api.add_resource(Test,'/')
api.add_resource(GetPredictionOutput,'/getPredictionOutput')

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5001))
    app.run(host='0.0.0.0', port=port)
