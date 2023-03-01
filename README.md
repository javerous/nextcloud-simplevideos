# Simple Videos
Use the native browser video player instead of Plyr video player in Nextcloud to play videos.



#### Build

```
make && make appstore
```



#### Install

- Extract the `build/artifacts/appstore/nextcloud-simplevideos.tar.gz` file in your server `nextcloud/apps` directory.
    ```
    cd nextcloud/apps
    tar xzvf /path/to/nextcloud-simplevideos.tar.gz
    ```

- Go to `https://<your-server>/nextcloud/index.php/settings/apps`
- Install `Simple Videos`

Videos will now be played with your native browser player instead of Plyr player.

