{-# LANGUAGE ForeignFunctionInterface #-}
module Bindings (rs_add2) where

import Foreign

foreign import ccall "add2"
  rs_add2 :: Word32 -> Word32 -> Word32
