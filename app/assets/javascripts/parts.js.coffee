# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
    $(document).on "click", "#parts .pagination a", ->
        $.getScript(this.href);
        return false
    $("#parts_search input").keyup ->
        $.get($("#parts_search").attr("action"), $("#parts_search").serialize(), null, "script")
        return false

