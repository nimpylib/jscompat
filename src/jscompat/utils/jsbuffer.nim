## NodeJs's Buffer
##
## As TypedArray is preferred, I'm tired to wrap each APIs of this.

import ../private/ffiGen
import ./[
  jsarraybuffer, jstypedarrays,
]
export jstypedarrays

type
  Buffer* = ref object of TypedArray[uint8, ArrayBuffer]  ## \
    ## NodeJs says:
    ## `The Buffer class is a subclass of JavaScript's <Uint8Array> class`
    ##
    # And due to doc of `.buffer` is said to return `ArrayBuffer`,
    #  so it shall be subclass of `Uint8Array<ArrayBuffer>`
    poolSize*: cint

genXIsX Buffer

