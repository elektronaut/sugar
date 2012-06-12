class Sugar.Models.User extends Backbone.Model
  paramRoot: 'user'

  idAttribute: "id"

  defaults:
    username: ''
    admin: false
    moderator: false
    user_admin: false

  isAdmin: ->
    this.get('admin')

  isModerator: ->
    this.get('moderator') or this.isAdmin()

  isUserAdmin: ->
    this.get('user_admin') or this.isAdmin()

class Sugar.Collections.Users extends Backbone.Collection
  model: Sugar.Models.User
  url: '/users'
