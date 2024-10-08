/*
Docs:
- https://developer.mozilla.org/en-US/docs/Mozilla/Preferences
- http://kb.mozillazine.org/User.js_file
- https://gist.github.com/haasn/69e19fc2fe0e25f3cff5
- http://www.comtek4u.com/content/2015/08/18/comprehensive-list-firefox-privacy-and-security-settings

This file comes from https://github.com/pyllyukko/user.js/blob/master/user.js
and was modified sligthlty
*/

/******************************************************************************
 * user.js                                                                    *
 * https://github.com/pyllyukko/user.js                                       *
 ******************************************************************************/

// Starting from FF 69, the user css it not loaded by default, to "improve performance"
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets",		true);

/******************************************************************************
 * HTML5 / APIs / DOM                                                         *
 *                                                                            *
 ******************************************************************************/

// disable Location-Aware Browsing
// http://www.mozilla.org/en-US/firefox/geolocation/
user_pref("geo.enabled",		false);
user_pref("geo.wifi.uri", "");

// http://kb.mozillazine.org/Dom.storage.enabled
// http://dev.w3.org/html5/webstorage/#dom-localstorage
// you can also see this with Panopticlick's "DOM localStorage"
// user_pref("dom.storage.enabled",		false); // breaks too many websites

// Don't reveal internal IPs
// http://net.ipcalf.com/
// user_pref("media.peerconnection.enabled",		false);
// getUserMedia
// https://wiki.mozilla.org/Media/getUserMedia
// https://developer.mozilla.org/en-US/docs/Web/API/Navigator
// user_pref("media.navigator.enabled",		false);
// https://developer.mozilla.org/en-US/docs/Web/API/BatteryManager
// Disable video autoplay
user_pref("media.autoplay.default",		5); // 5 seems to be "block audio and video" now
user_pref("media.block-autoplay-until-in-foreground",		true);
user_pref("media.autoplay.allow-muted",		false);
user_pref("media.autoplay.blackList-override-default",		false);
user_pref("media.autoplay.block-webaudio",		true);
user_pref("media.allowed-to-play.enabled",		false);
user_pref("media.autoplay.enabled.user-gestures-needed",		false);

user_pref("dom.battery.enabled",		false);
// https://wiki.mozilla.org/WebAPI/Security/WebTelephony
user_pref("dom.telephony.enabled",		false);
// https://developer.mozilla.org/en-US/docs/Web/API/navigator.sendBeacon
user_pref("beacon.enabled",		false);
// https://developer.mozilla.org/en-US/docs/Mozilla/Preferences/Preference_reference/dom.event.clipboardevents.enabled
// user_pref("dom.event.clipboardevents.enabled",		false);
// https://wiki.mozilla.org/Security/Reviews/Firefox/NavigationTimingAPI
user_pref("dom.enable_performance",		true); // breaks sites like linkedin
// Disable User Timing API - https://trac.torproject.org/projects/tor/ticket/16336
user_pref("dom.enable_user_timing", false);
// Disable resource/navigation timing
// user_pref("dom.enable_resource_timing", false);

user_pref("dom.webgpu.enabled", false);
// Disable shaking the screen
user_pref("dom.vibrator.enabled", false);
// Max popups from a single non-click event - default is 20!
user_pref("dom.popup_maximum", 3);
// Disable idle observation
user_pref("dom.idle-observers-api.enabled", false);
// 2417: disable SharedWorkers for now - https://www.torproject.org/projects/torbrowser/design/#identifier-linkab... (see no. 8)
// https://bugs.torproject.org/15562 - SharedWorker violates first party isolation
user_pref("dom.workers.sharedWorkers.enabled", false);

// Speech recognition
// https://dvcs.w3.org/hg/speech-api/raw-file/tip/speechapi.html
// https://wiki.mozilla.org/HTML5_Speech_API
user_pref("media.webspeech.recognition.enable",		false);

// Disable getUserMedia screen sharing
// https://mozilla.github.io/webrtc-landing/gum_test.html
user_pref("media.getusermedia.screensharing.enabled",		false);

// Disable sensor API
// https://wiki.mozilla.org/Sensor_API
user_pref("device.sensors.enabled",		false);
user_pref("camera.control.face_detection.enabled", false);

// http://kb.mozillazine.org/Browser.send_pings
user_pref("browser.send_pings",		false);
// this shouldn't have any effect, since we block pings altogether, but we'll set it anyway.
// http://kb.mozillazine.org/Browser.send_pings.require_same_host
user_pref("browser.send_pings.require_same_host",		true);
// Open any new tab at the end of the tabbar (not right to the current one)
user_pref("browser.tabs.insertRelatedAfterCurrent",		false);
// Don't go back to the latest tab when closing one (hazardous when closing multiple tabs)
user_pref("browser.tabs.selectOwnerOnClose",		false);
// Keep Firefox open even with the last tab closed
user_pref("browser.tabs.closeWindowWithLastTab",		false);
// Force title bar display (mandatory to move the windows from a virtual desktop to another, or just to easily see the page title...)
user_pref("browser.tabs.drawInTitlebar",		false);
// Off by default starting from FF94
user_pref("browser.tabs.warnOnClose",		true);
// New tabs are blank, not the useless tiles
user_pref("browser.newtab.url",		"about:blank");
user_pref("browser.newtabpage.activity-stream.enabled",		false);
user_pref("browser.uidensity",		1);


