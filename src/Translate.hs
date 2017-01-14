module Translate where

import qualified Data.Text            as T
import           Network.HTTP.Client
import           Web.Google.Translate

toEnglish :: Manager -> T.Text -> T.Text -> IO T.Text
toEnglish tlsH key message = do
    resp <- translate tlsH (Key key) Nothing (Target English) (Body message)
    case resp of
        Right TranslationResponse{translations = xs} ->
            -- @todo should probably foldl all the texts with newlines instead
            -- of throwing away all but the first...
            case xs of
                x:_ ->
                    return $
                    (\Translation{translatedText = TranslatedText txt} ->
                          txt)
                        x
                _ -> return "no text!"
        Left x -> return $ T.pack $ show x
