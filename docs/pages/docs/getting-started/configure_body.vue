<template>
  <getting-started-base category-name="Getting Started" page-name="Configure the request body">
    <div class="has-text-centered">
      <h1 class="title is-1">Configure the request body</h1>
    </div>

    <nuxt-content id="doc-content" :document="configure_body" />

    <div class="columns is-vcentered has-text-centered">
      <div @click="previous " class="column is-narrow is-arrow">&lt;</div>
      <div class="column"><img :src="currentImage"/></div>
      <div @click="next" class="column is-narrow is-arrow">&gt;</div>
    </div>
  </getting-started-base>
</template>

<script lang="ts">
import Vue from "vue";
import Base from "@/components/Base.vue";

export default Vue.extend({
  components: {
    GettingStartedBase: Base,

  },
  data() {
    return {
      imgIndex : 0,
      imageSrcs: [
        "create_request/create_request.png",
        "create_request/create_request_dialog.png"
      ]
    }
  },
  methods: {
    getImgIndex () : number {
      return this.imgIndex;
    },
    getImgSrc(index : number) : string {
      return this.imageSrcs[index];
    },
    next() {
      let nextIdx = this.imgIndex + 1;
      if (nextIdx >= this.imageSrcs.length) {
        this.imgIndex = 0;
      } else {
        this.imgIndex = nextIdx;
      }
    },
    previous() {
      let previousIdx = this.imgIndex - 1;
      if (previousIdx < 0) {
        this.imgIndex = this.imageSrcs.length - 1;
      } else {
        this.imgIndex = previousIdx;
      }
    }
  },
  computed: {
    currentImage() : string {
      return this.getImgSrc(this.getImgIndex());
    }
  },
  head() {
    return {
      title: "Spectator - Configure Request Body",
      meta: [
        {
          hid: "description",
          name: "description",
          content: "Configure the request body of your REST request with Spectator",
        },
      ],
    };
  },
  async asyncData({ $content, params }) {
    const configure_body = await $content(
      "getting-started/configure_body"
    ).fetch();

    return { configure_body };
  },
});
</script>

<style>
#doc-content .subtitle {
  margin-top: 0.75em;
}

.is-arrow {
  font-weight: bold;
  font-size: 2rem;
  cursor: pointer;
  color: #668e2c;
}
</style>
