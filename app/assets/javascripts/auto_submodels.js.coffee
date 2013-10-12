# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->
    $(document).on "click", "#auto_submodels .pagination a", ->
        $.getScript(this.href)
        return false
    $("#auto_submodels_search input").keyup ->
        $.get($("#auto_submodels_search").attr("action"), $("#auto_submodels_search").serialize(), null, "script")
        return false
