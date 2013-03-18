module Foreign.Cplex where

import Foreign.IloModel
import Foreign.C.Types
import Foreign.Marshal.Array
import Foreign.Ptr
import Data.CplexTypes
import Data.Var

import Control.Monad.State
import Foreign.Storable

foreign import ccall "CWrappers/wrappers.h build" 
  c_build :: Ptr CDouble -> CDouble
foreign import ccall "CWrappers/wrappers.h lpInitSolver" 
  lpInitSolver :: IO (Ptr ())
foreign import ccall "CWrappers/wrappers.h lpNewModel" 
  lpNewModel :: Ptr () -> CInt -> CInt -> Ptr (Ptr CDouble) -> Ptr (Ptr CDouble) -> Ptr CDouble -> IO (Ptr ())
foreign import ccall "CWrappers/wrappers.h solveLP" 
  solveLP :: Ptr () -> IO (Ptr CDouble)
             
quickSolveLP :: (Num b, Storable b, RealFrac b) =>
                LPT Var b (VSupplyT IO) [b]
quickSolveLP = do
  n <- gets $ getNbVars
  lift $ liftIO $ putStrLn $ "Loading " ++ show n ++ " vars." 
  env <- lift $ liftIO lpInitSolver
  (obj,boun,ctr,p) <- buildLP 
  m <- lift $ liftIO $ lpNewModel env (fromIntegral n) (fromIntegral p) boun ctr obj
  ans <- lift $ liftIO $ solveLP m
  ret <-  lift $ liftIO $ peekArray (fromIntegral n) ans
  return $ map realToFrac ret