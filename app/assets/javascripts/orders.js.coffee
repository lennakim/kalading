# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
    $("#new_order, form[id^=edit_order]").validate(
        rules:
            "order[service_type_ids][]":
                required: true
                minlength: 1
        errorPlacement:
            (error, element) ->
                error.css("color", "#FF0000")
                if element.is('input:checkbox')
                    error.insertAfter(element.parents('table'))
                else
                    error.insertAfter(element)
        messages:
            "order[service_type_ids][]":
                required: $('#service-type-at-least-one').text()
    )

    $(document).on "click", '#select-parts table tr td input:checkbox', ->
        if !$(this).data('multisel')
            $(this).closest('table').find('input:checkbox').not(this).prop("checked", false)
        $.post $("#calcprice-btn").prop('href'), $("#calcprice-btn").parents("form").serialize(), null, "script"

    $(document).on "click", '#select-service-types table tr td input:checkbox', ->
        $.post $("#calcprice-btn").prop('href'), $("#calcprice-btn").parents("form").serialize(), null, "script"

    $(document).on 'keyup input', "input[name^='order[part_counts]']", $.debounce 1000, ->
        $.post $("#calcprice-btn").prop('href'), $("#calcprice-btn").parents("form").serialize(), null, "script"
    
    $("#order_auto_submodel_id").change ->
        $.getScript($(this).attr('rel') + '/' + $(this).val())
    $("#search-by-car-num").click ->
        $.getScript(this.href + "?car_location=" + $("#select-car-location").val() + "&car_num=" + $("#order_car_num").val() ) if $("#order_car_num").val().length > 0
        return false
    $("#search-by-phone-num").click ->
        $.getScript(this.href + "?phone_num=" + $("#order_phone_num").val() ) if $("#order_phone_num").val().length > 0
        return false
    $("#calcprice-btn").click ->
        $.post this.href, $(this).parents("form").serialize(), null, "script"
        return false
    $("#verify-discount-num-btn").click ->
        $.getScript(this.href + '/' + $("#order_discount_num").val()) if $("#order_discount_num").val().length > 0
        return false

    car_model_table = {}
    $('#car-model-search').typeahead
        source: (query, process) ->
            params = {query: query}
            params[$('#checkbox-data-source').prop('name')] = 1 if $('#checkbox-data-source').is(':checked')
            return $.getJSON $('#car-model-search').data('link'),
                params,
                (data) ->
                    car_model_table = {}
                    newData = []
                    $.each data, ->
                        newData.push(this.full_name)
                        car_model_table[this.full_name] = this._id
                    return process(newData)
        matcher: (item) ->
            return true
        highlighter: (item) ->
            return '<strong>' + item + '</strong>'
        updater: (item) ->
            $.get('/auto_submodels/' + car_model_table[item], null, null, "script")
            return item
        items: 16
    $('a.datetime-shortcut').click ->
        $('#order_serve_datetime').val($(this).data('msg'))
