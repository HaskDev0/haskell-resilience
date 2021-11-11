{-# LANGUAGE OverloadedStrings#-}

import System.Environment(getArgs)
import System.IO(openFile,
                 hClose,
                 IOMode(..),
                 hPutStrLn)

--import qualified Data.ByteString as B
--import qualified Data.Text.Encoding as E

import qualified Data.Text as T
import qualified Data.Text.IO as TI

import Data.Array.Unboxed(Array,
                          (!))
import qualified Data.Vector as V
import Data.Ratio(Ratio,
                  (%))

--for stateful programs
import Data.Array.ST(runSTArray,
                     newArray,
                     writeArray)
import Control.Monad(forM,
                     forM_)
--import Control.Monad.ST

--Sample values
a :: Integer
a = 261

b :: Integer
b = 1537

q :: Ratio Integer
q = a%b

toQ :: (T.Text,T.Text) -> Ratio Integer
toQ (a,b) = (read (T.unpack a))%(read (T.unpack b))

textToTuples :: T.Text -> (T.Text,T.Text)
textToTuples text = (res !! 0, res !! 1)
  where
    res = T.words text

listTTolistT :: [T.Text] -> [(T.Text,T.Text)]
listTTolistT vals = map textToTuples vals

toListQ :: [(T.Text,T.Text)] -> [Ratio Integer]
toListQ vals = map toQ vals

--list of primes
sieve :: [Integer] -> [Integer]
sieve [] = []
sieve (nextPrime:rest) = nextPrime : sieve noFactors
  where noFactors = filter (not . (== 0) . (`mod` nextPrime)) rest

primes :: [Integer]
primes = sieve [2 .. ]

--totient
totient :: [Integer] -> Integer
totient prseq = foldl (*) 1 newseq
  where
    newseq = map (+ (-1)) prseq

resList :: Ratio Integer -> [Integer] -> [Integer] -> Integer -> Integer -> Integer -> Integer -> ([Integer],Integer,Integer)
resList val lval lprimes mult oldmult tot oldtot = if tot%(mult - 1) >= val
  then resList val newList newPrimes newMult mult a tot
  else (lval,oldmult,oldtot)
  where
    newList = (head lprimes):lval
    newPrimes = tail lprimes
    newMult = mult*(head lprimes)
    a = tot*((head lprimes) - 1)

listToSearch :: (a,b,c) -> a
listToSearch (x,_,_) = x

oldMul :: (a,b,c) -> b
oldMul (_,y,_) = y

oldT :: (a,b,c) -> c
oldT (_,_,z) = z

nR :: [Ratio Integer] -> Integer -> Integer -> Integer -> [Ratio Integer]
nR lvals 1 _ _ = lvals
nR lvals factor oldmult oldtot = nR (x:lvals) (factor - 1) oldmult oldtot
  where
    x = (oldtot*factor)%(factor*oldmult - 1)

listToArray :: Integer -> [Ratio Integer] -> Array Integer (Ratio Integer)
listToArray size vals = runSTArray $ do
    myArray <- newArray (2,size) 0
    forM_ (zip vals [2 .. ]) $ \(val,i) -> writeArray myArray i val
    return myArray

binarySearch :: (Ratio Integer) -> Integer -> Integer -> Array Integer (Ratio Integer) -> Integer
binarySearch qVal fstM lastM myArray
  | fstM == lastM = fstM
  | value < qVal = binarySearch qVal fstM index myArray
  | otherwise = binarySearch qVal (index + 1) lastM myArray
  where
     index = (lastM + fstM) `quot` 2
     value = myArray ! index

fullTransform :: (Ratio Integer) -> Integer
fullTransform qVal = finalIndex * oldmult
  where
    tripleM = resList qVal [2] (tail primes) 2 2 1 1
    oldmult = oldMul tripleM
    finalIndex = binarySearch qVal 2 size myArray
    size = head $ listToSearch tripleM
    myArray = listToArray size vals
    vals = nR [] size oldmult oldtot
    oldtot = oldT tripleM

main :: IO ()
main = do
  --getting contents from the file
  args <- getArgs
  let fileName = head args
  file <- openFile fileName ReadMode
  input <- TI.hGetContents file
  hClose file
  --prepare contents for functions
  let readableInput = T.lines input
  let numT = head readableInput
  lineResults <- forM (take (read (T.unpack numT)) (tail readableInput)) return
  let listOfQs = toListQ $ listTTolistT lineResults
  --finding the answers
  let listOfAs = map fullTransform listOfQs
  let listOfAsStr = map show listOfAs
  --printing to a file
  fileW <- openFile "Results.txt" WriteMode
  mapM_ (hPutStrLn fileW) listOfAsStr
  hClose fileW
  print "Done"
