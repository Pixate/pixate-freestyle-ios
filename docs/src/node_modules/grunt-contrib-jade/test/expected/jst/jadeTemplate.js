this["JST"] = this["JST"] || {};

this["JST"]["jadeTemplate"] = function anonymous(locals) {
var buf = [];
var locals_ = (locals || {}),year = locals_.year;buf.push("<div>" + (jade.escape(null == (jade.interp = year) ? "" : jade.interp)) + "</div>");;return buf.join("");
};