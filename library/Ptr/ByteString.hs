module Ptr.ByteString
where

import Ptr.Prelude
import qualified Ptr.Poking as A
import qualified Ptr.Take as C
import qualified Ptr.Peek as D
import qualified Data.ByteString.Internal as B


{-# INLINE poking #-}
poking :: A.Poking -> B.ByteString
poking (A.Poking size population) =
  B.unsafeCreate size population

{-# INLINE take #-}
take :: C.Take result -> B.ByteString -> Maybe result
take (C.Take (StateT maybeT)) (B.PS fp offset length) =
  unsafePerformIO $
  withForeignPtr fp $ \ptr ->
  case maybeT (length, plusPtr ptr offset) of
    MaybeT maybeIO -> do
      maybe <- maybeIO
      case maybe of
        Just (!result, _) -> return (Just result)
        Nothing -> return Nothing

{-# INLINE peek #-}
peek :: D.Peek result -> B.ByteString -> Maybe result
peek (D.Peek amount io) (B.PS fp offset length) =
  if amount <= length
    then Just $ unsafePerformIO $ withForeignPtr fp $ \ptr ->
      io (plusPtr ptr offset)
    else Nothing