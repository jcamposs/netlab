// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require kinetic
//= require neteditor/netlab
//= require neteditor/desktop/kwidgets
//= require neteditor/desktop/editor
//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require gdrivestrg
//= require_tree .

$(document).ready(function (){
  // Remove flash messages
  setTimeout("$('.alert').remove()", 5000);
  
  // Initialization tooltips
  $("a[rel=tooltip]").tooltip();
  $("a[rel=nofollow]").tooltip();
  
  // Initialization file inputs
  $('input[type=file]').bootstrapFileInput();
  $('.file-inputs').bootstrapFileInput();
  
  //Check if togetherjs is initiated
  setTimeout('check_chat_started()', 3000);
  
  $('#alert-notifications').toggleClass('in');
  
  // Remove alert notifications
  setTimeout("$('#alert-notifications').remove()", 5000);
});

function check_chat_started() {
  if ($("#togetherjs-container").length){
    $('#btn-chat').val("1");
    $('#btn-text-chat').addClass("label label-success");
    $('#btn-text-chat').html("Online");
  }  
}

function switchChat(){
  if ($("#togetherjs-container").length){
    $('#btn-chat').val("0");
    $('#btn-text-chat').removeClass();
    $('#btn-text-chat').addClass("label");
    $('#btn-text-chat').html("Offline");
  } else {
    $('#btn-chat').val("1");
    $('#btn-text-chat').addClass("label label-success");
    $('#btn-text-chat').html("Online");
  }
}
