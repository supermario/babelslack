module Main where

import           Config
import           Control.Concurrent.Async (mapConcurrently)
import           Control.Monad            (forM)
import           Data.Monoid              ((<>))
import qualified Data.Text                as T
import qualified Data.Text.IO             as T
import qualified Data.Text.Lazy           as TL
import           Data.Text.Lazy.Builder   (toLazyText)
import           HTMLEntities.Decoder     as H (htmlEncodedText)
import           Network.HTTP.Client
import           Network.HTTP.Client.TLS
import           Translate                (toEnglish)
import           Web.Slack

type Trans = (T.Text, T.Text)

main :: IO ()
main = do
    messages <- slackChan (slackChannel config)
    tlsH <- newManager tlsManagerSettings
    let transL = reverse (fmap toTrans messages)
    translations <- mapConcurrently (translateTrans tlsH) transL
    _ <-
        forM translations $
        \(user,message) ->
             T.putStrLn $ user <> ": " <> decodeHtmlEntities message
    return ()

toTrans :: Message -> Trans
toTrans m = (T.pack $ username m, messageText m)

username :: Message -> String
username message =
    case messageUser message of
        Just u  -> userName u
        Nothing -> "none"

decodeHtmlEntities :: T.Text -> T.Text
decodeHtmlEntities = TL.toStrict . toLazyText . htmlEncodedText

translateTrans :: Manager -> Trans -> IO Trans
translateTrans tlsH (user,message) = do
    messageT <- toEnglish tlsH (googleApiKey config) message
    return (user, messageT)

slackApi :: Slack a -> IO (Either SlackError a)
slackApi = runSlack $ slackApiKey config

slackChan :: String -> IO [Message]
slackChan chanName = do
    r <-
        slackApi $
        do chan <- channelFromName chanName
           channelHistory 100 chan
    case r of
        Left e -> do
            putStrLn e
            return []
        Right results -> return results
