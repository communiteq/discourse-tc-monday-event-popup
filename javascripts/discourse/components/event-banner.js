import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
const cookie = require("discourse/lib/cookie").default;
const { removeCookie } = require("discourse/lib/cookie")

let cookieExpDate = moment().add(1, 'year').toDate(); 

export default class EventBanner extends Component {

    @tracked closed = false;

    get showEventBanner() {  
        var closed_cookie = cookie("banner_closed");
        if (closed_cookie) {
            var cookieValue = JSON.parse(closed_cookie);
            if(cookieValue.name != settings.update_version) {
                removeCookie("banner_closed", {path: '/'} );
            } else {
                this.closed = true;
            }
        }

        return !this.closed;
    }
    get contentText() {
        return settings.content_text;
    }
    get buttonText() {
        return settings.button_text;
    }
    get buttonLink() {
        return settings.button_link;
    }

    @action
    closeBanner() {
        this.closed = true;
        let bannerState = { name: settings.update_version, closed: "true" };
        cookie("banner_closed", JSON.stringify(bannerState), { expires: cookieExpDate, path: '/' });
    }
}