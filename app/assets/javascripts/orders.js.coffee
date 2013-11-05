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
    $('#select-parts table tr td input:checkbox').click ->
        checkedState =   $(this).prop("checked")
        $(this).closest('table').find('input:checkbox').prop("checked", false)
        $(this).prop("checked", checkedState)
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