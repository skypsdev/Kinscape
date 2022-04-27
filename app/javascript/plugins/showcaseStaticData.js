import { delay } from "@/utils/functions"

export const communitiesShowCaseConfig = (that) => ({
    doneBtnText: that.$i18n.t('showcase.control.doneBtnText'),
    allowClose: false,
    nextBtnText: that.$i18n.t('showcase.control.nextBtnText'),
    prevBtnText: that.$i18n.t('showcase.control.prevBtnText'),
})

export const communitiesShowCaseData = (Driver, that) => ([
    {
        element: '#intro-communities-list-of-communities',
        popover: {
            title: that.$i18n.t('showcase.communities.listOfCommunitiesTitle'),
            description: that.$i18n.t('showcase.communities.listOfCommunitiesDescription')
        }
    },
    {
        element: '#intro-communities-new-community',
        popover: {
            title: that.$i18n.t('showcase.communities.newCommunityTitle'),
            description: that.$i18n.t('showcase.communities.newCommunityDescription'),
            position: 'bottom-right'
        },
        async onNext(Element) {
            // prevent double click
            if (Driver.lockClick) return Driver.preventMove()

            Driver
                .onNext(Element)
                .preventMove()

            // redirect to specific community
            const communityId = document.querySelectorAll('[data-community-id]')[0].getAttribute('data-community-id')
            localStorage.setItem('tour-community', communityId)

            that.$router.push({ name: 'showFamily', params: { id: communityId } })

            await delay(2000)

            Driver
                .refreshSteps()
                .continue()
        }
    },
    {
        element: '#intro-communities-community-profile-1',
        popover: {
            title: that.$i18n.t('showcase.communities.communityProfile1Title'),
            description: that.$i18n.t('showcase.communities.communityProfile1Description')
        },
        async onPrevious(Element) {
            // prevent double click
            if (Driver.lockClick) return Driver.preventMove()

            Driver
                .onPrev(Element)
                .preventMove()

            localStorage.setItem('fromPreviousTourStep', true)
            that.$router.push({ name: 'communities' })

            await delay(2000)

            Driver
                .refreshSteps()
                .continue()
        }
    },
    {
        element: '#intro-communities-community-profile-2',
        popover: {
            title: ' ',
            description: that.$i18n.t('showcase.communities.communityProfile1Description')
        },
    },
    {
        element: '#intro-communities-community-members',
        popover: {
            title: that.$i18n.t('showcase.communities.communityMembersTitle'),
            description: that.$i18n.t('showcase.communities.communityMembersDescription')
        }
    },
    {
        element: '#intro-communities-community-invitations',
        popover: {
            title: that.$i18n.t('showcase.communities.communityInvitationsTitle'),
            description: that.$i18n.t('showcase.communities.communityInvitationsDescription'),
            position: 'bottom-right'
        }

    },
    {
        element: '#intro-communities-community-vault',
        popover: {
            title: that.$i18n.t('showcase.communities.communityVaultTitle'),
            description: that.$i18n.t('showcase.communities.communityVaultDescription'),
            position: 'bottom-right'
        },
        onNext() {
            that.$router.push({ name: 'stories' })
        }
    },
])

/* -------------------------------------------------------------------------- */
/*                              STORIES DATA                             */
/* -------------------------------------------------------------------------- */

export const storiesShowCaseConfig = (that) => ({
    doneBtnText: that.$i18n.t('showcase.stories.doneBtnText'),
    allowClose: false,
    nextBtnText: that.$i18n.t('showcase.control.nextBtnText'),
    prevBtnText: that.$i18n.t('showcase.control.prevBtnText'),
    onReset() {
        localStorage.removeItem('fromPreviousTourStep')
    }
})

export const storiesShowCaseData = (Driver, that) => ([
    {
        element: '#intro-stories-list-of-stories',
        popover: {
            title: ' ',
            description: ' '
        }
    },
    {
        element: '#intro-stories-list-of-stories',
        popover: {
            title: that.$i18n.t('showcase.stories.listOfStoriesTitle'),
            description: that.$i18n.t('showcase.stories.listOfStoriesDescription')
        },
        async onPrevious() {
            // is used to check if should load dummy data inside community
            localStorage.setItem('fromStoryTourStep', true)

            const communityId = localStorage.getItem('tour-community')
            that.$router.push({ name: 'showFamily', params: { id: communityId } })
            that.$driver.setDefaultValues()
        }
    },
    {
        element: '#intro-stories-filter-stories',
        popover: {
            title: that.$i18n.t('showcase.stories.filterStoriesTitle'),
            description: that.$i18n.t('showcase.stories.filterStoriesDescription')
        }
    },
    {
        element: '#intro-stories-new-story',
        popover: {
            title: that.$i18n.t('showcase.stories.startNewStoriesTitle'),
            description: that.$i18n.t('showcase.stories.startNewStoriesDescription'),
            position: 'bottom-right'
        },
        async onNext(Element) {
            // prevent double click
            if (Driver.lockClick) return Driver.preventMove()

            Driver
                .onNext(Element)
                .preventMove()

            const divs = document.querySelectorAll(".story-title");
            const searchText = "weekend sailing with jackie";
            let storyId;
            for (const div of divs) {
                if (div.textContent.toLowerCase().includes(searchText)) {
                    storyId = div.getAttribute('data-story-id')
                    break;
                }
            }
            localStorage.setItem('tour-stories', storyId)
            that.$router.push({ name: 'showStory', params: { id: storyId } })

            await delay(3000)

            Driver
                .refreshSteps()
                .continue()
        }
    },
    {
        element: '#intro-stories-view-story',
        popover: {
            title: " ",
            description: that.$i18n.t('showcase.stories.viewStoryDescription')
        },
        async onPrevious(Element) {
            // prevent double click
            if (Driver.lockClick) return Driver.preventMove()

            Driver
                .onPrev(Element)
                .preventMove()

            that.$router.push({ name: 'stories' })
            localStorage.setItem('fromPreviousTourStep', true)

            await delay(2000)

            Driver
                .refreshSteps()
                .continue()
        },
        onNext() {
            that.$router.push({ name: 'myProfile' })
        }
    },
])

