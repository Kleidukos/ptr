module PtrMagic.Encoder
where

import PtrMagic.Prelude
import qualified PtrMagic.IO as A
import qualified PtrMagic.Codec as B


data Encoder input =
  Encoder !Int !(Ptr Word8 -> input -> IO ())

instance Contravariant Encoder where
  {-# INLINE contramap #-}
  contramap fn (Encoder size io) =
    Encoder size (\ptr input -> io ptr (fn input))

instance Divisible Encoder where
  {-# INLINE conquer #-}
  conquer =
    Encoder 0 (\_ _ -> pure ())
  {-# INLINE divide #-}
  divide fn (Encoder size1 io1) (Encoder size2 io2) =
    Encoder (size1 + size2) (\ptr input -> case fn input of (input1, input2) -> io1 ptr input1 *> io2 (plusPtr ptr size1) input2)


{-# INLINE word8 #-}
word8 :: Encoder Word8
word8 =
  Encoder 1 A.pokeWord8

{-# INLINE beWord32 #-}
beWord32 :: Encoder Word32
beWord32 =
  Encoder 4 A.pokeBEWord32

{-# INLINE beWord64 #-}
beWord64 :: Encoder Word64
beWord64 =
  Encoder 8 A.pokeBEWord64

{-# INLINE bytes #-}
bytes :: Int -> Encoder ByteString
bytes amount =
  Encoder amount (\ptr -> A.pokeBytesTrimming ptr amount)

{-# INLINE codec #-}
codec :: B.Codec input output -> Encoder input
codec (B.Codec size io _) =
  Encoder size io