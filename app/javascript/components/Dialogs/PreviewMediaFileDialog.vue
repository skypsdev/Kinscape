<template>
  <div class="media-dialog">
    <a
      class="media-dialog__close d-flex justify-center align-center"
      @click="closeDialog"
      href="javascript:void(0);"
    >
      <v-icon class="">mdi-close</v-icon>
    </a>

    <v-carousel
      :continuous="false"
      hideDelimiters
      v-model="model"
      height="auto"
    >
      <template v-slot:prev="{ on, attrs }">
        <a
          class="
            media-dialog__btn media-dialog__btn--left
            d-flex
            justify-center
            align-center
          "
          v-bind="attrs"
          @keyup.right="goNext"
          @keyup.left="goPrev"
          v-focus="focusedPrevBtn"
          :disabled="loadingState"
          href="javascript:void(0);"
          v-on="on"
        >
          <v-img
            :src="arrowImage"
            class="media-dialog__arrow media-dialog__arrow--left"
          />
        </a>
      </template>

      <template v-slot:next="{ on, attrs }">
        <a
          class="
            media-dialog__btn media-dialog__btn--right
            d-flex
            justify-center
            align-center
          "
          v-bind="attrs"
          v-focus="focusedNextBtn"
           :disabled="loadingState"
          @keyup.right="goNext"
          @keyup.left="goPrev"
          href="javascript:void(0);"
          v-on="on"
        >
          <v-img :src="arrowImage" class="media-dialog__arrow" />
        </a>
      </template>

      <v-carousel-item v-for="item in viewableItems" :key="item.id">
        <div
          class="d-flex justify-center align-center"
          :class="{
            'media-dialog__wrapper': checkContentType(
              'image',
              item.contentType
            ),
            'media-dialog__wrapper--audio': checkContentType(
              'audio',
              item.contentType
            ),
          }"
        >
          <img
            :key="`${model}-${item.id}`"
            v-if="checkContentType('image', item.contentType)"
            :src="item.url"
          />

          <audio
            :key="`${model}-${item.id}`"
            class="w--100"
            v-else-if="checkContentType('audio', item.contentType)"
            :src="item.url"
            controls
          />

          <video
            :key="`${model}-${item.id}`"
            v-else-if="checkContentType('video', item.contentType)"
            controls
          >
            <source :src="item.url" />
          </video>
        </div>
        <div
          class="media-dialog__caption"
          :class="
            checkContentType('audio', item.contentType) &&
            'media-dialog__caption--audio'
          "
        >
          <span :title="$$(item, 'attributes', 'name')">{{
            $$(item, "attributes", "name")
          }}</span>
        </div>
      </v-carousel-item>
    </v-carousel>
  </div>
</template>

<script>
  import { focus } from "vue-focus";
  import { mapActions, mapState } from "vuex";

  export function checkContentType(type, contentType) {
    const regex = new RegExp(type);
    return contentType?.match(regex);
  }

  function checkAllTypes(contentType) {
    return ["image", "audio", "video"].some((type) =>
      checkContentType(type, contentType)
    );
  }

  const get = (from, ...selectors) =>
  [...selectors].map(s =>
    s
      .replace(/\[([^[\]]*)]/g, '.$1.')
      .split('.')
      .filter(t => t !== '')
      .reduce((prev, cur) => prev && prev[cur], from)
  );

  export default {
    name: "PreviewMediaFileDialog",
    directives: { focus },
    data() {
      return {
        model: 0,
        loadingState: false,
        arrowImage: require("../../assets/images/arrow_right.svg")
      };
    },
      computed: {
        ...mapState({
          dialog: (state) => state.layout.dialog
        }),
        currentFileId() {
          return this.dialog.data?.file?.id || 0
        },
        currentViewable() {
          return this.viewableItems[this.model]
        },
        items(){
          const {itemsRef} = this.dialog.data
          return  get(this.$store, itemsRef)[0] || []
        },
        hasMoreData(){
          const {hasMoreDataRef} = this.dialog.data;
          const ref =   get(this.$store, hasMoreDataRef)[0]
  
          return typeof ref === 'function' ? ref():ref
        },
        viewableItems() {
          return this.items
            .map((obj) => ({ ...obj, ...obj.attributes }))
            .filter(({ contentType }) => checkAllTypes(contentType))
        },
        focusedPrevBtn() {
          return this.model == this.viewableItems.length - 1
        },
        focusedNextBtn() {
          return this.model != this.viewableItems.length - 1;
        },
      },
    watch: {
      model:'onSlideChange'
    },
    created() {
      this.prepareCurrentItem()
    },
    methods: {
      ...mapActions({
        closeDialog: "layout/closeDialog"
      }),
      checkContentType,
      isFileType(type) {
        return checkContentType(type, this.file.contentType)
      },
      prepareCurrentItem() {
        const index = this.viewableItems.findIndex(
          (item) => item.id == this.currentFileId
        )

        this.model = index
      },
      goNext() {
        if (this.model < this.viewableItems.length - 1) {
          this.model = this.model + 1
        }
      },
      goPrev() {
        if (this.model > 0) {
          this.model = this.model - 1
        }
      },
      async onSlideChange(slideIndex){
        const {loadMoreItems} = this.dialog.data

        // load more if is second item from end 
        if(this.hasMoreData && this.viewableItems.length - 2 === slideIndex){
        try {
          this.loadingState = true
          await  loadMoreItems()
        } finally {
          this.loadingState = false
          }
        }
      }
    },
  };
