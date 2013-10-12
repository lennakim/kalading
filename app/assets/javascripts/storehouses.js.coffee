# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
    $(document).on "click", "#partbatches .pagination a", ->
        $.getScript(this.href);
        return false
    $("#partbatches_search_by_part input, #partbatches_search_by_auto input, #partbatches_search_by_order input, #partbatches_search_by_partbatch input").click ->
        $.get($(this).closest("form").attr("action"), $(this).closest("form").serialize(), null, "script")
        return false
    $("#part_type_id").change ->
        $.get($(this).attr('rel') + '/' + $(this).val(), null, null, "script")
        return false
