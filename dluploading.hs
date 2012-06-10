module Main where

import           System.Environment
import           System.Process
import           System.Exit
import           Data.List
import           Network.URI
import           Data.Maybe
import qualified Data.ByteString.Lazy as B
import qualified Data.ByteString.Lazy.Char8 as B8
import           Data.ByteString.Lazy (ByteString)
import qualified System.IO as Sys
import           Network.HTTP
import           Control.Concurrent (threadDelay)
import           Text.JSON
import           Text.JSON.String
import           Control.Monad
import           Data.Functor
import           Data.Char

userAgent = "Mozilla/5.0 (X11; Linux i686; rv:10.0.4) Gecko/20100101 Firefox/10.0.4 Iceweasel/10.0.4"

main = getArgs >>= run

run :: [String] -> IO ()
run [uriStr] = do
  let uri = maybe (error $ "invalid uri: " ++ uriStr) id $ parseURI uriStr
  getCookies $ show uri
  sequence_ $ replicate 45 $ threadDelay (10^6) >> putStrLn "*"
  cookieHeader <- forgeCookieHeader $ getHostFromUri uri
  let fileHash = getHashFromUri uri
  let ajaxRequest = forgeAjaxRequest cookieHeader fileHash uriStr
  ajaxResponseZipped <- simpleHTTP ajaxRequest >>= getResponseBody
  B.writeFile "ajaxResponseZipped" ajaxResponseZipped
  link <- readProcess "gunzip" ["-c", "ajaxResponseZipped"] "" >>= return . getLink
  putStrLn link
  downloadFile link uriStr $ uriToFilename uriStr
run _ = putStrLn "usage: run <URL>"

uriToFilename :: String -> String
uriToFilename = map (\x -> if isAlphaNum x then x else '_')

downloadFile :: String -> String -> String -> IO ()
downloadFile link referer saveToFilename =
  rawSystem "wget" [ "-O", saveToFilename
                   , "--load-cookies=cookies.txt"
                   , "-U", userAgent
                   , "--referer=" ++ referer
                   , link
                   ]
    >> return ()

getCookies :: String -> IO ()
getCookies url =
  rawSystem "wget" ["-O", "/dev/null", "--save-cookies=cookies.txt", "--keep-session-cookies", url]
    >> return ()

forgeCookieHeader :: String -> IO String
forgeCookieHeader host = do
  cookieFields <- readFile "cookies.txt" >>= return . grep (("." ++ host) `isPrefixOf`)
  return $ (intercalate "; " $ map (intercalate "=") $ map (drop 5) $ map words cookieFields) ++ ";"

grep :: (String -> Bool) -> String -> [String]
grep pattern =
  filter pattern . lines

getHostFromUri :: URI -> String
getHostFromUri = uriRegName . fromJust . uriAuthority

getHashFromUri :: URI -> String
getHashFromUri = take 8 . drop 7 . uriPath

forgeAjaxRequest :: String -> String -> String -> Request ByteString
forgeAjaxRequest cookieHeader fileHash referer =
    Request
      { rqMethod  = POST
      , rqURI     = fromJust $ parseURI "http://uploading.com/files/get/?ajax"
      , rqBody    = B8.pack requestBody
      , rqHeaders =
          [ mkHeader HdrUserAgent userAgent
          , mkHeader HdrAccept "application/json, text/javascript, */*; q=0.01"
          , mkHeader HdrAcceptLanguage "en-us,en;q=0.5"
          , mkHeader HdrAcceptEncoding "gzip, deflate"
          , mkHeader HdrContentType "application/x-www-form-urlencoded; charset=UTF-8"
          , mkHeader (HdrCustom "X-Requested-With") "XMLHttpRequest"
          , mkHeader HdrContentLength $ show $ length requestBody
          , mkHeader HdrConnection "close"
          , mkHeader HdrCookie cookieHeader
          , mkHeader HdrReferer referer
          ]
      }
  where
    requestBody = "action=get_link&code=" ++ fileHash ++ "&pass=false"

getLink :: String -> String
getLink s = case either undefined id $ runGetJSON readJSString $ (reverse . drop 2 . reverse . drop 18) s of
  JSString s -> fromJSString s
  _ -> undefined
