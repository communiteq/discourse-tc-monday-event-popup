import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
const cookie = require("discourse/lib/cookie").default;
const { removeCookie } = require("discourse/lib/cookie")
import { on } from "@ember/modifier";
import { inject as service } from "@ember/service";

let cookieExpDate = moment().add(1, 'year').toDate();

export default class EventPopup extends Component {
  @service router;
  @tracked closed = false;

  get showEventBanner() {
    let allowedRoutes = ['discovery', 'tags'];
    if (!settings.popup_enabled) {
      return false;
    }
    if (!allowedRoutes.includes(this.router.currentRoute.name.split('.')[0])) {
      return false;
    }

    var closed_cookie = cookie("event_popup_closed");
    if (closed_cookie) {
      var cookieValue = JSON.parse(closed_cookie);
      if(cookieValue.name != settings.update_version) {
        removeCookie("event_popup_closed", {path: '/'} );
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
  closePopup() {
    this.closed = true;
    let bannerState = { name: settings.update_version, closed: "true" };
    cookie("event_popup_closed", JSON.stringify(bannerState), { expires: cookieExpDate, path: '/' });
  }

  <template>
    {{#if this.showEventBanner}}
      <div class="event-popup-div">
        <div class="wrapper">
          <div class="event-popup-content">
            <div class="content-text">
              {{this.contentText}}
            </div>
            <a class="cta-button" href="{{this.buttonLink}}">
              {{this.buttonText}}
            </a>
          </div>
          <div class="event-popup-close">
            <a class="button" {{on "click" this.closePopup}}>
              <svg class="fa d-icon d-icon-times svg-icon svg-node" aria-hidden="true"><use xlink:href="#times"></use></svg>
            </a>
          </div>
        </div>
      </div>
    {{/if}}
  </template>
}