</script>
<style lang="scss">
$underDesktopBtn: 32px;
$upDesktopBtn: 64px;
$backgroundColor:#8b78fe;
$backgroundColorHover:#a293fe;

$underDesktopArrow: 20px;
$upDesktopArrow: 40px;
$arrowPosition: 37px;

$underDesktopClose: 20px;
$upDesktopClose: 40px;
$closeBg: #E75739;
$closeColor: #ffff;
$closeHoverBg: darken(#e75739, 5%);

$audioBg:#e8e4ff;
$captionBg:#e8e4ff;
$captionColor:#4b4b4b;
$captionAudioBg:#e8e4ff;
$captionAudioColor:#666666;


.media-dialog {
  position: relative;
  &__btn {
    position: fixed;
    @include mq("desktop", max) {
      height: $underDesktopBtn;
      width: $underDesktopBtn;
    }
    height: $upDesktopBtn;
    width: $upDesktopBtn;

    background: $backgroundColor;
    border-radius: 50%;
    &--right {
      right: $arrowPosition;
    }
    &--left {
      left: $arrowPosition;
    }
    &:hover {
      background-color: $backgroundColorHover;
    }
  }

  &__arrow {
    @include mq("desktop", "max") {
      height: $underDesktopArrow;
    }
    height: $upDesktopArrow;

    &--left {
      transform: rotate(-180deg);
    }
    .v-image__image {
      width: 19.45px;
      position: absolute;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
    }
  }

  &__close {
    display: block;
    position: absolute;
    @include mq("desktop", "max") {
      width: $underDesktopClose;
      height: $underDesktopClose;
    }
    top: -95px;
    right: 0px;
    border-radius: 50%;
    width: $upDesktopClose;
    height: $upDesktopClose;
    background: $closeBg;

    i {
      @include mq("desktop", "max") {
        font-size: 18px !important;
      }
      color: $closeColor !important;
    }
    &:hover {
      background-color: $closeHoverBg;
    }
  }

  &__wrapper {
    max-height: 50vh;
    max-width: 50vw;

    &--audio {
      background: $audioBg;
      padding: 17px 25px 00;
      min-width: 700px;
      border-radius: 9px 9px 0px 0px;
    }

    img {
      height: 100%;
      max-height: 50vh;
      max-width: 50vw;
      width: 100%;
    }
  }
  video {
    max-width: 50vw;
    height: 100%;
    width: 100%;
    source {
      max-width: 50vw;
    }
  }

  &__caption {
    width: 100%;
    padding: 12px;

    font-style: normal;
    font-weight: bold;
    font-size: 16px;
    line-height: 24px;

    text-align: center;

    background: $captionBg;
    color: $captionColor;

    // truncate
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;

    &--audio {
      background: $captionAudioBg;
      text-align: left;
      padding-left: 45px;
      color: $captionAudioColor;
    }
  }
}
.v-dialog {
  width: auto;
  overflow: visible !important;
  box-shadow: unset;
}
.v-carousel,
.v-carousel__item {
  height: auto;
}
.v-carousel {
  border-radius: 0px 0px 10px 10px;
  &--audion {
    border-radius: 9px;
  }
}
.v-window__container {
  width: 100%;
}
</style>
