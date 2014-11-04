# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->
    $("#part_part_brand_id").change ->
        $.getScript($(this).attr('rel') + '/' + $(this).val() + "?sh_id=" + ($("#storehouse_id").val() || "") )
        return false
    part_number_table = {}
    $('#part-number-search').typeahead
        minLength: 3
        source: (query, process) ->
            return $.getJSON $('#part-number-search').data('link'),
                {search: query},
                (data) ->
                    part_number_table = {}
                    newData = []
                    $.each data, ->
                        newData.push(this.number)
                        part_number_table[this.number] = this._id
                    return process(newData)
        matcher: (item) ->
            return true
        highlighter: (item) ->
            return '<strong>' + item + '</strong>'
        updater: (item) ->
            $.get('/parts/' + part_number_table[item] + "?sh_id=" + ($("#storehouse_id").val() || ""), null, null, "script")
            return item