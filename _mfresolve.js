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
                // They have several download_links on their page, but the user sees (and clicks)
                // only the one with the largest z-index. The other download_link are fake! So we
                // need to find the one with the largest z-index
                var largestZIndex = 0;
                var result = "";
                for (i = 0; i < list.length; i++) {
                    var x = list[i];
                    if(  x.parentNode.className == 'download_link'
                      && x.parentNode.style.zIndex >= largestZIndex
                      ) {
                       result = x.href;
                       largestZIndex = x.parentNode.style.zIndex;
                    }
                }
                return result;
            });
            if (url != "") {
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
