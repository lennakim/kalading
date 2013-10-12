// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
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
    
    
 });