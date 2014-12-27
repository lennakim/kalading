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
        $.getScript(this.href + '?discount=' + $("#order_discount_num").val()) if $("#order_discount_num").val().length > 0
        return false

    car_model_table = {}
    $('#car-model-search').typeahead
        source: (query, process) ->
            params = {query: query}
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
    $('a.serve-datetime-shortcut').click ->
        $('#serve_datetime_start').val($(this).data('msg'))
        $('#serve_datetime_end').val($(this).data('msg'))
    $('a.serve-datetime-clear').click ->
        $('#serve_datetime_start').val('')
        $('#serve_datetime_end').val('')
    $('a.created-at-shortcut').click ->
        $('#created_at_start').val($(this).data('msg'))
        $('#created_at_end').val($(this).data('msg'))
    $('a.created-at-clear').click ->
        $('#created_at_start').val('')
        $('#created_at_end').val('')
    $(".form_datetime").datetimepicker({pickTime: false, language: 'zh-CN'})
    $('.order-a').on 'dragstart', (evt) ->
        evt.originalEvent.dataTransfer.setData("text", evt.originalEvent.target.id)
    $('.engineer-tr, .unassigned-orders').on 'drop', (evt) ->
        evt.preventDefault()
        data = evt.originalEvent.dataTransfer.getData("text")
        evt.originalEvent.target.appendChild(document.getElementById(data))
    $('.engineer-tr, .unassigned-orders').on 'dragover', (evt) ->
        evt.preventDefault()

    $('.tooltip-div').tooltip {selector: "span[data-toggle=tooltip]"}
    $('#hsplitter').split(
        orientation: 'horizontal',
        limit: 10,
        position: '60%'
    )
    $('#vsplitter').split(
        orientation: 'vertical',
        limit: 10,
        position: '50%'
    )
    
    if $('#map').length > 0
        map = new BMap.Map("map")
        map.enableScrollWheelZoom()
        map.enableContinuousZoom()
        map.centerAndZoom (new BMap.Point(116.393773, 39.989387)), 12
        window.map = map
        $('.order-a').on 'click', ->
            m = window.order_marker_table[$(this).data('seq')]
            if m?
                map.centerAndZoom m.getPosition(), 13
                m.setAnimation BMAP_ANIMATION_DROP

        add_order_marker_points = (points) ->
            window.order_marker_table ||= {}
            for v in points
                # closure to prevent v from being shared
                do (v) ->
                    options = 
                        onSearchComplete: (results) ->
                            return if local_search.getStatus() != BMAP_STATUS_SUCCESS
                            for r in results when r.getCurrentNumPois() > 0
                                $('#mqm-' + v.seq).fadeOut()
                                $('#mm-' + v.seq).fadeIn()
                                label = new BMap.Label v.seq, {position: r.getPoi(0).point, offset:new BMap.Size(1,-7)}
                                label.setStyle(
                                  color : v.color,
                                  fontSize : "12px",
                                  height : "20px",
                                  lineHeight : "20px"
                                )
                                label.addEventListener "click", (type, target) ->
                                  prev = $('#order-' + v.seq).prev().prev()
                                  prev = $('#order-table') if prev.size() <= 0
                                  document.getElementById(prev.attr("id")).scrollIntoView()
                                  $('#modal-map').modal('hide')
                                label.addEventListener "mouseover", (type, target) ->
                                  this.setContent v.seq + ' ' + v.state + ': ' + v.address
                                  this.setZIndex 100
                                label.addEventListener "mouseout", (type, target) ->
                                  this.setContent(v.seq)
                                map.addOverlay(label)
                                marker = new BMap.Marker(r.getPoi(0).point)
                                marker.addEventListener "click", (type, target) ->
                                  prev = $('#order-' + v.seq).prev().prev()
                                  prev = $('#order-table') if prev.size() <= 0
                                  e = document.getElementById(prev.attr("id"))
                                  e.scrollIntoView() if e?
                                map.addOverlay(marker)
                                window.order_marker_table[v.seq] = marker
                                break
                    a = []
                    for i in [v.address.length..9] by -3
                        a[a.length] = v.address.substring 0, i
                    if a.length > 0
                        local_search = new BMap.LocalSearch(map, options)
                        local_search.search(a) 
        points = for tr in $('.unassigned-order-tr')
            seq: $(tr).find('a').data('seq')
            state: $(tr).data('state')
            address: $(tr).find('td:last-child').text()
            city: $(tr).data('city')
            color: 'blue'
        add_order_marker_points points
        points = for tr in $('.assigned-order-tr')
            seq: $(tr).find('a').data('seq')
            state: $(tr).data('state')
            address: $(tr).find('span:last-child').prop('title')
            city: $(tr).data('city')
            color: 'red'
        add_order_marker_points points