// https://developer.mozilla.org/en-US/docs/IndexedDB
// https://wiki.mozilla.org/Security/Reviews/Firefox4/IndexedDB_Security_Review
// TODO: find out why html5test still reports this as available
// NOTE: this is enabled for now, as disabling this seems to break some plugins.
//       see: http://forums.mozillazine.org/viewtopic.php?p=13842047#p13842047
//user_pref("dom.indexedDB.enabled",		true);

// TODO: "Access Your Location" "Maintain Offline Storage" "Show Notifications"

// Disable gamepad input
// http://www.w3.org/TR/gamepad/
user_pref("dom.gamepad.enabled",		false);

// Disable virtual reality devices
// https://developer.mozilla.org/en-US/Firefox/Releases/36#Interfaces.2FAPIs.2FDOM
user_pref("dom.vr.enabled",		false);

// disable webGL
// http://www.contextis.com/resources/blog/webgl-new-dimension-browser-exploitation/
// user_pref("webgl.disabled",		true);
// somewhat related...
//user_pref("pdfjs.enableWebGL",		false);

// Disable giving away network info
// https://developer.mozilla.org/en-US/docs/Web/API/Network_Information_API
user_pref("dom.netinfo.enabled", false);

// Prevent websites from opening new windows with reduced set of stuff (missing toolbar, non resizable, etc.)
user_pref("dom.disable_window_open_feature.close", true);
user_pref("dom.disable_window_open_feature.location", true);
user_pref("dom.disable_window_open_feature.menubar", true);
user_pref("dom.disable_window_open_feature.minimizable", true);
user_pref("dom.disable_window_open_feature.personalbar", true);
user_pref("dom.disable_window_open_feature.resizable", true);
user_pref("dom.disable_window_open_feature.status", true);
user_pref("dom.disable_window_open_feature.titlebar", true);
user_pref("dom.disable_window_open_feature.toolbar", true);

/******************************************************************************
 * Misc                                                                       *
 *                                                                            *
 ******************************************************************************/

// Home page
user_pref("browser.startup.homepage", "https://duckduckgo.com");
// Default search engine
//user_pref("browser.search.defaultenginename",		"DuckDuckGo");

// http://kb.mozillazine.org/Clipboard.autocopy
user_pref("clipboard.autocopy",		false);

// Display an error message indicating the entered information is not a valid
// URL instead of asking from google.
// http://kb.mozillazine.org/Keyword.enabled#Caveats
user_pref("keyword.enabled",		false);

// Don't try to guess where i'm trying to go!!! e.g.: "http://foo" -> "http://(prefix)foo(suffix)"
// http://www-archive.mozilla.org/docs/end-user/domain-guessing.html
user_pref("browser.fixup.alternate.enabled",		false);

// https://trac.torproject.org/projects/tor/wiki/doc/TorifyHOWTO/WebBrowsers
user_pref("network.proxy.socks_remote_dns",		true);
// Can't connect to website with a certificate from cloudflare otherwise
user_pref("network.dns.echconfig.fallback_to_origin_when_all_failed",		true);

// Disable websockets
// user_pref("network.websocket.max-connections", 0);

// Don't let websites access the available fonts list
// user_pref("browser.display.use_document_fonts", 0); // breaks some extensions (ublock) and websites

// Disable notifications
user_pref("dom.webnotifications.enabled", false);

// Disable "what's new" stuff
user_pref("browser.messaging-system.whatsNewPanel.enabled", false);

// http://kb.mozillazine.org/Network.proxy.type
// the default in Firefox for Linux is to use system proxy settings.
// We change it to direct connection
//user_pref("network.proxy.type", 0);

/* Mixed content stuff
 * https://developer.mozilla.org/en-US/docs/Site_Compatibility_for_Firefox_23#Non-SSL_contents_on_SSL_pages_are_blocked_by_default
 * https://blog.mozilla.org/tanvi/2013/04/10/mixed-content-blocking-enabled-in-firefox-23/
 */
// user_pref("security.mixed_content.block_active_content",		true);
// Mixed Passive Content (a.k.a. Mixed Display Content).
// user_pref("security.mixed_content.block_display_content",		true);

// https://secure.wikimedia.org/wikibooks/en/wiki/Grsecurity/Application-specific_Settings#Firefox_.28or_Iceweasel_in_Debian.29
// Don't exist anymore
// user_pref("javascript.options.methodjit.chrome",		false);
// user_pref("javascript.options.methodjit.content",		false);

