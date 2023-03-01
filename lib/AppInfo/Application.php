<?php
declare(strict_types=1);
// SPDX-FileCopyrightText: Julien-Pierre Avérous <nextcloud@sourcemac.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

namespace OCA\SimpleVideos\AppInfo;

use OCP\EventDispatcher\IEventDispatcher;
use OCA\Files\Event\LoadAdditionalScriptsEvent;
use OCA\Files_Sharing\Event\BeforeTemplateRenderedEvent;
use OCP\Util;

use OCP\AppFramework\App;
use OCP\AppFramework\Bootstrap\IRegistrationContext;
use OCP\AppFramework\Bootstrap\IBootContext;
use OCP\AppFramework\Bootstrap\IBootstrap;

class Application extends App {
	public const APP_ID = 'simplevideos';

	public function __construct() {
		parent::__construct(self::APP_ID);
		
		$eventDispatcher = $this->getContainer()->get(IEventDispatcher::class);
		
		// To inject the script in files app.
		$eventDispatcher->addListener(LoadAdditionalScriptsEvent::class, static function() {
			Util::addScript(self::APP_ID, 'simplevideos-main', 'viewer');
		});
		
		// To inject the script in files_sharing app.
		$eventDispatcher->addListener(BeforeTemplateRenderedEvent::class, static function() {
			Util::addScript(self::APP_ID, 'simplevideos-main', 'viewer');
		});
	}
	
	public function register(IRegistrationContext $context): void {
	}

	public function boot(IBootContext $context): void {
	}
}
