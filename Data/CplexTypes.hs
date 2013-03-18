module Data.CplexTypes where

import Data.LinCombination

import Control.Monad.State
import Data.Map.Lazy




data Sense = Maximize | Minimize
data VarKind = BinVar | IntVar | NumVar
data Bound v = InftyPos | InftyNeg | BoundVal v


data ConstraintOperator = LowerOrEqual | Equal | GreaterOrEqual
data IloConstraint a b = IloRange (Bound b) (LinCombination a b) (Bound b) |
                         IloSOS1 [a]
                         
type IloObjective a b = LinCombination a b                      

{- Un modèle est de type a b avec 
   - a est le type de l'identifiant (permettant d'identifier les variables et les contraintes)
   - b est le type des valeurs
-}
data IloModel a b = IloModel{ getObjective :: IloObjective a b,
                              getSense :: Sense,
                              getVarsKind :: Map a VarKind,
                              getConstraints :: Map a (IloConstraint a b),
                              getNbVars :: Integer}
                    
emptyModel :: IloModel a b
emptyModel = IloModel (LinCombination []) Maximize empty empty 0

type LPM a b r = State (IloModel a b) r 
type LPT a b m r = StateT (IloModel a b) m r


runLPT :: LPT a b m r -> m (r, IloModel a b)
runLPT = flip runStateT emptyModel

runLPM :: LPM a b r -> (r, IloModel a b)
runLPM = flip runState emptyModel