import "@hotwired/turbo-rails"
import "controllers"


// Know issue in widget, see https://github.com/uploadcare/uploadcare-rails/issues/134

document.addEventListener('turbo:before-cache', function() {
    const dialogClose = document.querySelector('.uploadcare--dialog__close');
    if (dialogClose) {
        dialogClose.dispatchEvent(new Event('click'));
    }

    const dialog = document.querySelector('.uploadcare--dialog');
    if (dialog) {
        dialog.remove();
    }

    const widgets = document.querySelectorAll('.uploadcare--widget');
    widgets.forEach(widget => {
        widget.remove();
    });
});
