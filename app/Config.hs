module Config where

import Data.Text

data Config = Config
  { slackApiKey  :: String
  , googleApiKey :: Text
  , slackChannel :: String
  }

config =
    Config
    { slackApiKey = "your-slack-key-here"
    , googleApiKey = "your-google-key-here"
    , slackChannel = "some-channel"
    }
