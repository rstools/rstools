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
                if (url != null && url.indexOf('http') == 0) {
                    console.log(url);
                    phantom.exit();
                } else {
                    var err = page.evaluate(function () {
                        return document.getElementById('js_downloaderror').innerHTML;
                    });
                    if (err === null || err === "") {
                        setTimeout(f, 100);
                    } else {
                        console.log(err);
                        phantom.exit(1);
                    }
                }
            }
            setTimeout(f, 500);
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
    phantom.exit(1);
}
