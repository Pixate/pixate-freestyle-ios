define(['jade'], function(jade) { if(jade && jade['runtime'] !== undefined) { jade = jade.runtime; }

return function anonymous(locals) {
var buf = [];
buf.push("<html><head><title>TEST</title></head><body></body></html>");
var a = 'hello jade test'
buf.push("<p>" + (jade.escape(null == (jade.interp = a) ? "" : jade.interp)) + "</p>");;return buf.join("");
}

});