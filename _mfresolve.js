#!/usr/bin/env phantomjs

function run(mfURL) {
    var page = new WebPage();
    page.open(mfURL, openCallback);

    function openCallback(status) {
        if (status !== 'success') {
            console.log('Unable to access network!');
        } else {
            var url = page.evaluate(function () {
                var list = document.getElementsByTagName('a');
                for (i = 0; i < list.length; i++) {
                    var x = list[i];
                    if (x.parentNode.style.display == 'block') {
                        return x.href;
                    }
                }
                return null;
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