// Allows "enterprise" MITM: disable that
user_pref("security.certerrors.mitm.auto_enable_enterprise_roots",		false);
user_pref("security.enterprise_roots.enabled",		false);

// CIS Mozilla Firefox 24 ESR v1.0.0 - 3.7 Disable JAR from opening Unsafe File Types
// http://kb.mozillazine.org/Network.jar.open-unsafe-types
user_pref("network.jar.open-unsafe-types",		false);

// CIS 2.7.4 Disable Scripting of Plugins by JavaScript
user_pref("security.xpconnect.plugin.unrestricted",		false);

// CIS Mozilla Firefox 24 ESR v1.0.0 - 3.8 Set File URI Origin Policy
// http://kb.mozillazine.org/Security.fileuri.strict_origin_policy
user_pref("security.fileuri.strict_origin_policy",		true);

// CIS 2.3.6 Disable Displaying Javascript in History URLs
// http://kb.mozillazine.org/Browser.urlbar.filter.javascript
user_pref("browser.urlbar.filter.javascript",		true);

// Don't hide parts of URLs in the url bar
user_pref("browser.urlbar.trimURLs", false);

// Disable HTML frames
// WARNING: might make your life difficult!
// NOTE: to be removed(?) see: https://bugzilla.mozilla.org/show_bug.cgi?id=729030
//user_pref("browser.frames.enabled",		false);

// http://asmjs.org/
// https://www.mozilla.org/en-US/security/advisories/mfsa2015-29/
// https://www.mozilla.org/en-US/security/advisories/mfsa2015-50/
// https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2015-2712
user_pref("javascript.options.asmjs",		false);

// https://wiki.mozilla.org/SVGOpenTypeFonts
// the iSEC Partners Report recommends to disable this
user_pref("gfx.font_rendering.opentype_svg.enabled",		false);

/******************************************************************************
 * extensions / plugins                                                       *
 *                                                                            *
 ******************************************************************************/

// Flash plugin state - never activate
// user_pref("plugin.state.flash",		0);

// https://wiki.mozilla.org/Firefox/Click_To_Play
// https://blog.mozilla.org/security/2012/10/11/click-to-play-plugins-blocklist-style/
user_pref("plugins.click_to_play",		true);

// Updates addons automatically
// https://blog.mozilla.org/addons/how-to-turn-off-add-on-updates/
user_pref("extensions.update.enabled",		true);

// http://kb.mozillazine.org/Extensions.blocklist.enabled
user_pref("extensions.blocklist.enabled",		true);

// disable add-on metadata updating
user_pref("extensions.getAddons.cache.enabled", false);

// Don't leak plugins installed
user_pref("plugins.enumerable_names", "");

// Remove noise (recommended extensions)
user_pref("extensions.htmlaboutaddons.recommendations.enabled", false);
// Never ask to save payment data
user_pref("dom.payments.defaults.saveCreditCard", false);
user_pref("extensions.formautofill.creditCards.available", false);
user_pref("extensions.formautofill.creditCards.enabled", false);

// Disable recommandations (CFr, Contextual Feature Recommender)
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features", false);

/******************************************************************************
 * firefox features / components                                              *
 *                                                                            *
 ******************************************************************************/

// https://wiki.mozilla.org/Platform/Features/Telemetry
// https://www.mozilla.org/en-US/legal/privacy/firefox.html#telemetry
// https://wiki.mozilla.org/Security/Reviews/Firefox6/ReviewNotes/telemetry
user_pref("toolkit.telemetry.enabled",		false);
user_pref("toolkit.telemetry.server", "");
user_pref("experiments.enabled", false);
user_pref("experiments.manifest.uri", "");
user_pref("experiments.supported", false);
user_pref("experiments.activeExperiment", false);
user_pref("app.normandy.enabled", false); // allows to have remote stuff being transparently downloaded/set locally (by Mozilla)

// https://wiki.mozilla.org/Polaris#Tracking_protection
// https://support.mozilla.org/en-US/kb/tracking-protection-firefox
// TODO: are these two the same?
// user_pref("privacy.trackingprotection.enabled",		true);
// user_pref("browser.polaris.enabled",		true);

// Disable the built-in PDF viewer (CVE-2015-2743)
// https://web.nvd.nist.gov/view/vuln/detail?vulnId=CVE-2015-2743
// user_pref("pdfjs.disabled",		true);

// Disable sending of the health report
// https://support.mozilla.org/en-US/kb/firefox-health-report-understand-your-browser-perf
user_pref("datareporting.healthreport.uploadEnabled",		false);
// disable collection of the data (the healthreport.sqlite* files)
user_pref("datareporting.healthreport.service.enabled",		false);
user_pref("datareporting.healthreport.documentServerURI", "");

// Disable new tab tile ads & preload
// http://www.thewindowsclub.com/disable-remove-ad-tiles-from-firefox
// http://forums.mozillazine.org/viewtopic.php?p=13876331#p13876331
user_pref("browser.newtabpage.enhanced",		false);
user_pref("browser.newtabpage.activity-stream.default.sites",		"");
user_pref("browser.newtab.preload",		false);
// https://wiki.mozilla.org/Tiles/Technical_Documentation#Ping
user_pref("browser.newtabpage.directory.ping",		"");

