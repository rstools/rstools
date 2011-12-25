#!/usr/bin/env phantomjs

function run(url) {
    var page = new WebPage();
    page.open(url, openCallback);

    function openCallback(status) {
        if (status !== 'success') {
            console.log('Unable to access network!');
        } else {
            var url = page.evaluate(function () {
                return document.getElementById('dlbutton').href;
            });
            if (url != null) {
                console.log(url);
                phantom.exit();
            } else {
                console.log('Download link not found!');
                phantom.exit(1);
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
