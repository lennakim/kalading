# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->
    $(document).on "click", "#autos .pagination a", ->
        $.getScript(this.href);
        return false

    $("#autos_search input").keyup $.debounce 1000, ->
        $.get($("#autos_search").attr("action"), $("#autos_search").serialize(), null, "script")
        return false

    $("#auto_model_brand_id, #auto_submodel_model_id, #auto_auto_model, #service_type_auto_brand_id").change ->
        $.get($(this).attr('rel') + '/' + $(this).val() + '?data_source=' + $(this).data('source'), null, null, "script")

    $(document).ajaxSend (event, request, settings) ->
        $('.loading-indicator').show()
        $('#progress-dialog').modal('toggle')
    
    $(document).ajaxComplete (event, request, settings) ->
        $('.loading-indicator').hide()
        $('#progress-dialog').modal('toggle')