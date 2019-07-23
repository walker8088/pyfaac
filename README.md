# pyfaac

A easy python module taking raw PCM audio to ADTS AAC using libfaac.

## Install

You need installed packages:

- `libfaac-dev`
- `python-dev`

and c compiler.


Build:

`python setup.py install`


## Using

```python
import pyfaac

samplerate = 8000
channels = 1

input = open('audio.pcm', 'rb')
output = open('out.aac', 'wb')

codec = pyfaac.FaacEncoder(samplerate, channels)

codec.config(pyfaac.MPEG4, pyfaac.LOW, pyfaac.FAAC_INPUT_16BIT, pyfaac.ADTS_STREAM)

samples = codec.getSamples()

while True:
    data = input.read(samples*2)
    if data:
        stream = codec.encode(data, samples)
        if len(stream) > 0:
        	 output.write(stream)
    else:
        break

while True:
    stream = codec.encode(b'', 0)
    print(len(stream))
    if len(stream) > 0:
        output.write(stream)
    else:
        break


```

## Interface

```
codec = pyfaac.pyfaac(samplerate, channels, bitrate)
```

- `samplerate` — source PCM sample rate. 
- `channels` — source PCM channels. 1 — mono, 2 — stereo;
- `bitrate` — output AAC bitrate.

```
codec.getSamples()
```

Returns the maximum samples to be transmitted to the encoder.

```
aac = codec.encode(data, samples)
```

Encode raw PCM data to AAC. 

```
aac = codec.close()
```

Close encoder.
