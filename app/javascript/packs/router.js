import Vue from 'vue'
import Router from 'vue-router'

Vue.use(Router)

export default new Router({
  mode: 'history',
  base: process.env.BASE_URL,
  linkActiveClass: 'active',
  routes: [
    {
      name: 'invitation',
      path: '/invitations/:id',
      components: {
        default: () =>
          import(/* webpackChunkName: "stories" */ '../views/Stories/Stories'),
        toolbar: () =>
          import(
            /* webpackChunkName: "stories" */ '../components/Toolbars/StoriesHeader'
          )
      }
    },
    {
      path: '/communityInfo',
      name: 'familyInfo',
      components: {
        default: () => import(/* webpackChunkName: "account" */ '../views/Communities/FamilyInfo'),
      },
      meta: { hideToolbar: true }
    },
    {
      path: '/ownership',
      name: 'ownership',
      component: import(
        /* webpackChunkName: "account" */ '../components/families/ownership'
      ),
      meta: { hideToolbar: true }
    },
    {
      path: '/communities',
      name: 'communities',
      components: {
        default: () =>
          import(
            /* webpackChunkName: "communities" */ '../views/Communities/Communities'
          ),
        toolbar: () =>
          import(
            /* webpackChunkName: "communities" */ '../components/Toolbars/CommunitiesHeader'
          )
      }
    },
    {
      path: '/communities/:id',
      name: 'showFamily',
      components: {
        default: () =>
          import(
            /* webpackChunkName: "community" */ '../views/Communities/Community'
          ),
        toolbar: () =>
          import(
            /* webpackChunkName: "community" */ '../components/Toolbars/CommunityHeader'
          )
      }
    },
    {
      path: '/communities/:id/edit',
      name: 'community',
      components: {
        default: () =>
          import(
            /* webpackChunkName: "community" */ '../views/Communities/CommunityEdit'
          ),
        toolbar: () =>
          import(
            /* webpackChunkName: "community" */ '../components/Toolbars/CommunityHeader'
          )
      }
    },
    {
      path: '/communities/:id/members',
      name: 'members',
      components: {
        default: () =>
          import(
            /* webpackChunkName: "community" */ '../views/Communities/CommunityMembers'
          ),
        toolbar: () =>
          import(
            /* webpackChunkName: "community" */ '../components/Toolbars/CommunityHeader'
          )
      },
      props: {
        default: { reqType: 'defaults' }
      }
    },
    {
      path: '/communities/:id/invitations',
      name: 'invitedMembers',
      components: {
        default: () =>
          import(
            /* webpackChunkName: "community" */ '../views/Communities/CommunityMembers'
          ),
        toolbar: () =>
          import(
            /* webpackChunkName: "community" */ '../components/Toolbars/CommunityHeader'
          )
      },
      props: {
        default: { reqType: 'invited' }
      }
    },
    {
      path: '/communities/:id/vault',
      name: 'communityVault',
      components: {
        default: () =>
          import(
            /* webpackChunkName: "community" */ '../views/Communities/CommunityVault'
          ),
        toolbar: () =>
          import(
            /* webpackChunkName: "community" */ '../components/Toolbars/CommunityVaultHeader'
          )
      },
      props: {
        default: { reqType: 'invited' }
      }
    },
    {
      path: '/communities/:id/box/:boxId',
      name: 'CommunityBoxVault',
      components: {
        default: () =>
          import(
            /* webpackChunkName: "CommunityBoxVault" */ '../views/Communities/CommunityBoxVault'
          ),
        toolbar: () =>
          import(
            /* webpackChunkName: "CommunityVaultHeader" */ '../components/Toolbars/CommunityVaultHeader'
          )
      },
      props: { toolbar: { hasSimulatedPath: true } }
    },
    {
      path: '/communities/members/:id',
      name: 'member',
      components: {
        default: () =>
          import(
            /* webpackChunkName: "member" */ '../views/Communities/Member'
          ),
        toolbar: () =>
          import(
            /* webpackChunkName: "member" */ '../components/Toolbars/MemberHeader'
          )
      }
    },
    {
      path: '/communities/members/:id/edit',
      name: 'memberEdit',
      components: {
        default: () =>
          import(
            /* webpackChunkName: "member" */ '../views/Communities/MemberEdit'
          ),
        toolbar: () =>
          import(
            /* webpackChunkName: "member" */ '../components/Toolbars/MemberHeader'
          )
      }
    },
    {
      path: '/stories',
      name: 'stories',
      components: {
        default: () =>
          import(/* webpackChunkName: "stories" */ '../views/Stories/Stories'),
        toolbar: () =>
          import(
            /* webpackChunkName: "stories" */ '../components/Toolbars/StoriesHeader'
          )
      }
    },
    {
      path: '/stories/:id',
      name: 'showStory',
      components: {
        default: () =>
          import(/* webpackChunkName: "story" */ '../views/Stories/Story'),
        toolbar: () =>
          import(
            /* webpackChunkName: "story" */ '../components/Toolbars/StoryHeader'
          )
      }
    },
    {
      path: '/stories/:id/comments',
      name: 'showStoryWithComments',
      components: {
        default: () =>
          import(/* webpackChunkName: "story" */ '../views/Stories/Story'),
        toolbar: () =>
          import(
            /* webpackChunkName: "story" */ '../components/Toolbars/StoryHeader'
          )
      },
      props: {
        default: { showComments: true }
      }
    },
    {
      path: '/stories/:id/edit',
      name: 'editStory',
      components: {
        default: () =>
          import(/* webpackChunkName: "story" */ '../views/Stories/StoryEdit'),
        toolbar: () =>
          import(
            /* webpackChunkName: "story" */ '../components/Toolbars/StoryEditHeader'
          )
      }
    },
    {
      path: '/mylife',
      name: 'myProfile',
      components: {
        default: () =>
          import(/* webpackChunkName: "mylife" */ '../views/MyLife/MyProfile')
      },
      meta: { hideToolbar: true },
      props: {
        editing: false
      }
    },
    {
      path: '/mylife/my-people',
      name: 'myPeople',
      components: {
        default: () => import('../views/MyLife/MyPeople'),
        toolbar: () => import('../components/Toolbars/MyPeopleHeader')
      }
    },
    {
      path: '/mylife/my-people/:id',
      name: 'myPeoplePersonProfile',
      components: {
        default: () => import('@/views/MyLife/MyPeoplePersonProfile'),
        toolbar: () => import('@/components/Toolbars/MyPeopleHeader')
      },
      props: { toolbar: { hasSimulatedPath: 'myPeople' } }
    },
    {
      path: '/mylife/vault',
      name: 'MyVault',
      components: {
        default: () =>
          import(/* webpackChunkName: "mylife" */ '../views/MyLife/MyVault'),
        toolbar: () =>
          import(
            /* webpackChunkName: "mylife" */ '../components/Toolbars/MyVaultHeader'
          )
      }
    },
    {
      path: '/mylife/vault/box/:boxId',
      name: 'MyBoxVault',
      components: {
        default: () =>
          import(
            /* webpackChunkName: "MyBoxVault" */ '../views/MyLife/MyBoxVault'
          ),
        toolbar: () =>
          import(
            /* webpackChunkName: "CommunityVaultBoxHeader" */ '../components/Toolbars/MyVaultHeader'
          )
      },
      props: { toolbar: { hasSimulatedPath: 'MyVault' } }
    },
    {
      path: '/mylife/invitations',
      name: 'myInvitations',
      components: {
        default: () =>
          import(
            /* webpackChunkName: "mylife" */ '../views/MyLife/MyInvitations'
          ),
        toolbar: () =>
          import(
            /* webpackChunkName: "mylife" */ '../components/Toolbars/MyInvitationHeader'
          )
      }
    }
  ]
})
