# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
    $("#user_set_state_0").click ->
        $.getScript('/curr_user_state?state=0')
        $("#user_state_id").dropdown('toggle')
        return false
    $("#user_set_state_1").click ->
        $.getScript('/curr_user_state?state=1')
        $("#user_state_id").dropdown('toggle')
        return false
    $("#user_set_state_2").click ->
        $.getScript('/curr_user_state?state=2')
        $("#user_state_id").dropdown('toggle')
        return false