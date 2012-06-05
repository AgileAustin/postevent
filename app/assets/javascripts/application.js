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
//= require jquery
//= require jquery_ujs
//= require_tree .

//Restrict to integers and control keys (delete, backspace, etc.) only.
//To use, add class enforceIntegersOnly on the input field.
function enforceIntegersOnly(e) {
	return enforceKeysOnly(e, /[0123456789]/);
}

// Restrict to numbers and control keys (delete, backspace, etc.) only.
// To use, put onkeypress="return enforceKeysOnly(event, <regular expression>)" on the input field.
function enforceKeysOnly(e, regex) {
	var keynum = window.event ? e.keyCode : e.which;  // First case for IE; second for others
	return keynum == 0 || keynum == 8 || regex.test(String.fromCharCode(keynum));
}

function focusField(fieldName) {
	window.onload = function(){
		var text_input = document.getElementById(fieldName);
		text_input.focus();
		text_input.select();
	}
}