<template>
  <div id="app">
    <div class="section get-help">
      <div class="container">
        <div class="fact-box">
          <h4 class="date">{{ display_event.year }} {{ month }} {{ day }}</h4>
          <div class="loading" v-if="loading">Loading....</div>
          <div v-else>
            <h3 class="fact">{{ display_event.text }}</h3>
          </div>
        </div>
      </div>

      <input
        type="button"
        class="button-primary"
        value="What else?"
        @click="getQuote('curated')"
      />
      <input
        type="button"
        class="button-primary"
        value="Births"
        @click="getQuote('births')"
      />
      <input
        type="button"
        class="button-primary"
        value="Deaths"
        @click="getQuote('deaths')"
      />
      <input
        type="button"
        class="button-primary"
        value="Holidays"
        @click="getQuote('holidays')"
      />
      <input
        type="button"
        class="button-primary"
        value="Others"
        @click="getQuote('others')"
      />
    </div>
  </div>
</template>

<script>
import axios from "axios";
import moment from "moment";
import { ref } from "vue";
export default {
  setup() {
    const curated = ref([]);
    const notable_births = ref([]);
    const notable_deaths = ref([]);
    const other_events = ref([]);
    const fixed_holidays = ref([]);
    const display_event = ref("");
    const month = ref("");
    const day = ref("");
    const loading = ref(false);
    return {
      curated,
      notable_births,
      notable_deaths,
      other_events,
      fixed_holidays,
      display_event,
      month,
      day,
      loading,
    };
  },
  methods: {
    getUrl() {
      let today = new Date();
      let month = today.getMonth() + 1;
      let day = today.getDate();

      this.month = moment().format("MMMM");
      this.day = day;

      return `https://api.wikimedia.org/feed/v1/wikipedia/en/onthisday/all/${month}/${day}`;
    },

    async populate_events() {
      let url = this.getUrl();
      const response = await axios.get(url);

      response.data.selected.forEach((event) => {
        this.curated.push(event);
      });

      response.data.births.forEach((event) => {
        this.notable_births.push(event);
      });
      response.data.deaths.forEach((event) => {
        this.notable_deaths.push(event);
      });
      response.data.events.forEach((event) => {
        this.other_events.push(event);
      });
      response.data.holidays.forEach((event) => {
        this.fixed_holidays.push(event);
      });
    },

    async getQuote(btn_type) {
      this.loading = true;
      switch (btn_type) {
        case "births":
          this.display_event =
            this.notable_births[
              Math.floor(Math.random() * this.notable_births.length)
            ];
          break;
        case "deaths":
          this.display_event =
            this.notable_deaths[
              Math.floor(Math.random() * this.notable_deaths.length)
            ];
          break;
        case "holidays":
          this.display_event =
            this.fixed_holidays[
              Math.floor(Math.random() * this.fixed_holidays.length)
            ];
          break;
        case "others":
          this.display_event =
            this.other_events[
              Math.floor(Math.random() * this.other_events.length)
            ];
          break;
        default:
          this.display_event =
            this.curated[Math.floor(Math.random() * this.curated.length)];
      }
      this.loading = false;
    },
  },

  async mounted() {
    await this.populate_events();
    await this.getQuote();
  },
};
</script>

<style>
.button {
  border-radius: 100px;
}

.section {
  padding: 8rem 0 7rem;
  text-align: center;
}
.section-heading,
.section-description {
  margin-bottom: 1.2rem;
}

.container {
  border: 5px solid rgb(74, 73, 73);
  border-radius: 5px;
}

.fact-box {
  padding: 20px;
}

input[type="button"].button-primary {
  margin-top: 20px;
  margin-right: 10px;
  background-color: rgb(74, 73, 73) !important;
  border-color: rgb(41, 31, 31) !important;
}
input[type="button"].button-primary:hover {
  background-color: rgb(0, 0, 0) !important;
}
input[type="button"].button-primary:active {
  background-color: rgb(35, 52, 35) !important;
}
</style>
