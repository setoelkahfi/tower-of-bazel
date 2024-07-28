#!/usr/bin/env python3

import sys
from audio_file import AudioFile

filepath = sys.argv[1]
audiofile = AudioFile(filepath, 3)
print(str(audiofile.onset_detect()))