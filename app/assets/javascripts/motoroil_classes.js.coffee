# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->
    $('#btn-move-up').click ->
        t = $('#motoroil_group_part_ids option:selected')
        if t.length
            t.first().prev().before(t)

    $('#btn-move-down').click ->
        t = $('#motoroil_group_part_ids option:selected')
        if t.length
            t.last().next().after(t)

    $('#btn-move-right').click ->
        $('#motoroil_part_ids option:selected').appendTo('#motoroil_group_part_ids')

    $('#btn-move-left').click ->
        $('#motoroil_group_part_ids option:selected').appendTo('#motoroil_part_ids')
        
    $('.form-for-motoroil-group').submit ->
        # html form only submit selected options to server
        $('#motoroil_group_part_ids option').prop 'selected', true