// disable heartbeat
// https://wiki.mozilla.org/Advocacy/heartbeat
user_pref("browser.selfsupport.url",		"");

// Disable firefox hello
// https://wiki.mozilla.org/Loop
user_pref("loop.enabled",		false);

// Disable crash reports
user_pref("breakpad.reportURL", "");

// CIS 2.1.1 Enable Auto Update
// This is disabled for now. it is better to patch through package management.
//user_pref("app.update.auto", true);

// CIS 2.3.4 Block Reported Web Forgeries
// http://kb.mozillazine.org/Browser.safebrowsing.enabled
// http://kb.mozillazine.org/Safe_browsing
// https://support.mozilla.org/en-US/kb/how-does-phishing-and-malware-protection-work
// http://forums.mozillazine.org/viewtopic.php?f=39&t=2711237&p=12896849#p12896849
user_pref("browser.safebrowsing.enabled",		false);

// CIS 2.3.5 Block Reported Attack Sites
// http://kb.mozillazine.org/Browser.safebrowsing.malware.enabled
user_pref("browser.safebrowsing.malware.enabled",		false);

// Disable safe browsing for downloaded files. this leaks information to google.
// https://www.mozilla.org/en-US/firefox/39.0/releasenotes/
user_pref("browser.safebrowsing.downloads.enabled",		false);

// Disable pocket
// https://support.mozilla.org/en-US/kb/save-web-pages-later-pocket-firefox
user_pref("browser.pocket.enabled",		false);
user_pref("reader.parse-on-load.enabled", false);

// Social media integration
user_pref("social.toast-notifications.enabled", false);
user_pref("social.directories", "");
user_pref("social.whitelist", "");
user_pref("social.remote-install.enabled", false);

// DRM
user_pref("media.eme.enabled", false);
user_pref("media.gmp-eme-adobe.enabled", false);


/******************************************************************************
 * automatic connections                                                      *
 *                                                                            *
 ******************************************************************************/

// Disable link prefetching
// http://kb.mozillazine.org/Network.prefetch-next
// https://developer.mozilla.org/en-US/docs/Web/HTTP/Link_prefetching_FAQ#Is_there_a_preference_to_disable_link_prefetching.3F
user_pref("network.prefetch-next",		false);

// https://support.mozilla.org/en-US/kb/how-stop-firefox-making-automatic-connections#w_geolocation-for-default-search-engine
user_pref("browser.search.geoip.url",		"");

// http://kb.mozillazine.org/Network.dns.disablePrefetch
// https://developer.mozilla.org/en-US/docs/Web/HTTP/Controlling_DNS_prefetching
user_pref("network.dns.disablePrefetch",		true);
user_pref("network.dns.disablePrefetchFromHTTPS",		true);

// https://wiki.mozilla.org/Privacy/Reviews/Necko
user_pref("network.predictor.enabled",		false);

// http://kb.mozillazine.org/Browser.search.suggest.enabled
user_pref("browser.search.suggest.enabled",		false);

// Disable SSDP
// https://bugzil.la/1111967
user_pref("browser.casting.enabled",		false);

// https://support.mozilla.org/en-US/kb/how-stop-firefox-making-automatic-connections#w_media-capabilities
// http://andreasgal.com/2014/10/14/openh264-now-in-firefox/
user_pref("media.gmp-gmpopenh264.enabled",		false);
user_pref("media.gmp-manager.url",		"");

// https://support.mozilla.org/en-US/kb/how-stop-firefox-making-automatic-connections#w_speculative-pre-connections
user_pref("network.http.speculative-parallel-limit",		0);

// https://support.mozilla.org/en-US/kb/how-stop-firefox-making-automatic-connections#w_mozilla-content
user_pref("browser.aboutHomeSnippets.updateUrl",		"");

// https://support.mozilla.org/en-US/kb/how-stop-firefox-making-automatic-connections#w_auto-update-checking
user_pref("browser.search.update",		false);

// Don't ask to associate webmails (zimbra) for mailto links, adding an annoying header bar
user_pref("network.protocol-handler.external.mailto",		false);

/******************************************************************************
 * HTTP                                                                       *
 *                                                                            *
 ******************************************************************************/

// Disallow NTLMv1
// https://bugzilla.mozilla.org/show_bug.cgi?id=828183
user_pref("network.negotiate-auth.allow-insecure-ntlm-v1",		false);
// it is still allowed through HTTPS. uncomment the following to disable it completely.
//user_pref("network.negotiate-auth.allow-insecure-ntlm-v1-https",		false);

// https://bugzilla.mozilla.org/show_bug.cgi?id=855326
user_pref("security.csp.experimentalEnabled",		true);

// CSP https://developer.mozilla.org/en-US/docs/Web/Security/CSP/Introducing_Content_Security_Policy
user_pref("security.csp.enable",		true);

