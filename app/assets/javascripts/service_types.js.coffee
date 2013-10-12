# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->
    $("#service_type_auto_model_div").hide() if !$('#service_type_specific_auto_model').is(':checked')
    $("#service_type_specific_auto_model").on "click", ->
        $("#service_type_auto_model_div").toggle()