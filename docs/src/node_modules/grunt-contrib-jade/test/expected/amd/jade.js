define(['jade'], function(jade) { if(jade && jade['runtime'] !== undefined) { jade = jade.runtime; }

return function anonymous(locals) {
var buf = [];
var locals_ = (locals || {}),test = locals_.test;buf.push("<div id=\"test\" class=\"test\"><span id=\"data\">data</span>");
if ( test)
{
buf.push("<div>testing</div>");
}
buf.push("</div>");;return buf.join("");
}

});