module PtrMagic.Receiver
where

import PtrMagic.Prelude
import qualified PtrMagic.Receiver.Core as A
import qualified PtrMagic.Decoder as B


{-|
A wrapper of a receiving action, which extends it with bufferization.
-}
data Receiver =
  {-|
  * Exception-free action to receive another chunk of bytes. E.g., an exception-free wrapper of 'Network.Socket.recvBuf'
  * Buffer
  * Size of the buffer
  * Chunk size
  -}
  Receiver !(Ptr Word8 -> Int -> IO (Either Text Int)) !(ForeignPtr Word8) !(IORef (Int, Int)) !Int

{-|
Receive as many bytes as is required by the provided decoder and decode immediately.

If all you need is just to get a 'ByteString' chunk then use the 'B.bytes' decoder.
-}
decode :: Receiver -> B.Decoder decoded -> IO (Either Text decoded)
decode (Receiver fetch bufferFP bufferStateRef chunkSize) (B.Decoder amount action) =
  A.decode fetch bufferFP bufferStateRef chunkSize amount action
  
getBufferFilling :: Receiver -> IO Int
getBufferFilling (Receiver _ _ bufferStateRef _) = fmap (\(offset, end) -> end - offset) (readIORef bufferStateRef)