<template>
  <getting-started-base page-name="Create your first collection">
    <div class="has-text-centered">
      <h1 class="title is-1">Create your first collection</h1>
    </div>

    <nuxt-content id="doc-content" :document="collection" />
  </getting-started-base>
</template>

<script lang="ts">
import Vue from "vue";
import Base from "@/components/getting_started/Base.vue";

export default Vue.extend({
  components: {
    GettingStartedBase: Base,
  },
  head() {
    return {
      title: "Spectator - Create Request Collections",
      meta: [
        {
          hid: "description",
          name: "description",
          content: "Create a collection to categorize your REST requests with Spectator",
        },
      ],
    };
  },
  async asyncData({ $content, params }) {
    const collection = await $content(
      "getting-started/collection"
    ).fetch();

    return { collection };
  },
});
</script>

<style>
#doc-content .subtitle {
  margin-top: 0.75em;
}
</style>
