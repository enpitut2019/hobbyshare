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

function subcheck() {
  if (window.confirm('本当に削除しますか')) {
    return true;
  } else {
    //window.alert('キャンセルされました'); // 警告ダイアログの表示は要らなそう
    return false; // 送信を中止
  }
}
function subcheck_name(a) {
  if (window.confirm(a + 'を本当に削除しますか')) {
    return true;
  } else {
    //window.alert('キャンセルされました'); // 警告ダイアログの表示は要らなそう
    return false; // 送信を中止
  }
}

function subcheck_regist() {
  if (window.confirm('本当に登録しますか')) {
    return true;
  } else {
    //window.alert('キャンセルされました'); // 警告ダイアログの表示は要らなそう
    return false; // 送信を中止
  }
}

//アカウントマイページ、お気に入り趣味用
function ac_subcheck(a,b) {
  if (window.confirm(a +':' + b + 'に趣味をコピーしますか？')) {

    return true;
  } else {
    //window.alert('キャンセルされました'); // 警告ダイアログの表示は要らなそう
    return false; // 送信を中止
  }
}

// 趣味の表記揺れ対策登録隠しフォーム
function entrySimilarHobby(index){
  if(document.getElementById('regist_hidden'+index).style.display == "none") {
    document.getElementById('regist_hidden'+index).style.display = "";
  }else{
    document.getElementById('regist_hidden'+index).style.display = "none";
  }
}

function textarea_select(){
    //テキストエリアをフォーカスする
    document.form.textarea.focus();
    //テキストエリアを全選択する
    document.form.textarea.select();
}

// listのuser_intro隠しフォーム
function entryUserIntro(index){
  if(document.getElementById('intro_hidden'+index).style.display == "none") {
    document.getElementById('intro_hidden'+index).style.display = "";
  }else{
    document.getElementById('intro_hidden'+index).style.display = "none";
  }
}

/*\
|*| ========================================================================
|*| Bootstrap Toggle: bootstrap4-toggle.js v3.6.1
|*| https://gitbrent.github.io/bootstrap4-toggle/
|*| ========================================================================
|*| Copyright 2018-2019 Brent Ely
|*| Licensed under MIT
|*| ========================================================================
\*/
!function(a){"use strict";function l(t,e){this.$element=a(t),this.options=a.extend({},this.defaults(),e),this.render()}l.VERSION="3.6.0",l.DEFAULTS={on:"On",off:"Off",onstyle:"primary",offstyle:"light",size:"normal",style:"",width:null,height:null},l.prototype.defaults=function(){return{on:this.$element.attr("data-on")||l.DEFAULTS.on,off:this.$element.attr("data-off")||l.DEFAULTS.off,onstyle:this.$element.attr("data-onstyle")||l.DEFAULTS.onstyle,offstyle:this.$element.attr("data-offstyle")||l.DEFAULTS.offstyle,size:this.$element.attr("data-size")||l.DEFAULTS.size,style:this.$element.attr("data-style")||l.DEFAULTS.style,width:this.$element.attr("data-width")||l.DEFAULTS.width,height:this.$element.attr("data-height")||l.DEFAULTS.height}},l.prototype.render=function(){this._onstyle="btn-"+this.options.onstyle,this._offstyle="btn-"+this.options.offstyle;var t="large"===this.options.size||"lg"===this.options.size?"btn-lg":"small"===this.options.size||"sm"===this.options.size?"btn-sm":"mini"===this.options.size||"xs"===this.options.size?"btn-xs":"",e=a('<label for="'+this.$element.prop("id")+'" class="btn">').html(this.options.on).addClass(this._onstyle+" "+t),s=a('<label for="'+this.$element.prop("id")+'" class="btn">').html(this.options.off).addClass(this._offstyle+" "+t),o=a('<span class="toggle-handle btn btn-light">').addClass(t),i=a('<div class="toggle-group">').append(e,s,o),l=a('<div class="toggle btn" data-toggle="toggle" role="button">').addClass(this.$element.prop("checked")?this._onstyle:this._offstyle+" off").addClass(t).addClass(this.options.style);this.$element.wrap(l),a.extend(this,{$toggle:this.$element.parent(),$toggleOn:e,$toggleOff:s,$toggleGroup:i}),this.$toggle.append(i);var n=this.options.width||Math.max(e.outerWidth(),s.outerWidth())+o.outerWidth()/2,h=this.options.height||Math.max(e.outerHeight(),s.outerHeight());e.addClass("toggle-on"),s.addClass("toggle-off"),this.$toggle.css({width:n,height:h}),this.options.height&&(e.css("line-height",e.height()+"px"),s.css("line-height",s.height()+"px")),this.update(!0),this.trigger(!0)},l.prototype.toggle=function(){this.$element.prop("checked")?this.off():this.on()},l.prototype.on=function(t){if(this.$element.prop("disabled"))return!1;this.$toggle.removeClass(this._offstyle+" off").addClass(this._onstyle),this.$element.prop("checked",!0),t||this.trigger()},l.prototype.off=function(t){if(this.$element.prop("disabled"))return!1;this.$toggle.removeClass(this._onstyle).addClass(this._offstyle+" off"),this.$element.prop("checked",!1),t||this.trigger()},l.prototype.enable=function(){this.$toggle.removeClass("disabled"),this.$toggle.removeAttr("disabled"),this.$element.prop("disabled",!1)},l.prototype.disable=function(){this.$toggle.addClass("disabled"),this.$toggle.attr("disabled","disabled"),this.$element.prop("disabled",!0)},l.prototype.update=function(t){this.$element.prop("disabled")?this.disable():this.enable(),this.$element.prop("checked")?this.on(t):this.off(t)},l.prototype.trigger=function(t){this.$element.off("change.bs.toggle"),t||this.$element.change(),this.$element.on("change.bs.toggle",a.proxy(function(){this.update()},this))},l.prototype.destroy=function(){this.$element.off("change.bs.toggle"),this.$toggleGroup.remove(),this.$element.removeData("bs.toggle"),this.$element.unwrap()};var t=a.fn.bootstrapToggle;a.fn.bootstrapToggle=function(o){var i=Array.prototype.slice.call(arguments,1)[0];return this.each(function(){var t=a(this),e=t.data("bs.toggle"),s="object"==typeof o&&o;e||t.data("bs.toggle",e=new l(this,s)),"string"==typeof o&&e[o]&&"boolean"==typeof i?e[o](i):"string"==typeof o&&e[o]&&e[o]()})},a.fn.bootstrapToggle.Constructor=l,a.fn.toggle.noConflict=function(){return a.fn.bootstrapToggle=t,this},a(function(){a("input[type=checkbox][data-toggle^=toggle]").bootstrapToggle()}),a(document).on("click.bs.toggle","div[data-toggle^=toggle]",function(t){a(this).find("input[type=checkbox]").bootstrapToggle("toggle"),t.preventDefault()})}(jQuery);
//# sourceMappingURL=bootstrap4-toggle.min.js.map
