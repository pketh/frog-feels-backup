utils = require './utils'
mongojs = require 'mongojs'
knox = require 'knox'
Xray = require 'x-ray'
xray = Xray()
_ = require 'underscore'
urlRegex = require "url-regex"
moment = require 'moment'

db = mongojs("#{process.env.DB_USER}:#{process.env.DB_PASS}@#{process.env.DB_URL}")

self = 

  db: db

  feelings: []

  scrapeFeelings: new Promise (resolve, reject) ->
    xray('https://feelings.blackfriday', ['p']) (error, scrapedFeelings) ->
      self.feelings = scrapedFeelings
      if self.feelings.length > 0
        self.filterFeelings()
        resolve 'feelings scraped'
      else
        reject Error 'failed to scrape feelings.blackfriday'

  filterFeelings: ->
    self.feelings = _.compact self.feelings
    self.feelings = self.feelings.slice(3, 30)
    self.feelings = _.filter self.feelings, (feeling) ->
      feeling.length < 400 and not urlRegex().test feeling

  s3: knox.createClient
    key: process.env.S3_ACCESS_KEY_ID
    secret: process.env.S3_SECRET_ACCESS_KEY
    bucket: process.env.S3_BUCKET_PATH

  connectToDb: new Promise (resolve, reject) ->
    db.getCollectionNames (error, collections) ->
      if collections
        resolve collections
      else
        reject Error 'failed to connect to db'

  saveDrawing: (path, data) ->
    return new Promise (resolve, reject) ->
      console.log 'saving drawing to s3'
      headers =
        'Content-Type': 'image/png'
        'x-amz-acl': 'public-read'
      self.s3.putBuffer data, path, headers, (error, response) ->
        if response
          resolve response
        else
          reject Error error

  saveInfo: (path, feeling) ->
    return new Promise (resolve, reject) ->
      console.log 'updating db'
      db.collection('Drawings').save
        created: (new Date).toString()
        path: path
        feeling: feeling
      , (error, response) ->
        if response
          resolve response
        else
          reject Error error

  getLastWeek: ->
    return new Promise (resolve, reject) ->
      data =
        drawings: []
        feelings: []
      lastWeek = "#{moment().year()}-#{moment().week() - 1}" # "2016-53"
      db.collection('Drawings').find (error, drawings) ->
        for drawing in drawings
          if drawing.path.indexOf(lastWeek) > -1
            data.drawings.push drawing
            data.feelings.push drawing.feeling
        data.feelings = _.uniq(data.feelings)
        if data
          resolve data
        else
          reject Error "failed to get last week's data"

  getThisWeek: ->
    return new Promise (resolve, reject) ->
      data =
        drawings: []
        feelings: []
      thisWeek = "#{moment().year()}-#{moment().week()}"
      db.collection('Drawings').find (error, drawings) ->
        for drawing in drawings
          if drawing.path.indexOf(thisWeek) > -1
            data.drawings.push drawing
            data.feelings.push drawing.feeling
        data.feelings = _.uniq(data.feelings)
        if data
          resolve data
        else
          reject Error "failed to get this week's data"

  getMasterpieces: ->
    return new Promise (resolve, reject) ->
      db.collection('Drawings').find {masterpiece: true}, (error, drawings) ->
        for drawing in drawings
          drawing.feeling = drawing.feeling or "feeling unknown"
          artMedium = _.sample utils.artMedium
          artSurface = _.sample utils.artSurface
          drawing.medium = utils.capitalizeFirstLetter "#{artMedium} on #{artSurface}"
          date = new Date drawing.created
          drawing.year = moment(date).format('YYYY')
        if drawings
          resolve drawings
        else
          reject Error "failed to get masterpieces from db"

  # called as a GET from route
  getTherapyDrawing: ->
    masterpieces = self.getMasterpieces()
    thisWeek = "#{moment().year()}-#{moment().week()}"
    console.log masterpieces
    # add a therapyWeek array item to the drawing
    # check the year-week,
    # if no thisWeek match in drwing, create a db obj by randomly picking a masterpiece, and return the drawing path
    # else (is a thisweek match), return the drawing path

  # saveTherapy: ->
    # db.collection('Therapies')
    # saves slider values
    # therapy week
    # drawing url


    
module.exports = self

self.connectToDb.then (result) ->
  console.log '💁 database connected', result
.catch (error) ->
  console.log error

  