# mojobot

A hubot hanging around in the [#jekyll room on IRC](https://botbot.me/freenode/jekyll/).
Forked from [mattetti/bottetti](https://github.com/mattetti/bottetti).

## Testing

To test mojobot, run `script/console`. This will load your `.env` file and run the hubot REPL.

## Custom Scripts

We're trying to limit our custom scripts. If you really think it's a good idea, then others probably want to use it, too! Consider writing it as an NPM module and adding it to the `package.json` and `external-scripts.json` files in this project. No need to isolate it in this one repo!

## Deploying

Mojobot is currently deployed to Heroku. To deploy, just `git push heroku master` and you're done.
