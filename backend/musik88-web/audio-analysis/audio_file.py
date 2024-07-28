import librosa

class AudioFile:

  def __init__(self, path, decimal_places=8):
    self.path = path
    self.decimal_places = decimal_places

  def duration(self):
    duration = self.__get_duration()
    return round(duration, self.decimal_places)

  def duration_pretty(self):
    duration = self.__get_duration()
    m, s = divmod(duration, 60)
    return str(round(m, self.decimal_places)) + ':' + str(round(s, self.decimal_places))
  
  def samplerate(self):
    y, sr = librosa.load(self.path)
    return sr
  
  def onset_detect(self):
    y, sr = librosa.load(self.path)
    onsets = librosa.onset.onset_detect(y=y, sr=sr, units='time')
    return onsets

  # Private methods
  def __get_duration(self):
    y, sr = librosa.load(self.path)
    duration = librosa.get_duration(y=y, sr=sr)
    return duration