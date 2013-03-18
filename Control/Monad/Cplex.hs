module Control.Monad.Cplex where

import Control.Monad.State
import Data.LinCombination
import Data.CplexTypes
import Data.Var
import Data.Map.Lazy hiding (foldl)
import Foreign.C.Types

setVarKind :: (Monad m, Ord a) => a -> VarKind -> LPT a b m ()
setVarKind var kind = modify (\lp -> lp{getVarsKind=insert var kind $ getVarsKind lp})

addCtr :: (Monad m) => IloConstraint Var b -> LPT Var b (VSupplyT m) Var
addCtr ctr = do
  id <-  supplyNewId
  modify $ \lp -> lp{getConstraints = insert id ctr $ getConstraints lp}
  return id

setObjective :: (Monad m) => LinCombination a b -> LPT a b m ()
setObjective l = modify $ \lp -> lp{getObjective=l}


testlp :: LPT Var CDouble (VSupplyT IO) ()
testlp = do
  [x1,x2,x3] <- supplyN 3
  setObjective $ 5.*x1 .+ 4.*x2 .+ 3 .* x3
  addCtr $ IloRange (BoundVal 0) (2.* x1 .+ 3.* x2 .+ 1 .* x3) (BoundVal 5)
  addCtr $ IloRange (BoundVal 0) (4.* x1 .+ 1.* x2 .+ 2 .* x3) (BoundVal 11)
  addCtr $ IloRange (BoundVal 0) (3 .* x1 .+ 4.* x2 .+ 2 .* x3) (BoundVal 8)
  return ()

testlp2 :: LPT Var CDouble (VSupplyT IO) ()
testlp2= do
  [x1,x2] <- supplyN 2
  setObjective $ 1.*x1 .+ 1.* x2
  addCtr $ IloRange (BoundVal 0) (2.* x1 .+ 1.* x2) (BoundVal 14)
  addCtr $ IloRange (BoundVal 0) ((-1).* x1 .+ 2 .* x2) (BoundVal 8)
  addCtr $ IloRange (BoundVal 0) (2 .* x1 .+ (-1).* x2) (BoundVal 10)
  return ()

testks :: LPT Var Double (VSupplyT IO) ()
testks = do
  vars <- supplyN 4
  setObjective $ foldl (.+) (LinCombination []) $ zipWith (.*) [7,4,3,3] vars
  let ctr = foldl (.+) (LinCombination []) $ zipWith (.*) [13,12,8,10] vars
  addCtr $ IloRange (BoundVal 0) ctr (BoundVal 30)
  foldM (\_ e -> setVarKind e BinVar) () vars