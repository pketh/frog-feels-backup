express = require 'express'
app = express()
coffeeMiddleware = require 'coffee-middleware'
engines = require 'consolidate'
bodyParser = require 'body-parser'
stylish = require 'stylish'
autoprefixer = require 'autoprefixer-stylus'
urlRegex = require "url-regex"

PORT = process.env.PORT # 3000
routes = require './routes'
storage = require './storage'

app.use(express.static('public'))
app.engine('jade', engines.jade)
app.use coffeeMiddleware
  bare: true
  src: "public"
require('coffee-script/register')

app.use bodyParser.urlencoded
  extended: false
app.use bodyParser.json()
app.use bodyParser.text()

app.use stylish
  src: __dirname + '/public'
  setup: (renderer) ->
    renderer.use autoprefixer()
  watchCallback: (error, filename) ->
    if error
      console.log error
    else
      console.log "#{filename} compiled to css"

init = ->
  console.log 'init', new Date
  # scrape feelings saves a date, if within 3 hours..
    # get from db/cache/redis instead?? (w promise)
    # else scrapefeelings as below:
  storage.scrapeFeelings.then (response) ->
    # also save response to cache/redis
    # updateLastScrapedDate -> upsert db.meta.lastScrapped new Date
    console.log '🌴', response
  .then ->
    console.log 'feels scrapped', new Date
    app.use routes
    app.listen PORT, ->
      console.log "Your app is running on #{PORT}"
  .catch (error) ->
    console.error 'startup failed', error

init()

module.exports = app
