# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
    $(document).on "click", "#parts .pagination a", ->
        $.getScript(this.href);
        return false
    $("#parts_search input").keyup $.debounce 1000, ->
        $.get($("#parts_search").attr("action"), $("#parts_search").serialize(), null, "script")
        return false
    $("#part_search_brand_id, #part_search_type_id").change ->
        $.get($("#parts_search").attr("action"), $("#parts_search").serialize(), null, "script")
        return false
    $(document).on "submit", "#page-num-form", ->
        s = $("#parts_search").serialize() + '&' + $(this).serialize()
        s += ('&' + $('#checkbox-urlinfo').prop('name') + '=1') if $('#checkbox-urlinfo').is(':checked')
        $.get($("#parts_search").attr("action"), s, null, "script")
        return false
    $(document).on "submit", "#parts_search", ->
        return false
    $(document).on "click", "#checkbox-urlinfo", ->
        s = $("#parts_search").serialize() + '&' + $("#page-num-form").serialize()
        s += ('&' + $(this).prop('name') + '=1') if $(this).is(':checked')
        $.get($("#parts_search").attr("action"), s, null, "script")
    $(document).on "change", "#part_match_brand_id", ->
        s = 'brand_id=' + $(this).val() + '&type_id=' + $("#part-match-type").prop('value')
        $.get($(this).attr("rel"), s, null, "script")