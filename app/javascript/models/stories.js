class Story {
  constructor(story = {}) {
    this.id = story.id || null
    this.title = story.attributes?.title || ''
    this.description = story.attributes?.description || ''
    this.categories =  story.attributes?.categories || []
    this.dateAsText =  story.attributes?.dateAsText || ''
    this.endDateAsText = story.attributes?.endDateAsText || ''
    this.createdAt = story.attributes?.createdAt || null
    this.updatedAt = story.attributes?.updatedAt || null
    this.startYear = story.attributes?.startYear || null
    this.startMonth = story.attributes?.startMonth || null
    this.startDay = story.attributes?.startDay || null
    this.endYear = story.attributes?.endYear || null
    this.endMonth = story.attributes?.endMonth || null
    this.endDay = story.attributes?.endDay || null
    this.isRange = story.attributes?.isRange || false

    this.isPublished = story.attributes?.published || false
    this.isTimeCapsule = story.attributes?.isTimeCapsule || false
    this.publicationId = story.relationships?.publications?.data[0]?.id || null

    this.appreciationsCount = story.attributes?.appreciationsCount || 0
    this.appreciation = story.attributes?.appreciation || null

    this.isChanged = false
    this.isLoading = false
    this.chapterAdded = ''

    this.publication = story.publication || {}
    this.publications = story.publications || []

    this.content = {
      cover: story.attributes?.coverUrl || null,
      links: story.attributes?.links || [],
      chapters: []
    }

    this.community = {
      id: story.family?.id || undefined,
      name: story.family?.attributes?.name || '',
      connectorId: story.family?.attributes?.connectorId || null,
    }
    this.communities = story.families || []

    this.comments = story.relationships?.comments?.data || []

    this.userId = story.attributes?.userId
    this.user = {
      ...story.user?.attributes || null,
      id: story.user?.id || null,
      firstName: story.attributes?.firstName || null,
      lastName: story.attributes?.lastName || null
    }

  }
}

export {
  Story
}
