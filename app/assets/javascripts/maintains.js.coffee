# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
    $("#new_maintain, form[id^=edit_maintain]").validate(
        errorPlacement:
            (error, element) ->
                error.css("color", "#FF0000")
                error.insertAfter(element)
    )


    
