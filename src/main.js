// SPDX-FileCopyrightText: Julien-Pierre Avérous <nextcloud@sourcemac.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

import { generateFilePath } from '@nextcloud/router'

import Vue from 'vue'
import SimpleVideos from './SimpleVideos.vue'

// eslint-disable-next-line
__webpack_public_path__ = generateFilePath(appName, '', 'js/')


// To interpose our handlers before the embedded ones, we define a custom version of 'OCA.Viewer.registerHandler()' ('/nextcloud-viewer/src/services/Viewer.js') function.
// This way, we can insert our handlers at the array beginning, instead of array end.
// And by doing so, we make sure that embedded ones are rejected (there can be only one handler by mime, as enforced in 'nextcloud-viewer/src/views/Viewer.vue').
function interposeViewerHandler(handler) {
	OCA.Viewer._state.handlers.unshift(handler)
	OCA.Viewer._mimetypes.push.apply(OCA.Viewer._mimetypes, handler.mimes)
}

// Register. Use `interposeViewerHandler()` instead of `OCA.Viewer.registerHandler()` (see previous point).
interposeViewerHandler({
	id: 'simplevideos',

	group: 'media',

	mimes: [
		'video/mpeg',
		'video/ogg',
		'video/webm',
		'video/mp4',
		'video/x-m4v',
		'video/x-flv',
		'video/quicktime',
	],
	
	mimesAliases: {
		'video/x-matroska': 'video/webm',
	},

	component: SimpleVideos
 })
