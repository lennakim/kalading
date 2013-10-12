# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->
    $(document).on "click", "#autos .pagination a", ->
        $.getScript(this.href);
        return false
    $("#autos_search input").keyup ->
        $.get($("#autos_search").attr("action"), $("#autos_search").serialize(), null, "script")
        return false
    $("#auto_model_brand_id, #auto_submodel_model_id").change ->
        $.get($(this).attr('rel') + '/' + $(this).val(), null, null, "script")
        return false
