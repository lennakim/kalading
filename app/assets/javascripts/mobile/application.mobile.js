// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require jquery.validate
//= require jquery.validate.additional-methods
//= require jquery.ba-throttle-debounce.min
//= require autos
//= require jquery_nested_form
//= require jquery.mobile

$(document).bind('pageinit', function() {
    $(document.body).delegate("form[action='/users/sign_out']",'submit',function(e){
        //$(this).attr("data-ajax", "false");
    });
   
    $("#refresh-btn").click(function() {
        $.get($(this).attr('href') + "?mobilejs=1", null, null, "script");
        return false;
    });
    
    $("#refresh-page-btn").click(function() {
        location.reload(true);
        return false;
    });
    
    
    $("#new_order").validate({
        errorPlacement: function(error, element) {
            if (element.is('select')) {
                error.insertAfter(element.parents('div.ui-select'));
            } else if (element.is('input')) {
                error.css("color", "#FF0000");
                error.insertAfter(element.parents('div.ui-input-text'));
            } else {
                error.insertAfter(element);
            }
        }
    });
    
    $( "#new1_to_new2" ).click(function(e) {
        if(!$("#new_order").validate().element("input[name='order[car_num]']"))
            return false;
        return true;
    });

    $( "#new3_to_new4" ).click(function(e) {
        if(!$("#new_order").validate().element("input[name='order[phone_num]']") ||
           !$("#new_order").validate().element("input[name='order[address]']") )
            return false;
        return true;
    });

    $( "button[type='submit']" ).click(function(e) {
        if(!$("#new_order").validate().element("input[name='order[car_num]']")) {
            $.mobile.changePage("#page_new1", { transition: "slide", reverse: true, changeHash: true });
            return false;
        }
        if(!$("#new_order").validate().element("input[name='order[phone_num]']") ||
           !$("#new_order").validate().element("input[name='order[address]']") ) {
            $.mobile.changePage("#page_new3", { transition: "slide", reverse: true, changeHash: true });
            return false;
        }
        return true;
    });

    $( '#page_new3' ).on( 'pageshow',function(event, ui){
        ui.prevPage.each(function(i, p){
            if($(p).attr("id") == "page_new2") {
                $.get('/auto_parts?model=' + $("#order_auto_submodel_id").val(), null, null, "script");
                return false;
            }
            return true;
        });
        return false;
    });
    
    $("input[name='order[buymyself]']").click(function(e) {
        if ($("input[name='order[buymyself]']:checked").val() == "1")
            $("#parts").fadeOut();
        else
            $("#parts").fadeIn();
    });
});

