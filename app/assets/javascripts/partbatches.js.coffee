# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->
    $("#part_brand_id").change ->
        $.getScript($(this).attr('rel') + '/' + $(this).val())
        return false