// DNT HTTP header
// http://dnt.mozilla.org/
// https://en.wikipedia.org/wiki/Do_not_track_header
// https://dnt-dashboard.mozilla.org
// https://github.com/pyllyukko/user.js/issues/11
user_pref("privacy.donottrackheader.enabled",		false); // useless anyway

// Disable built-in tracking protection features : it can break sites, and it is done manually (and more strictly) via other extensions
user_pref("browser.contentblocking.category",		"custom");
user_pref("privacy.trackingprotection.enabled",		false);
user_pref("privacy.trackingprotection.cryptomining.enabled",		false);
user_pref("privacy.trackingprotection.pbmode.enabled",		false);
user_pref("privacy.trackingprotection.fingerprinting.enabled",		false);
user_pref("privacy.trackingprotection.socialtracking.enabled",		false);
user_pref("privacy.trackingprotection.origin_telemetry.enabled",		false);

// Disallow websites to perform privacy-preserving ad measurement
user_pref("dom.private-attribution.submission.enabled",		false);

// https://wiki.mozilla.org/Security/Fingerprinting
// Disabled, as it is VERY inconvenient (forces the FF version to the last old ESR even for extensions that complain it's too old, floods with canvas authorizations, silently blocks some standard canvas function, etc.)
// user_pref("privacy.resistFingerprinting",		true);

// http://kb.mozillazine.org/Network.http.sendRefererHeader#0
// https://bugzilla.mozilla.org/show_bug.cgi?id=822869
// Send a referer header with the target URI as the source
// user_pref("network.http.sendRefererHeader",		1); // breaks website (OVH manager for instance) ; handled via an extension (Referrer Control)
// user_pref("network.http.referer.spoofSource",		true);
// CIS Version 1.2.0 October 21st, 2011 2.4.3 Disable Referer from an SSL Website
user_pref("network.http.sendSecureXSiteReferrer",		false);

// Only send the origin in the referer (no path or query parameters)
user_pref("network.http.referer.defaultPolicy",		2);
user_pref("network.http.referer.defaultPolicy.pbmode",		2);
user_pref("network.http.referer.XOriginPolicy",		0);
user_pref("network.http.referer.XOriginTrimmingPolicy",		2);
// Don't allow websites to set their own preferences for the referer strategies
user_pref("network.http.referer.disallowCrossSiteRelaxingDefault",		true);
user_pref("network.http.referer.disallowCrossSiteRelaxingDefault.pbmode",		true);

// CIS 2.5.1 Accept Only 1st Party Cookies (modified: accept all now...)
// http://kb.mozillazine.org/Network.cookie.cookieBehavior#1
user_pref("network.cookie.cookieBehavior",		0); // was set to 1, but this might break a few websites (PSN...) ; cookies handled via an extension anyway to block all but 1st parties by default

// No DNS over HTTPS for now (same as "0" but means "this is my choice to deactivate it")
user_pref("network.trr.mode", 5);

// user-agent
//user_pref("general.useragent.override", "Mozilla/5.0 (Windows NT 6.1; rv:31.0) Gecko/20100101 Firefox/31.0");

/******************************************************************************
 * Caching                                                                    *
 *                                                                            *
 ******************************************************************************/

// Reduce number of cached pages for "back" button
user_pref("browser.sessionhistory.max_entries", 10);

// http://kb.mozillazine.org/Browser.sessionstore.postdata
// NOTE: relates to CIS 2.5.7
// user_pref("browser.sessionstore.postdata",		0);
// http://kb.mozillazine.org/Browser.sessionstore.enabled
// user_pref("browser.sessionstore.enabled",		false);

// http://kb.mozillazine.org/Browser.cache.offline.enable
user_pref("browser.cache.offline.enable",		false);

// Always use private browsing
// https://support.mozilla.org/en-US/kb/Private-Browsing
// https://wiki.mozilla.org/PrivateBrowsing
// user_pref("browser.privatebrowsing.autostart",		true);
// user_pref("extensions.ghostery.privateBrowsing",		true);

// Clear stuff when Firefox closes (mostly handled by extensions though, so not enabled
// much here)
user_pref("privacy.sanitize.sanitizeOnShutdown",		true);
user_pref("privacy.clearOnShutdown.cache",		false);
user_pref("privacy.clearOnShutdown.cookies",		false);
user_pref("privacy.clearOnShutdown.downloads",		true);
user_pref("privacy.clearOnShutdown.formdata",		false);
user_pref("privacy.clearOnShutdown.history",		true);
user_pref("privacy.clearOnShutdown.offlineApps",		false);
user_pref("privacy.clearOnShutdown.openWindows",		false);
user_pref("privacy.clearOnShutdown.passwords",		false);
user_pref("privacy.clearOnShutdown.sessions",		false);
user_pref("privacy.clearOnShutdown.siteSettings",		false);

// don't remember browsing history
// user_pref("places.history.enabled",		false);

