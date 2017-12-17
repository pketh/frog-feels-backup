Sparkpost = require 'sparkpost'
sparkpost = new Sparkpost()
juice = require 'juice'
_ = require 'underscore'
fs = require 'fs'
randomcolor = require 'randomcolor'
marked = require 'marked'

drawings = require './drawings'
storage = require './storage'
users = require './users'
utils = require './utils'
elections = require './elections'

self =
  getEmailCss: ->
    return fs.readFileSync('./public/styles/email.css').toString()

  mapUsers: (users) ->
    _.map users, (user) ->
      return {address: {email: user}}

  generateWeeklyEmail: (data, response) -> 
    console.log 'generating weekly'
    feelingGroups = []
    storage.getLastWeek().then (results) ->
      drawings.groupDrawings(results)
    .then (groups) ->
      feelingGroups = groups
      users.get()
    .then (users) ->
      data.users = self.mapUsers users
      elections.get()
    .then (electionData) ->
      election = elections.lastElection electionData
      response.render 'last-week',
        feelingGroups: feelingGroups
        emailHeader: _.sample utils.emailHeaders
        intro: marked data.intro
        awardColor: randomcolor luminosity:'light'
        election: election.question
        admin: false
        email: true
      ,
      (error, html) ->
        if error
          console.log error
        else
          data.html = juice.inlineContent html, self.getEmailCss()
          self.sendMail data, response

  sendMail: (data, response) ->
    console.log data.users
    sparkpost.transmissions.send
      transmissionBody:
        options:
          open_tracking: false
          click_tracking: false
          transactional: true
        content:
          from: 
            email: 'hi@frogfeels.com'
            name: 'Frog Feels'
          subject: data.subject
          html: data.html
        recipients: data.users
        # [
          # { address: { email: 'pirijan@gmail.com' } }
          # { address: { email: 'pketh@yahoo.com' } }
          # { address: { email: 'hi@pketh.org' } }
        # ]
    ,
    (error, status) ->
      if error
        console.log error
      else
        console.log "💌 emails sent!", status.body
        response.send
          code: 200


module.exports = self
