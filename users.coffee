storage = require './storage'

self =

  db: storage.db

  users: []

  save: (email) ->
    date = (new Date).toString()
    self.db.collection('Users').save
      created: date
      email: email

  remove: (request, response) ->
    console.log 'find mongo record and delete it'
    email = request.body.email
    console.log email
    self.db.collection('Users').remove {email: email}, (error, doc) ->
      if error
        console.warn error
      console.log doc
      response.send
        code: 200

  get: ->
    return new Promise (resolve, reject) ->
      self.db.collection('Users').find (error, users) ->
        self.users = []
        for user in users
          self.users.push user.email
        if self.users
          resolve self.users
        else
          reject Error 'failed to get users from db'

module.exports = self
