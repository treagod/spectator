<template>
  <div>
    <navbar></navbar>
    <div class="section">
      <div class="container">
        <Nuxt />
      </div>
    </div>
    
    <sfooter></sfooter>
  </div>
</template>

<script lang="ts">
import Vue from "vue";
import Navbar from "@/components/Navbar.vue";
import Footer from "@/components/Footer.vue";
export default Vue.extend({
  components: {
    Navbar,
    Sfooter: Footer,
  },
});
</script>

<style>
@media screen and (max-width: 800px) {
  .title.is-1 {
    font-size: 2.65rem;
  }
}

* {
  font-family: "Noto Serif", "Droid Serif", serif !important;
}

.title {
  font-family: Inter, Raleway, Inter, "Open Sans", "Noto Sans", "Roboto", "Droid Sans", sans-serif !important;
}

.subtitle {
  font-family: Inter, Raleway, Inter, "Open Sans", "Noto Sans", "Roboto", "Droid Sans", sans-serif !important;
}

a {
  color: #668e2c;
}

a:hover {
  color: #4a4a4a;
}
</style>