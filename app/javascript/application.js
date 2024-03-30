// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
// import "@hotwired/turbo-rails"
import Rails from "@rails/ujs"
import {Turbo} from "@hotwired/turbo-rails"

Turbo.start()
Rails.start()


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
