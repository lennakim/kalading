# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->
    $(document).on "click", "#auto_submodels .pagination a", ->
        $.getScript(this.href)
        return false
    $("#auto_submodels_search input").keyup $.debounce 1000, ->
        $.get($("#auto_submodels_search").attr("action"), $("#auto_submodels_search").serialize(), null, "script")
        return false
    
    window.part_match_rules = ''
    parse_filter_data = (row, s, target) ->
        filters = ''
        row.find(s).children().each ->
            filters += $(this).text() + ";" if $(this).is("a")
            window.part_match_rules += $(this).prev().text() + ": " + $(this).children("span.tooltip-content").text() + "\r\n" if $(this).is("span.tooltip")
        target.val(filters)

    is_chrome = /chrom(e|ium)/.test(navigator.userAgent.toLowerCase());
    $("#ajax-message").text($("#chrome-not-used").text()) if !is_chrome
    $('#catalog-frame').load ->
        model_first_tds = $(this).contents().find("tr.model td:first-child")
        $.each model_first_tds, ->
            $(this).append($('<div class="copy-btn-div" style="display: none;"><button class="copy-btn">' + $("#copy-btn-text").text() + '</button></div>')).click ->
                $("#auto_submodel_engine_displacement").val($(this).parent().children("td:nth-child(2)").text())
                $("#auto_submodel_engine_model").val($(this).parent().children("td:nth-child(4)").html().replace(/<br>/g, ";"))
                window.part_match_rules = ''
                parse_filter_data $(this).parent(), "td:nth-child(6)", $("#hengst_oil_filter")
                parse_filter_data $(this).parent(), "td:nth-child(7)", $("#hengst_fuel_filter")
                parse_filter_data $(this).parent(), "td:nth-child(8)", $("#hengst_air_filter")
                parse_filter_data $(this).parent(), "td:nth-child(9)", $("#hengst_cabin_filter")

                $("#auto_submodel_match_rule").val(window.part_match_rules)
            $(this).parent().hover ->
                $(this).parent().find("div.copy-btn-div").hide()
                $(this).find("div.copy-btn-div").show()
    $("#submit-form-btn").click ->
        $("form").submit()
        return false