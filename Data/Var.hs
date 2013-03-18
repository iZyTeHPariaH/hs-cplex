module Data.Var where

import Data.CplexTypes
import Data.Map.Lazy


import Control.Applicative
import Control.Monad.State
import Control.Monad.Identity

type Var = Int
type VSupplyT m  = StateT [Var] m 
type VSupply = VSupplyT Identity 

-- Génère un nouvel identifiant unique (pour manipuler des variables ou des contraintes)
supplyNewId :: (MonadTrans t, Monad m) => t (VSupplyT m) Var
supplyNewId = lift $ do 
  x <- gets head
  modify tail
  return x
 

supplyNew :: (Monad m) => LPT Var b (VSupplyT m) Var
supplyNew = do
  id <- supplyNewId
  modify $ \lp ->lp{getNbVars=getNbVars lp + 1,
                    getVarsKind= insert id NumVar (getVarsKind lp)}
  return id
  
supplyN n = do
     ids <- foldM (\a _ -> supplyNew >>= \x -> return (x:a)) [] [1..n]
     return $ reverse ids
runVSupplyT :: (Monad m) => VSupplyT m r -> m r
runVSupplyT v = do
     x <- runStateT v [1..]
     return $ fst x