{-# LANGUAGE CPP #-}

-- |
-- Copyright   : (c) 2010 Simon Meier
--
--               Original serialization code from 'Data.Binary.Builder':
--               (c) Lennart Kolmodin, Ross Patterson
--
-- License     : BSD3-style
--
-- Utilty module defining unchecked shifts.
--
-- These functions are undefined when the amount being shifted by is
-- greater than the size in bits of a machine Int#.-
module Ptr.UncheckedShifting
  ( shiftr_w16,
    shiftr_w32,
    shiftr_w64,
    shiftr_w,
    caseWordSize_32_64,
  )
where

#if !defined(__HADDOCK__)
import GHC.Base
import GHC.Word (Word32(..),Word16(..),Word64(..))

#if WORD_SIZE_IN_BITS < 64 && __GLASGOW_HASKELL__ >= 608
import GHC.Word (uncheckedShiftRL64#)
#endif
#else
import Data.Word
#endif

import Foreign
import Prelude

------------------------------------------------------------------------
-- Unchecked shifts

-- | Right-shift of a 'Word16'.
{-# INLINE shiftr_w16 #-}
shiftr_w16 :: Word16 -> Int -> Word16

-- | Right-shift of a 'Word32'.
{-# INLINE shiftr_w32 #-}
shiftr_w32 :: Word32 -> Int -> Word32

-- | Right-shift of a 'Word64'.
{-# INLINE shiftr_w64 #-}
shiftr_w64 :: Word64 -> Int -> Word64

-- | Right-shift of a 'Word'.
{-# INLINE shiftr_w #-}
shiftr_w :: Word -> Int -> Word
#if WORD_SIZE_IN_BITS < 64
shiftr_w w s = fromIntegral $ (`shiftr_w32` s) $ fromIntegral w
#else
shiftr_w w s = fromIntegral $ (`shiftr_w64` s) $ fromIntegral w
#endif

#if !defined(__HADDOCK__)
#if MIN_VERSION_base(4,16,0)
shiftr_w16 (W16# w) (I# i) = W16# (w `uncheckedShiftRLWord16#` i)
shiftr_w32 (W32# w) (I# i) = W32# (w `uncheckedShiftRLWord32#` i)
#else
shiftr_w16 (W16# w) (I# i) = W16# (w `uncheckedShiftRL#` i)
shiftr_w32 (W32# w) (I# i) = W32# (w `uncheckedShiftRL#` i)
#endif

#if WORD_SIZE_IN_BITS < 64
shiftr_w64 (W64# w) (I# i) = W64# (w `uncheckedShiftRL64#` i)
#else
shiftr_w64 (W64# w) (I# i) = W64# (w `uncheckedShiftRL#` i)
#endif

#else
shiftr_w16 = shiftR
shiftr_w32 = shiftR
shiftr_w64 = shiftR
#endif

-- | Select an implementation depending on the bit-size of 'Word's.
-- Currently, it produces a runtime failure if the bitsize is different.
-- This is detected by the testsuite.
{-# INLINE caseWordSize_32_64 #-}
caseWordSize_32_64 ::
  -- | Value to use for 32-bit 'Word's
  a ->
  -- | Value to use for 64-bit 'Word's
  a ->
  a
#if MIN_VERSION_base(4,7,0)
caseWordSize_32_64 f32 f64 =
  case finiteBitSize (undefined :: Word) of
    32 -> f32
    64 -> f64
    s  -> error $ "caseWordSize_32_64: unsupported Word bit-size " ++ show s
#else
caseWordSize_32_64 f32 f64 =
  case bitSize (undefined :: Word) of
    32 -> f32
    64 -> f64
    s  -> error $ "caseWordSize_32_64: unsupported Word bit-size " ++ show s
#endif
