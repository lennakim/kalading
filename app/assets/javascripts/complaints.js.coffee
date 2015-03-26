# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->
    $("#search-by-phone-num").click ->
        $.getScript(this.href + "?phone_num=" + $("#complaint_customer_phone_num").val() ) if $("#complaint_customer_phone_num").val().length >= 10
        return false
    $("#complainted_role").change ->
        $.getScript("/users?role=" + $("#complainted_role").val() + "&city=" + $("#complaint_city_id").val()) if $("#complainted_role").val() != ""
        return false
    $("#complaint_city_id").change ->
        $.getScript("/users?role=" + $("#complainted_role").val() + "&city=" + $("#complaint_city_id").val()) if $("#complaint_city_id").val() != ""
        return false