Q = require 'bluebird-q'
UserEdit = require './models/user_edit'
Profile = require '../../models/profile'

@refresh = (req, res, next) ->
  return res.redirect '/' unless req.user

  req.user
    .fetch()
    .then ->
      req.login req.user, (err) ->
        return next err if err?
        res.json req.user.attributes

    .catch next

@settings = (req, res, next) ->
  return res.redirect "/log_in?redirect_uri=#{req.url}" unless req.user
  return res.redirect '/' if req.user.isAdmin()

  user = new UserEdit req.user.attributes
  profile = new Profile

  # Fetch private User fields & overried CurrentUser's sync
  # to add the `access_token` param
  user
    .fetch()
    .then ->
      profile.set 'id', req.user.get 'default_profile_id'

      Q.all [
        user.fetchAuthentications data: access_token: user.get 'accessToken'
        profile.fetch data: access_token: user.get 'accessToken'
      ]

    .then ->
      res.locals.sd.PROFILE = profile.toJSON()
      res.locals.sd.USER = user.toJSON()

      # HTTP cache headers to prevent browser caching
      res.set 'Cache-Control', 'private, no-cache, no-store, max-age=0'
      res.set 'Pragma', 'no-cache'
      res.set 'Expires', '0'

      res.render 'index',
        user: user
        profile: profile

    .catch next
