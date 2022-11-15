<template>
  <div id="app">
    <div class="section get-help">
      <div class="container">
        <div class="fact-box">
          <h4 class="date">November 15</h4>
          <div class="loading" v-if="loading">Loading....</div>
          <div v-else>
            <h3 class="fact">{{ quote }}</h3>
            <h3 class="author">{{ author }}</h3>
          </div>
        </div>
      </div>
      <input
        type="button"
        class="button-primary"
        value="What else?"
        @click="getQuote"
      />
    </div>
  </div>
</template>

<script>
import axios from "axios";
import { ref } from "vue";
export default {
  setup() {
    const quote = ref("");
    const author = ref("");
    const loading = ref(false);
    return {
      quote,
      author,
      loading,
    };
  },
  methods: {
    async getQuote() {
      this.loading = true;
      const response = await axios.get("https://favqs.com/api/qotd");
      this.quote = response.data.quote.body;
      this.author = response.data.quote.author;
      this.loading = false;
    },
  },

  async mounted() {
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
