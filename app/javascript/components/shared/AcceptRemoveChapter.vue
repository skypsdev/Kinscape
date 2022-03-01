<template>
  <div class="remove-section-wrapper">
    <div class="prompt">
      {{ $i18n.t('placeholders.section.remove') }}
    </div>
    <div class="actions">
      <button
        class="btn-cancel hoverBlue"
        @click="$emit('cancelDelete')"
      >
        {{ $i18n.t('placeholders.section.remove_deny') }}
      </button>
      <button
        class="btn-cancel bgRed"
        @click="$emit('deleteChapter')"
      >
        {{ $i18n.t('placeholders.section.remove_approve') }}
      </button>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  .remove-section-wrapper{
    background: rgba(255, 217, 217, 0.75);
    border: 4px solid #ff6a6a;
    border-radius: 10px;
    bottom: 0;
    left: 0;
    margin-top: 89px;
    min-height: 175px;
    padding-top: 40px;
    position: absolute;
    right: 0;
    text-align: center;
    top: 0;
    z-index: 20;
  }
  .prompt{
    margin-top: 45px;
  }
  .hoverBlue:hover{
    background-color: #8B78FE !important;
    color:  white !important;
  }
  .bgRed {
    background-color: tomato !important;
    color:  white !important;
  }
  .bgRed:hover {
    background-color: #ff8484 !important;
    color:  white !important;
  }
  .btn-cancel {
    transition: all .15s linear;
    border-radius: 3px;
    border: 1px solid #8c98a8;
    display: inline-block;
    font-weight: 300;
    letter-spacing: 1px;
    line-height: normal;
    text-align: center;
    text-transform: none;
    cursor: pointer;
    padding: 0.4em;
    color: #8c98a8;
    background: white;
  }
  .btn-cancel:hover {
    background: #8B78FE;
    border-color: #4527fd;
    color: #fff;
  }
</style>
