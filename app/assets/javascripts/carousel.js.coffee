class Carousel
  constructor: ->
    @initialSliderIndex = 2
    @glideContainer = $('#glide')
    @glideContentItems = $('#glide-content').find('.glide-content__item')
    @showContentItem @initialSliderIndex
    @initCarousel()

  initCarousel: ->
    @glideContainer.glide
      type:'slider'
      startAt: @initialSliderIndex
      paddings: '27%'
      autoheight: true
      centered: true
      animationDuration: 300
      afterInit: @onAfterInit
      beforeTransition: @onBeforeTransition
      afterTransition: @onAfterTransition

  showContentItem: (index) ->
    @glideContentItems
      .eq(index - 1)
      .addClass('glide-content__item--active')

  onAfterInit: =>
    @glideContainer.removeClass 'glide--inactive'

  onBeforeTransition: =>
    @glideContentItems.removeClass 'glide-content__item--active'

  onAfterTransition: (evt) => @showContentItem evt.index

$ ->
  new Carousel
