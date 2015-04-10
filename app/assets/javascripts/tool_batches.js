$(function() {
  var detail_search_result = {}

  // 搜索工具信息库
  $('#tool_detail_search').typeahead({
    minLength: 2
  , source: function(query, process) {
      var $tool_supplier_id = $('#tool_supplier_id')

      $tool_supplier_id.css('border-color', '#cccccc')
      $('#tool_detail_search').parent().find('.text-error').remove()

      if ($tool_supplier_id.val() == '') {
        $tool_supplier_id.css('border-color', '#b94a48')
        $('#tool_detail_search').parent().prepend('<p class="text-error">请选择供应商</p>')
        return
      }

      return $.getJSON('/tool_details', {search: query, tool_supplier_id: $tool_supplier_id.val()}, function(data) {
        detail_search_result = {}
        var items = $.map(data, function(v) {
          var item = v['identification']
          detail_search_result[item] = v
          return item
        })
        return process(items)
      })
    }
  , matcher: function(item) {
      return true
    }
  , updater: function(item) {
      $('#tool_detail_search').data('tool_detail', detail_search_result[item])
      return item
    }
  })

  // 添加一条进货信息
  $('#add_tool_batch_item').on('click', function() {
    var tool_detail = $('#tool_detail_search').data('tool_detail')
    , blueprint = $($('#tool_batch_item_blueprint').data('blueprint'))
    , target = $('#tool_detail_items')

    blueprint.find('input.tool_detail_id').val(tool_detail._id)
    blueprint.find('td.tool_type').text(tool_detail.tool_type.identification)
    blueprint.find('td.tool_brand').text(tool_detail.tool_brand.name)
    blueprint.find('td.lifetime input').val(tool_detail.lifetime)
    blueprint.find('td.warranty_period input').val(tool_detail.warranty_period)
    blueprint.find('td.price input').val(tool_detail.price_to_f)
    target.append(blueprint)

    $('#tool_detail_search').removeData('tool_detail').val('')
  })

  // 删除一条进货信息
  $('#tool_detail_items').on('click', ' a.remove_tool_batch_item', function() {
    $(this).closest('tr').remove()
  })
})
