app = require 'express'
router = app.Router()
_ = require 'underscore'
randomcolor = require 'randomcolor'
isValidEmail = require 'is-valid-email'

storage = require './storage'
drawings = require './drawings'
users = require './users'
utils = require './utils'
emails = require './emails'
elections = require './elections'

router.get '/', (request, response) ->
  candidates = null
  console.log 'route start', new Date
  storage.getThisWeek().then (data) ->
    candidates = elections.getCandidates data
    elections.get()
  .then (electionData) ->
    election = elections.currentElection electionData
    console.log '🌎', election
    if election
      response.render 'index.jade',
        title: 'Frog Feels'
        feeling: _.sample storage.feelings
        palettes: _.shuffle utils.palettes
        candidates: candidates
        election: election.question
        admin: process.env.ADMIN
    else
      response.render 'new-election.jade',
        title: 'New Election'
        admin: process.env.ADMIN
        elections: electionData
        
    console.log 'post render', new Date
  .catch (error) ->
    console.error '/', error

router.post '/save-drawing', (request, response) ->
  drawing = request.body.image
  drawing = drawing.substring drawing.indexOf('base64,')+7
  data = new Buffer(drawing, 'base64')
  feeling = request.body.feeling
  drawings.save(data, feeling, response)

router.post '/sign-up', (request, response) ->
  email = request.body.email
  if isValidEmail(email)
    users.save email
    response.send true
  else
    response.send false

router.post '/remove-drawing', (request, response) ->
  drawings.remove request, response
  .then (result, error) ->
    response.send true
  .catch (error) ->
    console.error '/remove-drawing', error
    response.send false

router.post '/make-masterpiece', (request, response) ->
  drawings.makeMasterpiece request.body.path
  .then (result, error) ->
    response.send true
  .catch (error) ->
    console.error '/make-masterpiece', error
    response.send false

router.get '/last-week', (request, response) ->
  feelingGroups = []
  usersData = []
  storage.getLastWeek().then (data) ->
    drawings.groupDrawings(data)
  .then (groups) ->
    feelingGroups = groups
    usersData = users.get()
  .then (users) ->
    elections.get()
  .then (electionData) ->
    election = elections.lastElection electionData
    response.render 'last-week.jade',
      title: 'Last Week'
      emailHeader: _.sample utils.emailHeaders
      users: usersData
      feelingGroups: feelingGroups
      admin: process.env.ADMIN
      emailSecret: process.env.FROG_SECRET
      awardColor: randomcolor luminosity:'light'
      election: election.question
  .catch (error) ->
    console.error '/last-week', error

router.get '/this-week', (request, response) ->
  storage.getThisWeek().then (data) ->
    console.log 'this-week', data
    drawings.groupDrawings(data)
  .then (groups) ->
    response.render 'this-week.jade',
      title: 'This Week'
      feelingGroups: groups
      admin: process.env.ADMIN
  .catch (error) ->
    console.error '/this-week', error

router.get '/masterpieces', (request, response) ->
  storage.getMasterpieces().then (drawings) ->
    response.render 'masterpieces.jade',
      title: 'Masterpieces'
      drawings: _.shuffle drawings
      admin: process.env.ADMIN
  .catch (error) ->
    console.error '/masterpieces', error

router.get '/therapy-drawing', (request, response) ->
  storage.getTherapyDrawing().then (drawing) ->
    response.send drawing
  .catch (error) ->
    console.error '/therapy-drawing', error
    
router.post '/send-weekly-email', (request, response) ->
  data = request.body
  console.log 'request received: ', data
  if data.secret is process.env.FROG_SECRET
    emails.generateWeeklyEmail(data, response)

router.get '/unsubscribe', (request, response) ->
  response.render 'unsubscribe.jade'

router.post '/unsubscribe', (request, response) ->
  console.log request
  users.remove request, response

router.get '/new-election', (request, response) ->
  elections.get().then (elections) ->
    response.render 'new-election.jade',
      title: 'New Election'
      admin: process.env.ADMIN
      elections: elections
      admin: process.env.ADMIN

router.post '/new-election', (request, response) ->
  if elections.validate(request.body)
    elections.save(request.body).then (result, error) ->
      response.send result
    .catch (error) ->
      console.error '/new-election', error
      response.send false
  else 
    response.send false

router.post '/add-vote', (request, response) ->
  drawings.addVote(request.body.path).then (result, error) ->
    response.send true
  .catch (error) ->
    console.error '/add-vote', error
    response.send false


module.exports = router
