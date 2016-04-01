Sugar.extend({
  _currentUser: false,

  loggedIn: () => this.getCurrentUser() ? true : false,

  getCurrentUser: function() {
    if (this.Configuration.currentUser && !this._currentUser) {
      this._currentUser = new Sugar.Models.User(this.Configuration.currentUser);
    }
    return this._currentUser;
  }
});
