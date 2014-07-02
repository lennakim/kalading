# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
    $(document).on "click", "#partbatches .pagination a", ->
        $.getScript(this.href);
        return false
    $("#part_type_id").change ->
        $.get($(this).attr('rel') + '/' + $(this).val(), null, null, "script")
        return false