// The cookie expires at the end of the session (when the browser closes).
// http://kb.mozillazine.org/Network.cookie.lifetimePolicy#2
// user_pref("network.cookie.lifetimePolicy",		2); // keep session cookies

// http://kb.mozillazine.org/Browser.cache.disk.enable
// user_pref("browser.cache.disk.enable",		false);

// http://kb.mozillazine.org/Browser.cache.memory.enable
//user_pref("browser.cache.memory.enable",		false);

// CIS Version 1.2.0 October 21st, 2011 2.5.8 Disable Caching of SSL Pages
// http://kb.mozillazine.org/Browser.cache.disk_cache_ssl
// user_pref("browser.cache.disk_cache_ssl",		false);

// CIS Version 1.2.0 October 21st, 2011 2.5.2 Disallow Credential Storage
// user_pref("signon.rememberSignons",		false);

// CIS Version 1.2.0 October 21st, 2011 2.5.4 Delete History and Form Data
// http://kb.mozillazine.org/Browser.history_expire_days
// user_pref("browser.history_expire_days",		0);

// http://kb.mozillazine.org/Browser.history_expire_sites
// user_pref("browser.history_expire_sites",		0);

// http://kb.mozillazine.org/Browser.history_expire_visits
// user_pref("browser.history_expire_visits",		0);

// CIS Version 1.2.0 October 21st, 2011 2.5.5 Delete Download History
// Zero (0) is an indication that no download history is retained for the current profile.
user_pref("browser.download.manager.retention",		0);

// CIS Version 1.2.0 October 21st, 2011 2.5.6 Delete Search and Form History
user_pref("browser.formfill.enable",		false);
user_pref("browser.formfill.expire_days",		0);

// CIS Version 1.2.0 October 21st, 2011 2.5.7 Clear SSL Form Session Data
// http://kb.mozillazine.org/Browser.sessionstore.privacy_level#2
// Store extra session data for unencrypted (non-HTTPS) sites only.
// NOTE: CIS says 1, we use 2
user_pref("browser.sessionstore.privacy_level",		2);

// https://bugzil.la/238789#c19
user_pref("browser.helperApps.deleteTempFileOnExit",		true);

/******************************************************************************
 * UI related                                                                 *
 *                                                                            *
 ******************************************************************************/

// Webpages will not be able to affect the right-click menu
//user_pref("dom.event.contextmenu.enabled",		false);

// CIS 2.3.2 Disable Downloading on Desktop
user_pref("browser.download.folderList",		2);

// always ask the user where to download
// https://developer.mozilla.org/en/Download_Manager_preferences
user_pref("browser.download.useDownloadDir",		false);

// https://wiki.mozilla.org/Privacy/Reviews/New_Tab
user_pref("browser.newtabpage.enabled",		false);
// https://support.mozilla.org/en-US/kb/new-tab-page-show-hide-and-customize-top-sites#w_how-do-i-turn-the-new-tab-page-off
user_pref("browser.newtab.url",		"about:blank");

// CIS Version 1.2.0 October 21st, 2011 2.1.2 Enable Auto Notification of Outdated Plugins
// https://wiki.mozilla.org/Firefox3.6/Plugin_Update_Awareness_Security_Review
// user_pref("plugins.update.notifyUser",		true); // Annoying new tab at each startup !

// CIS Version 1.2.0 October 21st, 2011 2.1.3 Enable Information Bar for Outdated Plugins
user_pref("plugins.hide_infobar_for_outdated_plugin",		false);

// CIS Version 1.2.0 October 21st, 2011 2.2.3 Enable Warning of Using Weak Encryption
user_pref("security.warn_entering_weak",		true);

// CIS Mozilla Firefox 24 ESR v1.0.0 - 3.6 Enable IDN Show Punycode
// http://kb.mozillazine.org/Network.IDN_show_punycode
user_pref("network.IDN_show_punycode",		true);

user_pref("browser.urlbar.suggest.bookmark", true);
user_pref("browser.urlbar.suggest.engines", false);
user_pref("browser.urlbar.suggest.history", false);
user_pref("browser.urlbar.suggest.history.onlyTyped", false);
user_pref("browser.urlbar.suggest.openpage", false);
user_pref("browser.urlbar.suggest.quicksuggest", false);
user_pref("browser.urlbar.suggest.quicksuggest.sponsored", false);
user_pref("browser.urlbar.suggest.searches", false);
user_pref("browser.urlbar.suggest.topsites", false);

// http://kb.mozillazine.org/About:config_entries#Browser
// http://kb.mozillazine.org/Inline_autocomplete
user_pref("browser.urlbar.autoFill",		true); // limited to bookmarks
user_pref("browser.urlbar.autoFill.typed",		false);

// http://www.labnol.org/software/browsers/prevent-firefox-showing-bookmarks-address-location-bar/3636/
// http://kb.mozillazine.org/Browser.urlbar.maxRichResults
// "Setting the preference to 0 effectively disables the Location Bar dropdown entirely."
user_pref("browser.urlbar.maxRichResults",		0);

