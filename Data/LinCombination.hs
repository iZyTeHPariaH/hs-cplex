module Data.LinCombination where

infixl 5 .*
infixl 4 .+

data LinCombination a b = LinCombination [(a,b)]

(.*) :: b -> a -> LinCombination a b
n .* x = LinCombination [(x,n)]

-- Attention : ne réduit pas l'expression concaténée
(.+) :: LinCombination a b -> LinCombination a b -> LinCombination a b
LinCombination l .+ LinCombination l' = LinCombination $ l ++ l'


