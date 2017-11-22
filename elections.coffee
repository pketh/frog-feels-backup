_ = require 'underscore'

moment = require 'moment'
storage = require './storage'

self =

  db: storage.db
  
  getNewWeek: ->
    return new Promise (resolve, reject) ->
      self.get().then (elections) ->
        currentYear = moment().year()
        currentWeek = moment().week()
        current = "#{currentYear}-#{currentWeek}"
        if elections.length is 0
          resolve current
        else if elections
          latestMatches = elections[elections.length-1].week.match(/([0-9])*/g)
          latestYear = latestMatches[0]
          latestWeek = latestMatches[2]
          if latestYear is not currentYear
            resolve current
          else
            newWeek = parseInt(latestWeek) + 1
            resolve "#{currentYear}-#{newWeek}"
        else
          reject Error 'failed to get new election week'

  save: (election) ->
    return new Promise (resolve, reject) ->
      self.getNewWeek().then (week) ->
        self.db.collection('Elections').save
          week: week
          question: election.question
          award: election.award
        , (error, result) ->
          console.log 'election saved', result
          if result
            resolve result
          else
            reject Error 'failed to save elections to db', error

  validate: (election) ->
    true if election.question and election.award

  get: ->
    console.log 'get elections'
    console.log 'cy', moment().year()
    return new Promise (resolve, reject) ->
      self.db.collection('Elections').find (error, elections) ->
        if elections
          # TODO getNewWeek is faulty when year is filterd for currentyear only
          # currentYear = moment().year()
          # recentElections = elections.filter (election) ->
          #   if election.week.includes currentYear
          #     election
          # recentElections.reverse()
          # console.log recentElections
          resolve elections
        else
          reject Error 'failed to get elections from db', error

  currentElection: (elections) ->
    currentYear = moment().year()
    currentWeek = moment().week()
    current = "#{currentYear}-#{currentWeek}"
    console.log 'current', current
    for election in elections
      if election.week is current
        return election

  lastElection: (elections) ->
    currentYear = moment().year()
    currentWeek = moment().week() - 1
    current = "#{currentYear}-#{currentWeek}"
    for election in elections
      if election.week is current
        return election

  getCandidates: (data) ->
    if data.drawings.length > 3
      _.sample data.drawings, 3

  getElectionWinner: ->
    return new Promise (resolve, reject) ->
      winner = 
        votes: 0
      storage.getLastWeek().then (data) ->
        for drawing in data.drawings
          if drawing.votes > winner.votes
            winner = drawing
        if winner
          resolve winner
        else
          reject Error "failed to determine a winner"

module.exports = self
