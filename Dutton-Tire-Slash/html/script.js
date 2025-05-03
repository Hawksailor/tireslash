window.addEventListener('message', function(event) {
    if (event.data.action === 'show') {
        document.getElementById('slashUI').style.display = "block";
        document.querySelector('.progress').style.animation = "loading 3s linear forwards";
    } else if (event.data.action === 'hide') {
        document.getElementById('slashUI').style.display = "none";
        document.querySelector('.progress').style.animation = "none";
    }
});
