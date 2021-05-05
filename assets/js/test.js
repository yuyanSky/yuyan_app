

document.querySelectorAll('img[src]')
	.forEach(function (item) {
		console.log(item);
		item.onclick = function () {
			window.flutter_inappwebview.callHandler('showImage', item.outerHTML);
		};
	});