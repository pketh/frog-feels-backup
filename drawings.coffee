uuid = require 'node-uuid'
moment = require 'moment'
_ = require 'underscore'

storage = require './storage'
users = require './users'
utils = require './utils'
elections = require './elections'

self =

  db: storage.db
  s3: storage.s3

  save: (data, feeling, response) ->
    path = "/#{moment().year()}-#{moment().week()}/#{uuid.v4()}.png" # /2016-51/cool.png
    Promise.all [
      storage.saveDrawing path, data
      storage.saveInfo path, feeling
    ]
    .then ->
      response.send
        code: 200
        drawing: path
        feeling: feeling
    .catch (error) ->
      console.log 'failed to save drawing', error

  remove: (request, response) ->
    return new Promise (resolve, reject) ->
      path = request.body.path
      console.log 'removing', path
      self.db.collection('Drawings').remove {path: path}, (error, drawing) ->
        if error
          console.error error
          reject Error 'failed to remove drawing from db', error
        else
          console.log 'removed:', drawing
          resolve drawing

  groupDrawings: (data) ->
    drawingsGroupedByFeeling = []
    winner = {}
    elections.getElectionWinner().then (result) ->
      winner = result
      elections.get()
    .then (results) ->
      lastElection = elections.lastElection(results)
      for feeling in data.feelings
        group =
          feeling: feeling
          drawings: []
        for drawing in data.drawings
          if drawing.feeling is feeling
            group.drawings.push
              path: drawing.path
              votes: drawing.votes
              award: lastElection.award if drawing.path is winner.path
              masterpiece: drawing.masterpiece
        drawingsGroupedByFeeling.push group
      return drawingsGroupedByFeeling

  addVote: (path) ->
    return new Promise (resolve, reject) ->
      self.db.collection('Drawings').findAndModify 
         query: 
           path: path
         update:
           $inc:
             votes: 1
      , (error, drawing) ->
        if drawing
          resolve drawing
        else
          reject Error 'failed to add vote to drawing in db', error

  makeMasterpiece: (path) ->
    console.log "💖", path
    return new Promise (resolve, reject) ->
      self.db.collection('Drawings').findAndModify
         query: 
           path: path
         update:
           $set:
             masterpiece: true
      , (error, drawing) ->
        if drawing
          console.log 'success', drawing
          resolve drawing
        else
          reject Error 'failed to set drawing as masterpiece in db', error

module.exports = self
