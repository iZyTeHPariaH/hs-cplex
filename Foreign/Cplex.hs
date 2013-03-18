module Foreign.Cplex where

import Foreign.IloModel
import Foreign.C.Types
import Foreign.Marshal.Alloc
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
  lpNewModel :: Ptr () -> 
                CInt -> CInt -> CInt ->
                CInt ->
                Ptr (Ptr CDouble) -> 
                Ptr (Ptr (Ptr CDouble)) -> Ptr (Ptr CDouble) -> IO (Ptr ())
foreign import ccall "CWrappers/wrappers.h solveLP" 
  solveLP :: Ptr () -> IO (Ptr (Ptr CDouble))
   
foreign import ccall "CWrappers/wrappers.h lpRemoveModel"
  lpRemoveModel :: Ptr() -> IO (Ptr ())

quickSolveLP :: (Num b, Storable b, RealFrac b) =>
                LPT Var b (VSupplyT IO) [b]
{-
quickSolveLP = do
  n <- gets $ getNbVars
  lift $ liftIO $ putStrLn $ "Loading " ++ show n ++ " vars." 
  env <- lift $ liftIO lpInitSolver
  (obj,boun,ctr,p) <- buildLP 
  m <- lift $ liftIO $ lpNewModel env (fromIntegral n) (fromIntegral p) boun ctr obj
  ans <- lift $ liftIO $ solveLP m
  ret <-  lift $ liftIO $ peekArray (fromIntegral n) ans
  return $ map realToFrac ret
-}  
quickSolveLP = do
  (objpt,
   (boun,cpt),
   (n,b,i,p)) <- buildLP'
  lift $ liftIO $ do
    env <- lpInitSolver
    m <- lpNewModel env (fromIntegral n) (fromIntegral b) (fromIntegral i) (fromIntegral p) boun cpt objpt
    ans <- solveLP m
    [nvals,bvals,ivals] <- peekArray 3 ans
    nans <- peekArray  n nvals
    bans <- peekArray b bvals
    ians <- peekArray i ivals
    clean objpt boun cpt n b i p
    lpRemoveModel m
    return $ map realToFrac $ if n > 0 then nans else [] ++ 
                              if b > 0 then bans else [] ++
                              if i > 0 then ians else []
                                                      
                                                      
clean objpt boun cpt n b i p = do
  bounds <- peekArray p boun
  ctrs <- peekArray p cpt
  
  clean' objpt
  foldM (\_ e -> free e) () bounds
  foldM (\_ e -> clean' e) () ctrs
  free cpt
  
  where clean' pt = do
          [npt,bpt,ipt] <- peekArray 3 pt
          if n > 0 then free npt else return ()
          if b > 0 then free bpt else return ()
          if i > 0 then free ipt else return ()
          free pt