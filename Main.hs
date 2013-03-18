import Foreign.IloModel
import Foreign.Cplex

import Foreign.C.Types
import Foreign.Ptr
import Foreign.Marshal.Array

import Control.Monad.Cplex
import Data.Var
import Data.CplexTypes
{-
foreign import ccall "CWrappers/wrappers.h build" c_build :: Ptr CDouble -> CDouble
foreign import ccall "CWrappers/wrappers.h lpInitSolver" lpInitSolver :: IO (Ptr ())
foreign import ccall "CWrappers/wrappers.h lpNewModel" lpNewModel :: Ptr () -> CInt -> CInt -> Ptr (Ptr CDouble) -> Ptr (Ptr CDouble) -> Ptr CDouble -> IO (Ptr ())
foreign import ccall "CWrappers/wrappers.h solveLP" solveLP :: Ptr () -> IO (Ptr CDouble)
-}
build2c = testlp >> do
  (obj,bou,ct,p) <- buildLP
  
  return (obj,bou,ct,p)
{-
main' = do
  x <- newArray $ map realToFrac [1,2,3]
  putStrLn $ "[hs]:" ++ show x
  putStrLn $ show $ c_build x
  
  env <- lpInitSolver
  ((obj,bou,ct,p),_) <- runVSupplyT $ runLPT $ build2c
  m <- lpNewModel env 3 (fromIntegral p) bou ct obj
  ans <- solveLP m
  ans' <- peekArray 3 ans
  putStrLn $ show ans'
  
  putStrLn "2nd Model :"-}
main= do  
  (ans,_) <- runVSupplyT $ runLPT $ testks >> quickSolveLP
  putStrLn $ show ans
