/** Play Store URL. Can be overridden via VITE_PLAY_STORE_URL. */
export const PLAY_STORE_URL: string =
  import.meta.env.VITE_PLAY_STORE_URL ??
  "https://play.google.com/store/apps/details?id=com.matchvibe.app&pcampaignid=web_share";

/** Optional direct APK download URL (if you still host one). */
export const APK_DOWNLOAD_URL: string | undefined =
  import.meta.env.VITE_APK_DOWNLOAD_URL;
