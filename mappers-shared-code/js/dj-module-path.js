// Allows loading the api from a CDN and local modules from the correct location.

var package_path = window.location.pathname.substring(0, window.location.pathname.lastIndexOf('/'));
var dojoConfig = {
    packages: [{
        name: "application",
        location: package_path + '../../mappers-shared-code/js'
    }]
};