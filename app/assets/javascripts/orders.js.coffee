#encoding: UTF-8
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
        evt.originalEvent.dataTransfer.setData("text", $(evt.originalEvent.target).closest('tr').attr('id'))

    $('.engineer-tr, .unassigned-orders, .daily-order-tr').on 'dragover', (evt) ->
        evt.preventDefault()

    assign_order_to_engineer = (order_tr, engineer_tr, old_engineer_tr) ->
        # console.log order_tr.data('seq') + '  ' + old_engineer_tr.find('strong').text() + ' -> ' + engineer_tr.find('strong').text()
        return if old_engineer_tr? and old_engineer_tr.is(engineer_tr)
        $.ajax
            url: '/orders/' + order_tr.attr('id')
            type: 'PUT'
            contentType: 'application/json'
            data: JSON.stringify({state: 3, engineer_id: engineer_tr.attr('id')})
            dataType: 'json'
            success: ->
                # 保证订单按照服务时间排序，找到合适的位置，插入订单
                tr = engineer_tr.next('tr')
                while tr.hasClass('daily-order-tr') and tr.children('td.order-time').text() < order_tr.children('td.order-time').text()
                    tr = tr.next('tr')
                if old_engineer_tr.get(0)?
                    b = $(old_engineer_tr.find('.badge'))
                    b.text(parseInt(b.text()) - 1).fadeOut().fadeIn() if b?
                order_tr.insertBefore(tr)
                b = engineer_tr.find('.badge')
                b.text(parseInt(b.text()) + 1).fadeOut().fadeIn() if b?
                order_tr.data('label').setStyle({color: 'grey', opacity: 0.5, borderStyle: 'dotted' })
                order_tr.data('label').setZIndex 9
            error: ->
                alert 'Network error.'
    
    # 拖拽到技师tr上，可能是换技师，也可能是分配新订单
    $('.engineer-tr').on 'drop', (evt) ->
        evt.preventDefault()
        order_tr = document.getElementById(evt.originalEvent.dataTransfer.getData("text"))
        return if !order_tr? or !$(order_tr).hasClass('daily-order-tr')
        old_engineer_tr = $($(order_tr).prevAll('tr.engineer-tr')[0])
        assign_order_to_engineer $(order_tr), $(this), old_engineer_tr

    $('.daily-order-tr').on 'drop', (evt) ->
        evt.preventDefault()
        order_tr = document.getElementById(evt.originalEvent.dataTransfer.getData("text"))
        return if !order_tr? or !$(order_tr).hasClass('daily-order-tr')
        if !$(this).closest('table').hasClass('unassigned-orders')
            # 换技师，也可能是分配新订单
            engineer_tr = $($(this).prevAll('tr.engineer-tr')[0])
            old_engineer_tr = $($(order_tr).prevAll('tr.engineer-tr')[0])
            assign_order_to_engineer $(order_tr), engineer_tr, old_engineer_tr

    # 如果从已分配table拖拽到未分配table，是取消分配
    $('.unassigned-orders').on 'drop', (evt) ->
        evt.preventDefault()
        order_tr = document.getElementById(evt.originalEvent.dataTransfer.getData("text"))
        return if !order_tr? or !$(order_tr).hasClass('daily-order-tr')
        return if $(order_tr).closest('table').hasClass('unassigned-orders')
        # console.log '取消分配 ' + $(order_tr).data('seq')
        $.ajax
            url: '/orders/' + $(order_tr).attr('id')
            type: 'PUT'
            contentType: 'application/json'
            data: JSON.stringify({state: 2})
            dataType: 'json'
            success: =>
                old_engineer_tr = $($(order_tr).prevAll('tr.engineer-tr')[0])
                if old_engineer_tr.get(0)?
                    b = old_engineer_tr.find('.badge')
                    b.text(parseInt(b.text()) - 1).fadeOut().fadeIn() if b?
                if !make_order_tr_close_to_dianbu $(order_tr)
                    $(order_tr).insertAfter($('tr.city-tr[data-name=\'' + $(order_tr).data('city') + '\']')[0])
                $(order_tr).data('label').setStyle({color: 'red', opacity: 1.0, borderStyle: 'solid' })
                $(order_tr).data('label').setZIndex 10
            error: ->
                alert 'Network error.'

    $('.tooltip-parent').tooltip {selector: "span[data-toggle=tooltip]"}
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
            m = $(this).closest('tr').data('marker')
            if m?
                map.centerAndZoom m.getPosition(), 13
                m.setAnimation(BMAP_ANIMATION_BOUNCE)
                window.animate_mark.setAnimation(null) if window.animate_mark?
                window.animate_mark = m

        $('.dianbu-a').on 'click', ->
            d = $('#' + $(this).closest('tr').data('id'))
            if d?
                point = new BMap.Point parseFloat(d.data('lng')), parseFloat(d.data('lat'))
                map.centerAndZoom point, 13

        add_dianbu_mark = (point, name, id, city) ->
            circle1 = new BMap.Circle point, 300, {fillColor: "blue", fillOpacity: 1.0}
            map.addOverlay(circle1)
            circle2 = new BMap.Circle point, 5000, {fillColor: "red", fillOpacity: 0.1, strokeColor:"blue", strokeWeight:1, strokeOpacity:0.1}
            map.addOverlay(circle2)
            label = new BMap.Label name, {position: point, offset:new BMap.Size(-5,1)}
            label.setStyle(
              color : 'white',
              backgroundColor: 'black'
              fontSize : "10px",
              height : "12px",
              lineHeight : "12px"
            )
            label.addEventListener "click", (type, target) ->
                e.scrollIntoView() for e in $('tr[data-id=\'' + id + '\']').get()
            map.addOverlay(label)
            
        for li in $('.dianbu-li') when $(li).text()
            do (li) ->
                if $(li).data('lng')
                    # 从后端获得经纬度
                    point = new BMap.Point parseFloat($(li).data('lng')), parseFloat($(li).data('lat'))
                    add_dianbu_mark point, $(li).data('name'), li.id, $(li).data('city')
                else
                    options = 
                        onSearchComplete: (results) ->
                            return if local_search.getStatus() != BMAP_STATUS_SUCCESS
                            for r in results when r.getCurrentNumPois() > 0
                                add_dianbu_mark r.getPoi(0).point, $(li).data('name'), li.id, $(li).data('city')
                                $(li).data('lng', r.getPoi(0).point.lng).data('lat', r.getPoi(0).point.lat)
                                break
                    local_search = new BMap.LocalSearch($(li).data('city'), options)
                    local_search.search([$(li).text()])
        
        # 计算两点之间的距离，单位为米。输入参数为两个经纬度数组
        haversine_distance = ( lng_lat1, lng_lat2 ) ->
            RAD_PER_DEG = 0.017453293  #  PI/180
            Rkm = 6371              # radius in kilometers...some algorithms use 6367
            Rmeters = Rkm * 1000    # radius in meters
            dlon = lng_lat2[0] - lng_lat1[0]
            dlat = lng_lat2[1] - lng_lat1[1]
            dlon_rad = dlon * RAD_PER_DEG
            dlat_rad = dlat * RAD_PER_DEG
            lat1_rad = lng_lat1[1] * RAD_PER_DEG
            lat2_rad = lng_lat2[1] * RAD_PER_DEG
            a = (Math.sin(dlat_rad/2))**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * (Math.sin(dlon_rad/2))**2
            c = 2 * Math.atan2( Math.sqrt(a), Math.sqrt(1-a))
            Math.round(Rmeters * c)

        # 将未分配订单按照最近的点部（100公里内）分组
        make_order_tr_close_to_dianbu = (tr) ->
            max_dis = 100 * 1000.0
            dianbu_tr = null
            for li in $('.dianbu-li') when $(li).data('lng') and tr.data('city') == $(li).data('city') 
                dis = haversine_distance [ tr.data('marker').getPosition().lng, tr.data('marker').getPosition().lat], [parseFloat($(li).data('lng')), parseFloat($(li).data('lat'))]
                # console.log tr.data('seq') + ' -- ' + $(li).data('name') + ': ' + dis + '米'
                if dis < max_dis
                    max_dis = dis
                    dianbu_tr = $('tr.dianbu-tr[data-id=\'' + li.id + '\']')[0]
            if dianbu_tr
                tr.insertAfter dianbu_tr
        add_order_marker_points = (points) ->
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
                                  color : 'red',
                                  fontSize : "10px",
                                  height : "15px",
                                  lineHeight : "14px"
                                )
                                label.setZIndex 10
                                label.addEventListener "click", (type, target) ->
                                  document.getElementById(v.id)?.scrollIntoView()
                                  $('#modal-map').modal('hide')
                                label.addEventListener "mouseover", (type, target) ->
                                  this.setContent v.seq + ' ' + v.state + ': ' + v.address
                                label.addEventListener "mouseout", (type, target) ->
                                  this.setContent(v.seq)
                                map.addOverlay(label)
                                marker = new BMap.Marker(r.getPoi(0).point)
                                marker.addEventListener "click", (type, target) ->
                                  document.getElementById(v.id)?.scrollIntoView()
                                map.addOverlay(marker)
                                $('#' + v.id).data 'marker', marker
                                $('#' + v.id).data 'label', label
                                if $('#' + v.id).closest('table').hasClass('unassigned-orders')
                                    make_order_tr_close_to_dianbu $('#' + v.id)
                                else
                                    # 已分配的置灰
                                    if $('#' + v.id).hasClass('daily-order-tr')
                                        label.setStyle({color: 'grey', opacity: 0.5, borderStyle: 'dotted' })
                                        label.setZIndex 9
                                break
                    a =  for i in [v.address.length..9] by -3
                        v.address.substring 0, i
                    local_search = new BMap.LocalSearch(v.city, options)
                    local_search.search(a)
        points = for tr in $('.daily-order-tr').get().reverse() when $(tr).find('td:last-child').text()
            seq: $(tr).data('seq')
            state: $(tr).data('state')
            address: $(tr).find('td:last-child').text()
            city: $(tr).data('city')
            id: tr.id
        add_order_marker_points points
        points = for tr in $('.order-tr') when $(tr).children('td.order-address').text() and $(tr).find('span.order-state').data('state') in [0, 2, 3, 4]
            seq: $(tr).children('td:first-child').text()
            state: $(tr).find('span.order-state').text()
            address: $(tr).children('td.order-address').text()
            city: $(tr).data('city')
            id: tr.id
        add_order_marker_points points
    
        if $('#order_address').length > 0
            locate_order_address = ->
                t = $('#order_address').val()
                return if !t || t.length < 4
                map = window.map
                map.clearOverlays()
                options = 
                    onSearchComplete: (results) ->
                        return if address_search1.getStatus() != BMAP_STATUS_SUCCESS
                        for i in [0..(results.getCurrentNumPois() - 1)]
                            p = results.getPoi(i).point
                            circle1 = new BMap.Circle p, 100, {fillColor: "red", fillOpacity: 1.0}
                            map.addOverlay(circle1)
                            label = new BMap.Label t, {position: p, offset: new BMap.Size(-15,10)}
                            label.setStyle(
                              color : 'white',
                              backgroundColor: 'black'
                              fontSize : "10px",
                              height : "12px",
                              lineHeight : "12px"
                            )
                            map.addOverlay(label)
                            marker = new BMap.Marker p
                            map.addOverlay marker
                            marker.setAnimation BMAP_ANIMATION_BOUNCE
                            map.centerAndZoom p, 12
        
                            new BMap.Geocoder().getLocation p, (rs) ->
                                $("#district-select option").filter ->
                                    return $(this).text() == rs.addressComponents.district
                                .prop 'selected', true
                            break
                address_search1 = new BMap.LocalSearch $("option:selected", $('#order_city_id')).text(), options
                address_search1.search t
    
            $('#modal-map').on 'show', ->
                locate_order_address()
            locate_order_address()
            $("#district-select").change ->
                $('#order_address').val $("option:selected", $('#order_city_id')).text() + $("option:selected", $(this)).text()
            $("#order_city_id").change ->
                $.getScript "/cities/" + $(this).val()
        
            old_value = $('#order_address').val()
            ac_address = new BMap.Autocomplete(
                "input" : "order_address"
                "location" : window.map
            )
            ac_address.setInputValue old_value
            $(ac_address).on "onconfirm", (e) ->
                $("#order_city_id option").filter ->
                    return $(this).text() == e.originalEvent.item.value.city
                .prop 'selected', true
                $("#district-select option").filter ->
                    return $(this).text() == e.originalEvent.item.value.district
                .prop 'selected', true
        
        
