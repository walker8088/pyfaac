

from libc.stdint cimport uint8_t, int32_t
from libc.stdlib cimport malloc, free

cpdef enum:
    RAW_STREAM  = 0
    ADTS_STREAM = 1

cpdef enum:
    MPEG4  = 0
    MPEG2  = 1

cpdef enum:
    MAIN = 1
    LOW  = 2
    SSR  = 3
    LTP  = 4

cpdef enum:
    FAAC_INPUT_NULL  = 0 # invalid, signifies a misconfigured config
    FAAC_INPUT_16BIT = 1 # native endian 16bit
    FAAC_INPUT_24BIT = 2 #  native endian 24bit in 24 bits    (not implemented)
    FAAC_INPUT_32BIT = 3 #   native endian 24bit in 32 bits    (DEFAULT)
    FAAC_INPUT_FLOAT = 4 #  32bit floating point
  
cdef extern from "faac.h":
            
          ctypedef struct faacEncConfiguration: 
              int version
              char* name
              char* copyright
              
              unsigned int mpegVersion
              unsigned int aacObjectType

              unsigned int jointmode
              
              unsigned int useLfe
              unsigned int useTns
              unsigned long bitRate
              unsigned int bandWidth
              unsigned long quantqual

              unsigned int outputFormat
              void *psymodellist
              unsigned int psymodelidx
              unsigned int inputFormat

              # block type enforcing (SHORTCTL_NORMAL/SHORTCTL_NOSHORT/SHORTCTL_NOLONG)
              int shortctl
              int channel_map[64]
              int pnslevel
              
          
          ctypedef void *faacEncHandle

          faacEncHandle faacEncOpen(unsigned long sampleRate, unsigned int numChannels, unsigned long *inputSamples, unsigned long *maxOutputBytes)

          int faacEncEncode(faacEncHandle hEncoder, int32_t* inputBuffer, unsigned int samplesInput, uint8_t* outputBuffer, unsigned int bufferSize)

          int faacEncClose(faacEncHandle hEncoder)

          int faacEncSetConfiguration(faacEncHandle hEncoder, faacEncConfiguration* config)
          faacEncConfiguration* faacEncGetCurrentConfiguration(faacEncHandle hEncoder)

cdef class FaacEncoder:
    
    cdef faacEncHandle _c_handle
    cdef uint8_t* _c_outBuffer
    cdef unsigned int inSamples
    cdef unsigned int maxOutBytes

    def __cinit__(self):
        self._c_handle = NULL
        self._c_outBuffer = NULL
        self.inSamples = 0
        self.maxOutBytes = 0
    
    def __init__(self, unsigned long sampleRate, unsigned int numChannels):
        cdef unsigned long inputSamples
        cdef unsigned long maxOut
         
        self._c_handle = faacEncOpen(sampleRate, numChannels, &inputSamples, &maxOut)
         
        self.inSamples = inputSamples
        self.maxOutBytes = maxOut
        
        self._c_outBuffer = <uint8_t *>malloc(maxOut)
        
    def config(self, unsigned int mpegVersion, unsigned int ObjType,  unsigned int inputFormat, unsigned int outputFormat):
        
        conf = faacEncGetCurrentConfiguration(self._c_handle)
        conf.mpegVersion = mpegVersion
        conf.aacObjectType = ObjType
        conf.inputFormat = inputFormat   
        conf.outputFormat = outputFormat 
        #config.allowMidside = 1
        #conf.bitRate = 0

        return faacEncSetConfiguration(self._c_handle, conf)
          
    def getSamples(self): 
         return self.inSamples

    def close(self):
         faacEncClose(self._c_handle)
         if self._c_outBuffer:
              free(self._c_outBuffer)
              self._c_outBuffer = NULL

    def encode(self, bytes buff, unsigned int samples):
          
          cdef int out_len
          cdef unsigned int  bufferSize = self.maxOutBytes
          cdef uint8_t *outputBuffer = self._c_outBuffer
          cdef bytes out

          out_len  = faacEncEncode(self._c_handle, <int32_t*><uint8_t*>buff, samples, outputBuffer, bufferSize)
          out = outputBuffer[:out_len]
          
          return out
