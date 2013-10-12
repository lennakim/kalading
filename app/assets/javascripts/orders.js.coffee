# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
    # select elements end with service_type_id
    $(document).on "change", "[id$=service_type_id]", ->
        t = $(this)
        $.getJSON '/service_types/' + $(this).val(), null, (data) ->
            $.each data, (i, field) ->
                # select parent div's child input
                t.parents("div.fields").find("input").val(field)
        return false