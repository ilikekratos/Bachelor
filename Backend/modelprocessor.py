from flask import Flask, request
import librosa
import numpy as np
from python_speech_features import mfcc
import torch
import torch.nn as nn
import pytorch_lightning as pl
from torchmetrics.functional import accuracy
import torch.optim as optim
sample_rate=16000
class AccidentModel(nn.Module):
    def __init__(self, n_features, n_classes, n_hidden = 198, n_layers = 2):
        super().__init__()
        self.n_hidden = n_hidden
        self.lstm = nn.LSTM(
            input_size = n_features,
            hidden_size = n_hidden,
            num_layers = n_layers,
            batch_first = True,
            dropout = 0.2
        
        )
        self.classifier = nn.Linear(n_hidden, n_classes)
    def forward(self, x):
        self.lstm.flatten_parameters()
        _, (hidden, _) = self.lstm(x)
        out = hidden[-1]
        return self.classifier(out)
class AccidentPredictor(pl.LightningModule):
    def __init__(self, n_features:int, n_classes:int):
        super().__init__()
        self.model = AccidentModel(n_features, n_classes)
        self.criterion = nn.CrossEntropyLoss()
        self.save_hyperparameters()
    def forward(self, x, labels = None):
        #x = torch.stack(x).to(device)
        output = self.model(x)
        loss = 0
        if labels is not None:
            loss = self.criterion(output, labels.long())
        return loss, output
    def training_step(self, batch, batch_idx):
        self.model.train()
        features = batch["features"]
        labels = batch["label"]
        loss, outputs = self(features, labels)
        predictions = torch.argmax(outputs, dim = 1)
        step_accuracy = accuracy(predictions, labels,task='binary')
        self.log("train_loss", loss, prog_bar = True, logger = True)
        self.log("train_accuracy", step_accuracy, prog_bar = True, logger = True)
        return {"loss": loss, "accuracy": step_accuracy}
    
    def validation_step(self, batch, batch_idx):
        self.model.eval()
        features = batch["features"]
        labels = batch["label"]
        loss, outputs = self(features, labels)
        predictions = torch.argmax(outputs, dim = 1)
        step_accuracy = accuracy(predictions, labels,task='binary')
        self.log("val_loss", loss, prog_bar = True, logger = True)
        self.log("val_accuracy", step_accuracy, prog_bar = True, logger = True)
        return {"loss": loss, "accuracy": step_accuracy}
    
    def test_step(self, batch, batch_idx):
        self.model.eval()
        features = batch["features"]
        labels = batch["label"]
        loss, outputs = self(features, labels)
        predictions = torch.argmax(outputs, dim = 1)
        step_accuracy = accuracy(predictions, labels,task='binary')
        self.log("test_loss", loss, prog_bar = True, logger = True)
        self.log("test_accuracy", step_accuracy, prog_bar = True, logger = True)
        return {"loss": loss, "accuracy": step_accuracy}
    
    def predict_step(self, batch, batch_idx):
        self.model.eval()
        features = batch["features"]
        outputs = self.model(features)
        predictions = torch.argmax(outputs, dim=1)
        return predictions
    def configure_optimizers(self):
        return optim.Adam(self.parameters(), lr = 0.000006)
def spectrogram(samples, sample_rate, stride_ms = 10.0, window_ms = 25.0, max_freq = sample_rate, eps = 1e-14):
    stride_size = int(0.001 * sample_rate * stride_ms)
    window_size = int(0.001 * sample_rate * window_ms)
    # Extract strided windows
    truncate_size = (len(samples) - window_size) % stride_size
    samples = samples[:len(samples) - truncate_size]
    nshape = (window_size, (len(samples) - window_size) // stride_size + 1)
    nstrides = (samples.strides[0], samples.strides[0] * stride_size)
    windows = np.lib.stride_tricks.as_strided(samples, shape = nshape, strides = nstrides)
    assert np.all(windows[:, 1] == samples[stride_size:(stride_size + window_size)])
    # Window weighting, squared Fast Fourier Transform (fft), scaling
    weighting = np.hanning(window_size)[:, None]
    
    fft = np.fft.rfft(windows * weighting, axis=0)
    fft = np.absolute(fft)
    fft = fft**2
    
    scale = np.sum(weighting**2) * sample_rate
    fft[1:-1, :] *= (2.0 / scale)
    fft[(0, -1), :] /= scale
    
    # Prepare fft frequency list
    freqs = float(sample_rate) / window_size * np.arange(fft.shape[0])
    # Compute spectrogram feature
    ind = np.where(freqs <= max_freq)[0][-1]+1
    specgram = np.log(fft[:ind, :] + eps)
    return specgram




app = Flask(__name__)

@app.route('/', methods=['POST'])
def upload_file():
    file = request.files['file']
    username = request.form['username'] 
    filename = f"{username}_{file.filename}"
    file.save(filename)
    audio, sample_rate = librosa.load(filename, sr=16000)
    fft = spectrogram(audio,16000).transpose()[0:198]
    mel = mfcc(audio, 16000, nfft=400)[0:198]
    return {'prediction': int(0)}

if __name__ == '__main__':
    app.run(debug=True)
