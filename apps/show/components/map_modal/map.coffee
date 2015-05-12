_ = require 'underscore'
sd = require('sharify').data
GMaps = -> require('gmaps') arguments...
geo = require '../../../../components/geo/index.coffee'
{ getMapLink } = require "../../../../components/util/google_maps.coffee"
ModalView = require '../../../../components/modal/view.coffee'

template = -> require('./map.jade') arguments...

module.exports = class MapModal extends ModalView

  template: -> template arguments...

  className: 'map-modal'

  events: -> _.extend super,
    'click input': 'selectAll'

  initialize: (options) ->
    @show = options.model
    mapLinkOptions =
      q: @show.location().getMapsLocation()
    @templateData =
      show: @show
      googleMapsLink: getMapLink mapLinkOptions
    super

  postRender: ->
    geo.loadGoogleMaps =>
      map = new GMaps
        el: '#map-modal-show-map'
        lat: @show.location().get('coordinates').lat
        lng: @show.location().get('coordinates').lng
        zoom: 16
        disableDefaultUI: true
      map.addStyle {
        styledMapName: "Styled Map"
        styles: [
          {
            stylers: [
              { lightness: 50 }
              { saturation: -100 }
            ]
          }
        ]
        mapTypeId: "map_style"
      }
      map.setStyle "map_style"
      map.addMarker {
        lat: @show.location().get('coordinates').lat
        lng: @show.location().get('coordinates').lng
        icon: 'http://maps.google.com/mapfiles/ms/icons/purple-dot.png'
      }

  selectAll: (e) ->
    $(e.currentTarget).select()
