module Main where

import Bindings (rs_add2)

main :: IO ()
main = print (rs_add2 14 28)
