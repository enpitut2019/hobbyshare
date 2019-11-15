// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require activestorage
// turbolinksは無効化
//= require_tree .
//= require bootstrap
//= require jquery
//= require popper

function clearFormAll() {
  for (var i=0; i<document.forms.length; ++i) {
      clearForm(document.forms[i]);
  }
}
function clearForm(form) {
  for(var i=0; i<form.elements.length; ++i) {
      clearElement(form.elements[i]);
  }
}
function clearElement(element) {
  switch(element.type) {
      case "hidden":
      case "submit":
      case "reset":
      case "button":
      case "image":
          return;
      case "file":
          return;
      case "text":
      case "password":
      case "textarea":
          element.value = "";
          return;
      case "checkbox":
      case "radio":
          element.checked = false;
          return;
      case "select-one":
      case "select-multiple":
          element.selectedIndex = 0;
          return;
      default:
  }
}
