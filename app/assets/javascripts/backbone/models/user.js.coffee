class Sugar.Models.User extends Backbone.Model
  paramRoot: 'user'

  defaults:
    username: null
    admin: null
    moderator: null
    user_admin: null

class Sugar.Collections.Users extends Backbone.Collection
  model: Sugar.Models.User
  url: '/users'