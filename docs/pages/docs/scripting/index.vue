<template>
  <getting-started-base category-name="Scripting" page-name="Scripting Introduction">
    <div class="has-text-centered">
      <h1 class="title is-1">Scripting Introduction</h1>
    </div>

    <nuxt-content id="doc-content" :document="introduction" />
  </getting-started-base>
</template>

<script lang="ts">
import Vue from "vue";
import Base from "@/components/Base.vue";

export default Vue.extend({
  components: {
    GettingStartedBase: Base,
  },
  head() {
    return {
      title: "Spectator - Scripting Introduction",
      meta: [
        {
          hid: "description",
          name: "description",
          content: "Introduction to scripting with JavaScript inside Spectator",
        },
      ],
    };
  },
  async asyncData({ $content, params }) {
    const introduction = await $content(
      "scripting/introduction"
    ).fetch();

    return { introduction };
  },
});
</script>

<style>
#doc-content .subtitle {
  margin-top: 0.75em;
}
</style>
