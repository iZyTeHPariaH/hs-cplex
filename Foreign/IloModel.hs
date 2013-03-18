{-# LANGUAGE ForeignFunctionInterface #-}
module Foreign.IloModel where

import Control.Monad.State 

import Data.CplexTypes
import Data.Var
import Data.LinCombination
import Foreign.Ptr
import Foreign.C.Types
import Foreign.Storable
import Foreign.Marshal.Array
import Data.Array
import qualified Data.Map.Lazy as M

type CDoubleArray = Ptr CDouble
type CIntArray = Ptr CInt

emptyArray n = array (1,n) $ zip [1..n] $ repeat 0
-- Compte le nombre de variables de chaque type
countVarTypes :: (Monad m) => LPT Var b m (Int,Int,Int)
countVarTypes = do
  kinds <- gets getVarsKind
  return $ foldl (\(n,b,i) k -> case k of
                     NumVar -> (n+1,b,i)
                     BinVar -> (n,b+1,i)
                     IntVar -> (n,b,i+1)) (0,0,0) (M.elems kinds)
{- Crée un tableau de taille nbVars contenant les coefficients de la combinaison linéaire -}
buildLC :: (Num b, Storable b, RealFrac b) =>  LinCombination Var b -> LPT Var b (VSupplyT IO) (Ptr CDouble)
buildLC (LinCombination lc) = do
  nbVars <- gets $ fromIntegral.getNbVars
  let emp = array (1,nbVars) $ zip [1..nbVars] (repeat 0) 
      l = map realToFrac $ elems $ emp // lc
  lift $ liftIO $ newArray l
                                        
{- Pour une combinaison linéaire donnée, crée trois tableaux contenant
    -> les coefficients des variables continues
    -> les coefficients des variables bool
    -> les coefficients des variables entières -}
buildLC' :: (Num b, Storable b, RealFrac b) => 
            Int -> Int -> Int->  LinCombination Var b -> 
            LPT Var b (VSupplyT IO) (CDoubleArray, CDoubleArray, CDoubleArray)
buildLC' nNVar nBVar nIVar (LinCombination lc) = do
  kinds <- gets getVarsKind
  let (n,b,i) = foldr (\e@(x,v) (n,b,i) -> case kinds M.! x of
                          NumVar -> (e:n,b,i) 
                          BinVar -> (n,e:b,i)
                          IntVar -> (n,b,e:i)) ([],[],[]) lc          
      nVarArray = map realToFrac $ elems $ emptyArray nNVar // n
      bVarArray = map realToFrac $elems $ emptyArray nBVar // b
      iVarArray = map realToFrac $ elems $ emptyArray nIVar // i
  lift $ liftIO $ do
    ntab <- newArray nVarArray
    btab <- newArray bVarArray
    itab <- newArray iVarArray
    return (ntab,btab,itab)
{- Crée un tableau contenant la combinaison linéaire objectif -}                                        
buildObjective :: (Num b, Storable b, RealFrac b) => LPT Var b (VSupplyT IO) (Ptr CDouble)
buildObjective = gets getObjective >>= buildLC 
buildObjective' n b i = gets getObjective >>= buildLC' n b i  
                 
{- Crée un tableau contenant la contrainte spécifiée -}
buildCtrLC :: (Num b, Storable b, RealFrac b) => IloConstraint Var b -> LPT Var b (VSupplyT IO) (Ptr CDouble)
buildCtrLC (IloRange _ lc _) = buildLC lc
buildCtrLC' n b i (IloRange _ lc _) = buildLC' n b i lc 

buildLP' :: (Num b, Storable b, RealFrac b) =>
           LPT Var b (VSupplyT IO)
           (Ptr CDoubleArray,
            (Ptr CDoubleArray, Ptr (Ptr CDoubleArray)),
            (Int,Int,Int,Int))
buildLP' = do
  (n,b,i) <- countVarTypes
  ctrlist <- gets $ M.elems.getConstraints
  (nobj,bobj,iobj) <- buildObjective' n b i
  (boundtab, ctab) <- foldM (\(boun,cpt) e@(IloRange (BoundVal lb) _ (BoundVal ub)) -> do
                                          (npt,bpt,ipt) <- buildCtrLC' n b i e
                                          ptboun <- lift $ liftIO $ newArray [realToFrac lb, realToFrac ub]
                                          ct <- lift $ liftIO $ newArray [npt,bpt,ipt]
                                          return (ptboun:boun,ct:cpt) ) ([],[]) ctrlist
  lift $ liftIO $ do
    boun <- newArray boundtab
    cpt <- newArray ctab
    objpt <- newArray [nobj,bobj,iobj]

    return (objpt,
            (boun,cpt),
           (n,b,i, length boundtab))
{- Crée :
   -> un tableau de taille n pour la fonction objectif
   -> p tableaux de taille n pour chaque contraintes linéaires
   -> une matrice à p lignes contenant la borne inf et la borne sup de chaque contrainte
   -> un tableau de taille n contenant le type de chaque variable
-}
buildLP :: (Num b, Storable b, RealFrac b) => 
           LPT Var b (VSupplyT IO) 
           (Ptr CDouble,  -- Fonction objectif
            Ptr (Ptr CDouble), -- Bornes sur les contraintes
            Ptr (Ptr CDouble), -- Coefficients des contraintes
            Int) -- Nombre de contraintes
buildLP = do
  obj <- buildObjective
  ctrlist <- gets $ M.elems.getConstraints
  (boundtab,ctrtab) <- foldM (\(boun,coeffs) e@(IloRange (BoundVal lb) _ (BoundVal ub)) -> do
                                 ptlc <- buildCtrLC e
                                 ptboun <- lift $ liftIO $ newArray [realToFrac lb, realToFrac ub]
                                 return (ptboun:boun,ptlc:coeffs)) 
                       ([],[]) ctrlist
  boun <- lift $ liftIO $ newArray boundtab
  ctr <- lift $ liftIO $ newArray ctrtab
  return (obj,boun,ctr, length $ ctrtab)
  
