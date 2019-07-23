
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

codec.close()

input.close()
output.close()
