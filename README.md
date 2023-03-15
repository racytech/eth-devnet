Lighthouse will require [Rust installation and its build tools](https://lighthouse-book.sigmaprime.io/installation-source.html)

Configure `vars.env` to make it work for you and then build binaries:

```
./setup_binaries.sh

# this will clone repos (erigon, lighthouse and prysm) and build binaries
```

after that

```
./start_local_devnet.sh

# this will start 4 (by default) erigon nodes and a single rpcdaemon
# 2 lighthouse beacon and 2 lighthouse validator nodes
# 2 prysm beacon nodes 
# el_bootnode
# cl_bootnode
```

then when needed you can 

```
./stop_local_devnet.sh

# this will stop all processes
```

and 

```
./clean.sh # to remove $DATADIR
```



