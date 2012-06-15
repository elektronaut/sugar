Sugar.extend

  _currentUser: false,

  loggedIn: ->
    if this.getCurrentUser()
      true
    else
      false

  getCurrentUser: ->
    if this.Configuration.currentUser && !this._currentUser
      this._currentUser = new Sugar.Models.User(this.Configuration.currentUser)

    return this._currentUser
