### Config

``` bash
docker build -t grammarly .
```

``` bash
docker run -it --net=host \
--env="DISPLAY" \
--volume="$HOME/.Xauthority:/root/.Xauthority:rw" \
--name grammarly grammarly
```