// https://blog.mozilla.org/security/2010/03/31/plugging-the-css-history-leak/
// http://dbaron.org/mozilla/visited-privacy
user_pref("layout.css.visited_links_enabled",		false);

// http://kb.mozillazine.org/Places.frecency.unvisited%28place_type%29Bonus

// http://kb.mozillazine.org/Disabling_autocomplete_-_Firefox#Firefox_3.5
user_pref("browser.urlbar.autocomplete.enabled",		true);

// http://kb.mozillazine.org/Signon.autofillForms
// https://www.torproject.org/projects/torbrowser/design/#identifier-linkability
user_pref("signon.autofillForms",		false);

// Stop displaying all other subdomains' passwords everywhere
user_pref("signon.includeOtherSubdomainsInLookup",		false);

// Don't autogenerate new passwords (done externally)
user_pref("signon.generation.enabled",		false);

// do not check if firefox is the default browser
user_pref("browser.shell.checkDefaultBrowser",		false);

// https://developer.mozilla.org/en/Preferences/Mozilla_preferences_for_uber-geeks
// see also CVE-2009-3555
user_pref("security.ssl.warn_missing_rfc5746",		1);

// CIS Version 1.2.0 October 21st, 2011 2.5.3 Disable Prompting for Credential Storage
// user_pref("security.ask_for_password",		0);

// Don't try paste and open/load stuff via the middle click
user_pref("middlemouse.contentLoadURL", false);


/******************************************************************************
 * TLS / HTTPS / OCSP related stuff                                           *
 *                                                                            *
 ******************************************************************************/

// https://blog.mozilla.org/security/2012/11/01/preloading-hsts/
// https://wiki.mozilla.org/Privacy/Features/HSTS_Preload_List
user_pref("network.stricttransportsecurity.preloadlist",		true);

// enable SPDY
// https://en.wikipedia.org/wiki/SPDY
user_pref("network.http.spdy.enabled",		true);
user_pref("network.http.spdy.enabled.v3",		true);
user_pref("network.http.spdy.enabled.v3-1",		true);

// CIS Version 1.2.0 October 21st, 2011 2.2.4 Enable Online Certificate Status Protocol
user_pref("security.OCSP.enabled",		1);

// https://blog.mozilla.org/security/2013/07/29/ocsp-stapling-in-firefox/
user_pref("security.ssl.enable_ocsp_stapling",		true);

// require certificate revocation check through OCSP protocol.
// NOTICE: this leaks information about the sites you visit to the CA.
// user_pref("security.OCSP.require",		true);

// https://www.blackhat.com/us-13/briefings.html#NextGen
user_pref("security.enable_tls_session_tickets",		false);

// TLS 1.[012]
// http://kb.mozillazine.org/Security.tls.version.max
// 1 = TLS 1.0 is the minimum required / maximum supported encryption protocol. (This is the current default for the maximum supported version.)
// 2 = TLS 1.1 is the minimum required / maximum supported encryption protocol.
user_pref("security.tls.version.min",		1);
user_pref("security.tls.version.max",		3);

// disable SSLv3 (CVE-2014-3566)
user_pref("security.enable_ssl3",		false);

// pinning
// https://wiki.mozilla.org/SecurityEngineering/Public_Key_Pinning#How_to_use_pinning
// "2. Strict. Pinning is always enforced."
user_pref("security.cert_pinning.enforcement_level",		2);

// https://wiki.mozilla.org/Security:Renegotiation#security.ssl.treat_unsafe_negotiation_as_broken
// see also CVE-2009-3555
user_pref("security.ssl.treat_unsafe_negotiation_as_broken",		true);

// https://wiki.mozilla.org/Security:Renegotiation#security.ssl.require_safe_negotiation
// this makes browsing next to impossible=) (13.2.2012)
// update: the world is not ready for this! (6.5.2014)
// see also CVE-2009-3555
//user_pref("security.ssl.require_safe_negotiation",		true);

// https://support.mozilla.org/en-US/kb/certificate-pinning-reports
//
// we could also disable security.ssl.errorReporting.enabled, but I think it's
// good to leave the option to report potentially malicious sites if the user
// chooses to do so.
//
// you can test this at https://pinningtest.appspot.com/
user_pref("security.ssl.errorReporting.automatic",		false);

/******************************************************************************
 * CIPHERS                                                                    *
 *                                                                            *
 * you can debug the SSL handshake with tshark: tshark -t ad -n -i wlan0 -T text -V -R ssl.handshake
 ******************************************************************************/

// disable null ciphers
user_pref("security.ssl3.rsa_null_sha",		false);
user_pref("security.ssl3.rsa_null_md5",		false);
user_pref("security.ssl3.ecdhe_rsa_null_sha",		false);
user_pref("security.ssl3.ecdhe_ecdsa_null_sha",		false);
user_pref("security.ssl3.ecdh_rsa_null_sha",		false);
user_pref("security.ssl3.ecdh_ecdsa_null_sha",		false);

