import { delay } from "@/utils/functions"

export default {
    data() {
        return {
            isLoading: false
        }
    },
    methods: {
        onLoading() {
            this.isLoading = true
        },
        async onLoaded(timeout = 300,clb) {
            await delay(timeout)
            this.isLoading = false
            clb && clb()
        }
    },
}