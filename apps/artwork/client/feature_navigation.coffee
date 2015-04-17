Backbone = require 'backbone'
template = -> require('../templates/feature_navigation.jade') arguments...

module.exports = class FeatureNavigationView extends Backbone.View
  initialize: ({ @model, @kind }) ->
    @render()

  negativeRenderCriteria: ->
    @kind is 'fair' and not @model.get('published') or
    not @model.has 'name' or
    not @model.get 'has_full_feature'

  checkAndSetHref: ->
    return false if @negativeRenderCriteria()

    @href =
      if @kind is 'feature'
        "/feature/#{@model.id}"
      else if @kind is 'fair'
        "/#{@model.get('default_profile_id')}"
      else
        "/#{@model.id}"

  # Handles Feature and Fair models
  render: ->
    if @checkAndSetHref()
      @$el.html template
        model: @model
        kind: @kind
        href: @href
    this
