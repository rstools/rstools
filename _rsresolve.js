#!/usr/bin/env phantomjs

function run(rsURL) {
    var page = new WebPage();
    page.open(rsURL, wrappedOpenCallback());

    function openCallback(status) {
        if (status !== 'success') {
            console.log('Unable to access network!');
        } else {
            f = function() {
                var url = page.evaluate(function () {
                    return document.getElementById('js_dlpage_dlbtn').href;
                });
                console.log(url)
                phantom.exit();
            }
            setTimeout(f, 1000);
        }
    }

    // for some reason openCallback is called twice, and we are only interested in
    // the second call..
    function wrappedOpenCallback() {
        var i = 0;
        return function (status) {
            if (i++ == 1) {
                openCallback(status);
            }
        }
    }
}

if (phantom.args.length === 1) {
    run(phantom.args[0]);
} else {
    console.log('usage: ' + phantom.scriptName + ' <URL>');
    phantom.exit();
}
