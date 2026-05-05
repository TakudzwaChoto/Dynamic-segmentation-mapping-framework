#!/usr/bin/env python3
"""
Predictive Segmentation using Random Forest
Trains ML model to predict which water quality records will be queried
"""

import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, roc_auc_score, confusion_matrix
import joblib
import json
import os
import random

class PredictiveSegmentation:
    """ML-based predictive segmentation for smart contract data retention"""
    
    def __init__(self):
        self.model = RandomForestClassifier(
            n_estimators=100,
            max_depth=10,
            min_samples_split=5,
            min_samples_leaf=2,
            max_features='sqrt',
            bootstrap=True,
            random_state=42,
            n_jobs=-1
        )
        self.scaler = StandardScaler()
        self.feature_names = [
            'hour_of_day', 'day_of_week', 'days_since_recorded',
            'ph_level', 'turbidity', 'dissolved_oxygen', 'temperature',
            'user_query_frequency', 'contaminant_flag', 'historical_access_count'
        ]
    
    def generate_training_data(self, num_samples: int = 20000) -> pd.DataFrame:
        """Generate synthetic training data"""
        np.random.seed(42)
        data = []
        
        for _ in range(num_samples):
            hour = np.random.randint(0, 24)
            day_of_week = np.random.randint(0, 7)
            days_since = np.random.exponential(scale=7)
            ph = np.clip(np.random.normal(7.5, 1.0), 0, 14)
            turbidity = np.clip(np.random.exponential(scale=50), 0, 5000)
            dissolved_oxygen = np.clip(np.random.normal(8, 2), 0, 20)
            temperature = np.clip(np.random.normal(20, 10), 0, 50)
            contaminant = np.random.choice([0, 1], p=[0.95, 0.05])
            query_freq = np.random.exponential(scale=0.5)
            historical_access = np.random.poisson(lam=3)
            
            will_be_queried = 0
            if days_since < 7: will_be_queried += 0.3
            if contaminant == 1: will_be_queried += 0.35
            if query_freq > 1: will_be_queried += 0.3
            if historical_access > 5: will_be_queried += 0.2
            if ph < 6.5 or ph > 8.5: will_be_queried += 0.15
            if turbidity > 100: will_be_queried += 0.1
            if 9 <= hour <= 17 and day_of_week <= 4: will_be_queried += 0.1
            
            will_be_queried += np.random.normal(0, 0.1)
            label = 1 if will_be_queried > 0.5 else 0
            
            data.append({
                'hour_of_day': hour, 'day_of_week': day_of_week,
                'days_since_recorded': days_since, 'ph_level': ph,
                'turbidity': turbidity, 'dissolved_oxygen': dissolved_oxygen,
                'temperature': temperature, 'user_query_frequency': query_freq,
                'contaminant_flag': contaminant, 'historical_access_count': historical_access,
                'will_be_queried': label
            })
        
        return pd.DataFrame(data)
    
    def train(self, df: pd.DataFrame = None):
        """Train the predictive model"""
        print("=" * 60)
        print("Training Predictive Segmentation Model (Random Forest)")
        print("=" * 60)
        
        if df is None:
            df = self.generate_training_data(20000)
        
        X = df[self.feature_names]
        y = df['will_be_queried']
        
        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
        X_train_scaled = self.scaler.fit_transform(X_train)
        X_test_scaled = self.scaler.transform(X_test)
        
        self.model.fit(X_train_scaled, y_train)
        y_pred = self.model.predict(X_test_scaled)
        y_proba = self.model.predict_proba(X_test_scaled)[:, 1]
        
        metrics = {
            'accuracy': accuracy_score(y_test, y_pred),
            'precision': precision_score(y_test, y_pred),
            'recall': recall_score(y_test, y_pred),
            'f1_score': f1_score(y_test, y_pred),
            'auc_roc': roc_auc_score(y_test, y_proba)
        }
        
        print(f"\nAccuracy: {metrics['accuracy']:.3f} (89.7% target)")
        print(f"Precision: {metrics['precision']:.3f}")
        print(f"Recall: {metrics['recall']:.3f}")
        print(f"F1 Score: {metrics['f1_score']:.3f}")
        print(f"AUC-ROC: {metrics['auc_roc']:.3f}")
        
        cm = confusion_matrix(y_test, y_pred)
        print(f"Confusion Matrix - TP:{cm[1][1]} FP:{cm[0][1]} FN:{cm[1][0]} TN:{cm[0][0]}")
        
        importances = dict(zip(self.feature_names, self.model.feature_importances_))
        print("\nFeature Importance:")
        for name, imp in sorted(importances.items(), key=lambda x: -x[1]):
            print(f"  {name}: {imp:.3f}")
        
        return metrics
    
    def save_model(self, path: str = 'models/random_forest_model.pkl'):
        os.makedirs(os.path.dirname(path), exist_ok=True)
        joblib.dump({'model': self.model, 'scaler': self.scaler, 'feature_names': self.feature_names}, path)
        print(f"\nModel saved to {path}")

if __name__ == "__main__":
    ps = PredictiveSegmentation()
    ps.train()
    ps.save_model()
    print("\n✅ Predictive segmentation model training complete!")
