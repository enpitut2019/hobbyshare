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