/* ------------------------------ MY LIFE DATA ------------------------------ */
export const myLifeShowCaseConfig = (that) => ({
    doneBtnText: that.$i18n.t('showcase.my_life.doneBtnText'),
    allowClose: false,
    nextBtnText: that.$i18n.t('showcase.control.nextBtnText'),
    prevBtnText: that.$i18n.t('showcase.control.prevBtnText'),
    onReset() {
        localStorage.removeItem('fromPreviousTourStep')
    }
})

export const myLifeShowCaseData = (Driver, that) => ([
    // this empty is here to allow to add onPrevious() for next screen
    {
        element: '#intro-my-life-list-dummy-slide',
        popover: {
            title: ' ',
            description: ' '
        }
    },

    {
        element: '#intro-my-life-list-of-my-life',
        popover: {
            title: that.$i18n.t('showcase.my_life.listOfMyLifeTitle'),
            description: that.$i18n.t('showcase.my_life.listOfMyLifeDescription')
        },
        async onPrevious() {
            // is used to check if should load dummy data inside community
            localStorage.setItem('fromMyLifeTourStep', true)

            const storyId = localStorage.getItem('tour-stories')
            that.$router.push({ name: 'showStory', params: { id: storyId } })

            that.$driver.setDefaultValues()
        },
    },
    {
        element: '#intro-my-life-my-profile',
        popover: {
            title: that.$i18n.t('showcase.my_life.listOfMyLifeTitle'),
            description: that.$i18n.t('showcase.my_life.listOfMyLifeDescription')
        },
    },

    {
        element: '#intro-my-life-switch-profiles',
        popover: {
            title: that.$i18n.t('showcase.my_life.switchProfileTitle'),
            description: that.$i18n.t('showcase.my_life.switchProfileDescription')
        },
        async onNext(Element) {
            // prevent double click
            if (Driver.lockClick) return Driver.preventMove()

            Driver
                .onNext(Element)
                .preventMove()

            that.$router.push({ name: "myPeople" })

            await delay(2000)

            Driver
                .refreshSteps()
                .continue()
        },
    },

    {
        element: '#intro-my-life-my-people',
        popover: {
            title: that.$i18n.t('showcase.my_life.myPeopleTitle'),
            description: that.$i18n.t('showcase.my_life.myPeopleDescription'),
            position: 'bottom-right'
        },
        async onPrevious(Element) {
            // prevent double click
            if (Driver.lockClick) return Driver.preventMove()

            Driver
                .onPrev(Element)
                .preventMove()

            localStorage.setItem('fromPreviousTourStep', true)
            that.$router.push({ name: "myProfile" })

            await delay(2000)

            Driver
                .refreshSteps()
                .continue()
        },
        async onNext(Element) {
            // prevent double click
            if (Driver.lockClick) return Driver.preventMove()

            Driver
                .onNext(Element)
                .preventMove()

            that.$router.push({ name: "myInvitations" })

            await delay(2000)

            Driver
                .refreshSteps()
                .continue()
        },
    },
    {
        element: '#intro-my-life-my-invitations',
        popover: {
            title: that.$i18n.t('showcase.my_life.myInvitationsTitle'),
            description: that.$i18n.t('showcase.my_life.myInvitationsDescription'),
            position: 'bottom-right'
        },
        async onPrevious(Element) {
            // prevent double click
            if (Driver.lockClick) return Driver.preventMove()

            Driver
                .onPrev(Element)
                .preventMove()

            that.$router.push({ name: "myPeople" })

            await delay(2000)

            Driver
                .refreshSteps()
                .continue()
        },
        async onNext(Element) {
            // prevent double click
            if (Driver.lockClick) return Driver.preventMove()

            Driver
                .onNext(Element)
                .preventMove()

            that.$router.push({ name: "MyVault" })

            await delay(2000)

            Driver
                .refreshSteps()
                .continue()
        },
    },
    {
        element: '#intro-my-life-my-vault',
        popover: {
            title:that.$i18n.t('showcase.my_life.myVaultTitle'),
            description: that.$i18n.t('showcase.my_life.myVaultDescription')
        },
        async onPrevious(Element) {
            // prevent double click
            if (Driver.lockClick) return Driver.preventMove()

            Driver
                .onPrev(Element)
                .preventMove()

            that.$router.push({ name: "myInvitations" })

            await delay(2000)

            Driver
                .refreshSteps()
                .continue()
        },
        async onNext() {
            localStorage.removeItem('tour')
            that.$router.push({ name: 'communities' })
        },
    },
])