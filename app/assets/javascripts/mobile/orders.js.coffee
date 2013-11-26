# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).on 'mobileinit', ->
    $.mobile.pageLoadErrorMessage = '';

$(document).on 'pageinit', ->
    $("span.first-letter-nav").click ->
        $('html,body').animate 
            scrollTop: $($(this).data('target')).offset().top,
            500
    
    $("#refresh-btn").click ->
        $.get($(this).attr('href') + "?mobilejs=1", null, null, "script");
        e.preventDefault
    
    $("#refresh-page-btn").click (e)->
        location.reload(true)
        e.preventDefault

    $("#123").click ->
        $("#new_order").validate
            rules:
                "order[service_type_ids][]":
                    required: true
                    minlength: 1
            errorPlacement: (error, element) ->
                error.css("color", "#FF0000")
                if element.is('select')
                    error.insertAfter(element.parents('div.ui-select'))
                else if element.is('input:checkbox')
                    error.insertAfter(element.parents('div.ui-controlgroup-controls'))
                else if element.is('input')
                    error.insertAfter(element.parents('div.ui-input-text'))
                else
                    error.insertAfter(element)
            messages:
                "order[service_type_ids][]":
                    required: $('#service-type-at-least-one').text()

    $("#auto-brand-list").listview
        autodividers: true,
        autodividersSelector: (li) ->
            return li.attr('pinyin')
    .listview('refresh');

    $('input[name^="order[reciept_type]"]').click ->
        console.log($(this).prop("checked"))
        if $(this).attr('id') == 'order_reciept_type_0'
            $('div.order_reciept_title').fadeOut()
        else
            $('div.order_reciept_title').fadeIn()
    
    $("#order_discount_num").on 'input', $.debounce 2000, ->
        if $(this).val().length == 24
            $.get($(this).attr('rel') + '?discount=' + $(this).val(), null, null, "script")
    
    $(document).ajaxSend (event, request, settings) ->
        $('.loading-indicator').show()
    
    $(document).ajaxComplete (event, request, settings) ->
        $('.loading-indicator').hide()

$(document).on 'pageloadfailed', (e, d) ->
    $("#popup-text").text(d.xhr.responseText)
    $("#popupDialog").popup().popup("open")