import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { later, cancel } from '@ember/runloop';
const cookie = require("discourse/lib/cookie").default;
const { removeCookie } = require("discourse/lib/cookie")
import { on } from "@ember/modifier";
import { inject as service } from "@ember/service";

let cookieExpDate = moment().add(1, 'year').toDate();

export default class EventPopup extends Component {
  @service router;
  @service site;
  @tracked closed = false;

  @tracked days = '0';
  @tracked hours = '00';
  @tracked minutes = '00';
  @tracked seconds = '00';
  countdownInterval = null;

  constructor() {
    super(...arguments);
    this.setupCountdown();
  }

  setupCountdown() {
    if (settings.countdown_to != "") {
      this.startCountdown();
    }
  }

  parseDate(dateString) {
    try {
      const [datePart, timePart] = dateString.split(' ');
      const [year, month, day] = datePart.split('-').map(Number);
      const [hours, minutes] = timePart.split(':').map(Number);
      return new Date(Date.UTC(year, month - 1, day, hours, minutes));
    }
    catch (e) {
      console.log("Event popup: error parsing date/time " + dateString);
      return new Date;
    }
  }

  startCountdown() {
    const targetDate = this.parseDate(settings.countdown_to);

    const updateCountdown = () => {
      const now = new Date();
      const timeDifference = targetDate - now;
      if (timeDifference <= 0) {
        this.days = '0';
        this.hours = '00';
        this.minutes = '00';
        this.seconds = '00';
        if (this.countdownInterval) {
          cancel(this.countdownInterval);
        }
        return;
      }

      const days = Math.floor(timeDifference / (1000 * 60 * 60 * 24));
      const hours = Math.floor((timeDifference % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
      const minutes = Math.floor((timeDifference % (1000 * 60 * 60)) / (1000 * 60));
      const seconds = Math.floor((timeDifference % (1000 * 60)) / 1000);

      this.days = days > 0 ? days.toString() : '0';
      this.hours = hours.toString().padStart(2, '0');
      this.minutes = minutes.toString().padStart(2, '0');
      this.seconds = seconds.toString().padStart(2, '0');

      this.countdownInterval = later(this, updateCountdown, 1000);
    };

    updateCountdown();
  }

  willDestroy() {
    super.willDestroy(...arguments);
    if (this.countdownInterval) {
      cancel(this.countdownInterval);
    }
  }

  get showCountdown() {
    return (settings.countdown_to != "");
  }

  get divStyle() {
    var style = "";
    if (this.site.mobileView) {
      style += settings.popup_width_mobile ? `width: ${settings.popup_width_mobile}px; ` : '';
      style += settings.popup_height_mobile ? `height: ${settings.popup_height_mobile}px; ` : '';
      style += settings.background_image_mobile_url ? `background-image: url(${settings.background_image_mobile_url});` : '';
    } else {
      style += settings.popup_width_desktop ? `width: ${settings.popup_width_desktop}px; ` : '';
      style += settings.popup_height_desktop ? `height: ${settings.popup_height_desktop}px; ` : '';
      style += settings.background_image_desktop_url ? `background-image: url(${settings.background_image_desktop_url});` : '';
    }
    return style;
  }

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
      <div class="event-popup-div" style={{this.divStyle}}>
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

        {{#if this.showCountdown}}
        <div class="countdown-timer">
          <div class="countdown-elements">
            <div class="days">{{this.days}}</div>
            <div class="hours">{{this.hours}}</div>
            <div class="minutes">{{this.minutes}}</div>
            <div class="seconds">{{this.seconds}}</div>
          </div>
        </div>
        {{/if}}
      </div>
    {{/if}}
  </template>
}