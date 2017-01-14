## Babelslack

A very rudimentary application that

- Takes the last 100 lines of a slack channel
- Runs them through google translate for "to English" translation
- Prints them out

Relying on Google's language detection rather than explicitly setting the `From` value.

### Usage

Requires a Slack API key and a Google API key. Drop them into `app/Config.hs` along with a slack channel name, then:

```
stack build && stack exec babelslack-exe
```

Gives something like:
```
user1: Something that was originally in another language!
user2: <@U3RU7P8FM|user2> has joined the channel
user3: Another message in another language
```
