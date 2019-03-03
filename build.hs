#!/usr/bin/env cabal
{-cabal:
build-depends: base ^>= 4.12
             , shake ^>= 0.17
             , shake-cabal ^>= 0.2
-}
{-# LANGUAGE ViewPatterns #-}
module Main where

import Data.Char
import Data.List
import System.Directory (makeAbsolute)

import Development.Shake
import Development.Shake.Cabal
import Development.Shake.Command
import Development.Shake.FilePath
import Development.Shake.Util
import System.Info.Extra

buildDir :: FilePath
buildDir = "_build"

haskellPackage = "call-rust-from-haskell"
haskellExe = "call-rust-from-haskell"

rustLib = "hsffitest"

lib :: FilePath -> FilePath
lib (splitFileName -> (dir, fname))
  | isWindows = dir </>          fname <.> "dll"
  | isMac     = dir </>          fname <.> "dylib"
  | otherwise = dir </> "lib" <> fname <.> "so"

trim :: String -> String
trim = dropWhileEnd isSpace . dropWhile isSpace

main :: IO ()
main = shakeArgs shakeOptions{shakeFiles=buildDir} $ do
  let exePath = buildDir </> haskellExe <.> exe
      libPath = buildDir </> lib rustLib
  want [exePath, libPath]

  phony "clean" $ do
    putNormal $ "cleaning files in" <> buildDir
    removeFilesAfter buildDir ["//*"]
  
  phony "run" $ do
    need [exePath, libPath]
    putNormal $ "running " <> exePath
    cmd_ exePath

  buildDir </> haskellExe <.> exe %> \out -> do
    let cabalfiles = [haskellPackage <.> ".cabal", "cabal.project", "cabal.project.local"]
    need cabalfiles
    (_, hsDeps) <- liftIO (getCabalDeps $ haskellPackage <.> ".cabal")
    need hsDeps
    need [libPath]
    cmd_ "cabal v2-build" ["exe:" <> haskellExe]
    Stdout (trim -> exeLoc) <- cmd "cabal v2-exec -- where" [haskellExe]
    cmd_ "cp" [exeLoc, out]
  
  "target/debug//*" %> \_ -> do
    need ["Cargo.toml"]
    need =<< getDirectoryFiles "" ["rust/*.rs"]
    cmd_ "cargo build"
  
  "target/release//*" %> \_ -> do
    need ["Cargo.toml"]
    need =<< getDirectoryFiles "" ["rust/*.rs"]

  buildDir </> lib rustLib %> \out -> do
    copyFile' ("target/debug" </> lib rustLib) out
  
  "cabal.project.local" %> \out -> do
    extraLibDir <- liftIO $ makeAbsolute buildDir
    let config = unlines
          [ "package " <> haskellPackage
          , "  extra-lib-dirs: " <> extraLibDir
          ]
    writeFileChanged out config