/* SEED
 * https://en.wikipedia.org/wiki/SEED
 */
user_pref("security.ssl3.rsa_seed_sha",		false);

// 40 bits...
user_pref("security.ssl3.rsa_rc4_40_md5",		false);
user_pref("security.ssl3.rsa_rc2_40_md5",		false);

// 56 bits
user_pref("security.ssl3.rsa_1024_rc4_56_sha",		false);

// 128 bits
user_pref("security.ssl3.rsa_camellia_128_sha",		false);
user_pref("security.ssl3.ecdhe_rsa_aes_128_sha",		false);
user_pref("security.ssl3.ecdhe_ecdsa_aes_128_sha",		false);
user_pref("security.ssl3.ecdh_rsa_aes_128_sha",		false);
user_pref("security.ssl3.ecdh_ecdsa_aes_128_sha",		false);
user_pref("security.ssl3.dhe_rsa_camellia_128_sha",		false);
user_pref("security.ssl3.dhe_rsa_aes_128_sha",		false);

// RC4 (CVE-2013-2566)
user_pref("security.ssl3.ecdh_ecdsa_rc4_128_sha",		false);
user_pref("security.ssl3.ecdh_rsa_rc4_128_sha",		false);
user_pref("security.ssl3.ecdhe_ecdsa_rc4_128_sha",		false);
user_pref("security.ssl3.ecdhe_rsa_rc4_128_sha",		false);
user_pref("security.ssl3.rsa_rc4_128_md5",		false);
user_pref("security.ssl3.rsa_rc4_128_sha",		false);
// https://developer.mozilla.org/en-US/Firefox/Releases/38#Security
// https://bugzil.la/1138882
// https://rc4.io/
user_pref("security.tls.unrestricted_rc4_fallback",		false);

/*
 * 3DES -> false because effective key size < 128
 *
 *   https://en.wikipedia.org/wiki/3des#Security
 *   http://en.citizendium.org/wiki/Meet-in-the-middle_attack
 *
 *
 * See also:
 *
 * http://www-archive.mozilla.org/projects/security/pki/nss/ssl/fips-ssl-ciphersuites.html
 */
user_pref("security.ssl3.dhe_dss_des_ede3_sha",		false);
user_pref("security.ssl3.dhe_rsa_des_ede3_sha",		false);
user_pref("security.ssl3.ecdh_ecdsa_des_ede3_sha",		false);
user_pref("security.ssl3.ecdh_rsa_des_ede3_sha",		false);
user_pref("security.ssl3.ecdhe_ecdsa_des_ede3_sha",		false);
user_pref("security.ssl3.ecdhe_rsa_des_ede3_sha",		false);
user_pref("security.ssl3.rsa_des_ede3_sha",		false);
user_pref("security.ssl3.rsa_fips_des_ede3_sha",		false);

// Ciphers with ECDH (without /e$/)
user_pref("security.ssl3.ecdh_rsa_aes_256_sha",		false);
user_pref("security.ssl3.ecdh_ecdsa_aes_256_sha",		false);

// 256 bits without PFS
user_pref("security.ssl3.rsa_camellia_256_sha",		false);

// Ciphers with ECDHE and > 128bits
user_pref("security.ssl3.ecdhe_rsa_aes_256_sha",		true);
user_pref("security.ssl3.ecdhe_ecdsa_aes_256_sha",		true);

// GCM, yes please!
user_pref("security.ssl3.ecdhe_ecdsa_aes_128_gcm_sha256",		true);
user_pref("security.ssl3.ecdhe_rsa_aes_128_gcm_sha256",		true);

// Susceptible to the logjam attack - https://weakdh.org/
user_pref("security.ssl3.dhe_rsa_camellia_256_sha",		false);
user_pref("security.ssl3.dhe_rsa_aes_256_sha",		false);

// Ciphers with DSA (max 1024 bits)
user_pref("security.ssl3.dhe_dss_aes_128_sha",		false);
user_pref("security.ssl3.dhe_dss_aes_256_sha",		false);
user_pref("security.ssl3.dhe_dss_camellia_128_sha",		false);
user_pref("security.ssl3.dhe_dss_camellia_256_sha",		false);

// Fallbacks due compatibility reasons
user_pref("security.ssl3.rsa_aes_256_sha",		true);
user_pref("security.ssl3.rsa_aes_128_sha",		true);

// Temporary for old websites, until they are fixed...
user_pref("security.ssl3.dhe_rsa_aes_128_sha", true);
user_pref("security.ssl3.dhe_rsa_aes_256_sha", true);


/******************************************************************************
 * Extensions                                                                 *
 *                                                                            *
 ******************************************************************************/

user_pref("extensions.foxyproxy.socks_remote_dns", true);
user_pref("noscript.forbidWebGL", true);
user_pref("noscript.global", true);
user_pref("noscript.notify", false);
user_pref("noscript.notify.bottom", false);
user_pref("noscript.firstRunRedirection", false);

